IF EXISTS(SELECT * FROM sys.objects WHERE name = 'sp_CMV_ObtenerComprobantesDeCompra' AND type in (N'P') and SCHEMA_ID('Contabilidad') = schema_id)
	DROP PROCEDURE [Contabilidad].[sp_CMV_ObtenerComprobantesDeCompra];
GO;

CREATE PROCEDURE [Contabilidad].[sp_CMV_ObtenerComprobantesDeCompra]
	( 
	@ParamProducto varchar(25),
	@ParamListaBD varchar(1000),
	@ParamFechaDesde varchar(8),
	@ParamFechaHasta varchar(8),
	@ParamTablaDeRetorno varchar(100)
	)
AS
BEGIN
	/* Aqui ciclo entre las bases de dados de un agrupamiento y voy obteniendo los articulos comprados en cada facturas de compra dentro de un periodo */

	--declare @ParamProducto varchar(25) = 'DRAGONFISH'
	--declare @ParamListaBD varchar(1000) = 'DEMO2,DEMO4'
	--declare @ParamFechaDesde varchar(8) = ''
	--declare @ParamFechaHasta varchar(8) = '20250430'
	--declare @ParamTablaDeRetorno varchar(100) = '##tblTmpCompCompras'

	DECLARE @TablaReturn varchar(100) = ltrim( rtrim( @ParamTablaDeRetorno ) )
	DECLARE @Producto varchar(25) = ltrim( rtrim( @ParamProducto ) )
	DECLARE @FechaDesde varchar(8) = '19000101'
	DECLARE @FechaHasta varchar(8) = CONVERT( VARCHAR(8), GETDATE(), 112 ) 

	SET @FechaDesde = case when @ParamFechaDesde = '' then @FechaDesde else @ParamFechaDesde end
	SET @FechaHasta = case when @ParamFechaHasta = '' then @FechaHasta else @ParamFechaHasta end

	DECLARE @Posicion int = 0;
	DECLARE @ReferenciasDeBD varchar(100) = '';
	DECLARE @BaseDeDatos varchar(8) = '';
	DECLARE @CantidadDeDBS int = 0;
	DECLARE @CantidadDeDBSProcesadas int = 0;
	DECLARE @ListaDeBD TABLE (Referencias varchar(1000), IdRegistro int);

	INSERT INTO @ListaDeBD
	SELECT rtrim(ltrim(Item)), Row_Number() over (order by Item) FROM Funciones.DividirLaCadenaPorElCaracterDelimitador( @ParamListaBD, ',' );
	SET @CantidadDeDBS = @@RowCount;

	/*----------------------------------------------------------------------*/
	--DECLARE	@tblTmpCompAsociados Contabilidad.udt_TableType_CMVTipoCompMovStock
	--SELECT * INTO ##tblTmpCompCompras FROM @tblTmpCompAsociados
	/*----------------------------------------------------------------------*/

	DECLARE @CatalogoSQL varchar(50)
	WHILE @CantidadDeDBSProcesadas < @CantidadDeDBS
	BEGIN
		SELECT @ReferenciasDeBD = Referencias FROM @ListaDeBD WHERE IdRegistro = ( @CantidadDeDBS - @CantidadDeDBSProcesadas )
		SET @Posicion = charindex( ':', @ReferenciasDeBD );
		IF @Posicion > 0
			SET @BaseDeDatos = rtrim( ltrim( left( @ReferenciasDeBD, @Posicion - 1 ) ) );
		ELSE
			SET @BaseDeDatos = rtrim( ltrim( @ReferenciasDeBD ) );

		SET @CatalogoSQL = '[' + @Producto + '_' + ltrim( rtrim( @BaseDeDatos ) ) + ']'
			
		DECLARE @Sql nvarchar(max) = ''
		SET @Sql = @Sql + 'INSERT INTO ' + @TablaReturn + ' '
		SET @Sql = @Sql + 'EXEC [Contabilidad].[sp_CMV_ObtenerArticulosCompradosPorComprobante] ''' + @CatalogoSQL + ''', ''' + @BaseDeDatos + ''', ''' + @FechaDesde + ''', ''' + @FechaHasta + ''' '
		EXEC sp_executesql @Sql

		SET @CantidadDeDBSProcesadas = @CantidadDeDBSProcesadas + 1
	END

	/*-------------------------------------*/
	--SELECT * FROM ##tblTmpCompCompras
	--DROP TABLE ##tblTmpCompCompras
	/*-------------------------------------*/


	--EXEC [Contabilidad].[sp_CMV_ObtenerComprobantesDeCompra] 'DRAGONFISH', 'BASESCMV', '20250401', '20250430', '##NombreTabla'

END 
