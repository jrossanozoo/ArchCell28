IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Interfaz_ARBA2225_Retenciones]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Interfaz_ARBA2225_Retenciones];
GO;

create function [Interfaces].[Interfaz_ARBA2225_Retenciones]
(
	@FechaDesde varchar(10),
	@FechaHasta varchar(10)
)
RETURNS TABLE
AS
RETURN
(
	Select 
	cast( Funciones.ObtenerCUITFormateadoConGuiones( DatosExpo.ClCuit ) as char(13)) as CUIT,
	cast( DatosExpo.Diafecha + '/' + DatosExpo.MesFecha + '/' + DatosExpo.AnioFecha as char(10) ) as FechaRetencion, 
	cast( Funciones.padl( cast( DatosExpo.PtoVenta as varchar(5) ), 5, '0' ) as char(5)) as PuntodeVenta,
	cast( Funciones.padl( cast( DatosExpo.Numero as varchar(8) ), 8, '0' ) as char(8)) as NumeroComprobante,
	cast( Funciones.ObtenerMontoConPadlConSeparadorDecimal( DatosExpo.MontoBase, 2, 14, ',' )  as char(14)) as BaseImponible,
	cast( Funciones.ObtenerMontoConPadlConSeparadorDecimal( DatosExpo.Porcentaje, 2, 5, ',' ) as char(5)) as AliCuota,
	cast( Funciones.ObtenerMontoConPadlConSeparadorDecimal( DatosExpo.Monto, 2, 13, ',' ) as char(13)) as MontoRetencion,
	'A' as alta
	from (
			Select Proveedores.ClCuit, 
				cast( Funciones.padl( cast( day( Comprobantes.Fecha ) as varchar(2) ), 2, '0' ) as char(2) ) as DiaFecha, 
				cast( Funciones.padl( cast( month(Comprobantes.Fecha ) as varchar(2) ), 2, '0' ) as char(2) ) as MesFecha, 
				cast( Funciones.padl( cast( year( Comprobantes.Fecha ) as varchar(4) ), 4, '0' ) as char(4) ) as AnioFecha,
				Comprobantes.PtoVenta, Comprobantes.Numero, ImpuestosVentas.Monto, ImpuestosVentas.MontoBase, ImpuestosVentas.Porcentaje
				from ZooLogic.COMPRET as  Comprobantes
					join ZooLogic.CrimpDet as ImpuestosVentas on Comprobantes.Codigo = ImpuestosVentas.Codigo
					left join ZooLogic.Prov as Proveedores on Comprobantes.Prov = Proveedores.ClCod
				where Comprobantes.TipoImp = 'IIBB'
					and Comprobantes.Anulado = 0 
					and Comprobantes.Fecha between @FechaDesde and @FechaHasta				
					and ImpuestosVentas.Jurisdicci = '902' 
		) as DatosExpo	
 )
