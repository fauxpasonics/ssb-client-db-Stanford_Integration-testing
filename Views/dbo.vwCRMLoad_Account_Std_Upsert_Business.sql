SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






create VIEW [dbo].[vwCRMLoad_Account_Std_Upsert_Business] AS
SELECT --top 1

ssb_crmsystem_Contact_ID__c, a.Name ,a.Suffix, 
 BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, a.Phone, [LoadType]
 , CASE WHEN b.IsBusinessAccount = 1 THEN '012i0000000FBwbAAG' ELSE '012i0000000FCuwAAG' END RecordTypeId
FROM [dbo].[vwCRMLoad_Account_Std_Prep] a
JOIN dbo.Contact b ON a.ssb_crmsystem_Contact_ID__c = b.ssb_crmsystem_Contact_ID
WHERE LoadType = 'Upsert' AND b.IsBusinessAccount = 1







GO
