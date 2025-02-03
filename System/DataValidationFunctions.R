


# conInfo <- OS$DB$Config$getCon(OS$DB$Config$DBNames$NSMP_HoldingRW)
#fname <- 'C:/Users/sea084/OneDrive - CSIRO/RossRCode/Git/Shiny/Apps/NationalSoilMonitoring/NSMData/www/Configs/NSMP/Data Entry Template - NSMP.xlsx'
#fname <- 'C:/Users/sea084/OneDrive - CSIRO/RossRCode/Git/Shiny/Apps/NationalSoilMonitoring/NSMData/www/Configs/NSMP/Errors - Entry Template - NSMP.xlsx'
#fname <- 'C:/Projects/SiteDataEntryTool/NoErrors - PacificSoils.xlsx'


#fname <- 'C:/Users/sea084/OneDrive - CSIRO/RossRCode/Git/Shiny/Apps/SoilDataEntry/www/Configs/NSMP/No Errors -  Entry Template - NSMP.xlsx'
#setwd('C:/Users/sea084/OneDrive - CSIRO/RossRCode/Git/Shiny/Apps/SoilDataEntry')

get_DataValidationFunctions <- function(){
  
  dv <- list()
  
  dv$Constants$Sheetnames <- c('Template', "TemplateOriginal","About", "Filled Example", "Codes", "DBInfo", "DBTableLevels" )
  
  dv$SummariseValidation <- function(){
    
  }
  
  
  dv$ValidateSites <- function(fname, config, token){
    
    
    wb <- openxlsx::loadWorkbook(file.path(fname) )
    sheets <- names(wb)
    
    withProgress(message = paste0('Validating soil data ....'), value = 0,  max=length(sheets)*2, {
    incProgress(1, detail = paste("Reading data ..."))
   
    
    
    idxs <- match(OS$Validation$Constants$Sheetnames, sheets)
    siteSheets <- sheets[-idxs]
    
    excelInfo <- OS$IngestHelpers$getExcelFormInfo(fname)
    tablesInSheet <- unique(excelInfo$tableName)
    
    appcon <- OS$DB$Config$getCon(OS$DB$Config$DBNames$AppDB)$Connection
    cds <<- OS$DB$Helpers$doQuery(appcon, 'Select * from NatSoil_UnifiedCodes')
    
    #tableLevels <- as.data.frame(suppressMessages( read_excel(fname, sheet = 'DBTableLevels', col_names = T)))
    tableLevels <- openxlsx::readWorkbook(xlsxFile = fname, sheet = 'DBTableLevels', skipEmptyRows = F, skipEmptyCols = F)
    idxs <- which(tableLevels$Table %in% tablesInSheet)
    tableLevelsInSheet <- tableLevels[idxs,]
    
    tableLevelsInSheet <- tableLevelsInSheet[order(tableLevelsInSheet$Level),] 
    
    
    if(config=='NSMP'){
        con <- OS$DB$Config$getCon(OS$DB$Config$DBNames$NatSoilStageRO)$Connection
        dfs <- OS$DB$Helpers$doQuery(con, paste0("select * from project.PROPOSED_SITES where ps_token='", token, "'"))
        allowedSites <<- dfs$s_id
        dbDisconnect(con)
    }
    
    dbDisconnect(appcon)
    
    #incProgress(0, detail = paste("Reading data ..."))
    
    #############################   Check site names validity  ####
    
    itCnt=0
    
    odf <- data.frame()
    
    usedSiteList <<- list()
    for (s in 1:length(siteSheets)) {
      itCnt <- itCnt + 1
     # incProgress(itCnt, detail = paste("Checking site names - Site ", s, ' of ', length(siteSheets)))
      
      print(paste0('Validating ', s))
      sn <- siteSheets[s]
      #dataSheet <- as.data.frame(suppressMessages( readxl::read_excel(fname, sheet = sn, col_names = F)))
      dataSheet <- openxlsx::readWorkbook(xlsxFile = fname, sheet=sn, skipEmptyRows = F, skipEmptyCols = F)
      
      r <- excelInfo[excelInfo$dbFld == 's_id',]
      val=dataSheet[r$row,r$col]
      
      if(SheetHasData(dataSheet, excelInfo)){
        
        if(config=='NSMP'){
            if(!val %in% allowedSites){
              odf <- message(val, r, odf, sn, type='Error', msg='Site ID not in the allowed list of sites')
            }
        }
        
        if(val %in% usedSiteList){
          odf <- message(val, r, odf, sn, type='Error', msg='Duplicate Site ID')
        }else{
          usedSiteList <- c(usedSiteList, sn)
        }
        
      }
    }
    
    
    
    #######  Check site data validity ####
    
    sheetsWithData=0

    sitesDF <- data.frame(x=numeric(), y=numeric(), sitename=character())
    
    for (s in 1:length(siteSheets)) {
      
      itCnt <- itCnt + 1
      print(paste0('Validating ', s))
      sn <- siteSheets[s]
      #dataSheet <- as.data.frame(suppressMessages( read_excel(fname, sheet = sn, col_names = F)))
      dataSheet <- openxlsx::readWorkbook(xlsxFile = fname, sheet=sn, skipEmptyRows = F, skipEmptyCols = F)
      
      
      if(SheetHasData(dataSheet, excelInfo)){
        
        for (j in 1:nrow(tableLevelsInSheet)) {
          tab <- tableLevelsInSheet[j,]$Table
          flds <- excelInfo[excelInfo$tableName==tab,]
          
          for (k in 1:nrow(flds)) {
            r <- flds[k,]
              odf <- validateCell(row=r$row, col=r$col, dataSheet, r, odf, sn, config)
          }
        }
        
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
      
    #  incProgress(itCnt, detail = paste("Site ", s, ' of ', length(siteSheets)))
    }
    
    #oedf <- odf[odf$Result=='Error',]
    
    
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
   
   if(config=='NSMP'){
     odf <- checkNSMPSpecificRules(val, r, odf, sn)
   }
   
   odf <- checkRules(val, r, odf, sn)
   
   return(odf)
 }
 
 
 checkIfRequired <- function(row, col, dataSheet, val, r, odf, sn){
   
   if(!is.na(r$required) & r$required != ''){
       if(r$formRegion != 'H'){
         if(is.na(val) & str_to_upper(r$required)=='REQUIRED'){ return(T)}
       }else{
         if(r$recSubNum==1){
           datasection <- dataSheet[row,8:ncol(dataSheet)]
           horHasData <- !all(is.na(datasection))
           if(horHasData){
             if(is.na(val) & str_to_upper(r$required)=='REQUIRED'){return(T)}
           }
         }
       }
   }
   return(F)
 }
 
 
 
 checkNSMPSpecificRules <- function(val, r, odf, sn){
   if(r$dbFld=='o_latitude_GDA94'){
     
     if(as.numeric(val) > -10 | as.numeric(val) < -43){
       odf <- message(val, r, odf, sn, type='Error', msg='The latitude is not within Australia')
     }
   }
   
   if(r$dbFld=='o_longitude_GDA94'){
     
     if(as.numeric(val) < 112 | as.numeric(val) > 155){
       odf <- message(val, r, odf, sn, type='Error', msg='The longitude is not within Australia')
     }
   }
   
   return(odf)
 }
 
 
 #########  General  Rule checking    ########
 checkRules <- function(val, r, odf, sn){
   
   ###### Observation ID 
   if(r$dbFld=='o_id'){
     if(!check.numeric(val, only.integer=T)){
       odf <- message(val, r, odf, sn, type='Error', msg='Observation ID has to be an integer value')
     }
   }
   
   ###### Described date
   if(r$dbFld=='s_date_desc'){
     d <- as.Date(val, format='%Y%m%d')
     if(nchar(val)!=8){
       odf <- message(val, r, odf, sn, type='Error', msg='Date Described has to be an 8 characters string in the format YYYMMDD')
     }else if(is.na(d)){
       odf <- message(val, r, odf, sn, type='Error', msg='Date Described has to be an 8 characters string in the format YYYMMDD')
     }else if(year(d) < 2024){
       odf <- message(val, r, odf, sn, type='Warning', msg="Are you sure the date is correct ? The NSMP didn't begin until 2020")
     }
   }

     #####  Location
     if(r$dbFld=='o_latitude_GDA94'){

       if(!check.numeric(val, only.integer=F)){
         odf <- message(val, r, odf, sn, type='Error', msg='Observation ID has to be an numerical value')
       }
     }

     if(r$dbFld=='o_longitude_GDA94'){

       if(!check.numeric(val, only.integer=F)){
         odf <- message(val, r, odf, sn, type='Error', msg='Observation ID has to be an numerical value')
       }
     }
   
     
     ##########   NEED TO DO SOMETHING ABOUT DESC_BY  ###############
     
     
     #####  Slope
     if(r$dbFld=='s_slope'){
       
       if(!check.numeric(val, only.integer=F)){
         odf <- message(val, r, odf, sn, type='Error', msg='Slope % ID has to be an numerical value')
       }else if(as.numeric(val) > 100){
         odf <- message(val, r, odf, sn, type='Warning', msg='Are you sure the slope is great than 100% ?')
       }
     }

     #####  Depths
     if(r$dbFld=='h_upper_depth'){
    
        if(!is.na(as.numeric(val))){
           if(!check.numeric(val, only.integer=T)){
             odf <- message(val, r, odf, sn, type='Error', msg='Upper Depths have to be integer values in cm')
           }else if(as.numeric(val) > 200){
             odf <- message(val, r, odf, sn, type='Warning', msg='The upper depth is greater than 200 cm. Good work if you did dig that deep')
           }
         }
    }
     if(r$dbFld=='h_lower_depth'){
       if(!is.na(as.numeric(val))){
           if(!check.numeric(val, only.integer=T)){
             odf <- message(val, r, odf, sn, type='Error', msg='Lower Depths have to be integer values in cm')
           }else if(as.numeric(val) > 201){
             odf <- message(val, r, odf, sn, type='Warning', msg='The lower depth is greater than 200 cm. Good work if you did dig that deep')
           }
         }
     }
   # ValidateSites(token)  
   
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
 
  validateCode <- function(val, r, odf, sn){
    cvs <- cds[cds$field_name ==str_to_upper(r$dbFld ),]
    if(nrow(cvs)>0){
      
      if(!val %in% cvs$code_value){
        m <- message(val, r, odf, sn, type='Error', msg='Value not in the required codes list.')
        odf <- rbind(odf, m)
      }else{
        # e$Type = 'OK'
        # e$Issue = paste0('')
      }
    }
    return(odf)
  }
  
  isNumericValue <- function(){
    
  }
  
  SheetHasData <- function(dataSheet, excelInfo){
    
  # ymin <- min( excelInfo$row)
  # ymax <- max( excelInfo$row)
  # xmin <- min( excelInfo$col)
  # xmax <- max( excelInfo$col)
  #   
  #   datasection <- dataSheet[ymin:ymax, xmin:xmax]  # Looks athe the wholw data sheet
    
    datasection <- dataSheet[10:11, 2]  ## Just loook at the location
    
    resp <- !all(is.na(datasection))
    return(resp)
  }
  
getVals<- function(table, attribute, domain=NULL){ 
    
    
    if(nrow(table)==0){return("")}
    
    if(attribute=='s_date_desc'){
      v <- table[attribute][1]
      return(format(v, format="%B %d %Y"))
    }
    
    oVal <- ''
    for(k in 1:nrow(table)){
      recNum=k
      
      v <- as.character(table[attribute][recNum,])
      if(is.null(v) | is.na(v) | length(v) ==0 ){
        # return('')
        ov = ''
      }else{
        if(is.null(domain)){
          if(v=='NULL'){
            #return('')
            ov= ''
          }else{
            #return(v)
            ov=v
          }
          
        }else{
          
          if(v=='NULL'){
            #return('')
            ov=''
          }
          
          cds <- codes[codes$CODE_DOMAIN==domain,]
          if(nrow(cds>0)){
            dec <- cds[cds$CODE_VALUE==v,]
            if(nrow(dec)==0){
              #return(v)
              ov <- ''
            }else{
              desc <- dec$CODE_DESC
              #return(desc)
              ov <- desc
            }
          }else{
            #return(v)
            ov <- v
          }
        }
      }
      
      if(ov!='')
        oVal <- paste0(oVal, ov, ', ')
    }
    
    oVal2 <- str_sub(oVal, 1, nchar(oVal)-2)
    
    return(oVal2)
  }
  
  
#   return(dv)
# }