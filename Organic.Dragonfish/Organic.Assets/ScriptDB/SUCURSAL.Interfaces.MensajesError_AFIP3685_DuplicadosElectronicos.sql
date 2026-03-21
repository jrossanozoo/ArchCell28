IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[MensajesError_AFIP3685_DuplicadosElectronicos]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[MensajesError_AFIP3685_DuplicadosElectronicos];
GO;

CREATE FUNCTION [Interfaces].[MensajesError_AFIP3685_DuplicadosElectronicos]
( 
	@FechaDesde varchar(10),
	@FechaHasta varchar(10) 
)
RETURNS TABLE
AS
RETURN
(
	select cast( 'Conversion TIPOCOMPROBANTEAFIP: No se encuentra la conversion del valor ' + ErroresCabecera.TipoComprobante + '.' as char(100) ) as Error
	from Interfaces.Errores_AFIP3685_DuplicadosElectronicosCabecera( @FechaDesde, @FechaHasta ) as ErroresCabecera
	where ErroresCabecera.TipoComprobante is not null
	
	union
	
	select cast( 'Conversion CODIGODOCUMENTO: No se encuentra la conversion del valor ' + ErroresCabecera.TipoDocumento + '.' as char(100) ) as Error
	from Interfaces.Errores_AFIP3685_DuplicadosElectronicosCabecera( @FechaDesde, @FechaHasta ) as ErroresCabecera
	where ErroresCabecera.TipoDocumento is not null
	
	union
	
	select cast( 'Conversion MONEDAAFIP: No se encuentra la conversion del valor ' + ErroresCabecera.Moneda + '.' as char(100) ) as Error
	from Interfaces.Errores_AFIP3685_DuplicadosElectronicosCabecera( @FechaDesde, @FechaHasta ) as ErroresCabecera
	where ErroresCabecera.Moneda is not null
		
	union
	
	select cast( 'Conversion TIPORESPONSABLE: No se encuentra la conversion del valor ' + ErroresCabecera.TipoResponsable + '.' as char(100) ) as Error
	from Interfaces.Errores_AFIP3685_DuplicadosElectronicosCabecera( @FechaDesde, @FechaHasta ) as ErroresCabecera
	where ErroresCabecera.TipoResponsable is not null

	union
	
	select cast( 'Conversion TIPOCOMPROBANTEAFIP: No se encuentra la conversion del valor ' + ErroresDetalle.TipoComprobante + '.' as char(100) ) as Error
	from Interfaces.Errores_AFIP3685_DuplicadosElectronicosDetalle( @FechaDesde, @FechaHasta ) as ErroresDetalle
	where ErroresDetalle.TipoComprobante is not null
	
	union
	
	select cast( 'Conversion AFIP ALICUOTA DE IVA: No se encuentra la conversion del valor ' + cast( ErroresDetalle.PorcentajeIVA as varchar(5) ) + '.' as char(100) ) as Error
	from Interfaces.Errores_AFIP3685_DuplicadosElectronicosDetalle( @FechaDesde, @FechaHasta ) as ErroresDetalle
	where ErroresDetalle.PorcentajeIVA is not null

	union
	
	select cast( 'Conversion TIPOCOMPROBANTEAFIP: No se encuentra la conversion del valor ' + ErroresOtrasPercepciones.TipoComprobante + '.' as char(100) ) as Error
	from Interfaces.Errores_AFIP3685_DuplicadosElectronicosOtrasPercepciones( @FechaDesde, @FechaHasta ) as ErroresOtrasPercepciones
	where ErroresOtrasPercepciones.TipoComprobante is not null

	union
	
	select cast( 'Conversion JURISDICCIONAFIP: No se encuentra la conversion del valor ' + ErroresOtrasPercepciones.JurisdiccionIIBB + '.' as char(100) ) as Error
	from Interfaces.Errores_AFIP3685_DuplicadosElectronicosOtrasPercepciones( @FechaDesde, @FechaHasta ) as ErroresOtrasPercepciones
	where ErroresOtrasPercepciones.JurisdiccionIIBB is not null
)