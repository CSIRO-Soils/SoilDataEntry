



# getValidationResultsReactTable <- function(vTab){
#   
#     r <-  reactable(vTab, defaultPageSize = 15, filterable = TRUE, 
#                 columns = list(
#                   Result = colDef(width=100, cell = function(value) {
#                     if (value == "Error") "\u274c Error" else paste0("\u2714\ufe0f", value)
#                   }),
#                   Site = colDef(width=70),
#                   Value = colDef(width=100),
#                   Table = colDef(width=150),
#                   Field = colDef(width=150),
#                   RecNum = colDef(width=40),
#                   RecSnum = colDef(width=40)
#                   #Issue = colDef(width=20)
#                 ),
#                 outlined = TRUE,
#                 wrap = FALSE,
#                 width=1200
#       )
#     return(r)    
# }


getSiteSummaryInfo <- function(con, keys, configName=''){
  
  
  ol <- list()
  
  if(configName=='NSMP'){
    sdf <- OS$DB$SiteSummaryQueries$getSitesInfo_NSMP(con$Connection, agencyCode = keys$AgencyCode, projectCode = keys$ProjectCode, token=keys$Token)
    pps <- OS$DB$SiteSummaryQueries$getNSMPPotentialSites(con$Connection, keys)
    hors <- OS$DB$SiteSummaryQueries$getHorizonInfo_NSMP(con$Connection, agencyCode = keys$AgencyCode, projectCode = keys$ProjectCode, token=keys$Token)
    }else{
    sdf <- OS$DB$SiteSummaryQueries$GetSitesInfo(con$Connection, agencyCode = keys$AgencyCode, projectCode = keys$ProjectCode)
  }
 
 
  ol$ConfigName <- configName
  ol$AgencyCode <- keys$AgencyCode
  ol$ProjectCode <- keys$ProjectCode
  ol$NumberOfSites <- nrow(sdf)
  ol$DataTable <- sdf
  ol$Horizons <- hors
  
  if(configName=='NSMP'){
    ol$NSMP_ProposedSites <- pps
  }
  return(ol)
}

renderSiteSummary <- function(si){
  
 #df <-  OS$DB$NatSoilQueries$getSitesForAProject(con$Connection, agencyCode = keys$AgencyCode, projectCode = keys$ProjectCode)
 
 mindate <- min(as.Date(unique(si$DataTable$o_date_desc)))
 maxdate <- max(as.Date(unique(si$DataTable$o_date_desc)))
 minslope <- min(as.numeric(si$DataTable$s_slope))
 maxslope <- max(as.numeric(si$DataTable$s_slope))
 
 minX <- min(as.numeric(si$DataTable$o_longitude_GDA94))
 maxX <- max(as.numeric(si$DataTable$o_longitude_GDA94))
 minY <- min(as.numeric(si$DataTable$o_latitude_GDA94))
 maxY <- max(as.numeric(si$DataTable$o_latitude_GDA94))
 
 elemTypes <- paste0(unique(si$DataTable$s_elem_type), collapse = '; ')
 patTypes <- paste0(unique(si$DataTable$s_patt_type), collapse = '; ')
 descBy <- paste0(unique(si$DataTable$o_desc_by), collapse = '; ')
 ASC <-  paste0(unique(si$DataTable$o_asc_ord), collapse = '; ')
 
 
 c1W <- '120px'
 c2W <- '150px'
 c3W <- '20px'
 c4W <- '120px'
 c5W <- '150px'
 
  ot <- '<h2 style="color:blue">Site Summary</h2>'
  ot <- paste0(ot, 
               '<table style="width:1500px;  border-spacing: 100px;" >
            <tr><td style="width:', c1W, '"><b>Number of sites : </b></td>
                <td align ="left", style="width:', c2W, '">', si$NumberOfSites, '</td>
                <td style="width:', c3W, '"></td>',
               '<td style="width:', c4W, '"><b>Date range : </b></td>
               <td align ="left, style="width:', c5W, '" ">', mindate, ' to ', maxdate, '</td>
            </tr>
               
                <tr><td style="width:', c1W, '"><b>Longitude range : </b></td>
                <td align ="left", style="width:', c2W, '">', minX, ' to ', maxX,  '</td>
                <td style="width:', c3W, '"></td>',
               '<td style="width:', c4W, '"><b>Latitude range : </b></td>
               <td align ="left, style="width:', c5W, '" ">', minY, ' to ', maxY, '</td>
            </tr></table>',
               
               
                '<p><b>Described By : </b>', descBy, '</p>',
               # '<p><b>Longitude range : </b>', minX, ' to ', maxX, '</p>',
               # '<p><b>Latitude range : </b>', minY, ' to ', maxY, '</p>',
                '<p><b>Element Types : </b>', elemTypes, '</p>',
                '<p><b>Pattern Types : </b>', patTypes, '</p>',
                '<p><b>ASCs : </b>', ASC, '</p>'
               
               
               
               
               
               
  )
  # 
  # if(outcomes$ErrorCount ==0){
  #   ot <- paste0(ot, '<p style="color:green">There are no errors in the data that we could find. You are good to load this dataset into the database.</p>' )
  # }else{
  #   ot <- paste0(ot, '<p style="color:red">There are some errors in the dataset you have uploaded. 
  #                   Please fix these errors in the Excel spreadsheet before trying to upload the data again.</p>' )
  # }
  
  paste0(ot)
}



renderSiteSummaryMap<- function(si){
  
  
 # df <-  OS$DB$NatSoilQueries$getSitesForAProject(con$Connection, agencyCode = keys$AgencyCode, projectCode = keys$ProjectCode)
  
  df <- si$DataTable
  
  sfdf <- st_as_sf( df, coords = c("o_longitude_GDA94", "o_latitude_GDA94"), crs = 4326)
  b <- st_bbox(sfdf)
  
  if(nrow(df) == 1){
    
    b$xmin <-  b$xmin - 0.01
    b$xymin <-  b$ymin - 0.01
    b$ymax <-  b$ymax + 0.01
    b$xmax <-  b$xmax + 0.01
    
  }
  

  icons <- awesomeIcons(
    icon = 'ios-close',
    iconColor = 'blue',
    library = 'ion'
    #markerColor = getColor(sfdf)
  )
  
  leaflet() %>%
    clearMarkers() %>%
    addTiles(group = "Map") %>%
    addProviderTiles("Esri.WorldImagery", options = providerTileOptions(noWrap = F), group = "Satellite") %>%
    addMouseCoordinates()  %>%
    addEasyButton(easyButton(
      icon="fa-globe", title="Zoom to full extent",
      onClick=JS("function(btn, map){ map.setView({lon: 135, lat: -28}, 3); }"))) %>%
    addLayersControl(
      baseGroups = c("Map", "Satellite"),
      options = layersControlOptions(collapsed = FALSE)   
    ) %>%
    
    fitBounds(lng1 = as.numeric(b$xmin), lng2 = as.numeric(b$xmax), lat1 = as.numeric(b$ymin), lat2 = as.numeric(b$ymax)) %>%
    
   # addCircleMarkers( data=sfdf, radius=6, color = ~pal(Result)), stroke=FALSE, fillOpacity=1, group="locations")
    addAwesomeMarkers(data=sfdf, icon=icons, label=~as.character(s_id), layerId = ~as.character(s_id))
}


formatHorizonsSummaryTable <- function(si){
  
  df <- si$Horizons
  
  if(si$ConfigName == 'NSMP'){
    
    obsflds <- c("s_id", "o_date_desc", "o_desc_by", "o_latitude_GDA94", "o_longitude_GDA94", 
                 "o_type", "s_slope", "s_morph_type", 
                 "s_elem_type", "s_patt_type", "lu_code", "ps_soil_land_use", "ps_soil_class", 
                 "o_asc_ord", "o_asc_subord", "o_asc_gg", "o_asc_subg", "team_code", 
                 "sample_barcode_start", "o_notes", "s_notes" )
    
    hdf <- df[, c("s_id", "h_no", "h_upper_depth", "h_lower_depth", "h_desig_master", "h_texture", "h_texture_qual", 
                  "col_hue_val_chrom", "h_bound_distinct", "h_bound_shape", "crack_width", "cf_abun", "cf_size", "cf_shape", "cf_lith", "mott_abun", 
                  "mott_type", "mott_size", "mott_contrast", "seg_abun", "seg_nature", "seg_form", "seg_size", "cutan_type", "cutan_abun", 
                  "cutan_distinct", "pan_cementation", "pan_type", "pan_continuity", "pan_structure", "root_abun", "root_size", "strg_class", "h_ec", "h_salinity_depth", 
                  "h_dispersion")]
                  
        gcolList <- list(
          s_id = colDef(maxWidth = 60, name = "Site"),
          o_date_desc= colDef(maxWidth = 100, name = "Date"),
          o_desc_by = colDef(maxWidth = 60, name = "DescBy"),
          o_latitude_GDA94 = colDef(maxWidth = 100, name = "Lat"),
          o_longitude_GDA94 = colDef(maxWidth = 100, name = "Lon"),
          o_type = colDef(maxWidth = 40, name = "oType"),
          s_slope = colDef(maxWidth = 50, name = "Slp"),
          s_morph_type = colDef(maxWidth = 40, name = "MT"),
          s_elem_type = colDef(maxWidth = 50, name = "ET"),
          s_patt_type = colDef(maxWidth = 50, name = "PT"),
          lu_code = colDef(maxWidth = 100, name = "Luse"),
          ps_soil_land_use = colDef(maxWidth = 150, name = "Prop-Luse"),
          ps_soil_class = colDef(maxWidth = 120, name = "Prop-Soil"),
          
          
          o_asc_ord = colDef(maxWidth = 40, name = "ASC"),
          o_asc_subord = colDef(maxWidth = 40, name = "ASO"),
          o_asc_gg = colDef(maxWidth = 40, name = "AGg"),
          o_asc_subg = colDef(maxWidth = 40, name = "ASG"),
          
          team_code = colDef(maxWidth = 50, name = "Team"),
          sample_barcode_start = colDef(maxWidth = 90, name = "BarCode"),
          s_notes = colDef(maxWidth = 100, name = "S_Notes"),
          o_notes = colDef(maxWidth = 100, name = "O_Notes")
        ) 
  }else{
    
    obsflds <- c("s_id", "o_date_desc", "o_desc_by", "o_latitude_GDA94", "o_longitude_GDA94", 
                 "o_type", "s_slope", "s_morph_type", 
                 "s_elem_type", "s_patt_type", "lu_code",
                 "o_asc_ord", "o_asc_subord", "o_asc_gg", "o_asc_subg", 
                 "o_notes", "s_notes" )
    
    hdf <- df[, c("s_id", "h_no", "h_upper_depth", "h_lower_depth", "h_desig_master", "h_texture", "h_texture_qual", 
                  "col_hue_val_chrom", "h_bound_distinct", "h_bound_shape", "crack_width", "cf_abun", "cf_size", "cf_shape", "cf_lith", "mott_abun", 
                  "mott_type", "mott_size", "mott_contrast", "seg_abun", "seg_nature", "seg_form", "seg_size", "cutan_type", "cutan_abun", 
                  "cutan_distinct", "pan_cementation", "pan_type", "pan_continuity", "pan_structure", "root_abun", "root_size", "strg_class", "h_ec", "h_salinity_depth", 
                  "h_dispersion")]
                  
                  gcolList <- list(
                    s_id = colDef(maxWidth = 60, name = "Site"),
                    o_date_desc= colDef(maxWidth = 100, name = "Date"),
                    o_desc_by = colDef(maxWidth = 60, name = "DescBy"),
                    o_latitude_GDA94 = colDef(maxWidth = 100, name = "Lat"),
                    o_longitude_GDA94 = colDef(maxWidth = 100, name = "Lon"),
                    o_type = colDef(maxWidth = 40, name = "oType"),
                    s_slope = colDef(maxWidth = 50, name = "Slp"),
                    s_morph_type = colDef(maxWidth = 40, name = "MT"),
                    s_elem_type = colDef(maxWidth = 50, name = "ET"),
                    s_patt_type = colDef(maxWidth = 50, name = "PT"),
                    lu_code = colDef(maxWidth = 100, name = "Luse"),
                    
                    
                    o_asc_ord = colDef(maxWidth = 40, name = "ASC"),
                    o_asc_subord = colDef(maxWidth = 40, name = "ASO"),
                    o_asc_gg = colDef(maxWidth = 40, name = "AGg"),
                    o_asc_subg = colDef(maxWidth = 40, name = "ASG"),
                    s_notes = colDef(maxWidth = 100, name = "S_Notes"),
                    o_notes = colDef(maxWidth = 100, name = "O_Notes")
                  ) 
  }
  
  
  data <- unique(df[, obsflds])
  


  
rt <-  reactable(data, compact = TRUE, defaultPageSize = 20,showPagination = T, showPageInfo = T, sortable = T, 
            resizable = TRUE, 
            width = 1700,
            striped = TRUE,
            highlight = TRUE,
            bordered = TRUE,
            theme = reactableTheme(
              borderColor = "#dfe2e5",
              stripedColor = "#f6f8fa",
              highlightColor = "#aed6f1",
              cellPadding = "0px 0px",
              style = list(fontFamily = "-apple-system, BlinkMacSystemFont, Segoe UI, Helvetica, Arial, sans-serif")
            ),    
            
            
            defaultColDef = colDef(
              align = "right",
              headerStyle = list()
            ),
            
            
         
            
            columns = gcolList ,
            
            details = function(index) {
              hor_data <- hdf[hdf$s_id == data$s_id[index], ]
              htmltools::div(style = "padding: 1rem",
                             reactable(hor_data, outlined = TRUE, resizable = TRUE, width = 1500,
                                       striped = TRUE,
                                       highlight = TRUE,
                                       bordered = TRUE,
                                       theme = reactableTheme(
                                         borderColor = "#dfe2e5",
                                         stripedColor = "#f6f8fa",
                                         highlightColor = "#aed6f1",
                                         cellPadding = "0px 0px",
                                         style = list(fontFamily = "-apple-system, BlinkMacSystemFont, Segoe UI, Helvetica, Arial, sans-serif")
                                       ),    
                                       
                                       columns = list(
                                         s_id = colDef(maxWidth = 60, name = "Site"),
                                         h_no = colDef(maxWidth = 30, name = "h_no"),
                                         h_desig_master = colDef(maxWidth = 40, name = "HDes"),
                                         h_upper_depth = colDef(maxWidth = 50, name = "UDep", format = colFormat(digits = 2)),
                                         h_lower_depth = colDef(maxWidth = 50, name = "LDep", format = colFormat(digits = 2)),
                                         h_texture = colDef(maxWidth = 70, name = "Texture"),
                                         h_texture_qual = colDef(maxWidth = 30, name = "Qual"),
                                         col_hue_val_chrom = colDef(maxWidth = 70, name = "Colour"),
                                         h_bound_distinct = colDef(maxWidth = 30, name = "BDis"),
                                         h_bound_shape = colDef(maxWidth = 30, name = "BShp"),
                                         
                                         crack_width = colDef(maxWidth = 30, name = "CrW"),
                                         
                                         cf_abun = colDef(maxWidth = 30, name = "cfA"),
                                         cf_size = colDef(maxWidth = 30, name = "cfS"),
                                         cf_shape = colDef(maxWidth = 30, name = "cfsh"),
                                         cf_lith= colDef(maxWidth = 40, name = "cfL"),
                                         
                                         
                                         mott_abun = colDef(maxWidth = 30, name = "motA"),
                                         mott_type = colDef(maxWidth = 30, name = "motT"),
                                         mott_size = colDef(maxWidth = 30, name = "motS"),
                                         mott_contrast = colDef(maxWidth = 30, name = "motC"),
                                         
                                         seg_abun = colDef(maxWidth = 30, name = "SegA"),
                                         seg_nature = colDef(maxWidth = 30, name = "SegN"),
                                         seg_form = colDef(maxWidth = 30, name = "SegF"),
                                         seg_size = colDef(maxWidth = 30, name = "SegS"),
                                         
                                         cutan_type = colDef(maxWidth = 30, name = "CutT"),
                                         cutan_abun = colDef(maxWidth = 30, name = "CutA"),
                                         cutan_distinct = colDef(maxWidth = 30, name = "CutD"),
                                         
                                         pan_cementation = colDef(maxWidth = 30, name = "PanCe"),
                                         pan_type = colDef(maxWidth = 30, name = "PanT"),
                                         pan_continuity = colDef(maxWidth = 30, name = "PanCt"),
                                         pan_structure = colDef(maxWidth = 30, name = "PanS"),
                                         
                                         root_abun = colDef(maxWidth = 30, name = "RootA"),
                                         root_size = colDef(maxWidth = 30, name = "RootS"),
                                         
                                         strg_class = colDef(maxWidth = 30, name = "Stg"),
                                         
                                         h_ec = colDef(maxWidth = 50, name = "EC"),
                                         h_salinity_depth = colDef(maxWidth = 50, name = "TestDep"),
                                         h_dispersion = colDef(maxWidth = 50, name = "Disp")
                                       )
                             )
              )
            })

return(rt)
  
}


