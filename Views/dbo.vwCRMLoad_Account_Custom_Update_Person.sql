SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [dbo].[vwCRMLoad_Account_Custom_Update_Person]
AS
SELECT  
--b.ssb_crmsystem_Contact_ID,																					 
	 z.[crm_id] Id																								 
	,b.SSID_Winner SSB_CRMSYSTEM_SSID_Winner__c																	 --,aa.SSB_CRMSYSTEM_SSID_Winner__c
	--,DimCustIDs SSB_CRMSYSTEM_DimCustomerID__c																 
	,b.TI_IDs SSB_CRMSYSTEM_SSID_Paciolan__c																	 --,aa.SSB_CRMSYSTEM_SSID_Paciolan__c
	--,SeasonTicket_Years SSB_CRMSYSTEM_Season_Ticket_Years__c													
	--,SSB_CRMSYSTEM_Last_Ticket_Purchase_Date__c																
	,ISNULL(b.SSB_CRMSYSTEM_Broker_Flag__c, 0) SSB_CRMSYSTEM_Broker_Flag__c										 --,aa.SSB_CRMSYSTEM_Broker_Flag__c
	,ISNULL(b.SSB_CRMSYSTEM_Opponent_Flag__c, 0) SSB_CRMSYSTEM_Opponent_Flag__c									 --,aa.SSB_CRMSYSTEM_Opponent_Flag__c
	,ISNULL(b.SSB_CRMSYSTEM_HouseAccount_Flag__c, 0) SSB_CRMSYSTEM_HouseAccount_Flag__c							 --,aa.SSB_CRMSYSTEM_HouseAccount_Flag__c
	,ISNULL(b.SSB_CRMSYSTEM_Visitor_Flag__c, 0) SSB_CRMSYSTEM_Visitor_Flag__c									 --,aa.SSB_CRMSYSTEM_Visitor_Flag__c
	,b.Twitter_Account__c																						 --,aa.Twitter_Account__c
	,b.Facebook_Account__c																						 --,aa.Facebook_Account__c
	,ISNULL(b.Football_STM__c, 0) Football_STM__c																 --,aa.Football_STM__c
	,ISNULL(b.Men_s_Basketball_STM__c, 0) Men_s_Basketball_STM__c												 --,aa.Men_s_Basketball_STM__c
	,ISNULL(b.Women_s_Basketball_STM__c, 0) Women_s_Basketball_STM__c											 --,aa.Women_s_Basketball_STM__c
	,ISNULL(b.Women_s_Volleyball_STM__c, 0) Women_s_Volleyball_STM__c											 --,aa.Women_s_Volleyball_STM__c
	,ISNULL(b.Women_s_Soccer_STM__c, 0) Women_s_Soccer_STM__c													 --,aa.Women_s_Soccer_STM__c
	,ISNULL(b.Men_s_Soccer_STM__c, 0) Men_s_Soccer_STM__c														 --,aa.Men_s_Soccer_STM__c
	,ISNULL(b.Baseball_STM__c, 0) Baseball_STM__c																 --,aa.Baseball_STM__c
	,ISNULL(b.Football_Partial__c, 0) Football_Partial__c														 --,aa.Football_Partial__c
	,ISNULL(b.Men_s_Basketball_Partial__c, 0) Men_s_Basketball_Partial__c										 --,aa.Men_s_Basketball_Partial__c
	,ISNULL(b.Women_s_Basketball_Partial__c, 0) Women_s_Basketball_Partial__c									 --,aa.Women_s_Basketball_Partial__c
	,ISNULL(b.Volleyball_Partial__c, 0) Volleyball_Partial__c													 --,aa.Volleyball_Partial__c
	,ISNULL(b.Women_s_Soccer_Partial__c, 0) Women_s_Soccer_Partial__c											 --,aa.Women_s_Soccer_Partial__c
	,ISNULL(b.Men_s_Soccer_Partial__c, 0) Men_s_Soccer_Partial__c												 --,aa.Men_s_Soccer_Partial__c
	,ISNULL(b.Baseball_Partial__c, 0) Baseball_Partial__c														 --,aa.Baseball_Partial__c
	,ISNULL(b.SSB_CRMSYSTEM_Current_Student__c, 0) SSB_CRMSYSTEM_Current_Student__c								 --,aa.SSB_CRMSYSTEM_Current_Student__c
	,ISNULL(b.SSB_CRMSYSTEM_Student_Partner__c, 0) SSB_CRMSYSTEM_Student_Partner__c								 --,aa.SSB_CRMSYSTEM_Student_Partner__c
	,ISNULL(b.SSB_CRMSYSTEM_Stanford_Alumni__c, 0) SSB_CRMSYSTEM_Stanford_Alumni__c								 --,aa.SSB_CRMSYSTEM_Stanford_Alumni__c
	,ISNULL(b.SSB_CRMSYSTEM_Block_S_Member__c, 0) SSB_CRMSYSTEM_Block_S_Member__c								 --,aa.SSB_CRMSYSTEM_Block_S_Member__c
	,ISNULL(b.SSB_CRMSYSTEM_Faculty_Staff_Member__c, 0) SSB_CRMSYSTEM_Faculty_Staff_Member__c					 --,aa.SSB_CRMSYSTEM_Faculty_Staff_Member__c
	,ISNULL(b.SSB_CRMSYSTEM_Daper_Staff__c, 0) SSB_CRMSYSTEM_Daper_Staff__c										 --,aa.SSB_CRMSYSTEM_Daper_Staff__c
	,ISNULL(b.SSB_CRMSYSTEM_Daper_Retiree__c, 0) SSB_CRMSYSTEM_Daper_Retiree__c									 --,aa.SSB_CRMSYSTEM_Daper_Retiree__c
	,b.Comments__c																								 --,aa.Comments__c
	,b.SSB_CRMSYSTEM_VIP_Message  SSB_CRMSYSTEM_VIP_Message__c													 --,aa.SSB_CRMSYSTEM_VIP_Message__c
	--,ISNULL(Email_Quarantine__pc, 0) Email_Quarantine__pc														 
	--,ISNULL(Adobe_Unsubscribe__pc, 0) Adobe_Unsubscribe__pc													 
	--,Email_Quarantine_Reason__pc																				 
	,b.SSB_CRMSYSTEM_Secondary_Patron__c																		 --,aa.SSB_CRMSYSTEM_Secondary_Patron__c
	,b.PersonOtherPhone																							 --,aa.PersonOtherPhone
	,b.PersonHomePhone																							 --,aa.PersonHomePhone
	--,Secondary_Email__pc																						
	--,Preferred_Phone__pc																						
	--,Cell_Phone__pc																							
	--,Business_Phone__pc																						
	,z.AddressPrimaryStreet	PersonMailingStreet																	 --,aa.PersonMailingStreet
	,z.AddressPrimaryCity	PersonMailingCity																	 --,aa.PersonMailingCity
	,z.AddressPrimaryState	PersonMailingState																	 --,aa.PersonMailingState
	,z.AddressPrimaryZip	PersonMailingPostalCode																 --,aa.PersonMailingPostalCode
	,z.AddressPrimaryCountry PersonMailingCountry																 --,aa.PersonMailingCountry
	,b.PersonEmail																								 --,aa.PersonEmail
	,b.Business_Email__c																						 --,aa.Business_Email__c
	,b.PersonBirthdate																							 --,aa.PersonBirthdate
	,b.SSB_CRMSYSTEM_Organization_Type__c																		 --,aa.SSB_CRMSYSTEM_Organization_Type__c
	,b.SSB_CRMSYSTEM_SSID_Winner_SourceSystem__c																 --,aa.SSB_CRMSYSTEM_SSID_Winner_SourceSystem__c
FROM dbo.[vwCRMLoad_Account_Std_Prep] a
INNER JOIN dbo.Contact_Custom b ON [a].[ssb_crmsystem_Contact_ID__c] = b.ssb_crmsystem_Contact_ID
INNER JOIN dbo.Contact z ON a.[ssb_crmsystem_Contact_ID__c] = z.ssb_crmsystem_Contact_ID
LEFT JOIN prodcopy.Account AA ON z.crm_ID = aa.ID
LEFT JOIN prodcopy.RecordType rt ON aa.RecordTypeId = rt.Id
WHERE z.[SSB_CRMSYSTEM_Contact_ID] <> z.[crm_id]
AND ISNULL(CASE WHEN rt.name = 'Business Account' THEN 1 WHEN rt.name = 'Person Account' THEN 0 END, z.isbusinessaccount) = 0 --updated TCF 6/5/17 to correct name values (was Developer Name values)
AND (1=2

	OR ISNULL(b.SSID_Winner,'') != ISNULL(aa.SSB_CRMSYSTEM_SSID_Winner__c,'')
	OR ISNULL(b.TI_IDs,'') != ISNULL(aa.SSB_CRMSYSTEM_SSID_Paciolan__c,'')
	OR ISNULL(b.SSB_CRMSYSTEM_Broker_Flag__c,'') != ISNULL(aa.SSB_CRMSYSTEM_Broker_Flag__c,'')
	OR ISNULL(b.SSB_CRMSYSTEM_Opponent_Flag__c,'') != ISNULL(aa.SSB_CRMSYSTEM_Opponent_Flag__c,'')
	OR ISNULL(b.SSB_CRMSYSTEM_HouseAccount_Flag__c,'') != ISNULL(aa.SSB_CRMSYSTEM_HouseAccount_Flag__c,'')
	OR ISNULL(b.SSB_CRMSYSTEM_Visitor_Flag__c,'') != ISNULL(aa.SSB_CRMSYSTEM_Visitor_Flag__c,'')
	OR ISNULL(b.Twitter_Account__c,'') != ISNULL(aa.Twitter_Account__c,'')
	OR ISNULL(b.Facebook_Account__c,'') != ISNULL(aa.Facebook_Account__c,'')
	OR ISNULL(b.Football_STM__c,'') != ISNULL(aa.Football_STM__c,'')
	OR ISNULL(b.Men_s_Basketball_STM__c,'') != ISNULL(aa.Men_s_Basketball_STM__c,'')
	OR ISNULL(b.Women_s_Basketball_STM__c,'') != ISNULL(aa.Women_s_Basketball_STM__c,'')
	OR ISNULL(b.Women_s_Volleyball_STM__c,'') != ISNULL(aa.Women_s_Volleyball_STM__c,'')
	OR ISNULL(b.Women_s_Soccer_STM__c,'') != ISNULL(aa.Women_s_Soccer_STM__c,'')
	OR ISNULL(b.Men_s_Soccer_STM__c,'') != ISNULL(aa.Men_s_Soccer_STM__c,'')
	OR ISNULL(b.Baseball_STM__c,'') != ISNULL(aa.Baseball_STM__c,'')
	OR ISNULL(b.Football_Partial__c,'') != ISNULL(aa.Football_Partial__c,'')
	OR ISNULL(b.Men_s_Basketball_Partial__c,'') != ISNULL(aa.Men_s_Basketball_Partial__c,'')
	OR ISNULL(b.Women_s_Basketball_Partial__c,'') != ISNULL(aa.Women_s_Basketball_Partial__c,'')
	OR ISNULL(b.Volleyball_Partial__c,'') != ISNULL(aa.Volleyball_Partial__c,'')
	OR ISNULL(b.Women_s_Soccer_Partial__c,'') != ISNULL(aa.Women_s_Soccer_Partial__c,'')
	OR ISNULL(b.Men_s_Soccer_Partial__c,'') != ISNULL(aa.Men_s_Soccer_Partial__c,'')
	OR ISNULL(b.Baseball_Partial__c,'') != ISNULL(aa.Baseball_Partial__c,'')
	OR ISNULL(b.SSB_CRMSYSTEM_Current_Student__c,'') != ISNULL(aa.SSB_CRMSYSTEM_Current_Student__c,'')
	OR ISNULL(b.SSB_CRMSYSTEM_Student_Partner__c,'') != ISNULL(aa.SSB_CRMSYSTEM_Student_Partner__c,'')
	OR ISNULL(b.SSB_CRMSYSTEM_Stanford_Alumni__c,'') != ISNULL(aa.SSB_CRMSYSTEM_Stanford_Alumni__c,'')
	OR ISNULL(b.SSB_CRMSYSTEM_Block_S_Member__c,'') != ISNULL(aa.SSB_CRMSYSTEM_Block_S_Member__c,'')
	OR ISNULL(b.SSB_CRMSYSTEM_Faculty_Staff_Member__c,'') != ISNULL(aa.SSB_CRMSYSTEM_Faculty_Staff_Member__c,'')
	OR ISNULL(b.SSB_CRMSYSTEM_Daper_Staff__c,'') != ISNULL(aa.SSB_CRMSYSTEM_Daper_Staff__c,'')
	OR ISNULL(b.SSB_CRMSYSTEM_Daper_Retiree__c,'') != ISNULL(aa.SSB_CRMSYSTEM_Daper_Retiree__c,'')
	OR ISNULL(b.Comments__c,'') != ISNULL(aa.Comments__c,'')
	OR ISNULL(b.SSB_CRMSYSTEM_VIP_Message,'') != ISNULL(aa.SSB_CRMSYSTEM_VIP_Message__c,'')
	OR ISNULL(b.SSB_CRMSYSTEM_Secondary_Patron__c,'') != ISNULL(aa.SSB_CRMSYSTEM_Secondary_Patron__c,'')
	OR ISNULL(b.PersonOtherPhone,'') != ISNULL(aa.PersonOtherPhone,'')
	OR ISNULL(b.PersonHomePhone,'') != ISNULL(aa.PersonHomePhone,'')
	OR ISNULL(z.AddressPrimaryStreet,'') != ISNULL(aa.PersonMailingStreet,'')
	OR ISNULL(z.AddressPrimaryCity,'') != ISNULL(aa.PersonMailingCity,'')
	OR ISNULL(z.AddressPrimaryState,'') != ISNULL(aa.PersonMailingState,'')
	OR ISNULL(z.AddressPrimaryZip,'') != ISNULL(aa.PersonMailingPostalCode,'')
	OR ISNULL(z.AddressPrimaryCountry,'') != ISNULL(aa.PersonMailingCountry,'')
	OR ISNULL(b.PersonEmail,'') != ISNULL(aa.PersonEmail,'')
	OR ISNULL(b.Business_Email__c,'') != ISNULL(aa.Business_Email__c,'')
	OR ISNULL(b.PersonBirthdate,'') != ISNULL(aa.PersonBirthdate,'')
	OR ISNULL(b.SSB_CRMSYSTEM_Organization_Type__c,'') != ISNULL(aa.SSB_CRMSYSTEM_Organization_Type__c,'')
	OR ISNULL(b.SSB_CRMSYSTEM_SSID_Winner_SourceSystem__c,'') != ISNULL(aa.SSB_CRMSYSTEM_SSID_Winner_SourceSystem__c,'')




	)




GO
