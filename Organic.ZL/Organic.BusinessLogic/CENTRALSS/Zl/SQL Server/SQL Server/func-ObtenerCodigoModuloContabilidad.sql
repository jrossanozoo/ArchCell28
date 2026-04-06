Use [ZL]
go 

IF  NOT EXISTS ( 
      SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[ObtenerCodigoModuloContabilidad]') AND type in (N'FN'))
  begin  
    exec('create function [ZL].[ObtenerCodigoModuloContabilidad] () returns varchar(4) begin declare @CodigoModulo varchar(4) set @CodigoModulo = 0000 return @CodigoModulo end')
  end   
GO

USE [ZL]
GO
/****** Object:  UserDefinedFunction [ZL].[ObtenerCodigoModuloContabilidad]    Script Date: 11/02/2009 17:24:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================
-- Author:  Equipo Verde
-- Create date: 03-11-2009
-- Description:   Devuelve el codigo del modulo
-- =============================================================================

alter FUNCTION [ZL].[ObtenerCodigoModuloContabilidad]
  
()

returns varchar(4)
as
begin

declare @CodigoModulo varchar(4)
set @CodigoModulo = '0008'

return @CodigoModulo

end
