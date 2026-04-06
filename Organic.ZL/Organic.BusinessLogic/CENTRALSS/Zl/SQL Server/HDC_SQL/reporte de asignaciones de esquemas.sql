declare @Fecha datetime;
set @Fecha = '20130805';

With Asignaciones as (
	Select 
		Leg as Legajo
		, Numero
		, esqlab as Esquema
		, 'Legajo' as [Tipo de asignación]
		, Fecdesde as [Fecha desde]
		, fecHasta as [Fecha hasta]
		, ualtafw as [Registrado por]
		, faltafw as [Registrado el]
		, 2 as Prioridad
	from 
		zl.ZL.ASIGESQJLAB

	union all
	
	Select 
		legajo
		, Numero
		, esqlab as esquema
		, 'Puesto' as [Tipo de asignación]
		, Fecdesde
		, fechasta
		, ualtafw as [Registrado por]
		, faltafw as [Registrado el]
		, 3 as Prioridad
	from 
		ZL.ASIGESQJLAP as a
		join [ZL].[RrhhPuestosHistoricos] as ph on ph.[Puesto] = a.puesto 
	
	union all
	
	Select 
		legajo
		, Codin as Numero
		, 0 as esquema
		, 'Excepción' as [Tipo de asignación]
		, Fecdesde
		, fechasta
		, ualtafw as [Registrado por]
		, faltafw as [Registrado el]
		, 1 as Prioridad
	from 
		ZL.SALEXCJOR as s
		join [ZL].[RrhhPuestosHistoricos] as ph on ph.empleado = s.usu
)
Select distinct
	a.*
	, p.[Apellido y nombre]
	, p.sector as Area
	, p.subsector as Sector
	, p.Puesto
from 
	Asignaciones as a
	join [ZL].[RrhhPuestosHistoricos] as p on p.legajo = a. legajo
where 
	( '' between convert(varchar(6), finicio, 112) and convert(varchar(6), ffin, 112) or convert(datetime, @Fecha, 120) between finicio and ffin )
	and ( '' between convert(varchar(6), [Fecha desde], 112) and convert(varchar(6),[Fecha hasta], 112) or convert(datetime, @Fecha, 120) between [Fecha desde] and [Fecha hasta] )
order by 
	p.[Apellido y nombre]
	, prioridad
	, [Tipo de asignación]
	, numero desc