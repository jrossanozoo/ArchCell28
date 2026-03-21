IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[EsComprobanteElectronico]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[EsComprobanteElectronico];
GO;

CREATE FUNCTION [Funciones].[EsComprobanteElectronico]( @TIPOCOMPROBANTE numeric(2,0) )
returns bit
begin
	declare @llElectronico bit

	if @TIPOCOMPROBANTE in ( 27, 28, 29, 33, 35, 36 )
		set @llElectronico = 1
	else
		set @llElectronico = 0
	
	return @llElectronico
end
