IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Errores_ArcibaVentas]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Errores_ArcibaVentas];
GO;


CREATE FUNCTION [interfaces].[Errores_ArcibaVentas]
( 
@FechaDesde as char(8),
@FechaHasta as char(8)
)
RETURNS TABLE
AS
RETURN 
(
	select DISTINCT * from
	(

	select 
	--La resolución del impuesto percibido debe ser de tres posiciones numéricas
		cast( convert(varchar(10), GETDATE(), 108) + ',' + ' No se exportó la ' + case when c_comprobante.FACTTIPO in (1,2,4,6,27,29,54,56) then 'Factura        : ' else 'Nota de debito : ' end  + funciones.alltrim(c_comprobante.FLETRA) + ' ' + funciones.padl(funciones.alltrim(c_comprobante.FPTOVEN),4,'0') + '-' + funciones.padl(funciones.alltrim(c_comprobante.FNUMCOMP),8,'0') + '. La resolución del impuesto percibido debe ser de tres posiciones numéricas' as varchar(250)) as RegError
	from ZooLogic.COMPROBANTEV as c_comprobante
	inner join ZooLogic.[CLI] as c_cliente on c_cliente.CLCOD = c_comprobante.FPERSON
	inner join ZooLogic.COMPROBANTEVDET as c_compdet on c_compdet.CODIGO = c_comprobante.CODIGO
	inner join ZooLogic.IMPVENTAS as c_impventas on c_impventas.CCOD  = c_comprobante.CODIGO
	inner join ZooLogic.IMPUESTO as c_impuesto on c_impuesto.CODIGO = c_impventas.CODIMP 	
	where (c_comprobante.ffch >= @FechaDesde and c_comprobante.ffch <= @FechaHasta) and c_comprobante.FACTTIPO in (1,2,4,6,27,29,54,56) and (c_comprobante.fnumcomp <> 0 and c_comprobante.anulado = 0)  and c_impventas.jurid = '901' and c_impventas.TIPOI = 'IIBB' and c_impventas.monto > 0 and( isnumeric(substring(funciones.alltrim(c_impuesto.RESOLU),1,3)) = 0  )
	
	union all
	
	select 
	--No se acepta alicuota en cero cuando el código de norma es distinto de 28 o 29
		cast( convert(varchar(10), GETDATE(), 108) + ',' + ' No se exportó la ' + case when c_comprobante.FACTTIPO in (1,2,4,6,27,29,54,56) then 'Factura        : ' else 'Nota de debito : ' end  + funciones.alltrim(c_comprobante.FLETRA) + ' ' + funciones.padl(funciones.alltrim(c_comprobante.FPTOVEN),4,'0') + '-' + funciones.padl(funciones.alltrim(c_comprobante.FNUMCOMP),8,'0') + '. No se acepta alicuota en cero cuando el código de norma es distinto de 28 o 29' as varchar(250)) as RegError
	from ZooLogic.COMPROBANTEV as c_comprobante
	inner join ZooLogic.[CLI] as c_cliente on c_cliente.CLCOD = c_comprobante.FPERSON
	inner join ZooLogic.COMPROBANTEVDET as c_compdet on c_compdet.CODIGO = c_comprobante.CODIGO
	inner join ZooLogic.IMPVENTAS as c_impventas on c_impventas.CCOD  = c_comprobante.CODIGO
	where (c_comprobante.ffch >= @FechaDesde and c_comprobante.ffch <= @FechaHasta) and c_comprobante.FACTTIPO in (1,2,4,6,27,29,54,56) and (c_comprobante.fnumcomp <> 0 and c_comprobante.anulado = 0)  and c_impventas.jurid = '901' and c_impventas.TIPOI = 'IIBB' and c_impventas.monto > 0 and ( funciones.alltrim(substring(funciones.alltrim(c_impventas.DESCRI),1,3)) not in('28','29','028','029') and c_impventas.PORCEN = 0 )

	) as arcibaventas1 --VENTAS
)


