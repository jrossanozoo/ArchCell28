IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Datos_Cliente_20611]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Datos_Cliente_20611];
GO;

CREATE FUNCTION [Interfaces].[Datos_Cliente_20611]
(
	@FechaComprobanteDesde varchar(10),
	@FechaComprobanteHasta varchar(10)
)
RETURNS TABLE
AS
RETURN
(
	Select distinct
		Datos.NUM_PEDIDO,
		Datos.COD_CLIENT,
		Datos.TIPO_CBTE,
		Datos.LETRA_CBTE,
		Datos.SUC_CBTE,
		Datos.NUM_CBTE,
		Datos.FECHA_CBTE,
		Datos.ESTADO_CBTE,
		Datos.IMPORTE_CBTE
	From
		(select 
			Funciones.Alltrim( Pedido.FOBS ) as NUM_PEDIDO,
			Comprobante.FPERSON as COD_CLIENT,
			case 
				WHEN Comprobante.FACTTIPO IN (1, 2, 27) AND Comprobante.FLETRA = 'A' then 1
				WHEN Comprobante.FACTTIPO IN (1, 2, 27) AND Comprobante.FLETRA = 'B' then 2
				WHEN Comprobante.FACTTIPO IN (4, 6, 29) AND Comprobante.FLETRA = 'A' then 3
				WHEN Comprobante.FACTTIPO IN (4, 6, 29) AND Comprobante.FLETRA = 'B' then 4
				WHEN Comprobante.FACTTIPO IN (3, 5, 28) AND Comprobante.FLETRA = 'A' then 5
				WHEN Comprobante.FACTTIPO IN (3, 5, 28) AND Comprobante.FLETRA = 'B' then 6
				ELSE 7
			END as TIPO_CBTE,
			Comprobante.FLETRA as LETRA_CBTE,
			Funciones.Padl(cast(Comprobante.FPTOVEN as varchar(4)), 4, '0') as SUC_CBTE,
			Funciones.Padl(cast(Comprobante.FNUMCOMP as varchar(8)), 8, '0') as NUM_CBTE,
			convert(varchar(10), Comprobante.FFCH, 103) as FECHA_CBTE,
			Comprobante.ANULADO as ESTADO_CBTE,
			Comprobante.FTOTAL * Comprobante.SIGNOMOV as IMPORTE_CBTE
		from zoologic.comprobantev as Comprobante
		inner join ZooLogic.compafe as Afectado on Afectado.codigo = Comprobante.CODIGO and Afectado.AFETIPOCOM = 23
		inner join ZooLogic.COMPROBANTEV as Pedido on Afectado.afecta = Pedido.CODIGO
		where Comprobante.facttipo in (1, 3, 4, 2, 5, 6, 27, 28, 29, 33, 35, 36, 47, 48, 49, 54, 55, 56) 
		  and Comprobante.ffch between @FechaComprobanteDesde and @FechaComprobanteHasta
		) as Datos
)