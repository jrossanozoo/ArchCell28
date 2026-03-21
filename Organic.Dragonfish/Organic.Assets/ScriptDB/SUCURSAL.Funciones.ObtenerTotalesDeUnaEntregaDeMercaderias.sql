IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerTotalesDeUnaEntregaDeMercaderias]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerTotalesDeUnaEntregaDeMercaderias];
GO;

create FUNCTION [Funciones].[ObtenerTotalesDeUnaEntregaDeMercaderias]
	( 
	@CodigoEntregaDeMercaderias char(38),
	@TipoMonto int
	)
RETURNS numeric(17, 4)
AS
BEGIN
	declare @retorno numeric(17, 4);
	declare @Cantidad numeric(16,3);
	declare @Monto numeric(17,4);

	select @Cantidad = sum( rto.TOTALCANT ), @Monto = sum( rto.FTOTAL ) 
	from ZooLogic.ENTMERDET as det
	inner join ZooLogic.COMPROBANTEV rto on rto.CODIGO = det.COMPROB
	where det.CODIGO = @CodigoEntregaDeMercaderias

	set @retorno = coalesce( case @TipoMonto when 1 then @Cantidad else @Monto end, 0 )
			
	return @retorno
END