USE CSIS360
GO


--For instructions see https://github.com/CSISdefense/DIIGsql/blob/master/Doc/Output_Large_Dataset.md



SET ANSI_WARNINGS OFF;
SET NOCOUNT ON;

select *
from ProductOrServiceCode.ProdServHistoryCFTEcoalesce

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

EXEC	[Office].[sp_OfficeHistoryCapacityLagged]
		--@Customer = 'Defense'


		--SELECT	'Return Value' = @return_value
SET ANSI_WARNINGS OFF;
SET NOCOUNT ON;

EXEC	[Office].[sp_OfficeHistoryCapacityLagged]
		--@Customer = 'Defense'




--SELECT	'Return Value' = @return_value
SET ANSI_WARNINGS OFF;
SET NOCOUNT ON;

--EXEC	@return_value = [Vendor].[SP_EntityIDhistory]
EXEC	Office.sp_EntityIDofficeHistoryLagged
--EXEC	@return_value = Contract.[SP_ContractBudgetDecisionTree]
		--@Customer = 'Defense'

		


--SELECT	'Return Value' = @return_value
SET ANSI_WARNINGS OFF;
SET NOCOUNT ON;

--EXEC	@return_value = [Vendor].[SP_EntityIDhistory]
EXEC	Office.sp_ProdServOfficeHistoryLagged
--EXEC	@return_value = Contract.[SP_ContractBudgetDecisionTree]
		--@Customer = 'Defense'

		
		
--SELECT	'Return Value' = @return_value
SET ANSI_WARNINGS OFF;
SET NOCOUNT ON;

--EXEC	@return_value = [Vendor].[SP_EntityIDhistory]
EXEC	[Contract].[SP_ContractEntityID]
--EXEC	@return_value = Contract.[SP_ContractBudgetDecisionTree]
		--@Customer = 'Defense'

		
		

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
