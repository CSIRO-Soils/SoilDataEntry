################################################################# #
#####       Author : Ross Searle                              ###
#####       Date :  Fri Jan 24 07:40:46 2025                  ###
#####       Purpose : Function to populate  data tables into  ###
#####                 empty Natsoil container                 ###
#####       Comments :                                        ###
################################################################# #

library(DBI)

tables <- c('project.PROPOSED_SITES')

populateTables <- function(){
  
  a1 <- OS$DB$Config$getCon(OS$DB$Config$DBNames$NatSoilStageRO)$Connection
  a2 <- OS$DB$Config$getCon(OS$DB$Config$DBNames$NSMP_HoldingRW)$Connection
  

    df <- OS$DB$Helpers$doQuery(a1, paste0('select * from project.PROPOSED_SITES'))
    df2 <- OS$DB$Helpers$doQuery(a2, paste0('select * from project.PROPOSED_SITES'))
    df$ps_breadcrumbs<-NULL
    
   idxs <- which(!colnames(df) %in% colnames(df2))
   
   for(i in 1:nrow(df)){
      rec <- df[i, ]
      sql <- paste0("INSERT INTO project.PROPOSED_SITES (agency_code, proj_code, s_id, ps_token, sample_barcode_start) 
                      values ('", rec$agency_code, "', '", rec$proj_code, "', '", rec$s_id, "', '20250101', '", rec$pe_token , "')")
      OS$DB$Helpers$doInsert(a2, sql)
   }
   
   sql <- 'Delete from project.PROPOSED_SITES'
   OS$DB$Helpers$doInsert(a2, sql)

    #DBI::dbAppendTable(a2, '[project].PROPOSED_SITES', df[,-c(24, 25, 26)])
  }
}

makeCodeTableFromIndividualTables <- function(){

    a2 <- OS$DB$Config$getCon(OS$DB$Config$DBNames$NSMP_HoldingRW)$Connection
    alltbls <- DBI::dbListTables(a2)
    
    idxs <- which(grepl('^C_', alltbls))
    tbls <- alltbls[idxs]
    
    
    odf <- data.frame()
    for (i in 1:length(tbls)) {
      
       t <- tbls[i]
       print(t)
        
       df <- OS$DB$Helpers$doQuery(a2, paste0('select * from codes.', t))
       if(nrow(df) > 0){
           cd <- str_sub(t, 3, nchar(t))
           mdf <- cbind(cd, df)
           odf <- rbind(odf, mdf)
        }
    }
    
    
    idxs <- which(grepl('^N_', alltbls))
    tbls <- alltbls[idxs]
    for (i in 1:length(tbls)) {
      
      t <- tbls[i]
      print(t)
      
      df <- OS$DB$Helpers$doQuery(a2, paste0('select * from codes.', t))
      if(nrow(df) > 0){
        cd <- str_sub(t, 3, nchar(t))
        mdf <- cbind(cd, df)
        odf <- rbind(odf, mdf)
      }
    }
    
    nrow(odf)
    head(odf)
    
    colnames(odf)[1] <- 'field_name'
    
    c2 <- OS$DB$Config$getCon(OS$DB$Config$DBNames$AppDB)$Connection
    DBI::dbWriteTable(c2, 'NatSoil_UnifiedCodes', odf)
    
    dbDisconnect(c2)
    dbDisconnect(a2)
}





