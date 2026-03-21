IF EXISTS(SELECT * FROM sys.objects WHERE name = 'sp_ObtenerEjercicioSegunRangoDeFechas' AND type in (N'P') and SCHEMA_ID('Contabilidad') = schema_id)
	DROP PROCEDURE [Contabilidad].[sp_ObtenerEjercicioSegunRangoDeFechas];
GO;

CREATE PROCEDURE [Contabilidad].[sp_ObtenerEjercicioSegunRangoDeFechas] 
(
	@CatalogoSQL varchar(50),
	@FechaDesde varchar(8),
	@FechaHasta varchar(8)
)
AS
BEGIN
	/* Obtiene el numero de ejercicio correspondiente a las fechas ingresados  */
	/* Devuelve -1 si no hay ejercicios dados de alta                          */
	/* Devuelve 0 si las fechas no corresponden con un ejercicio en particular */

	--declare @CatalogoSQL varchar(50) = 'DRAGONFISH_DEMO2'
	--declare @FechaDesde varchar(8) = '20250401'
	--declare @FechaHasta varchar(8) = '20250530'

	DECLARE @Sql nvarchar(max) = ''

	SET @Sql = @Sql + 'DECLARE @Respuesta numeric(8,0) '

	SET @Sql = @Sql + 'SET @Respuesta = -1 '
	SET @Sql = @Sql + 'SELECT TOP 1 @Respuesta = NUMERO '
	SET @Sql = @Sql + 'FROM ' + ltrim( rtrim( @CatalogoSQL ) ) + '.[Zoologic].[EJERCICIO] '
	SET @Sql = @Sql + 'IF @Respuesta >= 0 '
	SET @Sql = @Sql + 'BEGIN '
	SET @Sql = @Sql + '	SET @Respuesta = 0 '
	SET @Sql = @Sql + '	SELECT @Respuesta = NUMERO '
	SET @Sql = @Sql + '	FROM ' + ltrim( rtrim( @CatalogoSQL ) ) + '.[Zoologic].[EJERCICIO] '
	SET @Sql = @Sql + '	WHERE ''' + @FechaDesde + ''' >= FECHADES and ''' + @FechaHasta + ''' <= FECHAHAS '
	SET @Sql = @Sql + 'END '
	SET @Sql = @Sql + 'SELECT @Respuesta'

	EXEC sp_executesql @Sql

	--EXEC [Contabilidad].[sp_ObtenerEjercicioSegunRangoDeFechas]  'DRAGONFISH_DEMO2', '20250401', '20250430'

END