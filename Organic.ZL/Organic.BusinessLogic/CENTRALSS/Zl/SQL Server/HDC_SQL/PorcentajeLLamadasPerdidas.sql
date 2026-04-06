USE [ZL]
GO

/****** Object:  UserDefinedFunction [Objetivos].[PorcentajeLLamadasPerdidas]    Script Date: 05/02/2013 11:57:58 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Objetivos].[PorcentajeLLamadasPerdidas]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Objetivos].[PorcentajeLLamadasPerdidas]
GO

USE [ZL]
GO

/****** Object:  UserDefinedFunction [Objetivos].[PorcentajeLLamadasPerdidas]    Script Date: 05/02/2013 11:57:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [Objetivos].[PorcentajeLLamadasPerdidas] 
(	@FechaInicio as datetime,
	@FechaFin as datetime )
  
  RETURNS @LlamadasPerdidas TABLE (
		Valor Numeric(10,4)
	)
AS
BEGIN
	insert into @LlamadasPerdidas	
	SELECT 
		 convert(numeric(10,2), Sum([Llamadas Perdidas]))/ convert( numeric(10,2), Sum([Llamadas Atendidas])) AS PERDIDAS
	FROM
		[TECNOVOZ].DBO.VistaACD
	where 
		[Llamadas Externas] = 1 
		and [Año] BETWEEN Year(@FechaInicio) and Year(@FechaFin) 
		AND [Mes] BETWEEN Month (@FechaInicio) and Month (@FechaFin) 
return

END


GO


