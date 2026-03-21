IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Listados].[700_ITEMVALORES]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Listados].[700_ITEMVALORES];
GO;
CREATE FUNCTION [Listados].[700_ITEMVALORES]
( @BaseDeDatos varchar(8),
	@ITEMVALORES_FECHA_DESDE datetime,
	@ITEMVALORES_FECHA_HASTA datetime,
	@ITEMVALORES_CODIGO_CAJA_DESDE int,
	@ITEMVALORES_CODIGO_CAJA_HASTA int,
	@ITEMVALORES_HORA_DESDE char(8),
	@ITEMVALORES_HORA_HASTA char(8),
	@ITEMVALORES_CICLODECAJA char(1),
	@Parametro2 varchar(10),
	@Parametro1 varchar(60),
	@Parametro3 int
)	
RETURNS TABLE
AS
RETURN
-----------------------------------------------------------------

(   
SELECT 
		@basededatos as ITEMVALORES__BD,
		SUBCONSULTA.CicloDeCaja as ITEMVALORES_CicloDeCajaVirtual,
		SUBCONSULTA.Bloque as ITEMVALORES_BloqueVirtual,
		SUBCONSULTA.SubBloque as ITEMVALORES_SubBloqueVirtual,
		SUBCONSULTA.Concepto as ITEMVALORES_ConceptoVirtual,
		SUBCONSULTA.Moneda as ITEMVALORES_MonedaVirtual,
		SUBCONSULTA.Monto as ITEMVALORES_MontoVirtual,
		SUBCONSULTA.Divisas as ITEMVALORES_DivisasVirtual,
		SUBCONSULTA.Cantidad as ITEMVALORES_CantidadVirtual,
		SUBCONSULTA.Cotizacion as ITEMVALORES_CotizacionVirtual,
		SUBCONSULTA.PtoVenta as ITEMVALORES_PtoVentaVirtual

FROM
(
-- GRUPO A
  SELECT @Parametro1 as CicloDeCaja,'GRUPO A - Totales' as Bloque, GRUPO_A.SubBloque as SubBloque, GRUPO_A.Concepto as Concepto, '' as Moneda,GRUPO_A.MONTO as Monto, 0 as Divisas, GRUPO_A.CANTIDAD as Cantidad, 
		0 as Cotizacion, 0 as PtoVenta
  FROM 
  (
   SELECT 'GRUPO A - Totales' as SubBloque, 'Saldo de Apertura de Caja' as Concepto,
   MONTOTOT AS MONTO,
   0 AS CANTIDAD
   FROM [ZooLogic].[CAJAAUDI] as saldoa where CODIGO = @Parametro3 AND ( ( @ITEMVALORES_CODIGO_CAJA_DESDE is null and @ITEMVALORES_CODIGO_CAJA_HASTA is null) or ( NUMCAJA >= cast(@ITEMVALORES_CODIGO_CAJA_DESDE as int) AND NUMCAJA <= cast(@ITEMVALORES_CODIGO_CAJA_HASTA as int) ) )
   
   union all

   SELECT 'GRUPO A - Totales' as SubBloque, 'Factura' as Concepto,
   SUM(case when FACTTIPO IN (1,2,27,54) then TOTALES else 0 end) AS MONTO,
   SUM(CANTIDAD) AS CANTIDAD
   FROM
   (SELECT FACTTIPO, sum(SIGNOMOV * FTOTAL) as TOTALES,
	SUM(CASE WHEN FACTTIPO IN (1,2,27,54) THEN 1 ELSE 0 END) AS CANTIDAD
	FROM [ZooLogic].[COMPROBANTEV] where ( ( @Parametro1 is null ) ) OR 
										 ( ( @ITEMVALORES_CODIGO_CAJA_DESDE is null and @ITEMVALORES_CODIGO_CAJA_HASTA is null) OR 
										 ( IDCAJA >= cast(@ITEMVALORES_CODIGO_CAJA_DESDE as int) )  and ( IDCAJA <= cast(@ITEMVALORES_CODIGO_CAJA_HASTA as int) ) ) and
										 ( ( @ITEMVALORES_FECHA_DESDE is null and @ITEMVALORES_FECHA_HASTA is null) OR 
										   ( convert(datetime,cast(faltafw as char(11)) + ' ' + haltafw) >= convert(datetime,substring( @Parametro1,11,19 )) 
										    and convert(datetime,cast(faltafw as char(11)) + ' ' + haltafw) <= convert(datetime,substring( @Parametro1,33,19 )) ) )
	group by FACTTIPO) as factura

	Union all
	
	SELECT 'GRUPO A - Totales' as SubBloque, 'Nota de crédito' as Concepto, 
	SUM(case when FACTTIPO IN (3,5,28,55) then TOTALES else 0 end) AS MONTO,
    SUM(CANTIDAD) AS CANTIDAD
   FROM
   (SELECT FACTTIPO, sum(SIGNOMOV * FTOTAL) as TOTALES,
    SUM(CASE WHEN FACTTIPO IN (3,5,28,55) THEN 1 ELSE 0 END) AS CANTIDAD
	FROM [ZooLogic].[COMPROBANTEV] where ( ( @Parametro1 is null ) ) OR 
										  ( ( @ITEMVALORES_CODIGO_CAJA_DESDE is null and @ITEMVALORES_CODIGO_CAJA_HASTA is null) OR 
										  ( IDCAJA >= cast(@ITEMVALORES_CODIGO_CAJA_DESDE as int) )  and ( IDCAJA <= cast(@ITEMVALORES_CODIGO_CAJA_HASTA as int) ) ) and
										 ( ( @ITEMVALORES_FECHA_DESDE is null and @ITEMVALORES_FECHA_HASTA is null) OR 
										   ( convert(datetime,cast(faltafw as char(11)) + ' ' + haltafw) >= convert(datetime,substring( @Parametro1,11,19 )) 
										    and convert(datetime,cast(faltafw as char(11)) + ' ' + haltafw) <= convert(datetime,substring( @Parametro1,33,19 )) ) )
	group by FACTTIPO) as ncredito
		
	Union all

	SELECT 'GRUPO A - Totales' as SubBloque, 'Nota de débito' as Concepto, 
	SUM(case when FACTTIPO IN (4,6,29,56) then TOTALES else 0 end) AS MONTO,
    SUM(CANTIDAD) AS CANTIDAD
   FROM
   (SELECT FACTTIPO, sum(SIGNOMOV * FTOTAL) as TOTALES,
	SUM(CASE WHEN FACTTIPO IN (4,6,29,56) THEN 1 ELSE 0 END) AS CANTIDAD
	FROM [ZooLogic].[COMPROBANTEV] where ( ( @Parametro1 is null ) ) OR 
										 ( ( @ITEMVALORES_CODIGO_CAJA_DESDE is null and @ITEMVALORES_CODIGO_CAJA_HASTA is null) OR 
										 ( IDCAJA >= cast(@ITEMVALORES_CODIGO_CAJA_DESDE as int) )  and ( IDCAJA <= cast(@ITEMVALORES_CODIGO_CAJA_HASTA as int) ) ) and
										 ( ( @ITEMVALORES_FECHA_DESDE is null and @ITEMVALORES_FECHA_HASTA is null) OR 
										   ( convert(datetime,cast(faltafw as char(11)) + ' ' + haltafw) >= convert(datetime,substring( @Parametro1,11,19 )) 
										    and convert(datetime,cast(faltafw as char(11)) + ' ' + haltafw) <= convert(datetime,substring( @Parametro1,33,19 )) ) )
	group by FACTTIPO) as ndebito 
		
	) AS GRUPO_A  where (Grupo_A.Concepto = 'Saldo de Apertura de Caja') OR (Grupo_A.Concepto <> 'Saldo de Apertura de Caja' and GRUPO_A.MONTO <> 0)

	UNION ALL
------------------------------------------------------------------------------------------------
-- GRUPO B
--- VER QU� HAY QUE CONSIDERAR CON EL VUELTO

 SELECT @Parametro1 as CicloDeCaja,'GRUPO BC - Valores' as Bloque, GRUPO_BC.SubBloque as SubBloque, GRUPO_BC.Concepto as Concepto, '' as Moneda, GRUPO_BC.MONTO as Monto, 0 as Divisas, 0 as Cantidad,
		0 as Cotizacion, 0 as PtoVenta
  FROM 
(
SELECT ' Valores moneda local' as SubBloque, C_VAL.JJDE as Concepto, 
SUM( C_COMP.SIGNOMOV * C_VAL.PESOS ) AS MONTO
FROM [ZooLogic].[COMPROBANTEV] AS C_COMP
LEFT JOIN [ZooLogic].[VAL] AS C_VAL ON C_VAL.JJNUM = C_COMP.CODIGO
LEFT JOIN [ZooLogic].[XVAL] AS C_XVAL ON C_XVAL.CLCOD = C_VAL.JJCO 
WHERE C_COMP.FACTTIPO IN (1,2,3,5,27,28,54,55,4,6,29,56) AND C_XVAL.CLSMONET = @Parametro2 and C_VAL.PESOS <> 0 and (
	  ( ( @Parametro1 is null ) ) OR 
	   ( ( @ITEMVALORES_CODIGO_CAJA_DESDE is null and @ITEMVALORES_CODIGO_CAJA_HASTA is null) OR 
	   ( C_COMP.IDCAJA >= cast(@ITEMVALORES_CODIGO_CAJA_DESDE as int) )  and ( C_COMP.IDCAJA <= cast(@ITEMVALORES_CODIGO_CAJA_HASTA as int) ) ) and
	   ( ( @ITEMVALORES_FECHA_DESDE is null and @ITEMVALORES_FECHA_HASTA is null) OR 
	     ( convert(datetime,cast(C_COMP.faltafw as char(11)) + ' ' + C_COMP.haltafw) >= convert(datetime,substring( @Parametro1,11,19 )) 
	     and convert(datetime,cast(C_COMP.faltafw as char(11)) + ' ' + C_COMP.haltafw) <= convert(datetime,substring( @Parametro1,33,19 )) ) ) )
	    
GROUP BY C_VAL.JJDE

UNION ALL
-- GRUPO C
SELECT 'Comprobantes de caja' as SubBloque, (rtrim(ltrim(C_COMCAJ.CONCEPTO)) + ' - ' + C_CONCECAJA.DESCRIP) as Concepto,
SUM(C_COMPCAJADET.COTIZA * C_COMPCAJADET.CTOTAL * C_COMCAJ.SIGNOMOV) AS MONTO 
FROM [ZooLogic].COMCAJ AS C_COMCAJ
LEFT JOIN [ZooLogic].COMPCAJADET AS C_COMPCAJADET ON C_COMPCAJADET.CODDETVAL = C_COMCAJ.CODIGO
LEFT JOIN [ZooLogic].CONCECAJA AS C_CONCECAJA on C_CONCECAJA.CODIGO = C_COMCAJ.CONCEPTO
WHERE C_COMCAJ.CONCEPTO NOT IN ('DIFARQ','APERTURA','CIERRE') and (
	  ( ( @Parametro1 is null ) ) OR 
	  ( ( @ITEMVALORES_CODIGO_CAJA_DESDE is null and @ITEMVALORES_CODIGO_CAJA_HASTA is null) OR 
	  ( C_COMPCAJADET.IDCAJA >= cast(@ITEMVALORES_CODIGO_CAJA_DESDE as int) )  and ( C_COMPCAJADET.IDCAJA <= cast(@ITEMVALORES_CODIGO_CAJA_HASTA as int) ) ) and
										 ( ( @ITEMVALORES_FECHA_DESDE is null and @ITEMVALORES_FECHA_HASTA is null) OR 
										   ( convert(datetime,cast(C_COMCAJ.fecha as char(11)) + ' ' + C_COMCAJ.haltafw) >= convert(datetime,substring( @Parametro1,11,19 )) 
										    and convert(datetime,cast(C_COMCAJ.fecha as char(11)) + ' ' + C_COMCAJ.haltafw) <= convert(datetime,substring( @Parametro1,33,19 )) ) ) )
										   
GROUP BY (rtrim(ltrim(C_COMCAJ.CONCEPTO)) + ' - ' + C_CONCECAJA.DESCRIP)
) AS GRUPO_BC

UNION ALL
------------------------------------------------------------------------------------------------
-- GRUPO D
SELECT @Parametro1 as CicloDeCaja,'GRUPO D - Valores moneda extranjera' as Bloque, '' as SubBloque, GRUPO_D.Concepto as Concepto, GRUPO_D.Moneda as Moneda, (GRUPO_D.MONTO * GRUPO_D.jjcotiz) as Monto, 
		GRUPO_D.MONTO as Divisas, 0 as Cantidad, GRUPO_D.jjcotiz as Cotizacion, 0 as PtoVenta
  FROM (
SELECT C_VAL.JJDE as Concepto, C_XVAL.CLSMONET as Moneda, C_VAL.JJCOTIZ, SUM( C_COMP.SIGNOMOV * C_VAL.JJTOTFAC) as MONTO
FROM [ZooLogic].[COMPROBANTEV] AS C_COMP
LEFT JOIN [ZooLogic].[VAL] AS C_VAL ON C_VAL.JJNUM = C_COMP.CODIGO
LEFT JOIN [ZooLogic].[XVAL] AS C_XVAL ON C_XVAL.CLCOD = C_VAL.JJCO 
WHERE C_COMP.FACTTIPO IN (1,2,3,5,27,28,54,55,4,6,29,56) AND C_XVAL.CLSMONET <> @Parametro2 AND (
	  ( ( @Parametro1 is null ) ) OR 
	   ( ( @ITEMVALORES_CODIGO_CAJA_DESDE is null and @ITEMVALORES_CODIGO_CAJA_HASTA is null) OR 
	   ( C_COMP.IDCAJA >= cast(@ITEMVALORES_CODIGO_CAJA_DESDE as int) )  and ( C_COMP.IDCAJA <= cast(@ITEMVALORES_CODIGO_CAJA_HASTA as int) ) ) and
	   ( ( @ITEMVALORES_FECHA_DESDE is null and @ITEMVALORES_FECHA_HASTA is null) OR 
	     ( convert(datetime,cast(C_COMP.faltafw as char(11)) + ' ' + C_COMP.haltafw) >= convert(datetime,substring( @Parametro1,11,19 )) 
	     and convert(datetime,cast(C_COMP.faltafw as char(11)) + ' ' + C_COMP.haltafw) <= convert(datetime,substring( @Parametro1,33,19 )) ) ) )

GROUP BY C_VAL.JJDE,C_XVAL.CLSMONET, C_VAL.JJCOTIZ ) as GRUPO_D 

UNION ALL
------------------------------------------------------------------------------------------------
-- GRUPO E
SELECT @Parametro1 as CicloDeCaja,'GRUPO E - Diferencia de caja' as Bloque, '' as SubBloque, GRUPO_E.Concepto as Concepto, GRUPO_E.Moneda as Moneda, GRUPO_E.MONTO as Monto, GRUPO_E.Divisas as Divisas, 0 as Cantidad,
		GRUPO_E.Cotizacion as Cotizacion, 0 as PtoVenta
  FROM (
SELECT (rtrim(ltrim(C_COMCAJ.CONCEPTO)) + ' - ' + C_CONCECAJA.DESCRIP) as Concepto,C_XVAL.CLSMONET as Moneda, SUM(C_COMPCAJADET.COTIZA * C_COMPCAJADET.CTOTAL * C_COMCAJ.SIGNOMOV) AS MONTO,
sum(case when C_XVAL.CLSMONET <> @Parametro2 then ( C_COMPCAJADET.CTOTAL * C_COMCAJ.SIGNOMOV) else 0 end) as Divisas, 
(case when C_XVAL.CLSMONET <> @Parametro2 then C_COMPCAJADET.COTIZA else 0 end) as Cotizacion
FROM [ZooLogic].COMCAJ AS C_COMCAJ
LEFT JOIN [ZooLogic].COMPCAJADET AS C_COMPCAJADET ON C_COMPCAJADET.CODDETVAL = C_COMCAJ.CODIGO
LEFT JOIN [ZooLogic].CONCECAJA AS C_CONCECAJA on C_CONCECAJA.CODIGO = C_COMCAJ.CONCEPTO
LEFT JOIN [ZooLogic].[XVAL] AS C_XVAL ON C_XVAL.CLCOD = C_COMPCAJADET.CODVAL 
WHERE C_COMCAJ.CONCEPTO = 'DIFARQ' and (
	  ( ( @Parametro1 is null ) ) OR 
	  ( ( @ITEMVALORES_CODIGO_CAJA_DESDE is null and @ITEMVALORES_CODIGO_CAJA_HASTA is null) OR 
	  ( C_COMPCAJADET.IDCAJA >= cast(@ITEMVALORES_CODIGO_CAJA_DESDE as int) )  and ( C_COMPCAJADET.IDCAJA <= cast(@ITEMVALORES_CODIGO_CAJA_HASTA as int) ) ) and
										 ( ( @ITEMVALORES_FECHA_DESDE is null and @ITEMVALORES_FECHA_HASTA is null) OR 
										   ( convert(datetime,cast(C_COMCAJ.fecha as char(11)) + ' ' + C_COMCAJ.haltafw) >= convert(datetime,substring( @Parametro1,11,19 )) 
										    and convert(datetime,cast(C_COMCAJ.fecha as char(11)) + ' ' + C_COMCAJ.haltafw) <= convert(datetime,substring( @Parametro1,33,19 )) ) ) )

GROUP BY C_XVAL.CLSMONET, (rtrim(ltrim(C_COMCAJ.CONCEPTO)) + ' - ' + C_CONCECAJA.DESCRIP), C_COMPCAJADET.COTIZA ) as GRUPO_E

UNION ALL
------------------------------------------------------------------------------------------------
-- GRUPO F
SELECT @Parametro1 as CicloDeCaja,'GRUPO F - Detalle de gastos' as Bloque, '' as SubBloque, GRUPO_F.Concepto as Concepto, '' as Moneda, GRUPO_F.MONTO as Monto, GRUPO_F.Divisas as Divisas, 0 as Cantidad,
		GRUPO_F.Cotizacion as Cotizacion, 0 as PtoVenta
  FROM (
SELECT (rtrim(ltrim(C_COMCAJ.CONCEPTO)) + ' - ' + C_CONCECAJA.DESCRIP) as Concepto, (C_COMPCAJADET.COTIZA * C_COMPCAJADET.CTOTAL * C_COMCAJ.SIGNOMOV) AS MONTO,
(case when C_XVAL.CLSMONET <> @Parametro2 then ( C_COMPCAJADET.CTOTAL * C_COMCAJ.SIGNOMOV) else 0 end) as Divisas, 
(case when C_XVAL.CLSMONET <> @Parametro2 then C_COMPCAJADET.COTIZA else 0 end) as Cotizacion   
FROM [ZooLogic].COMCAJ AS C_COMCAJ
LEFT JOIN [ZooLogic].COMPCAJADET AS C_COMPCAJADET ON C_COMPCAJADET.CODDETVAL = C_COMCAJ.CODIGO
LEFT JOIN [ZooLogic].CONCECAJA AS C_CONCECAJA on C_CONCECAJA.CODIGO = C_COMCAJ.CONCEPTO
LEFT JOIN [ZooLogic].[XVAL] AS C_XVAL ON C_XVAL.CLCOD = C_COMPCAJADET.CODVAL
WHERE C_COMCAJ.CONCEPTO NOT IN ('DIFARQ','APERTURA','CIERRE') and (
	  ( ( @Parametro1 is null ) ) OR 
	  ( ( @ITEMVALORES_CODIGO_CAJA_DESDE is null and @ITEMVALORES_CODIGO_CAJA_HASTA is null) OR 
	  ( C_COMPCAJADET.IDCAJA >= cast(@ITEMVALORES_CODIGO_CAJA_DESDE as int) )  and ( C_COMPCAJADET.IDCAJA <= cast(@ITEMVALORES_CODIGO_CAJA_HASTA as int) ) ) and
										 ( ( @ITEMVALORES_FECHA_DESDE is null and @ITEMVALORES_FECHA_HASTA is null) OR 
										   ( convert(datetime,cast(C_COMCAJ.fecha as char(11)) + ' ' + C_COMCAJ.haltafw) >= convert(datetime,substring( @Parametro1,11,19 )) 
										    and convert(datetime,cast(C_COMCAJ.fecha as char(11)) + ' ' + C_COMCAJ.haltafw) <= convert(datetime,substring( @Parametro1,33,19 )) ) ) )

) as GRUPO_F 



UNION ALL
------------------------------------------------------------------------------------------------
-- GRUPO G
SELECT @Parametro1 as CicloDeCaja,'GRUPO G - Tarjetas' as Bloque, '' as SubBloque, GRUPO_G.Concepto as Concepto, '' as Moneda, GRUPO_G.MONTO as Monto, 0 as Divisas, 0 as Cantidad,
		0 as Cotizacion, 0 as PtoVenta
  FROM (
SELECT (case when C_XVAL.CLCFI = 3 then 'TOTAL VENTA TARJETAS' else 'TARJETAS REGALO RECIBIDIAS' end) AS Concepto, SUM( C_COMP.SIGNOMOV * C_VAL.PESOS) AS MONTO 
FROM [ZooLogic].[COMPROBANTEV] AS C_COMP
LEFT JOIN [ZooLogic].[VAL] AS C_VAL ON C_VAL.JJNUM = C_COMP.CODIGO
LEFT JOIN [ZooLogic].[XVAL] AS C_XVAL ON C_XVAL.CLCOD = C_VAL.JJCO 
WHERE C_COMP.FACTTIPO IN (1,2,3,5,27,28,54,55,4,6,29,56) AND C_XVAL.CLSMONET = @Parametro2 AND 
((C_XVAL.CLCFI = 3 AND C_XVAL.CLGRUP = 'TARJ' ) OR
(C_XVAL.CLCFI = 8 AND C_XVAL.CLCOD = 'VC')) and (
( ( @Parametro1 is null ) ) OR 
       ( ( @ITEMVALORES_CODIGO_CAJA_DESDE is null and @ITEMVALORES_CODIGO_CAJA_HASTA is null) OR 
	   ( C_COMP.IDCAJA >= cast(@ITEMVALORES_CODIGO_CAJA_DESDE as int) )  and ( C_COMP.IDCAJA <= cast(@ITEMVALORES_CODIGO_CAJA_HASTA as int) ) ) and
	   ( ( @ITEMVALORES_FECHA_DESDE is null and @ITEMVALORES_FECHA_HASTA is null) OR 
	     ( convert(datetime,cast(C_COMP.faltafw as char(11)) + ' ' + C_COMP.haltafw) >= convert(datetime,substring( @Parametro1,11,19 )) 
	     and convert(datetime,cast(C_COMP.faltafw as char(11)) + ' ' + C_COMP.haltafw) <= convert(datetime,substring( @Parametro1,33,19 )) ) ) )
  
GROUP BY C_XVAL.CLCFI ) AS GRUPO_G

UNION ALL
-- GRUPO H

SELECT @Parametro1 as CicloDeCaja,'GRUPO H - Por punto de venta' as Bloque,  ('Punto de Venta ' + convert(char, GRUPO_H.PtoVenta)) as SubBloque, GRUPO_H.Concepto as Concepto, '' as Moneda, 
		GRUPO_H.MONTO as Monto, 0 as Divisas, GRUPO_H.CANTIDAD as Cantidad, 0 as Cotizacion, GRUPO_H.PtoVenta as PtoVenta
  FROM (

  SELECT 'Saldo de Apertura de Caja' as Concepto, 0 as PtoVenta,
   MONTOTOT AS MONTO,
   0 AS CANTIDAD
   FROM [ZooLogic].[CAJAAUDI] as saldoa where CODIGO = @Parametro3 AND ( ( @ITEMVALORES_CODIGO_CAJA_DESDE is null and @ITEMVALORES_CODIGO_CAJA_HASTA is null) or ( NUMCAJA >= cast(@ITEMVALORES_CODIGO_CAJA_DESDE as int) AND NUMCAJA <= cast(@ITEMVALORES_CODIGO_CAJA_HASTA as int) ) )
   
   union all

  (SELECT ('Facturas P.V. ' + convert(char, FPTOVEN)) as Concepto, FPTOVEN as PtoVenta, 
  SUM(case when FACTTIPO IN (1,2,27,54) then (SIGNOMOV * FTOTAL) else 0 end) AS MONTO,
  SUM(CASE WHEN FACTTIPO IN (1,2,27,54) THEN 1 ELSE 0 END) AS CANTIDAD
  FROM [ZooLogic].[COMPROBANTEV] where ( ( @Parametro1 is null ) ) OR 
										 ( ( @ITEMVALORES_CODIGO_CAJA_DESDE is null and @ITEMVALORES_CODIGO_CAJA_HASTA is null) OR 
										 ( IDCAJA >= cast(@ITEMVALORES_CODIGO_CAJA_DESDE as int) )  and ( IDCAJA <= cast(@ITEMVALORES_CODIGO_CAJA_HASTA as int) ) ) and
										 ( ( @ITEMVALORES_FECHA_DESDE is null and @ITEMVALORES_FECHA_HASTA is null) OR 
										   ( convert(datetime,cast(faltafw as char(11)) + ' ' + haltafw) >= convert(datetime,substring( @Parametro1,11,19 )) 
										    and convert(datetime,cast(faltafw as char(11)) + ' ' + haltafw) <= convert(datetime,substring( @Parametro1,33,19 )) ) )
								
  group by FPTOVEN )

  UNION ALL

  (SELECT ('Notas de credito P.V. ' + convert(char, FPTOVEN)) as Concepto, FPTOVEN as PtoVenta, 
  SUM(case when FACTTIPO IN (3,5,28,55) then (SIGNOMOV * FTOTAL) else 0 end) AS MONTO,
  SUM(CASE WHEN FACTTIPO IN (3,5,28,55) THEN 1 ELSE 0 END) AS CANTIDAD
  FROM [ZooLogic].[COMPROBANTEV] where ( ( @Parametro1 is null ) ) OR 
										 ( ( @ITEMVALORES_CODIGO_CAJA_DESDE is null and @ITEMVALORES_CODIGO_CAJA_HASTA is null) OR 
										 ( IDCAJA >= cast(@ITEMVALORES_CODIGO_CAJA_DESDE as int) )  and ( IDCAJA <= cast(@ITEMVALORES_CODIGO_CAJA_HASTA as int) ) ) and
										 ( ( @ITEMVALORES_FECHA_DESDE is null and @ITEMVALORES_FECHA_HASTA is null) OR 
										   ( convert(datetime,cast(faltafw as char(11)) + ' ' + haltafw) >= convert(datetime,substring( @Parametro1,11,19 )) 
										    and convert(datetime,cast(faltafw as char(11)) + ' ' + haltafw) <= convert(datetime,substring( @Parametro1,33,19 )) ) )
						
  group by FPTOVEN )

   UNION ALL

  (SELECT ('Notas de debito P.V. ' + convert(char, FPTOVEN)) as Concepto, FPTOVEN as PtoVenta, 
  SUM(case when FACTTIPO IN (4,6,29,56) then (SIGNOMOV * FTOTAL) else 0 end) AS MONTO,
  SUM(CASE WHEN FACTTIPO IN (4,6,29,56) THEN 1 ELSE 0 END) AS CANTIDAD
  FROM [ZooLogic].[COMPROBANTEV] where ( ( @Parametro1 is null ) ) OR 
										 ( ( @ITEMVALORES_CODIGO_CAJA_DESDE is null and @ITEMVALORES_CODIGO_CAJA_HASTA is null) OR 
										 ( IDCAJA >= cast(@ITEMVALORES_CODIGO_CAJA_DESDE as int) )  and ( IDCAJA <= cast(@ITEMVALORES_CODIGO_CAJA_HASTA as int) ) ) and
										 ( ( @ITEMVALORES_FECHA_DESDE is null and @ITEMVALORES_FECHA_HASTA is null) OR 
										   ( convert(datetime,cast(faltafw as char(11)) + ' ' + haltafw) >= convert(datetime,substring( @Parametro1,11,19 )) 
										    and convert(datetime,cast(faltafw as char(11)) + ' ' + haltafw) <= convert(datetime,substring( @Parametro1,33,19 )) ) )
						
  group by FPTOVEN )

  ) AS GRUPO_H where (GRUPO_H.Concepto = 'Saldo de Apertura de Caja') OR (Grupo_H.Concepto <> 'Saldo de Apertura de Caja' and GRUPO_H.MONTO <> 0)
  
 
  ) as SUBCONSULTA
   where ( 1 = 1 )
   
  ) --fin
