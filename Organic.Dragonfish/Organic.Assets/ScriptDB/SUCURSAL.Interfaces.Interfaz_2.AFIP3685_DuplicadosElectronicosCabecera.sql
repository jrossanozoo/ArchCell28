IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Interfaz_AFIP3685_DuplicadosElectronicosCabecera]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Interfaz_AFIP3685_DuplicadosElectronicosCabecera];
GO;

CREATE FUNCTION [Interfaces].[Interfaz_AFIP3685_DuplicadosElectronicosCabecera]
( 
	@FechaDesde varchar(10),
	@FechaHasta varchar(10) 
)
RETURNS TABLE
AS
RETURN
(
	select cast( DatosExpo.TipoRegistro as char(1) ) as TipoReg,
		cast( Funciones.padl( cast( year( DatosExpo.FechaComprobante ) as varchar(4) ), 4, '0' ) as char(4) ) as AnioFecha,
		cast( Funciones.padl( cast( month( DatosExpo.FechaComprobante ) as varchar(2) ), 2, '0' ) as char(2) ) as MesFecha,
		cast( Funciones.padl( cast( day( DatosExpo.FechaComprobante ) as varchar(2) ), 2, '0' ) as char(2) ) as DiaFecha,
		cast( Funciones.padl( DatosExpo.TipoComprobante, 3, '0' ) as char(3) ) as TipoComp,
		cast( DatosExpo.ComprobanteFiscal as char(1) ) as ContFisc,
		cast( Funciones.padl( cast( DatosExpo.PuntoVenta as varchar(5) ), 5, '0' ) as char(5) ) as PtoVenta,
		cast( Funciones.padl( cast( DatosExpo.NumeroComprobante as varchar(8) ), 8, '0' ) as char(8) ) as NumComp,
		cast( Funciones.padl( cast( DatosExpo.NumeroComprobante as varchar(8) ), 8, '0' ) as char(8) ) as NumCompReg,
		cast( Funciones.padl( cast( DatosExpo.CantidadHojas as varchar(3) ), 3, '0' ) as char(3) ) as CantHojas,
		cast( DatosExpo.TipoDocumento as char(2) ) as CliTipoDoc,
		cast( DatosExpo.NumeroDocumento as char(20) ) as CliNroDoc,
		cast( DatosExpo.NombreCliente as char(30) ) as CliNombre,
		cast( Funciones.ObtenerMontoNegativoConPadlSinComa( DatosExpo.Total, 2, 15 ) as char(15) ) as Total,
		cast( Funciones.ObtenerMontoNegativoConPadlSinComa( case when DatosExpo.EsExportacion = 1 then DatosExpo.Total else DatosExpo.NetoNoGravado end, 2, 15 ) as char(15) ) as NetoNoGrav,
		cast( Funciones.ObtenerMontoNegativoConPadlSinComa( case when DatosExpo.EsExportacion = 1 then 0 else DatosExpo.NetoGravado end, 2, 15 ) as char(15) ) as NetoGrav,
		cast( Funciones.ObtenerMontoNegativoConPadlSinComa( DatosExpo.ImpuestoLiquidado, 2, 15 ) as char(15) ) as ImpuLiqui,
		cast( Funciones.ObtenerMontoNegativoConPadlSinComa( DatosExpo.PercepcionesNoCategorizadas, 2, 15 ) as char(15) ) as PercNoCate,
		cast( Funciones.ObtenerMontoNegativoConPadlSinComa( DatosExpo.OperacionesExentas, 2, 15 ) as char(15) ) as OpeExentas,
		cast( Funciones.ObtenerMontoNegativoConPadlSinComa( case when DatosExpo.EsExportacion = 1 then 0 else DatosExpo.ImpuestosNacionales end, 2 , 15 ) as char(15) ) as ImpuNacion,
		cast( Funciones.ObtenerMontoNegativoConPadlSinComa( case when DatosExpo.EsExportacion = 1 then 0 else DatosExpo.ImpuestosIIBB end, 2, 15 ) as char(15) ) as ImpuIIBB,
		cast( Funciones.ObtenerMontoNegativoConPadlSinComa( DatosExpo.ImpuestosMunicipales, 2, 15 ) as char(15) ) as ImpuMunic,
		cast( Funciones.ObtenerMontoNegativoConPadlSinComa( case when DatosExpo.EsExportacion = 1 then 0 else DatosExpo.ImpuestosInternos end, 2, 15 ) as char(15) ) as ImpuIntern,
		cast( Funciones.ObtenerMontoNegativoConPadlSinComa( DatosExpo.Transporte, 2, 15 ) as char(15) ) as Transporte,
		cast( DatosExpo.TipoResponsable as char(2) ) as TipoResp,
		cast( DatosExpo.Moneda as char(3) ) as Moneda,
		cast( Funciones.ObtenerMontoNegativoConPadlSinComa( DatosExpo.Cotizacion, 6, 10 ) as char(10) ) as Cotizacion,
		cast( case when DatosExpo.EsExportacion = 1 or DatosExpo.CantidadAlicuotas = 0 then 1 else DatosExpo.CantidadAlicuotas end as char(1) ) as CantAlic,
		cast( case when DatosExpo.EsExportacion = 1 then 'X' else ( case when round( DatosExpo.NetoNoGravado, 2 ) <> 0 then 'N' else ' ' end ) end as char(1) ) as CodOperac,
		cast( Funciones.padl( cast( DatosExpo.NumeroCAE as varchar(14) ), 14, '0' ) as char(14) ) as NumeroCAE,
		cast( Funciones.padl( cast( case when DatosExpo.FechaVencimientoCAE <> '' then year( DatosExpo.FechaVencimientoCAE ) else 0 end as varchar(4) ), 4, '0' ) as char(4) ) as AnioVtoCAE,
		cast( Funciones.padl( cast( case when DatosExpo.FechaVencimientoCAE <> '' then month( DatosExpo.FechaVencimientoCAE ) else 0 end as varchar(2) ), 2, '0' ) as char(2) ) as MesVtoCAE,
		cast( Funciones.padl( cast( case when DatosExpo.FechaVencimientoCAE <> '' then day( DatosExpo.FechaVencimientoCAE ) else 0 end as varchar(2) ), 2, '0' ) as char(2) ) as DiaVtoCAE,
		cast( case when DatosExpo.EstaAnulado = 0 then '' else Funciones.padl( cast( year( DatosExpo.FechaAnulacion ) as varchar(4) ), 4, '0' ) end as char(4) ) as AnioAnul,
		cast( case when DatosExpo.EstaAnulado = 0 then '' else Funciones.padl( cast( month( DatosExpo.FechaAnulacion ) as varchar(2) ), 2, '0' ) end as char(2) ) as MesAnul,
		cast( case when DatosExpo.EstaAnulado = 0 then '' else Funciones.padl( cast( day( DatosExpo.FechaAnulacion ) as varchar(2) ), 2, '0' ) end as char(2) ) as DiaAnul,
		cast( Funciones.ObtenerMontoNegativoConPadlSinComa( case when DatosExpo.EsExportacion = 1 then 0 else DatosExpo.OtrosTributos end, 2, 15 ) as char(15) ) as ImpuOtros
	from ( 
		select 1 as TipoRegistro,
			Comprobante.FFch as FechaComprobante,
			Comprobante.FPtoVen as PuntoVenta,
			Comprobante.FNumComp as NumeroComprobante,
			Comprobante.Anulado as EstaAnulado,
			Comprobante.FImpuesto as ImpuestoLiquidado,
			Comprobante.FCliente as NombreCliente,
			Comprobante.FTotal as Total,
			Comprobante.Cotiz as Cotizacion,
			case when Comprobante.FCompFis = 1 then 'C' else ' ' end as ComprobanteFiscal,
			Funciones.EsComprobanteExportacion( Comprobante.FactTipo ) as EsExportacion,
			Interfaces.Auxiliar_AFIP3685_ObtenerTipoDocumentoCliente( Comprobante.FactTipo, Comprobante.FPerson, Comprobante.FCUIT, Cliente.ClCUIT, Cliente.PCUIT, Cliente.ClNroDoc, case when ConvVDocu.ValDest is null then ConvCDocu.ValorDef else ConvVDocu.ValDest end ) as TipoDocumento,
			Interfaces.Auxiliar_AFIP3685_ObtenerNumeroDocumentoCliente( Comprobante.FactTipo, Comprobante.FPerson, Comprobante.FCUIT, Cliente.ClCUIT, Cliente.PCUIT, Cliente.ClNroDoc ) as NumeroDocumento,
			case when ConvVTipo.ValDest is null then ConvCTipo.ValorDef else ConvVTipo.ValDest end as TipoComprobante,
			case when ConvVSitF.ValDest is null then ConvCSitF.ValorDef else ConvVSitF.ValDest end as TipoResponsable,
			case when ConvVMone.ValDest is null then ConvCMone.ValorDef else ConvVMone.ValDest end as Moneda,
			1 as CantidadHojas,
			0 as PercepcionesNoCategorizadas,
			0 as OperacionesExentas,
			0 as ImpuestosMunicipales,
			0 as Transporte,
			case when ImpuesIVA.IVAMonNG is not null then ImpuesIVA.IVAMonNG else 0 end as NetoNoGravado,
			case when ImpuesIVA.IVAMonGrav is not null then ImpuesIVA.IVAMonGrav else 0 end as NetoGravado,
			case when ImpVentas.ImpuestosNacionales is not null then ImpVentas.ImpuestosNacionales else 0 end as ImpuestosNacionales,
			case when ImpVentas.ImpuestosIIBB is not null then ImpVentas.ImpuestosIIBB else 0 end as ImpuestosIIBB,
			Comprobante.Gravamen as ImpuestosInternos,
			case when ImpVentas.OtrosTributos is not null then ImpVentas.OtrosTributos else 0 end as OtrosTributos,
			case when ImpuesIVA.CantidadAlicuotas is not null then ImpuesIVA.CantidadAlicuotas - ImpuesIVA.CantidadAlicuotasEn0 else 0 end as CantidadAlicuotas,
			case when Funciones.EsComprobanteElectronico( Comprobante.FactTipo ) = 1 and CAE.Numero is not null then CAE.Numero else cast( Comprobante.CAI as varchar(20) ) end as NumeroCAE,
			case when Funciones.EsComprobanteElectronico( Comprobante.FactTipo ) = 1 and CAE.FechaVto is not null then CAE.FechaVto else Comprobante.VtoCAI end as FechaVencimientoCAE,
			case when Comprobante.Anulado = 0 then cast( '' as datetime ) else Comprobante.FModiFW end as FechaAnulacion
		from [ZooLogic].[ComprobanteV] as Comprobante
			left join [ZooLogic].[Cli] as Cliente on Comprobante.FPerson = Cliente.ClCod
			left join (
				select ImpuesIVA.Codigo as Codigo,
					sum( case when ImpuesIVA.IVAPorcent = 0 then ImpuesIVA.IVAMonNG else 0 end ) as IVAMonNG,
					sum( case when ImpuesIVA.IVAPorcent > 0 then ImpuesIVA.IVAMonNG else 0 end ) as IVAMonGrav,
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
			left join [ZooLogic].[CAE] as CAE on Comprobante.Codigo = CAE.Codigo
			left join [Organizacion].[Conver] as ConvCTipo on ConvCTipo.Codigo = 'TIPOCOMPROBANTEAFIP'
			left join [Organizacion].[ConverVal] as ConvVTipo on ConvCTipo.Codigo = ConvVTipo.Conversion and ConvVTipo.ValOrig = cast( Comprobante.FactTipo as varchar(2) ) + Comprobante.FLetra
			left join [Organizacion].[Conver] as ConvCDocu on ConvCDocu.Codigo = 'CODIGODOCUMENTO'
			left join [Organizacion].[ConverVal] as ConvVDocu on ConvCDocu.Codigo = ConvVDocu.Conversion and ConvVDocu.ValOrig = Cliente.ClTipoDoc
			left join [Organizacion].[Conver] as ConvCMone on ConvCMone.Codigo = 'MONEDAAFIP'
			left join [Organizacion].[ConverVal] as ConvVMone on ConvCMone.Codigo = ConvVMone.Conversion and ConvVMone.ValOrig = case when Comprobante.Anulado = 1 then 'PESOS' else Comprobante.Moneda end
			left join [Organizacion].[Conver] as ConvCSitF on ConvCSitF.Codigo = 'TIPORESPONSABLE'
			left join [Organizacion].[ConverVal] as ConvVSitF on ConvCSitF.Codigo = ConvVSitF.Conversion and ConvVSitF.ValOrig = case when Comprobante.Anulado = 1 then '3' else cast( Comprobante.SitFiscCli as varchar(2) ) end
		where Comprobante.FactTipo in ( 1, 3, 4, 2, 5, 6, 27, 28, 29, 47, 48, 49, 33, 35, 36 )
			and Comprobante.FFch >= @FechaDesde and Comprobante.FFch <= @FechaHasta
		) as DatosExpo
)