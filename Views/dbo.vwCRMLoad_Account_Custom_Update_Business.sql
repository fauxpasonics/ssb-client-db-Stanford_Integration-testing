SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE  VIEW [dbo].[vwCRMLoad_Account_Custom_Update_Business]
AS
SELECT  
--b.ssb_crmsystem_Contact_ID,
	 z.[crm_id] Id
	,b.SSID_Winner SSB_CRMSYSTEM_SSID_Winner__c
	--,DimCustIDs SSB_CRMSYSTEM_DimCustomerID__c
	,b.TI_IDs SSB_CRMSYSTEM_SSID_Paciolan__c
	--,SeasonTicket_Years SSB_CRMSYSTEM_Season_Ticket_Years__c
	--,SSB_CRMSYSTEM_Last_Ticket_Purchase_Date__c
	,ISNULL(b.SSB_CRMSYSTEM_Broker_Flag__c, 0) SSB_CRMSYSTEM_Broker_Flag__c
	,ISNULL(b.SSB_CRMSYSTEM_Opponent_Flag__c, 0) SSB_CRMSYSTEM_Opponent_Flag__c
	,ISNULL(b.SSB_CRMSYSTEM_HouseAccount_Flag__c, 0) SSB_CRMSYSTEM_HouseAccount_Flag__c
	,ISNULL(b.SSB_CRMSYSTEM_Visitor_Flag__c, 0) SSB_CRMSYSTEM_Visitor_Flag__c
	,b.Twitter_Account__c
	,b.Facebook_Account__c
	,ISNULL(b.Football_STM__c, 0) Football_STM__c
	,ISNULL(b.Men_s_Basketball_STM__c, 0) Men_s_Basketball_STM__c
	,ISNULL(b.Women_s_Basketball_STM__c, 0) Women_s_Basketball_STM__c
	,ISNULL(b.Women_s_Volleyball_STM__c, 0) Women_s_Volleyball_STM__c
	,ISNULL(b.Women_s_Soccer_STM__c, 0) Women_s_Soccer_STM__c
	,ISNULL(b.Men_s_Soccer_STM__c, 0) Men_s_Soccer_STM__c
	,ISNULL(b.Baseball_STM__c, 0) Baseball_STM__c
	,ISNULL(b.Football_Partial__c, 0) Football_Partial__c
	,ISNULL(b.Men_s_Basketball_Partial__c, 0) Men_s_Basketball_Partial__c
	,ISNULL(b.Women_s_Basketball_Partial__c, 0) Women_s_Basketball_Partial__c
	,ISNULL(b.Volleyball_Partial__c, 0) Volleyball_Partial__c
	,ISNULL(b.Women_s_Soccer_Partial__c, 0) Women_s_Soccer_Partial__c
	,ISNULL(b.Men_s_Soccer_Partial__c, 0) Men_s_Soccer_Partial__c
	,ISNULL(b.Baseball_Partial__c, 0) Baseball_Partial__c
	,ISNULL(b.SSB_CRMSYSTEM_Current_Student__c, 0) SSB_CRMSYSTEM_Current_Student__c
	,ISNULL(b.SSB_CRMSYSTEM_Student_Partner__c, 0) SSB_CRMSYSTEM_Student_Partner__c
	,ISNULL(b.SSB_CRMSYSTEM_Stanford_Alumni__c, 0) SSB_CRMSYSTEM_Stanford_Alumni__c
	,ISNULL(b.SSB_CRMSYSTEM_Block_S_Member__c, 0) SSB_CRMSYSTEM_Block_S_Member__c
	,ISNULL(b.SSB_CRMSYSTEM_Faculty_Staff_Member__c, 0) SSB_CRMSYSTEM_Faculty_Staff_Member__c
	,ISNULL(b.SSB_CRMSYSTEM_Daper_Staff__c, 0) SSB_CRMSYSTEM_Daper_Staff__c
	,ISNULL(b.SSB_CRMSYSTEM_Daper_Retiree__c, 0) SSB_CRMSYSTEM_Daper_Retiree__c
	,b.Comments__c
	,b.SSB_CRMSYSTEM_VIP_Message  SSB_CRMSYSTEM_VIP_Message__c
	--,ISNULL(Email_Quarantine__pc, 0) Email_Quarantine__pc
	--,ISNULL(Adobe_Unsubscribe__pc, 0) Adobe_Unsubscribe__pc
	--,Email_Quarantine_Reason__pc
	,b.SSB_CRMSYSTEM_Secondary_Patron__c
	--,PersonOtherPhone
	--,PersonHomePhone
	--,Secondary_Email__pc
	--,Preferred_Phone__pc
	--,Cell_Phone__pc
	--,Business_Phone__pc
	--,AddressPrimaryStreet	PersonMailingStreet
	--,AddressPrimaryCity	PersonMailingCity
	--,AddressPrimaryState	PersonMailingState
	--,AddressPrimaryZip	PersonMailingPostalCode
	--,AddressPrimaryCountry PersonMailingCountry
	--,PersonEmail
	,b.Business_Email__c
	--,PersonBirthdate
	,b.SSB_CRMSYSTEM_Organization_Type__c
	, b.[SSB_CRMSYSTEM_SSID_Winner_SourceSystem__c]
FROM dbo.[vwCRMLoad_Account_Std_Prep] a
INNER JOIN dbo.Contact_Custom b ON [a].[ssb_crmsystem_Contact_ID__c] = b.ssb_crmsystem_Contact_ID
INNER JOIN dbo.Contact z ON a.[ssb_crmsystem_Contact_ID__c] = z.ssb_crmsystem_Contact_ID
LEFT JOIN prodcopy.Account AA ON z.crm_ID = aa.ID
LEFT JOIN prodcopy.RecordType rt ON aa.RecordTypeId = rt.Id
WHERE z.[SSB_CRMSYSTEM_Contact_ID] <> z.[crm_id]
AND rt.name = 'Business Account' --Added TCF 6/5/17 in place of line below
--AND ISNULL(CASE WHEN rt.name = 'Business_Account' THEN 1 WHEN rt.name = 'PersonAccount' THEN 0 END, z.isbusinessaccount) = 1






GO
