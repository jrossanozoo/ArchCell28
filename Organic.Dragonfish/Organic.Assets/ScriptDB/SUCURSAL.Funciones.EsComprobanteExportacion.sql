IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[EsComprobanteExportacion]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[EsComprobanteExportacion];
GO;

CREATE FUNCTION [Funciones].[EsComprobanteExportacion]( @TIPOCOMPROBANTE numeric(2,0) )
returns bit
begin
	declare @llExportacion bit

	if @TIPOCOMPROBANTE in ( 33, 35, 36, 47, 48, 49 )
		set @llExportacion = 1
	else
		set @llExportacion = 0
	
	return @llExportacion
end
