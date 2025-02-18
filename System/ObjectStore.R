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
OS$DB$IngestSiteData <- get_IngestFunctions()
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
OS$Validation <- get_DataValidationFunctions()
OS$Validation$Photos <- get_ValidationPhotos()





str(OS, max.level = 1)






