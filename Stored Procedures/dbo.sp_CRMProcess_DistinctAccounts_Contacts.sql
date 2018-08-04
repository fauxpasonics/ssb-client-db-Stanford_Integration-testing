SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE PROCEDURE [dbo].[sp_CRMProcess_DistinctAccounts_Contacts]
AS
--SELECT * 
--INTO stg.DistinctAccount_Saved_20150226
--FROM dbo.SFDCProcess_DistinctAccounts

-- Create Main Transaction Records Table
SELECT *
INTO #tmpTrans
FROM dbo.vwCRMProcess_CRMQualify_Transactions
-- DROP TABLE #tmpTrans
--SELECT * FROM #tmpTrans


CREATE INDEX idx_Trans_Acct_ID ON [#tmpTrans] ([SSB_CRMSYSTEM_ACCT_ID])
CREATE INDEX idx_Trans_Contact_ID ON [#tmpTrans] ([SSB_CRMSYSTEM_CONTACT_ID])

-- Create Activities/Notes Table
--SELECT b.SSB_CRMSYSTEM_ACCT_ID, b.SSB_CRMSYSTEM_CONTACT_ID, CASE WHEN Type LIKE '%Sixers%' THEN 'Sixers' ELSE 'Devils' END Brand, COUNT(*) RecordCount
--INTO #tmpActivity
--FROM PSP.dbo.vwDimCustomer_ModAcctId b
--INNER JOIN dbo.OtherSSIDsToBeLoaded c ON b.SSID = c.SSID
--GROUP BY b.SSB_CRMSYSTEM_ACCT_ID, b.SSB_CRMSYSTEM_CONTACT_ID, CASE WHEN Type LIKE '%Sixers%' THEN 'Sixers' ELSE 'Devils' END
---- Drop Table #tmpActivity

-- Create STH Table
SELECT b.SSB_CRMSYSTEM_ACCT_ID, b.SSB_CRMSYSTEM_CONTACT_ID
, b.SourceSystem
, COUNT(*) Count 
INTO #tmpSTHs
-- Select *
FROM stg.CRMProcess_SeasonTicketHolders_SSIDs a
INNER JOIN [dbo].[vwDimCustomer_ModAcctId] b ON b.SSID = a.SSID and b.SourceSystem = 'Stanford_TI'
GROUP BY b.SSB_CRMSYSTEM_ACCT_ID, b.SSB_CRMSYSTEM_CONTACT_ID, b.SourceSystem
-- DROP TABLE #tmpSTHs
-- SELECT * FROM #tmpSTHs

-- Bring in CRMRecords
SELECT b.SSB_CRMSYSTEM_ACCT_ID, b.SSB_CRMSYSTEM_CONTACT_ID, SourceSystem, COUNT(*) Count
INTO #tmpCRMRecords
-- Select *
FROM dbo.vwDimCustomer_ModAcctId b 
WHERE b.SourceSystem NOT LIKE 'Lead%' 
AND (SourceSystem LIKE '%CRM%' OR SourceSystem LIKE '%SFDC%' 
		)
AND [b].[SSB_CRMSYSTEM_ACCT_ID] IS NOT NULL
--AND b.SSID IN (SELECT contactid FROM ProdCopy.[vw_Contact])
GROUP BY b.SSB_CRMSYSTEM_ACCT_ID, b.SSB_CRMSYSTEM_CONTACT_ID, SourceSystem
--DROP TABLE [#tmpCRMRecords]
--SELECT * from #tmpCRMRecords

CREATE INDEX idx_CRM_Acct_ID ON [#tmpCRMRecords] ([SSB_CRMSYSTEM_ACCT_ID])
CREATE INDEX idx_CRM_Contact_ID ON [#tmpCRMRecords] ([SSB_CRMSYSTEM_CONTACT_ID])

-- CREATE Branding Table ** ACCOUNT LEVEL w/ Transaction Level
TRUNCATE TABLE stg.Distinct_Accounts

INSERT INTO stg.Distinct_Accounts ([SSB_CRMSYSTEM_ACCT_ID])
SELECT DISTINCT [SSB_CRMSYSTEM_ACCT_ID] FROM [#tmpTrans] WHERE [SSB_CRMSYSTEM_ACCT_ID] IS NOT NULL
UNION SELECT DISTINCT [SSB_CRMSYSTEM_ACCT_ID] FROM [#tmpSTHs] WHERE [SSB_CRMSYSTEM_ACCT_ID] IS NOT NULL
UNION SELECT DISTINCT [SSB_CRMSYSTEM_ACCT_ID] FROM [#tmpCRMRecords] WHERE [SSB_CRMSYSTEM_ACCT_ID] IS NOT NULL

UPDATE a
SET [MaxTransDate] = trans.[MaxTransDate]
, STH = CASE WHEN ISNULL(sth.[Count],0) > 0 THEN 1 ELSE 0 END
, CRM = CASE WHEN ISNULL(crm.[Count],0) > 0 THEN 1 ELSE 0 END	
FROM stg.[Distinct_Accounts] a
LEFT JOIN (SELECT [SSB_CRMSYSTEM_ACCT_ID], MAX([MaxTransDate]) MaxTransDate FROM [#tmpTrans] GROUP BY [SSB_CRMSYSTEM_ACCT_ID]) trans ON [trans].[SSB_CRMSYSTEM_ACCT_ID] = [a].[SSB_CRMSYSTEM_ACCT_ID]
LEFT JOIN (SELECT [SSB_CRMSYSTEM_ACCT_ID], Sum(ISNULL(Count,0)) Count FROM [#tmpSTHs] GROUP BY [SSB_CRMSYSTEM_ACCT_ID]) sth ON [sth].[SSB_CRMSYSTEM_ACCT_ID] = [a].[SSB_CRMSYSTEM_ACCT_ID]
LEFT JOIN (SELECT [SSB_CRMSYSTEM_ACCT_ID], Sum(ISNULL(Count,0)) Count FROM [#tmpCRMRecords] GROUP BY [SSB_CRMSYSTEM_ACCT_ID]) crm ON [crm].[SSB_CRMSYSTEM_ACCT_ID] = [a].[SSB_CRMSYSTEM_ACCT_ID]

--SELECT * FROM stg.[Distinct_Accounts]

-- distinct contacts
TRUNCATE TABLE [stg].[Distinct_Contacts]

INSERT INTO [stg].[Distinct_Contacts] ([SSB_CRMSYSTEM_ACCT_ID], [SSB_CRMSYSTEM_CONTACT_ID])
SELECT DISTINCT [SSB_CRMSYSTEM_ACCT_ID], [SSB_CRMSYSTEM_CONTACT_ID] FROM [#tmpTrans] WHERE [SSB_CRMSYSTEM_ACCT_ID] IS NOT NULL

UNION SELECT DISTINCT [SSB_CRMSYSTEM_ACCT_ID], [SSB_CRMSYSTEM_CONTACT_ID] FROM [#tmpSTHs] WHERE [SSB_CRMSYSTEM_ACCT_ID] IS NOT NULL

UNION SELECT DISTINCT [SSB_CRMSYSTEM_ACCT_ID], [SSB_CRMSYSTEM_CONTACT_ID] FROM [#tmpCRMRecords] WHERE [SSB_CRMSYSTEM_ACCT_ID] IS NOT NULL 

		and SSB_CRMSYSTEM_CONTACT_ID NOT IN (
'25D5FC98-7C02-40DE-A693-10AF95230F84',
'2800FA22-4DD7-4CBA-887E-47CA3E2C2AD8',
'46812993-E290-4006-B5B1-C92EA3CE7272',
'4BFD4447-435F-4D14-8255-6B37A019F612',
'63BAFD0C-E559-48A8-9004-1A10B8F090D3',
'6CC0E28A-922E-443E-B21C-83C214D0E547',
'C15F7506-5F55-4082-B9A0-0A2F6CC51BE9'
)


		SELECT ssb_crmsystem_contact_id, COUNT(*) FROM #tmpCRMRecords GROUP BY SSB_CRMSYSTEM_CONTACT_ID HAVING COUNT(*) > 1


UPDATE a
SET [MaxTransDate] = trans.[MaxTransDate]
, STH = CASE WHEN ISNULL(sth.[Count],0) > 0 THEN 1 ELSE 0 END
, CRM = CASE WHEN ISNULL(crm.[Count],0) > 0 THEN 1 ELSE 0 END	
FROM stg.[Distinct_Contacts] a
LEFT JOIN [#tmpTrans] trans ON [trans].[SSB_CRMSYSTEM_CONTACT_ID] = [a].[SSB_CRMSYSTEM_CONTACT_ID]
LEFT JOIN [#tmpSTHs] sth ON [sth].[SSB_CRMSYSTEM_CONTACT_ID] = [a].[SSB_CRMSYSTEM_CONTACT_ID]
LEFT JOIN [#tmpCRMRecords] crm ON [crm].[SSB_CRMSYSTEM_CONTACT_ID] = [a].[SSB_CRMSYSTEM_CONTACT_ID]

SELECT a.SSB_CRMSYSTEM_ACCT_ID
, a.MaxTransDate
, a.STH
, c.SeasonTicket_Years
, CRM
-- Select *
INTO #tmp_Results_Acct
FROM stg.Distinct_Accounts a 
LEFT JOIN dbo.CRMProcess_Acct_SeasonTicketHolders c ON c.SSB_CRMSYSTEM_ACCT_ID = a.SSB_CRMSYSTEM_ACCT_ID

--for contacts
SELECT a.SSB_CRMSYSTEM_ACCT_ID
,a.SSB_CRMSYSTEM_CONTACT_ID
, a.MaxTransDate
, a.STH
, c.SeasonTicket_Years
, CRM
--, *
INTO #tmp_Results_Contact
FROM stg.Distinct_Contacts a 
LEFT JOIN dbo.CRMProcess_Contact_SeasonTicketHolders c ON c.SSB_CRMSYSTEM_CONTACT_ID = a.SSB_CRMSYSTEM_CONTACT_ID



TRUNCATE TABLE dbo.CRMProcess_DistinctAccounts

INSERT INTO dbo.CRMProcess_DistinctAccounts
SELECT *
, 0 CriteriaMet
FROM #tmp_Results_Acct

UPDATE a
SET CRMLoadCriteriaMet = 1
--SELECT *
FROM dbo.[CRMProcess_DistinctAccounts] a 
WHERE MaxTransDate IS NOT NULL
OR CRM = 1
--OR STH = 1



TRUNCATE TABLE dbo.CRMProcess_DistinctContacts

INSERT INTO dbo.CRMProcess_DistinctContacts
SELECT *
, 0 
FROM #tmp_Results_Contact

UPDATE a
SET CRMLoadCriteriaMet = 1
FROM dbo.[CRMProcess_DistinctContacts] a 
WHERE MaxTransDate IS NOT NULL
OR CRM = 1
--OR STH = 1

--SELECT * FROM dbo.[CRMProcess_DistinctAccounts]
--SELECT * FROM [dbo].[CRMProcess_DistinctContacts]



GO
