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
      print(rec[1:8])
      
      setProgress(i, detail = paste(rec$FileName))
      
      sql <- paste0("DELETE from PHOTOS where agency_code=? and proj_code=? and s_id=? and o_id=? and photo_filename=?")
      params = list(keys$AgencyCode, keys$ProjectCode, as.character(rec$SiteID), as.character(rec$ObservationID), rec$FileName )
      res <- DBI::dbExecute(conn=con, statement=sql, params=params)
      res
      
      sql <- paste0("select max(photo_no) from PHOTOS where agency_code=? and proj_code=? and s_id=?")
      params = list(keys$AgencyCode, keys$ProjectCode, as.character(rec$SiteID) )
      pno <- DBI::dbGetQuery(conn=con, statement=sql, params=params)
      if(is.na(pno)){
        pno=0
      }else{
        pno <- as.numeric(pno)+1
      }
      
      iName = paste0(tdir, '/', rec$FileName)
      print(iName)
      file_content <-  paste( as.character(  readBin(iName, what = "raw", n = file.info(iName)[["size"]])), collapse = "")
      query = paste0("INSERT INTO PHOTOS (agency_code, proj_code, s_id, photo_no, o_id, photo_type_code, photo_alt_text, photo_filename, photo_img)  
                     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)")
      params = list(keys$AgencyCode, keys$ProjectCode, as.character(rec$SiteID), pno, as.character(rec$ObservationID), rec$PhotoType, 
                    rec$Description,  rec$FileName, file_content)
      DBI::dbExecute(con, query, params )
      
    }
    })
    
  
    }
  
  return(igp)
}










