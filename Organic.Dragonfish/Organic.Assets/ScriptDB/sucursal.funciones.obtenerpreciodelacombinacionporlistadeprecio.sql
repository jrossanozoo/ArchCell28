IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerPrecioDeLaCombinacionPorListaDePrecio]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerPrecioDeLaCombinacionPorListaDePrecio];
GO;

CREATE FUNCTION [Funciones].[ObtenerPrecioDeLaCombinacionPorListaDePrecio]
( @CodigoArticulo char(15),
  @CodigoColor char(6), 
  @CodigoTalle char(5),
  @CodigoLPrecio char(6) )
RETURNS numeric(15,2)
AS
BEGIN
declare @retorno numeric(15,2)
set @retorno = ( select Funciones.ObtenerPrecioDeLaCombinacionConVigencia( @CodigoArticulo, @CodigoColor, @CodigoTalle, @CodigoLPrecio, GETDATE(), default ) )
return @retorno
END
