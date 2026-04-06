USE [ZL]
GO
/****** Object:  StoredProcedure [ZooUpdate].[SP-ObtenerActualizacionesParaProductos]   ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZooUpdate].[SP-ObtenerActualizacionesParaProductos]') AND type in (N'P', N'PC'))
            DROP PROCEDURE [ZooUpdate].[SP-ObtenerActualizacionesParaProductos]
GO

CREATE PROCEDURE [ZooUpdate].[SP-ObtenerActualizacionesParaProductos] 
( @serie varchar(7) ,
  @buildp varchar(5),
  @producto varchar(4) )
with encryption
as
declare @BuildLibreDistibucion char(5) , @BuildEspecifico char(5) , @BuildResultante char(5) ;

/******************************************************************************************************/
/******************* Registrar la versión actual del serie ****************************/
/******************************************************************************************************/

exec [ZooUpdate].[SP-RegistrarBuildPorSerie] @serie, @buildp, @producto, 1

/******************************************************************************************************/
/******************* Detección de versión especifica para un cliente/serie ****************************/
/******************************************************************************************************/
set @BuildEspecifico = (
	select top(1) Versiones.cbuild as Build
	from zl.LIBERAVER Liberacion
		inner join Zl.VERPZL Versiones on Versiones.Ccod = Liberacion.CVERSION and Versiones.cbuild > @buildp
		left join Zl.PRODZL ProductosZl on ProductosZl.Ccod = Liberacion.Cpcod
		left join Zl.DETCLIVER ClientesIncluidos on Liberacion.Ccod = ClientesIncluidos.liberacion
		left join Zl.DETSERVER SeriesIncluidos on Liberacion.Ccod  = SeriesIncluidos.liberacion
	where 
	( ( Select top(1) estado from Zl.AsigEstVer where Zl.AsigEstVer.liberacion = Liberacion.Ccod order by Codin desc )= 1 ) and   
		rtrim( Liberacion.URLDESC ) <> '' and
		Liberacion.Cpcod = @producto 	  and 
			( SeriesIncluidos.Nroserie = @serie OR 
			  ClientesIncluidos.Ccodcli in ( 
										select distinct rz.cliente
											from zl.itemserv item
											inner join zl.series ser on ser.nroserie = item.nroserie
											inner join ZL.Razonsocial RZ on  RZ.Cmpcod = item.Crass
											inner join ( select nrz from [ZL].[AdmEstadoRS] () where [Dar código] = 1 ) RZA on  RZA.nrz = RZ.Cmpcod											
											where Item.Cmpfecalt <= GETDATE() AND item.Ccod IN ( SELECT Ccod  FROM ZL.Itemserv WHERE Nroserie = @serie and ccod in( select ccod from ZL.funcItemsVigentes() ) )
											
											)
			)
	order by Build desc 
	)

/******************************************************************************************************/
/**************** Detección de versión Libre distribución restando los Excluidos **********************/
/******************************************************************************************************/
set @BuildLibreDistibucion = (                 
	select top(1) Versiones.cbuild as Build
	from zl.LIBERAVER Liberacion
		inner join Zl.VERPZL Versiones on Versiones.Ccod = Liberacion.CVERSION and Versiones.cbuild > @buildp
		left join Zl.PRODZL ProductosZl on ProductosZl.Ccod = Liberacion.Cpcod
		left join Zl.DETCLIVEREXCL ClientesExcluidos on Liberacion.Ccod = ClientesExcluidos.Cmpcodigo
		left join Zl.DETSERVEREXCL SeriesExcluidos on Liberacion.Ccod  = SeriesExcluidos.Cmpcodigo
	where 
		( ( Select top(1) estado from Zl.AsigEstVer where Zl.AsigEstVer.liberacion = Liberacion.Ccod order by Codin desc )= 2  ) and  
		rtrim( Liberacion.URLDESC ) <> '' and 
		Liberacion.Cpcod = @producto	  and  not
		( 
			@serie in ( select rtrim( Nroserie ) from  Zl.DETSERVEREXCL where cmpcodigo = Liberacion.Ccod ) OR 
			(	( select distinct rz.cliente from zl.itemserv item
									inner join zl.series ser on ser.nroserie = item.nroserie
									inner join ZL.Razonsocial RZ on  RZ.Cmpcod = item.Crass
									inner join ( select nrz from [ZL].[AdmEstadoRS] () where [Dar código] = 1 ) RZA on  RZA.nrz = RZ.Cmpcod
									where Item.Cmpfecalt <= GETDATE() AND item.Ccod IN ( SELECT Ccod  FROM ZL.Itemserv WHERE Nroserie = @serie and ccod in(  select ccod from ZL.funcItemsVigentes() ) )
				 ) in 
				 ( select rtrim( CcodCli ) from Zl.DETCLIVEREXCL where liberacion = Liberacion.Ccod )
			)
		) 
	order by Build desc 
	)

/******************************************************************************************************/
/******************** Definición de la versión que se va a actualizar *********************************/
/******************************************************************************************************/
if  isnull(@BuildEspecifico,'00000') > isnull(@BuildLibreDistibucion, '00000')
      begin
            set @BuildResultante = @BuildEspecifico
      end
else
      begin
            set @BuildResultante = @BuildLibreDistibucion
      end   


/******************************************************************************************************/
/********************************** Armado del XMl de devolución **************************************/
/******************************************************************************************************/      
select rtrim( Versiones.cbuild ) as Build, rtrim( l.CVERSION ) as version, rtrim( l.Cpcod ) as producto, RTRIM( l.URLDESC ) as url 
	from zl.LIBERAVER l
    inner join Zl.VERPZL Versiones on Versiones.Ccod = l.CVERSION and Versiones.cbuild = @BuildResultante
	left join Zl.PRODZL ProductosZl on ProductosZl.Ccod = l.Cpcod 
	where  RTRIM( l.URLDESC ) <> '' and l.Cpcod = @producto
	order by Build desc for xml auto, elements
