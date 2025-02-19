
library(R6)


dbElement <- R6Class("dbElement", 
                     
                     public <- list(
                       row=NULL,
                       col=NULL,
                       type=NULL,
                       val=NULL,
                       dbTable=NULL,
                       dbField=NULL,
                       getInfo = function()
                       {
                         
                       },
                       initialize = function(row = NA, col=NA, type=NA, val=NA, dbTable=NA, dbField=NA ) {
                         self$row <- row
                         self$col <- col
                         self$type <- type
                         self$val <- val
                         self$dbTable <- dbTable
                         self$dbField <- dbField
                       }
                     )
)


get_IngestHelpers <- function()
{
  H <- list()
  
  
  tnames <- c('HORIZONS', 'COLOURS', 'MOTTLES', 'COARSE_FRAGS', 'STRUCTURES', 'SEGREGATIONS', 'STRENGTHS', 'CUTANS', 'PANS', 'ROOTS', 'PHS')
  tfids  <- c('h_no', 'col_no', 'mott_no', 'cf_no', 'str_no', 'seg_no', 'strg_no', 'cutan_no', 'pan_no', 'root_no', 'ph_no')
  tkeys <- data.frame(tableName=tnames, fid=tfids)
  
  H$ImportKeys <- tkeys

      H$getExcelFormInfo <- function(fname=NULL){
        
        #dbFlds <<- as.data.frame(suppressMessages(read_excel(fname, sheet = 'DBInfo', col_names = F)))
        dbFlds <- openxlsx::readWorkbook(xlsxFile = fname, sheet='DBInfo', skipEmptyRows=F, skipEmptyCols = F)
        
        odf<- data.frame()
        iflds <- c('S#', 'H#', 'K#')
        for (i in 1:nrow(dbFlds)) {
          for (j in 1:ncol(dbFlds)) {
            v <- dbFlds[i,j]
            
            if(!is.na(v)){
              s <- str_sub(v, 1,2)
              if(s %in% iflds){
                bits <- str_split(v, '#')
                rdf <- data.frame(row=i, col=j, formRegion=bits[[1]][1], tableName=bits[[1]][2], dbFld=bits[[1]][3], recNum=bits[[1]][4], recSubNum=bits[[1]][5], required=bits[[1]][6])
                odf <- rbind(odf, rdf)
              }
            }
          }
        }
        
        
        idxs <- which(odf$required=='')
        odf$required[idxs] <- NA
        return(odf)
      }


      H$makeSQLFromForm <- function(sheet, formRegion, tableName){
        
        recs <- excelInfo[excelInfo$formRegion==formRegion & excelInfo$tableName==tableName,]
        keys <- excelInfo[excelInfo$formRegion=='K',]
        tabLev <- tableLevels[tableLevels$Table==tableName, ]$Level
        
       
        
        if(tabLev==1){
          keyRows <- keys[c(1:3),]
        }else if(tabLev==2){
          keyRows <- keys[c(1:4),]
        }
        
        recs <- rbind(keyRows, recs)
        
        elements <- vector(mode='list', length = nrow(recs))
        
        for (i in 1:nrow(recs)) {
          formRec <- recs[i,]
          e <- OS$IngestHelpers$makeDBElement(formRec=formRec, dataSheet = sheet)
          elements[[i]] <- e
        }
        
        #### Hack to get obs date from Site date
        if(str_to_upper(tableName)=='OBSERVATIONS'){
          ObsDate=sheet[8,2]
          de <- dbElement$new(row=8, col=2, type='TEXT', val = ObsDate, dbTable = tableName, dbField = 'o_date_desc')
          elements[[nrow(recs)+1]] <- de
        }
        
        
        elements <- elements[!unlist(lapply(elements,is.null))]
        
        if(length(elements) > 0){
          sql <- OS$IngestHelpers$makeSQL(tableName, elements)
          return(sql)
        }else{
          return(NULL)
        }
      }
      
      
      H$makeHorizonsSQLFromForm <- function(sheet, formRegion, tableName, horizonNum, subrecNum){
        
        recs <- excelInfo[excelInfo$formRegion==formRegion & excelInfo$tableName==tableName & excelInfo$recNum==horizonNum & excelInfo$recSubNum==subrecNum,]
        keys <- excelInfo[excelInfo$formRegion=='K',]
        tabLev <- tableLevels[tableLevels$Table==tableName, ]$Level
        
        
        
        if(tabLev==1){
          keyRows <- keys[c(1:3),]
        }else if(tabLev==2){
          keyRows <- keys[c(1:4),]
        }else if(tabLev==3){
          keyRows <- keys[c(1:4),]
          fn <- OS$IngestHelpers$ImportKeys[OS$IngestHelpers$ImportKeys$tableName==tableName,]$fid
          keyRows[nrow(keyRows)+1,] <- c(row=-1, col=0, formRegion='H',tableName=tableName, dbFld=fn, recNum=horizonNum, recSubNum=subrecNum, required='')
        }else if(tabLev==4){
          keyRows <- keys[c(1:4),]
          fn1 <- OS$IngestHelpers$ImportKeys[OS$IngestHelpers$ImportKeys$tableName=='HORIZONS',]$fid
          keyRows[nrow(keyRows)+1,] <- c(row=-1, col=0, formRegion='H',tableName='HORIZONS', dbFld=fn1, recNum=horizonNum, recSubNum=subrecNum, required='')
          fn2 <- OS$IngestHelpers$ImportKeys[OS$IngestHelpers$ImportKeys$tableName==tableName,]$fid
          keyRows[nrow(keyRows)+1,] <- c(row=-2, col=0, formRegion='H',tableName=tableName, dbFld=fn2, recNum=horizonNum, recSubNum=subrecNum, required='')
        }
        
        recs <- rbind(keyRows, recs)
        
        elements <- vector(mode='list', length = nrow(recs))
        
        for (i in 1:nrow(recs)) {
          formRec <- recs[i,]
          e <- OS$IngestHelpers$makeDBElement(formRec=formRec, dataSheet = sheet)
          elements[[i]] <- e
        }
        
        elements <- elements[!unlist(lapply(elements,is.null))]
        if(length(elements) > nrow(keyRows)){
        #if(length(elements) > 0){
          sql <- OS$IngestHelpers$makeSQL(tableName, elements)
          return(sql)
        }else{
          return(NULL)
        }
      }
      
      
      
      
      
      H$makeDBElement <- function(formRec=NA, dataSheet){
        
        row <- as.numeric(formRec$row)
        col <- as.numeric(formRec$col)
        if(row== -1){
          val=formRec$recNum
        }else if(row== -2){
          val=formRec$recSubNum
        }else{
          val <- dataSheet[row, col]
        }
        
        
        if(!is.na(val)){
      
            Table <- formRec$tableName
            dbFld<- formRec$dbFld
          
            type <- dbInfo[str_to_lower(dbInfo$Table) == str_to_lower(Table) & 
                             str_to_lower(dbInfo$Field) == str_to_lower(dbFld),]$Type
            if(str_detect(formRec$dbFld, 'depth')){
              val <- as.numeric(val)/100
            }
            de <- dbElement$new(row=row, col=col, type=type, val = val, dbTable = Table, dbField = dbFld)
            
          return(de)
        }else{
            return(NULL)
        }
      }
      
      
      
      
      H$makeSQL <- function(tableName, elements, hNum=NULL, subhNum=NULL ){
        
        sqlFlds <- elements
        
        tf = paste0("INSERT into ", tableName, " ( ")
        tv = " VALUES ("
        
        for (k in 1:length(sqlFlds)) {

          e <- sqlFlds[[k]]
          f <- e$dbField
          v <- e$val
          
            tf <- paste0(tf, " ",  f, ",")
            type <- e$type
              
              if(type=='TEXT'){
              tv <- paste0(tv, " '", v, "',")
            }else{
              tv <- paste0(tv, " ", v, ",")
            }
        }
        
        # if(!is.null(hNum)){
        #   
        # }
        
        ### Some hacks to match DB schema rules
        if(str_to_upper(tableName)=='SITES'){
          tf <- paste0(tf, " s_trans_date")
          dt <- str_remove_all(Sys.Date(), '-')
          tv <- paste0(tv, " '", dt, "'")
        }
        
        
        tv <- trimws(tv, whitespace = ",")
        tf <- trimws(tf, whitespace = ",")
        
        sql <- paste0(tf, ') ', tv, ')')
      }
      
      
      # H$checkXLLabDataFileFormat <- function(fname){
      #   
      #   ol <- list()
      #   
      #   ext <- tools::file_ext(fname)
      #   
      #   if(ext!='xlsx'){
      #     ol$OK<-F
      #     ol$Message <-paste0('<P style="color:red;">You need to upload an MS Excel spreadsheet with a specific data entry template.</P>
      #                          <P>You can download the required template from the link above.</P>')
      #     return(ol)
      #   }
      #   
      #   wb <- openxlsx::loadWorkbook (xlsxFile = fname)
      #   sheets <- names(wb)
      #   
      # 
      #     idxs <- na.omit(match(c('Lab Data',"About", "Filled Example" ), sheets))
      #     if(length(idxs) != 3){
      #       ol$OK<-F
      #       ol$Message <-paste0('<P style="color:red;">It looks like the file you have uploaded is not the required MS Excel Lab Data Sheet template.</P>
      #                                <P>You can download the required template from the link below.</P>')
      #       return(ol)
      #     }
      #     if(length(sheets) == 7){
      #       ol$OK<-F
      #       ol$Message <-paste0('<P>The data entry template does not contain any sites to ingest.</P>')
      #       return(ol)
      #     }
      # 
      #     ld <- openxlsx::readWorkbook(xlsxFile = fname, sheet='Lab Data', skipEmptyRows=F, skipEmptyCols = F)
      #     nsites <- unique(ld$SiteID)
      #     nhoriz <- nrow(ld)
      #     nmeth = ncol(ld)-8
      #     ol$Message <-paste0('<p><b>Upload Info</b></p>',
      #                         '<p><b>Number of Sites : </b>', nsites, '</p>',
      #                         '<p><b>Number of Horizons : </b>', nhoriz, '</p>',
      #                         '<p><b>Number of Lab Methods : </b>', nmeth, '</p>')
      #   
      #   
      #   ol$OK = TRUE
      #   return(ol)
      #   
      # }



      
      
      
      H$makeRecordINSERT <- function(table, rec){
        p1 <- paste0('INSERT into ', table, ' (')
        p2 <- paste0(' VALUES (')
        
        fnames <- colnames(rec)
        for (i in 1:length(fnames)) {
          
          f <- fnames[i]
          v <- rec[i]
          if(f != 'samp_barcode'){
              if(!is.na(v)){
                p1 <- paste0(p1, ' "', f, '",' )
                tp <- dbInfo[dbInfo$Table==table & dbInfo$Field==f, ]$Type
                if(tp=='TEXT'){
                  p2 <- paste0(p2, " '", v, "',")
                }else{
                  p2 <- paste0(p2, " ", v, ",")
                }
              }
          }
        }
        
        p1 <- trimws(p1, whitespace = ",")
        p2 <- trimws(p2, whitespace = ",")
        
        sql <- paste0(p1, ') ', p2, ')')

        return(sql)
      }
      
      
      
      
      
      
      ###.####
      ### ^ Check Excel file formats  ####
      
      H$checkXLFileFormat <- function(fname, uploadType){
        
        ol <- list()
        
        ext <- tools::file_ext(fname)
        
        if(ext!='xlsx'){
          ol$OK<-F
          ol$Message <-paste0('<P>You need to upload an MS Excel spreadsheet with a specific data entry template.</P>
                               <P>You can download the required template from the link above.</P>')
          return(ol)
        }
        
        wb <- openxlsx::loadWorkbook (xlsxFile = fname)
        sheets <- names(wb)
        
        idxs <- na.omit(match(OS$Constants$Sheetnames, sheets))
        if(length(idxs) != 8){
          ol$OK<-F
          ol$Message <-paste0('<P>It looks like the file you have uploaded is not the required MS Excel Site Data Sheet template.</P>
                                     <P>You can download the required template from the link in the top left corner of the "Morphology Data Ingestion" tab')
          return(ol)
        }else{
          
          
          
          if(uploadType == OS$Constants$UploadTypes$Morphology_Data){
            
            if(length(sheets) == 8){
              ol$OK<-F
              ol$Message <-paste0('<P>The data entry template does not contain any sites to ingest.</P>')
              return(ol)
            }
            
            siteSheets <- sheets[-idxs]
            ps <- siteSheets[1]
            dataSheet <- openxlsx::readWorkbook(xlsxFile = fname, sheet = 9, skipEmptyRows = F, skipEmptyCols = F)
            
            
            agencyCode=dataSheet[4,2]
            projCode=dataSheet[5,2]
            
            ol$OK<-T
            ol$Message <-paste0('<p><b>Upload Info</b></p>',
                                '<p><b>Agency Code : </b>', agencyCode, '</p>',
                                '<p><b>Project Code : </b>', projCode, '</p>',
                                '<p><b>No. Sites : </b>', length(siteSheets), '</p>'
            )
            return(ol)
          }else if(uploadType == OS$Constants$UploadTypes$Lab_Data){
            
            ol$OK<-T
            ol$Message <-paste0('<p><b>Lab Data</b></p>')
            return(ol)
            
          }else if(uploadType == OS$Constants$UploadTypes$Photos){
            
            
            dataSheet <- openxlsx::readWorkbook(xlsxFile = fname, sheet = 'Photos', skipEmptyRows = F, skipEmptyCols = F)
            
            colNames <- dataSheet[2,1:8]
            idxs <- na.omit(match(OS$Constants$RequiredPhotoFields, colNames))
            
            if(length(idxs) != 8){
              ol$OK<-F
              ol$Message <-paste0('<P>It looks like the file you have uploaded is not the required MS Excel Site Data Sheet template.</P>
                                     <P>You can download the required template from the link in the top left corner of the "Morphology Data Ingestion" tab')
              return(ol)
            }
            
            numPhotos = nrow(dataSheet)-2
            numSites = length(unique(dataSheet[3:nrow(dataSheet),3]))
            agencyCode = dataSheet[3,1]
            projCode = dataSheet[3,2]

            ol$OK<-T
            
            ol$Message <- paste0('The Data Entry Spreadsheet contains ', numPhotos, ' photo records across ', numSites, ' sites. 
                                  Now drag the corresponding image files to the file upload box below.<BR><BR>')
            
            # ol$Message <- paste0('<p><b>Upload Info</b></p>',
            # 
            #                      '<p><b>Agency Code : </b>', agencyCode, '</p>',
            #                      '<p><b>Project Code : </b>', projCode, '</p>',
            #                      '<p><b>No. Sites : </b>', numSites, '</p>',
            #                      '<p><b>No. Photos: </b>', numPhotos, '</p>')

            
            
            return(ol)
          }
        }
      }
      
      
      
      
      

return(H)
}

