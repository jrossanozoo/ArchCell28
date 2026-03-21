IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Interfaz_AFIP3685_DuplicadosElectronicosDetalle]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Interfaz_AFIP3685_DuplicadosElectronicosDetalle];
GO;

CREATE FUNCTION [Interfaces].[Interfaz_AFIP3685_DuplicadosElectronicosDetalle]
( 
	@FechaDesde varchar(10),
	@FechaHasta varchar(10),
	@UsarDescripcionGenerica bit,
	@DescripcionGenerica varchar(75)
)
RETURNS TABLE
AS
RETURN
(
	select cast( Funciones.padl( DatosExpo.TipoComprobante, 3, '0' ) as char(3) ) as TipoComp,
		cast( case when DatosExpo.ComprobanteFiscal = 1 then 'C' else '' end as char(1) ) as ContFisc,
		cast( Funciones.padl( cast( year( DatosExpo.FechaComprobante ) as varchar(4) ), 4, '0' ) as char(4) ) as AnioFecha,
		cast( Funciones.padl( cast( month( DatosExpo.FechaComprobante ) as varchar(2) ), 2, '0' ) as char(2) ) as MesFecha,
		cast( Funciones.padl( cast( day( DatosExpo.FechaComprobante ) as varchar(2) ), 2, '0' ) as char(2) ) as DiaFecha,
		cast( Funciones.padl( cast( DatosExpo.PuntoVenta as varchar(5) ), 5, '0' ) as char(5) ) as PtoVenta,
		cast( Funciones.padl( cast( DatosExpo.NumeroComprobante as varchar(8) ), 8, '0' ) as char(8) ) as NumComp,
		cast( Funciones.padl( cast( DatosExpo.NumeroComprobante as varchar(8) ), 8, '0' ) as char(8) ) as NumCompReg,
		cast( Funciones.ObtenerMontoNegativoConPadlSinComa( case when DatosExpo.Cantidad < 0 then 1 else DatosExpo.Cantidad end, 5, 12 ) as char(12) ) as CantiArt,
		cast( case when DatosExpo.Cantidad < 0 then '99' else DatosExpo.UnidadMedida end as char(2) ) as UnidadMed,
		cast( Funciones.ObtenerMontoNegativoConPadlSinComa( case when DatosExpo.Cantidad < 0 then abs( DatosExpo.PrecioUnitario * DatosExpo.Cantidad ) else DatosExpo.PrecioUnitario end, 3, 16 ) as char(16) ) as PrecUni,
		cast( Funciones.ObtenerMontoNegativoConPadlSinComa( case when DatosExpo.Cantidad < 0 or DatosExpo.EsNotaCredito = 1 then 0 else DatosExpo.Bonificacion end, 2, 15 ) as char(15) ) as ImpoBonif,
		cast( Funciones.ObtenerMontoNegativoConPadlSinComa( case when DatosExpo.Cantidad < 0 or DatosExpo.EsNotaCredito = 0 then 0 else DatosExpo.Bonificacion end, 2, 16 ) as char(16) ) as ImpoAjuste,
		cast( Funciones.ObtenerMontoNegativoConPadlSinComa( abs( DatosExpo.Monto ), 2, 16 ) as char(16) ) as SubTotal,
		cast( Funciones.padl( DatosExpo.PorcentajeIVA, 4, '0' ) as char(4) ) as PorcIVA,
		cast( case when DatosExpo.EstaAnulado = 1 then '' else ( case when DatosExpo.PorcentajeIVAOriginal = 0 then 'N' else 'G' end ) end as char(1) ) as ExenOGrav,
		cast( case when DatosExpo.EstaAnulado = 0 then '' else 'A' end as char(1) ) as Anulado,
		cast( case when DatosExpo.EstaAnulado = 1 then '' else ( case when @UsarDescripcionGenerica = 1 and DatosExpo.DescuentoRecargo = 0 then @DescripcionGenerica else DatosExpo.DetalleArticulo end ) end as char(75) ) as DetArti
	from ( 
		select Comprobante.FFch as FechaComprobante,
			Comprobante.FPtoVen as PuntoVenta,
			Comprobante.FNumComp as NumeroComprobante,
			Comprobante.Anulado as EstaAnulado,
			Funciones.EsComprobanteNotaDeCredito( Comprobante.FactTipo ) as EsNotaCredito,
			Comprobante.FCompFis as ComprobanteFiscal,
			case when ConvVTipo.ValDest is null then ConvCTipo.ValorDef else ConvVTipo.ValDest end as TipoComprobante,
			case when ConvVUniM.ValDest is null then ConvCUniM.ValorDef else ConvVUniM.ValDest end as UnidadMedida,
			case when ConvVAlic.ValDest is null then ConvCAlic.ValorDef else ConvVAlic.ValDest end as PorcentajeIVA,
			case when DetArticulos.Codigo is null then 0 else DetArticulos.FCant end as Cantidad,
			case when DetArticulos.Codigo is null then 0 else ( case when Comprobante.FLetra = 'A' then DetArticulos.PrUnSinImp else DetArticulos.PrUnConImp end ) end as PrecioUnitario,
			case when DetArticulos.Codigo is null then 0 else ( case when Comprobante.FLetra = 'A' then DetArticulos.MnPDSI else DetArticulos.FCFiTot end + DetArticulos.MntDes ) end as Bonificacion,
			case when DetArticulos.Codigo is null then 0 else DetArticulos.FMonto end as Monto,
			case when DetArticulos.Codigo is null then 0 else DetArticulos.FPorIVA end as PorcentajeIVAOriginal,
			case when DetArticulos.Codigo is null then '' else ( case when DetArticulos.FCant < 0 then 'DESCUENTO GENERAL' else rtrim( DetArticulos.FArt ) + ' ' + DetArticulos.FTxt end ) end as DetalleArticulo,
			0 as DescuentoRecargo
		from [ZooLogic].[ComprobanteV] as Comprobante
			left join [ZooLogic].[ComprobanteVDet] as DetArticulos on Comprobante.Codigo = DetArticulos.Codigo
			left join [ZooLogic].[Art] as Articulo on DetArticulos.FArt = Articulo.ArtCod
			left join [ZooLogic].[UnMed] as UnidadMedida on Articulo.UniMed = UnidadMedida.Cod
			left join [Organizacion].[Conver] as ConvCTipo on ConvCTipo.Codigo = 'TIPOCOMPROBANTEAFIP'
			left join [Organizacion].[ConverVal] as ConvVTipo on ConvCTipo.Codigo = ConvVTipo.Conversion and ConvVTipo.ValOrig = cast( Comprobante.FactTipo as varchar(2) ) + Comprobante.FLetra
			left join [Organizacion].[Conver] as ConvCUniM on ConvCUniM.Codigo = 'UNIDADDEMEDIDA'
			left join [Organizacion].[ConverVal] as ConvVUniM on ConvCUniM.Codigo = ConvVUniM.Conversion and ConvVUniM.ValOrig = UnidadMedida.Cod
			left join [Organizacion].[Conver] as ConvCAlic on ConvCAlic.Codigo = 'AFIP ALICUOTA DE IVA'
			left join [Organizacion].[ConverVal] as ConvVAlic on ConvCAlic.Codigo = ConvVAlic.Conversion and Funciones.val( ConvVAlic.ValOrig ) = case when Comprobante.Anulado = 0 then DetArticulos.FPorIVA else 0 end
		where Comprobante.FactTipo in ( 1, 3, 4, 2, 5, 6, 27, 28, 29, 47, 48, 49, 33, 35, 36 )
			and Comprobante.FFch >= @FechaDesde and Comprobante.FFch <= @FechaHasta

		union all

		select Comprobante.FFch as FechaComprobante,
			Comprobante.FPtoVen as PuntoVenta,
			Comprobante.FNumComp as NumeroComprobante,
			Comprobante.Anulado as EstaAnulado,
			Funciones.EsComprobanteNotaDeCredito( Comprobante.FactTipo ) as EsNotaCredito,
			Comprobante.FCompFis as ComprobanteFiscal,
			case when ConvVTipo.ValDest is null then ConvCTipo.ValorDef else ConvVTipo.ValDest end as TipoComprobante,
			Interfaces.Auxiliar_AFIP3685_ObtenerUnidadMedida( Comprobante.FactTipo, Comprobante.TotRecarCI, Comprobante.TotRecar, Comprobante.TotDesc ) as UnidadMedida,
			case when ConvVAlic.ValDest is null then ConvCAlic.ValorDef else ConvVAlic.ValDest end as PorcentajeIVA,
			1 as Cantidad,
			Interfaces.Auxiliar_AFIP3685_ObtenerMontoDescuentoRecargo( Comprobante.FactTipo, Comprobante.FLetra, Comprobante.FSubTot, Comprobante.TotRecarCI, Comprobante.TotRecar, Comprobante.TotDesc, ImpuesIVA.IVAPorcent, ImpuesIVA.IVAMonNG ) as PrecioUnitario,
			0 as Bonificacion,
			Interfaces.Auxiliar_AFIP3685_ObtenerMontoDescuentoRecargo( Comprobante.FactTipo, Comprobante.FLetra, Comprobante.FSubTot, Comprobante.TotRecarCI, Comprobante.TotRecar, Comprobante.TotDesc, ImpuesIVA.IVAPorcent, ImpuesIVA.IVAMonNG ) as Monto,
			case when ImpuesIVA.Codigo is null then 0 else ImpuesIVA.IVAPorcent end as PorcentajeIVAOriginal,
			Interfaces.Auxiliar_AFIP3685_ObtenerDescripcionDescuentoRecargo( Comprobante.FactTipo, Comprobante.TotRecarCI, Comprobante.TotRecar, Comprobante.TotDesc ) as DetalleArticulo,
			1 as DescuentoRecargo
		from [ZooLogic].[ComprobanteV] as Comprobante
			inner join [ZooLogic].[ImpuestosV] as ImpuesIVA on Comprobante.Codigo = ImpuesIVA.Codigo and ( abs( ImpuesIVA.IVAMonto ) >= 0.01 or ImpuesIVA.IVAPorcent = 0 )
			left join [Organizacion].[Conver] as ConvCTipo on ConvCTipo.Codigo = 'TIPOCOMPROBANTEAFIP'
			left join [Organizacion].[ConverVal] as ConvVTipo on ConvCTipo.Codigo = ConvVTipo.Conversion and ConvVTipo.ValOrig = cast( Comprobante.FactTipo as varchar(2) ) + Comprobante.FLetra
			left join [Organizacion].[Conver] as ConvCAlic on ConvCAlic.Codigo = 'AFIP ALICUOTA DE IVA'
			left join [Organizacion].[ConverVal] as ConvVAlic on ConvCAlic.Codigo = ConvVAlic.Conversion and Funciones.val( ConvVAlic.ValOrig ) = ImpuesIVA.IVAPorcent
		where Comprobante.FactTipo in ( 1, 3, 4, 2, 5, 6, 27, 28, 29, 47, 48, 49, 33, 35, 36 )
			and Comprobante.FFch >= @FechaDesde and Comprobante.FFch <= @FechaHasta
			and Comprobante.Anulado = 0
			and ( case when Funciones.EsComprobanteConRecargoCI( Comprobante.FactTipo ) = 1 then Comprobante.TotRecarCI else Comprobante.TotRecar end ) - Comprobante.TotDesc <> 0
		) as DatosExpo
)