IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Datos_Icommkt_Customers]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Datos_Icommkt_Customers];
GO;

CREATE FUNCTION [Interfaces].[Datos_Icommkt_Customers]
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
	select	Funciones.alltrim(Cliente.Clcod) as UserId,
			SUBSTRING(DB_NAME(), 12, 8) as StoreCode,
			coalesce(Funciones.alltrim(Cliente.Clemail), '') as Email,
			Json.PRIMER_NOMBRE,
			Json.SEGUNDO_NOMBRE,
			Json.APELLIDO,
			Json.RAZON_SOCIAL,
			Json.SITUACION_FISCAL,
			Json.FECHA_DE_NACIMIENTO,
			Json.SEXO,
			Json.ESTADO_CIVIL,
			Json.CANTIDAD_DE_HIJOS,
			Json.CALLE,
			Json.NUMERO,
			Json.LOCALIDAD,
			Json.CODIGO_POSTAL,
			Json.PROVINCIA,
			Json.PAIS,
			Json.TELEFONO,
			Json.TELEFONO_MOVIL,
			Json.VENDEDOR,
			Json.TRANSPORTISTA,
			Json.LISTA_DE_PRECIO,
			Json.DESCUENTO,
			Json.LIMITE_DE_CREDITO,
			Json.CONDICION_DE_PAGO,
			Json.CLASIFICACION,
			Json.TIPO,
			Json.CATEGORIA,
			Json.RECOMENDADO_POR
	from ZooLogic.COMPROBANTEV as Comprobante
		left join ZooLogic.CLI as Cliente on Comprobante.FPERSON = Cliente.CLCOD
		left join Interfaces.Auxiliar_Icommkt_ObtenerJSONCustomers() as Json on Cliente.CLCOD = Json.Codigo
	where Comprobante.FACTTIPO in (1, 2, 27)
		and Comprobante.FLETRA between @LetraDesde and @LetraHasta
		and Comprobante.FPTOVEN between @PuntoVentaDesde and @PuntoVentaHasta
		and Comprobante.FNUMCOMP between @NumeroComprobanteDesde and @NumeroComprobanteHasta
		and Comprobante.FFCH between @FechaComprobanteDesde and @FechaComprobanteHasta
		and Comprobante.FECEXPO between @FechaExportacionDesde and @FechaExportacionHasta
		and Comprobante.Anulado = 0
		and Comprobante.FPERSON != ''
)