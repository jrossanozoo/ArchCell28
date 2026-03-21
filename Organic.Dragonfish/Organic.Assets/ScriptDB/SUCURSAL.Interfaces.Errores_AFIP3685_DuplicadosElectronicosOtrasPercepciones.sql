IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Errores_AFIP3685_DuplicadosElectronicosOtrasPercepciones]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Errores_AFIP3685_DuplicadosElectronicosOtrasPercepciones];
GO;

CREATE FUNCTION [Interfaces].[Errores_AFIP3685_DuplicadosElectronicosOtrasPercepciones]
( 
	@FechaDesde varchar(10),
	@FechaHasta varchar(10)
)
RETURNS TABLE
AS
RETURN
(
	select distinct case when DatosExpo.ConversionTipoComprobante is null then cast( DatosExpo.TipoComprobante as varchar(2) ) + DatosExpo.LetraComprobante else null end as TipoComprobante,
		case when DatosExpo.ConversionJurisdiccionIIBB is null then DatosExpo.JurisdiccionIIBB else null end as JurisdiccionIIBB
	from ( 
		select Comprobante.FactTipo as TipoComprobante,
			Comprobante.FLetra as LetraComprobante,
			PercepIIBB.Jurid as JurisdiccionIIBB,
			ConvVTipo.ValDest as ConversionTipoComprobante,
			ConvVJuri.ValDest as ConversionJurisdiccionIIBB
		from [ZooLogic].[ComprobanteV] as Comprobante
			inner join [ZooLogic].[ImpVentas] as PercepIIBB on Comprobante.Codigo = PercepIIBB.CCod and PercepIIBB.TipoI = 'IIBB'
			left join [Organizacion].[Conver] as ConvCTipo on ConvCTipo.Codigo = 'TIPOCOMPROBANTEAFIP'
			left join [Organizacion].[ConverVal] as ConvVTipo on ConvCTipo.Codigo = ConvVTipo.Conversion and ConvVTipo.ValOrig = cast( Comprobante.FactTipo as varchar(2) ) + Comprobante.FLetra
			left join [Organizacion].[Conver] as ConvCJuri on ConvCJuri.Codigo = 'JURISDICCIONAFIP'
			left join [Organizacion].[ConverVal] as ConvVJuri on ConvCJuri.Codigo = ConvVJuri.Conversion and ConvVJuri.ValOrig = PercepIIBB.Jurid
		where Comprobante.FactTipo in ( 1, 3, 4, 2, 5, 6, 27, 28, 29, 47, 48, 49, 33, 35, 36 )
			and Comprobante.FFch >= @FechaDesde and Comprobante.FFch <= @FechaHasta
		) as DatosExpo
	where DatosExpo.ConversionTipoComprobante is null
		or DatosExpo.ConversionJurisdiccionIIBB is null
)