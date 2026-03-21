IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Interfaz_NK_Ventas]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Interfaz_NK_Ventas];
GO;

CREATE FUNCTION [Interfaces].[Interfaz_NK_Ventas]
( 
	@LetraDesde varchar(1),
	@LetraHasta varchar(1),
	@PuntoVentaDesde int,
	@PuntoVentaHasta int,
	@NumeroComprobanteDesde int,
	@NumeroComprobanteHasta int,
	@FechaComprobanteDesde varchar(10),
	@FechaComprobanteHasta varchar(10),
	@FechaExportacionDesde varchar(10),
	@FechaExportacionHasta varchar(10),
	@CodigoProveedor varchar(10),
	@ListaPrecioCompra varchar(6)
)
RETURNS TABLE
AS
RETURN
(
	select '"' + cast(DatosExpo.Sucursal as varchar(10)) + '"' as Sucursal,
		'"' + cast(DatosExpo.FechaHora as varchar(21)) + '"' as FecHora,
		'"' + cast(DatosExpo.TipoComprobante as varchar(30)) + '"' as TipoComp,
		'"' + cast(Funciones.padl(cast(DatosExpo.NumeroComprobante as varchar(8)), 8, '0') as char(8)) + '"' as NumComp,
		'"' + cast(DatosExpo.Articulo as varchar(15)) + '"' as CodArt,
		'"' + cast(DatosExpo.Talle as varchar(20)) + '"' as Talle,
		cast(DatosExpo.Cantidad as varchar(8)) as Cantidad,
		case when DatosExpo.PrecioCompra = 0.00 then cast(0 as varchar(15))
			when DatosExpo.Cantidad < 0 then cast(DatosExpo.PrecioCompra * -1 as varchar(15)) 
		else cast(DatosExpo.PrecioCompra as varchar(15)) end as PreCompra,
		cast(DatosExpo.TotalFacturado as varchar(14)) as TotFact ,
		'"' + cast(DatosExpo.MedioDePago as varchar(5)) +'"' as MedPago,
		cast(DatosExpo.Cuotas as varchar(3)) as Coutas
	from [Interfaces].[Datos_NK_Ventas](@LetraDesde, @LetraHasta, @PuntoVentaDesde, @PuntoVentaHasta, @NumeroComprobanteDesde, @NumeroComprobanteHasta,
		@FechaComprobanteDesde, @FechaComprobanteHasta, @FechaExportacionDesde, @FechaExportacionHasta, @CodigoProveedor, @ListaPrecioCompra) as DatosExpo
)