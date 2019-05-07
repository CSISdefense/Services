/****** Object:  StoredProcedure [Office].[sp_EntityIDofficeHistoryLagged]    Script Date: 5/7/2019 7:00:59 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:      <Author, , Name>
-- Create Date: <Create Date, , >
-- Description: <Description, , >
-- =============================================
ALTER PROCEDURE [Office].[sp_EntityIDofficeHistoryLagged]
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
 [EntityID]
      ,[ContractingOfficeCode]
      ,[fiscal_year]
      ,[office_entity_paircount_7year]
      ,[office_entity_numberofactions_1year]
      ,[office_entity_obligatedamount_7year]
	  ,GDPdeflatorName
  FROM [Office].[EntityIDofficeHistoryLagged]

END
GO


