----------------------------------------------------------------------------------
-- Func  
----------------------------------------------------------------------------------

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[EstadosRsAFecha]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [ZL].[EstadosRsAFecha]
GO

CREATE function [ZL].[EstadosRsAFecha] 
(
	@Fecha datetime
 ) returns table as return

	select 
		nrz as RS, 
		max(numero) as ultimoComprobante,
		'ADM' as Origen
		from zl.ASESTRZAD
		Where fecha <= @Fecha
		group by nrz
union 
	
	Select 
		Razonsoc as RS ,
		max( A.Codin ) as ultimoComprobante,
		'ATC' as Origen
		from ZL.aatmda A 
		where A.Cmpfecfin >= @Fecha
		group by Razonsoc 			  

 GO
 
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[funcRzFacturablesAFecha]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [ZL].[funcRzFacturablesAFecha]
GO

CREATE function [ZL].[funcRzFacturablesAFecha] 
(
	@Fecha datetime
 ) returns table as return


		select 
			[Razonsocial].cmpcod as RZ
			,ultimoComprobante
          from 
				[ZL].[ZL].[Razonsocial] as  [Razonsocial] 
					left join [ZL].[ZL].[Asestrzad] on [Razonsocial].cmpcod =[Asestrzad].nrz
					inner join (
						select RS, ultimoComprobante from [ZL].[EstadosRsAFecha]( @Fecha ))
						as RsUltimoEstado on zl.[Asestrzad].numero = RsUltimoEstado.ultimoComprobante 
					left join zl.Estado  on zl.ASESTRZAD.cestado =  zl.Estado.codigo
			where zl.Estado.Inclfac = 1
GO

------------------------

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[AdmEstadoRS]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [ZL].[AdmEstadoRS]
GO

CREATE function [ZL].[AdmEstadoRS] ( ) returns table as return

select zl.ASESTRZAD.nrz
             ,zl.ASESTRZAD.cestado
             ,ZL.Funciones.Alltrim(zl.Estado.Nombre) as [Estado RS Descripción]
             ,zl.Estado.Codfz as [Código Foto Zoo Logic]
             ,zl.Estado.Inclfac as [Facturable]
             ,case when IsNull(Ltrim(rtrim(zl.Estado.fRAENT)),'')='' then 0 else 1 end as [Dar Código]
             ,zl.Estado.Observmda as [Obtener Servicio MDA]
             ,zl.ASESTRZAD.fecha
          from zl.ASESTRZAD   WITH (NOLOCK)
              inner join 
                 /*se cruza con los últimos comprobantes de asignación de estado*/
                 ( select RS, ultimoComprobante from [ZL].[EstadosRsAFecha]( GETDATE() ) where Origen='ADM' 
                 ) as RsUltimoEstado
                 on zl.ASESTRZAD.numero = RsUltimoEstado.ultimoComprobante 
              left join zl.Estado   WITH (NOLOCK) on zl.ASESTRZAD.cestado =  zl.Estado.codigo

GO 


----------------------------------------------------------------------------------
-- Func  
----------------------------------------------------------------------------------

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[sp_ObtenerFuncionalidadesParaPublicar]') AND type in (N'P', N'PC'))
DROP PROCEDURE [ZL].[sp_ObtenerFuncionalidadesParaPublicar]
GO


create procedure [ZL].[sp_ObtenerFuncionalidadesParaPublicar]
@Proyecto numeric( 10, 0),
@Entidad varchar( 25 )

as

if @Entidad='DEMO'
	select distinct Func codigo from ZL.HPivot as hp
		inner join 
		(SELECT  distinct f.codigo 
                 from
          [ZL].[ZL].[FCOMER]  AS F
          left join [ZL].[IydFuncionalidadUltimoProyecto] as up on up.Funcionalidad = f.codigo
          left join ZL.IydFuncionalidadUltimoEstado as ue on ue.funcionalidad = f.codigo   
          --tiene preestimación
          left join ZL.DetFcPreE as destim on destim.codigo = f.codigo
          left join ZL.FcPreEst on ZL.FcPreEst.numero = destim.codint
            left join zl.DtFcDep on DtFcDep.codint = f.codigo

          left join ZL.DETHISTPUB  on f.codigo = DETHISTPUB.codigo           
                          left join 
                          (select           d.codint, min (isnull(p.Funcionalidad,0)) as TodasListas
                                                          from zl.DtFcDep  as d left join ZL.funcIyDFuncionalidadesPrimeraParaPublicar() as p 
                                                           on p.Funcionalidad= d.func
                                                          group by d.codint
                         )
                                                          as fdepPub on f.codigo = fdepPub.codint        


          where  
          --no esté publicada
          DETHISTPUB.codigo is null    
          and 
          (FcPreEst.numero  is not null or ue.FuncEst=11 ) --está preestimada o es urgente
          and
          IsNull(up.Proy,0) in (@Proyecto)  
          and
          isNull(LTRIM(RTRIM(estado)),'Sin Estado') in ('Presupuesto - Aceptado','Aprobada','Aprobada condicionada', 'Urgencia')
          and 
          --que las funciones dependientes, si tiene, ya estén listas para publicar
          1 >= case when DtFcDep.func is null then 1 else  fdepPub.TodasListas end
          ) as funADes on funADes.codigo = hp.func
	where isNull(LTRIM(RTRIM(hp.estado)),'') = 'Accepted' 
		and hp.func not in  ( select Func FROM ZL.HPivot WHERE isNull(LTRIM(RTRIM(estado)),'') <> 'Accepted' )	
        and hp.func not in  ( select Func from zl.DtIyDemF )
    order by Func
    
else
	select distinct Func codigo from ZL.HPivot as hp
		inner join 
		(SELECT  distinct f.codigo, IsNull(up.Proy,0) as Proyecto
                 from
          [ZL].[ZL].[FCOMER]  AS F
          left join [ZL].[IydFuncionalidadUltimoProyecto] as up on up.Funcionalidad = f.codigo
          left join ZL.IydFuncionalidadUltimoEstado as ue on ue.funcionalidad = f.codigo   
          --tiene preestimación
          left join ZL.DetFcPreE as destim on destim.codigo = f.codigo
          left join ZL.FcPreEst on ZL.FcPreEst.numero = destim.codint
            left join zl.DtFcDep on DtFcDep.codint = f.codigo

          left join ZL.DETHISTPUB  on f.codigo = DETHISTPUB.codigo           
                          left join 
                          (select           d.codint, min (isnull(p.Funcionalidad,0)) as TodasListas
                                                          from zl.DtFcDep  as d left join ZL.funcIyDFuncionalidadesPrimeraParaPublicar() as p 
                                                           on p.Funcionalidad= d.func
                                                          group by d.codint
                         )
                                                          as fdepPub on f.codigo = fdepPub.codint        


          where  
          --no esté publicada
          DETHISTPUB.codigo is null    
          and 
          (FcPreEst.numero  is not null or ue.FuncEst=11 ) --está preestimada o es urgente
          and
          IsNull(up.Proy,0) in ( case when @Proyecto !=0 then (@Proyecto) else IsNull(up.Proy,0) end ) 
          and
          isNull(LTRIM(RTRIM(estado)),'Sin Estado') in ('Presupuesto - Aceptado','Aprobada','Aprobada condicionada', 'Urgencia')
          and 
          --que las funciones dependientes, si tiene, ya estén listas para publicar
          1 >= case when DtFcDep.func is null then 1 else  fdepPub.TodasListas end
          ) as funADes on funADes.codigo = hp.func
	where isNull(LTRIM(RTRIM(hp.estado)),'') = 'Accepted' 
		and hp.func not in  ( select Func FROM ZL.HPivot WHERE isNull(LTRIM(RTRIM(estado)),'') <> 'Accepted' )		
        and hp.func not in  ( select codint from zl.DETHISTPUB )
	order by Func            

GO
-----------------------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[sp_ObtenerBugsParaPublicar]') AND type in (N'P', N'PC'))
DROP PROCEDURE [ZL].[sp_ObtenerBugsParaPublicar]
GO

create procedure [ZL].[sp_ObtenerBugsParaPublicar]
@Proyecto numeric(10),
@Entidad varchar( 25 )
as

if @Entidad='DEMO'
	SELECT b.[Codin] bug, DetEvBugs.bugaso, DetEvBugs.func
		  FROM [ZL].[REGBUG] as b
				inner join ZL.hpivot hp on  hp.bug = b.Codin
						and isNull(LTRIM(RTRIM(hp.estado)),'Sin Estado') in ('Accepted')
				left join  ZL.DetEvBugs on b.codin = DetEvBugs.bug
				left join  zl.DetEvBgIss  on b.codin = DetEvBgIss.bug 
				left join  zl.DetBugPu as dbl on b.codin = dbl.bug
				left join ZL.IydBugUltimoEstado as bue on bue.bug = b.codin
				left join ZL.IydBugUltimoProyecto as bup on bup.bug = b.codin
	  where 
	  --o fue evaluado o es urgente
	  (DetEvBgIss.bug is not null or DetEvBugs.bug is not null or bue.funcest = 11) 
		  and  dbl.bug is null
		  and  IsNull(bup.Proy,0) in (@Proyecto)  
		  and isNull(LTRIM(RTRIM(bue.Estado)),'Sin Estado') in ('Presupuesto - Aceptado','Aprobada','Aprobada condicionada', 'Urgencia') 
		  and b.codin not in ( select Bug from zl.DtIyDemB )
else
	SELECT b.[Codin] bug, DetEvBugs.bugaso, DetEvBugs.func
		  FROM [ZL].[REGBUG] as b
				inner join ZL.hpivot hp on  hp.bug = b.Codin
						and isNull(LTRIM(RTRIM(hp.estado)),'Sin Estado') in ('Accepted')
				left join  ZL.DetEvBugs on b.codin = DetEvBugs.bug
				left join  zl.DetEvBgIss  on b.codin = DetEvBgIss.bug 
				left join  zl.DetBugPu as dbl on b.codin = dbl.bug
				left join ZL.IydBugUltimoEstado as bue on bue.bug = b.codin
				left join ZL.IydBugUltimoProyecto as bup on bup.bug = b.codin
	  where 
	  --o fue evaluado o es urgente
	  (DetEvBgIss.bug is not null or DetEvBugs.bug is not null or bue.funcest = 11) 
		  and  dbl.bug is null
		  and -- IsNull(bup.Proy,0) in (@Proyecto)  
		  IsNull(bup.Proy,0) in ( case when @Proyecto !=0 then (@Proyecto) else IsNull(bup.Proy,0) end ) 
		  and isNull(LTRIM(RTRIM(bue.Estado)),'Sin Estado') in ('Presupuesto - Aceptado','Aprobada','Aprobada condicionada', 'Urgencia') 
		  and b.codin not in ( SELECT Bug FROM ZL.DetBugPu )

GO

-----------------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[sp_ObtenerFuncionalidadesParaProbar]') AND type in (N'P', N'PC'))
DROP PROCEDURE [ZL].[sp_ObtenerFuncionalidadesParaProbar]
GO

create procedure [ZL].[sp_ObtenerFuncionalidadesParaProbar]
@Codigo_Producto varchar(4),
@Hasta_Fecha_Aceptacion as date

as

create table #ObtenerFuncionalidadesParaProbar ( Funcionalidad Numeric(10,0))

insert into #ObtenerFuncionalidadesParaProbar
	exec [ZL].[sp_ObtenerFuncionalidadesParaPublicar] 0,''

	select Funcionalidad
		, D.Nombre as Nombre_Titulo
		, H.Codigo as Codigo_Historia
		, H.Titulo as Titulo
		, convert( varchar, H.Faccep, 103 ) as Aceptacion
		, H.Prop as Propietario 
		, H.Proy Codigo_Proyecto
		, P.Descrip Descripcion_Proyecto	
			from #ObtenerFuncionalidadesParaProbar F 
			inner join zl.fcomer D on D.Codigo = F.Funcionalidad 
			inner join zl.hpivot H on H.FUNC = F.Funcionalidad 
			left join  zl.PROY P on P.Codigo = H.Proy 
			where  F.Funcionalidad 
					in ( select F.Codint from zl.DtFcPr F
						 where F.Ccod = @Codigo_Producto )
				and  convert( date, H.Faccep, 103 ) <= @Hasta_Fecha_Aceptacion	
				and  H.Codigo NOT in ( SELECT  distinct D.HISTID FROM ZL.DETHISTPRU D  
											where  ESTADOPRUE  in ( 2 , 4 ) 
												and D.CODINT = ( select max( CODINT ) from ZL.DETHISTPRU D
																	inner join ZL.PruVer P on P.NUM = D.CODINT 
																where HISTID = D.HISTID  and P.PROD = @Codigo_Producto )	
																					 
										)  					 
				     
drop table #ObtenerFuncionalidadesParaProbar
GO

-----------------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[sp_ObtenerBugsParaProbar]') AND type in (N'P', N'PC'))
DROP PROCEDURE [ZL].[sp_ObtenerBugsParaProbar]
GO

create procedure [ZL].[sp_ObtenerBugsParaProbar]
@Codigo_Producto varchar(4),
@Hasta_Fecha_Aceptacion as date
as

create table #ObtenerBugsParaProbar ( Bug Numeric(10,0),Bugaso Numeric(10,0), Func Numeric(10,0))

insert into #ObtenerBugsParaProbar
	exec [ZL].[sp_ObtenerBugsParaPublicar] 0,''

	select B.Bug
		, D.titulo as Nombre_Titulo 
		, H.Codigo as Codigo_Historia
		, H.Titulo as Titulo
		, convert( varchar, H.Faccep, 103 ) as Aceptacion
		, H.Prop as Propietario
		, H.Proy Codigo_Proyecto
		, P.Descrip Descripcion_Proyecto
			from #ObtenerBugsParaProbar B 
			inner join zl.regBug D on D.Codin = B.Bug 
			inner join zl.hpivot H on H.BUG = B.Bug 
			left join  zl.PROY P on P.Codigo = H.Proy 		
			where  B.Bug
					in ( select B.Codint as Bug  from zl.DBugProd B 
						 where B.CODPROD = @Codigo_Producto )
					and convert( date, H.Faccep, 103 ) <= @Hasta_Fecha_Aceptacion  
					and  B.Bug NOT in ( SELECT  distinct D.HISTID FROM ZL.DETHISTPRU D  
											where  ESTADOPRUE  in ( 2 , 4 ) 
												and D.CODINT = ( select max( CODINT ) from ZL.DETHISTPRU D
																	inner join ZL.PruVer P on P.NUM = D.CODINT 
																	where HISTID = D.HISTID  and P.PROD = @Codigo_Producto )
										)  					
						
drop table #ObtenerBugsParaProbar
GO
-------------------------
delete  from ZL.EstPruVer 
insert into ZL.EstPruVer  ( cod, Descr, Activo ) values ( 1, 'Pendiente', 1 )
insert into ZL.EstPruVer  ( cod, Descr, Activo  ) values ( 2, 'OK', 1 )
insert into ZL.EstPruVer  ( cod, Descr, Activo  ) values ( 3, 'Mal',1 )
insert into ZL.EstPruVer  ( cod, Descr, Activo  ) values ( 4, 'No aplica',1 )
-------------------------

----------------------------------------------------------------------------------
-- Func  
----------------------------------------------------------------------------------