IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Errores_AFIP3685_DuplicadosElectronicosDetalle]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Errores_AFIP3685_DuplicadosElectronicosDetalle];
GO;

CREATE FUNCTION [Interfaces].[Errores_AFIP3685_DuplicadosElectronicosDetalle]
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
		select Comprobante.FactTipo as TipoComprobante,
			Comprobante.FLetra as LetraComprobante,
			case when Comprobante.Anulado = 0 then DetArticulos.FPorIVA else 0 end as PorcentajeIVA,
			ConvVTipo.ValDest as ConversionTipoComprobante,
			ConvVAlic.ValDest as ConversionPorcentajeIVA
		from [ZooLogic].[ComprobanteV] as Comprobante
			left join [ZooLogic].[ComprobanteVDet] as DetArticulos on Comprobante.Codigo = DetArticulos.Codigo
			left join [ZooLogic].[Art] as Articulo on DetArticulos.FArt = Articulo.ArtCod
			left join [ZooLogic].[UnMed] as UnidadMedida on Articulo.UniMed = UnidadMedida.Cod
			left join [Organizacion].[Conver] as ConvCTipo on ConvCTipo.Codigo = 'TIPOCOMPROBANTEAFIP'
			left join [Organizacion].[ConverVal] as ConvVTipo on ConvCTipo.Codigo = ConvVTipo.Conversion and ConvVTipo.ValOrig = cast( Comprobante.FactTipo as varchar(2) ) + Comprobante.FLetra
			left join [Organizacion].[Conver] as ConvCUniM on ConvCUniM.Codigo = 'UNIDADDEMEDIDA'
			left join [Organizacion].[ConverVal] as ConvVUniM on ConvCUniM.Codigo = ConvVUniM.Conversion and ConvVUniM.ValOrig = UnidadMedida.Cod
			left join [Organizacion].[Conver] as ConvCAlic on ConvCAlic.Codigo = 'AFIP ALICUOTA DE IVA'
			left join [Organizacion].[ConverVal] as ConvVAlic on ConvCAlic.Codigo = ConvVAlic.Conversion and Funciones.val( ConvVAlic.ValOrig ) = case when Comprobante.Anulado = 0 then DetArticulos.FPorIVA else 0 end
		where Comprobante.FactTipo in ( 1, 3, 4, 2, 5, 6, 27, 28, 29, 47, 48, 49, 33, 35, 36 )
			and Comprobante.FFch >= @FechaDesde and Comprobante.FFch <= @FechaHasta

		union

		select Comprobante.FactTipo as TipoComprobante,
			Comprobante.FLetra as LetraComprobante,
			case when Comprobante.Anulado = 0 then ImpuesIVA.IVAPorcent else 0 end as PorcentajeIVA,
			ConvVTipo.ValDest as ConversionTipoComprobante,
			ConvVAlic.ValDest as ConversionPorcentajeIVA
		from [ZooLogic].[ComprobanteV] as Comprobante
			inner join [ZooLogic].[ImpuestosV] as ImpuesIVA on Comprobante.Codigo = ImpuesIVA.Codigo and ( abs( ImpuesIVA.IVAMonto ) >= 0.01 or ImpuesIVA.IVAPorcent = 0 )
			left join [Organizacion].[Conver] as ConvCTipo on ConvCTipo.Codigo = 'TIPOCOMPROBANTEAFIP'
			left join [Organizacion].[ConverVal] as ConvVTipo on ConvCTipo.Codigo = ConvVTipo.Conversion and ConvVTipo.ValOrig = cast( Comprobante.FactTipo as varchar(2) ) + Comprobante.FLetra
			left join [Organizacion].[Conver] as ConvCAlic on ConvCAlic.Codigo = 'AFIP ALICUOTA DE IVA'
			left join [Organizacion].[ConverVal] as ConvVAlic on ConvCAlic.Codigo = ConvVAlic.Conversion and Funciones.val( ConvVAlic.ValOrig ) = ImpuesIVA.IVAPorcent
		where Comprobante.FactTipo in ( 1, 3, 4, 2, 5, 6, 27, 28, 29, 47, 48, 49, 33, 35, 36 )
			and Comprobante.FFch >= @FechaDesde and Comprobante.FFch <= @FechaHasta
			and Comprobante.Anulado = 0
			and ( case when Funciones.EsComprobanteConRecargoCI( Comprobante.FactTipo ) = 1 then Comprobante.TotRecarCI else Comprobante.TotRecar end ) - Comprobante.TotDesc <> 0
		) as DatosExpo
	where DatosExpo.ConversionTipoComprobante is null
		or DatosExpo.ConversionPorcentajeIVA is null
)