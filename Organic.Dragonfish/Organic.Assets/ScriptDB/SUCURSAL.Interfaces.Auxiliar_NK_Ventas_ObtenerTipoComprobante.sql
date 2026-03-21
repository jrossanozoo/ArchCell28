IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Auxiliar_NK_Ventas_ObtenerTipoComprobante]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Auxiliar_NK_Ventas_ObtenerTipoComprobante];
GO;

CREATE FUNCTION [Interfaces].[Auxiliar_NK_Ventas_ObtenerTipoComprobante]
(	
	@TipoComprobante int,
	@Letra char(1)	
)
returns varchar(max)     
as     
begin
	declare @equivTipo varchar(3)
	set @equivTipo = case @TipoComprobante
		when 1 then 'FC'	--FACTURA
		when 2 then 'TFC'	--TICKET FACTURA
		when 3 then 'NC'	--NOTA DE CREDITO
		when 4 then 'ND'	--NOTA DE DEBITO
		when 5 then 'TNC'	--TICKET NOTA DE CREDITO
		when 6 then 'TND'	--TICKET NOTA DE DEBITO
		when 27 then 'FCE'	--FACTURA ELECECTRONICA
		when 28 then 'NCE'	--NOTA DE CREDITO ELECTRONICA
		when 29 then 'NDE'	--NOTA DE DEBITO ELECTRONICA
		else cast(@TipoComprobante as varchar(3)) end
	
	return @equivTipo + ' ' + @Letra
end