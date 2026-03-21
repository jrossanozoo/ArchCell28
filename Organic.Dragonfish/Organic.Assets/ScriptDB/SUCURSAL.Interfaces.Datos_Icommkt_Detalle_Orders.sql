IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Datos_Icommkt_Detalle_Orders]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Datos_Icommkt_Detalle_Orders];
GO;

CREATE FUNCTION [Interfaces].[Datos_Icommkt_Detalle_Orders]
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
	select	DatosExpoBasicos.StoreCode,
			DatosExpoBasicos.OrderNumber,
			DatosExpoBasicos.LineNumber,
			DatosExpoBasicos.Quantity,
			DatosExpoBasicos.ItemCode,
			DatosExpoBasicos.ItemName,
			DatosExpoBasicos.Brand,
			DatosExpoBasicos.Description,
			DatosExpoBasicos.Price,
			DatosExpoBasicos.ListPrice,
			DatosExpoBasicos.SellingPrice,
			DatosExpoBasicos.ImageUrl,
			DatosExpoBasicos.DetailUrl,
			DatosExpoBasicos.Seller
	from (
		select	SUBSTRING(DB_NAME(), 12, 8) as StoreCode,
				Comprobante.FLETRA + right(Funciones.padl(Comprobante.FPTOVEN, 4, 0), 4) + right(Funciones.padl(Comprobante.FNUMCOMP, 8, 0), 8) as OrderNumber,
				DetalleOrden.NROITEM as LineNumber,
				DetalleOrden.FCANT as Quantity,
				funciones.alltrim(DetalleOrden.FART) as ItemCode,
				funciones.alltrim(DetalleOrden.FTXT) as ItemName,
				funciones.alltrim(coalesce(Linea.DESCRIP, '')) as Brand,
				funciones.alltrim(DetalleOrden.FTXT) + 'T:' + funciones.alltrim(DetalleOrden.FTATXT) + 'C:' + funciones.alltrim(DetalleOrden.FCOLTXT) as 'Description',
				(DetalleOrden.FNETO - DetalleOrden.MNTPDESSI) / (case when DetalleOrden.FCANT = 0 then 1 else DetalleOrden.FCANT end) as Price,
				coalesce(Funciones.ObtenerPrecioDeLaCombinacionConOSinImpuestosALaFecha(DetalleOrden.FART, DetalleOrden.CCOLOR, DetalleOrden.TALLE, Comprobante.CODLISTA, 0, Comprobante.FFCH, default ), 0) as ListPrice,
				case when Comprobante.FLETRA = 'A' then DetalleOrden.FPRECIO else DetalleOrden.FPRECIO / ((DetalleOrden.FPORIVA / 100) + 1) end as SellingPrice,
				'' as ImageUrl,
				'' as DetailUrl,
				funciones.alltrim(coalesce(Vendedor.CLNOM, '')) as Seller
		From ZooLogic.COMPROBANTEV as Comprobante
			left join ZooLogic.COMPROBANTEVDET as DetalleOrden on Comprobante.CODIGO = DetalleOrden.CODIGO
			left join Zoologic.ART as Articulo on DetalleOrden.FART = Articulo.ARTCOD
			left join Zoologic.PROV as Proveedor on Articulo.ARTFAB = Proveedor.CLCOD
			left join ZooLogic.LINEA as Linea on Articulo.LINEA = Linea.COD
			left join ZooLogic.VEN as Vendedor on Comprobante.FVEN = Vendedor.CLCOD 
		where Comprobante.FACTTIPO in (1, 2, 27)
			and Comprobante.FLETRA between @LetraDesde and @LetraHasta
			and Comprobante.FPTOVEN between @PuntoVentaDesde and @PuntoVentaHasta
			and Comprobante.FNUMCOMP between @NumeroComprobanteDesde and @NumeroComprobanteHasta
			and Comprobante.FFCH between @FechaComprobanteDesde and @FechaComprobanteHasta
			and Comprobante.FECEXPO between @FechaExportacionDesde and @FechaExportacionHasta
			and Comprobante.Anulado = 0
	) as DatosExpoBasicos
)