IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerClausulaJoinParaListadosAgrupados]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerClausulaJoinParaListadosAgrupados];
GO;

CREATE FUNCTION [Funciones].[ObtenerClausulaJoinParaListadosAgrupados]
	( 
	@ListaDeCampos varchar(max),
	@Alias1 varchar(50),
	@Alias2 varchar(50)
	)
returns varchar(max)
AS
begin
	declare @ClausulaJoin varchar(max);
	
	select @ClausulaJoin = stuff(
				(
				select
					'( ' + @Alias1 + '.' + Funciones.Alltrim(Item) + ' = ' +  @Alias2 + '.' + Funciones.Alltrim(Item) + ' or ( ' + @Alias1 + '.' + Funciones.Alltrim(Item) + ' is null and '  + @Alias2 + '.' + Funciones.Alltrim(Item) + ' is null ) ) and '
				from Funciones.DividirLaCadenaPorElCaracterDelimitador(@ListaDeCampos,',')
				for  xml path('')
				)
			, 1, 0, '')

	return left( @ClausulaJoin, len(@ClausulaJoin) - 4 )
end
