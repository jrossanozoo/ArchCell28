IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerCotizacionesPendientesProduccion]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[ObtenerCotizacionesPendientesProduccion];
GO;

CREATE FUNCTION [Funciones].[ObtenerCotizacionesPendientesProduccion]
( @CodigoLista varchar(max), 
  @AccionInsumos varchar(max),
  @AccionDescartes varchar(max) )
RETURNS TABLE
AS

RETURN
(
--declare @Codigolista char(6) = 'LISTAP'
--declare @AccionInsumos varchar(max) = '1' --> INCLUIR -- INSUMOS
--declare @AccionDescartes varchar(max) = '2' --> NO INCLUIR -- DESCARTES

	select *, 
	funciones.ObtenerCostoDeInsumoPonderado( @CodigoLista, insumo, PROCESO, taller, codcolor, codtalle, cantprod ) as costo ,
	cantprod * funciones.ObtenerCostoDeInsumoPonderado( @CodigoLista, insumo, PROCESO, taller, codcolor, codtalle, cantprod ) as monto--, codigo
	from (
		SELECT  'SEMIELABORADO' AS tipoProducto,gcurv.INSUMO, gcurv.INSUMODET, gcurv.CODCOLOR, gcurv.FCOLTXT, gcurv.CODTALLE, gcurv.TALLEDET, gcurv.CANTPROD, gcurv.GESPRODCUR, 
			gcurv.nroitem, 
			oprod.NUMERO as numero_op,
			gprod.NUMERO,
			gprod.PROCESO, gprod.TALLER, gprod.CODIGO, gprod.INVENTORIG, gprod.INVENTDEST, gprod.ORDENDEPRO, gprod.FFCH
			,cast(gprod.OBS as char(200)) as obs
			,gprod.BDALTAFW
			,gprod.BDMODIFW
			,gprod.ESTTRANS
			,gprod.faltafw
			,gprod.fecexpo
			,gprod.fecimpo
			,gprod.fmodifw
			,gprod.fectrans
			,gprod.HALTAFW
			,gprod.HORAEXPO
			,gprod.HORAIMPO
			,gprod.HMODIFW
			,gprod.SALTAFW
			,gprod.SMODIFW
			,gprod.UALTAFW
			,gprod.UMODIFW
			,gprod.VALTAFW
			,gprod.VMODIFW
			,cast(gprod.ZADSFW as char(200)) as zadsfw
			FROM ZOOLOGIC.GESPCURV gcurv
			LEFT JOIN ZOOLOGIC.GESTIONPROD gprod ON gcurv.GESPRODCUR = gprod.CODIGO
			LEFT JOIN ZOOLOGIC.ORDENPROD oprod ON oprod.CODIGO = gprod.ORDENDEPRO
			LEFT JOIN ZOOLOGIC.COTIZAGOP coti ON coti.GESTIONPRO = gprod.CODIGO
			LEFT JOIN ZOOLOGIC.COTORDPROD cotprod ON cotprod.COTIZALQPR = coti.CODIGO
			WHERE cotprod.COTIZALQPR IS NULL

		union all

		SELECT tipoProducto, gpins.INSUMO, gpins.cinsdet as INSUMODET, gpins.CODCOLOR, gpins.FCOLTXT, gpins.CODTALLE, gpins.ITALLETXT as TALLEDET, gpins.cantidad as CANTPROD,
			gpins.gesprodins as GESPRODCUR, gpins.NROITEM,
			oprod.NUMERO as numero_op,
			gprod.NUMERO,
			gprod.PROCESO, gprod.TALLER, gprod.CODIGO, gprod.INVENTORIG, gprod.INVENTDEST, gprod.ORDENDEPRO, gprod.FFCH
			,cast(gprod.OBS as char(200)) as obs
			,gprod.BDALTAFW
			,gprod.BDMODIFW
			,gprod.ESTTRANS
			,gprod.faltafw
			,gprod.fecexpo
			,gprod.fecimpo
			,gprod.fmodifw
			,gprod.fectrans
			,gprod.HALTAFW
			,gprod.HORAEXPO
			,gprod.HORAIMPO
			,gprod.HMODIFW
			,gprod.SALTAFW
			,gprod.SMODIFW
			,gprod.UALTAFW
			,gprod.UMODIFW
			,gprod.VALTAFW
			,gprod.VMODIFW
			,cast(gprod.ZADSFW as char(200)) as zadsfw
			FROM 
			( SELECT 'INSUMO' AS tipoProducto, insumo, cinsdet, codcolor, fcoltxt, codtalle, italletxt, cantidad, gesprodins, NROITEM  FROM ZOOLOGIC.GESPINS 
			  union all
			  SELECT 'INS.DESCARTADO' AS tipoProducto, insumo, cinsdet, codcolor, fcoltxt, codtalle, italletxt, cantidad, GESPRODIND as gesprodins, NROITEM  FROM ZOOLOGIC.GESPIND )  gpins
			LEFT JOIN ZOOLOGIC.GESTIONPROD gprod ON gpins.gesprodins = gprod.CODIGO
			LEFT JOIN ZOOLOGIC.ORDENPROD oprod ON oprod.CODIGO = gprod.ORDENDEPRO
			LEFT JOIN ZOOLOGIC.COTIZAGOP coti ON coti.GESTIONPRO = gprod.CODIGO
			LEFT JOIN ZOOLOGIC.COTORDINS cotordins ON cotordins.COTIZALQIN = coti.CODIGO
			WHERE cotordins.COTIZALQIN IS NULL 
			
			union all

			SELECT  'SEMI.DESCARTADO' AS tipoProducto,gdesc.INSUMO, gdesc.INSUMODET, gdesc.CODCOLOR, gdesc.FCOLTXT, gdesc.CODTALLE, gdesc.CTALLEDET AS TALLEDET, gdesc.CANTDESC AS CANTPROD, gdesc.GESPRODDES AS GESPRODCUR, 
			gdesc.nroitem, 
			oprod.NUMERO as numero_op,
			gprod.NUMERO,
			gprod.PROCESO, gprod.TALLER, gprod.CODIGO, gprod.INVENTORIG, gprod.INVENTDEST, gprod.ORDENDEPRO, gprod.FFCH
			,cast(gprod.OBS as char(200)) as obs
			,gprod.BDALTAFW
			,gprod.BDMODIFW
			,gprod.ESTTRANS
			,gprod.faltafw
			,gprod.fecexpo
			,gprod.fecimpo
			,gprod.fmodifw
			,gprod.fectrans
			,gprod.HALTAFW
			,gprod.HORAEXPO
			,gprod.HORAIMPO
			,gprod.HMODIFW
			,gprod.SALTAFW
			,gprod.SMODIFW
			,gprod.UALTAFW
			,gprod.UMODIFW
			,gprod.VALTAFW
			,gprod.VMODIFW
			,cast(gprod.ZADSFW as char(200)) as zadsfw
			FROM ZOOLOGIC.GESPDESC gdesc
			LEFT JOIN ZOOLOGIC.GESTIONPROD gprod ON gdesc.GESPRODDES = gprod.CODIGO
			LEFT JOIN ZOOLOGIC.ORDENPROD oprod ON oprod.CODIGO = gprod.ORDENDEPRO
			LEFT JOIN ZOOLOGIC.COTIZAGOP coti ON coti.GESTIONPRO = gprod.CODIGO
			LEFT JOIN ZOOLOGIC.COTORDDESC cotdesc ON cotdesc.COTIZALQDE = coti.CODIGO
			WHERE cotdesc.COTIZALQDE IS NULL

	) InsumoYSemielaborado
		where
			( LEFT(@AccionInsumos, 2) <> '2' OR tipoproducto not in ( 'INSUMO','INS.DESCARTADO' ) ) and
			( LEFT(@AccionDescartes, 2) <> '2' OR Tipoproducto not in ('INS.DESCARTADO', 'SEMI.DESCARTADO' ) ) 

)

