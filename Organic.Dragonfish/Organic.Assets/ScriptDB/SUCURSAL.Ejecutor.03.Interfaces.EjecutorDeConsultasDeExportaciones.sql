IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[EjecutorDeConsultasDeExportaciones]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT', N'P'))
	DROP PROCEDURE [Interfaces].[EjecutorDeConsultasDeExportaciones];
GO;

CREATE PROCEDURE [Interfaces].[EjecutorDeConsultasDeExportaciones]
(
	@ListaDeBases varchar(max),	
	@ListaSelect varchar(max),
	@FuncionExportacion varchar(max),
	@ListaParametros varchar(max)
)
AS
begin
	declare @IdUnico varchar(max) = replace( convert( varchar(255), newid() ), '-', '' );
	declare @TempTablaDeExportacion varchar(max) = '##c_Exportacion_' + @IdUnico;
	declare @ConsultaBaseDeExportacion varchar(max) = '';

	/* Crea la tabla temporal para Exportacion ------------------------------------------------------------ */
	set @ConsultaBaseDeExportacion = 'select ' + @ListaSelect + ' into ' + @TempTablaDeExportacion + ' from ' + replace( @FuncionExportacion, '$CatalogoSQL!', db_name() ) + '(' + @ListaParametros + ') where 1=0;';
	execute( @ConsultaBaseDeExportacion )

	/* Llena la tabla temporal delegando la ejecucion al EjecutorDeConsultasDeListados  --------------------------------- */
	declare @SQLDinamico nvarchar(max) = 'insert into ' +  @TempTablaDeExportacion + ' exec [Listados].[EjecutorDeConsultasDeListados] @ListaDeBases1, @ListaSelect1, @FuncionListado1, @ListaParametros1, @CamposGroupBy1, @ClausulaHaving1, @FiltroSobreResultados1, @CamposOrderBy1, @ModoDebug1';  
	declare @ListaDeParametros nvarchar(max) = '@ListaDeBases1 varchar(max), @ListaSelect1 varchar(max), @FuncionListado1 varchar(max), @ListaParametros1 varchar(max), @CamposGroupBy1 varchar(max), @ClausulaHaving1 varchar(max), @FiltroSobreResultados1 as varchar(max), @CamposOrderBy1 varchar(max), @ModoDebug1 int';    
	execute sp_executesql @SQLDinamico, @ListaDeParametros, @ListaDeBases1 = @ListaDeBases, @ListaSelect1 = @ListaSelect, @FuncionListado1 = @FuncionExportacion, @ListaParametros1 = @ListaParametros, @CamposGroupBy1  = '', @ClausulaHaving1 = '', @FiltroSobreResultados1 = '', @CamposOrderBy1 = '', @ModoDebug1 = 0;

	execute( 'select * from ' + @TempTablaDeExportacion )
	execute( 'drop table ' + @TempTablaDeExportacion )
end


