IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[ArmarAsientos_FacturasDeCompras]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[ArmarAsientos_FacturasDeCompras];
GO;
Create Function [Contabilidad].[ArmarAsientos_FacturasDeCompras]
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
		@tblImpdirart as Contabilidad.udt_TableType_Impdirart ReadOnly,
		@tblImpdirimp as Contabilidad.udt_TableType_Impdirimp ReadOnly,
		@tblPlanCuenta as Contabilidad.udt_TableType_PlanCuenta ReadOnly,
		@tblDDCCosto as Contabilidad.udt_TableType_DDCCosto ReadOnly,
		@tblImpdircca as Contabilidad.udt_TableType_Impdircca ReadOnly,
		@tblTipoFcCompra as Contabilidad.udt_TableType_TipoFcCompra ReadOnly
	)
RETURNS TABLE
AS
RETURN
(
	select 
		asietipo.codigo as CodigoAsientoTipo,
		convert(date,cab.ffch) as FechaAsiento, 
		'FC' as TipoComp,
		cab.fletra as LetraComp,
		convert(char(150), 'Compras - FC ' + cab.fletra + ' ' + right( replicate( '0', 4 ) + ltrim(str( cab.fptoven )), 4 ) + '-' + right( replicate( '0', 8 ) + ltrim(str( cab.fnumcomp )), 8 ) 
			+ case when tipoComprRG1361.descr = '' then '' else ' [' + tipoComprRG1361.descr + ']' end
			+ '  [' + cab.fperson + ' - ' + isnull(prov.clnom,'') + ']' ) as Referencia,
		cab.codigo,
		case when asietipo.CodConc = 'COMPRAS' and detCompras.CuentaDebe is not null then detCompras.CuentaDebe
			 when asietipo.CodConc = 'IMPUESTOS' and imp.CuentaDebe is not null then imp.CuentaDebe
			 when asietipo.CodConc = 'VALORESENTREG' and val.CuentaDebe is not null then val.CuentaDebe
			 else asietipo.cuentade
			end CuentaDebe,
		case when asietipo.CodConc = 'COMPRAS' and detCompras.CuentaHaber is not null then detCompras.CuentaHaber
			 when asietipo.CodConc = 'IMPUESTOS' and imp.CuentaHaber is not null then imp.CuentaHaber
			 when asietipo.CodConc = 'VALORESENTREG' and val.CuentaHaber is not null then val.CuentaHaber
			 else asietipo.cuentaha
			end CuentaHaber,
		case when asietipo.CodConc = 'COMPRAS' and detCompras.CCosto is not null and PlanCuenta.ReqCCosto = 1 then detCompras.CCosto
			 else ''
			end CentroDeCostos,
		case when asietipo.CodConc = 'COMPRAS' and detCompras.Monto is not null then detCompras.Monto * cab.cotiz
			 when asietipo.CodConc = 'RECARGOTOTAL' then ( cab.recmntosi + cab.recmntosi2 ) * cab.cotiz
			 when asietipo.CodConc = 'IVACREDITO' then cab.fimpuesto * cab.cotiz
			 when asietipo.CodConc = 'IMPUESTOS' and imp.Monto is not null then imp.Monto * cab.cotiz
			 when asietipo.CodConc = 'VALORESENTREG' and val.Monto is not null then val.Monto * cab.cotiz
			 when asietipo.CodConc = 'IVADEBITO' then 0
			 when asietipo.CodConc = 'DESCLINEA' and detDesc.Monto is not null then detDesc.Monto * cab.cotiz
			 when asietipo.CodConc = 'DESCTOTAL' then ( cab.desmntosi3 + cab.desmntosi ) * cab.cotiz
			else 0 end  as Monto
	 from ZooLogic.FACCOMPRA cab
	  cross join ( select codigo, codconc, cuentade, cuentaha from @tblAtipodet where codigo = 'FAC.COMPRA' ) asietipo
	  left join zoologic.prov on cab.fperson = prov.clcod
	  left join ( select det.codigo,
						SUM( det.MNDESSI + det.MNPDSI ) as Monto
						from ZooLogic.FACCOMPRADET det
						group by det.codigo
						) detDesc on cab.codigo = detDesc.codigo
	  left join ( select det.codigo, impdir.cuentaDebe, impdir.cuentaHaber,
						case when det.ccosto <> '' then det.ccosto
							 when dcc.codccos <> '' then dcc.codccos
							 else '' end ccosto,
							sum( det.PrunSinImp * ( case when ( det.ccosto <> '' or det.dccosto = '' ) then 1 else ( dcc.porcenta / 100 ) end ) * det.fcant ) as Monto
						from ( select d.codigo, d.fart, d.PrunSinImp, d.fcant,
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
								from ZooLogic.FACCOMPRADET d
								 inner join ZooLogic.FACCOMPRA c on d.codigo = c.codigo
								 left join Contabilidad.ObtenerImputacionesParaCentrosDeCostosPorArticulo( @tblImpdircca, 2 ) as impdir on d.fart = impdir.Cod
							 ) det

						 left join Contabilidad.ObtenerImputacionesContablesPorArticulo( @tblAtipodet, @tblImpdirart, @tblBasesAgrup, 'FAC.COMPRA', 'COMPRAS', 2, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual ) as impdir on det.fart = impdir.Cod
						 left join @tblDDCCosto dcc on det.dccosto = dcc.Codigo
						group by det.codigo, impdir.cuentaDebe, impdir.cuentaHaber, 
							case when det.ccosto <> '' then det.ccosto
								when dcc.codccos <> '' then dcc.codccos
								else '' end
						) detCompras on cab.codigo = detCompras.codigo and asietipo.CodConc = 'COMPRAS'
	  left join @tblPlanCuenta PlanCuenta on case when detCompras.CuentaDebe = '' then detCompras.CuentaHaber else detCompras.CuentaDebe end = PlanCuenta.CtaCodigo
	  left join ( select val.jjnum, 
					case when impdir.cuentaDebe = '' then '' else case when impdirProv.PCuenta is null then impdir.cuentaDebe else impdirProv.PCuenta end end cuentaDebe, 
					case when impdir.cuentaHaber = '' then '' else case when impdirProv.PCuenta is null then impdir.cuentaHaber else impdirProv.PCuenta end end cuentaHaber, 
					sum( val.pesos ) as Monto
				  from ZooLogic.VALFACCOMP val
					inner join ZooLogic.FACCOMPRA c on val.JJNUM = c.codigo
					left join Contabilidad.ObtenerImputacionesContablesPorValor( @tblAtipodet, @tblImpdirval, @tblBasesAgrup, 'FAC.COMPRA', 'VALORESENTREG', 2, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual ) as impdir on val.jjco = impdir.Cod
					left join Contabilidad.ObtenerImputacionesContablesPorValorPorProveedor( @tblImpdirpro, @tblBasesAgrup, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual ) as impdirProv
																							  on impdir.NumeroImpValor = impdirProv.NumeroImpValor 
																							 and c.fperson = impdirProv.Cod
				  group by val.jjnum, impdir.cuentaDebe, impdir.cuentaHaber, impdirProv.PCuenta 
				 ) val on cab.codigo = val.JJNUM and asietipo.CodConc = 'VALORESENTREG'
	  left join ( select imp.ccod, 
					case when impdir.cuentaDebe = '' then '' else impdir.cuentaDebe end cuentaDebe, 
					case when impdir.cuentaHaber = '' then '' else impdir.cuentaHaber end cuentaHaber, 
				   sum( imp.monto ) as Monto
				  from ZooLogic.IMPFACC imp 
					 left join Contabilidad.ObtenerImputacionesContablesPorImpuesto( @tblAtipodet, @tblImpdirimp, @tblBasesAgrup, 'FAC.COMPRA', 'IMPUESTOS', 2, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual ) as impdir on imp.codimp = impdir.Cod
				  group by imp.ccod, impdir.cuentaDebe, impdir.cuentaHaber
				 ) imp on cab.codigo = imp.ccod and asietipo.CodConc = 'IMPUESTOS'
	  inner join @tblTipoFcCompra as tipoComprRG1361 on cab.tcrg1361 = tipoComprRG1361.tcrg1361
	  where cab.ffch between @FechaDesde and @FechaHasta
		and cab.facttipo = 8
		and cab.ANULADO = 0
)
