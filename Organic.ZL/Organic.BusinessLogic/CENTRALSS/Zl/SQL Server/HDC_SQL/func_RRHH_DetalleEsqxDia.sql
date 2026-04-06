USE [ZL]
GO

/****** Object:  UserDefinedFunction [Objetivos].[func_RRHH_DetalleEsqxDia]    Script Date: 07/31/2013 10:52:24 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Objetivos].[func_RRHH_DetalleEsqxDia]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Objetivos].[func_RRHH_DetalleEsqxDia]
GO

USE [ZL]
GO

/****** Object:  UserDefinedFunction [Objetivos].[func_RRHH_DetalleEsqxDia]    Script Date: 07/31/2013 10:52:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Daniel Correa
-- Create date: 16/07/2013
-- Description:	FUNCION QUE DEVUELVE DETALLES DE
-- UN ESQUEMA DE JORNADA LABORAL DADO POR SU
-- NUMERO PARA UN DIA DE LA SEMANA (1 A 7)
-- =============================================

CREATE FUNCTION [Objetivos].[func_RRHH_DetalleEsqxDia]
(
	@Esquema INT
	, @Dia INT
)
RETURNS 
	@TABLA TABLE 
	(
	DIA INT
	, HORAING VARCHAR(5)
	, HORAEGR VARCHAR(5)
	, RANGOHS INT
	, FERIADOS INT
	, HORLAB VARCHAR(5)
	, ALMUERZO VARCHAR(5)
	, ALMUERZODEC NUMERIC(4,2)
	, HORLABDEC NUMERIC(4,2)
	)
AS
BEGIN
	INSERT INTO @TABLA
	SELECT
		DIA
		, HORAING
		, HORAEGR
		, RANGOHS --!? NO SABEMOS PARA QUE SE USA
		, FERIADOS
		, HORLAB
		, ALMUERZO
		, ZL.HTODEC(ALMUERZO)
		, DATEDIFF(hour, CONVERT(DATETIME, HORAING), CONVERT(DATETIME, HORAEGR)) - ZL.HTODEC(ALMUERZO)
	FROM
		ZL.DTSALRGDH
	WHERE
		ZL.DTSALRGDH.CODINT = @ESQUEMA
		AND DIA = @DIA;
	RETURN 
END


GO


