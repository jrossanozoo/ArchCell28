IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerStockDeLaCombinacionALaFecha]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerStockDeLaCombinacionALaFecha];
GO;

CREATE FUNCTION [Funciones].[ObtenerStockDeLaCombinacionALaFecha]
	(
	@Articulo char(15),
	@Color char(6),
	@Talle char(5),
	@Fecha datetime
	)
RETURNS numeric(16,3)
AS
BEGIN
	declare @retorno numeric(16, 3)

	set @Color = rtrim( @Color )
	set @Talle = rtrim( @Talle )
			
	set @retorno =	(select top 1
						cast( c_COMB.COCANT - case when c_ADT_COMB.COCANT is null then 0 else c_ADT_COMB.COCANT end as numeric(16, 3) ) as Cantidad
					from ZooLogic.COMB as c_COMB
						left join 
							( 
								select 
									COCOD, 
									sum(COCANT) as COCANT 
								from ZooLogic.ADT_COMB 
								where ADT_EXT = 0
									and Funciones.ObtenerFechaDelComprobanteDeOrigenDelRegistroDeAuditoria( ADT_COMP, ADT_FECHA ) > @Fecha
								group by COCOD 
							) as c_ADT_COMB on c_COMB.COCOD = c_ADT_COMB.COCOD
					 where ( c_COMB.COART = @Articulo ) 		-- El artículo no puede ser nulo.
						and ( ( @Color is null ) OR ( c_COMB.COCOL = @Color ) ) 
						and ( ( @Talle is null ) OR ( c_COMB.Talle = @Talle ) )
					order by c_COMB.COART, c_COMB.COCOL, c_COMB.Talle
					)
	return @retorno
END
	

	