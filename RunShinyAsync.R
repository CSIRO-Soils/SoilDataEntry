################################################################# #
#####       Author : Ross Searle                              ###
#####       Date :  Mon Jan 20 10:06:17 2025                  ###
#####       Purpose : Run Shiny app in the background         ###
#####       Comments : It auto updates on saving in RStudio   ###
################################################################# #

job::job({
  
  setwd('C:/Users/sea084/OneDrive - CSIRO/RossRCode/Git/Shiny/Apps/NationalSoilMonitoring/NSMData')
  options(shiny.autoreload = TRUE)
  shiny::runApp(launch.browser=T, port = 4321)
  
}, title = 'NSMP Data Entry App')



