IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[ArmarAsientos_OtrosPagos]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[ArmarAsientos_OtrosPagos];
GO;
Create Function [Contabilidad].[ArmarAsientos_OtrosPagos]
	(
		@FechaDesde as DateTime, 
		@FechaHasta as DateTime, 
		@BaseDeDatosActual char(8), 
		@SucursalActual char(10), 
		@TipoSucursalActual char(10),
		@tblBasesAgrup as Contabilidad.udt_TableType_BasesAgrup ReadOnly,
		@tblAtipodet as Contabilidad.udt_TableType_Atipodet ReadOnly, 
		@tblImpdirval as Contabilidad.udt_TableType_Impdirval ReadOnly,
		@tblImpdirpro as Contabilidad.udt_TableType_Impdirpro ReadOnly,
		@tblImpdircon as Contabilidad.udt_TableType_Impdircon ReadOnly,
		@tblPlanCuenta as Contabilidad.udt_TableType_PlanCuenta ReadOnly,
		@tblDDCCosto as Contabilidad.udt_TableType_DDCCosto ReadOnly,
		@tblImpdirccc as Contabilidad.udt_TableType_Impdirccc ReadOnly
	)
RETURNS TABLE
AS
RETURN
(
	select 
		asietipo.codigo as CodigoAsientoTipo,
		convert(date,cab.ffch) as FechaAsiento, 
		'' as TipoComp,
		'' as LetraComp,
		convert(char(150),'Otros pagos ' + convert(varchar(10),cab.numero) + ' - ' + cab.fperson + ' ' + isnull(prov.clnom,'') + ' ' + isnull(cab.fnumcomp,'') ) as Referencia,
		cab.codigo,
		case when asietipo.CodConc = 'OTROSPAGOS' and det.CuentaDebe is not null then det.CuentaDebe
			 when asietipo.CodConc = 'VALORESENTREG' and val.CuentaDebe is not null then val.CuentaDebe
			 else asietipo.cuentade
			 end CuentaDebe,
		case when asietipo.CodConc = 'OTROSPAGOS' and det.CuentaHaber is not null then det.CuentaHaber
			 when asietipo.CodConc = 'VALORESENTREG' and val.CuentaHaber is not null then val.CuentaHaber
			 else asietipo.cuentaha
			 end CuentaHaber,
		case when asietipo.CodConc = 'OTROSPAGOS' and det.CCosto is not null and PlanCuenta.ReqCCosto = 1 then det.CCosto
			 else ''
			end CentroDeCostos,
		case when asietipo.CodConc = 'OTROSPAGOS' then det.Monto * cab.cotiz
			 when asietipo.CodConc = 'VALORESENTREG' then val.Monto * cab.cotiz
			 else 0 
			 end  as Monto
	 from zoologic.COMPPAGO cab
	  cross join ( select codigo, codconc, cuentade, cuentaha from @tblAtipodet where codigo = 'OTROS.PAGO' ) asietipo
	  left join zoologic.prov on cab.fperson = prov.clcod
	  left join ( select SubDet.codigo, impdir.cuentaDebe, impdir.cuentaHaber,
						case when SubDet.ccosto <> '' then SubDet.ccosto
							 when dcc.codccos <> '' then dcc.codccos
							 else '' end ccosto,
							sum( SubDet.fmonto * ( case when ( SubDet.ccosto <> '' or SubDet.dccosto = '' ) then 1 else ( dcc.porcenta / 100 ) end ) ) as Monto
						from ( select d.codigo, d.fconc, d.fmonto,
									case when ( d.ccosto = '' and d.dccosto = '' )
											then case when ( c.ccosto = '' and c.disccos = '' )
													then impdir.CentroDeCosto
													else c.ccosto
													end
										else d.ccosto
										end ccosto,
									case when ( d.ccosto = '' and d.dccosto = '' )
											then case when ( c.ccosto = '' and c.disccos = '' )
													then impdir.DistribucionPorCentroDeCosto
													else c.disccos
													end
										else d.dccosto
										end dccosto
								from ZooLogic.COMPPAGODET d
								 inner join ZooLogic.COMPPAGO c on d.codigo = c.codigo
								 left join Contabilidad.ObtenerImputacionesParaCentrosDeCostosPorConceptoPago( @tblImpdirccc ) as impdir on d.fconc = impdir.Cod
							 ) SubDet
						 left join Contabilidad.ObtenerImputacionesContablesPorConceptoPago( @tblAtipodet, @tblImpdircon, @tblBasesAgrup, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual ) as impdir on SubDet.fconc = impdir.Cod
						 left join @tblDDCCosto dcc on SubDet.dccosto = dcc.Codigo
						group by SubDet.codigo, impdir.cuentaDebe, impdir.cuentaHaber, 
							case when SubDet.ccosto <> '' then SubDet.ccosto
								when dcc.codccos <> '' then dcc.codccos
								else '' end
						) det on cab.codigo = det.codigo and asietipo.CodConc = 'OTROSPAGOS'
	  left join @tblPlanCuenta PlanCuenta on case when det.CuentaDebe = '' then det.CuentaHaber else det.CuentaDebe end = PlanCuenta.CtaCodigo
	  left join ( select val.jjnum, 
					case when impdir.cuentaDebe = '' then '' else case when impdirProv.PCuenta is null then impdir.cuentaDebe else impdirProv.PCuenta end end cuentaDebe, 
					case when impdir.cuentaHaber = '' then '' else case when impdirProv.PCuenta is null then impdir.cuentaHaber else impdirProv.PCuenta end end cuentaHaber, 
					sum( val.pesos ) as Monto
				  from ZooLogic.VALCOMPPAGO val
					inner join ZooLogic.COMPPAGO c on val.JJNUM = c.codigo
					left join Contabilidad.ObtenerImputacionesContablesPorValor( @tblAtipodet, @tblImpdirval, @tblBasesAgrup, 'OTROS.PAGO', 'VALORESENTREG', 2, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual ) as impdir on val.jjco = impdir.Cod
					left join Contabilidad.ObtenerImputacionesContablesPorValorPorProveedor( @tblImpdirpro, @tblBasesAgrup, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual ) as impdirProv
																							  on impdir.NumeroImpValor = impdirProv.NumeroImpValor 
																							 and c.fperson = impdirProv.Cod
				  group by val.jjnum, impdir.cuentaDebe, impdir.cuentaHaber, impdirProv.PCuenta 
				 ) val on cab.codigo = val.JJNUM and asietipo.CodConc = 'VALORESENTREG'
	-- esta subconsulta obtiene primero la cuenta a imputar para cada valor (según imputación directa por valores y teniendo en cuenta la importancia en caso de repetirse,
	-- y luego se fija si por cada una de las imputaciones directas por Valor hay alguna que sea específica para el proveedor del comprobante 

	where cab.ffch between @FechaDesde and @FechaHasta
)

