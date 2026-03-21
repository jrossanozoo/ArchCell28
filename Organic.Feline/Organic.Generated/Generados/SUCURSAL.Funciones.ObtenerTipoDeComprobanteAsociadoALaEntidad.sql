IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerTipoDeComprobanteAsociadoALaEntidad]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerTipoDeComprobanteAsociadoALaEntidad];
GO;

CREATE FUNCTION [Funciones].[ObtenerTipoDeComprobanteAsociadoALaEntidad]
( @Entidad varchar(40) )
RETURNS numeric(2,0)
AS
BEGIN
declare @retorno numeric(2,0)
set @retorno = 
case upper(@Entidad)
	when 'FACTURA' then 1
	when 'TICKETFACTURA' then 2
	when 'NOTADECREDITO' then 3
	when 'NOTADEDEBITO' then 4
	when 'TICKETNOTADECREDITO' then 5
	when 'TICKETNOTADEDEBITO' then 6
	when 'FACTURADECOMPRA' then 8
	when 'NOTADEDEBITOCOMPRA' then 9
	when 'NOTADECREDITOCOMPRA' then 10
	when 'REMITO' then 11
	when 'DEVOLUCION' then 12
	when 'RECIBO' then 13
	when 'PEDIDO' then 23
	when 'PRESUPUESTO' then 25
	when 'FACTURAELECTRONICA' then 27
	when 'NOTADECREDITOELECTRONICA' then 28
	when 'NOTADEDEBITOELECTRONICA' then 29
	when 'PRESUPUESTODECOMPRA' then 30
	when 'ORDENDEPAGO' then 31
	when 'CANJEDECUPONES' then 32
	when 'FACTURAELECTRONICAEXPORTACION' then 33
	when 'NOTADECREDITOELECTRONICAEXPORTACION' then 35
	when 'NOTADEDEBITOELECTRONICAEXPORTACION' then 36
	when 'PAGO' then 37
	when 'PEDIDODECOMPRA' then 38
	when 'SOLICITUDDECOMPRA' then 39
	when 'REQUERIMIENTODECOMPRA' then 40
	when 'REMITODECOMPRA' then 41
	when 'AJUSTECCPROVEEDOR' then 42
	when 'AJUSTECCCLIENTE' then 43
	when 'CANCELACIONDECOMPRA' then 44
	when 'CANCELACIONDESENIAS' then 45
	when 'DESCARGADECHEQUES' then 46
	when 'FACTURADEEXPORTACION' then 47
	when 'NOTADECREDITODEEXPORTACION' then 48
	when 'NOTADEDEBITODEEXPORTACION' then 49
	when 'COMPROBANTEPAGO' then 50
	when 'FACTURAAGRUPADA' then 51
	when 'NOTADECREDITOAGRUPADA' then 52
	when 'NOTADEDEBITOAGRUPADA' then 53
	when 'FACTURAELECTRONICADECREDITO' then 54
	when 'NOTADECREDITOELECTRONICADECREDITO' then 55
	when 'NOTADEDEBITOELECTRONICADECREDITO' then 56
	when 'PREPARACIONDEMERCADERIA' then 57
	when 'SENIA' then 58
	else 0
end
return @retorno

END