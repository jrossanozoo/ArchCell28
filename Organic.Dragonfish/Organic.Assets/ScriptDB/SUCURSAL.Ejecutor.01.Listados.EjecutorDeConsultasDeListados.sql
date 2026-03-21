IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Listados].[EjecutorDeConsultasDeListados]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT', N'P'))
	DROP PROCEDURE [Listados].[EjecutorDeConsultasDeListados];
GO;

CREATE PROCEDURE [Listados].[EjecutorDeConsultasDeListados]
(
	@ListaDeBases varchar(max),	
	@ListaSelect varchar(max),
	@FuncionListado varchar(max),
	@ListaParametros varchar(max),
	@CamposGroupBy varchar(max),
	@ClausulaHaving varchar(max),
	@FiltroSobreResultados as varchar(max),
	@CamposOrderBy varchar(max),
	@ModoDebug int = 0	-- Cualquier valor distinto de cero activa el modo debug
)
AS
begin
	/*  Prepara para la ejecución  ---------------------------------------------------------------------------------------*/
	declare @SaltoDeLinea varchar(4) = char(13)+char(10); 
	declare @Tab varchar(4) = char(9);
	declare @TempTableName varchar(max) = '##c_EjecutorListados_' + replace( convert( varchar(255), newid() ), '-', '' )


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

	declare @ListaDeBD TABLE (Referencias varchar(max), IdRegistro int)
	declare @CantidadDeDBS int;
	declare @CantidadDeDBSProcesadas int;

	declare @Posicion int;
	declare @ReferenciasDeBD varchar(100);
	declare @CodigoDeBD varchar(50);
	declare @CatalogoSQL varchar(50);

	/*  Obtiene datos parciales por cada base de datos y acuma en la tabla temporal  -------------------------------------*/
	insert into @ListaDeBD
	select Item, Row_Number() over (order by Item) from Funciones.DividirLaCadenaPorElCaracterDelimitador(@ListaDeBases,',');
	
	set @CantidadDeDBS = @@RowCount;
	set @CantidadDeDBSProcesadas = 0;
	set @ConsultaDebug = '';

	while @CantidadDeDBSProcesadas < @CantidadDeDBS
	begin
		select @ReferenciasDeBD = Referencias FROM @ListaDeBD WHERE IdRegistro = ( @CantidadDeDBS - @CantidadDeDBSProcesadas )

		set @Posicion = charindex( ':', @ReferenciasDeBD );
		if @Posicion > 0
			begin
				set @CodigoDeBD = rtrim( ltrim( left( @ReferenciasDeBD, @Posicion - 1 ) ) );
				set @CatalogoSQL = rtrim( ltrim( right( @ReferenciasDeBD, len( @ReferenciasDeBD ) - @Posicion ) ) );
			end
		else
			begin
				set @CodigoDeBD = ''
				set @CatalogoSQL =  ''
			end;
		
		set @CamposSelect = replace( @ListaSelect, '$CatalogoSQL!', @CatalogoSQL );
		set @Funcion = replace( @FuncionListado, '$CatalogoSQL!', @CatalogoSQL );
		set @Parametros = replace( @ListaParametros, '$CodigoDeBD!', @CodigoDeBD );

		if @CantidadDeDBSProcesadas = 0
			/* La consulta sobre la priemara base de datos crea la tabla temporal  */
			set @SubconsultaPorBD = 'select ' + @CamposSelect + ' $SaltoDeLinea!$Tabulador!into ' + @TempTableName;
		else
			/* El resto de las bases de datos realizan un insert en la tabla temporal creada anteriormente  */
			set @SubconsultaPorBD = 'insert into ' + @TempTableName + ' $SaltoDeLinea!$Tabulador!select ' + @CamposSelect;

		set @SubconsultaPorBD = @SubconsultaPorBD + '$SaltoDeLinea!$Tabulador!from ' + @Funcion + '(' + @Parametros + ') $SaltoDeLinea!$SaltoDeLinea!';
		
		set @CantidadDeDBSProcesadas = @CantidadDeDBSProcesadas + 1;
		
		set @SubconsultaPorBD = replace( replace( @SubconsultaPorBD, '$Tabulador!', @Tab ), '$SaltoDeLinea!', @SaltoDeLinea )
		if @ModoDebug != 0
			set @ConsultaDebug =  @ConsultaDebug + @SubconsultaPorBD;
		else
			execute( @SubconsultaPorBD )
	end;
	
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
	
	/*  Elimina la tabla temporal  ---------------------------------------------------------------------------------------*/
	set @sql = rtrim(@sql) + ';$SaltoDeLinea!$SaltoDeLinea!drop table ' + @TempTableName + '$SaltoDeLinea!'

	set @sql = replace( replace( @sql, '$Tabulador!', @Tab ), '$SaltoDeLinea!', @SaltoDeLinea )
	if @ModoDebug != 0
		select @ConsultaDebug + @sql as Sentencia_SQL
	else
		execute( @sql )
end