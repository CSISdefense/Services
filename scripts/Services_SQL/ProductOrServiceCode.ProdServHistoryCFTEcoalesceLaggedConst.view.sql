/****** Object:  View [ProductOrServiceCode].[ProdServHistoryCFTEcoalesce]    Script Date: 5/7/2019 8:55:51 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER view [ProductOrServiceCode].[ProdServHistoryCFTEcoalesceLaggedConst]
as 
/****** Script for SelectTopNRows command from SSMS  ******/
select PSCFY.fiscal_year
,coalesce(p4.OCO_GF,p4avg.OCO_GF,p1.OCO_GF,p1avg.OCO_GF) as OCO_GF
,PSCFY.ProductOrServiceCode
,psc.ProductOrServiceCode1L
,psc.IsRnDdefenseSystem
,coalesce(p4.CFTE_Rate/def_lag1.GDPdeflator,p4avg.AvgCFTE_RateConst,p1.CFTE_Rate/def_lag1.GDPdeflator,p1avg.AvgCFTE_RateConst) as CFTE_Rate_1year
,coalesce(p4.CFTE_Factor*def_lag1.GDPdeflator,p4avg.AvgCFTE_FactorConst,p1.CFTE_Factor*def_lag1.GDPdeflator,p1avg.AvgCFTE_FactorConst) as CFTE_Factor_1year
,p4.CFTE_Factor*def_lag1.GDPdeflator as CFTE_Factor_1yearP4 
,p4avg.AvgCFTE_FactorConst as CFTE_Factor_1yearP4avg 
,p1.CFTE_Factor*def_lag1.GDPdeflator as CFTE_Factor_1yearP1
,p1avg.AvgCFTE_FactorConst as CFTE_Factor_1yearP1avg
,def_lag1.GDPdeflatorName
from (select f.fiscal_year
,f.productorservicecode
from contract.FPDS f
left outer join FPDSTypeTable.ProductOrServiceCode psc
on f.productorservicecode=psc.ProductOrServiceCode
where psc.simple in ('Services','R&D')
group by f.fiscal_year
,f.productorservicecode

) as PSCFY
left outer join FPDSTypeTable.ProductOrServiceCode psc
on pscfy.productorservicecode=psc.ProductOrServiceCode

left outer join ProductOrServiceCode.CFTEfactorPSC4 p4
on PSCFY.productorservicecode=p4.psc
and PSCFY.fiscal_year=p4.Fiscal_Year+1
and p4.OCO_GF='GF'
and p4.Fiscal_Year<2017
left outer join ProductOrServiceCode.CFTEfactorPSC4avg p4avg
on PSCFY.productorservicecode=p4avg.psc
and p4avg.OCO_GF='GF'
left outer join ProductOrServiceCode.CFTEfactorPSC1 p1
on psc.ProductOrServiceCode1L=p1.psc
and PSCFY.fiscal_year=p1.Fiscal_Year+1
and psc.IsRnDdefenseSystem=p1.IsRnDdefenseSystem
and p1.OCO_GF='GF'
left outer join ProductOrServiceCode.CFTEfactorPSC1avg p1avg
on psc.ProductOrServiceCode1L=p1avg.psc
and psc.IsRnDdefenseSystem=p1avg.IsRnDdefenseSystem
and p1avg.OCO_GF='GF'
left join Economic.Deflators def_lag1
  on PSCFY.fiscal_year=def_lag1.Fiscal_Year+1




UNION
select PSCFY.fiscal_year
,coalesce(p4.OCO_GF,p4avg.OCO_GF,p1.OCO_GF,p1avg.OCO_GF) as OCO_GF
,PSCFY.ProductOrServiceCode
,psc.ProductOrServiceCode1L
,psc.IsRnDdefenseSystem
,coalesce(p4.CFTE_Rate/def_lag1.GDPdeflator,1/(p4.CFTE_Factor*def_lag1.GDPdeflator),p4avg.AvgCFTE_RateConst,p1.CFTE_Rate/def_lag1.GDPdeflator,1/p1.CFTE_Factor*def_lag1.GDPdeflator,p1avg.AvgCFTE_RateConst) as CFTE_Rate_1year
,coalesce(p4.CFTE_Factor*def_lag1.GDPdeflator,p4avg.AvgCFTE_FactorConst,p1.CFTE_Factor*def_lag1.GDPdeflator,p1avg.AvgCFTE_FactorConst) as CFTE_Factor_1year
,p4.CFTE_Factor*def_lag1.GDPdeflator as CFTE_Factor_1yearP4 
,p4avg.AvgCFTE_FactorConst as CFTE_Factor_1yearP4avg 
,p1.CFTE_Factor*def_lag1.GDPdeflator as CFTE_Factor_1yearP1
,p1avg.AvgCFTE_FactorConst as CFTE_Factor_1yearP1avg
,def_lag1.GDPdeflatorName
from (select f.fiscal_year
,f.productorservicecode
from contract.FPDS f
left outer join FPDSTypeTable.ProductOrServiceCode psc
on f.productorservicecode=psc.ProductOrServiceCode
where psc.simple in ('Services','R&D')
group by f.fiscal_year
,f.productorservicecode

) as PSCFY
left outer join FPDSTypeTable.ProductOrServiceCode psc
on pscfy.productorservicecode=psc.ProductOrServiceCode

left outer join ProductOrServiceCode.CFTEfactorPSC4 p4
on PSCFY.productorservicecode=p4.psc
and PSCFY.fiscal_year=p4.Fiscal_Year+1
and p4.OCO_GF='OCO'
and p4.Fiscal_Year<2017

left outer join ProductOrServiceCode.CFTEfactorPSC4avg p4avg
on PSCFY.productorservicecode=p4avg.psc
and p4avg.OCO_GF='OCO'

left outer join ProductOrServiceCode.CFTEfactorPSC1 p1
on psc.ProductOrServiceCode1L=p1.psc
and PSCFY.fiscal_year=p1.Fiscal_Year+1
and psc.IsRnDdefenseSystem=p1.IsRnDdefenseSystem
and p1.OCO_GF='OCO'
left outer join ProductOrServiceCode.CFTEfactorPSC1avg p1avg
on psc.ProductOrServiceCode1L=p1avg.psc
and psc.IsRnDdefenseSystem=p1avg.IsRnDdefenseSystem
and p1avg.OCO_GF='OCO'
left join Economic.Deflators def_lag1
  on PSCFY.fiscal_year=def_lag1.Fiscal_Year+1
GO


