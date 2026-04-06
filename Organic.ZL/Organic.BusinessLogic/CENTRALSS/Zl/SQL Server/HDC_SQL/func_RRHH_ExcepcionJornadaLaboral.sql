USE [ZL]
GO

/****** Object:  UserDefinedFunction [Objetivos].[func_RRHH_ExcepcionJornadaLaboral]    Script Date: 07/31/2013 10:52:07 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Objetivos].[func_RRHH_ExcepcionJornadaLaboral]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Objetivos].[func_RRHH_ExcepcionJornadaLaboral]
GO

USE [ZL]
GO

/****** Object:  UserDefinedFunction [Objetivos].[func_RRHH_ExcepcionJornadaLaboral]    Script Date: 07/31/2013 10:52:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- ===========================================================================
-- Author:		Daniel Correa
-- Create date: 12/07/2013
-- Description:	Función que devuelve, de haberlo, el comprobante y la fecha
--              con la hora y minutos de entrada
--              y la hora y minutos de salida
--              de un Registro de Excepción de Jornada Laboral
--              para calcular la llegada tarde
-- ===========================================================================
CREATE FUNCTION [Objetivos].[func_RRHH_ExcepcionJornadaLaboral] 
(
	@Legajo varchar(4)
	, @Fecha datetime
)
RETURNS 
	@Excepcion TABLE 
	(
		CODIN NUMERIC(8,0)
		, INGRESO DATETIME
		, EGRESO DATETIME
	)
AS
BEGIN
	INSERT INTO @Excepcion
	SELECT
		DISTINCT
		COMPROBANTE.CODIN
		, CONVERT(DATETIME, CONVERT(VARCHAR(10), @Fecha, 102)+' '+ZL.SALEXCJOR.HINICIO+':'+ZL.SALEXCJOR.MINICIO, 102) AS [INGRESO]
		, CONVERT(DATETIME, CONVERT(VARCHAR(10), @Fecha, 102)+' '+ZL.SALEXCJOR.HFIN+':'+ZL.SALEXCJOR.MFIN, 102) AS [EGRESO]
	FROM 
		ZL.SALEXCJOR
		INNER JOIN (SELECT * FROM [ZL].[OBJETIVOS].LEGAJOACTIVO('', CONVERT(VARCHAR(8), @Fecha, 112))) AS ACTIVOS ON ACTIVOS.LEGAJO = ZL.SALEXCJOR.USU
		INNER JOIN (SELECT MAX(CODIN) AS CODIN, MAX(FMODIFW) AS FMODIFW, MAX(HMODIFW) AS HMODIFW, USU, FECDESDE, FECHASTA FROM ZL.SALEXCJOR GROUP BY USU, FECDESDE, FECHASTA) AS COMPROBANTE
			ON COMPROBANTE.USU = ZL.SALEXCJOR.USU AND @Fecha BETWEEN COMPROBANTE.FECDESDE AND COMPROBANTE.FECHASTA
	WHERE
		ACTIVOS.CLEGAJO = @LEGAJO
		AND @Fecha BETWEEN ZL.SALEXCJOR.FECDESDE AND ZL.SALEXCJOR.FECHASTA
	
	RETURN 
END


GO


--select * from [Objetivos].[func_RRHH_ExcepcionJornadaLaboral]('0228', '20130731')
--declare @Fecha datetime;
--set @fecha = '20130731';
--SELECT * FROM [ZL].[OBJETIVOS].LEGAJOACTIVO('', CONVERT(VARCHAR(8), @Fecha, 112)) order by legajo
--SELECT MAX(CODIN) AS CODIN, MAX(FMODIFW) AS FMODIFW, MAX(HMODIFW) AS HMODIFW, USU, FECDESDE, FECHASTA FROM ZL.SALEXCJOR 
--where @Fecha BETWEEN FECDESDE AND FECHASTA
--GROUP BY USU, FECDESDE, FECHASTA