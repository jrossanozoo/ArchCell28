USE [ZL]
GO

/****** Object:  UserDefinedFunction [ZL].[func_ZL_DiaSemana]    Script Date: 07/23/2013 14:05:12 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[func_ZL_DiaSemana]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [ZL].[func_ZL_DiaSemana]
GO

USE [ZL]
GO

/****** Object:  UserDefinedFunction [ZL].[func_ZL_DiaSemana]    Script Date: 07/23/2013 14:05:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ============================================================
-- Author:		Daniel Correa
-- Create date: 23/07/2013
-- Description:	Devuelve el numero de dia de la semana segun ZL
-- ============================================================
CREATE FUNCTION [ZL].[func_ZL_DiaSemana]
(
	@FECHA DATETIME
)
RETURNS INT
AS
BEGIN
	
	DECLARE @DIA int;

	-- Add the T-SQL statements to compute the return value here
	IF DATEPART(WEEKDAY, @FECHA) = 1
	BEGIN
		SET @DIA = 7;
	END
	ELSE
	BEGIN
		SELECT @DIA = DATEPART(WEEKDAY, @FECHA) - 1;
	END
	
	-- Return the result of the function
	RETURN @DIA;

END

GO


