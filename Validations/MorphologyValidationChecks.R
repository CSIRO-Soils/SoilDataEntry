################################################################# #
#####       Author : Ross Searle                              ###
#####       Date :  Fri Feb 14 09:41:24 2025                  ###
#####       Purpose : Site data validation checks             ###
#####       Comments :                                        ###
################################################################# #




# fname = 'C:/Projects/SiteDataEntryTool/Validation Testing - NSMP - Burnie.xlsx'
# dataSheet <- openxlsx::readWorkbook(xlsxFile = fname, sheet='N2056', skipEmptyRows = F, skipEmptyCols = F)


CheckFieldTests <- function(dataSheet, sheetName, excelInfo, odf){
  
  sn=sheetName
  ECDepthsPos <- excelInfo[excelInfo$dbFld=='h_salinity_depth' & excelInfo$recSubNum ==1,]
  ECValsPos <- excelInfo[excelInfo$dbFld=='h_ec' & excelInfo$recSubNum ==1,]
  dispPos <- excelInfo[excelInfo$dbFld=='h_dispersion' & excelInfo$recSubNum ==1,]
  
  phDepthsPos <- excelInfo[excelInfo$dbFld=='ph_depth' & excelInfo$recSubNum ==1,]
  phValsPos <- excelInfo[excelInfo$dbFld=='ph_value' & excelInfo$recSubNum ==1,]
  
  ecd<- vector(mode = 'list', nrow(ECDepthsPos))
  ecv<- vector(mode = 'list', nrow(ECDepthsPos))
  dispv<- vector(mode = 'list', nrow(ECDepthsPos))
  
  for (i in 1:nrow(ECDepthsPos)) {
    row <- ECDepthsPos$row[i]
    col <- ECDepthsPos$col[i]
    ecd[[i]] <- dataSheet[row, col]
    ecv[[i]] <- dataSheet[row, col+1]
    dispv[[i]] <- dataSheet[row, col+2]
  }
  
  EC <- data.frame(Depth=unlist(ecd), EC=unlist(ecv))
  Disp <- data.frame(Depth=unlist(ecd), Disp=unlist(dispv))
  
  
  phd<- vector(mode = 'list', nrow(phDepthsPos))
  phv<- vector(mode = 'list', nrow(phDepthsPos))
  
  for (i in 1:nrow(phDepthsPos)) {
    row <- phDepthsPos$row[i]
    col <- phDepthsPos$col[i]
    phd[[i]] <- dataSheet[row, col]
    phv[[i]] <- dataSheet[row, col+1]
  }
  pH <- data.frame(Depth=unlist(phd), pH=unlist(phv))
  
  odf <- processFieldChecks(ft='h_ec', df=EC, odf, sn)
  odf <- processFieldChecks(ft='h_dispersion', df=Disp, odf, sn)
  odf <- processFieldChecks(ft='ph_value', df=pH, odf, sn)
  
  
}


processFieldChecks <- function(ft, df, odf, sn){
  
  
  r <- list()
  r$tableName = 'Horizons'
  r$dbFld = ''
  r$recNum = ''
  r$recSubNum = ''
  
  numericCheckPassed=T
  for (i in 1:nrow(df)) {
    ud <- df[i,1]
    if(!check.numeric(ud )){
      r$dbFld <-ft
      r$recNum=i
      odf <- message(val=ud, r, odf, sn, type='Error', msg="Depth is not a numeric value")
      numericCheckPassed=F
    }
  }
  
  if(numericCheckPassed){
    
    all(is.na(df))
    idxs<- which(is.na(df[,1]) & is.na(df[,2]))
    if(length(idxs)>0){
      df <- df[-idxs,]
    }
    
    NaDepthCheckPassed=T
    for (i in 1:nrow(df)) {
      if(is.na(df$Depth[i])){
        r$dbFld <-ft
        r$recNum=i
        odf <- message(val=df$Depth[i], r, odf, sn, type='Error', msg="Depth is missing")
        NaDepthCheckPassed=F
      }
      
    }
    
    if(NaDepthCheckPassed){
      
      df$Depth <- as.numeric(df$Depth)
      df[,2] <- as.numeric(df[,2])
      
      r$dbFld = ft
      
      if(max(df$Depth) > 200){
        odf <- message('', r, odf, sn, type='Warning', msg="You have Field Test depths greater than 200cm. Are you sure that is correct?")
      }
      
      if( min(df$Depth) < 0){
        odf <- message('', r, odf, sn, type='Error', msg="You have negative Field Test depth values. This is not allowed. Depths denote cm below the surface.")
      }
      
      if( max(df$Depth) < 3){
        odf <- message('', r, odf, sn, type='Warning', msg="You have a very small Field Test depth values. Are you sure these depths are recorded in centimetres?")
      }
      
      if( is.unsorted(df$Depth)){
        odf <- message('', r, odf, sn, type='Error', msg="The Field Test depths are not in ascending order.")
      }
      
      if(ft=='h_ec'){
        for (i in 1:nrow(df)) {
          if(df$EC[i] > 50){
            r$recNum=i
            odf <- message(val=df$EC[i], r, odf, sn, type='Warning', msg="EC value is over 50 dS/m. Are you sure this is correct?")
          }
          if(df$EC[i] < 0){
            r$recNum=i
            odf <- message(val=df$EC[i], r, odf, sn, type='Error', msg="EC value is less than 0")
          }
        }
      }
      
      if(ft=='ph_value'){
        for (i in 1:nrow(df)) {
          if(df$pH[i] < 4){
            r$recNum=i
            odf <- message(val=df$pH[i], r, odf, sn, type='Warning', msg="pH value is less than 4. Are you sure this is correct?")
          }
          
          if(df$pH[i] > 10){
            r$recNum=i
            odf <- message(val=df$pH[i], r, odf, sn, type='Warning', msg="pH value is greater than 10. Are you sure this is correct?")
          }
          
          if(df$pH[i] < 1){
            r$recNum=i
            odf <- message(val=df$pH[i], r, odf, sn, type='Error', msg="pH value is less than 1.")
          }
          
          if(df$pH[i] > 11){
            r$recNum=i
            odf <- message(val=df$pH[i], r, odf, sn, type='Error', msg="pH value is greater than 11. ")
          }
        }
      }
      
      
      
      
      } # NaDepthCheckPassed
  }#numericCheckPassed
  return(odf)
}


############ check depths ###########


CheckDepths <- function(dataSheet, sheetName, excelInfo, odf){
      
      sn=sheetName
      udpos <- excelInfo[excelInfo$dbFld=='h_upper_depth' & excelInfo$recSubNum==1,]
      ldspos <- excelInfo[excelInfo$dbFld=='h_lower_depth' & excelInfo$recSubNum==1,]
      r <- list()
      r$tableName = 'Horizons'
      r$dbFld = ''
      r$recNum = ''
      r$recSubNum = ''
      
      rvu <- vector(mode = 'list', nrow(udpos))
      rvl <- vector(mode = 'list', nrow(udpos))
      
      for (i in 1:nrow(udpos)) {
        row <- udpos$row[i]
        col <- udpos$col[i]
        rvu[[i]] <- dataSheet[row, col]
        rvl[[i]] <- dataSheet[row, col+1]
      }
      
      depths <- data.frame(ud=unlist(rvu), ld=unlist(rvl))
      
      #### Check for missing values
      numericCheckPassed=T
      for (i in 1:nrow(depths)) {
        ud <- depths[i,1]
        if(!check.numeric(ud )){
          r$dbFld <-'h_upper_depth'
          r$recNum=i
          odf <- message(val=ud, r, odf, sn, type='Error', msg="Depth is not a numeric value")
          numericCheckPassed=F
        }
        
        ld <- depths[i,2]
        if(!check.numeric(ld)){
          r$dbFld <-'h_lower_depth'
          r$recNum=i
          odf <- message(val=ld, r, odf, sn, type='Error', msg="Depth is not a numeric value")
          numericCheckPassed=F
        }
      }
      
      # no point doing further checks if there is non numeric data
      if(numericCheckPassed){
        
        
        
        
################### Check for NA depth values in legit horizons - the above check.numeric ignores NA values
        recNum = 4
        row=1
        horDatadRows=numeric()
        NaCheckPassed=T
        for (i in 1:nrow(depths)) {

            datasection <- dataSheet[recNum, c(8:42)[-c(1,2)]]
            horHasData <- !all(is.na(datasection))
            if(horHasData){
              
                ud <- depths[i,1]
                if(is.na(ud)){
                  r$dbFld <-'h_upper_depth'
                  r$recNum=i
                  odf <- message(val=ud, r, odf, sn, type='Error', msg="Upper depth value is missing")
                  NaCheckPassed=F
                }
                ld <- depths[i,2]
                if(is.na(ld)){
                  r$dbFld <-'h_lower_depth'
                  r$recNum=i
                  odf <- message(val=ld, r, odf, sn, type='Error', msg="Lower depth value is missing")
                  NaCheckPassed=F
                }
            
                horDatadRows <- c(horDatadRows, i)
            }else{
             # ndrows <- c(ndrows, i)
            }
            recNum = recNum+2
            row=row+1
        }

        
        
        
                
############################# no point doing further checks if there is NA data
            if(NaCheckPassed){
              
              depths <- depths[horDatadRows,]
              depths$ud <- as.numeric(depths$ud)
              depths$ld <- as.numeric(depths$ld)

                ####  Check top upper depths is zero
                td <- depths[1,1]
                if(td != 0){
                  r$dbFld = 'h_upper_depth'
                  odf <- message(td, r, odf, sn, type='Warning', msg="Upper depths of the soil profile are generally 0cm, but yours isn't?")
                }
                
                if(max(depths$ud) > 200){
                  r$dbFld = 'h_upper_depth'
                  odf <- message('', r, odf, sn, type='Warning', msg="You have Upper Depths greater than 200cm. Are you sure that is correct?")
                }
                if(max(depths$ld) > 200){
                  r$dbFld = 'h_lower_depth'
                  odf <- message('', r, odf, sn, type='Warning', msg="You have Lower Depths greater than 200cm. Are you sure that is correct?")
                }
                if( min(depths) < 0){
                  r$dbFld = 'h_lower_depth'
                  odf <- message('', r, odf, sn, type='Error', msg="You have negative depth values. This is not allowed. Depths denote cm below the surface.")
                }
                
                if( max(depths) < 3){
                  r$dbFld = 'h_lower_depth'
                  odf <- message('', r, odf, sn, type='Warning', msg="You have a very small depth values. Are you sure these depths are recorded in centimetres?")
                }
               
                if( is.unsorted(depths$ld)){
                  r$dbFld = 'h_lower_depth'
                  odf <- message('', r, odf, sn, type='Error', msg="The lower depth values are not in ascending order.")
                }
                
                if(is.unsorted(depths$ud)){
                  r$dbFld = 'h_upper_depth'
                  odf <- message('', r, odf, sn, type='Error', msg="The upper depth values are not in ascending order.")
                }
                
                for (i in 1:(nrow(depths)-1)) {
                  ud <- depths$ud[i+1]
                  ld <- depths$ld[i]
                  if(!identical(ud, ld)){
                    r$recNum=i
                    odf <- message(ld, r, odf, sn, type='Error', msg="The lower depth and the upper depth of the horizon below are not the same.")
                  }
                  
                  udh <-depths$ud[i]
                  if(identical(udh, ld)){
                    r$recNum=i
                    odf <- message(ld, r, odf, sn, type='Error', msg="The upper depth and lower depth of a horizon can not be the same.")
                  }
                
            }#general checks
    
          }#NaCheckPassed
      }#numericCheckPassed

return(odf)

}

checkSiteNameValidity <- function(fname, itCnt, siteSheets, excelInfo, odf, config, allowedSites){


      usedSiteList <<- list()
      for (s in 1:length(siteSheets)) {
        itCnt <- itCnt + 1
#        setProgress(itCnt, detail = paste("Checking site names - Site ", s, ' of ', length(siteSheets)))
        
        sn <- siteSheets[s]
        print(paste0('Checking Site Name : ', sn))
        
        dataSheet <- openxlsx::readWorkbook(xlsxFile = fname, sheet=sn, skipEmptyRows = F, skipEmptyCols = F)
        r <- excelInfo[excelInfo$dbFld == 's_id',]
        val=dataSheet[r$row,r$col]
        
        if(SheetHasData(dataSheet, excelInfo)){
          if(config=='NSMP'){
            if(!val %in% allowedSites){
              odf <- message(val, r, odf, sn, type='Error', msg='Site ID not in the allowed list of sites')
            }
          }
          
          if(val %in% usedSiteList){
            odf <- message(val, r, odf, sn, type='Error', msg='Duplicate Site ID')
          }else{
            usedSiteList <- c(usedSiteList, sn)
          }
          
        }
      }
      ol <- list()
      ol$ODF <- odf
      ol$itcnt <- itCnt
      return(ol)
}

checkIfRequired <- function(row, col, dataSheet, val, r, odf, sn){
  
  if(!is.na(r$required) & r$required != ''){
    if(r$formRegion != 'H'){
      if(is.na(val) & str_to_upper(r$required)=='REQUIRED'){ return(T)}
    }else{
      if(r$recSubNum==1){
        # datasection <- dataSheet[row,8:ncol(dataSheet)]
        datasection <- dataSheet[row,c(8:42)]  # hardcoding this for now - this allows pHs etc to be on the right with having to have required horizon fields
        horHasData <- !all(is.na(datasection))
        if(horHasData){
          if(is.na(val) & str_to_upper(r$required)=='REQUIRED'){return(T)}
        }
      }
    }
  }
  return(F)
}



checkNSMPSpecificRules <- function(val, r, odf, sn){
  if(r$dbFld=='o_latitude_GDA94'){
    
    if(as.numeric(val) > -10 | as.numeric(val) < -43){
      odf <- message(val, r, odf, sn, type='Error', msg='The latitude is not within Australia')
    }
  }
  
  if(r$dbFld=='o_longitude_GDA94'){
    
    if(as.numeric(val) < 112 | as.numeric(val) > 155){
      odf <- message(val, r, odf, sn, type='Error', msg='The longitude is not within Australia')
    }
  }
  
  if(year(d) < 2024){
    odf <- message(val, r, odf, sn, type='Warning', msg="Are you sure the date is correct ? The NSMP didn't begin until 2020")
  }
  
  return(odf)
}


#########  General  Rule checking    ########
checkRules <- function(val, r, odf, sn){
  
  ###### Observation ID 
  if(r$dbFld=='o_id'){
    if(!check.numeric(val, only.integer=T)){
      odf <- message(val, r, odf, sn, type='Error', msg='Observation ID has to be an integer value')
    }
  }
  
  ###### Described date
  if(r$dbFld=='s_date_desc'){
        d <- as.Date(val, format='%Y%m%d')
        if(nchar(val)!=8){
          odf <- message(val, r, odf, sn, type='Error', msg='Date Described has to be an 8 characters string in the format YYYMMDD')
        }else if(is.na(d)){
          odf <- message(val, r, odf, sn, type='Error', msg='Date Described has to be an 8 characters string in the format YYYMMDD')
        }else if(d > Sys.Date()){
              odf <- message(val, r, odf, sn, type='Warning', msg='Date supplied is in the future. Are you sure this is correct?'  )
        }else if(year(d)<1900){
              odf <- message(val, r, odf, sn, type='Warning', msg='Date supplied is before 1900. Are you sure this is correct?'  )
        }
  } 
  
  
  #####  Location
  if(r$dbFld=='o_latitude_GDA94'){
    
    if(!check.numeric(val, only.integer=F)){
      odf <- message(val, r, odf, sn, type='Error', msg='Observation ID has to be an numerical value')
    }else if(as.numeric(val)< -90 | as.numeric(val) > 90) {
      odf <- message(val, r, odf, sn, type='Error', msg='Latitude has to be between -90 and 90 degrees')
    }
  }
  
  if(r$dbFld=='o_longitude_GDA94'){
    
    if(!check.numeric(val, only.integer=F)){
      odf <- message(val, r, odf, sn, type='Error', msg='Observation ID has to be an numerical value')
    }else if(as.numeric(val)< -180 | as.numeric(val) > 180) {
      odf <- message(val, r, odf, sn, type='Error', msg='Longitude has to be between -180 and 180 degrees')
    }
    
  }
  
  ######  Described By
  if(r$dbFld=='o_desc_by'){
    
    if(nchar(val)!=4){
      odf <- message(val, r, odf, sn, type='Error', msg='Described by needs to be 4 characters long')
    }
  }
  
  #####  Slope
  if(r$dbFld=='s_slope'){
    
    if(!check.numeric(val, only.integer=F)){
      odf <- message(val, r, odf, sn, type='Error', msg='Slope % has to be an numerical value')
    }else if(as.numeric(val) > 100){
      odf <- message(val, r, odf, sn, type='Warning', msg='Are you sure the slope is great than 100% ?')
    }
  }
  
  #####  Depths
  if(r$dbFld=='h_upper_depth'){
    
    if(!is.na(as.numeric(val))){
      if(!check.numeric(val, only.integer=T)){
        odf <- message(val, r, odf, sn, type='Error', msg='Upper Depths have to be integer values in cm')
      }else if(as.numeric(val) > 200){
        odf <- message(val, r, odf, sn, type='Warning', msg='The upper depth is greater than 200 cm. Good work if you did dig that deep')
      }
    }
  }
  if(r$dbFld=='h_lower_depth'){
    if(!is.na(as.numeric(val))){
      if(!check.numeric(val, only.integer=T)){
        odf <- message(val, r, odf, sn, type='Error', msg='Lower Depths have to be integer values in cm')
      }else if(as.numeric(val) > 201){
        odf <- message(val, r, odf, sn, type='Warning', msg='The lower depth is greater than 200 cm. Good work if you did dig that deep')
      }
    }
  }

  
  #####  Depth to water
  if(r$dbFld=='o_depth_water'){
    
    if(!check.numeric(val, only.integer=F)){
      odf <- message(val, r, odf, sn, type='Error', msg='Slope % has to be an numerical value')
    }else if(as.numeric(val) > 10){
      odf <- message(val, r, odf, sn, type='Warning', msg='Did you really see water past 10m deep ?')
    }
  }
  
  #####  Horizon Designation
  if(r$dbFld=='h_desig_master'){
   h <- str_sub(val, 1,1)
     if(str_detect(h,"[[:lower:]]")){
        odf <- message(val, r, odf, sn, type='Error', msg='The first character of the horizon needs to be a capital letter')
     }
     if(!str_to_upper(h) %in% c('A', 'B', 'C', 'D', 'R', 'L', 'M', 'O')){
       odf <- message(val, r, odf, sn, type='Error', msg="The first character of the horizon needs to be one of these - 'A', 'B', 'C', 'D', 'R', 'L', 'M', 'O'")
     }
  }
  
  if(r$dbFld=='h_desig_suffix'){

    if(str_detect(val,"[[:upper:]]")){
      odf <- message(val, r, odf, sn, type='Error', msg='The horizon designation suffix has to be lower case')
    }
    if(!str_to_upper(val) %in% c('a', 'b', 'c', 'cc', 'c', 'e', 'f', 'g','h', 'i', 'j', 'k', 'kk', 'm', 'n', 'o','p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'yy', 'z', '?')){
      odf <- message(val, r, odf, sn, type='Error', msg="The horizon designation suffix has to be in the list in the yellow book P131.'")
    }
  }
  
  
  return(odf)
}


validateCode <- function(val, r, odf, sn){
  cvs <- cds[cds$field_name ==str_to_upper(r$dbFld ),]
  if(nrow(cvs)>0){
    
    if(!val %in% cvs$code_value){
      m <- message(val, r, odf, sn, type='Error', msg='Value not in the required codes list.')
      odf <- rbind(odf, m)
    }else{
      # e$Type = 'OK'
      # e$Issue = paste0('')
    }
  }
  return(odf)
}


SheetHasData <- function(dataSheet, excelInfo){
  
  # ymin <- min( excelInfo$row)
  # ymax <- max( excelInfo$row)
  # xmin <- min( excelInfo$col)
  # xmax <- max( excelInfo$col)
  #   
  #   datasection <- dataSheet[ymin:ymax, xmin:xmax]  # Looks athe the whole data sheet
  
  datasection <- dataSheet[10:11, 2]  ## Just look at the location
  
  resp <- !all(is.na(datasection))
  return(resp)
}















