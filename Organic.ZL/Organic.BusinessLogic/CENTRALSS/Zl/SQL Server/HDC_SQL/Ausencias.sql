DECLARE @FechaInicio DATETIME, @FechaFin DATETIME, @Legajo VARCHAR(4);
SET @FechaInicio = CONVERT(DATETIME, '20120320', 112)
SET @FechaFin    = GETDATE();
SET @Legajo      = '0091';

/******************************************************************************************
*                                   INJUSTIFICADAS                                        *
******************************************************************************************/
SELECT * FROM [Objetivos].AusenciasInjustificadas(@Legajo, @FechaInicio, @FechaFin)

/******************************************************************************************
*                                    JUSTIFICADAS                                         *
******************************************************************************************/
SELECT * FROM [Objetivos].AusenciasJustificadas(@Legajo, @FechaInicio, @FechaFin)
