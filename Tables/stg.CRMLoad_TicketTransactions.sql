CREATE TABLE [stg].[CRMLoad_TicketTransactions]
(
[Season_Code__c] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Season_Name__c] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Order_Line_ID__c] [varchar] (48) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Sequence__c] [bigint] NOT NULL,
[Patron_ID__c] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Basis__c] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Disposition_Code__c] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Event_Code__c] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Item_Code__c] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Item_Title__c] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Price_Level__c] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Price_Type_Name__c] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Price_Type__c] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Item_Price__c] [numeric] (18, 2) NULL,
[Order_Date__c] [datetime] NULL,
[Order_Quantity__c] [bigint] NULL,
[Order_Total__c] [numeric] (38, 2) NULL,
[Amount_Paid__c] [numeric] (18, 2) NULL,
[Discount__c] [numeric] (18, 2) NULL,
[Orig_Salecode__c] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Orig_Salecode_Name__c] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Promo_Code__c] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Promo_Code_Name__c] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Mark_Code__c] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Inrefsource__c] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Inrefdata__c] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Seat_Block__c] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Salecode_Name__c] [int] NULL,
[Location_Preference__c] [int] NULL,
[Ticket_Class__c] [int] NULL,
[Export_Datetime__c] [datetime] NULL
)
GO
ALTER TABLE [stg].[CRMLoad_TicketTransactions] ADD CONSTRAINT [PK_CRMLoad_TicketTransactions] PRIMARY KEY CLUSTERED  ([Order_Line_ID__c])
GO
