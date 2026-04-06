USE [ZL]
GO

IF  NOT EXISTS (
 SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[SP-DesactivaGrupoComunicacionesxSerie]') AND type in (N'P', N'PC'))
  begin  
    exec('create proc [ZL].[SP-DesactivaGrupoComunicacionesxSerie] as ')
  end   
  
/****** Object:  StoredProcedure [ZL].[SP-DesactivaGrupoComunicacionesxSerie]    Script Date: 10/15/2009 11:47:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:	Equipo Verde
-- Create date: 15-10-2009
-- Description:	Cuando se realiza una baja de IS y el Serie tiene Host, se actualiza la fecha de vigencia
--				de los Grupos de Comunicación donde participa el serie ( Entidad ZLSeries )
-- =============================================
ALTER PROCEDURE [ZL].[SP-DesactivaGrupoComunicacionesxSerie]
	( @NroSerie varchar(6) = '', @FechaBaja varchar(12) = '' )
AS
declare @fecha datetime, @tmp varchar(2)

	set @tmp = substring( @FechaBaja, 1, 2 )

	if @tmp = '01'
		BEGIN
			set @FechaBaja = '20' + substring( @FechaBaja, 3, LEN(@FechaBaja)-2 )
		END
		
	set @fecha = CONVERT( datetime, @FechaBaja)
		
	update ZL.Seriegrupo
	set Fechabaja = @Fecha
	where Nroserie = @NroSerie
GO


