IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerMontoNegativoConPadlSinComa]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[ObtenerMontoNegativoConPadlSinComa];
GO;

CREATE FUNCTION [Funciones].[ObtenerMontoNegativoConPadlSinComa]( @MONTO numeric(30,10), @DECIMALES int, @LONGITUD int )
returns varchar(31)
begin
	declare @lnPosicionComa int
	declare @lcMontoEntero varchar(31)
	declare @lcMontoPadl varchar(31)
	declare @lcMontoGuion varchar(31)

	set @lcMontoEntero = cast( round( @MONTO, @DECIMALES ) * power( 10, @DECIMALES ) as varchar(31) )
	set @lnPosicionComa = charindex( '.', @lcMontoEntero )
	if @lnPosicionComa > 0
		set @lcMontoEntero = left( @lcMontoEntero, @lnPosicionComa - 1 )
		
	set @lcMontoPadl = Funciones.padl( @lcMontoEntero, @LONGITUD, '0' )
	
	if charindex( '-', @lcMontoPadl ) > 0 
		set @lcMontoGuion = '-' + stuff( @lcMontoPadl, charindex( '-', @lcMontoPadl ), 1, '' )
	else
		set @lcMontoGuion = @lcMontoPadl
	
	return @lcMontoGuion
end
