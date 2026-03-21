IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Interfaz_Icommkt_Cabecera_Orders]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Interfaz_Icommkt_Cabecera_Orders];
GO;

CREATE FUNCTION [Interfaces].[Interfaz_Icommkt_Cabecera_Orders]
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
	select	DatosExpo.OrderNumber,
			DatosExpo.StoreCode,
			DatosExpo.UserId,
			DatosExpo.Date,
			DatosExpo.TotalItems,
			DatosExpo.TotalProducts,
			DatosExpo.TotalAmount,
			DatosExpo.ItemsAmount,
			DatosExpo.DiscountsAmount,
			DatosExpo.ShippingAmount,
			DatosExpo.TaxAmount,
			DatosExpo.PromoCodes,
			DatosExpo.PreShippingAmount,
			DatosExpo.DeliveryType,
			DatosExpo.DeliverySubType,
			DatosExpo.DeliveryCompany,
			DatosExpo.PaymentMethod,
			DatosExpo.PaymentMethodDetail,
			DatosExpo.PaymentMethodEntity,
			DatosExpo.PaymentTerms
	from [Interfaces].[Datos_Icommkt_Cabecera_Orders](@LetraDesde, @LetraHasta, @PuntoVentaDesde, @PuntoVentaHasta, @NumeroComprobanteDesde, @NumeroComprobanteHasta, @FechaComprobanteDesde, @FechaComprobanteHasta, @FechaExportacionDesde, @FechaExportacionHasta) as DatosExpo
)