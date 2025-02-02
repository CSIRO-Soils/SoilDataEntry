library(DBI)



get_DBHelpers <- function()
{
  DB <- list()
  
  
  DB$doQuery <- function(con, sql){
        res <- dbSendQuery(con, sql)
        rows <- dbFetch(res)
        dbClearResult(res)
        return(rows)
      }
      
  DB$doInsert <- function(con, sql){
        if(!is.null(sql)){
        res <- dbSendStatement (con, sql)
        rows <- dbClearResult(res)
        return(rows)
        }else{
          return(0)
        }
      }
      
  DB$doExec <- function(con, sql){
        res <- dbExecute (con, sql)
        return()
      }
      
  DB$deleteAllData <- function(con){
    
    appcon <- OS$DB$Config$getCon(OS$DB$Config$DBNames$AppDB)$Connection
    tableLevels <- OS$DB$Helpers$doQuery(appcon, "select * from NatSoil_TableLevels")
    dbDisconnect(appcon)
    
        dfd <- tableLevels[rev(order(tableLevels$Level)), ]
        for (i in 1:nrow(dfd)) {
          rec<-dfd[i,]$Table
          print(paste0('Deleting data from ', rec))
          OS$DB$Helpers$doExec(con, paste0('DELETE from ', rec))
        }
  }
  
  DB$deleteAllHorizons <- function(con){
    
    appcon <- OS$DB$Config$getCon(OS$DB$Config$DBNames$AppDB)$Connection
    tableLevels <- OS$DB$Helpers$doQuery(appcon, "select * from NatSoil_TableLevels")
    dbDisconnect(appcon)
    
    dfd <- tableLevels[rev(order(tableLevels$Level)), ]
    for (i in 1:(nrow(dfd)-3)) {
      rec<-dfd[i,]$Table
      print(paste0('Deleting data from ', rec))
      OS$DB$Helpers$doExec(con, paste0('DELETE from ', rec))
    }
  }
  
  
  DB$deleteWholeSite <- function(con, verbose=F, agencyCode='994', projCode='NSMP', siteID=1, obsNo=NULL){
    
    appcon <- OS$DB$Config$getCon(OS$DB$Config$DBNames$AppDB)$Connection
    tableLevels <- OS$DB$Helpers$doQuery(appcon, "select * from NatSoil_TableLevels")
    dbDisconnect(appcon)
    
    dfd <- tableLevels[rev(order(tableLevels$Level)), ]
    for (i in 1:nrow(dfd)) {
      rec<-dfd[i,]$Table
      if(verbose){  print(paste0('Deleting data from ', rec)) }
      if(!is.null(obsNo)){
      sql <- paste0("DELETE from ", rec, " WHERE 
                         agency_code = '", agencyCode, "' and ",
                    "proj_code = '", projCode, "' and ",
                    "s_id = '", siteID, "' and ",
                    "o_id = '", obsNo
      )
      }else{
        sql <- paste0("DELETE from ", rec, " WHERE 
                         agency_code = '", agencyCode, "' and ",
                      "proj_code = '", projCode, "' and ",
                      "s_id = '", siteID, "'"
        )
        
      }
     OS$DB$Helpers$doExec(con, sql)
    }
    
  }

return(DB)

}

