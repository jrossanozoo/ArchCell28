IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[EliminarExpresionesDeLaListaDeCampos]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[EliminarExpresionesDeLaListaDeCampos];
GO;

CREATE FUNCTION [Funciones].[EliminarExpresionesDeLaListaDeCampos]
	( 
	@ClausulaSelect varchar(max)
	)
returns varchar(max)
AS
begin
	declare @InicioExpresion int;
	declare @PosicionAS int;
	declare @PosicionComa int;
	declare @DesecharHasta int;
	declare @ListaDeCampos varchar(max);
	declare @Aux varchar(max);
	declare @Campo varchar(1000);
	
	set @Aux = ltrim( rtrim( lower( @ClausulaSelect ) ) );
	if rtrim( left( @Aux, 4 ) ) = 'top'		/* si la lista de campos comienza con top ### campo1, campo2, ... se quita le calusula top ### */
		begin
			set @DesecharHasta = 4 + charindex( ' ', substring( @Aux, 4 + 1, len( @Aux ) ) );
			set @Aux = substring( @Aux, @DesecharHasta + 1, len( @Aux ) );
		end
	
	set @ListaDeCampos = '';
	
	while len( @Aux ) > 0
	begin
		set @InicioExpresion = charindex( '(', @Aux )
		if @InicioExpresion = 0 set @InicioExpresion = len( @Aux );

		set @PosicionAS = charindex( ' as ', @Aux )
		if @PosicionAS = 0 set @PosicionAS = len( @Aux );

		set @PosicionComa = charindex( ',', @Aux )
		if @PosicionComa = 0 set @PosicionComa = len( @Aux );
		
		if @PosicionComa < @InicioExpresion
			begin
				set @Campo = left( @Aux, @PosicionComa - 1);
				set @DesecharHasta = @PosicionComa + 1;
			end
		else
			if @PosicionComa < @PosicionAS
				begin
					set @Campo = '';
					set @DesecharHasta = @PosicionAS + 3;
				end
			else
				if  ( @PosicionComa > @PosicionAS ) and ( @PosicionAS < len( @Aux ) )
					begin
						set @Campo = '';
						set @DesecharHasta = @PosicionAS + 3;
					end
				else
					begin
						set @Campo = @Aux;
						set @DesecharHasta = len( @Aux );
					end;
		
		if len( @Campo ) > 0 set @ListaDeCampos = @ListaDeCampos + ', ' + @Campo;
		
		if len( @Aux ) > @DesecharHasta
			set @Aux = rtrim( ltrim( right( @Aux, len( @Aux ) - @DesecharHasta ) ) )
		else
			set @Aux = '';
	end;
	
	set @ListaDeCampos = replace( @ListaDeCampos, ' ,', ', ' );
	set @ListaDeCampos = replace( @ListaDeCampos, '  ', ' ');
	
	return right( @ListaDeCampos, len( @ListaDeCampos ) - 2 )
end
