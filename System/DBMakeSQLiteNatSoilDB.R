##################################################################### #
#####       Author : Ross Searle                                  ###
#####       Date :  Wed Jan 22 18:48:58 2025                      ###
#####       Purpose : Generates an empty Natsoil shell in sqllite ###
#####       Comments :                                            ###
##################################################################### #


library("DBI")
library("odbc") 
library("readr") 

get_makeSQLiteNatSoilDB <- function()
{
  m <- list()

      m$makeSQLiteNatSoilDB <- function(con, scriptPath, populateData=T){
      
      print('Reading SQL make DB script...')
      dbExecute(con, 'PRAGMA foreign_keys = ON;')
      
      lns <- readr::read_lines(scriptPath)
      
      sqlist <- list()
      
      sql<- ''
      
      for (i in 1:length(lns)) {
        l<-lns[i]
        if(l != ''){
          if (stringr::str_starts(l, pattern = '[/***]')){
            sql<-''
            l=''
          }
          
          sql <- paste0(sql, l)
            if(stringr::str_detect(l, ';')){
            sqlist <- c(sqlist, sql)
          }
        }
      }
      
     
      #### Generate the blank tables in the DB  
      print('Generating the blank tables...')
      for (i in 1:length(sqlist)) {
        dbExecute(con, sqlist[[i]])
      }
      
      
      if(populateData){
      
       conInfo <- OS$DB$Config$getCon(OS$DB$Config$DBNames$NatSoilStageRO)
       tcon <- conInfo$Connection
        tables <- c('CODES','STATES','AGENCIES','PROJECTS','OFFICERS','LAB_METHOD_TYPES','LAB_METHODS','LAB_PROPERTIES')
        for (i in 1:length(tables)) {
      
          t <- tables[i]
          print(paste0('Inserting data for ', t))
          res <- dbSendQuery(tcon, paste0('select * from ',t))
          recs <- dbFetch(res)
          dbAppendTable(con, t, recs)
          dbClearResult(res)
        }
        
        dbDisconnect(tcon)
        dbDisconnect(con)
      }
      }
      return(m)
}






