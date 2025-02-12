
PublishSites_formatTable <- function(df, type){
  
  
  colList <- list(
    .selection = colDef(headerStyle = list(pointerEvents = "none")),
    ps_token = colDef(show = FALSE),
    agency_code = colDef(show = FALSE),
    proj_code = colDef(show = FALSE),
    o_id = colDef(show = FALSE),
    PublishedSite = colDef(show = FALSE),
    s_id = colDef(name = "Site ID"),
    o_desc_by= colDef(name = "Desc By"),
    o_date_desc = colDef(name = "Date Desc"),
    o_latitude_GDA94 = colDef(name = "Latitude"),
    o_longitude_GDA94 = colDef(name = "Longitude"),
    s_slope = colDef(name = "Slope"),
    s_morph_type = colDef(name = "Morph Type"),
    s_elem_type = colDef(name = "Elem Type"),
    s_patt_type= colDef(name = "Patt Type"),
    s_date_desc = colDef(show = FALSE),
    lu_code = colDef(name = "Land Use"),
    ps_soil_class = colDef(name = "Prop Soil"),
    ps_soil_land_use = colDef(name = "Prop Use", minWidth =150),
    o_type = colDef(name = "Obs Type"),
    o_asc_ord = colDef(name = "ASC Ord"),
    o_asc_subord = colDef(name = "Sub Ord"),
    o_asc_gg = colDef(name = "Great Grp"),
    o_asc_subg = colDef(name = "Sub Grp"),
    o_notes = colDef(minWidth = 600),
    s_notes = colDef(minWidth = 600)
  )
  
  
  if(type=='Draft'){ 
    seltype='multiple'
  
  } else{
    seltype=NULL
    colList <- colList[-1]
  }
 
  
  ot <-  reactable(
      df,
      compact = TRUE, defaultPageSize = 20,showPagination = T, showPageInfo = T, sortable = T,
      
      striped = TRUE,
      highlight = TRUE,
      bordered = TRUE,
      style = list(maxWidth = 10000),
      selection = seltype,
      columns = colList,
      theme = reactableTheme(
        headerStyle = list("& input[type='checkbox']" = list(display = "none")),
        borderColor = "#dfe2e5",
        stripedColor = "#f6f8fa",
        highlightColor = "#aed6f1",
        cellPadding = "0px 0px",
        style = list(fontFamily = "-apple-system, BlinkMacSystemFont, Segoe UI, Helvetica, Arial, sans-serif")
      )
    )

  return(ot)
}




PublishSites_formatToDoTable <- function(con, keys){
  
  df <- OS$PublishSitesToNatSoil$getToDoSites(con, keys)
  
  colList <- list(
   
    HoldingSites = colDef(show = FALSE),
    agency_code = colDef(show = FALSE),
    proj_code = colDef(show = FALSE),
    ps_token = colDef(show = FALSE),
    s_id = colDef(name = "Site ID"),

    ps_latitude_GDA94 = colDef(name = "Latitude"),
    ps_longitude_GDA94 = colDef(name = "Longitude"),
    ps_description = colDef(name = "PS Desc"),
    lu_code = colDef(name = "Land Use"),
    ps_soil_class = colDef(name = "PS Soil Type"),
    ps_soil_land_use= colDef(name = "PS Land Use"),
    ps_soil_color = colDef(name = "PS Colour")
    
  )
  
  
  ot <-  reactable(
    df,
    compact = TRUE, defaultPageSize = 20,showPagination = T, showPageInfo = T, sortable = T,
    
    striped = TRUE,
    highlight = TRUE,
    bordered = TRUE,
    style = list(maxWidth = 1200),
    selection = NULL,
    columns = colList,
    theme = reactableTheme(
      headerStyle = list("& input[type='checkbox']" = list(display = "none")),
      borderColor = "#dfe2e5",
      stripedColor = "#f6f8fa",
      highlightColor = "#aed6f1",
      cellPadding = "0px 0px",
      style = list(fontFamily = "-apple-system, BlinkMacSystemFont, Segoe UI, Helvetica, Arial, sans-serif")
    )
  )
  
  return(ot)
}



publishSitesToNatsoil <- function(selectedDraftRows, authPerson){
  
  con <- OS$DB$Config$getCon(OS$DB$Config$DBNames$NatSoilStageRO)$Connection
  sql <- paste0("select * from Officers where offr_name ='", authPerson, "'")
  df <- OS$DB$Helpers$doQuery(con, sql)
  officerCode <- df$offr_code[1]
  dbDisconnect(con)
  
  
  selRowsDF <- selectedDraftRows
  
  appCon <- OS$DB$Config$getCon(OS$DB$Config$DBNames$AppDB)$Connection
  natSoilCon <- OS$DB$Config$getCon(OS$DB$Config$DBNames$NatSoilDev)$Connection
  holdCon <- OS$DB$Config$getCon(OS$DB$Config$DBNames$NSMP_HoldingRW)$Connection
  
  sql <- 'Select * from NatSoil_TableLevels order by Level'
  tables <- OS$DB$Helpers$doQuery(appCon, sql)
  
  for (i in 1:nrow(selRowsDF)) {
    rec <- selRowsDF[i,]
    ac <-  rec$agency_code
    pc <-  rec$proj_code
    sid <- rec$s_id
    oid=1
    print(paste0('Adding site sid'))
    
    OS$DB$Helpers$deleteWholeSite(natSoilCon, verbose=T, agencyCode = ac, projCode = pc, siteID=sid, obsNo=NULL)
    
    for (j in 1:nrow(tables)) {
      t <- tables[j,]$Table
      if(t %in% c('SITES', 'ELEM_GEOMORPHS', 'LAND_COVER', 'LAND_USES', 'PATT_GEOMORPHS', 'DISTURBANCES')){
        sql <- paste0("Select * from ", t, " WHERE agency_code = '", ac, "' and proj_code='", pc, "' and s_id = '", sid, "'" )
      }else{
        sql <- paste0("Select * from ", t, " WHERE agency_code = '", ac, "' and proj_code='", pc, "' and s_id = '", sid, "' and o_id=1" )
      }
      
      dt <- OS$DB$Helpers$doQuery(holdCon, sql)
      if(j==1){
        dt <- dt[,-c(44)]
      }
      
      if(j==2){
        dt <- dt[,-c(116:118)]
      }

      if(nrow(dt)>0){
        dbWriteTable(natSoilCon, t, dt, append=T )
      }
    }
    
    dt <- str_remove_all(Sys.Date(), '-')
    sql <- paste0("Insert Into PublishedSites values('", ac, "', '", pc, "', '", sid, "', '", dt, "', '", officerCode ,"' )")
    OS$DB$Helpers$doInsertUsingRawSQL(holdCon, sql)
    
  }


}





