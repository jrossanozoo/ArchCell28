Use [ZL]
go 

--/****** Objeto:  StoredProcedure [ZL].[SerieCentralizador]    Fecha de la secuencia de comandos: 05/13/2009 11:30:43 ******/
IF  NOT EXISTS (
 SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[SerieCentralizador]') AND type in (N'P', N'PC'))
  begin  
    exec('create proc [ZL].[SerieCentralizador] as ')
  end   
  
/****** Object:  StoredProcedure [ZL].[SerieCentralizador]    Script Date: 06/11/2009 12:32:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [ZL].[SerieCentralizador] (@SerieOrigen varchar(6))
AS
BEGIN
      select cast( it.ccod as char( 7 ) ) as relalote, it.nroserie, it.codart, ar.conexiones
      from zl.itemserv it inner join zl.isarticu ar on it.codart = ar.ccod
                  inner join zl.dmodart dm on ar.ccod = dm.codigo
                  inner join zl.ismodulo mo on dm.ccod = mo.ccod
      where mo.tipomodu = 3 and it.Nroserie = @SerieOrigen and [ZL].[func-EsItemVigente]( it.ccod ) = 1
END

