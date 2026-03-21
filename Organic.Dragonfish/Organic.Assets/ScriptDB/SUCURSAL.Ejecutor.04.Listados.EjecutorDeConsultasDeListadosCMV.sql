IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Listados].[EjecutorDeConsultasDeListadosCMV]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT', N'P'))
	DROP PROCEDURE [Listados].[EjecutorDeConsultasDeListadosCMV];
GO;

CREATE PROCEDURE [Listados].[EjecutorDeConsultasDeListadosCMV]
(
	@ListaDeBases varchar(max),	
	@ListaSelect varchar(max),
	@FuncionListado varchar(max),
	@ListaParametros varchar(max),
	@CamposGroupBy varchar(max),
	@ClausulaHaving varchar(max),
	@FiltroSobreResultados as varchar(max),
	@CamposOrderBy varchar(max),
	@BaseParaFiltros varchar(max), 
	@ParamFechaDesde varchar(max),
	@ParamFechaHasta varchar(max),
	@ParamFechaIniDesde varchar(max),
	@ParamFechaIniHasta varchar(max),
	@ParamTomaInfoContable varchar(max),
	@ModoDebug int = 0	
)
AS
begin
	/*  Prepara para la ejecución  ---------------------------------------------------------------------------------------*/
	declare @SaltoDeLinea varchar(4) = char(13)+char(10); 
	declare @Tab varchar(4) = char(9);
	declare @TempTableName varchar(max) = '##c_EjecutorListados_' + replace( convert( varchar(255), newid() ), '-', '' )

	/* Se declaran las tablas temporales que contendrán los datos de todas las bases agrupadas. La idea es contar con todos los datos ya unidos antes de ejecutar el listado  */	
	declare @TempTableSaldoInicial varchar(max) = '##c_SaldoInicial_' + replace( convert( varchar(255), newid() ), '-', '' )
	declare @TempTableMovimientos varchar(max) = '##c_Movimientos_' + replace( convert( varchar(255), newid() ), '-', '' )
	declare @TempTableCompAsociados varchar(max) = '##c_CompAsociados_' + replace( convert( varchar(255), newid() ), '-', '' )
	declare @TempTableCompras varchar(max) = '##c_Compras_' + replace( convert( varchar(255), newid() ), '-', '' )
	
	if @ModoDebug = 0	-- Si no está en modo debug
		begin	-- Cancela los tabuladores y saltos de linea
			set @SaltoDeLinea = ' ';
			set @Tab = ' ';
		end
	else				-- Si está en modo debug
		begin	-- Elimina los saltos de línea de todos los parámetros
			set @ListaDeBases = replace( @ListaDeBases, @SaltoDeLinea, '')
			set @ListaSelect = replace( @ListaSelect, @SaltoDeLinea, '' )
			set @FuncionListado = replace( @FuncionListado, @SaltoDeLinea, '')
			set @ListaParametros = replace( @ListaParametros, @SaltoDeLinea, '')
			set @CamposGroupBy = replace( @CamposGroupBy, @SaltoDeLinea, '')
			set @ClausulaHaving = replace( @ClausulaHaving, @SaltoDeLinea, '')
			set @FiltroSobreResultados = replace( @FiltroSobreResultados, @SaltoDeLinea, '')
			set @CamposOrderBy = replace( @CamposOrderBy, @SaltoDeLinea, '')
		end;
	
	/*  Declara las variables  -------------------------------------------------------------------------------------------*/
	declare @sql varchar(max);
	declare @SubconsultaPorBD varchar(max);
	declare @ConsultaDebug varchar(max);
	declare @FromDeAcumulados varchar(max);
	declare @Acumulados varchar(max);
	declare @CamposSelect varchar(max);
	declare @Funcion varchar(1000);
	declare @Parametros varchar(max);
	declare @FromDeAcumuladosSinRepetir varchar(max);

	declare @FechaIniBusqueda varchar(8)
	declare @FechaFinBusqueda varchar(8)
	declare @FechaInicioReferencia varchar(8)
	declare @Ejercicio numeric(8,0)
	declare @FechaIniEjercicio varchar(8)
	declare @NumeroEjercicioContable TABLE ( Numero numeric(8,0) )
	declare @FechaEjercicioContable TABLE ( Fecha datetime )
	
	declare @ListaDeBD TABLE (Referencias varchar(max), IdRegistro int)
	declare @CantidadDeDBS int;
	declare @CantidadDeDBSProcesadas int;

	declare @Posicion int;
	declare @UltimaPos int;
	declare @Producto varchar(25);
	declare @ReferenciasDeBD varchar(100);
	declare @CodigoDeBD varchar(50);
	declare @SucursalSQL varchar(50);
	declare @CatalogoSQL varchar(50);
	declare @CadenaDeSucursales varchar(1000);
	
	/* Declara variables para armar las consultas en formato texto para que se puedan ejecutar con un EXEC() */
	declare @SubconsultaSaldoInicial varchar(max);
	declare @SubconsultaSaldoInicial2 varchar(max);
	declare @SubconsultaMovimientos varchar(max);
	declare @SubconsultaMovimientos2 varchar(max);
	declare @SubconsultaCompAsociados varchar(max);
	declare @SubconsultaCompAsociados2 varchar(max);
	declare @SubconsultaCompras varchar(max);
	declare @SubconsultaCompras2 varchar(max);
	

	/*  Obtiene las bases de datos a procesar pasadas por parametro */
	insert into @ListaDeBD
	select Item, Row_Number() over (order by Item) from Funciones.DividirLaCadenaPorElCaracterDelimitador(@ListaDeBases,',');
	set @CantidadDeDBS = @@RowCount;
	set @CantidadDeDBSProcesadas = 0;

	set @ConsultaDebug = '';
	set @SubconsultaPorBD = '';
	

	/* Inicialización de variables declaradas anteriormente para armar las consultas en formato texto para que se puedan ejecutar con un EXEC()  */
	set @SubconsultaSaldoInicial = '';
	set @SubconsultaSaldoInicial2 = '';
	set @SubconsultaMovimientos = '';
	set @SubconsultaMovimientos2 = '';
	set @SubconsultaCompAsociados = '';
	set @SubconsultaCompAsociados2 = '';
	set @SubconsultaCompras = '';
	set @SubconsultaCompras2 = '';

	
	/* Obtiene una lista de sucursales separandas por compas a partir de la lista de bases de datos pasadas por parametro */
	set @CadenaDeSucursales = ''
	set @CantidadDeDBSProcesadas = 0;
	while @CantidadDeDBSProcesadas < @CantidadDeDBS
	begin
		select @ReferenciasDeBD = Referencias FROM @ListaDeBD WHERE IdRegistro = ( @CantidadDeDBS - @CantidadDeDBSProcesadas )
		set @Posicion = charindex( ':', @ReferenciasDeBD );
		if @Posicion > 0
			set @CadenaDeSucursales = @CadenaDeSucursales + rtrim( ltrim( left( @ReferenciasDeBD, @Posicion - 1 ) ) ) + ',';

		set @CantidadDeDBSProcesadas = @CantidadDeDBSProcesadas + 1;
	end
	set @CadenaDeSucursales = left( @CadenaDeSucursales, len( @CadenaDeSucursales ) -1 );


	/* Obtiene el nombre del cataloogo a partir de la BaseParaFiltros pasada por parametro */
	set @Posicion = charindex( ':', @BaseParaFiltros );
	if @Posicion > 0
		begin
			set @SucursalSQL = rtrim( ltrim( left( @BaseParaFiltros, @Posicion - 1 ) ) );
			set @CatalogoSQL = rtrim( ltrim( right( @BaseParaFiltros, len( @BaseParaFiltros ) - @Posicion ) ) );
		end
	else
		begin
			set @SucursalSQL = ''
			set @CatalogoSQL = ''
		end


	/* Obtiene el nombre del producto a partir del catalogo obtenido anteriormente */
	set @ultimaPos = len( @CatalogoSQL ) - charindex( '_', reverse( @CatalogoSQL ) );
	if @ultimaPos <> len( @CatalogoSQL )
		set @Producto = rtrim( ltrim( left( @CatalogoSQL, @ultimaPos ) ) ) ;
	else
		set @Producto =  rtrim( ltrim( @CatalogoSQL ) );


	/* Obtiene el numero de ejercicio correspondiente segun el rango de fechas  */
	insert into @NumeroEjercicioContable
		exec [Contabilidad].[sp_ObtenerEjercicioSegunRangoDeFechas]  @CatalogoSQL, @ParamFechaDesde, @ParamFechaHasta ;
	select top 1 @Ejercicio = Numero from @NumeroEjercicioContable


	/* Obtiene la fecha de inicio del ejercicio contable */
	insert into @FechaEjercicioContable
		exec [Contabilidad].[sp_CMV_ObtenerFechaDeInicioDelEjercicio] @CatalogoSQL, @Ejercicio 
	select top 1 @FechaIniEjercicio = convert( varchar(8), Fecha, 112 ) from @FechaEjercicioContable

	/* Determino las fechas segun el parametro */
	if @ParamTomaInfoContable = '1'
		begin
			set @FechaIniBusqueda = cast( '' as varchar(8) )
			set @FechaFinBusqueda = cast( '' as varchar(8) )
			set @FechaInicioReferencia = @FechaIniEjercicio
		end
	else
		begin
			set @FechaIniBusqueda = cast( @ParamFechaIniDesde as varchar(8) )
			set @FechaFinBusqueda = cast( @ParamFechaIniHasta as varchar(8) )
			set @FechaInicioReferencia = convert( varchar(8), convert( datetime, @FechaFinBusqueda ) +1, 112 ) 
		end


	/* ----------------------------------------------------------------------------------- */	
	/*                   INICIO CREACIÓN DE TABLAS TEMPORALES                              */

	set @SubconsultaSaldoInicial = '$SaltoDeLinea!';
	set @SubconsultaSaldoInicial = @SubconsultaSaldoInicial + 'declare @tblSaldosInialesCmv Contabilidad.udt_TableType_CMVTipoCompMovStock ' + '$SaltoDeLinea!';
	set @SubconsultaSaldoInicial = @SubconsultaSaldoInicial + 'select * into ' + @TempTableSaldoInicial + ' FROM @tblSaldosInialesCmv ' + '$SaltoDeLinea!';
	if @ParamTomaInfoContable = '1'
		set @SubconsultaSaldoInicial = @SubconsultaSaldoInicial + 'EXEC [Contabilidad].[sp_CMV_ObtenerSaldosInicialesCostoMercaderiaVendida] ''' + @Producto + ''', ''' + @SucursalSQL + ''', ''' + @CadenaDeSucursales + ''', ' + convert( varchar(8), @Ejercicio ) + ', ''' + @TempTableSaldoInicial + ''' ';
	else
		set @SubconsultaSaldoInicial = @SubconsultaSaldoInicial + 'EXEC [Contabilidad].[sp_CMV_ObtenerSaldosInicialesDeArticulosComprados] ''' + @Producto + ''', ''' + @CadenaDeSucursales + ''', ''' + @FechaIniBusqueda + ''', ''' + @FechaFinBusqueda + ''', ''' + @TempTableSaldoInicial + ''' ';
	set @SubconsultaSaldoInicial = @SubconsultaSaldoInicial + '$SaltoDeLinea!';
	set @SubconsultaSaldoInicial = replace( replace( @SubconsultaSaldoInicial, '$Tabulador!', @Tab ), '$SaltoDeLinea!', @SaltoDeLinea );

	set @SubconsultaMovimientos = '$SaltoDeLinea!';
	set @SubconsultaMovimientos = @SubconsultaMovimientos + 'declare @tblMovimientosProcesados Contabilidad.udt_TableType_CMVTipoCompMovStock ' + '$SaltoDeLinea!';
	set @SubconsultaMovimientos = @SubconsultaMovimientos + 'select * into ' + @TempTableMovimientos + ' FROM @tblMovimientosProcesados ' + '$SaltoDeLinea!';
	set @SubconsultaMovimientos = @SubconsultaMovimientos + 'EXEC [Contabilidad].[sp_CMV_ObtenerMovimientosDeArticulosComprados] ''' + @Producto + ''', ''' + @CadenaDeSucursales + ''', ''' + @FechaInicioReferencia + ''', ''' + @ParamFechaHasta + ''', ''' + @TempTableMovimientos + ''' ';
	set @SubconsultaMovimientos = @SubconsultaMovimientos + '$SaltoDeLinea!';
	set @SubconsultaMovimientos = replace( replace( @SubconsultaMovimientos, '$Tabulador!', @Tab ), '$SaltoDeLinea!', @SaltoDeLinea );

	set @SubconsultaCompAsociados = '$SaltoDeLinea!';
	set @SubconsultaCompAsociados = @SubconsultaCompAsociados + 'declare @tblCompAsocPorBaseDeDatos Contabilidad.udt_TableType_CMVCompAsociados ' + '$SaltoDeLinea!';
	set @SubconsultaCompAsociados = @SubconsultaCompAsociados + 'select * into ' + @TempTableCompAsociados + ' FROM @tblCompAsocPorBaseDeDatos ' + '$SaltoDeLinea!';
	set @SubconsultaCompAsociados = @SubconsultaCompAsociados + 'EXEC [Contabilidad].[sp_CMV_ObtenerFacturasAsociadasANotasDeCredito] ''' + @Producto + ''', ''' + @CadenaDeSucursales + ''', ''' + @FechaInicioReferencia + ''', ''' + @ParamFechaHasta + ''', ''' + @TempTableCompAsociados + ''' ';
	set @SubconsultaCompAsociados = @SubconsultaCompAsociados + '$SaltoDeLinea!';
	set @SubconsultaCompAsociados = replace( replace( @SubconsultaCompAsociados, '$Tabulador!', @Tab ), '$SaltoDeLinea!', @SaltoDeLinea );

	set @SubconsultaCompras = '$SaltoDeLinea!';
	set @SubconsultaCompras = @SubconsultaCompras + 'declare @tblComprasPorBaseDeDatos Contabilidad.udt_TableType_CMVTipoCompMovStock ' + '$SaltoDeLinea!';
	set @SubconsultaCompras = @SubconsultaCompras + 'select * into ' + @TempTableCompras + ' FROM @tblComprasPorBaseDeDatos ' + '$SaltoDeLinea!';
	set @SubconsultaCompras = @SubconsultaCompras + 'EXEC [Contabilidad].[sp_CMV_ObtenerComprobantesDeCompra] ''' + @Producto + ''', ''' + @CadenaDeSucursales + ''', ''' + @FechaInicioReferencia + ''', ''' + @ParamFechaHasta + ''', ''' + @TempTableCompras + ''' ';
	set @SubconsultaCompras = @SubconsultaCompras + '$SaltoDeLinea!';
	set @SubconsultaCompras = @SubconsultaCompras + '$SaltoDeLinea!';
	set @SubconsultaCompras = replace( replace( @SubconsultaCompras, '$Tabulador!', @Tab ), '$SaltoDeLinea!', @SaltoDeLinea );

	/*                      FIN CREACIÓN DE TABLAS TEMPORALES                              */
	/* ----------------------------------------------------------------------------------- */	


	if @ModoDebug != 0
		set @ConsultaDebug =  @ConsultaDebug + @SubconsultaSaldoInicial + @SubconsultaMovimientos + @SubconsultaCompAsociados + @SubconsultaCompras;
	else
		execute( @SubconsultaSaldoInicial + @SubconsultaMovimientos + @SubconsultaCompAsociados + @SubconsultaCompras )

	
	/* ----------------------------------------------------------------------------------- */	
	/*             INICIO PASAJE DE TABLAS TEMPORALES GLOBALES A TABLAS LOCALES            */

	set @SubconsultaSaldoInicial2 = '$SaltoDeLinea!';
	if @ModoDebug = 0
		set @SubconsultaSaldoInicial2 = @SubconsultaSaldoInicial2 + 'declare @tblSaldosInialesCmv Contabilidad.udt_TableType_CMVTipoCompMovStock ' + '$SaltoDeLinea!';
	set @SubconsultaSaldoInicial2 = @SubconsultaSaldoInicial2 + 'insert into @tblSaldosInialesCmv ( ID, GLOBALID, CODIGO, FACTTIPO, ARTICULO, COLOR, TALLE, FECHA, LETRA, PTOVENEXT, NUMCOMP, PTOVEN, NUMINT, CANTIDAD, PRECIO, TIMESTAMP, DESCRIP, BASE ) $SaltoDeLinea!$Tabulador!';
	set @SubconsultaSaldoInicial2 = @SubconsultaSaldoInicial2 + 'select  ID, GLOBALID, CODIGO, FACTTIPO, ARTICULO, COLOR, TALLE, FECHA, LETRA, PTOVENEXT, NUMCOMP, PTOVEN, NUMINT, CANTIDAD, PRECIO, TIMESTAMP, DESCRIP, BASE $SaltoDeLinea!$Tabulador!';
	set @SubconsultaSaldoInicial2 = @SubconsultaSaldoInicial2 + 'from ' + @TempTableSaldoInicial + ' order by Articulo, Color, Talle, Fecha, Id  $SaltoDeLinea!';
	set @SubconsultaSaldoInicial2 = replace( replace( @SubconsultaSaldoInicial2, '$Tabulador!', @Tab ), '$SaltoDeLinea!', @SaltoDeLinea );

	set @SubconsultaMovimientos2 = '$SaltoDeLinea!';
	if @ModoDebug = 0
		set @SubconsultaMovimientos2 = @SubconsultaMovimientos2 + 'declare @tblMovimientosProcesados Contabilidad.udt_TableType_CMVTipoCompMovStock ' + '$SaltoDeLinea!';
	set @SubconsultaMovimientos2 = @SubconsultaMovimientos2 + 'insert into @tblMovimientosProcesados ( ID, GLOBALID, CODIGO, FACTTIPO, ARTICULO, COLOR, TALLE, FECHA, LETRA, PTOVENEXT, NUMCOMP, PTOVEN, NUMINT, CANTIDAD, PRECIO, TIMESTAMP, DESCRIP, BASE ) $SaltoDeLinea!$Tabulador!';
	set @SubconsultaMovimientos2 = @SubconsultaMovimientos2 + 'select ID, GLOBALID, CODIGO, FACTTIPO, ARTICULO, COLOR, TALLE, FECHA, LETRA, PTOVENEXT, NUMCOMP, PTOVEN, NUMINT, CANTIDAD, PRECIO, TIMESTAMP, DESCRIP, BASE $SaltoDeLinea!$Tabulador!';
	set @SubconsultaMovimientos2 = @SubconsultaMovimientos2 + 'from ' + @TempTableMovimientos + ' order by Articulo, Color, Talle, Fecha, Id  $SaltoDeLinea!';
	set @SubconsultaMovimientos2 = replace( replace( @SubconsultaMovimientos2, '$Tabulador!', @Tab ), '$SaltoDeLinea!', @SaltoDeLinea );

	set @SubconsultaCompAsociados2 = '$SaltoDeLinea!';
	if @ModoDebug = 0
		set @SubconsultaCompAsociados2 = @SubconsultaCompAsociados2 + 'declare @tblCompAsocPorBaseDeDatos Contabilidad.udt_TableType_CMVCompAsociados ' + '$SaltoDeLinea!';
	set @SubconsultaCompAsociados2 = @SubconsultaCompAsociados2 + 'insert into @tblCompAsocPorBaseDeDatos ( Articulo, Color, Talle, Cantidad, Descfw, Fecha, CompTipo, CompCodigo, Comprobante ) $SaltoDeLinea!$Tabulador!';
	set @SubconsultaCompAsociados2 = @SubconsultaCompAsociados2 + 'select Articulo, Color, Talle, Cantidad, Descfw, Fecha, CompTipo, CompCodigo, Comprobante $SaltoDeLinea!$Tabulador!';
	set @SubconsultaCompAsociados2 = @SubconsultaCompAsociados2 + 'from ' + @TempTableCompAsociados + ' $SaltoDeLinea!';
	set @SubconsultaCompAsociados2 = replace( replace( @SubconsultaCompAsociados2, '$Tabulador!', @Tab ), '$SaltoDeLinea!', @SaltoDeLinea );

	set @SubconsultaCompras2 = '$SaltoDeLinea!';
	if @ModoDebug = 0
		set @SubconsultaCompras2 = @SubconsultaCompras2 + 'declare @tblComprasPorBaseDeDatos Contabilidad.udt_TableType_CMVTipoCompMovStock ' + '$SaltoDeLinea!';
	set @SubconsultaCompras2 = @SubconsultaCompras2 + 'insert into @tblComprasPorBaseDeDatos ( ID, GLOBALID, CODIGO, FACTTIPO, ARTICULO, COLOR, TALLE, FECHA, LETRA, PTOVENEXT, NUMCOMP, PTOVEN, NUMINT, CANTIDAD, PRECIO, TIMESTAMP, DESCRIP, BASE ) $SaltoDeLinea!$Tabulador!';
	set @SubconsultaCompras2 = @SubconsultaCompras2 + 'select ID, GLOBALID, CODIGO, FACTTIPO, ARTICULO, COLOR, TALLE, FECHA, LETRA, PTOVENEXT, NUMCOMP, PTOVEN, NUMINT, CANTIDAD, PRECIO, TIMESTAMP, DESCRIP, BASE $SaltoDeLinea!$Tabulador!';
	set @SubconsultaCompras2 = @SubconsultaCompras2 + 'from ' + @TempTableCompras + ' $SaltoDeLinea!';
	set @SubconsultaCompras2 = @SubconsultaCompras2 + '$SaltoDeLinea!';
	set @SubconsultaCompras2 = @SubconsultaCompras2 + '$SaltoDeLinea!';
	set @SubconsultaCompras2 = replace( replace( @SubconsultaCompras2, '$Tabulador!', @Tab ), '$SaltoDeLinea!', @SaltoDeLinea );

	/*             FIN PASAJE DE TABLAS TEMPORALES GLOBALES A TABLAS LOCALES               */
	/* ----------------------------------------------------------------------------------- */	


	/* Armado original con los parámetros que recibo desde DF para los campos, parámetros, y filtros del listado */
	set @CamposSelect = replace( @ListaSelect, '$CatalogoSQL!', @CatalogoSQL );
	set @Parametros = replace( @ListaParametros, '$CodigoDeBD!', @SucursalSQL );
	set @Funcion = replace( @FuncionListado, '$CatalogoSQL!', @CatalogoSQL );


	set @SubconsultaPorBD = 'select ' + @CamposSelect + ' $SaltoDeLinea!$Tabulador!into ' + @TempTableName;
	set @SubconsultaPorBD = @SubconsultaPorBD + '$SaltoDeLinea!$Tabulador!from ' + @Funcion + '(' + @Parametros + ') $SaltoDeLinea!$SaltoDeLinea!';
	set @SubconsultaPorBD = replace( replace( @SubconsultaPorBD, '$Tabulador!', @Tab ), '$SaltoDeLinea!', @SaltoDeLinea )


	/* Se reemplaza el nombre fijo asignado en la listcampos para @Parametro*, por los nombres de las tablas temporales */
	set @SubconsultaPorBD = replace( @SubconsultaPorBD, '''TblSI''', '@tblSaldosInialesCmv' ) 
	set @SubconsultaPorBD = replace( @SubconsultaPorBD, '''TblMov''', '@tblMovimientosProcesados' )
	set @SubconsultaPorBD = replace( @SubconsultaPorBD, '''TblAsoc''', '@tblCompAsocPorBaseDeDatos' )
	set @SubconsultaPorBD = replace( @SubconsultaPorBD, '''TblCompra''', '@tblComprasPorBaseDeDatos' )


	if @ModoDebug != 0
		set @ConsultaDebug =  @ConsultaDebug + @SubconsultaSaldoInicial2 + @SubconsultaMovimientos2 + @SubconsultaCompAsociados2 + @SubconsultaCompras2 + @SubconsultaPorBD;
	else
		execute( @SubconsultaSaldoInicial2 + @SubconsultaMovimientos2 + @SubconsultaCompAsociados2 + @SubconsultaCompras2 + @SubconsultaPorBD )


	
	/*  Obtiene los datos finales  ---------------------------------------------------------------------------------------*/
	set @sql = 'select $ListaSelect!$SaltoDeLinea!$IdentacionFromAgrupamiento!from ' + @TempTableName + ' as subconsulta';

	set @ListaSelect = Funciones.EliminarExpresionesDeLaListaDeCampos( @ListaSelect );
	set @ListaSelect = 'subconsulta.' + replace( @ListaSelect, ',', ', subconsulta.' );
	set @ListaSelect = replace( @ListaSelect, '. ', '.' );
	
	/*  Aplica filtros sobre agrupamientos o resultados  -----------------------------------------------------------------*/
	if (ltrim(rtrim(@CamposGroupBy)) != '') and (ltrim(rtrim(@ClausulaHaving)) != '')
		begin

			set @FromDeAcumuladosSinRepetir = Funciones.Alltrim( REPLACE ( @CamposGroupBy , Funciones.ObtenerListaDeCamposDeLaClausulaHaving(@ClausulaHaving) , '' ) + REPLACE ( @CamposGroupBy + Funciones.ObtenerListaDeCamposDeLaClausulaHaving(@ClausulaHaving) ,@CamposGroupBy ,  '' ) )
			set @FromDeAcumuladosSinRepetir = case when right( @FromDeAcumuladosSinRepetir, 1 ) = ',' then LEFT(@FromDeAcumuladosSinRepetir, LEN(@FromDeAcumuladosSinRepetir) - 1) else  @FromDeAcumuladosSinRepetir end -- para eliminar coma final 

			set @FromDeAcumulados = replace( replace( replace( @sql, '$ListaSelect!', @FromDeAcumuladosSinRepetir /* @CamposGroupBy + Funciones.ObtenerListaDeCamposDeLaClausulaHaving(@ClausulaHaving)*/ ), '$IdentacionFromAgrupamiento!', '$Tabulador!$Tabulador!' ), 'as subconsulta', '' )
			set @CamposGroupBy = Funciones.EliminarExpresionesDeLaListaDeCampos( @CamposGroupBy );
			set @Acumulados = 'select ' + @CamposGroupBy + '$SaltoDeLinea!$Tabulador!from ($SaltoDeLinea!$Tabulador!$Tabulador!' + @FromDeAcumulados + '$SaltoDeLinea!$Tabulador!$Tabulador!) as tmp$SaltoDeLinea!$Tabulador!group by ' + @CamposGroupBy + '$SaltoDeLinea!$Tabulador!having ' + Funciones.EliminarExpresionesDeLaClausulaHaving( @ClausulaHaving )

			set @sql = @sql + '$SaltoDeLinea!$Tabulador!inner join$SaltoDeLinea!$Tabulador!($SaltoDeLinea!$Tabulador!' + @Acumulados + '$SaltoDeLinea!$Tabulador!) as acumulados$SaltoDeLinea!$Tabulador!on ' + Funciones.ObtenerClausulaJoinParaListadosAgrupados(@CamposGroupBy, 'subconsulta', 'acumulados')
		end
	else
		if ltrim(rtrim(@FiltroSobreResultados)) != '' set @sql = @sql + '$SaltoDeLinea!where ' + Funciones.EliminarExpresionesDeLaListaDeCampos( @FiltroSobreResultados );

	set @sql = replace( replace( @sql, '$IdentacionFromAgrupamiento!', '' ), '$ListaSelect!', @ListaSelect );
	if  (ltrim(rtrim(@CamposOrderBy)) != '') set @sql = @sql + '$SaltoDeLinea!order by ' + Funciones.AgregarAliasALaClausulaOrderBy( @CamposOrderBy, 'subconsulta' )
	

	/* ----------------------------------------------------------------------------------------------------------*/	
	/*                        INICIO BORRADO DE TABLAS TEMPORALES GLOBALES ANTES DECLARADAS                      */

	/*  Elimina las tablas temporales  --------------------------------------------------------------------------*/
	set @sql = rtrim(@sql) + ';$SaltoDeLinea!$SaltoDeLinea!drop table ' + @TempTableName --+ '$SaltoDeLinea!'

	set @sql = rtrim(@sql) + ';$SaltoDeLinea!drop table ' + @TempTableSaldoInicial -- + '$SaltoDeLinea!'
	set @sql = rtrim(@sql) + ';$SaltoDeLinea!drop table ' + @TempTableMovimientos --+ '$SaltoDeLinea!'
	set @sql = rtrim(@sql) + ';$SaltoDeLinea!drop table ' + @TempTableCompAsociados --+ '$SaltoDeLinea!'
	set @sql = rtrim(@sql) + ';$SaltoDeLinea!drop table ' + @TempTableCompras + '$SaltoDeLinea!'

	set @sql = replace( replace( @sql, '$Tabulador!', @Tab ), '$SaltoDeLinea!', @SaltoDeLinea )

	/*              FIN  BORRADO DE TABLAS TEMPORALES GLOBALES ANTES DECLARADAS                                    */
	/* ------------------------------------------------------------------------------------------------------------*/	


	if @ModoDebug != 0
		select @ConsultaDebug + @sql as Sentencia_SQL
	else
		execute( @sql )
end
