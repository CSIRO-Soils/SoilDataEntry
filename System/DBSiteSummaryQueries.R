################################################################# #
#####       Author : Ross Searle                              ###
#####       Date :  Tues Feb 4 08:28:56 2025                  ###
#####       Purpose : Site Summary specific queries           ###
#####       Comments :                                        ###
################################################################# #


#codes <<- read.csv('./MetaTables/CODES.csv')

get_SiteSummaryQueries <- function()
{
  ss <- list()
  
  ss$getSitesInfo_NSMP <- function(con, agencyCode, projectCode, token){
    
    sql <- paste0("SELECT natProp.ps_token, nsmp.agency_code, nsmp.proj_code, nsmp.s_id, nsmp.s_slope, nsmp.s_morph_type, nsmp.s_elem_type, nsmp.s_patt_type, nsmp.s_notes, nsmp.s_date_desc, natProp.team_code, natProp.lu_code, natProp.sample_barcode_start, natProp.ps_soil_class, 
                    natProp.ps_soil_land_use, OBSERVATIONS.o_type, OBSERVATIONS.o_desc_by, OBSERVATIONS.o_latitude_GDA94, OBSERVATIONS.o_longitude_GDA94, OBSERVATIONS.o_asc_ord, OBSERVATIONS.o_asc_subord, OBSERVATIONS.o_asc_gg, 
                    OBSERVATIONS.o_asc_subg, OBSERVATIONS.o_notes, OBSERVATIONS.o_date_desc
                    FROM   SITES AS nsmp INNER JOIN
                    NatSoil.project.PROPOSED_SITES AS natProp ON nsmp.agency_code = natProp.agency_code AND nsmp.proj_code = natProp.proj_code AND nsmp.s_id = natProp.s_id INNER JOIN
                    OBSERVATIONS ON nsmp.agency_code = OBSERVATIONS.agency_code AND nsmp.proj_code = OBSERVATIONS.proj_code AND nsmp.s_id = OBSERVATIONS.s_id
                    WHERE ( OBSERVATIONS.agency_code = '", agencyCode,"') AND ( OBSERVATIONS.proj_code = '",projectCode,"') and natProp.ps_token = '", token, "'") 
                        
    sites <- OS$DB$Helpers$doQuery(con, sql)
    return(sites)
  }
  
  ss$getHorizonInfo_NSMP <- function(con, agencyCode, projectCode, token){  
    
    sql <-paste0("SELECT nsmp.agency_code, nsmp.proj_code, nsmp.s_id, dbo.OBSERVATIONS.o_date_desc, dbo.OBSERVATIONS.o_desc_by, dbo.OBSERVATIONS.o_latitude_GDA94, dbo.OBSERVATIONS.o_longitude_GDA94, dbo.OBSERVATIONS.o_type, nsmp.s_slope, nsmp.s_morph_type, 
             nsmp.s_elem_type, nsmp.s_patt_type, natProp.lu_code, natProp.ps_soil_land_use, natProp.ps_soil_class, dbo.OBSERVATIONS.o_asc_ord, dbo.OBSERVATIONS.o_asc_subord, dbo.OBSERVATIONS.o_asc_gg, dbo.OBSERVATIONS.o_asc_subg, natProp.team_code, 
             natProp.sample_barcode_start, dbo.OBSERVATIONS.o_notes, nsmp.s_notes, dbo.HORIZONS.h_no, dbo.HORIZONS.h_upper_depth, dbo.HORIZONS.h_lower_depth, dbo.HORIZONS.h_desig_master, dbo.HORIZONS.h_texture, dbo.HORIZONS.h_texture_qual, 
             dbo.COLOURS.col_hue_val_chrom, dbo.HORIZONS.h_bound_distinct, dbo.HORIZONS.h_bound_shape, dbo.CRACKS.crack_width, dbo.COARSE_FRAGS.cf_abun, dbo.COARSE_FRAGS.cf_size, dbo.COARSE_FRAGS.cf_shape, dbo.COARSE_FRAGS.cf_lith, dbo.MOTTLES.mott_abun, 
             dbo.MOTTLES.mott_type, dbo.MOTTLES.mott_size, dbo.MOTTLES.mott_contrast, dbo.SEGREGATIONS.seg_abun, dbo.SEGREGATIONS.seg_nature, dbo.SEGREGATIONS.seg_form, dbo.SEGREGATIONS.seg_size, dbo.CUTANS.cutan_type, dbo.CUTANS.cutan_abun, 
             dbo.CUTANS.cutan_distinct, dbo.PANS.pan_cementation, dbo.PANS.pan_type, dbo.PANS.pan_continuity, dbo.PANS.pan_structure, dbo.ROOTS.root_abun, dbo.ROOTS.root_size, dbo.STRENGTHS.strg_class, dbo.HORIZONS.h_ec, dbo.HORIZONS.h_salinity_depth, 
             dbo.HORIZONS.h_dispersion
FROM   dbo.SITES AS nsmp INNER JOIN
             NatSoil.project.PROPOSED_SITES AS natProp ON nsmp.agency_code = natProp.agency_code AND nsmp.proj_code = natProp.proj_code AND nsmp.s_id = natProp.s_id INNER JOIN
             dbo.OBSERVATIONS ON nsmp.agency_code = dbo.OBSERVATIONS.agency_code AND nsmp.proj_code = dbo.OBSERVATIONS.proj_code AND nsmp.s_id = dbo.OBSERVATIONS.s_id INNER JOIN
             dbo.HORIZONS ON dbo.OBSERVATIONS.agency_code = dbo.HORIZONS.agency_code AND dbo.OBSERVATIONS.proj_code = dbo.HORIZONS.proj_code AND dbo.OBSERVATIONS.s_id = dbo.HORIZONS.s_id AND dbo.OBSERVATIONS.o_id = dbo.HORIZONS.o_id LEFT OUTER JOIN
             dbo.STRUCTURES ON dbo.HORIZONS.agency_code = dbo.STRUCTURES.agency_code AND dbo.HORIZONS.proj_code = dbo.STRUCTURES.proj_code AND dbo.HORIZONS.s_id = dbo.STRUCTURES.s_id AND dbo.HORIZONS.o_id = dbo.STRUCTURES.o_id AND 
             dbo.HORIZONS.h_no = dbo.STRUCTURES.h_no LEFT OUTER JOIN
             dbo.CRACKS ON dbo.HORIZONS.agency_code = dbo.CRACKS.agency_code AND dbo.HORIZONS.proj_code = dbo.CRACKS.proj_code AND dbo.HORIZONS.s_id = dbo.CRACKS.s_id AND dbo.HORIZONS.o_id = dbo.CRACKS.o_id AND 
             dbo.HORIZONS.h_no = dbo.CRACKS.h_no LEFT OUTER JOIN
             dbo.COARSE_FRAGS ON dbo.HORIZONS.agency_code = dbo.COARSE_FRAGS.agency_code AND dbo.HORIZONS.proj_code = dbo.COARSE_FRAGS.proj_code AND dbo.HORIZONS.s_id = dbo.COARSE_FRAGS.s_id AND dbo.HORIZONS.o_id = dbo.COARSE_FRAGS.o_id AND 
             dbo.HORIZONS.h_no = dbo.COARSE_FRAGS.h_no LEFT OUTER JOIN
             dbo.PANS ON dbo.HORIZONS.agency_code = dbo.PANS.agency_code AND dbo.HORIZONS.proj_code = dbo.PANS.proj_code AND dbo.HORIZONS.s_id = dbo.PANS.s_id AND dbo.HORIZONS.o_id = dbo.PANS.o_id AND dbo.HORIZONS.h_no = dbo.PANS.h_no LEFT OUTER JOIN
             dbo.STRENGTHS ON dbo.HORIZONS.agency_code = dbo.STRENGTHS.agency_code AND dbo.HORIZONS.proj_code = dbo.STRENGTHS.proj_code AND dbo.HORIZONS.s_id = dbo.STRENGTHS.s_id AND dbo.HORIZONS.o_id = dbo.STRENGTHS.o_id AND 
             dbo.HORIZONS.h_no = dbo.STRENGTHS.h_no LEFT OUTER JOIN
             dbo.COLOURS ON dbo.HORIZONS.agency_code = dbo.COLOURS.agency_code AND dbo.HORIZONS.proj_code = dbo.COLOURS.proj_code AND dbo.HORIZONS.s_id = dbo.COLOURS.s_id AND dbo.HORIZONS.o_id = dbo.COLOURS.o_id AND 
             dbo.HORIZONS.h_no = dbo.COLOURS.h_no LEFT OUTER JOIN
             dbo.ROOTS ON dbo.HORIZONS.agency_code = dbo.ROOTS.agency_code AND dbo.HORIZONS.proj_code = dbo.ROOTS.proj_code AND dbo.HORIZONS.s_id = dbo.ROOTS.s_id AND dbo.HORIZONS.o_id = dbo.ROOTS.o_id AND dbo.HORIZONS.h_no = dbo.ROOTS.h_no LEFT OUTER JOIN
             dbo.MOTTLES ON dbo.HORIZONS.agency_code = dbo.MOTTLES.agency_code AND dbo.HORIZONS.proj_code = dbo.MOTTLES.proj_code AND dbo.HORIZONS.s_id = dbo.MOTTLES.s_id AND dbo.HORIZONS.o_id = dbo.MOTTLES.o_id AND 
             dbo.HORIZONS.h_no = dbo.MOTTLES.h_no LEFT OUTER JOIN
             dbo.CUTANS ON dbo.HORIZONS.agency_code = dbo.CUTANS.agency_code AND dbo.HORIZONS.proj_code = dbo.CUTANS.proj_code AND dbo.HORIZONS.s_id = dbo.CUTANS.s_id AND dbo.HORIZONS.o_id = dbo.CUTANS.o_id AND 
             dbo.HORIZONS.h_no = dbo.CUTANS.h_no LEFT OUTER JOIN
             dbo.SEGREGATIONS ON dbo.HORIZONS.agency_code = dbo.SEGREGATIONS.agency_code AND dbo.HORIZONS.proj_code = dbo.SEGREGATIONS.proj_code AND dbo.HORIZONS.s_id = dbo.SEGREGATIONS.s_id AND dbo.HORIZONS.o_id = dbo.SEGREGATIONS.o_id AND 
             dbo.HORIZONS.h_no = dbo.SEGREGATIONS.h_no
                WHERE ( OBSERVATIONS.agency_code = '", agencyCode,"') AND ( OBSERVATIONS.proj_code = '",projectCode,"') and natProp.ps_token = '", token, "'") 
    
    hors <- OS$DB$Helpers$doQuery(con, sql)
    return(hors)
  }
  
  
  ss$GetSitesInfo <- function(con, agencyCode, projectCode){
    sql <- paste0("SELECT nsmp.agency_code, nsmp.proj_code, nsmp.s_id, nsmp.s_slope, nsmp.s_morph_type, nsmp.s_elem_type, nsmp.s_patt_type, nsmp.s_notes, nsmp.s_date_desc, OBSERVATIONS.o_type, OBSERVATIONS.o_desc_by, OBSERVATIONS.o_latitude_GDA94, 
                  OBSERVATIONS.o_longitude_GDA94, OBSERVATIONS.o_asc_ord, OBSERVATIONS.o_asc_subord, OBSERVATIONS.o_asc_gg, OBSERVATIONS.o_asc_subg, OBSERVATIONS.o_notes, OBSERVATIONS.o_date_desc
                  FROM   SITES AS nsmp INNER JOIN
                  OBSERVATIONS ON nsmp.agency_code = OBSERVATIONS.agency_code AND nsmp.proj_code = OBSERVATIONS.proj_code AND nsmp.s_id = OBSERVATIONS.s_id 
                  WHERE ( OBSERVATIONS.agency_code = '",agencyCode,"') AND ( OBSERVATIONS.proj_code = '",projectCode,"')")
    
    sites <- OS$DB$Helpers$doQuery(con, sql)
    return(sites)
    
  }
  
 
  
  ss$getNSMPPotentialSites <- function(con, keys){
    
    sql <- paste0("SELECT s_id FROM [NatSoil].[project].[PROPOSED_SITES] where ps_token = '", keys$Token, "'")
    sites <- OS$DB$Helpers$doQuery(con, sql)
    return(sites)
  }
  
  return(ss)
}


