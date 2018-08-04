SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


 /****** Change Log ***********

 3/14/2017 - created by AMeitin to populate Patron__c object in Salesforce
			
			I used the version on OleMiss_Integration as my starting point but changed all references 
			to SSB_CRMSYSTEM_ACCT_ID to SSB_CRMSYSTEM_CONTACT_ID and dbo.Account to dbo.Contact

			I commented out the Left Join to prodcopy.patron__c and the where clause that referenced this 
			bc they do not exist on Stanford
 *******************************/


CREATE VIEW [dbo].[vwCRMLoad_Custom_Patron]
AS
SELECT DISTINCT a.[crm_id] Account__c, a.[SSB_CRMSYSTEM_Contact_ID] SSB_CRMSYSTEM_CONTACT_ID__c,dimcust.[SSID] Patron_ID__c
FROM dbo.[vwDimCustomer_ModAcctId] dimcust WITH (NOLOCK)
JOIN dbo.[Contact] a WITH (NOLOCK) ON dimcust.[SSB_CRMSYSTEM_CONTACT_ID] = a.[SSB_CRMSYSTEM_CONTACT_ID] 
LEFT JOIN prodcopy.patron__c z WITH (NOLOCK) ON dimcust.ssid = z.patron_id__c AND z.isdeleted = 0
LEFT JOIN prodcopy.account acct WITH (NOLOCK) ON acct.id = a.crm_id AND acct.IsDeleted = 0
WHERE dimcust.[SourceSystem] = 'Stanford_TI' 
AND a.[SSB_CRMSYSTEM_CONTACT_ID] <> [a].[crm_id]
AND (z.id IS NULL OR (acct.id <> z.account__c OR  a.SSB_CRMSYSTEM_CONTACT_ID <> z.SSB_CRMSYSTEM_CONTACT_ID__c) )
AND acct.id IS NOT null



GO
