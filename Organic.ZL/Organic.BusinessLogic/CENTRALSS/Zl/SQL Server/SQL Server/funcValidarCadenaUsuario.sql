USE [ZL]
GO

/****** Object:  UserDefinedFunction [ZL].[funcValidarCadenaUsuario]    Script Date: 12/28/2009 09:52:18 ******/
IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[funcValidarCadenaUsuario]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	BEGIN
	EXECUTE ('CREATE FUNCTION [ZL].[funcValidarCadenaUsuario] ( @CadenaChar varchar(60) ) RETURNS bit AS BEGIN DECLARE @OK_Resultado bit SET @OK_Resultado = 0 RETURN @OK_Resultado END')
	END
GO

USE [ZL]
GO

/****** Object:  UserDefinedFunction [ZL].[funcValidarCadenaUsuario]    Script Date: 12/28/2009 09:52:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		MatiasB
-- Create date: 24/11/2009
-- Description:	Valida que la cadena de texto pasada esté compuesta sólo por números y letras (ASCII)
-- Ejemplo:		select ZL.funcValidarCadenaUsuario('FGHFG9541%')
-- =============================================
ALTER FUNCTION [ZL].[funcValidarCadenaUsuario]
(
	-- Add the parameters for the function here
	@CadenaChar varchar(60)
)
RETURNS bit
AS
BEGIN
	-- Declare the return variable here
	DECLARE @OK_Resultado bit
	
	
	-- Add the T-SQL statements to compute the return value here
	SET @CadenaChar = LTRIM(RTRIM(@CadenaChar))
	IF @CadenaChar = '' SET @OK_Resultado = 1 
		else BEGIN
	
	DECLARE @I INT
	SET @I = 1
	
		WHILE @I <= LEN(@CadenaChar)
		BEGIN
			IF (ASCII(SUBSTRING(@CadenaChar,@I,1)) BETWEEN 48 AND 57 OR 
				ASCII(SUBSTRING(@CadenaChar,@I,1)) BETWEEN 65 AND 90 OR 
					ASCII(SUBSTRING(@CadenaChar,@I,1)) BETWEEN 97 AND 122 )
					
					BEGIN
					SET @OK_Resultado = 1
					SET @I  = @I + 1
					END
					
					ELSE BEGIN
							SET @OK_Resultado = 0
							BREAK 					
						END	
		END
	
	
			END
	-- Return the result of the function
	RETURN @OK_Resultado 

END

GO


