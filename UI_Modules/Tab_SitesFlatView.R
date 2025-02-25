##################################################################
#####       Author : Ross Searle                             #####
#####       Date :   Tuesday 08:28:22 2025                   #####
#####       Purpose : Shiny UI for the Sites flat view       #####
#####       Comments :                                       #####
##################################################################


Tab_SitesFlatView <- function() {
  
  tabPanel("Data Sheet View",  icon = icon("table-cells", tags$style()),
           
           sidebarLayout(
             sidebarPanel(width = 2,
                          selectInput('vwgtSiteIDFlatView', label = 'Site No.', choices = NULL),

              uiOutput("uiFlatViewSitePublishType"),
              withBusyIndicatorUI(actionButton('vwgtViewSiteButtonFlatView', 'View Site Data',  class = "btn-success")),
            
               
             
               
               #with_busy_indicator_ui(actionButton('vwgtViewSiteButtonFlatView', 'View Site Data',  class = "btn-success"))
             ),
             
            mainPanel(
             
             fluidRow(reactableOutput("wgtSiteFlatViewTable")  )
             
             )
           
           )          
  )
  
  }
