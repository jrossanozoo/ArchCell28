/**********************************************************************************************************************
*                                                                                                                     *
*                                                 ARMAMOS TODOS LOS FILTROS                                           *
*                                        PARA PODER EJECUTAR EL QUERY FUERA DEL REPORTE                               *
*                                                                                                                     *
**********************************************************************************************************************/
drop table #RegistPor;
drop table #RequerPor;
drop table #Clientes;
drop table #Proyectos;
drop table #Estados;

DECLARE @FechaDesde AS DATETIME
        ,@FechaHasta  AS DATETIME
        ,@FechaEstadoDesde  AS DATETIME
        ,@FechaEstadoHasta  AS DATETIME
        ,@FechaEtapaDesde  AS DATETIME
        ,@FechaEtapaHasta  AS DATETIME;
		
SET @FechaDesde       = DATEADD(MONTH, -6, GETDATE());
SET @FechaHasta       = GETDATE();
SET @FechaEstadoDesde = CONVERT(DATETIME, CONVERT(VARCHAR(10), GETDATE(), 103), 103);
SET @FechaEstadoHasta = CONVERT(DATETIME, CONVERT(VARCHAR(10), GETDATE(), 103), 103);
SET @FechaEtapaDesde  = CONVERT(DATETIME, CONVERT(VARCHAR(10), GETDATE(), 103), 103);
SET @FechaEtapaHasta  = CONVERT(DATETIME, CONVERT(VARCHAR(10), GETDATE(), 103), 103);

create table #RegistPor (RegPor varchar(50) not null);
insert intO #RegistPor SELECT
	RTRIM([REQ REGPOR]) AS REGPOR
FROM
	(SELECT 
		ZL.PNCEREQ.REGPOR AS [REQ REGPOR]
	 FROM
	    ZL.PNCEREQ 
	    LEFT OUTER JOIN ZL.REQCLIDET ON ZL.PNCEREQ.CODIN = ZL.REQCLIDET.NUMERO
	 WHERE
		(ZL.REQCLIDET.FUNC IS NOT NULL) 
		OR (ZL.REQCLIDET.BUG IS NOT NULL) 
		OR (ZL.PNCEREQ.NAPROV = 0) 
		AND (ZL.PNCEREQ.CMPFECINI > '20111001') 
		AND (ZL.PNCEREQ.FALTAFW BETWEEN @FECHADESDE AND @FECHAHASTA)
UNION
SELECT
	ZL.REQUER.REGPOR AS [REQ REGPOR]
FROM
	ZL.REQUER 
	LEFT OUTER JOIN ZL.REQIDDET ON ZL.REQUER.CODIGO = ZL.REQIDDET.REQID 
		AND ZL.REQUER.FALTAFW BETWEEN @FECHADESDE AND @FECHAHASTA
UNION
SELECT
	R.REGPOR AS [REQ REGPOR]
FROM
	ZL.INCIDS 
	INNER JOIN ZL.IYDREQUERIMIENTOSINCIDENTES AS R ON R.NUMERO = ZL.INCIDS.CODIN 
		AND ZL.INCIDS.CMPFECINI BETWEEN @FECHADESDE AND @FECHAHASTA) AS REQUERIMIENTOS	
UNION
	SELECT 
		''
ORDER BY
	1;

create table #RequerPor (codigo varchar(10) null, Contacto varchar(50) null);
INSERT INTO #RequerPor SELECT [CONTACT].codigo, LTRIM(RTRIM([CONTACT].apell))+ ', ' + LTRIM(RTRIM([CONTACT].pnom)) + ' ' + LTRIM(RTRIM([CONTACT].snom)) as Contacto
FROM [ZL].[CONTACT]
	INNER JOIN [ZL].[ZL].[PNCEREQ] ON [ZL].[ZL].[PNCEREQ].CONTACTO = [CONTACT].codigo
		AND [PNCEREQ].[NAPROV] = 0  
		AND [PNCEREQ].[CMPFECINI] > '20111001'
		AND [PNCEREQ].[FALTAFW] BETWEEN @FechaDesde AND @FechaHasta
UNION
SELECT
	''
	,'' AS Contacto
order by 2;

CREATE TABLE #Clientes (CCLIENTE VARCHAR(10) NULL, NOMBRE VARCHAR(50) NULL);
INSERT INTO #Clientes SELECT
	[PNCEREQ].[CCLIENTE] AS [REQ CCLIENTE]
	,[CLIENTES].[CMPNOMBRE] AS [REQ CLIENTE NOMBRE]
FROM 
	[ZL].[ZL].[PNCEREQ] 
	LEFT JOIN [ZL].[REQCLIDET] ON [PNCEREQ].[CODIN] = [REQCLIDET].[NUMERO]
	LEFT JOIN [ZL].[ZL].[CLIENTES] AS [CLIENTES] ON [CLIENTES].[CMPCODIGO] = [PNCEREQ].[CCLIENTE]
WHERE
	( (  [REQCLIDET].FUNC IS NOT NULL OR [REQCLIDET].BUG IS NOT NULL) 
		OR 
	  ( [PNCEREQ].[NAPROV] = 0  AND  [PNCEREQ].[CMPFECINI] > '20111001' ) )
	AND [PNCEREQ].[FALTAFW] BETWEEN @FECHADESDE AND @FECHAHASTA  
UNION 
SELECT
	'' AS CLIENTE
	,'' AS CIENTENOMBRE		
UNION 
SELECT
	[INCIDS].[CCLIENTE]
	,[CLIENTES].[CMPNOMBRE] AS [CLIENTE NOMBRE]
FROM
	[ZL].[ZL].[INCIDS]
	JOIN ZL.IYDREQUERIMIENTOSINCIDENTES AS R ON R.NUMERO = INCIDS.CODIN
	LEFT JOIN [ZL].[ZL].[CLIENTES] ON [CLIENTES].[CMPCODIGO] = [INCIDS].[CCLIENTE]
WHERE 
	[INCIDS].[CMPFECINI] BETWEEN @FECHADESDE AND @FECHAHASTA           
ORDER BY 2;

CREATE TABLE #Proyectos (ENTIDADRELACIONADAPROYECTOACTUAL VARCHAR(50) NULL);
INSERT INTO #Proyectos SELECT 
	DISTINCT
	CASE 
		WHEN REQUERIMIENTOS.FUNCIONALIDAD IS NULL THEN ' SIN PRE-ANÁLISIS '
		ELSE CASE 
				WHEN (REQUERIMIENTOS.FUNCIONALIDAD = 0 AND REQUERIMIENTOS.BUG = 0) THEN ISNULL(REQUERIMIENTOS.PROYECTOPREANALISIS,' SIN EQUIPO ')
				ELSE CASE 
						WHEN REQUERIMIENTOS.BUG <> 0 THEN ISNULL(BUP.PROYECTO, ' SIN EQUIPO ') 
						ELSE ISNULL(FUP.PROYECTO,' SIN EQUIPO')  
					END 
			END 
	END AS ENTIDADRELACIONADAPROYECTOACTUAL
FROM
	(SELECT
		[REQCLIDET].FUNC AS FUNCIONALIDAD
		,[REQCLIDET].BUG AS BUG
		,ESTDET.DESCR AS ESTADOPREANALISIS
		,PROY.DESCRIP AS PROYECTOPREANALISIS
	FROM [ZL].[ZL].[PNCEREQ] 
		LEFT JOIN		
			(SELECT REQCLIDET.CODIGO, REQCLIDET.NUMERO, REQCLIDET.FUNCEST, REQCLIDET.PROY, REQCLIDET.FUNC, REQCLIDET.BUG 
			 FROM
				(SELECT MAX(CODIGO) AS CODIGO, NUMERO,  FUNC, BUG 
				 FROM [ZL].[REQCLIDET]
				 GROUP BY  NUMERO, FUNC, BUG ) AS U JOIN ZL.REQCLIDET ON REQCLIDET.CODIGO = U.CODIGO 
					AND U.NUMERO = REQCLIDET.NUMERO 
					AND REQCLIDET.FUNC = U.FUNC 
					AND REQCLIDET.BUG = U.BUG) AS [REQCLIDET] ON [PNCEREQ].[CODIN] = [REQCLIDET].[NUMERO]
		LEFT JOIN [ZL].[ZL].[ESTDET] ON [REQCLIDET].[FUNCEST] = [ESTDET].[CODIGO]
		LEFT JOIN [ZL].[ZL].[PROY] ON [REQCLIDET].[PROY] = [PROY].[CODIGO]
	WHERE
		( ([REQCLIDET].FUNC IS NOT NULL OR [REQCLIDET].BUG IS NOT NULL) 
		   OR 
		  ([PNCEREQ].[NAPROV] = 0  AND  [PNCEREQ].[CMPFECINI] > '20111001') )
		AND [PNCEREQ].[FALTAFW] BETWEEN @FECHADESDE AND @FECHAHASTA  
UNION ALL
SELECT
	[REQIDDET].[FUNC] AS FUNCIONALIDAD
	,0 AS BUG
	,ESTDET.DESCR AS ESTADOPREANALISIS
	,PROY.DESCRIP AS PROYECTOPREANALISIS
FROM 
	[ZL].[REQUER] 
	LEFT JOIN  
		(SELECT REQIDDET.CODIGO, REQIDDET.FUNCEST, REQIDDET.PROY, REQIDDET.REQID, REQIDDET.FUNC 
         FROM [ZL].[REQIDDET] 
			 JOIN (SELECT MAX(CODIGO) AS CODIGO, REQID, FUNC 
				   FROM [ZL].[ZL].[REQIDDET] 
				   GROUP BY REQID, FUNC) AS ULT ON ULT.REQID = [REQIDDET].[REQID] 
					AND ULT.CODIGO = [REQIDDET].CODIGO 
					AND  ULT.FUNC =[REQIDDET].FUNC) AS REQIDDET ON [REQUER].[CODIGO] = [REQIDDET].[REQID]                
 			 LEFT JOIN [ZL].[ZL].[ESTDET] ON [REQIDDET].[FUNCEST] = [ESTDET].[CODIGO]
			 LEFT JOIN [ZL].[ZL].[PROY] ON [REQIDDET].[PROY] = [PROY].[CODIGO]       
		 WHERE 
			[REQUER].[FALTAFW] BETWEEN @FECHADESDE AND @FECHAHASTA  
UNION ALL
SELECT
	[REQINCDET].[FUNC] AS FUNCIONALIDAD
	,[REQINCDET].[BUG] AS BUG
	,ESTDET.DESCR AS ESTADOPREANALISIS
	,PROY.DESCRIP AS PROYECTOPREANALISIS
FROM
	[ZL].[ZL].[INCIDS]
	JOIN ZL.IYDREQUERIMIENTOSINCIDENTES AS R ON R.NUMERO = INCIDS.CODIN
	LEFT JOIN     
		(SELECT REQINCDET.CODIGO,  REQINCDET.[INC_ID], REQINCDET.FUNC, [REQINCDET].BUG , REQINCDET.FUNCEST, REQINCDET.PROY
         FROM [ZL].[REQINCDET]  
			JOIN (SELECT MAX(CODIGO) AS CODIGO, [INC_ID], FUNC, BUG
				  FROM [ZL].[REQINCDET]
				  GROUP BY [INC_ID] , FUNC , BUG ) AS ULT ON ULT.[INC_ID] = [REQINCDET].[INC_ID] 
					AND ULT.CODIGO = [REQINCDET].CODIGO 
					AND ULT.FUNC =[REQINCDET].FUNC 
					AND ULT.BUG =[REQINCDET].BUG) AS REQINCDET ON [INCIDS].[CODIN] = [REQINCDET].[INC_ID]
			LEFT JOIN [ZL].[ZL].[ESTDET] ON [REQINCDET].[FUNCEST] = [ESTDET].[CODIGO]
			LEFT JOIN [ZL].[ZL].[PROY] ON [REQINCDET].[PROY] = [PROY].[CODIGO]       
		 WHERE 
			[INCIDS].[CMPFECINI] BETWEEN @FECHADESDE AND @FECHAHASTA           
	) AS REQUERIMIENTOS 
	LEFT JOIN ZL.IYDFUNCIONALIDADULTIMOPROYECTO AS FUP ON FUP.FUNCIONALIDAD = REQUERIMIENTOS.FUNCIONALIDAD
	LEFT JOIN ZL.IYDBUGULTIMOPROYECTO AS BUP ON BUP.BUG = [REQUERIMIENTOS].[BUG]
ORDER BY 
	1;

CREATE TABLE #Estados (ENTIDADRELACIONADAESTADOACTUAL VARCHAR(50) NULL);
INSERT INTO #Estados SELECT 
	DISTINCT
	CASE 
		WHEN REQUERIMIENTOS.FUNCIONALIDAD IS NULL THEN ' SIN PRE-ANÁLISIS '
		ELSE CASE 
			WHEN (REQUERIMIENTOS.FUNCIONALIDAD = 0 AND REQUERIMIENTOS.BUG = 0) THEN REQUERIMIENTOS.ESTADOPREANALISIS
			ELSE CASE 
				WHEN REQUERIMIENTOS.BUG <> 0 THEN ISNULL(BUE.ESTADO,' SIN ESTADO ') 
				ELSE ISNULL(FUE.ESTADO,' SIN ESTADO ') 
			END 
		END 
	END AS ENTIDADRELACIONADAESTADOACTUAL
FROM
	(SELECT
		[REQCLIDET].FUNC AS FUNCIONALIDAD
		,[REQCLIDET].BUG AS BUG
		,ESTDET.DESCR AS ESTADOPREANALISIS
		,PROY.DESCRIP AS PROYECTOPREANALISIS
	 FROM 
		[ZL].[ZL].[PNCEREQ] 
		LEFT JOIN		
			(SELECT REQCLIDET.CODIGO, REQCLIDET.NUMERO, REQCLIDET.FUNCEST, REQCLIDET.PROY, REQCLIDET.FUNC, REQCLIDET.BUG 
			 FROM
				(SELECT MAX(CODIGO) AS CODIGO, NUMERO, FUNC, BUG 
				 FROM [ZL].[REQCLIDET]
				 GROUP BY NUMERO, FUNC, BUG) AS U JOIN ZL.REQCLIDET ON REQCLIDET.CODIGO = U.CODIGO 
					AND U.NUMERO = REQCLIDET.NUMERO 
					AND REQCLIDET.FUNC = U.FUNC 
					AND REQCLIDET.BUG = U.BUG) AS [REQCLIDET] ON [PNCEREQ].[CODIN] = [REQCLIDET].[NUMERO]
		LEFT JOIN [ZL].[ZL].[ESTDET] ON [REQCLIDET].[FUNCEST] = [ESTDET].[CODIGO]
		LEFT JOIN [ZL].[ZL].[PROY] ON [REQCLIDET].[PROY] = [PROY].[CODIGO]
	WHERE
		( ([REQCLIDET].FUNC IS NOT NULL OR [REQCLIDET].BUG IS NOT NULL) 
		OR 
		([PNCEREQ].[NAPROV] = 0  AND  [PNCEREQ].[CMPFECINI] > '20111001') )
		AND [PNCEREQ].[FALTAFW] BETWEEN @FECHADESDE AND @FECHAHASTA  
	UNION ALL
	SELECT
		[REQIDDET].[FUNC] AS FUNCIONALIDAD
		,0 AS BUG
		,ESTDET.DESCR AS ESTADOPREANALISIS
		,PROY.DESCRIP AS PROYECTOPREANALISIS
	FROM 
		[ZL].[REQUER] 
		LEFT JOIN
			(SELECT REQIDDET.CODIGO, REQIDDET.FUNCEST, REQIDDET.PROY, REQIDDET.REQID, REQIDDET.FUNC 
			 FROM [ZL].[REQIDDET]
				JOIN 
					(SELECT MAX(CODIGO) AS CODIGO,  REQID, FUNC 
					 FROM [ZL].[ZL].[REQIDDET] 
					 GROUP BY REQID, FUNC) AS ULT ON ULT.REQID = [REQIDDET].[REQID] 
						AND ULT.CODIGO = [REQIDDET].CODIGO 
						AND ULT.FUNC =[REQIDDET].FUNC) AS REQIDDET ON [REQUER].[CODIGO] = [REQIDDET].[REQID]                
		LEFT JOIN [ZL].[ZL].[ESTDET] ON [REQIDDET].[FUNCEST] = [ESTDET].[CODIGO]
		LEFT JOIN [ZL].[ZL].[PROY] ON [REQIDDET].[PROY] = [PROY].[CODIGO]       
	WHERE 
		[REQUER].[FALTAFW] BETWEEN @FECHADESDE AND @FECHAHASTA  
	UNION ALL
	SELECT
		[REQINCDET].[FUNC] AS FUNCIONALIDAD
		,[REQINCDET].[BUG] AS BUG
		,ESTDET.DESCR AS ESTADOPREANALISIS
		,PROY.DESCRIP AS PROYECTOPREANALISIS
	FROM
		[ZL].[ZL].[INCIDS]
		JOIN ZL.IYDREQUERIMIENTOSINCIDENTES AS R ON R.NUMERO = INCIDS.CODIN
		LEFT JOIN     
			(SELECT REQINCDET.CODIGO, REQINCDET.[INC_ID], REQINCDET.FUNC, [REQINCDET].BUG, REQINCDET.FUNCEST, REQINCDET.PROY
			 FROM [ZL].[REQINCDET] 
				JOIN
					(SELECT MAX(CODIGO) AS CODIGO, [INC_ID], FUNC, BUG
					 FROM [ZL].[REQINCDET]
					 GROUP BY [INC_ID], FUNC, BUG) AS ULT ON ULT.[INC_ID] = [REQINCDET].[INC_ID] 
						AND ULT.CODIGO = [REQINCDET].CODIGO 
						AND ULT.FUNC = [REQINCDET].FUNC 
						AND ULT.BUG = [REQINCDET].BUG) AS REQINCDET ON [INCIDS].[CODIN] = [REQINCDET].[INC_ID]
		LEFT JOIN [ZL].[ZL].[ESTDET] ON [REQINCDET].[FUNCEST] = [ESTDET].[CODIGO]
		LEFT JOIN [ZL].[ZL].[PROY] ON [REQINCDET].[PROY] = [PROY].[CODIGO]       
	WHERE 
		[INCIDS].[CMPFECINI] BETWEEN @FECHADESDE AND @FECHAHASTA) AS REQUERIMIENTOS 
	LEFT JOIN ZL.IYDFUNCIONALIDADULTIMOESTADO AS FUE ON FUE.FUNCIONALIDAD = REQUERIMIENTOS.FUNCIONALIDAD
	LEFT JOIN ZL.IYDBUGULTIMOESTADO AS BUE ON BUE.BUG = [REQUERIMIENTOS].[BUG]
ORDER BY 1;

select
          Requerimientos.[Tipo de Requerimiento]
          , Requerimientos.[Req Número]
          , Requerimientos.[Req Alta]
          , Requerimientos.[Req Regpor]
          , Requerimientos.[Req Asunto/Título]
          , Requerimientos.[Req Detalle]
          , Requerimientos.[Req Observación]
          , Requerimientos.[Req Ccliente]
          , Requerimientos.[Req Cliente nombre]
          , Requerimientos.Contacto
         
          ,case when Requerimientos.Funcionalidad is null --no pasó por pre-análisis todavía
				or (Requerimientos.Funcionalidad=0 and Requerimientos.bug=0) --se descartó 
				Then ''
			else case when  Requerimientos.Bug <> 0 then 'Bug' else 'Funcionalidad' end end as EntidadRelacionada
		  
		  ,case when Requerimientos.Funcionalidad is null --no pasó por pre-análisis todavía
				or (Requerimientos.Funcionalidad=0 and Requerimientos.bug=0) --se descartó 
				Then 0
			else case when  Requerimientos.Bug <> 0 then Requerimientos.Bug else Requerimientos.Funcionalidad end end as EntidadRelacionadaNumero	
		
		  ,case when Requerimientos.Funcionalidad is null THEN ' Sin Pre-Análisis '--no pasó por pre-análisis todavía
				else case when (Requerimientos.Funcionalidad=0 and Requerimientos.bug=0) --se descartó 
				Then IsNull(Requerimientos.EstadoPreAnalisis,' Sin Estado ')
			else case when  Requerimientos.Bug <> 0 then iSNull(bue.estado,' Sin Estado ') else isNull(ULTEST.Estado,' Sin Estado ') end end end  as EntidadRelacionadaEstadoActual
		 	
		 	
           ,case when Requerimientos.Funcionalidad is null THEN ' Sin Pre-Análisis ' --no pasó por pre-análisis todavía
			else case when (Requerimientos.Funcionalidad=0 and Requerimientos.bug=0) --se descartó 
				Then IsNull(Requerimientos.ProyectoPreAnalisis,' Sin Equipo ')
			else case when  Requerimientos.Bug <> 0 then isnUll(bup.Proyecto, ' Sin Equipo ') else isNull(fup.Proyecto,' Sin Equipo ')  end end end as EntidadRelacionadaProyectoActual
		
		 
		 ,case when Requerimientos.Funcionalidad is null --no pasó por pre-análisis todavía
				or (Requerimientos.Funcionalidad=0 and Requerimientos.bug=0) --se descartó 
				Then ''
			else case when  Requerimientos.Bug <> 0 then b.Titulo else f.Nombre end end as EntidadRelacionadaNombre
		
		,case 
			when Requerimientos.Funcionalidad is null THEN '' --no pasó por pre-análisis todavía
			ELSE 
				CASE 
					WHEN (Requerimientos.Funcionalidad = 0 and Requerimientos.bug = 0) THEN 'Pre-Análisis' 
					ELSE --se descartó 
						case 
							when Requerimientos.Bug <> 0 AND [ULTEST].[Estado] IS NULL then LTRIM(RTRIM(beu.Comprobante))
							else LTRIM(RTRIM([ULTEST].[Estado]))
						end 
				end 
		END as [UltimoEstado]
		,case 
			when Requerimientos.Funcionalidad is null --no pasó por pre-análisis todavía
				or (Requerimientos.Funcionalidad = 0 and Requerimientos.bug = 0) --se descartó 
				Then CONVERT(VARCHAR, Requerimientos.FechaPreAnalisis, 103)
			else 
				case when 
					Requerimientos.Bug <> 0 AND [ULTEST].Fecha IS NULL then CONVERT(VARCHAR, beu.fecha, 103) 
					else CONVERT(VARCHAR, [ULTEST].Fecha, 103) 
				end 
		end as [FechaUltimoEstado]

		,case 
			when Requerimientos.Funcionalidad is null THEN '' --no pasó por pre-análisis todavía
			ELSE 
				CASE 
					WHEN (Requerimientos.Funcionalidad = 0 and Requerimientos.bug = 0) THEN LTRIM(RTRIM(Requerimientos.EstadoPreAnalisis))
					else 
						case 
							when Requerimientos.Bug <> 0 and [ULTETAP].[Comprobante] is null then LTRIM(RTRIM(beu.Comprobante))
							else LTRIM(RTRIM([ULTETAP].[Comprobante]))
						end 
				end 
		end as [UltimaEtapa]
		
		,case 
			when Requerimientos.Funcionalidad is null --no pasó por pre-análisis todavía
				or (Requerimientos.Funcionalidad = 0 and Requerimientos.bug = 0) --se descartó 
				Then CONVERT(VARCHAR, Requerimientos.FechaPreAnalisis, 103)
			else 
				case when 
					Requerimientos.Bug <> 0 AND ULTETAP.Fecha IS NULL then CONVERT(VARCHAR, beu.fecha, 103) 
					else CONVERT(VARCHAR, ULTETAP.Fecha, 103) 
				end 
		end as [FechaUltimaEtapa]
        
          from

          (
          SELECT
          'Req. Cliente' as [Tipo de Requerimiento]
          ,[PNCEREQ].[Codin] as [Req Número]
          ,[PNCEREQ].[Faltafw] as [Req Alta]
          ,[PNCEREQ].[Regpor] as [Req Regpor]
          ,[REQCLIDET].Func as Funcionalidad
          ,[REQCLIDET].Bug as Bug
          ,[PNCEREQ].[ASUNTO] as [Req Asunto/Título]
          ,cast([PNCEREQ].[Cmpconsult]as varchar(max)) as [Req Detalle]
          ,'' as [Req Observación]
          ,[PNCEREQ].[Ccliente] as [Req Ccliente]
          ,[Clientes].[Cmpnombre] as [Req Cliente nombre]
          ,[Prodzl].[Descr] as [Req Producto]
          ,RTRIM(contact.pnom) + ' ' + RTRIM(contact.snom) + RTRIM(contact.apell) as Contacto
,[REQCLIDET].codigo as Preanalisis          
,[PRE_ANAL].Faltafw as FechaPreAnalisis
          ,EstDet.Descr as EstadoPreAnalisis
          ,Proy.Descrip as ProyectoPreAnalisis



          FROM [ZL].[ZL].[PNCEREQ] 
          left join		
          (select REQCLIDET.codigo, REQCLIDET.numero, REQCLIDET.funcest, REQCLIDET.proy, REQCLIDET.func, REQCLIDET.bug 
          from           --ultimo preanalisis para el  requerimiento /func/bug
						(select max(codigo) as codigo, numero,  func, bug 
						from [ZL].[REQCLIDET]
						group by  numero, func, bug ) as u join zl.REQCLIDET on 
						REQCLIDET.codigo = u.codigo and u.numero = REQCLIDET.numero and REQCLIDET.func = u.func and REQCLIDET.bug = u.bug
		) as [REQCLIDET]
						
						on [PNCEREQ].[Codin] = [REQCLIDET].[Numero]
          left join zl.[PRE_ANAL] on [PRE_ANAL].[Codigo]  = [REQCLIDET].[Codigo] 
          left join [ZL].[ZL].[Clientes] as [Clientes] on [Clientes].[Cmpcodigo] = [PNCEREQ].[Ccliente]
          left join [ZL].[ZL].[Prodzl] on [PNCEREQ].[CPCOD] = [Prodzl].[Ccod]
          left join [ZL].[ZL].[ESTDET] on [REQCLIDET].[Funcest] = [ESTDET].[Codigo]
          left join [ZL].[ZL].[PROY] on [REQCLIDET].[Proy] = [PROY].[Codigo]
          left join [ZL].contact on contact.codigo = pncereq.contacto
        
          where  --es viejo, diferente el circuito, pero se convirtió en una func o bug, o es nuevo.
				(
				(  [REQCLIDET].Func is not null or [REQCLIDET].Bug is not null) 
				or 
				( [PNCEREQ].[NAPROV] = 0  and  [PNCEREQ].[Cmpfecini] > '20111001' )
				)

and [PNCEREQ].[Faltafw] between @FechaDesde and @FechaHasta  
and RTRIM([PNCEREQ].[Regpor]) in (SELECT RegPor FROM #RegistPor)
and [PNCEREQ].[Ccliente] in (SELECT CCLIENTE FROM #Clientes)
and '' in (SELECT codigo from #RequerPor)

		union all
		SELECT
			'Req. I+D' as Tipo
			 ,[REQUER].[Codigo] as [Req Número]
			,[REQUER].[Faltafw] as [Req Alta]
			,[REQUER].[Regpor] as [Req Regpor]
			,[REQIDDET].[FUNC] as Funcionalidad
			,0 as bug
			,[REQUER].[Titulo] as [Req Asunto/Título]
			,[REQUER].Descr as Descripcion
			,Requer.Obs 
			,'' as Cliente
			,'' as CienteNombre
			,'' as Producto
			,Requer.ReqId as RequeridoPorContacto 
,[REQIDDET].[Codigo]	as PreAnalisis		  
,[PRE_ANAL].Faltafw as FechaPreAnalisis
			  ,EstDet.Descr as EstadoPreAnalisis
          ,Proy.Descrip as ProyectoPreAnalisis
           
          FROM [ZL].[REQUER] left join  
          (
          select REQIDDET.codigo, REQIDDET.funcest, REQIDDET.proy, REQIDDET.reqid, REQIDDET.func 
          from [ZL].[REQIDDET]  join 
								  (select max(codigo) as codigo ,  reqid, func 
								  from [ZL].[ZL].[REQIDDET] 
								  group by reqid, func) as ult 
								 on ult.reqid = [REQIDDET].[Reqid] and ult.codigo = [REQIDDET].codigo and  ult.func =[REQIDDET].func 
		  ) as 		REQIDDET						 
								 
          on [REQUER].[Codigo] = [REQIDDET].[Reqid]
     
           left join zl.[PRE_ANAL] on [PRE_ANAL].[Codigo]  = [REQIDDET].[Codigo] 
            left join [ZL].[ZL].[ESTDET] on [REQIDDET].[Funcest] = [ESTDET].[Codigo]
          left join [ZL].[ZL].[PROY] on [REQIDDET].[Proy] = [PROY].[Codigo]       
           
where [REQUER].[Faltafw] between @FechaDesde and @FechaHasta  
		and RTRIM([REQUER].[Regpor]) in (SELECT RegPor FROM #RegistPor)
and '' in (SELECT CCLIENTE FROM #Clientes)
and rtrim(Requer.ReqId)  in (SELECT codigo from #RequerPor)

          union all

          SELECT
          'Incidente' as [Tipo de Requerimiento]
          ,[Incids].[Codin] AS [Req Número]
          ,[Incids].[Cmpfecini] AS [Req Alta]
          ,r.regpor as [Req Regpor]
          ,[REQINCDET].[func] as Funcionalidad
          ,[REQINCDET].[bug] as Bug
          ,r.[Req Asunto/Título]
          ,cast(r.[Req Detalle] as varchar(max)) as [Req Detalle]
          ,''as [Req Observación]
          ,[Incids].[Ccliente]
          ,[Clientes].[Cmpnombre] as [Cliente nombre]
          ,[Prodzl].[Descr] as Producto
          ,'' as Contacto
,[REQINCDET].Codigo as preAnalisis
 ,[PRE_ANAL].Faltafw as FechaPreAnalisis
            ,EstDet.Descr as EstadoPreAnalisis
          ,Proy.Descrip as ProyectoPreAnalisis


          FROM
          [ZL].[ZL].[Incids]
          join ZL.IyDRequerimientosIncidentes as r on r.numero = incids.codin
          left join [ZL].[ZL].[Tipif] on [Incids].[Cmptipif] = [Tipif].[Ccod]
          left join [ZL].[ZL].[Tipif2] on [Incids].[Cmpstip] = [Tipif2].[Ccod]
          left join     
          (
          select REQINCDET.codigo,  REQINCDET.[Inc_id], REQINCDET.func, [REQINCDET].bug , REQINCDET.funcest, REQINCDET.proy
          from [ZL].[REQINCDET]  join 
								  (select max(codigo) as codigo ,  [Inc_id] , func , bug
								  from [ZL].[REQINCDET]
								  group by [Inc_id] , func , bug ) as ult 
								 on ult.[Inc_id] = [REQINCDET].[Inc_id] and ult.codigo = [REQINCDET].codigo and  ult.func =[REQINCDET].func and ult.bug =[REQINCDET].bug 
		  ) as 	REQINCDET						 
			 on [Incids].[Codin] = [REQINCDET].[Inc_id]
          left join zl.[PRE_ANAL] on [PRE_ANAL].[Codigo]  = [REQINCDET].[Codigo] 
          left join [ZL].[ZL].[Clientes] on [Clientes].[Cmpcodigo] = [Incids].[Ccliente]
          left join [ZL].[ZL].[Prodzl] on [Incids].[Cprod] = [Prodzl].[Ccod]  
            left join [ZL].[ZL].[ESTDET] on [REQINCDET].[Funcest] = [ESTDET].[Codigo]
          left join [ZL].[ZL].[PROY] on [REQINCDET].[Proy] = [PROY].[Codigo]       

		where [Incids].[Cmpfecini] between @FechaDesde and @FechaHasta           
				and RTRIM(r.regpor) in (SELECT RegPor FROM #RegistPor)
and [Incids].[Ccliente] in (SELECT CCLIENTE FROM #Clientes)
	and '' in (SELECT codigo from #RequerPor)			
          ) as Requerimientos 

	LEFT JOIN ZL.FCOMER AS F ON F.CODIGO = REQUERIMIENTOS.FUNCIONALIDAD
	LEFT JOIN ZL.REGBUG AS B ON [REQUERIMIENTOS].[BUG] = B.[CODIN]
	LEFT JOIN ( SELECT FUNCIONALIDAD, FECHA, ESTADO 
				FROM ZL.IYDFUNCIONALIDADULTIMOESTADO 
				WHERE ESTADO IS NOT NULL AND ESTADO <> ' SIN ESTADO '
					AND ESTADO IN (@Estado)) 
		AS ULTEST ON ULTEST.FUNCIONALIDAD = [REQUERIMIENTOS].[BUG] 
			OR ULTEST.FUNCIONALIDAD = [REQUERIMIENTOS].[FUNCIONALIDAD]
	LEFT JOIN ZL.IYDFUNCIONALIDADULTIMOPROYECTO AS FUP ON FUP.FUNCIONALIDAD = F.CODIGO
	LEFT JOIN ZL.IYDBUGETAPAULTIMA AS BEU ON BEU.BUG = B.CODIN
	LEFT JOIN ZL.IYDBUGULTIMOPROYECTO AS BUP ON BUP.BUG = B.CODIN
	LEFT JOIN ZL.IYDBUGULTIMOESTADO AS BUE ON BUE.BUG = B.CODIN
	LEFT JOIN ( SELECT FUNCIONALIDAD, FECHA, COMPROBANTE 
				FROM ZL.IYDFUNCIONALIDADETAPAULTIMA 
				WHERE COMPROBANTE IS NOT NULL 
					AND COMPROBANTE <> ' SIN ESTADO ') 
		AS ULTETAP ON ULTETAP.FUNCIONALIDAD = [REQUERIMIENTOS].[BUG] 
			OR ULTETAP.FUNCIONALIDAD = [REQUERIMIENTOS].[FUNCIONALIDAD]
WHERE 
	CASE 
		WHEN REQUERIMIENTOS.FUNCIONALIDAD IS NULL THEN ' SIN PRE-ANÁLISIS '--NO PASÓ POR PRE-ANÁLISIS TODAVÍA
		ELSE 
			CASE 
				WHEN (REQUERIMIENTOS.FUNCIONALIDAD = 0 AND REQUERIMIENTOS.BUG = 0) THEN REQUERIMIENTOS.ESTADOPREANALISIS --SE DESCARTÓ 
				ELSE 
					CASE 
						WHEN REQUERIMIENTOS.BUG <> 0 THEN ISNULL(BUE.ESTADO,' SIN ESTADO ') 
						ELSE ISNULL(ULTEST.ESTADO,' SIN ESTADO ') 
					END 
			END 
	END IN (@Estado)
	AND
	CASE 
		WHEN REQUERIMIENTOS.FUNCIONALIDAD IS NULL THEN ' SIN PRE-ANÁLISIS ' --NO PASÓ POR PRE-ANÁLISIS TODAVÍA
		ELSE 
			CASE 
				WHEN (REQUERIMIENTOS.FUNCIONALIDAD = 0 AND REQUERIMIENTOS.BUG = 0) THEN ISNULL(REQUERIMIENTOS.PROYECTOPREANALISIS,' SIN EQUIPO ') --SE DESCARTÓ 
				ELSE 
					CASE 
						WHEN REQUERIMIENTOS.BUG <> 0 THEN ISNULL(BUP.PROYECTO, ' SIN EQUIPO ') 
						ELSE ISNULL(FUP.PROYECTO,' SIN EQUIPO ')
					END 
			END 
	END IN (@Proyecto)
	AND ULTEST.FECHA BETWEEN @FECHAESTADODESDE AND @FECHAESTADOHASTA
	AND ULTETAP.FECHA BETWEEN @FECHAESTADODESDE AND @FECHAESTADOHASTA
