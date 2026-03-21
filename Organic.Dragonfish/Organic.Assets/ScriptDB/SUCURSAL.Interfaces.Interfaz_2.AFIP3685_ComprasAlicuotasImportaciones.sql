IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Interfaz_AFIP3685_ComprasAlicuotasImportaciones]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Interfaz_AFIP3685_ComprasAlicuotasImportaciones];
GO;

CREATE FUNCTION [Interfaces].[Interfaz_AFIP3685_ComprasAlicuotasImportaciones]
( 
	@FechaDesde varchar(10),
	@FechaHasta varchar(10),
	@ComprobanteFiscal bit,
	@ComprobanteManual bit,
	@ComprobanteElectronico bit,
	@CompDespacho bit,
	@CompLiqA bit,
	@CompLiqB bit,
	@CompServPubA bit,
	@CompServPubB bit,
	@CompReciboA bit,
	@CompReciboC bit
)
RETURNS TABLE
AS
RETURN
(
	select DespImpo,
		   MontoNGIVA,
	       PorcIVA,
		   MontoIVA
	from [Interfaces].[Interfaz_AFIPRG4597_ComprasAlicuotasImportaciones](@FechaDesde, @FechaHasta, null, null, null, null, @ComprobanteFiscal, @ComprobanteManual, @ComprobanteElectronico, @CompDespacho, @CompLiqA, @CompLiqB, @CompServPubA, @CompServPubB, @CompReciboA, @CompReciboC, 0)

)