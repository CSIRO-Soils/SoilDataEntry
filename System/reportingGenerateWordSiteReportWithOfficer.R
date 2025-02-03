

bold_face <- officer::shortcuts$fp_bold(font.size = 10)
bold_face12 <- officer::shortcuts$fp_bold(font.size = 12)


printableSiteReport <- function(con, RV, templatePath, outputPath, ProfPlotPath=NULL){

  

  labMeths <<- OS$DB$Helpers$doQuery(con=con, 'Select LABM_CODE, LABM_SHORT_NAME from LAB_METHODS')

  print("Finished lab methods")
  
doc <- read_docx(templatePath)

bmks <- doc %>% docx_bookmarks()
idxs <- match(c("ProfilePlot"), bmks)
bmks <- bmks[-idxs]

if(!is.null( ProfPlotPath)){
  body_replace_img_at_bkm(doc, bookmark='ProfilePlot', value = external_img(src = ProfPlotPath, width=1, height=4))
}else{
  body_replace_text_at_bkm(doc, bookmark='ProfilePlot', value='')
}



for (i  in 1:length(bmks)) {
  nme <- bmks[i]
  body_replace_text_at_bkm(doc, bookmark=nme, value=as.character(RV$SiteData[nme]))
}

for (i in 1:length(RV$HorizonText)) {
  cursor_end(doc)
   fpar_1 <- fpar(
     ftext( RV$HorizonText[[i]]$Desig, prop = bold_face ),
     paste0( '\t',  RV$HorizonText[[i]]$Depths, '- ',  RV$HorizonText[[i]]$Description,  '\r\n')
     )
  doc <- body_add_fpar(doc, fpar_1, pos = "after")
  doc <-  body_add_par(doc, "",pos = "after")
}


if(nrow(RV$LabData) > 0){
  fpar_Lab <- fpar(
    ftext( 'Lab Results', prop = bold_face12 )
  )
  doc <- body_add_fpar(doc, fpar_Lab, pos = "after")
  doc <-  body_add_par(doc, "",pos = "after")
  
    bt <- generateBlankTable(dfDenorm=RV$LabData, field='labm_code', upperD='samp_upper_depth', lowerD='samp_lower_depth')
    labs <- populateTable(blankTable=bt, dfDenorm=RV$LabData, field='labm_code', decode=F)
    
    ons <- colnames(labs[,-c(1:2)])
    idxs <- match(ons, labMeths$LABM_CODE)
    newnames <- labMeths[idxs, ]$LABM_SHORT_NAME
    newnames <- make.unique(newnames)
    colnames(labs) <- c('Upper Depth', 'Lower Depth', newnames)
    hhgt <- max(nchar(colnames(labs))) / 16
    
    
     ft_lab <- flextable(labs, cwidth = 0.35) %>% fontsize( size = 8, part = 'all') %>% 
       flextable::padding(padding.top = 1, part = "all") %>%
       flextable::padding(padding.bottom = 1, part = "all") %>%
       flextable::padding(padding.left = 1, part = "all") %>%
       flextable::padding(padding.right = 1, part = "all") %>%
       rotate( align = "bottom", rotation = "btlr", part = "header") %>%
       height(height = hhgt, part = "header") %>%
       hrule(i = 1, rule = "exact", part = "header") 
       
     doc <- body_add_flextable( doc, ft_lab )
}

footers_replace_all_text(doc, old_value = 'Footer',  new_value=paste0('Soil data extracted from the CSIRO NatSoil database on ', format(Sys.Date(), format = "%A %d %B %Y"))
)

print(doc, target=outputPath)

return(outputPath)
}


