IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerStockFisicoParaUnaDiferenciaDeInventario]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerStockFisicoParaUnaDiferenciaDeInventario];
GO;

CREATE FUNCTION [Funciones].[ObtenerStockFisicoParaUnaDiferenciaDeInventario]
	( 
	@Codigo numeric(8),
	@CodigoArticulo char(15),
	@CodigoColor char(6), 
	@CodigoTalle char(5)
	)
RETURNS numeric(16,3)
AS
BEGIN
	declare @retorno numeric(16, 3)

	set @retorno = (
					select sum(Detalle.[CANTI]) as canti
					from [ZooLogic].[TIItemDifInv] as Diferencia
					inner join [ZooLogic].[TIINVFIS] as Cabecera on Diferencia.IDINVFIS = Cabecera.CODIGO 
					inner join [ZooLogic].[TIINVFISDET] as Detalle on Cabecera.CODIGO = Detalle.IDCABECERA 
					where (Diferencia.[CODIGO] = @Codigo and (Detalle.ART = @CodigoArticulo ) and (( @CodigoColor is null) or  Detalle.CCOLOR = @CodigoColor ) and (( @CodigoTalle is null) or Detalle.TALLE = @CodigoTalle ))
					group by Detalle.[ART] ,  Detalle.[CCOLOR] , Detalle.[talle]
					)
	
	if @retorno is null set @retorno = 0
		
	return @retorno
END
