Use [ZL]
go 

IF  NOT EXISTS (
 SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[TieneOtroModuloCentralizadorActivo]') AND type in (N'FN'))
  begin  
    exec('Create function [ZL].[TieneOtroModuloCentralizadorActivo] ( @Serie varchar(13) ) returns bit begin declare @TieneCentralizador bit set @TieneCentralizador = 0 return @TieneCentralizador end')
  end  
go

/****** Object:  UserDefinedFunction [ZL].[TieneOtroModuloCentralizadorActivo]    Script Date: 11/05/2009 11:00:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Equipo Verde
-- Create date: 03-09-2009
-- Description:	Devuelve si el articulo tiene un módulo Centralizador
-- =============================================
ALTER FUNCTION [ZL].[TieneOtroModuloCentralizadorActivo] 
(
	@Serie varchar( 13)
)
RETURNS bit
AS
BEGIN

	DECLARE  @TieneCentralizador bit
	
	if exists( select * from ZL.Ismodulo where Tipomodu = '3' and Ccod in (select dm.ccod from ZL.Dmodart dm 
            left join ZL.Itemserv it on it.codart = dm.codigo 
            where it.nroserie = @Serie and ( ZL.[func-EsItemActivoSINActDesact]( it.ccod , getdate()) = 1)
            group by dm.ccod))
		set @TieneCentralizador = 1
	else 
		set @TieneCentralizador = 0
	
	RETURN @TieneCentralizador

END
