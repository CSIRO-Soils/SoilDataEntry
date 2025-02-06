Tab_DataIngestion_UI<- function() {
  
  
  tabPanel("Sites Data Ingestion", icon = icon('cloud-arrow-up'),

           sidebarLayout(
             sidebarPanel(width = 3,
                          
                          fluidRow(
                            HTML(paste0('<font color="#425df5"><H4><b>Ingest Site Description Sheets</b></H4></font>')),
                            HTML('<BR>'),
                            downloadLink('wgtDownloadDataEntrySheet', label = 'Download Site Data Entry Sheet'),
                            HTML('<BR><BR>'),
                            uiOutput("uiIngestTokenText"),

                            fileInput('wgtXLFile', 'Drag your sites spreadsheet here')),
                          
                          shinyjs::hidden( actionButton('wgtValidateButton', 'Validate Site Data', class = "btn-success")),
                          HTML('<BR><BR>'),
                          #shinyjs::hidden( actionButton('wgtIngestButton', 'Import Site Data to DB', class = "btn-success")),
                          withBusyIndicatorUI(  shinyjs::hidden( actionButton('wgtIngestButton', 'Import Site Data to DB', class = "btn-success"))),
                          
                          
                          HTML('<BR><BR>'),
                          htmlOutput('wgtIngestFileInfo'),

                          HTML('<BR><BR>'),
                        # shinyjs::hidden( downloadLink('wgtDownDB', label = 'DownloadYYYYYYY')),
                        #  downloadLink('wgtDownDB', label = 'Download Database File'),
                          HTML('<BR><BR>'),
                         
                         
                          wellPanel(id = "wgtDownloadsPanel",
                                    
                                    HTML('<h4>Resources</h4>'),
                                    
                                    uiOutput("uiIngestDownloads"),
                          ),
             ),
             mainPanel(
               
               fluidRow(
                 column(8, htmlOutput('wgtIngestOutcomeInfo')),
                        column(4, HTML('<BR>'), leafletOutput("UI_IngestMap", width = 350, height = 250),HTML('<BR>')
                        ),
               
               fluidRow(
                 uiOutput("uiErrorsTableTitle"),
                 shinyjs::hidden( downloadLink('wgtDownloadErrorTable', label = 'Click here to download the errors table')),
                HTML('<BR>'),
                
                
                 shinyjs::hidden( actionLink('wgtShowAllErrorsLink', 'Show All Errors')),
                        reactableOutput("wgtValidationResultsTable")
                        ),

              
               fluidRow( HTML('<BR><BR>')),
               
               fluidRow( shinyjs::hidden( downloadLink('wgtDBLink', label = 'Click here to download the data base you just created'))),
               HTML('<BR><BR>'),
             )
           )
           
  )  
           
  )         
           
}