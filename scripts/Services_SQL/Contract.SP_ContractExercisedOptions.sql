/****** Object:  StoredProcedure [Contract].[SP_ContractPricingCustomer]    Script Date: 3/27/2018 4:55:41 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Greg Sanders
-- Create date: 2/01/2013
-- Description:	Break down contracts by size.
-- =============================================
Alter PROCEDURE [Contract].[SP_ContractExercisedOptions]
	-- Add the parameters for the stored procedure here
	@IsDefense Bit
	--@ServicesOnly Bit
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statementIDVPIID.
	SET NOCOUNT ON;

	-- Insert statements for procedure here

		--Copy the start of your query here
	 		select  cc.[CSIScontractID]
		,AnyUnmodifiedUnexercisedOptions
		,AnyUnmodifiedUnexercisedOptionsWhy
		,UnmodifiedBase
		,SteadyScopeOptionGrowthAlone
		,SteadyScopeOptionGrowthMixed
		,SteadyScopeOptionRescision
		,AdminOptionModification
		,ChangeOrderOptionModification
		,EndingOptionModification
		,OtherOptionModification
		,SumOfbaseandexercisedoptionsvalue
   --   ,cc.[TypeOfContractPricing]
   --   ,[UnmodifiedTypeOfContractPricing]
   --   ,[ObligatedAmountIsFixedPrice]
   --   ,[IsFixedPrice]
   --   ,[UnmodifiedIsFixedPrice]
   --   ,[ObligatedAmountIsCostBased]
   --   ,[IsCostBased]
   --   ,[UnmodifiedIsCostBased]
   --   ,[ObligatedAmountIsCombination]
   --   ,[IsCombination]
   --   ,[UnmodifiedIsCombination]
   --    ,[ObligatedAmountIsIncentive]
   --   ,[IsIncentive]
   --   ,[UnmodifiedIsIncentive]
   --   ,[ObligatedAmountIsAwardFee]
   --   ,[IsAwardFee]
   --   ,[UnmodifiedIsAwardFee]
   --   ,[ObligatedAmountIsFFPorNoFee]
   --   ,[IsFFPorNoFee]
   --   ,[UnmodifiedIsFFPorNoFee]
   --   ,[ObligatedAmountIsFixedFee]
   --   ,[IsFixedFee]
   --   ,[UnmodifiedIsFixedFee]
   --   ,[ObligatedAmountIsOtherFee]
   --   ,[IsOtherFee]
   --   ,[UnmodifiedIsOtherFee]
	  --  ,IsUCA
	  --,UnmodifiedIsUCA
from contract.ContractDiscretization cc
where @IsDefense is null or cc.CSIScontractID in 
	(select CSIScontractID
	from contract.CSIStransactionID ctid
	inner join FPDSTypeTable.agencyid a
	on ctid.contractingofficeagencyid=a.AgencyID
	where a.IsDefense=@IsDefense 
	group by CSIScontractID)

		--End of your query

	END
GO


