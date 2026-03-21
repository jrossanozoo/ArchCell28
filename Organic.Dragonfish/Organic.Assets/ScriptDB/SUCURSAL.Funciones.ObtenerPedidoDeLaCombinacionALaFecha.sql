IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerPedidoDeLaCombinacionALaFecha]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerPedidoDeLaCombinacionALaFecha];
GO;

CREATE FUNCTION [Funciones].[ObtenerPedidoDeLaCombinacionALaFecha]
	(
	@Articulo char(15),
	@Color char(6),
	@Talle char(5),
	@Fecha datetime
	)
RETURNS numeric(15,2)
AS
BEGIN
	declare @retorno numeric(15, 2)

	set @Color = rtrim( @Color )
	set @Talle = rtrim( @Talle )
			
	set @retorno =	(select top 1 
						cast( c_COMB.PEDIDO - case when c_ADT_COMB.pedido  is null then 0 else c_ADT_COMB.pedido end as numeric(15, 2) ) as Cantidad
					from ZooLogic.COMB as c_COMB
						left join 
							( 
								select 
									COCOD, 
									sum(pedido) as pedido
								from ZooLogic.ADT_COMB 
								where ADT_EXT = 0 and (ADT_FECHA)> @Fecha
								--	and Funciones.ObtenerFechaDelComprobanteDeOrigenDelRegistroDeAuditoria( ADT_COMP, ADT_FECHA ) > @Fecha
								group by COCOD 
							) as c_ADT_COMB on 
							c_COMB.COCOD = c_ADT_COMB.COCOD
					 where ( c_COMB.COART = @Articulo ) 		-- El artículo no puede ser nulo.
						and ( ( @Color is null ) OR ( c_COMB.COCOL = @Color ) ) 
						and ( ( @Talle is null ) OR ( c_COMB.Talle = @Talle ) )
					order by c_COMB.COART, c_COMB.COCOL, c_COMB.Talle

		)
	return @retorno
END
	