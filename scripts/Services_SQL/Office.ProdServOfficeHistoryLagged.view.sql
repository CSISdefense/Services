/****** Object:  View [Office].[ProdServOfficeHistoryLagged]    Script Date: 5/7/2019 7:35:51 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






ALTER  VIEW [Office].[ProdServOfficeHistoryLagged]
AS
SELECT        
o.ProductOrServiceCode
,o.ContractingOfficeCode
,o.fiscal_year
,ohistory.paircount_7year
,ohistory.numberofactions_7year
,ohistory.obligatedamount_7year
,o.GDPdeflatorName
FROM Office.[ProdServOfficeHistory] AS o
left outer join (
 select interior.ContractingOfficeCode
	,interior.productorservicecode
	,interior.fiscal_year
	,count(interior.fiscal_year) as paircount_7year
	,sum(ohistory.ObligatedAmountConst) as  obligatedamount_7year
	, sum(ohistory.numberofactions) as  numberofactions_7year
	FROM Office.[ProdServOfficeHistory] AS interior
	left outer join Office.[ProdServOfficeHistory] ohistory
	on interior.contractingofficecode=ohistory.contractingofficecode and
	ohistory.fiscal_year  between interior.fiscal_year-7 and interior.fiscal_year-1 and
	ohistory.ProductOrServiceCode = interior.ProductOrServiceCode
	GROUP BY 
	interior.fiscal_year
	, interior.ContractingOfficeCode 
	,interior.ProductOrServiceCode
	) ohistory
 on o.ContractingOfficeCode=ohistory.contractingofficecode
	and o.fiscal_year=ohistory.fiscal_year
	and o.ProductOrServiceCode=ohistory.ProductOrServiceCode
 
 
 
-- LEFT OUTER JOIN FPDSTypeTable.ProductOrServiceCode AS PSC 
-- ON C.productorservicecode = PSC.ProductOrServiceCode 
--		LEFT OUTER JOIN
--			FPDSTypeTable.AgencyID AS CAgency 
--				ON C.contractingofficeagencyid = CAgency.AgencyID
--		LEFT OUTER JOIN
--			FPDSTypeTable.AgencyID AS FAgency
--				ON C.fundingrequestingagencyid = FAgency.AgencyID 
-- LEFT OUTER JOIN FPDSTypeTable.Country3LetterCode AS CountryCode 
-- ON C.placeofperformancecountrycode = CountryCode.Country3LetterCode
-- left outer join Office.ContractingOfficeCode as CO
-- on c.contractingofficeid=co.ContractingOfficeCode
--left outer join office.ContractingAgencyIDofficeIDtoMajorCommandIDhistory as cO2MCC
--	on co.ContractingOfficeCode=co2mcc.ContractingOfficeID and 
--	c.contractingofficeagencyid=co2mcc.ContractingAgencyID and
--	c.fiscal_year=co2mcc.Fiscal_Year				
--left outer join contract.csistransactionid as ctid
--on ctid.CSIStransactionID=c.CSIStransactionID
--left outer join contract.CSIScontractID as ccid
--on ccid.CSIScontractID=ctid.CSIScontractID
--left outer join FPDSTypeTable.PrincipalNaicsCode naics
--on c.principalnaicscode=naics.principalnaicscode
--left outer join contract.ContractLabelID as label
--on cid.ContractLabelID=label.ContractLabelID


--, co2mcc.ContractingOfficeName 
--, Cagency.AgencyID
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


