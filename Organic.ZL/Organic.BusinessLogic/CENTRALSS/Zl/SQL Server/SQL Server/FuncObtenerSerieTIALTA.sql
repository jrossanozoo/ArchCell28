Use [ZL]
go 

IF  NOT EXISTS (
 SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[ObtenerSeriesTIAlta]') AND type in (N'IF'))
  begin  
    exec('create function [ZL].[ObtenerSeriesTIAlta] (@ISAlta integer) returns table as RETURN ( select 1 as col1 )
 ')
  end   
GO
----------------------------------------------------------------------------------------
/****** Object:  UserDefinedFunction [ZL].[ObtenerSeriesTIAlta]     Script Date: 23/11/2009 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================
-- Author:	Equipo Verde
-- Create date: 23-10-2009
-- Description:	Se le pasa nro de lote de alta de servicio y devuelve los series
-- TI que tenga
-- =============================================================================
ALTER FUNCTION [ZL].[ObtenerSeriesTIAlta]
	( @ISAlta integer )

RETURNS table
AS

return(	
		select serieti 
		from zl.DetItemServicio
		where Subitem = @ISAlta
)


