use ZL
go 

IF  NOT EXISTS (
 SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[ObtenerDatosElinceZLxSerie]') AND type in (N'P', N'PC'))
  begin  
    exec('create proc [ZL].[ObtenerDatosElinceZLxSerie] as ')
  end   

/****** Object:  StoredProcedure [ZL].[ObtenerDatosElinceZLxSerie]    Script Date: 12/21/2009 09:24:35 ******/

USE [ZL]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [ZL].[ObtenerDatosElinceZLxSerie]
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
				  (case when dmod.ccod = ZL.ObtenerCodigoModuloHost() then 1 else 0 end) as Host,
            	  (case when ismod.tipomodu = 2 then 1 else 0 end) as eHost,
          		  (case when dmod.ccod = ZL.ObtenerCodigoModuloMemo() then 1 else 0 end) as Memo,
            	  (case when dmod.ccod = ZL.ObtenerCodigoModuloCheckline() then 1 else 0 end) as CHKLine,
            	  (case when dmod.ccod = ZL.ObtenerCodigoModuloProgramadorDeTareas() then 1 else 0 end) as ProgTareas,
				  (case when ismod.tipomodu = 3 then 1 else 0 end) as Centralizad
            from zl.itemserv item
            inner join zl.series ser on ser.nroserie = item.nroserie
            inner join zl.dmodart dmod on item.codart = dmod.codigo
            inner join ZL.Razonsocial RZ on  RZ.Cmpcod = item.Crass
            inner join zl.Ismodulo ismod on dmod.Ccod = ismod.Ccod
            where ( ismod.ccod = ZL.ObtenerCodigoModuloProgramadorDeTareas() or 
					ismod.ccod = ZL.ObtenerCodigoModuloMemo() or
					ismod.ccod = ZL.ObtenerCodigoModuloHost() or
					ismod.ccod = ZL.ObtenerCodigoModuloCheckline() or
					ismod.tipomodu in ( 2, 3 ) )
            and Item.Cmpfecalt <= GETDATE() 
            and Item.Cmpfecdes = '19000101'
			AND item.Ccod IN 
			(SELECT Ccod  FROM ZL.Itemserv WHERE Nroserie IN (select Nroserie 
				from zl.seriegrupo
				where grupo in
	             ( select grupo from zl.seriegrupo where nroserie = @nroserie
					and ( fechaalta <= getdate() or fechaalta = '1900-01-01' )
					and ( fechabaja > getdate() or fechabaja = '1900-01-01' ) )))
				    group by item.crass, rz.cliente,item.nroserie,puesto, item.codart, dmod.descr, dmod.ccod, ismod.tipomodu
					order by item.nroserie


END
