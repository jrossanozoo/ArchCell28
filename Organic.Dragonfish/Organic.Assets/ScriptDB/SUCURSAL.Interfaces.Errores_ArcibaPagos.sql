IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Errores_ArcibaPagos]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Errores_ArcibaPagos];
GO;

CREATE FUNCTION [interfaces].[Errores_ArcibaPagos]
( 
@FechaDesde as char(8),
@FechaHasta as char(8)
)
RETURNS TABLE
AS
RETURN 
(
	select DISTINCT * from
	(
		select 
			--La resolución del impuesto retenido debe ser de tres posiciones numéricas.
			cast( convert(varchar(10), GETDATE(), 108) + ',' + ' No se exportó la Orden de pago  :   ' + funciones.padl(funciones.alltrim(c_comprobante.PtoVenOP),4,'0') + '-' + funciones.padl(funciones.alltrim(c_comprobante.NumOP),8,'0') + '. La resolución del impuesto retenido debe ser de tres posiciones numéricas.' as varchar(250)) as RegError
			from ZooLogic.COMPRET as c_comprobante
			inner join [ZooLogic].[CRImpDet] as c_CDRImpuestos on c_CDRIMPUESTOS.CODIGO = c_comprobante.CODIGO and (c_CDRImpuestos.Jurisdicci = '901' and c_CDRImpuestos.monto > 0)
			inner join [ZooLogic].[Prov] as c_Proveedor on c_Proveedor.ClCod = funciones.alltrim(c_comprobante.prov)
			inner join [ZooLogic].[IMPUESTO] as c_impuesto on c_impuesto.CODIGO =  c_CDRImpuestos.CODIMP	
			where (c_comprobante.fecha >= @FechaDesde and c_comprobante.fecha <= @FechaHasta) and (c_comprobante.Numero <> 0 or c_comprobante.anulado = 0)  and ( isnumeric(substring(funciones.alltrim(c_impuesto.RESOLU),1,3)) = 0  )
		union all

		select 
			--No se acepta alicuota en cero cuando el código de norma es distinto de 28 o 29
			cast( convert(varchar(10), GETDATE(), 108) + ',' + ' No se exportó la Orden de pago  :   ' + funciones.padl(funciones.alltrim(c_comprobante.PtoVenOP),4,'0') + '-' + funciones.padl(funciones.alltrim(c_comprobante.NumOP),8,'0') + '. No se acepta alicuota en cero cuando el código de norma es distinto de 28 o 29.' as varchar(250)) as RegError
			from ZooLogic.COMPRET as c_comprobante
			inner join [ZooLogic].[CRImpDet] as c_CDRImpuestos on c_CDRIMPUESTOS.CODIGO = c_comprobante.CODIGO and (c_CDRImpuestos.Jurisdicci = '901' and c_CDRImpuestos.monto > 0)
			inner join [ZooLogic].[Prov] as c_Proveedor on c_Proveedor.ClCod = funciones.alltrim(c_comprobante.prov)
			where (c_comprobante.fecha >= @FechaDesde and c_comprobante.fecha <= @FechaHasta) and (c_comprobante.Numero <> 0 or c_comprobante.anulado = 0)  and ( funciones.alltrim(substring(funciones.alltrim(c_CDRImpuestos.ResolDeta),1,3)) not in('28','29','028','029') and c_CDRImpuestos.porcentaje = 0 )

) as arcibaPagos --Pagos
)


