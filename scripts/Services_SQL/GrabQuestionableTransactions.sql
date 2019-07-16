select f.*, t.CSIScontractID
from contract.csistransactionid t
inner join contract.fpds f
on f.csistransactionid = t.csistransactionid
where f.CSIStransactionID in 
(select CSIStransactionID
from contract.csistransactionid ctid
where ctid.csiscontractid in (
1416351,
8568990,
8441432,
8441462
))