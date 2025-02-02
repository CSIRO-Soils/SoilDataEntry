##################################################################
#####       Author : Ross Searle                             #####
#####       Date :   Tuesday 08:28:22 2025                   #####
#####       Purpose : Shiny UI for the Admin tab             #####
#####       Comments :                                       #####
##################################################################


Tab_Admin <- function() {

  tabPanel("Admin",  icon = icon("toolbox", tags$style()),
  
          tabsetPanel(
            tabPanel("System Summary",
                     
                     uiOutput('uiAdminDBCon')
                     
                     ),
             tabPanel("Add New User", 
                      fluidRow(HTML('<H4>Add new user</h4>'))
             ),    
             tabPanel("Data Status")
           )
  )}
