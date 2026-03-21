IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerCodigoVendedor]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerCodigoVendedor];
GO;

CREATE FUNCTION [Funciones].[ObtenerCodigoVendedor]
( @TipoComprobante int, 
	@VendedorRecibo varchar(10),
	@VendedorFactura varchar(10)
)
	
RETURNS varchar (60)
AS
BEGIN
declare @retorno varchar(60)
set @retorno =
case 
	when @TipoComprobante = '13' then @VendedorRecibo
	else @VendedorFactura
end

return @retorno

END