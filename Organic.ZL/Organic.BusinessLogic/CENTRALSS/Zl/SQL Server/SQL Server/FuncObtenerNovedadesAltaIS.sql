Use [ZL]
go 

IF  NOT EXISTS (
 SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[ObtenerNovedadAltaIS]') AND type in (N'IF'))
  begin  
    exec('create function [ZL].[ObtenerNovedadAltaIS] (@ISAlta integer) returns table as RETURN ( select 1 as col1 )
 ')
  end   
GO
----------------------------------------------------------------------------------------
/****** Object:  UserDefinedFunction [ZL].[ObtenerNovedadAltaIS]    Script Date: 23/10/2009 15:40:27 ******/
USE [ZL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================
-- Author:	Equipo Verde
-- Create date: 23-10-2009
-- Description:	Se le pasa nro de lote de alta de servicio y devuelve los series
-- que tenga ese IS con sus respectivos articulos y si esta activo o no
-- Esta funcion se usa en la migracion ONLINE
-- =============================================================================
ALTER FUNCTION [ZL].[ObtenerNovedadAltaIS]
	( @ISAlta integer )

RETURNS table
AS

return(	
		select RelaLote as nroalta,                               
			   nroserie as serie,
			   crass as scod , 
			   fealvig as shastafecha, 
			   codart,
			   fealvig as falta,
			   febavig as fbaja,
			   cmpfecalt,
			   cmpfecdes,
			   contadm as va,
			   'ALTA' as origen,
			   ccod,
			  ( ZL.TieneModuloMinorista( Codart ) )          as minoris,
			  ( ZL.TieneModuloBarras( Codart ) )             as lBarra,  
			  ( ZL.TieneModuloTarjetas( Codart ) )           as tarjeta, 
			  ( ZL.TieneModuloTicketFactura( Codart ) )      as tfac,
			  ( ZL.TieneModuloMayorista( Codart ) )          as moyori,
			  ( ZL.TieneModuloNike( Codart ) )               as nike,
			  ( ZL.TieneModuloDoblePantalla( Codart ) )      as dpant,
			  ( ZL.TieneModuloRed( Codart ) )                as red,
			  ( ZL.TieneModuloContabilidad( Codart ) )		 as contab,
			  ( ZL.TieneModuloGestionTrabajo( Codart ) )     as trabaj,
			  ( ZL.TieneModuloProduccion( Codart ) )         as porduc,
			  ( ZL.TieneModuloCompras( Codart ) )            as compra,
			  ( ZL.TieneModuloCentralizador( Codart ) )      as centra,
			  ( ZL.TieneModuloCubos( Codart ) )              as fondos,
			  ( ZL.TieneModuloHost( Codart ) )               as host1,
			  ( ZL.TieneModuloeHost( Codart ) )              as elince,
			  ( ZL.TieneModuloPromosYKits( Codart ) )        as comext,
			  ( ZL.TieneModuloProgramadorDeTareas( Codart ) )as attel,
			  ( ZL.TieneModuloLaPos( Codart ) )              as fidel,
			  ( ZL.EsSerieActivo (nroserie ) )               as SerieAct
		  from ZL.Itemserv 
		where
			RelaLote = @ISAlta			   
)





