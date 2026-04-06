Use [ZL]
go 

IF  NOT EXISTS (
 SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[ValidarUsuario]') AND type in (N'FN'))
  begin  
    exec('Create function [ZL].[ValidarUsuario] ( @Articulo varchar(13) ) returns bit begin declare @TieneModulo bit set @TieneModulo = 0 return @TieneModulo end')
  end  
go

/****** Object:  UserDefinedFunction [ZL].[TieneModuloCompras]     Script Date: 19/11/2009 12:41:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:	Validar Usuario Web
-- Create date: 19-11-2009
-- Description:	Devuelve si el usuario es valido o no.
-- =============================================
ALTER FUNCTION [ZL].[ValidarUsuario]
(
	@Usuario varchar( 13 ),
	@Serie varchar( 6 )
)
RETURNS bit
AS
BEGIN

	DECLARE  @lRetorno bit
	set @lRetorno = 1
	
	RETURN @lRetorno
END
