IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[EsComprobanteNotaDeCredito]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[EsComprobanteNotaDeCredito];
GO;

CREATE FUNCTION [Funciones].[EsComprobanteNotaDeCredito]( @TIPOCOMPROBANTE numeric(2,0) )
returns bit
begin
	declare @llNotaCredito bit

	if @TIPOCOMPROBANTE in ( 3, 5, 28, 35, 48 )
		set @llNotaCredito = 1
	else
		set @llNotaCredito = 0
	
	return @llNotaCredito
end
