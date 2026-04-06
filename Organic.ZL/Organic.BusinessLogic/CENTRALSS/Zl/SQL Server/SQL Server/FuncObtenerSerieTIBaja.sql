Use [ZL]
go 

IF  NOT EXISTS (
 SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[ObtenerSeriesTIBaja]') AND type in (N'IF'))
  begin  
    exec('create function [ZL].[ObtenerSeriesTIBaja] (@ISBaja integer) returns table as RETURN ( select 1 as col1 )
 ')
  end   
GO
----------------------------------------------------------------------------------------
/****** Object:  UserDefinedFunction [ZL].[ObtenerSeriesTIBaja]     Script Date: 23/11/2009 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================
-- Author:	Equipo Verde
-- Create date: 23-10-2009
-- Description:	Se le pasa nro de lote de baja de servicio y devuelve los series
-- TI que tenga
-- =============================================================================
ALTER FUNCTION [ZL].[ObtenerSeriesTIBaja]
	( @ISBaja integer )

RETURNS table
AS

return(	
		select serieti 
		from zl.DetItemServiBaja    
		where Subitem = @ISBaja
)


