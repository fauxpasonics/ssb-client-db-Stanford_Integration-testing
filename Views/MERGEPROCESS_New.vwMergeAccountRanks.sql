SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [MERGEPROCESS_New].[vwMergeAccountRanks]

AS

SELECT a.SSBID
	, c.ID
	--Add in custom ranking here
	,ROW_NUMBER() OVER(PARTITION BY SSBID ORDER BY CASE WHEN d.FirstName = 'ETL' THEN 0 
														WHEN d.FirstName = 'Stanford' THEN 0
														WHEN d.IsActive = 0 THEN 1 ELSE 99 
														END DESC, c.LastActivityDate DESC) xRank
FROM MERGEPROCESS_New.DetectedMerges a with (nolock)
JOIN mergeprocess_new.tmp_dimcust b with (nolock)
	ON a.SSBID = b.SSB_CRMSYSTEM_CONTACT_ID
	AND a.MergeType = 'Account'
JOIN mergeprocess_new.tmp_pcaccount c with (nolock)
	ON b.SSID = ID
JOIN [ProdCopy].[vw_User] d-- order by 5
	ON c.OwnerId = d.Id
WHERE MergeComplete = 0;



GO
