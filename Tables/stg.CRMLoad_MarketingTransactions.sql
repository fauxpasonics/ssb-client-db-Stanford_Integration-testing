CREATE TABLE [stg].[CRMLoad_MarketingTransactions]
(
[Activity_date__c] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Subject__c] [varchar] (55) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description__c] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[primarykey] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[What__c] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Who__c] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
