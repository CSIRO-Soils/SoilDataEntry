
source('C:/Users/sea084/OneDrive - CSIRO/RossRCode/Git/Shiny/Apps/NationalSoilMonitoring/NSMData/System/ObjectStore.R')

dbi <- OS$DB$Config$getCon('AppDB')

con <- dbi$Connection

con

df <- read.csv('C:/Users/sea084/OneDrive - CSIRO/RossRCode/Git/Shiny/Apps/SoilDataIngestR/DataBase/DBInfo.csv')
DBI::dbWriteTable(con, 'NatSoil_DBInfo', df)

df <- read.csv('C:/Users/sea084/OneDrive - CSIRO/RossRCode/Git/Shiny/Apps/SoilDataIngestR/DataBase/TableLevels.csv')
DBI::dbWriteTable(con, 'NatSoil_TableLevels', df)

df <- read.csv('C:/Users/sea084/OneDrive - CSIRO/RossRCode/Git/Shiny/Apps/SoilDataIngestR/MetaTables/CODES.csv')
DBI::dbWriteTable(con, 'NatSoil_Codes', df)
