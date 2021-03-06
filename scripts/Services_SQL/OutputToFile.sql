USE CSIS360
GO


--For instructions see https://github.com/CSISdefense/DIIGsql/blob/master/Doc/Output_Large_Dataset.md


SET ANSI_WARNINGS OFF;
SET NOCOUNT ON;

--Base and all options 250M examination
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
 60378093 ,
 18192191 ,
 18504240 ,
 24685121  ,
 8665643 ,
 25049082  ,
 1286145  ,
 2362527 ,
 27649914  ,
 8666052,
 8114536  ,
 3229787  ,
 8413869 ,
 24799263  ,
 9991108 ,
 61815629  ,
 2970558 ,
  8413827 ,
  24798438
))
 
--Base and exercised options 10x examination
select f.*, t.CSIScontractID
from contract.csistransactionid t
inner join contract.fpds f
on f.csistransactionid = t.csistransactionid
where f.CSIStransactionID in 
(select CSIStransactionID
from contract.csistransactionid ctid
where ctid.csiscontractid in (
1416351, 
2141645, 
2141646, 
2141647,  
3157486,  
8441432,
8441452,
8441462,
8568990,
10060563,
26427614
))


SET ANSI_WARNINGS OFF;
SET NOCOUNT ON;

DECLARE	@return_value int

--EXEC	@return_value = [Vendor].[SP_EntityIDhistory]
EXEC	@return_value = Contract.SP_ContractCeilingBreachCustomer
--EXEC	@return_value = Contract.[SP_ContractBudgetDecisionTree]
		@Customer = NULL





SET ANSI_WARNINGS OFF;
SET NOCOUNT ON;

select *
from ProductOrServiceCode.ProdServHistoryCFTEcoalesceLaggedConst

DECLARE	@return_value int

--EXEC	@return_value = [Vendor].[SP_EntityIDhistory]
EXEC	@return_value = [Vendor].[SP_EntityIDhistoryNAICS]
--EXEC	@return_value = Contract.[SP_ContractBudgetDecisionTree]
		@Customer = 'Defense'
		
SET ANSI_WARNINGS OFF;
SET NOCOUNT ON;

--DECLARE	@return_value int
EXEC	[Contract].[SP_ContractExercisedOptions]
@IsDefense = NULL

--SELECT	'Return Value' = @return_value
SET ANSI_WARNINGS OFF;
SET NOCOUNT ON;

EXEC	[Office].[sp_OfficeHistoryCapacityLaggedConst]
		--@Customer = 'Defense'


		--SELECT	'Return Value' = @return_value
SET ANSI_WARNINGS OFF;
SET NOCOUNT ON;

EXEC	[Office].[sp_EntityIDofficeHistoryLaggedConst]
		--@Customer = 'Defense'


--SELECT	'Return Value' = @return_value
SET ANSI_WARNINGS OFF;
SET NOCOUNT ON;

EXEC	Office.sp_ProdServOfficeHistoryLaggedConst
		--@Customer = 'Defense'

		
		
--SELECT	'Return Value' = @return_value
SET ANSI_WARNINGS OFF;
SET NOCOUNT ON;

--EXEC	@return_value = [Vendor].[SP_EntityIDhistory]
EXEC	[Contract].[SP_ContractEntityID]
--EXEC	@return_value = Contract.[SP_ContractBudgetDecisionTree]
		--@Customer = 'Defense'

		
		
--SELECT	'Return Value' = @return_value
SET ANSI_WARNINGS OFF;
SET NOCOUNT ON;

--EXEC	@return_value = [Vendor].[SP_EntityIDhistory]
EXEC	Office.sp_OfficeHistoryNAICS
--EXEC	@return_value = Contract.[SP_ContractBudgetDecisionTree]
		@Customer = 'Defense'
		

----SET ANSI_WARNINGS OFF;
----SET NOCOUNT ON;
----DECLARE	@return_value int

------EXEC	@return_value = [Vendor].[SP_EntityIDhistory]
----EXEC	@return_value = [Vendor].[SP_EntityIDhistoryNAICS]
------EXEC	@return_value = Contract.[SP_ContractBudgetDecisionTree]
----		@Customer = NULL
----This resulted in a blank file!
----SELECT	'Return Value' = @return_value


--SET ANSI_WARNINGS OFF;
--SET NOCOUNT ON;

--DECLARE	@return_value int

----EXEC	@return_value = [Vendor].[SP_EntityIDhistory]
--EXEC	@return_value = Vendor.sp_EntityCountHistoryPlatformSubCustomer
----EXEC	@return_value = Contract.[SP_ContractBudgetDecisionTree]
--		@Customer = 'Defense'
		
----SELECT	'Return Value' = @return_value


--SET ANSI_WARNINGS OFF;
--SET NOCOUNT ON;

--DECLARE	@return_value int

----EXEC	@return_value = [Vendor].[SP_EntityIDhistory]
--EXEC	@return_value = Vendor.sp_EntityCountHistorySubCustomer
----EXEC	@return_value = Contract.[SP_ContractBudgetDecisionTree]
--		@Customer = 'Defense'
		
----SELECT	'Return Value' = @return_value


--SET ANSI_WARNINGS OFF;
--SET NOCOUNT ON;

--DECLARE	@return_value int

----EXEC	@return_value = [Vendor].[SP_EntityIDhistory]
--EXEC	@return_value = Vendor.sp_EntityCountHistoryPlatformCustomer
----EXEC	@return_value = Contract.[SP_ContractBudgetDecisionTree]
--		@Customer = 'Defense'
		
----SELECT	'Return Value' = @return_value


--SET ANSI_WARNINGS OFF;
--SET NOCOUNT ON;

--DECLARE	@return_value int

----EXEC	@return_value = [Vendor].[SP_EntityIDhistory]
--EXEC	@return_value = Vendor.sp_EntityCountHistoryCustomer
----EXEC	@return_value = Contract.[SP_ContractBudgetDecisionTree]
--		@Customer = 'Defense'
		
----SELECT	'Return Value' = @return_value




--SET ANSI_WARNINGS OFF;
--SET NOCOUNT ON;

----DECLARE	@return_value int

--EXEC	
-- [Vendor].[SP_DunsnumberNewEntrants]
--		@Customer = NULL,
--		@IsSAMduns = NULL

----SELECT	'Return Value' = @return_value

--GO
