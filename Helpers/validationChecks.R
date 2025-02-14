################################################################# #
#####       Author : Ross Searle                              ###
#####       Date :  Fri Feb 14 09:41:24 2025                  ###
#####       Purpose : Site data validation checks             ###
#####       Comments :                                        ###
################################################################# #




# fname = 'C:/Projects/SiteDataEntryTool/Validation Testing - NSMP - Burnie.xlsx'
# dataSheet <- openxlsx::readWorkbook(xlsxFile = fname, sheet='N2056', skipEmptyRows = F, skipEmptyCols = F)



############ check depths ###########


CheckDepths <- function(dataSheet){
        
      udpos <- excelInfo[excelInfo$dbFld=='h_upper_depth' & excelInfo$recSubNum==1,]
      ldspos <- excelInfo[excelInfo$dbFld=='h_lower_depth' & excelInfo$recSubNum==1,]
      r <- list()
      r$tableName = 'Horizons'
      r$dbFld = ''
      r$recNum = ''
      r$recSubNum = ''
      
      rvu <- vector(mode = 'list', nrow(uds))
      rvl <- vector(mode = 'list', nrow(uds))
      
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
        if(!check.numeric(ud)){
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

            datasection <- dataSheet[recNum,horizonDataSection[-c(1,2)]]
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
                }
            }
    
          }#NaCheckPassed
      }#numericCheckPassed

return(odf)

}
