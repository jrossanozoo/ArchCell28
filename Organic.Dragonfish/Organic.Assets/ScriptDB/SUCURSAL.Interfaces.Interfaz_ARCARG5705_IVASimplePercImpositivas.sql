IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Interfaz_ARCARG5705_IVASimplePercImpositivas]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Interfaz_ARCARG5705_IVASimplePercImpositivas];
GO;

CREATE FUNCTION [Interfaces].[Interfaz_ARCARG5705_IVASimplePercImpositivas]
( 
	@FechaDesde varchar(10),
	@FechaHasta varchar(10),
	@FechaEmisionDesde varchar(10),
	@FechaEmisionHasta varchar(10),
	@CompFiscal bit,
	@CompManual bit,
	@CompElectr bit,
	@CompServPubA bit,
	@CompServPubB bit,
	@CompReciboA bit,
	@CompReciboC bit
)
RETURNS TABLE
AS
RETURN

(
	select 
		c_imp.regimenimp AS Regimen
		, c_compras.fcuit AS CuitAgente
		, '' AS CuitI
		,Funciones.padl( cast( year( convert( date, c_compras.FFchFac ) ) as varchar(4) ), 4, '0' ) + '-' + 
		Funciones.padl( cast( month( convert( date, c_compras.FFchFac ) ) as varchar(2) ), 2, '0' ) + '-' + 
		Funciones.padl( cast( day( convert( date, c_compras.FFchFac ) ) as varchar(2) ), 2, '0' ) as FechaPercep
		, case 
			when c_compras.TCRG1361 in (1,2,3) and c_compras.facttipo = 8 then '1' -- factura
			when c_compras.TCRG1361 in (1,2,3) and c_compras.facttipo = 10  then '3' -- n/credito
			when c_compras.TCRG1361 in (1,2,3) and c_compras.facttipo = 9  then '4' -- n/débito 
			when c_compras.TCRG1361 = 7 then '17' -- ServPubA
			when c_compras.TCRG1361 = 8 then '18' -- ServPubB
			when c_Compras.TCRG1361 = 9 then '2' -- ReciboA
			when c_Compras.TCRG1361 = 10 then '2' -- ReciboC
		end as TipoComprob -- POSIBILIDAD DE CONVERSION VALORES
		,funciones.padl( Funciones.alltrim( RIGHT(c_compras.descfw, 14)), 14, '0' )   AS NroComprob
		,replace( cast( c_PercCompras.monto as varchar(15) ), '.', ',') as Importe
		,c_compras.FFchFac
		,c_compras.FFCH
		--,c_compras.descfw as DescComprob
		--,c_compras. 
	from 
		( select Ccod, CodImp, Monto from zoologic.impfacc 
			union all select Ccod, CodImp, Monto from zoologic.impndc
			union all select Ccod, CodImp, Monto from zoologic.impncc ) c_PercCompras
	left join zoologic.IMPUESTO c_imp ON c_imp.codigo = c_PercCompras.codimp
	left join 
		 ( select codigo, fcuit, ffch, FFCHFAC, facttipo, descfw, case when funciones.empty(fptovenext) = 1 then fptoven else fptovenext end as ptoventa, fnumcomp, TCRG1361, anulado from zoologic.faccompra 
			union all select codigo, fcuit, ffch, FFCHFAC, facttipo, descfw, case when funciones.empty(fptovenext) = 1 then fptoven else fptovenext end as ptoventa, fnumcomp, TCRG1361, anulado from zoologic.nccompra 
			union all select codigo, fcuit, ffch, FFCHFAC, facttipo, descfw, case when funciones.empty(fptovenext) = 1 then fptoven else fptovenext end as ptoventa, fnumcomp, TCRG1361, anulado from zoologic.ndcompra)
			c_compras on c_compras.codigo = c_PercCompras.ccod
	
	where C_IMP.tipo ='IVA' 
		and C_IMP.aplicacion = 'PRC' 
		and c_Compras.Anulado = 0
		and case 
				when @CompFiscal = 1 and c_Compras.TCRG1361 = 3 then 1 
				when @CompManual = 1 and c_Compras.TCRG1361 = 1 then 1
				when @CompElectr = 1 and c_Compras.TCRG1361 = 2 then 1
				when @CompServPubA = 1 and c_Compras.TCRG1361 = 7 then 1
				when @CompServPubB = 1 and c_Compras.TCRG1361 = 8 then 1
				when @CompReciboA = 1 and c_Compras.TCRG1361 = 9 then 1
				when @CompReciboC = 1 and c_Compras.TCRG1361 = 10 then 1
				else 0
			end = 1
		--and c_Compras.TCRG1361 <> 5 and c_Compras.TCRG1361 <> 6 -- no se informan liquidaciones a y b
		and ( ( @FechaEmisionDesde is null ) or ( c_compras.FFchFac >= @FechaEmisionDesde ) )  
		and ( ( @FechaEmisionHasta is null ) or ( c_compras.FFchFac <= @FechaEmisionHasta ) )
		and ( ( @FechaDesde is null ) or ( c_compras.Ffch >= @FechaDesde ) ) 
		and ( ( @FechaHasta is null ) or ( c_compras.Ffch <= @FechaHasta ) )

)

