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
	when 1 then 'Factura Manual De Venta'
	when 2 then 'Factura Fiscal De Venta'
	when 3 then 'Nota De Crédito Manual De Venta'
	when 4 then 'Nota De Débito Manual De Venta'
	when 5 then 'Nota De Crédito Fiscal De Venta'
	when 6 then 'Nota De Débito Fiscal De Venta'
	when 8 then 'Factura De Compra'
	when 9 then 'Nota De Débito De Compra'
	when 10 then 'Nota De Crédito De Compra'
	when 11 then 'Remito De Venta'
	when 12 then 'Cancelación De Venta'
	when 13 then 'Recibo'
	when 23 then 'Pedido De Venta'
	when 25 then 'Presupuesto De Venta'
	when 27 then 'Factura Electrónica De Venta'
	when 28 then 'Nota De Crédito Electrónica De Venta'
	when 29 then 'Nota De Débito Electrónica De Venta'
	when 30 then 'Presupuesto De Compra'
	when 31 then 'Orden De Pago'
	when 32 then 'Canje De Valores'
	when 33 then 'Factura Electrónica Exportación De Venta'
	when 35 then 'Nota De Crédito Electrónica Exportación De Venta'
	when 36 then 'Nota De Débito Electrónica Exportación De Venta'
	when 37 then 'Pago'
	when 38 then 'Pedido De Compra'
	when 39 then 'Solicitud De Compra'
	when 40 then 'Remito De Compra'
	when 41 then 'Cancelación De Compra'
	when 42 then 'Requerimiento De Compra'
	when 43 then 'Ajuste De Cuenta Corriente De Clientes'
	when 44 then 'Ajuste De Cuenta Corriente De Proveedores'
	when 45 then 'Cancelación De Señas'
	when 46 then 'Descarga De Cheques De Terceros'
	when 47 then 'Factura De Exportación De Venta'
	when 48 then 'Nota De Crédito De Exportación De Venta'
	when 49 then 'Nota De Débito De Exportación De Venta'
	when 50 then 'Otros Pagos'
	when 51 then 'Factura'
	when 52 then 'Nota De Crédito'
	when 53 then 'Nota De Débito'
	when 54 then 'Factura De Crédito Electrónica Mipyme De Venta'
	when 55 then 'Nota De Crédito Electrónica Mipyme De Venta'
	when 56 then 'Nota De Débito Electrónica Mipyme De Venta'
	when 57 then 'Preparación De Mercadería'
	when 58 then 'Seña'
	when 96 then 'Ajuste de Caja'
	when 98 then 'Comprobante de caja'
	when 99 then 'Apertura de Caja'
	else '[' + CONVERT(VARCHAR(19), @TipoDeComprobante) + '] Comprobante Desconocido'
end
return @retorno

END