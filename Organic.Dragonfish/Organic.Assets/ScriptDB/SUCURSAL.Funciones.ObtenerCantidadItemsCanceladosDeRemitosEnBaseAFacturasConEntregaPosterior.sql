IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerCantidadItemsCanceladosDeRemitosEnBaseAFacturasConEntregaPosterior]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[ObtenerCantidadItemsCanceladosDeRemitosEnBaseAFacturasConEntregaPosterior];
GO;

CREATE FUNCTION [Funciones].[ObtenerCantidadItemsCanceladosDeRemitosEnBaseAFacturasConEntregaPosterior]
( @CodigoComprobanteAfectado varchar(38),
  @IdItem varchar(38) )
  
RETURNS numeric(15,2)
AS
BEGIN
declare @retorno numeric(15,2)

set @retorno = ( select sum([Funciones].[ObtenerCantidadAfectadaParaElItemCircuitoDeVentas](AFECTA, @IdItem, 0)) as Cantidad 
				 from zoologic.COMPAFE
				 where codigo = @CodigoComprobanteAfectado and AFETIPOCOM = 11 )

return isnull( @retorno, 0 )

END
