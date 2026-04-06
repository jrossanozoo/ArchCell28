USE [ZL]
GO

/****** Object:  UserDefinedFunction [ZL].[Func_IyD_BuscadorFunc]    Script Date: 03/14/2013 16:19:40 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[Func_IyD_BuscadorFunc]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [ZL].[Func_IyD_BuscadorFunc]
GO

USE [ZL]
GO

/****** Object:  UserDefinedFunction [ZL].[Func_IyD_BuscadorFunc]    Script Date: 03/14/2013 16:19:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Héctor Daniel Correa
-- Create date: 14/03/2013
-- Description:	Devuelve un string query para ejecutar
-- =============================================
CREATE FUNCTION [ZL].[Func_IyD_BuscadorFunc]
(
  @BUSQUEDA VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @SQLFINAL VARCHAR(MAX)

    SET @SQLFINAL = 'SELECT ''Funcionalidad'' AS REGISTRO, F.CODIGO AS CODIGO, F.NOMBRE AS NOMBRE, F.DESCRIP AS DESCRIP'
    SET @SQLFINAL = @SQLFINAL + ', F.OBS AS OBS, KEY_TBL.RANK AS RANKING FROM ZL.FCOMER AS F '
    SET @SQLFINAL = @SQLFINAL + 'INNER JOIN CONTAINSTABLE(ZL.FCOMER, *, ''' + @BUSQUEDA + ''') AS KEY_TBL '
    SET @SQLFINAL = @SQLFINAL + 'ON F.CODIGO = KEY_TBL.[KEY] '

	RETURN @SQLFINAL

END

GO


