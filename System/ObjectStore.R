################################################################# #
#####       Author : Ross Searle                                ###
#####       Date :  Tue Jan 21 11:00:52 2025                    ###
#####       Purpose : Instantiates all of the system functions  ###
#####                 into the Object Store                     ###
#####       Comments :                                          ###
################################################################# #



# setwd('C:/Users/sea084/OneDrive - CSIRO/RossRCode/Git/Shiny/Apps/SoilDataEntry')

#### Source the files with the requisite functions #####

files.sources = list.files(c('./System', './Helpers', './UI_Modules', './Server', './Secrets', './Queries', './Validations'), full.names = T, pattern = '.R')

idx <- which(files.sources=='./System/ObjectStore.R')
files.sources = files.sources[-idx]
for (i in 1:length(files.sources)) {
  print(files.sources[i])
  source(files.sources[i])
}

OS <<- list()
OS$AppAdmin <- get_AppAdmin()
OS$AppConfigs <- get_AppConfigs()
OS$DB$Config <- get_DBConfig()
OS$DataEntry <- get_DataEntryFunctions()
OS$DB$Helpers <- get_DBHelpers()

#OS$DB$IngestSiteData <- get_IngestFunctions()
OS$DB$IngestData <- list() 
OS$DB$IngestData <- c(OS$DB$IngestData, get_IngestFunctions())
OS$DB$IngestData <- c(OS$DB$IngestData, get_IngestPhotos())
OS$DB$IngestData <- c(OS$DB$IngestData, get_LabDataIngestion ())
#OS$Photos <- get_IngestPhotos()

OS$DB$Logins <- get_DBLogins()
OS$DB$NatSoilQueries <- get_NatSoilQueries()
OS$DB$Tools <- get_makeSQLiteNatSoilDB()
OS$Constants <- get_AppConstants()
OS$IngestHelpers <- get_IngestHelpers()
OS$Logging <- get_LoggingFunctions()

OS$PublishSitesToNatSoil <- get_SitePublishingQueries()
OS$Reporting$FlatSheet <- get_FlatSheetFunctions()
OS$DB$SiteSummaryQueries <- get_SiteSummaryQueries()
OS$UI$DynamicUI <- get_DynamicUi_ServerFunctions()

#OS$Validation <- vector(mode='list', length = 3)
OS$Validation = list()
OS$Validation <- c(OS$Validation,  get_ValidateMorphologyData())
OS$Validation <- c(OS$Validation,  get_ValidationPhotos())
OS$Validation <- c(OS$Validation,  get_ValidateLabData())


str(OS, max.level = 1)






