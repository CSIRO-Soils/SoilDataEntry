################################################################# #
#####       Author : Ross Searle                              ###
#####       Date :  Mon Jan 20 09:51:02 2025                  ###
#####       Purpose : Shiny App for entering soil data into   ###
#####                 the CSIS database environment.          ###       
#####       Comments :                                        ###
################################################################# #

###  Auto updating during dev info - Run the Run the RunShinyAsync.R script. the GUI will then auto update upon save in RStudio



##### .##########################  ####
####. App Instantiation  ######
##### .##########################  ####




machineName <- as.character(Sys.info()['nodename'])

if(machineName=='ROHAN-SL'){
  develMode <<- T
}else{
  develMode <<- F
  #Sys.setenv(ODBCSYSINI = "/apps/msodbcsql/17.7.2.1/etc/")
}




#setwd('C:/Users/sea084/OneDrive - CSIRO/RossRCode/Git/Shiny/Apps/NationalSoilMonitoring/NSMData')

source('System/ObjectStore.R')


 appcon <- OS$DB$Config$getCon(OS$DB$Config$DBNames$NatSoilStageRO)$Connection
 codes <<- OS$DB$Helpers$doQuery(appcon, 'select * from Codes')
 dbDisconnect(appcon)
####. ####
#### .========     UI  ========  ####
#### ^ Load UI components ####
ui <- fluidPage(
 
  uiOutput("uiHtmlHeader"),
  uiOutput("uiPageHeader"),
  uiOutput("appUI")
  
#### .========  End of UI  ========  ####   
)

####. ####
####. ####
#### .========     SERVER  ========  ####
server <- function(input, output,session) {
  
  options(shiny.maxRequestSize=200*1024^2)

  ####.   ======  App Configuration  ============== ###### 

#### ^ Reactive Values Instantiation ####
  RV <- reactiveValues()
  RV$DBCon <- NULL
  RV$RequiredParams <- NULL
  RV$SiteSummaryInfo <- NULL
  RV$AvailableSitesIDs <- NULL
  RV$CurrentPhotoInfoTable <- NULL
  RV$PublishedAndDraftSiteInfo <- NULL
  RV$SiteUpdateCount <- 1
  RV$ValidationPhotosOutcomes <- NULL
  RV$IngestPhotosCount <- 1
  RV$PhotoUpdateCount <- 1
  
  
  # autoInvalidate <- reactiveTimer(10000)
  # observe({
  #   autoInvalidate()
  #   cat(".")
  # })
  
  observe({
     cd <-reactiveValuesToList(session$clientData)
     RV$SiteURL <- paste0(cd$url_protocol, '//', cd$url_hostname, cd$url_pathname)
  })
  
  #### ^ Read in the DB config paramaters ####  
  output$appUI <- renderUI({

    query <- parseQueryString(session$clientData$url_search)
    
    if (!is.null(query$config)) {
      RV$ConfigName <- query$config
      RV$Keys$AgencyCode <- query$agencycode
      RV$Keys$ProjectCode <- query$projectcode
      RV$Keys$Token <- query$token
      RV$Keys$AdminKey <- query$adminkey
    }else{
      if(develMode){
        RV$ConfigName <- OS$AppConfigs$DevelopConfigName
        RV$Keys$AgencyCode <- OS$AppConfigs$DevelopAgency
        RV$Keys$ProjectCode <- OS$AppConfigs$DevelopProject
        RV$Keys$Token <- OS$AppConfigs$DevelopToken
     #   RV$Keys$AdminKey <- OS$AppConfigs$ShowAdminKey
        RV$Keys$AdminKey <- NULL
      }else{
        RV$Keys$Token <- 'None'
        RV$ConfigName <- OS$AppConfigs$DevelopToken
        RV$Keys$AdminKey <- NULL
      }
    }

    if(!is.null(RV$ConfigName) & !is.null(RV$Keys$AgencyCode)  & !is.null(RV$Keys$ProjectCode)) 
    {
      RV$RequiredParams = T
      html <- setupUIBasedOnConfigs(config=RV$Keys, url=RV$SiteURL)
    }else{
      RV$RequiredParams = F
      html <- setupUIBasedOnConfigs(config=NULL, url=RV$SiteURL)
    }
    html
  })
  
  
  observe({
    req(RV$ConfigName, RV$Keys)
   # OS$Logging$logSession(configName = RV$ConfigName, keys = RV$Keys)
  })
 
  #### ^  Connect to the App NatSoil DB  #### 
  observe({
    
      req(RV$DBName, RV$Keys$ProjectCode)
      con <- OS$DB$Config$getCon(RV$DBName, fname=RV$Keys$ProjectCode)
      print(paste0('Connecting to DB - ', RV$DBName))
      RV$DBCon <- con
     
     # updateTabsetPanel(session, "MainTabsetPanel", selected = "Laboratory Data Ingestion")
     # updateTabsetPanel(session, "MainTabsetPanel", selected = "Publish Sites")
     # updateTabsetPanel(session, "IngestTabsetPanel", selected = "Photo Ingestion")
     # updateTabsetPanel(session, "IngestTabsetPanel", selected = "Laboratory Data Ingestion")
      
  })

  


  #### ^ Show the Download Portable DB Link  #######  
  observe({
    req(RV$Keys$ProjectCode)
      DBpath <- paste0(OS$DB$Config$Constants$portableDBDirectory, '/',RV$Keys$ProjectCode , '.db')
      
      if(file.exists(DBpath)){
        shinyjs::show('wgtDownloadPortableDB')
      }
  })
  
  #### ^ Load UI Configuration Parameters  ####### 
  observe({

    req(RV$ConfigName )
    
     coni <- OS$DB$Config$getCon(OS$DB$Config$DBNames$AppDB)
     con <- coni$Connection
     rec <- OS$DB$Helpers$doQuery(con, paste0("select * from Configurations where Configuration='", RV$ConfigName,  "'"))
     dbDisconnect(con)
     
     if(nrow(rec)==1){
       
        RV$ConfigName <- rec$Configuration
        RV$ConfigValues$AppHeaderImage <- rec$AppHeaderImage
        RV$ConfigValues$AppTitle <- rec$AppTitle
        RV$ConfigValues$AppLogo <- rec$AppLogo
        RV$ConfigValues$TitleFont <- rec$TitleFont
        RV$ConfigValues$BrowserTabName <- rec$BrowserTabName
        jsn <- rec$Downloads
        resources=fromJSON(jsn, simplifyDataFrame = T)
        RV$ConfigValues$IngestDownloads <- resources
        RV$ConfigValues$AboutPage <- rec$AboutPage
        RV$DBName <- rec$DefaultDB
        RV$DataEntryFileName <- rec$DataEntryFileName
     }
  })


    
  #### ^  Get the list of available sites  #####
  observe({
    req(RV$DBCon, RV$Keys)
    RV$SiteUpdateCount 
    sites <- getListOfAvailableSites(con=RV$DBCon$Connection, keys=RV$Keys)
    RV$AvailableSitesIDs <- sites
    
    if(RV$ConfigName == 'NSMP'){
      RV$PublishedAndDraftSiteInfo$Draft <- OS$PublishSitesToNatSoil$getDraftOrPublishedSites(type='Draft', keys=RV$Keys)
      RV$PublishedAndDraftSiteInfo$Published<- OS$PublishSitesToNatSoil$getDraftOrPublishedSites(type='Published', keys=RV$Keys)
    }
  }) 
  
  observe({
    req(RV$AvailableSitesIDs)
    updateSelectInput(inputId = "vwgtSiteID", choices = RV$AvailableSitesIDs)
    updateSelectInput(inputId = "vwgtSiteIDFlatView", choices = RV$AvailableSitesIDs)
    updateSelectInput(inputId = "vwgtSiteIDPhotoView", choices = RV$AvailableSitesIDs)
  })
  
  
  ####. ####
  ####. == DYNAMIC PAGE RENDERING =========  ####### 
  ####. ####
  
  ### ^ Whole Website  ####
  #### ^^ Dynamic Banner Rendering  #######  
  output$uiPageHeader <- renderUI({
    
    req(RV$ConfigValues)
    html <- setupHeaderBasedOnConfigs(reqParams = RV$RequiredParams, font=RV$ConfigValues$TitleFont, 
                                      configName=RV$ConfigName, imageHeader=RV$ConfigValues$AppHeaderImage, 
                                      imageLogo=RV$ConfigValues$AppLogo,
                                      title=RV$ConfigValues$AppTitle)
    HTML(html)
  })
  
  #### ^^ Dynamic HTML Header Rendering  ####### 
  output$uiHtmlHeader <- renderUI({
    
    req(RV$ConfigValues$BrowserTabName)
    t1 <- tags$head(
                      shinyjs::useShinyjs(),
                      tags$style(".shiny-notification {position: fixed; top: 20% ;left: 50%"),  
                                    tags$link(rel="shortcut icon", href="./images/dirt-48.png"), tags$title(RV$ConfigValues$BrowserTabName))
    t1
  })
  
  
  
  ###.####
  ### ^ Data Ingestion ####
  #### ^^ Dynamic Ingestion Download Links Rendering  #######   
  output$uiIngestDownloads <- renderUI({
    
    req(RV$ConfigValues$IngestDownloads)
    resources <-  RV$ConfigValues$IngestDownloads
    
    html <- ''
    for (i in 1:nrow(resources)) {
      rec <- resources[i, ]
      html <- paste0(html,  '<a href="',paste0('./Configs/',RV$ConfigName, '/', rec$path) , '" download>',  paste0(rec$Name),'</a><br>')
    }
    HTML(html)
  })
  
  
  ###.####
  #### ^ About Page  ####### 
  #### ^^ Dynamic About Page Rendering  ####### 
  output$uiAboutTab <- renderUI({
    
    req(RV$ConfigValues)
    page <-  RV$ConfigValues$AboutPage
    path <- paste0('./www/Configs/',RV$ConfigName, '/', page)
    html <- readLines(path, warn = FALSE, encoding = "UTF-8")
    HTML(html)
  })
   
  
  
####.  ####  
####. ======  PAGES  ============ ####
  ####.  ####
  ####  *****  Site Description  *******####

  
  #### ^ Click show site description button to populate data ####
  observeEvent(input$vwgtViewSiteButton,{

    req( RV$DBCon)
    con <- RV$DBCon$Connection

    withBusyIndicatorServer("vwgtViewSiteButton", {
      
        RV$CurrentSiteLocation <- OS$DB$NatSoilQueries$getLocationInfo(con, RV$Keys$AgencyCode, RV$Keys$ProjectCode, input$vwgtSiteID, input$vwgtObsID)
        RV$SiteDesc <- getSiteDescription(con=con, agencyCode=RV$Keys$AgencyCode, projectCode=RV$Keys$ProjectCode, siteID=input$vwgtSiteID, obsID=1)
        RV$ProfPlotData <- RV$SiteDesc$ProfPlotData
        if(nrow(RV$SiteDesc$LabData)>0){
          shinyjs::show('UI_SiteDescription_LabResults')
          RV$LabData <- RV$SiteDesc$LabData
        }else{
          RV$LabData<-NULL
          shinyjs::hide('UI_SiteDescription_LabResults')
        }
    })
  })
  
  #### ^ Render Site Description   ####   
  
  output$wgtSiteDescription = renderText({ 
    req(RV$SiteDesc)
    RV$SiteDesc$HTML
  })
  
  
  #### ^ Download Site Description   #### 
  output$wgtDownloadSiteSheetBtn <- downloadHandler(
    filename = function() {
      paste0('NatSoil_', RV$Keys$AgencyCode, "_", RV$Keys$ProjectCode,  "_",input$vwgtSiteID, '.docx')
    },
    content = function(file) {

      of <-  tempfile(pattern = 'SitesDesc_', fileext = '.docx') 
      #ProfPlotPath <- 'C:/Temp/profile.PNG'
      if(nrow( RV$ProfPlotData) > 0){
        saveSoilProfileDiagram('sid', p= RV$SiteDesc$ProfPlotData,  RV$SiteDesc$ProfilePlotPath)
        ProfPlotPath <- RV$SiteDesc$ProfilePlotPath
      }else{
        ProfPlotPath <- NULL
      }
      printableSiteReport(con=RV$DBCon$Connection, RV <- RV$SiteDesc, templatePath = './Outputs/siteReportTemplate.docx', outputPath=of, ProfPlotPath=ProfPlotPath)
      file.copy(of, file)
    }
  )
  
  #### ^ Render profile diagram   ####  
  
  output$wgtProfile = renderPlot({
    
    req( RV$ProfPlotData)
    
    if(nrow( RV$ProfPlotData) > 0){
      df <- RV$ProfPlotData
      hp <-  getSoilProfileDiagram(input$wgtSiteID, p=df)
      hp
    }
  }, height = 700, width = 400)
  
  
  
  #### ^ Render Site View Publish type   ####  
  output$uiSiteViewSitePublishType <-  renderText({
    req(RV$ConfigName, input$vwgtSiteID)
    if(RV$ConfigName=='NSMP'){
      shinyjs::show('uiSiteViewSitePublishType')
      if(input$vwgtSiteID %in% RV$PublishedAndDraftSiteInfo$Draft$s_id){
        message <- 'This site is <span style="color:orange">Draft</span><BR><BR>'
      }else if (input$vwgtSiteID %in% RV$PublishedAndDraftSiteInfo$Published$s_id) {
        message <- 'This site is <span style="color:green">Published</span><BR><BR>'
      }
      paste0(HTML(message))
    }
  })
  
  
  observeEvent(input$wgtDownloadDataEntrySheet, {

    req(RV$ConfigName)

    xlPathName <- paste0(getwd(), '/www/Configs/',RV$ConfigName, '/', RV$DataEntryFileName)
    
   
     if(RV$ConfigName =='NSMP'){
       downloadPath <- OS$DataEntry$generateNSMPSiteSheet(fname=xlPathName,  token=RV$Keys$Token)
       RV$DataEntryTemplatePath <- downloadPath
     }else{
       RV$DataEntryTemplatePath <- xlPathName
     }
    
    print(RV$DataEntryTemplatePath)
    shinyjs::runjs("document.getElementById('wgtDL').click();")
   
  })

  
  ####.####
  ###  ***** Morphology Data Ingestion ****  ####
  #### ^ Download Data Entry Template ####
  output$wgtDL <- downloadHandler(
   
    filename = function() {
      basename(RV$DataEntryTemplatePath)
    },
    content = function(file) {

      xlPathName <- paste0(getwd(), '/www/Configs/',RV$ConfigName, '/', RV$DataEntryFileName)
      downloadPath <- RV$DataEntryTemplatePath
      print(downloadPath)
      if(RV$ConfigName =='NSMP'){
        on.exit(unlink(downloadPath))
      }
      file.copy(downloadPath, file, overwrite = T)
    }
  )
  
  #### ^ Upload Soil Morphology Excel File ####
  output$wgtIngestFileInfo <-  renderText({
    
    shinyjs::hide('wgtIngestButton')
    file <- input$wgtXLFile
    req(file)
    fname <- file$datapath
    RVExcelFile <- file$datapath
    r <- OS$IngestHelpers$checkXLFileFormat(fname, OS$Constants$UploadTypes$Morphology_Data)
    if(!r$OK){
      
    }else{
      shinyjs::show('wgtValidateButton')
    }
    paste0(r$Message)
  })
  
  

  
  
  
  #### ^ Validate Site Data ####
  observeEvent(input$wgtValidateButton, {
    
    if(is.null(RV$DBCon)){
      
      str1 = tags$span(
        paste('Oh Dear'),
        style = "font-size: 25px; color: #1a168a; font-weight: bold;"
      )
      str2 = tags$span(
        paste("There was a problem connecting the the backend database"),
        style = "font-size: 15px; color: #425df5"
      )
      showModal(modalDialog(title = tagList(str1),
                            str2,
                            size = 's',
                            fade=F 
      ))
      
    }else{

        req(RV$ConfigName)

        isolate({

         
          RV$XLfile <- input$wgtXLFile$datapath
          
          if(RV$ConfigName=='NSMP'){
            t=RV$Keys$Token
          }else{
            t=NULL
          }
          
          outcome <- OS$Validation$ValidateSites(fname=RV$XLfile, config=RV$ConfigName, keys=RV$Keys)
          RV$ValidationOutcomes <- outcome

          if(RV$ValidationOutcomes$ErrorCount==0){
            shinyjs::show('wgtIngestButton')
          }

        })
    }
    })
  
  
  #### ^ Ingest Excel into DB ####
  observeEvent(input$wgtIngestButton, {
    
    if(is.null(RV$DBCon)){
      
      str1 = tags$span(
        paste('Oh Dear'),
        style = "font-size: 25px; color: #1a168a; font-weight: bold;"
      )
      str2 = tags$span(
        paste("There was a problem connecting the the backend database"),
        style = "font-size: 15px; color: #425df5"
      )
      showModal(modalDialog(title = tagList(str1),
                            str2,
                            size = 's',
                            fade=F 
      ))
      
    }else{
      
      str1 = tags$span(
        paste('Just Checking ....'),
        style = "font-size: 20px; color: orange; font-weight: bold;"
      )
      str2 = tags$span(
        HTML(paste("Uploading the data from this spreadsheet will overwrite any existing data for sites already in the staging database.<BR><BR>Are you sure you want to proceed ?")),
        style = "font-size: 15px; color: #425df5"
      )
      
      showModal(modalDialog(title =  tagList(str1),
                            str2,
                            size = 's',
                            fade=F ,
                            
                            footer = tagList(
                              modalButton("Cancel"),
                              actionButton(inputId = "wgtInjectDataConfirmButton", "Do It")
                            )
      ))
      
    }
  })
  
  observeEvent(input$wgtInjectDataConfirmButton, {
   
    removeModal()
      
      req(RV$ConfigName)
        isolate({
        RV$XLfile <- input$wgtXLFile$datapath
        outcome <- OS$DB$IngestData$ingestMorpholgyData(con=RV$DBCon, XLFile=RV$XLfile, config=RV$ConfigName, keys=RV$Keys)
        RV$ValidationOutcomes <- outcome
        RV$SiteUpdateCount =  RV$SiteUpdateCount + 1
        
      })
  })
    
  
  output$uiErrorsTableTitle <-  renderText({
    req(RV$ValidationOutcomes)
    
    if(RV$ValidationOutcomes$Type=='Validation'){
        if(nrow(RV$ValidationOutcomes$validationResultsTable) > 0){
            paste0('<h4>Validation Errors Table</h4>') 
        }
    }else{
      
    }
  })
  
  
  #### ^ Download Portable DB ####
  output$wgtDownloadPortableDB <- downloadHandler(
    filename = function() {
      file <- paste0(RV$Keys$ProjectCode, '.db')
    },
    content = function(file) {
      
        DBpath <- paste0(OS$DB$Config$Constants$portableDBDirectory, '/', RV$Keys$ProjectCode, '.db')
        if(file.exists(DBpath)){
            file.copy(DBpath, file)
        }
    }
  )
  
  #### ^ Download Validation Errors Table ####
  output$wgtDownloadErrorTable <- downloadHandler(
    filename = function() {
      req(RV$ValidationOutcomes)
      if(RV$Keys$ProjectCode=='NSMP'){
        tof <-  paste0('DataValidationErrors_', RV$Keys$ProjectCode, '_', RV$Keys$Token, '.csv')
      }else{
        tof <-  paste0('DataValidationErrors_', RV$Keys$ProjectCode, '.csv')
      }
    },
    content = function(file) {
      write.csv(RV$ValidationOutcomes$validationResultsTable, file)
    }
  )
  
  #### ^ Render validation errors table  #### 
  output$wgtValidationResultsTable <- renderReactable({
    req(RV$ValidationOutcomes)

    if(RV$ValidationOutcomes$Type=='Validation'){
      
      if(nrow(RV$ValidationOutcomes$validationResultsTable) > 0){
          shinyjs::show('wgtDownloadErrorTable')
          shinyjs::show('wgtShowAllErrorsLink')
        
           getValidationResultsReactTable(vTab=RV$ValidationOutcomes$validationResultsTable)
      }else{
          shinyjs::hide('wgtDownloadErrorTable')
          shinyjs::hide('wgtShowAllErrorsLink')
      }
    }else{
      
    }
  })
  
  observe({
    req( RV$ValidationOutcomes$validationResultsTable)
    
    if(RV$ValidationOutcomes$Type=='Validation'){
    input$wgtShowAllErrorsLink
    updateReactable("wgtValidationResultsTable", data =  RV$ValidationOutcomes$validationResultsTable)
    }else{
      
    }
  })
  
  observeEvent(input$UI_IngestMap_marker_click, { 
    p <- input$UI_IngestMap_marker_click  # typo was on this line
    data <- RV$ValidationOutcomes$validationResultsTable
   idxs <- which(data$Site == as.character(p$id[1]))
   filtered <- data[idxs,]
    updateReactable("wgtValidationResultsTable", data = filtered)
  })

### ^ Render validation & Ingestion outcomes ####  
  output$wgtIngestOutcomeInfo <-  renderText({
    req(RV$ValidationOutcomes)
    if(RV$ValidationOutcomes$Type=='Ingestion'){
      shinyjs::hide('wgtDownloadErrorTable')
      shinyjs::hide('wgtIngestButton')
      shinyjs::hide('wgtShowAllErrorsLink')
    }
    
    renderDataValidationOutcomes(outcomes <- RV$ValidationOutcomes)
    
  })
  
  #### ^ Render Site Ingestion Map ######  
  output$UI_IngestMap <- renderLeaflet({
    req(RV$ValidationOutcomes)
    if(RV$ValidationOutcomes$Type=='Validation'){
    renderDataValidationOutcomesSiteMap(outcomes=RV$ValidationOutcomes)
    }else{
      
    }
  })
  
  

####. ####
  ####  ***** Lab Data Ingestion  *****  #####
  
  #### ^ Upload Lab Data Excel File ####
  output$wgtLabDataIngestFileInfo <-  renderText({

    shinyjs::hide('wgtValidateButtonLabResults')
    file <- input$wgtXLFileLabData
    req(file)
    fname <- file$datapath
    r <- OS$IngestHelpers$checkXLFileFormat(fname, OS$Constants$UploadTypes$Lab_Data)

    print(r)
    if(!r$OK){

    }else{
      shinyjs::show('wgtValidateButtonLabResults')
    }
    paste0(r$Message)
  })
  
  
  #### ^ Validate Lab Data ####
  
  observeEvent(input$wgtValidateButtonLabResults, {
    req(RV$ConfigName)
    isolate({
      if(RV$ConfigName=='NSMP'){
        t=RV$Keys$Token
      }else{
        t=NULL
      }
      outcome <- OS$Validation$ValidateLabData(con = RV$DBCon$Connection, keys=RV$Keys, fname=input$wgtXLFileLabData$datapath, config=RV$ConfigName)
      RV$LabValidationOutcomes <- outcome

      if(RV$LabValidationOutcomes$ErrorCount==0){
        shinyjs::show('wgtIngestButtonLabResults')
        shinyjs::show('wgtLabDataIngestReminderMessage')
      }
    })
  })

  output$wgtLabDataIngestReminderMessage<-  renderText({
    HTML('<p>NB. Any Lab data in the DB that matches these records will be overwitten while ingesting this lab data</p>')
  })
  
  
  #### ^ Render Lab validation errors table  #### 
  output$wgtLabDataValidationResultsTable <- renderReactable({
    req(RV$LabValidationOutcomes)
    
    if(RV$LabValidationOutcomes$Type=='Validation'){
      
      if(nrow(RV$LabValidationOutcomes$validationResultsTable) > 0){
        shinyjs::show('wgtDownloadLabErrorTable')
        getLabValidationResultsReactTable(vTab=RV$LabValidationOutcomes$validationResultsTable)
      }else{
        shinyjs::hide('wgtDownloadLabErrorTable')
      }
    }else{
      
    }
  })

  
  ### ^ Render Lab validation & Ingestion outcomes ####  
  output$wgtLabDataIngestOutcomeInfo <-  renderText({
    req( RV$LabValidationOutcomes)
    renderLabDataValidationOutcomes(outcomes =  RV$LabValidationOutcomes )
  })
  
  observe({
    req( RV$LabValidationOutcomes)
    if(RV$LabValidationOutcomes$Type=='Ingestion'){
      shinyjs::hide('wgtDownloadLabErrorTable')
      shinyjs::hide('wgtIngestButtonLabResults')
      shinyjs::hide('wgtLabDataIngestReminderMessage')
    }
  })
  
  
 #### ^ Ingest Lab Data  #### 
  observeEvent(input$wgtIngestButtonLabResults, {
    
    file <- input$wgtXLFileLabData
    req(file)
    fname <- file$datapath
    outcome <- OS$DB$IngestData$IngestLabData(con=RV$DBCon, keys=RV$Keys, fname=fname)
    RV$LabValidationOutcomes <- outcome
  })
  
  
  
  
  #### ^ Download Lab Validation Errors Table ####
  output$wgtDownloadLabErrorTable <- downloadHandler(
    filename = function() {
      req(RV$LabValidationOutcomes)
      if(RV$Keys$ProjectCode=='NSMP'){
        tof <-  paste0('LabDataValidationErrors_', RV$Keys$ProjectCode, '_', RV$Keys$Token, '.csv')
      }else{
        tof <-  paste0('LabDataValidationErrors_', RV$Keys$ProjectCode, '.csv')
      }
    },
    content = function(file) {
      write.csv(RV$LabValidationOutcomes$validationResultsTable, file)
    }
  )
  
  
  
  
  
  ###. ####
  ### ***** Photos Ingestion ***** ####  
  
  #### ^ Upload Photos spreadsheet ####
#  observe({
  output$wgtPhotosIngestXLInfo <-  renderText({
  
  
    req(input$wgtXLFilePhotosDataEntrySheet)
    shinyjs::hide('wgtXLFilePhotosImages')
    file <- input$wgtXLFilePhotosDataEntrySheet
    req(file)
    odir <- paste0(tempdir(), '/Photos/', RV$Keys$AgencyCode, '_', RV$Keys$ProjectCode )
    
    if(dir.exists(odir)){
      unlink(odir, recursive = T)
    }
    dir.create(odir, recursive = T)
    of <- paste0(odir, '/photos.xlsx')
    file.copy(file$datapath, of)
    r <- OS$IngestHelpers$checkXLFileFormat(fname=of, OS$Constants$UploadTypes$Photos)
    if(!r$OK){
    }else{
      shinyjs::show('wgtXLFilePhotosImages')
    }
    paste0(r$Message)
  })
  
  
  
  #### ^ Upload Photos image files ####
  output$wgtPhotosIngestFileInfo <-  renderText({
    
    shinyjs::hide('wgtValidateButtonPhotos')
    files <- input$wgtXLFilePhotosImages
    req(files)

    fname <- files$datapath
    odir <- paste0(tempdir(), '/Photos/', RV$Keys$AgencyCode, '_', RV$Keys$ProjectCode )
    file.copy(files$datapath, paste0(odir, '/', basename(files$name)))
    
    if(length(files)>0){
      shinyjs::show('wgtValidateButtonPhotos')
    }else{
      shinyjs::hide('wgtValidateButtonPhotos')
    }
    if(nrow(files)==1){
      paste0(nrow(files), ' photo was uploaded.')
    }else{
      paste0(nrow(files), ' photos where uploaded.')
    }
    
  })
  
  
  #### ^ Photo Validation  ####
  observeEvent(input$wgtValidateButtonPhotos,{
    
    req(input$wgtXLFilePhotosDataEntrySheet, input$wgtXLFilePhotosImages, RV$DBCon )
    
    outcome <- OS$Validation$validatePhotos( con=RV$DBCon$Connection, keys = RV$Keys )
    RV$ValidationPhotosOutcomes <- outcome
    
    if(RV$ValidationPhotosOutcomes$ErrorCount==0){
      shinyjs::show('wgtIngestButtonPhotos')
      shinyjs::show('wgtPhotosIngestReminderMessage')
    }
  })
  
  ### ^ Render Lab validation & Ingestion outcomes ####  
  output$wgtPhotoIngestOutcomeInfo <-  renderText({
    req( RV$ValidationPhotosOutcomes)
    renderPhotoValidationOutcomes(outcomes =  RV$ValidationPhotosOutcomes )
  })
  
  output$wgtPhotosIngestReminderMessage<-  renderText({
    HTML('<p>NB. Any exisiting photos with the same filename for a given site will be overwritten while ingesting this set of photos</p>')
  })
  
  #### ^ Render the Photo Validation Table ####
  output$wgtPhotosValidationResultsTable <- renderReactable({
    req(RV$ValidationPhotosOutcomes)
    
    if(RV$ValidationPhotosOutcomes$Type!='Ingestion'){
      if(nrow( RV$ValidationPhotosOutcomes$validationResultsTable) > 0){
        getPhotoValidationResultsReactTable(RV$ValidationPhotosOutcomes$validationResultsTable)
      }
    }
    
    
  })
  
  observeEvent(input$wgtIngestButtonPhotos, {
    RV$IngestPhotosCount = RV$IngestPhotosCount + 1
  })
  
  #### ^ Ingest Photos ####
  observe({
    if(RV$IngestPhotosCount>1){
      req(RV$DBCon,input$wgtValidateButtonPhotos )
       RV$ValidationPhotosOutcomes <- OS$DB$IngestData$IngestPhotos(RV$DBCon$Connection, RV$Keys)
     
    }
  })
  
  observe({
    req( RV$ValidationPhotosOutcomes)
    if(RV$ValidationPhotosOutcomes$Type=='Ingestion'){
      shinyjs::hide('wgtPhotosValidationResultsTable')
      shinyjs::hide('wgtIngestButtonPhotos')
      shinyjs::hide('wgtPhotosIngestReminderMessage')
    }
  })
  
  
  

  ###. ####
  ### ***** Flat File ***** ####
 
  
  ####### ^ Get Flat File Data Frame   #######
  observeEvent(input$vwgtViewSiteButtonFlatView, {
    
    req(RV$DBCon, input$vwgtSiteIDFlatView)
    withBusyIndicatorServer("vwgtViewSiteButtonFlatView", {
    
    xlPathName <- paste0(getwd(), '/www/Configs/',RV$ConfigName, '/', RV$DataEntryFileName)
    df <- OS$Reporting$FlatSheet$makeFlatSiteDescriptionSheetfromDB(con=RV$DBCon$Connection, fname=xlPathName, agency=RV$Keys$AgencyCode, proj=RV$Keys$ProjectCode, sid=input$vwgtSiteIDFlatView, oid=1)
    RV$FlatViewSiteDF <- df
    })
    
  })
  
  
  ####### ^ Render Flat File View   #######
  output$wgtSiteFlatViewTable <- renderReactable({
   req(RV$FlatViewSiteDF)
   formatFlatSheet (RV$FlatViewSiteDF)
  })
  
  
  #### ^ Render Publish type   ####  
  output$uiFlatViewSitePublishType<-  renderText({
    req(RV$ConfigName, input$vwgtSiteIDFlatView)
    if(RV$ConfigName=='NSMP'){
      shinyjs::show('uiSiteViewSitePublishType')
      if(input$vwgtSiteIDFlatView %in% RV$PublishedAndDraftSiteInfo$Draft$s_id){
        message <- 'This site is  <span style="color:orange">Draft</span><BR><BR>'
      }else if (input$vwgtSiteIDFlatView %in% RV$PublishedAndDraftSiteInfo$Published$s_id) {
        message <- 'This site is  <span style="color:green">Published</span><BR><BR>'
      }
      paste0(message)
    }
  })
  
  
  ####.####
  ####. ***** Sites Summary ****** ####
  
  observe({
    req(RV$Keys, RV$DBCon, RV$ConfigName)
    RV$SiteUpdateCount
    RV$SiteSummaryInfo <-  getSiteSummaryInfo(con=RV$DBCon, keys=RV$Keys, RV$ConfigName)
  })
  
  ### ^ Render Sites Summary ####  
  output$wgtSitesSummaryInfo <-  renderText({
    req(RV$SiteSummaryInfo)
    RV$SiteUpdateCount
    renderSiteSummary(RV$SiteSummaryInfo)
  })
  
  #### ^ Render Site Summary Map ######  
  output$UI_SiteSummaryMap <- renderLeaflet({
    req(RV$SiteSummaryInfo)
    RV$SiteUpdateCount
    renderSiteSummaryMap(RV$SiteSummaryInfo)
  })
  
  
  
  output$wgtSiteDataSummaryTable <- renderReactable({
    req(RV$SiteSummaryInfo)
    RV$SiteUpdateCount
    formatHorizonsSummaryTable(si=RV$SiteSummaryInfo)
  })
  
  
  ###.####
  #### ***** Photos ***** #####
  #### ^ Update site photos select list  #######
  
  observe({
    req(input$vwgtSiteIDPhotoView, RV$ConfigName)
    
    if(RV$ConfigName=='NSMP'){
      sql <- paste0("SELECT * FROM [NatSoil].[dbo].[PHOTOS] 
                  where agency_code='", RV$Keys$AgencyCode, "' and proj_code='", RV$Keys$ProjectCode,
                    "' and s_id='", input$vwgtSiteIDPhotoView, "' and o_id=2")
      con <- OS$DB$Config$getCon(OS$DB$Config$DBNames$NatSoilStageRO)$Connection
    }else{
      sql <- paste0("SELECT * FROM [PHOTOS] 
                  where agency_code='", RV$Keys$AgencyCode, "' and proj_code='", RV$Keys$ProjectCode,
                    "' and s_id='", input$vwgtSiteIDPhotoView, "' and o_id='1'")
      con <-RV$DBCon$Connection
    }

   df <- OS$DB$Helpers$doQuery(con, sql)
   if(nrow(df)>0){
      RV$CurrentPhotoInfoTable <- df
   }
  })
  
  
  observe({
    req(RV$CurrentPhotoInfoTable)
    updateSelectInput(inputId = 'wgtPhotosSelectList', choices = RV$CurrentPhotoInfoTable$photo_alt_text )
  })
  
  output$wgtPhotosImage <- renderImage({
   
    df <- RV$CurrentPhotoInfoTable 
    rec <- df[df$photo_alt_text == input$wgtPhotosSelectList, ]
   
    a=NULL
    if(nrow(rec)==1){a=1}
    req(a)
    
    outfile <- tempfile(fileext = '.jpg')
    binData <- rec$photo_img
    content<-unlist(binData)
    writeBin(content, con = outfile)
     
    ext <- tools::file_ext(rec$photo_filename)
    if(ext=='jpg'){
    img <- readJPEG(outfile)
    d <- dim(img)
    } else if(ext=='png'){
      img <- readPNG(outfile)
      d <- dim(img)
    }else{}
    
    RV$PhotoInfo$Width =d[1]
    RV$PhotoInfo$Height = d[2]
    
    iratio <- d[1]/d[2]
    
    list(src = outfile,
         contentType = 'image/jpg',
         width = 700,
         height = 700 * iratio,
         alt = "")
  }, deleteFile = TRUE)

  
  
  output$uiPhotoInfo <-  renderText({
    req(RV$CurrentPhotoInfoTable, input$wgtPhotosSelectList)
    
    df <- RV$CurrentPhotoInfoTable 
    rec <- df[df$photo_alt_text == input$wgtPhotosSelectList, ]
    
    if(nrow(rec) > 0){
     ot <- paste0('<p><b>Date : </b>', rec$photo_taken_date, '</p>',
                  '<p><b>File Name : </b>', rec$photo_filename, '</p>',
                  '<p><b>Type : </b>', rec$photo_type_code, '</p>',
                  '<p><b>width : </b>', RV$PhotoInfo$Width, '</p>',
                  '<p><b>Height : </b>', RV$PhotoInfo$Height, '</p>'
                  ) 
    }
  })
  
  observe({
    req(input$wgtPhotosSelectList)
    shinyjs::show('wgtPhotoDownloadLink')
  })
  
  #### ^ Download Site Photo ####
  output$wgtPhotoDownloadLink <- downloadHandler(
    
    filename = function() {
      df <- RV$CurrentPhotoInfoTable 
      rec <- df[df$photo_alt_text == input$wgtPhotosSelectList, ]
      
      ext <- tools::file_ext(rec$photo_filename)
      fname = paste0(rec$agency_code, "_", rec$proj_code, "_", rec$s_id, "_", rec$photo_alt_text, '.', ext)
      file <- fname
    },
    content = function(file) {
      
      df <- RV$CurrentPhotoInfoTable 
      rec <- df[df$photo_alt_text == input$wgtPhotosSelectList, ]
      outfile <- tempfile(fileext = '.jpg')
      binData <- rec$photo_img
      content<-unlist(binData)
      writeBin(content, con = outfile)
      file.copy(outfile, file, overwrite = T)
      on.exit(unlink(outfile))
    }
  )
  
  
  
  
  ###.####
  #### ***** Publish Sites to NatSoil ***** #####
  
  
  observe({
    req(RV$DBCon, RV$ConfigName)
      
    if(RV$ConfigName=='NSMP'){
      con <- OS$DB$Config$getCon(OS$DB$Config$DBNames$NatSoilStageRO)$Connection
      sql <- 'select * from Officers order by offr_code'
      df <- OS$DB$Helpers$doQuery(con, sql)
      updateSelectInput(session, 'wgtAuthoriser', choices=c('None', df$offr_name), selected = 'None')
      dbDisconnect(con)
    }
  })
  
  output$wgtHoldingSitesTable <- renderReactable({
    req(RV$PublishedAndDraftSiteInfo)
    PublishSites_formatTable(RV$PublishedAndDraftSiteInfo$Draft, type='Draft')
  })
  
  output$wgtPublishedSitesTable <- renderReactable({
    req(RV$PublishedAndDraftSiteInfo)
    PublishSites_formatTable(RV$PublishedAndDraftSiteInfo$Published, type='Published')
  })
    
  
  output$wgtToDoSitesTable <- renderReactable({
    req(RV$DBCon, RV$ConfigName)
    PublishSites_formatToDoTable(con=RV$DBCon$Connection, keys=RV$Keys)
  })
  
  observe({
    req(RV$PublishedAndDraftSiteInfo)
    selectedSitesRows <- reactable::getReactableState("wgtHoldingSitesTable", "selected")

    if(is.null(selectedSitesRows)){
      disable('wgtPublishSitesBtn')
    }else{
        if(length(selectedSitesRows) > 0 & input$wgtAuthoriser != 'None'){
          enable('wgtPublishSitesBtn')
        }else{
          disable('wgtPublishSitesBtn')
        }
    }
    
  })
  
  observeEvent(input$wgtPublishSitesBtn, {
    req(RV$DBCon)
    selectedSitesRows <- reactable::getReactableState("wgtHoldingSitesTable", "selected")
    selRowsDF <- RV$PublishedAndDraftSiteInfo$Draft[selectedSitesRows,]
    publishSitesToNatsoil(selectedDraftRows=selRowsDF, authPerson = input$wgtAuthoriser)
    RV$SiteUpdateCount =  RV$SiteUpdateCount + 1
    
  })

  
}  #### End of server

shinyApp(ui = ui, server = server)
