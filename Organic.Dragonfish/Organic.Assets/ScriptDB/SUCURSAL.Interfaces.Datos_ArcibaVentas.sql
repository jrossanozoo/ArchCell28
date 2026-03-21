IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Datos_ArcibaVentas]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Datos_ArcibaVentas];
GO;

CREATE FUNCTION [interfaces].[Datos_ArcibaVentas]
( 
@FechaDesde as char(8),
@FechaHasta as char(8)
)
RETURNS TABLE
AS
RETURN 
(




	select DISTINCT 
		tipooperacion,	-- 1 a 1 (long 1) PERCEPCIONES
		codigonorma,	-- 2 a 4 (long 3)
		fecharetper,	-- 5 a 14 (long 10)  dd/mm/aaaa
		--case when tipocomprobante != '01' then '09' else tipocomprobante end as tipocomprobante,	-- 15 a 16 (long 2) && por conversion ARCIBATIPOCOMP
	--	case when tipocomprobante != '01' then '10' else tipocomprobante end as tipocomprobante,
	    tipocomprobante ,
		letra,			-- 17 (long 1)
		ptoVenta,	-- 18 a 33 (long 16) no indica formato solo dice "mayor a cero"	
		numcomp,	-- 18 a 33 (long 16) concatenado con el pto de vta y mayor a cero
		fechacomp,	-- 34 a 43 (long 10)  dd/mm/aaaa
		montocomp,	-- 44 a 59 (long 16) 9999999999999,99
		nrocertpropio,	-- 60 a 75 (long 16)
		tipodocret,	-- 76 a 76 (long 1) 3:cuit, 2: cuil, 1:cdi. Si nrodocret >= 30000000000: tipodocret = 4
		nrodocret,	-- 77 a 87 (long 11) 99999999999. 
		situacionIBret,	-- 88 a 88 (long 1) 1:local, 2: multi, 3: no insc, 4: reg simplif
		nroIIBBret,	-- 89 a 99 (long 11) si situacionIBret=4: 00000000000
		situacionIVAret,	-- 100 a 100 (long 1) 1:RI, 3: exento, 4: mono
		razonsocialret,	--101 a 130 (long 30) 
		importeotrosconcep,	-- 131 a 146 (long 16) 9999999999999,99
		importeIVA,	-- 147 a 162 (long 16)
		montoperret,	-- 163 a 178 (long 16)
		alicuota,	-- 179 a 183 (long 5) Mayor a cero, salvo norma 28 y 29
		montoretper,	-- 184 a 199 (long 16)
		montototalretper, -- 200 a 215 (long 1)
		'' as aceptacion, -- Nuevo desde 01-2022=> Solo para retenc de MiPyme (tipocpbte 10,11,12,13) E:a ceptación expresa o T: tácita ¿?
		'          ' as fechaAceptacion	-- Nuevo desde 01-2022 => si aceptacion= E informar fecha, sino espacios en blanco
	from
	(
		select 
			'2' as tipooperacion,
			cast(c_impuesto.RESOLU as char(3)) as codigonorma, 	
			cast(funciones.alltrim((substring(CONVERT(varchar, CONVERT(date, c_comprobante.ffch)), 9, 2) + '/' + substring(CONVERT(varchar,CONVERT(date, c_comprobante.ffch)), 6, 2) + '/' + substring(CONVERT(varchar, CONVERT(date, c_comprobante.ffch)),1, 4))) AS char(10)) as fecharetper,
			case when ARCIBATIPOCOMP_valconv.VALDEST is null then cast(funciones.padl(funciones.alltrim(ARCIBATIPOCOMP_valDefault.VALORDEF),2,'0') as char(2)) else cast(funciones.padl(funciones.alltrim(ARCIBATIPOCOMP_valconv.VALDEST),2,'0') as char(2)) end as tipocomprobante,
			cast(c_comprobante.FLETRA as char(1)) as letra,
			cast(funciones.padl(funciones.alltrim(c_comprobante.FPTOVEN),4,'0') as char(4)) as ptoVenta,
			cast(funciones.padl(funciones.alltrim(c_comprobante.FNUMCOMP),12,'0') as char(12)) as numcomp,		
			cast(funciones.alltrim((substring(CONVERT(varchar, CONVERT(date, c_comprobante.ffch)), 9, 2) + '/' + substring(CONVERT(varchar,CONVERT(date, c_comprobante.ffch)), 6, 2) + '/' + substring(CONVERT(varchar, CONVERT(date, c_comprobante.ffch)),1, 4))) AS char(10)) as fechacomp,
			cast(funciones.padl(replace(funciones.alltrim(convert(char(16),cast(( c_comprobante.FTOTAL ) as numeric(14,2)))),'.',',') ,16,'0') as char(16))as montocomp,
			space(16) as nrocertpropio,
			'3' as tipodocret,
			cast(c_cliente.CLCUIT as char(11)) as nrodocret,		
			cast(c_cliente.CLTIPCONV as char(1)) as situacionIBret, --Situación IB del Retenido
			cast(case when c_cliente.CLTIPCONV = 2 then funciones.alltrim(replace(c_cliente.CLCUIT,'-','')) else (case when c_cliente.CLTIPCONV = 4 then '00000000000' else funciones.padl(funciones.alltrim(c_cliente.CLNROIIBB),11,'0')end) end as char(11)) as nroIIBBret, --Se validará digito verificador. 1.Local: 8 dígitos Número + 2 dígitos Verificador 2. Conv.Multilateral: 3 dígitos Jurisdicción + 6 dígitos Número + 1 Dígito Verificador 5.RS: 2 dígitos + 8 dígitos + 1 dígito verificador 
			cast(funciones.alltrim(convert(char(2),c_cliente.CLIVA)) as char(1)) as situacionIVAret,		
			cast(c_cliente.CLNOM as char(30)) as razonsocialret,
			cast(funciones.padl(replace(funciones.alltrim(convert(char(16),cast(( c_comprobante.TOTIMPUE ) as numeric(14,2)))),'.',',') ,16,'0') as char(16)) as importeotrosconcep,
			cast(case when c_comprobante.fletra in ('A','M') and c_comprobante.fimpuesto is null then '0000000000000,00' else funciones.padl(replace(c_comprobante.fimpuesto,'.',','),16,'0') end as char(16)) as importeIVA,	
			cast(funciones.padl(replace(funciones.alltrim(convert(char(16),cast((c_comprobante.FTOTAL - (c_comprobante.TOTIMPUE + c_comprobante.fimpuesto)) as numeric(14,2)))),'.',',') ,16,'0') as char(16)) as montoperret,	
			cast(funciones.padl(replace(funciones.alltrim(convert(char(5),cast(c_impventas.PORCEN as numeric(5,2)))),'.',',') ,5,'0') as char(5)) as alicuota, 
			cast(funciones.padl(replace(funciones.alltrim(convert(char(16),convert(numeric(14,2),c_impventas.MONTO))),'.',',') ,16,'0') as char(16)) as montoretper,
			cast(funciones.padl(replace(funciones.alltrim(convert(char(16),convert(numeric(14,2),c_impventas.MONTO))),'.',',') ,16,'0') as char(16)) as montototalretper
		from ZooLogic.COMPROBANTEV as c_comprobante
		inner join ZooLogic.[CLI] as c_cliente on c_cliente.CLCOD = c_comprobante.FPERSON
		inner join ZooLogic.COMPROBANTEVDET as c_compdet on c_compdet.CODIGO = c_comprobante.CODIGO
		inner join ZooLogic.IMPVENTAS as c_impventas on c_impventas.CCOD  = c_comprobante.CODIGO
		inner join ZooLogic.IMPUESTO as c_impuesto on c_impuesto.CODIGO = c_impventas.CODIMP 
		left join [Organizacion].[ConverVal] as ARCIBATIPOCOMP_valconv on ARCIBATIPOCOMP_valconv.CONVERSION = 'ARCIBATIPOCOMPROBANTEPERCEP' and ARCIBATIPOCOMP_valconv.VALORIG = funciones.alltrim(cast(c_comprobante.FACTTIPO as varchar(2)))
		left join [Organizacion].[Conver] as ARCIBATIPOCOMP_valDefault on ARCIBATIPOCOMP_valDefault.CODIGO = 'ARCIBATIPOCOMPROBANTEPERCEP'
		where (c_comprobante.ffch >= @FechaDesde and c_comprobante.ffch <= @FechaHasta) and c_comprobante.FACTTIPO in (1,2,4,6,27,29,54,56) and (c_comprobante.fnumcomp <> 0 and c_comprobante.anulado = 0)  and c_impventas.jurid = '901' and c_impventas.TIPOI = 'IIBB' and c_impventas.monto > 0 	
	) as arcibaventas1 --VENTAS
)


