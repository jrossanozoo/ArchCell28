IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerPrecioDeLaCombinacion]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerPrecioDeLaCombinacion];
GO;

CREATE FUNCTION [Funciones].[ObtenerPrecioDeLaCombinacion]
( @CodigoArticulo char(15),
  @CodigoColor char(6), 
  @CodigoTalle char(5),
  @NroListaDePrecio int )
RETURNS numeric(15,2)
AS
BEGIN
declare @retorno numeric(15,2)
set @retorno = ( select distinct Funciones.ObtenerPrecioDeLaCombinacionConVigencia( @CodigoArticulo, @CodigoColor,  @CodigoTalle, p.listapre, GETDATE(), default ) as Precio 
from ZooLogic.PRECIOAR p inner join ZooLogic.lprecio lp on lp.lpr_numero = p.listapre and lp.lordcons = @NroListaDePrecio  )
return @retorno

END


