IF EXISTS(SELECT * FROM sys.objects WHERE name = 'sp_CMV_ObtenerSaldosStockAlCerrarEjercicio' AND type in (N'P') and SCHEMA_ID('Contabilidad') = schema_id)
	DROP PROCEDURE Contabilidad.sp_CMV_ObtenerSaldosStockAlCerrarEjercicio;
GO;

CREATE PROCEDURE [Contabilidad].[sp_CMV_ObtenerSaldosStockAlCerrarEjercicio]
(
	@Version varchar(13),
	@Usuario varchar(100),
	@NroSerie varchar(6),
	@Producto varchar(25),
	@BaseDeDatos varchar(8),
	@ListaBaseDeDatos varchar(1000),
	@NroEjercicio numeric(8,0),
	@MetodoDeCosteo varchar(4),
	@TipoDeSalida char(1)
)
AS
BEGIN
	/* Obtener los saldos de stock de la tabla CMVFACCOMPRA al realizar el cierre de ejercicio para saber cuanto quedo de cada combinacion */

	--declare @Version varchar(13) = '01.0001.00000'
	--declare @Usuario varchar(100) = 'ADMIN'
	--declare @NroSerie varchar(6) = '100847'
	--declare @Producto varchar(25) = 'DRAGONFISH'
	--declare @BaseDeDatos varchar(8) = 'DEMO2'
	--declare @ListaBaseDeDatos varchar(1000) = 'DEMO2,DEMO4'
	--declare @NroEjercicio numeric(8,0) = 1
	--declare @MetodoDeCosteo varchar(4) = 'PEPS'
	--declare @TipoDeSalida char(1) = 'S'

	DECLARE @HoraActual varchar(8) = CONVERT ( VARCHAR(8), CONVERT( TIME, GETDATE() ) ) 
	DECLARE @FechaVacia datetime = CONVERT( DATETIME, '1900-01-01 00:00:00.000' )
	DECLARE @FechaActual datetime = CONVERT( DATETIME, CONVERT( DATE, GETDATE() ) )

	DECLARE @FechaIniEjercicio varchar(8)
	DECLARE @FechaFinEjercicio varchar(8)

	SELECT @FechaIniEjercicio = CONVERT( VARCHAR(8), FECHADES, 112 ), @FechaFinEjercicio = CONVERT( VARCHAR(8), FECHAHAS, 112 )  
			FROM [ZooLogic].[EJERCICIO] WHERE NUMERO = @NroEjercicio


	DECLARE	@tblSaldosInialesCmv Contabilidad.udt_TableType_CMVTipoCompMovStock
	DECLARE @tblMovimientosProcesados Contabilidad.udt_TableType_CMVTipoCompMovStock
	DECLARE @tblCompAsocPorBaseDeDatos Contabilidad.udt_TableType_CMVCompAsociados
	DECLARE @tblComprasPorBaseDeDatos Contabilidad.udt_TableType_CMVTipoCompMovStock
	DECLARE @tblCostoMercaderiaVendida Contabilidad.udt_TableType_CMVInfoResultado


	/*----------------------------------------------------------------------------------------------------------------*/
	/* -- Saldos iniciales para el CMV -- */
	IF OBJECT_ID('tempdb.dbo.##tblSaldosInialesCmv', 'U') IS NOT NULL
		TRUNCATE TABLE ##tblSaldosInialesCmv; 
	ELSE
		SELECT * INTO ##tblSaldosInialesCmv FROM @tblSaldosInialesCmv

	EXEC [Contabilidad].[sp_CMV_ObtenerSaldosInicialesCostoMercaderiaVendida] @Producto, @BaseDeDatos, @ListaBaseDeDatos, @NroEjercicio, '##tblSaldosInialesCmv'

	INSERT INTO @tblSaldosInialesCmv
		SELECT * FROM ##tblSaldosInialesCmv
	DROP TABLE ##tblSaldosInialesCmv

	/* -- Movimientos de stock para el CMV -- */
	IF OBJECT_ID('tempdb.dbo.##tblMovStockPorBaseDeDatos', 'U') IS NOT NULL
		TRUNCATE TABLE ##tblMovStockPorBaseDeDatos; 
	ELSE
		SELECT * INTO ##tblMovStockPorBaseDeDatos FROM @tblMovimientosProcesados

	EXEC [Contabilidad].[sp_CMV_ObtenerMovimientosDeArticulosComprados] @Producto, @ListaBaseDeDatos, @FechaIniEjercicio, @FechaFinEjercicio, '##tblMovStockPorBaseDeDatos' 

	INSERT INTO @tblMovimientosProcesados
		SELECT * FROM ##tblMovStockPorBaseDeDatos
	DROP TABLE ##tblMovStockPorBaseDeDatos

	/* -- Comprobantes asociados para CMV -- */
	IF OBJECT_ID('tempdb.dbo.##tblCompAsocPorBaseDeDatos', 'U') IS NOT NULL
		TRUNCATE TABLE ##tblCompAsocPorBaseDeDatos; 
	ELSE
		SELECT * INTO ##tblCompAsocPorBaseDeDatos FROM @tblCompAsocPorBaseDeDatos

	EXEC [Contabilidad].[sp_CMV_ObtenerFacturasAsociadasANotasDeCredito] @Producto, @ListaBaseDeDatos, @FechaIniEjercicio, @FechaFinEjercicio, '##tblCompAsocPorBaseDeDatos'

	INSERT INTO @tblCompAsocPorBaseDeDatos
		SELECT * FROM ##tblCompAsocPorBaseDeDatos
	DROP TABLE ##tblCompAsocPorBaseDeDatos

	/* -- Comprobantes de compra para costos del CMV -- */
	IF OBJECT_ID('tempdb.dbo.##tblCompComprasPorBaseDeDatos', 'U') IS NOT NULL
		TRUNCATE TABLE ##tblCompComprasPorBaseDeDatos; 
	ELSE
		SELECT * INTO ##tblCompComprasPorBaseDeDatos FROM @tblComprasPorBaseDeDatos

	EXEC [Contabilidad].[sp_CMV_ObtenerComprobantesDeCompra] @Producto, @ListaBaseDeDatos, @FechaIniEjercicio, @FechaFinEjercicio, '##tblCompComprasPorBaseDeDatos'

	INSERT INTO @tblComprasPorBaseDeDatos
		SELECT * FROM ##tblCompComprasPorBaseDeDatos
	DROP TABLE ##tblCompComprasPorBaseDeDatos
	/*----------------------------------------------------------------------------------------------------------------*/




	SELECT distinct sdo.Referencia, sdo.CompCodigo, 'Registro generado con el cierre de ejercicio nro.: ' + CONVERT ( VARCHAR(8), @NroEjercicio ) as ZADSFW
		 , sdo.Articulo, sdo.Color, sdo.Talle, sdo.Fecha, sdo.Cantidad as Cantidad, sdo.Cantidad as Stock, sdo.Cantidad as StockAnt, sdo.CostoUnitario, sdo.CompTipo
		 , coalesce(mov.Letra,'') as Letra, coalesce(mov.PtoVenExt,0) as PtoVenExt, coalesce(mov.NumComp,0) as NumComp, coalesce(mov.PtoVen,0) as PtoVen, coalesce(mov.NumInt,0) as NumInt
		 , coalesce(mov.Descrip,'') as Descrip, sdo.BD, @NroEjercicio as Ejercicio, 'C' as TipoIngreso
	FROM (
		SELECT BD, Referencia, Codigo, Articulo, Color, Talle, Cantidad, Stock, CostoUnitario, Fecha, CompTipo, CompCodigo, CompDesc, CostoInvAnt, CostoInvAcum 
		FROM [Contabilidad].[CMV_ObtenerCostosComprobantesMuevenStockEntreFechas]( @FechaIniEjercicio, @FechaFinEjercicio, @MetodoDeCosteo, @TipoDeSalida, @tblSaldosInialesCmv, @tblMovimientosProcesados, @tblCompAsocPorBaseDeDatos, @tblComprasPorBaseDeDatos ) 
		) sdo
	LEFT JOIN @tblMovimientosProcesados as MOV on mov.Codigo = sdo.CompCodigo


	--EXEC [Contabilidad].[sp_CMV_ActualizarStockAlCerrarEjercicio] @Version, @Usuario,	@NroSerie, @Producto, @BaseDeDatos, @ListaBaseDeDatos, @Ejercicio, @MetodoDeCosteo, @TipoDeSalida

END
