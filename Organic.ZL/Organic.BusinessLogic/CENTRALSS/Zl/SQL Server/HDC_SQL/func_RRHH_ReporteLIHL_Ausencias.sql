USE [ZL]
GO

/****** Object:  UserDefinedFunction [dbo].[func_RRHH_ReporteLIHL_Ausencias]    Script Date: 08/05/2013 10:12:42 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[func_RRHH_ReporteLIHL_Ausencias]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[func_RRHH_ReporteLIHL_Ausencias]
GO

USE [ZL]
GO

/****** Object:  UserDefinedFunction [dbo].[func_RRHH_ReporteLIHL_Ausencias]    Script Date: 08/05/2013 10:12:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ================================================
-- Author:		Gaston Malusardi / Daniel Correa
-- Create date: 05/08/2013
-- Description:	Devuelve las ausencias en un rango
--              dado de fechas
-- ================================================
CREATE FUNCTION [dbo].[func_RRHH_ReporteLIHL_Ausencias] 
(	
	@FECHADESDE DATETIME
	, @FECHAHASTA DATETIME
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT 
		AUSENCIAS.LEGAJO AS [LEGAJO]
		, AUSENCIAS.APELLIDOYNOMBRES AS [CAPENOM] 
		, NULL AS [FCHREG] 
		, AUSENCIAS.FECHA AS [FECHA]
		, NULL AS [HORAREG]
		, NULL AS [TIPO]
		, NULL AS [HORARIOESQUEMA]
		, NULL AS [TOLERANCIA]
		, NULL AS [DESVIO]
		, AUSENCIAS.TIPOINCUMPLIMPIENTO AS [TIPOINCUMPLIMIENTO]
		, DATOS.CODPUESTO AS [CODPUESTO]
		, DATOS.AREA AS [AREA]
		, DATOS.SECTOR AS [SECTOR]
		, DATOS.ESQUEMA AS [ESQUEMA]
		, DATOS.ASIGESQ AS [ASIGESQ]
		, DATOS.INGRESOESQUEMA AS [INGRESOESQUEMA]
		, DATOS.EGRESOESQUEMA AS [EGRESOESQUEMA]
		, NULL AS [MINUTOS]
		, NULL AS [ANIO]
		, NULL AS [MES]
		, NULL AS [IDA]
	FROM 
		[OBJETIVOS].[FUNC_RRHH_INCUMPLIMIENTOSAUSENCIAS]( '', @FECHADESDE , @FECHAHASTA  ) AS AUSENCIAS
		LEFT JOIN (SELECT * FROM [Objetivos].[func_RRHH_FichajeAplicarEsquemas](CONVERT(VARCHAR(8), @FECHADESDE, 112), CONVERT(VARCHAR(8), @FECHAHASTA, 112))) AS DATOS 
			ON DATOS.LEGAJO = [AUSENCIAS].[LEGAJO]
	)

GO
