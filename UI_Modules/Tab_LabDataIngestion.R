Tab_LabDataIngestion_UI<- function() {
  
  
  tabPanel("Laboratory Data Ingestion", icon = icon('flask'),

           sidebarLayout(
             sidebarPanel(width = 3,
                          
                          fluidRow(
                            HTML(paste0('<font color="#425df5"><H4><b>Ingest Laboratory Data</b></H4></font>')),
                            HTML('<BR>'),
                            
                          ###  import Lab widgets
                          fileInput('wgtXLFileLabData', 'Drag your laboratory data spreadsheet here'),
                          shinyjs::hidden(shinyjs::hidden( actionButton('wgtValidateButtonLabResults', 'Validate Laboratory Data', class = "btn-success"))),
                          HTML('<BR><BR><BR>'),
                          shinyjs::hidden( htmlOutput('wgtLabDataIngestReminderMessage')),
                          
                          withBusyIndicatorUI(  shinyjs::hidden( actionButton('wgtIngestButtonLabResults', 'Import Laboratory Data to DB', class = "btn-success"))),
                           
                          HTML('<BR><BR>'),
                          htmlOutput('wgtLabDataIngestFileInfo'),

                          HTML('<BR><BR>'),
                          HTML('<BR><BR>')
                         
                          )  
  
             ),
             mainPanel(
               
               fluidRow(
                 column(12, htmlOutput('wgtLabDataIngestOutcomeInfo'))
                        
                        ),
               
               
                 uiOutput("uiLabDataErrorsTableTitle"),
                 shinyjs::hidden( downloadLink('wgtDownloadLabErrorTable', label = 'Click here to download the errors table')),
                HTML('<BR><BR>'),
                
                
               #  shinyjs::hidden( actionLink('wgtShowAllLabDataErrorsLink', 'Show All Errors')),
                        reactableOutput("wgtLabDataValidationResultsTable"),
                        

              
               fluidRow( HTML('<BR><BR>'))
              
             )
           )
           
  )  
           
          
           
}
