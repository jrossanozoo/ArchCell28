IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Interfaz_COMARB_SIFERE_RetencionesSufridas_IIBB]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Interfaz_COMARB_SIFERE_RetencionesSufridas_IIBB];
GO;


CREATE FUNCTION [Interfaces].[Interfaz_COMARB_SIFERE_RetencionesSufridas_IIBB]
( 
	@FechaDesde varchar(10),
	@FechaHasta varchar(10) 
)
RETURNS TABLE
AS
RETURN
(
	select cast( DatosExpo.Jurisdicci as char(3) ) as Jurisdicci,
		cast( Funciones.ObtenerCUITFormateadoConGuiones( DatosExpo.CUIT ) as char(13) ) as CUIT,
		cast( DatosExpo.Diafecha + '/' + DatosExpo.MesFecha + '/' + DatosExpo.AnioFecha as char(10) ) as FechaEmision, 
		cast( Funciones.padl( cast( DatosExpo.PuntoVentaRecibo as varchar(4) ), 4, '0' ) as char(4) ) as PtoVenta,
		cast( Funciones.padl( cast( DatosExpo.NroCertificado as varchar(16) ), 16, '0' ) as char(16) ) as NroCertificado,
		cast( DatosExpo.Tipo as char(1) ) as TipoComp,
		cast( DatosExpo.LetraRecibo as char(1) ) as LetraComp,
		cast( DatosExpo.NumeroRecibo as char(20) ) as NumComp,
		cast( Funciones.ObtenerMontoConPadlConSeparadorDecimal( DatosExpo.MontoRetencionIIBB, 2, 11, ',' ) as char(11) ) as MontoReten
	
		from (

		--> comprobantes de retención recibidos
			select RetRecibos.Jurisdicci as Jurisdicci, 
				Comprobante.CUIT as CUIT,
				cast( Funciones.padl( cast( day( Comprobante.FechCert ) as varchar(2) ), 2, '0' ) as char(2) ) as DiaFecha, 
				cast( Funciones.padl( cast( month(Comprobante.FechCert ) as varchar(2) ), 2, '0' ) as char(2) ) as MesFecha, 
				cast( Funciones.padl( cast( year( Comprobante.FechCert ) as varchar(4) ), 4, '0' ) as char(4) ) as AnioFecha, 
				substring( Comprobante.Recibo, 3, 4 ) as PuntoVentaRecibo,
				Comprobante.NumeCert as NroCertificado, 
				Comprobante.TipoComp as Tipo,
				' ' as LetraRecibo,
				substring( Comprobante.Recibo, 8, 8 ) as NumeroRecibo,
				RetRecibos.Monto as MontoRetencionIIBB
			from (
					select Codigo, TipoImp, FechCert, Recibo, NumeCert, 'R' as TipoComp, 'C' as FLetra, CUIT, Anulado
					from [ZooLogic].[COMPRR]
				) as Comprobante

			inner join (
				select Codigo, Jurisdicci, Monto 
					from [ZooLogic].[CompRRDet] 
			) as RetRecibos on Comprobante.Codigo = RetRecibos.Codigo
				
			where Comprobante.Anulado = 0
				and Comprobante.FechCert >= @FechaDesde and Comprobante.FechCert <= @FechaHasta
				and Comprobante.TipoImp = 'IIBB'

		) as DatosExpo
)