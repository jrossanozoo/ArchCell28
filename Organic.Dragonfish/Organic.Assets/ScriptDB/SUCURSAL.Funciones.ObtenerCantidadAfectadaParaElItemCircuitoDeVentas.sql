IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerCantidadAfectadaParaElItemCircuitoDeVentas]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[ObtenerCantidadAfectadaParaElItemCircuitoDeVentas];
GO;

CREATE FUNCTION [Funciones].[ObtenerCantidadAfectadaParaElItemCircuitoDeVentas]
( @CodigoComprobanteAfectado varchar(38),
  @IdItem varchar(38),
  @FiltroConjunto int )
  
RETURNS numeric(16,3)
AS
BEGIN
declare @retorno numeric(16,3)
set @retorno = ( select sum( DetalleAfectantes.Afecant ) as cantidad
				from ZooLogic.ComprobantevDet as DetalleAfectantes
				inner join ZooLogic.CompAfe as Afectantes on DetalleAfectantes.Codigo = Afectantes.Afecta
				inner join ZooLogic.Comprobantev as Cabecera on Afectantes.Codigo = Cabecera.Codigo
				where Afectantes.Codigo = @CodigoComprobanteAfectado
				and ((Cabecera.ENTREGAPOS = 1 and Afectantes.Afetipo = 'Afectado' and @FiltroConjunto = 3) or (Afectantes.Afetipo = 'Afectante')) --Se agregó la opcion para que tome las facturas con entrega posterior
				and (	( @FiltroConjunto = 0 and Afectantes.AfetipoCom =  12 )  -- Cancelación de ventas. 
					 or ( @FiltroConjunto = 1 and Afectantes.AfetipoCom =  23)   -- Pedido.
					 or ( @FiltroConjunto = 2 and Afectantes.AfetipoCom =  11 )  -- Remito.
					 or ( @FiltroConjunto = 3 and Afectantes.AfetipoCom in ( 1, 2, 27, 33, 47, 54 ) )  --factura,ticketfactura,devolucion,facturaelectronica,facturaelectronicaexportacion,facturadeexportacion,facturaelectronicaMiPyme.
					 or ( @FiltroConjunto = 4 and Afectantes.AfetipoCom in ( 3, 5, 28, 34, 48, 55 ) ) ) -- Nota de credito (Manual, Fiscal, Electronica, Exportacion, Electronica de exportacion, Electronica MiPyme)
				and DetalleAfectantes.idItem = @IdItem 
			   )
return isnull( @retorno, 0 )

END
