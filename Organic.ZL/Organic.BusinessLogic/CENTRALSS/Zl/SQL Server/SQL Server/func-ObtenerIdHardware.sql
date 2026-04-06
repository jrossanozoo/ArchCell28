Use [ZL]
go 

IF  NOT EXISTS ( 
      SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[ObtenerIdhardware]') AND type in (N'FN'))
  begin  
    exec('create function [ZL].[ObtenerIdhardware] () returns varchar(3) begin declare @CodigoModulo varchar(4) set @CodigoModulo = 0000 return @CodigoModulo end')
  end   
GO

USE [ZL]
GO
/****** Object:  UserDefinedFunction [ZL].[ObtenerIdhardware]    Script Date: 11/02/2009 17:24:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================
-- Author:  Equipo Amarillo
-- Create date: 23-11-2009
-- Description:   Devuelve el id de HardWare
-- =============================================================================

alter FUNCTION [ZL].[ObtenerIdhardware]
  
()

returns varchar(3)
as
begin

declare @CodigoModulo varchar(3)
set @CodigoModulo = 'IDH'

return @CodigoModulo

end
