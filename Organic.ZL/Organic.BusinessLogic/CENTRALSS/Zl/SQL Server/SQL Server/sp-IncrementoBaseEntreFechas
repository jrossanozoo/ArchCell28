USE [ZL]
GO

IF  NOT EXISTS (
 SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DIR].[sp_IncrementoBaseEntreFechas]') AND type in (N'P', N'PC'))
  begin  
    exec('create proc [DIR].[sp_IncrementoBaseEntreFechas] as ')
  end   

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [DIR].[sp_IncrementoBaseEntreFechas]
	@FechaInicial datetime
	,@FechaFinal datetime = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		IF (@FechaFinal is null)    SELECT @FechaFinal = getdate()

	EXECUTE [ZL].[DIR].[sp_IncrementoBaseEntreFechasMotor] 
	   @FechaInicial
	  ,@FechaFinal
	
	select * from  [ZL].[DIR].[Incremento]

END
