USE [ZL]
GO

/****** Object:  UserDefinedFunction [ZL].[Func_IyD_BuscadorReqs]    Script Date: 03/14/2013 16:19:40 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[Func_IyD_BuscadorReqs]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [ZL].[Func_IyD_BuscadorReqs]
GO

USE [ZL]
GO

/****** Object:  UserDefinedFunction [ZL].[Func_IyD_BuscadorReqs]    Script Date: 03/14/2013 16:19:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Héctor Daniel Correa
-- Create date: 15/03/2013
-- Description:	Devuelve un string query para ejecutar
-- =============================================
CREATE FUNCTION [ZL].[Func_IyD_BuscadorReqs]
(
  @BUSQUEDA VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @SQLFINAL VARCHAR(MAX)
	DECLARE @BUSQUEDAOLD VARCHAR(MAX)
	SET @BUSQUEDAOLD = @BUSQUEDA;
	SET @BUSQUEDA = REPLACE(@BUSQUEDA, 'AND', '' )
	SET @BUSQUEDA = REPLACE(@BUSQUEDA, 'OR', '' )
	
    SET @SQLFINAL = 'SELECT 
						''Requerimiento de Cliente'' AS REGISTRO
						, RC.CODIN AS CODIGO
						, RC.ASUNTO AS NOMBRE
						, RC.CMPCONSULT AS DESCRIP
						, '''' AS OBS
						, KEY_TBL.RANK AS RANKING
					 FROM 
						ZL.PNCEREQ AS RC 
						INNER JOIN CONTAINSTABLE(ZL.PNCEREQ, *, ''' + @BUSQUEDAOLD + ''') AS KEY_TBL ON RC.CODIN = KEY_TBL.[KEY] 
					 WHERE 
						(( RC.[CMPFECINI] < ''20111001'' AND RC.CODIN IN (SELECT DISTINCT NUMERO FROM [ZL].[REQCLIDET]))
						OR 
						( RC.[NAPROV] = 0 AND RC.[CMPFECINI] > ''20111001''))
					 UNION ALL
					 SELECT 
						''Requerimiento de I+D'' AS REGISTRO
						, RID.CODIGO AS CODIGO
						, RID.TITULO AS NOMBRE
						, RID.DESCR AS DESCRIP
						, RID.OBS AS OBS
						, KEY_TBL.RANK AS RANKING
					 FROM 
						ZL.REQUER AS RID 
						INNER JOIN CONTAINSTABLE(ZL.REQUER, *, ''' + @BUSQUEDAOLD + ''') AS KEY_TBL ON RID.CODIGO = KEY_TBL.[KEY]
					UNION ALL
					SELECT 
						''Incidente'' AS REGISTRO
						, ZL.INCIDS.CODIN
						, ISNULL(TIPIF.CDESC, '''') + ISNULL(TIPIF2.CDESC, '''') + ISNULL(TAREAS.CTITULO, '''') AS NOMBRE
						, ZL.INCIDS.CMPCONSULT AS DETALLE
						, '''' AS OBS
						, KEY_TBL.RANK AS RANKING
					FROM 
						ZL.INCIDS 
						INNER JOIN CONTAINSTABLE(ZL.INCIDS, *, ''' + @BUSQUEDAOLD + ''' ) AS KEY_TBL ON KEY_TBL.[KEY] = ZL.INCIDS.CODIN
						LEFT  JOIN (SELECT 
										ULTREGPOR.INC
										, ISNULL(ZLTASK.CTITULO, '''') AS CTITULO
									FROM
										ZL.ZLTASK
										LEFT JOIN (SELECT 
												MAX(NUMERO) AS TAREA
												, CODIGO AS INC
											  FROM 
												ZL.DINCIDS
											  GROUP BY CODIGO) AS ULTREGPOR ON ULTREGPOR.TAREA = ZLTASK.NUMERO
									WHERE
										FREETEXT(CTITULO, ''' + @BUSQUEDA + ''' )) AS TAREAS ON TAREAS.INC = ZL.INCIDS.CODIN
						LEFT JOIN (SELECT CCOD, ISNULL(CDESC+''//'', '''') AS CDESC FROM [ZL].[TIPIF] WHERE FREETEXT(CDESC, ''' + @BUSQUEDA + ''')) AS TIPIF ON TIPIF.[CCOD] = [INCIDS].[CMPTIPIF]
						LEFT JOIN (SELECT CCOD, ISNULL(CDESC+''//'', '''') AS CDESC FROM [ZL].[TIPIF2] WHERE FREETEXT(CDESC, ''' + @BUSQUEDA + ''')) AS TIPIF2 ON TIPIF2.[CCOD] = [INCIDS].[CMPSTIP]'

	RETURN @SQLFINAL

END

GO