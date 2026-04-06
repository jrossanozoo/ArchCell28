--Incidentes detalle de consulta tiene las palabras de la frase

declare @BUSQUEDA AS VARCHAR(MAX);
SET @BUSQUEDA = 'FACTURACIÓN REMITO';
SELECT 
	'INCIDENTE' AS REGISTRO
	, ZL.INCIDS.CODIN
	, ISNULL(TIPIF.CDESC, '') + ISNULL(TIPIF2.CDESC, '') + ISNULL(TAREAS.CTITULO, '') AS NOMBRE
	, ZL.INCIDS.CMPCONSULT AS DETALLE
	, '''' AS OBS
	, KEY_TBL.RANK AS RANKING
FROM 
	ZL.INCIDS 
	--JOIN ZL.IYDREQUERIMIENTOSINCIDENTES AS R ON ZL.INCIDS.CODIN = R.NUMERO 	
	INNER JOIN CONTAINSTABLE(ZL.INCIDS, *, 'FACTURACIÓN AND REMITO' ) AS KEY_TBL ON KEY_TBL.[KEY] = ZL.INCIDS.CODIN
	LEFT  JOIN (SELECT 
					ULTREGPOR.INC
					, ISNULL(ZLTASK.CTITULO, '') AS CTITULO
				FROM
					ZL.ZLTASK
					LEFT JOIN (SELECT 
							MAX(NUMERO) AS TAREA
							, CODIGO AS INC
						  FROM 
							ZL.DINCIDS
						  GROUP BY CODIGO) AS ULTREGPOR ON ULTREGPOR.TAREA = ZLTASK.NUMERO
				WHERE
					FREETEXT(CTITULO, 'FACTURACIÓN AND REMITO' )) AS TAREAS ON TAREAS.INC = ZL.INCIDS.CODIN
	LEFT JOIN (SELECT CCOD, ISNULL(CDESC+'//', '') AS CDESC FROM [ZL].[TIPIF] WHERE FREETEXT(CDESC, 'FACTURACIÓN AND REMITO')) AS TIPIF ON TIPIF.[CCOD] = [INCIDS].[CMPTIPIF]
	LEFT JOIN (SELECT CCOD, ISNULL(CDESC+'//', '') AS CDESC FROM [ZL].[TIPIF2] WHERE FREETEXT(CDESC, 'FACTURACIÓN AND REMITO')) AS TIPIF2 ON TIPIF2.[CCOD] = [INCIDS].[CMPSTIP]
ORDER BY
	KEY_TBL.RANK DESC

/*
		 SELECT distinct [Incids].[Codin] as Numero, ut.regpor
          ,RTRIM([Tipif].[Cdesc]) + ' // ' + RTRIM([Tipif2].[Cdesc])  + '//' + RTRIM(ut.ctitulo) as [Req Asunto/Título]    
          ,cast([Incids].cMPcONSULT as varchar(4000)) as [Req Detalle]
                  
          FROM
          [ZL].[Incids]
          left join [ZL].[Tipif] on [Incids].[Cmptipif] = [Tipif].[Ccod]
          left join [ZL].[Tipif2] on [Incids].[Cmpstip] = [Tipif2].[Ccod]
          left join [ZL].[REQINCDET] on [Incids].[Codin] = [REQINCDET].[Inc_id]
        
          left join
          (
          select ultRegPor.inc, zl.zltask.regpor, zltask.ctitulo
          from
          zl.zltask
          join
          (
          select max(numero) as tarea, codigo as inc
          from zl.dincids
          group by codigo
          )
          as ultRegPor on ultRegPor.tarea = zltask.numero
          ) as ut on ut.inc = [Incids].[Codin]
          
          left join 
          (select distinct codigo from zl.[Dincids] where RTRIM([Dincids].Asignt) in('DISEÑOYANALISISTECNICO','ANALISISFUNCIONAL') )
          as Pend on Pend.Codigo = Incids.Codin

          where 
		(	(  [REQINCDET].[Inc_id] is null and  Pend.Codigo is not null ) or [REQINCDET].[Inc_id] is not null )

	
	*/