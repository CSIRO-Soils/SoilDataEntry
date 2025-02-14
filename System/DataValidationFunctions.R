


# conInfo <- OS$DB$Config$getCon(OS$DB$Config$DBNames$NSMP_HoldingRW)
#fname <- 'C:/Users/sea084/OneDrive - CSIRO/RossRCode/Git/Shiny/Apps/NationalSoilMonitoring/NSMData/www/Configs/NSMP/Data Entry Template - NSMP.xlsx'
#fname <- 'C:/Users/sea084/OneDrive - CSIRO/RossRCode/Git/Shiny/Apps/NationalSoilMonitoring/NSMData/www/Configs/NSMP/Errors - Entry Template - NSMP.xlsx'
#fname <- 'C:/Projects/SiteDataEntryTool/NoErrors - PacificSoils.xlsx'


#fname <- 'C:/Projects/SiteDataEntryTool/No Errors -  Entry Template - NSMP.xlsx'
#setwd('C:/Users/sea084/OneDrive - CSIRO/RossRCode/Git/Shiny/Apps/SoilDataEntry')

#fname='C:/Temp/Data Entry Template - NSMP_NSMP_Capital.xlsx'
#fname='C:/Users/sea084/OneDrive - CSIRO/RossRCode/Git/Shiny/Apps/SoilDataEntry/www/Configs/PacificSoils/Lab Data Entry Template - PacificSoils.xlsx'


# fname = 'C:/Projects/SiteDataEntryTool/Validation Testing - NSMP - Burnie.xlsx'



get_DataValidationFunctions <- function(){
  
  dv <- list()
  
  dv$Constants$Sheetnames <- c('Template', "TemplateOriginal","About", "Filled Example", "Codes", "DBInfo", "DBTableLevels" )
  dv$RequiredLabFields <- c('AgencyCode', 'ProjectCode', 'SiteID', 'ObservationID', 'HorizonNumber', 'SampleNumber', 'UpperDepth', 'LowerDepth')

  dv$ValidateLabData <- function(fname, config){
    
    
    ld <- openxlsx::readWorkbook(xlsxFile = fname, sheet = 'Lab Data', skipEmptyRows = F, skipEmptyCols = F)
    
    agencyCode = ld[1,1]
    projectCode = ld[1,2]
    
    conInfo <- OS$DB$Config$getCon(OS$DB$Config$DBNames$NatSoilStageRO)$Connection
    conStaging <- OS$DB$Config$getCon(OS$DB$Config$DBNames$PacificSoils)$Connection
    
    AvailMeths <- OS$DB$NatSoilQueries$getLabMethods(conInfo)
    sheetMeths <- colnames(ld[9:ncol(ld)])
    idxs <- which(!sheetMeths %in% AvailMeths$LABM_CODE )
    
    
    ####  check that provided lab method codes are legitimate
    odf <- data.frame()
    if(length(idxs)>0){
      r<-list()
      r$Table = 'LAB_RESULTS'
      r$Field = 'labm_code'
      r$RecNum =''
      r$RecSnum =''
      em <- paste0('Lab methods ', paste0(sheetMeths[idxs], collapse = '; '), ' are not valid lab method codes')
      odf <-  message( val='', r, odf, '',  'Error', em)
    }
    
    
    #### Check that sites are in the DB already
    sql <- paste0("select s_id from SITES where proj_code='", agencyCode, "' and proj_code='", projectCode, "'" )
    sites <- OS$DB$Helpers$doQuery(conStaging, sql)
    sheetSites <- unique(ld$SiteID)
    
    for(i in 1:length(sheetSites)){
      site <- sheetSites[i]
      if(!site %in% sites){
        r<-list()
        r$Table = 'LAB_RESULTS'
        r$Field = ''
        r$RecNum =''
        r$RecSnum =''
        odf <-  message( val= paste0("Site Id = ", rec$SiteID), r, odf, '',  'Error', "Site not on the Staging Database")
      }  
   }
    
    
  
    dbDisconnect(conStaging)
    dbDisconnect(conInfo)
    }
  
  

  ###########   Validate the Morphology Data  ####################################
  
  dv$ValidateSites <- function(fname, config, keys){
    
    horizonDataSection = 8:42
    
    wb <- openxlsx::loadWorkbook(file.path(fname) )
    sheets <- names(wb)
    
    withProgress(message = paste0('Validating soil data ....'), value = 0,  max=length(sheets)*2, {
    setProgress(0, detail = paste("Reading data ..."))
    
    
    idxs <- match(OS$Validation$Constants$Sheetnames, sheets)
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
      print(paste0('Validating site data', s))
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
        odf <- CheckDepths(dataSheet, sheetName=sn, excelInfo, odf, horizonDataSection)
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
      
#      setProgress(itCnt, detail = paste("Site ", s, ' of ', length(siteSheets)))
    }
    
    
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
   
   # if(!is.na(val)){
   #    odf <- validateCode(val, r, odf, sn)
   # }
   
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
 
  
# getVals<- function(table, attribute, domain=NULL){ 
#     
#     
#     if(nrow(table)==0){return("")}
#     
#     if(attribute=='s_date_desc'){
#       v <- table[attribute][1]
#       return(format(v, format="%B %d %Y"))
#     }
#     
#     oVal <- ''
#     for(k in 1:nrow(table)){
#       recNum=k
#       
#       v <- as.character(table[attribute][recNum,])
#       if(is.null(v) | is.na(v) | length(v) ==0 ){
#         # return('')
#         ov = ''
#       }else{
#         if(is.null(domain)){
#           if(v=='NULL'){
#             #return('')
#             ov= ''
#           }else{
#             #return(v)
#             ov=v
#           }
#           
#         }else{
#           
#           if(v=='NULL'){
#             #return('')
#             ov=''
#           }
#           
#           cds <- codes[codes$CODE_DOMAIN==domain,]
#           if(nrow(cds>0)){
#             dec <- cds[cds$CODE_VALUE==v,]
#             if(nrow(dec)==0){
#               #return(v)
#               ov <- ''
#             }else{
#               desc <- dec$CODE_DESC
#               #return(desc)
#               ov <- desc
#             }
#           }else{
#             #return(v)
#             ov <- v
#           }
#         }
#       }
#       
#       if(ov!='')
#         oVal <- paste0(oVal, ov, ', ')
#     }
#     
#     oVal2 <- str_sub(oVal, 1, nchar(oVal)-2)
#     
#     return(oVal2)
#   }
  
  
#   return(dv)
# }