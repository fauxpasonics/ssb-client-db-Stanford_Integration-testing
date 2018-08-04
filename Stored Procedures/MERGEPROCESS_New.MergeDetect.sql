SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE proc [MERGEPROCESS_New].[MergeDetect]  --OleMiss --'raiders'
--[MERGEPROCESS_New].[MergeDetect]  'Stanford'
	@Client VARCHAR(100) 
AS
Declare @Date Date = (select cast(getdate() as date));
DECLARE @Account varchar(100) = (Select CASE WHEN @client = 'TrailBlazers' THEN 'CRM_Account' ELSE Concat(@client,' PC_SFDC Account' ) END);
--DECLARE @Contact varchar(100) = (Select CASE WHEN @client = 'TrailBlazers' THEN 'CRM_Contact' ELSE Concat(@client,' PC_SFDC Contact' ) END );

With MergeAccount as (
select ISNULL(SSB_CRMSYSTEM_CONTACT_ID,SSB_CRMSYSTEM_ACCT_ID) SSB_CRMSYSTEM_CONTACT_ID, count(1) CountAccounts, --max(CASE WHEN b.SSID is not null then 1 else 0 END) --Key accounts not setup
0 Key_Related, MAX(pca.recordtypeid) MAX_RT, MIN(pca.recordtypeid) MIN_RT
from dbo.vwDimCustomer_ModAcctID a 
--left join dbo.vw_KeyAccounts b on a.dimcustomerid = b.dimcustomerid -- Key accounts not set up
inner join prodcopy.account pca with (nolock)
on a.ssid = pca.id and a.sourcesystem = @Account
where 
--SourceSystem = @Account AND 
ISNULL(SSB_CRMSYSTEM_CONTACT_ID,SSB_CRMSYSTEM_ACCT_ID) IS NOT NULL
group by ISNULL(SSB_CRMSYSTEM_CONTACT_ID,SSB_CRMSYSTEM_ACCT_ID)--, pca.recordtypeid
having count(1) > 1)--, 

-- MergeContact as (
--select SSB_CRMSYSTEM_CONTACT_ID, count(1) CountContacts, max(CASE WHEN b.ID is not null then 1 else 0 END) Key_Related from dbo.vwDimCustomer_ModAcctID a 
--		left join (select cc.ID FROM prodcopy.vwContact cc join Raiders.dbo.vw_KeyAccounts bb on cc.AccountID = bb.SSID) b		
--		on a.SSID = b.ID
--where SourceSystem = @Contact
--group by SSB_CRMSYSTEM_CONTACT_ID
--having count(1) > 1)


MERGE  MERGEPROCESS_New.DetectedMerges  as tar
using ( Select 'Account' MergeType, SSB_CRMSYSTEM_CONTACT_ID SSBID, CASE WHEN Key_Related = 0 and MAX_RT = MIN_RT THEN 1 ELSE 0 END AutoMerge, @Date DetectedDate, CountAccounts NumRecords FROM MergeAccount
		--UNION ALL
		--Select 'Contact' MergeType, SSB_CRMSYSTEM_Contact_ID SSBID, CASE WHEN CountContacts = 2 AND Key_Related = 0 THEN 1 ELSE 0 END AutoMerge, @Date DetectedDate, CountContacts NumRecords FROM MergeContact
		) as sour
	ON tar.MergeType = sour.MergeType
	AND tar.SSBID = sour.SSBID
WHEN MATCHED  AND (tar.DetectedDate <> sour.DetectedDate 
				OR sour.NumRecords <> tar.NumRecords
				OR MergeComplete =  1
				OR tar.AutoMerge != sour.AutoMerge) THEN UPDATE 
	Set DetectedDate = @Date
	,NumRecords = sour.NumRecords
	,MergeComplete = 0 
	, tar.AutoMerge = sour.AutoMerge
WHEN Not Matched THEN Insert
	(MergeType
	,SSBID
	,AutoMerge
	--,recordtypeid
	,DetectedDate
	,NumRecords)
Values(
	 sour.MergeType
	,sour.SSBID
	,sour.AutoMerge
	--,sour.recordtypeid
	,sour.DetectedDate
	,sour.NumRecords)
WHEN NOT MATCHED BY SOURCE AND tar.MergeComment IS NULL THEN UPDATE
	SET MergeComment = CASE WHEN tar.Mergecomplete = 1 then 'Merge Detection - Merge Successfully completed'
							WHEN tar.mergeComplete = 0 THEN 'Merge Detection - Merge not completed, but no longer detected' END
		,MergeComplete = 1
	;

	
--SET UP FOR PERSON ACCOUNT MODEL
IF OBJECT_ID('mergeprocess_new.tmp_pcaccount', 'U') IS NOT NULL 
DROP TABLE mergeprocess_new.tmp_pcaccount; 

IF OBJECT_ID('mergeprocess_new.tmp_pccontact', 'U') IS NOT NULL 
DROP TABLE mergeprocess_new.tmp_pccontact;

IF OBJECT_ID('mergeprocess_new.tmp_dimcust', 'U') IS NOT NULL 
DROP TABLE mergeprocess_new.tmp_dimcust;

select * into mergeprocess_new.tmp_dimcust 
from dbo.vwdimcustomer_modacctid  where ssb_crmsystem_contact_id in (
select ssb_crmsystem_contact_id from dbo.vwdimcustomer_modacctid where sourcesystem = @Account group by ssb_crmsystem_contact_id having count(*) > 1 )
and sourcesystem = @Account
--UNION ALL
--select * from 
--dbo.vwdimcustomer_modacctid where ssb_crmsystem_acct_id in (
--select ssb_crmsystem_acct_id from dbo.vwdimcustomer_modacctid where sourcesystem = @Account group by ssb_crmsystem_acct_id having count(*) > 1 )
--and sourcesystem = @Account
--1:04

--create nonclustered index ix_tmp_dimcust_acct on mergeprocess_new.tmp_dimcust (sourcesystem, ssb_crmsystem_acct_id)
create nonclustered index ix_tmp_dimcust_contact on mergeprocess_new.tmp_dimcust (sourcesystem, ssb_crmsystem_contact_id)
create nonclustered index ix_tmp_dimcust_ssid on mergeprocess_new.tmp_dimcust (sourcesystem, ssid)
--0:05

--select pcc.* into mergeprocess_new.tmp_pccontact from mergeprocess_new.tmp_dimcust dc
--inner join prodcopy.vw_contact pcc on dc.ssid = pcc.id
--where dc.sourcesystem = @Contact
--0:07

select pca.* into mergeprocess_new.tmp_pcaccount from mergeprocess_new.tmp_dimcust dc
inner join prodcopy.vw_account pca with (nolock) on dc.ssid = pca.id
where dc.sourcesystem = @Account
--0:08

alter table mergeprocess_new.tmp_pcaccount
alter column id varchar(200)
----0:03

--alter table mergeprocess_new.tmp_pccontact
--alter column id varchar(200)
--0:02

create nonclustered index ix_tmp_pcaccount on mergeprocess_new.tmp_pcaccount (id)
--0:05

--create nonclustered index ix_tmp_pccontact on mergeprocess_new.tmp_pccontact (id)
--0:01


GO
