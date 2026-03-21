IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Interfaz_AFIP3685_DuplicadosElectronicosCabeceraTotales]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Interfaz_AFIP3685_DuplicadosElectronicosCabeceraTotales];
GO;

CREATE FUNCTION [Interfaces].[Interfaz_AFIP3685_DuplicadosElectronicosCabeceraTotales]
( 
	@FechaDesde varchar(10),
	@FechaHasta varchar(10)
)
RETURNS TABLE
AS
RETURN
(
	select count(*) as CantComp,
		sum( DatosExpo.Total * ( case when DatosExpo.EsNotaCredito = 0 then 1 else -1 end ) ) as Total,
		sum( ( case when DatosExpo.EsExportacion = 1 then DatosExpo.Total else DatosExpo.NetoNoGravado end ) * ( case when DatosExpo.EsNotaCredito = 0 then 1 else -1 end ) ) as NetoNoGrav,
		sum( ( case when DatosExpo.EsExportacion = 1 then 0 else DatosExpo.NetoGravado end ) * ( case when DatosExpo.EsNotaCredito = 0 then 1 else -1 end ) ) as NetoGrav,
		sum( DatosExpo.ImpuestoLiquidado * ( case when DatosExpo.EsNotaCredito = 0 then 1 else -1 end ) ) as ImpuLiqui,
		sum( DatosExpo.PercepcionesNoCategorizadas * ( case when DatosExpo.EsNotaCredito = 0 then 1 else -1 end ) ) as PercNoCate,
		sum( DatosExpo.OperacionesExentas * ( case when DatosExpo.EsNotaCredito = 0 then 1 else -1 end ) ) as OpeExentas,
		sum( ( case when DatosExpo.EsExportacion = 1 then 0 else DatosExpo.ImpuestosNacionales end ) * ( case when DatosExpo.EsNotaCredito = 0 then 1 else -1 end ) ) as ImpuNacion,
		sum( ( case when DatosExpo.EsExportacion = 1 then 0 else DatosExpo.ImpuestosIIBB end ) * ( case when DatosExpo.EsNotaCredito = 0 then 1 else -1 end ) ) as ImpuIIBB,
		sum( ( case when DatosExpo.EsExportacion = 1 then 0 else DatosExpo.ImpuestosMunicipales end ) * ( case when DatosExpo.EsNotaCredito = 0 then 1 else -1 end ) ) as ImpuMunic,
		sum( ( case when DatosExpo.EsExportacion = 1 then 0 else DatosExpo.ImpuestosInternos end ) * ( case when DatosExpo.EsNotaCredito = 0 then 1 else -1 end ) ) as ImpuIntern,
		sum( ( case when DatosExpo.EsExportacion = 1 then 0 else DatosExpo.OtrosTributos end ) * ( case when DatosExpo.EsNotaCredito = 0 then 1 else -1 end ) ) as ImpuOtros
	from (
		select Comprobante.FImpuesto as ImpuestoLiquidado,
			Comprobante.FTotal as Total,
			Funciones.EsComprobanteExportacion( Comprobante.FactTipo ) as EsExportacion,
			Funciones.EsComprobanteNotaDeCredito( Comprobante.FactTipo ) as EsNotaCredito,
			0 as PercepcionesNoCategorizadas,
			0 as OperacionesExentas,
			0 as ImpuestosMunicipales,
			sum( case when ImpuesIVA.IVAMonNG is not null then round( ImpuesIVA.IVAMonNG, 2 ) else 0 end ) as NetoNoGravado,
			sum( case when ImpuesIVA.IVAMonGrav is not null then round( ImpuesIVA.IVAMonGrav, 2 ) else 0 end ) as NetoGravado,
			sum( case when ImpVentas.ImpuestosNacionales is not null then round( ImpVentas.ImpuestosNacionales, 2 ) else 0 end ) as ImpuestosNacionales,
			sum( case when ImpVentas.ImpuestosIIBB is not null then round( ImpVentas.ImpuestosIIBB, 2 ) else 0 end ) as ImpuestosIIBB,
			Comprobante.Gravamen as ImpuestosInternos,
			sum( case when ImpVentas.OtrosTributos is not null then round( ImpVentas.OtrosTributos, 2 ) else 0 end ) as OtrosTributos
		from [ZooLogic].[ComprobanteV] as Comprobante
			left join (
				select ImpuesIVA.Codigo as Codigo,
					sum( case when ImpuesIVA.IVAPorcent = 0 then ImpuesIVA.IVAMonNG else 0 end ) as IVAMonNG,
					sum( case when ImpuesIVA.IVAPorcent > 0 then ImpuesIVA.IVAMonNG else 0 end ) as IVAMonGrav
				from [ZooLogic].[ImpuestosV] as ImpuesIVA
				group by ImpuesIVA.Codigo
				) as ImpuesIVA on Comprobante.Codigo = ImpuesIVA.Codigo
			left join (
				select ImpVentas.CCod,
					sum( case when ImpVentas.TipoI in ( 'IVA', 'GANANCIAS' ) then ImpVentas.Monto else 0 end ) as ImpuestosNacionales,
					sum( case when ImpVentas.TipoI = 'IIBB' then ImpVentas.Monto else 0 end ) as ImpuestosIIBB,
					sum( case when ImpVentas.TipoI not in ( 'IVA', 'GANANCIAS', 'IIBB' ) then ImpVentas.Monto else 0 end ) as OtrosTributos
				from [ZooLogic].[ImpVentas] as ImpVentas
				group by ImpVentas.CCod
				) as ImpVentas on Comprobante.Codigo = ImpVentas.CCod
		where Comprobante.FactTipo in ( 1, 3, 4, 2, 5, 6, 27, 28, 29, 47, 48, 49, 33, 35, 36 )
			and Comprobante.FFch >= @FechaDesde and Comprobante.FFch <= @FechaHasta 
		group by Comprobante.FFch,
			Comprobante.FPtoVen,
			Comprobante.FactTipo,
			Comprobante.FNumComp,
			Comprobante.FTotal,
			Comprobante.FImpuesto,
			Comprobante.Gravamen,
			ImpuesIVA.Codigo,
			ImpVentas.CCod
		) as DatosExpo
)