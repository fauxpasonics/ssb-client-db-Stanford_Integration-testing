SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vwCRMLoad_Contact_Custom_Update]
AS
SELECT  
	 CAST(cc.Id AS VARCHAR) Id
	,ISNULL(b.Email_Quarantine__pc, 0) Email_Quarantine__c
	,ISNULL(b.Adobe_Unsubscribe__pc, 0) Adobe_Unsubscribe__c
	,b.Email_Quarantine_Reason__pc  Email_Quarantine_Reason__c
	,b.Secondary_Email__pc	Secondary_Email__c
	,b.Preferred_Phone__pc  Preferred_Phone__c
	,b.Cell_Phone__pc		Cell_Phone__c
	,b.Business_Phone__pc	Business_Phone__c

FROM dbo.[vwCRMLoad_Account_Std_Prep] a
INNER JOIN dbo.Contact_Custom b ON [a].[ssb_crmsystem_Contact_ID__c] = b.ssb_crmsystem_Contact_ID
INNER JOIN dbo.Contact z ON a.[ssb_crmsystem_Contact_ID__c] = z.ssb_crmsystem_Contact_ID
INNER JOIN prodcopy.Contact CC ON z.CRM_ID = cc.AccountId
WHERE z.[SSB_CRMSYSTEM_Contact_ID] <> z.[crm_id]
AND (1=2

	OR ISNULL(b.Email_Quarantine__pc, 0) != ISNULL(Email_Quarantine__c,0)
	OR ISNULL(b.Adobe_Unsubscribe__pc, 0) != ISNULL(Adobe_Unsubscribe__c,0)
	OR isnull(b.Email_Quarantine_Reason__pc,'') != ISNULL(Email_Quarantine_Reason__c,'')
	OR isnull(b.Secondary_Email__pc,'') != ISNULL(Secondary_Email__c,'')
	OR isnull(b.Preferred_Phone__pc,'') != ISNULL(Preferred_Phone__c,'')
	OR isnull(b.Cell_Phone__pc,'')	!= ISNULL(Cell_Phone__c,'')
	OR isnull(b.Business_Phone__pc,'')	!= ISNULL(Business_Phone__c,'')
	)
GO
