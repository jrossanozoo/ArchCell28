USE [ZL]
GO

/****** Object:  UserDefinedFunction [Objetivos].[func_EsquemaAsignadosHistoricos]    Script Date: 08/13/2013 10:28:00 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Objetivos].[func_EsquemaAsignadosHistoricos]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Objetivos].[func_EsquemaAsignadosHistoricos]
GO

USE [ZL]
GO

/****** Object:  UserDefinedFunction [Objetivos].[func_EsquemaAsignadosHistoricos]    Script Date: 08/13/2013 10:28:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- ===========================================================
-- Author:		Daniel Correa
-- Create date: 11/07/2013
-- Description:	Devuelve los Esquemas asignados históricamente
--              a cada legajo
-- ===========================================================

CREATE FUNCTION [Objetivos].[func_EsquemaAsignadosHistoricos] 
()
RETURNS 
	@Esquemas TABLE 
		(
			Legajo VARCHAR(4)
			, OperadorZL VARCHAR(25)
			, Puesto VARCHAR(4)
			, Area VARCHAR(3)
			, Sector VARCHAR(4)
			, Descripcion VARCHAR(255)
			, Nombre VARCHAR(255)
			-- ESQUEMA POR PUESTO
			, ESQASIGPTO INT DEFAULT 0
			, EsquemaxPto INT
			, xPtoAsigDesde VARCHAR(10)
			, xPtoAsigHasta VARCHAR(10)
			, xPtoAsigEstado VARCHAR(10)
			-- ESQUEMA POR LEGAJO
			, ESQASIGLEG INT DEFAULT 0
			, EsquemaxLegajo INT
			, xLegAsigDesde VARCHAR(10)
			, xLegAsigHasta VARCHAR(10)
			, xLegAsigEstado VARCHAR(10)
		)
AS
BEGIN
	INSERT INTO @Esquemas
	SELECT
		Legajo.Ccod
		, ACTIVOS.Legajo
		, ACTIVOS.Puesto
		, PUESTOS.AREA
		, PUESTOS.Sector
		, SUBSTRING(RTRIM(PUESTOS.Descr), 1, 255)
		, SUBSTRING(RTRIM(Legajo.Capellido)+' '+
					RTRIM(Legajo.Cprinombre)+' '+
					RTRIM(Legajo.CSegnombre), 1, 255) AS NOMBRE
		-- ESQUEMA POR PUESTO
		, ISNULL(ESQASIGPTO.NUMERO, 0) AS ASIGPTO
		, ISNULL(ESQASIGPTO.ESQLAB, 0) AS [ESQxPTO]
		, ISNULL(CONVERT(VARCHAR(10), ESQASIGPTO.FECDESDE, 103), '') AS [ASIGxPTODESDE]
		, CASE
			WHEN ISNULL(CONVERT(VARCHAR(10), ESQASIGPTO.FECHASTA, 103), '') = '01/01/1900' THEN ''
			ELSE ISNULL(CONVERT(VARCHAR(10), ESQASIGPTO.FECHASTA, 103), '')
		END AS [ASIGxPTOHASTA]
		, ISNULL(CASE 
			WHEN ESQASIGPTO.FECHASTA = '19000101' THEN 'Actual'
			WHEN ESQASIGPTO.FECHASTA IS NULL THEN 'Actual'
			WHEN ESQASIGPTO.FECHASTA <> '19000101' AND ESQASIGPTO.FECHASTA < GETDATE() THEN 'Vencido'
			WHEN ESQASIGPTO.FECHASTA >= GETDATE() THEN 'Actual'
			ELSE ''
		END, '') AS [ASIGxPTOESTADO]
		-- ESQUEMA POR LEGAJO
		, ISNULL(ESQASIGLEG.NUMERO, 0) AS ASIGLEG
		, ISNULL(CONVERT(VARCHAR(2), ESQASIGLEG.ESQLAB), '') AS [ESQxLEG]
		, ISNULL(CONVERT(VARCHAR(10), ESQASIGLEG.FECDESDE, 103), '') AS [ASIGxLEGDESDE]
		, CASE
			WHEN ISNULL(CONVERT(VARCHAR(10), ESQASIGLEG.FECHASTA, 103), '') = '01/01/1900' THEN ''
			ELSE ISNULL(CONVERT(VARCHAR(10), ESQASIGLEG.FECHASTA, 103), '')
		END AS [ASIGxLEGHASTA]
		, ISNULL(CASE
			WHEN ESQASIGLEG.FECHASTA = '19000101' THEN 'Actual'
			WHEN ESQASIGLEG.FECHASTA IS NULL THEN 'Actual'
			WHEN ESQASIGLEG.FECHASTA <> '19000101' AND ESQASIGLEG.FECHASTA < GETDATE() THEN 'Vencido'
			WHEN ESQASIGLEG.FECHASTA >= GETDATE() THEN 'Actual'
			ELSE ''
		END, '') AS [ASIGxLEGESTADO]
	FROM
		ZL.Legajo
		, (SELECT * FROM [ZL].[Objetivos].LegajoActivo('', CONVERT(VARCHAR(8), GETDATE(), 112))) AS ACTIVOS
		LEFT JOIN ZL.ASIGESQJLAP AS ESQASIGPTO ON ESQASIGPTO.PUESTO = ACTIVOS.Puesto 
		LEFT JOIN ZL.ASIGESQJLAB AS ESQASIGLEG ON ESQASIGLEG.LEG    = ACTIVOS.CLegajo 
		LEFT JOIN ZL.puestosrh   AS PUESTOS    ON PUESTOS.Cod       = ACTIVOS.Puesto 
	WHERE
		ZL.Legajo.Ccod = ACTIVOS.CLegajo 
	ORDER BY
		NOMBRE;
			
	RETURN
END


GO


