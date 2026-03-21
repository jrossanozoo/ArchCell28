IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[sp_ObtenerBasesAgrupamiento]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT', N'P'))
DROP PROCEDURE [Funciones].[sp_ObtenerBasesAgrupamiento];
GO;

CREATE PROCEDURE [Funciones].[sp_ObtenerBasesAgrupamiento] ( @Grupo char(21) )
AS
BEGIN
	   IF EXISTS (SELECT 1 FROM [PUESTO].[AGRUPAMIENTO] WHERE CODIGO = @Grupo ) 
	   begin
  
		   DECLARE @Grupos TABLE (Grupo char(21))

		   ;WITH GruposCte (Grupo)
		   AS (
				 SELECT CAST( AGRUP AS CHAR(21)) Grupo
				 FROM [PUESTO].[AGRUPAG] WHERE CODIGO = @Grupo and Incluye = 1
				 UNION ALL
				 SELECT CAST( AGRUP as char(21)) Grupo
				 FROM [PUESTO].[AGRUPAG] a
				 INNER JOIN GruposCte cte ON cte.Grupo = a.codigo and a.Incluye = 1
		   )

		   INSERT INTO @Grupos SELECT Grupo FROM GruposCte
		   INSERT INTO @Grupos VALUES (@Grupo)

		   SELECT DISTINCT RTRIM(BASEDEDATO) Base FROM [PUESTO].[AGRUPBD]
		   WHERE Codigo IN (SELECT Grupo FROM @Grupos) and Incluye = 1
		end
		else
			SELECT @Grupo Bases --Se copia logica de FOX, si el grupo no existe se retorno el mismo nombre de grupo 
END