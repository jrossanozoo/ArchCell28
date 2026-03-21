IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Interfaz_AFIP3685_VentasAlicuotas]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Interfaz_AFIP3685_VentasAlicuotas];
GO;

CREATE FUNCTION [Interfaces].[Interfaz_AFIP3685_VentasAlicuotas]
( 
	@FechaDesde varchar(10),
	@FechaHasta varchar(10),
	@ComprobanteFiscal bit,
	@ComprobanteManual bit,
	@ComprobanteElectronico bit 
)
RETURNS TABLE
AS
RETURN
(
	select	TipoComp,
			PtoVenta,
			NumCompD,
			MontoNGIVA,
			PorcIVA,
			MontoIVA
	from [Interfaces].[Interfaz_AFIPRG4597_VentasAlicuotas](@FechaDesde, @FechaHasta, null, null, @ComprobanteFiscal, @ComprobanteManual, @ComprobanteElectronico)
)