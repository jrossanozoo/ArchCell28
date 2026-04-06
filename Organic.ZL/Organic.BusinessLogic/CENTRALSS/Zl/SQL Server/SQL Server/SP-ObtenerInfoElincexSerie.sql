use ZL
go

IF  NOT EXISTS (
 SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[ObtenerInfoElincexSerie]') AND type in (N'P', N'PC'))
  begin  
    exec('create proc [ZL].[ObtenerInfoElincexSerie] as ')
  end   
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [ZL].[ObtenerInfoElincexSerie]
            -- Add the parameters for the stored procedure here
            @nroserie varchar(6)
AS
BEGIN
            -- SET NOCOUNT ON added to prevent extra result sets from
            -- interfering with SELECT statements.
            
            /* Devuelve los series y los modulos habilitados de un clientes*/
            
            SET NOCOUNT ON;
			select item.nroserie, 
                   ser.puesto, 
                   item.crass, 
                   rz.cliente,
                   item.codart,
                   dmod.descr,
                   (case when dmod.descr = 'Host' then 1 else 0 end) as Host,
                   (case when dmod.descr = 'eHost' then 1 else 0 end) as eHost, 
                   (case when dmod.descr = 'Memo' then 1 else 0 end) as Memo, 
                   (case when dmod.descr = 'CHKLine' then 1 else 0 end) as CHKLine, 
                   (case when dmod.descr = 'ProgTareas' then 1 else 0 end) as ProgTareas, 
                   (case when dmod.descr = 'Centralizad' then 1 else 0 end) as Centralizad
            from zl.itemserv item
				inner join zl.series ser on ser.nroserie = item.nroserie
				inner join zl.dmodart dmod on item.codart = dmod.codigo
				inner join ZL.Razonsocial RZ on  RZ.Cmpcod = item.Crass
            where dmod.descr in ('Host','eHost','Memo','CHKLine','ProgTareas','Centralizad' )
				and Item.Cmpfecalt <= GETDATE() 
				and Item.Cmpfecdes = '19000101'
				AND item.Nroserie = @nroserie 
			group by item.crass, rz.cliente,item.nroserie,puesto, item.codart, dmod.descr
			order by item.nroserie
            

END
