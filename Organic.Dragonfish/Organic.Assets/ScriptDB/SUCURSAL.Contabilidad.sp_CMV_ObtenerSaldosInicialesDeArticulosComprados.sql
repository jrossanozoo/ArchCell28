IF EXISTS(SELECT * FROM sys.objects WHERE name = 'sp_CMV_ObtenerSaldosInicialesDeArticulosComprados' AND type in (N'P') and SCHEMA_ID('Contabilidad') = schema_id)
	DROP PROCEDURE [Contabilidad].[sp_CMV_ObtenerSaldosInicialesDeArticulosComprados];
GO;

CREATE PROCEDURE [Contabilidad].[sp_CMV_ObtenerSaldosInicialesDeArticulosComprados]
(
	@ParamProducto varchar(25),
	@ParamListaBD varchar(1000),
	@ParamFechaDesde varchar(8), 
	@ParamFechaHasta varchar(8), 
	@ParamTablaDeRetorno varchar(100)
)
AS
BEGIN
	/* Obtiene los datos iniciales de stock y precio desde FACCOMPRA para armar los saldos iniciales */
	/* Este stored procedure se utiliza cuando no hay un ejercicio contable dado de alta (solo listado) */
	
	--declare @ParamProducto varchar(25) = 'DRAGONFISH'
	--declare @ParamListaBD varchar(1000) = 'DEMO2,DEMO4'
	--declare @ParamFechaDesde varchar(8) = '20250301'
	--declare @ParamFechaHasta varchar(8) = '20250331'
	--declare @ParamTablaDeRetorno varchar(100) = '##tblTmpSaldosIniciales'

	DECLARE @TablaReturn varchar(100) = ltrim( rtrim( @ParamTablaDeRetorno ) )
	DECLARE @Producto varchar(25) = ltrim( rtrim( @ParamProducto ) )
	DECLARE @FechaDesde varchar(8) = '19000101'
	DECLARE @FechaHasta varchar(8) = '19000101'

	SET @FechaDesde = case when @ParamFechaDesde = '' then @FechaDesde else @ParamFechaDesde end
	SET @FechaHasta = case when @ParamFechaHasta = '' then @FechaHasta else @ParamFechaHasta end
	
	DECLARE @Sql nvarchar(max) = ''
	SET @Sql = 'DECLARE @tblFactComprasProcesados Contabilidad.udt_TableType_CMVTipoCompMovStock '

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
	--DECLARE @tblTmpSaldosIniciales Contabilidad.udt_TableType_CMVTipoCompMovStock
	--SELECT * INTO ##tblTmpSaldosIniciales FROM @tblTmpSaldosIniciales
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
				
		SET @Sql = @Sql + 'INSERT INTO @tblFactComprasProcesados '
		SET @Sql = @Sql + '	EXEC [Contabilidad].[sp_CMV_ObtenerCostoYUltimaFacturaDeCompraPorArticulo] ' + @CatalogoSQL + ', ''' + @FechaDesde + ''', ''' + @FechaHasta + ''' '
				
		SET @CantidadDeDBSProcesadas = @CantidadDeDBSProcesadas + 1
	END
	
	SET @Sql = @Sql + 'INSERT INTO ' + @TablaReturn + ' '
	SET @Sql = @Sql + 'SELECT ( ROW_NUMBER() OVER (ORDER BY ARTICULO, COLOR, TALLE, FECHA, TIMESTAMP) ) AS Id, '
	SET @Sql = @Sql + ' ( Select Funciones.ObtenerIdGlobal() ) AS GlobalId, '
	SET @Sql = @Sql + ' Codigo, FactTipo, Articulo, Color, Talle, Fecha, Letra, PtoVenExt, NumComp, PtoVen, NumInt, Cantidad, Precio, Timestamp, Descrip, Base '
	SET @Sql = @Sql + 'FROM ( '
	SET @Sql = @Sql + '  select Codigo, FactTipo, Articulo, Color, Talle, Fecha, Letra, PtoVenExt, '
	SET @Sql = @Sql + '  NumComp, PtoVen, NumInt, Cantidad, Precio, Timestamp, Descrip, Base, '
	SET @Sql = @Sql + '  row_number() over ( partition by Articulo, Color, Talle order by Fecha desc, Timestamp desc ) as Prioridad '
	SET @Sql = @Sql + '  from @tblFactComprasProcesados '
	SET @Sql = @Sql + ') facturas '
	SET @Sql = @Sql + 'WHERE Prioridad = 1 '

	EXEC sp_executesql @Sql

	/*-------------------------------------*/
	--SELECT * FROM ##tblTmpSaldosIniciales
	--DROP TABLE ##tblTmpSaldosIniciales
	/*-------------------------------------*/

	
	--EXEC [Contabilidad].[sp_CMV_ObtenerSaldosInicialesDeArticulosComprados] 'DRAGONFISH', 'DEMO2', 'DEMO2,DEMO4', '20250301', '20250331', '##NombreTabla' 

END