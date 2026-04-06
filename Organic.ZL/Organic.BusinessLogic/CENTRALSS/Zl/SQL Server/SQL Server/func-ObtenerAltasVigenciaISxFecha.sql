Use [ZL]
go 

IF  NOT EXISTS (
 SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[ObtenerAltasVigenciaISxFecha]') AND type in (N'IF'))
  begin  
    exec('create function [ZL].[ObtenerAltasVigenciaISxFecha] (@fecha datetime) returns table as RETURN ( select 1 as col1 )
 ')
  end   
  
GO
USE [ZL]
GO
/****** Object:  UserDefinedFunction [ZL].[ObtenerAltasVigenciaISxFecha]    Script Date: 11/11/2009 11:04:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION [ZL].[ObtenerAltasVigenciaISxFecha]
	( @tdFecha datetime )

RETURNS table
AS

return(	
		select nroserie as serie,
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
			  ( ZL.TieneModuloMemo( Codart ) )               as Memo,
			  ( ZL.TieneModuloCheckLine( Codart ) )          as CheckL,
			  ( ZL.EsSerieActivo (nroserie ) )               as SerieAct			  
		  from ZL.Itemserv 
		where
		   fealvig between Funciones.dtos(@tdFecha-2) and Funciones.dtos(@tdFecha)		   
)