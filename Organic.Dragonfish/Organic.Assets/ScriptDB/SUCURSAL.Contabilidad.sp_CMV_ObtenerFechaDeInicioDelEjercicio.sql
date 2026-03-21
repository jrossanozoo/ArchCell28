IF EXISTS(SELECT * FROM sys.objects WHERE name = 'sp_CMV_ObtenerFechaDeInicioDelEjercicio' AND type in (N'P') and SCHEMA_ID('Contabilidad') = schema_id)
	DROP PROCEDURE [Contabilidad].[sp_CMV_ObtenerFechaDeInicioDelEjercicio];
GO;

CREATE procedure [Contabilidad].[sp_CMV_ObtenerFechaDeInicioDelEjercicio]
(
	@CatalogoSQL varchar(50),
	@NumeroEj numeric(8,0) 
)
AS
BEGIN
	
	--declare @CatalogoSQL varchar(50) = 'DRAGONFISH_DEMO2'
	--declare @NumeroEj numeric(8,0) = 1

	DECLARE @Sql nvarchar(max) = ''
	SET @Sql = @Sql + 'DECLARE @Retorno datetime '
	SET @Sql = @Sql + 'DECLARE @FechaVacia datetime = CONVERT( DATETIME, ''' + '1900-01-01 00:00:00.000' + ''' ) '
	SET @Sql = @Sql + 'SELECT @Retorno = FECHADES FROM ' + ltrim( rtrim( @CatalogoSQL ) ) + '.ZooLogic.EJERCICIO WHERE NUMERO = ' + CONVERT( VARCHAR(8), @NumeroEj ) + ' '
	SET @Sql = @Sql + 'SELECT coalesce( @Retorno, @FechaVacia )' 
	
	EXEC sp_executesql @Sql

	--EXEC [Contabilidad].[sp_CMV_ObtenerFechaDeInicioDelEjercicio] 'DRAGONFISH_DEMO2', 1

END