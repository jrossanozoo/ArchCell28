USE [ZL]
GO
/****** Object:  StoredProcedure [ZL].[SP-ModulosBinariosV2]    Script Date: 12/16/2009 09:28:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[SP-ModulosBinariosV2]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [ZL].[SP-ModulosBinariosV2]
GO

CREATE PROCEDURE [ZL].[SP-ModulosBinariosV2] 
( @serie varchar(7) ,
  @producto varchar(2),
  @build varchar(5)  )
with encryption
as
declare @row char(6), @resultado varchar(4), @retorno varchar(19), @posicion varchar(4), @PkAsignacionDePosicionesDeModulos varchar(15),
	  @productoEnZl varchar(4)

DECLARE @ModulosActivos TABLE ( posicion varchar(4) )

set @productoEnZl = [ZL].[Funciones].[padl](@producto, 4, '0')
set @retorno = ''
set @row = 1

/** Se detecta la versión menor inmediata al build pasado por parámetro ( si pasa 1751 y tenemos cargados builds 1600, 1750 y 1800, nos devuelve 1750 ) **/						
set @PkAsignacionDePosicionesDeModulos = ( select top 1 zlCodigoModulo.cCod from zl.codmod zlCodigoModulo
							inner join zl.VerPZL VersionesZl on zlCodigoModulo.cvCod = VersionesZl.cCod
							where [ZL].[Funciones].[padl](rtrim( ltrim( VersionesZl.cbuild ) ) ,5,'0') <= @build 
								and zlCodigoModulo.cpcod = @productoEnZl 
							order by [ZL].[Funciones].[padl](rtrim( ltrim( VersionesZl.cbuild ) ) ,5,'0') desc )
                            
if @PkAsignacionDePosicionesDeModulos is null
	begin
		RAISERROR (70002, 16,1)
	end
	
insert into @ModulosActivos
	select DetalleModulos.vmcreto posicion  from ZL.dcodmod DetalleModulos
		  cross apply [ZL].funcModulosRetornablesxSerie ( @serie ) ModulosActivosDelSerie
		  where DetalleModulos.codigo = @PkAsignacionDePosicionesDeModulos and 
			DetalleModulos.modulo = ModulosActivosDelSerie.modulocod
		  
while @row < 20
	Begin
		set @posicion  = ( select posicion from @ModulosActivos where posicion = @row )
		      
			  if  @posicion is null 
			  begin
					set @retorno = @retorno + '0'
			  end
			  else
			  begin
					set @retorno = @retorno + '1'
			  end   
			  set @row = @row + 1
end
select @retorno