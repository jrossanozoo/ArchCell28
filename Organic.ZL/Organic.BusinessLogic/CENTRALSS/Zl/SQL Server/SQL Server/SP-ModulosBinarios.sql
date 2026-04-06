USE [ZL]
GO
/****** Object:  StoredProcedure [ZL].[SP-ModulosBinarios]    Script Date: 12/16/2009 09:28:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[SP-ModulosBinarios]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [ZL].[SP-ModulosBinarios]
GO

CREATE PROCEDURE [ZL].[SP-ModulosBinarios] 
( @serie varchar(7) ,
  @version varchar(4),
  @producto varchar(2) )
with encryption
as
declare @row char(6), @resultado varchar(4), @retorno varchar(19), @posicion varchar(4), @versionvigente varchar(4), @productoEnZl varchar(4)

DECLARE @moduloactivo TABLE (
posicion varchar(4), 
modulo varchar(4) )

if @version = '0.00'
	set @version = '6.72'

set @productoEnZl = '00' + [ZL].[Funciones].[padl](@producto, 2, '0')
set @retorno = ''
set @row = 1
set @versionvigente = ( select top 1 left(cvcod,4) as cvcod from zl.codmod 
                             where left( cvcod,4 ) <= @version order by cvcod desc )

if @versionvigente is null
	begin
		RAISERROR (70002, 16,1)
	end
	
insert into @moduloactivo
select vmcreto, cs.modulocod  from ZL.codmod cod 
                  inner join ZL.dcodmod dco on cod.ccod = dco.codigo
                  cross apply ZL.funcModulosRetornablesxSerie ( @serie ) cs
                  where left( cod.cvcod,4 ) = @versionvigente and 
					modulo = cs.modulocod and 
					cod.cpcod = @productoEnZl
                  order by vmcreto

while @row < 20
Begin

set @posicion  = ( select posicion from @moduloactivo where posicion = @row )
      
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
