/****** Object:  View [ProductOrServiceCode].[CFTEfactorPSC4avg]    Script Date: 5/7/2019 8:43:43 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/****** Script for SelectTopNRows command from SSMS  ******/
ALTER view [ProductOrServiceCode].[CFTEfactorPSC4avg]
as 
SELECT   [PSC]
      --,[PSC_Description]
      --,[Contract_Invoiced_Amount]
      --,[Number_of_Contractor_FTEs]
      --,[CFTE_Rate]
	  ,avg(coalesce([CFTE_Rate]/def.GDPdeflator,1/([CFTE_Factor]*def.GDPdeflator))) as AvgCFTE_RateConst
	  --Because the rate is the inverted factor, deflator is multipled by factor rather than dividing it.
      ,avg([CFTE_Factor]*def.GDPdeflator) as AvgCFTE_FactorConst
      ,[OCO_GF]
      --,[Fiscal_Year]
      --,[Direct_Non_Labor_Cost]
      --,[Direct_Labor_Dollars]
      --,[Location_Count]
	  ,max(def.GDPdeflatorName) as GDPdeflatorName
  FROM [ProductOrServiceCode].[CFTEfactorPSC4] as cfte
  left join Economic.Deflators def
  on cfte.Fiscal_Year = def.Fiscal_Year
  where CFTE_Factor is not null
    and cfte.Fiscal_Year<=2016 --Temporarily excluding 2017 due to glitchy data.
  group by [PSC],[OCO_GF]
GO


