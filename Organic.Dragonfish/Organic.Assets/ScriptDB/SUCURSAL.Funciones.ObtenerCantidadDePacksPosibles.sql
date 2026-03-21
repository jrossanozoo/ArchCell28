IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerCantidadDePacksPosibles]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerCantidadDePacksPosibles];
GO;

CREATE FUNCTION [Funciones].[ObtenerCantidadDePacksPosibles]
( @CodigoPack varchar(15) )
RETURNS int
AS
BEGIN
declare @retorno int
set @retorno = ( SELECT top 1 cast( cocant / cant as int ) as CantPacksPosibles from ZooLogic.ART as articulo
							inner join ZooLogic.KITPARTDET as packs on ARTCOD = CODIGO
							inner join ZooLogic.COMB as stock on COART = IPPART and TALLE = IPTALLE and COCOL = IPCOLOR where ARTCOD = @CodigoPack
							order by CantPacksPosibles asc
							)
return isnull( @retorno, 0 )

END


