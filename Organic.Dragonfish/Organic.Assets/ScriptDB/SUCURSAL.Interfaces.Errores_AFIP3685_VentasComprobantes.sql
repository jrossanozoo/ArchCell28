IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Errores_AFIP3685_VentasComprobantes]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Errores_AFIP3685_VentasComprobantes];
GO;

CREATE FUNCTION [Interfaces].[Errores_AFIP3685_VentasComprobantes]
( 
	@FechaDesde varchar(10),
	@FechaHasta varchar(10) 
)
RETURNS TABLE
AS
RETURN
(
	select distinct case when DatosExpo.ConversionTipoComprobante is null then cast( DatosExpo.TipoComprobante as varchar(2) ) + DatosExpo.LetraComprobante else null end as TipoComprobante,
		case when DatosExpo.ConversionTipoDocumento = '' then DatosExpo.TipoDocumento else null end as TipoDocumento,
		case when DatosExpo.ConversionMoneda is null then DatosExpo.Moneda else null end as Moneda
	from ( 
		select 
			Comprobante.FactTipo as TipoComprobante,
			Comprobante.Fletra as LetraComprobante,
			Comprobante.Moneda as Moneda,
			Cliente.ClTipoDoc as TipoDocumento,
			ConvVTipo.ValDest as ConversionTipoComprobante,
			ConvVMone.ValDest as ConversionMoneda,
			Interfaces.Auxiliar_AFIP3685_ObtenerTipoDocumentoCliente( Comprobante.FactTipo, Comprobante.FPerson, Comprobante.FCUIT, Cliente.ClCUIT, Cliente.PCUIT, Cliente.ClNroDoc, case when ConvVDocu.ValDest is null then ConvCDocu.ValorDef else ConvVDocu.ValDest end ) as ConversionTipoDocumento,
			case when ImpuesIVA.CantidadAlicuotas is not null then ImpuesIVA.CantidadAlicuotas - ImpuesIVA.CantidadAlicuotasEn0 else 0 end as CantidadAlicuotas,
			Comprobante.Gravamen as ImpuestosInternos
		from [ZooLogic].[ComprobanteV] as Comprobante
			left join [ZooLogic].[Cli] as Cliente on Comprobante.FPerson = Cliente.ClCod
			left join (
				select ImpuesIVA.Codigo as Codigo,
					sum( case when ImpuesIVA.IVAPorcent = 0 then ImpuesIVA.IVAMonNG else 0 end ) as IVAMonNG,
					count( distinct ImpuesIVA.IVAPorcent ) as CantidadAlicuotas,
					sum( case when ImpuesIVA.IVAPorcent > 0 and ImpuesIVA.IVAMonto < 0.01 then 1 else 0 end ) as CantidadAlicuotasEn0
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
			left join [Organizacion].[Conver] as ConvCTipo on ConvCTipo.Codigo = 'TIPOCOMPROBANTEAFIP'
			left join [Organizacion].[ConverVal] as ConvVTipo on ConvCTipo.Codigo = ConvVTipo.Conversion and ConvVTipo.ValOrig = cast( Comprobante.FactTipo as varchar(2) ) + Comprobante.FLetra
			left join [Organizacion].[Conver] as ConvCDocu on ConvCDocu.Codigo = 'CODIGODOCUMENTO'
			left join [Organizacion].[ConverVal] as ConvVDocu on ConvCDocu.Codigo = ConvVDocu.Conversion and ConvVDocu.ValOrig = Cliente.ClTipoDoc
			left join [Organizacion].[Conver] as ConvCMone on ConvCMone.Codigo = 'MONEDAAFIP'
			left join [Organizacion].[ConverVal] as ConvVMone on ConvCMone.Codigo = ConvVMone.Conversion and ConvVMone.ValOrig = Comprobante.Moneda
		where Comprobante.FactTipo in ( 1, 3, 4, 2, 5, 6, 27, 28, 29, 47, 48, 49, 33, 35, 36 )
			and Comprobante.Anulado = 0
			and Comprobante.FFch >= @FechaDesde and Comprobante.FFch <= @FechaHasta
		) as DatosExpo
	where DatosExpo.CantidadAlicuotas > 0
		and ( DatosExpo.ConversionTipoComprobante is null
			or DatosExpo.ConversionMoneda is null 
			or DatosExpo.ConversionTipoDocumento = '' )
)