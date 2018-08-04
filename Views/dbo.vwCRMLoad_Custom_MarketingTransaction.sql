SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





/********* CHANGE LOG ***********************
3/14/2017 - created by AMEITIN

			I used UMICH's version of this as the starting point
			I deleted the join to dbo.Account because Stanford's model does not use this
			I commented out the join to prodcopy.MarketingActivity because I wasn't sure what this is doing
			and if prodcopy.Marketing_Activity__c is the correct table

3/31/17 - modified by TFRANCIS

			Put back in the logic to join to prodcopy to assure we don't push dupes.
			Also added in the who__c column.

4/7/17 - modified by AMEITIN

			Added a.PersonContactId to Who__c AND ISNULL(pcc.Id, a.PersonContactId) IS NOT NULL to the where clause to 
			remove business accounts that do not have a contact
			Changed dbo.contact to ProdCopy.Account to get to What__c
*********************************************/


CREATE VIEW [dbo].[vwCRMLoad_Custom_MarketingTransaction]
AS

SELECT DISTINCT
CONVERT(VARCHAR(40), mt.activity_date__c, 126) Activity_date__c
,CAST(mt.Subject__c					   AS VARCHAR(55)) Subject__c
,CAST(mt.Description__c				   AS VARCHAR(8000)) Description__c
,CAST(mt.primarykey  AS VARCHAR(8000)) primarykey
,a.Id What__c
,ISNULL(pcc.Id, a.PersonContactId)  who__c
FROM Stanford.dbo.vwCRMLoad_MarketingTransactions mt WITH (NOLOCK)
INNER JOIN dbo.[vwDimCustomer_ModAcctId] dimcust WITH (NOLOCK) ON mt.SSB_CRMSYSTEM_CONTACT_ID = [dimcust].SSB_CRMSYSTEM_CONTACT_ID
LEFT JOIN dbo.[Contact] c WITH (NOLOCK) ON [c].[SSB_CRMSYSTEM_CONTACT_ID] = [dimcust].[SSB_CRMSYSTEM_CONTACT_ID]
LEFT JOIN prodcopy.marketing_activity__c z WITH (NOLOCK) ON z.adobe_primarykey__c = CAST(mt.primarykey  AS VARCHAR(8000))
LEFT JOIN prodcopy.Account a ON a.id = c.crm_id AND a.IsDeleted = 0
LEFT JOIN prodcopy.contact pcc ON a.PersonContactId = pcc.Id AND pcc.IsDeleted = 0
WHERE 1=1
AND c.[SSB_CRMSYSTEM_CONTACT_ID] <> c.[crm_id]
AND (z.adobe_primarykey__c IS NULL OR (z.activity_date__c <> CONVERT(VARCHAR(40), mt.activity_date__c, 126) OR z.subject__c <> CAST(mt.Subject__c					   AS VARCHAR(55))
	OR z.description__c <> CAST(mt.Description__c				   AS VARCHAR(8000)) OR z.what__c <> c.crm_id OR z.who__c != pcc.id ))
AND a.Id IS NOT NULL
AND ISNULL(pcc.Id, a.PersonContactId) IS NOT NULL
AND CONVERT(VARCHAR(40), mt.activity_date__c, 126) < '2017-01-01T00:01:00'







GO
