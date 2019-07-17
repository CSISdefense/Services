select f.*, t.CSIScontractID
from contract.csistransactionid t
inner join contract.fpds f
on f.csistransactionid = t.csistransactionid
where f.CSIStransactionID in 
(select CSIStransactionID
from contract.csistransactionid ctid
where ctid.csiscontractid in (
10060591,
2893470,
60378093,
18192191,
18504240,
24685121,
8665643,
25049082,
1286145,
2362527,
27649914,
8666052,
8114536,
8413869,
24799263,
9991108,
61815629,
2970558,
8413827,
24798438
))