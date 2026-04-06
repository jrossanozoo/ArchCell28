Use [ZL]
go 

IF  NOT EXISTS (
 SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[func-EsItemInactivo]') AND type in (N'FN'))
  begin  
    exec('Create function [ZL].[func-EsItemInactivo] ( @NroItem numeric(13,0) = 0, @Fecha datetime = getdate ) returns bit begin declare @lRetorno bit set @lRetorno = 0 return @lRetorno end')
  end  
go

/****** Object:  UserDefinedFunction [ZL].[func-EsItemInactivo]     Script Date: 06/11/2009 12:41:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/************************************************************************************************/
/* Es un Item Inactivo */
/************************************************************************************************/			
ALTER function [ZL].[func-EsItemInactivo]
	( @NroItem numeric(13,0) = 0, 
	  @Fecha datetime = getdate )
returns bit

begin
	declare @lRetorno bit

	If exists( Select *
			  from ZL.ItemServ
			  where ccod = @NroItem
				and ( Funciones.dtos( Fealvig ) <= Funciones.dtos( @Fecha )
						or Funciones.dtos( Fealvig ) = '19000101' ) -- Fecha de Alta de Vigencia NULA o menor o igual a la Fecha del Codigo
				and ( Funciones.dtos( Febavig ) > Funciones.dtos( @Fecha )
					  or Funciones.dtos( Febavig ) = '19000101' ) -- Fecha Vigencia Baja  mayor a la Fecha del Codigo o NULA
			--	and Funciones.dtos( Febareg ) = '19000101' -- Fecha de Baja Registro NULA
				and Funciones.dtos( Cmpfecdes ) = '19000101' -- Fecha de Desactivacion NULA
				and Funciones.dtos( Cmpfecalt ) = '19000101' ) -- Fecha de Activacion NULA			  
		set @lRetorno = 1
	else
		set @lRetorno = 0
	
return @lRetorno
end
GO