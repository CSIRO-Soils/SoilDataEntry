SELECT nsmp.agency_code, nsmp.proj_code, nsmp.s_id, dbo.PublishedSites.s_id AS PublishedSite
FROM   dbo.SITES AS nsmp INNER JOIN
NatSoil.project.PROPOSED_SITES AS natProp ON nsmp.agency_code = natProp.agency_code AND nsmp.proj_code = natProp.proj_code AND nsmp.s_id = natProp.s_id LEFT OUTER JOIN
dbo.PublishedSites ON natProp.agency_code = dbo.PublishedSites.agency_code AND natProp.proj_code = dbo.PublishedSites.proj_code AND natProp.s_id = dbo.PublishedSites.s_id
WHERE (dbo.PublishedSites.s_id IS NULL)