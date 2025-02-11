library(DBI)
library(RSQLite)

con <- OS$DB$Config$getCon(OS$DB$Config$DBNames$NatSoilStageRO)$Connection
copyCon <- dbConnect(RSQLite::SQLite(), paste0('c:/temp/copy.db'))


tables <- OS$DB$Helpers$doQuery(con, "SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE'")


for (i in 1:nrow(tables)) {
  
  rec <- tables[i,]
  print(rec$TABLE_NAME)
  
  if(!rec$TABLE_NAME %in% c('__RefactorLog')){
  
      if(rec$TABLE_SCHEMA %in% c('project', 'codes')){
        sql <- paste0('Select * from ', rec$TABLE_SCHEMA ,'.', rec$TABLE_NAME)
        t <- OS$DB$Helpers$doQuery(con,sql)
        
      }else{
        sql <- paste0('Select TOP 1 * from ', rec$TABLE_NAME)
        t <- OS$DB$Helpers$doQuery(con,sql)
        t <- t[-1,]
      }
    
      tabname <- paste0(rec$TABLE_SCHEMA ,'.', rec$TABLE_NAME)
      dbWriteTable(copyCon, tabname, t, overwrite=T )
  
  }
}

dbDisconnect(con)
dbDisconnect(copyCon)
