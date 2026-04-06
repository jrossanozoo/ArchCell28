use ZL
go

insert into ZL.ZNPCONTROL (
	ZL.ZNPCONTROL.CodZnube
	, CVERSION
	, [DESCR] 
	, COD
	, METVAL
	)
SELECT
	distinct 
	[Id]
	, [Version]
	, [Name]
	, ROW_NUMBER() OVER(order by [version]) as numero
	, [TypeAplication]
FROM 
	[zNube_Hub01].[d1ada87a-240b-46d6-966e-5d493172f723_TM].[dbo].[ApplicationValidator]
group by
	[Id]
	,[Version]
	,[TypeAplication]
	,[Name]
go
