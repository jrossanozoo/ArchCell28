IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerStockAControlarParaUnaDiferenciaDeInventario]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerStockAControlarParaUnaDiferenciaDeInventario];
GO;

CREATE FUNCTION [Funciones].[ObtenerStockAControlarParaUnaDiferenciaDeInventario]
	( 
	@Codigo	numeric(8),
	@CodigoArticulo char(15),
	@CodigoColor char(6), 
	@CodigoTalle char(5)
	)
RETURNS numeric(16,3)
AS
BEGIN
	declare @retorno numeric(16, 3)

	set @retorno = ( 

					select sum([CANTI]) as canti
					from [ZooLogic].[TIINVCONT] as Cabecera
					inner join [ZooLogic].[TIINVCONDET] as Detalle on Cabecera.CODIGO = Detalle.IDCABECERA 
					where Cabecera.[CODIGO] = @Codigo  and  Detalle.MART = @CodigoArticulo  and  Detalle.CCOLOR = @CodigoColor and  Detalle.TALLE = @CodigoTalle 
					group by Detalle.[CODIGO] , Detalle.[MART] ,  Detalle.[CCOLOR] , Detalle.[talle]

					)
	
	if @retorno is null set @retorno = 0
		
	return @retorno
END
