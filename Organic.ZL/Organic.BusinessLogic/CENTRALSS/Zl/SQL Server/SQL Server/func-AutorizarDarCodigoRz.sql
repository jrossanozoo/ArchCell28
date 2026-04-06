Use [ZL]
go 

IF  NOT EXISTS (
 SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[AutorizarDarCodigoRz]') AND type in (N'IF'))
  begin  
    exec('create function [ZL].[AutorizarDarCodigoRz] (@cCOdRZ varchar(5)) returns table as RETURN ( select 1 as col1 )
 ')
  end   
GO
----------------------------------------------------------------------------------------

USE [ZL]
GO
/****** Object:  UserDefinedFunction [ZL].[AutorizarDarCotigoRz]    Script Date: 11/18/2009 09:44:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================
-- Author:	Equipo Verde
-- Create date: 23-10-2009
-- Description:	Devuelve si el ultimo estado de la RZ 
-- TI que tenga
-- =============================================================================
ALTER FUNCTION [ZL].[AutorizarDarCodigoRz]

	
	(@cCOdRZ varchar(5))

RETURNS table
AS

return(	

		select --Estado.Dacodigo 
				case when IsNull(LTRIM(RTRIM(Estado.Fraent)),'') ='' then 0 else 1 end as DaCodigo 
		from zl.ASESTRZAD EstRZ
		inner join ( select nrz as RS, max(numero) as ultimoComprobante   
					 from zl.ASESTRZAD
					 group by nrz ) as UE on EstRZ.numero = UE.ultimoComprobante
		left join zl.Estado on EstRZ.cestado =  Estado.codigo 
		where EstRZ.Nrz = @cCOdRZ
		
		)
		
