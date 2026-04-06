Use [ZL]
go 

--/****** Objeto:  StoredProcedure [ZL].[SeriesCentralizadoresxGrupo]    Fecha de la secuencia de comandos: 05/13/2009 11:30:43 ******/
IF  NOT EXISTS (
 SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[SeriesCentralizadoresxGrupo]') AND type in (N'P', N'PC'))
  begin  
    exec('create proc [ZL].[SeriesCentralizadoresxGrupo] as ')
  end   

/****** Object:  StoredProcedure [ZL].[SeriesCentralizadoresxGrupo]    Script Date: 06/11/2009 12:32:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [ZL].[SeriesCentralizadoresxGrupo] ( @Grupo int )
AS
BEGIN
      select cast( it.ccod as char( 7 ) ) as itemserv, se.nroserie, it.codart, ar.conexiones
      from Zl.funcSerieGrupo(@Grupo) se inner join zl.itemserv it on se.nroserie = it.nroserie
                  inner join zl.isarticu ar on it.codart = ar.ccod
                  inner join zl.dmodart dm on ar.ccod = dm.codigo
                  inner join zl.ismodulo mo on dm.ccod = mo.ccod
      where mo.tipomodu = 3 and [ZL].[func-EsItemVigente]( it.ccod ) = 1
END
