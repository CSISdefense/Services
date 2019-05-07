/****** Object:  View [Office].[EntityIDofficeHistory]    Script Date: 5/7/2019 6:55:05 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





ALTER  VIEW [Office].[EntityIDofficeHistory]
AS



	
	select interior.contractingofficeid as ContractingOfficeCode
	,interior.EntityID
	,interior.fiscal_year
	,EID.EntityText	
	, CASE
		WHEN Parent.ParentID is not null and isnull(Parent.UnknownCompany,0)=0 
		THEN 'PID'
		WHEN HasParentDunsnumber=1 and ParentDunsChildCount=1
		THEN 'PDuns-1'
		WHEN HasParentDunsnumber=1 and ParentDunsChildCount>=2
		THEN 'PDuns-2+'
		--Next check the imputed parentdunsnumber
		WHEN HasParentDunsnumberImputed=1 and ParentDunsImputedChildCount=1
		THEN 'PDuns-1'
		WHEN HasParentDunsnumberImputed=1 and ParentDunsImputedChildCount>=2
		THEN 'PDuns-2+'
	--	--Even if using Dunsnumber here other entries may think of this as a parent.
		WHEN EID.dunsnumber is not null and DunsChildCount=1
		THEN 'PDuns-1'
		WHEN EID.dunsnumber is not null and DunsChildCount>=2
		THEN 'PDuns-2+'
		WHEN EID.dunsnumber is not null 
		THEN 'Duns'
		WHEN EID.EntityID is not null
		THEN 'Name'
		 END as EntityCategory
		 ,GDPdeflatorName
	--,CASE
	--	WHEN Parent.ParentID is not null and isnull(Parent.UnknownCompany,0)=0 
	--	THEN pidh.EntitySizeCode 
	--	WHEN eid.Dunsnumber is not null 
	--	THEN DtPCH.EntitySizeCode
	--	when eid.VendorName is not null
	--	then nameh.EntitySizeCode
	--	else pidh.EntitySizeCode
	--	 end  as EntitySizeCode
	--,CASE
	--	WHEN Parent.ParentID is not null and isnull(Parent.UnknownCompany,0)=0 
	--	THEN pidh.IsEntityAbove2016constantOneMillionThreshold 
	--	WHEN eid.Dunsnumber is not null 
	--	THEN DtPCH.IsEntityAbove2016constantOneMillionThreshold
	--	when eid.VendorName is not null
	--	then nameh.IsEntityAbove2016constantOneMillionThreshold
	--	else pidh.IsEntityAbove2016constantOneMillionThreshold
	--	 end  as IsEntityAbove2016constantOneMillionThreshold

	--,CASE
	--	WHEN Parent.ParentID is not null and isnull(Parent.UnknownCompany,0)=0 
	--	THEN pidh.IsEntityAbove2016constantReportingThreshold 
	--	WHEN eid.Dunsnumber is not null 
	--	THEN DtPCH.IsEntityAbove2016constantReportingThreshold
	--	when eid.VendorName is not null
	--	then nameh.IsEntityAbove2016constantReportingThreshold
	--	else pidh.IsEntityAbove2016constantReportingThreshold
	--	 end  as IsEntityAbove2016constantReportingThreshold
	
	--,CASE
	--	WHEN Parent.ParentID is not null and isnull(Parent.UnknownCompany,0)=0 
	--	THEN pidh.IsEntityAbove1990constantReportingThreshold 
	--	WHEN eid.Dunsnumber is not null 
	--	THEN DtPCH.IsEntityAbove1990constantReportingThreshold
	--	when eid.VendorName is not null
	--	then nameh.IsEntityAbove1990constantReportingThreshold
	--	else pidh.IsEntityAbove1990constantReportingThreshold
	--	 end  as IsEntityAbove1990constantReportingThreshold

	--,case
	--	WHEN Parent.ParentID is not null and isnull(Parent.UnknownCompany,0)=0 
	--	THEN pidh.AnyEntityUSplaceOfPerformance 
	--	WHEN eid.Dunsnumber is not null 
	--	THEN DtPCH.AnyEntityUSplaceOfPerformance
	--	when eid.VendorName is not null
	--	then nameh.AnyEntityUSplaceOfPerformance
	--	else pidh.AnyEntityUSplaceOfPerformance
	--	 end  as AnyEntityUSplaceOfPerformance

	
	--,case
	--	WHEN Parent.ParentID is not null and isnull(Parent.UnknownCompany,0)=0 
	--	THEN pidh.AnyEntityForeignPlaceOfPerformance 
	--	WHEN eid.Dunsnumber is not null 
	--	THEN DtPCH.AnyEntityForeignPlaceOfPerformance
	--	when eid.VendorName is not null
	--	then nameh.AnyEntityForeignPlaceOfPerformance
	--	else pidh.AnyEntityForeignPlaceOfPerformance
	--	 end  as AnyEntityForeignPlaceOfPerformance

	,interior.ObligatedAmountConst
	,interior.NumberOfActions
	,PARENT.Top100Federal
	,PARENT.Top6
	,PARENT.UnknownCompany
	from (
	--Assign EntitySize and related states via CSIStransactionID/StandardizedVendorName
	select 
	CASE WHEN Parent.ParentID is not null and isnull(Parent.UnknownCompany,0)=0 
		THEN Parent.EntityID 
		WHEN c.parentdunsnumber is not null and isnull(ParentSquared.UnknownCompany,0)=0 
		THEN ParentDuns.EntityID
	WHEN DtPCH.parentdunsnumber is not null and isnull(PARENTsquaredImputed.UnknownCompany,0)=0 
		THEN ParentDUNSimputed.EntityID
		WHEN c.dunsnumber is not null and isnull(Parent.UnknownCompany,0)=0 
		THEN DUNS.EntityID
		ELSE coalesce(vn.EntityID,Duns.entityID)
	 end  as EntityID
		,c.fiscal_year	
		,c.contractingofficeid
	,max(iif(c.parentdunsnumber is not null and isnull(ParentSquared.UnknownCompany,0)=0,1,0)) as HasParentDunsnumber
	,max(iif(DtPCH.parentdunsnumber is not null and isnull(PARENTsquaredImputed.UnknownCompany,0)=0,1,0)) as HasParentDunsnumberImputed
	,max(ParentDtPCH.ChildCount) as ParentDunsChildCount
	,max(ParentDtPCHimputed.ChildCount) as ParentDunsImputedChildCount
	,max(DtPCH.ChildCount) as DunsChildCount
	,sum(c.ObligatedAmount/def.GDPdeflator) as ObligatedAmountConst
	,sum(c.NumberOfActions) as NumberOfActions
	,def.GDPdeflatorName
	from Contract.FPDS as C
		LEFT OUTER JOIN Contractor.DunsnumbertoParentContractorHistory as DtPCH
			ON DtPCH.FiscalYear=C.fiscal_year AND DtPCH.DUNSNUMBER=C.DUNSNumber
		LEFT OUTER JOIN Contractor.Dunsnumber as DUNS
			ON DUNS.Dunsnumber=DtPCH.Dunsnumber
		LEFT OUTER JOIN Contractor.ParentContractor as PARENT
			ON PARENT.ParentID=DtPCH.ParentID
		LEFT OUTER JOIN Contractor.DunsnumbertoParentContractorHistory as ParentDtPCH
			ON ParentDtPCH.FiscalYear=C.fiscal_year  AND  ParentDtPCH.DUNSnumber=C.parentdunsnumber
		LEFT OUTER JOIN Contractor.Dunsnumber as ParentDUNS
			ON ParentDUNS.Dunsnumber=ParentDtPCH.Dunsnumber
		LEFT OUTER JOIN Contractor.ParentContractor as PARENTsquared
			ON PARENTsquared.ParentID= ParentDtPCH.ParentID 
		LEFT OUTER JOIN Contractor.DunsnumbertoParentContractorHistory as ParentDtPCHimputed
			ON ParentDtPCHimputed.FiscalYear=C.fiscal_year  AND  ParentDtPCHimputed.DUNSnumber=DtPCH.parentdunsnumber
		LEFT OUTER JOIN Contractor.Dunsnumber as ParentDUNSimputed
			ON ParentDUNSimputed.Dunsnumber=ParentDtPCHimputed.Dunsnumber
		LEFT OUTER JOIN Contractor.ParentContractor as PARENTsquaredImputed
			ON PARENTsquaredImputed.ParentID= ParentDtPCHimputed.ParentID 
		left outer join contract.CSIStransactionID ctid
			on ctid.CSIStransactionID=c.CSIStransactionID
		left outer join contract.CSIScontractID ccid
			on ctid.CSIScontractID=ccid.CSIScontractID
		left outer join contract.UnlabeledDunsnumberCSIStransactionIDentityID u
		on u.CSIStransactionID=c.CSIStransactionID
		left outer join Vendor.VendorName vn
		on vn.VendorName=u.StandardizedVendorName
		left outer join Economic.Deflators def
        on c.fiscal_year=def.Fiscal_Year
	group by CASE WHEN Parent.ParentID is not null and isnull(Parent.UnknownCompany,0)=0 
		THEN Parent.EntityID 
		WHEN c.parentdunsnumber is not null and isnull(ParentSquared.UnknownCompany,0)=0 
		THEN ParentDuns.EntityID
	WHEN DtPCH.parentdunsnumber is not null and isnull(PARENTsquaredImputed.UnknownCompany,0)=0 
		THEN ParentDUNSimputed.EntityID
		WHEN c.dunsnumber is not null and isnull(Parent.UnknownCompany,0)=0 
		THEN DUNS.EntityID
		ELSE coalesce(vn.EntityID,Duns.entityID)
	 end
		,c.fiscal_year
		,c.contractingofficeid
		,GDPdeflatorName
	) as interior
	left outer join vendor.EntityID as EID
	on EID.EntityID=interior.EntityID
	left outer join Contractor.ParentContractor Parent
	on EID.ParentID=Parent.ParentID
	left outer join Vendor.ParentIDHistory pidh
	on pidh.ParentID=PARENT.ParentID and pidh.FiscalYear=interior.fiscal_year
	LEFT OUTER JOIN Contractor.DunsnumbertoParentContractorHistory as DtPCH
		ON DtPCH.FiscalYear=interior.fiscal_year AND DtPCH.DUNSNUMBER=eid.DUNSNumber
	left outer join Vendor.StandardizedVendorNameHistory as nameh
	on interior.fiscal_year=nameh.Fiscal_Year and eid.VendorName=nameh.StandardizedVendorName
			

	















GO


