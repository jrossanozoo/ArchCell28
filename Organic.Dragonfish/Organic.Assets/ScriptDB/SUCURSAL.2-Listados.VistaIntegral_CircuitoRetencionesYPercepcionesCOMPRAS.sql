IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[Listados].[VistaIntegral_RetYPerCompras]') AND type = N'V')
	DROP VIEW [Listados].[VistaIntegral_RetYPerCompras];
GO;

CREATE VIEW [Listados].[VistaIntegral_RetYPerCompras] AS
(
	select ANULADO
		, BDALTAFW
		, BDMODIFW
		, CODIGO
		, CRTOTAL 
		, DESPROV
		, ESTTRANS
		, FALTAFW
		, FECEXPO
		, FECHA
		, FECHA as FECHAEMI
		, FECIMPO
		, FECTRANS
		, FMODIFW
		, HALTAFW
		, HMODIFW
		, HORAEXPO
		, HORAIMPO
		, IMPMAN
		, LETRAOP
		, MONEDA
		, MONSIS
		, NUMERO
		, NUMOP
		, OBS
		, PROV
		, PTOVENOP
		, PTOVENTA
		, SALTAFW
		, SMODIFW
		, TIMESTAMP
		, TIPOIMP
		, '1' as NROITEM
		, UALTAFW
		, UMODIFW
		, VALTAFW
		, VMODIFW
		, ZADSFW 
		, cast( 31 as numeric( 2, 0 ) ) as FACTTIPO
		, cast(  1 as numeric( 2, 0 ) ) as SIGNO
	from ZooLogic.COMPRET
	union all
	select fcc.ANULADO
		, fcc.BDALTAFW
		, fcc.BDMODIFW
		, fcc.CODIGO
		, ifc.MONTO as CRTOTAL 
		, cast( coalesce(prv.CLNOM, '') as varchar(60)) as DESPROV
		, fcc.ESTTRANS
		, fcc.FALTAFW
		, fcc.FECEXPO
		, fcc.FFCH as FECHA
		, fcc.FFCHFAC as FECHAEMI
		, fcc.FECIMPO
		, fcc.FECTRANS
		, fcc.FMODIFW
		, fcc.HALTAFW
		, fcc.HMODIFW
		, fcc.HORAEXPO
		, fcc.HORAIMPO
		, fcc.IMPMAN
		, cast( fcc.FLETRA as char(1) ) as LETRAOP
		, fcc.MONEDA
		, fcc.MONSIS
		, Null as NUMERO
		, fcc.FNUMCOMP as NUMOP
		, fcc.FOBS as OBS
		, fcc.FPERSON as PROV
		, cast( case when funciones.empty( fcc.fptovenext ) = 1 then fcc.FPTOVEN else fcc.fptovenext end as numeric( 5,0 ) ) as PTOVENOP
		, null as PTOVENTA
		, fcc.SALTAFW
		, fcc.SMODIFW
		, fcc.TIMESTAMP
		, ifc.CODIMP as TIPOIMP
		, ifc.NROITEM
		, fcc.UALTAFW
		, fcc.UMODIFW
		, fcc.VALTAFW
		, fcc.VMODIFW
		, fcc.ZADSFW
		, fcc.FACTTIPO
		, cast( -1 as numeric( 2, 0 ) ) as SIGNO
	from ZooLogic.FACCOMPRA fcc 
		inner join ZooLogic.IMPFACC ifc on ifc.CCOD = fcc.CODIGO
		left join ZooLogic.PROV prv on prv.CLCOD = fcc.FPERSON
	union all
	select fcc.ANULADO
		, fcc.BDALTAFW
		, fcc.BDMODIFW
		, fcc.CODIGO
		, ifc.MONTO as CRTOTAL 
		, cast( coalesce(prv.CLNOM, '') as varchar(60)) as DESPROV
		, fcc.ESTTRANS
		, fcc.FALTAFW
		, fcc.FECEXPO
		, fcc.FFCH as FECHA
		, fcc.FFCHFAC as FECHAEMI
		, fcc.FECIMPO
		, fcc.FECTRANS
		, fcc.FMODIFW
		, fcc.HALTAFW
		, fcc.HMODIFW
		, fcc.HORAEXPO
		, fcc.HORAIMPO
		, fcc.IMPMAN
		, cast( fcc.FLETRA as char(1) ) as LETRAOP
		, fcc.MONEDA
		, fcc.MONSIS
		, Null as NUMERO
		, fcc.FNUMCOMP as NUMOP
		, fcc.FOBS as OBS
		, fcc.FPERSON as PROV
		, cast( case when funciones.empty( fcc.fptovenext ) = 1 then fcc.FPTOVEN else fcc.fptovenext end as numeric( 5,0 ) ) as PTOVENOP
		, null as PTOVENTA
		, fcc.SALTAFW
		, fcc.SMODIFW
		, fcc.TIMESTAMP
		, ifc.CODIMP as TIPOIMP
		, ifc.NROITEM
		, fcc.UALTAFW
		, fcc.UMODIFW
		, fcc.VALTAFW
		, fcc.VMODIFW
		, fcc.ZADSFW
		, fcc.FACTTIPO
		, cast( -1 as numeric( 2, 0 ) ) as SIGNO
	from ZooLogic.NDCOMPRA fcc 
		inner join ZooLogic.IMPNDC ifc on ifc.CCOD = fcc.CODIGO
		left join ZooLogic.PROV prv on prv.CLCOD = fcc.FPERSON
	union all
	select fcc.ANULADO
		, fcc.BDALTAFW
		, fcc.BDMODIFW
		, fcc.CODIGO
		, (ifc.MONTO * -1) as CRTOTAL 
		, cast( coalesce(prv.CLNOM, '') as varchar(60)) as DESPROV
		, fcc.ESTTRANS
		, fcc.FALTAFW
		, fcc.FECEXPO
		, fcc.FFCH as FECHA
		, fcc.FFCHFAC as FECHAEMI
		, fcc.FECIMPO
		, fcc.FECTRANS
		, fcc.FMODIFW
		, fcc.HALTAFW
		, fcc.HMODIFW
		, fcc.HORAEXPO
		, fcc.HORAIMPO
		, fcc.IMPMAN
		, cast( fcc.FLETRA as char(1) ) as LETRAOP
		, fcc.MONEDA
		, fcc.MONSIS
		, Null as NUMERO
		, fcc.FNUMCOMP as NUMOP
		, fcc.FOBS as OBS
		, fcc.FPERSON as PROV
		, cast( case when funciones.empty( fcc.fptovenext ) = 1 then fcc.FPTOVEN else fcc.fptovenext end as numeric( 5,0 ) ) as PTOVENOP
		, null as PTOVENTA
		, fcc.SALTAFW
		, fcc.SMODIFW
		, fcc.TIMESTAMP
		, ifc.CODIMP as TIPOIMP
		, ifc.NROITEM
		, fcc.UALTAFW
		, fcc.UMODIFW
		, fcc.VALTAFW
		, fcc.VMODIFW
		, fcc.ZADSFW
		, fcc.FACTTIPO
		, cast( 1 as numeric( 2, 0 ) ) as SIGNO
	from ZooLogic.NCCOMPRA fcc 
		inner join ZooLogic.IMPNCC ifc on ifc.CCOD = fcc.CODIGO
		left join ZooLogic.PROV prv on prv.CLCOD = fcc.FPERSON

	union all
	select 0 as ANULADO
		, fcc.BDALTAFW
		, fcc.BDMODIFW
		, fcc.CODIGO
		, (ifc.MONTO * -1) as CRTOTAL 
		, cast( coalesce(prv.CLNOM, '') as varchar(60)) as DESPROV
		, fcc.ESTTRANS
		, fcc.FALTAFW
		, fcc.FECEXPO
		, fcc.FECHALIQ as FECHA
		, fcc.FECHALIQ as FECHAEMI
		, fcc.FECIMPO
		, fcc.FECTRANS
		, fcc.FMODIFW
		, fcc.HALTAFW
		, fcc.HMODIFW
		, fcc.HORAEXPO
		, fcc.HORAIMPO
		, 0 as IMPMAN
		, '' as LETRAOP
		, '' as MONEDA
		, '' as MONSIS
		, Null as NUMERO
		, fcc.NROLIQ as NUMOP
		, '' as OBS
		, prv.clcod as PROV	
		, fcc.PTOVENTA as PTOVENOP
		, null as PTOVENTA
		, fcc.SALTAFW
		, fcc.SMODIFW
		, cast( FCC.NUMINT + FCC.NROLIQ as numeric( 20,0 ) ) as timestamp
		, ifc.CODIMP as TIPOIMP
		, ifc.NROITEM
		, fcc.UALTAFW
		, fcc.UMODIFW
		, fcc.VALTAFW
		, fcc.VMODIFW
		, fcc.ZADSFW
		, 999 as FACTTIPO
		, cast( 1 as numeric( 2, 0 ) ) as SIGNO
	from ZooLogic.LIQMENSUAL as fcc
		inner join ZooLogic.IMPLIQMENCOM ifc on ifc.CCOD = fcc.CODIGO
		left join ZooLogic.OPETAR as c_opetar on c_opetar.CODIGO = fcc.OPERADORA 
		left join ZooLogic.PROV as prv on prv.CLCOD = c_opetar.PROVEEDOR	
);
