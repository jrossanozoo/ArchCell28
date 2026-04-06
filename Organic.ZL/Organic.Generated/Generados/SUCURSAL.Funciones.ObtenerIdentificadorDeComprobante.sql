IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerIdentificadorDeComprobante]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerIdentificadorDeComprobante];
GO;

CREATE FUNCTION [Funciones].[ObtenerIdentificadorDeComprobante]
( @TipoDeComprobante int )
RETURNS varchar (3)
AS
BEGIN
declare @retorno varchar(3)
set @retorno =
case @TipoDeComprobante
	when 1 then '226'
	when 3 then '231'
	when 4 then '232'
	when 96 then 'AJC'
	when 98 then 'CC'
	when 99 then 'ADC'
	when 999 then 'LIQ'
	when 888 then 'COP'
	else 'XXX'
end
return @retorno

END