
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Objetivos].[func_RRHH_EsquemasVigentesxLegajoxFecha]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Objetivos].[func_RRHH_EsquemasVigentesxLegajoxFecha]
GO

CREATE FUNCTION [Objetivos].[func_RRHH_EsquemasVigentesxLegajoxFecha]
(     
      @Legajo VARCHAR(4)
      , @FecIni DATETIME
      , @FecFin DATETIME
)
RETURNS TABLE 
AS
RETURN 
(
    --DECLARE  @Legajo VARCHAR(4)
    --  , @FecIni DATETIME
    --  , @FecFin DATETIME;
    --SET @Legajo = '0043';
    --SET @FecIni = '20130101';
    --SET @FecFin = '20130801';
	WITH CALENDARIO
	AS
	(
		SELECT 
			@FECINI AS FECHA
		UNION ALL
		SELECT 
			DATEADD(DD, 1, FECHA) 
		FROM 
			CALENDARIO 
		WHERE 
			FECHA < @FECFIN
	)
	SELECT 
		C.FECHA
		, ESQUEMA.ESQLAB
	FROM 
		CALENDARIO C 
		CROSS APPLY OBJETIVOS.FUNC_RRHH_ESQUEMAVIGENTEXLEGAJO( @LEGAJO, C.FECHA) AS ESQUEMA
	--OPTION (MAXRECURSION 0) 	
)
GO    

--SELECT * FROM [Objetivos].func_RRHH_EsquemasVigentesxLegajoxFecha('0043', '20130101', '20130801')