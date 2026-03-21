IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Interfaz_AFIPRG4597_ComprasAlicuotasImportaciones]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Interfaz_AFIPRG4597_ComprasAlicuotasImportaciones];
GO;

CREATE FUNCTION [Interfaces].[Interfaz_AFIPRG4597_ComprasAlicuotasImportaciones]
( 
@FechaDesde varchar(10),
	@FechaHasta varchar(10),
	@FechaEmisionDesde varchar(10),
	@FechaEmisionHasta varchar(10),
	@PtVtaDesde int,
	@PtVtaHasta int,
	@CompFiscal bit,
	@CompManual bit,
	@CompElectr bit,
	@CompDespacho bit,
	@CompLiqA bit,
	@CompLiqB bit,
	@CompServPubA bit,
	@CompServPubB bit,
	@CompReciboA bit,
	@CompReciboC bit,
	@ProrratearCreditoFiscalComputable varchar(1)
)
RETURNS TABLE
AS
RETURN
(
	select 
		cast( DatosExpo.DespachoImportacion as char(16) ) as DespImpo,
		cast( Funciones.ObtenerMontoNegativoConPadlSinComa( DatosExpo.MontoNoGravadoIVA, 2, 15 ) as char(15) ) as MontoNGIVA,
		cast( Funciones.padl( DatosExpo.PorcentajeIVA, 4, '0' ) as char(4) ) as PorcIVA,
		cast( Funciones.ObtenerMontoNegativoConPadlSinComa( DatosExpo.MontoIVA, 2, 15 ) as char(15) ) as MontoIVA,
		DatosExpo.FechaComp
	from (
		select 
			case when Comprobante.TcRG1361 = 4 then ( SUBSTRING( TipoComp.AnoDespa, 3,2 ) + Funciones.padl( Funciones.AllTrim ( TipoComp.CodAduana ), 3, '0' ) + TipoComp.TipoDestin + Funciones.padl( Funciones.AllTrim ( TipoComp.nroDespa ), 6, '0' ) + TipoComp.DigVerif ) else '' end as DespachoImportacion,
		    case when Alicuotas.IVAPorcent = 0 or Comprobante.TcRG1361 = 5 then 0 else Alicuotas.IVAMonNG end as MontoNoGravadoIVA,
			case when Alicuotas.IVAPorcent is not null then Alicuotas.IVAPorcent else 0 end as PorcentajeIVAOriginal,			
			case when ConvVAlic.ValDest is null then ConvCAlic.ValorDef else ConvVAlic.ValDest end as PorcentajeIVA,
			case when ImpuesIVA.CantidadAlicuotas is not null then ImpuesIVA.CantidadAlicuotas - ImpuesIVA.CantidadAlicuotasEn0 else 0 end as CantidadAlicuotas,
			case when Alicuotas.IVAMonto is not null then Alicuotas.IVAMonto else 0 end as MontoIVA,
			comprobante.FFCH as FechaComp
				
		from (
				select Codigo, FFch, FFCHFAC, FPtoVen, FactTipo, FLetra, FNumComp, FPerson, TCRG1361, Anulado, FPtoVenExt
				from [ZooLogic].[FacCompra]
				union all
				select Codigo, FFch, FFCHFAC, FPtoVen, FactTipo, FLetra, FNumComp, FPerson, TCRG1361, Anulado, FPtoVenExt
				from [ZooLogic].[NCCompra]
				union all
				select Codigo, FFch, FFCHFAC, FPtoVen, FactTipo, FLetra, FNumComp, FPerson, TCRG1361, Anulado, FPtoVenExt
				from [ZooLogic].[NDCompra]
			) as Comprobante
			left join (
				select ImpuesIVA.Codigo as Codigo,
					count( distinct ImpuesIVA.IVAPorcent ) as CantidadAlicuotas,
					sum( case when ImpuesIVA.IVAPorcent > 0 and ImpuesIVA.IVAMonto < 0.01 then 1 else 0 end ) as CantidadAlicuotasEn0
				from (
					select Codigo, IVAPorcent, IVAMonNG, IVAMonto
					from [ZooLogic].[ImpFacComp]
					union all
					select Codigo, IVAPorcent, IVAMonNG, IVAMonto
					from [ZooLogic].[ImpNCComp]
					union all
					select Codigo, IVAPorcent, IVAMonNG, IVAMonto
					from [ZooLogic].[ImpNDComp]
					) as ImpuesIVA
				group by ImpuesIVA.Codigo
				) as ImpuesIVA on Comprobante.Codigo = ImpuesIVA.Codigo
			left join (
				select Codigo, IVAPorcent, IVAMonNG, IVAMonto
				from [ZooLogic].[ImpFacComp]
				union all
				select Codigo, IVAPorcent, IVAMonNG, IVAMonto
				from [ZooLogic].[ImpNCComp]
				union all
				select Codigo, IVAPorcent, IVAMonNG, IVAMonto
				from [ZooLogic].[ImpNDComp]
			) as Alicuotas on Comprobante.Codigo = Alicuotas.Codigo
			left join [Organizacion].[Conver] as ConvCAlic on ConvCAlic.Codigo = 'AFIP ALICUOTA DE IVA'
			left join [Organizacion].[ConverVal] as ConvVAlic on ConvCAlic.Codigo = ConvVAlic.Conversion and Funciones.val( ConvVAlic.ValOrig ) = Alicuotas.IVAPorcent
			left join [ZooLogic].[TipocompCom] as TipoComp on Comprobante.Codigo = TipoComp.CodigoCor
		where Comprobante.FactTipo in ( 8, 9, 10 ) and
			 case 
				when @CompDespacho = 1 and Comprobante.TCRG1361 = 4 then 1
				else 0
			  end = 1
			  and Comprobante.Anulado <> 1
			  and Comprobante.FLetra not in ( 'B', 'C' )
			  and ( ( @FechaDesde is null ) or ( Comprobante.FFch >= @FechaDesde ) ) 
			  and ( ( @FechaHasta is null ) or ( Comprobante.FFch <= @FechaHasta ) )
			  and ( ( @FechaEmisionDesde is null ) or ( Comprobante.FFCHFAC >= @FechaEmisionDesde ) ) 
              and ( ( @FechaEmisionHasta is null ) or ( Comprobante.FFCHFAC <= @FechaEmisionHasta ) )
			  and ( ( @PtVtaDesde is null ) or ( Comprobante.FPTOVEN >= @PtVtaDesde ) ) 
			  and ( ( @PtVtaHasta is null ) or ( Comprobante.FPTOVEN <= @PtVtaHasta ) )
		) as DatosExpo
	where DatosExpo.CantidadAlicuotas > 0
		and ( ( DatosExpo.PorcentajeIVAOriginal > 0 and DatosExpo.MontoIVA >= 0.01 ) or DatosExpo.PorcentajeIVAOriginal = 0 )
)	