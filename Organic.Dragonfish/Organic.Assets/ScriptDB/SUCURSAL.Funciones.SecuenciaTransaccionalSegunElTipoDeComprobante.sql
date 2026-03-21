IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[SecuenciaTransaccionalSegunElTipoDeComprobante]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[SecuenciaTransaccionalSegunElTipoDeComprobante];
GO;

CREATE FUNCTION [Funciones].[SecuenciaTransaccionalSegunElTipoDeComprobante]
( @TipoDeComprobante int,
  @AfectaAlTipo int)
  
RETURNS int
AS
BEGIN
	declare @SecuenciaTransaccional int;

	if (@TipoDeComprobante < 1)
		set @SecuenciaTransaccional = 0
	else
		set @SecuenciaTransaccional = 
		case 
			when @TipoDeComprobante = 25 then 1	-- Presupuesto
			when @TipoDeComprobante = 23 then 2 -- Pedido
			when @TipoDeComprobante = 11 then 3 -- Remito
			when @TipoDeComprobante in (1, 2, 27, 33, 47) then 4 -- Facturas
			when @TipoDeComprobante in (12, 3, 5, 28, 35, 48) and @AfectaAlTipo != 12 then -Funciones.SecuenciaTransaccionalSegunElTipoDeComprobante( @AfectaAlTipo, 0 ) -- Cancelación de ventas y NC
			else 5 -- Notas de Débito y otros casos
		end;

	return @SecuenciaTransaccional;
END