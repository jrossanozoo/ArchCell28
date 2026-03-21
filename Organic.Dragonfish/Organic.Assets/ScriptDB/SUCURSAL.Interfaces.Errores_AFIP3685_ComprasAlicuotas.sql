IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Errores_AFIP3685_ComprasAlicuotas]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Errores_AFIP3685_ComprasAlicuotas];
GO;

CREATE FUNCTION [Interfaces].[Errores_AFIP3685_ComprasAlicuotas]
(
	@FechaDesde varchar(10),
	@FechaHasta varchar(10)
)
RETURNS TABLE
AS
RETURN
(
	select distinct case when DatosExpo.ConversionTipoComprobante is null then cast( DatosExpo.TipoComprobante as varchar(2) ) + DatosExpo.TicketOManual + DatosExpo.LetraComprobante else null end as TipoComprobante,
		case when DatosExpo.ConversionPorcentajeIVA is null then DatosExpo.PorcentajeIVA else null end as PorcentajeIVA
	from ( 
		select Comprobante.FactTipo as TipoComprobante,
			case when Comprobante.TCRG1361 = 3 then 'T' else 'M' end as TicketOManual,
			Comprobante.FLetra as LetraComprobante,
			Alicuotas.IVAPorcent as PorcentajeIVA,
			ConvVTipo.ValDest as ConversionTipoComprobante,
			ConvVAlic.ValDest as ConversionPorcentajeIVA,
			case when Alicuotas.IVAMonto is not null then Alicuotas.IVAMonto else 0 end as MontoIVA,
			case when ImpuesIVA.CantidadAlicuotas is not null then ImpuesIVA.CantidadAlicuotas - ImpuesIVA.CantidadAlicuotasEn0 else 0 end as CantidadAlicuotas
		from(
				select Codigo, FFch, FPtoVen, FactTipo, FLetra, FNumComp, FPerson, TCRG1361, Anulado
				from [ZooLogic].[FacCompra]
				union all
				select Codigo, FFch, FPtoVen, FactTipo, FLetra, FNumComp, FPerson, TCRG1361, Anulado
				from [ZooLogic].[NCCompra]
				union all
				select Codigo, FFch, FPtoVen, FactTipo, FLetra, FNumComp, FPerson, TCRG1361, Anulado
				from [ZooLogic].[NDCompra]
			) as Comprobante
			left join [ZooLogic].[Prov] as Proveedor on Comprobante.FPerson = Proveedor.ClCod
			left join (
				select ImpuesIVA.Codigo as Codigo,
					count( distinct ImpuesIVA.IVAPorcent ) as CantidadAlicuotas,
					sum( case when ImpuesIVA.IVAPorcent > 0 and ImpuesIVA.IVAMonto < 0.01 then 1 else 0 end ) as CantidadAlicuotasEn0,
					sum( case when ImpuesIVA.IVAPorcent = 0 then 1 else 0 end ) as CantidadAlicuotasPorcentaje0
				from (
					select Codigo, IVAPorcent, IVAMonNG, IVAMonto
					from [ZooLogic].[ImpFacComp]
					union all
					select Codigo, IVAPorcent, IVAMonNG, IVAMonto
					from [ZooLogic].[ImpNCComp]
					union all
					select Codigo, IVAPorcent, IVAMonNG, IVAMonto
					from [ZooLogic].[ImpNDComp]
					) as ImpuesIVA
				group by ImpuesIVA.Codigo
				) as ImpuesIVA on Comprobante.Codigo = ImpuesIVA.Codigo
			left join (
				select Codigo, IVAPorcent, IVAMonNG, IVAMonto
				from [ZooLogic].[ImpFacComp]
				union all
				select Codigo, IVAPorcent, IVAMonNG, IVAMonto
				from [ZooLogic].[ImpNCComp]
				union all
				select Codigo, IVAPorcent, IVAMonNG, IVAMonto
				from [ZooLogic].[ImpNDComp]
			) as Alicuotas on Comprobante.Codigo = Alicuotas.Codigo
			left join [Organizacion].[Conver] as ConvCTipo on ConvCTipo.Codigo = 'TIPOCOMPROBANTEAFIP'
			left join [Organizacion].[ConverVal] as ConvVTipo on ConvCTipo.Codigo = ConvVTipo.Conversion and ConvVTipo.ValOrig = cast( Comprobante.FactTipo as varchar(2) ) + case when Comprobante.TCRG1361 = 3 then 'T' else 'M' end + Comprobante.FLetra
			left join [Organizacion].[Conver] as ConvCAlic on ConvCAlic.Codigo = 'AFIP ALICUOTA DE IVA'
			left join [Organizacion].[ConverVal] as ConvVAlic on ConvCAlic.Codigo = ConvVAlic.Conversion and Funciones.val( ConvVAlic.ValOrig ) = Alicuotas.IVAPorcent
		where Comprobante.FactTipo in ( 8, 9, 10 )
			and Comprobante.Anulado <> 1
			and Comprobante.FLetra not in ( 'B', 'C' )
			and Comprobante.FFch >= @FechaDesde and Comprobante.FFch <= @FechaHasta

	union all
	
		select 	
				99 as TipoComprobante,
				'' as TicketOManual,
				'A' as LetraComprobante,
				case when ConvVAlic.ValDest is null then ConvCAlic.ValorDef else ConvVAlic.ValDest end as PorcentajeIVA,
				'' as ConversionTipoComprobante,
				ConvVAlic.ValDest as ConversionPorcentajeIVA,
				case when Alicuotas.IVAMonto is not null then Alicuotas.IVAMonto else 0 end as MontoIVA,
				case when ImpuesIVA.CantidadAlicuotas is not null then ImpuesIVA.CantidadAlicuotas - ImpuesIVA.CantidadAlicuotasEn0 else 0 end as CantidadAlicuotas
			from  [ZooLogic].[LiqMensual] as Liquidacion
				left join [ZooLogic].[OPETAR] as Operadora on Liquidacion.Operadora = Operadora.Codigo
				left join [ZooLogic].[Prov] as Proveedor on Operadora.Proveedor = Proveedor.CLCOD
				left join (
							select ImpuesIVA.Codigo as Codigo,
								count( distinct ImpuesIVA.IVAPorcent ) as CantidadAlicuotas,
								sum( case when ImpuesIVA.IVAPorcent > 0 and ImpuesIVA.IVAMonto < 0.01 then 1 else 0 end ) as CantidadAlicuotasEn0
							from  [ZooLogic].[ImpLiqMen] as ImpuesIVA
							group by ImpuesIVA.Codigo
							) as ImpuesIVA on Liquidacion.Codigo = ImpuesIVA.Codigo
				left join [ZooLogic].[ImpLiqMen] as Alicuotas on Liquidacion.Codigo = Alicuotas.Codigo
				left join [Organizacion].[Conver] as ConvCAlic on ConvCAlic.Codigo = 'AFIP ALICUOTA DE IVA'
				left join [Organizacion].[ConverVal] as ConvVAlic on ConvCAlic.Codigo = ConvVAlic.Conversion and Funciones.val( ConvVAlic.ValOrig ) = Alicuotas.IVAPorcent
			where 
				Liquidacion.FechaLiq >= @FechaDesde and Liquidacion.FechaLiq <= @FechaHasta

		) as DatosExpo
	where DatosExpo.CantidadAlicuotas > 0
		and ( ( DatosExpo.PorcentajeIVA > 0 and DatosExpo.MontoIVA >= 0.01 ) or DatosExpo.PorcentajeIVA = 0 )
		and ( DatosExpo.ConversionTipoComprobante is null
			or DatosExpo.ConversionPorcentajeIVA is null )
)