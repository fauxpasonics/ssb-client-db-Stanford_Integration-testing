SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_CRMLoad_MarketingTransactions_Prep]
AS 

TRUNCATE TABLE stg.CRMLoad_MarketingTransactions

INSERT INTO stg.CRMLoad_MarketingTransactions
SELECT DISTINCT
CONVERT(VARCHAR(40), mt.activity_date__c, 126) Activity_date__c
,CAST(mt.Subject__c					   AS VARCHAR(55)) Subject__c
,CAST(mt.Description__c				   AS VARCHAR(8000)) Description__c
,CAST(mt.primarykey  AS VARCHAR(8000)) primarykey
,a.[id] What__c
,pcc.Id  who__c
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

TRUNCATE TABLE [dbo].[MarketingActivity_ErrorOutput]

GO
