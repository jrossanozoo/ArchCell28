Use [ZL]
go 

IF  NOT EXISTS (
 SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[AutorizarDarCodigoRzPorExcepcion]') AND type in (N'IF'))
  begin  
    exec('create function [ZL].[AutorizarDarCodigoRzPorExcepcion] (@cCOdRZ varchar(5)) returns table as RETURN ( select 1 as col1 )
 ')
  end   
GO
----------------------------------------------------------------------------------------
USE [ZL]
GO

/****** Object:  UserDefinedFunction [ZL].[AutorizarDarCodigoRzPorExcepcion]    Script Date: 11/17/2009 15:51:26 ******/
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
alter FUNCTION [ZL].[AutorizarDarCodigoRzPorExcepcion]
						
	(@cCOdRZ varchar(5))

RETURNS table
AS

return(	

		select --Estado.Dacodigo 
				case when IsNull(LTRIM(RTRIM(Estado.Fraent)),'') ='' then 0 else 1 end as DaCodigo 
		from zl.aatmda
		inner join ( select Razonsoc as RS, max(Codin) as ultimoComprobante   
					 from zl.aatmda
					 group by Razonsoc ) as UE on aatmda.Codin = UE.ultimoComprobante
		left join zl.Estado on aatmda.cestado =  Estado.codigo 
		where aatmda.Razonsoc = @cCOdRZ and
		      Funciones.dtos( aatmda.cmpfecfin ) > getdate()
		)


