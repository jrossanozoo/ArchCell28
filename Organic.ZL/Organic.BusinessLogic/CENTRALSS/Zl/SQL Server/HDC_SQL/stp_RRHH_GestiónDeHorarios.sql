USE [ZL]
GO

/****** Object:  StoredProcedure [ZL].[stp_RRHH_GestiónDeHorarios]    Script Date: 08/23/2013 15:30:21 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[stp_RRHH_GestiónDeHorarios]') AND type in (N'P', N'PC'))
DROP PROCEDURE [ZL].[stp_RRHH_GestiónDeHorarios]
GO

USE [ZL]
GO

/****** Object:  StoredProcedure [ZL].[stp_RRHH_GestiónDeHorarios]    Script Date: 08/23/2013 15:30:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		ffrenkel
-- Create date: 12/08/13
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [ZL].[stp_RRHH_GestiónDeHorarios]
	@Fechai as datetime 
	,@fechaf as datetime
	, @Usuario as varchar(40) = null
as
 declare 
	@Area varchar(4) 
	--,@Usuario varchar (40)
	,@MandoMedio varchar(2)
	,@Sector varchar(4)
	,@NivelJerárquico int
	,@SoloIncumplimientos varchar (2)
	,@TodosLosLegajos varchar(2)
BEGIN
	SET NOCOUNT ON;
		
		
		if @Usuario is null
		begin
			set @Usuario = right(SUSER_NAME(),len(SUSER_NAME()) - PATINDEX('%\%',SUSER_NAME()));;
		end
		
		--Set @Usuario = 'aanica'
		--Set @Usuario = 'SMIROCHNIK'
		--Set @Usuario = 'rlombardo'
		--Set @Usuario = 'efaricelli'
		--Set @Usuario = 'LGOMEZ'

		set @Area = (Select top 1 Sector from [ZL].[RrhhPuestosHistoricos] as PuH where puh.Empleado = @Usuario and  getdate() between PuH.finicio and PuH.ffin)
		Set @Sector = (Select top 1 Subsector from [ZL].[RrhhPuestosHistoricos] as PuH where puh.Empleado = @Usuario and  getdate() between PuH.finicio and PuH.ffin)
		Set @MandoMedio = (
							Select top 1 
								[Mandos medios] 
							from [ZL].[ZL].[Vista_RRHH_Puestos_MandosMedios] as v
							join [ZL].[RrhhPuestosHistoricos] as PuH on puh.puesto = v.puesto
							where puh.Empleado = @Usuario and  getdate() between PuH.finicio and PuH.ffin)
		Set @NivelJerárquico = (
							Select top 1 
								[Nivel jerárquico] 
							from [ZL].[ZL].[Vista_RRHH_Puestos_NivelesJerarquicos] as pnj
							join [ZL].[RrhhPuestosHistoricos] as PuH on puh.puesto = pnj.puesto
							where puh.Empleado = @Usuario and  getdate() between PuH.finicio and PuH.ffin
							order by [Nivel jerárquico] desc )
			
		

		Set @SoloIncumplimientos =(case when @Sector not in ('DIR','RRHH') then 'Si' else '' end)
		Set @TodosLosLegajos= (Case When @Area in ('DIR','RRHH') and @Sector in ('DIR','RRHH') then 'Si' end)

		--Select
		--	@fechai as fechai
		--	,@fechaf as fechaf
		--	,@Usuario as Usuario
		--	,@MandoMedio as MandoMedio
		--	,@Area as Area
		--	,@Sector as Sector
		--	,@SoloIncumplimientos as SoloIncumplimientos
		--	,@TodosLosLegajos as TodosLosLegajos
		--	,@NivelJerárquico as  NivelJerárquico
			

		if  @TodosLosLegajos = 'Si'
			SELECT * FROM [ZL].[Objetivos].[func_RRHH_GestionDeHorarios] (@FechaI,@FechaF)
			order by
			[Fecha] desc
			, [Tipo Incumplimiento]
			, [Sector]
			, [Apellido y Nombre]

		else
			if	@MandoMedio = 'Si' and @Area <> 'SAL' or @NivelJerárquico = 1
				SELECT * FROM [ZL].[Objetivos].[func_RRHH_GestionDeHorarios] (@FechaI,@FechaF)
				where area = @Area and incumplimiento = 'Si'
				order by
				[Fecha] desc
				, [Tipo Incumplimiento]
				, [Sector]
				, [Apellido y Nombre]
			else
				if  @MandoMedio = 'Si' and @Area = 'SAL'
					SELECT * FROM [ZL].[Objetivos].[func_RRHH_GestionDeHorarios] (@FechaI,@FechaF)
					where sector = @Sector and incumplimiento = 'Si'
					order by
					[Fecha] desc
					, [Tipo Incumplimiento]
					, [Sector]
					, [Apellido y Nombre]
				else
					SELECT * FROM [ZL].[Objetivos].[func_RRHH_GestionDeHorarios] (@FechaI,@FechaF)
					where empleado = @Usuario and incumplimiento = 'Si'	and ([Incumplimiento Justificado] is null or [Incumplimiento Justificado] = 'No')			
					order by
					[Fecha] desc
					, [Tipo Incumplimiento]
					, [Sector]
					, [Apellido y Nombre]
END


GO


