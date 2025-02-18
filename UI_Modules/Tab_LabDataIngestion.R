Tab_LabDataIngestion_UI<- function() {
  
  
  tabPanel("Laboratory Data Ingestion", icon = icon('flask'),

           sidebarLayout(
             sidebarPanel(width = 3,
                          
                          fluidRow(
                            HTML(paste0('<font color="#425df5"><H4><b>Ingest Laboratory Data</b></H4></font>')),
                            HTML('<BR>'),
                            #downloadLink('wgtDownloadLabDataEntrySheet', label = 'Download Lab Data Entry Sheet Template'),
                            #HTML('<BR><BR>'),
                            
                          ###  import Lab widgets
                          fileInput('wgtXLFileLabData', 'Drag your soil data spreadsheet here'),
                          shinyjs::hidden(shinyjs::hidden( actionButton('wgtValidateButtonLabResults', 'Validate Chemistry Data', class = "btn-success"))),
                          HTML('<BR><BR>'),
                          withBusyIndicatorUI(  shinyjs::hidden( actionButton('wgtIngestButtonLabResults', 'Import Chemistry Data to DB', class = "btn-success"))),
                           
                          HTML('<BR><BR>'),
                          htmlOutput('wgtLabDataIngestFileInfo'),

                          HTML('<BR><BR>'),
                          HTML('<BR><BR>')
                         
                          )  
  
             ),
             mainPanel(
               
               fluidRow(
                 column(8, htmlOutput('wgtLadDataIngestOutcomeInfo')),
                        column(4, HTML('<BR>'), leafletOutput("UI_IngestMap", width = 350, height = 250),HTML('<BR>')
                        ),
               
               fluidRow(
                 uiOutput("uiLabDataErrorsTableTitle"),
                 shinyjs::hidden( downloadLink('wgtDownloadErrorTable', label = 'Click here to download the errors table')),
                HTML('<BR>'),
                
                
                 shinyjs::hidden( actionLink('wgtShowAllLabDataErrorsLink', 'Show All Errors')),
                        reactableOutput("wgtLabDataValidationResultsTable")
                        ),

              
               fluidRow( HTML('<BR><BR>'))
              
             )
           )
           
  )  
           
  )         
           
}
