CREATE TABLE [dbo].[MarketingActivity_ErrorOutput]
(
[Activity_date__c] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Subject__c] [varchar] (55) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description__c] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[primarykey] [varchar] (8000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[What__c] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ErrorCode] [int] NULL,
[ErrorColumn] [int] NULL,
[Id] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ErrorDescription] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[who__c] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
