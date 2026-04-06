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
			else case when  Requerimientos.Bug <> 0 then iSNull(bue.estado,' Sin Estado ') else isNull(fue.Estado,' Sin Estado ') end end end  as EntidadRelacionadaEstadoActual
		 	
		 	
           ,case when Requerimientos.Funcionalidad is null THEN ' Sin Pre-Análisis ' --no pasó por pre-análisis todavía
			else case when (Requerimientos.Funcionalidad=0 and Requerimientos.bug=0) --se descartó 
				Then IsNull(Requerimientos.ProyectoPreAnalisis,' Sin Equipo ')
			else case when  Requerimientos.Bug <> 0 then isnUll(bup.Proyecto, ' Sin Equipo ') else isNull(fup.Proyecto,' Sin Equipo ')  end end end as EntidadRelacionadaProyectoActual
		
		 
		 ,case when Requerimientos.Funcionalidad is null --no pasó por pre-análisis todavía
				or (Requerimientos.Funcionalidad=0 and Requerimientos.bug=0) --se descartó 
				Then ''
			else case when  Requerimientos.Bug <> 0 then b.Titulo else f.Nombre end end as EntidadRelacionadaNombre
		
		 ,case when Requerimientos.Funcionalidad is null THEN '' --no pasó por pre-análisis todavía
			ELSE CASE WHEN  (Requerimientos.Funcionalidad=0 and Requerimientos.bug=0) THEN 'Pre-Análisis' ELSE --se descartó 
				case when  Requerimientos.Bug <> 0 then beu.Comprobante else feu.Comprobante end end END as EntidadRelacionadaUltimaEtapaComprobante
	
		 
		,case when Requerimientos.Funcionalidad is null THEN 0 --no pasó por pre-análisis todavía
			ELSE CASE WHEN  (Requerimientos.Funcionalidad=0 and Requerimientos.bug=0) THEN 	Requerimientos.Preanalisis
	else case when  Requerimientos.Bug <> 0 then  beu.Numero else  feu.Numero end end end as EntidadRelacionadaUltimaEtapaComprobanteNumero
		 
		 ,case when Requerimientos.Funcionalidad is null --no pasó por pre-análisis todavía
			or (Requerimientos.Funcionalidad=0 and Requerimientos.bug=0) --se descartó 
				Then Requerimientos.FechaPreAnalisis
			else case when  Requerimientos.Bug <> 0 then  beu.fecha else  feu.Fecha end end as EntidadRelacionadaUltimaEtapaComprobanteFecha
					                    
       	,CONVERT(VARCHAR, fue.Fecha, 103) as 'UltimaEtapaFecha'
 
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
          ,''as [Req Observación]
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
AND REQCLIDET.FUNC <> 0
and [PNCEREQ].[Faltafw] between @FechaDesde and @FechaHasta  
and RTRIM([PNCEREQ].[Regpor]) in (@RegPor)
and [PNCEREQ].[Ccliente] in (@Cliente)
and '' in (@RequeridoPor)

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
		and RTRIM([REQUER].[Regpor]) in (@RegPor)
and '' in (@Cliente)
and rtrim(Requer.ReqId)  in (@RequeridoPor)

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
				and RTRIM(r.regpor) in (@RegPor)
and [Incids].[Ccliente] in (@Cliente)
	and '' in (@RequeridoPor)			
          ) as Requerimientos 

          left join zl.fcomer as f on f.codigo = Requerimientos.Funcionalidad
          left join zl.regbug as b on [Requerimientos].[Bug] = b.[Codin]
	  left join (SELECT ZL.IydFuncionalidadUltimoEstado.Funcionalidad, ZL.IydFuncionalidadUltimoEstado.Estado, MAX(ZL.IydFuncionalidadUltimoEstado.Fecha) AS Fecha 
			   FROM ZL.IydFuncionalidadUltimoEstado 
			  GROUP BY ZL.IydFuncionalidadUltimoEstado.Funcionalidad, ZL.IydFuncionalidadUltimoEstado.Estado) as fue on fue.Funcionalidad = f.codigo
          left join ZL.IydFuncionalidadUltimoProyecto as fup on fup.Funcionalidad = f.codigo
          left join ZL.IydBugEtapaUltima as beu on beu.Bug = b.codin
          left join ZL.IydBugUltimoProyecto as bup on bup.bug = b.codin
          left join ZL.IydBugUltimoEstado as bue on bue.bug = b.codin
          left join (SELECT ZL.IyDFuncionalidadEtapaUltima.Numero, ZL.IyDFuncionalidadEtapaUltima.Funcionalidad, ZL.IyDFuncionalidadEtapaUltima.Comprobante, MAX(ZL.IyDFuncionalidadEtapaUltima.Fecha) AS Fecha 
			   FROM ZL.IyDFuncionalidadEtapaUltima 
			  GROUP BY ZL.IyDFuncionalidadEtapaUltima.Funcionalidad, ZL.IyDFuncionalidadEtapaUltima.Comprobante, ZL.IyDFuncionalidadEtapaUltima.Numero) as feu on feu.Funcionalidad = f.codigo

where case when Requerimientos.Funcionalidad is null THEN ' Sin Pre-Análisis '--no pasó por pre-análisis todavía
				else case when (Requerimientos.Funcionalidad=0 and Requerimientos.bug=0) --se descartó 
				Then Requerimientos.EstadoPreAnalisis
			else case when  Requerimientos.Bug <> 0 then iSNull(bue.estado,' Sin Estado ') else isNull(fue.Estado,' Sin Estado ') end end end  in (@Estado)

and


  case when Requerimientos.Funcionalidad is null THEN ' Sin Pre-Análisis ' --no pasó por pre-análisis todavía
			else case when (Requerimientos.Funcionalidad=0 and Requerimientos.bug=0) --se descartó 
				Then IsNull(Requerimientos.ProyectoPreAnalisis,' Sin Equipo ')
			else case when  Requerimientos.Bug <> 0 then isnUll(bup.Proyecto, ' Sin Equipo ') else isNull(fup.Proyecto,' Sin Equipo ')  end end end in (@Proyecto)
and fue.Fecha between @FechaEstadoDesde and @FechaEstadoHasta
OR feu.Fecha between @FechaEtapaDesde and @FechaEtapaHasta