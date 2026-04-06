--=Avg(Fields!Cantidad.Value, "NServicio")/10000
DECLARE @FechaInicio datetime, @FechaFin datetime, @Legajo varchar(25);
SET @FechaInicio = '20110401';
SET @FechaFin = GETDATE();

SELECT
	ROUND((CONVERT(NUMERIC(10,2), SUM([LLAMADAS ATENDIDAS EN 60]))/(SUM([LLAMADAS ATENDIDAS])+SUM([LLAMADAS PERDIDAS]))), 4) [VALOR]
FROM 
	[TECNOVOZ].[DBO].[VISTAACD]
WHERE 
	[LLAMADAS EXTERNAS] = 1 
	AND [AÑO] BETWEEN YEAR(@FechaInicio) AND YEAR(@FechaFin) 
	AND [MES] BETWEEN MONTH (@FechaInicio) AND MONTH (@FechaFin)