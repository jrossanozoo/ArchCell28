USE [ZL]
GO

/****** Object:  UserDefinedFunction [ZL].[HtoDec]    Script Date: 07/17/2013 11:46:19 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[HtoDec]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [ZL].[HtoDec]
GO

USE [ZL]
GO

/****** Object:  UserDefinedFunction [ZL].[HtoDec]    Script Date: 07/17/2013 11:46:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- ==================================================
-- Author:		Daniel Correa
-- Create date: 16/07/2013
-- FUNCION QUE TRANSFORMA UNA CANTIDAD DE HORAS 
-- EN SU EQUIVALENTE DECIMAL PARA PODER HACER CUENTAS
-- ==================================================
CREATE FUNCTION [ZL].[HtoDec]
(
	@Hora VARCHAR(MAX) --FORMATO HH:MM
)
RETURNS NUMERIC(4,2)
AS
BEGIN
	IF @HORA <> ''
		BEGIN
			RETURN (CONVERT(NUMERIC(4,2), LEFT(@HORA, CHARINDEX(':', @HORA)-1))) + (CONVERT(NUMERIC(4,2), RIGHT(@HORA, CHARINDEX(':', @HORA)-1)) / 60);
		END
	RETURN 0.00;
END
GO


