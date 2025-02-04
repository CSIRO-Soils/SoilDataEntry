
get_LoggingFunctions <- function()
{
  lg<- list()

    lg$logSession <- function(configName, keys){
      
      sql <- paste0("Insert into log_Sessions ('Config', 'AgencyCode', 'ProjectCode', 'Token', 'DateTime') 
                      values('", configName, "', '", keys$AgencyCode, "', '", keys$ProjectCode, "',  '", keys$Token, "', '",  Sys.time(), "')")
      con <- OS$DB$Config$getCon(OS$DB$Config$DBNames$AppDB)$Connection
      OS$DB$Helpers$doInsert(con, sql)
      
    }

    return(lg)
}