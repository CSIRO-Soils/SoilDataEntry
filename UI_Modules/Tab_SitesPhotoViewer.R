##################################################################
#####       Author : Ross Searle                             #####
#####       Date :   Tuesday 08:28:22 2025                   #####
#####       Purpose : Shiny UI for viewing site photos       #####
#####       Comments :                                       #####
##################################################################

Tab_SitesPhotoView <- function() {
  
  tabPanel("Photo Viewer",  icon = icon("image", tags$style()),
           
           sidebarLayout(
             sidebarPanel(width = 2,
                          selectInput('vwgtSiteIDPhotoView', label = 'Site No.', choices = NULL),
                          selectInput('wgtPhotosSelectList', label = 'Photo', choices = NULL),
                          HTML('<BR><BR>'),
                          uiOutput("uiPhotoInfo"),
                          HTML('<BR><BR>'),
                          hidden(downloadLink('wgtPhotoDownloadLink', 'Download Photo'))
                          ),
            mainPanel(
             fluidRow(imageOutput("wgtPhotosImage", width = 800, height = 800)  )
             )
           
           )          
  )}

