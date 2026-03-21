IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerStockEnTransitoDeLaCombinacion]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerStockEnTransitoDeLaCombinacion];
GO;

CREATE FUNCTION [Funciones].[ObtenerStockEnTransitoDeLaCombinacion]
	(
	@Articulo char(15),
	@Color char(6),
	@Talle char(5)
	)
RETURNS numeric(15,2)
AS
BEGIN

	declare @retorno numeric(15, 2)
	
	set @Color = nullif( rtrim( @Color ), '' )
	set @Talle = nullif( rtrim( @Talle ), '' )
		
	set @retorno = ( 
					
					select top 1 c_COMB.ENTRANSITO
					from ZooLogic.COMB as c_COMB
					where c_COMB.COART = @Articulo 
						and ( ( @Color is null ) OR ( c_COMB.COCOL = @Color ) ) 
						and ( ( @Talle is null ) OR ( c_COMB.Talle = @Talle ) )
					order by c_COMB.COART, c_COMB.COCOL, c_COMB.Talle

					)
	return @retorno

END	