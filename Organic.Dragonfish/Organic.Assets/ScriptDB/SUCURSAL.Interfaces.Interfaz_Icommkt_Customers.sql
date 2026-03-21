IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Interfaz_Icommkt_Customers]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Interfaz_Icommkt_Customers];
GO;

CREATE FUNCTION [Interfaces].[Interfaz_Icommkt_Customers]
(
	@LetraDesde char(1),
	@LetraHasta char(1),
	@PuntoVentaDesde int,
	@PuntoVentaHasta int,
	@NumeroComprobanteDesde int,
	@NumeroComprobanteHasta int,
	@FechaComprobanteDesde varchar(10),
	@FechaComprobanteHasta varchar(10),
	@FechaExportacionDesde varchar(10),
	@FechaExportacionHasta varchar(10)
)
RETURNS TABLE
AS
RETURN
(
	select	DatosExpo.UserId,
			DatosExpo.StoreCode,
			DatosExpo.Email,
			DatosExpo.PRIMER_NOMBRE,
			DatosExpo.SEGUNDO_NOMBRE,
			DatosExpo.APELLIDO,
			DatosExpo.RAZON_SOCIAL,
			DatosExpo.SITUACION_FISCAL,
			DatosExpo.FECHA_DE_NACIMIENTO,
			DatosExpo.SEXO,
			DatosExpo.ESTADO_CIVIL,
			DatosExpo.CANTIDAD_DE_HIJOS,
			DatosExpo.CALLE,
			DatosExpo.NUMERO,
			DatosExpo.LOCALIDAD,
			DatosExpo.CODIGO_POSTAL,
			DatosExpo.PROVINCIA,
			DatosExpo.PAIS,
			DatosExpo.TELEFONO,
			DatosExpo.TELEFONO_MOVIL,
			DatosExpo.VENDEDOR,
			DatosExpo.TRANSPORTISTA,
			DatosExpo.LISTA_DE_PRECIO,
			DatosExpo.DESCUENTO,
			DatosExpo.LIMITE_DE_CREDITO,
			DatosExpo.CONDICION_DE_PAGO,
			DatosExpo.CLASIFICACION,
			DatosExpo.TIPO,
			DatosExpo.CATEGORIA,
			DatosExpo.RECOMENDADO_POR
	from [Interfaces].[Datos_Icommkt_Customers](@LetraDesde, @LetraHasta, @PuntoVentaDesde, @PuntoVentaHasta, @NumeroComprobanteDesde, @NumeroComprobanteHasta, @FechaComprobanteDesde, @FechaComprobanteHasta, @FechaExportacionDesde, @FechaExportacionHasta) as DatosExpo
)