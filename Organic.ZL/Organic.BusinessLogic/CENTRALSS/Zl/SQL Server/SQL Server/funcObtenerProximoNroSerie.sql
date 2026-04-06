Use [ZL]
go 

IF  NOT EXISTS (
 SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[funcObtenerProximoNroSerie]') AND type in (N'IF'))
  begin  
    exec('create function [ZL].[funcObtenerProximoNroSerie] (@PEPE INT) returns table as RETURN select 1 as col1 ')
  end   
GO
/****** Object:  UserDefinedFunction [ZL].[funcObtenerProximoNroSerie]    Script Date: 09/18/2009 12:00:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION [ZL].[funcObtenerProximoNroSerie]
()
RETURNS table
AS

return(

/*

select top 1 right( '000000' + convert( varchar, Nroserie + 1 ), 6 ) as Nroserie
from ZL.Series T
where not exists( select 1 from ZL.Series where (Nroserie = T.Nroserie + 1)) and
    ((Nroserie between '100000' and '109999') or
    (Nroserie between '200000' and '209999') or
    (Nroserie between '400000' and '409999') or
    (Nroserie between '500000' and '509999') or
    (Nroserie between '600000' and '609999') or
    (Nroserie between '700000' and '709999') or
    (Nroserie between '800000' and '809999') or
    (Nroserie between '900000' and '909999')))*/
    
    --modificado 02/12/2010 Mbuero.
   SELECT  right( '000000' + convert( varchar, min(r.Nroserie) ), 6 ) as Nroserie
	FROM ZL.RangoSeries  as r LEFT JOIN ZL.Series as s ON r.NroSerie = s.Nroserie

	WHERE s.Nroserie is null  )
