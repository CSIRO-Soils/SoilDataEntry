
/****** Object:  Table [dbo].[STATES]    Script Date: 6/04/2023 9:11:01 AM ******/

CREATE TABLE [STATES](
	[STATE_CODE] [NVARCHAR](1) NOT NULL,
	[STATE_NAME] [NVARCHAR](3) NOT NULL,
	[STATE_NAME_LONG] [NVARCHAR](30) NULL,
             [state_boundary_gda94]  [NVARCHAR] NULL,
 CONSTRAINT [PK_STATES] PRIMARY KEY ([STATE_CODE] ASC)
 );
 
/****** Object:  Table [dbo].[AGENCIES]    Script Date: 6/04/2023 8:58:40 AM ******/

CREATE TABLE [AGENCIES](
	[STATE_CODE] [nvarchar](1) NOT NULL,
	[AGENCY_CODE] [nvarchar](3) NOT NULL,
	[AGENCY_NAME] [nvarchar](255) NOT NULL,
	[AGENCY_ACRONYM] [nvarchar](10) NULL,
 CONSTRAINT [PK_AGENCIES] PRIMARY KEY 
(
	[AGENCY_CODE] ASC
)
    FOREIGN KEY([STATE_CODE]) REFERENCES [STATES] ([STATE_CODE])
);
 

/****** Object:  Table [dbo].[OFFICERS]    Script Date: 6/04/2023 9:00:33 AM ******/

CREATE TABLE [OFFICERS](
	[agency_code] [nvarchar](3) NOT NULL,
	[offr_code] [nvarchar](4) NOT NULL,
	[offr_name] [nvarchar](40) NOT NULL,
             [offr_company]  [nvarchar](255) NULL,
 CONSTRAINT [PK_OFFICERS] PRIMARY KEY  
(
	[agency_code] ASC,
	[offr_code] ASC
)

CONSTRAINT [FK_OFFICERS_AGENCIES] FOREIGN KEY([agency_code]) REFERENCES [AGENCIES] ([AGENCY_CODE])

);


/****** Object:  Table [dbo].[PROJECTS]    Script Date: 6/04/2023 8:59:26 AM ******/
CREATE TABLE [PROJECTS](
	[agency_code] [nvarchar](3) NOT NULL,
	[proj_code] [nvarchar](10) NOT NULL,
	[proj_name] [nvarchar](255) NOT NULL,
	[proj_manager_code] [nvarchar](4) NULL,
	[proj_biblio_ref] [nvarchar](510) NULL,
             [proj_collection_method_id] [int]  NULL,
	[proj_start_date] [nvarchar](8) NULL,
	[proj_finish_date] [nvarchar](8) NULL,
             [proj_o2d] nvarchar(510) NULL,
             [proj_last_modified] [nvarchar](8) NULL,
             
 CONSTRAINT [PK_PROJECTS] PRIMARY KEY 
(
	[agency_code] ASC,
	[proj_code] ASC
)

CONSTRAINT [FK_PROJECTS_AGENCIES] FOREIGN KEY([agency_code]) REFERENCES [AGENCIES] ([AGENCY_CODE])

);



/****** Object:  Table [dbo].[SITES]    Script Date: 6/04/2023 8:59:26 AM ******/

CREATE TABLE [SITES](
	[agency_code] [nvarchar](3) NOT NULL,
	[proj_code] [nvarchar](10) NOT NULL,
	[s_id] [nvarchar](10) NOT NULL,
	[s_orig_tech_ref] [nvarchar](1) NULL,
	[s_map_scale] [nvarchar](2) NULL,
	[s_map_sheet_no] [nvarchar](10) NULL,
	[s_map_ref_type] [nvarchar](1) NULL,
	[s_photo_film_no] [nvarchar](11) NULL,
	[s_photo_run_no] [nvarchar](3) NULL,
	[s_photo_frame_no] [smallint] NULL,
	[s_desc_by] [nvarchar](4) NULL,
	[s_date_desc] [nvarchar](8) NULL,
	[s_rainfall] [smallint] NULL,
	[s_type] [nvarchar](1) NULL,
	[s_slope_pf] [nvarchar](1) NULL,
	[s_slope] [real] NULL,
	[s_slope_eval] [nvarchar](1) NULL,
	[s_slope_class] [nvarchar](2) NULL,
	[s_morph_type] [nvarchar](1) NULL,
	[s_elem_inc_slope] [nvarchar](1) NULL,
	[s_elem_length] [real] NULL,
	[s_elem_width] [real] NULL,
	[s_elem_height] [nvarchar](3) NULL,
	[s_elem_location] [nvarchar](1) NULL,
	[s_elem_type] [nvarchar](3) NULL,
	[s_relief] [smallint] NULL,
	[s_modal_slope] [nvarchar](2) NULL,
	[s_relief_class] [nvarchar](1) NULL,
	[s_rel_ms_class] [nvarchar](2) NULL,
	[s_strm_ch_spacing] [nvarchar](2) NULL,
	[s_strm_ch_dev] [nvarchar](1) NULL,
	[s_strm_ch_dtow] [nvarchar](1) NULL,
	[s_strm_ch_mig] [nvarchar](1) NULL,
	[s_strm_ch_patt] [nvarchar](1) NULL,
	[s_strm_ch_net_int] [nvarchar](1) NULL,
	[s_strm_ch_dir_net] [nvarchar](1) NULL,
	[s_patt_type] [nvarchar](3) NULL,
	[s_notes] [nvarchar](255) NULL,
	[s_trans_author] [nvarchar](4) NULL,
	[s_trans_date] [nvarchar](8) NULL,
	[ref_agency_code] [nvarchar](3) NULL,
	[ref_project_code] [nvarchar](10) NULL,
	[ref_s_id] [nvarchar](10) NULL,
 CONSTRAINT [PK_SITES] PRIMARY KEY 
(
	[agency_code] ASC,
	[proj_code] ASC,
	[s_id] ASC
)

CONSTRAINT [FK_SITES_PROJECTS] FOREIGN KEY([agency_code], [proj_code]) REFERENCES [PROJECTS] ([agency_code], [proj_code])
);






/****** Object:  Table [dbo].[OBSERVATIONS]    Script Date: 6/04/2023 8:59:49 AM ******/

CREATE TABLE [OBSERVATIONS](
	[agency_code] [nvarchar](3) NOT NULL,
	[proj_code] [nvarchar](10) NOT NULL,
	[s_id] [nvarchar](10) NOT NULL,
	[o_id] [nvarchar](2) NOT NULL,
	[o_type] [nvarchar](1) NULL,
	[o_nature] [nvarchar](1) NULL,
	[o_desc_by] [nvarchar](4) NULL,
	[o_date_desc] [nvarchar](8) NULL,
	[o_amg_zone] [smallint] NULL,
	[o_easting] [int] NULL,
	[o_northing] [int] NULL,
	[o_latitude] [float] NULL,
	[o_longitude] [float] NULL,
	[o_datum] [nvarchar](50) NULL,
	[o_latitude_GDA94] [float] NULL,
	[o_longitude_GDA94] [float] NULL,
	[o_location_state] [nvarchar](3) NULL,
	[o_location_notes] [nvarchar](255) NULL,
	[o_photo_east] [smallint] NULL,
	[o_photo_north] [smallint] NULL,
	[o_land_use] [nvarchar](5) NULL,
	[o_forest_type] [nvarchar](1) NULL,
	[o_rf_complex] [nvarchar](1) NULL,
	[o_rf_leafsize] [nvarchar](1) NULL,
	[o_rf_flor_comp] [nvarchar](1) NULL,
	[o_rf_indicator] [nvarchar](1) NULL,
	[o_rf_emergents] [nvarchar](1) NULL,
	[o_sclerophyll] [nvarchar](1) NULL,
	[o_veg_notes] [nvarchar](255) NULL,
	[o_aspect] [smallint] NULL,
	[o_elevation_eval] [nvarchar](1) NULL,
	[o_elevation_pf] [nvarchar](1) NULL,
	[o_elevation] [smallint] NULL,
	[o_drainage_eval] [nvarchar](1) NULL,
	[o_drainage_height] [real] NULL,
	[o_drainage] [nvarchar](1) NULL,
	[o_mr_sampled] [nvarchar](1) NULL,
	[o_soil_disturb] [nvarchar](1) NULL,
	[o_grnd_cov_level_min] [smallint] NULL,
	[o_grnd_cov_level_max] [smallint] NULL,
	[o_grnd_cov_height_min] [smallint] NULL,
	[o_grnd_cov_height_max] [smallint] NULL,
	[o_wind_state] [nvarchar](1) NULL,
	[o_wind_deg] [nvarchar](1) NULL,
	[o_wind_stabilty] [nvarchar](1) NULL,
	[o_wind_visibility] [nvarchar](1) NULL,
	[o_scald_state] [nvarchar](1) NULL,
	[o_scald_deg] [nvarchar](1) NULL,
	[o_sheet_state] [nvarchar](1) NULL,
	[o_sheet_deg] [nvarchar](1) NULL,
	[o_wave_state] [nvarchar](1) NULL,
	[o_wave_deg] [nvarchar](1) NULL,
	[o_rill_state] [nvarchar](1) NULL,
	[o_rill_deg] [nvarchar](1) NULL,
	[o_mass_state] [nvarchar](1) NULL,
	[o_mass_deg] [nvarchar](1) NULL,
	[o_gully_state] [nvarchar](1) NULL,
	[o_gully_deg] [nvarchar](1) NULL,
	[o_stbank_state] [nvarchar](1) NULL,
	[o_stbank_deg] [nvarchar](1) NULL,
	[o_tunnel_state] [nvarchar](1) NULL,
	[o_tunnel_deg] [nvarchar](1) NULL,
	[o_other_er_state] [nvarchar](1) NULL,
	[o_other_er_deg] [nvarchar](1) NULL,
	[o_other_er_type] [nvarchar](30) NULL,
	[o_gully_depth] [nvarchar](1) NULL,
	[o_aggradation] [nvarchar](1) NULL,
	[o_inund_freq] [nvarchar](1) NULL,
	[o_inund_dur] [nvarchar](1) NULL,
	[o_inund_depth] [nvarchar](1) NULL,
	[o_inund_runon_vel] [nvarchar](1) NULL,
	[o_depth_water] [real] NULL,
	[o_depth_water_pref] [nvarchar](1) NULL,
	[o_depth_rhorizon_pf] [nvarchar](1) NULL,
	[o_depth_rhorizon] [float] NULL,
	[o_runoff] [nvarchar](1) NULL,
	[o_permeability] [nvarchar](1) NULL,
	[o_sb_obs_type] [nvarchar](1) NULL,
	[o_sb_distance] [real] NULL,
	[o_sb_confidence] [nvarchar](1) NULL,
	[o_sb_depth_pf] [nvarchar](1) NULL,
	[o_sb_depth] [real] NULL,
	[o_sb_grain_size] [nvarchar](1) NULL,
	[o_sb_texture] [nvarchar](1) NULL,
	[o_sb_structure] [nvarchar](1) NULL,
	[o_sb_porosity] [nvarchar](1) NULL,
	[o_sb_strength] [nvarchar](2) NULL,
	[o_sb_lith] [nvarchar](2) NULL,
	[o_sb_mass_spac_dis] [nvarchar](1) NULL,
	[o_sb_mass_alt] [nvarchar](1) NULL,
	[o_sb_mass_strength] [nvarchar](2) NULL,
	[o_sb_mass_gen_type] [nvarchar](2) NULL,
	[o_substrate_notes] [nvarchar](255) NULL,
	[o_ppf] [nvarchar](9) NULL,
	[o_gsg] [nvarchar](3) NULL,
	[o_asc_tech_ref] [nvarchar](1) NULL,
	[o_asc_conf] [nvarchar](1) NULL,
	[o_asc_ord] [nvarchar](2) NULL,
	[o_asc_subord] [nvarchar](2) NULL,
	[o_asc_gg] [nvarchar](2) NULL,
	[o_asc_subg] [nvarchar](2) NULL,
	[o_asc_fam1] [nvarchar](1) NULL,
	[o_asc_fam2] [nvarchar](1) NULL,
	[o_asc_fam3] [nvarchar](1) NULL,
	[o_asc_fam4] [nvarchar](1) NULL,
	[o_asc_fam5] [nvarchar](1) NULL,
	[o_asc_notes] [nvarchar](255) NULL,
	[o_uni_soil_class] [nvarchar](5) NULL,
	[o_soil_taxonomy] [nvarchar](6) NULL,
	[o_tax_unit_type] [nvarchar](3) NULL,
	[o_tax_unit_name] [nvarchar](100) NULL,
	[o_map_unit_type] [nvarchar](3) NULL,
	[o_map_unit_name] [nvarchar](100) NULL,
	[o_notes] [nvarchar](255) NULL,
 CONSTRAINT [PK_OBSERVATIONS] PRIMARY KEY 
(
	[agency_code] ASC,
	[proj_code] ASC,
	[s_id] ASC,
	[o_id] ASC
)

CONSTRAINT [FK_OBSERVATIONS_SITES] FOREIGN KEY([agency_code], [proj_code], [s_id])
REFERENCES [SITES] ([agency_code], [proj_code], [s_id])

);



/****** Object:  Table [dbo].[HORIZONS]    Script Date: 6/04/2023 9:20:54 AM ******/


CREATE TABLE [HORIZONS](
	[agency_code] [nvarchar](3) NOT NULL,
	[proj_code] [nvarchar](10) NOT NULL,
	[s_id] [nvarchar](10) NOT NULL,
	[o_id] [nvarchar](2) NOT NULL,
	[h_no] [smallint] NOT NULL,
	[h_desig_num_pref] [smallint] NULL,
	[h_desig_master] [nvarchar](3) NULL,
	[h_desig_subdiv] [smallint] NULL,
	[h_desig_suffix] [nvarchar](5) NULL,
	[h_upper_depth] [real] NULL,
	[h_lower_depth] [real] NULL,
	[h_texture] [nvarchar](5) NULL,
	[h_texture_qual] [nvarchar](1) NULL,
	[h_soil_water_stat] [nvarchar](1) NULL,
	[h_stickiness] [nvarchar](1) NULL,
	[h_plasticity_type] [nvarchar](1) NULL,
	[h_plasticity_deg] [nvarchar](1) NULL,
	[h_water_repellence] [nvarchar](1) NULL,
	[h_carbonate_eff] [nvarchar](1) NULL,
	[h_bound_distinct] [nvarchar](1) NULL,
	[h_bound_shape] [nvarchar](1) NULL,
	[h_permeability] [nvarchar](1) NULL,
	[h_notes] [nvarchar](510) NULL,
	[h_ec] [nvarchar](10) NULL,
	[h_salinity_depth] [nvarchar](10) NULL,
	[h_dispersion] [nvarchar](10) NULL,
	[h_drainage] [nvarchar](1) NULL,
 CONSTRAINT [PK_HORIZONS] PRIMARY KEY 
(
	[agency_code] ASC,
	[proj_code] ASC,
	[s_id] ASC,
	[o_id] ASC,
	[h_no] ASC
)

CONSTRAINT [FK_HORIZONS_OBSERVATIONS] FOREIGN KEY([agency_code], [proj_code], [s_id], [o_id])
REFERENCES [OBSERVATIONS] ([agency_code], [proj_code], [s_id], [o_id])

);


/****** Object:  Table [dbo].[SAMPLES]    Script Date: 6/04/2023 9:00:08 AM ******/

CREATE TABLE [SAMPLES](
	[agency_code] [nvarchar](3) NOT NULL,
	[proj_code] [nvarchar](10) NOT NULL,
	[s_id] [nvarchar](10) NOT NULL,
	[o_id] [nvarchar](2) NOT NULL,
	[h_no] [smallint] NOT NULL,
	[samp_no] [smallint] NOT NULL,
	[samp_upper_depth] [real] NULL,
	[samp_lower_depth] [real] NULL,
	[samp_contrib] [smallint] NULL,
	[samp_size] [nvarchar](1) NULL,
	[samp_notes] [nvarchar](255) NULL,

CONSTRAINT [FK_SAMPLES_HORIZONS] 
FOREIGN KEY([agency_code], [proj_code], [s_id], [o_id], [h_no])
REFERENCES [HORIZONS] ([agency_code], [proj_code], [s_id], [o_id], [h_no]) 

);




/****** Object:  Table [dbo].[ARCHIVE_SAMPLES]    Script Date: 6/04/2023 9:01:32 AM ******/


CREATE TABLE [ARCHIVE_SAMPLES](
	[agency_code] [nvarchar](3) NOT NULL,
	[proj_code] [nvarchar](10) NOT NULL,
	[s_id] [nvarchar](10) NOT NULL,
	[o_id] [nvarchar](2) NOT NULL,
	[h_no] [smallint] NOT NULL,
	[samp_no] [smallint] NOT NULL,
	[jar_no] [smallint] NOT NULL,
	[samp_type] [nvarchar](2) NULL,
	[location] [nvarchar](12) NULL,
	[weight] [real] NULL,
	[>2mm] [bit] NOT NULL,
	[spec_id] [int] NULL,
	[subsample_date] [nvarchar](8) NULL,
	[subsample_tray] [nvarchar](50) NULL,
 CONSTRAINT [FK_ARCHIVE_SAMPLES_SAMPLES] FOREIGN KEY([agency_code], [proj_code], [s_id], [o_id], [h_no], [samp_no])
REFERENCES [SAMPLES] ([agency_code], [proj_code], [s_id], [o_id], [h_no], [samp_no])
);




/****** Object:  Table [dbo].[CODES]    Script Date: 6/04/2023 9:01:48 AM ******/

CREATE TABLE [CODES](
	[AGENCY_CODE] [nvarchar](3) NOT NULL,
	[CODE_DOMAIN] [nvarchar](20) NOT NULL,
	[CODE_VALUE] [nvarchar](10) NOT NULL,
	[CODE_VALUE2] [nvarchar](6) NULL,
	[CODE_VALUE3] [nvarchar](6) NULL,
	[CODE_DESC] [nvarchar](100) NULL,
	[CODE_TECH_REF] [nvarchar](1) NULL,
	[CODE_AVG_NO_VALUE] [float] NULL,
	[CODE_LOW_NO_VALUE] [float] NULL,
	[CODE_HIGH_NO_VALUE] [float] NULL,
             [code_pub_id] [int] NULL,
 CONSTRAINT [PK_CODES] PRIMARY KEY ([AGENCY_CODE] ASC,
	[CODE_DOMAIN] ASC,
	[CODE_VALUE] ASC

)
);




/****** Object:  Table [dbo].[LAB_METHOD_TYPES]    Script Date: 6/04/2023 9:03:00 AM ******/

CREATE TABLE [LAB_METHOD_TYPES](
	[LABMT_CODE] [nvarchar](20) NOT NULL,
	[LABMT_NAME] [nvarchar](80) NOT NULL,
 CONSTRAINT [PK_LAB_METHOD_TYPES] PRIMARY KEY (
	[LABMT_CODE] ASC
)
);


/****** Object:  Table [dbo].[LAB_PROPERTIES]    Script Date: 6/04/2023 9:03:00 AM ******/
CREATE TABLE [LAB_PROPERTIES](
	[LABP_CODE] [nvarchar](20) NOT NULL,
	[LABP_NAME] [nvarchar](80) NULL,
 CONSTRAINT [PK_LAB_PROPERTIES] PRIMARY KEY 
(
	[LABP_CODE] ASC
)
);




/****** Object:  Table [dbo].[LAB_METHODS]    Script Date: 6/04/2023 9:02:40 AM ******/

CREATE TABLE [LAB_METHODS](
	[AGENCY_CODE] [nvarchar](3) NULL,
	[LABM_CODE] [nvarchar](15) NOT NULL,
	[LABP_CODE] [nvarchar](20) NOT NULL,
	[LABMT_CODE] [nvarchar](20) NULL,
	[LABM_NAME] [nvarchar](255) NOT NULL,
	[LABM_SHORT_NAME] [nvarchar](32) NOT NULL,
	[LABM_REF] [nvarchar](511) NOT NULL,
	[LABM_MASK] [nvarchar](12) NULL,
	[LABM_UNITS] [nvarchar](20) NULL,
	[LABM_LOW_VALUE] [float] NULL,
	[LABM_HIGH_VALUE] [float] NULL,
             [labm_pub_id] [int] NULL

);






/****** Object:  Table [dbo].[LAB_RESULTS]    Script Date: 24/11/2023 10:16:58 AM ******/

CREATE TABLE [LAB_RESULTS](
	[agency_code] [nvarchar](3) NOT NULL,
	[proj_code] [nvarchar](10) NOT NULL,
	[s_id] [nvarchar](10) NOT NULL,
	[o_id] [nvarchar](2) NOT NULL,
	[h_no] [smallint] NOT NULL,
	[samp_no] [smallint] NOT NULL,
	[labr_no] [smallint] NOT NULL,
	[labm_code] [nvarchar](15) NOT NULL,
	[labr_value_prefix] [nvarchar](1) NULL,
	[labr_value] [real] NULL,
	[labr_low_value] [float] NULL,
	[labr_high_value] [float] NULL,
	[labr_analysis_type] [nvarchar](4) NULL,
	[labr_date] [nvarchar](8) NULL,
	[labr_agency_code] [nvarchar](3) NULL,
	[labr_label] [nvarchar](10) NULL,
 CONSTRAINT [PK_LAB_RESULTS] PRIMARY KEY 
(
	[agency_code] ASC,
	[proj_code] ASC,
	[s_id] ASC,
	[o_id] ASC,
	[h_no] ASC,
	[samp_no] ASC,
	[labr_no] ASC,
	[labm_code] ASC
)

CONSTRAINT [FK_LAB_RESULTS_AGENCY_CODE] FOREIGN KEY([labr_agency_code])
REFERENCES [AGENCIES] ([AGENCY_CODE])

CONSTRAINT [FK_LAB_RESULTS_LAB_METHODS] FOREIGN KEY([labm_code])
REFERENCES [LAB_METHODS] ([LABM_CODE])

CONSTRAINT [FK_LAB_RESULTS_SAMPLES] FOREIGN KEY([agency_code], [proj_code], [s_id], [o_id], [h_no], [samp_no])
REFERENCES [SAMPLES] ([agency_code], [proj_code], [s_id], [o_id], [h_no], [samp_no])

);



/****** Object:  Table [dbo].[COARSE_FRAGS]    Script Date: 6/04/2023 9:04:31 AM ******/

CREATE TABLE [COARSE_FRAGS](
	[agency_code] [nvarchar](3) NOT NULL,
	[proj_code] [nvarchar](10) NOT NULL,
	[s_id] [nvarchar](10) NOT NULL,
	[o_id] [nvarchar](2) NOT NULL,
	[h_no] [smallint] NOT NULL,
	[cf_no] [smallint] NOT NULL,
	[cf_abun] [nvarchar](1) NULL,
	[cf_size] [nvarchar](1) NULL,
	[cf_shape] [nvarchar](2) NULL,
	[cf_lith] [nvarchar](2) NULL,
	[cf_strength] [nvarchar](2) NULL,
	[cf_distribution] [nvarchar](1) NULL,
 CONSTRAINT [PK_COARSE_FRAGS] PRIMARY KEY  
(
	[agency_code] ASC,
	[proj_code] ASC,
	[s_id] ASC,
	[o_id] ASC,
	[h_no] ASC,
	[cf_no] ASC
)

CONSTRAINT [FK_COARSE_FRAGS_HORIZONS] FOREIGN KEY([agency_code], [proj_code], [s_id], [o_id], [h_no])
REFERENCES [HORIZONS] ([agency_code], [proj_code], [s_id], [o_id], [h_no])
);


/****** Object:  Table [dbo].[COLOURS]    Script Date: 6/04/2023 9:04:51 AM ******/

CREATE TABLE [COLOURS](
	[agency_code] [nvarchar](3) NOT NULL,
	[proj_code] [nvarchar](10) NOT NULL,
	[s_id] [nvarchar](10) NOT NULL,
	[o_id] [nvarchar](2) NOT NULL,
	[h_no] [smallint] NOT NULL,
	[col_no] [smallint] NOT NULL,
	[col_hue_val_chrom] [nvarchar](10) NOT NULL,
	[col_hue] [nvarchar](5) NULL,
	[col_value] [real] NULL,
	[col_chroma] [real] NULL,
	[col_moisture_stat] [nvarchar](1) NULL,
 CONSTRAINT [PK_COLOURS] PRIMARY KEY 
(
	[agency_code] ASC,
	[proj_code] ASC,
	[s_id] ASC,
	[o_id] ASC,
	[h_no] ASC,
	[col_no] ASC
)

CONSTRAINT [FK_COLOURS_HORIZONS] FOREIGN KEY([agency_code], [proj_code], [s_id], [o_id], [h_no])
REFERENCES [HORIZONS] ([agency_code], [proj_code], [s_id], [o_id], [h_no])

);


/****** Object:  Table [dbo].[CRACKS]    Script Date: 6/04/2023 9:05:10 AM ******/

CREATE TABLE [CRACKS](
	[agency_code] [nvarchar](3) NOT NULL,
	[proj_code] [nvarchar](10) NOT NULL,
	[s_id] [nvarchar](10) NOT NULL,
	[o_id] [nvarchar](2) NOT NULL,
	[h_no] [smallint] NOT NULL,
	[crack_no] [smallint] NOT NULL,
	[crack_width] [nvarchar](1) NOT NULL,
 CONSTRAINT [PK_CRACKS] PRIMARY KEY 
(
	[agency_code] ASC,
	[proj_code] ASC,
	[s_id] ASC,
	[o_id] ASC,
	[h_no] ASC,
	[crack_no] ASC
)

CONSTRAINT [FK_CRACKS_HORIZONS] FOREIGN KEY([agency_code], [proj_code], [s_id], [o_id], [h_no])
REFERENCES [HORIZONS] ([agency_code], [proj_code], [s_id], [o_id], [h_no])

);




/****** Object:  Table [dbo].[CUTANS]    Script Date: 6/04/2023 9:05:31 AM ******/

CREATE TABLE [CUTANS](
	[agency_code] [nvarchar](3) NOT NULL,
	[proj_code] [nvarchar](10) NOT NULL,
	[s_id] [nvarchar](10) NOT NULL,
	[o_id] [nvarchar](2) NOT NULL,
	[h_no] [smallint] NOT NULL,
	[cutan_no] [smallint] NOT NULL,
	[cutan_type] [nvarchar](1) NULL,
	[cutan_abun] [nvarchar](1) NULL,
	[cutan_distinct] [nvarchar](1) NULL,
 CONSTRAINT [PK_CUTANS] PRIMARY KEY  
(
	[agency_code] ASC,
	[proj_code] ASC,
	[s_id] ASC,
	[o_id] ASC,
	[h_no] ASC,
	[cutan_no] ASC
)

CONSTRAINT [FK_CUTANS_HORIZONS] FOREIGN KEY([agency_code], [proj_code], [s_id], [o_id], [h_no])
REFERENCES [HORIZONS] ([agency_code], [proj_code], [s_id], [o_id], [h_no])

);



/****** Object:  Table [dbo].[DISTURBANCES]    Script Date: 6/04/2023 9:05:41 AM ******/

CREATE TABLE [DISTURBANCES](
	[agency_code] [nvarchar](3) NOT NULL,
	[proj_code] [nvarchar](10) NOT NULL,
	[s_id] [nvarchar](10) NOT NULL,
	[o_id] [nvarchar](2) NOT NULL,
	[dist_no] [smallint] NOT NULL,
	[dist_type] [nvarchar](1) NOT NULL,
 CONSTRAINT [PK_DISTURBANCES] PRIMARY KEY 
(
	[agency_code] ASC,
	[proj_code] ASC,
	[s_id] ASC,
	[o_id] ASC,
	[dist_no] ASC
)
CONSTRAINT [FK_DISTURBANCES_OBSERVATIONS] FOREIGN KEY([agency_code], [proj_code], [s_id], [o_id])
REFERENCES [OBSERVATIONS] ([agency_code], [proj_code], [s_id], [o_id])

);



/****** Object:  Table [dbo].[ELEM_GEOMORPHS]    Script Date: 6/04/2023 9:06:01 AM ******/

CREATE TABLE [ELEM_GEOMORPHS](
	[agency_code] [nvarchar](3) NOT NULL,
	[proj_code] [nvarchar](10) NOT NULL,
	[s_id] [nvarchar](10) NOT NULL,
	[egm_no] [smallint] NOT NULL,
	[egm_mode] [nvarchar](2) NULL,
	[egm_agent] [nvarchar](2) NULL,
 CONSTRAINT [PK_ELEM_GEOMORPHS] PRIMARY KEY  
(
	[agency_code] ASC,
	[proj_code] ASC,
	[s_id] ASC,
	[egm_no] ASC
)

CONSTRAINT [FK_ELEM_GEOMORPHS_SITES] FOREIGN KEY([agency_code], [proj_code], [s_id])
REFERENCES [SITES] ([agency_code], [proj_code], [s_id])

);




/****** Object:  Table [dbo].[EXOTICS]    Script Date: 6/04/2023 9:06:17 AM ******/

CREATE TABLE [EXOTICS](
	[AGENCY_CODE] [nvarchar](3) NOT NULL,
	[PROJ_CODE] [nvarchar](10) NOT NULL,
	[S_ID] [nvarchar](10) NOT NULL,
	[O_ID] [nvarchar](2) NOT NULL,
	[EX_NO] [int] NOT NULL,
	[EX_SPECIES_CODE] [nvarchar](1) NULL,
	[EX_EXTENT] [float] NULL,
 CONSTRAINT [PK_EXOTICS] PRIMARY KEY 
(
	[AGENCY_CODE] ASC,
	[PROJ_CODE] ASC,
	[S_ID] ASC,
	[O_ID] ASC,
	[EX_NO] ASC
)
CONSTRAINT [FK_EXOTICS_OBSERVATIONS] FOREIGN KEY([AGENCY_CODE], [PROJ_CODE], [S_ID], [O_ID])
REFERENCES [OBSERVATIONS] ([agency_code], [proj_code], [s_id], [o_id])
);



/****** Object:  Table [dbo].[FABRICS]    Script Date: 6/04/2023 9:06:29 AM ******/

CREATE TABLE [FABRICS](
	[agency_code] [nvarchar](3) NOT NULL,
	[proj_code] [nvarchar](10) NOT NULL,
	[s_id] [nvarchar](10) NOT NULL,
	[o_id] [nvarchar](2) NOT NULL,
	[h_no] [smallint] NOT NULL,
	[fab_no] [smallint] NOT NULL,
	[fab_type] [nvarchar](1) NOT NULL,
	[fab_abun] [nvarchar](1) NULL,
 CONSTRAINT [PK_FABRICS] PRIMARY KEY 
(
	[agency_code] ASC,
	[proj_code] ASC,
	[s_id] ASC,
	[o_id] ASC,
	[h_no] ASC,
	[fab_no] ASC
)

CONSTRAINT [FK_FABRICS_HORIZONS] FOREIGN KEY([agency_code], [proj_code], [s_id], [o_id], [h_no])
REFERENCES [HORIZONS] ([agency_code], [proj_code], [s_id], [o_id], [h_no])
);



/****** Object:  Table [dbo].[LAND_COVER]    Script Date: 6/04/2023 9:06:51 AM ******/

CREATE TABLE [LAND_COVER](
	[agency_code] [nvarchar](3) NOT NULL,
	[proj_code] [nvarchar](10) NOT NULL,
	[s_id] [nvarchar](10) NOT NULL,
	[lcov_no] [smallint] NOT NULL,
	[lcov_date] [nvarchar](8) NOT NULL,
	[lcov_ref] [nvarchar](10) NULL,
	[land_cover] [nvarchar](10) NULL,
 CONSTRAINT [PK_LAND_COVER] PRIMARY KEY  
(
	[agency_code] ASC,
	[proj_code] ASC,
	[s_id] ASC,
	[lcov_no] ASC
) 
CONSTRAINT [FK_LAND_COVER_SITES] FOREIGN KEY([agency_code], [proj_code], [s_id])
REFERENCES [SITES] ([agency_code], [proj_code], [s_id])
);



/****** Object:  Table [dbo].[LAND_USES]    Script Date: 6/04/2023 9:07:05 AM ******/

CREATE TABLE [LAND_USES](
	[agency_code] [nvarchar](3) NOT NULL,
	[proj_code] [nvarchar](10) NOT NULL,
	[s_id] [nvarchar](10) NOT NULL,
	[luse_no] [smallint] NOT NULL,
	[luse_date] [nvarchar](8) NULL,
	[luse_end_date] [nvarchar](8) NULL,
	[luse_ref] [nvarchar](10) NOT NULL,
	[land_use] [nvarchar](10) NOT NULL,
 CONSTRAINT [PK_LAND_USES] PRIMARY KEY
(
	[agency_code] ASC,
	[proj_code] ASC,
	[s_id] ASC,
	[luse_no] ASC
)
CONSTRAINT [FK_LAND_USES_SITES] FOREIGN KEY([agency_code], [proj_code], [s_id])
REFERENCES [SITES] ([agency_code], [proj_code], [s_id])
);




/****** Object:  Table [dbo].[MICRORELIEFS]    Script Date: 6/04/2023 9:07:16 AM ******/

CREATE TABLE [MICRORELIEFS](
	[agency_code] [nvarchar](3) NOT NULL,
	[proj_code] [nvarchar](10) NOT NULL,
	[s_id] [nvarchar](10) NOT NULL,
	[o_id] [nvarchar](2) NOT NULL,
	[mr_no] [smallint] NOT NULL,
	[mr_type] [nvarchar](1) NULL,
	[mr_prop_gilgai] [nvarchar](1) NULL,
	[mr_biotic_agent] [nvarchar](1) NULL,
	[mr_biotic_comp] [nvarchar](1) NULL,
	[mr_vertical_int] [real] NULL,
	[mr_horiz_int] [real] NULL,
 CONSTRAINT [PK_MICRORELIEFS] PRIMARY KEY
(
	[agency_code] ASC,
	[proj_code] ASC,
	[s_id] ASC,
	[o_id] ASC,
	[mr_no] ASC
)

CONSTRAINT [FK_MICRORELIEFS_OBSERVATIONS] FOREIGN KEY([agency_code], [proj_code], [s_id], [o_id])
REFERENCES [OBSERVATIONS] ([agency_code], [proj_code], [s_id], [o_id])
);


/****** Object:  Table [dbo].[MOTTLES]    Script Date: 6/04/2023 9:07:30 AM ******/

CREATE TABLE [MOTTLES](
	[agency_code] [nvarchar](3) NOT NULL,
	[proj_code] [nvarchar](10) NOT NULL,
	[s_id] [nvarchar](10) NOT NULL,
	[o_id] [nvarchar](2) NOT NULL,
	[h_no] [smallint] NOT NULL,
	[mott_no] [smallint] NOT NULL,
	[mott_type] [nvarchar](1) NULL,
	[mott_abun] [nvarchar](1) NULL,
	[mott_size] [nvarchar](1) NULL,
	[mott_contrast] [nvarchar](1) NULL,
	[mott_hue_val_chrom] [nvarchar](10) NULL,
	[mott_hue] [nvarchar](5) NULL,
	[mott_value] [real] NULL,
	[mott_chroma] [real] NULL,
	[mott_moisture_stat] [nvarchar](1) NULL,
	[mott_colour] [nvarchar](1) NULL,
	[mott_boun_distinct] [nvarchar](1) NULL,
 CONSTRAINT [PK_MOTTLES] PRIMARY KEY 
(
	[agency_code] ASC,
	[proj_code] ASC,
	[s_id] ASC,
	[o_id] ASC,
	[h_no] ASC,
	[mott_no] ASC
)
CONSTRAINT [FK_MOTTLES_HORIZONS] FOREIGN KEY([agency_code], [proj_code], [s_id], [o_id], [h_no])
REFERENCES [HORIZONS] ([agency_code], [proj_code], [s_id], [o_id], [h_no])
);



/****** Object:  Table [dbo].[OBS_MNG_PRACS]    Script Date: 6/04/2023 9:07:42 AM ******/

CREATE TABLE [OBS_MNG_PRACS](
	[agency_code] [nvarchar](3) NOT NULL,
	[proj_code] [nvarchar](10) NOT NULL,
	[s_id] [nvarchar](10) NOT NULL,
	[o_id] [nvarchar](2) NOT NULL,
	[omp_no] [smallint] NOT NULL,
	[omp_date] [nvarchar](8) NULL,
	[omp_ref] [nvarchar](10) NOT NULL,
	[omp_code] [nvarchar](10) NOT NULL,
 CONSTRAINT [PK_OBS_MNG_PRACS] PRIMARY KEY  
(
	[agency_code] ASC,
	[proj_code] ASC,
	[s_id] ASC,
	[o_id] ASC,
	[omp_no] ASC
)
CONSTRAINT [FK_OBS_MNG_PRACS_OBSERVATIONS] FOREIGN KEY([agency_code], [proj_code], [s_id], [o_id])
REFERENCES [OBSERVATIONS] ([agency_code], [proj_code], [s_id], [o_id])
);



/****** Object:  Table [dbo].[PANS]    Script Date: 6/04/2023 9:07:55 AM ******/

CREATE TABLE [PANS](
	[agency_code] [nvarchar](3) NOT NULL,
	[proj_code] [nvarchar](10) NOT NULL,
	[s_id] [nvarchar](10) NOT NULL,
	[o_id] [nvarchar](2) NOT NULL,
	[h_no] [smallint] NOT NULL,
	[pan_no] [smallint] NOT NULL,
	[pan_cementation] [nvarchar](1) NULL,
	[pan_type] [nvarchar](1) NULL,
	[pan_continuity] [nvarchar](1) NULL,
	[pan_structure] [nvarchar](1) NULL,
 CONSTRAINT [PK_PANS] PRIMARY KEY 
(
	[agency_code] ASC,
	[proj_code] ASC,
	[s_id] ASC,
	[o_id] ASC,
	[h_no] ASC,
	[pan_no] ASC
)

CONSTRAINT [FK_PANS_HORIZONS] FOREIGN KEY([agency_code], [proj_code], [s_id], [o_id], [h_no])
REFERENCES [HORIZONS] ([agency_code], [proj_code], [s_id], [o_id], [h_no])
);


/****** Object:  Table [dbo].[PATT_GEOMORPHS]    Script Date: 6/04/2023 9:08:06 AM ******/

CREATE TABLE [PATT_GEOMORPHS](
	[agency_code] [nvarchar](3) NOT NULL,
	[proj_code] [nvarchar](10) NOT NULL,
	[s_id] [nvarchar](10) NOT NULL,
	[pgm_no] [smallint] NOT NULL,
	[pgm_mode] [nvarchar](2) NULL,
	[pgm_agent] [nvarchar](2) NULL,
	[pgm_stat] [nvarchar](1) NULL,
 CONSTRAINT [PK_PATT_GEOMORPHS] PRIMARY KEY  
(
	[agency_code] ASC,
	[proj_code] ASC,
	[s_id] ASC,
	[pgm_no] ASC
)

CONSTRAINT [FK_PATT_GEOMORPHS_SITES] FOREIGN KEY([agency_code], [proj_code], [s_id])
REFERENCES [SITES] ([agency_code], [proj_code], [s_id])
);


/****** Object:  Table [dbo].[PHS]    Script Date: 6/04/2023 9:08:30 AM ******/

CREATE TABLE [PHS](
	[agency_code] [nvarchar](3) NOT NULL,
	[proj_code] [nvarchar](10) NOT NULL,
	[s_id] [nvarchar](10) NOT NULL,
	[o_id] [nvarchar](2) NOT NULL,
	[h_no] [smallint] NOT NULL,
	[ph_no] [smallint] NOT NULL,
	[ph_value] [real] NULL,
	[ph_depth] [real] NULL,
	[ph_method] [nvarchar](1) NULL,
 CONSTRAINT [PK_PHS] PRIMARY KEY 
(
	[agency_code] ASC,
	[proj_code] ASC,
	[s_id] ASC,
	[o_id] ASC,
	[h_no] ASC,
	[ph_no] ASC
)
CONSTRAINT [FK_PHS_HORIZONS] FOREIGN KEY([agency_code], [proj_code], [s_id], [o_id], [h_no])
REFERENCES [HORIZONS] ([agency_code], [proj_code], [s_id], [o_id], [h_no])
CONSTRAINT [CHK_PHS_ph_value] CHECK  (([ph_value]>(0) AND [ph_value]<(14) OR [ph_value] IS NULL))
);


/****** Object:  Table [dbo].[PORES]    Script Date: 6/04/2023 9:08:44 AM ******/

CREATE TABLE [PORES](
	[agency_code] [nvarchar](3) NOT NULL,
	[proj_code] [nvarchar](10) NOT NULL,
	[s_id] [nvarchar](10) NOT NULL,
	[o_id] [nvarchar](2) NOT NULL,
	[h_no] [smallint] NOT NULL,
	[pore_no] [smallint] NOT NULL,
	[pore_abun] [nvarchar](1) NULL,
	[pore_diameter] [nvarchar](1) NULL,
 CONSTRAINT [PK_PORES] PRIMARY KEY  
(
	[agency_code] ASC,
	[proj_code] ASC,
	[s_id] ASC,
	[o_id] ASC,
	[h_no] ASC,
	[pore_no] ASC
)
CONSTRAINT [FK_PORES_HORIZONS] FOREIGN KEY([agency_code], [proj_code], [s_id], [o_id], [h_no])
REFERENCES [HORIZONS] ([agency_code], [proj_code], [s_id], [o_id], [h_no])
);


/****** Object:  Table [dbo].[ROCK_OUTCROPS]    Script Date: 6/04/2023 9:09:52 AM ******/

CREATE TABLE [ROCK_OUTCROPS](
	[agency_code] [nvarchar](3) NOT NULL,
	[proj_code] [nvarchar](10) NOT NULL,
	[s_id] [nvarchar](10) NOT NULL,
	[o_id] [nvarchar](2) NOT NULL,
	[ro_no] [smallint] NOT NULL,
	[ro_abun] [nvarchar](1) NULL,
	[ro_lith] [nvarchar](2) NULL,
 CONSTRAINT [PK_ROCK_OUTCROPS] PRIMARY KEY  
(
	[agency_code] ASC,
	[proj_code] ASC,
	[s_id] ASC,
	[o_id] ASC,
	[ro_no] ASC
)
CONSTRAINT [FK_ROCK_OUTCROPS_OBSERVATIONS] FOREIGN KEY([agency_code], [proj_code], [s_id], [o_id])
REFERENCES [OBSERVATIONS] ([agency_code], [proj_code], [s_id], [o_id])
);




/****** Object:  Table [dbo].[ROOTS]    Script Date: 6/04/2023 9:10:05 AM ******/

CREATE TABLE [ROOTS](
	[agency_code] [nvarchar](3) NOT NULL,
	[proj_code] [nvarchar](10) NOT NULL,
	[s_id] [nvarchar](10) NOT NULL,
	[o_id] [nvarchar](2) NOT NULL,
	[h_no] [smallint] NOT NULL,
	[root_no] [smallint] NOT NULL,
	[root_abun] [nvarchar](1) NULL,
	[root_size] [nvarchar](1) NULL,
 CONSTRAINT [PK_ROOTS] PRIMARY KEY 
(
	[agency_code] ASC,
	[proj_code] ASC,
	[s_id] ASC,
	[o_id] ASC,
	[h_no] ASC,
	[root_no] ASC
)
CONSTRAINT [FK_ROOTS_HORIZONS] FOREIGN KEY([agency_code], [proj_code], [s_id], [o_id], [h_no])
REFERENCES [HORIZONS] ([agency_code], [proj_code], [s_id], [o_id], [h_no])
);



/****** Object:  Table [dbo].[SEGREGATIONS]    Script Date: 6/04/2023 9:10:18 AM ******/

CREATE TABLE [SEGREGATIONS](
	[agency_code] [nvarchar](3) NOT NULL,
	[proj_code] [nvarchar](10) NOT NULL,
	[s_id] [nvarchar](10) NOT NULL,
	[o_id] [nvarchar](2) NOT NULL,
	[h_no] [smallint] NOT NULL,
	[seg_no] [smallint] NOT NULL,
	[seg_abun] [nvarchar](1) NULL,
	[seg_nature] [nvarchar](1) NULL,
	[seg_form] [nvarchar](1) NULL,
	[seg_size] [nvarchar](1) NULL,
	[seg_strength] [nvarchar](1) NULL,
	[seg_magnetic_attr] [nvarchar](1) NULL,
 CONSTRAINT [PK_SEGREGATIONS] PRIMARY KEY 
(
	[agency_code] ASC,
	[proj_code] ASC,
	[s_id] ASC,
	[o_id] ASC,
	[h_no] ASC,
	[seg_no] ASC
)
CONSTRAINT [FK_SEGREGATIONS_HORIZONS] FOREIGN KEY([agency_code], [proj_code], [s_id], [o_id], [h_no])
REFERENCES [HORIZONS] ([agency_code], [proj_code], [s_id], [o_id], [h_no])
);


/****** Object:  Table [dbo].[SITE_ENVELOPE]    Script Date: 6/04/2023 9:10:31 AM ******/

CREATE TABLE [SITE_ENVELOPE](
	[agency_code] [nvarchar](3) NOT NULL,
	[proj_code] [nvarchar](10) NOT NULL,
	[s_id] [nvarchar](10) NOT NULL,
	[s_env_no] [smallint] NOT NULL,
	[s_env_code] [nvarchar](10) NOT NULL,
	[s_env_value] [nvarchar](50) NULL,
 CONSTRAINT [PK_SITE_ENVELOPE] PRIMARY KEY   
(
	[agency_code] ASC,
	[proj_code] ASC,
	[s_id] ASC,
	[s_env_no] ASC,
	[s_env_code] ASC
)
CONSTRAINT [FK_SITE_ENVELOPE_SITES] FOREIGN KEY([agency_code], [proj_code], [s_id])
REFERENCES [SITES] ([agency_code], [proj_code], [s_id])

);


/****** Object:  Table [dbo].[SITE_MNG_PRACS]    Script Date: 6/04/2023 9:10:47 AM ******/

CREATE TABLE [SITE_MNG_PRACS](
	[agency_code] [nvarchar](3) NOT NULL,
	[proj_code] [nvarchar](10) NOT NULL,
	[s_id] [nvarchar](10) NOT NULL,
	[luse_no] [smallint] NOT NULL,
	[smp_no] [smallint] NOT NULL,
	[smp_date] [nvarchar](8) NOT NULL,
	[smp_ref] [nvarchar](10) NULL,
	[smp_code] [nvarchar](10) NULL,
 CONSTRAINT [PK_SITE_MNG_PRACS] PRIMARY KEY  
(
	[agency_code] ASC,
	[proj_code] ASC,
	[s_id] ASC,
	[luse_no] ASC,
	[smp_no] ASC
)
CONSTRAINT [FK_SITE_MNG_PRACS_SITES] FOREIGN KEY([agency_code], [proj_code], [s_id])
REFERENCES [SITES] ([agency_code], [proj_code], [s_id])
);





/****** Object:  Table [dbo].[STRENGTHS]    Script Date: 6/04/2023 9:12:23 AM ******/

CREATE TABLE [STRENGTHS](
	[agency_code] [nvarchar](3) NOT NULL,
	[proj_code] [nvarchar](10) NOT NULL,
	[s_id] [nvarchar](10) NOT NULL,
	[o_id] [nvarchar](2) NOT NULL,
	[h_no] [smallint] NOT NULL,
	[strg_no] [smallint] NOT NULL,
	[strg_class] [nvarchar](1) NULL,
	[strg_moisture_stat] [nvarchar](1) NULL,
 CONSTRAINT [PK_STRENGTHS] PRIMARY KEY  
(
	[agency_code] ASC,
	[proj_code] ASC,
	[s_id] ASC,
	[o_id] ASC,
	[h_no] ASC,
	[strg_no] ASC
)
CONSTRAINT [FK_STRENGTHS_HORIZONS] FOREIGN KEY([agency_code], [proj_code], [s_id], [o_id], [h_no])
REFERENCES [HORIZONS] ([agency_code], [proj_code], [s_id], [o_id], [h_no])
);




/****** Object:  Table [dbo].[STRUCTURES]    Script Date: 6/04/2023 9:12:36 AM ******/

CREATE TABLE [STRUCTURES](
	[agency_code] [nvarchar](3) NOT NULL,
	[proj_code] [nvarchar](10) NOT NULL,
	[s_id] [nvarchar](10) NOT NULL,
	[o_id] [nvarchar](2) NOT NULL,
	[h_no] [smallint] NOT NULL,
	[str_no] [smallint] NOT NULL,
	[str_ped_grade] [nvarchar](1) NULL,
	[str_ped_size] [nvarchar](1) NULL,
	[str_ped_type] [nvarchar](2) NULL,
	[str_compound_ped] [nvarchar](1) NULL,
	[str_clods_frags] [nvarchar](2) NULL,
 CONSTRAINT [PK_STRUCTURES] PRIMARY KEY  
(
	[agency_code] ASC,
	[proj_code] ASC,
	[s_id] ASC,
	[o_id] ASC,
	[h_no] ASC,
	[str_no] ASC
)
CONSTRAINT [FK_STRUCTURES_HORIZONS] FOREIGN KEY([agency_code], [proj_code], [s_id], [o_id], [h_no])
REFERENCES [HORIZONS] ([agency_code], [proj_code], [s_id], [o_id], [h_no])
);


/****** Object:  Table [dbo].[SUB_MINERAL_COMPS]    Script Date: 6/04/2023 9:12:54 AM ******/

CREATE TABLE [SUB_MINERAL_COMPS](
	[agency_code] [nvarchar](3) NOT NULL,
	[proj_code] [nvarchar](10) NOT NULL,
	[s_id] [nvarchar](10) NOT NULL,
	[o_id] [nvarchar](2) NOT NULL,
	[sb_no] [smallint] NOT NULL,
	[sb_mineral_comp] [nvarchar](1) NOT NULL,
 CONSTRAINT [PK_SUB_MINERAL_COMPS] PRIMARY KEY  
(
	[agency_code] ASC,
	[proj_code] ASC,
	[s_id] ASC,
	[o_id] ASC,
	[sb_no] ASC
)
CONSTRAINT [FK_SUB_MINERAL_COMPS_OBSERVATIONS] FOREIGN KEY([agency_code], [proj_code], [s_id], [o_id])
REFERENCES [OBSERVATIONS] ([agency_code], [proj_code], [s_id], [o_id])
);


/****** Object:  Table [dbo].[SURF_COARSE_FRAGS]    Script Date: 6/04/2023 9:13:09 AM ******/

CREATE TABLE [SURF_COARSE_FRAGS](
	[agency_code] [nvarchar](3) NOT NULL,
	[proj_code] [nvarchar](10) NOT NULL,
	[s_id] [nvarchar](10) NOT NULL,
	[o_id] [nvarchar](2) NOT NULL,
	[scf_no] [smallint] NOT NULL,
	[scf_abun] [nvarchar](1) NULL,
	[scf_size] [nvarchar](1) NULL,
	[scf_shape] [nvarchar](2) NULL,
	[scf_lith] [nvarchar](2) NULL,
	[scf_strength] [nvarchar](2) NULL,
 CONSTRAINT [PK_SURF_COARSE_FRAGS] PRIMARY KEY  
(
	[agency_code] ASC,
	[proj_code] ASC,
	[s_id] ASC,
	[o_id] ASC,
	[scf_no] ASC
)
CONSTRAINT [FK_SURF_COARSE_FRAGS_OBSERVATIONS] FOREIGN KEY([agency_code], [proj_code], [s_id], [o_id])
REFERENCES [OBSERVATIONS] ([agency_code], [proj_code], [s_id], [o_id])
);



/****** Object:  Table [dbo].[SURF_CONDITIONS]    Script Date: 6/04/2023 9:13:24 AM ******/

CREATE TABLE [SURF_CONDITIONS](
	[agency_code] [nvarchar](3) NOT NULL,
	[proj_code] [nvarchar](10) NOT NULL,
	[s_id] [nvarchar](10) NOT NULL,
	[o_id] [nvarchar](2) NOT NULL,
	[scon_no] [smallint] NOT NULL,
	[scon_stat] [nvarchar](1) NULL,
 CONSTRAINT [PK_SURF_CONDITIONS] PRIMARY KEY  
(
	[agency_code] ASC,
	[proj_code] ASC,
	[s_id] ASC,
	[o_id] ASC,
	[scon_no] ASC
)
CONSTRAINT [FK_SURF_CONDITIONS_OBSERVATIONS] FOREIGN KEY([agency_code], [proj_code], [s_id], [o_id])
REFERENCES [OBSERVATIONS] ([agency_code], [proj_code], [s_id], [o_id])
);



/****** Object:  Table [dbo].[VEG_STRATA]    Script Date: 6/04/2023 9:13:49 AM ******/

CREATE TABLE [VEG_STRATA](
	[agency_code] [nvarchar](3) NOT NULL,
	[proj_code] [nvarchar](10) NOT NULL,
	[s_id] [nvarchar](10) NOT NULL,
	[o_id] [nvarchar](2) NOT NULL,
	[vstr_code] [nvarchar](2) NOT NULL,
	[vstr_growth_form] [nvarchar](1) NULL,
	[vstr_height_class] [nvarchar](1) NULL,
	[vstr_cover_class] [nvarchar](1) NULL,
	[vstr_crown_cover] [real] NULL,
 CONSTRAINT [PK_VEG_STRATA] PRIMARY KEY  
(
	[agency_code] ASC,
	[proj_code] ASC,
	[s_id] ASC,
	[o_id] ASC,
	[vstr_code] ASC
)
CONSTRAINT [FK_VEG_STRATA_OBSERVATIONS] FOREIGN KEY([agency_code], [proj_code], [s_id], [o_id])
REFERENCES [OBSERVATIONS] ([agency_code], [proj_code], [s_id], [o_id])
);



/****** Object:  Table [dbo].[VEG_SPECIES]    Script Date: 6/04/2023 9:13:36 AM ******/

CREATE TABLE [VEG_SPECIES](
	[agency_code] [nvarchar](3) NOT NULL,
	[proj_code] [nvarchar](10) NOT NULL,
	[s_id] [nvarchar](10) NOT NULL,
	[o_id] [nvarchar](2) NOT NULL,
	[vstr_code] [nvarchar](2) NOT NULL,
	[vsp_no] [nvarchar](2) NOT NULL,
	[vsp_species] [nvarchar](90) NOT NULL,
	[vsp_code] [nvarchar](8) NULL,
	[vsp_anbg_id] [smallint] NULL,
	[vsp_abun] [nvarchar](3) NULL,
 CONSTRAINT [PK_VEG_SPECIES] PRIMARY KEY  
(
	[agency_code] ASC,
	[proj_code] ASC,
	[s_id] ASC,
	[o_id] ASC,
	[vstr_code] ASC,
	[vsp_no] ASC
)
CONSTRAINT [FK_VEG_SPECIES_VEG_STRATA] FOREIGN KEY([agency_code], [proj_code], [s_id], [o_id], [vstr_code])
REFERENCES [VEG_STRATA] ([agency_code], [proj_code], [s_id], [o_id], [vstr_code])
);
























