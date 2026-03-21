IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Errores_AFIP3685_ComprasComprobantes]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Errores_AFIP3685_ComprasComprobantes];
GO;

CREATE FUNCTION [Interfaces].[Errores_AFIP3685_ComprasComprobantes]
( 
	@FechaDesde varchar(10),
	@FechaHasta varchar(10) 
)
RETURNS TABLE
AS
RETURN
(
	select distinct case when DatosExpo.ConversionTipoComprobante is null then cast( DatosExpo.TipoComprobante as varchar(2) ) + DatosExpo.TicketOManual + DatosExpo.LetraComprobante else null end as TipoComprobante,
		case when DatosExpo.ConversionTipoDocumento = '' then DatosExpo.TipoDocumento else null end as TipoDocumento,
		case when DatosExpo.ConversionMoneda is null then DatosExpo.Moneda else null end as Moneda
	from ( 
		select Comprobante.FactTipo as TipoComprobante,
			case when Comprobante.TCRG1361 = 3 then 'T' else 'M' end as TicketOManual,
			cast( Comprobante.FLetra as char(1) ) as LetraComprobante,
			Proveedor.ClTipoDoc as TipoDocumento,
			ConvVTipo.ValDest as ConversionTipoComprobante,
			ConvVMone.ValDest as ConversionMoneda,
			Interfaces.Auxiliar_AFIP3685_ObtenerTipoDocumentoProveedor( Comprobante.FCUIT, Proveedor.ClCUIT, Proveedor.ClNroDoc, case when ConvVDocu.ValDest is null then ConvCDocu.ValorDef else ConvVDocu.ValDest end ) as ConversionTipoDocumento,
			Comprobante.Moneda as Moneda,
			case when ImpuesIVA.CantidadAlicuotas is not null then ImpuesIVA.CantidadAlicuotas - ImpuesIVA.CantidadAlicuotasEn0 else 0 end as CantidadAlicuotas
		from (
				select Codigo, FFch, FPtoVen, FactTipo, FLetra, FNumComp, FTotal, Cotiz, FPerson, FCUIT, Anulado, Moneda, TCRG1361
				from [ZooLogic].[FacCompra]
				union all
				select Codigo, FFch, FPtoVen, FactTipo, FLetra, FNumComp, FTotal, Cotiz, FPerson, FCUIT, Anulado, Moneda, TCRG1361
				from [ZooLogic].[NCCompra]
				union all
				select Codigo, FFch, FPtoVen, FactTipo, FLetra, FNumComp, FTotal, Cotiz, FPerson, FCUIT, Anulado, Moneda, TCRG1361
				from [ZooLogic].[NDCompra]
				) as Comprobante
			left join [ZooLogic].[Prov] as Proveedor on Comprobante.FPerson = Proveedor.ClCod
			left join (
				select ImpuesIVA.Codigo as Codigo,
					sum( case when ImpuesIVA.IVAPorcent = 0 then ImpuesIVA.IVAMonNG else 0 end ) as IVAMonNG,
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
				select ImpCompras.CCod,
					sum( case when ImpCompras.Tipo = 'IVA' and ImpCompras.Aplicacion = 'PRC' then ImpCompras.Monto else 0 end ) as PercepcionesIVA,
					sum( case when ImpCompras.Tipo = 'GANANCIAS' and ImpCompras.Aplicacion = 'PRC' then ImpCompras.Monto else 0 end ) as PercepcionesNacionales,
					sum( case when ImpCompras.Tipo = 'IIBB' and ImpCompras.Aplicacion = 'PRC' then ImpCompras.Monto else 0 end ) as PercepcionesIIBB,
					sum( case when ImpCompras.Tipo = 'IMPINTERNO' then ImpCompras.Monto else 0 end ) as PercepcionesInternos,			
					sum( case when not (( ImpCompras.Aplicacion = 'PRC' and ImpCompras.Tipo in ( 'IVA', 'GANANCIAS', 'IIBB' )) or ImpCompras.Tipo = 'IMPINTERNO') then ImpCompras.Monto else 0 end ) as OtrosTributos
				from (
					select ImpCompras.CCod as CCod,
						ImpCompras.CodImp as CodImp,
						ImpCompras.Monto as Monto,
						Impuestos.Tipo as Tipo,
						Impuestos.Aplicacion as Aplicacion
					from [ZooLogic].[ImpFacC] as ImpCompras
						left join [ZooLogic].[Impuesto] as Impuestos on ImpCompras.CodImp = Impuestos.Codigo
					union all
					select ImpCompras.CCod as CCod,
						ImpCompras.CodImp as CodImp,
						ImpCompras.Monto as Monto,
						Impuestos.Tipo as Tipo,
						Impuestos.Aplicacion as Aplicacion
					from [ZooLogic].[ImpNCC] as ImpCompras
						left join [ZooLogic].[Impuesto] as Impuestos on ImpCompras.CodImp = Impuestos.Codigo
					union all
					select ImpCompras.CCod as CCod,
						ImpCompras.CodImp as CodImp,
						ImpCompras.Monto as Monto,
						Impuestos.Tipo as Tipo,
						Impuestos.Aplicacion as Aplicacion
					from [ZooLogic].[ImpNDC] as ImpCompras
						left join [ZooLogic].[Impuesto] as Impuestos on ImpCompras.CodImp = Impuestos.Codigo
					) as ImpCompras
				group by ImpCompras.CCod
				) as ImpCompras on Comprobante.Codigo = ImpCompras.CCod
			left join [Organizacion].[Conver] as ConvCTipo on ConvCTipo.Codigo = 'TIPOCOMPROBANTEAFIP'
			left join [Organizacion].[ConverVal] as ConvVTipo on ConvCTipo.Codigo = ConvVTipo.Conversion and ConvVTipo.ValOrig = cast( Comprobante.FactTipo as varchar(2) ) + case when Comprobante.TCRG1361 = 3 then 'T' else 'M' end + Comprobante.FLetra
			left join [Organizacion].[Conver] as ConvCDocu on ConvCDocu.Codigo = 'CODIGODOCUMENTO'
			left join [Organizacion].[ConverVal] as ConvVDocu on ConvCDocu.Codigo = ConvVDocu.Conversion and ConvVDocu.ValOrig = Proveedor.ClTipoDoc
			left join [Organizacion].[Conver] as ConvCMone on ConvCMone.Codigo = 'MONEDAAFIP'
			left join [Organizacion].[ConverVal] as ConvVMone on ConvCMone.Codigo = ConvVMone.Conversion and ConvVMone.ValOrig = Comprobante.Moneda
		where Comprobante.FactTipo in ( 8, 9, 10 )
			and Comprobante.Anulado = 0
			and Comprobante.FFch >= @FechaDesde and Comprobante.FFch <= @FechaHasta

	union all
		select	99 as TipoComprobante,
			'' as TicketOManual,
			'A' as LetraComprobante,
			'' as TipoDocumento,
			'' as ConversionTipoComprobante,
			DatosLiquidacion.ConversionMoneda as ConversionMoneda,
			'80' as ConversionTipoDocumento,
			DatosLiquidacion.Moneda as Moneda,
			DatosLiquidacion.CantidadAlicuotas as CantidadAlicuotas
			
			from (

				select Liquidacion.FechaLiq as FechaComprobante,
					Liquidacion.PtoVenta as PuntoVenta,
					Liquidacion.NroLiq as NumeroComprobante,   
					case when Proveedor.ClCUIT  is null then '' else Proveedor.ClCUIT end as NumeroDocumento,
					case when Proveedor.ClNom  is null then '' else Proveedor.ClNom end as NombreProveedor,
					case when ConvVMone.ValDest is null then ConvCMone.ValorDef else ConvVMone.ValDest end as Moneda,
					case when ImpuesIVA.IVAMonNG is not null then ImpuesIVA.IVAMonNG else 0 end as NetoNoGravado,
					case when ImpCompras.PercepcionesIVA is not null then ImpCompras.PercepcionesIVA else 0 end as PercepcionesIVA,
					case when ImpCompras.PercepcionesNacionales is not null then ImpCompras.PercepcionesNacionales else 0 end as PercepcionesNacionales,
					case when ImpCompras.PercepcionesIIBB is not null then ImpCompras.PercepcionesIIBB else 0 end as PercepcionesIIBB,
					case when ImpCompras.PercepcionesInternos is not null then ImpCompras.PercepcionesInternos else 0 end as PercepcionesInternos,
					case when ImpCompras.OtrosTributos is not null then ImpCompras.OtrosTributos else 0 end as OtrosTributos,
					case when ImpuesIVA.CantidadAlicuotas is not null then ImpuesIVA.CantidadAlicuotas - ImpuesIVA.CantidadAlicuotasEn0 else 0 end as CantidadAlicuotas,
					0 as OperacionesExentas,
					0 as PercepcionesMunicipales,
					case when ImpuesIVA.IVANetoGravado is not null then ImpuesIVA.IVANetoGravado else 0 end as IVANetoGravado,
					case when ImpuesIVA.IVAMonto is not null then ImpuesIVA.IVAMonto else 0 end as IVAMonto,
					ConvVMone.ValDest as ConversionMoneda
				from [ZooLogic].[LiqMensual] as Liquidacion
					left join [ZooLogic].[OPETAR] as Operadora on Liquidacion.Operadora = Operadora.Codigo
					left join [ZooLogic].[Prov] as Proveedor on Operadora.Proveedor = Proveedor.CLCOD
					left join (
						select ImpuesIVA.Codigo as Codigo,
							sum( case when ImpuesIVA.IVAPorcent = 0 then ImpuesIVA.IVAMonNG else 0 end ) as IVAMonNG,
							sum( case when ImpuesIVA.IVAPorcent <> 0 then ImpuesIVA.IVAMonNG else 0 end ) as IVANetoGravado,
							sum( case when ImpuesIVA.IVAPorcent <> 0 then ImpuesIVA.IVAMonto else 0 end ) as IVAMonto,
							count( distinct ImpuesIVA.IVAPorcent ) as CantidadAlicuotas,
							sum( case when ImpuesIVA.IVAPorcent > 0 and ImpuesIVA.IVAMonto < 0.01 then 1 else 0 end ) as CantidadAlicuotasEn0
						from [ZooLogic].[ImpLiqMen] as ImpuesIVA
						group by ImpuesIVA.Codigo
						) as ImpuesIVA on Liquidacion.Codigo = ImpuesIVA.Codigo
		
					left join (
						select ImpCompras.CCod,
							sum( case when ImpCompras.Tipo = 'IVA' and ImpCompras.Aplicacion = 'PRC' then ImpCompras.Monto else 0 end ) as PercepcionesIVA,
							sum( case when ImpCompras.Tipo = 'GANANCIAS' and ImpCompras.Aplicacion = 'PRC' then ImpCompras.Monto else 0 end ) as PercepcionesNacionales,
							sum( case when ImpCompras.Tipo = 'IIBB' and ImpCompras.Aplicacion = 'PRC' then ImpCompras.Monto else 0 end ) as PercepcionesIIBB,
							sum( case when ImpCompras.Tipo = 'IMPINTERNO' then ImpCompras.Monto else 0 end ) as PercepcionesInternos,
							sum( case when not (( ImpCompras.Aplicacion = 'PRC' and ImpCompras.Tipo in ( 'IVA', 'GANANCIAS', 'IIBB' )) or ImpCompras.Tipo = 'IMPINTERNO') then ImpCompras.Monto else 0 end ) as OtrosTributos
						from (
							select ImpCompras.CCod as CCod,
								ImpCompras.Monto as Monto,
								Impuestos.Tipo as Tipo,
								Impuestos.Aplicacion as Aplicacion
							from [ZooLogic].[ImpLiqMenCom] as ImpCompras
								left join [ZooLogic].[Impuesto] as Impuestos on ImpCompras.CodImp = Impuestos.Codigo
							) as ImpCompras
						group by ImpCompras.CCod
						) as ImpCompras on Liquidacion.Codigo = ImpCompras.CCod
					left join [Organizacion].[Conver] as ConvCMone on ConvCMone.Codigo = 'MONEDAAFIP'
					left join [Organizacion].[ConverVal] as ConvVMone on ConvCMone.Codigo = ConvVMone.Conversion and ConvVMone.ValOrig = 'PESOS'
				where  Liquidacion.FechaLiq >= @FechaDesde and Liquidacion.FechaLiq <= @FechaHasta
				) as DatosLiquidacion

		) as DatosExpo
	where DatosExpo.CantidadAlicuotas > 0
		and ( DatosExpo.ConversionTipoComprobante is null
			or DatosExpo.ConversionMoneda is null 
			or DatosExpo.ConversionTipoDocumento = '' )
)