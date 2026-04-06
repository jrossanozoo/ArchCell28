USE [ZL]
GO
/****** Object:  StoredProcedure [ZooUpdate].[SP-RegistrarBuildPorSerie]   ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZooUpdate].[SP-RegistrarBuildPorSerie]') AND type in (N'P', N'PC'))
            DROP PROCEDURE [ZooUpdate].[SP-RegistrarBuildPorSerie]
GO

CREATE PROCEDURE [ZooUpdate].[SP-RegistrarBuildPorSerie] 
( @serie varchar(7) ,
  @buildp varchar(5),
  @producto varchar(4),
  @origen int )
with encryption
as

/******************************************************************************************************/
/******************* Registrar la versión actual del serie ****************************/
/******************************************************************************************************/

DECLARE @FechaActual varchar(8)

set @FechaActual = CONVERT(varchar(8), GETDATE(), 112)

if EXISTS( select serie from [ZooUpdate].[BuildPorSerie] tabla 
			where @FechaActual = tabla.Fecha and tabla.Serie = @serie )
	begin
	update [ZooUpdate].[BuildPorSerie]  
		set Build = @buildp, Producto = @producto, Origen = @origen
		where Fecha = @FechaActual and Serie = @serie
	end
else
	begin
		insert into [ZooUpdate].[BuildPorSerie] (Serie, Producto, Build, Fecha, Origen ) values ( @serie, @producto, @buildp, @FechaActual, @origen )
	end