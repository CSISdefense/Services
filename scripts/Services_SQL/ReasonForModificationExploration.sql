select f.reasonformodification
,rm.reasonformodificationText
,sum(f.obligatedamount) as obligatedamount
,sum(f.baseandexercisedoptionsvalue) as baseandexercisedoptionsvalue
,sum(f.baseandalloptionsvalue) baseandalloptionsvalue
,count(distinct ctid.csiscontractid) as nCont
,count(f.CSIStransactionID) as nTran
,count(distinct iif(f.baseandexercisedoptionsvalue>0,ctid.csiscontractid,NULL)) as PositiveExercisedContract
,count(distinct iif(f.baseandexercisedoptionsvalue>coalesce(f.baseandalloptionsvalue,0) and f.baseandexercisedoptionsvalue>0
	,ctid.csiscontractid,null)) as NetExercisedContract
from contract.FPDS f
left outer join contract.CSIStransactionID ctid
on f.CSIStransactionID=ctid.CSIStransactionID
left outer join contract.ContractDiscretization cd
on ctid.CSIScontractID = cd.CSIScontractID
left outer join FPDSTypeTable.reasonformodification rm
on f.reasonformodification=rm.reasonformodification

where f.fiscal_year>=2007 and cd.StartFiscal_Year>=2007
group by f.reasonformodification
,rm.reasonformodificationText