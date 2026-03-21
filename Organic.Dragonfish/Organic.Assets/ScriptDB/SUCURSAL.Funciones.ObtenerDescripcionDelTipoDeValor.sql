IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerDescripcionDelTipoDeValor]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerDescripcionDelTipoDeValor];
GO;

CREATE FUNCTION [Funciones].[ObtenerDescripcionDelTipoDeValor]
( @TipoDeValor int,
  @TipoTarjeta varchar(1) )
RETURNS varchar (35)
AS
BEGIN
declare @retorno varchar(35)
set @retorno =
case @TipoDeValor
	when 1 then 'Moneda Local'
	when 2 then 'Moneda extranjera'
	when 3 then 'Tarjeta de ' + case when @TipoTarjeta = 'D' then 'débito' else 'crédito' end 
	when 4 then 'Cheque de Terceros (discontinuado)'
	when 5 then 'Pagaré'
	when 6 then 'Cuenta Corriente'
	when 7 then 'Ticket'
	when 8 then 'Vale de Cambio'
	when 9 then 'Cheque Propio (discontinuado)'
	when 10 then 'Ajuste de Cupones'
	when 11 then 'Pago Electrónico'
	when 12 then 'Cheque de Terceros'
	when 13 then 'Cuenta Bancaria'
	when 14 then 'Cheque propio'
	else 'Otros tipos'
end

return @retorno
END



