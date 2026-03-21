IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerListaDeCamposDeLaClausulaHaving]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerListaDeCamposDeLaClausulaHaving];
GO;

CREATE FUNCTION [Funciones].[ObtenerListaDeCamposDeLaClausulaHaving]
	( 
	@ClausulaHaving varchar(max)
	)
returns varchar(max)
AS
begin
	declare @ListaDeCampos varchar(max);
	declare @PosicionParentesisApertura int;
	declare @PosicionParentesisCierre int;
	declare @PosicionOperadorLogico int;
	declare @PosicionIgual int;
	declare @PosicionMayor int;
	declare @PosicionMenor int;
	declare @PosicionOperadorComparacion int;
	declare @Campo varchar(1000);
	declare @Aux varchar(max);

	set @Aux = lower( @ClausulaHaving );
	set @ListaDeCampos = ''
	while ( len( @Aux ) > 0 )
	begin
		set @PosicionOperadorLogico = charindex( 'and', @Aux );		--actualmente solo se conforman expresiones con "and"
		if @PosicionOperadorLogico = 0 set @PosicionOperadorLogico = len( @Aux );

		set @PosicionIgual = charindex( '=', @Aux );
		if @PosicionIgual = 0 set @PosicionIgual = @PosicionOperadorLogico;
		
		set @PosicionMenor = charindex( '<', @Aux );
		if @PosicionMenor = 0 set @PosicionMenor = @PosicionOperadorLogico;
		
		set @PosicionMayor = charindex( '>', @Aux );
		if @PosicionMayor = 0 set @PosicionMayor = @PosicionOperadorLogico;
		
		select @PosicionOperadorComparacion = min( posiciones.posicion ) from ( select @PosicionIgual as posicion union select @PosicionMenor union select @PosicionMayor ) as posiciones

		set @PosicionParentesisApertura = charindex( '(', @Aux );
		set @PosicionParentesisCierre = @PosicionOperadorComparacion - 1;

		if @PosicionParentesisApertura > 0
			begin 
				set @PosicionParentesisApertura = @PosicionParentesisApertura + 1;

				while substring( @Aux, @PosicionParentesisCierre, 1) != ')' and @PosicionParentesisCierre > @PosicionParentesisApertura
					set @PosicionParentesisCierre = @PosicionParentesisCierre - 1;			
			end;

		set @Campo = ', ' + rtrim( ltrim( substring( @Aux, @PosicionParentesisApertura, @PosicionParentesisCierre - @PosicionParentesisApertura ) ) );

		if charindex( @Campo, @ListaDeCampos ) = 0 set @ListaDeCampos = @ListaDeCampos + @Campo;

		set @PosicionOperadorLogico = @PosicionOperadorLogico + len( 'and' );
		if ( len( @Aux ) > @PosicionOperadorLogico ) and ( charindex( '(', @Aux, @PosicionOperadorLogico ) > 0 )
			set @Aux = ltrim( right( @Aux, len( @Aux ) - @PosicionOperadorLogico ) )
		else
			set @Aux = '';
	end;

	return @ListaDeCampos
end
