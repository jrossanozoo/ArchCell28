IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Interfaz_ATP_CHACO_IIBB_Retenciones]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Interfaz_ATP_CHACO_IIBB_Retenciones];
GO;


CREATE FUNCTION [Interfaces].[Interfaz_ATP_CHACO_IIBB_Retenciones]
( 
	@FechaDesde varchar(10),
	@FechaHasta varchar(10)
)
RETURNS TABLE
AS
RETURN
(
	select 
		cast( funciones.padl( DatosExpo.NumeroComp, 6, '0' ) as char(6) ) as NumeroComp,
		cast( DatosExpo.Cuit as char(11)) as Cuit,
		cast( funciones.padr( DatosExpo.NomRZ, 30, ' ') as char(30) ) as NomRZ,
		cast( funciones.padr( DatosExpo.Domicilio, 50, ' ' ) as char(50)) as Domicilio,
		cast( DatosExpo.Diafecha + DatosExpo.MesFecha + DatosExpo.AnioFecha as char(8) ) as FechaEmision,
		cast( funciones.padl( Montoreten, 11, '0') as char(11)) as Montoreten,
		cast( funciones.padl( CodConcepto, 2, '0') as char(2)) as CodConcepto,
		cast( funciones.padl( MontoImponible, 11, '0') as char(11)) as MontoImponible,
		cast( funciones.padl( Alicuota, 11, '0') as char(11)) as Alicuota,
		'000' as Producto,
		'00' as Dependencia,
		'  ' as OrdendePago,
		cast( funciones.padl( NOrdenPago, 5 , '0' ) as char(5)) as NOrdenPago	
		from (
			select 
				Comprobantes.NUMERO as NumeroComp,
				Proveedor.CLCUIT as Cuit,
				Proveedor.CLNOM as NomRZ,
				funciones.alltrim( Proveedor.PCALLE ) + ' ' + funciones.alltrim( Proveedor.PNUMERO ) + ' - ' +  funciones.alltrim( Proveedor.CLLOC ) as Domicilio,
				cast( Funciones.padl( cast( day( comprobantes.FECHA ) as varchar(2) ), 2, '0' ) as char(2) ) as DiaFecha, 
				cast( Funciones.padl( cast( month( comprobantes.FECHA ) as varchar(2) ), 2, '0' ) as char(2) ) as MesFecha, 
				cast( Funciones.padl( cast( year( comprobantes.FECHA ) as varchar(4) ), 4, '0' ) as char(4) ) as AnioFecha,				
				convert(int, Impuestos.MONTO *100) as Montoreten,
				Impuestos.REGIMENIMP as CodConcepto,
				convert(bigint, Impuestos.MONTOBASE *100) as MontoImponible,
				convert(int, Impuestos.PORCENTAJE *100) as Alicuota,
				Comprobantes.NUMOP as NOrdenPago
			from [ZooLogic].[COMPRet] as Comprobantes
			join ZooLogic.PROV Proveedor on Proveedor.CLCOD = comprobantes.PROV
			join ZooLogic.CRImpDet Impuestos on Impuestos.CODIGO = Comprobantes.CODIGO				
			where Comprobantes.Anulado = 0
				and Comprobantes.FECHA>= @FechaDesde and Comprobantes.FECHA <= @FechaHasta
				and Comprobantes.TipoImp = 'IIBB'
				and Impuestos.JURISDICCI = 906		
		) as DatosExpo
)




