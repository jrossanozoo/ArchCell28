/*------------------------------------------------------------------------------------------------------------------------*/
-- Create date: <Junio'19>
-- Description:	<Vista para omptimizar el uso de la tabla COMB>
/*------------------------------------------------------------------------------------------------------------------------*/

if object_id(N'[Listados].[CombinacionesConStockYSusComprometidos]') is not null drop view [Listados].[CombinacionesConStockYSusComprometidos]
if object_id(N'[Listados].[Vista_COMBExtendida]') is not null drop view [Listados].[Vista_COMBExtendida];
if object_id(N'[Funciones].[PropagarPreciosATodasLasCombinaciones]') is not null drop function [Funciones].[PropagarPreciosATodasLasCombinaciones];
GO;

/*------------------------------------------------------------------------------------------------------------------------*/

CREATE VIEW [Listados].[Vista_COMBExtendida] AS
(
	select 
		coalesce( tc.COART, ar.ARTCOD ) as COART
		, coalesce( tc.COCOL, '' ) as COCOL
		, coalesce( tc.TALLE, '' ) as TALLE
		, tc.COCOD
		, tc.CORIG
		, tc.CORIGPEDCO
		, tc.CORIGPEDID
		, tc.CORIGPRESU
		, tc.DESCFW
		, tc.COCANT
		, tc.ENTRANSITO
		, tc.ENTREGAPEN
		, tc.PEDCOMP
		, tc.PEDIDO
		, tc.PRESUPUEST
		, tc.MAXREPO
		, tc.MINREPO
		, tc.BDALTAFW
		, tc.BDMODIFW
		, tc.ESTTRANS
		, tc.FALTAFW
		, tc.FECEXPO
		, tc.FECIMPO
		, tc.FMODIFW
		, tc.FECTRANS
		, tc.HALTAFW
		, tc.HORAEXPO
		, tc.HORAIMPO
		, tc.HMODIFW
		, tc.SALTAFW
		, tc.SMODIFW
		, tc.UALTAFW
		, tc.UMODIFW
		, tc.VALTAFW
		, tc.VMODIFW
		, tc.ZADSFW
		, tc.CORIGSENIA
		, tc.SENIADO
		, tc.PREPARADO
		, coalesce( vta.AFESALDO, 0.0 ) COMPVTA
		, coalesce( cpr.AFESALDO, 0.0 ) COMPCPR
		, ar.ARTDES
		, ar.CATEARTI
		, ar.CLASIFART
		, ar.FAMILIA
		, ar.GRUPO
		, ar.LINEA
		, ar.MAT
		, ar.ATEMPORADA
		, ar.TIPOARTI
		, ar.ARTFAB
		, ar.UNIMED
		, ar.PALCOL
		, cast( dp.ORDEN as numeric( 3, 0 ) ) ORDENPALCOL
		, ar.CURTALL
		, cast( dc.ORDEN as numeric( 3, 0 ) ) ORDENCURTALL
		, ar.ARTNARBA
		, ar.ASTOCK
		, ar.BLOQREG
	from
		(
			select 
				ARTCOD
				, ARTDES
				, CATEARTI
				, CLASIFART
				, FAMILIA
				, GRUPO
				, LINEA
				, MAT
				, ATEMPORADA
				, TIPOARTI
				, ARTFAB
				, UNIMED
				, coalesce( art.PALCOL, grp.PALCOL ) PALCOL
				, coalesce( art.CURTALL, grp.CURTALL ) CURTALL
				, ARTNARBA
				, ASTOCK
				, BLOQREG
			from ZooLogic.ART art
			left join [ZooLogic].[GRUPO] grp on grp.COD = art.GRUPO
		) ar
		left join (
					select
						row_number() over( partition by COART, COCOL, TALLE order by COCOD desc ) Prioridad
						, COART, COCOL, TALLE, COCOD, CORIG, CORIGPEDCO, CORIGPEDID, CORIGPRESU, DESCFW, COCANT, ENTRANSITO, ENTREGAPEN, PEDCOMP, PEDIDO, PRESUPUEST, MAXREPO, MINREPO, BDALTAFW, BDMODIFW, ESTTRANS, FALTAFW, FECEXPO, FECIMPO, FMODIFW, FECTRANS, HALTAFW, HORAEXPO, HORAIMPO, HMODIFW, SALTAFW, SMODIFW, UALTAFW, UMODIFW, VALTAFW, VMODIFW, ZADSFW, CORIGSENIA, SENIADO, PREPARADO
					from
						(
						select COART, COCOL, TALLE, COCOD, CORIG, CORIGPEDCO, CORIGPEDID, CORIGPRESU, DESCFW, COCANT, ENTRANSITO, ENTREGAPEN, PEDCOMP, PEDIDO, PRESUPUEST, MAXREPO, MINREPO, BDALTAFW, BDMODIFW, ESTTRANS, case when faltafw = '01/01/1900 00:00:00' then null else faltafw end as FALTAFW, case when fecexpo = '01/01/1900 00:00:00' then null else fecexpo end as FECEXPO, case when fecimpo = '01/01/1900 00:00:00' then null else fecimpo end as FECIMPO, case when fmodifw = '01/01/1900 00:00:00' then null else fmodifw end as FMODIFW, case when fectrans = '01/01/1900 00:00:00' then null else fectrans end as FECTRANS, HALTAFW, HORAEXPO, HORAIMPO, HMODIFW, SALTAFW, SMODIFW, UALTAFW, UMODIFW, VALTAFW, VMODIFW, cast( ZADSFW as varchar(max)) ZADSFW, CORIGSENIA, SENIADO, PREPARADO from ZooLogic.COMB
						union
						select ARTICULO, CCOLOR, TALLE, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null from ZooLogic.PRECIOAR
						) cmb
				) tc on ar.ARTCOD = tc.COART and tc.Prioridad = 1
		left join [ZooLogic].[DCTALLE] dc on dc.CODIGO = ar.CURTALL and dc.CODTALL = tc.TALLE
		left join [ZooLogic].[DPCOLOR] as dp on dp.CODIGO = ar.PALCOL and dp.CODCOL = tc.COCOL
		LEFT JOIN (
					select det.FART, det.CCOLOR, det.TALLE, sum( det.AFESALDO ) AFESALDO 
					from ( select CODIGO, FART, CCOLOR, TALLE, AFESALDO from Zoologic.COMPROBANTEVDET where AFESALDO > 0 ) as det 
						inner join ( select CODIGO from ZooLogic.COMPROBANTEV where FACTTIPO = 23 ) as cab on det.CODIGO = cab.CODIGO
					group by det.FART, det.CCOLOR, det.TALLE
					) vta ON tc.COART = vta.FART AND tc.COCOL = vta.CCOLOR	AND tc.TALLE = vta.TALLE
		LEFT JOIN (
					select det.FART, det.FCOLO, det.FTALL, sum( det.AFESALDO ) AFESALDO
					from Zoologic.PEDCOMPRADET as det
					where det.AFESALDO > 0
					group by det.FART, det.FCOLO, det.FTALL
				  ) cpr ON tc.COART = cpr.FART AND tc.COCOL = cpr.FCOLO AND tc.TALLE = CPR.FTALL
)
GO;

/*------------------------------------------------------------------------------------------------------------------------*/

CREATE FUNCTION [Funciones].[PropagarPreciosATodasLasCombinaciones]
(
	@Vigencia as datetime,
	@PreciosEnCero bit
)
RETURNS TABLE
AS
/*
	El script de esta función se declara dentro del archivo donde se define la vista listados.Vista_COMBExtendida en la carpeta
	ScriptDB con el nombre SUCURSAL.8-Listados.Vista_COMBExtendida.sql
*/
RETURN
(
Select case when EsVigenteFecha = 1 and ( Timestampa = TimestampaMasReciente2 )  then 1 else 0 end as EsVigente, * from (
	Select 
		DatosBase.CODIGO,
		DatosBase.articulo,
		DatosBase.ccolor,
		DatosBase.talle,
		DatosBase.listapre,
		DatosBase.LPR_NOMBRE,
		DatosBase.pdirecto,
		Case when DatosBase.pdirecto = 0 then @PreciosEnCero else 1 end as Mostrar,
		case when codigo is null or PDIRECTO = 0 then funciones.ObtenerVigenciaDelPrecioDeLaCombinacion( DatosBase.articulo, DatosBase.ccolor, DatosBase.Talle, DatosBase.listapre, @Vigencia ) else FECHAVIG end as FECHAVIG,
		case when ( Diferencia = FechaVigMasReciente ) then 1 else 0 end as EsVigenteFecha,
		max( case when coalesce( FECHAVIG, getdate() ) <= getdate() then coalesce( TIMESTAMPA, 0 ) else null end ) over ( partition by case when ( Diferencia = FechaVigMasReciente ) then 1 else 0 end, articulo, ccolor, talle, listapre ) as TimestampaMasReciente2,
		DatosBase.Timestampa,
		DatosBase.OBS,
		DatosBase.BDALTAFW,
		DatosBase.BDMODIFW,
		DatosBase.ESTTRANS,
		DatosBase.FALTAFW,
		DatosBase.FECEXPO,
		DatosBase.FECIMPO,
		DatosBase.FMODIFW,
		DatosBase.FECTRANS,
		DatosBase.HALTAFW,
		DatosBase.HORAEXPO,
		DatosBase.HORAIMPO,
		DatosBase.HMODIFW,
		DatosBase.SALTAFW,
		DatosBase.SMODIFW,
		DatosBase.UALTAFW,
		DatosBase.UMODIFW,
		DatosBase.VALTAFW,
		DatosBase.VMODIFW,
		DatosBase.ZADSFW,
		DatosBase.PCALCULADO,
		DatosBase.ListaBase
	from (
		select 
				PRECIOAR.CODIGO, 
				COMB2.articulo, 
				COMB2.ccolor, 
				COMB2.talle, 
				COMB2.listapre,
				COMB2.lpr_nombre,
				case when codigo is null or PDIRECTO = 0 then funciones.ObtenerPrecioDeLaCombinacionConVigencia( COMB2.articulo, COMB2.ccolor, COMB2.Talle, COMB2.listapre, @Vigencia, default ) else pdirecto end as pdirecto,
				PRECIOAR.FECHAVIG,
				cast( case when coalesce(PRECIOAR.FECHAVIG, @Vigencia) <= @Vigencia then COALESCE(PRECIOAR.FECHAVIG - @Vigencia, 0) else null end as int ) as Diferencia,
				cast( max( case when coalesce( PRECIOAR.FECHAVIG, @Vigencia ) <= @Vigencia then COALESCE( PRECIOAR.FECHAVIG - @Vigencia, 0 ) else null end ) over ( partition by COMB2.articulo, COMB2.ccolor, COMB2.talle, COMB2.listapre ) as int ) as FechaVigMasReciente,
				coalesce( PRECIOAR.TIMESTAMPA, 0 ) as Timestampa,
				max( case when coalesce( PRECIOAR.FECHAVIG, @Vigencia ) <= @Vigencia then coalesce( PRECIOAR.TIMESTAMPA, 0 ) else null end ) over ( partition by COMB2.articulo, COMB2.ccolor, COMB2.talle, COMB2.listapre ) as TimestampaMasReciente,
				PRECIOAR.OBS,
				PRECIOAR.BDALTAFW,
				PRECIOAR.BDMODIFW,
				PRECIOAR.ESTTRANS,
				PRECIOAR.FALTAFW,
				PRECIOAR.FECEXPO,
				PRECIOAR.FECIMPO,
				PRECIOAR.FMODIFW,
				PRECIOAR.FECTRANS,
				PRECIOAR.HALTAFW,
				PRECIOAR.HORAEXPO,
				PRECIOAR.HORAIMPO,
				PRECIOAR.HMODIFW,
				PRECIOAR.SALTAFW,
				PRECIOAR.SMODIFW,
				PRECIOAR.UALTAFW,
				PRECIOAR.UMODIFW,
				PRECIOAR.VALTAFW,
				PRECIOAR.VMODIFW,
				PRECIOAR.ZADSFW,
				COMB2.PCALCULADO,
				'' as ListaBase
		from zoologic.precioar as PRECIOAR
		right join (
			select COMB.coart as articulo, COMB.cocol as ccolor, COMB.talle, Lista.lpr_numero as listapre, Lista.lpr_nombre, Lista.PCALCULADO from listados.Vista_COMBExtendida as COMB
			cross join zoologic.LPRECIO as Lista /* Para vincular cada combinacion con una lista de precios */
		) as COMB2 on ( COMB2.articulo = PRECIOAR.ARTICULO ) and ( COMB2.ccolor = PRECIOAR.CCOLOR or PRECIOAR.CCOLOR is null ) and ( COMB2.TALLE = PRECIOAR.TALLE or PRECIOAR.TALLE is null ) and ( COMB2.listapre = PRECIOAR.listapre or PRECIOAR.LISTAPRE is null)
		
		union all
		
		select c_PRECIODEARTICULO.CODIGO,
		c_PRECIODEARTICULO.ARTICULO, 
		c_PRECIODEARTICULO.CCOLOR, 
		c_PRECIODEARTICULO.talle, 
		c_LPRECIO.LPR_NUMERO,
		c_LPRECIO.LPR_NOMBRE,
		funciones.ObtenerPrecioDeLaCombinacionConVigenciaAlMomento( c_PRECIODEARTICULO.PDIRECTO, @Vigencia, c_LPRECIO.OPERADOR, c_LPRECIO.COEFICIENT, c_LPRECIO.MonedaCoti, c_LPRECIO.TRedondeo, c_LPRECIO.Cantidad ) as pdirecto, 
		c_PRECIODEARTICULO.FECHAVIG,
		cast( case when coalesce(c_PRECIODEARTICULO.FECHAVIG, @Vigencia) <= @Vigencia then COALESCE(c_PRECIODEARTICULO.FECHAVIG - @Vigencia, 0) else null end as int ) as Diferencia,
		cast( max( case when coalesce( c_PRECIODEARTICULO.FECHAVIG, @Vigencia ) <= @Vigencia then COALESCE( c_PRECIODEARTICULO.FECHAVIG - @Vigencia, 0 ) else null end ) over ( partition by c_PRECIODEARTICULO.articulo, c_PRECIODEARTICULO.ccolor, c_PRECIODEARTICULO.talle, c_PRECIODEARTICULO.listapre ) as int ) as FechaVigMasReciente,
		coalesce( c_PRECIODEARTICULO.TIMESTAMPA, 0 ) as Timestampa,
		max( case when coalesce( c_PRECIODEARTICULO.FECHAVIG, @Vigencia ) <= @Vigencia then coalesce( c_PRECIODEARTICULO.TIMESTAMPA, 0 ) else null end ) over ( partition by c_PRECIODEARTICULO.articulo, c_PRECIODEARTICULO.ccolor, c_PRECIODEARTICULO.talle, c_PRECIODEARTICULO.listapre ) as TimestampaMasReciente,
		c_PRECIODEARTICULO.OBS,
		c_PRECIODEARTICULO.BDALTAFW,
		c_PRECIODEARTICULO.BDMODIFW,
		c_PRECIODEARTICULO.ESTTRANS,
		c_PRECIODEARTICULO.FALTAFW,
		c_PRECIODEARTICULO.FECEXPO,
		c_PRECIODEARTICULO.FECIMPO,
		c_PRECIODEARTICULO.FMODIFW,
		c_PRECIODEARTICULO.FECTRANS,
		c_PRECIODEARTICULO.HALTAFW,
		c_PRECIODEARTICULO.HORAEXPO,
		c_PRECIODEARTICULO.HORAIMPO,
		c_PRECIODEARTICULO.HMODIFW,
		c_PRECIODEARTICULO.SALTAFW,
		c_PRECIODEARTICULO.SMODIFW,
		c_PRECIODEARTICULO.UALTAFW,
		c_PRECIODEARTICULO.UMODIFW,
		c_PRECIODEARTICULO.VALTAFW,
		c_PRECIODEARTICULO.VMODIFW,
		c_PRECIODEARTICULO.ZADSFW,
		c_LPRECIO.pCalculado,
		c_LPRECIO.LISTABASE
from Zoologic.LPRECIO as c_LPRECIO
left join Zoologic.PRECIOAR as c_PRECIODEARTICULO On c_PRECIODEARTICULO.LISTAPRE = c_LPRECIO.LISTABASE 
right join (
			select COMB.coart as articulo, COMB.cocol as ccolor, COMB.talle, Lista.lpr_numero as listapre, Lista.lpr_nombre from listados.Vista_COMBExtendida as COMB
			cross join zoologic.LPRECIO as Lista /* Para vincular cada combinacion con una lista de precios */
		) as COMB2 on ( COMB2.articulo = c_PRECIODEARTICULO.ARTICULO ) and ( COMB2.ccolor = c_PRECIODEARTICULO.CCOLOR or c_PRECIODEARTICULO.CCOLOR is null ) and ( COMB2.TALLE = c_PRECIODEARTICULO.TALLE or c_PRECIODEARTICULO.TALLE is null ) and ( COMB2.listapre = c_PRECIODEARTICULO.listapre or c_PRECIODEARTICULO.LISTAPRE is null)
where c_LPRECIO.PCALCULADO = 1
	) DatosBase
) DatosFinales
Where Mostrar = 1
)




