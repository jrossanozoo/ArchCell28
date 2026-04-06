USE [ZL]
GO

/****** Object:  UserDefinedFunction [RRHH].[func_RRHH_EsquemasExcepcionesAsignadas_II]    Script Date: 08/15/2013 11:52:43 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[RRHH].[func_RRHH_EsquemasExcepcionesAsignadas_II]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [RRHH].[func_RRHH_EsquemasExcepcionesAsignadas_II]
GO

USE [ZL]
GO

/****** Object:  UserDefinedFunction [RRHH].[func_RRHH_EsquemasExcepcionesAsignadas_II]    Script Date: 08/15/2013 11:52:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create function [RRHH].[func_RRHH_EsquemasExcepcionesAsignadas_II]
(
	@Fecha datetime
)
RETURNS TABLE 
AS
RETURN 
(
With Asignaciones as
(
      Select 
            Leg as Legajo
            ,Numero
            ,esqlab as Esquema
            ,'Legajo'  as [Tipo de asignación]
            ,Fecdesde as [Fecha desde]
            ,fecHasta  as [Fecha hasta]
            ,ualtafw as [Registrado por]
            ,faltafw as [Registrado el]
            ,2 as Prioridad
            ,pH.[Apellido y nombre]
            ,pH.sector as Sector
            ,pH.subsector as Area
            ,pH.Puesto
            ,pH.Descripcion
      from zl.ZL.ASIGESQJLAB as a
            join [ZL].[RrhhPuestosHistoricos] as ph on a.leg = ph.legajo

      union all

      Select 
            legajo
            ,Numero
            ,esqlab as esquema
            ,'Puesto'  as [Tipo de asignación]
            ,Fecdesde
            ,fechasta
            ,ualtafw  as [Registrado por]
            ,faltafw as [Registrado el]
            ,3 as Prioridad
            ,pH.[Apellido y nombre]
            ,pH.sector as Area
            ,pH.subsector as Sector
            ,pH.Puesto
            ,pH.Descripcion
      from ZL.ASIGESQJLAP     as a
            join [ZL].[RrhhPuestosHistoricos] as ph on ph.[Puesto] = a.puesto
      where  
            '' between convert(varchar(6),finicio,112) and convert(varchar(6),ffin,112)
            or @fecha between finicio and ffin
            
      union all
      Select 
            legajo
            ,Codin as Numero
            ,0 as esquema
            ,'Excepción'  as [Tipo de asignación]
            ,Fecdesde
            ,fechasta
            ,ualtafw  as [Registrado por]
            ,faltafw as [Registrado el]
            ,1 as Prioridad
            ,pH.[Apellido y nombre]
            ,pH.sector as Sector
            ,pH.subsector as Area
            ,pH.Puesto
            ,pH.Descripcion
      from ZL.SALEXCJOR  as s
            join [ZL].[RrhhPuestosHistoricos] as ph on ph.empleado = s.usu
)

      Select 
            a.*
      from Asignaciones as a
            join [ZL].[RrhhPuestosHistoricos] as p on a.legajo = p. legajo and a.puesto = p.puesto
      where 
      
            ('' between convert(varchar(6),finicio,112) and convert(varchar(6),ffin,112)
            or @fecha between finicio and ffin)
            and ('' between convert(varchar(6),[Fecha desde],112) and convert(varchar(6),[Fecha hasta],112)
            or @fecha between [Fecha desde] and [Fecha hasta] )
            
)

GO

--declare @Fecha datetime
--set @Fecha = getdate();

--select 
--	* 
--from 
--	[RRHH].[func_RRHH_EsquemasExcepcionesAsignadas_II](convert(datetime, convert(varchar(10), @Fecha, 120), 120))
--order by 
--	[Apellido y nombre]
--	,	prioridad
--	,	[Tipo de asignación]
--	,	numero desc
	
	
