################################################################# #
#####       Author : Ross Searle                              ###
#####       Date :  Tue Feb 11 10:48:54 2025                  ###
#####       Purpose : Queries to support the Sites Publishing ###
#####       Comments :                                        ###
################################################################# #


get_SitePublishingQueries <- function()
{
  sp <- list()
  
  # sp$getHoldingSites <- function(con, keys){
  #   
  #   sql <- paste0("SELECT natProp.ps_token, nsmp.agency_code, nsmp.proj_code, nsmp.s_id, nsmp.s_slope, nsmp.s_morph_type, nsmp.s_elem_type, nsmp.s_patt_type, nsmp.s_notes, nsmp.s_date_desc, natProp.team_code, natProp.lu_code, natProp.sample_barcode_start, natProp.ps_soil_class, 
  #                   natProp.ps_soil_land_use, OBSERVATIONS.o_type, OBSERVATIONS.o_desc_by, OBSERVATIONS.o_latitude_GDA94, OBSERVATIONS.o_longitude_GDA94, OBSERVATIONS.o_asc_ord, OBSERVATIONS.o_asc_subord, OBSERVATIONS.o_asc_gg, 
  #                   OBSERVATIONS.o_asc_subg, OBSERVATIONS.o_notes, OBSERVATIONS.o_date_desc
  #                   FROM   SITES AS nsmp INNER JOIN
  #                   NatSoil.project.PROPOSED_SITES AS natProp ON nsmp.agency_code = natProp.agency_code AND nsmp.proj_code = natProp.proj_code AND nsmp.s_id = natProp.s_id INNER JOIN
  #                   OBSERVATIONS ON nsmp.agency_code = OBSERVATIONS.agency_code AND nsmp.proj_code = OBSERVATIONS.proj_code AND nsmp.s_id = OBSERVATIONS.s_id
  #                   WHERE ( OBSERVATIONS.agency_code = '", keys$AgencyCode,"') AND ( OBSERVATIONS.proj_code = '",keys$ProjectCode,"')") 
  #   
  #   if(is.null(keys$AdminKey)){
  #     t <- paste0(" and natProp.ps_token = '", keys$Token, "'")
  #   }else if (keys$AdminKey!=OS$AppConfigs$ShowAdminKey){
  #     t <- paste0(" and natProp.ps_token = '", keys$Token, "'")
  #   }else{
  #     t <- ''
  #   }
  #   sql <- paste0(sql, t)
  #   
  #   sites <- OS$DB$Helpers$doQuery(con, sql)
  #   
  #   return(sites)
  # }
  
  
  
#   sp$getPublishedSites <- function(con, keys){
#     
#   sql <- paste0("SELECT project.PROPOSED_SITES.ps_token, dbo.SITES.agency_code, dbo.SITES.proj_code,  dbo.SITES.s_id, dbo.OBSERVATIONS.o_id, dbo.SITES.s_desc_by, dbo.SITES.s_slope, dbo.SITES.s_morph_type, dbo.SITES.s_elem_type, dbo.SITES.s_patt_type, 
#     dbo.OBSERVATIONS.o_latitude_GDA94, dbo.OBSERVATIONS.o_longitude_GDA94, dbo.OBSERVATIONS.o_asc_ord, dbo.OBSERVATIONS.o_asc_subord, dbo.OBSERVATIONS.o_asc_gg, dbo.OBSERVATIONS.o_asc_subg, dbo.SITES.s_notes, dbo.OBSERVATIONS.o_notes
#     FROM   dbo.SITES INNER JOIN
#     dbo.OBSERVATIONS ON dbo.SITES.agency_code = dbo.OBSERVATIONS.agency_code AND dbo.SITES.proj_code = dbo.OBSERVATIONS.proj_code AND dbo.SITES.s_id = dbo.OBSERVATIONS.s_id INNER JOIN
#     project.PROPOSED_SITES ON dbo.SITES.agency_code = project.PROPOSED_SITES.agency_code AND dbo.SITES.proj_code = project.PROPOSED_SITES.proj_code AND dbo.SITES.s_id = project.PROPOSED_SITES.s_id
#     WHERE (dbo.SITES.agency_code = '", keys$AgencyCode,"') AND (dbo.SITES.proj_code = '",keys$ProjectCode,"') AND (dbo.OBSERVATIONS.o_id = N'1') AND (project.PROPOSED_SITES.ps_token = '", keys$Token ,"')")
#   
#   sites <- OS$DB$Helpers$doQuery(con, sql)
#   return(sites)
#     
#   }

  
  
  
  
  sp$getToDoSites <- function(con, keys){

    sql <- paste0("SELECT nat.s_id, nsmp.s_id AS HoldingSites, nat.proj_code, nat.agency_code, nat.team_code, nat.ps_latitude_GDA94, nat.ps_longitude_GDA94, nat.ps_description, nat.lu_code, nat.ps_token, nat.ps_soil_class, nat.ps_soil_land_use, nat.ps_soil_color
          FROM   NatSoil.project.PROPOSED_SITES AS nat LEFT OUTER JOIN
          dbo.SITES AS nsmp ON nat.agency_code = nsmp.agency_code AND nat.proj_code = nsmp.proj_code AND nat.s_id = nsmp.s_id
          WHERE (nat.agency_code = '", keys$AgencyCode, "') AND (nat.proj_code = '", keys$ProjectCode, "') AND (nat.ps_token = '", keys$Token, "') AND (nsmp.s_id IS NULL)")

    sites <- OS$DB$Helpers$doQuery(con, sql)
    return(sites)
  }






  sp$getDraftOrPublishedSites <- function(type='Draft', keys=NULL){
  
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

  return(sp)

}
