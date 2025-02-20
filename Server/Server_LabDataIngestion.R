################################################################# #
#####       Author : Ross Searle                              ###
#####       Date :  Tue Feb 18 15:41:17 2025                  ###
#####       Purpose : Ingests photos into the DB              ###
#####       Comments :                                        ###
################################################################# #


# iName <- 'C:/Temp/FijiPhotos/Landscape1.jpg'

# fname <- 'C:/Projects/SiteDataEntryTool/aaa One Photo Data Entry Testing - General.xlsx'
# photoDF <- read.csv('C:/Temp/files.csv')
# con <-OS$DB$Config$getCon(OS$DB$Config$DBNames$NatSoilProjects)$Connection
# keys <- list()
# keys$AgencyCode <- '994'
# keys$ProjectCode <- 'SLAM'






getLabValidationResultsReactTable <- function(vTab){
  
  r <-  reactable(vTab, defaultPageSize = 15, filterable = TRUE, 
                  
                  style = list(maxWidth = 10000,  minWidth=1500),
                  columns = list(
                    Result = colDef(width=100, cell = function(value) {
                      if (value == "Error") "\u274c Error" else paste0("\u2714\ufe0f", value)
                    }),
                    SiteID = colDef(width=70),
                    obsID = colDef(width=30, name='O#'),
                    Value = colDef(width=100),
                    RecNum = colDef(width=40, name='H#')
                  ),
                  outlined = TRUE,
                  wrap = FALSE
                  #width=2000,
                  
  )
  return(r)    
}


renderLabDataValidationOutcomes <- function(outcomes){
  
  if(outcomes$Type=='Validation'){
  
  df <- outcomes$validationResultsTable
  if(nrow(df) > 0){
    df2 <- df[df$Result=='Error',]
    if(nrow(df2) > 0 ){
      siteerrors <- nrow(df2)
    }else{
      siteerrors = 0
    }
  }else{
    siteerrors = 0
  }
  
  ot <- '<h3>Validation Results</h3>'
  ot <- paste0(ot, 
               
               '</p><p>Total Number of Errors : ',  outcomes$ErrorCount,
               '</p><p>Number of Sites with Errors : ', outcomes$SitesWithErrorCnt,
               '</p><BR>'
  )
  
  if(outcomes$ErrorCount ==0){
    ot <- paste0(ot, '<p style="color:green">There are no errors in the laboratory data that we could find. You are good to load this dataset into the database.</p>' )
  }else{
    ot <- paste0(ot, '<p style="color:red">There are some errors in the laboratory data you have uploaded. 
                            Please fix these errors in the Excel spreadsheet before trying to upload the data again.</p><BR>' )
    return(paste0(ot))
  }
  
  }else{
    
    return( outcomes$html)
  
  }
  
}





# getPhotoValidationResultsReactTable <- function(vTab){
#   
#   r <-  reactable(vTab, defaultPageSize = 15, filterable = TRUE, 
#                   
#                   style = list(maxWidth = 10000,  minWidth=1500),
#                   columns = list(
#                     Result = colDef(width=100, cell = function(value) {
#                       if (value == "Error") "\u274c Error" else paste0("\u2714\ufe0f", value)
#                     }),
#                     RecNum = colDef(width=70, name='Rec #'),
#                     photoName = colDef(width=200, name = 'File Name'),
#                     SiteID = colDef(width=100, name='Site ID'),
#                     obsID= colDef(width=50, name='Obs ID'),
#                     Value = colDef(width=150)
#                     # RecSnum = colDef(width=50, name='sub#')
#                     # #Issue = colDef(width=20)
#                   ),
#                   outlined = TRUE,
#                   wrap = FALSE
#                   #width=2000,
#                   
#   )
#   return(r)    
# }


get_LabDataIngestion <- function()
{
  igl <- list()
  
  igl$IngestLabData <- function(conInfo, keys, fname){

    con <- conInfo$Connection
    
    ld <- openxlsx::readWorkbook(xlsxFile = fname, sheet=OS$Constants$LabTabName, skipEmptyRows = F, skipEmptyCols = F, startRow = 3)
    
    withProgress(message = paste0('Ingesting Lab data ....'), value = 0,  max=nrow(ld), {
     
      sheetMeths <- colnames(ld[9:ncol(ld)])
    
    for (i in 1:nrow(ld)) {

          setProgress(i, detail = paste('Record ', i))
          
          rec <- ld[i,]
          
           ### Delete existing Lab Results for a sample
           sql <- paste0("DELETE from LAB_RESULTS where agency_code=? and proj_code=? and s_id=? and o_id=? and h_no=? and samp_no=?")
           params = list(keys$AgencyCode, keys$ProjectCode, as.character(rec$SiteID), as.character(rec$ObservationID), rec$HorizonNumber, rec$SampleNumber )
           res <- DBI::dbExecute(conn=con, statement=sql, params=params)
           
           ### Delete existing Samples
           sql <- paste0("DELETE from SAMPLES where agency_code=? and proj_code=? and s_id=? and o_id=? and h_no=? and samp_no=?")
           params = list(keys$AgencyCode, keys$ProjectCode, as.character(rec$SiteID), as.character(rec$ObservationID), rec$HorizonNumber, rec$SampleNumber )
           samps <- DBI::dbExecute(conn=con, statement=sql, params=params)
          
           ##### Insert a sample
           query = paste0("INSERT INTO SAMPLES (agency_code, proj_code, s_id,  o_id, h_no, samp_no, samp_upper_depth, samp_lower_depth)  
                         VALUES (?, ?, ?, ?, ?, ?, ?, ?)")
           params = list(keys$AgencyCode, keys$ProjectCode, as.character(rec$SiteID), as.character(rec$ObservationID), as.numeric(rec$HorizonNumber), 
                         as.numeric(rec$SampleNumber), as.numeric(rec$UpperDepth), as.numeric(rec$LowerDepth)   )
           DBI::dbExecute(con, query, params )
           
           ##### Insert a lab results
           for (j in 1:length(sheetMeths)) {
             
               meth <- sheetMeths[j]
               val <- rec[meth][1,1]
               
               if(!is.na(val)){
               
                   query = paste0("INSERT INTO LAB_RESULTS (agency_code, proj_code, s_id,  o_id, h_no, samp_no, labr_no, labm_code, labr_value)  
                               VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)")
                   params = list(keys$AgencyCode, keys$ProjectCode, as.character(rec$SiteID), as.character(rec$ObservationID), as.numeric(rec$HorizonNumber), 
                                 as.numeric(rec$SampleNumber), 1, meth, val )
                   DBI::dbExecute(con, query, params )
                }
           }
        }
    })  # Progress counter
    
    
    ol <- list()
    ol$Type='Ingestion'
   
    
    ot <- paste0('<H3 style="color:green;"><b>Finished loading laboratory data into the database</b></H3><BR>')
    ot <- paste0(ot, '<p>Well done, you have successfully loaded your soil laboratory data into the database.
                              You can now use the Tabs above to explore and review your data.</p><BR>')
    
    ot <- paste0(ot, '<p><b>Database Name : </b>', conInfo$Name , '</p>')
    ot <- paste0(ot, '<p><b>Agency Code : </b>', keys$AgencyCode, '</p>' )
    ot <- paste0(ot, '<p><b>Project Code : </b>', keys$ProjectCode, '</p>')
    ot <- paste0(ot, '<p><b>Number of Sites : </b>', length(unique(ld$SiteID)), '</p>')
    ot <- paste0(ot, '<p><b>Number of Lab Methods : </b>', length(sheetMeths), '</p>')
    ot <- paste0(ot, '<p><b>Number of Records : </b>', nrow(ld), '</p>')
    
   
    
    ol$html <- ot
    
    return(ol)
  }
  
  return(igl)
}










