Use [ZL]
go 

--/****** Objeto:  StoredProcedure [dbo].[funcSerieConex]    Fecha de la secuencia de comandos: 05/13/2009 11:30:43 ******/
IF  NOT EXISTS (
 SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[funcSerieConex]') AND type in (N'if'))
  begin  
    exec('create function [dbo].[funcSerieConex] (@PEPE INT) returns table as RETURN select 1 as col1 ')
  end  
go

/****** Object:  UserDefinedFunction [dbo].[funcSerieConex]    Script Date: 06/11/2009 12:41:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER FUNCTION [ZL].[funcSerieConex]
( @serieorigen varchar( 6 ) )

RETURNS table
AS
 
return ( select grupo as conexion , grupodes, nroserie as serie
      from ZL.Seriegrupo
      where grupo in ( select grupo from ZL.Seriegrupo where nroserie = @serieorigen group by grupo )
      and nroserie <> @serieorigen )
