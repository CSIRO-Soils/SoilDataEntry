################################################################# #
#####       Author : Ross Searle                                  ###
#####       Date :  Tue Feb 18 10:08:34 2025                      ###
#####       Purpose : Check the photo upload information provided ###
#####                 wil be able to be imported to DB            ###
#####       Comments :                                            ###
################################################################# #


# fname <- 'C:/Projects/SiteDataEntryTool/aaa One Photo Data Entry Testing - General.xlsx'
# fname <- 'C:/Projects/SiteDataEntryTool/aaa Errors Data Entry Testing - General .xlsx'
# photoDF <- read.csv('C:/Temp/files.csv')
# con <-OS$DB$Config$getCon(OS$DB$Config$DBNames$NatSoilProjects)$Connection
# keys <- list()
# keys$AgencyCode <- '994'
# keys$ProjectCode <- 'SLAM'



photoMessage <- function(odf, type, recNum, PhotoName, siteID, obsID, val,msg){
  e=list()
  e$Result = type
  e$RecNum = recNum
  e$photoName = PhotoName
  e$SiteID = siteID
  e$obsID = obsID
  e$Value = val
  e$Issue = msg
  odf <- rbind(odf, data.frame(e) )
  return(odf)
}


get_ValidationPhotos <- function()
{
  pv <- list()
  
  pv$validatePhotos <- function(con, keys){
    
    tdir <-  paste0(tempdir(), '/Photos/', keys$AgencyCode, '_', keys$ProjectCode)
    fname <- paste0(tdir, '/photos.xlsx' )
    allfiles <- list.files(tdir, full.names = F)
    idx <- which(grepl(pattern = 'photos.xlsx', allfiles))
    uploadNames <- allfiles[-idx]
    
   
    odf<-data.frame()
    photoRecs <- openxlsx::readWorkbook(xlsxFile = fname, sheet=OS$Constants$PhotosTabName, skipEmptyRows = F, skipEmptyCols = F, startRow = 3)
    
    withProgress(message = paste0('Validating photo data ....'), value = 0,  max=nrow(photoRecs), {
      
    
    snames <- unique(photoRecs$FileName)
    if(length(snames) != length(photoRecs$FileName)){
      odf <- photoMessage(odf, 'Error', '', '',  '', '', val='', 
                          paste0('The list of supplied photo names needs to be unique within this set.'  ))
    }
    
    for (i in 1:nrow(photoRecs)) {
      
      print(i)
      rec <- photoRecs[i,]
      pfn <- basename(rec$FileName)
      
      setProgress(i, detail = paste(rec$FileName))
      
     # uploadRec <- photoDF[photoDF$name==rec$FileName, ]
      
      
      photoPath <- paste0(tdir, '/', rec$FileName)  
    
      if(!file.exists(photoPath)){
        odf <- photoMessage(odf, 'Error', i, PhotoName=rec$FileName,  rec$SiteID, rec$ObservationID, val=rec$FileName, 
                            paste0('File is not in the list of uploaded photos.'  ))
      }else{
      
      sql <- paste0("Select s_id, o_id from OBSERVATIONS where agency_code='", keys$AgencyCode, "' and proj_code = '", keys$ProjectCode, 
                    "' and s_id = '", rec$SiteID, "' and o_id = ", rec$ObservationID )
     sites <- OS$DB$Helpers$doQuery(con, sql)
     
     #### Check site is in the DB
     if(nrow(sites)==0){
       odf <- photoMessage(odf, 'Error', i, PhotoName=rec$FileName, rec$SiteID, rec$ObservationID, val=rec$SiteID, 
                           paste0('Site ID : ', rec$SiteID, ' Observation ID : ', rec$ObservationID, ' does not exist in the database.'  ))
     }
     
     #### Check image formats
     ext <- paste0(".", tools::file_ext(rec$FileName))
     if(!ext %in% OS$Constants$PhotoFormats){
       odf <- photoMessage(odf, 'Error', i, PhotoName=rec$FileName,  rec$SiteID, rec$ObservationID, val=rec$FileName, 
                           paste0('Image is not in the list of supported image formats - ', paste0(OS$Constants$PhotoFormats, collapse = ", ")  ))
     }
       
     ####  Check if name matches on of the uploaded images
     if(!rec$FileName %in% uploadNames){
       odf <- photoMessage(odf, 'Error', i, PhotoName=rec$FileName,  rec$SiteID, rec$ObservationID, val=rec$FileName, 
                           paste0('Photo file name "', rec$FileName, '" is not in the list of uploaded images.'  ))
     }
     
     
     ##### check dates
     photoDate <- suppressWarnings(read_exif(photoPath)$DateTimeOriginal)

       if(is.null(rec$DateTaken)){
         odf <- photoMessage(odf, 'Error', i, PhotoName=rec$FileName,  rec$SiteID, rec$ObservationID, val='', 
                             paste0('Please supply a date of the photo capture.'  ))
       }else if(nchar(rec$DateTaken) != 8){
         odf <- photoMessage(odf, 'Error', i, PhotoName=rec$FileName,  rec$SiteID, rec$ObservationID, val=rec$DateTaken, 
                             paste0('The date needs to be an 8 digit value in the form YYYYMMDD.'  ))
       }else{
         y <- str_sub(rec$DateTaken, 1,4)
         m <- str_sub(rec$DateTaken, 5,6)
         d <- str_sub(rec$DateTaken, 7,8)
         
         dt <- as.Date(paste0(y, '-', m, '-', d), format='%Y-%m-%d')
         if(is.na(dt)){
           odf <- photoMessage(odf, 'Error', i, PhotoName=rec$FileName,  rec$SiteID, rec$ObservationID, val=rec$DateTaken, 
                               paste0('Not a valid date.'  ))
         }else{
           if(dt > Sys.Date()){
             odf <- photoMessage(odf, 'Warning', i, PhotoName=rec$FileName,  rec$SiteID, rec$ObservationID, val=rec$DateTaken, 
                                 paste0('Date supplied is in the future. Are you sure this is correct?'  ))
           }else if(year(dt)<1900){
             odf <- photoMessage(odf, 'Warning', i, PhotoName=rec$FileName,  rec$SiteID, rec$ObservationID, val=rec$DateTaken, 
                                 paste0('Date supplied is before 1900. Are you sure this is correct?'  ))
           }
           
           else if(!is.null(photoDate)){
             sdt <- str_split(photoDate, ' ')[[1]][1]
             pdt <- as.Date(sdt, format='%Y:%m:%d')
             if(!dt==pdt){
               odf <- photoMessage(odf, 'Warning', i, PhotoName=rec$FileName,  rec$SiteID, rec$ObservationID, val=rec$DateTaken, 
                                   paste0('Date supplied is different to the date contained in the image. Are you sure this is correct?'  ))
             }
           }
         }
       } 
     
     if(is.na(rec$Description)){
       odf <- photoMessage(odf, 'Error', i, PhotoName=rec$FileName,  rec$SiteID, rec$ObservationID, val='', 
                           paste0("Please supply a photo description."))
     }
     
     else if(nchar(rec$Description)< 5){
       odf <- photoMessage(odf, 'Warning', i, PhotoName=rec$FileName,  rec$SiteID, rec$ObservationID, val=rec$Description, 
                           paste0("You haven't supplied a very useful description. It is desirable but not a requirement to supply a reasonable description."))
       
     }

    }
    
    }
    
    })
    
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
    
    return(ol)
  }
  
  
  
  return(pv)
  
}

