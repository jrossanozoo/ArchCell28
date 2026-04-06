Use [ZL]
go 

IF  NOT EXISTS ( 
      SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[funcValidarArticuloCentralizador]') AND type in (N'FN'))
  begin  
    exec('create function [ZL].[funcValidarArticuloCentralizador] (@Articulo varchar(13), @SerieOrigen varchar(6)) returns char(10) begin declare @Retorno char(10) return @Retorno end')
  end   
GO

USE [ZL]
GO
/****** Object:  UserDefinedFunction [ZL].[funcValidarArticuloCentralizador]    Script Date: 11/02/2009 17:24:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================
-- Author:  Equipo Verde
-- Create date: 11-12-2009
-- Description:   Valida si el artículo es centralizador y cuantas conexiones tiene
-- =============================================================================
ALTER function [ZL].[funcValidarArticuloCentralizador]
      ( @Articulo varchar(13), @SerieOrigen varchar(6) )

returns char(10)
as
begin

	declare @TieneModuloCentralizador bit, @Conexiones integer, @CantSeries integer, @Retorno varchar(10)
	set @Retorno = ''

	select @TieneModuloCentralizador = [ZL].[TieneModuloCentralizador]( @Articulo )
	select @Conexiones = conexiones from ZL.Isarticu where Ccod = @Articulo

	if @TieneModuloCentralizador = 1 and @Conexiones > 0
		begin
			select @CantSeries = count( serie ) from ZL.funcConexionesCentraxSerie( @SerieOrigen ) where centra = 0
			if ZL.funcSerieCentralizador( @SerieOrigen ) = 0
				begin
					set @CantSeries = @CantSeries - 1
				end
			set @Retorno = cast( @Conexiones as char(4) ) + '-' + cast( @CantSeries as char(4) )
		end

	return @Retorno
end
