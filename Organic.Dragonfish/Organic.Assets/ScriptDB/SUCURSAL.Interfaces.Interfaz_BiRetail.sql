IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Interfaz_BiRetail]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Interfaz_BiRetail];
GO;

CREATE FUNCTION [Interfaces].[Interfaz_BiRetail]
( 
	@LetraDesde char(1),
	@LetraHasta char(1),
	@PuntoVentaDesde numeric(4,0),
	@PuntoVentaHasta numeric(4,0),
	@NumeroComprobanteDesde numeric(8,0),
	@NumeroComprobanteHasta numeric(8,0),
	@FechaComprobanteDesde datetime,
	@FechaComprobanteHasta datetime,
	@FechaExportacionDesde datetime,
	@FechaExportacionHasta datetime,
	@Sucursal char(10),
	@ListaPrecioCompra char(6),
	@ListaPrecioVenta char(6)
)
RETURNS TABLE
AS
RETURN
(
	select  DatosExpo.Fechahora ,
			cast(DatosExpo.CodigoTransaccion as varchar(15)) as CodigoTransaccion,
			DatosExpo.Apertura_Tkt,
			cast(DatosExpo.Sucursal as varchar(10)) as Sucursal,
			cast(DatosExpo.Articulo as varchar(15)) as Articulo,
			DatosExpo.Proveedor,
			DatosExpo.Grupo,
			DatosExpo.Familia,
			DatosExpo.Linea,
			DatosExpo.Material,
			DatosExpo.Temporada,
			DatosExpo.Tipo,
			DatosExpo.Clasificacion,
			DatosExpo.Categoria,
			cast(round(DatosExpo.PrecioCosto,2) as decimal(15,2)) as PrecioCosto,
			cast(round(DatosExpo.PrecioPublico,2) as decimal(15,2)) as PrecioPublico,
			DatosExpo.DescripcionArticulo,
			DatosExpo.Color,
			cast(DatosExpo.Talle as varchar(20)) as Talle,
			DatosExpo.Cantidad,
			cast(round(DatosExpo.Importe,2) as decimal(15,2)) as Importe,
			DatosExpo.CodVendedor,
			DatosExpo.Vendedor,
			cast(DatosExpo.MedioPago as varchar(100)) as MedioPago,
			cast(DatosExpo.Tarjetas as varchar(100)) as Tarjetas,
			cast(DatosExpo.Banco as varchar(100)) as Banco,
			cast(DatosExpo.Promo as varchar(100)) as Promo,
			cast(round(DatosExpo.Margen,2) as decimal(15,2)) as Margen,
			cast(round(DatosExpo.TotalFactura,2) as decimal(15,2)) as TotalFactura
	from [Interfaces].[Datos_BiRetail](@LetraDesde, @LetraHasta, @PuntoVentaDesde, @PuntoVentaHasta, @NumeroComprobanteDesde, @NumeroComprobanteHasta,
		@FechaComprobanteDesde, @FechaComprobanteHasta, @FechaExportacionDesde, @FechaExportacionHasta, @Sucursal, @ListaPrecioCompra, @ListaPrecioVenta) as DatosExpo
)