Use [ZL]
go 

IF  NOT EXISTS ( 
      SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[func-ObtenerUltimaFechaDeFacturacionDeUnItemServ]') AND type in (N'FN'))
  begin  
    exec('create function [ZL].[func-ObtenerUltimaFechaDeFacturacionDeUnItemServ] ( @NroItem numeric(13,0) ) returns datetime begin declare @Fecha datetime return @Fecha end')
  end   
GO

USE [ZL]
GO
/****** Object:  UserDefinedFunction [ZL].[func-ObtenerUltimaFechaDeFacturacionDeUnItemServ]    Script Date: 21/12/2009 17:24:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================
-- Author:  Equipo Verde
-- Create date: 21-12-2009
-- Description:  Regresa la ultima fecha de facturacion de un item de servicio.
-- =============================================================================
ALTER function [ZL].[func-ObtenerUltimaFechaDeFacturacionDeUnItemServ]( @ItemServicio numeric(13,0) )

returns datetime
	
WITH execute as 'dbo'
as
begin

	return(
			/*	SELECT max( [ffch] ) AS FECHA
		FROM [ZL].[CtasCtes].[ZOO_SA_fac]
		where fart like 'it%' and cast( right( funciones.alltrim( fart ), 7 ) as int ) = @ItemServicio
	*/--
	--obtiene la fecha de facturación de un item
	select ZL.[func-FechaFacturaciónxItem](@ItemServicio)
	)


end