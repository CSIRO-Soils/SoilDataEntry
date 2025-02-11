##################################################################
#####       Author : Ross Searle                             #####
#####       Date :   Tuesday 08:28:22 2025                   #####
#####       Purpose : Shiny UI for the Site publishing tab   #####
#####       Comments :                                       #####
##################################################################


Tab_PublishSitesToNatSoil <- function() {
  
  tabPanel("Publish Sites",  icon = icon("upload", tags$style()),
           
        HTML('<H1>Publish</H1>'),
            fluidRow( HTML('<BR><BR>')),
            fluidRow( actionButton('wgtPublishSitesBtn', 'Publish Selected Sites')),
            fluidRow( HTML('<BR><BR>')),
            fluidRow( reactableOutput("wgtHoldingSitesTable")),
            fluidRow( HTML('<BR><BR>')),
            fluidRow( reactableOutput("wgtPublishedSitesTable")),
            fluidRow( HTML('<BR><BR>')),
            fluidRow( reactableOutput("wgtToDoSitesTable"))
           
  )
           
}
