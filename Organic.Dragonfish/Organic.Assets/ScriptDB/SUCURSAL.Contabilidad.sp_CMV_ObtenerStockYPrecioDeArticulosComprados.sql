IF EXISTS(SELECT * FROM sys.objects WHERE name = 'sp_CMV_ObtenerStockYPrecioDeArticulosComprados' AND type in (N'P') and SCHEMA_ID('Contabilidad') = schema_id)
	DROP PROCEDURE Contabilidad.sp_CMV_ObtenerStockYPrecioDeArticulosComprados;
GO;

CREATE PROCEDURE [Contabilidad].[sp_CMV_ObtenerStockYPrecioDeArticulosComprados]
(
	@ParamVersion varchar(13),
	@ParamUsuario varchar(100),
	@ParamNroSerie varchar(6),
	@ParamProducto varchar(25),
	@ParamSucursalActiva varchar(8),
	@ParamListaBD varchar(1000),
	@ParamEjercicio numeric(8,0),
	@ParamFechaDesde varchar(8), 
	@ParamFechaHasta varchar(8)
)
AS
BEGIN
	/* Aqui ciclo entre las bases de dados de un agrupamiento y voy obteniendo las facturas de compra para armar los saldos iniciales para el CMV */
	
	--declare @ParamNroSerie varchar(6) = '100456'
	--declare @ParamUsuario varchar(100) = 'ADMIN'
	--declare @ParamVersion varchar(13) = '01.0001.00000'
	--declare @ParamProducto varchar(25) = 'DRAGONFISH'
	--declare @ParamSucursalActiva varchar(8) = 'DEMO2'
	--declare @ParamListaBD varchar(1000) = 'DEMO2,DEMO4'
	--declare @ParamEjercicio numeric(8,0) = 1
	--declare @ParamFechaDesde varchar(8) = '20250301'
	--declare @ParamFechaHasta varchar(8) = '20250331'

	DECLARE @NroSerie varchar(6) = ltrim( rtrim( @ParamNroSerie ) )
	DECLARE @Usuario varchar(100) = ltrim( rtrim( @ParamUsuario ) )
	DECLARE @Version varchar(13) = ltrim( rtrim( @ParamVersion ) )
	DECLARE @SucursalActiva varchar(8) = ltrim( rtrim( @ParamSucursalActiva ) )

	DECLARE @Producto varchar(25) = ltrim( rtrim( @ParamProducto ) )

	DECLARE @FechaDesde varchar(8) = '19000101'
	DECLARE @FechaHasta varchar(8) = CONVERT( VARCHAR(8), GETDATE(), 112 ) 

	SET @FechaDesde = case when @ParamFechaDesde = '' then @FechaDesde else @ParamFechaDesde end
	SET @FechaHasta = case when @ParamFechaHasta = '' then @FechaHasta else @ParamFechaHasta end
	
	DECLARE	@tblFactComprasProcesados Contabilidad.udt_TableType_CMVTipoCompMovStock

	DECLARE @Posicion int = 0;
	DECLARE @ReferenciasDeBD varchar(100) = '';
	DECLARE @BaseDeDatos varchar(8) = '';
	DECLARE @CantidadDeDBS int = 0;
	DECLARE @CantidadDeDBSProcesadas int = 0;
	DECLARE @ListaDeBD TABLE (Referencias varchar(1000), IdRegistro int);

	INSERT INTO @ListaDeBD
	SELECT rtrim(ltrim(Item)), Row_Number() over (order by Item) FROM Funciones.DividirLaCadenaPorElCaracterDelimitador( @ParamListaBD, ',' );
	SET @CantidadDeDBS = @@RowCount;

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
				
		INSERT INTO @tblFactComprasProcesados
			EXEC [Contabilidad].[sp_CMV_ObtenerCostoYUltimaFacturaDeCompraPorArticulo] @CatalogoSQL, @FechaDesde, @FechaHasta
				
		SET @CantidadDeDBSProcesadas = @CantidadDeDBSProcesadas + 1
	END
	
	DECLARE	@tblStockYPrecio Contabilidad.udt_TableType_CMVTipoCompMovStock
	
	INSERT INTO @tblStockYPrecio
		SELECT 0 as Id, ( Select Funciones.ObtenerIdGlobal() ) AS GlobalId, 
			 Codigo, FactTipo, Articulo, Color, Talle, Fecha, Letra, PtoVenExt, NumComp, PtoVen, NumInt, Stock, Costo, Timestamp, Descrip, Base 
		FROM (
			select Codigo, FactTipo, Articulo, Color, Talle, Fecha as FECHA, Letra, PtoVenExt, 
				 NumComp, PtoVen, NumInt, Cantidad as Stock, Precio as Costo, Timestamp, Descrip, Base, 
				 row_number() over ( partition by Articulo, Color, Talle order by Fecha desc, Timestamp desc ) as Prioridad
			from @tblFactComprasProcesados
				) facturas
		WHERE Prioridad = 1

	EXEC [Contabilidad].[sp_CMV_ImportarSaldosIniciales] @NroSerie, @Usuario, @Version, @SucursalActiva, @ParamEjercicio, @tblStockYPrecio 
	
	
	--EXEC [Contabilidad].[sp_CMV_ObtenerStockYPrecioDeArticulosComprados] '100456', 'ADMIN', '01.0001.00000', 'DRAGONFISH', 'DEMO2', 'BASESCMV', 1, '20250301', '20250331'

END