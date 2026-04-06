USE [ZL]
GO

IF  NOT EXISTS (
 SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[funcExistenciaSerieGrupo]') AND type in (N'FN'))
  begin  
    exec('Create function [ZL].[funcExistenciaSerieGrupo] ( @cSerie char(6) = 0, @cGrupo numeric(6,0) ) returns bit begin declare @lRetorno bit set @lRetorno = 0 return @lRetorno end')
  end  
go

/****** Object:  UserDefinedFunction [ZL].[funcExistenciaSerieGrupo]    Script Date: 10/08/2009 12:11:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER function [ZL].[funcExistenciaSerieGrupo] ( @cSerie varchar(6), @cGrupo numeric(6,0))
returns bit
begin
	declare @lRetorno bit

	if exists( select 1 codigo
				from zl.seriegrupo
				where Nroserie = @cSerie and Grupo = @cGrupo and fechabaja = '1900-01-01' )
		set @lRetorno = 1
	else
		set @lRetorno = 0

	return @lRetorno
end
