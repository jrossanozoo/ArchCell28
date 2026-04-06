USE [ZL]
GO
/****** Object:  UserDefinedFunction [ZL].[func-EsItemActivoSINActDesact]    Script Date: 11/02/2009 10:22:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/************************************************************************************************/
/* Es un Item Activo */
/************************************************************************************************/                  
ALTER function [ZL].[func-EsItemActivoSINActDesact]
      ( @NroItem numeric(13,0) = 0, 
        @Fecha datetime = getdate )
returns bit

      begin
            declare @lRetorno bit

            If exists( Select *
                       from ZL.ItemServ
                       where ccod = @NroItem and
                          Funciones.dtos( FeAlVig ) <= Funciones.dtos( @Fecha ) and
                          ( Funciones.dtos( Febavig ) = '19000101' or
                           Funciones.dtos( Febavig ) > Funciones.dtos(( @Fecha ))))
                  set @lRetorno = 1
            else
                  set @lRetorno = 0

      return @lRetorno

end   
--and Funciones.dtos( Cmpfecdes ) <> '19000101 '  -- Fecha de Desactivacion NULA
  --                        or  Funciones.dtos( Febavig )  <= getdate())