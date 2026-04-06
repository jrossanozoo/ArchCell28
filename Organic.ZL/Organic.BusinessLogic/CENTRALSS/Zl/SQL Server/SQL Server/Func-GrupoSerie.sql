Use [ZL]
go 

--/Le llega por parametro un serie y devuelve en una tabla los grupos a los que pertenece --/
--/****** Objeto:  StoredProcedure [dbo].[funcGrupoSerie]    ******/
IF  NOT EXISTS (
 SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[funcGrupoSerie]') AND type in (N'IF'))
  begin  
    exec('create function [ZL].[funcGrupoSerie] (@PEPE INT) returns table as RETURN select 1 as col1 ')
  end   
go

ALTER FUNCTION [ZL].[funcGrupoSerie]
( @SerieOrigen varchar(7))

RETURNS table
AS
return ( select grupo
		 from zl.seriegrupo
		 where nroserie = @SerieOrigen and ( fechabaja > getdate() or fechabaja = '1900-01-01' ) )
