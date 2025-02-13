##################################################################
#####       Author : Ross Searle                             #####
#####       Date :   Tuesday 08:28:22 2025                   #####
#####       Purpose : Shiny UI for the Site Data Summary tab #####
#####       Comments :                                       #####
##################################################################


Tab_SitesSummary <- function() {
  
  tabPanel("All Sites Summary",  icon = icon("list", tags$style()),
           
           
           fluidRow(
             column(6, htmlOutput('wgtSitesSummaryInfo')),
             column(6, HTML('<BR>'), leafletOutput("UI_SiteSummaryMap", width = 350, height = 250),HTML('<BR>')
             ),
           ),
           fluidRow(
           reactableOutput("wgtSiteDataSummaryTable")  
           )
  )
           
}
