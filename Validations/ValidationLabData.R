###################################################################### #
#####       Author : Ross Searle                                   ###
#####       Date :  Thu Feb 20 05:27:58 2025                       ###
#####       Purpose : Validate Lab Data for ingetsion into NatSoil ###
#####       Comments :                                             ###
###################################################################### #




# fname <- 'C:/Projects/SiteDataEntryTool/aaa Errors Data Entry Testing - General .xlsx'
# con <-OS$DB$Config$getCon(OS$DB$Config$DBNames$NatSoilProjects)$Connection
# keys <- list()
# keys$AgencyCode <- '994'
# keys$ProjectCode <- 'SLAM'


LabMessage <- function(odf, type, recNum, siteID, obsID, val,msg){
  e=list()
  e$Result = type
  e$RecNum = recNum
  e$SiteID = siteID
  e$obsID = obsID
  e$Value = val
  e$Issue = msg
  odf <- rbind(odf, data.frame(e) )
  return(odf)
}

get_ValidateLabData <- function(){
  
  lv <- list()
  
  
  lv$ValidateLabData <- function(con, keys, fname, config){
    
    ld <- openxlsx::readWorkbook(xlsxFile = fname, sheet = 'Laboratory Data', skipEmptyRows = F, skipEmptyCols = F, startRow = 3)
    
    withProgress(message = paste0('Validating Lab Data ....'), value = 0,  max=nrow(ld), {
    
    appCon <- OS$DB$Config$getCon(OS$DB$Config$DBNames$AppDB)$Connection
    labLims <- OS$DB$Helpers$doQuery(appCon, 'Select * from LabLimits')
    DBI::dbDisconnect(appCon)

    AvailMeths <- OS$DB$Helpers$doQuery(con, 'select * from LAB_METHODS')
    sheetMeths <- colnames(ld[9:ncol(ld)])
    idxs <- which(!sheetMeths %in% AvailMeths$LABM_CODE )
    
    
    
####  Check global values ####    
    
    ####  check that provided lab method codes are legitimate
    odf <- data.frame()
    if(length(idxs)>0){
      em <- paste0('Lab methods ', paste0(sheetMeths[idxs], collapse = '; '), ' are not valid lab method codes')
      odf <-  LabMessage( odf, type='Error', recNum='',  siteID='', obsID='', val='', msg=em)
    }
    
    ####  Check all agency codes are correct
    if(!all(ld$AgencyCode==keys$AgencyCode)){
      odf <-  LabMessage( odf, type='Error', recNum='',  siteID='', obsID='', val='', msg=paste0('Not all of the Agency Codes are equal to ', keys$AgencyCode))
    }
    
    ####  Check all project codes are correct
    if(!all(ld$ProjectCode==keys$ProjectCode)){
      odf <-  LabMessage( odf, type='Error', recNum='',  siteID='', obsID='', val='', msg=paste0('Not all of the Project Codes are equal to ', keys$ProjectCode))
    }
    
    #### Check that sites are in the DB already
    sql <- paste0("select s_id from SITES where agency_code='",  keys$AgencyCode, "' and proj_code='",  keys$ProjectCode, "'" )
    res <- OS$DB$Helpers$doQuery(con, sql)
    SitesinDB <- res$s_id
    
    SitesInLab <- unique(ld$SiteID)
    
    for(i in 1:length(SitesInLab)){
      
      site <- SitesInLab[i]
      if(!site %in% SitesinDB){
        odf <-  LabMessage( odf, type='Error', recNum='',  siteID=site, obsID='', val=site, msg=paste0('Site ', site, " is not in the DB"))
      }else{
        obsid <- ld[ld$SiteID==site, ]$ObservationID
        sql <- paste0("select s_id, o_id from OBSERVATIONS where agency_code='",  keys$AgencyCode, "' and proj_code='",  keys$ProjectCode, "' and s_id = '", site, "'" )
        res <- OS$DB$Helpers$doQuery(con, sql)
        obsindb <- res$o_id
        
        if(!all(obsid %in% obsindb)){
          odf <-  LabMessage( odf, type='Error', recNum='',  siteID=site, obsID='', val='', msg=paste0('Not all of the ObservationIDs for site ', site, ' are in the DB'))
        }
      }
    }
    
    
    #### check to see if there is validation information for each of the methods
    
    legitMethodsIdxs <- which(sheetMeths %in% AvailMeths$LABM_CODE )
    
    for (k in 1:length(legitMethodsIdxs)) {
      
      meth <- sheetMeths[k]
      
      if(!meth %in% labLims$labm_code){
        odf <-  LabMessage( odf, type='Warning', recNum=i,  siteID='', obsID='', val=meth, 
                            msg=paste0('There is no data validation information available for this Lab Method'))
      }
    }
    
    
    
    
    
#####  Check individual records  ####    
    
    for (i in 1:nrow(ld)) {
      
      setProgress(i, detail = paste('Validating record ', i))
      
      rec <- ld[i,]
      sql <- paste0("select s_id, o_id, h_no from HORIZONS where agency_code='",  keys$AgencyCode, "' and proj_code='",  keys$ProjectCode, "' and s_id = '", site, "' and o_id='", rec$ObservationID , "'")
      res <- OS$DB$Helpers$doQuery(con, sql)
      if(!rec$HorizonNumber %in% res$h_no){
        odf <-  LabMessage( odf, type='Error', recNum=i,  siteID=rec$SiteID, obsID=rec$ObservationID, val=rec$HorizonNumber, 
                            msg=paste0('Horizon Number ', rec$HorizonNumber, ' is not in the DB for Site=', site, ' ObservationID=', rec$ObservationID))
      }
      
      
      #### Check if Sample Number is numeric
      if(!check.numeric( rec$SampleNumber, only.integer = T )){
        odf <-  LabMessage( odf, type='Error', recNum=i,  siteID=rec$SiteID, obsID=rec$ObservationID, val=rec$SampleNumber, 
                            msg=paste0('Sample Number is not an integer value'))
      }
      
      #### Check Upper Depths
      if(!check.numeric( rec$UpperDepth, only.integer = T )){
        odf <-  LabMessage( odf, type='Error', recNum=i,  siteID=rec$SiteID, obsID=rec$ObservationID, val=rec$UpperDepth, 
                            msg=paste0('Upper Depth is not an integer value'))
      }else{
        if(rec$UpperDepth>200){
          odf <-  LabMessage( odf, type='Warning', recNum=i,  siteID=rec$SiteID, obsID=rec$ObservationID, val=rec$UpperDepth, 
                              msg=paste0('Upper Depth is greater than 200cm. Are you sure this is correct?'))
        }
      }
      
      #### Check Lower Depths
      if(!check.numeric( rec$LowerDepth, only.integer = T )){
        odf <-  LabMessage( odf, type='Error', recNum=i,  siteID=rec$SiteID, obsID=rec$ObservationID, val=rec$LowerDepth, 
                            msg=paste0('Lower Depth is not an integer value'))
      }else{
        if(rec$LowerDepth>200){
          odf <-  LabMessage( odf, type='Warning', recNum=i,  siteID=rec$SiteID, obsID=rec$ObservationID, val=rec$UpperDepth, 
                              msg=paste0('Lower Depth is greater than 200cm. Are you sure this is correct?'))
        }
      }
      
      
      
      
      for (k in 1:length(legitMethodsIdxs)) {
         
         meth <- sheetMeths[k]
         
         if(meth %in% labLims$labm_code){
               val <- rec[meth][1,1]

               if(!is.na(val)){
                     if(!check.numeric(val)){
                        odf <-  LabMessage( odf, type='Error', recNum=i,  siteID=rec$SiteID, obsID=rec$ObservationID, val=val, 
                                           msg=paste0('Value needs to be numeric.'))
                       }else{
                       
                           lims <- labLims[labLims$labm_code==meth,]
                           if(val < lims$Min){
                              odf <-  LabMessage( odf, type='Error', recNum=i,  siteID=rec$SiteID, obsID=rec$ObservationID, val=val, 
                                                 msg=paste0('Value for ', meth, ' is less than the valid range for this Lab Method'))
                           }else if(val < lims$LQ){
                             odf <-  LabMessage( odf, type='Warning', recNum=i,  siteID=rec$SiteID, obsID=rec$ObservationID, val=val, 
                                                 msg=paste0('Value for ', meth, ' is below the 5th percentile of all measured data'))
                           }
                           
                           if(val > lims$Max){
                             odf <-  LabMessage( odf, type='Error', recNum=i,  siteID=rec$SiteID, obsID=rec$ObservationID, val=val, 
                                                 msg=paste0('Value for ', meth, ' is greater than the valid range for this Lab Method'))
                           }else if(val > lims$UQ){
                             odf <-  LabMessage( odf, type='Warning', recNum=i,  siteID=rec$SiteID, obsID=rec$ObservationID, val=val, 
                                                 msg=paste0('Value for ', meth, ' is above the 5th percentile of all measured data'))
                           }
                       }
               }
               
               }

      }
    }
    
    })  ###  End progress bar
    
    

    sitesWithErrorsCnt=0
    
    usites <- unique(ld$SiteID)
    
    for (i in 1:length(usites)) {
      s <- usites[i]
      idxs <- which(odf$SiteID==s & odf$Result=='Error')
      
      if(length(idxs)>0){
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
    ol$SitesWithErrorCnt <- sitesWithErrorsCnt
    
    return(ol)
  }
  
  return(lv)
  
}
  