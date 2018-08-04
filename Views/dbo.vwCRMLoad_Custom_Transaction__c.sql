SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







CREATE VIEW [dbo].[vwCRMLoad_Custom_Transaction__c]
AS 

SELECT
CAST(t.Season_Code__c             AS VARCHAR(20)) Season_Code__c
, CAST(t.Season_Name__c			AS VARCHAR(50))  Season_Name__c
, CAST(t.Order_Line_ID__c			AS VARCHAR(50))  Order_Line_ID__c
, CAST(t.Sequence__c				AS VARCHAR(4))  Sequence__c				
, CAST(t.Patron_ID__c				AS VARCHAR(12))  Patron_ID__c				
, CAST(t.Basis__c					AS VARCHAR(5))  Basis__c					
, CAST(t.Disposition_Code__c		AS VARCHAR(10))  Disposition_Code__c		
, CAST(t.Event_Code__c			AS VARCHAR(255))  Event_Code__c			
, CAST(t.Item_Code__c			AS VARCHAR(10))  Item_Code__c				
, CAST(t.Item_Title__c			AS VARCHAR(150))  Item_Title__c			
, CAST(t.Price_Level__c			AS VARCHAR(5))  Price_Level__c			
, CAST(t.Price_Type_Name__c		AS VARCHAR(50))    Price_Type_Name__c		
, CAST(t.Price_Type__c			AS VARCHAR(10))  Price_Type__c			
, CAST(t.Item_Price__c			AS NUMERIC(8,2))  Item_Price__c	--Currency (6,2)		
, CAST(t.Order_Date__c			AS DATETIME)       Order_Date__c			
, CAST(t.Order_Quantity__c		AS NUMERIC(4,0))  Order_Quantity__c	 --	Number (4,0)
, CAST(t.Order_Total__c			AS NUMERIC(8,2))  Order_Total__c			--Currency (6,2)
, CAST(t.Amount_Paid__c			AS NUMERIC(8,2))  Amount_Paid__c			--Currency (8,2)
, CAST(t.Discount__c			AS NUMERIC(8,2))  Discount__c				--Currency (8,2)
, CAST(t.Orig_Salecode__c		AS VARCHAR(20))  Orig_Salecode__c			
, CAST(t.Orig_Salecode_Name__c	AS VARCHAR(40))  Orig_Salecode_Name__c	
, CAST(t.Promo_Code__c			AS VARCHAR(30))  Promo_Code__c			
, LEFT(CAST(t.Promo_Code_Name__c		AS VARCHAR(100)),100)  Promo_Code_Name__c		
, CAST(t.Mark_Code__c				AS VARCHAR(10))  Mark_Code__c				
--, CAST(t.Inrefsource__c			AS VARCHAR(8000))  Inrefsource__c			
--, CAST(t.Inrefdata__c				AS VARCHAR(8000))  Inrefdata__c				
, CAST(t.Seat_Block__c			AS VARCHAR(8000))  Seat_Block__c			--	Long Text Area(131072)
, CAST(t.Salecode_Name__c			AS VARCHAR(100))  Salecode_Name__c			
, CAST(t.Location_Preference__c	AS VARCHAR(10))  Location_Preference__c	
, CAST(t.Ticket_Class__c			AS VARCHAR(12))  Ticket_Class__c			
, Export_Datetime__c 
, CAST(a.id AS VARCHAR(18)) Account__c
--, CAST(c.id AS VARCHAR(18)) Contact__c 
-- SELECT COUNT(Distinct ORDER_LINE_ID__c), Max(ORDER_DATE__c), Min(ORDER_DATE__c), COUNT(*)
--SELECT ORDER_LINE_ID__c, COUNT(*)
--SELECT *
FROM stg.CRMLoad_TicketTransactions t
INNER JOIN dbo.[vwDimCustomer_ModAcctId] dimcust WITH (NOLOCK) ON t.patron_id__c = [dimcust].[SSID] AND [dimcust].[SourceSystem] = 'Stanford_TI'
INNER JOIN dbo.vwCRMProcess_DeDupProdCopyAcct_ByGUID a WITH (NOLOCK) ON dimcust.SSB_CRMSYSTEM_CONTACT_ID = a.SSB_CRMSYSTEM_CONTACT_ID__c AND a.Rank = 1 
LEFT JOIN prodcopy.Transaction__c pctt WITH (NOLOCK) ON pctt.order_line_id__c COLLATE SQL_Latin1_General_CP1_CS_AS = t.order_line_id__c 

--To catch up failures with missing fields
--INNER join dbo.TicketTrans_ErrorOutput e ON
--e.Order_Line_ID__c = t.Order_Line_ID__c
--AND e.Sequence__c =  t.Sequence__c
--AND e.account__c =   t.account__c

WHERE 1=1
--AND ( CAST(t.Order_Date__c			AS DATETIME) >= (GETDATE() - 20) ) /******** IF YOU NEED TO RELOAD THIS TABLE, GO BACK TO 2 YEARS PRIOR!!!! ***************/
--AND ( CAST(t.Order_Date__c			AS DATETIME) >= (getdate() - 731) ) /******** IF YOU NEED TO RELOAD THIS TABLE, GO BACK TO 2 YEARS PRIOR!!!! ***************/
AND pctt.id IS NULL







GO
