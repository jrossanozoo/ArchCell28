IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[EliminarExpresionesDeLaClausulaHaving]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[EliminarExpresionesDeLaClausulaHaving];
GO;

CREATE FUNCTION [Funciones].[EliminarExpresionesDeLaClausulaHaving]
	(
	@ClausulaHaving varchar(max)
	)     
returns varchar(max)     
as     
begin
	declare @HavingAuxiliar varchar(max)
	declare @CamposDelHaving varchar(max);
	declare @ListaDeCampos TABLE (Campo varchar(max), IdRegistro int)
	declare @Registros int;
	declare @Campo varchar(max);
	declare @CampoSinExpresion varchar(max);

	set @HavingAuxiliar = lower( @ClausulaHaving )

	set @CamposDelHaving = Funciones.ObtenerListaDeCamposDeLaClausulaHaving( @HavingAuxiliar );
	set @CamposDelHaving = right( @CamposDelHaving, len( @CamposDelHaving ) - 2 );

	insert into @ListaDeCampos
	select campos.Item, Row_Number() over (order by campos.Item)
	from ( select distinct item from Funciones.DividirLaCadenaPorElCaracterDelimitador( @CamposDelHaving, ',' ) ) as campos;

	set @Registros = @@ROWCOUNT;

	while @Registros > 0
	begin
		select @Campo = Campo from @ListaDeCampos where IdRegistro = @Registros;

		set @CampoSinExpresion = Funciones.EliminarExpresionesDeLaListaDeCampos( @Campo );

		set @HavingAuxiliar = replace( @HavingAuxiliar, @Campo, @CampoSinExpresion );

		set @Registros = @Registros - 1;
	end;

	return @HavingAuxiliar   
end
