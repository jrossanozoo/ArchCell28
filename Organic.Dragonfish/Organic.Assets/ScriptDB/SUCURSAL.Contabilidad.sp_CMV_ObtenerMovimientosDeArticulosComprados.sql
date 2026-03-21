IF EXISTS(SELECT * FROM sys.objects WHERE name = 'sp_CMV_ObtenerMovimientosDeArticulosComprados' AND type in (N'P') and SCHEMA_ID('Contabilidad') = schema_id)
	DROP PROCEDURE [Contabilidad].[sp_CMV_ObtenerMovimientosDeArticulosComprados];
GO;

CREATE PROCEDURE [Contabilidad].[sp_CMV_ObtenerMovimientosDeArticulosComprados]
	( 
	@ParamProducto varchar(25),
	@ParamListaBD varchar(1000),
	@ParamFechaDesde varchar(8),
	@ParamFechaHasta varchar(8),
	@ParamTablaDeRetorno varchar(100)
	)
AS
BEGIN
	/* Aqui ciclo entre las bases de dados de un agrupamiento y voy obteniendo los movimientos de stock dentro de un periodo dado */

	--declare @ParamProducto varchar(25) = 'DRAGONFISH'
	--declare @ParamListaBD varchar(1000) = 'DEMO2,DEMO4'
	--declare @ParamFechaDesde varchar(8) = ''
	--declare @ParamFechaHasta varchar(8) = '20250430'
	--declare @ParamTablaDeRetorno varchar(100) = '##tblTmpMovimientos'

	DECLARE @TablaReturn varchar(100) = ltrim( rtrim( @ParamTablaDeRetorno ) )
	DECLARE @Producto varchar(25) = ltrim( rtrim( @ParamProducto ) )
	DECLARE @FechaDesde varchar(8) = '19000101'
	DECLARE @FechaHasta varchar(8) = CONVERT( VARCHAR(8), GETDATE(), 112 ) 

	SET @FechaDesde = case when @ParamFechaDesde = '' then @FechaDesde else @ParamFechaDesde end
	SET @FechaHasta = case when @ParamFechaHasta = '' then @FechaHasta else @ParamFechaHasta end

	DECLARE	@tblTmpMovimientos Contabilidad.udt_TableType_CMVTipoCompMovStock
	
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
	--SELECT * INTO ##tblTmpMovimientos FROM @tblTmpMovimientos
	--SET @TablaReturn = '##tblTmpMovimientos'
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

		INSERT INTO @tblTmpMovimientos 
		EXEC [Contabilidad].[sp_CMV_ObtenerCambiosDeStockPorComprobante] @CatalogoSQL, @BaseDeDatos, @FechaDesde, @FechaHasta 
				
		SET @CantidadDeDBSProcesadas = @CantidadDeDBSProcesadas + 1
	END

	IF OBJECT_ID('tempdb.dbo.#tblCambiosDeStock', 'U') IS NOT NULL
		DROP TABLE #tblCambiosDeStock; 
	SELECT (ROW_NUMBER() OVER (ORDER BY ARTICULO, COLOR, TALLE, FECHA, TIMESTAMP)) AS ID, * INTO #tblCambiosDeStock 
	FROM ( 
		  SELECT GLOBALID, CODIGO, FACTTIPO, ARTICULO, COLOR, TALLE, FECHA, LETRA, PTOVENEXT, NUMCOMP, PTOVEN, NUMINT, CANTIDAD, PRECIO, TIMESTAMP, DESCRIP, BASE 
		  FROM @tblTmpMovimientos 
		 ) Movimientos

	DECLARE @Sql nvarchar(max) = ''
	SET @Sql = @Sql + 'INSERT INTO ' + @TablaReturn + ' SELECT * FROM #tblCambiosDeStock '
	EXEC sp_executesql @Sql

	/*-------------------------------------*/
	--SELECT * FROM ##tblTmpMovimientos
	--DROP TABLE ##tblTmpMovimientos
	/*-------------------------------------*/


	--EXEC [Contabilidad].[sp_CMV_ObtenerMovimientosDeArticulosComprados] 'DRAGONFISH', 'BASESCMV', '20250401', '20250430', '##NombreTabla'

END 
