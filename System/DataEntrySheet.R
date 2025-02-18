####################################################################### #
#####       Author : Ross Searle                                    ###
#####       Date :  Fri Jan 24 08:44:32 2025                        ###
#####       Purpose : Generates data entry spreadsheet populated    ###
#####                 with proposed site IDs.                       ###
#####       Comments :                                              ###
####################################################################### #

# Sys.setenv(JAVA_HOME = "C:/Program Files/OpenLogic/jdk-22.0.2.9-hotspot")
# setwd('C:/Program Files/OpenLogic/jdk-22.0.2.9-hotspot/bin')
#library(XLConnect)


# fname = 'C:/Temp/Data Entry Template - NSMP.xlsx'
# token = 'Burnie'
# tmpD <- 'c:/temp/xltemp'


get_DataEntryFunctions <- function()
{
  de <- list()

      de$generateNSMPSiteSheet <- function(fname, token){

       
        
        tmpD <- tempdir()
        
        if(!dir.exists(tmpD)){dir.create(tmpD, recursive = T)}
        b <- basename(fname)
        tof <-  paste0(tmpD, '/', str_replace(b, '.xlsx', paste0('_', token, '.xlsx')))
        if(file.exists(tof)){unlink(tof)}

         wb <- openxlsx::loadWorkbook(file.path(fname) )

        con <- OS$DB$Config$getCon(OS$DB$Config$DBNames$NatSoilStageRO)$Connection
        df <- OS$DB$Helpers$doQuery(con, paste0("select * from project.PROPOSED_SITES where ps_token='", token, "'"))

        withProgress(message = paste0('Generating Soil Data Entry Spreadsheet ....'), value = 0,  max=nrow(df)+5, {
        
            for (i in 1:nrow(df)) {
              setProgress(value=i, detail = paste("Sheet ", i, ' of ', nrow(df)))
              rec <- df[i, ]
              s <- rec$s_id
              print(paste0('Generating worksheet ', s))
              openxlsx::cloneWorksheet(wb, sheetName = s, clonedSheet = "Morphology Template")
              openxlsx::writeData(wb, sheet=s, x=s, startRow = 7, startCol = 2)
            }
          setProgress(value=i+2, detail = paste("Preparing download !!! "))
          
          openxlsx::saveWorkbook(wb, file = tof, overwrite = T)
        
        })
        return(tof)
      }

return(de)
}


