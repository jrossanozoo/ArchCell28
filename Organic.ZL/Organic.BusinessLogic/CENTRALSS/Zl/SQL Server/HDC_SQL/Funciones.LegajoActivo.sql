USE [Objetivos]
GO

/****** Object:  UserDefinedFunction [dbo].[LegajoActivo]    Script Date: 04/15/2013 17:28:20 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LegajoActivo]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[LegajoActivo]
GO

USE [Objetivos]
GO

/****** Object:  UserDefinedFunction [dbo].[LegajoActivo]    Script Date: 04/15/2013 17:28:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================================
-- Author:		Héctor Daniel Correa, Gastón Malusardi
-- Create date: 11/04/2013
-- Description:	Obtiene el legajo activo a una fecha determinada
--              retorna además el puesto al que pertenece
-- =============================================================
CREATE FUNCTION [dbo].[LegajoActivo] (@Legajo VARCHAR(25), @Fecha varchar(8))
	RETURNS @LEGAJOS TABLE (
		Legajo VARCHAR(25)
		, Puesto VARCHAR(4)
	)
AS
BEGIN
	IF (@Legajo = '')
		BEGIN
			INSERT INTO @LEGAJOS (Legajo, Puesto)
			SELECT 
				L.CCOD, 
				C.CPUESTO
			FROM ZL.ZL.CARRZL C
				INNER JOIN ZL.ZL.LEGOPS AS L ON L.CLEGAJO = C.CCOD
				INNER JOIN ZL.ZL.LEGAJO J ON J.CCOD = C.CCOD      
			WHERE J.FEGRESO = '19000101'
				AND (( C.FFIN >= CASE @Fecha WHEN '' THEN GETDATE() ELSE CONVERT(DATETIME, @Fecha, 112) END ) OR C.FFIN = '19000101' )
				AND LTRIM(RTRIM(C.CPUESTO)) <> '';
		END
	ELSE
		BEGIN
			INSERT INTO @LEGAJOS (Legajo, Puesto)
			SELECT 
				L.CCOD, 
				C.CPUESTO
			FROM ZL.ZL.CARRZL C
				INNER JOIN ZL.ZL.LEGOPS AS L ON L.CLEGAJO = C.CCOD
				INNER JOIN ZL.ZL.LEGAJO J ON J.CCOD = C.CCOD      
			WHERE J.FEGRESO = '19000101'
				AND (( C.FFIN >= CASE @Fecha WHEN '' THEN GETDATE() ELSE CONVERT(DATETIME, @Fecha, 112) END ) OR C.FFIN = '19000101' )
				AND LTRIM(RTRIM(C.CPUESTO)) <> ''
				AND L.CCOD = @Legajo;
		END
	RETURN	
END


GO


