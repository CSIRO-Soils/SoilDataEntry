################################################################# #
#####       Author : Ross Searle                              ###
#####       Date :  Thu Jan 30 14:37:10 2025                  ###
#####       Purpose : Set up the UI based on the supplied     ###
#####                 config parameters in the URL            ###
#####       Comments :                                        ###
################################################################# #


setupUIBasedOnConfigs <- function(config, url){

      if(!is.null(config)){
        
        if(config$ProjectCode != 'NSMP'){

        html <-  tabsetPanel( type = "tabs", id='MainTabsetPanel',
                              Tab_DataIngestion_UI(),
                              Tab_SiteViewer_UI(), 
                              Tab_SitesFlatView(),
                              Tab_SitesPhotoView(),
                              Tab_SitesSummary(),
                              Tab_LabDataIngestion_UI(),
                              Tab_About()
        )
                              
        }else{
          html <-  tabsetPanel( type = "tabs", id='MainTabsetPanel',
                                Tab_DataIngestion_UI(),
                                Tab_SiteViewer_UI(), 
                                Tab_SitesFlatView(),
                                Tab_SitesPhotoView(),
                                Tab_SitesSummary(),
                                Tab_PublishSitesToNatSoil(),
                                Tab_About()
          )
          }
      }else{
        html <- HTML(paste0('<h1>Oops.....</h1>
                     <p>To use this tool you need to supply some setup parameters in the URL you used to get here.</p>
                     <p>eg. ', url, '?config=Aconfig&agencycode=AnAgencyCode&projectcode=aProject</p>
                     <BR><BR>
                     <p> Please get in touch with ross.searle@csiro.au for assistance</p>
                     ')
                     
                     
                     )
      }
      
}



setupHeaderBasedOnConfigs <- function(reqParams, configName, font, imageHeader, imageLogo, title){
      
        if(reqParams){
          t <- paste0( '<span style="color:white; font-size: 75px; font-family:', font  ,'; 
                        height: 120px; min-width: 100%; background-size:100% 100%; display: inline-block;
                        background-image: url(./Configs/', configName, '/' , imageHeader, ')" > &nbsp;&nbsp; 
                        <img src="./Configs/',configName, '/' , imageLogo, '", height=100px > ', 
                        title , '</span>') 
          }else{
            t <- paste0( '<span style="color:white; font-size: 75px; font-family:', 'Arial' ,'; height: 120px; min-width: 100%; background-size:100% 100%; display: inline-block;
                       background-image: url(./Configs/CSIRO/HeaderSoil.png)" > &nbsp;&nbsp; <img src="./images/csiro.png", height=100px > ', 'CSIRO Soil Data Entry Tool' , '</span>') 
          }
        return(t)
}



getListOfAvailableSites <- function(con, keys){
  
  if(keys$ProjectCode=='NSMP'){
    
    if(is.null(keys$AdminKey)){
    sql <- paste0("SELECT nat.[s_id] FROM [NatSoil].[project].[PROPOSED_SITES] nat JOIN [NSMP_Holding].[dbo].[SITES] nsmp
            ON nat.[agency_code] = nsmp.[agency_code] AND nat.[proj_code] = nsmp.[proj_code] AND nat.[s_id] = nsmp.[s_id]
            where nat.agency_code='", keys$AgencyCode, "' and nat.proj_code='", keys$ProjectCode, "' and ps_token='", keys$Token, "'")
    }else{
      
      if(keys$AdminKey==OS$AppConfigs$ShowAdminKey){
          sql <- paste0("SELECT nat.[s_id] FROM [NatSoil].[project].[PROPOSED_SITES] nat JOIN [NSMP_Holding].[dbo].[SITES] nsmp
                ON nat.[agency_code] = nsmp.[agency_code] AND nat.[proj_code] = nsmp.[proj_code] AND nat.[s_id] = nsmp.[s_id]
                where nat.agency_code='", keys$AgencyCode, "' and nat.proj_code='", keys$ProjectCode, "'")
      }else{
          sql <- paste0("SELECT nat.[s_id] FROM [NatSoil].[project].[PROPOSED_SITES] nat JOIN [NSMP_Holding].[dbo].[SITES] nsmp
                ON nat.[agency_code] = nsmp.[agency_code] AND nat.[proj_code] = nsmp.[proj_code] AND nat.[s_id] = nsmp.[s_id]
                where nat.agency_code='", keys$AgencyCode, "' and nat.proj_code='", keys$ProjectCode, "' and ps_token='", keys$Token, "'")
      }
      
    }
    

  }else{
    sql <- paste0("select s_id from sites where agency_code='", keys$AgencyCode, "' and proj_code='", keys$ProjectCode, "'")
  }
  
  sites <- OS$DB$Helpers$doQuery(con, sql)
  sl <- sites$s_id
  return(sl)
}
    
  
# getListOfDraftSites <- function(keys){
#   
#   holdCon <- OS$DB$Config$getCon(OS$DB$Config$DBNames$NSMP_HoldingRW)$Connection
#   
#  sql <- paste0("SELECT nsmp.agency_code, nsmp.proj_code, nsmp.s_id, dbo.PublishedSites.s_id AS PublishedSite
#   FROM   dbo.SITES AS nsmp INNER JOIN
#   NatSoil.project.PROPOSED_SITES AS natProp ON nsmp.agency_code = natProp.agency_code AND nsmp.proj_code = natProp.proj_code AND nsmp.s_id = natProp.s_id LEFT OUTER JOIN
#   dbo.PublishedSites ON natProp.agency_code = dbo.PublishedSites.agency_code AND natProp.proj_code = dbo.PublishedSites.proj_code AND natProp.s_id = dbo.PublishedSites.s_id
#    WHERE nsmp.agency_code='", keys$AgencyCode, "' and nsmp.proj_code='", keys$ProjectCode, "' and ps_token='", keys$Token, "' and dbo.PublishedSites.s_id IS NULL")
# 
#  
#  sites <- OS$DB$Helpers$doQuery(holdCon, sql)
#  sl <- sites$s_id
#  print(sl)
#  return(sl)
#  
# }

getDraftOrPublishedSites <- function(type='Draft', keys=NULL){
  
  if(type=='Draft'){
    T=''
  }else(
    T=' NOT '
  )
 
  holdCon <- OS$DB$Config$getCon(OS$DB$Config$DBNames$NSMP_HoldingRW)$Connection
  
  
  sql <- paste0("SELECT natProp.ps_token, nsmp.agency_code, nsmp.proj_code, nsmp.s_id, dbo.OBSERVATIONS.o_id, dbo.PublishedSites.s_id AS PublishedSite, dbo.OBSERVATIONS.o_desc_by, dbo.OBSERVATIONS.o_date_desc, dbo.OBSERVATIONS.o_latitude_GDA94, 
             dbo.OBSERVATIONS.o_longitude_GDA94, nsmp.s_slope, nsmp.s_morph_type, nsmp.s_elem_type, nsmp.s_patt_type, nsmp.s_date_desc, natProp.lu_code, natProp.ps_soil_class, natProp.ps_soil_land_use, dbo.OBSERVATIONS.o_type, dbo.OBSERVATIONS.o_asc_ord, 
             dbo.OBSERVATIONS.o_asc_subord, dbo.OBSERVATIONS.o_asc_gg, dbo.OBSERVATIONS.o_asc_subg, nsmp.s_notes, dbo.OBSERVATIONS.o_notes
              FROM   dbo.SITES AS nsmp INNER JOIN
             NatSoil.project.PROPOSED_SITES AS natProp ON nsmp.agency_code = natProp.agency_code AND nsmp.proj_code = natProp.proj_code AND nsmp.s_id = natProp.s_id INNER JOIN
             dbo.OBSERVATIONS ON nsmp.agency_code = dbo.OBSERVATIONS.agency_code AND nsmp.proj_code = dbo.OBSERVATIONS.proj_code AND nsmp.s_id = dbo.OBSERVATIONS.s_id LEFT OUTER JOIN
             dbo.PublishedSites ON natProp.agency_code = dbo.PublishedSites.agency_code AND natProp.proj_code = dbo.PublishedSites.proj_code AND natProp.s_id = dbo.PublishedSites.s_id
              WHERE (natProp.ps_token = N'Burnie') AND (nsmp.agency_code = ", keys$AgencyCode, ") AND (nsmp.proj_code = '", keys$ProjectCode, "')  
                and ps_token='", keys$Token, "' AND (dbo.OBSERVATIONS.o_id = N'1') AND (dbo.PublishedSites.s_id IS ", T, " NULL)")

  sites <- OS$DB$Helpers$doQuery(holdCon, sql)

  
  dbDisconnect(holdCon)
  return(sites)
  
  }

  
  
  
  
  