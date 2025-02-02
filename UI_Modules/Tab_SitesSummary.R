##################################################################
#####       Author : Ross Searle                             #####
#####       Date :   Tuesday 08:28:22 2025                   #####
#####       Purpose : Shiny UI for the Site Data Summary tab #####
#####       Comments :                                       #####
##################################################################


Tab_SitesSummary <- function() {
  
  tabPanel("Sites Summary",  icon = icon("toolbox", tags$style()),
           
           reactableOutput("wgtSiteDataSummaryTable")  
           
  )}
