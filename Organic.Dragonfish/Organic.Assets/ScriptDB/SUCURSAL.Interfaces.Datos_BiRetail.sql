IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Datos_BiRetail]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Datos_BiRetail];
GO;

CREATE FUNCTION [Interfaces].[Datos_BiRetail]
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
	select
		CONVERT(varchar, Comprobantes.hAltaFW + Comprobantes.fAltaFW, 120) as fechaHora,
		LTRIM(Comprobantes.fLetra + Funciones.padl(cast(Comprobantes.FPtoVen as varchar(4)), 4, '0') + Funciones.padl(cast(Comprobantes.FNumComp as varchar(8)), 8, '0')) as CodigoTransaccion,
		case when DetalleArticulos.FCant > 0
		then case when DetalleArticulos.NroItem = 1 or DetalleArticulos.NroItem = (select top 1 NroItem from ZooLogic.ComprobanteVDet where Codigo = DetalleArticulos.Codigo and fCant > 0)
				then case when Comprobantes.FactTipo in (3, 5, 28)
						then -1
						else 1 end
				else 0 end
		else -- negativos
			case when DetalleArticulos.NroItem = 1 or DetalleArticulos.NroItem = (select top 1 NroItem from ZooLogic.ComprobanteVDet where Codigo = DetalleArticulos.Codigo and fCant < 0)
				then case when Comprobantes.FactTipo in (3, 5, 28)
						then 1
						else -1 end
				else 0 end
		end as Apertura_Tkt,
		RTRIM(@Sucursal) as sucursal,
		RTRIM(DetalleArticulos.fArt) as Articulo,
		EntidadArticulos.ArtFab as Proveedor,
		EntidadArticulos.Grupo as Grupo,
		EntidadArticulos.Familia as Familia,
		EntidadArticulos.Linea as Linea,
		EntidadArticulos.Mat as Material,
		EntidadArticulos.ATemporada as Temporada,
		EntidadArticulos.TipoArti as Tipo,
		EntidadArticulos.ClasifArt as Clasificacion,
		EntidadArticulos.CateArti as Categoria,
		Funciones.ObtenerPrecioDeLaCombinacionConVigencia( DetalleArticulos.fArt, DetalleArticulos.FColTxt, DetalleArticulos.Talle, @ListaPrecioCompra, Comprobantes.fAltaFW, default) as PrecioCosto,
		Funciones.ObtenerPrecioDeLaCombinacionConVigencia( DetalleArticulos.fArt, DetalleArticulos.FColTxt, DetalleArticulos.Talle, @ListaPrecioVenta, Comprobantes.fAltaFW, default) as PrecioPublico,
		DetalleArticulos.FTxt as DescripcionArticulo,
		DetalleArticulos.FColTxt as Color,
		DetalleArticulos.Talle as Talle,
		cast(cast(round(DetalleArticulos.FCant, 0) as int) as varchar(8)) as Cantidad,
		case when Comprobantes.FactTipo in (3, 5, 28)
			then cast( round( (DetalleArticulos.FBruto * -1), 2) as numeric (8,2) )
			else cast( round( DetalleArticulos.FBruto, 2) as numeric (8,2) )
		end as Importe,
		Comprobantes.FVen as CodVendedor,
		isnull(EntidadVendedor.ClNom,'') as Vendedor,
		ISNULL ((select STUFF( (select distinct ',' + TipoValor + '|' + cast( Porcentaje as varchar)  from
		    (select TipoValor, case when TotalFacturaSinImpuestos<>0 then convert(decimal(10,2),round((MontoValor / TotalNetoItems * TotalFacturaSinImpuestos ),2)) else 0 end as Porcentaje   from 
         	(
				select (select ftotal from ZooLogic.ComprobanteV  where Codigo = DetalleArticulos.Codigo) as TotalNetoItems,
						(select convert(decimal(10,2), (round((SELECT SUM(fBruto) from ZooLogic.ComprobanteVDet where ComprobanteVDet.Codigo = DetalleArticulos.Codigo ),2)))) as TotalFacturaSinImpuestos,
						sum(recpesos) as MontoValor,
						case when clcfi in (1, 2) then 'Efectivo' else case when clcfi = 3 then 'Tarjeta' else 'Otro' end end as TipoValor,
						clcfi
					from ZooLogic.Val 
					left join ZooLogic.xVal on Val.jjco = xVal.ClCod
					where jjnum = DetalleArticulos.Codigo
				group by clcfi
				) a
			) c FOR XML PATH ('')), 1, 1, '')),'' ) as MedioPago,
		isnull((select stuff((select distinct ',' + jjDe from ZooLogic.Val left join ZooLogic.xVal on Val.jjco = xVal.ClCod
				where jjNum = DetalleArticulos.Codigo and jjDe NOT LIKE '%VUELTO%' and ClCfi = 3 for xml path ('')), 1, 1, '')), '') as Tarjetas,
		isnull((select (stuff((select distinct ',' + efDes from ZooLogic.Cupones
						left join ZooLogic.entFin on Cupones.EntFin = entFin.efCod
					where Comp = DetalleArticulos.Codigo for xml path ('')), 1, 1, ''))), '' ) as Banco,
		isnull((select stuff((select distinct ',' + Descrip from ZooLogic.PromDet
			where Codigo = DetalleArticulos.Codigo for xml path ('')), 1, 1, '')), '')  as Promo, 
		case when DetalleArticulos.FNeto > 0
			then cast(round(((((DetalleArticulos.FNeto) - round((Funciones.ObtenerPrecioDeLaCombinacionConVigencia( DetalleArticulos.FArt, DetalleArticulos.FColTxt, DetalleArticulos.Talle, @ListaPrecioCompra, Comprobantes.fAltaFW, DEFAULT)),2)) / (DetalleArticulos.FNeto)) * 100 ) , 2 ) as numeric (8,2) )
			else 0
		end as Margen,
		convert(decimal(10,2), (round((SELECT SUM(fBruto) AS TotalNetoItems FROM ZooLogic.ComprobanteVDet where Codigo = Comprobantes.Codigo ),2)))  as TotalFactura

	from ZooLogic.ComprobanteVDet as DetalleArticulos
		left join ZooLogic.ComprobanteV as Comprobantes on  DetalleArticulos.Codigo = Comprobantes.Codigo
		left join ZooLogic.Art as EntidadArticulos on DetalleArticulos.FArt = EntidadArticulos.ArtCod
		left join ZooLogic.Ven as EntidadVendedor on Comprobantes.FVen = EntidadVendedor.ClCod

	where Comprobantes.FactTipo in (1, 3, 4, 2, 5, 6, 27, 28, 29)
		and Comprobantes.Anulado = 0 and DetalleArticulos.fArt != 'SEÑA'
		and Comprobantes.FLETRA Between @LetraDesde and @LetraHasta
		and Comprobantes.FPTOVEN Between @PuntoVentaDesde and @PuntoVentaHasta
		and Comprobantes.FNUMCOMP Between @NumeroComprobanteDesde and @NumeroComprobanteHasta
		and Comprobantes.FALTAFW Between @FechaComprobanteDesde and @FechaComprobanteHasta
		and Comprobantes.FECEXPO Between @FechaExportacionDesde and @FechaExportacionHasta
)

