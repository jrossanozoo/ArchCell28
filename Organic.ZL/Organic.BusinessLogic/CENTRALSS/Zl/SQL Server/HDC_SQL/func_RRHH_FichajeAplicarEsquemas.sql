

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Objetivos].[func_RRHH_FichajeAplicarEsquemas]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Objetivos].[func_RRHH_FichajeAplicarEsquemas]
GO



CREATE FUNCTION [Objetivos].[func_RRHH_FichajeAplicarEsquemas]
(
      @FecIni Varchar(8)
      , @FecFin Varchar(8)
)

RETURNS TABLE 
AS
RETURN 
(
	SELECT
		COD
		, [CAPENOM]
		, [FCHREG]
		, [LEGAJO] --ESTE CAMPO ES VARCHAR(4)
		-- , [OBS]
		, [HORAREG]
		, (SELECT CODPUESTO FROM [Objetivos].[func_RRHH_UpdateFichaje]( LEGAJO, FCHREG)) as CODPUESTO
		, (SELECT FUNCION.AREA FROM [Objetivos].[func_RRHH_UpdateFichaje](LEGAJO, FCHREG) AS FUNCION) as AREA 
		, (SELECT FUNCION.SECTOR FROM [Objetivos].[func_RRHH_UpdateFichaje](LEGAJO, FCHREG) AS FUNCION) as SECTOR 
		, (SELECT FUNCION.ESQUEMA FROM [Objetivos].[func_RRHH_UpdateFichaje](LEGAJO, FCHREG) AS FUNCION) as  ESQUEMA
		, (SELECT FUNCION.ASIGESQ FROM [Objetivos].[func_RRHH_UpdateFichaje](LEGAJO, FCHREG) AS FUNCION) as ASIGESQ
		, (SELECT FUNCION.INGRESOESQUEMA FROM [Objetivos].[func_RRHH_UpdateFichaje](LEGAJO, FCHREG) AS FUNCION) as INGRESOESQUEMA
		, (SELECT FUNCION.EGRESOESQUEMA FROM [Objetivos].[func_RRHH_UpdateFichaje](LEGAJO, FCHREG) AS FUNCION) as EGRESOESQUEMA
		, (SELECT FUNCION.TOLERANCIA FROM [Objetivos].[func_RRHH_UpdateFichaje](LEGAJO, FCHREG) AS FUNCION) as TOLERANCIA
		, (SELECT FUNCION.MINUTOS FROM [Objetivos].[func_RRHH_UpdateFichaje](LEGAJO, FCHREG) AS FUNCION) as MINUTOS
		, CONVERT(DATETIME, CONVERT(VARCHAR(10), FCHREG, 120), 102) as FECHA
		, YEAR(FCHREG) as ANIO
		, MONTH(FCHREG) as MES
		, DAY(FCHREG)  as DIA
	FROM 
		ZL.ZNFICHAJE 
	WHERE 
		CONVERT( VARCHAR(8), FCHREG, 112 ) >= @FECINI
		AND CONVERT( VARCHAR(8), FCHREG, 112 ) <= @FECFIN
                                                                      
)

GO




 

