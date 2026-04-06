USE [ZL]
GO

IF  NOT EXISTS (
 SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[sp-DesactivarISxSerie]') AND type in (N'P', N'PC'))
  begin  
    exec('create proc [ZL].[sp-DesactivarISxSerie] as ')
  end   

/****** Object:  StoredProcedure [ZL].[sp-DesactivarISxSerie]    Script Date: 09/02/2009 10:18:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [ZL].[sp-DesactivarISxSerie]
	( @NroSerie varchar(6) = '', @FechaCodigo datetime = getdate )
AS

	Update Zl.Itemserv
	set cmpFecDes = @FechaCodigo 	-- Fecha de Activacion
	where  [ZL].[func-EsItemActivo](ccod, @FechaCodigo ) = 1
	and Funciones.dtos( Febavig ) <> '19000101'
	and Nroserie = @NroSerie
	and codart not like '%-TI'	

go 

