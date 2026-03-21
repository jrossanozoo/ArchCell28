IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[AgregarAliasALaClausulaOrderBy]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[AgregarAliasALaClausulaOrderBy];
GO;

CREATE FUNCTION [Funciones].[AgregarAliasALaClausulaOrderBy]
	(
	@ClausulaOrderBy varchar(max), -- Puede tener expresiones de fecha para los agrupamientos anual, semestral, ..., semanal
	@Alias varchar(30)
	)     
returns varchar(max)     
as     
begin
	declare @OrderByAuxiliar varchar(max)
	declare @ListaDeCampos TABLE (Campo varchar(max), IdRegistro int)
	declare @Registros int;
	declare @Campo varchar(1000);

	set @OrderByAuxiliar = replace( replace( replace( lower( @ClausulaOrderBy ), ' asc ', '' ), ' desc ', '' ), ')', '' )

	insert into @ListaDeCampos
	select campos.Item, Row_Number() over (order by campos.Item)
	from ( select distinct item from Funciones.DividirLaCadenaPorElCaracterDelimitador( @OrderByAuxiliar, ',' ) ) as campos
	where ( charindex( '(', campos.Item ) = 0 ) and ( isnumeric( campos.Item ) != 1 );

	set @Registros = @@ROWCOUNT;
	set @OrderByAuxiliar = @ClausulaOrderBy;
	while @Registros > 0
	begin
		select @Campo = Campo from @ListaDeCampos where IdRegistro = @Registros;

		set @OrderByAuxiliar = replace( @OrderByAuxiliar, ' '+@Campo, ' '+@Alias + '.' + @Campo );
		
		set @Registros = @Registros - 1;
	end;

	while charindex( @Alias + '.' + @Alias,  @OrderByAuxiliar, 1 ) > 0
		set @OrderByAuxiliar = replace( @OrderByAuxiliar, @Alias + '.' + @Alias, @Alias );

	return @OrderByAuxiliar   
end
