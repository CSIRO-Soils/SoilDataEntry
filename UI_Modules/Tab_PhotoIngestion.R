Tab_PhotoIngestion_UI<- function() {
  
  
  tabPanel("Photo Ingestion", icon = icon('camera'),

           sidebarLayout(
             sidebarPanel(width = 3,
                          
                        #  fluidRow(
                            HTML(paste0('<font color="#425df5"><H4><b>Ingest Laboratory Data</b></H4></font>')),
                            HTML('<BR>'),
                            #downloadLink('wgtDownloadPhotoEntrySheet', label = 'Download Lab Data Entry Sheet Template'),
                            #HTML('<BR><BR>'),
                            
                          ###  import Photo widgets
                          fileInput('wgtXLFilePhotosDataEntrySheet', 'Drag your soil data spreadsheet here'),
                          
                          shinyjs::hidden(fileInput('wgtXLFilePhotosImages', 'Drag your photo files here', multiple = T, accept = OS$Constants$PhotoFormats)),
                          
                          shinyjs::hidden( actionButton('wgtValidateButtonPhotos', 'Validate Photo Data', class = "btn-success")),
                          HTML('<BR><BR>'),
                          withBusyIndicatorUI(  shinyjs::hidden( actionButton('wgtIngestButtonPhotos', 'Import Photos to DB', class = "btn-success"))),
                           
                          HTML('<BR><BR>'),
                          htmlOutput('wgtPhotosIngestFileInfo'),

                          HTML('<BR><BR>'),
                          HTML('<BR><BR>')
                         
                         # )  
  
             ),
             mainPanel(
               
               # fluidRow(
               #   column(8, htmlOutput('wgtPhotoIngestOutcomeInfo')),
               #          column(4, HTML('<BR>'), leafletOutput("UI_IngestMap", width = 350, height = 250),HTML('<BR>')
               #          ),
               
               # fluidRow(
               #   uiOutput("uiPhotoErrorsTableTitle"),
               #   shinyjs::hidden( downloadLink('wgtDownloadPhotosErrorTable', label = 'Click here to download the errors table')),
               #  HTML('<BR>'),
               #  
                
                 shinyjs::hidden( actionLink('wgtShowAllPhotosErrorsLink', 'Show All Errors')),
                        reactableOutput("wgtPhotosValidationResultsTable")
                       # ),

              
              # fluidRow( HTML('<BR><BR>'))
              
            # )
           )
           
  )  
           
  )         
           
}
