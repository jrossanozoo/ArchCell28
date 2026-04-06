USE [ZL]
GO

IF  NOT EXISTS (
 SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[sp-ActivarISxSerie]') AND type in (N'P', N'PC'))
  begin  
    exec('create proc [ZL].[sp-ActivarISxSerie] as ')
  end   

/****** Object:  StoredProcedure [ZL].[sp-ActivarISxSerie]    Script Date: 09/02/2009 10:15:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [ZL].[sp-ActivarISxSerie]
	( @NroSerie varchar(6) = '', @FechaCodigo datetime = getdate )
AS

	If convert(integer, @NroSerie ) between 300000 and 309999
		Update Zl.RelacionTiIS
		set fechaact = @FechaCodigo 	-- Fecha de Activacion
		where Funciones.dtos( fechaact ) = '19000101'
		and Nroserie = @NroSerie
	else
		Update Zl.Itemserv
		set cmpFecAlt = @FechaCodigo 	-- Fecha de Activacion
		where [ZL].[func-EsItemInactivo](ccod, @FechaCodigo ) = 1
		and Nroserie = @NroSerie
go