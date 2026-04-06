Use [ZL]
go 

IF  NOT EXISTS (
 SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[TieneModuloNike]') AND type in (N'FN'))
  begin  
    exec('Create function [ZL].[TieneModuloNike] ( @Articulo varchar(13) ) returns bit begin declare @TieneModulo bit set @TieneModulo = 0 return @TieneModulo end')
  end  
go

/****** Object:  UserDefinedFunction [ZL].[TieneModuloNike]     Script Date: 06/11/2009 12:41:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:	Equipo Verde
-- Create date: 14-10-2009
-- Description:	Devuelve si el articulo tiene un módulo Nike
-- =============================================
ALTER FUNCTION [ZL].[TieneModuloNike]
(
	@Articulo varchar( 13)
)
RETURNS bit
AS
BEGIN

	DECLARE  @TieneModulo bit
	
	if exists( select * from ZL.Dmodart where Ccod =  [ZL].[ObtenerCodigoModuloNike]() and Codigo = @Articulo )
		set @TieneModulo = 1
	else 
		set @TieneModulo = 0
	
	RETURN @TieneModulo

END
