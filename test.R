library(magrittr)


con <- OS$DB$Config$getCon(OS$DB$Config$DBNames$NatSoilDev)$Connection


sql <- paste0("INSERT INTO PHOTOS ('agency_code', 'proj_code', 's_id', 'o_id', 'photo_type', 'photo_img') 
VALUES ('191', 'CAN', 'C1', 1, 'test', ", file_content ,");")


fn <-  'C:/Temp/small.jpg'
file_content <- paste(as.character(readBin(fn, what = "raw", n = file.info(fn)[["size"]])), collapse = "")
sql <- paste0("INSERT INTO PHOTOS (agency_code, proj_code, s_id, o_id, photo_type_code) 
VALUES ('191', 'CAN', 'C1', '1', 'test');")

DBI::dbExecute(con, sql)




fn <-  'C:/Temp/small.jpg'
file_content <- paste(as.character(readBin(fn, what = "raw", n = file.info(fn)[["size"]])), collapse = "")
sql <- paste0("INSERT INTO PHOTOS (agency_code, proj_code, s_id, o_id, photo_type_code, photo_img) 
VALUES ('191', 'CAN', 'C1', '1', 'test', '", file_content ,"');")

DBI::dbExecute(con, sql)


OS$DB$Helpers$doInsertUsingRawSQL(con, sql)




\
file_name <- 'C:/Temp/small.jpg'
file_name <- 'C:/Temp/aimage.jpg'

file_content <- 
  vapply(
    file_name,
    function(x)
    {
      # read the binary data from the file
      readBin(x,
              what = "raw",
              n = file.info(x)[["size"]]) %>%
        # convert the binary data to a character string suitable for import
        as.character() %>%
        paste(collapse = "")
    },
    character(1)
  )



query = paste0("INSERT INTO PHOTOS (agency_code, proj_code, s_id, o_id, photo_no, photo_type_code, photo_img)  VALUES (?, ?, ?, ?, ?, ?, ?)")
data = list('199', 'CAN', 'C1', '1', 2, 'test2', file_content)

DBI::dbExecute(con, query, data )


sql <- paste0("SELECT *  FROM [PHOTOS] 
                  where agency_code='", '199', "' and proj_code='", 'CAN',
              "' and s_id='", 'C1', "' and o_id=1")

df <- OS$DB$Helpers$doQuery(con, sql)

rec <- df[2,]
outfile <- 'c:/temp/backout2.jpg'
binData <- rec$photo_img
content<-unlist(binData)
writeBin(content, con = outfile)






