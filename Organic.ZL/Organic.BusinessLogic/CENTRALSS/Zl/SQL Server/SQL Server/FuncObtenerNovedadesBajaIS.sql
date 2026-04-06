Use [ZL]
go 

IF  NOT EXISTS (
 SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[ObtenerNovedadBajaIS]') AND type in (N'IF'))
  begin  
    exec('create function [ZL].[ObtenerNovedadBajaIS] (@ISBaja integer) returns table as RETURN ( select 1 as col1 )
 ')
  end   
GO
----------------------------------------------------------------------------------------
USE [ZL]
GO
/****** Object:  UserDefinedFunction [ZL].[ObtenerNovedadBajaIS]    Script Date: 11/05/2009 12:59:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================
-- Author:	Equipo Verde
-- Create date: 23-10-2009
-- Description:	Se le pasa nro de lote de baja de servicio y devuelve los series
-- que tenga ese IS con sus respectivos articulos y si esta activo o no
-- Esta funcion se usa en la migracion ONLINE
-- =============================================================================
ALTER FUNCTION [ZL].[ObtenerNovedadBajaIS]
	( @ISbaja integer )

RETURNS table
AS

return(	

select RelaLoteb as nroalta,                               
      nroserie as serie,
      crass as scod , 
      fealvig as shastafecha, 
      codart,
      fealvig as falta,
      febavig as fbaja,
      cmpfecalt,
      cmpfecdes,
      contadm as va,
      'BAJA' as origen,
      ccod,
      case when ( charindex([ZL].[ObtenerCodigoModuloMinorista](), (select zl.ObtenerModulosConcatenadosBajaISxSerie( nroserie )) ) > 0 ) then 'False' else (ZL.TieneModuloMinorista( Codart )) end as minoris,
      case when ( charindex([ZL].[ObtenerCodigoModuloBarras](), (select zl.ObtenerModulosConcatenadosBajaISxSerie( nroserie )) ) > 0 ) then 'False' else ( ZL.TieneModuloBarras( Codart ) ) end as lBarra,  
      case when ( charindex([ZL].[ObtenerCodigoModuloTarjetas](), (select zl.ObtenerModulosConcatenadosBajaISxSerie( nroserie )) ) > 0 ) then 'False' else ( ZL.TieneModuloTarjetas( Codart ) ) end  as tarjeta, 
      case when ( charindex([ZL].[ObtenerCodigoModuloticketfactura](), (select zl.ObtenerModulosConcatenadosBajaISxSerie( nroserie )) ) > 0 ) then 'False' else ( ZL.TieneModuloTicketFactura( Codart ) )  end as tfac,
      case when ( charindex([ZL].[ObtenerCodigoModuloMayorista](), (select zl.ObtenerModulosConcatenadosBajaISxSerie( nroserie )) ) > 0 ) then 'False' else ( ZL.TieneModuloMayorista( Codart ) ) end as moyori,
      case when ( charindex([ZL].[ObtenerCodigoModuloNike](), (select zl.ObtenerModulosConcatenadosBajaISxSerie( nroserie )) ) > 0 ) then 'False' else ( ZL.TieneModuloNike( Codart ) ) end as nike,
      case when ( charindex([ZL].[ObtenerCodigoModuloDoblepantalla](), (select zl.ObtenerModulosConcatenadosBajaISxSerie( nroserie )) ) > 0 ) then 'False' else ( ZL.TieneModuloDoblePantalla( Codart ) ) end  as dpant,
      case when ( charindex([ZL].[ObtenerCodigoModuloRed](), (select zl.ObtenerModulosConcatenadosBajaISxSerie( nroserie )) ) > 0 ) then 'False' else ( ZL.TieneModuloRed( Codart ) ) end as red,
      case when ( charindex([ZL].[ObtenerCodigoModuloContabilidad](), (select zl.ObtenerModulosConcatenadosBajaISxSerie( nroserie )) ) > 0 ) then 'False' else ( ZL.TieneModuloContabilidad( Codart ) ) end as contab,
      case when ( charindex([ZL].[ObtenerCodigoModulogestiontrabajo](), (select zl.ObtenerModulosConcatenadosBajaISxSerie( nroserie )) ) > 0 ) then 'False' else ( ZL.TieneModuloGestionTrabajo( Codart ) ) end as trabaj,
      case when ( charindex([ZL].[ObtenerCodigoModuloProduccion](), (select zl.ObtenerModulosConcatenadosBajaISxSerie( nroserie )) ) > 0 ) then 'False' else ( ZL.TieneModuloProduccion( Codart ) ) end as porduc,
      case when ( charindex([ZL].[ObtenerCodigoModuloCompras](), (select zl.ObtenerModulosConcatenadosBajaISxSerie( nroserie )) ) > 0 ) then 'False' else ( ZL.TieneModuloCompras( Codart ) ) end as compra,
      case when ( charindex([ZL].[ObtenerCodigoModuloCubos](), (select zl.ObtenerModulosConcatenadosBajaISxSerie( nroserie )) ) > 0 ) then 'False' else ( ZL.TieneModuloCubos( Codart ) ) end as fondos,
      case when ( charindex([ZL].[ObtenerCodigoModuloHost](), (select zl.ObtenerModulosConcatenadosBajaISxSerie( nroserie )) ) > 0 ) then 'False' else ( ZL.TieneModuloHost( Codart ) ) end as host1,
	  case when ( [ZL].[TieneOtroModuloeHostActivo]( nroserie ) > 0 ) then 'False' else ( ZL.TieneModuloeHost( Codart ) ) end as elince,
	  case when ( [ZL].[TieneOtroModuloCentralizadorActivo]( nroserie ) > 0 ) then 'False' else ( ZL.TieneModuloCentralizador( Codart ) ) end as centra,
      case when ( charindex([ZL].[ObtenerCodigoModuloPromosYKits](), (select zl.ObtenerModulosConcatenadosBajaISxSerie( nroserie )) ) > 0 ) then 'False' else ( ZL.TieneModuloPromosYKits( Codart ) ) end as comext,
      case when ( charindex([ZL].[ObtenerCodigoModuloProgramadorDeTareas](), (select zl.ObtenerModulosConcatenadosBajaISxSerie( nroserie )) ) > 0 ) then 'False' else ( ZL.TieneModuloProgramadorDeTareas( Codart ) )  end as attel,
      case when ( charindex([ZL].[ObtenerCodigoModuloLaPos](), (select zl.ObtenerModulosConcatenadosBajaISxSerie( nroserie )) ) > 0 ) then 'False' else ( ZL.TieneModuloLaPos( Codart ) ) end as fidel,
	  case when ( charindex([ZL].[ObtenerCodigoModuloMemo](), (select zl.ObtenerModulosConcatenadosBajaISxSerie( nroserie )) ) > 0 ) then 'False' else ( ZL.TieneModuloMemo( Codart ) ) end as memo,
	  case when ( charindex([ZL].[ObtenerCodigoModuloCheckline](), (select zl.ObtenerModulosConcatenadosBajaISxSerie( nroserie )) ) > 0 ) then 'False' else ( ZL.TieneModuloCheckLine( Codart ) ) end as CheckL,
      ( ZL.EsSerieActivo (nroserie ) ) as SerieAct
from ZL.Itemserv 
where
      RelaLoteb = @ISbaja

)

