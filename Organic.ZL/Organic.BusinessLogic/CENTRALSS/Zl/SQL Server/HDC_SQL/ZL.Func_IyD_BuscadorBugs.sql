USE [ZL]
GO

/****** Object:  UserDefinedFunction [ZL].[Func_IyD_BuscadorBugs]    Script Date: 03/14/2013 16:18:58 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[Func_IyD_BuscadorBugs]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [ZL].[Func_IyD_BuscadorBugs]
GO

USE [ZL]
GO

/****** Object:  UserDefinedFunction [ZL].[Func_IyD_BuscadorBugs]    Script Date: 03/14/2013 16:18:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Héctor Daniel Correa
-- Create date: 14/03/2013
-- Description:	Devuelve un string query para ejecutar
-- =============================================
CREATE FUNCTION [ZL].[Func_IyD_BuscadorBugs]
(
  @BUSQUEDA VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @SQLFINAL VARCHAR(MAX)

	SET @SQLFINAL = ' SELECT ''Bug'' AS REGISTRO, CODIN AS CODIGO, TITULO AS NOMBRE, DESBUG AS DESCRIP, MSGSIS AS OBS, KEY_TBL.RANK AS RANKING FROM ZL.REGBUG '
	SET @SQLFINAL = @SQLFINAL + ' INNER JOIN CONTAINSTABLE(ZL.REGBUG, *, ''' + @BUSQUEDA + ''') AS KEY_TBL '
	SET @SQLFINAL = @SQLFINAL + 'ON ZL.REGBUG.CODIN = KEY_TBL.[KEY] '

	RETURN @SQLFINAL

END

GO


