alter view ProductOrServiceCode.ProdServHistoryCFTEcoalesce
as 
/****** Script for SelectTopNRows command from SSMS  ******/
select PSCFY.fiscal_year
,coalesce(p4.OCO_GF,p4avg.OCO_GF,p1.OCO_GF,p1avg.OCO_GF) as OCO_GF
,PSCFY.ProductOrServiceCode
,psc.ProductOrServiceCode1L
,psc.IsRnDdefenseSystem
,coalesce(p4.CFTE_Rate,p4avg.avgCFTE_Rate,p1.CFTE_Rate,p1avg.AvgCFTE_Rate) as CFTE_Rate_1year
,coalesce(p4.CFTE_Factor,p4avg.avgCFTE_Factor,p1.CFTE_Factor,p1avg.AvgCFTE_Factor) as CFTE_Factor_1year
,p4.CFTE_Factor as CFTE_Factor_1yearP4 
,p4avg.avgCFTE_Factor as CFTE_Factor_1yearP4avg 
,p1.CFTE_Factor as CFTE_Factor_1yearP1
,p1avg.AvgCFTE_Factor as CFTE_Factor_1yearP1avg
from (select f.fiscal_year
,f.productorservicecode
from contract.FPDS f
left outer join FPDSTypeTable.ProductOrServiceCode psc
on f.productorservicecode=psc.ProductOrServiceCode
where psc.simple in ('Service','R&D')
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
UNION
select PSCFY.fiscal_year
,coalesce(p4.OCO_GF,p4avg.OCO_GF,p1.OCO_GF,p1avg.OCO_GF) as OCO_GF
,PSCFY.ProductOrServiceCode
,psc.ProductOrServiceCode1L
,psc.IsRnDdefenseSystem
,coalesce(p4.CFTE_Rate,1/p4.CFTE_Factor,p4avg.avgCFTE_Rate,p1.CFTE_Rate,1/p1.CFTE_Factor,p1avg.AvgCFTE_Rate) as CFTE_Rate_1year
,coalesce(p4.CFTE_Factor,p4avg.avgCFTE_Factor,p1.CFTE_Factor,p1avg.AvgCFTE_Factor) as CFTE_Factor_1year
,p4.CFTE_Factor as CFTE_Factor_1yearP4 
,p4avg.avgCFTE_Factor as CFTE_Factor_1yearP4avg 
,p1.CFTE_Factor as CFTE_Factor_1yearP1
,p1avg.AvgCFTE_Factor as CFTE_Factor_1yearP1avg
from (select f.fiscal_year
,f.productorservicecode
from contract.FPDS f
left outer join FPDSTypeTable.ProductOrServiceCode psc
on f.productorservicecode=psc.ProductOrServiceCode
where psc.simple in ('Service','R&D')
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
