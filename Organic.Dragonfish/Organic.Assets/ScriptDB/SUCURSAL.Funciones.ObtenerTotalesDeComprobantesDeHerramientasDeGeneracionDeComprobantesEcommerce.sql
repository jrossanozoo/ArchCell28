IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerTotalesDeComprobantesDeHerramientasDeGeneracionDeComprobantesEcommerce]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerTotalesDeComprobantesDeHerramientasDeGeneracionDeComprobantesEcommerce];
GO;


create FUNCTION [Funciones].[ObtenerTotalesDeComprobantesDeHerramientasDeGeneracionDeComprobantesEcommerce]
	( 
	@CodigoNumeroComprobante char(10),
	@TipoMonto int
	)
RETURNS numeric(17, 4)
AS
BEGIN
	declare @retorno numeric(17, 4);
	declare @Cantidad numeric(15,2);
	declare @Monto numeric(17,4);

	select @Cantidad = sum( det.CANT ), @Monto = sum( det.MONTO ) 
	from ZooLogic.ECCOMPDET as det
	inner join ZooLogic.COMPECOM hgce on hgce.NUMERO = det.NUMERO
	where det.NUMERO = @CodigoNumeroComprobante

	set @retorno = coalesce( case @TipoMonto when 1 then @Cantidad else @Monto end, 0 )
			
	return @retorno
END


