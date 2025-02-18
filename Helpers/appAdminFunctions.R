################################################################# #
#####       Author : Ross Searle                                ###
#####       Date :  Mon Feb 17 12:49:34 2025                    ###
#####       Purpose : Admin Functions for the SoilDataEntry App ###
#####       Comments :                                          ###
################################################################# #


get_AppAdmin <- function()
{
  a <- list()
  
  a$InsertNewProjectIntoNatSoilProjects <- function(agencyCode, projCode, projName='', projManager='', proj_start_date='',  proj_finish_date=''){
    
    sql <- paste0("INSERT into PROJECTS ( agency_code, proj_code, proj_name, proj_manager_code, proj_start_date, proj_finish_date )
                      values ('", agencyCode, "' , '", projCode, "', '", projName, "', '", projManager, "', '", proj_start_date, "', '", proj_finish_date, "')")
    
    print(sql)
    con<- OS$DB$Config$getCon(OS$DB$Config$DBNames$NatSoilProjects)
    OS$DB$Helpers$doInsert(ingestCon, sql)
    print(paste0("Inserted new project - ", keys$ProjectCode))
    DBI::dbDisconnect(con)
    
  }
 
  return(a)
}