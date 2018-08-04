SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CRMProcess_CRMID_Assign_Contact]
AS

--Reset crm_id where current crm_id is a deleted record

UPDATE c 
SET c.crm_id = SSB_CRMSYSTEM_Contact_ID
FROM dbo.Contact c
INNER JOIN prodcopy.account pcc
ON c.crm_id = pcc.Id
WHERE pcc.IsDeleted = 1

--remove salesforce_ids that are not in prodcopy joining on sf_id
UPDATE a
SET crm_id = a.SSB_CRMSYSTEM_Contact_ID
--SELECT COUNT(*)
FROM dbo.contact a
LEFT JOIN prodcopy.vw_Account b
ON a.[crm_id] = b.id
where b.id IS NULL

--remove salesforce_ids that are not in prodcopy joining on ssb_id
UPDATE a
SET [crm_id] = b.id
--SELECT COUNT(*)
FROM dbo.contact a
INNER JOIN (select cc.*, ROW_NUMBER() OVER(PARTITION BY SSB_CRMSYSTEM_Contact_ID__C ORDER BY CASE WHEN d.FirstName = 'ETL' THEN 0 WHEN d.IsActive = 0 THEN 1 ELSE 99 END DESC, cc.createddate) xRank FROM prodcopy.vw_account cc
			JOIN [ProdCopy].[vw_User] d-- order by 5
			ON cc.OwnerId = d.Id
	)b ON a.SSB_CRMSYSTEM_Contact_ID = b.SSB_CRMSYSTEM_Contact_ID__C
		AND b.xRank = 1
LEFT JOIN (SELECT crm_id FROM dbo.contact WHERE crm_id <> SSB_CRMSYSTEM_Contact_ID) c ON b.id = c.[crm_id]
WHERE isnull(a.[crm_id], '') != b.id
AND c.[crm_id] IS NULL

--Remove crm_id where no CRM/SF record exists in SSBID. Not sure if this is needed
--SELECT crm_id, c.ssb_crmsystem_contact_Id
--FROM dbo.contact c
--LEFT JOIN (SELECT ssb_crmsystem_contact_id FROM dbo.vwDimCustomer_ModAcctId  WITH (NOLOCK) WHERE SourceSystem = 'Stanford PC_SFDC Account' AND IsDeleted = 0) ssb
--ON ssb.ssb_crmsystem_contact_id = c.ssb_crmsystem_contact_id
--WHERE ssb.SSB_CRMSYSTEM_CONTACT_ID IS NULL AND crm_id != c.SSB_CRMSYSTEM_Contact_ID

UPDATE a
SET crm_ID =  b.ssid 
--SELECT COUNT(*)
FROM dbo.contact a
INNER JOIN dbo.vwdimcustomer_modacctid b ON a.SSB_CRMSYSTEM_Contact_ID = b.SSB_CRMSYSTEM_Contact_ID
LEFT JOIN (SELECT crm_id FROM dbo.contact WHERE crm_id <> SSB_CRMSYSTEM_Contact_ID) c ON b.ssid = c.[crm_id]
WHERE b.SourceSystem = 'Stanford PC_SFDC Account' AND ISNULL(a.crm_id, '') != b.ssid
AND c.[crm_id] IS NULL 
--AND a.crm_ID = a.SSB_CRMSYSTEM_ACCT_ID
--and a. ssb_CRMSYSTEM_ACCT_ID = '72C5A993-A611-4E4C-A2A2-6B9355E080A6'

UPDATE c
SET crm_id = dc.ssid
--SELECT c.crm_id, dc.SSID
from dbo.contact c
INNER JOIN dbo.vwDimCustomer_ModAcctId ssb
ON c.SSB_CRMSYSTEM_CONTACT_ID = ssb.SSB_CRMSYSTEM_CONTACT_ID
INNER JOIN dbo.vwDimCustomer_ModAcctId dc ON ssb.DimCustomerId = dc.DimCustomerId AND dc.isdeleted = 0
LEFT JOIN (SELECT crm_id FROM dbo.contact WHERE crm_id <> SSB_CRMSYSTEM_Contact_ID) z ON ssb.ssid = z.[crm_id]
WHERE dc.SourceSystem = 'Stanford PC_SFDC Account'
AND c.crm_id = ssb.SSB_CRMSYSTEM_CONTACT_ID
AND z.crm_id IS null



GO
