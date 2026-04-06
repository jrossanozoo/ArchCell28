Use [ZL]
go 

IF NOT EXISTS (
 SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[funcConexionesxSerie]') AND type in (N'IF'))
  begin  
    exec('Create function [ZL].[funcConexionesxSerie] ( @SerieOrigen varchar(6) ) returns table as RETURN select 1 as col1')
  end  
go

/****** Object:  UserDefinedFunction [ZL].[funcConexionesxSerie]     Script Date: 06/11/2009 12:41:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:	Equipo Verde
-- Create date: 11-12-2009
-- Description:	Devuelve los series que comunican con el serie
-- =============================================
ALTER FUNCTION [ZL].[funcConexionesxSerie]
	(@SerieOrigen varchar(6))

RETURNS table
AS

return( 
select distinct( nroserie ) as serie
		  from zl.seriegrupo
		  where nroserie != 0 and grupo in ( select distinct grupo 
							from zl.seriegrupo 
							where nroserie = isnull( @serieorigen, nroserie )
							and ( fechaalta <= getdate() or fechaalta = '1900-01-01' )
							and ( fechabaja >= dateadd(day,0,datediff(DAY,0,getdate())) or fechabaja = '1900-01-01' ) )
				and ( fechaalta <= getdate() or fechaalta = '1900-01-01' )
				and ( fechabaja >= dateadd(day,0,datediff(DAY,0,getdate())) or fechabaja = '1900-01-01' ) )



