SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [MERGEPROCESS_New].[vw_Cust_Account_ColumnLogic]
AS
SELECT  ID,
		Losing_ID AS Losing_ID ,					
        CAST(SUBSTRING(PersonTitle, 2, 82) AS nvarchar(80)) PersonTitle,
		isnull(CAST(SUBSTRING(Prefers_to_be_Contacted_by_Email__c, 2, 1) AS nvarchar(80)),0) Prefers_to_be_Contacted_by_Email__c,
		isnull(CAST(SUBSTRING(Prefers_to_be_Contacted_by_Mail__c, 2, 1) AS nvarchar(80)),0) Prefers_to_be_Contacted_by_Mail__c,
		isnull(CAST(SUBSTRING(Prefers_to_be_Contacted_by_Phone__c, 2, 1) AS nvarchar(80)),0) Prefers_to_be_Contacted_by_Phone__c,
		CAST(SUBSTRING(Comments__c, 2, 3999) AS nvarchar(max)) Comments__c	 
FROM    ( SELECT    Winning_ID AS ID ,
					Losing_ID AS Losing_ID ,					
                    MAX(CASE WHEN dta.xtype = 'Winning'
                                  AND PersonTitle IS NOT NULL and Persontitle != ''
                             THEN '2' + CAST(PersonTitle AS VARCHAR(80))
                             WHEN dta.xtype = 'Losing'
                                  AND PersonTitle IS NOT NULL and Persontitle != ''
                             THEN '1' + CAST(PersonTitle AS VARCHAR(80))
                        END) PersonTitle ,
					 
					  MAX(CASE WHEN dta.xtype = 'Winning'
                                  AND Prefers_to_be_Contacted_by_Email__c IS NOT NULL and Prefers_to_be_Contacted_by_Email__c != 0
                             THEN '2' + CAST(Prefers_to_be_Contacted_by_Email__c AS VARCHAR(10))
                             WHEN dta.xtype = 'Losing'
                                  AND Prefers_to_be_Contacted_by_Email__c IS NOT NULL and Prefers_to_be_Contacted_by_Email__c != 0
                             THEN '1' + CAST(Prefers_to_be_Contacted_by_Email__c AS VARCHAR(10))
                        END) Prefers_to_be_Contacted_by_Email__c ,
						  
						  MAX(CASE WHEN dta.xtype = 'Winning'
                                  AND Prefers_to_be_Contacted_by_Mail__c IS NOT NULL and Prefers_to_be_Contacted_by_Mail__c != 0
                             THEN '2' + CAST(Prefers_to_be_Contacted_by_Mail__c AS VARCHAR(10))
                             WHEN dta.xtype = 'Losing'
                                  AND Prefers_to_be_Contacted_by_Mail__c IS NOT NULL and Prefers_to_be_Contacted_by_Mail__c != 0
                             THEN '1' + CAST(Prefers_to_be_Contacted_by_Mail__c AS VARCHAR(10))
                        END) Prefers_to_be_Contacted_by_Mail__c ,
						  
						  MAX(CASE WHEN dta.xtype = 'Winning'
                                  AND Prefers_to_be_Contacted_by_Phone__c IS NOT NULL and Prefers_to_be_Contacted_by_Phone__c != 0
                             THEN '2' + CAST(Prefers_to_be_Contacted_by_Phone__c AS VARCHAR(10))
                             WHEN dta.xtype = 'Losing'
                                  AND Prefers_to_be_Contacted_by_Phone__c IS NOT NULL and Prefers_to_be_Contacted_by_Phone__c != 0
                             THEN '1' + CAST(Prefers_to_be_Contacted_by_Phone__c AS VARCHAR(10))
                        END) Prefers_to_be_Contacted_by_Phone__c ,
						  
						  MAX(CASE WHEN dta.xtype = 'Winning'
                                  AND Comments__c	 IS NOT NULL and Comments__c != ''
                             THEN '2' + CAST(Comments__c	 AS VARCHAR(max))
                             WHEN dta.xtype = 'Losing'
                                  AND Comments__c	 IS NOT NULL and Comments__c != ''
                             THEN '1' + CAST(Comments__c	AS VARCHAR(max))
                        END) Comments__c 
						                    
FROM      ( SELECT    *
            FROM      ( SELECT    'Winning' xtype ,
                                a.Winning_ID ,
								a.Losing_ID ,					
                                b.*
                        FROM      [MERGEPROCESS_New].[Queue] a
                                JOIN Prodcopy.vw_Account b ON a.Winning_ID = b.ID
                        UNION ALL
                        SELECT    'Losing' xtype ,
                                a.Winning_ID ,
								a.Losing_ID ,					
                                b.*
                        FROM      [MERGEPROCESS_New].[Queue] a
                                JOIN Prodcopy.vw_Account b ON a.Losing_ID = b.ID
                    ) x
        ) dta

GROUP BY  Winning_ID ,
		Losing_ID					
        ) aa

;

GO
