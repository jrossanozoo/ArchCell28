IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[EsComprobanteConRecargoCI]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[EsComprobanteConRecargoCI];
GO;

CREATE FUNCTION [Funciones].[EsComprobanteConRecargoCI]( @TIPOCOMPROBANTE numeric(2,0) )
returns bit
begin
	declare @llRecargoCI bit

	if @TIPOCOMPROBANTE in ( 1, 27, 33, 35, 36, 47, 48, 49 )
		set @llRecargoCI = 1
	else
		set @llRecargoCI = 0
	
	return @llRecargoCI
end
