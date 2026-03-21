IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Listados].[EjecutorParaVentasVsStockExtendido]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT', N'P'))
	DROP PROCEDURE [Listados].[EjecutorParaVentasVsStockExtendido];
GO;

CREATE PROCEDURE [Listados].[EjecutorParaVentasVsStockExtendido]
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
	/* Prepara para la ejecución  --------------------------------------------------------------------------------------- */
	declare @SaltoDeLinea varchar(4) = char(13)+char(10); 
	--declare @Tab varchar(4) = char(9);

	set @ModoDebug = 0;	-- Este Store Procedure no está preparado para usar el @ModoDebug 

	declare @IdUnico varchar(max) = replace( convert( varchar(255), newid() ), '-', '' );
	declare @TempTableNameStockD varchar(max) = '##c_VentasVsStock_' + @IdUnico;
	declare @TempTableNameStockC varchar(max) = '##c_StockComplementario_' + @IdUnico;

	declare @ConsultaVentasVsStockDirecto varchar(max) = '';
	declare @ConsultaStockComplementario varchar(max) = '';
	declare @LimpliarEntorno varchar(max) = '';

	/* Crea la tabla temporal para Ventas Vs. Stock directo  ------------------------------------------------------------ */
	set @ConsultaVentasVsStockDirecto = 'select ' + @ListaSelect + ' into ' + @TempTableNameStockD + ' from ' + replace( @FuncionListado, '$CatalogoSQL!', db_name() ) + '(' + @ListaParametros + ') where 1=0;' + @SaltoDeLinea;
	execute( @ConsultaVentasVsStockDirecto )
	
	/* Llena la tabla temporal delegando la ejecucion al EjecutorDeConsultasDeListados  --------------------------------- */
	declare @SQLDinamico nvarchar(max) = 'insert into ' +  @TempTableNameStockD + @SaltoDeLinea + 'exec [Listados].[EjecutorDeConsultasDeListados] @ListaDeBases1, @ListaSelect1, @FuncionListado1, @ListaParametros1, @CamposGroupBy1, @ClausulaHaving1, @FiltroSobreResultados1, @CamposOrderBy1, @ModoDebug1';  
	declare @ListaDeParametros nvarchar(max) = '@ListaDeBases1 varchar(max), @ListaSelect1 varchar(max), @FuncionListado1 varchar(max), @ListaParametros1 varchar(max), @CamposGroupBy1 varchar(max), @ClausulaHaving1 varchar(max), @FiltroSobreResultados1 as varchar(max),	@CamposOrderBy1 varchar(max), @ModoDebug1 int';    
	execute sp_executesql @SQLDinamico, @ListaDeParametros, @ListaDeBases1 = @ListaDeBases, @ListaSelect1 = @ListaSelect, @FuncionListado1 = @FuncionListado, @ListaParametros1 = @ListaParametros, @CamposGroupBy1  = @CamposGroupBy, @ClausulaHaving1 = @ClausulaHaving, @FiltroSobreResultados1 =@FiltroSobreResultados, @CamposOrderBy1 = @CamposOrderBy, @ModoDebug1 = @ModoDebug;

	/* Crea la tabla temporal para Stock complementario  ---------------------------------------------------------------- */
	set @ConsultaStockComplementario= 'select ' + @ListaSelect + ' into ' + @TempTableNameStockC + ' from ' + replace( @FuncionListado, '$CatalogoSQL!', db_name() ) + '(' + @ListaParametros + ') where 1=0;' + @SaltoDeLinea;
	execute( @ConsultaStockComplementario )
	
	/* Llena la tabla temporal segun la lista de bases de datos del último argumento de @ListaSelect  ------------------- */
	declare @Posicion int = len(@ListaParametros) - charindex(''' ,', reverse(@ListaParametros)) + 2;
	declare @ListaBDStockComplementario varchar(max) = substring( @ListaParametros, @Posicion, len(@ListaParametros) - @Posicion );

	/* Actualiza y completa la tabla temporal  Ventas Vs. Stock directo con los datos del Stock complementario  --------- */
	if @ListaBDStockComplementario != '$CatalogoSQL!'
	begin
		set @SQLDinamico = replace( @SQLDinamico, @TempTableNameStockD, @TempTableNameStockC )
		execute sp_executesql @SQLDinamico, @ListaDeParametros, @ListaDeBases1 = @ListaBDStockComplementario, @ListaSelect1 = @ListaSelect, @FuncionListado1 = @FuncionListado, @ListaParametros1 = @ListaParametros, @CamposGroupBy1  = @CamposGroupBy, @ClausulaHaving1 = @ClausulaHaving, @FiltroSobreResultados1 =@FiltroSobreResultados, @CamposOrderBy1 = @CamposOrderBy, @ModoDebug1 = @ModoDebug;
	
		set @ConsultaVentasVsStockDirecto = 'alter table ' + @TempTableNameStockD + ' alter column ITEMARTICULOSVENTAS__BD varchar(60)'
		execute( @ConsultaVentasVsStockDirecto )

		set @ConsultaStockComplementario = 'alter table ' + @TempTableNameStockC + ' alter column ITEMARTICULOSVENTAS__BD varchar(60)'
		execute( @ConsultaStockComplementario )

		set @ConsultaStockComplementario = 'update ' + @TempTableNameStockC + ' set ITEMARTICULOSVENTAS__BD = '' '' + FACTURA_StockAgregadoVirtual, FACTURA_VentasDesdeVirtual = FACTURA_StockAgregadoVirtual, ITEMARTICULOSVENTAS_FCANT = null'
		execute( @ConsultaStockComplementario )
		execute( 'insert into ' + @TempTableNameStockD + ' select * from ' + @TempTableNameStockC )
	end

	execute( 'select * from ' + @TempTableNameStockD )

	set @LimpliarEntorno = @LimpliarEntorno + 'drop table ' + @TempTableNameStockD + ';' +@SaltoDeLinea
	set @LimpliarEntorno = @LimpliarEntorno + 'drop table ' + @TempTableNameStockC + ';' +@SaltoDeLinea
	execute( @LimpliarEntorno )
end
