IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[Listados].[VistaIntegral_RetYPerComprasDet]') AND type = N'V')
	DROP VIEW [Listados].[VistaIntegral_RetYPerComprasDet];
GO;

CREATE VIEW [Listados].[VistaIntegral_RetYPerComprasDet] AS
(
	select 
		  CRIMPDET.ACUMCOMPR
		, CRIMPDET.ACUMPAGOS
		, CRIMPDET.ACUMRETENC
		, CRIMPDET.BASECALC
		, CRIMPDET.CODIGO
		, CRIMPDET.codimp 	
		, impuesto.tipo as tipoimp
		, CRIMPDET.CONVMULTI
		, CRIMPDET.DESCRI
		, CRIMPDET.ESCALA
		, CRIMPDET.ESCEXCED
		, CRIMPDET.ESCFIJO
		, CRIMPDET.ESCPORC
		, CRIMPDET.ESRG1575AR
		, CRIMPDET.ESRG2616AR
		, CRIMPDET.JURISDETA
		, CRIMPDET.JURISDICCI
		, CRIMPDET.MINIMO
		, CRIMPDET.MINNOIMP
		, CRIMPDET.MINNOIMPO
		, CRIMPDET.MONTO
		, CRIMPDET.MONTOBASE
		, CRIMPDET.MONTOORIGE
		, CRIMPDET.NROITEM
		, CRIMPDET.PORCBASE
		, CRIMPDET.PORCENTAJE
		, CRIMPDET.PORCONVMUL
		, CRIMPDET.REGIMDESCR
		, CRIMPDET.REGIMENIMP 
		, CRIMPDET.RESOLDETA
		, CRIMPDET.SIRECERT
		, CRIMPDET.SIRECS
	from ZooLogic.CRIMPDET as CRIMPDET
		Left join zoologic.IMPUESTO as IMPUESTO on CRIMPDET.codimp = impuesto.codigo
	union all
	select
		  cast( 0 as numeric(15, 2)) as ACUMCOMPR
		, cast( 0 as numeric(15, 2)) as ACUMPAGOS
		, cast( 0 as numeric(15, 2)) as ACUMRETENC
		, dfi.BASECALC
		, pfc.CCOD as CODIGO
		, pfc.CODIMP
		, pfc.codimp as tipoimp
		, cast( '' as varchar(10)) as CONVMULTI
		, pfc.DESCRI
		, dfi.ESCALA
		, cast( 0 as numeric(12, 2)) as ESCEXCED
		, cast( 0 as numeric(12, 2)) as ESCFIJO
		, cast( 0 as numeric(6, 2)) as ESCPORC
		, cast( 0 as bit ) as ESRG1575AR
		, cast( 0 as bit ) as ESRG2616AR
		, cast( coalesce(dfj.DESCRI, '') as varchar(50)) as JURISDETA
		, dfi.JURISDICCI
		, dfi.MINIMO
		, pfc.MINOIMP as MINNOIMP
		, dfi.MONTO as MINNOIMPO
		, pfc.MONTO
		, cast( 0 as numeric(15, 2)) as MONTOBASE
		, cast( 0 as numeric(15, 2)) as MONTOORIGE
		, pfc.NROITEM
		, dfi.PORCBASE
		, dfi.PORCENTAJE
		, cast( 0 as numeric(6, 2)) as PORCONVMUL
		, cast( coalesce(dfr.DESCRIP, '') as varchar(100)) as REGIMDESCR
		, dfi.REGIMENIMP 
		, dfi.RESOLU as RESOLDETA
		, cast( '' as varchar(25)) as SIRECERT
		, cast( '' as varchar(4)) as SIRECS
	from ZooLogic.IMPFACC as pfc 
		left join ZooLogic.IMPUESTO dfi on dfi.CODIGO = pfc.CODIMP 
		left join ZooLogic.JURISDIC dfj on dfj.CODIGO = dfi.JURISDICCI
		left join ZooLogic.REGIMP dfr on dfr.CODIGO = dfi.REGIMENIMP
	union all
	select
		  cast( 0 as numeric(15, 2)) as ACUMCOMPR
		, cast( 0 as numeric(15, 2)) as ACUMPAGOS
		, cast( 0 as numeric(15, 2)) as ACUMRETENC
		, dfi.BASECALC
		, pfc.CCOD as CODIGO
		, pfc.CODIMP
		, pfc.codimp as tipoimp
		, cast( '' as varchar(10)) as CONVMULTI
		, pfc.DESCRI
		, dfi.ESCALA
		, cast( 0 as numeric(12, 2)) as ESCEXCED
		, cast( 0 as numeric(12, 2)) as ESCFIJO
		, cast( 0 as numeric(6, 2)) as ESCPORC
		, cast( 0 as bit ) as ESRG1575AR
		, cast( 0 as bit ) as ESRG2616AR
		, cast( coalesce(dfj.DESCRI, '') as varchar(50)) as JURISDETA
		, dfi.JURISDICCI
		, dfi.MINIMO
		, (-1 * pfc.MINOIMP ) as MINNOIMP
		, (-1 * dfi.MONTO ) as MINNOIMPO
		, (-1 * pfc.MONTO )
		, cast( 0 as numeric(15, 2)) as MONTOBASE
		, cast( 0 as numeric(15, 2)) as MONTOORIGE
		, pfc.NROITEM
		, dfi.PORCBASE
		, dfi.PORCENTAJE
		, cast( 0 as numeric(6, 2)) as PORCONVMUL
		, cast( coalesce(dfr.DESCRIP, '') as varchar(100)) as REGIMDESCR
		, dfi.REGIMENIMP 
		, dfi.RESOLU as RESOLDETA
		, cast( '' as varchar(25)) as SIRECERT
		, cast( '' as varchar(4)) as SIRECS
	from ZooLogic.IMPNCC as pfc 
		left join ZooLogic.IMPUESTO dfi on dfi.CODIGO = pfc.CODIMP 
		left join ZooLogic.JURISDIC dfj on dfj.CODIGO = dfi.JURISDICCI
		left join ZooLogic.REGIMP dfr on dfr.CODIGO = dfi.REGIMENIMP
	union all
	select
		  cast( 0 as numeric(15, 2)) as ACUMCOMPR
		, cast( 0 as numeric(15, 2)) as ACUMPAGOS
		, cast( 0 as numeric(15, 2)) as ACUMRETENC
		, dfi.BASECALC
		, pfc.CCOD as CODIGO
		, pfc.CODIMP
		, pfc.codimp as tipoimp
		, cast( '' as varchar(10)) as CONVMULTI
		, pfc.DESCRI
		, dfi.ESCALA
		, cast( 0 as numeric(12, 2)) as ESCEXCED
		, cast( 0 as numeric(12, 2)) as ESCFIJO
		, cast( 0 as numeric(6, 2)) as ESCPORC
		, cast( 0 as bit ) as ESRG1575AR
		, cast( 0 as bit ) as ESRG2616AR
		, cast( coalesce(dfj.DESCRI, '') as varchar(50)) as JURISDETA
		, dfi.JURISDICCI
		, dfi.MINIMO
		, pfc.MINOIMP as MINNOIMP
		, dfi.MONTO as MINNOIMPO
		, pfc.MONTO
		, cast( 0 as numeric(15, 2)) as MONTOBASE
		, cast( 0 as numeric(15, 2)) as MONTOORIGE
		, pfc.NROITEM
		, dfi.PORCBASE
		, dfi.PORCENTAJE
		, cast( 0 as numeric(6, 2)) as PORCONVMUL
		, cast( coalesce(dfr.DESCRIP, '') as varchar(100)) as REGIMDESCR
		, dfi.REGIMENIMP 
		, dfi.RESOLU as RESOLDETA
		, cast( '' as varchar(25)) as SIRECERT
		, cast( '' as varchar(4)) as SIRECS
	from ZooLogic.IMPNDC as pfc
		left join ZooLogic.IMPUESTO dfi on dfi.CODIGO = pfc.CODIMP 
		left join ZooLogic.JURISDIC dfj on dfj.CODIGO = dfi.JURISDICCI
		left join ZooLogic.REGIMP dfr on dfr.CODIGO = dfi.REGIMENIMP

	union all
	
	Select
		 cast( 0 as numeric(15, 2)) as ACUMCOMPR
		, cast( 0 as numeric(15, 2)) as ACUMPAGOS
		, cast( 0 as numeric(15, 2)) as ACUMRETENC
		, dfi.BASECALC
		, pfc.CCOD as CODIGO
		, pfc.CODIMP
		, pfc.codimp as tipoimp
		, cast( '' as varchar(10)) as CONVMULTI
		, pfc.DESCRI
		, dfi.ESCALA
		, cast( 0 as numeric(12, 2)) as ESCEXCED
		, cast( 0 as numeric(12, 2)) as ESCFIJO
		, cast( 0 as numeric(6, 2)) as ESCPORC
		, cast( 0 as bit ) as ESRG1575AR
		, cast( 0 as bit ) as ESRG2616AR
		, cast( coalesce(dfj.DESCRI, '') as varchar(50)) as JURISDETA
		, dfi.JURISDICCI
		, dfi.MINIMO
		, pfc.MINOIMP as MINNOIMP
		, dfi.MONTO as MINNOIMPO
		, pfc.MONTO
		, cast( 0 as numeric(15, 2)) as MONTOBASE
		, cast( 0 as numeric(15, 2)) as MONTOORIGE
		, pfc.NROITEM
		, dfi.PORCBASE
		, dfi.PORCENTAJE
		, cast( 0 as numeric(6, 2)) as PORCONVMUL
		, cast( coalesce(dfr.DESCRIP, '') as varchar(100)) as REGIMDESCR
		, dfi.REGIMENIMP 
		, dfi.RESOLU as RESOLDETA
		, cast( '' as varchar(25)) as SIRECERT
		, cast( '' as varchar(4)) as SIRECS
	from ZooLogic.IMPLIQMENCOM as PFC
		LEFT JOIN ZOOLOGIC.IMPUESTO as dfi on dfi.codigo = pfc.CODIMP and 0 = Funciones.empty( pfc.codimp ) 
		left join ZooLogic.JURISDIC dfj on dfj.CODIGO = dfi.JURISDICCI
		left join ZooLogic.REGIMP dfr on dfr.CODIGO = dfi.REGIMENIMP
);
