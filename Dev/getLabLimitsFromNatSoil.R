



con <- OS$DB$Config$getCon(OS$DB$Config$DBNames$NatSoilStageRO)$Connection

sql <- 'Select Distinct LABM_CODE from LAB_METHODS'
sql <- 'SELECT labm_code, COUNT(labr_value) AS cnt FROM dbo.LAB_RESULTS GROUP BY labm_code'
lm <- OS$DB$Helpers$doQuery(con, sql)


odf <- data.frame()
for (i in 1:nrow(lm)) {
  
  rec <- lm[i,]
  print(i)
  sql <- paste0("Select labr_value from LAB_Results where labm_code='", rec$labm_code, "'" )
  vals <- OS$DB$Helpers$doQuery(con, sql)
  if(nrow(vals)>3){
      #hist(vals$labr_value)
      probs<-c(0, 0.05, 0.50, 0.95, 1)
      qts <- sprintf("%.5f", (quantile(vals$labr_value, probs, na.rm = T)))
      outRec <- c(labm_code=rec$labm_code, Count=rec$cnt, min=as.numeric(qts[1]),
                  LQ=as.numeric(qts[2]), mean=as.numeric(qts[3]), UQ=as.numeric(qts[4]), max=as.numeric(qts[5])
                  )
      odf <- rbind(odf, outRec)
  }
}

dbDisconnect(con)

colnames(odf) <- c('labm_code', 'Count', 'Min', 'LQ', 'Mean', 'UQ', 'Max')
odf1 <- odf[sort(order(odf$labm_code)),]
odf1$Count <- as.numeric(odf1$Count)
odf1$Min <- as.numeric(odf1$Min)
odf1$LQ <- as.numeric(odf1$LQ)
odf1$Mean <- as.numeric(odf1$Mean)
odf1$UQ <- as.numeric(odf1$UQ)
odf1$Max <- as.numeric(odf1$Max)

write.csv(odf1, 'C:/Users/sea084/OneDrive - CSIRO/RossRCode/Git/Shiny/Apps/SoilDataEntry/Dev/ChemLimits.csv')


con <- OS$DB$Config$getCon(OS$DB$Config$DBNames$AppDB)$Connection
dbWriteTable(con, 'LabLimits', odf1)




