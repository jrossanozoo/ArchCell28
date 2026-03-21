IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Interfaz_Icommkt_OrderDetailCategories]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Interfaz_Icommkt_OrderDetailCategories];
GO;

CREATE FUNCTION [Interfaces].[Interfaz_Icommkt_OrderDetailCategories]
(
	@LetraDesde char(1),
	@LetraHasta char(1),
	@PuntoVentaDesde int,
	@PuntoVentaHasta int,
	@NumeroComprobanteDesde int,
	@NumeroComprobanteHasta int,
	@FechaComprobanteDesde varchar(10),
	@FechaComprobanteHasta varchar(10),
	@FechaExportacionDesde varchar(10),
	@FechaExportacionHasta varchar(10)
)
RETURNS TABLE
AS
RETURN
(
	select	DatosExpo.StoreCode,
			DatosExpo.OrderNumber,
			DatosExpo.LineNumber,
			DatosExpo.Category
	from [Interfaces].[Datos_Icommkt_OrderDetailCategories](@LetraDesde, @LetraHasta, @PuntoVentaDesde, @PuntoVentaHasta, @NumeroComprobanteDesde, @NumeroComprobanteHasta, @FechaComprobanteDesde, @FechaComprobanteHasta, @FechaExportacionDesde, @FechaExportacionHasta) as DatosExpo
)