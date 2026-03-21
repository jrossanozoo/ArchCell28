IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Datos_Icommkt_OrderDetailCategories]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Datos_Icommkt_OrderDetailCategories];
GO;

CREATE FUNCTION [Interfaces].[Datos_Icommkt_OrderDetailCategories]
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
	select	SUBSTRING(DB_NAME(), 12, 8) as StoreCode,
			Comprobante.FLETRA + right(Funciones.padl(Comprobante.FPTOVEN, 4, 0), 4) + right(Funciones.padl(Comprobante.FNUMCOMP, 8, 0), 8) as OrderNumber,
			funciones.alltrim(DetalleOrden.NROITEM) as LineNumber,
			funciones.alltrim(coalesce(Categoria.Descrip,'')) as Category
	from ZooLogic.COMPROBANTEV as Comprobante
		left join zoologic.comprobantevdet as DetalleOrden on Comprobante.Codigo = DetalleOrden.Codigo
		left join zoologic.art as Articulo on DetalleOrden.FART = Articulo.ARTCOD
		left join zoologic.categart as Categoria on Articulo.catearti = Categoria.COD
	where Comprobante.FACTTIPO in (1, 2, 27)
		and Comprobante.FLETRA between @LetraDesde and @LetraHasta
		and Comprobante.FPTOVEN between @PuntoVentaDesde and @PuntoVentaHasta
		and Comprobante.FNUMCOMP between @NumeroComprobanteDesde and @NumeroComprobanteHasta
		and Comprobante.FFCH between @FechaComprobanteDesde and @FechaComprobanteHasta
		and Comprobante.FECEXPO between @FechaExportacionDesde and @FechaExportacionHasta
		and Comprobante.Anulado = 0
)
