Tab_SiteViewer_UI <- function() {

tabPanel("Site Viewer", icon = icon("file-lines"),
         
         
         sidebarLayout(
           sidebarPanel(width = 3,
                        
                        fluidRow(
                          
                          # wellPanel(id = "wgtConPanel",
                          #           selectInput('vwgtDBType', label = 'Database to use', choices = availableDBs, selected = "NatSoil"),
                          #           shinyjs::hidden( passwordInput('wgtDBPWD', label='DataBase Password' ,  placeholder = 'Password needed for staging DB access' ),
                          #                            shinyjs::hidden(passwordInput('wgtCSIROKey', label='CSIRO Access Key', placeholder = 'Leave blank for public access'))
                          #           ),
                          #           shinyjs::hidden(
                          #             textInput('wgtPortableDBName', label='DataBase File Name')
                          #           ),
                          #           actionButton('vwgtConDB', 'Connect to DataBase',  class = "btn-info"), 
                          #           htmlOutput('wgtConInfo'),
                          #           htmlOutput('wgtDBAccessType')
                          # ),
                          
                        #  selectInput('vwgtAgency', label = 'Agency Code', choices = NULL),
                        #  selectInput('vwgtProject', label = 'Project Code', choices = NULL),
                        
                          
                          selectInput('vwgtSiteID', label = 'Site No.', choices = NULL),
                          #selectInput('vwgtObsID', label = 'Obs No.', choices = c('1'), selected = '1')
                          ),
                          fluidRow(
                          HTML("<BR>"),
                          
                          uiOutput("uiSiteViewSitePublishType"),
                          
                          withBusyIndicatorUI(actionButton('vwgtViewSiteButton', 'View Site Data',  class = "btn-success")),
                          
                          HTML("<BR>"),
                          withBusyIndicatorUI(downloadButton('wgtDownloadSiteSheetBtn', 'Download Site Document')),
                          HTML("<BR>"),
                          
                          leafletOutput("UI_SiteViewerMap", width = 350, height = 350),HTML('<BR>')
                          
                          #leafletOutput("UI_Map", width = 350, height = 350)
                          , align = "center"
                          , style = "margin-bottom: 10px;"
                          , style = "margin-top: -10px;"
                        ),
                        
           ),
           mainPanel(
             
             fluidRow(
               
               column(12,  tabsetPanel(type = "tabs", id='ViewSitesTabsetPanel',
                                       
                                       tabPanel("Site Description",
                                                
                                                tags$div(id = "wgtSiteContainer",
                                                         fluidRow(
                                                           column(2,
                                                                  plotOutput('wgtProfile')
                                                                  
                                                           ),
                                                           column(10,
                                                                  
                                                                  htmlOutput('wgtSiteDescription'),
                                                                  hidden(htmlOutput("wgtLabResultsLabel2")),
                                                                  rHandsontableOutput('labResultsTable2' ),
                                                                  HTML('<BR><BR>'),
                                                                  hidden( rHandsontableOutput('UI_SiteDescription_LabResults' ))
                                                           )
                                                         )
                                                )
                                       ),
                                       
                                       ##### ^^ All projects Info Tab  #### 
                                       # tabPanel(id='tabProjectInfoView', "Projects Info", 
                                       #          
                                       #          fluidRow(
                                       #            column(8,htmlOutput('pwgtAllProjectsDescription')),
                                       #            column(4,leafletOutput("UI_ProjectSitesMap", width = 350, height = 350))
                                       #            
                                       #          )),
                                       
                                       ##### ^^  Lab Data Plots Tab  #### 
                                       tabPanel("Lab Data Plots", 
                                                
                                                sidebarPanel( width=2,
                                                              # HTML('HELLO'),
                                                              selectInput('wgtLabResultsSelect',label='Choose a lab Method to plot',choices = NULL),
                                                              HTML('<BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR>
                                                                                    <BR><BR><BR><BR><BR><BR><BR><BR><BR>'),
                                                ),
                                                
                                                mainPanel(
                                                  HTML('<H4> Lab Data Soil Profile Plot</H4>'),
                                                  plotOutput('UI_LabDataPlots', height = '730px'),
                                                )
                                       ),
                                       
                                     #  tabPanel("Projects Information", fluidRow(DTOutput('UI_ProjectInfo'))),
                                       
                                       ##### ^^  Lab Methods Information Tab  #### 
                                       # tabPanel("Lab Methods Information", 
                                       #          fluidRow(
                                       #            HTML('<BR>'),
                                       #            div(DTOutput('wgtlabMethods' ), style = "font-size:75%")
                                       #            #  DTOutput('wgtlabMethods' )
                                       #          ))
               )
               
               )),
             HTML('<BR><BR>'),
             
           )
         )
         
)
}