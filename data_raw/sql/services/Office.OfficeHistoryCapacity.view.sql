/****** Object:  View [Office].[TFBSOOfficeBucketSubCustomer]    Script Date: 3/17/2019 9:23:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER VIEW [Office].OfficeHistoryCapacity
AS

SELECT CurrOff.[fiscal_year]
      ,CurrOff.[C_officeID]
      ,CurrOff.[contractingofficeagencyid]
      ,CurrOff.[ProductOrServiceCodeCount]
      ,CurrOff.[ProductOrServiceAreaCount]
      ,CurrOff.[DetailedIndustryCount]
      ,CurrOff.[SubSectorCount]
      ,CurrOff.[NumberOfPlaceCountries]
      ,CurrOff.[NumberOfTransactions]
      ,CurrOff.[NumberOfContracts]
      ,CurrOff.[NumberOfParentContracts]
      ,CurrOff.[numberofactions]
	  ,CurrOff.[PBSCobligated] / CurrOff.[obligatedamount] as PBSCpercent

      ,CurrOff.[obligatedamount] as ObligatedCurrent




	  ,iif(PastOff.fiscal_year=fiscal_year-1,PastOff.[obligatedamount],NULL) as ObligatedPast1
	  ,iif(PastOff.fiscal_year=fiscal_year-2,PastOff.[obligatedamount],NULL) as ObligatedPast2
	  ,iif(PastOff.fiscal_year=fiscal_year-3,PastOff.[obligatedamount],NULL) as ObligatedPast3
	  ,iif(PastOff.fiscal_year=fiscal_year-4,PastOff.[obligatedamount],NULL) as ObligatedPast4
	  ,iif(PastOff.fiscal_year=fiscal_year-5,PastOff.[obligatedamount],NULL) as ObligatedPast5
	  ,iif(PastOff.fiscal_year=fiscal_year-6,PastOff.[obligatedamount],NULL) as ObligatedPast6

	  ,sum(PastOff.[obligatedamount]) as Obligated7year
      --,[PBSCobligated]
      --,[ServicesObligated]
  FROM [Office].[OfficeHistoryCapacityPartial] CurrOff
  left outer join [Office].[OfficeHistoryCapacityPartial] PastOff
  on CurrOff.[C_officeID]=PastOff.[C_officeID]
  and CurrOff.[contractingofficeagencyid]=PastOff.[contractingofficeagencyid]
  --Join to all fiscal years between t-1 and t-6, a 7 year period
  and CurrOff.fiscal_year>PastOff.fiscal_year and 
		CurrOff.fiscal_year-6<=PastOff.fiscal_year




--SELECT        
--C.fiscal_year
--, co.ContractingOfficeCode as C_officeID
--, c.contractingofficeagencyid
--,count(distinct c.productorservicecode) as ProductOrServiceCodeCount
--,count(distinct ProductServiceOrRnDarea) as ProductOrServiceAreaCount
--,count(distinct c.principalnaicscode) as DetailedIndustryCount
--,count(distinct naics.principalNAICS3DigitCode) as SubSectorCount
--, sum(c.obligatedamount) as obligatedamount 
--, sum(c.numberofactions) as  numberofactions
--,sum(iif(perf.[isperformancebasedcontract]=1,c.obligatedamount,NULL)) as PBSCobligated
--,sum(iif(psc.IsService=1,c.obligatedamount,NULL)) as ServicesObligated
----, SUM(C.obligatedamount) AS SumOfobligatedAmount
----, SUM(C.numberofactions) AS SumOfnumberOfActions
--, count(distinct CountryCode.Country3LetterCodeText) as NumberOfPlaceCountries
--,count(c.CSIStransactionID) as NumberOfTransactions
--,count(distinct ctid.CSIScontractID) as NumberOfContracts
--,count(distinct iif(ctid.csisidvmodificationid<>656978, ccid.CSISidvpiidID,NULL))+ --Number of IDVids
--	count(distinct iif(ctid.csisidvmodificationid=656978, ccid.csiscontractid,NULL)) as NumberOfParentContracts
--FROM            Contract.FPDS AS C
-- LEFT OUTER JOIN FPDSTypeTable.ProductOrServiceCode AS PSC 
-- ON C.productorservicecode = PSC.ProductOrServiceCode 
-- left outer  join fpdstypetable.PerformanceBasedServiceContract perf
--on c.PerformanceBasedServiceContract=perf.PerformanceBasedServiceContract
--		--LEFT OUTER JOIN
--		--	FPDSTypeTable.AgencyID AS CAgency 
--		--		ON C.contractingofficeagencyid = CAgency.AgencyID
--		--LEFT OUTER JOIN
--		--	FPDSTypeTable.AgencyID AS FAgency
--		--		ON C.fundingrequestingagencyid = FAgency.AgencyID 
-- LEFT OUTER JOIN FPDSTypeTable.Country3LetterCode AS CountryCode 
-- ON C.placeofperformancecountrycode = CountryCode.Country3LetterCode
-- left outer join Office.ContractingOfficeCode as CO
-- on c.contractingofficeid=co.ContractingOfficeCode
----left outer join office.ContractingAgencyIDofficeIDtoMajorCommandIDhistory as cO2MCC
----	on co.ContractingOfficeCode=co2mcc.ContractingOfficeID and 
----	c.contractingofficeagencyid=co2mcc.ContractingAgencyID and
----	c.fiscal_year=co2mcc.Fiscal_Year				
--left outer join contract.csistransactionid as ctid
--on ctid.CSIStransactionID=c.CSIStransactionID
--left outer join contract.CSIScontractID as ccid
--on ccid.CSIScontractID=ctid.CSIScontractID
--left outer join FPDSTypeTable.PrincipalNaicsCode naics
--on c.principalnaicscode=naics.principalnaicscode
----left outer join contract.ContractLabelID as label
----on cid.ContractLabelID=label.ContractLabelID

--GROUP BY 
--C.fiscal_year
--, co.ContractingOfficeCode 
----, co2mcc.ContractingOfficeName 
--, c.contractingofficeagencyid
----, cO2MCC.MajorCommandName 
----, cO2MCC.MajorCommandCode 
----,ISNULL(CAgency.Customer, CAgency.AGENCYIDText) 
----,ISNULL(CAgency.subCustomer, CAgency.AGENCYIDText) 

----C.fiscal_year
----, c.idvpiid
----, c.piid
----,label.TFBSOmentioned
---- , label.TFBSOoriginated
----, iif(co.TFBSOrelated=1 or fo.TFBSOrelated=1,1,0)
----,ISNULL(CAgency.Customer, CAgency.AGENCYIDText)
----,COALESCE(FAgency.Customer, FAgency.AgencyIDText, CAgency.Customer, CAgency.AGENCYIDText) 
----,ISNULL(CAgency.subCustomer, CAgency.AGENCYIDText)
----	,COALESCE(FAgency.subCustomer, FAgency.AgencyIDText, CAgency.subCustomer, CAgency.AGENCYIDText)
----, PSC.ServicesCategory
----, PSC.IsService
----, CountryCode.Country3LetterCodeText
----, co.OfficeID 
----, co.Depot 
----, co.FISC 
----, co2mcc.ContractingOfficeName 
----, cO2MCC.MajorCommandName 
----, cO2MCC.MajorCommandCode 
----, fo.OfficeID 
----, fo.Depot
----, fo.FISC 
----, fo2mcc.ContractingOfficeName 
----, fO2MCC.MajorCommandName 
----, fO2MCC.MajorCommandCode 
----, c.descriptionofcontractrequirement
----, c.solicitationid
----, c.vendorcountrycode
----,label.TFBSOmentioned
----,label.TFBSOoriginated





GO


