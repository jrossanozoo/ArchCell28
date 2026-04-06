select
	CodIn
	, zl.salexcjor.leg
	, ltrim(rtrim(ZL.Legops.Ccortesia)) as Ccortesia
	, convert(varchar(10),FecDesde,103) as FechaDesde
	, convert(varchar(10),Fechasta,103) as FechaHasta
	, HoraIng
	, HoraEgr
	, Almuerzo
	, HorLab
	, case Feriados 
		when 0 then 'No' 
		else 'Si'
		end as Feriados
	, ltrim(rtrim(convert(varchar(151), zl.SalExcJor.obs))) as Obs
from 
	zl.SalExcJor
	left join ZL.Legops on ZL.Legops.Clegajo = zl.SalExcJor.LEG
	
where 
	ZL.Legops.Ccortesia <> ''
	and CodIn in (@Codigo)
	and leg in (@Legajo)
	and fecdesde between @Desde and @Hasta
order by
	FecDesde desc