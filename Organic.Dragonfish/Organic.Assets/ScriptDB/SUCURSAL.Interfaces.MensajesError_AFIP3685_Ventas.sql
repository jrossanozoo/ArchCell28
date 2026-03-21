IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[MensajesError_AFIP3685_Ventas]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[MensajesError_AFIP3685_Ventas];
GO;

CREATE FUNCTION [Interfaces].[MensajesError_AFIP3685_Ventas]
( 
	@FechaDesde varchar(10),
	@FechaHasta varchar(10) 
)
RETURNS TABLE
AS
RETURN
(
	select cast( 'Conversion TIPOCOMPROBANTEAFIP: No se encuentra la conversion del valor ' + ErroresComprobantes.TipoComprobante + '.' as char(100) ) as Error
	from Interfaces.Errores_AFIP3685_VentasComprobantes( @FechaDesde, @FechaHasta ) as ErroresComprobantes
	where ErroresComprobantes.TipoComprobante is not null
	
	union
	
	select cast( 'Conversion CODIGODOCUMENTO: No se encuentra la conversion del valor ' + ErroresComprobantes.TipoDocumento + '.' as char(100) ) as Error
	from Interfaces.Errores_AFIP3685_VentasComprobantes( @FechaDesde, @FechaHasta ) as ErroresComprobantes
	where ErroresComprobantes.TipoDocumento is not null
	
	union
	
	select cast( 'Conversion MONEDAAFIP: No se encuentra la conversion del valor ' + ErroresComprobantes.Moneda + '.' as char(100) ) as Error
	from Interfaces.Errores_AFIP3685_VentasComprobantes( @FechaDesde, @FechaHasta ) as ErroresComprobantes
	where ErroresComprobantes.Moneda is not null
	
	union
	
	select cast( 'Conversion TIPOCOMPROBANTEAFIP: No se encuentra la conversion del valor ' + ErroresAlicuotas.TipoComprobante + '.' as char(100) ) as Error
	from Interfaces.Errores_AFIP3685_VentasAlicuotas( @FechaDesde, @FechaHasta ) as ErroresAlicuotas
	where ErroresAlicuotas.TipoComprobante is not null
	
	union
	
	select cast( 'Conversion AFIP ALICUOTA DE IVA: No se encuentra la conversion del valor ' + cast( ErroresAlicuotas.PorcentajeIVA as varchar(5) ) + '.' as char(100) ) as Error
	from Interfaces.Errores_AFIP3685_VentasAlicuotas( @FechaDesde, @FechaHasta ) as ErroresAlicuotas
	where ErroresAlicuotas.PorcentajeIVA is not null

	union
	
	select cast( 'Comprobante electronico sin CAE : ' + funciones.alltrim(ErroresCompElectronicos.Descrip)  + '.' as char(100)) as Error
	from Interfaces.Errores_AFIP3685_VentasCompElectronicos( @FechaDesde, @FechaHasta ) as ErroresCompElectronicos
	where ErroresCompElectronicos.Descrip is not null
)