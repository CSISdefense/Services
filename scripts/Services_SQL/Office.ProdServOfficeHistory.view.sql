/****** Object:  View [Office].[ProdServOfficeHistory]    Script Date: 5/7/2019 7:34:09 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER  VIEW [Office].[ProdServOfficeHistory]	
AS



	
	select C.contractingofficeid as ContractingOfficeCode
	,C.ProductOrServiceCode
	,C.fiscal_year
	,sum(C.obligatedamount/def.GDPdeflator) as ObligatedAmountConst
	,sum(C.numberofactions) as numberofactions
	,max(def.GDPdeflatorName) as GDPdeflatorName
	from Contract.FPDS as C
	left outer join Economic.Deflators def
    on c.fiscal_year=def.Fiscal_Year 
	group by c.productorservicecode
		,c.fiscal_year
		,c.contractingofficeid
	














GO


