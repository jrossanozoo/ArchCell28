IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Interfaz_COMARB_SIFERE_PercepcionesSufridas_IIBB]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Interfaz_COMARB_SIFERE_PercepcionesSufridas_IIBB];
GO;

CREATE  FUNCTION [Interfaces].[Interfaz_COMARB_SIFERE_PercepcionesSufridas_IIBB]
( 
	@FechaEmisionDesde varchar(10),
	@FechaEmisionHasta varchar(10),
	@FechaIngresoDesde varchar(10),
	@FechaIngresoHasta varchar(10) 
)
RETURNS TABLE
AS
RETURN
(
	select cast( DatosExpo.Jurisdicci as char(3) ) as Jurisdicci, 
		cast( Funciones.ObtenerCUITFormateadoConGuiones( DatosExpo.CUIT ) as char(13) ) as CUIT,
		cast( DatosExpo.Diafecha + '/' + DatosExpo.MesFecha + '/' + DatosExpo.AnioFecha as char(10) ) as FechaEmision, 
		cast( Funciones.padl( cast( DatosExpo.PuntoVenta as varchar(4) ), 4, '0' ) as char(4) ) as PtoVenta,
		cast( Funciones.padl( cast( DatosExpo.NumeroComprobante as varchar(8) ),8, '0' ) as char(8) ) as NumComp,
		cast( DatosExpo.Tipo as char(1) ) as TipoComp, 
		cast( DatosExpo.LetraComprobante as char(1) ) as LetraComp,
		case cast( DatosExpo.Tipo as char(1) )
			when 'C' then cast( '-' + Funciones.ObtenerMontoConPadlConSeparadorDecimal( DatosExpo.MontoPercepcionIIBB, 2, 10, ',' ) as char(11) )
			else cast( Funciones.ObtenerMontoConPadlConSeparadorDecimal( DatosExpo.MontoPercepcionIIBB, 2, 11, ',' ) as char(11) )
		end as MontoPerce
		from (
		--> comprobantes de compra
			select ImpCompras.Jurisdicci as Jurisdicci, 
				Comprobante.FCUIT as CUIT,
				cast( Funciones.padl( cast( day( Comprobante.FFchfac ) as varchar(2) ), 2, '0' ) as char(2) ) as DiaFecha, 
				cast( Funciones.padl( cast( month(Comprobante.FFchfac ) as varchar(2) ), 2, '0' ) as char(2) ) as MesFecha, 
				cast( Funciones.padl( cast( year( Comprobante.FFchfac ) as varchar(4) ), 4, '0' ) as char(4) ) as AnioFecha, 
				Comprobante.FPtoVen as PuntoVenta,
				Comprobante.FNumComp as NumeroComprobante,
				Comprobante.FTipo as Tipo,
				Comprobante.FLetra as LetraComprobante,
				ImpCompras.MontoPercibido as MontoPercepcionIIBB
			from (
					select Codigo, FFchfac, ffch, FPtoVen, FNumComp, 'F' as FTipo, FLetra, FCUIT, Anulado, FactTipo
					from [ZooLogic].[FacCompra]
					union all
					select Codigo, FFchfac, ffch, FPtoVen, FNumComp, 'C' as FTipo, FLetra, FCUIT, Anulado, FactTipo
					from [ZooLogic].[NCCompra]
					union all
					select Codigo, FFchfac, ffch, FPtoVen, FNumComp, 'D' as FTipo, FLetra, FCUIT, Anulado, FactTipo
					from [ZooLogic].[NDCompra]
				) as Comprobante
			inner join (
				select ImpCompras.CCod,
					ImpCompras.Jurisdicci as Jurisdicci,
					ImpCompras.Monto as MontoPercibido
				from (
					select ImpCompras.CCod as CCod,
						ImpCompras.CodImp as CodImp,
						ImpCompras.Monto as Monto,
						Impuestos.Jurisdicci as Jurisdicci
					from [ZooLogic].[ImpFacC] as ImpCompras
						inner join [ZooLogic].[Impuesto] as Impuestos on ( ImpCompras.CodImp = Impuestos.Codigo and Impuestos.Tipo = 'IIBB' and Impuestos.Aplicacion = 'PRC' )
					union all
					select ImpCompras.CCod as CCod,
						ImpCompras.CodImp as CodImp,
						ImpCompras.Monto as Monto,
						Impuestos.Jurisdicci as Jurisdicci
					from [ZooLogic].[ImpNCC] as ImpCompras
						inner join [ZooLogic].[Impuesto] as Impuestos on ( ImpCompras.CodImp = Impuestos.Codigo and Impuestos.Tipo = 'IIBB' and Impuestos.Aplicacion = 'PRC' )
					union all
					select ImpCompras.CCod as CCod,
						ImpCompras.CodImp as CodImp,
						ImpCompras.Monto as Monto,
						Impuestos.Jurisdicci as Jurisdicci
					from [ZooLogic].[ImpNDC] as ImpCompras
						inner join [ZooLogic].[Impuesto] as Impuestos on ( ImpCompras.CodImp = Impuestos.Codigo and Impuestos.Tipo = 'IIBB' and Impuestos.Aplicacion = 'PRC' )
					) as ImpCompras
			) as ImpCompras on Comprobante.Codigo = ImpCompras.CCod
			where Comprobante.FactTipo in ( 8, 9, 10 )
				and Comprobante.Anulado = 0
				and Comprobante.FFchfac >= @FechaEmisionDesde and Comprobante.FFchfac <= @FechaEmisionHasta
				and Comprobante.FFch >= @FechaIngresoDesde and Comprobante.FFch <= @FechaIngresoHasta
			) as DatosExpo
)

