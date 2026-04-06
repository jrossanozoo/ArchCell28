USE [ZL]
GO

/****** Object:  UserDefinedFunction [Objetivos].[LlegadasTarde]    Script Date: 07/05/2013 17:28:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Daniel Correa
-- Create date: 05/07/2013
-- Description:	Devuelve las llegadas tardes
-- =============================================
ALTER FUNCTION [Objetivos].[LlegadasTarde]
(	
	@Legajo VARCHAR(4)
	, @FechaInicio DATETIME
	, @FechaFin DATETIME
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT 
		COUNT(ZL.SALEXCJOR.CODIN) AS VALOR
	FROM 
		ZL.SALEXCJOR
	WHERE 
		LTRIM(RTRIM(SUBSTRING(ZL.SALEXCJOR.OBS,CHARINDEX('**', ZL.SALEXCJOR.OBS)+2,5))) = 'TARDE'
		AND ZL.SALEXCJOR.FECDESDE BETWEEN @FechaInicio AND @FechaFin
		AND ZL.SALEXCJOR.LEG = @Legajo
	GROUP BY
		ZL.SALEXCJOR.USU
)

GO


