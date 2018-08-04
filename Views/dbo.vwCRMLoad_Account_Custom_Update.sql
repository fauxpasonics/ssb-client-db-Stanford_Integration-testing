SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [dbo].[vwCRMLoad_Account_Custom_Update]
AS
SELECT  
b.ssb_crmsystem_Contact_ID,
	 z.[crm_id] Id
	,SSID_Winner SSB_CRMSYSTEM_SSID_Winner__c
	,DimCustIDs SSB_CRMSYSTEM_DimCustomerID__c
	,TI_IDs SSB_CRMSYSTEM_SSID_Paciolan__c
	,SeasonTicket_Years SSB_CRMSYSTEM_Season_Ticket_Years__c
	,SSB_CRMSYSTEM_Last_Ticket_Purchase_Date__c
	,ISNULL(SSB_CRMSYSTEM_Broker_Flag__c, 0) SSB_CRMSYSTEM_Broker_Flag__c
	,ISNULL(SSB_CRMSYSTEM_Opponent_Flag__c, 0) SSB_CRMSYSTEM_Opponent_Flag__c
	,ISNULL(SSB_CRMSYSTEM_HouseAccount_Flag__c, 0) SSB_CRMSYSTEM_HouseAccount_Flag__c
	,ISNULL(SSB_CRMSYSTEM_Visitor_Flag__c, 0) SSB_CRMSYSTEM_Visitor_Flag__c
	,Twitter_Account__c
	,Facebook_Account__c
	,ISNULL(Football_STM__c, 0) Football_STM__c
	,ISNULL(Men_s_Basketball_STM__c, 0) Men_s_Basketball_STM__c
	,ISNULL(Women_s_Basketball_STM__c, 0) Women_s_Basketball_STM__c
	,ISNULL(Women_s_Volleyball_STM__c, 0) Women_s_Volleyball_STM__c
	,ISNULL(Women_s_Soccer_STM__c, 0) Women_s_Soccer_STM__c
	,ISNULL(Men_s_Soccer_STM__c, 0) Men_s_Soccer_STM__c
	,ISNULL(Baseball_STM__c, 0) Baseball_STM__c
	,ISNULL(Football_Partial__c, 0) Football_Partial__c
	,ISNULL(Men_s_Basketball_Partial__c, 0) Men_s_Basketball_Partial__c
	,ISNULL(Women_s_Basketball_Partial__c, 0) Women_s_Basketball_Partial__c
	,ISNULL(Volleyball_Partial__c, 0) Volleyball_Partial__c
	,ISNULL(Women_s_Soccer_Partial__c, 0) Women_s_Soccer_Partial__c
	,ISNULL(Men_s_Soccer_Partial__c, 0) Men_s_Soccer_Partial__c
	,ISNULL(Baseball_Partial__c, 0) Baseball_Partial__c
	,ISNULL(SSB_CRMSYSTEM_Current_Student__c, 0) SSB_CRMSYSTEM_Current_Student__c
	,ISNULL(SSB_CRMSYSTEM_Student_Partner__c, 0) SSB_CRMSYSTEM_Student_Partner__c
	,ISNULL(SSB_CRMSYSTEM_Stanford_Alumni__c, 0) SSB_CRMSYSTEM_Stanford_Alumni__c
	,ISNULL(SSB_CRMSYSTEM_Block_S_Member__c, 0) SSB_CRMSYSTEM_Block_S_Member__c
	,ISNULL(SSB_CRMSYSTEM_Faculty_Staff_Member__c, 0) SSB_CRMSYSTEM_Faculty_Staff_Member__c
	,ISNULL(SSB_CRMSYSTEM_Daper_Staff__c, 0) SSB_CRMSYSTEM_Daper_Staff__c
	,ISNULL(SSB_CRMSYSTEM_Daper_Retiree__c, 0) SSB_CRMSYSTEM_Daper_Retiree__c
	,Comments__c
	,SSB_CRMSYSTEM_VIP_Message
	,ISNULL(Email_Quarantine__pc, 0) Email_Quarantine__pc
	,ISNULL(Adobe_Unsubscribe__pc, 0) Adobe_Unsubscribe__pc
	,Email_Quarantine_Reason__pc
	,SSB_CRMSYSTEM_Secondary_Patron__c
	,PersonOtherPhone
	,Secondary_Email__pc
	,Preferred_Phone__pc
	,Cell_Phone__pc
	,Business_Phone__pc
	,AddressPrimaryStreet	PersonMailingStreet
	,AddressPrimaryCity	PersonMailingCity
	,AddressPrimaryState	PersonMailingState
	,AddressPrimaryZip	PersonMailingPostalCode
	,AddressPrimaryCountry PersonMailingCountry
	,b.PersonEmail   PersonEmail
	,b.personhomephone  
	,b.business_email__c
	,b.personbirthdate  
FROM dbo.[vwCRMLoad_Account_Std_Prep] a
INNER JOIN dbo.Contact_Custom b ON [a].[ssb_crmsystem_Contact_ID__c] = b.ssb_crmsystem_Contact_ID
INNER JOIN dbo.Contact z ON a.[ssb_crmsystem_Contact_ID__c] = z.ssb_crmsystem_Contact_ID
WHERE z.[SSB_CRMSYSTEM_CONTACT_ID] <> z.[crm_id]










GO
