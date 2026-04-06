Use [ZL]
go 

IF  NOT EXISTS (
 SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[TieneModuloHost]') AND type in (N'FN'))
  begin  
    exec('Create function [ZL].[TieneModuloHost] ( @Articulo varchar(13) ) returns bit begin declare @TieneHost bit set @TieneHost = 0 return @TieneHost end')
  end  
go

/****** Object:  UserDefinedFunction [ZL].[TieneModuloHost]     Script Date: 06/11/2009 12:41:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:	Equipo Verde
-- Create date: 14-10-2009
-- Description:	Devuelve si el articulo tiene un módulo host
-- =============================================
ALTER FUNCTION [ZL].[TieneModuloHost] 
(
	@Articulo varchar( 13)
)
RETURNS bit
AS
BEGIN

	DECLARE  @TieneHost bit
	
	if exists( select * from ZL.Dmodart where Ccod =  [ZL].[ObtenerCodigoModuloHost]() and Codigo = @Articulo )
		set @TieneHost = 1
	else 
		set @TieneHost = 0
	
	RETURN @TieneHost

END
