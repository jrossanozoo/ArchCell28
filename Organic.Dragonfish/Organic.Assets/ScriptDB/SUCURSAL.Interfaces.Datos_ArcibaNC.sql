IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Datos_ArcibaNC]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Datos_ArcibaNC];
GO;

CREATE FUNCTION [interfaces].[Datos_ArcibaNC]
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
		cast(c_comprobante.codigo as char(38)) as Campo0, --Codigo,
		cast(funciones.alltrim(c_comprobante.fletra) as char(1)) as letra,
		'2' as Campo1, --tipooperacion,		
		cast(funciones.padl(funciones.alltrim(c_comprobante.FPTOVEN),4,'0') as char(4)) as Campo2, --ptoVenta,		
		cast(funciones.padl(funciones.alltrim(c_comprobante.FNUMCOMP),8,'0') as char(8)) as Campo3, --numcomp,		
		cast(funciones.alltrim((substring(CONVERT(varchar, CONVERT(date, c_comprobante.FFCH)), 9, 2) + '/' + substring(CONVERT(varchar,CONVERT(date, c_comprobante.FFCH)), 6, 2) + '/' + substring(CONVERT(varchar, CONVERT(date, c_comprobante.FFCH)),1, 4))) AS char(10)) as Campo4, --fechacomp,
		cast(funciones.padl(funciones.alltrim(replace(convert(char(16),cast((c_impventas.MONTOBASE ) as numeric(14,2))),'.',',')) ,16,'0') as char(16))as Campo5, --montocomp,
		cast( ' ' as char(16)) as Campo6, --nrocertpropio,
		cast('  ' as char(2)) as Campo7, --tipocomprobante,
		cast(' ' as char(1)) as Campo8, --letera,
		cast(' ' as char(16))as Campo9, --NroComp,
		cast(c_cliente.CLCUIT as char(11)) as Campo10, --nrodocret, 
		cast(left(funciones.alltrim(c_impventas.DESCRI),3) as char(3)) as Campo11, --codigonorma,				
		cast(funciones.alltrim((substring(CONVERT(varchar, CONVERT(date, c_comprobante.FFCH)), 9, 2) + '/' + substring(CONVERT(varchar,CONVERT(date, c_comprobante.FFCH)), 6, 2) + '/' + substring(CONVERT(varchar, CONVERT(date, c_comprobante.FFCH)),1, 4))) AS char(10))as Campo12, -- Fecha de retenci�n/percepci�n
		cast(funciones.padl(funciones.alltrim(replace(convert(char(16),convert(numeric(14,2),c_impventas.MONTO)),'.',',')) ,16,'0') as char(16)) as Campo13, --monto,		
		cast(funciones.padl(funciones.alltrim(replace(convert(char(5),cast(c_impventas.PORCEN as numeric(5,2))),'.',',')) ,5,'0') as char(5)) as Campo14 --alicuota	
	from ZooLogic.COMPROBANTEV as c_comprobante
	inner join ZooLogic.[CLI] as c_cliente on c_cliente.CLCOD = c_comprobante.FPERSON	
	inner join ZooLogic.IMPVENTAS as c_impventas on c_impventas.CCOD  = c_comprobante.CODIGO
	where (c_comprobante.ffch >= @FechaDesde and c_comprobante.ffch <= @FechaHasta) and c_comprobante.FACTTIPO in (3,5,28,55) and (c_comprobante.fnumcomp <> 0 and c_comprobante.anulado = 0) and c_impventas.jurid = '901' and c_impventas.TIPOI = 'IIBB' and c_impventas.monto > 0 	
	) as arcibaNC --Notas de Crédito
)


