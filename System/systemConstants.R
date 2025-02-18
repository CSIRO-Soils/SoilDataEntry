################################################################# #
#####       Author : Ross Searle                              ###
#####       Date :  Mon Feb 17 10:03:21 2025                  ###
#####       Purpose : Constant Values used in the App         ###
#####       Comments :                                        ###
################################################################# #



get_AppConstants <- function()
{
  c <- list()
  
  c$UploadTypes <- as.list(c(Morphology_Data='Morphology_Data', Lab_Data='Lab_Data', Photos='Photos'))
  
  
  c$Sheetnames <- c("DBInfo",  "DBTableLevels", "Codes","About",'Morphology Template', "Laboratory Data", "Photos", "Filled Morphology Example" )
  
  c$RequiredLabFields <- c('AgencyCode', 'ProjectCode', 'SiteID', 'ObservationID', 'HorizonNumber', 'SampleNumber', 'UpperDepth', 'LowerDepth')
  
  c$RequiredPhotoFields <- c('AgencyCode', 'ProjectCode', 'SiteID', 'ObservationID', 'FileName', 'DateTaken', 'PhotoType', 'Description')
  
  c$PhotosTabName <- 'Photos'
  
  c$PhotoFormats <- c('.jpg', '.jpeg', '.png')
  
  return(c)
}

