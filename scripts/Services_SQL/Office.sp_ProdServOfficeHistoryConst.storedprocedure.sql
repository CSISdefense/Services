/****** Object:  StoredProcedure [Office].[sp_ProdServOfficeHistoryLagged]    Script Date: 5/7/2019 7:36:35 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      <Author, , Name>
-- Create Date: <Create Date, , >
-- Description: <Description, , >
-- =============================================
ALTER PROCEDURE [Office].[sp_ProdServOfficeHistoryLaggedConst]
--(
--    ---- Add the parameters for the stored procedure here
--    --<@Param1, sysname, @p1> <Datatype_For_Param1, , int> = <Default_Value_For_Param1, , 0>,
--    --<@Param2, sysname, @p2> <Datatype_For_Param2, , int> = <Default_Value_For_Param2, , 0>
--)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

    -- Insert statements for procedure here
    --SELECT <@Param1, sysname, @p1>, <@Param2, sysname, @p2>
	

SET ANSI_WARNINGS OFF;
SET NOCOUNT ON;

/****** Script for SelectTopNRows command from SSMS  ******/
SELECT /****** Script for SelectTopNRows command from SSMS  ******/
[ProductOrServiceCode]
      ,[ContractingOfficeCode]
      ,[fiscal_year]
      ,[paircount_7year] as office_psc_paircount_7year
      ,[numberofactions_7year] as office_psc_numberofactions_7year
      ,[obligatedamount_7year] as office_psc_obligatedamount_7year
	  ,GDPdeflatorName
  FROM [Office].[ProdServOfficeHistoryLagged]

END
GO


