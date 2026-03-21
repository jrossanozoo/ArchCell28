IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Auxiliar_AFIP3685_ObtenerDescripcionDescuentoRecargo]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Auxiliar_AFIP3685_ObtenerDescripcionDescuentoRecargo];
GO;

CREATE FUNCTION [Interfaces].[Auxiliar_AFIP3685_ObtenerDescripcionDescuentoRecargo]
( 
	@TipoComprobante numeric(2,0),
	@RecargosConImpuestos numeric(15,2),
	@Recargos numeric(15,2),
	@Descuentos numeric(15,2)
)
returns varchar(75)
begin
	declare @lcDescripcion varchar(75)
	declare @lnTotalRecargo numeric(15,2)
	
	set @lnTotalRecargo = ( case when Funciones.EsComprobanteConRecargoCI( @TipoComprobante ) = 1 then @RecargosConImpuestos else @Recargos end ) - @Descuentos
	if Funciones.EsComprobanteNotaDeCredito( @TipoComprobante ) = 1
		begin
		if @lnTotalRecargo < 0
			set @lcDescripcion = 'RECARGO GENERAL'
		else
			set @lcDescripcion = 'DESCUENTO GENERAL'
		end
	else
		begin
		if @lnTotalRecargo > 0
			set @lcDescripcion = 'RECARGO GENERAL'
		else
			set @lcDescripcion = 'DESCUENTO GENERAL'
		end

	return @lcDescripcion
end