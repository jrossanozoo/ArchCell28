Use [ZL]
go 

IF  NOT EXISTS (
 SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[funcSerieCentralizador]') AND type in (N'FN'))
  begin  
    exec('Create function [ZL].[funcSerieCentralizador] ( @SerieOrigen varchar(6) ) returns bit begin declare @EsCentralizador bit set @EsCentralizador = 0 return @EsCentralizador end')
  end  
go

/****** Object:  UserDefinedFunction [ZL].[funcSerieCentralizador]   Script Date: 06/11/2009 12:41:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================
-- Author:  Equipo Verde
-- Create date: 30-12-2009
-- Description:   Devuelve si el serie es centralizador
-- =============================================================================
ALTER FUNCTION [ZL].[funcSerieCentralizador]
(
	@SerieOrigen varchar(6)
)
RETURNS bit
AS
BEGIN

	declare @EsCentralizador bit
	if exists ( select it.relalote, it.nroserie, it.codart, ar.conexiones
		        from zl.itemserv it inner join zl.isarticu ar on it.codart = ar.ccod
									inner join zl.dmodart dm on ar.ccod = dm.codigo
									inner join zl.ismodulo mo on dm.ccod = mo.ccod
				where mo.tipomodu = 3 and
					it.Nroserie = @SerieOrigen and
					[ZL].[func-EsItemVigente]( it.ccod ) = 1 )
		set @EsCentralizador = 1
	else
		set @EsCentralizador = 0
	
	return @EsCentralizador
END
