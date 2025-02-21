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



getPhotoValidationResultsReactTable <- function(vTab){
  
  r <-  reactable(vTab, defaultPageSize = 15, filterable = TRUE, 
                  
                  style = list(maxWidth = 10000,  minWidth=1500),
                  columns = list(
                    Result = colDef(width=100, cell = function(value) {
                      if (value == "Error") "\u274c Error" else paste0("\u2714\ufe0f", value)
                    }),
                    RecNum = colDef(width=70, name='Rec #'),
                    photoName = colDef(width=200, name = 'File Name'),
                    SiteID = colDef(width=100, name='Site ID'),
                    obsID= colDef(width=50, name='Obs ID'),
                    Value = colDef(width=150)
                    # RecSnum = colDef(width=50, name='sub#')
                    # #Issue = colDef(width=20)
                  ),
                  outlined = TRUE,
                  wrap = FALSE
                  #width=2000,
                  
  )
  return(r)    
}


renderPhotoValidationOutcomes <- function(outcomes){
  
  if(outcomes$Type=='Validation'){
    
    df <- outcomes$validationResultsTable
    
    
    ot <- '<h3>Photo Validation Results</h3>'
    ot <- paste0(ot, 
                 
                 '</p><p>Total Number of Errors : ',  outcomes$ErrorCount,
                 '</p><BR>'
    )
    
    if(outcomes$ErrorCount ==0){
      ot <- paste0(ot, '<p style="color:green">There are no errors in the Photo upload that we could find. You are good to load these photos into the database.</p>' )
    }else{
      ot <- paste0(ot, '<p style="color:red">There are some errors in the photos records you have uploaded. 
                            Please fix these errors in the Excel spreadsheet before trying to upload the photos records again.</p><BR>' )
      return(paste0(ot))
    }
    
  }else{
    
    return( outcomes$html)
    
  }
  
}






get_IngestPhotos <- function()
{
  igp <- list()
  
  igp$IngestPhotos <- function(con, keys){
    
    tdir <-  paste0(tempdir(), '/Photos/', keys$AgencyCode, '_', keys$ProjectCode)
    fname <- paste0(tdir, '/photos.xlsx' )
    allfiles <- list.files(tdir, full.names = F)
    idx <- which(grepl(pattern = 'photos.xlsx', allfiles))
    uploadNames <- allfiles[-idx]
    
    
    photoRecs <- openxlsx::readWorkbook(xlsxFile = fname, sheet=OS$Constants$PhotosTabName, skipEmptyRows = F, skipEmptyCols = F, startRow = 3)
    
    withProgress(message = paste0('Ingesting photo data ....'), value = 0,  max=nrow(photoRecs), {
     
    
    for (i in 1:nrow(photoRecs)) {

      rec <- photoRecs[i,]
      
      setProgress(i, detail = paste(rec$FileName))
      
      sql <- paste0("DELETE from PHOTOS where agency_code=? and proj_code=? and s_id=? and o_id=? and photo_filename=?")
      params = list(keys$AgencyCode, keys$ProjectCode, as.character(rec$SiteID), as.character(rec$ObservationID), rec$FileName )
      res <- DBI::dbExecute(conn=con, statement=sql, params=params)
      
      sql <- paste0("select max(photo_no) from PHOTOS where agency_code=? and proj_code=? and s_id=?")
      params = list(keys$AgencyCode, keys$ProjectCode, as.character(rec$SiteID) )
      pno <- DBI::dbGetQuery(conn=con, statement=sql, params=params)
      if(is.na(pno)){
        pno=0
      }else{
        pno <- as.numeric(pno)+1
      }
      
      iName = paste0(tdir, '/', rec$FileName)

      file_content <-  paste( as.character(  readBin(iName, what = "raw", n = file.info(iName)[["size"]])), collapse = "")
#      query = paste0("INSERT INTO PHOTOS (agency_code, proj_code, s_id, photo_no, o_id, photo_type_code, photo_alt_text, photo_filename, photo_img)  
#                     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)")
      
      # 
      # params = list(keys$AgencyCode, keys$ProjectCode, as.character(rec$SiteID), pno, as.character(rec$ObservationID), rec$PhotoType, 
      #               rec$Description, rec$FileName, file_content)
      # DBI::dbExecute(con, query, params )
      
      
      pdf <- data.frame(agency_code=keys$AgencyCode, proj_code=keys$ProjectCode, s_id=as.character(rec$SiteID), photo_no=pno, o_id=as.character(rec$ObservationID),  
                        photo_type_code=rec$PhotoType, photo_alt_text=rec$Description, photo_filename=rec$FileName, photo_img=file_content)
      
      DBI::dbAppendTable(con, 'PHOTOS', pdf)
      
      
      # this is a hack as I can't get the above insert query to work with the date field in it
      sql <- paste0("UPDATE PHOTOS set photo_taken_date='",rec$DateTaken, "' 
                    where agency_code=? and proj_code=? and s_id=? and o_id=? and photo_filename=?")
      params = list( keys$AgencyCode, keys$ProjectCode, as.character(rec$SiteID), as.character(rec$ObservationID), rec$FileName)
      DBI::dbExecute(con, sql, params)
      
      
    }
    })
    
    
    ol <- list()
    ol$Type='Ingestion'
    
    
    ot <- paste0('<H3 style="color:green;"><b>Finished loading the photos into the database</b></H3><BR>')
    ot <- paste0(ot, '<p>Splendid, you have successfully loaded your photos into the database.
                              You can now use the Tabs above to explore and review your data.</p><BR>')
    

    ot <- paste0(ot, '<p><b>Agency Code : </b>', keys$AgencyCode, '</p>' )
    ot <- paste0(ot, '<p><b>Project Code : </b>', keys$ProjectCode, '</p>')
    ot <- paste0(ot, '<p><b>Number of Sites : </b>', length(unique(photoRecs$SiteID)), '</p>')
    ot <- paste0(ot, '<p><b>Number of Records : </b>', nrow(photoRecs), '</p>')
    
    
    
    ol$html <- ot
    
    return(ol)
  
    }
  
  return(igp)
}










