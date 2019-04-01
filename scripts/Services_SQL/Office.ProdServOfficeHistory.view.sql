/****** Object:  View [Vendor].[EntityIDhistory]    Script Date: 4/1/2019 1:16:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


alter  VIEW Office.[ProdServOfficeHistory]
AS



	
	select contractingofficeid as ContractingOfficeCode
	,ProductOrServiceCode
	,fiscal_year
	,sum(obligatedamount) as obligatedamount
	,sum(numberofactions) as numberofactions
	from Contract.FPDS as C
	group by c.productorservicecode
		,c.fiscal_year
		,c.contractingofficeid
	















GO


