SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Created By: Abbey Meitin
-- Create Date: Before we started tracking
-- Reviewed By: Caeleon Work
-- Reviewed Date: 5-29-2018
-- Description: CRM Custom Contact Sproc
-- =============================================
 
/***** Revision History
 
Abbey Meitin: 2018/05/21 - Added Football Loyal Group Logic 
Caeleon Work: 2018/05/24 - Removed Truncate Table (not needed)
Abbey Meitin: 2018/05/24 - Added remaining sports group logic
Caeleon Work: 2018/05/29 - Reviewed added groups

*****/


CREATE PROCEDURE [wrk].[sp_Contact_Custom]
AS 

--TRUNCATE TABLE dbo.Contact_Custom;

MERGE INTO dbo.Contact_Custom Target
USING dbo.[Contact] source
ON source.[SSB_CRMSYSTEM_Contact_ID] = target.[SSB_CRMSYSTEM_Contact_ID]
WHEN NOT MATCHED BY TARGET THEN
INSERT ([SSB_CRMSYSTEM_Contact_ID]) VALUES (Source.[SSB_CRMSYSTEM_Contact_ID])
WHEN NOT MATCHED BY SOURCE THEN DELETE;

EXEC dbo.sp_CRMProcess_ConcatIDs 'Contact'

DECLARE @currentmemberyear int = (Select  datepart(year,getdate()))
					
DECLARE @previousmemberyear int = @currentmemberyear -1 


UPDATE a
SET SSID_Winner = b.SSID
, a.SSB_CRMSYSTEM_SSID_Winner_SourceSystem__c = b.SourceSystem
	,[AddressTwoStreet] = b.AddressTwoStreet
	,[AddressTwoCity] = b.AddressTwoCity
	,[AddressTwoState] = b.AddressTwoState
	,[AddressTwoZip] = b.AddressTwoZip
	,[AddressTwoCountry] = b.AddressTwoCountry
	,[AddressFourStreet] = b.AddressFourStreet
	,[AddressFourCity]	= b.AddressFourCity
	,[AddressFourState]	= b.AddressFourState
	,[AddressFourZip]	= b.AddressFourZip
	,[AddressFourCountry]	=b.AddressFourCountry
	,[Preferred_Phone__pc] = b.PhonePrimary
	,[Cell_Phone__pc] = b.PhoneCell
	,[Business_Phone__pc] = b.PhoneBusiness
	,[PersonHomePhone] = b.PhoneHome
	,[PersonOtherPhone] = b.PhoneOther
	,[PersonEmail] = CASE WHEN b.EmailOne LIKE '%@%' THEN b.EmailOne ELSE NULL END
	,[Business_Email__c] = CASE WHEN b.EmailOne LIKE '%@%' THEN b.EmailOne ELSE NULL END
	,[Secondary_Email__pc] = CASE WHEN b.EmailTwo LIKE '%@%' THEN b.EmailTwo ELSE NULL END
	,[PersonBirthdate] = b.Birthday

	
FROM [dbo].[Contact_Custom] a (NOLOCK)
INNER JOIN dbo.[vwCompositeRecord_ModAcctID] b ON b.[SSB_CRMSYSTEM_CONTACT_ID] = [a].[SSB_CRMSYSTEM_Contact_ID]
INNER JOIN dbo.[vwDimCustomer_ModAcctId] c ON b.[DimCustomerId] = c.[DimCustomerId] AND c.SSB_CRMSYSTEM_PRIMARY_FLAG = 1

UPDATE a
SET SeasonTicket_Years = recent.SeasonTicket_Years
FROM dbo.[Contact_Custom] a
INNER JOIN dbo.CRMProcess_DistinctContacts recent ON [recent].SSB_CRMSYSTEM_Contact_ID = [a].SSB_CRMSYSTEM_Contact_ID


SELECT b.[SSB_CRMSYSTEM_Contact_ID], b.SSID, b.[SourceSystem]
INTO #tmpSSID_ACCTGUID
FROM [dbo].[Contact_Custom] a
INNER JOIN dbo.[vwDimCustomer_ModAcctId] b ON [a].[SSB_CRMSYSTEM_Contact_ID] = b.[SSB_CRMSYSTEM_Contact_ID]
--DROP TABLE #tmpSSID_ACCTGUID

---------------------------------------------------------------------------------
----------------- PACIOLAN FIELDS -----------------------------------------------
---------------------------------------------------------------------------------

-- For Last_Ticket_Purchase_Date
UPDATE a
SET [SSB_CRMSYSTEM_Last_Ticket_Purchase_Date__c]= odet.Ticket_Date
FROM [dbo].[Contact_Custom] a (NOLOCK)
INNER JOIN (SELECT [b].[SSB_CRMSYSTEM_Contact_ID],MAX([I_DATE]) AS Ticket_Date FROM [Stanford].[dbo].[TK_ODET] a (NOLOCK)
			INNER JOIN dbo.[vwDimCustomer_ModAcctId] b ON [a].CUSTOMER = b.SSID AND b.SourceSystem = 'Stanford_TI'
			GROUP BY [b].[SSB_CRMSYSTEM_Contact_ID])odet
ON odet.[SSB_CRMSYSTEM_Contact_ID]=a.[SSB_CRMSYSTEM_Contact_ID] 

--Broker Flag
UPDATE a
SET [SSB_CRMSYSTEM_Broker_Flag__c] = CASE WHEN br.Broker_Flag IS NOT NULL THEN 1 ELSE 0 END
FROM [dbo].[Contact_Custom] a (NOLOCK)
INNER JOIN (SELECT [b].[SSB_CRMSYSTEM_Contact_ID], MAX(a.TYPE) AS Broker_Flag FROM [Stanford].[dbo].[TK_CUSTOMER] a (NOLOCK)
			INNER JOIN dbo.[vwDimCustomer_ModAcctId] b ON [a].CUSTOMER = b.SSID AND b.SourceSystem = 'Stanford_TI'
			WHERE a.TYPE IN ('BR1', 'BR2')
			GROUP BY [b].[SSB_CRMSYSTEM_Contact_ID])br
ON br.[SSB_CRMSYSTEM_Contact_ID]=a.[SSB_CRMSYSTEM_Contact_ID]


--Opponent Flag
UPDATE a
SET [SSB_CRMSYSTEM_Opponent_Flag__c] = CASE WHEN o.Opponent_Flag IS NOT NULL THEN 1 ELSE 0 END
FROM [dbo].[Contact_Custom] a (NOLOCK)
INNER JOIN (SELECT [b].[SSB_CRMSYSTEM_Contact_ID], MAX(a.TYPE) AS Opponent_Flag FROM [Stanford].[dbo].[TK_CUSTOMER] a (NOLOCK)
			INNER JOIN dbo.[vwDimCustomer_ModAcctId] b ON [a].CUSTOMER = b.SSID AND b.SourceSystem = 'Stanford_TI'
			WHERE a.TYPE = 'O'
			GROUP BY [b].[SSB_CRMSYSTEM_Contact_ID])o
ON o.[SSB_CRMSYSTEM_Contact_ID]=a.[SSB_CRMSYSTEM_Contact_ID]

--House Contact
UPDATE a
SET [SSB_CRMSYSTEM_HouseAccount_Flag__c] = CASE WHEN ha.HouseContact IS NOT NULL THEN 1 ELSE 0 END
FROM [dbo].[Contact_Custom] a (NOLOCK)
INNER JOIN (SELECT [b].[SSB_CRMSYSTEM_Contact_ID], MAX(a.TYPE) AS HouseContact FROM [Stanford].[dbo].[TK_CUSTOMER] a (NOLOCK)
			INNER JOIN dbo.[vwDimCustomer_ModAcctId] b ON [a].CUSTOMER = b.SSID AND b.SourceSystem = 'Stanford_TI'
			WHERE a.TYPE IN ('H', 'T')
			GROUP BY [b].[SSB_CRMSYSTEM_Contact_ID])ha
ON ha.[SSB_CRMSYSTEM_Contact_ID]=a.[SSB_CRMSYSTEM_Contact_ID]

--Visitor Flag
UPDATE a
SET [SSB_CRMSYSTEM_Visitor_Flag__c] = CASE WHEN v.Visitor_Flag IS NOT NULL THEN 1 ELSE 0 END
FROM [dbo].[Contact_Custom] a WITH (NOLOCK)
INNER JOIN (SELECT [b].[SSB_CRMSYSTEM_Contact_ID], MAX(a.TYPE) AS Visitor_Flag FROM [Stanford].[dbo].[TK_CUSTOMER] a WITH(NOLOCK)
			INNER JOIN dbo.[vwDimCustomer_ModAcctId] b  WITH(NOLOCK) ON [a].CUSTOMER = b.SSID AND b.SourceSystem = 'Stanford_TI'
			WHERE a.TYPE = 'V'
			GROUP BY [b].[SSB_CRMSYSTEM_Contact_ID])v
ON v.[SSB_CRMSYSTEM_Contact_ID]=a.[SSB_CRMSYSTEM_Contact_ID]

--Twitter Contact

UPDATE a
SET [Twitter_Account__c] = customer.PHONE
FROM [dbo].[Contact_Custom] a WITH (NOLOCK)
	INNER JOIN dbo.[vwDimCustomer_ModAcctId] b WITH (NOLOCK) ON b.SSB_CRMSYSTEM_CONTACT_ID = a.SSB_CRMSYSTEM_CONTACT_ID 
	JOIN Stanford.dbo.PD_PATRON_PHONE_TYPE customer WITH (NOLOCK) on customer.patron = b.SSID AND b.SourceSystem = 'Stanford_TI' 
where b.SSB_CRMSYSTEM_PRIMARY_FLAG = 1
and customer.PHONE_TYPE = '@'

--Facebook Contact

UPDATE a
SET [Twitter_Account__c] = customer.PHONE
FROM [dbo].[Contact_Custom] a WITH (NOLOCK)
	INNER JOIN dbo.[vwDimCustomer_ModAcctId] b WITH (NOLOCK) ON b.SSB_CRMSYSTEM_CONTACT_ID = a.SSB_CRMSYSTEM_CONTACT_ID 
	JOIN Stanford.dbo.PD_PATRON_PHONE_TYPE customer WITH (NOLOCK) ON  customer.patron = b.SSID AND b.SourceSystem = 'Stanford_TI' 
where b.SSB_CRMSYSTEM_PRIMARY_FLAG = 1
and customer.PHONE_TYPE = 'FB'

--Football STM
UPDATE a
SET [Football_STM__c] = c.Football_STM
FROM [dbo].[Contact_Custom] a 
INNER JOIN (SELECT DISTINCT [b].[SSB_CRMSYSTEM_Contact_ID], 1 AS Football_STM FROM [Stanford].[dbo].[FactTicketSales] a WITH (NOLOCK)
			INNER JOIN  [Stanford].[dbo].[DimSeason] s WITH (NOLOCK) ON a.DimSeasonId = s.DimSeasonId
			INNER JOIN [Stanford].dbo.DimTicketCustomer dtc WITH (NOLOCK) ON a.DimTicketCustomerId = dtc.DimTicketCustomerId
			INNER JOIN [Stanford].dbo.[vwDimCustomer_ModAcctId] b WITH (NOLOCK) ON dtc.ETL__SSID_PATRON = b.SSID AND b.SourceSystem = 'Stanford_TI'
			WHERE s.ETL__SSID IN (select MAX(s.ETL__SSID) FROM [Stanford].[dbo].[FactTicketSales] a WITH (NOLOCK)
                                    INNER JOIN  [Stanford].[dbo].[DimSeason] s WITH (NOLOCK) ON a.DimSeasonId = s.DimSeasonId
                                    where  a.DimTicketTypeId = '3' AND s.SeasonClass = 'F' AND s.SeasonName NOT LIKE '%Renewal%')
			AND a.DimTicketTypeId = '3' AND s.SeasonClass = 'F') c
ON c.[SSB_CRMSYSTEM_Contact_ID]=a.[SSB_CRMSYSTEM_Contact_ID]

--MBB STM
UPDATE a
SET [Men_s_Basketball_STM__c] = c.MBB_STM
FROM [dbo].[Contact_Custom] a 
INNER JOIN (SELECT DISTINCT [b].[SSB_CRMSYSTEM_Contact_ID], 1 AS MBB_STM FROM [Stanford].[dbo].[FactTicketSales] a
			INNER JOIN  [Stanford].[dbo].[DimSeason] s ON a.DimSeasonId = s.DimSeasonId
			INNER JOIN [Stanford].dbo.DimTicketCustomer dtc ON a.DimTicketCustomerId = dtc.DimTicketCustomerId
			INNER JOIN [Stanford].dbo.[vwDimCustomer_ModAcctId] b ON dtc.ETL__SSID_PATRON = b.SSID AND b.SourceSystem = 'Stanford_TI'
			WHERE s.ETL__SSID IN (select MAX(s.ETL__SSID) FROM [Stanford].[dbo].[FactTicketSales] a
                                    INNER JOIN  [Stanford].[dbo].[DimSeason] s ON a.DimSeasonId = s.DimSeasonId
                                    where  a.DimTicketTypeId = '3' AND s.SeasonClass = 'B' AND s.SeasonName NOT LIKE '%Renewal%')
			AND a.DimTicketTypeId = '3' AND s.SeasonClass = 'B') c
ON c.[SSB_CRMSYSTEM_Contact_ID]=a.[SSB_CRMSYSTEM_Contact_ID]

--WBB STM
UPDATE a
SET [Women_s_Basketball_STM__c] = c.WBB_STM
FROM [dbo].[Contact_Custom] a WITH (NOLOCK)
INNER JOIN (SELECT DISTINCT [b].[SSB_CRMSYSTEM_Contact_ID], 1 AS WBB_STM FROM [Stanford].[dbo].[FactTicketSales] a WITH (NOLOCK)
			INNER JOIN  [Stanford].[dbo].[DimSeason] s WITH (NOLOCK) ON a.DimSeasonId = s.DimSeasonId
			INNER JOIN [Stanford].dbo.DimTicketCustomer dtc WITH (NOLOCK) ON a.DimTicketCustomerId = dtc.DimTicketCustomerId
			INNER JOIN [Stanford].dbo.[vwDimCustomer_ModAcctId] b  WITH (NOLOCK) ON dtc.ETL__SSID_PATRON = b.SSID AND b.SourceSystem = 'Stanford_TI'
			WHERE s.ETL__SSID IN (select MAX(s.ETL__SSID) FROM [Stanford].[dbo].[FactTicketSales] a WITH (NOLOCK)
                                    INNER JOIN  [Stanford].[dbo].[DimSeason] s WITH (NOLOCK) ON a.DimSeasonId = s.DimSeasonId
                                    where  a.DimTicketTypeId = '3' AND s.SeasonClass = 'WBB' AND s.SeasonName NOT LIKE '%Renewal%')
			AND a.DimTicketTypeId = '3' 
			AND s.SeasonClass = 'WBB') c
ON c.[SSB_CRMSYSTEM_Contact_ID]=a.[SSB_CRMSYSTEM_Contact_ID]

--Women's Volleyball STM
UPDATE a
SET [Women_s_Volleyball_STM__c] = c.WVB_STM
FROM [dbo].[Contact_Custom] a WITH (NOLOCK)
INNER JOIN (SELECT DISTINCT [b].[SSB_CRMSYSTEM_Contact_ID], 1 AS WVB_STM 
			FROM [Stanford].[dbo].[FactTicketSales] a WITH (NOLOCK)
            INNER JOIN  [Stanford].[dbo].[DimSeason] s WITH (NOLOCK) ON a.DimSeasonId = s.DimSeasonId
            INNER JOIN [Stanford].dbo.DimTicketCustomer dtc WITH (NOLOCK) ON a.DimTicketCustomerId = dtc.DimTicketCustomerId
            INNER JOIN [Stanford].dbo.[vwDimCustomer_ModAcctId] b WITH (NOLOCK) ON dtc.ETL__SSID_PATRON = b.SSID AND b.SourceSystem = 'Stanford_TI'
			WHERE s.ETL__SSID IN (select MAX(s.ETL__SSID) FROM [Stanford].[dbo].[FactTicketSales] a WITH (NOLOCK)
                                    INNER JOIN  [Stanford].[dbo].[DimSeason] s WITH (NOLOCK) ON a.DimSeasonId = s.DimSeasonId
                                    where  a.DimTicketTypeId = '3' AND s.SeasonClass = 'V' AND s.SeasonName NOT LIKE '%Renewal%')
			AND a.DimTicketTypeId = '3' AND s.SeasonClass = 'V') c
ON c.[SSB_CRMSYSTEM_Contact_ID]=a.[SSB_CRMSYSTEM_Contact_ID]

--Women's Soccer STM

UPDATE a
SET [Women_s_Soccer_STM__c] = c.WS_STM
FROM [dbo].[Contact_Custom] a WITH (NOLOCK)
INNER JOIN (SELECT DISTINCT [b].[SSB_CRMSYSTEM_Contact_ID], 1 AS WS_STM 
			FROM [Stanford].[dbo].[FactTicketSales] a WITH (NOLOCK)
			INNER JOIN  [Stanford].[dbo].[DimItem] i WITH (NOLOCK) ON a.DimItemId = i.DimItemId
			 INNER JOIN  [Stanford].[dbo].[DimSeason] s WITH (NOLOCK) ON a.DimSeasonId = s.DimSeasonId
            INNER JOIN [Stanford].dbo.DimTicketCustomer dtc WITH (NOLOCK) ON a.DimTicketCustomerId = dtc.DimTicketCustomerId
            INNER JOIN [Stanford].dbo.[vwDimCustomer_ModAcctId] b WITH (NOLOCK) ON dtc.ETL__SSID_PATRON = b.SSID AND b.SourceSystem = 'Stanford_TI'
			WHERE s.ETL__SSID IN (select MAX(s.ETL__SSID) from [Stanford].dbo.FactTicketSales fts WITH (NOLOCK)
									JOIN [Stanford].dbo.DimItem i WITH (NOLOCK) on fts.DimItemId = i.DimItemId
									INNER JOIN  [Stanford].[dbo].[DimSeason] s WITH (NOLOCK) ON fts.DimSeasonId = s.DimSeasonId
									where i.ItemCode = 'WST' AND s.SeasonName NOT LIKE '%Renewal%')
			AND i.ItemCode = 'WST') c
ON c.[SSB_CRMSYSTEM_Contact_ID]=a.[SSB_CRMSYSTEM_Contact_ID]

--Men's Soccer STM

UPDATE a
SET [Men_s_Soccer_STM__c] = c.MS_STM
FROM [dbo].[Contact_Custom] a WITH (NOLOCK)
INNER JOIN (SELECT DISTINCT [b].[SSB_CRMSYSTEM_Contact_ID], 1 AS MS_STM 
			FROM [Stanford].[dbo].[FactTicketSales] a WITH (NOLOCK)
            INNER JOIN  [Stanford].[dbo].[DimSeason] s WITH (NOLOCK) ON a.DimSeasonId = s.DimSeasonId
			INNER JOIN  [Stanford].[dbo].[DimItem] i WITH (NOLOCK) ON a.DimItemId = i.DimItemId
            INNER JOIN [Stanford].dbo.DimTicketCustomer dtc WITH (NOLOCK) ON a.DimTicketCustomerId = dtc.DimTicketCustomerId
            INNER JOIN [Stanford].dbo.[vwDimCustomer_ModAcctId] b WITH (NOLOCK) ON dtc.ETL__SSID_PATRON = b.SSID AND b.SourceSystem = 'Stanford_TI'
			WHERE s.ETL__SSID IN (select MAX(s.ETL__SSID) from [Stanford].dbo.FactTicketSales fts WITH (NOLOCK)
									JOIN [Stanford].dbo.DimItem i WITH (NOLOCK) on fts.DimItemId = i.DimItemId
									INNER JOIN  [Stanford].[dbo].[DimSeason] s WITH (NOLOCK) ON fts.DimSeasonId = s.DimSeasonId
									where i.ItemCode = 'MST' AND s.SeasonName NOT LIKE '%Renewal%')
			AND i.ItemCode = 'MST') c
ON c.[SSB_CRMSYSTEM_Contact_ID]=a.[SSB_CRMSYSTEM_Contact_ID]



--Baseball STM
UPDATE a
SET [Baseball_STM__c] = c.BB_STM
FROM [dbo].[Contact_Custom] a WITH (NOLOCK)
INNER JOIN (SELECT DISTINCT [b].[SSB_CRMSYSTEM_Contact_ID], 1 AS BB_STM 
			FROM [Stanford].[dbo].[FactTicketSales] a WITH (NOLOCK)
            INNER JOIN  [Stanford].[dbo].[DimSeason] s WITH (NOLOCK) ON a.DimSeasonId = s.DimSeasonId
            INNER JOIN [Stanford].dbo.DimTicketCustomer dtc WITH (NOLOCK) ON a.DimTicketCustomerId = dtc.DimTicketCustomerId
            INNER JOIN [Stanford].dbo.[vwDimCustomer_ModAcctId] b WITH (NOLOCK) ON dtc.ETL__SSID_PATRON = b.SSID AND b.SourceSystem = 'Stanford_TI'
			WHERE s.ETL__SSID IN (select MAX(s.ETL__SSID) FROM [Stanford].[dbo].[FactTicketSales] a WITH (NOLOCK)
                                    INNER JOIN  [Stanford].[dbo].[DimSeason] s WITH (NOLOCK) ON a.DimSeasonId = s.DimSeasonId
                                    where  a.DimTicketTypeId = '3' AND s.SeasonClass = 'BB' AND s.SeasonName NOT LIKE '%Renewal%')
			AND a.DimTicketTypeId = '3' AND s.SeasonClass = 'BB') c
ON c.[SSB_CRMSYSTEM_Contact_ID]=a.[SSB_CRMSYSTEM_Contact_ID]



--Football Partial
UPDATE a
SET [Football_Partial__c] = c.Football_Partial
FROM [dbo].[Contact_Custom] a WITH (NOLOCK)
INNER JOIN (SELECT DISTINCT [b].[SSB_CRMSYSTEM_Contact_ID], 1 AS Football_Partial FROM [Stanford].[dbo].[FactTicketSales] a WITH (NOLOCK)
			INNER JOIN  [Stanford].[dbo].[DimSeason] s WITH (NOLOCK) ON a.DimSeasonId = s.DimSeasonId
			INNER JOIN [Stanford].dbo.DimTicketCustomer dtc WITH (NOLOCK)  ON a.DimTicketCustomerId = dtc.DimTicketCustomerId
			INNER JOIN [Stanford].dbo.[vwDimCustomer_ModAcctId] b WITH (NOLOCK) ON dtc.ETL__SSID_PATRON = b.SSID AND b.SourceSystem = 'Stanford_TI'
			WHERE s.ETL__SSID IN (select MAX(s.ETL__SSID) FROM [Stanford].[dbo].[FactTicketSales] a WITH (NOLOCK)
                                    INNER JOIN  [Stanford].[dbo].[DimSeason] s WITH (NOLOCK) ON a.DimSeasonId = s.DimSeasonId
                                    where  a.DimTicketTypeId = '4' AND s.SeasonClass = 'F'  AND s.SeasonName NOT LIKE '%Renewal%')
			AND a.DimTicketTypeId = '4' AND s.SeasonClass = 'F') c
ON c.[SSB_CRMSYSTEM_Contact_ID]=a.[SSB_CRMSYSTEM_Contact_ID]

--MBB Partial
UPDATE a
SET [Men_s_Basketball_Partial__c] = c.MBB_Partial
FROM [dbo].[Contact_Custom] a WITH (NOLOCK)
INNER JOIN (SELECT DISTINCT [b].[SSB_CRMSYSTEM_Contact_ID], 1 AS MBB_Partial FROM [Stanford].[dbo].[FactTicketSales] a WITH (NOLOCK)
			INNER JOIN  [Stanford].[dbo].[DimSeason] s WITH (NOLOCK) ON a.DimSeasonId = s.DimSeasonId
			INNER JOIN [Stanford].dbo.DimTicketCustomer dtc WITH (NOLOCK) ON a.DimTicketCustomerId = dtc.DimTicketCustomerId
			INNER JOIN [Stanford].dbo.[vwDimCustomer_ModAcctId] b WITH (NOLOCK) ON dtc.ETL__SSID_PATRON = b.SSID AND b.SourceSystem = 'Stanford_TI'
			WHERE s.ETL__SSID IN (select MAX(s.ETL__SSID) FROM [Stanford].[dbo].[FactTicketSales] a WITH (NOLOCK)
                                    INNER JOIN  [Stanford].[dbo].[DimSeason] s WITH (NOLOCK) ON a.DimSeasonId = s.DimSeasonId
                                    where  a.DimTicketTypeId = '4' AND s.SeasonClass = 'B'  AND s.SeasonName NOT LIKE '%Renewal%')
			AND a.DimTicketTypeId = '4' AND s.SeasonClass = 'B') c
ON c.[SSB_CRMSYSTEM_Contact_ID]=a.[SSB_CRMSYSTEM_Contact_ID]

--WBB Partial
UPDATE a
SET [Women_s_Basketball_Partial__c] = c.WBB_Partial
FROM [dbo].[Contact_Custom] a WITH (NOLOCK)
INNER JOIN (SELECT [b].[SSB_CRMSYSTEM_Contact_ID], 1 AS WBB_Partial FROM [Stanford].[dbo].[FactTicketSales] a WITH (NOLOCK)
			INNER JOIN  [Stanford].[dbo].[DimSeason] s WITH (NOLOCK) ON a.DimSeasonId = s.DimSeasonId
			INNER JOIN [Stanford].dbo.DimTicketCustomer dtc WITH (NOLOCK) ON a.DimTicketCustomerId = dtc.DimTicketCustomerId
			INNER JOIN [Stanford].dbo.[vwDimCustomer_ModAcctId] b WITH (NOLOCK) ON dtc.ETL__SSID_PATRON = b.SSID AND b.SourceSystem = 'Stanford_TI'
			WHERE s.ETL__SSID IN (select MAX(s.ETL__SSID) FROM [Stanford].[dbo].[FactTicketSales] a WITH (NOLOCK)
                                    INNER JOIN  [Stanford].[dbo].[DimSeason] s WITH (NOLOCK) ON a.DimSeasonId = s.DimSeasonId
                                    where  a.DimTicketTypeId = '4' AND s.SeasonClass = 'WBB'  AND s.SeasonName NOT LIKE '%Renewal%')
			AND a.DimTicketTypeId = '4' AND s.SeasonClass = 'WBB') c
ON c.[SSB_CRMSYSTEM_Contact_ID]=a.[SSB_CRMSYSTEM_Contact_ID]

--Women's Volleyball Partial
UPDATE a
SET [Volleyball_Partial__c] = c.WVB_Partial
FROM [dbo].[Contact_Custom] a 
INNER JOIN (SELECT DISTINCT [b].[SSB_CRMSYSTEM_Contact_ID], 1 AS WVB_Partial FROM [Stanford].[dbo].[FactTicketSales] a WITH (NOLOCK)
			INNER JOIN  [Stanford].[dbo].[DimSeason] s WITH (NOLOCK) ON a.DimSeasonId = s.DimSeasonId
			INNER JOIN [Stanford].dbo.DimTicketCustomer dtc WITH (NOLOCK) ON a.DimTicketCustomerId = dtc.DimTicketCustomerId
			INNER JOIN [Stanford].dbo.[vwDimCustomer_ModAcctId] b WITH (NOLOCK) ON dtc.ETL__SSID_PATRON = b.SSID AND b.SourceSystem = 'Stanford_TI'
			WHERE s.ETL__SSID IN (select MAX(s.ETL__SSID) FROM [Stanford].[dbo].[FactTicketSales] a WITH (NOLOCK)
                                    INNER JOIN  [Stanford].[dbo].[DimSeason] s WITH (NOLOCK) ON a.DimSeasonId = s.DimSeasonId
                                    where  a.DimTicketTypeId = '4' AND s.SeasonClass = 'V'  AND s.SeasonName NOT LIKE '%Renewal%')
			AND a.DimTicketTypeId = '4' AND s.SeasonClass = 'V') c
ON c.[SSB_CRMSYSTEM_Contact_ID]=a.[SSB_CRMSYSTEM_Contact_ID]



--Baseball Partial
UPDATE a
SET [Baseball_Partial__c] = c.BB_Partial
FROM [dbo].[Contact_Custom] a 
INNER JOIN (SELECT DISTINCT [b].[SSB_CRMSYSTEM_Contact_ID], 1 AS BB_Partial FROM [Stanford].[dbo].[FactTicketSales] a WITH (NOLOCK)
			INNER JOIN  [Stanford].[dbo].[DimSeason] s WITH (NOLOCK) ON a.DimSeasonId = s.DimSeasonId
			INNER JOIN [Stanford].dbo.DimTicketCustomer dtc WITH (NOLOCK) ON a.DimTicketCustomerId = dtc.DimTicketCustomerId
			INNER JOIN [Stanford].dbo.[vwDimCustomer_ModAcctId] b WITH (NOLOCK) ON dtc.ETL__SSID_PATRON = b.SSID AND b.SourceSystem = 'Stanford_TI'
			WHERE s.ETL__SSID IN (select MAX(s.ETL__SSID) FROM [Stanford].[dbo].[FactTicketSales] a WITH (NOLOCK)
                                    INNER JOIN  [Stanford].[dbo].[DimSeason] s WITH (NOLOCK) ON a.DimSeasonId = s.DimSeasonId
                                    where  a.DimTicketTypeId = '4' AND s.SeasonClass = 'BB'  AND s.SeasonName NOT LIKE '%Renewal%')
			AND a.DimTicketTypeId = '4' AND s.SeasonClass = 'BB') c
ON c.[SSB_CRMSYSTEM_Contact_ID]=a.[SSB_CRMSYSTEM_Contact_ID]

--Women's Soccer Partial

UPDATE a
SET [Women_s_Soccer_Partial__c] = c.WS_Partial
FROM [dbo].[Contact_Custom] a 
INNER JOIN (SELECT DISTINCT [b].[SSB_CRMSYSTEM_Contact_ID], 1 AS WS_Partial
			FROM [Stanford].[dbo].[FactTicketSales] a WITH (NOLOCK)
            INNER JOIN  [Stanford].[dbo].[DimSeason] s WITH (NOLOCK) ON a.DimSeasonId = s.DimSeasonId
			INNER JOIN [Stanford].dbo.DimPriceType p WITH (NOLOCK) on a.DimPriceTypeId = p.DimPriceTypeId
			INNER JOIN [Stanford].dbo.DimEvent e WITH (NOLOCK) on a.DimEventId = e.DimEventId
            INNER JOIN [Stanford].dbo.DimTicketCustomer dtc WITH (NOLOCK) ON a.DimTicketCustomerId = dtc.DimTicketCustomerId
            INNER JOIN [Stanford].dbo.[vwDimCustomer_ModAcctId] b WITH (NOLOCK) ON dtc.ETL__SSID_PATRON = b.SSID AND b.SourceSystem = 'Stanford_TI'
			WHERE s.ETL__SSID IN (select MAX(s.ETL__SSID) from [Stanford].dbo.FactTicketSales fts WITH (NOLOCK)
									JOIN [Stanford].dbo.DimPriceType p WITH (NOLOCK) on fts.DimPriceTypeId = p.DimPriceTypeId
									JOIN [Stanford].dbo.DimEvent e WITH (NOLOCK) on fts.DimEventId = e.DimEventId
									INNER JOIN  [Stanford].[dbo].[DimSeason] s WITH (NOLOCK) ON fts.DimSeasonId = s.DimSeasonId
									where p.PriceTypeClass = 'MP'
									and e.Etype = 'WS'
									and s.SeasonName NOT LIKE '%Renewal%')
			AND p.PriceTypeClass = 'MP'
			AND e.Etype = 'WS') c
ON c.[SSB_CRMSYSTEM_Contact_ID]=a.[SSB_CRMSYSTEM_Contact_ID]

--Men's Soccer Partial

UPDATE a
SET [Men_s_Soccer_Partial__c] = c.MS_Partial
FROM [dbo].[Contact_Custom] a 
INNER JOIN (SELECT DISTINCT [b].[SSB_CRMSYSTEM_Contact_ID], 1 AS MS_Partial
			FROM [Stanford].[dbo].[FactTicketSales] a WITH (NOLOCK)
            INNER JOIN  [Stanford].[dbo].[DimSeason] s WITH (NOLOCK) ON a.DimSeasonId = s.DimSeasonId
			INNER JOIN [Stanford].dbo.DimPriceType p WITH (NOLOCK) on a.DimPriceTypeId = p.DimPriceTypeId
			INNER JOIN [Stanford].dbo.DimEvent e WITH (NOLOCK) on a.DimEventId = e.DimEventId
            INNER JOIN [Stanford].dbo.DimTicketCustomer dtc WITH (NOLOCK) ON a.DimTicketCustomerId = dtc.DimTicketCustomerId
            INNER JOIN [Stanford].dbo.[vwDimCustomer_ModAcctId] b WITH (NOLOCK) ON dtc.ETL__SSID_PATRON = b.SSID AND b.SourceSystem = 'Stanford_TI'
			WHERE s.ETL__SSID IN (select MAX(s.ETL__SSID) from [Stanford].dbo.FactTicketSales fts WITH (NOLOCK)
									JOIN [Stanford].dbo.DimPriceType p WITH (NOLOCK) on fts.DimPriceTypeId = p.DimPriceTypeId
									JOIN [Stanford].dbo.DimEvent e WITH (NOLOCK) on fts.DimEventId = e.DimEventId
									INNER JOIN  [Stanford].[dbo].[DimSeason] s WITH (NOLOCK) ON fts.DimSeasonId = s.DimSeasonId
									where p.PriceTypeClass = 'MP'
									and e.Etype = 'MS'
									and s.SeasonName NOT LIKE '%Renewal%')
			AND p.PriceTypeClass = 'MP'
			AND e.Etype = 'MS') c
ON c.[SSB_CRMSYSTEM_Contact_ID]=a.[SSB_CRMSYSTEM_Contact_ID]

-------Football Loyal Group -- Added by AMeitin 2018/05/21

UPDATE a
SET [FB_Loyal_group__c] = c.FB
FROM [dbo].[Contact_Custom] a WITH (NOLOCK)
LEFT JOIN (

select DISTINCT cur.SSB_CRMSYSTEM_CONTACT_ID, 1 AS FB

FROM (

		select distinct SSB_CRMSYSTEM_CONTACT_ID, DimEventId, SUM(QtySeat) QtySeat 
		FROM [Stanford].[dbo].[FactTicketSales] a WITH (NOLOCK)
		INNER JOIN  [Stanford].[dbo].[DimSeason] s WITH (NOLOCK) ON a.DimSeasonId = s.DimSeasonId
		INNER JOIN  Stanford.dbo.DimPriceType dpt (NOLOCK) ON a.DimPriceTypeId = dpt.DimPriceTypeID
		INNER JOIN [Stanford].dbo.DimTicketCustomer dtc WITH (NOLOCK) ON a.DimTicketCustomerId = dtc.DimTicketCustomerId
		INNER JOIN [Stanford].dbo.[vwDimCustomer_ModAcctId] b  WITH (NOLOCK) ON dtc.ETL__SSID_PATRON = b.SSID AND b.SourceSystem = 'Stanford_TI'
		WHERE dpt.PriceTypeClass IN ('GROUP', 'G')
		AND s.SeasonCode = 'F17'
		GROUP BY SSB_CRMSYSTEM_CONTACT_ID, DimEventId 
		HAVING SUM(QtySeat) > 15) cur

FULL OUTER JOIN (

		select distinct SSB_CRMSYSTEM_CONTACT_ID, DimEventId, SUM(QtySeat) QtySeat 
		FROM [Stanford].[dbo].[FactTicketSales] a WITH (NOLOCK)
		INNER JOIN  [Stanford].[dbo].[DimSeason] s WITH (NOLOCK) ON a.DimSeasonId = s.DimSeasonId
		INNER JOIN Stanford.dbo.DimPriceType dpt (NOLOCK) ON a.DimPriceTypeId = dpt.DimPriceTypeID
		INNER JOIN [Stanford].dbo.DimTicketCustomer dtc WITH (NOLOCK) ON a.DimTicketCustomerId = dtc.DimTicketCustomerId
		INNER JOIN [Stanford].dbo.[vwDimCustomer_ModAcctId] b  WITH (NOLOCK) ON dtc.ETL__SSID_PATRON = b.SSID AND b.SourceSystem = 'Stanford_TI'
		WHERE dpt.PriceTypeClass IN ('GROUP', 'G')
		AND s.SeasonCode = 'F16'
		GROUP BY SSB_CRMSYSTEM_CONTACT_ID, DimEventId
		HAVING SUM(QtySeat) > 15
) prev on prev.SSB_CRMSYSTEM_CONTACT_ID = cur.SSB_CRMSYSTEM_CONTACT_ID

WHERE cur.SSB_CRMSYSTEM_CONTACT_ID IS NOT NULL
AND prev.SSB_CRMSYSTEM_CONTACT_ID IS NOT NULL

) c ON c.[SSB_CRMSYSTEM_Contact_ID]= a.[SSB_CRMSYSTEM_Contact_ID]

-------MBB Loyal Group -- Added by AMeitin 2018/05/24

UPDATE a
SET [MBB_Loyal_group__c] = c.MBB
FROM [dbo].[Contact_Custom] a WITH (NOLOCK)
LEFT JOIN (

select DISTINCT cur.SSB_CRMSYSTEM_CONTACT_ID, 1 AS MBB

FROM (

		select distinct SSB_CRMSYSTEM_CONTACT_ID, DimEventId, SUM(QtySeat) QtySeat 
		FROM [Stanford].[dbo].[FactTicketSales] a WITH (NOLOCK)
		INNER JOIN  [Stanford].[dbo].[DimSeason] s WITH (NOLOCK) ON a.DimSeasonId = s.DimSeasonId
		INNER JOIN  Stanford.dbo.DimPriceType dpt (NOLOCK) ON a.DimPriceTypeId = dpt.DimPriceTypeID
		INNER JOIN [Stanford].dbo.DimTicketCustomer dtc WITH (NOLOCK) ON a.DimTicketCustomerId = dtc.DimTicketCustomerId
		INNER JOIN [Stanford].dbo.[vwDimCustomer_ModAcctId] b  WITH (NOLOCK) ON dtc.ETL__SSID_PATRON = b.SSID AND b.SourceSystem = 'Stanford_TI'
		WHERE dpt.PriceTypeClass IN ('GROUP', 'G')
		AND s.SeasonCode = 'B17'
		GROUP BY SSB_CRMSYSTEM_CONTACT_ID, DimEventId 
		HAVING SUM(QtySeat) > 15) cur

FULL OUTER JOIN (

		select distinct SSB_CRMSYSTEM_CONTACT_ID, DimEventId, SUM(QtySeat) QtySeat 
		FROM [Stanford].[dbo].[FactTicketSales] a WITH (NOLOCK)
		INNER JOIN  [Stanford].[dbo].[DimSeason] s WITH (NOLOCK) ON a.DimSeasonId = s.DimSeasonId
		INNER JOIN Stanford.dbo.DimPriceType dpt (NOLOCK) ON a.DimPriceTypeId = dpt.DimPriceTypeID
		INNER JOIN [Stanford].dbo.DimTicketCustomer dtc WITH (NOLOCK) ON a.DimTicketCustomerId = dtc.DimTicketCustomerId
		INNER JOIN [Stanford].dbo.[vwDimCustomer_ModAcctId] b  WITH (NOLOCK) ON dtc.ETL__SSID_PATRON = b.SSID AND b.SourceSystem = 'Stanford_TI'
		WHERE dpt.PriceTypeClass IN ('GROUP', 'G')
		AND s.SeasonCode = 'B16'
		GROUP BY SSB_CRMSYSTEM_CONTACT_ID, DimEventId
		HAVING SUM(QtySeat) > 15
) prev on prev.SSB_CRMSYSTEM_CONTACT_ID = cur.SSB_CRMSYSTEM_CONTACT_ID

WHERE cur.SSB_CRMSYSTEM_CONTACT_ID IS NOT NULL
AND prev.SSB_CRMSYSTEM_CONTACT_ID IS NOT NULL

) c ON c.[SSB_CRMSYSTEM_Contact_ID]= a.[SSB_CRMSYSTEM_Contact_ID]

-------WBB Loyal Group -- Added by AMeitin 2018/05/24

UPDATE a
SET [WBB_Loyal_group__c] = c.WBB
FROM [dbo].[Contact_Custom] a WITH (NOLOCK)
LEFT JOIN (

select DISTINCT cur.SSB_CRMSYSTEM_CONTACT_ID, 1 AS WBB

FROM (

		select distinct SSB_CRMSYSTEM_CONTACT_ID, DimEventId, SUM(QtySeat) QtySeat 
		FROM [Stanford].[dbo].[FactTicketSales] a WITH (NOLOCK)
		INNER JOIN  [Stanford].[dbo].[DimSeason] s WITH (NOLOCK) ON a.DimSeasonId = s.DimSeasonId
		INNER JOIN  Stanford.dbo.DimPriceType dpt (NOLOCK) ON a.DimPriceTypeId = dpt.DimPriceTypeID
		INNER JOIN [Stanford].dbo.DimTicketCustomer dtc WITH (NOLOCK) ON a.DimTicketCustomerId = dtc.DimTicketCustomerId
		INNER JOIN [Stanford].dbo.[vwDimCustomer_ModAcctId] b  WITH (NOLOCK) ON dtc.ETL__SSID_PATRON = b.SSID AND b.SourceSystem = 'Stanford_TI'
		WHERE dpt.PriceTypeClass IN ('GROUP', 'G')
		AND s.SeasonCode = 'W17'
		GROUP BY SSB_CRMSYSTEM_CONTACT_ID, DimEventId 
		HAVING SUM(QtySeat) > 15) cur

FULL OUTER JOIN (

		select distinct SSB_CRMSYSTEM_CONTACT_ID, DimEventId, SUM(QtySeat) QtySeat 
		FROM [Stanford].[dbo].[FactTicketSales] a WITH (NOLOCK)
		INNER JOIN  [Stanford].[dbo].[DimSeason] s WITH (NOLOCK) ON a.DimSeasonId = s.DimSeasonId
		INNER JOIN Stanford.dbo.DimPriceType dpt (NOLOCK) ON a.DimPriceTypeId = dpt.DimPriceTypeID
		INNER JOIN [Stanford].dbo.DimTicketCustomer dtc WITH (NOLOCK) ON a.DimTicketCustomerId = dtc.DimTicketCustomerId
		INNER JOIN [Stanford].dbo.[vwDimCustomer_ModAcctId] b  WITH (NOLOCK) ON dtc.ETL__SSID_PATRON = b.SSID AND b.SourceSystem = 'Stanford_TI'
		WHERE dpt.PriceTypeClass IN ('GROUP', 'G')
		AND s.SeasonCode = 'W16'
		GROUP BY SSB_CRMSYSTEM_CONTACT_ID, DimEventId
		HAVING SUM(QtySeat) > 15
) prev on prev.SSB_CRMSYSTEM_CONTACT_ID = cur.SSB_CRMSYSTEM_CONTACT_ID

WHERE cur.SSB_CRMSYSTEM_CONTACT_ID IS NOT NULL
AND prev.SSB_CRMSYSTEM_CONTACT_ID IS NOT NULL

) c ON c.[SSB_CRMSYSTEM_Contact_ID]= a.[SSB_CRMSYSTEM_Contact_ID]



-------WVB Loyal Group -- Added by AMeitin 2018/05/24

UPDATE a
SET [WVB_Loyal_group__c] = c.WVB
FROM [dbo].[Contact_Custom] a WITH (NOLOCK)
LEFT JOIN (

select DISTINCT cur.SSB_CRMSYSTEM_CONTACT_ID, 1 AS WVB

FROM (

		select distinct SSB_CRMSYSTEM_CONTACT_ID, DimEventId, SUM(QtySeat) QtySeat 
		FROM [Stanford].[dbo].[FactTicketSales] a WITH (NOLOCK)
		INNER JOIN  [Stanford].[dbo].[DimSeason] s WITH (NOLOCK) ON a.DimSeasonId = s.DimSeasonId
		INNER JOIN  Stanford.dbo.DimPriceType dpt (NOLOCK) ON a.DimPriceTypeId = dpt.DimPriceTypeID
		INNER JOIN [Stanford].dbo.DimTicketCustomer dtc WITH (NOLOCK) ON a.DimTicketCustomerId = dtc.DimTicketCustomerId
		INNER JOIN [Stanford].dbo.[vwDimCustomer_ModAcctId] b  WITH (NOLOCK) ON dtc.ETL__SSID_PATRON = b.SSID AND b.SourceSystem = 'Stanford_TI'
		WHERE dpt.PriceTypeClass IN ('GROUP', 'G')
		AND s.SeasonCode = 'V17'
		GROUP BY SSB_CRMSYSTEM_CONTACT_ID, DimEventId 
		HAVING SUM(QtySeat) > 15) cur

FULL OUTER JOIN (

		select distinct SSB_CRMSYSTEM_CONTACT_ID, DimEventId, SUM(QtySeat) QtySeat 
		FROM [Stanford].[dbo].[FactTicketSales] a WITH (NOLOCK)
		INNER JOIN  [Stanford].[dbo].[DimSeason] s WITH (NOLOCK) ON a.DimSeasonId = s.DimSeasonId
		INNER JOIN Stanford.dbo.DimPriceType dpt (NOLOCK) ON a.DimPriceTypeId = dpt.DimPriceTypeID
		INNER JOIN [Stanford].dbo.DimTicketCustomer dtc WITH (NOLOCK) ON a.DimTicketCustomerId = dtc.DimTicketCustomerId
		INNER JOIN [Stanford].dbo.[vwDimCustomer_ModAcctId] b  WITH (NOLOCK) ON dtc.ETL__SSID_PATRON = b.SSID AND b.SourceSystem = 'Stanford_TI'
		WHERE dpt.PriceTypeClass IN ('GROUP', 'G')
		AND s.SeasonCode = 'V16'
		GROUP BY SSB_CRMSYSTEM_CONTACT_ID, DimEventId
		HAVING SUM(QtySeat) > 15
) prev on prev.SSB_CRMSYSTEM_CONTACT_ID = cur.SSB_CRMSYSTEM_CONTACT_ID

WHERE cur.SSB_CRMSYSTEM_CONTACT_ID IS NOT NULL
AND prev.SSB_CRMSYSTEM_CONTACT_ID IS NOT NULL

) c ON c.[SSB_CRMSYSTEM_Contact_ID]= a.[SSB_CRMSYSTEM_Contact_ID]


-------Baseball Loyal Group -- Added by AMeitin 2018/05/24

UPDATE a
SET [Baseball_Loyal_group__c] = c.BSB
FROM [dbo].[Contact_Custom] a WITH (NOLOCK)
LEFT JOIN (

select DISTINCT cur.SSB_CRMSYSTEM_CONTACT_ID, 1 AS BSB

FROM (

		select distinct SSB_CRMSYSTEM_CONTACT_ID, DimEventId, SUM(QtySeat) QtySeat 
		FROM [Stanford].[dbo].[FactTicketSales] a WITH (NOLOCK)
		INNER JOIN  [Stanford].[dbo].[DimSeason] s WITH (NOLOCK) ON a.DimSeasonId = s.DimSeasonId
		INNER JOIN  Stanford.dbo.DimPriceType dpt (NOLOCK) ON a.DimPriceTypeId = dpt.DimPriceTypeID
		INNER JOIN [Stanford].dbo.DimTicketCustomer dtc WITH (NOLOCK) ON a.DimTicketCustomerId = dtc.DimTicketCustomerId
		INNER JOIN [Stanford].dbo.[vwDimCustomer_ModAcctId] b  WITH (NOLOCK) ON dtc.ETL__SSID_PATRON = b.SSID AND b.SourceSystem = 'Stanford_TI'
		WHERE dpt.PriceTypeClass IN ('GROUP', 'G')
		AND s.SeasonCode = 'D18'
		GROUP BY SSB_CRMSYSTEM_CONTACT_ID, DimEventId 
		HAVING SUM(QtySeat) > 15) cur

FULL OUTER JOIN (

		select distinct SSB_CRMSYSTEM_CONTACT_ID, DimEventId, SUM(QtySeat) QtySeat 
		FROM [Stanford].[dbo].[FactTicketSales] a WITH (NOLOCK)
		INNER JOIN  [Stanford].[dbo].[DimSeason] s WITH (NOLOCK) ON a.DimSeasonId = s.DimSeasonId
		INNER JOIN Stanford.dbo.DimPriceType dpt (NOLOCK) ON a.DimPriceTypeId = dpt.DimPriceTypeID
		INNER JOIN [Stanford].dbo.DimTicketCustomer dtc WITH (NOLOCK) ON a.DimTicketCustomerId = dtc.DimTicketCustomerId
		INNER JOIN [Stanford].dbo.[vwDimCustomer_ModAcctId] b  WITH (NOLOCK) ON dtc.ETL__SSID_PATRON = b.SSID AND b.SourceSystem = 'Stanford_TI'
		WHERE dpt.PriceTypeClass IN ('GROUP', 'G')
		AND s.SeasonCode = 'd17'
		GROUP BY SSB_CRMSYSTEM_CONTACT_ID, DimEventId
		HAVING SUM(QtySeat) > 15
) prev on prev.SSB_CRMSYSTEM_CONTACT_ID = cur.SSB_CRMSYSTEM_CONTACT_ID

WHERE cur.SSB_CRMSYSTEM_CONTACT_ID IS NOT NULL
AND prev.SSB_CRMSYSTEM_CONTACT_ID IS NOT NULL

) c ON c.[SSB_CRMSYSTEM_Contact_ID]= a.[SSB_CRMSYSTEM_Contact_ID]


-------WBB Loyal Group -- Added by AMeitin 2018/05/24

UPDATE a
SET [WBB_Loyal_group__c] = c.WBB
FROM [dbo].[Contact_Custom] a WITH (NOLOCK)
LEFT JOIN (

select DISTINCT cur.SSB_CRMSYSTEM_CONTACT_ID, 1 AS WBB

FROM (

		select distinct SSB_CRMSYSTEM_CONTACT_ID, DimEventId, SUM(QtySeat) QtySeat 
		FROM [Stanford].[dbo].[FactTicketSales] a WITH (NOLOCK)
		INNER JOIN  [Stanford].[dbo].[DimSeason] s WITH (NOLOCK) ON a.DimSeasonId = s.DimSeasonId
		INNER JOIN  Stanford.dbo.DimPriceType dpt (NOLOCK) ON a.DimPriceTypeId = dpt.DimPriceTypeID
		INNER JOIN [Stanford].dbo.DimTicketCustomer dtc WITH (NOLOCK) ON a.DimTicketCustomerId = dtc.DimTicketCustomerId
		INNER JOIN [Stanford].dbo.[vwDimCustomer_ModAcctId] b  WITH (NOLOCK) ON dtc.ETL__SSID_PATRON = b.SSID AND b.SourceSystem = 'Stanford_TI'
		WHERE dpt.PriceTypeClass IN ('GROUP', 'G')
		AND s.SeasonCode = 'W17'
		GROUP BY SSB_CRMSYSTEM_CONTACT_ID, DimEventId 
		HAVING SUM(QtySeat) > 15) cur

FULL OUTER JOIN (

		select distinct SSB_CRMSYSTEM_CONTACT_ID, DimEventId, SUM(QtySeat) QtySeat 
		FROM [Stanford].[dbo].[FactTicketSales] a WITH (NOLOCK)
		INNER JOIN  [Stanford].[dbo].[DimSeason] s WITH (NOLOCK) ON a.DimSeasonId = s.DimSeasonId
		INNER JOIN Stanford.dbo.DimPriceType dpt (NOLOCK) ON a.DimPriceTypeId = dpt.DimPriceTypeID
		INNER JOIN [Stanford].dbo.DimTicketCustomer dtc WITH (NOLOCK) ON a.DimTicketCustomerId = dtc.DimTicketCustomerId
		INNER JOIN [Stanford].dbo.[vwDimCustomer_ModAcctId] b  WITH (NOLOCK) ON dtc.ETL__SSID_PATRON = b.SSID AND b.SourceSystem = 'Stanford_TI'
		WHERE dpt.PriceTypeClass IN ('GROUP', 'G')
		AND s.SeasonCode = 'W16'
		GROUP BY SSB_CRMSYSTEM_CONTACT_ID, DimEventId
		HAVING SUM(QtySeat) > 15
) prev on prev.SSB_CRMSYSTEM_CONTACT_ID = cur.SSB_CRMSYSTEM_CONTACT_ID

WHERE cur.SSB_CRMSYSTEM_CONTACT_ID IS NOT NULL
AND prev.SSB_CRMSYSTEM_CONTACT_ID IS NOT NULL

) c ON c.[SSB_CRMSYSTEM_Contact_ID]= a.[SSB_CRMSYSTEM_Contact_ID]


--Stanford Affiliation Field(s)
UPDATE a
SET [SSB_CRMSYSTEM_Current_Student__c] = c.CurrentStudent
, [SSB_CRMSYSTEM_Student_Partner__c] = c.StudentPartner
, [SSB_CRMSYSTEM_Stanford_Alumni__c] = c.StanfordAlumni
, [SSB_CRMSYSTEM_Block_S_Member__c] = c.BlockSMember
, [SSB_CRMSYSTEM_Faculty_Staff_Member__c] = c.FacultyStaff
, [SSB_CRMSYSTEM_Daper_Staff__c] = c.DaperStaff
, [SSB_CRMSYSTEM_Daper_Retiree__c] = c.DaperRetiree
FROM [dbo].[Contact_Custom] a
INNER JOIN (SELECT SSB_CRMSYSTEM_Contact_ID
                            , MAX(CASE WHEN ctype.TYPE = 'S02' AND dc.CustomerStatus = 'A' THEN 1 ELSE NULL	END) AS CurrentStudent
                            , MAX(CASE WHEN ctype.TYPE = 'S03' AND dc.CustomerStatus = 'A' THEN 1 ELSE NULL	END) AS StudentPartner
                            , MAX(CASE WHEN ctype.TYPE IN ('A','S16')					    THEN 1 ELSE NULL	END) AS StanfordAlumni
							, MAX(CASE WHEN ctype.TYPE = 'S16'        				    THEN 1 ELSE NULL	END) AS BlockSMember
                            , MAX(CASE WHEN ctype.TYPE = 'FS'                           THEN 1 ELSE NULL END) AS FacultyStaff
                            , MAX(CASE WHEN ctype.TYPE = 'S99'                               THEN 1 ELSE NULL	END) AS DaperStaff
                            , MAX(CASE WHEN ctype.TYPE = 'DR'                               THEN 1 ELSE NULL		END) AS DaperRetiree
                FROM Stanford.[dbo].[vwDimCustomer_ModAcctId] dc
                JOIN Stanford.[dbo].[TK_CTYPE] ctype ON dc.CustomerType = ctype.NAME
                WHERE dc.SourceSystem = 'Stanford_TI'
				GROUP BY  SSB_CRMSYSTEM_Contact_ID) c                
ON c.[SSB_CRMSYSTEM_Contact_ID]=a.[SSB_CRMSYSTEM_Contact_ID]

--Customer Comments

UPDATE a
SET Comments__c = customer.COMMENTS
FROM [dbo].[Contact_Custom] a
	INNER JOIN dbo.[vwDimCustomer_ModAcctId] b ON b.SSB_CRMSYSTEM_CONTACT_ID = a.SSB_CRMSYSTEM_CONTACT_ID 
	JOIN Stanford.dbo.TK_CUSTOMER customer on customer.customer = b.SSID AND b.SourceSystem = 'Stanford_TI' 
where b.SSB_CRMSYSTEM_PRIMARY_FLAG = 1


--Secondary Patron
UPDATE a
SET  [SSB_CRMSYSTEM_Secondary_Patron__c] = x.[NAME2]
FROM [dbo].[Contact_Custom] a 
       INNER JOIN    
              (SELECT SSB_CRMSYSTEM_CONTACT_ID,NAME2, ROW_NUMBER() OVER(Partition by SSB_CRMSYSTEM_CONTACT_ID ORDER BY LAST_DATETIME DESC, ENTRY_DATETIME) xRank 
                     FROM dbo.[vwDimCustomer_ModAcctId] b 
                     JOIN Stanford.dbo.PD_PATRON patron on patron.Patron = b.SSID AND b.SourceSystem = 'Stanford_TI' 
					 where NAME2 IS NOT NULL
                     ) x
       ON a.SSB_CRMSYSTEM_CONTACT_ID = x.SSB_CRMSYSTEM_CONTACT_ID
where x.xRank = 1


--Organization Type
UPDATE a
SET  [SSB_CRMSYSTEM_Organization_Type__c] = x.[Name]
FROM [dbo].[Contact_Custom] a 
       INNER JOIN    
              (SELECT SSB_CRMSYSTEM_CONTACT_ID, ISNULL(a.[SSB_CRMSYSTEM_Organization_Type__c], otype.[Name]) As [Name]
                  FROM dbo.[vwDimCustomer_ModAcctId] b 
					 LEFT JOIN Stanford_Reporting.[prodcopy].[vw_Account] a ON a.SSB_CRMSYSTEM_Contact_ID__c = b.SSB_CRMSYSTEM_CONTACT_ID
                     LEFT JOIN Stanford.dbo.PD_ORG org (NOLOCK) on org.ORG = b.SSID AND b.SourceSystem = 'Stanford_TI' AND SSB_CRMSYSTEM_PRIMARY_FLAG = '1'
					 LEFT JOIN Stanford.dbo.PD_OTYPE otype (NOLOCK) on org.ORG_TYPE = otype.OTYPE 
                     ) x
       ON a.SSB_CRMSYSTEM_CONTACT_ID = x.SSB_CRMSYSTEM_CONTACT_ID


-------------------------ADOBE FIELDS------------------------------------------



--Email Quarantine 
UPDATE a
SET  [Email_Quarantine__pc] = x.Quarantined_Preferences
FROM [dbo].[Contact_Custom] a 
       INNER JOIN    
              (SELECT DISTINCT SSB_CRMSYSTEM_CONTACT_ID, Quarantined_Preferences
				FROM  dbo.[vwDimCustomer_ModAcctId] b (NOLOCK)
				INNER JOIN Stanford.ods.Adobe_Recipient adobe (NOLOCK)
					ON  adobe.Email = b.EmailPrimary
				WHERE ISNULL(RTRIM(adobe.Email), '') <> ''
					AND [SSB_CRMSYSTEM_PRIMARY_FLAG] = '1') x
       ON a.SSB_CRMSYSTEM_CONTACT_ID = x.SSB_CRMSYSTEM_CONTACT_ID


--Adobe Unsubscribe
UPDATE a
SET  [Adobe_Unsubscribe__pc] = x.EmailOptOut_Preferences
FROM [dbo].[Contact_Custom] a 
       INNER JOIN    
              (SELECT DISTINCT SSB_CRMSYSTEM_CONTACT_ID, EmailOptOut_Preferences
				FROM  dbo.[vwDimCustomer_ModAcctId] b (NOLOCK)
				INNER JOIN Stanford.ods.Adobe_Recipient adobe (NOLOCK)
					ON  adobe.Email = b.EmailPrimary
				WHERE ISNULL(RTRIM(adobe.Email), '') <> ''
					AND [SSB_CRMSYSTEM_PRIMARY_FLAG] = '1'
                     ) x
       ON a.SSB_CRMSYSTEM_CONTACT_ID = x.SSB_CRMSYSTEM_CONTACT_ID


--Adobe Email Quarantine Reason

UPDATE a
SET [Email_Quarantine_Reason__pc]  = x.[QuarantinedReason_Preferences]
FROM [dbo].[Contact_Custom] a 
       INNER JOIN    
              (SELECT DISTINCT SSB_CRMSYSTEM_CONTACT_ID, QuarantinedReason_Preferences
				FROM  dbo.[vwDimCustomer_ModAcctId] b (NOLOCK)
					INNER JOIN Stanford.ods.Adobe_Recipient adobe (NOLOCK)
					ON  adobe.Email = b.EmailPrimary
				WHERE ISNULL(RTRIM(adobe.Email), '') <> ''
						AND [SSB_CRMSYSTEM_PRIMARY_FLAG] = '1'
						AND QuarantinedReason_Preferences <> ''
                     ) x
       ON a.SSB_CRMSYSTEM_CONTACT_ID = x.SSB_CRMSYSTEM_CONTACT_ID


		

EXEC  [dbo].[sp_CRMLoad_Contact_ProcessLoad_Criteria]



























GO
