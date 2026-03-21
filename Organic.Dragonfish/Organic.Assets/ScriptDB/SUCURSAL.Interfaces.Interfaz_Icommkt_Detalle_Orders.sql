IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Interfaz_Icommkt_Detalle_Orders]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Interfaz_Icommkt_Detalle_Orders];
GO;

CREATE FUNCTION [Interfaces].[Interfaz_Icommkt_Detalle_Orders]
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
			DatosExpo.Quantity,
			DatosExpo.ItemCode,
			DatosExpo.ItemName,
			DatosExpo.Brand,
			DatosExpo.Description,
			DatosExpo.Price,
			DatosExpo.ListPrice,
			DatosExpo.SellingPrice,
			DatosExpo.ImageUrl,
			DatosExpo.DetailUrl,
			DatosExpo.Seller
	from [Interfaces].[Datos_Icommkt_Detalle_Orders](@LetraDesde, @LetraHasta, @PuntoVentaDesde, @PuntoVentaHasta, @NumeroComprobanteDesde, @NumeroComprobanteHasta, @FechaComprobanteDesde, @FechaComprobanteHasta, @FechaExportacionDesde, @FechaExportacionHasta) as DatosExpo
)