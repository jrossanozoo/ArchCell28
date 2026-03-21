IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Errores_AFIP3685_VentasAlicuotas]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Errores_AFIP3685_VentasAlicuotas];
GO;

CREATE FUNCTION [Interfaces].[Errores_AFIP3685_VentasAlicuotas]
( 
	@FechaDesde varchar(10),
	@FechaHasta varchar(10) 
)
RETURNS TABLE
AS
RETURN
(
	select distinct case when DatosExpo.ConversionTipoComprobante is null then cast( DatosExpo.TipoComprobante as varchar(2) ) + DatosExpo.LetraComprobante else null end as TipoComprobante,
		case when DatosExpo.ConversionPorcentajeIVA is null then DatosExpo.PorcentajeIVA else null end as PorcentajeIVA
	from ( 
		select  Comprobante.FactTipo  as TipoComprobante,
			Comprobante.FLetra as LetraComprobante,
			Alicuotas.IVAPorcent as PorcentajeIVA,
			ConvVTipo.ValDest as ConversionTipoComprobante,
			ConvVAlic.ValDest as ConversionPorcentajeIVA,
			case when Alicuotas.IVAMonto is not null then Alicuotas.IVAMonto else 0 end as MontoIVA,
			case when ImpuesIVA.CantidadAlicuotas is not null then ImpuesIVA.CantidadAlicuotas - ImpuesIVA.CantidadAlicuotasEn0 else 0 end as CantidadAlicuotas
		from [ZooLogic].[ComprobanteV] as Comprobante
			left join (
				select ImpuesIVA.Codigo as Codigo,
					count( distinct ImpuesIVA.IVAPorcent ) as CantidadAlicuotas,
					sum( case when ImpuesIVA.IVAPorcent > 0 and ImpuesIVA.IVAMonto < 0.01 then 1 else 0 end ) as CantidadAlicuotasEn0
				from [ZooLogic].[ImpuestosV] as ImpuesIVA
				group by ImpuesIVA.Codigo
				) as ImpuesIVA on Comprobante.Codigo = ImpuesIVA.Codigo
			left join [ZooLogic].[ImpuestosV] as Alicuotas on Comprobante.Codigo = Alicuotas.Codigo
			left join [Organizacion].[Conver] as ConvCTipo on ConvCTipo.Codigo = 'TIPOCOMPROBANTEAFIP'
			left join [Organizacion].[ConverVal] as ConvVTipo on ConvCTipo.Codigo = ConvVTipo.Conversion and ConvVTipo.ValOrig = cast( Comprobante.FactTipo as varchar(2) ) + Comprobante.FLetra
			left join [Organizacion].[Conver] as ConvCAlic on ConvCAlic.Codigo = 'AFIP ALICUOTA DE IVA'
			left join [Organizacion].[ConverVal] as ConvVAlic on ConvCAlic.Codigo = ConvVAlic.Conversion and Funciones.val( ConvVAlic.ValOrig ) = Alicuotas.IVAPorcent
		where Comprobante.FactTipo in ( 1, 3, 4, 2, 5, 6, 27, 28, 29, 47, 48, 49, 33, 35, 36 )
			and Comprobante.Anulado = 0
			and Comprobante.FFch >= @FechaDesde and Comprobante.FFch <= @FechaHasta
		) as DatosExpo
	where DatosExpo.CantidadAlicuotas > 0
		and ( ( DatosExpo.PorcentajeIVA > 0 and DatosExpo.MontoIVA >= 0.01 ) or DatosExpo.PorcentajeIVA = 0 )
		and ( DatosExpo.ConversionTipoComprobante is null
			or DatosExpo.ConversionPorcentajeIVA is null )
)