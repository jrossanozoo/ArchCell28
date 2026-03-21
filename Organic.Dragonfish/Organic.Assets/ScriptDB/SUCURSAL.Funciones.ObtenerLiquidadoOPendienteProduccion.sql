IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerLiquidadoOPendienteProduccion]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[ObtenerLiquidadoOPendienteProduccion];
GO;

CREATE  FUNCTION [Funciones].[ObtenerLiquidadoOPendienteProduccion]
(
    @CodigoLista VARCHAR(MAX), 
    @AccionInsumos VARCHAR(MAX),
    @AccionDescartes VARCHAR(MAX)

)
RETURNS @Resultado TABLE
(
    tipoProducto VARCHAR(15),
    INSUMO VARCHAR(25),
    INSUMODET VARCHAR(100),
    CODCOLOR VARCHAR(6),
    FCOLTXT VARCHAR(50),
    CODTALLE VARCHAR(5),
    TALLEDET VARCHAR(50),
    CANTPROD NUMERIC(14,6),
    GESPRODCUR CHAR(38),
    nroitem INT,
    numero_op NUMERIC(12),
    NUMERO NUMERIC(12),
    PROCESO CHAR(15),
    TALLER CHAR(15),
    CODIGO CHAR(38), 
    INVENTORIG CHAR(15),
    INVENTDEST CHAR(15),
    ORDENDEPRO CHAR(38),
    FFCH DATETIME,
    NroCotizacion NUMERIC(12), 
    Liquidado NUMERIC(14,6),
    MontoLiquidado NUMERIC(14,2), 
    obs VARCHAR(200),
    BDALTAFW VARCHAR(8),
    BDMODIFW VARCHAR(8),
    ESTTRANS VARCHAR(20),
    faltafw DATETIME,
    fecexpo DATETIME,
    fecimpo DATETIME,
    fmodifw DATETIME,
    fectrans DATETIME,
    HALTAFW VARCHAR(8),
    HORAEXPO VARCHAR(8),
    HORAIMPO VARCHAR(8),
    HMODIFW VARCHAR(8),
    SALTAFW VARCHAR(7),
    SMODIFW VARCHAR(7),
    UALTAFW VARCHAR(100),
    UMODIFW VARCHAR(100),
    VALTAFW VARCHAR(13),
    VMODIFW VARCHAR(13),
    zadsfw VARCHAR(200),
    pendiente NUMERIC(14,6),
    costoSegunLista NUMERIC(14,2), 
    costoTotal NUMERIC(14,2),
    costoEstimadoLiquidado NUMERIC(14,2),
    costoLiquidado NUMERIC(14,2),
    costoPendiente NUMERIC(14,2),
	CodigoListaFinal VARCHAR(9)
)
AS
BEGIN

	--declare @Codigolista char(6) = 'LISTAP'
	--declare @AccionInsumos varchar(max) = '1' --> '1': INCLUIR INSUMOS; '2': no incluir insumos
	--declare @AccionDescartes varchar(max) = '1' --> '1': incluir descartes; '2': NO INCLUIR DESCARTES

    DECLARE @ListaFinal VARCHAR(MAX)

    SET @ListaFinal = 
        CASE 
            WHEN @CodigoLista IS NULL OR LTRIM(RTRIM(@CodigoLista)) = '' 
                THEN Funciones.ObtenerListaDeCostoProduccionParaListado()
            ELSE @CodigoLista
        END

    INSERT INTO @Resultado
    SELECT  
        tipoProducto, INSUMO, INSUMODET, CODCOLOR, FCOLTXT, CODTALLE, TALLEDET, CANTPROD, GESPRODCUR, nroitem,
        numero_op, NUMERO, PROCESO, TALLER, CODIGO, INVENTORIG, INVENTDEST, ORDENDEPRO, FFCH,
        NroCotizacion, Liquidado, MontoLiquidado, obs,
        BDALTAFW, BDMODIFW, ESTTRANS, faltafw, fecexpo, fecimpo, fmodifw, fectrans, HALTAFW, HORAEXPO, HORAIMPO, HMODIFW,
        SALTAFW, SMODIFW, UALTAFW, UMODIFW, VALTAFW, VMODIFW, zadsfw,
        CANTPROD - COALESCE(Liquidado, 0) AS pendiente,
        COALESCE(costo.nCostoUnitario, 0 ) AS costoSegunLista,
        coalesce(CANTPROD * costo.nCostoUnitario, 0) AS costoTotal,
        COALESCE(Liquidado, 0) * costo.nCostoUnitario AS costoEstimadoLiquidado,
        coalesce(MontoLiquidado, 0) AS costoLiquidado,
        (CANTPROD - COALESCE(Liquidado, 0)) * costo.nCostoUnitario AS costoPendiente,
		@listaFinal as CodigoListaFinal
    FROM (
        SELECT 
            'SEMIELABORADO' AS tipoProducto,
            gcurv.IDITEM,
            gcurv.INSUMO, gcurv.INSUMODET, gcurv.CODCOLOR, gcurv.FCOLTXT, gcurv.CODTALLE, gcurv.TALLEDET, gcurv.CANTPROD, gcurv.GESPRODCUR,
            gcurv.nroitem,
            oprod.NUMERO AS numero_op, gprod.NUMERO, gprod.PROCESO, gprod.TALLER, gprod.CODIGO, gprod.INVENTORIG, gprod.INVENTDEST, gprod.ORDENDEPRO, gprod.FFCH,
            cabcotiza.numero AS NroCotizacion,
            DetaLiqui.Cantidad AS Liquidado,
            DetaLiqui.Monto AS MontoLiquidado,
            CAST(gprod.OBS AS VARCHAR(200)) AS obs,
            gprod.BDALTAFW, gprod.BDMODIFW, gprod.ESTTRANS, gprod.faltafw, gprod.fecexpo, gprod.fecimpo, gprod.fmodifw, gprod.fectrans,
            gprod.HALTAFW, gprod.HORAEXPO, gprod.HORAIMPO, gprod.HMODIFW,
            gprod.SALTAFW, gprod.SMODIFW, gprod.UALTAFW, gprod.UMODIFW, gprod.VALTAFW, gprod.VMODIFW,
            CAST(gprod.ZADSFW AS VARCHAR(200)) AS zadsfw
        FROM ZOOLOGIC.GESPCURV gcurv
        LEFT JOIN ZOOLOGIC.GESTIONPROD gprod ON gcurv.GESPRODCUR = gprod.CODIGO
        LEFT JOIN ZOOLOGIC.ORDENPROD oprod ON oprod.CODIGO = gprod.ORDENDEPRO
        LEFT JOIN (
					SELECT CODIGO, GESTIONPRO, NUMERO, 
						   ROW_NUMBER() OVER (PARTITION BY GESTIONPRO ORDER BY NUMERO DESC) AS rowNum
					FROM ZooLogic.COTIZAGOP
				) AS CabCotiza ON CabCotiza.GESTIONPRO = gprod.CODIGO AND CabCotiza.rowNum = 1
        LEFT JOIN (
					SELECT IDITEM, SUM(CANTIDAD) AS Cantidad, SUM(Monto) AS Monto 
					FROM ZooLogic.LIQTPROD 
					GROUP BY IDITEM
				) AS DetaLiqui ON DetaLiqui.IDITEM = gcurv.IDITEM  --WHERE DetaLiqui.iditem IS NULL --> gestiones no liquidadas 
			
	union all

			SELECT 
            tipoProducto,
            gpins.IDITEM,
            gpins.INSUMO, gpins.cinsdet as INSUMODET, gpins.CODCOLOR, gpins.FCOLTXT, gpins.CODTALLE, gpins.ITALLETXT as TALLEDET, gpins.cantidad as CANTPROD, gpins.gesprodins as GESPRODCUR,
            gpins.nroitem,
            oprod.NUMERO AS numero_op, gprod.NUMERO, gprod.PROCESO, gprod.TALLER, gprod.CODIGO, gprod.INVENTORIG, gprod.INVENTDEST, gprod.ORDENDEPRO, gprod.FFCH,
            cabcotiza.numero AS NroCotizacion,
            DetaLiqui.Cantidad AS Liquidado,
            DetaLiqui.Monto AS MontoLiquidado,
            CAST(gprod.OBS AS VARCHAR(200)) AS obs,
            gprod.BDALTAFW, gprod.BDMODIFW, gprod.ESTTRANS, gprod.faltafw, gprod.fecexpo, gprod.fecimpo, gprod.fmodifw, gprod.fectrans,
            gprod.HALTAFW, gprod.HORAEXPO, gprod.HORAIMPO, gprod.HMODIFW,
            gprod.SALTAFW, gprod.SMODIFW, gprod.UALTAFW, gprod.UMODIFW, gprod.VALTAFW, gprod.VMODIFW,
            CAST(gprod.ZADSFW AS VARCHAR(200)) AS zadsfw
        FROM 
			( SELECT 'INSUMO' AS tipoProducto, insumo, cinsdet, codcolor, fcoltxt, codtalle, italletxt, cantidad, gesprodins, NROITEM, iditem  FROM ZOOLOGIC.GESPINS 
			  union all
			  SELECT 'INS.DESCARTADO' AS tipoProducto, insumo, cinsdet, codcolor, fcoltxt, codtalle, italletxt, cantidad, GESPRODIND as gesprodins, NROITEM, iditem  FROM ZOOLOGIC.GESPIND )  gpins
				
        LEFT JOIN ZOOLOGIC.GESTIONPROD gprod ON gpins.gesprodins = gprod.CODIGO
        LEFT JOIN ZOOLOGIC.ORDENPROD oprod ON oprod.CODIGO = gprod.ORDENDEPRO
        LEFT JOIN (
					SELECT CODIGO, GESTIONPRO, NUMERO, 
						   ROW_NUMBER() OVER (PARTITION BY GESTIONPRO ORDER BY NUMERO DESC) AS rowNum
					FROM ZooLogic.COTIZAGOP
				) AS CabCotiza ON CabCotiza.GESTIONPRO = gprod.CODIGO AND CabCotiza.rowNum = 1
        LEFT JOIN (
					SELECT IDITEM, SUM(CANTIDAD) AS Cantidad, SUM(Monto) AS Monto 
					FROM ZooLogic.LIQTINS 
					GROUP BY IDITEM
				) AS DetaLiqui ON DetaLiqui.IDITEM = gpins.IDITEM

			
	union all

			 SELECT 
            'SEMI.DESCARTADO' AS tipoProducto,
            gdesc.IDITEM,
            gdesc.INSUMO, gdesc.INSUMODET, gdesc.CODCOLOR, gdesc.FCOLTXT, gdesc.CODTALLE, gdesc.CTALLEDET AS TALLEDET, gdesc.CANTDESC AS CANTPROD, gdesc.GESPRODDES AS GESPRODCUR,
			gdesc.nroitem,
            oprod.NUMERO AS numero_op, gprod.NUMERO, gprod.PROCESO, gprod.TALLER, gprod.CODIGO, gprod.INVENTORIG, gprod.INVENTDEST, gprod.ORDENDEPRO, gprod.FFCH,
            cabcotiza.numero AS NroCotizacion,
            DetaLiqui.Cantidad AS Liquidado,
            DetaLiqui.Monto AS MontoLiquidado,
            CAST(gprod.OBS AS VARCHAR(200)) AS obs,
            gprod.BDALTAFW, gprod.BDMODIFW, gprod.ESTTRANS, gprod.faltafw, gprod.fecexpo, gprod.fecimpo, gprod.fmodifw, gprod.fectrans,
            gprod.HALTAFW, gprod.HORAEXPO, gprod.HORAIMPO, gprod.HMODIFW,
            gprod.SALTAFW, gprod.SMODIFW, gprod.UALTAFW, gprod.UMODIFW, gprod.VALTAFW, gprod.VMODIFW,
            CAST(gprod.ZADSFW AS VARCHAR(200)) AS zadsfw
        FROM ZOOLOGIC.GESPDESC gdesc
        LEFT JOIN ZOOLOGIC.GESTIONPROD gprod ON gdesc.GESPRODDES = gprod.CODIGO
        LEFT JOIN ZOOLOGIC.ORDENPROD oprod ON oprod.CODIGO = gprod.ORDENDEPRO
        LEFT JOIN (
					SELECT CODIGO, GESTIONPRO, NUMERO, 
						   ROW_NUMBER() OVER (PARTITION BY GESTIONPRO ORDER BY NUMERO DESC) AS rowNum
					FROM ZooLogic.COTIZAGOP
				) AS CabCotiza ON CabCotiza.GESTIONPRO = gprod.CODIGO AND CabCotiza.rowNum = 1
        LEFT JOIN (
					SELECT IDITEM, SUM(CANTIDAD) AS Cantidad, SUM(Monto) AS Monto 
					FROM ZooLogic.LIQTDESC 
					GROUP BY IDITEM
				) AS DetaLiqui ON DetaLiqui.IDITEM = gdesc.IDITEM

    ) AS InsumoYSemielaborado
    CROSS APPLY (
        SELECT Funciones.ObtenerCostoDeInsumoPonderado(
            @ListaFinal, insumo, PROCESO, taller, codcolor, codtalle, cantprod
        ) AS nCostoUnitario -- para llamar 1 sola vez a la función ObtenerCostoDeInsumoPonderado()
    ) AS costo
   where
			( LEFT(@AccionInsumos, 2) <> '2' OR tipoproducto not in ( 'INSUMO','INS.DESCARTADO' ) ) and
			( LEFT(@AccionDescartes, 2) <> '2' OR Tipoproducto not in ('INS.DESCARTADO', 'SEMI.DESCARTADO' ) ) 

    RETURN
END
