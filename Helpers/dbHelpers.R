library(DBI)



get_DBHelpers <- function()
{
  DB <- list()
  
  
  makeParameterInsertQuery <- function(sql){
    
    sql <- str_replace_all(sql, "[']", '')
    
    bits = str_split(sql, 'VALUES')
    
    vals <- bits[[1]][2]
    s1 <-str_remove(vals, '[(]')
    s2 <-str_remove(s1,  '[)]')
    sqlRawParams <- str_trim(str_split(s2, ',')[[1]])
    
    flds <- bits[[1]][1]
    f1 <-str_split(flds, '[(]')
    f2 <-str_remove(f1[[1]][2],  '[)]')
    sqlRawFields <- str_trim(str_split(f2, ',')[[1]])
    
    paramSQLStr <- '( '
    paramList <- vector(mode = "list", length = length(sqlRawParams))
    
    for (i in 1:length(sqlRawParams)) {
      paramSQLStr <- paste0(paramSQLStr, ' ?, ')
      
      fld <- sqlRawFields[i]
      
      if(fld %in% c('s_date_desc', 's_trans_date', 'o_date_desc')){
        
        y <- str_sub(sqlRawParams[i], 1, 4)
        m <- str_sub(sqlRawParams[i], 5, 6)
        d <- str_sub(sqlRawParams[i], 7, 8)
        
        dte <- paste0(y, '-', m, '-', d)
        
        paramList[[i]] <- as.character(dte)
      }else{
        paramList[[i]] <-  sqlRawParams[i]
      }
    }
    
    paramSQLStr <-  paste0(gsub(", $" ," ", paramSQLStr), ')')
    
    outSql <- paste0(bits[[1]][1], ' VALUES ', paramSQLStr) 
    
    ol <- list()
    # ol$Vals <- list('994', 'NSMP', 'N20558', as.character('2001-01-01'), as.character('2001-01-01'))  ### this list works for reference
    
    ol$SQL <- outSql
    ol$Vals <- paramList
    return(ol)
    
  }
  
  
  DB$doQuery <- function(con, sql){
        res <- dbSendQuery(con, sql)
        rows <- dbFetch(res)
        dbClearResult(res)
        return(rows)
      }
      
  DB$doInsert <- function(con, sql){
        if(!is.null(sql)){
        
         ql <- makeParameterInsertQuery(sql)
          res <- dbSendStatement(con, ql$SQL)
          dbBind(res,ql$Vals)
          rows <- dbGetRowsAffected(res)
          dbClearResult(res)
          
        return(rows)
        }else{
          return(0)
        }
  }
  
  DB$doInsertUsingRawSQL <- function(con, sql){
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
      # if(!rec %in% c('SITES', 'ELEM_GEOMORPHS', 'LAND_COVER', 'LAND_USES', 'PATT_GEOMORPHS', 'DISTURBANCES')){
      #   
      # sql <- paste0("DELETE from ", rec, " WHERE 
      #                    agency_code = '", agencyCode, "' and ",
      #               "proj_code = '", projCode, "' and ",
      #               "s_id = '", siteID, "' and ",
      #               "o_id = '", obsNo, "'"
      # )
      # }else{
        sql <- paste0("DELETE from ", rec, " WHERE 
                         agency_code = '", agencyCode, "' and ",
                      "proj_code = '", projCode, "' and ",
                      "s_id = '", siteID, "'"
        )
        
      #}

     OS$DB$Helpers$doExec(con, sql)
    }
    
  }

return(DB)

}

