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

	IF (@IsDefense is not null) --Begin sub path where only services only one Customer will be returned
	BEGIN
		--Copy the start of your query here
	 
		select distinct cc.[CSIScontractID]
		,AnyUnmodifiedUnexercisedOptions
		,AnyUnmodifiedUnexercisedOptionsWhy
		,SumOfUnmodifiedbaseandexercisedoptionsvalue as UnmodifiedBaseandExercisedOptionsValue
		,ExercisedOptions
		,RescindedOptions
   --   ,cc.[TypeOfContractPricing]
   --   ,[UnmodifiedTypeOfContractPricing]
	  --,IsLabeledPricing
   --   ,[ObligatedAmountIsFixedPrice]
   --   ,[IsFixedPrice]
   --   ,[UnmodifiedIsFixedPrice]
   --   ,[ObligatedAmountIsCostBased]
   --   ,[IsCostBased]
   --   ,[UnmodifiedIsCostBased]
   --   ,[ObligatedAmountIsCombination]
   --   ,[IsCombination]
   --   ,[UnmodifiedIsCombination]
   --   ,[ObligatedAmountIsIncentive]
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
	  --,IsUCA
	  --,UnmodifiedIsUCA
from contract.fpds f
inner join contract.CSIStransactionID ct
on ct.CSIStransactionID=f.CSIStransactionID
inner join contract.ContractDiscretization cc
on ct.CSIScontractID=cc.CSIScontractID
inner join FPDSTypeTable.agencyid a
on f.contractingofficeagencyid=a.AgencyID
where a.IsDefense=@IsDefense
	END
	ELSE --Begin sub path wall Customers will be returned
		BEGIN
		--Copy the start of your query here
		select  cc.[CSIScontractID]
			,SumOfUnmodifiedbaseandexercisedoptionsvalue as UnmodifiedBaseandExercisedOptionsValue
			,AnyUnmodifiedUnexercisedOptions
		,AnyUnmodifiedUnexercisedOptionsWhy
		,ExercisedOptions
		,RescindedOptions
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

		--End of your query
		END
	END
GO


