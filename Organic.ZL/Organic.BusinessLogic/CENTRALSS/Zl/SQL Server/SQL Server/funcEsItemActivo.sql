Use [ZL]
go 

IF  NOT EXISTS (
 SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[func-EsItemActivo]') AND type in (N'FN'))
  begin  
    exec('Create function [ZL].[func-EsItemActivo] ( @NroItem numeric(13,0) = 0, @Fecha datetime = getdate ) returns bit begin declare @lRetorno bit set @lRetorno = 0 return @lRetorno end')
  end  
go

/****** Object:  UserDefinedFunction [ZL].[func-EsItemActivo]   Script Date: 06/11/2009 12:41:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/************************************************************************************************/
/* Es un Item Activo */
/************************************************************************************************/			
ALTER function [ZL].[func-EsItemActivo]
	( @NroItem numeric(13,0) = 0, 
	  @Fecha datetime = getdate )
returns bit

	begin
		declare @lRetorno bit

		If exists( Select *
				  from ZL.ItemServ
				  where ccod = @NroItem
				  and ( Funciones.dtos( Febavig ) <= Funciones.dtos( @Fecha )
						or Funciones.dtos( Febavig ) = '19000101' )-- Fecha de Baja de Vigencia menor o igual a la Fecha del Codigo
				  and Funciones.dtos( Cmpfecalt ) <> '19000101' -- Fecha de Activacion NO NULA
				  and Funciones.dtos( Cmpfecdes ) = '19000101 ' ) -- Fecha de Desactivacion NULA
			set @lRetorno = 1
		else
			set @lRetorno = 0

	return @lRetorno

end	

GO


