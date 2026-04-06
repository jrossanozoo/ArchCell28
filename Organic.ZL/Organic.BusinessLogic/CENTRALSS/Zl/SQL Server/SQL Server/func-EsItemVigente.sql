Use [ZL]
go 

IF  NOT EXISTS (
 SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[func-EsItemVigente]') AND type in (N'FN'))
  begin  
    exec('Create function [ZL].[func-EsItemVigente] ( @NroItem numeric(13,0) ) returns bit begin declare @lRetorno bit set @lRetorno = 0 return @lRetorno end')
  end  
go

/****** Object:  UserDefinedFunction [ZL].[func-EsItemVigente]     Script Date: 06/11/2009 12:41:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:	Equipo Verde
-- Create date: 25-11-2009
-- Description:	Devuelve si el Item de Servicio está vigente
-- =============================================
ALTER FUNCTION [ZL].[func-EsItemVigente]
(
	@NroItem numeric(13,0)
)
RETURNS bit
AS
BEGIN
	declare @lRetorno bit

	If exists(
			Select *
			from ZL.ItemServ
			where ccod = @NroItem and (
				(Funciones.dtos( Fealvig ) <= Funciones.dtos( getdate() ) or
				Funciones.dtos( Cmpfecalt ) <> '19000101' ) and
				(Funciones.dtos( Febavig ) > Funciones.dtos( getdate() ) or
				Funciones.dtos( Febavig ) = '19000101' ) and
				(Funciones.dtos( Cmpfecdes ) > Funciones.dtos( getdate() ) or
				Funciones.dtos( Cmpfecdes ) = '19000101' ) ) )
		set @lRetorno = 1
	else
		set @lRetorno = 0
	
	RETURN @lRetorno
END
