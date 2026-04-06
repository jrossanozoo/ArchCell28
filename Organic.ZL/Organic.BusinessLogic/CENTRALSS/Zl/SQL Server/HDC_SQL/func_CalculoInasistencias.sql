USE [ZL]
GO

/****** Object:  UserDefinedFunction [Objetivos].[func_CalculoInasistencias]    Script Date: 04/30/2013 17:29:59 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Objetivos].[func_CalculoInasistencias]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Objetivos].[func_CalculoInasistencias]
GO

USE [ZL]
GO

/****** Object:  UserDefinedFunction [Objetivos].[func_CalculoInasistencias]    Script Date: 04/30/2013 17:29:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =================================================
-- Author:		Hector Daniel Correa
-- Create date: 30/04/2013
-- Description:	Calcula las ausencias para un legajo
--              dado entre un período de fechas
-- =================================================
CREATE FUNCTION [Objetivos].[func_CalculoInasistencias]
(
	@FechaInicio AS DATETIME
	, @FechaFin AS DATETIME
	, @Legajo AS VARCHAR(4)
)
RETURNS 
	@TABLA TABLE 
(
	VALOR INT
)
AS
BEGIN
	INSERT INTO @TABLA
		SELECT     
		SUM(DATEDIFF(DD,ZL.AUSENC.FECHAI,ZL.AUSENC.FECHAF)) AS DIAS
	FROM
		ZL.AUSENC 
	WHERE 
		ZL.AUSENC.FECHAI >= @FechaInicio
		AND ZL.AUSENC.FECHAF <= @FechaFin
		AND ZL.AUSENC.LEG = @Legajo
	
	RETURN 
END

GO

declare
	@FechaInicio AS DATETIME
	, @FechaFin AS DATETIME
	, @Legajo AS VARCHAR(4);
set @FechaInicio = '20110401';
set @FechaFin = getdate();
set @Legajo = '0091';

SELECT * FROM [ZL].[ObjEtivos].[func_CalculoInasistencias](@FechaInicio, @FechaFin, @Legajo)
go