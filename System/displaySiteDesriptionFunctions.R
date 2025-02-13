

getProjectDescriptionHTML <- function(p){
  
  ### Insert url for reference 
  s <- p$proj_biblio_ref
  loc <- str_locate(s, 'http')
  if(!is.na(loc[1,1])){
    url <- url <- str_sub(s, loc[1,1], nchar(s))
    lhtml <- paste0('<a href="', url, '", target="_blank" ><b> Show Document </b></a>')
  }else{
    lhtml <- ''
  }
  
  phtml <- paste0('<P><B>Project Name : </B>', ifelse(is.na(p$proj_name), "", p$proj_name), '</P>', 
                  '<P><B>Project Code : </B>', ifelse(is.na(p$proj_code), "", p$proj_code) , '</P>', 
                  '<P><B>Agency Name : </B>', ifelse(is.na(p$Agency), "", p$Agency) , ' (', p$AgencyCode, ')</P>', 
                  '<P><B>Project Manager : </B>', ifelse(is.na(p$Manager), "", p$Manager) , '</P>', 
                  '<P><B>Project Describers : </B>', ifelse(is.na(p$describers), "", p$describers) , '</P>', 
                  '<P><B>Project Start : </B>', ifelse(is.na(p$proj_start_date), "", p$proj_start_date) , '</P>', 
                  '<P><B>Observations Date Range : </B>', ifelse(is.na(p$observations_start_date), "", p$observations_start_date) , 
                                                '  to ', ifelse(is.na(p$observations_end_date), "", p$observations_end_date) , '</P>', 
                  '<P><B>No. Sites : </B>', ifelse(is.na(p$sites), "", p$sites) , '</P>', 
                  '<P><B>No Specimens : </B>', ifelse(is.na( p$Specimens), "",  p$Specimens), '</P>',
                  '<P><B>No Lab Results : </B>',  ifelse(is.na( p$LabTotal), "0",  p$LabTotal) , ' (Chem/Phys/MIR/MIN) : ', 
                  '(', ifelse(is.na( p$CHEM), "0",  p$CHEM) , ' / ',ifelse(is.na( p$PHYS), "0",p$PHYS) , ' / ',
                       ifelse(is.na( p$MIR), "0",  p$MIR) , ' / ', ifelse(is.na( p$MIN), "0",  p$MIN), ')', '</P>',
                 # '<BR>'
                  '<P><B>Publication : </B>', ifelse(is.na( p$proj_biblio_ref), "", p$proj_biblio_ref)  , lhtml, '</P>'
                  )
  oh <- paste0(phtml)
  
  return(oh)
}







getSiteDescription <- function(con, agencyCode, projectCode, siteID, obsID){
  
 ol<-list()
 

agencyInfo <- OS$DB$NatSoilQueries$getAgencyInfo(con, agencyCode = agencyCode)[1,]
projectInfo <- OS$DB$NatSoilQueries$getProjectInfo(con, agencyCode = agencyCode, projectCode=projectCode)[1,]
locationInfo <- OS$DB$NatSoilQueries$getLocationInfo(con, agencyCode = agencyCode, projectCode=projectCode, siteID=siteID, obsID=obsID)[1,]
siteInfo <- OS$DB$NatSoilQueries$getSiteInfo(con, agencyCode = agencyCode, projectCode=projectCode, siteID=siteID, obsID=obsID)[1,]
microInfo <- OS$DB$NatSoilQueries$getLevel3Info(con, table='MICRORELIEFS', agencyCode = agencyCode, projectCode=projectCode, siteID=siteID, obsID=obsID)
vegInfo <- OS$DB$NatSoilQueries$getLevel3Info(con, table='VEG_SPECIES', agencyCode = agencyCode, projectCode=projectCode, siteID=siteID, obsID=obsID)
SCFInfo <- OS$DB$NatSoilQueries$getLevel3Info(con, table='SURF_COARSE_FRAGS', agencyCode = agencyCode, projectCode=projectCode, siteID=siteID, obsID=obsID)
distInfo <-  OS$DB$NatSoilQueries$getLevel3Info(con, table='DISTURBANCES', agencyCode = agencyCode, projectCode=projectCode, siteID=siteID, obsID=obsID)
SurfCondInfo <-  OS$DB$NatSoilQueries$getLevel3Info(con, table='SURF_CONDITIONS', agencyCode = agencyCode, projectCode=projectCode, siteID=siteID, obsID=obsID)
RockOutcropInfo <-  OS$DB$NatSoilQueries$getLevel3Info(con, table='ROCK_OUTCROPS', agencyCode = agencyCode, projectCode=projectCode, siteID=siteID, obsID=obsID)
# snotes <- getSiteNotes(con, agencyCode = agencyCode, projectCode=projectCode, siteID=siteID)
# onotes <- getObsNotes(con, agencyCode = agencyCode, projectCode=projectCode, siteID=siteID, obsID=obsID)
horizonInfo <- OS$DB$NatSoilQueries$getHorizons(con, agencyCode = agencyCode, projectCode=projectCode, siteID=siteID, obsID=obsID)


agencyC <- agencyInfo$AGENCY_CODE
projC <- projectInfo$proj_code
locT <- paste0(locationInfo$o_longitude_GDA94, ' E.   ', locationInfo$o_latitude_GDA94, ' N.')

html <- paste0('<BR><table>
                 <colgroup>
                   <col span="1" style="width: 500px;">
                   <col span="1" style="width: 500px;">
                </colgroup><tbody>
                 <tr><td><b>Profile ID: </b>', siteID, '</td>')

ol$AgencyCode <- paste0( agencyC)
ol$ProjectCode <- paste0( projC)
ol$SiteID <- siteID
ol$ObsID <- obsID
ol$ProfileID <- paste0( agencyC, '_', projC , '_', siteID, '_',obsID)




html <- paste0(html, '<td><b>Location: </b>', locT, '</td></tr>')
ol$Location <- locT

an <- paste0(agencyInfo$AGENCY_CODE, ' : ', agencyInfo$AGENCY_NAME )
ol$AgencyName <- an
pn <- paste0(projectInfo$proj_code, ' : ', projectInfo$proj_name )
ol$ProjectName <- pn

html <- paste0(html, '<tr><td><b>Agency: </b>', an, '</td>')
html <- paste0(html, '<td><b>Project: </b>', pn, '</td></tr>')

person <- getVals(table=siteInfo, attribute='s_desc_by', domain = 'C_S_DESC_BY')
if(person=='' | is.na(person)){
person <- getVals(table=siteInfo, attribute='o_desc_by', domain = 'C_S_DESC_BY')
}
ol$Person <- person
html <- paste0(html, '<tr><td><b>Described By: </b>', person, '</td>')
dt <- getVals(table=siteInfo,  attribute='s_date_desc')
if(dt=='' | is.na(dt)){
  dt <- getVals(table=siteInfo,  attribute='o_date_desc')
}

html <- paste0(html, '<td><b>Date Described: </b>', dt, '</td></tr>')
ol$DateDesc <- as.character(dt)

aOrd <- getVals( table=siteInfo, attribute='o_asc_ord', domain = 'C_O_ASC_ORD')
aSubOrd <- getVals( siteInfo, 'o_asc_subord', 'C_O_ASC')
agrp <- getVals(siteInfo, 'o_asc_gg', 'C_O_ASC')
asubgrp <- getVals( siteInfo, 'o_asc_subg', 'C_O_ASC')
html <- paste0(html, '<tr><td><b>Aust Soil Classification: </b>', asubgrp, ' ',agrp, ' ', aSubOrd, ' ', aOrd, '</td>')
ol$ASC <- paste0(asubgrp, ' ',agrp, ' ', aSubOrd, ' ', aOrd)
gsg <- getVals(table=siteInfo, 'o_gsg', 'C_O_GSG')
html <- paste0(html, '<td><b>Great Soil Group: </b>', gsg , '</td></tr>')
ol$GSG <- gsg
ppf <- getVals(table=siteInfo, 'o_ppf')
html <- paste0(html, '<tr><td><b>Principal Profile Form: </b>', ppf, '</td>')
ol$PPF <- ppf
dist <-  getVals(table=distInfo, 'dist_type', 'C_DIST_TYPE')
html <- paste0(html, '<td><b>Disturbance: </b>',dist, '</td></tr>')
ol$Disturbance <- dist
lpat <- getVals(table=siteInfo, 's_patt_type', 'C_S_PATT_TYPE')
html <- paste0(html, '<td><b>Landform Pattern: </b>', lpat, '</td>')
ol$LandformPattern <- lpat
lelem <- getVals(table=siteInfo, 's_elem_type', 'C_S_ELEM_TYPE')
html <- paste0(html, '<td><b>Landform Element: </b>', lelem, '</td></tr>')
ol$LandformElement <- lelem
mtype <- getVals(table=siteInfo, 's_morph_type', 'C_S_MORPH_TYPE')
html <- paste0(html, '<td><b>Morphological Type: </b>', mtype, '</td>')
ol$MorpholgicalType = mtype
modSlope <- getVals(table=siteInfo, 's_rel_ms_class', 'C_S_REL_MS_CLASS')
html <- paste0(html, '<td><b>Relief Modal Slope: </b>', modSlope, '</td></tr>')
ol$ModalSlope <- modSlope
slpClass <- getVals(table=siteInfo, 's_slope_class', 'C_S_SLOPE_CLASS')
html <- paste0(html, '<td><b>Slope Class: </b>',slpClass , '</td>')
ol$SlopeClass <- slpClass

slp <- getVals(table=siteInfo, 's_slope')
if(slp!=''){slp <- round(as.numeric(slp), digits = 0)}
html <- paste0(html, '<td><b>Slope: </b>', slp, ' % </td></tr>')
ol$Slope <- paste0(slp, ' % ')

veg=getVals(table=vegInfo, attribute = 'vsp_code', domain = 'C_VSP_CODE')
ol$Veg <- veg

mr_type <- getVals(table=microInfo, 'mr_type')
mr_hint <- getVals(table=microInfo, 'mr_horiz_int')
mr_vint <- getVals(table=microInfo, 'mr_vertical_int')
mr <- paste0(mr_type, ' ',mr_hint, ' ',mr_vint)
if (!grepl("^\\s*$", mr)){ omr<- paste0(mr)  }else {omr<- ''}

html <- paste0(html, '<td><b>Veg Species: </b>', veg, '</td>')
html <- paste0(html, '<td><b>Microrelief: </b>',  mr , '</td></tr>')
ol$MicroRelief <- mr

scf_abun <- getVals(SCFInfo, 'scf_abun', 'N_CF_ABUN')
scf_size <- getVals(SCFInfo, 'scf_size', 'N_CF_SIZE')
scf_shape <- getVals(SCFInfo, 'scf_shape', 'C_CF_SHAPE')
scf_lith <- getVals(SCFInfo, 'scf_lith', 'C_LITHOLOGY')
scf <- paste0(scf_abun, ' ',scf_size, ' ',scf_shape, ' ', scf_lith)
if (!grepl("^\\s*$", scf)){ oscf<- paste0(scf)  }else {oscf<- ''}
ol$SurfCoarseFrags <- oscf




scon <- getVals(SurfCondInfo, 'scon_stat', 'C_SCON_STAT')
ol$SurfCon <- scon
 
 html <- paste0(html, '<td><b>Surface Coarse Fragments: </b>', oscf, '</td>')
 html <- paste0(html, '<td><b>Surface Condition: </b>',  scon , '</td></tr>')
 
 ro_abun <- getVals(RockOutcropInfo, 'ro_abun', 'N_RO_ABUN')
 ro_lith <- getVals(RockOutcropInfo, 'ro_lith', 'C_LITHOLOGY') 
 ro <- paste0(ro_abun, ' ',ro_lith)
 if (!grepl("^\\s*$", ro)){ oro <- paste0(ro)  }else {oro <- ''}
 html <- paste0(html, '<td><b>Rock Outcrop: </b>', oro, '</td>')
 html <- paste0(html, '<td><b> </b>',  '</td></tr>')
 ol$RockOutcrop <- oro
# 
# 
 n1 <- getVals(siteInfo, 'o_notes') 
 n2 <-  getVals(siteInfo, 's_notes') 
 html <- paste0(html, '<td colspan="2"><b>Notes: </b>',n1, ' - ', n2, '</td>')
ol$Notes <- paste0(n1, ' - ', n2)

 
 html <- paste0(html, '</tbody></table>')
 
 
 txt <- vector(mode = 'character', length = nrow(horizonInfo))
 
 
 htext<-vector(mode = 'list', length = nrow(horizonInfo))
 
for (i in 1:nrow(horizonInfo)) {
  
  o <- horizonInfo[i,]
  
  lname <- paste0('h', i)
  
  colourInfo <- OS$DB$NatSoilQueries$getLevel4Info(con, table='COLOURS', agencyCode = agencyCode, projectCode=projectCode, siteID=siteID, obsID=obsID, hnum=i)
  structureInfo <-  OS$DB$NatSoilQueries$getLevel4Info(con, table='STRUCTURES', agencyCode = agencyCode, projectCode=projectCode, siteID=siteID, obsID=obsID, hnum=i)
  phInfo <- OS$DB$NatSoilQueries$getLevel4Info(con, table='PHS', agencyCode = agencyCode, projectCode=projectCode, siteID=siteID, obsID=obsID, hnum=i)
  CFInfo <- OS$DB$NatSoilQueries$getLevel4Info(con, table='COARSE_FRAGS', agencyCode = agencyCode, projectCode=projectCode, siteID=siteID, obsID=obsID, hnum=i)
  segInfo <- OS$DB$NatSoilQueries$getLevel4Info(con, table='SEGREGATIONS', agencyCode = agencyCode, projectCode=projectCode, siteID=siteID, obsID=obsID, hnum=i)
  mottleInfo <- OS$DB$NatSoilQueries$getLevel4Info(con, table='MOTTLES', agencyCode = agencyCode, projectCode=projectCode, siteID=siteID, obsID=obsID, hnum=i)

  ph<-''
  bdy<-''
  hname <-''
  hstructure<-''
  tex<-''
  colcode=''

  hpref <- getVals(o, 'h_desig_num_pref')
  hname <- getVals(o, 'h_desig_master')
  hsubdiv <- getVals(o, 'h_desig_subdiv')
  hnsuf <- getVals(o, 'h_desig_suffix')
  hname <- paste0(hpref, hname, hsubdiv, hnsuf)
  rawDesig <- paste0(hpref, hname, hsubdiv, hnsuf)
  if (!grepl("^\\s*$", hname)){hname=paste0('<B>', hname, ' : </B>')}

  str_grade <- getVals(structureInfo, 'str_ped_grade', 'C_STR_PED_GRADE')
  str_size <- getVals(structureInfo, 'str_ped_size', 'N_STR_PED_SIZE')
  str_type <- getVals(structureInfo, 'str_ped_type', 'C_STR_PED_TYPE')
  hstructure <- paste0(str_grade, ' ', str_size, ' ', str_type)
  if (!grepl("^\\s*$", hstructure)){hstructure=paste0(hstructure, ' structure; ')}


   b_dist <- getVals(o, 'h_bound_distinct', 'N_H_BOUND_DISTINCT')
   if(b_dist!=''){bdy <- paste0(b_dist, ' change to')}

  col <-  getVals(colourInfo, 'col_hue_val_chrom', 'C_MUNSELL_COLOUR')
  colcode <-  getVals(colourInfo, 'col_hue_val_chrom')
  if(colcode!=''){colcode=paste0(' (', colcode, '); ')}

   tex <- getVals(o, 'h_texture', 'C_H_TEXTURE')
   if(tex!=''){tex=paste0(tex, '; ')}

  phVal <- getVals(phInfo, 'ph_value')
  if(phVal!=''){ph <- paste0('pH : ', round(as.numeric(getVals(phInfo, 'ph_value')), digits = 1), '; ')}

  # ec <- getVals(o, 'h_ec')
  # if(ec!=''){ph <- paste0('EC : ', ec, '; ')}

  # drain <- getVals(o, 'h_drainage', 'C_O_DRAINAGE')
  # if(drain!=''){ph <- paste0(drain, '; ')}
  # 
  # perm <- getVals(o, 'h_permeability', 'C_PERMEABILITY')
  # if(perm!=''){perm <- paste0(perm, '; ')}
  # 
  # # sw <- getVals(o, 'h_soil_water_stat')
  # # sticky <- getVals(o, 'h_stickiness')
  # # repel <- getVals(o, 'h_water_repellence')
  # 
  cf_abun <- getVals(CFInfo, 'cf_abun', 'N_CF_ABUN')
  cf_dist<- getVals(CFInfo, 'cf_distribution', 'C_CF_DISTRIBUTION')
  cf_shape <- getVals(CFInfo, 'cf_shape', 'C_CF_SHAPE')
  cf_size <-  getVals(CFInfo, 'cf_size', 'N_CF_SIZE')
  cf_lith <-  getVals(CFInfo, 'cf_lith', 'C_LITHOLOGY')
  cf <- paste0(cf_abun, ' ',cf_dist, ' ',cf_shape, ' ',cf_size, ' ',cf_lith )
  if (!grepl("^\\s*$", cf)){ ocf <- paste0(cf, ' coarse fragments; ')  }else {ocf<- ''}

  seg_abun <- getVals(segInfo, 'seg_abun', 'N_SEG_ABUN')
  seg_form<- getVals(segInfo, 'seg_form', 'C_SEG_FORM')
  seg_nat <- getVals(segInfo, 'seg_nature', 'C_SEG_NATURE')
  seg_size <-  getVals(segInfo, 'seg_size', 'N_SEG_SIZE')
  seg_strength <-  getVals(segInfo, 'seg_strength', 'C_SEG_STRENGTH')
  seg <- paste0(seg_abun, ' ',seg_nat, ' ', seg_form, ' ', seg_size, ' ',seg_strength )
  if (!grepl("^\\s*$", seg)){ oseg <- paste0(seg, ' segregations; ')  }else {oseg<- ''}

  mott_cont <- getVals(mottleInfo, 'mott_contrast', 'C_CONTRAST')
  mott_abun <- getVals(mottleInfo, 'mott_abun', 'N_MOTT_ABUN')
  mott_size<- getVals(mottleInfo, 'mott_size', 'N_MOTT_SIZE')
  mott_col <- getVals(mottleInfo, 'mott_hue_val_chrom', 'C_MOTT_COLOUR') #getVals(mottleInfo, 'mott_hue_val_chrom')
  #mott_col <- getVals(mottleInfo, 'mott_type', 'C_MOTT_TYPE') 
  mot <- paste0(mott_cont, ' ', mott_abun, ' ',mott_size, ' ', mott_col )
  if (!grepl("^\\s*$", mot)){ omot <- paste0(mot, ' mottles; ')  }else {omot<- ''}


  desc <- paste0(hname, ' ', col, colcode, tex, hstructure, ph, ocf, oseg, omot, ' ', bdy)
  #desc <- paste0(hname, ' ', col, colcode, tex, hstructure, ph, ec, ocf, oseg, omot, bdy)
  txt[[i]] <- paste0('<P>', desc, '</P>')
  
  hrl <- list()
  hrl$Desig <- rawDesig
  hrl$Depths <- paste0(as.integer(o$h_upper_depth * 100), ' cm to ', as.integer(o$h_lower_depth * 100), ' cm ')
  hrl$Description <- paste0( col, colcode, tex, hstructure, ph, ocf, oseg, omot, ' ', bdy)
  htext[[i]] <- hrl
 

}
  allhtml <- c(html,'<BR><BR>', txt)
  
  CurrentSiteLocation <- OS$DB$NatSoilQueries$getLocationInfo(con, agencyCode, projectCode, siteID, obsID)
  ProfPlotData <- OS$DB$NatSoilQueries$getColourHorizons(con, agencyCode, projectCode, siteID, obsID)
  labData <- OS$DB$NatSoilQueries$getLabData(con, agencyCode, projectCode, siteID, obsID)
  
  rl=list()
  rl$SiteData <- ol
  rl$HTML <- allhtml
  rl$HorizonData <- NULL
  rl$CurrentSiteLocation <- CurrentSiteLocation
  rl$ProfPlotData <- ProfPlotData
  rl$LabData <- labData
  rl$ProfilePlotPath <-  tempfile(pattern = 'ProfPlot_', fileext = '.png')
  rl$HorizonText <- htext
  

 return(rl) 

}








getVals<- function(table, attribute, domain=NULL){ #}, recNum=1){
  

  if(nrow(table)==0){return("")}
  
  if(attribute=='s_date_desc'){
    v <- table[attribute][1]
    return(format(v, format="%B %d %Y"))
  }
  
  oVal <- ''
  for(k in 1:nrow(table)){
  recNum=k

  v <- as.character(table[attribute][recNum,])
  if(is.null(v) | is.na(v) | length(v) ==0 ){
   # return('')
    ov = ''
  }else{
    if(is.null(domain)){
      if(v=='NULL'){
        #return('')
        ov= ''
      }else{
        #return(v)
        ov=v
      }
      
    }else{
      
      if(v=='NULL'){
        #return('')
        ov=''
      }
      
      cds <- codes[codes$CODE_DOMAIN==domain,]
      if(nrow(cds>0)){
        dec <- cds[cds$CODE_VALUE==v,]
        if(nrow(dec)==0){
          #return(v)
          ov <- ''
        }else{
          desc <- dec$CODE_DESC
          #return(desc)
          ov <- desc
        }
      }else{
        #return(v)
        ov <- v
      }
    }
  }
  
  if(ov!='')
    oVal <- paste0(oVal, ov, ', ')
  }
  
  oVal2 <- str_sub(oVal, 1, nchar(oVal)-2)
  
return(oVal2)
}





generateBlankTable <- function(dfDenorm, field, upperD, lowerD){
  
  cols <- unique(dfDenorm[field])
  
  depths <- unique(dfDenorm[c(upperD, lowerD)])
  df <- data.frame(ud=depths[,1], ld=depths[,2])
  df <- df[with(df, order(ud, ld)), ]
  
  for (i in 1:nrow(cols)) {
    c <- cols[i,1]
    df[c] <- rep('', nrow(df))
  }
  return(df)
}

populateTable <- function(blankTable, dfDenorm, field, decode=F){
  
  bt <- blankTable
  nt <- dfDenorm
  cols <- unique(nt[field])
  
#write.csv(nt, 'c:/temp/chem.csv')
  
   if(nrow(nt)==0)
   {return(data.frame())}
# 
  for (i in 1:nrow(bt)) {
    rec <- bt[i, ]
    ud <- rec$ud
    ld <- rec$ld
    for (j in 1:nrow(cols)) {
      att <- cols[j,1]
        v <- nt[nt$samp_upper_depth==ud & nt$samp_lower_depth==ld & nt$labm_code==att, ]$labr_value
        v <- as.numeric(v)
        vc <- paste(round(v, digits = 3), sep = " ", collapse = '; ')
        bt[i, ][att] <- vc
    }
  
  }
  return(bt)
}
