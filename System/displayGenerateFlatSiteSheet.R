################################################################# #
#####       Author : Ross Searle                              ###
#####       Date :  Thu Jan 30 06:24:32 2025                  ###
#####       Purpose : Generates a site sheet format from the  ###
#####                 db similar to the data entry Excel      ###
#####                 spreadsheet                             ###
#####       Comments :                                        ###
################################################################# #


#con=con$Connection; agencyCode='994'; projectCode='NSMP'; siteID='N2051'; obsID=1;


#fname <- 'C:/Users/sea084/OneDrive - CSIRO/RossRCode/Git/Shiny/Apps/NationalSoilMonitoring/NSMData/www/Configs/NSMP/No Errors -  Entry Template - NSMP.xlsx'
#fname <- 'C:/Users/sea084/OneDrive - CSIRO/RossRCode/Git/Shiny/Apps/NationalSoilMonitoring/NSMData/www/Configs/NSMP/Data Entry Template - NSMP.xlsx'


#makeFlatSiteDescriptionSheetfromDB(con, fname, agency, proj, sid, oid)

# con <- OS$DB$Config$getCon(OS$DB$Config$DBNames$NSMP_HoldingRW)$Connection
# agency <- '994'
# proj <- 'NSMP'
# sid <- 'N5006'
# o_id=1

get_FlatSheetFunctions <- function()
{
  fs <- list()
  

      fs$makeFlatSiteDescriptionSheetfromDB <- function(con, fname, agency, proj, sid, oid){
        
       # fname <- 'C:/Users/sea084/OneDrive - CSIRO/RossRCode/Git/Shiny/Apps/NationalSoilMonitoring/NSMData/www/Configs/NSMP/Data Entry Template - NSMP.xlsx'
        
        keys <<- c(COLOURS='col', MOTTLES='mott', COARSE_FRAGS='cf', STRUCTURES='str', SEGREGATIONS='seg', 
                  STRENGTHS='strg', CUTANS='cutan', PANS='pan', ROOTS='root', PHS='ph')
        
        excelInfo <<- OS$IngestHelpers$getExcelFormInfo(fname)
      
          outMat <- generateBlankTemplate(fname)
          outMat <- populateKeyData(outMat, excelInfo, con, agency, proj, sid, oid)
          outMat=populateSiteData(outMat, excelInfo, con, agency, proj, sid, oid)
          outMat=populateHorizonData(outMat, excelInfo, con, agency, proj, sid, oid)
          outMat=populateSubHorizonData(outMat, excelInfo, con, agency, proj, sid, oid)
          
          idxs <- which(is.na(outMat))
          outMat[idxs] <- ''
          
          cns <- outMat[3,]
          outMat <- outMat[4:nrow(outMat),]
          c1 <- str_replace_all(cns, ' ', '_')
          c2 <- str_replace_all(c1, '[(]', '')
          c3 <- str_replace_all(c2, '[)]', '')
          colnames(outMat) <- c3
      
          return(outMat)
      }
      
      
      generateBlankTemplate <- function(fname){
        
        #tp <<- as.data.frame(suppressMessages(read_excel(fname, sheet = 'DBInfo', col_names = F)))
        tp <<- openxlsx::readWorkbook(xlsxFile = fname, sheet = 'DBInfo', skipEmptyRows = F, skipEmptyCols = F)
        
        outMat <- matrix(nrow = nrow(tp), ncol=ncol(tp))
        
        for (i in 1:nrow(tp)) {
          for (j in 1:ncol(tp)) {
            val <- tp[i,j]
            if(!is.na(val)){
              if(!str_detect(val, '#')){
                outMat[i,j] <- as.character(val)
              }
            }
          }
        }
        return(outMat)
      }
      
      populateKeyData <- function(outMat, excelInfo, con, agency, proj, sid, oid){
        
        siteSQL <- paste0("SELECT agency_code, proj_code, s_id, o_id from observations WHERE agency_code='", agency, "' and proj_code='", proj, "' and s_id ='", sid, "' and o_id=",oid)
        svs <- OS$DB$Helpers$doQuery(con, siteSQL)
        si <- excelInfo[excelInfo$formRegion=='K', ]
        
        for (i in 1:nrow(si)) {
          r <- si[i,]
          v <- svs[1, r$dbFld]
          outMat[r$row, r$col] <- v
        }
        
        return(outMat)
      }
      
      
      populateSiteData <- function(outMat, excelInfo, con, agency, proj, sid, oid){
        
        si <- excelInfo[excelInfo$formRegion=='S',]
        
        s <- ''
        for (k in 1:nrow(si)) {
          r <- si[k,]
          s <- paste0(s, 'dbo.', r$tableName, '.', r$dbFld, ', ' )
        }
        s <- gsub(", $", " ", s)
        
        siteSQL <- paste0("SELECT 
            ", s, " 
            FROM   dbo.SURF_CONDITIONS FULL OUTER JOIN
                         dbo.OBSERVATIONS ON dbo.SURF_CONDITIONS.agency_code = dbo.OBSERVATIONS.agency_code AND dbo.SURF_CONDITIONS.proj_code = dbo.OBSERVATIONS.proj_code AND dbo.SURF_CONDITIONS.s_id = dbo.OBSERVATIONS.s_id AND 
                         dbo.SURF_CONDITIONS.o_id = dbo.OBSERVATIONS.o_id FULL OUTER JOIN
                         dbo.SURF_COARSE_FRAGS ON dbo.OBSERVATIONS.agency_code = dbo.SURF_COARSE_FRAGS.agency_code AND dbo.OBSERVATIONS.proj_code = dbo.SURF_COARSE_FRAGS.proj_code AND dbo.OBSERVATIONS.s_id = dbo.SURF_COARSE_FRAGS.s_id AND 
                         dbo.OBSERVATIONS.o_id = dbo.SURF_COARSE_FRAGS.o_id FULL OUTER JOIN
                         dbo.LAND_USES FULL OUTER JOIN
                         dbo.SITES ON dbo.LAND_USES.agency_code = dbo.SITES.agency_code AND dbo.LAND_USES.proj_code = dbo.SITES.proj_code AND dbo.LAND_USES.s_id = dbo.SITES.s_id ON dbo.OBSERVATIONS.agency_code = dbo.SITES.agency_code AND 
                         dbo.OBSERVATIONS.proj_code = dbo.SITES.proj_code AND dbo.OBSERVATIONS.s_id = dbo.SITES.s_id FULL OUTER JOIN
                         dbo.DISTURBANCES ON dbo.OBSERVATIONS.agency_code = dbo.DISTURBANCES.agency_code AND dbo.OBSERVATIONS.proj_code = dbo.DISTURBANCES.proj_code AND dbo.OBSERVATIONS.s_id = dbo.DISTURBANCES.s_id AND 
                         dbo.OBSERVATIONS.o_id = dbo.DISTURBANCES.o_id 
            WHERE dbo.OBSERVATIONS.agency_code='", agency, "' and dbo.OBSERVATIONS.proj_code='", proj, "' and dbo.OBSERVATIONS.s_id ='", sid, "' and dbo.OBSERVATIONS.o_id=",oid
            )
        
        svs <- OS$DB$Helpers$doQuery(con, siteSQL)
        
        
        for (i in 1:nrow(si)) {
          r <- si[i,]
          v <- svs[1, r$dbFld]
          #if(!is.na(v)){
          outMat[r$row, r$col] <- v
          #}
          
        }
        return(outMat)
      }
      
      
      
      populateHorizonData <- function(outMat, excelInfo, con, agency, proj, sid, oid){
        
            tn <- 'HORIZONS'
            si <- excelInfo[excelInfo$tableName==tn,]
            flds <- unique(si[,c('tableName','dbFld')])
            
            s <- ''
            for (k in 1:nrow(flds)) {
              r <- flds[k,]
              s <- paste0(s, 'dbo.', r$tableName, '.', r$dbFld, ', ' )
            }
            s <- gsub(", $", " ", s)
            
            horSQL <- paste0("SELECT ", s, " FROM ", tn, "  WHERE agency_code='", agency, "' and proj_code='", proj, "' and s_id ='", sid, "' and o_id=",oid, 
                              " ORDER BY h_upper_depth, h_lower_depth")
            svs <- OS$DB$Helpers$doQuery(con, horSQL)
            
            if(nrow(svs)>0){
            
            tm <- outMat
            fldnames <- colnames(svs)
            
            for (i in 1:nrow(svs)) {
              
              for (j in 1:length(fldnames)) {
                fld <- fldnames[j]
                r <- si[si$recNum==as.character(i) & si$dbFld==fld & si$recSubNum==1, ]
                if(fld=='h_upper_depth' | fld=='h_lower_depth' ){
                  v <- 0
                }else{
                  v <- svs[i, r$dbFld]
                }
      
                if(!is.na(v)){
                  tm[r$row, r$col] <- v
                }
              }
            }
      return(tm)
            }else{
              return(outMat)
            }
      }
      
      
      
      populateSubHorizonData <- function(outMat, excelInfo, con, agency, proj, sid, oid){
        
        si <- excelInfo[excelInfo$formRegion=='H', ]
        t1 <- unique(si[,c('tableName')])
        tablenames <- t1[-1]
        
        for(j in 1:length(tablenames)){
      
          tn <- tablenames[j]
          si <- excelInfo[excelInfo$tableName==tn,]
          flds <- unique(si[,c('tableName','dbFld')])
          
          s <- ''
          for (k in 1:nrow(flds)) {
            r <- flds[k,]
            s <- paste0(s, 'dbo.', r$tableName, '.', r$dbFld, ', ' )
          }
          s <- gsub(", $", " ", s)
          
          siteSQL <- paste0("SELECT o_id, h_no, ", keys[tn],"_no, ", s, " FROM ", tn, "  WHERE agency_code='", agency, "' and proj_code='", proj, "' and s_id ='", sid, "' and o_id=",oid)
          svs <- OS$DB$Helpers$doQuery(con, siteSQL)
          
          if(nrow(svs)>0){
          
          fldnames <- colnames(svs)
          
              for (i in 1:nrow(svs)) {
                
                for (j in 4:length(fldnames)) {
                  fld <- fldnames[j]
                  snum <- svs[i,3]
                  hnum <- svs[i,2]
                  r <- si[si$recNum==as.character(hnum) & si$dbFld==fld & si$recSubNum==as.character(snum), ]
                  if( fld=='ph_depth' | fld=='ph_value'){
                    v <- 0
                  }else{
                    v <- svs[i, r$dbFld]
                  }
                  
                  if(!is.na(v)){
                    outMat[r$row, r$col] <- v
                  }
                }
              }
        }
          
        }
        return(outMat)
      }  

      return(fs)
}


