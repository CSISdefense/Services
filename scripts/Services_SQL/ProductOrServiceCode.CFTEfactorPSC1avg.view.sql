/****** Object:  View [ProductOrServiceCode].[CFTEfactorPSC1avg]    Script Date: 5/7/2019 8:43:37 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/****** Script for SelectTopNRows command from SSMS  ******/
ALTER view [ProductOrServiceCode].[CFTEfactorPSC1avg]
as 
SELECT   [PSC]
      --,[PSC_Description]
      --,[Contract_Invoiced_Amount]
      --,[Number_of_Contractor_FTEs]
      ,avg(coalesce([CFTE_Rate]/def.GDPdeflator,1/([CFTE_Factor]*def.GDPdeflator))) as AvgCFTE_RateConst
	  --Because the rate is the inverted factor, deflator is multipled by factor rather than dividing it.
      ,avg([CFTE_Factor]*def.GDPdeflator) as AvgCFTE_FactorConst
      ,[OCO_GF]
      --,[Fiscal_Year]
      --,[Direct_Non_Labor_Cost]
      --,[Direct_Labor_Dollars]
      --,[Location_Count]
      ,[IsRnDdefenseSystem]
	  ,max(def.GDPdeflatorName) as GDPdeflatorName
  FROM [ProductOrServiceCode].[CFTEfactorPSC1] as cfte
  left outer join Economic.Deflators def
  on cfte.Fiscal_Year=def.Fiscal_Year
  where CFTE_Factor is not null
  group by [PSC],[OCO_GF],[IsRnDdefenseSystem]
  
  
GO


