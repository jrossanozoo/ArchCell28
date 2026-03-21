IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Datos_ArcibaPagos]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Datos_ArcibaPagos];
GO;

CREATE FUNCTION [interfaces].[Datos_ArcibaPagos]
( 
@FechaDesde as char(8),
@FechaHasta as char(8)
)
RETURNS TABLE
AS
RETURN 
(
	select DISTINCT 
		tipooperacion,	-- 1 a 1 (long 1) RETENCIONES
		codigonorma,	-- 2 a 4 (long 3)
		fecharetper,	-- 5 a 14 (long 10)  dd/mm/aaaa
		tipocomprobante, -- 15 a 16 (long 2) 
		letra,			-- 17 (long 1)
		ptoVenta,	-- 18 a 33 (long 16) no indica formato solo dice "mayor a cero"	
		numcomp,	-- 18 a 33 (long 16) concatenado con el pto de vta y mayor a cero
		fechacomp,	-- 34 a 43 (long 10)  dd/mm/aaaa
		montoperret as montocomp,	-- 44 a 59 (long 16) 9999999999999,99
		nrocertpropio,	-- 60 a 75 (long 16)
		tipodocret,	-- 76 a 76 (long 1) 3:cuit, 2: cuil, 1:cdi. Si nrodocret >= 30000000000: tipodocret = 4
		nrodocret,	-- 77 a 87 (long 11) 99999999999. 
		situacionIBret,	-- 88 a 88 (long 1) 1:local, 2: multi, 3: no insc, 4: reg simplif
		nroIIBBret,	-- 89 a 99 (long 11) si situacionIBret=4: 00000000000
		situacionIVAret,	-- 100 a 100 (long 1) 1:RI, 3: exento, 4: mono
		razonsocialret,	--101 a 130 (long 30) 
		--cast(funciones.padl(replace(funciones.alltrim(convert(char(16),cast(( TotalRetenciones ) as numeric(14,2)))),'.',',') ,16,'0') as char(16)) as importeotrosconcep,
	    TotalRetenciones as importeotrosconcep,
		importeIVA,	-- 147 a 162 (long 16)
		montoperret,	-- 163 a 178 (long 16)
		alicuota,	-- 179 a 183 (long 5) Mayor a cero, salvo norma 28 y 29
		montoretper,	-- 184 a 199 (long 16)
		montototalretper, -- 200 a 215 (long 1)
		'' as aceptacion, -- Nuevo desde 01-2022=> Solo para retenc de MiPyme (tipocomprobante 10,11,12,13) E:a ceptación expresa o T: tácita ¿?
		'          ' as fechaAceptacion	-- Nuevo desde 01-2022 => si aceptacion= E informar fecha, sino espacios en blanco
	from
	(
		select 
		'1' as tipooperacion,		-- PAGO
		cast(c_Impuestos.Resolu  as char(3)) as codigonorma,	
		cast(funciones.alltrim((substring(CONVERT(varchar, CONVERT(date, c_Pago.fechap)), 9, 2) + '/' + substring(CONVERT(varchar,CONVERT(date, c_Pago.fechap)), 6, 2) + '/' + substring(CONVERT(varchar, CONVERT(date, c_Pago.fechap)),1, 4))) AS char(10)) as fecharetper,
		cast('03' as char(2)) as tipocomprobante,
		cast(' ' as char(1)) as letra,
		cast(funciones.padl(funciones.alltrim(c_Pago.FPTOVEN),4,'0') as char(4)) as ptoVenta,
		cast(funciones.padl(funciones.alltrim(c_Pago.FNUMCOMP),12,'0') as char(12)) as numcomp,	
		cast(funciones.alltrim((substring(CONVERT(varchar, CONVERT(date, c_Pago.fechap)), 9, 2) + '/' + substring(CONVERT(varchar,CONVERT(date, c_Pago.fechap)), 6, 2) + '/' + substring(CONVERT(varchar, CONVERT(date, c_Pago.fechap)),1, 4))) AS char(10)) as fechacomp,
		cast(funciones.padl(replace(funciones.alltrim(convert(char(16),cast(( c_Pago.FTOTAL ) as numeric(14,2)))),'.',',') ,16,'0') as char(16)) as montocomp,
		cast(funciones.padl(funciones.alltrim(c_comprobante.ptoVenta) + funciones.alltrim( c_comprobante.Numero),16,' ') as char(16)) as nrocertpropio, --space(16) as nrocertpropio,
		'3' as tipodocret,
		cast(c_Proveedor.CLCUIT as char(11)) as nrodocret,	
		cast(c_Proveedor.cltipconv as char(1)) as situacionIBret, --Situación IB del Retenido
		cast(case when c_Proveedor.cltipconv = 2 then funciones.alltrim(replace(c_Proveedor.CLCUIT,'-','')) else( case when c_Proveedor.cltipconv = 4 then '00000000000' else funciones.padl(funciones.alltrim(c_Proveedor.CLNROIIBB),11,'0')end ) end as char(11)) as nroIIBBret, --Se validará digito verificador. 1.Local: 8 dígitos Número + 2 dígitos Verificador 2. Conv.Multilateral: 3 dígitos Jurisdicción + 6 dígitos Número + 1 Dígito Verificador 5.RS: 2 dígitos + 8 dígitos + 1 dígito verificador 
		cast(funciones.alltrim(convert(char(2),c_Proveedor.CLIVA)) as char(1)) as situacionIVAret,
		cast(c_Proveedor.CLNOM as char(30)) as razonsocialret,
		'0000000000000,00' as importeIVA,
	--	(select sum( CPR.CRTOTAL ) from ZooLogic.Compret CPR where cpr.numop = c_comprobante.NUMOP) as TotalRetenciones,
		'0000000000000,00' as TotalRetenciones,
		cast(funciones.padl(replace(funciones.alltrim(convert(char(16),cast(c_CDRImpuestos.MontoBase as numeric(14,2)))),'.',',') ,16,'0') as char(16)) as montoperret,	--( c_comprobante.FSUBTON - (c_comprobante.TOTDESCSI + c_comprobante.TOTRECARSI) ) as montoperret,
		cast(funciones.padl(replace(funciones.alltrim(convert(char(5),cast(c_CDRImpuestos.Porcentaje as numeric(5,2)))),'.',',') ,5,'0') as char(5)) as alicuota, --c_impventas.PORCEN as alicuota,
		cast(funciones.padl(replace(funciones.alltrim(convert(char(16),convert(numeric(14,2),c_CDRImpuestos.Monto))),'.',',') ,16,'0') as char(16)) as montoretper, --c_impventas.MONTO as montoretper,
		cast(funciones.padl(replace(funciones.alltrim(convert(char(16),convert(numeric(14,2),c_CDRImpuestos.Monto))),'.',',') ,16,'0') as char(16)) as montototalretper --c_impventas.MONTO as montototalretper
	from ZooLogic.COMPRET as c_comprobante
	inner join [ZooLogic].[ORDPAGO] as c_OrdenPago on c_OrdenPago.FLetra = c_comprobante.LetraOP and c_OrdenPago.fptoven = c_comprobante.PtoVenOp and c_OrdenPago.FNUMCOMP = c_comprobante.NumOp
	inner join [ZooLogic].[PAGO] as c_Pago on c_Pago.OPago = c_OrdenPago.codigo
	inner join [ZooLogic].[CRImpDet] as c_CDRImpuestos on c_CDRIMPUESTOS.CODIGO = c_comprobante.CODIGO and c_CDRImpuestos.monto > 0
	inner join [Zoologic].[Impuesto] as c_Impuestos on c_CDRImpuestos.CODIMP = c_Impuestos.CODIGO and c_Impuestos.Jurisdicci = '901'
	inner join [ZooLogic].[Prov] as c_Proveedor on c_Proveedor.ClCod = funciones.alltrim(c_comprobante.prov)
	where (c_Pago.fechap >= @FechaDesde and c_Pago.fechap <= @FechaHasta) and (c_comprobante.Numero <> 0 or c_comprobante.anulado = 0) 
) as arcibaPagos --Pagos
)
