Use [ZL]
go 

IF  NOT EXISTS (
 SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[ObtenerEstadosRZAReestablecer]') AND type in (N'IF'))
  begin  
    exec('create function [ZL].[ObtenerEstadosRZAReestablecer] () returns table as RETURN ( select 1 as col1 )
 ')
  end   
GO
----------------------------------------------------------------------------------------
USE [ZL]
GO
/****** Object:  UserDefinedFunction [ZL].[ObtenerEstadosRZAReestablecer]    Script Date: 11/17/2009 16:48:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================
ALTER FUNCTION [ZL].[ObtenerEstadosRZAReestablecer]

	()

RETURNS table
AS

return(	

WITH UltimaExecpcion as
( 

	select	aatmda.razonsoc, spc.dacodigo, max(Aatmda.Cmpfecfin ) as fechafin
		from zl.aatmda
		cross apply [ZL].[AutorizarDarCodigoRz](aatmda.razonsoc) as spc
		group by razonsoc, dacodigo   
)

select *
from UltimaExecpcion
where fechafin between (GETDATE()-3) and (GETDATE()-1)
		
)
