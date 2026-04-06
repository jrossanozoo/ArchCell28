IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerNombreDeComprobanteDeVentas]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerNombreDeComprobanteDeVentas];
GO;

CREATE FUNCTION [Funciones].[ObtenerNombreDeComprobanteDeVentas]
( @TipoDeComprobante int )
RETURNS varchar (254)
AS
BEGIN
declare @retorno varchar (254)
set @retorno =
case @TipoDeComprobante
	when 1 then 'Factura'
	when 3 then 'Nota De Crédito'
	when 4 then 'Nota De Débito'
	when 96 then 'Ajuste de Caja'
	when 98 then 'Comprobante de caja'
	when 99 then 'Apertura de Caja'
	else '[' + CONVERT(VARCHAR(19), @TipoDeComprobante) + '] Comprobante Desconocido'
end
return @retorno

END