DECLARE @BUG AS INT;

SET @BUG = 1201;

SELECT 
b.[Codin]
,b.[Cmpfecini]
   ,b.[Regpor]
      ,b.[TITULO]      
      ,dp.[Codprod]
      ,dp.desprod as Producto
      ,dp.[CBUILD]
      ,v.Version
       ,b.[Desbug]     
      ,b.[Msgsis]      
      ,b.[Cseve]
      ,ISSEVE.des as Severidad
     ,b.[Cocurr]
     ,ISSOCU.des as Ocurrencia
      ,b.[Codeos]
      ,cedoss.descr as EdicionSO
      ,dp.[Codesti]
      ,dp.desesti as Estilo      
      ,dp.[Codmotor]
      ,dp.desmotor as Motor
      ,b.[Codos]
      ,coss.descr as SO
      ,b.[Codplat]
      ,cplatoss.Descr as PlataformaOS
      --,b.[CVERSION]
,( select sum(horas) from  ZL.IyDHorasFuncBug where Bug =@Bug ) as HorasZL
	
,bue.Estado as BugEstadoActual
,bup.Proyecto as BugProyectoActual
,bpub.Fecha as BugFechaTerminada
, case when (eval.func=0 and  eval.bugaso=0) or (eval.func is null and eval.bugaso is null )then 'Nada' else  case when eval.func=0 then 'Bug' else 'Funcionalidad' end end as EntidRela,
	case when(eval.func=0 and  eval.bugaso=0) or (eval.func is null and eval.bugaso is null ) then 0 else  case when eval.func=0 then eval.bugaso  else eval.func end end as EntidRelaNumero,
	case when (eval.func=0 and  eval.bugaso=0) or (eval.func is null and eval.bugaso is null ) then '' else  case when eval.func=0 then eval.titaso  else eval.nombre end end as EntidRelaTitulo
,bsp.Sprints
,b.imgbug


  FROM [ZL].[REGBUG] as b
  left join zl.DBugProd as dp on dp.codint = b.codin           
  left join [ZL].[IyDBugVersion] as v on v.bug = b.codin and dp.codprod = v.producto
  left join zl.DetEvBugs as eval on eval.bug = b.codin
  left join zl.coss on b.[Codos] = zl.coss.ccod
  left join zl.cplatoss  on b.[Codplat] = cplatoss.ccod
  left join zl.cedoss  on b.[Codeos] = cedoss.ccod
  left join zl.ISSEVE  on b.[Cseve] = ISSEVE.cod
  left join zl.ISSOCU  on  b.[Cocurr] = ISSOCU.cod
  
left join ZL.IydBugUltimoProyecto as bup on bup.bug = b.codin
left join ZL.IydBugUltimoEstado as bue on bue.bug = b.codin
left join ZL.[IydBugCorregidosAPublicarPrimero] as bpub on bpub.Bug = b.codin
left join ZL.IyDduracionSprintsFuncBugs  as bsp on bsp.Bug = b.codin

where b.[Codin] = @Bug