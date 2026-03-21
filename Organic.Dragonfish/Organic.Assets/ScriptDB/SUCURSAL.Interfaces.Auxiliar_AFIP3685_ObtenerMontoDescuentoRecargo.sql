IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Auxiliar_AFIP3685_ObtenerMontoDescuentoRecargo]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Auxiliar_AFIP3685_ObtenerMontoDescuentoRecargo];
GO;

CREATE FUNCTION [Interfaces].[Auxiliar_AFIP3685_ObtenerMontoDescuentoRecargo]
( 
	@TipoComprobante numeric(2,0),
	@Letra char(1),
	@Subtotal numeric(15,4),
	@RecargosConImpuestos numeric(15,2),
	@Recargos numeric(15,2),
	@Descuentos numeric(15,2),
	@PorcentajeIVA numeric(6,2),
	@MontoNoGravado numeric(17,4)
)
returns numeric(15,4)
begin
	declare @lnMontoDescuentoRecargo numeric(15,4)
	declare @lnTotalRecargo numeric(15,2)
	declare @lnMontoNeto numeric(15,4)
	
	set @lnTotalRecargo = ( case when Funciones.EsComprobanteConRecargoCI( @TipoComprobante ) = 1 then @RecargosConImpuestos else @Recargos end ) - @Descuentos
	if @Subtotal = 0
		set @lnMontoNeto = abs( @lnTotalRecargo )
	else
		set @lnMontoNeto = abs( ( case when @MontoNoGravado is null then 0 else @MontoNoGravado end ) * ( @lnTotalRecargo / @Subtotal ) )
	if @Letra = 'A'
		set @lnMontoDescuentoRecargo = @lnMontoNeto / ( 1 + ( ( case when @PorcentajeIVA is null then 0 else @PorcentajeIVA end ) / 100 ) )
	else
		set @lnMontoDescuentoRecargo = @lnMontoNeto

	return @lnMontoDescuentoRecargo
end