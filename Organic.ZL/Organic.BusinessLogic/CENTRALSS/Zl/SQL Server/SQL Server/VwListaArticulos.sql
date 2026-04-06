USE [testing]
GO

/****** Object:  View [ZL].[VwListaArticulos]    Script Date: 05/07/2010 11:25:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [ZL].[VwListaArticulos] WITH ENCRYPTION  AS 

SELECT	
		ISer.Ccod as ArticuloCodigo
		,LTRIM(RTRIM(ISer.Descr)) as ArticuloDescripcion
		,case ISer.Endolar 
					when 0 then '$'
					when 1 then 'u$s'
					end as ArticuloMoneda
		,Precios.Pdirecto as Precio
		,ISer.product as ProductoCodigo
		,LTRIM(RTRIM(prod.descr)) as ProductoDescripcion
		,substring(modulos.modulos,1,len(modulos.modulos)-1) as DetalleModulos
		,iser.Orden as OrdenImpreso

FROM
	ZL.Isarticu AS ISer INNER JOIN
	ZL.Precioar as Precios --solo articulos con precio
				ON ISer.Ccod = Precios.Articulo
			INNER join zl.prodzl as prod on ISer.product = prod.ccod
			
			LEFT join
					(

					select art.ccod, (	select LTRIM(RTRIM(modulos.descr)) + ', '
										from  zl.DMODART as modulos	
										where codigo    = art.ccod		
										order by  modulos.ccod		
										FOR XML PATH('') 
										)  		as Modulos from ZL.Isarticu as Art
					) as modulos on modulos.ccod = ISer.Ccod



		where

		ISer.Desacti = 0 --solo art activos
		and ISer.Tipart = 'AB' --solo abonos / tipo software
		and ISer.Ccod in (select codcla from zl.DCLAART where cmpclasif = '01' ) --solo clientes estandar
		AND Precios.Listapre = 'ZOO002' --solo precios de esta lista 
		AND Precios.Pdirecto <> 0






GO


