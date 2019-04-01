/****** Object:  View [Office].[OfficeHistoryCapacityPartial]    Script Date: 4/1/2019 11:21:28 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [Office].[OfficeHistoryCapacityPartial]
AS
SELECT        
C.fiscal_year
, co.ContractingOfficeCode as C_officeID
, c.contractingofficeagencyid
,count(distinct c.productorservicecode) as ProductOrServiceCodeCount
,count(distinct ProductServiceOrRnDarea) as ProductOrServiceAreaCount
,count(distinct c.principalnaicscode) as DetailedIndustryCount
,count(distinct naics.principalNAICS3DigitCode) as SubSectorCount
, sum(c.obligatedamount) as obligatedamount 
, sum(c.numberofactions) as  numberofactions
,sum(iif(perf.[isperformancebasedcontract]=1,c.obligatedamount,NULL)) as PBSCobligated
,sum(iif(psc.IsService=1,c.obligatedamount,NULL)) as ServicesObligated
--, SUM(C.obligatedamount) AS SumOfobligatedAmount
--, SUM(C.numberofactions) AS SumOfnumberOfActions
, count(distinct CountryCode.Country3LetterCodeText) as NumberOfPlaceCountries
,count(c.CSIStransactionID) as NumberOfTransactions
,count(distinct ctid.CSIScontractID) as NumberOfContracts
,count(distinct iif(ctid.csisidvmodificationid<>656978, ccid.CSISidvpiidID,NULL))+ --Number of IDVids
	count(distinct iif(ctid.csisidvmodificationid=656978, ccid.csiscontractid,NULL)) as NumberOfParentContracts
FROM            Contract.FPDS AS C
 LEFT OUTER JOIN FPDSTypeTable.ProductOrServiceCode AS PSC 
 ON C.productorservicecode = PSC.ProductOrServiceCode 
 left outer  join fpdstypetable.PerformanceBasedServiceContract perf
on c.PerformanceBasedServiceContract=perf.PerformanceBasedServiceContract
		--LEFT OUTER JOIN
		--	FPDSTypeTable.AgencyID AS CAgency 
		--		ON C.contractingofficeagencyid = CAgency.AgencyID
		--LEFT OUTER JOIN
		--	FPDSTypeTable.AgencyID AS FAgency
		--		ON C.fundingrequestingagencyid = FAgency.AgencyID 
 LEFT OUTER JOIN FPDSTypeTable.Country3LetterCode AS CountryCode 
 ON C.placeofperformancecountrycode = CountryCode.Country3LetterCode
 left outer join Office.ContractingOfficeCode as CO
 on c.contractingofficeid=co.ContractingOfficeCode
--left outer join office.ContractingAgencyIDofficeIDtoMajorCommandIDhistory as cO2MCC
--	on co.ContractingOfficeCode=co2mcc.ContractingOfficeID and 
--	c.contractingofficeagencyid=co2mcc.ContractingAgencyID and
--	c.fiscal_year=co2mcc.Fiscal_Year				
left outer join contract.csistransactionid as ctid
on ctid.CSIStransactionID=c.CSIStransactionID
left outer join contract.CSIScontractID as ccid
on ccid.CSIScontractID=ctid.CSIScontractID
left outer join FPDSTypeTable.PrincipalNaicsCode naics
on c.principalnaicscode=naics.principalnaicscode
--left outer join contract.ContractLabelID as label
--on cid.ContractLabelID=label.ContractLabelID

GROUP BY 
C.fiscal_year
, co.ContractingOfficeCode 
--, co2mcc.ContractingOfficeName 
, c.contractingofficeagencyid
--, cO2MCC.MajorCommandName 
--, cO2MCC.MajorCommandCode 
--,ISNULL(CAgency.Customer, CAgency.AGENCYIDText) 
--,ISNULL(CAgency.subCustomer, CAgency.AGENCYIDText) 

--C.fiscal_year
--, c.idvpiid
--, c.piid
--,label.TFBSOmentioned
-- , label.TFBSOoriginated
--, iif(co.TFBSOrelated=1 or fo.TFBSOrelated=1,1,0)
--,ISNULL(CAgency.Customer, CAgency.AGENCYIDText)
--,COALESCE(FAgency.Customer, FAgency.AgencyIDText, CAgency.Customer, CAgency.AGENCYIDText) 
--,ISNULL(CAgency.subCustomer, CAgency.AGENCYIDText)
--	,COALESCE(FAgency.subCustomer, FAgency.AgencyIDText, CAgency.subCustomer, CAgency.AGENCYIDText)
--, PSC.ServicesCategory
--, PSC.IsService
--, CountryCode.Country3LetterCodeText
--, co.OfficeID 
--, co.Depot 
--, co.FISC 
--, co2mcc.ContractingOfficeName 
--, cO2MCC.MajorCommandName 
--, cO2MCC.MajorCommandCode 
--, fo.OfficeID 
--, fo.Depot
--, fo.FISC 
--, fo2mcc.ContractingOfficeName 
--, fO2MCC.MajorCommandName 
--, fO2MCC.MajorCommandCode 
--, c.descriptionofcontractrequirement
--, c.solicitationid
--, c.vendorcountrycode
--,label.TFBSOmentioned
--,label.TFBSOoriginated





GO


