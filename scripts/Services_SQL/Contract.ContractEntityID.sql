/****** Object:  View [Contract].[ContractFundingAccount]    Script Date: 4/3/2019 11:40:39 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER VIEW [Contract].ContractEntityID
AS
select M.CSIScontractID
--TreasuryAgencyCode
,iif(MinOfEntityID=MaxOfEntityID,
	MinOfEntityID,
	NULL) as EntityID
,iif(M.MinOfUnmodifiedEntityID=MaxOfUnmodifiedEntityID,
	MinOfUnmodifiedEntityID,
	NULL) as UnmodifiedEntityID

from (select
csiscontractid
	,min(entityID) as MinOfEntityID
	,max(entityID) as MaxOfEntityID
	,min(iif(Unmodified=1,entityID,NULL)) as MinOfUnmodifiedEntityID
	,max(iif(Unmodified=1,entityID,NULL)) as MaxOfUnmodifiedEntityID
	
from (SELECT      
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
	,ctid.CSIScontractID
	,iif(c.modnumber is null or c.modnumber='0',1,0) as Unmodified
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
		) as interior 
	group by CSIScontractID
	) as M
	--left outer join vendor.EntityID as EID
	--on EID.EntityID=interior.EntityID
	--left outer join Contractor.ParentContractor Parent
	--on EID.ParentID=Parent.ParentID
	--left outer join Vendor.ParentIDHistory pidh
	--on pidh.ParentID=PARENT.ParentID and pidh.FiscalYear=interior.fiscal_year
	--LEFT OUTER JOIN Contractor.DunsnumbertoParentContractorHistory as DtPCH
	--	ON DtPCH.FiscalYear=interior.fiscal_year AND DtPCH.DUNSNUMBER=eid.DUNSNumber
	--left outer join Vendor.StandardizedVendorNameHistory as nameh
	--on interior.fiscal_year=nameh.Fiscal_Year and eid.VendorName=nameh.StandardizedVendorName
			

	



















GO


