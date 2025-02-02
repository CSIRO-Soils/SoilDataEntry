####################################################################### #
#####       Author : Ross Searle                                    ###
#####       Date :  Fri Jan 24 08:44:32 2025                        ###
#####       Purpose : Generates data entry spreadsheet populated    ###
#####                 with proposed site IDs.                       ###
#####       Comments :                                              ###
####################################################################### #

# Sys.setenv(JAVA_HOME = "C:/Program Files/OpenLogic/jdk-22.0.2.9-hotspot")
# setwd('C:/Program Files/OpenLogic/jdk-22.0.2.9-hotspot/bin')
library(XLConnect)


# fname = 'C:/Temp/Data Entry Template - NSMP.xlsx'
# token = 'Burnie'
# tmpD <- 'c:/temp/xltemp'


get_DataEntryFunctions <- function()
{
  de <- list()

      de$generateNSMPSiteSheet <- function(fname, token){

        tmpD <- tempdir()
        
      #  tmpD <- 'C:/temp/xltemp'
        
        if(!dir.exists(tmpD)){dir.create(tmpD, recursive = T)}
        b <- basename(fname)
        tof <-  paste0(tmpD, '/', str_replace(b, '.xlsx', paste0('_', token, '.xlsx')))
        if(file.exists(tof)){unlink(tof)}

         wb <- loadWorkbook(file.path(fname) )
        setStyleAction(wb, XLC$"STYLE_ACTION.DATA_FORMAT_ONLY")

        con <- OS$DB$Config$getCon(OS$DB$Config$DBNames$NatSoilStageRO)$Connection
        df <- OS$DB$Helpers$doQuery(con, paste0("select * from project.PROPOSED_SITES where ps_token='", token, "'"))

        for (i in 1:nrow(df)) {
          rec <- df[i, ]
          s <- rec$s_id
          print(paste0('Generating worksheet ', s))
          cloneSheet(wb, sheet = "Template", name = s)
          XLConnect::writeWorksheet(wb, sheet=s, data=s, startRow = 7, startCol = 2, header = F)
        }
        saveWorkbook(wb, file = tof)
        return(tof)
      }

return(de)
}


