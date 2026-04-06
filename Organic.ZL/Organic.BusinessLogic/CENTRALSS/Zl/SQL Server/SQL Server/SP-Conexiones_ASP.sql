Use [ZL]
go 

IF  NOT EXISTS (
 SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[Conexiones_ASP]') AND type in (N'P', N'PC'))
  begin  
    exec('create proc [ZL].[Conexiones_ASP] as ')
  end   

/****** Object:  StoredProcedure [ZL].[Conexiones_ASP]    Script Date: 06/11/2009 12:32:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [ZL].[Conexiones_ASP] (@SerieOrigen varchar(6))
with execute as 'dbo'
AS
SET NOCOUNT ON
BEGIN
	select cast( dbo.moduloactivo( @serieorigen, '0015') as char(1))  serie
	union all
	select cast( dbo.moduloactivo( @serieorigen, '0014') as char(1)) serie
	union all
	select serie from ZL.funcConexionesxSerie( @serieorigen )
END
