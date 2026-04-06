Use [ZL]
go 

--/****** Objeto:  StoredProcedure [zl].[ValidaStockDeConexiones]    Fecha de la secuencia de comandos: 05/13/2009 11:30:43 ******/
IF  NOT EXISTS (
 SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[ValidaStockDeConexiones]') AND type in (N'P', N'PC'))
  begin  
    exec('create proc [ZL].[ValidaStockDeConexiones] as ')
  end   

/****** Object:  StoredProcedure [zl].[ValidaStockDeConexiones]    Script Date: 06/08/2009 10:11:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [ZL].[ValidaStockDeConexiones] ( @Grupo int )
AS
BEGIN
      select it.relalote as itemserv, se.nroserie, it.codart, ar.conexiones
      from zl.seriegrupo se inner join zl.itemserv it on se.nroserie = it.nroserie
                  inner join zl.isarticu ar on it.codart = ar.ccod
                  inner join zl.dmodart dm on ar.ccod = dm.codigo
                  inner join zl.ismodulo mo on dm.ccod = mo.ccod
      where se.grupo = @Grupo and mo.tipomodu = 3
END

