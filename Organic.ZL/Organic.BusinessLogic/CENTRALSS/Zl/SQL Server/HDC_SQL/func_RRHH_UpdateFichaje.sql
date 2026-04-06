USE [ZL]
GO

/****** Object:  UserDefinedFunction [Objetivos].[func_RRHH_UpdateFichaje]    Script Date: 07/31/2013 15:28:07 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Objetivos].[func_RRHH_UpdateFichaje]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Objetivos].[func_RRHH_UpdateFichaje]
GO

USE [ZL]
GO

/****** Object:  UserDefinedFunction [Objetivos].[func_RRHH_UpdateFichaje]    Script Date: 07/31/2013 15:28:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- ===========================================================================================
-- Author:		Daniel Correa
-- Create date: 18/07/2013
-- Description:	Devuelve CODPUESTO, AREA, SECTOR, ESQUEMA, ASIGNACION, INGRESO S/ESQUEMA
-- EGRESO S/ESQUEMA, TOLERANCIA y diferencia en MINUTOS entre fichada de ingreso según Esquema
-- ===========================================================================================
CREATE FUNCTION [Objetivos].[func_RRHH_UpdateFichaje] 
(	
	@LEGAJO VARCHAR(4)
	, @FECHA DATETIME
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT
		TOP 1
		/*HORAINGRESO.HORAING
		,*/ (SELECT TOP 1 C.PUESTO FROM [OBJETIVOS].[LEGAJOACTIVO](@LEGAJO, (CONVERT(varchar(8), @FECHA, 112)) ) C INNER JOIN ZL.PUESTOSRH P ON C.PUESTO = P.COD) AS [CODPUESTO]
		, (SELECT TOP 1 P.AREA FROM [OBJETIVOS].[LEGAJOACTIVO](@LEGAJO, (CONVERT(varchar(8), @FECHA, 112)) ) C INNER JOIN ZL.PUESTOSRH P ON C.PUESTO = P.COD) AS [AREA] 
		, (SELECT TOP 1 P.SECTOR FROM [OBJETIVOS].[LEGAJOACTIVO](@LEGAJO, (CONVERT(varchar(8), @FECHA, 112)) ) C INNER JOIN ZL.PUESTOSRH P ON C.PUESTO = P.COD) AS [SECTOR] 
		, (SELECT ESQLAB FROM [Objetivos].[func_RRHH_EsquemaVigentexLegajo](@LEGAJO, @FECHA)) AS ESQUEMA
		, (SELECT NUMERO FROM [Objetivos].[func_RRHH_EsquemaVigentexLegajo](@LEGAJO, @FECHA)) AS ASIGESQ

		, ISNULL(CONVERT(VARCHAR(8), ISNULL(
			(SELECT INGRESO FROM Objetivos.func_RRHH_ExcepcionJornadaLaboral(@LEGAJO, @FECHA))
			, (SELECT CONVERT(DATETIME, (CONVERT(VARCHAR(10), @FECHA, 103)+' '+HORAING), 103) FROM Objetivos.func_RRHH_DetalleEsqxDia((SELECT ESQLAB FROM [Objetivos].[func_RRHH_EsquemaVigentexLegajo](@LEGAJO, @FECHA)), [ZL].[func_ZL_DiaSemana](@FECHA)))
		), 108), '') AS 'INGRESOESQUEMA'

		, ISNULL(CONVERT(VARCHAR(8), ISNULL(
			(SELECT EGRESO FROM Objetivos.func_RRHH_ExcepcionJornadaLaboral(@LEGAJO, @FECHA))
			, (SELECT CONVERT(DATETIME, (CONVERT(VARCHAR(10), @FECHA, 103)+' '+HORAEGR), 103) FROM Objetivos.func_RRHH_DetalleEsqxDia((SELECT ESQLAB FROM [Objetivos].[func_RRHH_EsquemaVigentexLegajo](@LEGAJO, @FECHA)), [ZL].[func_ZL_DiaSemana](@FECHA)))
		), 108), '') AS 'EGRESOESQUEMA'

		, ISNULL((SELECT TOLERANCIA FROM [Objetivos].[func_RRHH_EsquemaVigentexLegajo](@LEGAJO, @FECHA)), 0) AS [TOLERANCIA]
		, (CASE
			WHEN ISNULL (
							(
								SELECT INGRESO FROM Objetivos.func_RRHH_ExcepcionJornadaLaboral(@LEGAJO, @FECHA)
							) , (
								SELECT CONVERT (DATETIME, (CONVERT(VARCHAR(10), GETDATE(), 103)+' '+HORAING), 103) FROM Objetivos.func_RRHH_DetalleEsqxDia (
																																								(
																																									SELECT ESQLAB FROM [Objetivos].[func_RRHH_EsquemaVigentexLegajo](@LEGAJO, @FECHA)
																																								), 
																																								[ZL].[func_ZL_DiaSemana](@FECHA)
																																							)
								)
						) IS NULL THEN 0
			ELSE DATEDIFF	(minute
							, (ISNULL(
										(SELECT INGRESO FROM Objetivos.func_RRHH_ExcepcionJornadaLaboral(@LEGAJO, @FECHA))
										, (SELECT CONVERT(DATETIME, (CONVERT(VARCHAR(10), @FECHA, 103)+' '+HORAING), 103) FROM Objetivos.func_RRHH_DetalleEsqxDia((SELECT ESQLAB FROM [Objetivos].[func_RRHH_EsquemaVigentexLegajo](@LEGAJO, @FECHA)), [ZL].[func_ZL_DiaSemana](@FECHA)))
									)
								)
							, HORAINGRESO.HORAING 
							)
		END) AS 'MINUTOS'			
	FROM
		[ZL].[ZNFICHAJE] AS [FICHAJES]
		LEFT JOIN [ZL].[ZNPCONTROL] AS [PTOCONTROL] ON [PTOCONTROL].[COD] = [FICHAJES].[PCONTROL]
		INNER JOIN (SELECT MIN(FCHREG) AS HORAING, FCHREG, LEGAJO FROM [ZL].[ZNFICHAJE] WHERE CONVERT(VARCHAR(10), [FCHREG], 103) = CONVERT(VARCHAR(10), @FECHA, 103) GROUP BY LEGAJO, FCHREG) AS HORAINGRESO ON HORAINGRESO.LEGAJO = [FICHAJES].LEGAJO 
	WHERE
		CONVERT(VARCHAR(10), [FICHAJES].[FCHREG], 103) = CONVERT(VARCHAR(10), @FECHA, 103)
		AND [FICHAJES].LEGAJO = @LEGAJO
	GROUP BY
		HORAINGRESO.HORAING
	ORDER BY
		HORAINGRESO.HORAING ASC
)



GO
