IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Datos_Icommkt_Cabecera_Orders]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Datos_Icommkt_Cabecera_Orders];
GO;

CREATE FUNCTION [Interfaces].[Datos_Icommkt_Cabecera_Orders]
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
	select	DatosExpoBasicos.OrderNumber,
			DatosExpoBasicos.StoreCode,
			DatosExpoBasicos.UserId,
			DatosExpoBasicos.Date,
			count(DatosExpoBasicos.TotalItems) as TotalItems,
			sum(DatosExpoBasicos.TotalProducts) as TotalProducts,
			DatosExpoBasicos.TotalAmount,
			DatosExpoBasicos.ItemsAmount,
			DatosExpoBasicos.DiscountsAmount,
			DatosExpoBasicos.ShippingAmount,
			DatosExpoBasicos.TaxAmount,
			DatosExpoBasicos.PromoCodes,
			DatosExpoBasicos.PreShippingAmount,
			DatosExpoBasicos.DeliveryType,
			DatosExpoBasicos.DeliverySubType,
			DatosExpoBasicos.DeliveryCompany,
			DatosExpoBasicos.PaymentMethod,
			DatosExpoBasicos.PaymentMethodDetail,
			DatosExpoBasicos.PaymentMethodEntity,
			DatosExpoBasicos.PaymentTerms
	from (
		select	Comprobante.FLETRA + right(Funciones.padl(Comprobante.FPTOVEN, 4, 0), 4) + right(Funciones.padl(Comprobante.FNUMCOMP, 8, 0), 8) as OrderNumber,
				SUBSTRING(DB_NAME(), 12, 8) as StoreCode,
				Comprobante.FPERSON as UserId,
				convert(varchar(10),Comprobante.FALTAFW,103) as 'Date',
				DetalleComprobante.NROITEM as TotalItems,
				coalesce(DetalleComprobante.FCANT, 0) as TotalProducts,
				cast(Comprobante.FTOTAL as numeric(10,2)) as TotalAmount,
				cast(Comprobante.FSUBTON as numeric(10,2)) as ItemsAmount,
				coalesce(cast((Comprobante.FDESCU + Comprobante.MD2 + Comprobante.MD3) + (select (case when Comprobante.fletra = 'A' then sum(MNTDES) + sum(MNPDSI) else sum(MNTDES) + sum(FCFITOT) end) from ZooLogic.COMPROBANTEVDET where codigo = Comprobante.CODIGO) as numeric(10,2)), 0) as DiscountsAmount,
				'0.00' as ShippingAmount,
				Comprobante.FIMPUESTO + Comprobante.TOTIMPUE as TaxAmount,
				coalesce(cast(PromosYFormasDePago.PROMOS as varchar(80)), '') as PromoCodes,
				cast(Comprobante.FTOTAL as numeric(10,2)) as PreShippingAmount,
				'' as DeliveryType,
				'' as DeliverySubType,
				'' as DeliveryCompany,
				coalesce(cast(PromosYFormasDePago.FORMADEPAGO as varchar(80)), '') as PaymentMethod,
				coalesce(cast(PromosYFormasDePago.DESCVALOR as varchar(80)), '') as PaymentMethodDetail,
				coalesce(cast(PromosYFormasDePago.ENTIDADFINANCIERA as varchar(80)), '') as PaymentMethodEntity,
				coalesce(cast(PromosYFormasDePago.CUOTAS as varchar(50)), '') as PaymentTerms
		from [ZooLogic].[Comprobantev] as Comprobante
			left join [Zoologic].[ComprobantevDet] as DetalleComprobante on Comprobante.Codigo = DetalleComprobante.Codigo
			left join [Interfaces].[Auxiliar_Icommkt_Cabecera_Orders]() AS PromosYFormasDePago on Comprobante.CODIGO = PromosYFormasDePago.JJNUM
		where Comprobante.FACTTIPO in (1, 2, 27)
			and Comprobante.FLETRA between @LetraDesde and @LetraHasta
			and Comprobante.FPTOVEN between @PuntoVentaDesde and @PuntoVentaHasta
			and Comprobante.FNUMCOMP between @NumeroComprobanteDesde and @NumeroComprobanteHasta
			and Comprobante.FFCH between @FechaComprobanteDesde and @FechaComprobanteHasta
			and Comprobante.FECEXPO between @FechaExportacionDesde and @FechaExportacionHasta
			and Comprobante.Anulado = 0
	) as DatosExpoBasicos
	group by
		DatosExpoBasicos.OrderNumber,
		DatosExpoBasicos.StoreCode,
		DatosExpoBasicos.UserId,
		DatosExpoBasicos.Date,
		DatosExpoBasicos.TotalAmount,
		DatosExpoBasicos.ItemsAmount,
		DatosExpoBasicos.DiscountsAmount,
		DatosExpoBasicos.ShippingAmount,
		DatosExpoBasicos.TaxAmount,
		DatosExpoBasicos.PromoCodes,
		DatosExpoBasicos.PreShippingAmount,
		DatosExpoBasicos.DeliveryType,
		DatosExpoBasicos.DeliverySubType,
		DatosExpoBasicos.DeliveryCompany,
		DatosExpoBasicos.PaymentMethod,
		DatosExpoBasicos.PaymentMethodDetail,
		DatosExpoBasicos.PaymentMethodEntity,
		DatosExpoBasicos.PaymentTerms
)