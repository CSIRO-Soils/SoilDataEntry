
conNSMPHolding <- OS$DB$Config$getCon(OS$DB$Config$DBNames$NSMP_HoldingRW)
AnsisCon <- conInfo$Connection

OS$DB$Helpers$doQuery(AnsisCon, 'select * from COLOURS')


OS$DB$Helpers$deleteWholeSite(AnsisCon, verbose=T, agencyCode = '994', projCode = 'NSMP', siteID = '1')
OS$DB$Helpers$deleteWholeSite(AnsisCon, verbose=T, agencyCode = '994', projCode = 'NSMP', siteID = '2')


sql <- "SELECT dbo.SITES.agency_code, dbo.SITES.proj_code, dbo.SITES.s_id, project.PROPOSED_SITES.ps_token
FROM   dbo.SITES RIGHT OUTER JOIN
project.PROPOSED_SITES ON dbo.SITES.agency_code = project.PROPOSED_SITES.agency_code AND dbo.SITES.proj_code = project.PROPOSED_SITES.proj_code AND dbo.SITES.s_id = project.PROPOSED_SITES.s_id
WHERE (project.PROPOSED_SITES.ps_token = N'Burnie')"

OS$DB$Helpers$doQuery(conInfo$Connection, sql)


cond <- OS$DB$Config$getCon(OS$DB$Config$DBNames$NSMP_HoldingRW)$Connection
OS$DB$Helpers$deleteAllData(cond)

dev <- OS$DB$Config$getCon(OS$DB$Config$DBNames$NatSoilDev)
OS$DB$Helpers$deleteAllData(con=dev$Connection)

OS$DB$Helpers$deleteAllData(con=dev$Connection)
OS$DB$Helpers$doExec(con=dev$Connection, paste0('DELETE from dbo.CSIS_Allowed_Sites'))
OS$DB$Helpers$doExec(con=dev$Connection, paste0('DELETE from dbo.SITE_ENVELOPE'))
OS$DB$Helpers$doExec(con=dev$Connection, paste0('DELETE from dbo.SITE_MNG_PRACS'))

OS$DB$Helpers$doQuery(con, paste0('select * from dbo.CSIS_Allowed_Sites'))

OS$DB$Helpers$deleteWholeSite(con=conNSMPHolding$Connection )

OS$DB$Helpers$deleteWholeSite(con=conNSMPHolding$Connection, verbose=F, agencyCode='994', projCode='NSMP', siteID='N5006' )



con <- OS$DB$Config$getCon(OS$DB$Config$DBNames$NatSoilStageRO)$Connection

sql <- 'Select Labm_code from LAB_METHODS'
lc <- OS$DB$Helpers$doQuery(con, sql)
write.csv(lc, 'c:/temp/codes.csv')


OS$DB$Helpers$deleteWholeSite(con=OS$DB$Config$getCon(OS$DB$Config$DBNames$NatSoilProjects)$Connection, verbose=F, agencyCode='994', projCode='SLAM', siteID='5' )


conNSMPNat <- OS$DB$Config$getCon(OS$DB$Config$DBNames$NatSoilDev )

OS$DB$Helpers$deleteWholeSite(con=conNSMPNat$Connection, verbose=F, agencyCode='994', projCode='NSMP', siteID='N2056' )




