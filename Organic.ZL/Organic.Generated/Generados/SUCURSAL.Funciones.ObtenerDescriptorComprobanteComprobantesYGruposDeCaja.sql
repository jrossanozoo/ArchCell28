IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerDescriptorComprobanteComprobantesYGruposDeCaja]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerDescriptorComprobanteComprobantesYGruposDeCaja];
GO;

CREATE FUNCTION [Funciones].[ObtenerDescriptorComprobanteComprobantesYGruposDeCaja]
( @TipoDeComprobante varchar(2) )
RETURNS varchar (50)
AS
BEGIN
declare @retorno varchar (50)
set @retorno = 
case @TipoDeComprobante
	 when '00' then 'Facturas A'
	 when '01' then 'Facturas B'
	 when '23' then 'Facturas C'
	 when '02' then 'Notas de crédito A'
	 when '03' then 'Notas de crédito B'
	 when '24' then 'Notas de crédito C'
	 when '04' then 'Notas de débito A'
	 when '05' then 'Notas de débito B'
	 when '25' then 'Notas de débito C'
	 when '07' then 'Ticket Factura A'
	 when '08' then 'Ticket Factura B'
	 when '26' then 'Ticket Factura C'
	 when '09' then 'Ticket Notas de crédito A'
	 when '10' then 'Ticket Notas de crédito B'
	 when '27' then 'Ticket Notas de crédito C'
	 when '11' then 'Ticket Notas de débito A'
	 when '12' then 'Ticket Notas de débito B'
	 when '28' then 'Ticket Notas de débito C'
	 when '13' then 'Recibos X'
	 when '06' then 'Comprobantes de caja'
	 when '99' then 'Apertura de Caja'
	 when '50' then 'Facturas de Compra A'
	 when '51' then 'Facturas de Compra B'
	 when '52' then 'Facturas de Compra C'
	 when '70' then 'Facturas de Compra M'
	 when '63' then 'Notas de débito Compra A'
	 when '64' then 'Notas de débito Compra B'
	 when '65' then 'Notas de débito Compra C'
	 when '71' then 'Notas de débito Compra M'
	 when '66' then 'Notas de crédito Compra A'
	 when '67' then 'Notas de crédito Compra B'
	 when '68' then 'Notas de crédito Compra C'
	 when '72' then 'Notas de crédito Compra M'
	 when '53' then 'Facturas Electrónicas A'
	 when '54' then 'Facturas Electrónicas B'
	 when '55' then 'Facturas Electrónicas C'
	 when '56' then 'Notas de crédito Electrónicas A'
	 when '57' then 'Notas de crédito Electrónicas B'
	 when '58' then 'Notas de crédito Electrónicas C'
	 when '59' then 'Notas de débito Electrónicas A'
	 when '60' then 'Notas de débito Electrónicas B'
	 when '61' then 'Notas de débito Electrónicas C'
	 when '62' then 'Orden de pago'
	 when '97' then 'Canje de cupones'
	 when '76' then 'Facturas Electrónicas Exportación'
	 when '77' then 'Notas de crédito Electrónicas Exportación'
	 when '78' then 'Notas de crédito Electrónicas Exportación'
	else ''
end
return @retorno
END