Use [ZL]
go 

IF  NOT EXISTS (
 SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[TieneOtroModuloeHostActivo]') AND type in (N'FN'))
  begin  
    exec('Create function [ZL].[TieneOtroModuloeHostActivo] ( @Serie varchar(13) ) returns bit begin declare @TieneHost bit set @TieneHost = 0 return @TieneHost end')
  end  
go

/****** Object:  UserDefinedFunction [ZL].[TieneOtroModuloeHostActivo]    Script Date: 11/05/2009 11:00:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Equipo Verde
-- Create date: 03-09-2009
-- Description:	Devuelve si el articulo tiene un módulo host
-- =============================================
ALTER FUNCTION [ZL].[TieneOtroModuloeHostActivo] 
(
	@Serie varchar( 13)
)
RETURNS bit
AS
BEGIN

	DECLARE  @TieneHost bit
	
	if exists( select * from ZL.Ismodulo where Tipomodu = '2' and Ccod in (select dm.ccod from ZL.Dmodart dm 
            left join ZL.Itemserv it on it.codart = dm.codigo 
            where it.nroserie = @Serie and ( ZL.[func-EsItemActivoSINActDesact]( it.ccod , getdate()) = 1)
            group by dm.ccod))
		set @TieneHost = 1
	else 
		set @TieneHost = 0
	
	RETURN @TieneHost

END
