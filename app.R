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


# http://127.0.0.1:3902/?config=NSMP&agencycode=994&projectcode=NSMP&token=Burnie&adminkey=123
#  ?config=NSMP&token=Burnie&adminkey=123
#  ?config=PacificSoils&agencycode=994&projectcode=PACSOILS
#  ?config=NSMP&agencycode=994&projectcode=NSMP&token=Burnie&adminkey=123
#  ?config=PacificSoils&agencycode=994&projectcode=NSMP&token=Burnie&adminkey=123

#?config=NSMP&agencycode=994&projectcode=NSMP&token=Capital

library(shiny)
library(shinyjs)
library(shinyalert)
library(shinybusy)
library(rhandsontable)
library(DT)
library(munsell)
library(shinycssloaders)
library(sf)
library(leaflet)
library(leaflet.extras)
library(leafem)
library(RColorBrewer)
library(officer)
library(flextable)
library(jsonlite)
library(reactable)
library(shinyBS)
library(lubridate)
library(stringr)


library(jpeg)
library(png)


machineName <- as.character(Sys.info()['nodename'])

if(machineName=='ROHAN-SL'){
  develMode <<- T
}else{
  develMode <<- F
  #Sys.setenv(ODBCSYSINI = "/apps/msodbcsql/17.7.2.1/etc/")
}




#setwd('C:/Users/sea084/OneDrive - CSIRO/RossRCode/Git/Shiny/Apps/NationalSoilMonitoring/NSMData')

source('System/ObjectStore.R')


source("Helpers/busyHelper.R")


####. ####
#### ^ UI Functions load  ####
# source('UI_Modules/Tab_DataIngestion.R' )
# source('UI_Modules/Tab_SiteViewer.R')
# source('UI_Modules/Tab_Admin.R')
# source('UI_Modules/Tab_About.R')

availableDBs <<- c('Portable', "NatSoil")

appcon <- OS$DB$Config$getCon(OS$DB$Config$DBNames$NSMP_HoldingRW)$Connection
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

  ####.   ======  App Configuration  ============== ###### 

#### ^ Reactive Values Instantiation ####
  RV <- reactiveValues()
  RV$DBCon <- NULL
  RV$RequiredParams <- NULL
  RV$SiteSummaryInfo <- NULL
  RV$AvailableSitesIDs <- NULL
  RV$CurrentPhotoInfoTable <- NULL
  
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
        RV$Keys$Token <- OS$AppConfigs$DevelopToken
        RV$ConfigName <- OS$AppConfigs$DevelopConfigName
        RV$Keys$AgencyCode <- OS$AppConfigs$DevelopAgency
        RV$Keys$ProjectCode <- OS$AppConfigs$DevelopProject
        RV$Keys$AdminKey <- OS$AppConfigs$ShowAdminKey
      }else{
        RV$Keys$Token <- 'None'
        RV$ConfigName <- OS$AppConfigs$DevelopToken
        RV$Keys$AdminKey <- 'None'
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
      print('Connecting to DB')
      RV$DBCon <- con
     
  #    updateTabsetPanel(session, "MainTabsetPanel", selected = "Sites Summary"    )
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
    sites <- getListOfAvailableSites(con=RV$DBCon$Connection, keys=RV$Keys)
   
    RV$AvailableSitesIDs <- sites
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
    t1 <- tags$head(tags$style(".shiny-notification {position: fixed; top: 20% ;left: 50%"),
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
  
  
  #### Dynamic IngestionTab Token Box Rendering 
  # output$uiIngestTokenText <- renderUI({
  #   req(RV$ConfigName, RV$ConfigValues)
  #    OS$UI$DynamicUI$ShowHideIngestionTokenTextbox(config=RV$ConfigName, token=RV$Token)
  # })
  
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
   
  
  
  # Dynamic Tabs Rendering Depending on Role 
  # observe({
  #   req(RV$Keys$Token)
  #     OS$UI$DynamicUI$ShowHideTabs(RV$ConfigName, RV$Keys$Token)
  # })
  
  #### ^ Show or hide the Admin Tab   
  # observe({
  #   req(RV$ConfigName)
  #   OS$UI$DynamicUI$ShowHideAdminTab(RV$ConfigName, RV$AdminKey)
  # })
  
  # Show DB Connection Info on Admin Tab  
  # output$uiAdminDBCon <- renderUI({
  #   
  #   req(RV$CurrentDBCon)
  #   html <- paste0('<BR>App is connected to <font color="darkgreen"><b>', RV$CurrentDBCon$Name, '</b></font> - ', RV$CurrentDBCon$Description)
  #   HTML(html)
  # })
  
####.  ####  
####. ======  PAGES  ============ ####
  ####.  ####
  ####  *****  Site Description  *******####

  
  #### ^ Click show site description button to populate data ####
  observeEvent(input$vwgtViewSiteButton,{
    #req( RV$DBcon, input$vwgtAgency, input$vwgtProject, input$vwgtSiteID, input$vwgtObsID)
    
    req( RV$DBCon)
    con <- RV$DBCon$Connection

    withBusyIndicatorServer("vwgtViewSiteButton", {
      
        RV$CurrentSiteLocation <- OS$DB$NatSoilQueries$getLocationInfo(con, '994', 'NSMP', input$vwgtSiteID, input$vwgtObsID)
        RV$SiteDesc <- getSiteDescription(con=con, agencyCode='994', projectCode='NSMP', siteID=input$vwgtSiteID, obsID=input$vwgtObsID)
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
      paste0('NatSoil_', '994', "_", 'NSMP',  "_",input$vwgtSiteID, "_",input$vwgtObsID, '.docx')
    },
    content = function(file) {

      of <-  tempfile(pattern = 'SitesDesc_', fileext = '.docx') 
      ProfPlotPath <- 'C:/Temp/profile.PNG'
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
  
####  Render Project Description   
  # output$pwgtAllProjectsDescription = renderText({
  #   #req(input$vwgtAgency, input$vwgtProject)
  #   req( RV$DBCon)
  #   projs <- RV$AllProjectsInfo[RV$AllProjectsInfo$AgencyCode=='NSMP' & RV$AllProjectsInfo$proj_code=='NSMP', ]
  #   phtml <- getProjectDescriptionHTML(p=projs)
  #   phtml
  # })
  
  #### ^ Render profile diagram   ####  
  
  output$wgtProfile = renderPlot({
    
    req( RV$ProfPlotData)
    
    if(nrow( RV$ProfPlotData) > 0){
      df <- RV$ProfPlotData
      hp <-  getSoilProfileDiagram(input$wgtSiteID, p=df)
      hp
    }
  }, height = 700, width = 400)
  
  
  

  
  ####.####
  ###  ***** Data Ingestion ****  ####
  #### ^ Download Data Entry Template ####
  output$wgtDownloadDataEntrySheet <- downloadHandler(
    filename = function() {
      req(RV$ConfigName)
      if(RV$ConfigName =='NSMP'){
      tof <- str_replace(RV$DataEntryFileName, '.xlsx', paste0('_', RV$Keys$ProjectCode, '_', RV$Keys$Token, '.xlsx'))
      }else{
        tof <- str_replace(RV$DataEntryFileName, '.xlsx', paste0('_', RV$Keys$ProjectCode, '.xlsx'))
      }
    },
    content = function(file) {

      xlPathName <- paste0(getwd(), '/www/Configs/',RV$ConfigName, '/', RV$DataEntryFileName)
    #  shinyBS::createAlert(session, "alert", "waitalert", title = "", content = paste0("<div id='zs1'><img src=wait.gif>&nbsp;&nbsp;Downloading data", " .....</div>"), append = FALSE, dismiss = F)
      
      if(RV$ConfigName =='NSMP'){
        downloadPath <- OS$DataEntry$generateNSMPSiteSheet(fname=xlPathName,  token= RV$Keys$Token)
      }else{
        downloadPath <- xlPathName
      }
      file.copy(downloadPath, file, overwrite = T)
      on.exit(unlink(downloadPath))
    }
  )
  
  #### ^ Upload Excel File ####
  output$wgtIngestFileInfo <-  renderText({
    
    shinyjs::hide('wgtIngestButton')
    file <- input$wgtXLFile
    req(file)
    fname <- file$datapath
    RVExcelFile <- file$datapath
    r <- OS$IngestHelpers$checkXLFileFormat(fname, 'Site Data Sheet')
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
          
          outcome <- OS$Validation$ValidateSites(fname=RV$XLfile, config=RV$ConfigName, token=t)
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
      
      req(RV$ConfigName)
      
      isolate({
        
        RV$XLfile <- input$wgtXLFile$datapath
        # 
        # if(RV$ConfigName==RV$Token){
        #   t=RV$Token
        # }else{
        #   t=NULL
        # }
        # 
        outcome <- OS$DB$IngestSiteData$ingestXL(con=RV$DBCon, XLFile=RV$XLfile)
       # RV$IngestOutcomes <- outcome
        
      })
    }
  })
  
  
  output$uiErrorsTableTitle <-  renderText({
    req(RV$ValidationOutcomes)
    
    if(nrow(RV$ValidationOutcomes$validationResultsTable) > 0){
        paste0('<h4>Validation Errors Table</h4>') 
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

      if(nrow(RV$ValidationOutcomes$validationResultsTable) > 0){
          shinyjs::show('wgtDownloadErrorTable')
          shinyjs::show('wgtShowAllErrorsLink')
        
           getValidationResultsReactTable(vTab=RV$ValidationOutcomes$validationResultsTable)
      }else{
          shinyjs::hide('wgtDownloadErrorTable')
          shinyjs::hide('wgtShowAllErrorsLink')
      }
  })
  
  observe({
    req( RV$ValidationOutcomes$validationResultsTable)
    input$wgtShowAllErrorsLink
    updateReactable("wgtValidationResultsTable", data =  RV$ValidationOutcomes$validationResultsTable)
  })
  
  observeEvent(input$UI_IngestMap_marker_click, { 
    p <- input$UI_IngestMap_marker_click  # typo was on this line
    data <- RV$ValidationOutcomes$validationResultsTable
   idxs <- which(data$Site == as.character(p$id[1]))
   filtered <- data[idxs,]
    updateReactable("wgtValidationResultsTable", data = filtered)
  })

### ^ Render validation outcomes ####  
  output$wgtIngestOutcomeInfo <-  renderText({
    req(RV$ValidationOutcomes)
    renderDataValidationOutcomes(outcomes <- RV$ValidationOutcomes)
  })
  
  #### ^ Render Site Ingestion Map ######  
  output$UI_IngestMap <- renderLeaflet({
    req(RV$ValidationOutcomes)
    renderDataValidationOutcomesSiteMap(outcomes=RV$ValidationOutcomes)
  })
  
  


  
  

  ###. ####
  ### ***** Flat File ***** ####
 
  
  ####### ^ Get Flat File Data Frame   #######
  observeEvent(input$vwgtViewSiteButtonFlatView, {
    
    req(RV$DBCon, input$vwgtSiteIDFlatView)
    withBusyIndicatorServer("vwgtViewSiteButtonFlatView", {
    
    xlPathName <- paste0(getwd(), '/www/Configs/',RV$ConfigName, '/', RV$DataEntryFileName)
    df <- OS$Reporting$FlatSheet$makeFlatSiteDescriptionSheetfromDB(con=RV$DBCon$Connection, fname=xlPathName, agency='994', proj='NSMP', sid=input$vwgtSiteIDFlatView, oid=1)
    RV$FlatViewSiteDF <- df
    })
    
  })
  
  
  ####### ^ Render Flat File View   #######
  output$wgtSiteFlatViewTable <- renderReactable({
   req(RV$FlatViewSiteDF)
   formatFlatSheet (RV$FlatViewSiteDF)
  })
  
  
  
  
  
  ####.####
  ####. ***** Sites Summary ****** ####
  
  observe({
    req(RV$Keys, RV$DBCon, RV$ConfigName)
    RV$SiteSummaryInfo <-  getSiteSummaryInfo(con=RV$DBCon, keys=RV$Keys, RV$ConfigName)
  })
  
  ### ^ Render Sites Summary ####  
  output$wgtSitesSummaryInfo <-  renderText({
    req(RV$SiteSummaryInfo)
    renderSiteSummary(RV$SiteSummaryInfo)
  })
  
  #### ^ Render Site Summary Map ######  
  output$UI_SiteSummaryMap <- renderLeaflet({
    req(RV$SiteSummaryInfo)
    renderSiteSummaryMap(RV$SiteSummaryInfo)
  })
  
  
  
  output$wgtSiteDataSummaryTable <- renderReactable({
    req(RV$SiteSummaryInfo)
    formatHorizonsSummaryTable(si=RV$SiteSummaryInfo)
  })
  
  
  ###.####
  #### ***** Photos ***** #####
  #### ^ Update site photos select list  #######
  
  observe({
    req(input$vwgtSiteIDPhotoView)
    
    sql <- paste0("SELECT *  FROM [NatSoil].[dbo].[PHOTOS] 
                  where agency_code='", RV$Keys$AgencyCode, "' and proj_code='", RV$Keys$ProjectCode,
                  "' and s_id='", input$vwgtSiteIDPhotoView, "' and o_id=2")
    
   con <- OS$DB$Config$getCon(OS$DB$Config$DBNames$NatSoilStageRO)$Connection
   df <- OS$DB$Helpers$doQuery(con, sql)
   dbDisconnect(con)
   RV$CurrentPhotoInfoTable <- df
   
  })
  
  
  observe({
    req(RV$CurrentPhotoInfoTable)
    updateSelectInput(inputId = 'wgtPhotosSelectList', choices = RV$CurrentPhotoInfoTable$photo_alt_text )
  })
  
  output$wgtPhotosImage <- renderImage({
   
    req(input$wgtPhotosSelectList)
    
    df <- RV$CurrentPhotoInfoTable 
    rec <- df[df$photo_alt_text == input$wgtPhotosSelectList, ]
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
         alt = "This is alternate text")
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
  
  

}


shinyApp(ui = ui, server = server)
