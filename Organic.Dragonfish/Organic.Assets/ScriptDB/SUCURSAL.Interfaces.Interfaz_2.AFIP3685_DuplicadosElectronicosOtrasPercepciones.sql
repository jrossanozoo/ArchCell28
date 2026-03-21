IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Interfaz_AFIP3685_DuplicadosElectronicosOtrasPercepciones]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Interfaz_AFIP3685_DuplicadosElectronicosOtrasPercepciones];
GO;

CREATE FUNCTION [Interfaces].[Interfaz_AFIP3685_DuplicadosElectronicosOtrasPercepciones]
( 
	@FechaDesde varchar(10),
	@FechaHasta varchar(10)
)
RETURNS TABLE
AS
RETURN
(
	select cast( Funciones.padl( cast( year( DatosExpo.FechaComprobante ) as varchar(4) ), 4, '0' ) as char(4) ) as AnioFecha,
		cast( Funciones.padl( cast( month( DatosExpo.FechaComprobante ) as varchar(2) ), 2, '0' ) as char(2) ) as MesFecha,
		cast( Funciones.padl( cast( day( DatosExpo.FechaComprobante ) as varchar(2) ), 2, '0' ) as char(2) ) as DiaFecha,	
		cast( Funciones.padl( DatosExpo.TipoComprobante, 3, '0' ) as char(3) ) as TipoComp,
		cast( Funciones.padl( cast( DatosExpo.PuntoVenta as varchar(5) ), 5, '0' ) as char(5) ) as PtoVenta,
		cast( Funciones.padl( cast( DatosExpo.NumeroComprobante as varchar(8) ), 8, '0' ) as char(8) ) as NumComp,
		cast( Funciones.padl( cast( DatosExpo.JurisdiccionIIBB as varchar(2) ), 2, '0' ) as char(2) ) as JurisIIBB,
		cast( Funciones.ObtenerMontoNegativoConPadlSinComa( DatosExpo.ImporteIIBB, 2, 15 ) as char(15) ) as ImpoIIBB,
		cast( DatosExpo.JurisdiccionMunicipal as char(40) ) as JurisMuni,
		cast( Funciones.ObtenerMontoNegativoConPadlSinComa( DatosExpo.ImporteMunicipal, 2, 15 ) as char(15) ) as ImpoMuni
	from ( 
		select Comprobante.FFch as FechaComprobante,
			Comprobante.FPtoVen as PuntoVenta,
			Comprobante.FNumComp as NumeroComprobante,
			'' as JurisdiccionMunicipal,
			0 as ImporteMunicipal,
			PercepIIBB.Monto as ImporteIIBB,
			case when ConvVTipo.ValDest is null then ConvCTipo.ValorDef else ConvVTipo.ValDest end as TipoComprobante,
			case when ConvVJuri.ValDest is null then ConvCJuri.ValorDef else ConvVJuri.ValDest end as JurisdiccionIIBB
		from [ZooLogic].[ComprobanteV] as Comprobante
			inner join [ZooLogic].[ImpVentas] as PercepIIBB on Comprobante.Codigo = PercepIIBB.CCod and PercepIIBB.TipoI = 'IIBB'
			left join [Organizacion].[Conver] as ConvCTipo on ConvCTipo.Codigo = 'TIPOCOMPROBANTEAFIP'
			left join [Organizacion].[ConverVal] as ConvVTipo on ConvCTipo.Codigo = ConvVTipo.Conversion and ConvVTipo.ValOrig = cast( Comprobante.FactTipo as varchar(2) ) + Comprobante.FLetra
			left join [Organizacion].[Conver] as ConvCJuri on ConvCJuri.Codigo = 'JURISDICCIONAFIP'
			left join [Organizacion].[ConverVal] as ConvVJuri on ConvCJuri.Codigo = ConvVJuri.Conversion and ConvVJuri.ValOrig = PercepIIBB.Jurid
		where Comprobante.FactTipo in ( 1, 3, 4, 2, 5, 6, 27, 28, 29, 47, 48, 49, 33, 35, 36 )
			and Comprobante.FFch >= @FechaDesde and Comprobante.FFch <= @FechaHasta
		) as DatosExpo
)