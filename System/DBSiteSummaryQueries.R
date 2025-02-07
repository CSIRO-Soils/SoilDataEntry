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
  
  ss$getSitesInfo_NSMP <- function(con, keys){
    
    sql <- paste0("SELECT natProp.ps_token, nsmp.agency_code, nsmp.proj_code, nsmp.s_id, nsmp.s_slope, nsmp.s_morph_type, nsmp.s_elem_type, nsmp.s_patt_type, nsmp.s_notes, nsmp.s_date_desc, natProp.team_code, natProp.lu_code, natProp.sample_barcode_start, natProp.ps_soil_class, 
                    natProp.ps_soil_land_use, OBSERVATIONS.o_type, OBSERVATIONS.o_desc_by, OBSERVATIONS.o_latitude_GDA94, OBSERVATIONS.o_longitude_GDA94, OBSERVATIONS.o_asc_ord, OBSERVATIONS.o_asc_subord, OBSERVATIONS.o_asc_gg, 
                    OBSERVATIONS.o_asc_subg, OBSERVATIONS.o_notes, OBSERVATIONS.o_date_desc
                    FROM   SITES AS nsmp INNER JOIN
                    NatSoil.project.PROPOSED_SITES AS natProp ON nsmp.agency_code = natProp.agency_code AND nsmp.proj_code = natProp.proj_code AND nsmp.s_id = natProp.s_id INNER JOIN
                    OBSERVATIONS ON nsmp.agency_code = OBSERVATIONS.agency_code AND nsmp.proj_code = OBSERVATIONS.proj_code AND nsmp.s_id = OBSERVATIONS.s_id
                    WHERE ( OBSERVATIONS.agency_code = '", keys$AgencyCode,"') AND ( OBSERVATIONS.proj_code = '",keys$ProjectCode,"')") 
                        
    if(is.null(keys$AdminKey)){
      t <- paste0(" and natProp.ps_token = '", keys$Token, "'")
    }else if (keys$AdminKey!=OS$AppConfigs$ShowAdminKey){
      t <- paste0(" and natProp.ps_token = '", keys$Token, "'")
    }else{
      t <- ''
    }
    sql <- paste0(sql, t)
    
    sites <- OS$DB$Helpers$doQuery(con, sql)

    return(sites)
  }
  
  ss$getHorizonInfo_NSMP <- function(con, keys){  
    
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
                WHERE ( OBSERVATIONS.agency_code = '", keys$AgencyCode,"') AND ( OBSERVATIONS.proj_code = '", keys$ProjectCode,"')") 
    
      if(is.null(keys$AdminKey)){
        t <- paste0(" and natProp.ps_token = '", keys$Token, "'")
      }else if (keys$AdminKey!=OS$AppConfigs$ShowAdminKey){
        t <- paste0(" and natProp.ps_token = '", keys$Token, "'")
      }else{
        t <- ''
      }
      sql <- paste0(sql, t)
    
    hors <- OS$DB$Helpers$doQuery(con, sql)
    return(hors)
  }
  
  ss$getSiteEnvelopes_NSMP <- function(con, keys, sites){  
    
    sql <- paste0("SELECT [agency_code],[proj_code],[s_id],[s_geom_GDA94].STAsText() as geom FROM [NatSoil].[dbo].[SITES] 
                  where  agency_code = '", keys$AgencyCode, "' and proj_code = '", keys$ProjectCode, "'")
    envelopes <- OS$DB$Helpers$doQuery(con, sql)
    idxs <- which(envelopes$s_id %in% sites)
    e <- envelopes[idxs,]
    
    
    return(e)
  }
  
  
  ss$GetSitesInfo <- function(con, keys){
    sql <- paste0("SELECT nsmp.agency_code, nsmp.proj_code, nsmp.s_id, nsmp.s_slope, nsmp.s_morph_type, nsmp.s_elem_type, nsmp.s_patt_type, nsmp.s_notes, nsmp.s_date_desc, OBSERVATIONS.o_type, OBSERVATIONS.o_desc_by, OBSERVATIONS.o_latitude_GDA94, 
                  OBSERVATIONS.o_longitude_GDA94, OBSERVATIONS.o_asc_ord, OBSERVATIONS.o_asc_subord, OBSERVATIONS.o_asc_gg, OBSERVATIONS.o_asc_subg, OBSERVATIONS.o_notes, OBSERVATIONS.o_date_desc
                  FROM   SITES AS nsmp INNER JOIN
                  OBSERVATIONS ON nsmp.agency_code = OBSERVATIONS.agency_code AND nsmp.proj_code = OBSERVATIONS.proj_code AND nsmp.s_id = OBSERVATIONS.s_id 
                  WHERE ( OBSERVATIONS.agency_code = '",keys$AgencyCode,"') AND ( OBSERVATIONS.proj_code = '",keys$ProjectCode,"')")
    
    sites <- OS$DB$Helpers$doQuery(con, sql)
    return(sites)
    
  }
  
  ss$getHorizonInfo <- function(con, keys){  
    
    sql <- paste0("SELECT SITES.agency_code, SITES.proj_code, SITES.s_id, OBSERVATIONS.o_date_desc, OBSERVATIONS.o_desc_by, OBSERVATIONS.o_latitude_GDA94, OBSERVATIONS.o_longitude_GDA94, OBSERVATIONS.o_type, SITES.s_slope, 
             SITES.s_morph_type, SITES.s_elem_type, SITES.s_patt_type, OBSERVATIONS.o_asc_ord, OBSERVATIONS.o_asc_subord, OBSERVATIONS.o_asc_gg, OBSERVATIONS.o_asc_subg, OBSERVATIONS.o_notes, SITES.s_notes, 
             HORIZONS.h_no, HORIZONS.h_upper_depth, HORIZONS.h_lower_depth, HORIZONS.h_desig_master, HORIZONS.h_texture, HORIZONS.h_texture_qual, COLOURS.col_hue_val_chrom, HORIZONS.h_bound_distinct, HORIZONS.h_bound_shape, 
             CRACKS.crack_width, COARSE_FRAGS.cf_abun, COARSE_FRAGS.cf_size, COARSE_FRAGS.cf_shape, COARSE_FRAGS.cf_lith, MOTTLES.mott_abun, MOTTLES.mott_type, MOTTLES.mott_size, MOTTLES.mott_contrast, 
             SEGREGATIONS.seg_abun, SEGREGATIONS.seg_nature, SEGREGATIONS.seg_form, SEGREGATIONS.seg_size, CUTANS.cutan_type, CUTANS.cutan_abun, CUTANS.cutan_distinct, PANS.pan_cementation, PANS.pan_type, 
             PANS.pan_continuity, PANS.pan_structure, ROOTS.root_abun, ROOTS.root_size, STRENGTHS.strg_class, HORIZONS.h_ec, HORIZONS.h_salinity_depth, HORIZONS.h_dispersion
FROM   SITES INNER JOIN
             OBSERVATIONS ON SITES.agency_code = OBSERVATIONS.agency_code AND SITES.proj_code = OBSERVATIONS.proj_code AND SITES.s_id = OBSERVATIONS.s_id INNER JOIN
             HORIZONS ON OBSERVATIONS.agency_code = HORIZONS.agency_code AND OBSERVATIONS.proj_code = HORIZONS.proj_code AND OBSERVATIONS.s_id = HORIZONS.s_id AND OBSERVATIONS.o_id = HORIZONS.o_id LEFT OUTER JOIN
             STRUCTURES ON HORIZONS.agency_code = STRUCTURES.agency_code AND HORIZONS.proj_code = STRUCTURES.proj_code AND HORIZONS.s_id = STRUCTURES.s_id AND HORIZONS.o_id = STRUCTURES.o_id AND 
             HORIZONS.h_no = STRUCTURES.h_no LEFT OUTER JOIN
             CRACKS ON HORIZONS.agency_code = CRACKS.agency_code AND HORIZONS.proj_code = CRACKS.proj_code AND HORIZONS.s_id = CRACKS.s_id AND HORIZONS.o_id = CRACKS.o_id AND 
             HORIZONS.h_no = CRACKS.h_no LEFT OUTER JOIN
             COARSE_FRAGS ON HORIZONS.agency_code = COARSE_FRAGS.agency_code AND HORIZONS.proj_code = COARSE_FRAGS.proj_code AND HORIZONS.s_id = COARSE_FRAGS.s_id AND HORIZONS.o_id = COARSE_FRAGS.o_id AND 
             HORIZONS.h_no = COARSE_FRAGS.h_no LEFT OUTER JOIN
             PANS ON HORIZONS.agency_code = PANS.agency_code AND HORIZONS.proj_code = PANS.proj_code AND HORIZONS.s_id = PANS.s_id AND HORIZONS.o_id = PANS.o_id AND HORIZONS.h_no = PANS.h_no LEFT OUTER JOIN
             STRENGTHS ON HORIZONS.agency_code = STRENGTHS.agency_code AND HORIZONS.proj_code = STRENGTHS.proj_code AND HORIZONS.s_id = STRENGTHS.s_id AND HORIZONS.o_id = STRENGTHS.o_id AND 
             HORIZONS.h_no = STRENGTHS.h_no LEFT OUTER JOIN
             COLOURS ON HORIZONS.agency_code = COLOURS.agency_code AND HORIZONS.proj_code = COLOURS.proj_code AND HORIZONS.s_id = COLOURS.s_id AND HORIZONS.o_id = COLOURS.o_id AND 
             HORIZONS.h_no = COLOURS.h_no LEFT OUTER JOIN
             ROOTS ON HORIZONS.agency_code = ROOTS.agency_code AND HORIZONS.proj_code = ROOTS.proj_code AND HORIZONS.s_id = ROOTS.s_id AND HORIZONS.o_id = ROOTS.o_id AND HORIZONS.h_no = ROOTS.h_no LEFT OUTER JOIN
             MOTTLES ON HORIZONS.agency_code = MOTTLES.agency_code AND HORIZONS.proj_code = MOTTLES.proj_code AND HORIZONS.s_id = MOTTLES.s_id AND HORIZONS.o_id = MOTTLES.o_id AND 
             HORIZONS.h_no = MOTTLES.h_no LEFT OUTER JOIN
             CUTANS ON HORIZONS.agency_code = CUTANS.agency_code AND HORIZONS.proj_code = CUTANS.proj_code AND HORIZONS.s_id = CUTANS.s_id AND HORIZONS.o_id = CUTANS.o_id AND 
             HORIZONS.h_no = CUTANS.h_no LEFT OUTER JOIN
             SEGREGATIONS ON HORIZONS.agency_code = SEGREGATIONS.agency_code AND HORIZONS.proj_code = SEGREGATIONS.proj_code AND HORIZONS.s_id = SEGREGATIONS.s_id AND HORIZONS.o_id = SEGREGATIONS.o_id AND 
             HORIZONS.h_no = SEGREGATIONS.h_no")
    
    hors <- OS$DB$Helpers$doQuery(con, sql)
    return(hors)
  }
  
 
  
  ss$getNSMPPotentialSites <- function(con, keys){
    
    sql <- paste0("SELECT s_id FROM [NatSoil].[project].[PROPOSED_SITES] where ps_token = '", keys$Token, "'")
    sites <- OS$DB$Helpers$doQuery(con, sql)
    return(sites)
  }
  
  return(ss)
}


