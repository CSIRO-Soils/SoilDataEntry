##################################################################
#####       Author : Ross Searle                             #####
#####       Date :   Tuesday 08:28:22 2025                   #####
#####       Purpose : Shiny UI for viewing site photos       #####
#####       Comments :                                       #####
##################################################################

Tab_SitesPhotoView <- function() {
  
  tabPanel("Photo Viewer",  icon = icon("table-cells", tags$style()),
           
           sidebarLayout(
             sidebarPanel(width = 2,
                          selectInput('vwgtSiteIDPhotoView', label = 'Site No.', choices = NULL),
                          selectInput('wgtPhotosSelectList', label = 'Photo', choices = NULL)
                          ),
            mainPanel(
             fluidRow(imageOutput("wgtPhotosImage", width = 800, height = 800)  )
             )
           
           )          
  )}
