USE [ZL]
GO

/****** Object:  UserDefinedFunction [RRHH].[func_RRHH_EsquemasExcepcionesAsignadas]    Script Date: 08/20/2013 12:12:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[RRHH].[func_RRHH_EsquemasExcepcionesAsignadas]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [RRHH].[func_RRHH_EsquemasExcepcionesAsignadas]
GO

USE [ZL]
GO

/****** Object:  UserDefinedFunction [RRHH].[func_RRHH_EsquemasExcepcionesAsignadas]    Script Date: 08/20/2013 12:12:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create function [RRHH].[func_RRHH_EsquemasExcepcionesAsignadas]
(
	@Fecha datetime
)
RETURNS TABLE 
AS
RETURN 
(
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
		a.legajo AS legajo
		, a.numero
		, a.esquema
		, a.[Tipo de Asignación]
		, convert(varchar(10), a.[Fecha desde], 103) as [Fecha desde]
		, convert(varchar(10), a.[Fecha hasta], 103) as [Fecha hasta]
		, a.[Registrado por]
		, a.[Registrado el]
		, a.[Prioridad]
		, p.[Apellido y nombre]
		, p.sector as Sector
		, isnull(AR.CODIGO, '    ') as Area
		, p.Puesto
		, ltrim(rtrim(p.descripcion)) as [Descripción]
	from 
		Asignaciones as a
		join [ZL].[RrhhPuestosHistoricos] as p on p.legajo = a. legajo
		left join [ZL].[AREA] AS AR ON AR.CODIGO = p.subsector and ar.sector = p.sector
	where 
		( '' between convert(varchar(6), finicio, 112) and convert(varchar(6), ffin, 112) or convert(datetime, convert(varchar(10), @Fecha, 120), 120) between finicio and ffin )
		and ( '' between convert(varchar(6), [Fecha desde], 112) and convert(varchar(6),[Fecha hasta], 112) or convert(datetime, convert(varchar(10), @Fecha, 120), 120) between [Fecha desde] and [Fecha hasta] )
)


GO


