IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Interfaz_AFIP3685_VentasComprobantes]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Interfaz_AFIP3685_VentasComprobantes];
GO;

CREATE FUNCTION [Interfaces].[Interfaz_AFIP3685_VentasComprobantes]
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
	select	AnioFecha,
			MesFecha,
			DiaFecha,
			TipoComp,
			PtoVenta,
			NumCompD,
			NumCompH,
			CliTipoDoc,
			CliNroDoc,
			cast( case when CambioNombreCliente = 1 then ' '  else CliNombre end as char(30) ) as CliNombre,
			Total,
			NetoNoGrav,
			PercNoCate,
			OpeExentas,
			ImpuNacion,
			ImpuIIBB,
			ImpuMunic,
			ImpuIntern,
			Moneda,
			Cotizacion,
			CantAlic3685 as CantAlic,
			CodOperac,
			ImpuOtros,
			FecVtoPago
	from [Interfaces].[Interfaz_AFIPRG4597_VentasComprobantes](@FechaDesde, @FechaHasta, null, null, @ComprobanteFiscal, @ComprobanteManual, @ComprobanteElectronico)
)