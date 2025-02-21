################################################################# #
#####       Author : Ross Searle                              ###
#####       Date :  Thu Feb 20 15:29:47 2025                  ###
#####       Purpose : Photo ingestion Tab                     ###
#####       Comments : Not used for NSMP config               ###
################################################################# #



Tab_PhotoIngestion_UI<- function() {
  
  
  tabPanel("Photo Ingestion", icon = icon('camera'),

           sidebarLayout(
             sidebarPanel(width = 3,
                          
                            HTML(paste0('<font color="#425df5"><H4><b>Ingest Photo Data</b></H4></font>')),
                            HTML('<BR>'),

                          ###  import Photo widgets
                          fileInput('wgtXLFilePhotosDataEntrySheet', 'Drag your soil data spreadsheet here'),
                          htmlOutput('wgtPhotosIngestXLInfo'),
                          shinyjs::hidden(fileInput('wgtXLFilePhotosImages', 'Drag your photo files here', multiple = T, accept = OS$Constants$PhotoFormats)),
                          htmlOutput('wgtPhotosIngestFileInfo'),
                          HTML('<BR>'),
                          withBusyIndicatorUI(   shinyjs::hidden( actionButton('wgtValidateButtonPhotos', 'Validate Photo Data', class = "btn-success"))),
                          HTML('<BR>'),
                          shinyjs::hidden( htmlOutput('wgtPhotosIngestReminderMessage')),
                          shinyjs::hidden( actionButton('wgtIngestButtonPhotos', 'Import Photos to DB', class = "btn-success")),
                           
                          HTML('<BR><BR>'),
                          HTML('<BR><BR>')
                         
                         # )  
  
             ),
             mainPanel(
               
 
               htmlOutput('wgtPhotoIngestOutcomeInfo'),
                
                 shinyjs::hidden( actionLink('wgtShowAllPhotosErrorsLink', 'Show All Errors')),
                        reactableOutput("wgtPhotosValidationResultsTable")

           )
           
  )  
           
  )         
           
}
