USE [ZL]
GO

/****** Object:  UserDefinedFunction [Objetivos].[func_RRHH_GestionDeHorarios]    Script Date: 08/15/2013 16:27:39 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Objetivos].[func_RRHH_GestionDeHorarios]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Objetivos].[func_RRHH_GestionDeHorarios]
GO

USE [ZL]
GO

/****** Object:  UserDefinedFunction [Objetivos].[func_RRHH_GestionDeHorarios]    Script Date: 08/15/2013 16:27:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<ffrenkel>
-- Create date: <11/08/2013>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [Objetivos].[func_RRHH_GestionDeHorarios]  
(	
	@Fechai as datetime
	,@fechaf as datetime 
	--,@Usuario varchar (40) = null /* Para llamar a la funcion sin este parámetro llamarlo con dafault: ,default*/
	--,@Area varchar(4) = 'DIR'  /* Para llamar a la funcion sin este parámetro llamarlo con dafault: ,default*/
	--,@MandoMedio varchar(2) = 'Si'
	--,@TodosLosLegajos varchar(2) = 'Si'
	--,@SoloIncumplimientos varchar (2) = 'No'
)
RETURNS TABLE 
--with encryption 
AS

RETURN 
(

/* Para llamar a la funcion sin los parametros @area ni @usuario llamarlos por ejemplo:

SELECT * FROM [ZL].[Objetivos].[func_RRHH_GestionDeHorarios] (
  '20130801'
  ,getdate()
  ,default
  ,default
  )

*/



with FechasValidas as 
(
	Select 
		Fecha
		,dianombre
		,diadelasemana
		,anio_mes
	 from zl.dbo.fechascalendario as f 
	 where f.fecha between @Fechai and @fechaf
)
, LegajosxFechaActivos as
(
	Select 
		f.Fecha as Fecha
		,puh.Empleado
		,puh.[Apellido y nombre]
		,puh.Legajo as Legajo
		,puh.Puesto
		,puh.sector as [Area]
		,puh.subsector as [Sector]
		,puh.descripcion as [Puesto descripción]
		,f.dianombre as [Día nombre]
		,f.anio_mes as [Período]
		,jmm.[Mandos medios]
	from [ZL].[RrhhPuestosHistoricos] as PuH
		join FechasValidas as f on f.fecha between PuH.finicio and PuH.ffin
		left join  [ZL].[ZL].[Vista_RRHH_Puestos_MandosMedios] as jmm on puh.Puesto = jmm.puesto
	where Legajo not in ('0001','0002')
			

)

,Fichajes as
(
	 Select 
		  cast(convert(varchar(8),[FCHREG],112) as datetime) as fecha
		  ,[LEGAJO]
		  ,min([FCHREG]) as [Fichaje]
		  ,'Entrada' as [Fichaje tipo]
	 FROM [ZL].[ZL].[ZNFICHAJE]
	 group by cast(convert(varchar(8),[FCHREG],112) as datetime),legajo
	 union all
	 Select 
		  cast(convert(varchar(8),[FCHREG],112) as datetime) as fecha
		  ,[LEGAJO]
		  ,max([FCHREG]) as [Fichaje]
		  ,'Salida' as [Fichaje tipo]
	 FROM [ZL].[ZL].[ZNFICHAJE]
	 group by cast(convert(varchar(8),[FCHREG],112) as datetime),legajo
	
)

,Gestion as
(
	SELECT 
		Fecha
		,Numero
		,case when [INCHLAB]= 'AUS' then 'Ausencia'
			else
				case when [INCHLAB]= 'SAT' then 'Salida temprana'
				else 'Tarde' end end as  [Tipo Incumplimiento]
		,[LEG] as Legajo
	FROM [ZL].[ZL].[GESINC]
	join FechasValidas as f on f.fecha between Fechai and FechaF 
)


,GestionMax as
(
	Select
		Fecha
		,[Tipo Incumplimiento]
		,Legajo
		,max(numero) as numero
	from Gestion
	group by Fecha,[Tipo Incumplimiento],Legajo
)

,LegajoAsig as
(
	Select 
		Leg
		,Numero
		,Fecha
	from zl.ZL.ASIGESQJLAB
	 join FechasValidas as f on f.fecha between FECDESDE and FECHASTA 
)
, LegajoAsigmax as
(
	Select
		Fecha
		,Leg
		,max(numero) as Numero
	from LegajoAsig
	group by leg,fecha
)
, PuestoAsig as
(
	Select 
		Puesto
		,Numero
		,Fecha
	from ZL.ASIGESQJLAP
	 join FechasValidas as f on f.fecha between FECDESDE and FECHASTA   
)
, PuestoAsigmax as
(
	Select
		Fecha
		,Puesto
		,max(numero) as Numero
	from PuestoAsig
	group by puesto,fecha
)
,ExcepAsig as
(
	Select 
		Usu
		,Codin as Numero
		,Fecha
	from ZL.SALEXCJOR
	 join FechasValidas as f on f.fecha between FECDESDE and FECHASTA  
)

, ExcepAsigMax as
(
	Select
		Fecha
		,Usu
		,max(numero) as Numero
	from ExcepAsig
	group by usu,fecha
)

, UnionLegajoPuestoExcep as
(	
	Select
		Leg
		,Fecha
		,2 as Prioridad
		,numero 
	from LegajoAsigmax as L
	union all
	Select
		ph.[Legajo]
		,Pu.Fecha
		,3 as Prioridad
		,Pu.numero
	from PuestoAsigMax as Pu
	join [ZL].[RrhhPuestosHistoricos] as ph on ph.[Puesto] = Pu.puesto and Pu.Fecha between [Finicio] and [Ffin]
	union all
	Select 
		ph.[Legajo]
		,E.Fecha
		,1 as Prioridad
		,E.numero
	from ExcepAsigmax as e
	join [ZL].[RrhhPuestosHistoricos] as ph on ph.[Empleado] = E.usu and E.Fecha between [Finicio] and [Ffin]
)
, ComprobanteAsigValidoxDíaxLegajo as
(

	select
		Leg
		,Fecha
		,min(Prioridad) as Prioridad
		,max(numero) as numero
  from UnionLegajoPuestoExcep
  group by leg,fecha
)
, UnionCompletaSinDetectarAsignacionValida as
(
	Select 
		L.Fecha
		,L.Leg as Legajo
		,L.numero
		,ASIGESQJLAB.ESQLAB as Esquema
		,'Legajo' as [Tipo de asignación]
		,2 as Prioridad

	from LegajoAsigMax as L
	join zl.ZL.ASIGESQJLAB on L.Numero = ASIGESQJLAB.numero

	union all

	Select
		Pu.Fecha
		,ph.[Legajo]
		,Pu.numero
		,ESQLAB as Esquema
		,'Puesto' as [Tipo de asignación]
		,3 as Prioridad
	from PuestoAsigMax as Pu
	join zl.ZL.ASIGESQJLAP on Pu.Numero = ASIGESQJLAP.numero
	join [ZL].[RrhhPuestosHistoricos] as ph on ph.[Puesto] = Pu.puesto and Pu.Fecha between [Finicio] and [Ffin]
	

	union all

	Select 
		Ex.Fecha
		,ph.[Legajo]
		,Ex.numero
		,0 as Esquema 
		,'Excepción' as [Tipo de asignación]
		,1 as Prioridad
	from ExcepAsigMax as Ex
	join [ZL].[RrhhPuestosHistoricos] as ph on ph.[Empleado] = Ex.usu and Ex.Fecha between [Finicio] and [Ffin]

)
, AsignacionesVálidasxFechaxLegajo as
(
	Select 
		UCSDAV.Fecha
		,UCSDAV.Legajo
		,UCSDAV.numero as Numero
		,UCSDAV.Esquema
		,UCSDAV.[Tipo de asignación]

	from UnionCompletaSinDetectarAsignacionValida as UCSDAV 
	join ComprobanteAsigValidoxDíaxLegajo as CAVxDxL on UCSDAV.Fecha = CAVxDxL.Fecha 
		and UCSDAV.[Legajo] = CAVxDxL.Leg
		and UCSDAV.Prioridad = CAVxDxL.Prioridad
		and UCSDAV.numero = CAVxDxL.numero
	
)
, AsignacionesVálidasFinales as
(
	select 
		AsignacionesVálidasxFechaxLegajo.*
		,EsqCab.TMAXLLEGTJ as Tolerancia
		,AsignacionesVálidasxFechaxLegajo.fecha + cast(EsqDet.horaing as datetime) as [Hora ingreso s/asig]
		,AsignacionesVálidasxFechaxLegajo.fecha + cast(EsqDet.horaegr as datetime) as [Hora egreso s/asig]
		,AsignacionesVálidasxFechaxLegajo.fecha + cast(EsqDet.horaing as datetime) + cast('00:'+ cast(EsqCab.TMAXLLEGTJ as varchar(3))as datetime) as [Hora ingreso s/asig c/tolerancia]
		--,FechasValidas.dianombre
	from AsignacionesVálidasxFechaxLegajo
		join FechasValidas on FechasValidas.fecha = AsignacionesVálidasxFechaxLegajo.Fecha 
		join ZL.SalRgDH as EsqCab on EsqCab.codin = Esquema
		join ZL.dtsalrgdh as EsqDet on EsqDet.codint = Esquema and FechasValidas.diadelasemana = EsqDet.dia
	where  [Tipo de asignación] = 'Puesto' or [Tipo de asignación] = 'Legajo'
	union all
	Select 
		AsignacionesVálidasxFechaxLegajo.*
		,0 as Tolerancia
		,AsignacionesVálidasxFechaxLegajo.fecha + cast(case when hinicio= '' then '00' else hinicio end  +':'+ case when minicio='' then '00' else minicio end as datetime) as [Hora ingreso s/asig]
		,AsignacionesVálidasxFechaxLegajo.fecha + cast(case when hfin= '' then '00' else hfin end  +':'+ case when mfin='' then '00' else mfin end as datetime) as [Hora egreso s/asig]
		,AsignacionesVálidasxFechaxLegajo.fecha + cast(case when hinicio= '' then '00' else hinicio end  +':'+ case when minicio='' then '00' else minicio end as datetime) as [Hora ingreso s/asig c/tolerancia]
		--,''
	from AsignacionesVálidasxFechaxLegajo
		join ZL.SALEXCJOR as Exc on numero = Exc.Codin 
	where  [Tipo de asignación] = 'Excepción'		
)

, LegajosActivosxDiaConAsignaciones as
(
	select 
		l.*
		,a1.Numero
		,a1.Esquema
		,a1.[Tipo de asignación]
		,a.Tolerancia
		,a.[Hora ingreso s/asig]
		,a.[Hora egreso s/asig]
		,a.[Hora ingreso s/asig c/tolerancia]

	from LegajosxFechaActivos as l
	left join AsignacionesVálidasFinales as a on a.Fecha = l.fecha and a.legajo = l.legajo   
	left join AsignacionesVálidasxFechaxLegajo as a1 on a1.Fecha = l.fecha and a1.legajo = l.legajo
)

, Análisis as
(
	select 
		l.*
		,Case when [Fichaje tipo] = 'Entrada'
			then Tolerancia
			end as [Tolerancia ingreso]
		,Case when [fichaje tipo] = 'Entrada' 
			or	 numero is not null and [Hora ingreso s/asig] is not null and fichaje is null -- Ausencia
			then [Hora ingreso s/asig]
			else 
				 Case when [fichaje tipo] = 'Salida'
				 then  [Hora egreso s/asig]
				 end
			end as [Hora seg/asign.]
		,f.[Fichaje]
		,f.[Fichaje tipo] 
		,Case when numero is not null and [Hora ingreso s/asig]	is null and fichaje is null /* Dias que no se trabaja segun esquema */
			then 'No corresponde'
			else
				case when numero is null  
					or [Fichaje tipo] = 'Entrada' and [Hora ingreso s/asig]	is null /* esquema sin hora de ingreso  */
					or [Fichaje tipo] = 'Salida' and [Hora egreso s/asig]	is null /* esquema sin hora de egreso   */
					or [Fichaje tipo] = 'Entrada' and f.[Fichaje] > [Hora ingreso s/asig c/tolerancia] + '00:01' /* Tarde */
					or [fichaje tipo] = 'Salida' and [Fichaje] < [Hora egreso s/asig] and [Hora egreso s/asig] < getdate() /*Salida Temprana*/
					or [Fichaje] is null and [Hora ingreso s/asig] < getdate() /* Ausencia */
				then 'Si'
				else 
					case when [Hora ingreso s/asig] < getdate()
					then ''
					else 'No'
					end
				end
			end as Incumplimiento
		,Case when numero is not null and [Hora ingreso s/asig]	is null and fichaje is null /* Dias que no se trabaja segun esquema */
			then 'No corresponde'
			else
				Case when [Fichaje tipo] = 'Entrada' and [Hora ingreso s/asig]	is null /* esquema sin hora de ingreso  */
				or [fichaje tipo] = 'Entrada' and f.[Fichaje] > [Hora ingreso s/asig c/tolerancia] + '00:01' /* Tarde */
				or  [fichaje tipo] = 'Entrada' and numero is null /* Fichajes sin esquema asignado */
				then 'Tarde'
				else
					case when [Fichaje tipo] = 'Salida' and [Hora egreso s/asig] is null -- esquema sin hora de ingreso 
					or [fichaje tipo] = 'Salida' and [Fichaje] < [Hora egreso s/asig] and [Hora egreso s/asig] < getdate() --Salida Temprana 
					or [fichaje tipo] = 'Salida' and numero is null -- Fichajes sin esquema asignado 
					then 'Salida temprana'
					Else
						case when [Fichaje] is null and [Hora ingreso s/asig] < getdate()
						then 'Ausencia'
						Else ''
						end
					end
				end
			end as [Tipo Incumplimiento]
		,Case when [Fichaje tipo] = 'Entrada' and [Hora ingreso s/asig]	is null /* esquema sin hora de ingreso  */
			or [fichaje tipo] = 'Entrada' and f.[Fichaje] > [Hora ingreso s/asig c/tolerancia] + '00:01' /* Tarde */
			or  [fichaje tipo] = 'Entrada' and numero is null /* Fichajes sin esquema asignado */
			then [Fichaje] - [Hora ingreso s/asig]
			else
				case when [Fichaje tipo] = 'Salida' and [Hora egreso s/asig] is null -- esquema sin hora de ingreso 
				or [fichaje tipo] = 'Salida' and [Fichaje] < [Hora egreso s/asig] and [Hora egreso s/asig] < getdate() --Salida Temprana 
				or [fichaje tipo] = 'Salida' and numero is null -- Fichajes sin esquema asignado 
				then [Hora egreso s/asig] - [Fichaje]
				end
			end  as [Tiempo incumplimiento]
		,Case when numero is null then 'No' else 'Si' end as [Posee asignación] 
	from LegajosActivosxDiaConAsignaciones as l
	left join fichajes as f on f.fecha = l.fecha and f.legajo = l.legajo
	
)

Select 
	i.[Fecha] AS Fecha
	, i.[Empleado]
	, i.[Apellido y Nombre]
	, i.[Legajo]
	, i.[Puesto]
	, i.[Area]
	, i.[Sector]
	, i.[Puesto descripción]
	, i.[Día nombre]
	, i.[Período]
	, i.[Mandos medios]
	, i.[Numero]
	, i.[Esquema]
	, i.[Tipo de asignación]
	, i.[Tolerancia]
	, i.[Hora ingreso s/asig] as [Hora ingreso s/asig]
	, i.[Hora egreso s/asig] as [Hora egreso s/asig]
	, i.[Hora ingreso s/asig c/tolerancia] as [Hora ingreso s/asig c/tolerancia]
	, i.[Tolerancia ingreso]
	, i.[Hora seg/asign.] as [Hora seg/asign.]
	, i.[Fichaje] as [Fichaje]
	, i.[Fichaje tipo]
	, i.[Incumplimiento]
	, i.[Tipo Incumplimiento]
	, i.[Tiempo incumplimiento] as [Tiempo incumplimiento]
	, i.[Posee asignación]
	,g.numero as [Gestión Número]
	,case when gesinc.justifica = 1 
		then 'Si' 
		else
			case when g.numero is not null
			then 'No'
			end
		end as [Incumplimiento Justificado]
	,motaus.[Descr] as Motivo
 from Análisis as i
	left join gestionmax as g on i.fecha = g.fecha and g.[Tipo Incumplimiento] = i.[Tipo Incumplimiento] and i.legajo = g.legajo
	left join [ZL].[ZL].[GESINC] on g.numero = gesinc.numero
	left join [ZL].[ZL].[Motaus] on gesinc.motivo = motaus.ccod

)

GO


