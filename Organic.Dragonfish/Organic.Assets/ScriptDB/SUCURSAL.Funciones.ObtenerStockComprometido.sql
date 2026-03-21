IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerStockComprometido]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerStockComprometido];
GO;

CREATE FUNCTION [Funciones].[ObtenerStockComprometido]
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
					from Zoologic.COMPROBANTEVDET as det
					where exists
								(
								select 1 from ZooLogic.COMPROBANTEV as cab 
								where cab.FACTTIPO = 23 and cab.CODIGO = det.CODIGO
								)
						and ( ( @CodigoArticulo is null ) OR ( det.FART = @CodigoArticulo ) )
						and ( ( @CodigoColor is null ) OR ( det.CCOLOR = @CodigoColor ) )
						and ( ( @CodigoTalle is null ) OR ( det.TALLE = @CodigoTalle ) )
					group by det.FART, det.CCOLOR, det.TALLE
					)
	
	if @retorno is null set @retorno = 0
		
	return @retorno
END
