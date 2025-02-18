################################################################# #
#####       Author : Ross Searle                              ###
#####       Date :  Tue Feb 18 15:41:17 2025                  ###
#####       Purpose : Ingests photos into the DB              ###
#####       Comments :                                        ###
################################################################# #


# iName <- 'C:/Temp/FijiPhotos/Landscape1.jpg'


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
    
    for (i in 1:nrow(photoRecs)) {
      
      rec <- photoRecs[i,]
      iName = paste0(tdir, '/', rec$FileName)
      file_content <-  paste( as.character(  readBin(iName, what = "raw", n = file.info(iName)[["size"]])), collapse = "")
      
      sql <- paste0("select * from PHOTOS where agency_code='994' and proj_code='SLAM' and s_id='5' and o_id=1")
      res <- DBI::dbGetQuery(conn=con, statement=sql)
      
      sql <- paste0("select * from PHOTOS where agency_code=? and proj_code=? and s_id=? and o_id=?")
      data = list(keys$AgencyCode, keys$ProjectCode, as.character(rec$SiteID), as.character(rec$ObservationID))
      res <- DBI::dbGetQuery(conn=con, statement=sql, params=data)
      res
      
      
      
      query = paste0("INSERT INTO PHOTOS (agency_code, proj_code, s_id, o_id, photo_no, photo_type_code, photo_img)  VALUES (?, ?, ?, ?, ?, ?, ?)")
      data = list(keys$AgencyCode, keys$ProjectCode, rec$SiteID, rec$ObservationID, 2, rec$PhotoType, file_content)
      DBI::dbExecute(con, query, data )
      
      
      # sql <- paste0("SELECT *  FROM [PHOTOS] 
      #             where agency_code='", '994', "' and proj_code='", 'SLAM',
      #               "' and s_id='", '5', "' and o_id=1")
      # 
      # df <- OS$DB$Helpers$doQuery(con, sql)
      # 
      # rec <- df[1,]
      # outfile <- 'c:/temp/backout2.jpg'
      # binData <- rec$photo_img
      # content<-unlist(binData)
      # writeBin(content, con = outfile)
      
      
    }
    
    
  }
  
  
  return(igp)
}










