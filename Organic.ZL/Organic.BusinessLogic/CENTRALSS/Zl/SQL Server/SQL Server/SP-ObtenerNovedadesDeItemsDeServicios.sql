Use [ZL]
go 

IF  NOT EXISTS (
 SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[ObtenerNovedadesDeItemsDeServicios]') AND type in (N'P', N'PC'))
  begin  
    exec('create proc [ZL].[ObtenerNovedadesDeItemsDeServicios] as ')
  end   

/****** Object:  StoredProcedure [ZL].[ObtenerNovedadesDeItemsDeServicios]    Script Date: 11/11/2009 10:50:31 ******/


USE [ZL]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [ZL].[ObtenerNovedadesDeItemsDeServicios] 
AS
BEGIN
	select * from
			ZL.ObtenerBajasVigenciaISxFecha( getdate())
	union	
		select * from
			ZL.ObtenerAltasVigenciaISxFecha( GETDATE())
	order by serie, falta
END
