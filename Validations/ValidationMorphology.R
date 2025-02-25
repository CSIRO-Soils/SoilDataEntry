


# conInfo <- OS$DB$Config$getCon(OS$DB$Config$DBNames$NSMP_HoldingRW)

# config='NSMP'
# fname <- 'C:/Projects/SiteDataEntryTool/bbb Data Entry Template - NSMP_Capital.xlsx'
# fname <- 'C:/Projects/SiteDataEntryTool/bbb No Errors Data Entry Template - NSMP_Capital.xlsx'
# fname <- 'C:/Temp/a/Data Entry Template - NSMP_NSMP_Capital.xlsx'

# keys <- list()
# keys$AgencyCode <- '994'
# keys$ProjectCode <- 'SLAM'
# keys$Token = 'Capital'


get_ValidateMorphologyData <- function(){
  
  dv <- list()

  ###########   Validate the Morphology Data  ####################################
  
  dv$ValidateSites <- function(fname, config, keys){
    
    #horizonDataSection = 8:42
    
    
    wb <- openxlsx::loadWorkbook(file.path(fname) )
    sheets <- names(wb)
    

        withProgress(message = paste0('Validating soil data ....'), value = 0,  max=length(sheets)*2, {
        setProgress(0, detail = paste("Reading data ..."))

    
    idxs <- match(OS$Constants$Sheetnames, sheets)
    siteSheets <- sheets[-idxs]
    
    excelInfo <- OS$IngestHelpers$getExcelFormInfo(fname)
    tablesInSheet <- unique(excelInfo$tableName)
    
    appcon <- OS$DB$Config$getCon(OS$DB$Config$DBNames$AppDB)$Connection
    cds <<- OS$DB$Helpers$doQuery(appcon, 'Select * from NatSoil_UnifiedCodes')
    
    tableLevels <- openxlsx::readWorkbook(xlsxFile = fname, sheet = 'DBTableLevels', skipEmptyRows = F, skipEmptyCols = F)
    idxs <- which(tableLevels$Table %in% tablesInSheet)
    tableLevelsInSheet <- tableLevels[idxs,]
    
    tableLevelsInSheet <- tableLevelsInSheet[order(tableLevelsInSheet$Level),] 
    
    
    if(config=='NSMP'){
        con <- OS$DB$Config$getCon(OS$DB$Config$DBNames$NatSoilStageRO)$Connection
        dfs <- OS$DB$Helpers$doQuery(con, paste0("select * from project.PROPOSED_SITES where ps_token='", keys$Token, "'"))
        allowedSites <<- dfs$s_id
        dbDisconnect(con)
        
       publishedSites <- OS$PublishSitesToNatSoil$getDraftOrPublishedSites(type='Published', keys=keys)$s_id
    }
    
    dbDisconnect(appcon)
    

    
    #############################   Check site names validity  ####
    
    
    odf <- data.frame()
    itCnt=0
    
    #### Check Site Name validity   #########
    if(config=='NSMP'){
          rl <-  checkSiteNameValidity(fname, itCnt, siteSheets, excelInfo, odf, config, allowedSites)
    }else{
          rl <-  checkSiteNameValidity(fname, itCnt, siteSheets, excelInfo, odf, config, allowedSites=NULL)
    }
    
   odf <- rl$ODF
   itCnt <- rl$itcnt
    
    
    
    #######  Check site data validity ####
    
    sheetsWithData=0

    sitesDF <- data.frame(x=numeric(), y=numeric(), sitename=character())
    
    for (s in 1:length(siteSheets)) {
      
      itCnt <- itCnt + 1
      print(paste0('Validating site data ', s))
      sn <- siteSheets[s]
      dataSheet <- openxlsx::readWorkbook(xlsxFile = fname, sheet=sn, skipEmptyRows = F, skipEmptyCols = F)
      
      siteAlreadyPublished=F
      if(config=='NSMP'){
        loc <- excelInfo[excelInfo$dbFld=='s_id',]
        sid <- dataSheet[loc$row, loc$col]
        if(sid %in% publishedSites){
          siteAlreadyPublished=T
          r <- list()
          r$tableName = ''
          r$dbFld = ''
          r$recNum = ''
          r$recSubNum = ''
          odf <- message(sid, r, odf, sid,'Warning', paste0('Site ', sid, ' is  already published. It will not be ingested and can no longer be edited with this App.'))
        }
      }
      
      if(siteAlreadyPublished){
        
      }else{
      
      if(SheetHasData(dataSheet, excelInfo)){
        
        
        #### Check depths validity
        odf <- CheckDepths(dataSheet, sheetName=sn, excelInfo, odf)
        #### Check field tests validity
        odf <- CheckFieldTests(dataSheet, sheetName=sn, excelInfo, odf)
        

        for (j in 1:nrow(tableLevelsInSheet)) {
          tab <- tableLevelsInSheet[j,]$Table
          flds <- excelInfo[excelInfo$tableName==tab,]
          
          for (k in 1:nrow(flds)) {
            r <- flds[k,]
            
              odf <- validateCell(row=r$row, col=r$col, dataSheet, r, odf, sn, config)
          }
        }
        
       
        
        ###  Add sites to a SF dataframe
        rlat <- excelInfo[excelInfo$dbFld=='o_latitude_GDA94',]
        y <- dataSheet[rlat$row, rlat$col]
        rlng <- excelInfo[excelInfo$dbFld=='o_longitude_GDA94',]
        x <- dataSheet[rlng$row, rlng$col]
        
        
        if(check.numeric(x) & check.numeric(y)){
          sloc <- c(x, y, sn)
          sitesDF[nrow(sitesDF) + 1,] <- sloc
        }
        sheetsWithData = sheetsWithData + 1
      }else{
        
      }
    }
      
#  setProgress(itCnt, detail = paste("Site ", s, ' of ', length(siteSheets)))
    }
    
    
    if(nrow(sitesDF)>0){
        sitesDF$ErrorCnt <- 0
    
        #### Put the number of errors for each site into the spatial DF
        sitesWithErrorsCnt=0
        for (i in 1:nrow(sitesDF)) {
          s <- sitesDF$sitename[i]
          idxs <- which(odf$Site==s & odf$Result=='Error')
          
          if(length(idxs)>0){
            sitesDF[i,]$ErrorCnt <- length(idxs)
            sitesWithErrorsCnt=sitesWithErrorsCnt+1
          }
        }
    }else{
      
      r <- list()
      r$tableName = ''
      r$dbFld = ''
      r$recNum = ''
      r$recSubNum = ''
      odf <- message('', r, odf, sid,'Error', paste0('There are no sites in the spreadsheet that are able to be imported into the DB'))
      sitesWithErrorsCnt=0
    }
    

    if(nrow(odf)==0)
    {
      errorCnt=0
    } else {
      errors <- odf[odf$Result=='Error', ] 
      if(nrow(errors)==0){
        errorCnt=0
      }else{
        errorCnt = nrow(errors)
      }
    }
    
    ol <- list()
    ol$Type='Validation'
    ol$ErrorCount = errorCnt
    ol$validationResultsTable <- odf
    ol$Sites <- sitesDF
    ol$SitesWithErrorCnt <- sitesWithErrorsCnt
    ol$sheetsWithData <- sheetsWithData
    ol$NumSheets <- length(siteSheets)
    

    return(ol)
    
    })
    
  }
  
  return(dv)
}
  
  
 validateCell <- function( row, col, dataSheet, r, odf, sn, config){
    
   val = dataSheet[row, col]
   missing <- checkIfRequired(row, col, dataSheet, val, r, odf, sn)
   if(missing){
     odf <- message(val, r, odf, sn, type='Error', msg='Value is required.')
     return(odf)
   }
   
   if(!is.na(val)){
      odf <- validateCode(val, r, odf, sn)
   }
   
   if(!is.na(val)){
     if(config=='NSMP'){
       odf <- checkNSMPSpecificRules(val, r, odf, sn)
     }
   }
   
   if(!is.na(val)){
      odf <- checkRules(val, r, odf, sn)
   }
   
   return(odf)
 }
 
 

  
 message <- function(val, r, odf, sn, type, msg){
   e=list()
   e$Result = type
   e$Site = sn
   e$Value = val
   e$Table = r$tableName
   e$Field = r$dbFld
   e$RecNum =r$recNum
   e$RecSnum =r$recSubNum
   e$Issue = msg
   odf <- rbind(odf, data.frame(e) )
   return(odf)
 }
 
