IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Interfaz_ARCARG5705_IVASimpleRetenciones]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Interfaz_ARCARG5705_IVASimpleRetenciones];
GO;

CREATE FUNCTION [Interfaces].[Interfaz_ARCARG5705_IVASimpleRetenciones]
( 
	@FechaDesde varchar(10),
	@FechaHasta varchar(10)

)
RETURNS TABLE
AS
RETURN

(
	select 
		'767' AS Impuesto, 
		Regimen AS Regimen, 
		Cuit AS CuitAgente, 
		'' AS CuitI, 
		Funciones.padl( cast( year( convert( date, FechCert ) ) as varchar(4) ), 4, '0' ) + '-' + 
		Funciones.padl( cast( month( convert( date, FechCert ) ) as varchar(2) ), 2, '0' ) + '-' + 
		Funciones.padl( cast( day( convert( date, FechCert ) ) as varchar(2) ), 2, '0' ) as FechaReten, -- acomodar fecha a AAAAMMDD
		'2' AS TipoComprob, 
		'0'+SUBSTRING( Recibo, 3, 13 )  AS NroComprob, 
		Numecert AS Certificado, 
		replace( cast( Rtotal as varchar(15) ), '.', ',') as Importe
	from [ZooLogic].comprr c_RetenRecibos
		where c_RetenRecibos.tipoimp = 'IVA'
			and ( ( @FechaDesde is null ) or ( c_RetenRecibos.FechCert >= @FechaDesde ) ) 
			and ( ( @FechaHasta is null ) or ( c_RetenRecibos.FechCert <= @FechaHasta ) )
)