USE [ZL]
GO

/****** Object:  UserDefinedFunction [Objetivos].[EvalCoordinacion]    Script Date: 07/05/2013 16:10:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ====================================================
-- Author:		Daniel Correa
-- Create date: 05/07/2013
-- Description:	Devuelve la Evaluación de Coordinación
-- ====================================================
ALTER FUNCTION [Objetivos].[EvalCoordinacion]
(	
	@Legajo VARCHAR(4)
)
RETURNS TABLE 
	
AS
RETURN 
(
	SELECT
		NOTA_PONDERADA AS VALOR
	FROM        
		[TECNOVOZ].[DBO].[EVALUACIONCOORDINACION]
		INNER JOIN ZL.ZL.LEGOPS AS LEGZL ON LEGZL.CCOD = [TECNOVOZ].[DBO].[EVALUACIONCOORDINACION].OPERADOR
			AND LEGZL.CLEGAJO = @Legajo
)

GO


