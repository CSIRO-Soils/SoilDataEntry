################################################################# #
#####       Author : Ross Searle                              ###
#####       Date :  Thu Feb  6 10:29:44 2025                  ###
#####       Purpose : Renders validation outcomes on the page ###
#####       Comments :                                        ###
################################################################# #




getValidationResultsReactTable <- function(vTab){
  
    r <-  reactable(vTab, defaultPageSize = 15, filterable = TRUE, 
                columns = list(
                  Result = colDef(width=100, cell = function(value) {
                    if (value == "Error") "\u274c Error" else paste0("\u2714\ufe0f", value)
                  }),
                  Site = colDef(width=70),
                  Value = colDef(width=100),
                  Table = colDef(width=150),
                  Field = colDef(width=150),
                  RecNum = colDef(width=40),
                  RecSnum = colDef(width=40)
                  #Issue = colDef(width=20)
                ),
                outlined = TRUE,
                wrap = FALSE,
                width=1200
      )
    return(r)    
}


renderDataValidationOutcomes <- function(outcomes){
  
  if(outcomes$Type=='Validation'){
  
          df <- outcomes$validationResultsTable
          if(nrow(df) > 0){
            df2 <- df[df$Result=='Error',]
            if(nrow(df2) > 0 ){
              siteerrors <- nrow(df2)
            }else{
              siteerrors = 0
            }
          }else{
            siteerrors = 0
          }
          
          ot <- '<h3>Validation Results</h3>'
          ot <- paste0(ot, '<p>Number of Sheets : ', outcomes$NumSheets,
                       '</p><p>Number of Sites with Data: ', outcomes$sheetsWithData,
                       '</p><p>Total Number of Errors : ',  outcomes$ErrorCount,
                       '</p><p>Number of Sites with Errors : ', outcomes$SitesWithErrorCnt,
                       '</p>'
          )
          
          if(outcomes$ErrorCount ==0){
            ot <- paste0(ot, '<p style="color:green">There are no errors in the data that we could find. You are good to load this dataset into the database.</p>' )
          }else{
            ot <- paste0(ot, '<p style="color:red">There are some errors in the dataset you have uploaded. 
                            Please fix these errors in the Excel spreadsheet before trying to upload the data again.</p>' )
            
          }
          
          return(paste0(ot))
          
  }else{

   return( outcomes$html)
  }
}



renderDataValidationOutcomesSiteMap<- function(outcomes){
  
  sfdf <- st_as_sf( outcomes$Sites, coords = c("x", "y"), crs = 4326)
  b <- st_bbox(sfdf)
 
   expand = 1
  b$xmin <-  b$xmin - expand
  b$xymin <-  b$ymin - expand
  b$ymax <-  b$ymax + expand
  b$xmax <-  b$xmax + expand
  
  getColor <- function(sfdf) {
    sapply(sfdf$ErrorCnt, function(ErrorCnt) {
      if(ErrorCnt > 0) {
        "red"
      } else {
        "green"
      } })
  }
  
  icons <- awesomeIcons(
    icon = 'ios-close',
    iconColor = 'black',
    library = 'ion',
    markerColor = getColor(sfdf)
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
    addAwesomeMarkers(data=sfdf, icon=icons, label=~as.character(sitename), layerId = ~as.character(sitename))
}

