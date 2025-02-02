################################################################# #
#####       Author : Ross Searle                              ###
#####       Date :  Thu Jan 23 14:28:56 2025                  ###
#####       Purpose : Natsoil specific queries                ###
#####       Comments :                                        ###
################################################################# #


#codes <<- read.csv('./MetaTables/CODES.csv')

get_NatSoilQueries <- function()
{
  ns <- list()

  ns$getAgencyCodes<- function(con){
        
        sql <- paste0("SELECT AGENCY_CODE FROM  AGENCIES")
        agc <- OS$DB$Helpers$doQuery(con, sql)
        return(agc)
      }
      
      ns$getProjects <- function(con, agencyCode){
        
        sql <- paste0("SELECT * from PROJECTS where agency_code='", agencyCode, "'")
        projs <- OS$DB$Helpers$doQuery(con, sql)
        return(projs)
      }
      
      ns$getLabMethods <- function(con){
        
        sql <- paste0("SELECT * from LAB_METHODS")
        meths <- OS$DB$Helpers$doQuery(con, sql)
        return(meths)
      }
      
      
      ns$getAgenciesAndProjectsWithData <- function(con){
        
        sql <- 'SELECT SITES.agency_code, SITES.proj_code, COUNT(SITES.s_id) AS SiteCount
      FROM   AGENCIES INNER JOIN
                   PROJECTS ON AGENCIES.AGENCY_CODE = PROJECTS.agency_code INNER JOIN
                   SITES ON PROJECTS.agency_code = SITES.agency_code AND PROJECTS.proj_code = SITES.proj_code
      GROUP BY SITES.agency_code, SITES.proj_code'
        agprojs <- OS$DB$Helpers$doQuery(con, sql)
        return(agprojs)
      }
      
      ns$getColourHorizons <- function(con, agencyCode, projectCode, siteID, obsID){
        
      sql <- paste0("SELECT  HORIZONS.agency_code,  HORIZONS.proj_code,  HORIZONS.s_id,  HORIZONS.o_id,  HORIZONS.h_no,  HORIZONS.h_desig_master,  HORIZONS.h_desig_num_pref,  HORIZONS.h_desig_subdiv,  HORIZONS.h_desig_suffix, 
                    HORIZONS.h_upper_depth,  HORIZONS.h_lower_depth,  HORIZONS.h_texture,  HORIZONS.h_texture_qual,  COLOURS.col_hue_val_chrom
      FROM    HORIZONS INNER JOIN
                    COLOURS ON  HORIZONS.agency_code =  COLOURS.agency_code AND  HORIZONS.proj_code =  COLOURS.proj_code AND  HORIZONS.s_id =  COLOURS.s_id AND  HORIZONS.o_id =  COLOURS.o_id AND 
                    HORIZONS.h_no =  COLOURS.h_no
      WHERE ( HORIZONS.agency_code = '",agencyCode,"') AND 
                      ( HORIZONS.proj_code = '",projectCode,"') 
                      AND ( HORIZONS.s_id = '",siteID,"') 
                      AND ( HORIZONS.o_id = '",obsID,"')")
        
        hors <- OS$DB$Helpers$doQuery(con, sql)
        return(hors)
      }
      
      
      ns$getDataAuthInfo <- function(con){
        sql <- 'SELECT dbo.CSIS_Allowed_Sites.agency_code, dbo.CSIS_Allowed_Sites.proj_code, COUNT(dbo.CSIS_Allowed_Sites.s_id) AS SiteCount, dbo.CSIS_Allowed_Sites.access_level, dbo.CSIS_Allowed_Sites.custodian
      FROM   dbo.CSIS_Allowed_Sites INNER JOIN
                   dbo.SITES ON dbo.CSIS_Allowed_Sites.agency_code = dbo.SITES.agency_code AND dbo.CSIS_Allowed_Sites.proj_code = dbo.SITES.proj_code AND dbo.CSIS_Allowed_Sites.s_id = dbo.SITES.s_id
      GROUP BY dbo.CSIS_Allowed_Sites.access_level, dbo.CSIS_Allowed_Sites.proj_code, dbo.CSIS_Allowed_Sites.agency_code, dbo.CSIS_Allowed_Sites.custodian
      ORDER BY dbo.CSIS_Allowed_Sites.agency_code, dbo.CSIS_Allowed_Sites.proj_code'
        
        auth <- OS$DB$Helpers$doQuery(con, sql)
        return(auth)
      }
      
      ns$getHiddenNatSoilData <- function(con, key){
        
        sql <- paste0("select * from CSIS_USER_API_KEYS where apikey = '", key, "'")
        res <- doQuery(con, sql)
        rec <- res[1,]
        agens <- str_split(rec$agencies, ',')[[1]]
        projs <- rec$projects
        pbits <- str_split(projs, ',')[[1]]
        # psql <- paste0('( ', paste0(sQuote(pbits), collapse = ', '), ')')
        # psql2 <- str_replace(psql, '"', "\'⁠")
        
        odf <- data.frame(agency_code=character(),  proj_code=character(), SiteCount=character())
        for (i in 1:length(agens)) {
          a <- agens[i]
          for (j in 1:length(pbits)) {
            sql2 <- paste0("select * from projects where agency_code = '", a, "' and proj_code = '", pbits[j], "'" )
            sdf <- OS$DB$Helpers$doQuery(con, sql2)
            if(nrow(sdf)>0){
                rdf <- data.frame(agency_code=sdf$agency_code, proj_code=sdf$proj_code, SiteCount=-1)
                odf <- rbind(odf, rdf)
            }
          }
        }
        return(odf)
        
      }
      
      
      ns$getHorizons <- function(con, agencyCode, projectCode, siteID, obsID){
        
        sql <- paste0("SELECT  * FROM HORIZONS WHERE ( HORIZONS.agency_code = '",agencyCode,"') AND 
                      ( HORIZONS.proj_code = '",projectCode,"') 
                      AND ( HORIZONS.s_id = '",siteID,"') 
                      AND ( HORIZONS.o_id = '",obsID,"') 
                      ORDER BY h_no
                      ")
        
        hors <- OS$DB$Helpers$doQuery(con, sql)
        return(hors)
      }
      
      
      ns$getSitesForAProject <- function(con, agencyCode, projectCode){
        
        sql <- paste0("SELECT s_id FROM  OBSERVATIONS WHERE (agency_code = '",agencyCode,"') AND (proj_code = '",projectCode,"')")
        sites <- OS$DB$Helpers$doQuery(con, sql)
        return(sites)
      }
      
      ns$getObservationsForASite <- function(con, agencyCode, projectCode, siteID){
        
        sql <- paste0("SELECT o_id FROM  OBSERVATIONS WHERE (agency_code = '",agencyCode,"') AND (proj_code = '",projectCode,"') AND (s_id = '", siteID, "')")
        obs <- OS$DB$Helpers$doQuery(con, sql)
        return(obs)
      }
      
      ns$getAgencyInfo <- function(con, agencyCode){
        
        sql <- paste0("SELECT  AGENCIES.* FROM AGENCIES WHERE (AGENCY_CODE = '", agencyCode, "')")
        agn <- OS$DB$Helpers$doQuery(con, sql)
        return(agn)
      }
      
      ns$getSiteCount <- function(con){
        sql <- "select proj_code, s_id from SITES"
        scnt <- OS$DB$Helpers$doQuery(con, sql)
        return(scnt)
      }
      
      ns$getProjectCount <- function(con){
        sql <- "select count() as cnt from PROJECTS"
        pcnt <- OS$DB$Helpers$doQuery(con, sql)
        return(pcnt)
      }
      
      ns$getProjectInfo <- function(con, agencyCode = agencyCode, projectCode=projectCode){
        
        sql <- paste0("SELECT  PROJECTS.* FROM    PROJECTS WHERE (agency_code = '", agencyCode, "') AND (proj_code = '", projectCode, "')")
        agn <- OS$DB$Helpers$doQuery(con, sql)
        return(agn)
      }
      
      ns$getProjectSInfo <- function(con){
        
        sql <- paste0("SELECT CAST(PROJECTS.agency_code AS INT) AS agency_code, AGENCIES.AGENCY_NAME, PROJECTS.proj_code, PROJECTS.proj_name, PROJECTS.proj_manager_code, PROJECTS.proj_biblio_ref, PROJECTS.proj_finish_date, 
                      PROJECTS.proj_start_date, PROJECTS.proj_o2d
                      FROM   PROJECTS INNER JOIN
                      AGENCIES ON PROJECTS.agency_code = AGENCIES.AGENCY_CODE
                      ORDER BY PROJECTS.agency_code, PROJECTS.proj_code")
        prj <- OS$DB$Helpers$doQuery(con, sql)
        return(prj)
      }
      
      ns$getProjectsViewInfo <- function(con){
        
        sql <- paste0("SELECT * from v_ProjectSummary")
        prj <- OS$DB$Helpers$doQuery(con, sql)
        return(prj)
      }
      
      
      ns$getLocationInfo <- function(con, agencyCode, projectCode, siteID, obsID){
        
        sql <- paste0("SELECT o_latitude_GDA94, o_longitude_GDA94 FROM OBSERVATIONS WHERE (agency_code = '",agencyCode,"') AND (proj_code = '",projectCode,"') 
                      AND (s_id = '", siteID, "') AND (o_id = '", obsID, "')")
        loc <- OS$DB$Helpers$doQuery(con, sql)
        return(loc)
      }
      
      ns$getProjectLocationInfo <- function(con, agencyCode, projectCode){
        
        sql <- paste0("SELECT o_latitude_GDA94, o_longitude_GDA94 FROM OBSERVATIONS WHERE (agency_code = '",agencyCode,"') 
                      AND (proj_code = '",projectCode,"' )")
        loc <- OS$DB$Helpers$doQuery(con, sql)
        return(loc)
      }
      
      
      ns$getSiteInfo <- function(con, agencyCode, projectCode, siteID, obsID){
        
        sql <- paste0("SELECT OBSERVATIONS.*, SITES.*
                        FROM   OBSERVATIONS INNER JOIN
                           SITES ON  OBSERVATIONS.agency_code =  SITES.agency_code AND  OBSERVATIONS.proj_code =  SITES.proj_code AND 
                           OBSERVATIONS.s_id =  SITES.s_id
                        WHERE ( OBSERVATIONS.agency_code = '",agencyCode,"') AND ( OBSERVATIONS.proj_code = '",projectCode,"') 
                        AND ( OBSERVATIONS.s_id = '",siteID,"') AND ( OBSERVATIONS.o_id = '",obsID,"')")
        site <- OS$DB$Helpers$doQuery(con, sql)
        return(site)
      }
      
      
      
      
      ns$getLevel3Info <- function(con, table, agencyCode, projectCode, siteID, obsID){
        
        sql <- paste0("SELECT ", table, ".*
      FROM  ", table, "
      WHERE (agency_code = '",agencyCode,"') AND (proj_code = '",projectCode,"') AND (s_id = '",siteID,"') AND (o_id = '",obsID,"')")
        df <- OS$DB$Helpers$doQuery(con, sql)
        return(df)
        
      }
      
      ns$getLevel4Info <- function(con, table, agencyCode, projectCode, siteID, obsID, hnum){
        
        sql <- paste0("SELECT ", table, ".*
      FROM  ", table, "
      WHERE (agency_code = '",agencyCode,"') AND (proj_code = '",projectCode,"') AND (s_id = '",siteID,"') AND (o_id = '",obsID,"') AND (h_no = '",hnum,"')")
        df <- OS$DB$Helpers$doQuery(con, sql)
        return(df)
        
      }
      
      ns$getLabData <- function(con, agencyCode, projectCode, siteID, obsID){
        
        sql <- paste0("SELECT LAB_RESULTS.agency_code, LAB_RESULTS.proj_code, LAB_RESULTS.s_id, LAB_RESULTS.o_id, LAB_RESULTS.h_no, LAB_RESULTS.samp_no, 
                      LAB_RESULTS.labr_no, LAB_RESULTS.labm_code, LAB_RESULTS.labr_value,
                      
                      SAMPLES.samp_upper_depth, SAMPLES.samp_lower_depth
                      
                      FROM   LAB_RESULTS INNER JOIN SAMPLES ON LAB_RESULTS.agency_code = SAMPLES.agency_code AND LAB_RESULTS.proj_code = SAMPLES.proj_code 
                      AND LAB_RESULTS.s_id = SAMPLES.s_id AND LAB_RESULTS.o_id = SAMPLES.o_id AND 
                      LAB_RESULTS.h_no = SAMPLES.h_no AND LAB_RESULTS.samp_no = SAMPLES.samp_no 
                      WHERE (LAB_RESULTS.agency_code = '",agencyCode,"') AND (LAB_RESULTS.proj_code = '",projectCode,"') 
                      AND (LAB_RESULTS.s_id = '",siteID,"') AND (LAB_RESULTS.o_id = '",obsID,"')")
        df <- OS$DB$Helpers$doQuery(con, sql)
        return(df)
        
      }
      
      
     ns$getBoundingBoxForProject <- function(con, agencyCode, projCode){
        
        sql <- paste0("SELECT agency_code, proj_code, MIN(o_latitude_GDA94) AS miny, MAX(o_latitude_GDA94) AS maxy, MIN(o_longitude_GDA94) AS minx, MAX(o_longitude_GDA94) AS maxx
                        FROM   OBSERVATIONS
                        GROUP BY agency_code, proj_code 
                        HAVING (agency_code = '", agencyCode, "') AND (proj_code = '", projCode, "')")
        df <- OS$DB$Helpers$doQuery(con, sql)
      }

      return(ns)
}


