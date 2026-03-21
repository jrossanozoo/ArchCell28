IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Datos_CaballitoShopping]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Datos_CaballitoShopping];
GO;

CREATE FUNCTION [Interfaces].[Datos_CaballitoShopping]
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
	select DISTINCT 
		DatosExpo.TipoComprobante,
		DatosExpo.Letra,
		DatosExpo.PuntoDeVenta,
		DatosExpo.Numero,
		DatosExpo.Fecha,
		DatosExpo.Hora,
		DatosExpo.Fecha_hora ,
		DatosExpo.Total,
		DatosExpo.iva,
		DatosExpo.OtrosImpuestos, 
		DatosExpo.Anulado,
		DatosExpo.Tipo,
		DatosExpo.Cliente_cuit, 
		DatosExpo.cliente_dni,
		DatosExpo.CodComprobante,
		DatosExpo.TipoMedioDePago,
		DatosExpo.MedioDePago,
		DatosExpo.ImportePago
	from
	(
		select 
			case when Comprobante.FACTTIPO in (1,2,27,33,47) then 'D' else 'C' end as TipoComprobante,
			Comprobante.FLETRA as Letra,
			cast(Funciones.padl(Comprobante.FPTOVEN,4,'0') as char(4)) as PuntoDeVenta,
			cast(Funciones.padl(Comprobante.FNUMCOMP,8,'0') as char(8)) as Numero,
			Convert(char(8), Comprobante.FFCH, 3) as Fecha,
			Comprobante.HMODIFW as Hora,
			comprobante.ffch as fecha_hora,
			cast(Funciones.padl(left(FTOTAL,9),9,'0') as char(9)) as Total,
			cast(Funciones.padl(left(FIMPUESTO,9),9,'0') as char(9)) as iva,
			cast(Funciones.padl(left(TOTIMPUE,9),9,'0') as char(9)) as OtrosImpuestos,
		--	case when ( select top 1 xVal.CLCFI 
						--from ZooLogic.val as Val 
						--inner join ZooLogic.xval as xVal on Val.JJCO = xVal.CLCOD 
					--	where val.JJNUM = Comprobante.CODIGO
					--	order by Val.NROITEM asc) = 3 then '03' else '01' 
		--	end as FormaDePago,
			cast(Comprobante.ANULADO as char(1)) as Anulado,
			Funciones.Alltrim(cast(Comprobante.FACTTIPO as char)) as Tipo,
		     coalesce (cli.CLcuit,'0') as cliente_cuit, 
			 coalesce (cli.clnrodoc,'0') as cliente_dni,
			 coalesce(comprobante.codigo,'0') as CodComprobante,cast(Funciones.padl(left(JJTOTFAC,9),9,'0') as char(9)) as				ImportePago ,
			 case when xval.clcfi = 1 then 'E' else 
			 case when xval.clcfi = 3 then 'T' else 'O' end end  as TipoMedioDePago,
			 xval.clcod as MedioDePago    
		from ZooLogic.COMPROBANTEV as Comprobante left join Zoologic.CLI on CLI.CLCOD = Comprobante.FCLIENTE
		left join Zoologic.val on val.JJNUM = comprobante.CODIGO left join  Zoologic.xval  on Val.JJCO = xVal.CLCOD 
		where Comprobante.FACTTIPO in (1,2,3,5,27,28,33,35,47,48)
			and Comprobante.FLETRA between @LetraDesde and @LetraHasta
			and Comprobante.FPTOVEN between @PuntoVentaDesde and @PuntoVentaHasta
			and Comprobante.FNUMCOMP between @NumeroComprobanteDesde and @NumeroComprobanteHasta
			and Comprobante.FFCH between @FechaComprobanteDesde and @FechaComprobanteHasta
			and Comprobante.FECEXPO between @FechaExportacionDesde and @FechaExportacionHasta
	) as DatosExpo
)
