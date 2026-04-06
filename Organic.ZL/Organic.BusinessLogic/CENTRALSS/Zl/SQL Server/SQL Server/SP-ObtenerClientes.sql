use ZL
go

IF  NOT EXISTS (
 SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[ObtenerClientes]') AND type in (N'P', N'PC'))
  begin  
    exec('create proc [ZL].[ObtenerClientes] as ')
  end   
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
ALTER PROCEDURE [ZL].[ObtenerClientes]( @NroSerie varchar(7) )
            
AS
BEGIN
            SET NOCOUNT ON;

select cli.cmpcodigo, cli.cmpnombre, cont.pnom, rz.cmpcod,rz.descrip, rz.fantasia, '' as cabelin
            from zl.clientes cli
            left outer join zl.contact cont on cont.ccliente = cli.cmpcodigo
            inner join zl.razonsocial rz on  rz.cliente = cli.cmpcodigo
			WHERE rz.Cmpcod IN     
(SELECT DISTINCT(Crass) AS RAZONSOCIAL FROM ZL.Itemserv WHERE Nroserie IN (select Nroserie 
      from zl.seriegrupo
      where grupo in
             ( select grupo from zl.seriegrupo where nroserie = @NroSerie )))
        

END

GO
