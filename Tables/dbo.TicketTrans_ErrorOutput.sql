CREATE TABLE [dbo].[TicketTrans_ErrorOutput]
(
[IsDeleted] [bit] NULL,
[Name] [nvarchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedDate] [datetime] NULL,
[CreatedById] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastModifiedDate] [datetime] NULL,
[LastModifiedById] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SystemModstamp] [datetime] NULL,
[Amount_Paid__c] [float] NULL,
[Basis__c] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Disposition_Code__c] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Event_Code__c] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[First_Name__c] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Account__c] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Home_Phone__c] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Item_Code__c] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Item_Price__c] [float] NULL,
[Item_Title__c] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Last_Name__c] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Location_Preference__c] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Mobile_Phone__c] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Office_Phone__c] [nvarchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Order_Date__c] [date] NULL,
[Order_Line_ID__c] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Order_Quantity__c] [float] NULL,
[Order_Total__c] [float] NULL,
[Orig_Salecode__c] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Orig_Salecode_Name__c] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Patron_ID__c] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Price_Level__c] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Price_Type__c] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Promo_Code__c] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Promo_Code_Name__c] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Mark_Code__c] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Season_Code__c] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Season_Name__c] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Seat_Block__c] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sequence__c] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Ticket_Class__c] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Full_Transaction_ID__c] [varchar] (1300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ErrorCode] [int] NULL,
[ErrorColumn] [int] NULL,
[Id] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ErrorDescription] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF__TicketTra__LoadD__43D61337] DEFAULT (getdate())
)
GO
