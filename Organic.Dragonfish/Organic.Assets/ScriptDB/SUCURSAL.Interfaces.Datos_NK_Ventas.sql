IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Datos_NK_Ventas]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Datos_NK_Ventas];
GO;

CREATE FUNCTION [Interfaces].[Datos_NK_Ventas]
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
	select DatosExpoAvanzados.Sucursal,
		DatosExpoAvanzados.FechaHora,
		DatosExpoAvanzados.TipoComprobante,
		DatosExpoAvanzados.NumeroComprobante,
		DatosExpoAvanzados.Articulo,
		DatosExpoAvanzados.Talle,
		sum(DatosExpoAvanzados.Cantidad) as Cantidad,
		DatosExpoAvanzados.SignoCantidad,
		DatosExpoAvanzados.PrecioCompra,
		sum(DatosExpoAvanzados.TotalFacturado) as TotalFacturado,
		DatosExpoAvanzados.MedioDePago,
		DatosExpoAvanzados.Cuotas
	from (
		select DatosExpoIntermedios.Sucursal,
			DatosExpoIntermedios.FechaHora,
			DatosExpoIntermedios.TipoComprobante,
			DatosExpoIntermedios.NumeroComprobante,
			DatosExpoIntermedios.Talle,
			DatosExpoIntermedios.Cantidad,
			case when DatosExpoIntermedios.Cantidad >=0 then 1 else 0 end as SignoCantidad,
			DatosExpoIntermedios.PrecioCompra,
			DatosExpoIntermedios.MedioDePago,
			DatosExpoIntermedios.Cuotas,
			cast(round(DatosExpoIntermedios.TotalFacturado, 2) as numeric(15,2)) as TotalFacturado,
			case when DatosExpoIntermedios.ConversionArticulo = '-' then DatosExpoIntermedios.Articulo else DatosExpoIntermedios.ConversionArticulo end as Articulo
		from (
			select	DatosExpoBasicos.NumeroComprobante,
				DatosExpoBasicos.DiaFecha + '/' + DatosExpoBasicos.MesFecha + '/' + DatosExpoBasicos.AnioFecha + ' ' + DatosExpoBasicos.Hora as FechaHora,
				DatosExpoBasicos.Articulo,
				(DatosExpoBasicos.Cantidad * DatosExpoBasicos.Signo) as Cantidad,
				((DatosExpoBasicos.MontoNeto - DatosExpoBasicos.MontoProrrateoDescuentosSI + DatosExpoBasicos.MontoProrrateoRecargosSI + DatosExpoBasicos.MontoProrrateoIVA) * DatosExpoBasicos.Signo) as TotalFacturado,
				DatosExpoBasicos.PrecioCompra,
				left(DatosExpoBasicos.ConversionSucursal, 6) as Sucursal,
				case when DatosExpoBasicos.ConversionTipoComp = '' then DatosExpoBasicos.TipoComprobante else DatosExpoBasicos.ConversionTipoComp end as TipoComprobante,
				left(DatosExpoBasicos.ConversionArticulo, 6) + '-' + left(DatosExpoBasicos.ConversionColor, 3) as ConversionArticulo,
				left(DatosExpoBasicos.ConversionTalle, 5) as Talle,
				DatosExpoBasicos.MedioDePago,
				case when DatosExpoBasicos.Cuotas is null then 0 else DatosExpoBasicos.Cuotas end as Cuotas
			from (
				select Comprobantes.FNumComp as NumeroComprobante,
					Funciones.padl(cast(year(Comprobantes.FAltaFW) as varchar(4)), 4, '0') as AnioFecha,
					Funciones.padl(cast(month(Comprobantes.FAltaFW) as varchar(2)), 2, '0') as MesFecha,
					Funciones.padl(cast(day(Comprobantes.FAltaFW) as varchar(2)), 2, '0') as DiaFecha,
					Funciones.alltrim(Comprobantes.HAltaFW) as Hora,
					Funciones.alltrim(DetArticulos.FArt) as Articulo,
					cast(DetArticulos.FCant as int) as Cantidad,
					DetArticulos.FNeto as MontoNeto,
					DetArticulos.MntPDesSI as MontoProrrateoDescuentosSI,
					DetArticulos.MntPRecSI as MontoProrrateoRecargosSI,
					DetArticulos.MntPIVA as MontoProrrateoIVA,
					[Interfaces].[Auxiliar_NK_Ventas_ObtenerMedioDePago](TotValores.CantidadEfectivo, TotValores.CantidadTarjeta, TotValores.CantidadOtros, TotCupones.CantCuotasDistintas) as MedioDePago,
					TotCupones.Cuotas as Cuotas,
					Funciones.ObtenerPrecioDeLaCombinacionPorListaDePrecio(DetArticulos.FArt, DetArticulos.CColor, DetArticulos.Talle, @ListaPrecioCompra) as PrecioCompra,
					[Interfaces].[Auxiliar_NK_Ventas_ObtenerTipoComprobante](Comprobantes.FactTipo, Comprobantes.FLetra) as TipoComprobante,
					case when NKNOMBREBASE_valconv.ValDest is null then Comprobantes.BDAltaFW else NKNOMBREBASE_valconv.ValDest end as ConversionSucursal,
					case when NKTIPOCOMPROBANTE_valconv.ValDest is null then '' else left(Funciones.alltrim(NKTIPOCOMPROBANTE_valconv.ValDest), 1) end as ConversionTipoComp,
					case when NKCODIGOARTICULO_valconv.ValDest is null then '' else Funciones.alltrim(NKCODIGOARTICULO_valconv.ValDest) end as ConversionArticulo,
					case when NKCOLOR_valconv.ValDest is null then '' else Funciones.alltrim(NKCOLOR_valconv.ValDest) end as ConversionColor,
					case when NKTALLE_valconv.ValDest is null then Funciones.alltrim(DetArticulos.Talle) else Funciones.alltrim(NKTALLE_valconv.ValDest) end as ConversionTalle,
					Comprobantes.SignoMov as Signo
				from [ZooLogic].[ComprobanteV] as Comprobantes
					join [ZooLogic].[ComprobanteVDet] as DetArticulos on DetArticulos.Codigo = Comprobantes.Codigo
					join [ZooLogic].[Art] as Articulos on Articulos.ArtCod = DetArticulos.FArt and Articulos.ArtFab = @CodigoProveedor
					join (
						select DetValores.JJNum as CodigoComprobante,
							sum(case when DetValores.JJT = 1 then 1 else 0 end) as CantidadEfectivo,
							sum(case when DetValores.JJT = 3 then 1 else 0 end) as CantidadTarjeta,
							sum(case when DetValores.JJT not in (1, 3) then 1 else 0 end) as CantidadOtros
						from [ZooLogic].[Val] as DetValores
						where DetValores.EsVuelto = 0
						group by DetValores.JJNum
						) as TotValores on TotValores.CodigoComprobante = Comprobantes.Codigo
					left join (
						select Cupones.Comp as CodigoComprobante,
							max(Cupones.Cuotas) as Cuotas,
							count(distinct Cupones.Cuotas) as CantCuotasDistintas
						from [ZooLogic].[Cupones] as Cupones
						group by Cupones.Comp
						) as TotCupones on TotCupones.CodigoComprobante = Comprobantes.Codigo
					left join [Organizacion].[ConverVal] as NKNOMBREBASE_valconv on NKNOMBREBASE_valconv.Conversion = 'NKNOMBREBASE' and NKNOMBREBASE_valconv.ValOrig = Comprobantes.BDAltaFW
					left join [Organizacion].[ConverVal] as NKTIPOCOMPROBANTE_valconv on NKTIPOCOMPROBANTE_valconv.Conversion = 'NKTIPOCOMPROBANTE' and NKTIPOCOMPROBANTE_valconv.ValOrig = [Interfaces].[Auxiliar_NK_Ventas_ObtenerTipoComprobante](Comprobantes.FactTipo, Comprobantes.FLetra)
					left join [Organizacion].[ConverVal] as NKCODIGOARTICULO_valconv on NKCODIGOARTICULO_valconv.Conversion = 'NKCODIGOARTICULO' and NKCODIGOARTICULO_valconv.ValOrig = DetArticulos.FArt
					left join [Organizacion].[ConverVal] as NKCOLOR_valconv on NKCOLOR_valconv.Conversion = 'NKCOLOR' and NKCOLOR_valconv.ValOrig = DetArticulos.CColor
					left join [Organizacion].[ConverVal] as NKTALLE_valconv on NKTALLE_valconv.Conversion = 'NKTALLE' and NKTALLE_valconv.ValOrig = DetArticulos.Talle
				where Comprobantes.FactTipo in (1, 3, 4, 2, 5, 6, 27, 28, 29)
					and Comprobantes.FLetra between @LetraDesde and @LetraHasta
					and Comprobantes.FPtoVen between @PuntoVentaDesde and @PuntoVentaHasta
					and Comprobantes.FNumComp between @NumeroComprobanteDesde and @NumeroComprobanteHasta
					and Comprobantes.FFch between @FechaComprobanteDesde and @FechaComprobanteHasta
					and Comprobantes.FecExpo between @FechaExportacionDesde and @FechaExportacionHasta
					and Comprobantes.Anulado = 0
			) as DatosExpoBasicos
		) as DatosExpoIntermedios
	) as DatosExpoAvanzados
	group by DatosExpoAvanzados.Sucursal,
		DatosExpoAvanzados.FechaHora,
		DatosExpoAvanzados.TipoComprobante,
		DatosExpoAvanzados.NumeroComprobante,
		DatosExpoAvanzados.Articulo,
		DatosExpoAvanzados.Talle,
		DatosExpoAvanzados.SignoCantidad,
		DatosExpoAvanzados.PrecioCompra,
		DatosExpoAvanzados.MedioDePago,
		DatosExpoAvanzados.Cuotas
)