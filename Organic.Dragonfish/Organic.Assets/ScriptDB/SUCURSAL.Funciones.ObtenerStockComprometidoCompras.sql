IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerStockComprometidoCompras]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerStockComprometidoCompras];
GO;

CREATE FUNCTION [Funciones].[ObtenerStockComprometidoCompras]
	( 
	@CodigoArticulo char(15),
	@CodigoColor char(6), 
	@CodigoTalle char(5)
	)
RETURNS numeric(16,3)
AS
BEGIN
	declare @retorno numeric(16, 3)

	set @retorno = ( 
					select sum( det.AFESALDO ) 
					from Zoologic.PEDCOMPRADET as det
					where exists
								(
								select 1 from ZooLogic.PEDCOMPRA as cab 
								where cab.FACTTIPO = 38 and cab.CODIGO = det.CODIGO
								)
						and ( ( @CodigoArticulo is null ) OR ( det.FART = @CodigoArticulo ) )
						and ( ( @CodigoColor is null ) OR ( det.FCOLO = @CodigoColor ) )
						and ( ( @CodigoTalle is null ) OR ( det.FTALL = @CodigoTalle ) )
					group by det.FART, det.FCOLO, det.FTALL
					)
	
	if @retorno is null set @retorno = 0
		
	return @retorno
END