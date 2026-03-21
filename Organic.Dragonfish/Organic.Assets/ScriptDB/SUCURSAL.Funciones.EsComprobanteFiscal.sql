IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[EsComprobanteFiscal]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[EsComprobanteFiscal];
GO;

CREATE FUNCTION [Funciones].[EsComprobanteFiscal]( @TIPOCOMPROBANTE numeric(2,0) )
returns bit
begin
	declare @llComprobanteFiscal bit

	if @TIPOCOMPROBANTE in ( 2, 5, 6 )
		set @llComprobanteFiscal = 1
	else
		set @llComprobanteFiscal = 0
	
	return @llComprobanteFiscal
end
