################################################################# #
#####       Author : Ross Searle                              ###
#####       Date :  Wed Jan 22 08:45:17 2025                  ###
#####       Purpose : App Configuration values                ###
#####       Comments :                                        ###
################################################################# #


get_AppConfigs <- function()
{
  c <- list()
  
  c$ShowAdminKey = '123'
  c$DevelopConfigName = 'NSMP'
  c$DevelopToken = 'Burnie'
  c$DevelopAgency = '994'
  c$DevelopProject = 'NSMP'
  
  c$AppDBPath = './DBs/SoilDataEntryAppConfigs.sqlite'
  
  return(c)
}