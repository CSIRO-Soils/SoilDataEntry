
conInfo <- OS$DB$Config$getCon(OS$DB$Config$DBNames$NSMP_HoldingRW)
AnsisCon <- conInfo$Connection

OS$DB$Helpers$doQuery(AnsisCon, 'select * from COLOURS')


OS$DB$Helpers$deleteWholeSite(AnsisCon, verbose=T, agencyCode = '994', projCode = 'NSMP', siteID = '1')
OS$DB$Helpers$deleteWholeSite(AnsisCon, verbose=T, agencyCode = '994', projCode = 'NSMP', siteID = '2')


sql <- "SELECT dbo.SITES.agency_code, dbo.SITES.proj_code, dbo.SITES.s_id, project.PROPOSED_SITES.ps_token
FROM   dbo.SITES RIGHT OUTER JOIN
project.PROPOSED_SITES ON dbo.SITES.agency_code = project.PROPOSED_SITES.agency_code AND dbo.SITES.proj_code = project.PROPOSED_SITES.proj_code AND dbo.SITES.s_id = project.PROPOSED_SITES.s_id
WHERE (project.PROPOSED_SITES.ps_token = N'Burnie')"

OS$DB$Helpers$doQuery(conInfo$Connection, sql)


