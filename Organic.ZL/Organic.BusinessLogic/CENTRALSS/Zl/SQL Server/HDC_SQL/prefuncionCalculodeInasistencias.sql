DECLARE @FechaInicio DATETIME, @FechaFin DATETIME;
DECLARE @Legajo varchar(25);
set @FechaInicio = '20110401';
set @FechaFin = getdate();
set @Legajo = '0091';

SELECT     
	SUM(DATEDIFF(DD,ZL.AUSENC.FECHAI,ZL.AUSENC.FECHAF)) AS DIAS
FROM
	ZL.AUSENC 
WHERE 
	ZL.AUSENC.FECHAI >= @FechaInicio
	AND ZL.AUSENC.FECHAF <= @FechaFin
	AND ZL.AUSENC.LEG = @Legajo
