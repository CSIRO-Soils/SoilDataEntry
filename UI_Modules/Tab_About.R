##################################################################
#####       Author : Ross Searle                             #####
#####       Date :  Tuesday 08:28:22 2025                    #####
#####       Purpose : Shiny UI for the about tab             #####
#####       Comments :                                       #####
##################################################################


Tab_About <- function() {
  
           tabPanel("About", icon = icon("circle-info"),
                    uiOutput("uiAboutTab")
           )}
