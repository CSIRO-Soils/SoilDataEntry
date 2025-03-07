################################################################### #
#####       Author : Ross Searle                                ###
#####       Date :  Thu Jan 23 14:33:06 2025                    ###
#####       Purpose : Ingest the MS Excel spreadsheet of soils  ###
#####                 Data into a Natsoil containers DB         ###
#####       Comments :                                          ###
################################################################### #




# library(DBI)
# library(readxl)
# library(stringr)


get_IngestFunctions <- function()
{
  ig <- list()
  
      ig$ingestMorpholgyData <- function(con, XLFile, config, keys){
        
     
       
##########   Dev Only   ###########################################################        
        # con <- OS$DB$Config$getCon(OS$DB$Config$DBNames$NSMP_HoldingRW)
        # XLFile <- 'C:/Projects/SiteDataEntryTool/bbb No Errors Data Entry Template - NSMP_Capital.xlsx'
        # XLFile <- 'C:/Projects/SiteDataEntryTool/temp.xlsx'
        
        # keys<-list()
        # keys$AgencyCode='994'
        # keys$ProjectCode='NSMP'
        # keys$Token='Capital'
        # config='NSMP'

        #####################################################################################  
       #conInfo <- OS$DB$Config$getCon(conName$Name)
        ingestCon <- con$Connection
        
        fname=XLFile
        wb <- openxlsx::loadWorkbook(file.path(fname) )
        sheets <- names(wb)

          idxs <- match(OS$Constants$Sheetnames, sheets)
          siteSheets <- sheets[-idxs]
          
          withProgress(message = paste0('Ingesting soil data....'), max=length(siteSheets)+1, value = 0, {
            setProgress(0, detail = paste("Reading configuration data ..."))
          
          excelInfo <<- OS$IngestHelpers$getExcelFormInfo(fname)
          tablesInSheet <<- unique(excelInfo$tableName)
          
          appcon <- OS$DB$Config$getCon(OS$DB$Config$DBNames$AppDB)$Connection
          cds <- OS$DB$Helpers$doQuery(appcon, 'Select * from NatSoil_UnifiedCodes')
          
          #tableLevels <<- as.data.frame(suppressMessages( read_excel(fname, sheet = 'DBTableLevels', col_names = T)))
          tableLevels <<- openxlsx::readWorkbook(xlsxFile = fname, sheet = 'DBTableLevels')
          idxs <- which(tableLevels$Table %in% tablesInSheet)
          tableLevelsInSheet <- tableLevels[idxs,]
          
          tableLevelsInSheet <<- tableLevelsInSheet[order(tableLevelsInSheet$Level),] 
  
         appcon<- OS$DB$Config$getCon(OS$DB$Config$DBNames$AppDB)$Connection
         dbInfo <<- OS$DB$Helpers$doQuery(appcon, 'select * from NatSoil_DBInfo')

        ps <- siteSheets[1]
        #dataSheet <- as.data.frame(suppressMessages( read_excel(fname, sheet = ps, col_names = F)))
        dataSheet <- openxlsx::readWorkbook(xlsxFile = fname, sheet = ps, skipEmptyRows = F, skipEmptyCols = F)
        
        #####  Do project insertion  #####
        r <- excelInfo[excelInfo$dbFld == 'agency_code',]
        agencyCode=dataSheet[r$row,r$col]
        r <- excelInfo[excelInfo$dbFld == 'proj_code',]
        projCode=dataSheet[r$row, r$col]

        
        sql <- paste0("select * from projects where agency_code='",keys$AgencyCode, "' and proj_code='", keys$ProjectCode, "'")

        pdf <- OS$DB$Helpers$doQuery(ingestCon, sql)
       
        if(nrow(pdf)==0){
          stop('Project does not exist in the database')
        }else{
          print(paste0("Project exists - ", keys$ProjectCode))
        }
        
        
        if(config=='NSMP'){
          publishedSites <- OS$PublishSitesToNatSoil$getDraftOrPublishedSites(type='Published', keys=keys)$s_id
        }
        
        
        #########   Insert Sites into DB  ###############################
        
          hcnt=0
          for (s in 1:length(siteSheets)) {
            
#            setProgress(s, detail = paste("Site ", s, ' of ', length(siteSheets)))
            
            print(paste0('Ingesting ', s))
            sn <- siteSheets[s]
            dataSheet <- openxlsx::readWorkbook(xlsxFile = fname, sheet = sn, skipEmptyRows = F, skipEmptyCols = F)
            
            
            siteAlreadyPublished=F
            if(config=='NSMP'){
              loc <- excelInfo[excelInfo$dbFld=='s_id',]
              sid <- dataSheet[loc$row, loc$col]
              if(sid %in% publishedSites){
                siteAlreadyPublished=T
              }
            }
            
            if(siteAlreadyPublished){
              
            }else{
              
            
            
            if(SheetHasData(dataSheet, excelInfo)){
           
            
            ######  Check if site already exists and if it does delete it from the DB  #####
            
            r <- excelInfo[excelInfo$dbFld == 's_id',]
            sid=dataSheet[r$row, r$col]
            r <- excelInfo[excelInfo$dbFld == 'o_id',]
            oid=dataSheet[r$row, r$col]
            
            # sid <- dataSheet[6,2]
            # oid <- dataSheet[7,2]
            sql <- paste0("SELECT * from SITES WHERE agency_code = '", keys$AgencyCode, "' and ", "proj_code = '", keys$ProjectCode, "' and ", "s_id = '", sid, "'")
            st <- OS$DB$Helpers$doQuery(ingestCon, sql)
            if(nrow(st)>0){
              print(paste('Site ', sid, ' already exists in the database. It will be overwritten by the data in this new site.'))
              OS$DB$Helpers$deleteWholeSite(ingestCon, agencyCode=keys$AgencyCode, projCode = keys$ProjectCode, siteID = sid, obsNo = NULL)
            }else{
              print(paste('Adding new Site ', sid))
            }
            
            sql <- OS$IngestHelpers$makeSQLFromForm(sheet=dataSheet, formRegion='S',tableName = 'SITES')
            OS$DB$Helpers$doInsert(ingestCon,sql)
            sql <- OS$IngestHelpers$makeSQLFromForm(sheet=dataSheet, formRegion='S',tableName = 'OBSERVATIONS')
            OS$DB$Helpers$doInsert(ingestCon,sql)
            
            #### This inserts land use. If we get more instances of tables at this level I will have to implement something better
            r <- excelInfo[excelInfo$dbFld == 'luse_use_code',]
            luse=dataSheet[r$row, r$col]
            if(!is.na(luse)){
              sql <- paste0("INSERT into LAND_USES (agency_code, proj_code, s_id, luse_no, luse_tech_ref', luse_use_code) 
              VALUES ('", keys$AgencyCode, "', '", keys$ProjectCode, "', '", sid, "', 1, 'ALUM v6', '", luse, "')")
              OS$DB$Helpers$doInsert(ingestCon,sql)
            }
            
            
            hif <- excelInfo[excelInfo$formRegion=='H', ]
            htabs <- unique(hif$tableName)

            for (h in 1:8) {
              hcnt=hcnt+1
              for (hsub in 1:2) {
                
                for (tn in 1:length(htabs)) {
                  tabname <- htabs[tn]
                   sql <- OS$IngestHelpers$makeHorizonsSQLFromForm(sheet=dataSheet, formRegion='H', tableName=tabname, horizonNum=h, subrecNum=hsub)
                   OS$DB$Helpers$doInsert(ingestCon,sql)
                }
              }
            }
            }
          }
          }
          print('Finished ingesting')
       })
        
        
        ol <- list()
        ol$Type='Ingestion'
        bbox <- OS$DB$NatSoilQueries$getBoundingBoxForProject(ingestCon, keys$AgencyCode, keys$ProjectCode)
        
        ot <- paste0('<H3 style="color:green;"><b>Finished loading data into the Database</b></H3><BR>')
         ot <- paste0(ot, '<p>Well done, you have successfully loaded your soil site data into the Database.
                              You can now use the Tabs above to explore and review your data.</p><BR>')
         
       # ot <- paste0(ot, '<p><b>Database Name : </b>', con$Name , '</p>')
        ot <- paste0(ot, '<p><b>Agency Code : </b>', keys$AgencyCode, '</p>' )
        ot <- paste0(ot, '<p><b>Project Code : </b>', keys$ProjectCode, '</p>')
        ot <- paste0(ot, '<p><b>Number of Sites : </b>', length(siteSheets), '</p>')


        if(nrow(bbox)==0){
          ot <- paste0(ot, '<p><b>No site locations have been recorded</b></p>')
          ol$HasLocs=F
        }else{
          ot <- paste0(ot, '<p><b>Minimum Longitude : </b>', bbox$minx, '</p><p><b>Maximum Longitude : </b>', bbox$maxx, '</p>')
          ot <- paste0(ot, '<p><b>Minimum Latitude : </b>', bbox$miny, '</p><p><b>Maximum Latitude : </b>', bbox$maxy, '</p>')
          ol$HasLocs=T
        }

        ol$html <- ot
        ol$locs <- OS$DB$NatSoilQueries$getProjectLocationInfo(ingestCon, keys$AgencyCode, keys$ProjectCode)
        
      #  dbDisconnect(ingestCon)
          return(ol)
      }


ig$ingestFlatExcelFile <- function(conInfo, XLFile){
  
  con <- conInfo$Connection
  
  withProgress(message = paste0('Loading your soil site data into ', conInfo$Name), value = 0, {
    
    print('Ingesting data from the Excel Flat File format')
    fname <- XLFile
    dbInfo <<- read.csv(dbInfoPath)
    s <- suppressMessages( readxl::read_xlsx (fname))
    sheets <- excel_sheets(fname)
    ps <- sheets[1]
    
    
    ##### Do agency insertion  ######
    
    #sagency <- as.data.frame(suppressMessages( read_excel(fname, sheet = ps, col_names = T)))
    sagency <- openxlsx::readWorkbook(xlsxFile = fname, sheet = ps, skipEmptyRows = F, skipEmptyCols = F)
    agencyCode <- sagency$AGENCY_CODE[1]
    pdf <- doQuery(con, paste0("select * from agencies where AGENCY_CODE ='",keys$AgencyCode , "'"))
    if(nrow(pdf)==0){
      DBI::dbAppendTable(con, 'agencies', sagency[1,])
      print(paste0("Inserted new project - ",  sagency$AGENCY_CODE[1]))
    }else{
      print(paste0("Agency exists exists - ",  sagency$AGENCY_CODE[1]))    
    }
    
    
    #####  Do project insertion  ##### 
    
    #sproj<- as.data.frame(suppressMessages( read_excel(fname, sheet = sheets[2], col_names = T)))
    sproj <- openxlsx::readWorkbook(xlsxFile = fname, sheet = sheets[2], skipEmptyRows = F, skipEmptyCols = F)
    projCode <- sproj$proj_code[1]
    pdf <- doQuery(con, paste0("select * from projects where proj_code='",keys$ProjectCode, "'"))
    if(nrow(pdf)==0){
      DBI::dbAppendTable(con, 'PROJECTS', sproj[1,])
      print(paste0("Inserted new project - ", sproj$proj_code[1]))
    }else{
      print(paste0("Project exists - ", sproj$proj_code[1]))    
    }
    
    #####  Do oficers insertion  ##### 
    
    #sOff<- as.data.frame(suppressMessages( read_excel(fname, sheet = sheets[3], col_names = T)))
    sOff<- openxlsx::readWorkbook(xlsxFile = fname, sheet = sheets[3])
    for (j in 1:nrow(sOff)){
      
      rec<- sOff[j,]
      
      pdf <- doQuery(con, paste0("select * from OFFICERS where offr_code='",rec$offr_code, "'"))
      if(nrow(pdf)==0){
        DBI::dbAppendTable(con, 'OFFICERS', rec)
        print(paste0("Inserted new officer - ", rec$offr_code))
      }else{
        print(paste0("Officer exists - ", rec$offr_code))    
      }
    }
    
    
    
    tl <- tableLevels[order(tableLevels$Level),]
    
    
    
    for (i in 1:nrow(tl)) {
      
      rec <- tl[i,]
      tbl <- rec$Table
      
      incProgress(1/nrow(tl), detail = paste("Inserting data into  ",tbl))
      
      tid <- match(str_to_upper(tbl), str_to_upper(sheets))
      
      if(!is.na(tid)){
       # d <- as.data.frame(suppressMessages( read_excel(fname, sheet = sheets[tid], col_names = T)))
        d <- openxlsx::readWorkbook(xlsxFile = fname, sheet = sheets[tid], skipEmptyRows = F, skipEmptyCols = F)
        
        if(nrow(d)>1){
          print(paste0('Inserting data into ', tbl))
          for (j in 1:nrow(d)) {
            sql <- makeRecordINSERT(table=tbl, rec=d[j,])
            doExec(con, sql)
          }
        }else{
          print(paste0('No data for ', tbl))
        }
      }
    }
    
    
    print('Finished ingesting data')
    
    
    ol <- list()
    
    bbox <- getBoundingBoxForProject(con, keys$AgencyCode, keys$ProjectCode)
    
    ot <- paste0('<H3>Finished loading data</H3><BR>')
    ot <- paste0(ot, '<p>Database Name : ', con$Name , '</p>')
    ot <- paste0(ot, '<p>Agency Code : ', keys$AgencyCode, '</p><p>Project Code : ', keys$ProjectCode, '</p>')
    #hs <- as.data.frame(suppressMessages( read_excel(fname, sheet = sheets[6], col_names = T)))
    #ss <- as.data.frame(suppressMessages( read_excel(fname, sheet = sheets[4], col_names = T)))
    
    hs <- openxlsx::readWorkbook(xlsxFile = fname, sheet = sheets[6], skipEmptyRows = F, skipEmptyCols = F)
    ss <- openxlsx::readWorkbook(xlsxFile = fname, sheet = sheets[4], skipEmptyRows = F, skipEmptyCols = F)
    
    ot <- paste0(ot, '<p>Number of Sites : ', nrow(ss), '</p><p>Number of Horizons : ', nrow(hs), '</p>')
    
    if(nrow(bbox)==0){
      ot <- paste0(ot, '<p>No site locations have been recorded</p>')
      ol$HasLocs=F
    }else{
      ot <- paste0(ot, '<p>Minimum Longitude : ', bbox$minx, '</p><p>Maximum Longitude : ', bbox$maxx, '</p>')
      ot <- paste0(ot, '<p>Minimum Latitude : ', bbox$miny, '</p><p>Maximum Latitude : ', bbox$maxy, '</p>')
      ol$HasLocs=T
    }
    
    ol$html <- ot
    ol$locs <- getProjectLocationInfo(con, keys$AgencyCode, keys$ProjectCode)
    
    return(ol)
  })
  
}
  return(ig)
}





