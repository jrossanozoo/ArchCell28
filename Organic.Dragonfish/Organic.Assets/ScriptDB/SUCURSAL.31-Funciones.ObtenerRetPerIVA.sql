IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerRetPerIVA]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerRetPerIVA];
GO;

CREATE FUNCTION [Funciones].[ObtenerRetPerIVA]
(@BaseDeDatos varchar(8) )
RETURNS TABLE
AS

RETURN
(
  select 'IVA' as origen,
	cast( funciones.padr( @BaseDeDatos, 8, ' ' ) + funciones.padr( c_Compras.codigo, 38, ' ' ) as varchar( 46 ) ) as _Grupo,
	@BaseDeDatos as _BD,
	c_Compras.CODIGO as Codigo,
	'' as ConvMulti,
	0 as PorConvMul,
	c_Compras.IVAPORCENT as PorcBase, 
	c_Compras.IVAMONNG as MontoBase,
	'TOT' as BaseCalc,
	'' as RegimenImp,
	0 as Minimo,
	0 as MinNoImp,
	c_Compras.FTOTAL as MontoOrige,
	'' as RegimDescr,
	'' as JurisDeta,
	'' as ResolDeta,
	0 as MinNoImpo,
	c_Compras.IVAPORCENT as Porcentaje,
	c_Compras.CODIGO as CR_CODIGO,
	c_proveedor.descfw as CR_DesProv,
	c_Compras.MONEDA as CR_Moneda,
	c_Compras.fptoven as CR_PtoVenta,
	c_Compras.FNUMCOMP as CR_Numero,
	c_Compras.FFCH as CR_Fecha,
	c_Compras.FLETRA as CR_LetraOP,
	c_Compras.FPTOVEN as CR_PtoVenOP,
	c_Compras.FNUMCOMP as CR_NumOP,
	c_Compras.ftotal as  CR_CRTotal,
	'' as CR_Obs,
	'1' as NROITEM,
	c_Compras.BDALTAFW as CR_BDALTAFW,
	c_Compras.BDMODIFW as CR_BDMODIFW,
	c_Compras.ESTTRANS as CR_ESTTRANS,
	case when c_Compras.faltafw = '01/01/1900 00:00:00' then null else c_Compras.faltafw end as CR_FALTAFW,
	case when c_Compras.fecexpo = '01/01/1900 00:00:00' then null else c_Compras.fecexpo end as CR_FECEXPO,
	case when c_Compras.fecimpo = '01/01/1900 00:00:00' then null else c_Compras.fecimpo end as CR_FECIMPO,
	case when c_Compras.fmodifw = '01/01/1900 00:00:00' then null else c_Compras.fmodifw end as CR_FMODIFW,
	case when c_Compras.fectrans = '01/01/1900 00:00:00' then null else c_Compras.fectrans end as CR_FECTRANS,
	c_Compras.HALTAFW as CR_HALTAFW,
	c_Compras.HORAEXPO as CR_HORAEXPO,
	c_Compras.HORAIMPO as CR_HORAIMPO,
	c_Compras.HMODIFW as CR_HMODIFW,
	c_Compras.SALTAFW as CR_SALTAFW,
	c_Compras.SMODIFW as CR_SMODIFW,
	c_Compras.UALTAFW as CR_UALTAFW,
	c_Compras.UMODIFW as CR_UMODIFW,
	c_Compras.VALTAFW as CR_VALTAFW,
	c_Compras.VMODIFW as CR_VMODIFW,
	c_Compras.ZADSFW as CR_ZADSFW,
	cast( funciones.obtenercodigodesucursaldeunabase(@BaseDeDatos) as varchar( 10 ) ) as _SUCURSAL,
	'IVA' + CAST(c_Compras.IVAPORCENT as varchar(5)) as CodImp,
	'IVA' as IMPUESTO8000_tipo,
	'IVA' as IMPUESTO8000_aplicacion,
	c_Compras.SIGNOMOV as IMPUESTO8000_8000_SignoVirtual,
	c_Compras.FACTTIPO as CR_1_TipoComprobanteVirtual,
	C_PROVEEDOR.CLCOD as CR_Prov,
	case when c_Compras.facttipo = 999 
		then cast( funciones.padl(c_Compras.FPTOVEN, 4, '0')+'-'+funciones.padl(c_Compras.FNUMCOMP, 15, '0') as varchar( 20 ) ) 
		else cast( funciones.alltrim(c_Compras.FLETRA)+' '+funciones.padl(c_Compras.FPTOVEN, 4, '0')+'-'+funciones.padl(c_Compras.FNUMCOMP, 8, '0') as varchar( 20 ) ) 
		end as CR_1_OCVirtual,
	c_Compras.IVAMONTO as Monto,
	c_Compras.FALTAFW as CR_FechaEmisionVirtual,
	'IVA ' + CAST(c_Compras.IVAPORCENT as varchar(5)) + '%' as IMPUESTO8000_descrip,
	'Impuesto al Valor Agregado' as TIPOIMPUESTO_Decrip,
	null as IMPUESTO64_codigo,
	null as IMPUESTO65_codigo,
	null as IMPUESTO66_codigo,
	'IVA' as IMPUESTO8000_codigo,
	C_PROVEEDOR.CLCOD as PROVEEDOR_CLCOD,
	c_proveedor.cliva as PROVEEDOR_CLIVA,
	'IMP IVA' as TIPOIMPUESTO_Codigo
	, cast( '' as varchar(25)) as SIRECERT
	, cast( '' as varchar(4)) as SIRECS
  from ( 
 	select 'IVA' as Origen,c_Compras.CODIGO,FPERSON,FIMPUESTO,MONEDA,FPTOVEN,FNUMCOMP,FFCH,FLETRA,c_Compras.BDALTAFW,c_Compras.BDMODIFW,c_Compras.ESTTRANS,
	c_Compras.FALTAFW,c_Compras.FECEXPO,c_Compras.FECIMPO,c_Compras.FMODIFW,c_Compras.FECTRANS,c_Compras.HALTAFW,c_Compras.HORAEXPO,c_Compras.HORAIMPO,c_Compras.HMODIFW,
	c_Compras.SALTAFW,c_Compras.SMODIFW,c_Compras.UALTAFW,c_Compras.UMODIFW,c_Compras.VALTAFW,c_Compras.VMODIFW,c_Compras.ZADSFW,SIGNOMOV,FACTTIPO,
	FSUBTON,C_IVA.IVAMONNG,C_IVA.IVAMONTO,C_IVA.IVAPORCENT,c_Compras.FTOTAL
 from ZooLogic.FACCOMPRA as c_Compras
 	left join ( Select distinct clcod from ZooLogic.PROV ) as C_PROVEEDOR on C_PROVEEDOR.CLCOD = c_Compras.FPERSON and 0 = Funciones.empty( c_Compras.FPERSON )
	left join ZooLogic.IMPFACCOMP as c_IVA on c_IVA.CODIGO = c_Compras.CODIGO
 where ( not 1 = funciones.empty( c_Compras.codigo ) )
 union all
 	select 'IVA' as Origen,c_Compras.CODIGO,FPERSON,FIMPUESTO,MONEDA,FPTOVEN,FNUMCOMP,FFCH,FLETRA,c_Compras.BDALTAFW,c_Compras.BDMODIFW,c_Compras.ESTTRANS,
	c_Compras.FALTAFW,c_Compras.FECEXPO,c_Compras.FECIMPO,c_Compras.FMODIFW,c_Compras.FECTRANS,c_Compras.HALTAFW,c_Compras.HORAEXPO,c_Compras.HORAIMPO,c_Compras.HMODIFW,
	c_Compras.SALTAFW,c_Compras.SMODIFW,c_Compras.UALTAFW,c_Compras.UMODIFW,c_Compras.VALTAFW,c_Compras.VMODIFW,c_Compras.ZADSFW,SIGNOMOV,FACTTIPO,
	FSUBTON,C_IVA.IVAMONNG,C_IVA.IVAMONTO,C_IVA.IVAPORCENT,c_Compras.FTOTAL
  from ZooLogic.NCCOMPRA as c_Compras
 	left join ( Select distinct clcod from ZooLogic.PROV ) as C_PROVEEDOR on C_PROVEEDOR.CLCOD = c_Compras.FPERSON and 0 = Funciones.empty( c_Compras.FPERSON )
	left join ZooLogic.IMPNCCOMP as c_IVA on c_IVA.CODIGO = c_Compras.CODIGO
 where ( not 1 = funciones.empty( c_Compras.codigo ) )
 union all
 	select 'IVA' as Origen,c_Compras.CODIGO,FPERSON,FIMPUESTO,MONEDA,FPTOVEN,FNUMCOMP,FFCH,FLETRA,c_Compras.BDALTAFW,c_Compras.BDMODIFW,c_Compras.ESTTRANS,
	c_Compras.FALTAFW,c_Compras.FECEXPO,c_Compras.FECIMPO,c_Compras.FMODIFW,c_Compras.FECTRANS,c_Compras.HALTAFW,c_Compras.HORAEXPO,c_Compras.HORAIMPO,c_Compras.HMODIFW,
	c_Compras.SALTAFW,c_Compras.SMODIFW,c_Compras.UALTAFW,c_Compras.UMODIFW,c_Compras.VALTAFW,c_Compras.VMODIFW,c_Compras.ZADSFW,SIGNOMOV,FACTTIPO,
	FSUBTON,C_IVA.IVAMONNG,C_IVA.IVAMONTO,C_IVA.IVAPORCENT,c_Compras.FTOTAL
  from ZooLogic.NDCOMPRA as c_Compras
 	left join ( Select distinct clcod from ZooLogic.PROV ) as C_PROVEEDOR on C_PROVEEDOR.CLCOD = c_Compras.FPERSON and 0 = Funciones.empty( c_Compras.FPERSON )
	left join ZooLogic.IMPNDCOMP as c_IVA on c_IVA.CODIGO = c_Compras.CODIGO
 where ( not 1 = funciones.empty( c_Compras.codigo ) )
 union all
	select 'IVA' as Origen, c_Compras.CODIGO, c_proveedor.CLCOD as fperson, 0 as fimpuesto,'' as moneda ,c_Compras.PTOVENTA as FPTOVEN,c_Compras.NROLIQ as FNUMCOMP,
	case when c_Compras.FECHALIQ = '01/01/1900 00:00:00' then null else c_Compras.FECHALIQ end as FFCH,'' as FLETRA, c_Compras.BDALTAFW, c_Compras.BDMODIFW, c_Compras.ESTTRANS,
	c_Compras.FALTAFW, c_Compras.FECEXPO, c_Compras.FECIMPO, c_Compras.FMODIFW, c_Compras.FECTRANS, c_Compras.HALTAFW, c_Compras.HORAEXPO,c_Compras.HORAIMPO,c_Compras.HMODIFW,
	c_Compras.SALTAFW,c_Compras.SMODIFW,c_Compras.UALTAFW,c_Compras.UMODIFW,c_Compras.VALTAFW,c_Compras.VMODIFW,c_Compras.ZADSFW,-1.00 as SIGNOMOV, 999 as FACTTIPO,
	cast( c_Compras.subtotal *-1 as numeric( 15, 4 ) ) as FSUBTON, cast( c_liq.IVAMONNG as numeric(15,2) ) as IVAMONNG,cast( c_liq.ivamonto as numeric( 15, 4 ) ) as IVAMONTO,
	cast( c_liq.ivaporcent as numeric( 5, 2 ) ) as IVAPORCENT, c_Compras.totalliq as FTOTAL
from zoologic.liqmensual as c_compras
	left join Zoologic.IMPLIQMEN as c_liq on c_compras.codigo = c_liq.codigo 
	left join ZooLogic.OPETAR as c_opetar on c_opetar.CODIGO = c_Compras.OPERADORA 
	left join ZooLogic.PROV as c_proveedor on c_proveedor.CLCOD = c_opetar.PROVEEDOR	
	) as c_Compras

	left join ZooLogic.PROV as C_PROVEEDOR on C_PROVEEDOR.CLCOD = c_Compras.FPERSON and 0 = Funciones.empty( c_Compras.FPERSON )
 where ( not 1 = funciones.empty( c_Compras.codigo ) )
 
 
 union all


 select 'RETPER' as origen,
	cast( funciones.padr( @BaseDeDatos, 8, ' ' ) + funciones.padr( c_itemcdrimpuestos.codigo, 38, ' ' ) as varchar( 46 ) ) as _Grupo,
	@BaseDeDatos as _BD,
	c_ITEMCDRIMPUESTOS.CODIGO as Codigo,
	c_ITEMCDRIMPUESTOS.CONVMULTI as ConvMulti,
	c_ITEMCDRIMPUESTOS.PORCONVMUL as PorConvMul,
	c_ITEMCDRIMPUESTOS.PORCBASE as PorcBase,
	c_ITEMCDRIMPUESTOS.MONTOBASE  as MontoBase,	
	c_ITEMCDRIMPUESTOS.BASECALC as BaseCalc,
	c_ITEMCDRIMPUESTOS.REGIMENIMP as RegimenImp,
	c_ITEMCDRIMPUESTOS.MINIMO as Minimo,
	c_ITEMCDRIMPUESTOS.MINNOIMP as MinNoImp,
	c_ITEMCDRIMPUESTOS.MONTOORIGE as MontoOrige,	-- ver PRC
	c_ITEMCDRIMPUESTOS.REGIMDESCR as RegimDescr,
	c_ITEMCDRIMPUESTOS.JURISDETA as JurisDeta,
	c_ITEMCDRIMPUESTOS.RESOLDETA as ResolDeta,
	c_ITEMCDRIMPUESTOS.MINNOIMPO as MinNoImpo,
	c_ITEMCDRIMPUESTOS.PORCENTAJE as Porcentaje,
	C_COMPROBANTEDERETENCIONES.CODIGO as CR_CODIGO,
	C_COMPROBANTEDERETENCIONES.DESPROV as CR_DesProv,
	C_COMPROBANTEDERETENCIONES.MONEDA as CR_Moneda,
	case when C_IMPUESTO8000.aplicacion = 'RTN' then C_COMPROBANTEDERETENCIONES.PTOVENTA else c_Total.fptoven end as CR_PtoVenta,
	case when C_IMPUESTO8000.aplicacion = 'RTN' then C_COMPROBANTEDERETENCIONES.NUMERO else c_Total.fnumcomp end as CR_Numero,
	case when c_comprobantederetenciones.fecha = '01/01/1900 00:00:00' then null else c_comprobantederetenciones.fecha end as CR_Fecha,
	case when C_IMPUESTO8000.aplicacion = 'RTN' then C_COMPROBANTEDERETENCIONES.LETRAOP else c_Total.fletra end as CR_LetraOP,
	case when C_IMPUESTO8000.aplicacion = 'RTN' then C_COMPROBANTEDERETENCIONES.PTOVENOP else c_Total.fptoven end as CR_PtoVenOP,
	case when C_IMPUESTO8000.aplicacion = 'RTN' then C_COMPROBANTEDERETENCIONES.NUMOP else c_Total.fnumcomp end as CR_NumOP,
	case when C_IMPUESTO8000.aplicacion = 'RTN' then c_op.ftotal else c_Total.FTOTAL end as CR_CRTotal, 
	C_COMPROBANTEDERETENCIONES.OBS as CR_Obs,
	c_ITEMCDRIMPUESTOS.NROITEM as NROITEM,
	C_COMPROBANTEDERETENCIONES.BDALTAFW as CR_BDALTAFW,
	C_COMPROBANTEDERETENCIONES.BDMODIFW as CR_BDMODIFW,
	C_COMPROBANTEDERETENCIONES.ESTTRANS as CR_ESTTRANS,
	case when c_comprobantederetenciones.faltafw = '01/01/1900 00:00:00' then null else c_comprobantederetenciones.faltafw end as CR_FALTAFW,
	case when c_comprobantederetenciones.fecexpo = '01/01/1900 00:00:00' then null else c_comprobantederetenciones.fecexpo end as CR_FECEXPO,
	case when c_comprobantederetenciones.fecimpo = '01/01/1900 00:00:00' then null else c_comprobantederetenciones.fecimpo end as CR_FECIMPO,
	case when c_comprobantederetenciones.fmodifw = '01/01/1900 00:00:00' then null else c_comprobantederetenciones.fmodifw end as CR_FMODIFW,
	case when c_comprobantederetenciones.fectrans = '01/01/1900 00:00:00' then null else c_comprobantederetenciones.fectrans end as CR_FECTRANS,
	C_COMPROBANTEDERETENCIONES.HALTAFW as CR_HALTAFW,
	C_COMPROBANTEDERETENCIONES.HORAEXPO as CR_HORAEXPO,
	C_COMPROBANTEDERETENCIONES.HORAIMPO as CR_HORAIMPO,
	C_COMPROBANTEDERETENCIONES.HMODIFW as CR_HMODIFW,
	C_COMPROBANTEDERETENCIONES.SALTAFW as CR_SALTAFW,
	C_COMPROBANTEDERETENCIONES.SMODIFW as CR_SMODIFW,
	C_COMPROBANTEDERETENCIONES.UALTAFW as CR_UALTAFW,
	C_COMPROBANTEDERETENCIONES.UMODIFW as CR_UMODIFW,
	C_COMPROBANTEDERETENCIONES.VALTAFW as CR_VALTAFW,
	C_COMPROBANTEDERETENCIONES.VMODIFW as CR_VMODIFW,
	C_COMPROBANTEDERETENCIONES.ZADSFW as CR_ZADSFW,
	cast( funciones.obtenercodigodesucursaldeunabase(@BaseDeDatos) as varchar( 10 ) ) as _SUCURSAL,
	c_ITEMCDRIMPUESTOS.CODIMP as CodImp,
	C_IMPUESTO8000.TIPO as IMPUESTO8000_tipo,
	C_IMPUESTO8000.APLICACION as IMPUESTO8000_aplicacion,
	C_COMPROBANTEDERETENCIONES.SIGNO as IMPUESTO8000_8000_SignoVirtual,
	C_COMPROBANTEDERETENCIONES.FACTTIPO as CR_1_TipoComprobanteVirtual,
	C_COMPROBANTEDERETENCIONES.PROV as CR_Prov,
	cast( funciones.alltrim(c_comprobantederetenciones.letraop)+' '+funciones.padl(c_comprobantederetenciones.ptovenop, 4, '0')+'-'+funciones.padl(c_comprobantederetenciones.numop, 8, '0') as varchar( 20 ) ) as CR_1_OCVirtual,
	c_ITEMCDRIMPUESTOS.MONTO as Monto,
	C_COMPROBANTEDERETENCIONES.FECHAEMI as CR_FechaEmisionVirtual,
	C_IMPUESTO8000.DESCRIP as IMPUESTO8000_descrip,
	C_TIPOIMPUESTO.DECRIP as TIPOIMPUESTO_Decrip,
	C_IMPUESTO64.CODIGO as IMPUESTO64_codigo,
	C_IMPUESTO65.CODIGO as IMPUESTO65_codigo,
	C_IMPUESTO66.CODIGO as IMPUESTO66_codigo,
	C_IMPUESTO8000.CODIGO as IMPUESTO8000_codigo,
	C_PROVEEDOR.CLCOD as PROVEEDOR_CLCOD,
	c_proveedor.cliva as PROVEEDOR_CLIVA,
	C_TIPOIMPUESTO.CODIGO as TIPOIMPUESTO_Codigo,
	c_ITEMCDRIMPUESTOS.sirecert as SIRECERT,
	c_ITEMCDRIMPUESTOS.SIRECS as SIRECS
 from Listados.VistaIntegral_RetYPerComprasDet as c_ITEMCDRIMPUESTOS
 left join Listados.VistaIntegral_RetYPerCompras as C_COMPROBANTEDERETENCIONES on C_COMPROBANTEDERETENCIONES.CODIGO = c_ITEMCDRIMPUESTOS.CODIGO and C_COMPROBANTEDERETENCIONES.TIPOIMP = c_ITEMCDRIMPUESTOS.tipoimp and C_COMPROBANTEDERETENCIONES.NROITEM = ( case when C_COMPROBANTEDERETENCIONES.facttipo != 31 then  c_ITEMCDRIMPUESTOS.NROITEM else 1 end ) and 0 = Funciones.empty( c_ITEMCDRIMPUESTOS.CODIGO )
 left join ZooLogic.ORDPAGO c_op on c_op.FPERSON = C_COMPROBANTEDERETENCIONES.prov and c_op.fletra = C_COMPROBANTEDERETENCIONES.letraop and c_op.fptoven = C_COMPROBANTEDERETENCIONES.ptovenop and c_op.fnumcomp = C_COMPROBANTEDERETENCIONES.numop
 left join ZooLogic.IMPUESTO as C_IMPUESTO8000 on C_IMPUESTO8000.CODIGO = c_ITEMCDRIMPUESTOS.CODIMP and 0 = Funciones.empty( c_ITEMCDRIMPUESTOS.CODIMP )
 left join ZooLogic.PROV as C_PROVEEDOR on C_PROVEEDOR.CLCOD = C_COMPROBANTEDERETENCIONES.PROV and 0 = Funciones.empty( C_COMPROBANTEDERETENCIONES.PROV )
 left join ZooLogic.TIPOIMP as C_TIPOIMPUESTO on C_TIPOIMPUESTO.CODIGO = C_IMPUESTO8000.TIPO and 0 = Funciones.empty( C_IMPUESTO8000.TIPO )
 left join ZooLogic.CONDPAGO as C_CONDICIONDEPAGO on C_CONDICIONDEPAGO.CLCOD = C_PROVEEDOR.CLCONDPAG and 0 = Funciones.empty( C_PROVEEDOR.CLCONDPAG )
 left join ZooLogic.SIPRIBDATADIC as C_DATOSADICIONALESSIPRIB on C_DATOSADICIONALESSIPRIB.CODIGO = C_PROVEEDOR.CLSIPRIB and 0 = Funciones.empty( C_PROVEEDOR.CLSIPRIB )
 left join ZooLogic.IMPUESTO as C_IMPUESTO64 on C_IMPUESTO64.CODIGO = C_PROVEEDOR.CLRETGAN and 0 = Funciones.empty( C_PROVEEDOR.CLRETGAN )
 left join ZooLogic.IMPUESTO as C_IMPUESTO65 on C_IMPUESTO65.CODIGO = C_PROVEEDOR.CLRETSUSS and 0 = Funciones.empty( C_PROVEEDOR.CLRETSUSS )
 left join ZooLogic.IMPUESTO as C_IMPUESTO66 on C_IMPUESTO66.CODIGO = C_PROVEEDOR.CLRETIVA and 0 = Funciones.empty( C_PROVEEDOR.CLRETIVA )
 left join ( select codigo, ftotal, fsubtot, FLETRA,FPTOVEN, FNUMCOMP from Zoologic.FACCOMPRA union all select codigo, ftotal, fsubtot,FLETRA,FPTOVEN, FNUMCOMP from Zoologic.NCCOMPRA union all select codigo,ftotal,fsubtot, FLETRA,FPTOVEN,FNUMCOMP from Zoologic.NDCompra) as c_Total 
	on c_Total.codigo = c_ITEMCDRIMPUESTOS.CODIGO and 0 = Funciones.empty( c_ITEMCDRIMPUESTOS.CODIGO )
 where ( 1=1 )

 union all
  
 Select 'RETPER' as origen,
	cast( funciones.padr( @BaseDeDatos, 8, ' ' ) + funciones.padr( c_liqretper.CCOD, 38, ' ' ) as varchar( 46 ) ) as _Grupo,
	@BaseDeDatos as _BD,
	c_liqretper.CCOD as Codigo,
	0 as ConvMulti,
	0 as PorConvMul,
	0 as PorcBase,
	0  as MontoBase,	
	c_impuesto.BASECALC as BaseCalc,
	c_impuesto.REGIMENIMP as RegimenImp,
	c_impuesto.MINIMO as Minimo,
	0 as MinNoImp,
	0 as MontoOrige,	-- ver PRC
	'' as RegimDescr,
	c_impuesto.JURISDICCI as JurisDeta,
	c_impuesto.RESOLU as ResolDeta,
	0 as MinNoImpo,
	c_impuesto.porcentaje  as Porcentaje,
	c_liqmensual.CODIGO as CR_CODIGO,
	c_proveedor.descfw as CR_DesProv,
	'' as CR_Moneda,
	c_liqmensual.PTOVENTA as CR_PtoVenta,
	c_liqmensual.NROLIQ as CR_Numero,
	case when c_liqmensual.FECHALIQ = '01/01/1900 00:00:00' then null else c_liqmensual.FECHALIQ end as CR_Fecha,
	'' as CR_LetraOP,
	c_liqmensual.PTOVENTA as CR_PtoVenOP,
	c_liqmensual.NROLIQ as CR_NumOP,
	c_liqmensual.TOTALLIQ as CR_CRTotal, 
	'' as CR_Obs,
	c_liqretper.NROITEM as NROITEM,
	c_liqmensual.BDALTAFW as CR_BDALTAFW,
	c_liqmensual.BDMODIFW as CR_BDMODIFW,
	c_liqmensual.ESTTRANS as CR_ESTTRANS,
	case when c_liqmensual.faltafw = '01/01/1900 00:00:00' then null else c_liqmensual.faltafw end as CR_FALTAFW,
	case when c_liqmensual.fecexpo = '01/01/1900 00:00:00' then null else c_liqmensual.fecexpo end as CR_FECEXPO,
	case when c_liqmensual.fecimpo = '01/01/1900 00:00:00' then null else c_liqmensual.fecimpo end as CR_FECIMPO,
	case when c_liqmensual.fmodifw = '01/01/1900 00:00:00' then null else c_liqmensual.fmodifw end as CR_FMODIFW,
	case when c_liqmensual.fectrans = '01/01/1900 00:00:00' then null else c_liqmensual.fectrans end as CR_FECTRANS,
	c_liqmensual.HALTAFW as CR_HALTAFW,
	c_liqmensual.HORAEXPO as CR_HORAEXPO,
	c_liqmensual.HORAIMPO as CR_HORAIMPO,
	c_liqmensual.HMODIFW as CR_HMODIFW,
	c_liqmensual.SALTAFW as CR_SALTAFW,
	c_liqmensual.SMODIFW as CR_SMODIFW,
	c_liqmensual.UALTAFW as CR_UALTAFW,
	c_liqmensual.UMODIFW as CR_UMODIFW,
	c_liqmensual.VALTAFW as CR_VALTAFW,
	c_liqmensual.VMODIFW as CR_VMODIFW,
	c_liqmensual.ZADSFW as CR_ZADSFW,
	cast( funciones.obtenercodigodesucursaldeunabase(@BaseDeDatos) as varchar( 10 ) ) as _SUCURSAL,
	c_liqretper.CODIMP as CodImp,
	C_IMPUESTO.TIPO as IMPUESTO8000_tipo,
	c_impuesto.aplicacion as IMPUESTO8000_aplicacion,
	1 as IMPUESTO8000_8000_SignoVirtual,
	999 as CR_1_TipoComprobanteVirtual,
	c_proveedor.clcod as CR_Prov,
	cast( funciones.padl(c_liqmensual.PTOVENTA, 4, '0')+'-'+funciones.padl(c_liqmensual.NROLIQ, 15, '0') as varchar( 20 ) ) as CR_1_OCVirtual,
	c_liqretper.MONTO as Monto,
	c_liqmensual.FECHALIQ as CR_FechaEmisionVirtual,
	C_IMPUESTO.DESCRIP as IMPUESTO8000_descrip,
	C_TIPOIMPUESTO.DECRIP as TIPOIMPUESTO_Decrip,
	'' as IMPUESTO64_codigo,
	'' as IMPUESTO65_codigo,
	'' as IMPUESTO66_codigo,
	C_IMPUESTO.CODIGO as IMPUESTO8000_codigo,
	c_proveedor.clcod as PROVEEDOR_CLCOD,
	c_proveedor.cliva as PROVEEDOR_CLIVA,
	C_TIPOIMPUESTO.CODIGO as TIPOIMPUESTO_Codigo
	, cast( '' as varchar(25)) as SIRECERT
	, cast( '' as varchar(4)) as SIRECS
from ZooLogic.IMPLIQMENCOM as c_liqretper
	LEFT JOIN ZOOLOGIC.IMPUESTO as c_impuesto on c_impuesto.codigo = c_liqretper.CODIMP and 0 = Funciones.empty( c_liqretper.codimp ) 
	left join zoologic.liqmensual as c_liqmensual on c_liqmensual.codigo = c_liqretper.ccod and 0 = Funciones.empty( c_liqretper.ccod ) 
	left join ZooLogic.TIPOIMP as C_TIPOIMPUESTO on C_TIPOIMPUESTO.CODIGO = C_IMPUESTO.TIPO and 0 = Funciones.empty( C_IMPUESTO.TIPO )
 	left join ZooLogic.OPETAR as c_opetar on c_opetar.CODIGO = c_liqmensual.OPERADORA 
	left join ZooLogic.PROV as c_proveedor on c_proveedor.CLCOD = c_opetar.PROVEEDOR	
 where ( 1=1 )
) 
 
