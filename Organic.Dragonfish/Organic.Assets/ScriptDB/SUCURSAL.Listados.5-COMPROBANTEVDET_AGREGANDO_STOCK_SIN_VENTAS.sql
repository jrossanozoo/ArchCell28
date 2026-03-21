IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Listados].[COMPROBANTEVDET_AGREGANDO_STOCK_SIN_VENTAS]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Listados].[COMPROBANTEVDET_AGREGANDO_STOCK_SIN_VENTAS];
GO;

CREATE FUNCTION [Listados].[COMPROBANTEVDET_AGREGANDO_STOCK_SIN_VENTAS]
(
	@PERIODOS xml
)
RETURNS TABLE
AS
RETURN
(
	with Periodos as 
	(
		select
			IDSegmento = T.Periodo.value('ID[1]', 'int'),
			Desde = T.Periodo.value('Desde[1]', 'date'),
			Hasta = T.Periodo.value('Hasta[1]', 'date') 
		from @Periodos.nodes('/Periodos/Periodo') as T(Periodo)
	)
	
	, UltimaFechaIngresoStock AS 
		(
		select
			MAX( c_adtcomb.adt_fecha ) as UltimoIngreso, 
			c_adtcomb.coart, 
			c_adtcomb.cocol, 
			c_adtcomb.talle
		from Zoologic.adt_comb as c_adtcomb
			LEFT JOIN Zoologic.mstock as c_mstock ON  c_mstock.dirmov = 1 AND  c_mstock.descfw = c_adtcomb.adt_comp
			LEFT JOIN Zoologic.faccompra as c_faccompra ON c_faccompra.signomov = -1 AND  c_faccompra.descfw = c_adtcomb.adt_comp
			LEFT JOIN Zoologic.remcompra as c_remcompra ON c_remcompra.signomov = -1 AND c_remcompra.descfw = c_adtcomb.adt_comp
		WHERE ( c_adtcomb.adt_comp like 'REMITODECOMPRA%' or c_adtcomb.adt_comp like 'FACTURADECOMPRA%' or c_adtcomb.adt_comp like 'MOVIMIENTODESTOCK%' )
			and ( c_mstock.descfw is not null or c_faccompra.descfw is not null or c_remcompra.descfw is not null ) 
		GROUP BY c_adtcomb.coart, c_adtcomb.cocol, c_adtcomb.talle
	)

	, Ventas as
	(
		select
			dvta.*, cvta.IDSegmento			
		from
			ZooLogic.COMPROBANTEVDET dvta
			inner join (select 
							CODIGO,
							Periodos.IDSegmento
						from ZooLogic.COMPROBANTEV 
							inner join periodos on FFCH between Periodos.Desde and Periodos.Hasta 
							and FACTTIPO in ( 1, 3, 4, 2, 5, 6, 27, 28, 29, 33, 35, 36, 47, 48, 49 )
						) cvta on dvta.CODIGO = cvta.CODIGO
					) 

	, Stock as
	(
	select
		csvta.COART
		, art.ARTDES
		, csvta.COCOL
		, col.COLDES
		, csvta.TALLE
		, tll.DESCRIP
		, funciones.obtenerstockdelacombinacion(csvta.COART, csvta.COCOL, csvta.TALLE) as ST_Fisico
		, funciones.obtenerstockentransitodelacombinacion(csvta.COART, csvta.COCOL, csvta.TALLE) ST_Transito
		, uf.UltimoIngreso
	from
		Zoologic.COMB as csvta
		left join Zoologic.ART as art on art.ARTCOD = csvta.COART
		left join Zoologic.COL as col on col.COLCOD = csvta.COCOL
		left join Zoologic.TALLE as tll on tll.CODIGO = csvta.TALLE
		left join UltimaFechaIngresoStock as uf on uf.coart = csvta.COART and uf.cocol = csvta.COCOL and uf.talle = csvta.TALLE
	)

	select
		Ventas.ACONDIVAV,
		Ventas.AFECANT,
		Ventas.AFELETRA,
		Ventas.AFENROITEM,
		Ventas.AFENUMCOM,
		Ventas.AFEPTOVEN,
		Ventas.AFESALDO,
		Ventas.AFETIPOCOM,
		Ventas.AFETS,
		Ventas.AFE_COD,
		Ventas.AJUCIMP,
		Ventas.AJUSIMP,
		Ventas.APORCIVAV,
		Ventas.ARTSINDES,
		coalesce( Ventas.CCOLOR, Stock.COCOL ) as CCOLOR,
		Ventas.CIDITEM,
		Ventas.CODAUTDJCP,
		Ventas.CODGTIN,
		Ventas.CODIGO,
		Ventas.CONRESTR,
		Ventas.EQUIV,
		coalesce( Ventas.FART, Stock.COART ) as FART,
		Ventas.FBRUTO,
		Ventas.FCANT,
		Ventas.FCFI,
		Ventas.FCFITOT,
		coalesce( Ventas.FCOLTXT, Stock.COLDES ) as FCOLTXT,
		Ventas.FKIT,
		Ventas.FMONTO,
		Ventas.FMTOCFI,
		Ventas.FMTODTO1,
		Ventas.FMTOIVA,
		Ventas.FN11,
		Ventas.FNETO,
		Ventas.FPORCFI,
		Ventas.FPORDTO1,
		Ventas.FPORIVA,
		Ventas.FPRECIO,
		Ventas.FPRUN,
		coalesce( Ventas.FTATXT, Stock.DESCRIP ) as FTATXT,
		coalesce( Ventas.FTXT, Stock.ARTDES ) as FTXT,
		Ventas.FUNID,
		Ventas.FX2,
		Ventas.IDITEM,
		Ventas.IDITEMORIG,
		Ventas.IMPINTERNO,
		Ventas.MNDESCI,
		Ventas.MNDESSI,
		Ventas.MNPDSI,
		Ventas.MNTDES,
		Ventas.MNTPDESCI,
		Ventas.MNTPDESSI,
		Ventas.MNTPINT,
		Ventas.MNTPIVA,
		Ventas.MNTPPER,
		Ventas.MNTPRECCI,
		Ventas.MNTPRECSI,
		Ventas.MNTPTOT,
		Ventas.MOTDESCU,
		Ventas.MOTDEVOL,
		Ventas.NROITEM,
		Ventas.PRECIOCISR,
		Ventas.PRECIOSISR,
		Ventas.PRECIOSR,
		Ventas.PROCSTOCK,
		Ventas.PRUNCONIMP,
		Ventas.PRUNSINIMP,
		Ventas.SENIACANCE,
		coalesce( Ventas.TALLE, Stock.TALLE ) as TALLE,
		Ventas.TASAIMPINT,
		Ventas.USARPLISTA,
		Ventas.IDSegmento,
		coalesce( Stock.ST_Fisico, 0 ) as ST_Fisico,
		coalesce( Stock.ST_Transito, 0) as ST_Transito,
		coalesce( Stock.UltimoIngreso, convert( date, '19000101')) as UltimoIngreso
	from
		Ventas
		full outer join Stock on Ventas.FART = Stock.COART and Ventas.CCOLOR = Stock.COCOL and Ventas.TALLE = Stock.TALLE
	where 1=1 	--Se filtran las combinaciones que tengan stock <> 0.
		and case when Ventas.FART is null --Si es uno de los registros agregados del stock entonses se verifica si tienen stock
				then sign( abs(Stock.ST_Fisico) + abs(Stock.ST_Transito) ) else 1 
			end = 1  
)