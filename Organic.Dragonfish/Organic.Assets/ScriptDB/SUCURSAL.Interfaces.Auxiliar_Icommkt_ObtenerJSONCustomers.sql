IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Auxiliar_Icommkt_ObtenerJSONCustomers]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Auxiliar_Icommkt_ObtenerJSONCustomers];
GO;

CREATE FUNCTION [Interfaces].[Auxiliar_Icommkt_ObtenerJSONCustomers]
(
)
RETURNS TABLE
AS
RETURN
(
	select 
		Funciones.Alltrim(C.CLCOD) as Codigo,
		'{"Key":"PRIMER_NOMBRE","Value":"' + funciones.alltrim(C.CLPRINOM) + '"}' as PRIMER_NOMBRE,
		'{"Key":"SEGUNDO_NOMBRE","Value":"' + funciones.alltrim(C.CLSEGNOM) + '"}' as SEGUNDO_NOMBRE,
		'{"Key":"APELLIDO","Value":"' + funciones.alltrim(C.CLAPELL) + '"}' as APELLIDO,
		'{"Key":"RAZON_SOCIAL","Value":"' + case when C.CLIVA <> 3 then funciones.alltrim(C.CLNOM) else '' end + '"}' as RAZON_SOCIAL,
		'{"Key":"SITUACION_FISCAL","Value":"' + case C.CLIVA 
													when 1 then 'Responsable Inscripto'
													when 3 then 'Consumidor Final'
													when 4 then 'Exento'
													when 5 then 'No Responsable'
													when 7 then 'Responsable Monotributo'
													when 12 then 'No Alcanzado'
													else ''
												end + '"}' as SITUACION_FISCAL,
		'{"Key":"FECHA_DE_NACIMIENTO","Value":"' + funciones.alltrim(CONVERT(VARCHAR(10), C.CLFECHA, 103)) + '"}' as FECHA_DE_NACIMIENTO,
		'{"Key":"SEXO","Value":"' + funciones.alltrim(C.SEXO) + '"}' as SEXO,
		'{"Key":"ESTADO_CIVIL","Value":"' + funciones.alltrim(C.ESTADO) + '"}' as ESTADO_CIVIL,
		'{"Key":"CANTIDAD_DE_HIJOS","Value":"' + FUNCIONES.ALLTRIM(CAST(C.HIJOS AS varchar(2))) + '"}' as CANTIDAD_DE_HIJOS,
		'{"Key":"CALLE","Value":"' + Funciones.Alltrim(C.CLCALLE) + '"}' as CALLE,
		'{"Key":"NUMERO","Value":"' + FUNCIONES.ALLTRIM(CAST(C.CLNRO AS VARCHAR(6))) + '"}' as NUMERO,
		'{"Key":"LOCALIDAD","Value":"' + Funciones.alltrim(C.CLLOC) + '"}' as LOCALIDAD,
		'{"Key":"CODIGO_POSTAL","Value":"' + funciones.alltrim(C.CLCP) + '"}' as CODIGO_POSTAL,
		'{"Key":"PROVINCIA","Value":"' + COALESCE(funciones.alltrim(PC.PRV_DES), '') + '"}' as PROVINCIA,
		'{"Key":"PAIS","Value":"' + COALESCE(funciones.alltrim(PA.PDES), '') + '"}' as PAIS,
		'{"Key":"TELEFONO","Value":"' + funciones.alltrim(C.CLTLF) + '"}' as TELEFONO,
		'{"Key":"TELEFONO_MOVIL","Value":"' + funciones.alltrim(C.CLMOVIL) + '"}' as TELEFONO_MOVIL,
		'{"Key":"VENDEDOR","Value":"' + COALESCE(funciones.alltrim(V.CLNOM), '') + '"}' as VENDEDOR,
		'{"Key":"TRANSPORTISTA","Value":"' + COALESCE(funciones.alltrim(T.TRNOM), '') + '"}' as TRANSPORTISTA,
		'{"Key":"LISTA_DE_PRECIO","Value":"' + funciones.alltrim(C.CLLISPREC) + '"}' as LISTA_DE_PRECIO,
		'{"Key":"DESCUENTO","Value":"' + funciones.alltrim(C.CLCO_DTO) + '"}' as DESCUENTO,
		'{"Key":"LIMITE_DE_CREDITO","Value":"' + FUNCIONES.ALLTRIM(CAST(C.CLTOPECCTE AS VARCHAR(12))) + '"}' as LIMITE_DE_CREDITO,
		'{"Key":"CONDICION_DE_PAGO","Value":"' + COALESCE(funciones.alltrim(CP.CLNOM), '') + '"}' as CONDICION_DE_PAGO,
		'{"Key":"CLASIFICACION","Value":"' + COALESCE(funciones.alltrim(CL.CLADES), '') + '"}' as CLASIFICACION,
		'{"Key":"TIPO","Value":"' + COALESCE(funciones.alltrim(TC.TCDES), '') + '"}' as TIPO,
		'{"Key":"CATEGORIA","Value":"' + COALESCE(funciones.alltrim(CC.CGDES), '') + '"}' as CATEGORIA,
		'{"Key":"RECOMENDADO_POR","Value":"' + COALESCE(funciones.alltrim(CR.CLNOM), '') + '"}' as RECOMENDADO_POR
	from ZooLogic.cli AS C
	LEFT JOIN ZooLogic.PROVINCI AS PC ON C.CLPRV = PC.PRV_COD
	LEFT JOIN ZooLogic.PAISES AS PA ON C.CLPAIS = PA.PCOD
	LEFT JOIN ZooLogic.VEN AS V ON C.CLVEND = V.CLCOD
	LEFT JOIN ZooLogic.TRA AS T ON C.CLTRANS = T.TRCOD
	LEFT JOIN ZooLogic.CONDPAGO AS CP ON C.CLCONDPAG = CP.CLCOD
	LEFT JOIN ZooLogic.CLASIF AS CL ON C.CLCLAS = CL.CLACOD
	LEFT JOIN ZooLogic.TIPOCLI AS TC ON C.CLTIPOCLI = TC.TCCOD
	LEFT JOIN ZooLogic.CATCLI AS CC ON C.CLCATEGCLI = CC.CGCOD
	LEFT JOIN ZooLogic.CLI AS CR ON C.CODRECOM = CR.CLCOD
)
