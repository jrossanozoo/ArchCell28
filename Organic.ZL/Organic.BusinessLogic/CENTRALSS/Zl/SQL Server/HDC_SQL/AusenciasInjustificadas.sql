USE [ZL]
GO

/****** Object:  UserDefinedFunction [Objetivos].[AusenciasInjustificadas]    Script Date: 07/05/2013 17:13:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =====================================================
-- Author:		Daniel Correa
-- Create date: 05/07/2013
-- Description:	Devuelve la Ausencias Injustificadas
-- =====================================================
ALTER FUNCTION [Objetivos].[AusenciasInjustificadas]
(	
	@Legajo VARCHAR(4),
	@FechaInicio DATETIME,
	@FechaFin DATETIME
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT     
		SUM(DATEDIFF(D, ZL.AUSENC.FECHAI, ZL.AUSENC.FECHAF)) AS VALOR
	FROM
		ZL.AUSENC 
		LEFT OUTER JOIN ZL.MOTAUS ON ZL.AUSENC.MOTIV = ZL.MOTAUS.CCOD 
		LEFT OUTER JOIN ZL.LEGAJO ON ZL.AUSENC.LEG = ZL.LEGAJO.CCOD
		LEFT OUTER JOIN ZL.LEGOPS ON ZL.AUSENC.LEG = ZL.LEGOPS.CLEGAJO
	WHERE 
		ZL.AUSENC.JUST <> 1 
		AND ZL.AUSENC.FECHAI BETWEEN @FechaInicio AND @FechaFin
		AND ZL.AUSENC.FECHAF BETWEEN @FechaInicio AND @FechaFin
		AND ZL.LEGOPS.CLEGAJO = @Legajo
	GROUP BY     
		ZL.LEGOPS.CCOD
)

GO


