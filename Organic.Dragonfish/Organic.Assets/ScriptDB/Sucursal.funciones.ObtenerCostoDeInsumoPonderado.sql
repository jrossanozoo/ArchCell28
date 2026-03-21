IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerCostoDeInsumoPonderado]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerCostoDeInsumoPonderado];
GO;

CREATE FUNCTION [Funciones].[ObtenerCostoDeInsumoPonderado]
( @CodigoLista char(6),
  @CodigoInsumo char(25), 
  @CodigoProceso char(15), 
  @CodigoTaller char(15), 
  @CodigoColor char(6), 
  @CodigoTalle char(5),
  @Cantidad int)
RETURNS numeric(15,2)
AS
BEGIN
	declare @retorno numeric(15,2)

	declare @PonderadoProceso int
	declare @PonderadoTaller int
	declare @PonderadoColor int
	declare @PonderadoTalle int

	Set @PonderadoProceso = 1
	Set @PonderadoTaller = 2
	Set @PonderadoColor = 3
	Set @PonderadoTalle = 4

	Set @retorno = 
		isnull((Select TOP 1 cdirecto from zoologic.costoins 
		where listacost = @CodigoLista and Insumo = @CodigoInsumo 
		and cantidad <= @Cantidad 
		and ((proceso = @CodigoProceso or proceso = '') 
		and (taller = @CodigoTaller or taller = '')
		and (ccolor = @CodigoColor or ccolor = '')  
		and (talle = @CodigoTalle or talle = '')
		) 
		order by 
		iif(proceso != '',power(2,4-@PonderadoProceso),0) +
		iif(taller != '',power(2,4-@PonderadoTaller),0) + 
		iif(ccolor != '',power(2,4-@PonderadoColor),0) + 
		iif(talle != '',power(2,4-@PonderadoTalle),0)
		+ cantidad / 10000000 desc ),0)

return @retorno

END

