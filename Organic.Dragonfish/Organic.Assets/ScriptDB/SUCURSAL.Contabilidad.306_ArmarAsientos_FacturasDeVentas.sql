IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[ArmarAsientos_FacturasDeVentas]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[ArmarAsientos_FacturasDeVentas];
GO;
Create Function [Contabilidad].[ArmarAsientos_FacturasDeVentas]
	(
		@FechaDesde as DateTime, 
		@FechaHasta as DateTime, 
		@BaseDeDatosActual char(8), 
		@SucursalActual char(10), 
		@TipoSucursalActual char(10),
		@tblBasesAgrup as Contabilidad.udt_TableType_BasesAgrup ReadOnly,
		@tblAtipodet as Contabilidad.udt_TableType_Atipodet ReadOnly,
		@tblImpdirval as Contabilidad.udt_TableType_Impdirval ReadOnly,
		@tblImpdircli as Contabilidad.udt_TableType_Impdircli ReadOnly,
		@tblImpdirart as Contabilidad.udt_TableType_Impdirart ReadOnly,
		@tblImpdirimp as Contabilidad.udt_TableType_Impdirimp ReadOnly,
		@tblTipoComp as Contabilidad.udt_TableType_TipoComp ReadOnly
	)
RETURNS TABLE
AS
RETURN
(
	select 
		asietipo.codigo as CodigoAsientoTipo,
		convert(date,cab.ffch) as FechaAsiento, 
		case when ( cab.facttipo = 1 or cab.facttipo = 2 or cab.facttipo = 27 or cab.facttipo = 54) then 'FC'
			 when ( cab.facttipo = 3 or cab.facttipo = 5 or cab.facttipo = 28 or cab.facttipo = 55) then 'NC'
			 when ( cab.facttipo = 4 or cab.facttipo = 6 or cab.facttipo = 29 or cab.facttipo = 56) then 'ND'
			 else ''
			end as TipoComp,
		cab.fletra as LetraComp,
		convert(char(150), 'Ventas - '
							+ case when ( cab.facttipo = 1 or cab.facttipo = 2 or cab.facttipo = 27 or cab.facttipo = 54 ) then 'FC'
								 when ( cab.facttipo = 3 or cab.facttipo = 5 or cab.facttipo = 28 or cab.facttipo = 55 ) then 'NC'
								 when ( cab.facttipo = 4 or cab.facttipo = 6 or cab.facttipo = 29 or cab.facttipo = 56 ) then 'ND'
								 else ''
								end
							+ ' ' + cab.fletra 
							+ ' ' + right( replicate( '0', 4 ) + ltrim(str( cab.fptoven )), 4 ) 
							+ '-' + right( replicate( '0', 8 ) + ltrim(str( cab.fnumcomp )), 8 ) 
							+ '  [' + cab.fperson + ' - ' + cab.fcliente + ']' ) as Referencia,
		cab.codigo,
		case when ( cab.signomov = 1 or ( cab.signomov = (-1) and asietipo.CodConc = 'IVACREDITO' ) /*and asietipo.CodConc <> 'VUELTOS'*/ ) -- Invierte cuentas para NCs
			then 
				case when asietipo.CodConc = 'VENTAS' and detVentas.CuentaDebe is not null then detVentas.CuentaDebe
					 when asietipo.CodConc = 'VALORESRECIB' and val.CuentaDebe is not null then val.CuentaDebe
					 when ( asietipo.CodConc = 'PERCEPIVA' or asietipo.CodConc = 'PERCEPGAN' or asietipo.CodConc = 'PERCEPIIBB' ) and imp.CuentaDebe is not null then imp.CuentaDebe
					 else asietipo.cuentade
				end
			else
				case when asietipo.CodConc = 'VENTAS' and detVentas.CuentaHaber is not null then detVentas.CuentaHaber
					 when asietipo.CodConc = 'VALORESRECIB' and val.CuentaHaber is not null then val.CuentaHaber
					 when ( asietipo.CodConc = 'PERCEPIVA' or asietipo.CodConc = 'PERCEPGAN' or asietipo.CodConc = 'PERCEPIIBB' ) and imp.CuentaHaber is not null then imp.CuentaHaber
					 else asietipo.cuentaha
				end
			end CuentaDebe,
		case when ( cab.signomov = 1 or ( cab.signomov = (-1) and asietipo.CodConc = 'IVACREDITO' ) /*and asietipo.CodConc <> 'VUELTOS'*/ ) -- Invierte cuentas para NCs
			then 
				case when asietipo.CodConc = 'VENTAS' and detVentas.CuentaHaber is not null then detVentas.CuentaHaber
					 when asietipo.CodConc = 'VALORESRECIB' and val.CuentaHaber is not null then val.CuentaHaber
					 when ( asietipo.CodConc = 'PERCEPIVA' or asietipo.CodConc = 'PERCEPGAN' or asietipo.CodConc = 'PERCEPIIBB' ) and imp.CuentaHaber is not null then imp.CuentaHaber
					 else asietipo.cuentaha
				end
			else
				case when asietipo.CodConc = 'VENTAS' and detVentas.CuentaDebe is not null then detVentas.CuentaDebe
					 when asietipo.CodConc = 'VALORESRECIB' and val.CuentaDebe is not null then val.CuentaDebe
					 when ( asietipo.CodConc = 'PERCEPIVA' or asietipo.CodConc = 'PERCEPGAN' or asietipo.CodConc = 'PERCEPIIBB' ) and imp.CuentaDebe is not null then imp.CuentaDebe
					 else asietipo.cuentade
				end
			end CuentaHaber,
		'' as CentroDeCostos,
		case when asietipo.CodConc = 'VALORESRECIB' and val.Monto is not null then val.Monto * cab.cotiz
			 when asietipo.CodConc = 'DESCLINEA' and detDesc.Monto is not null then detDesc.Monto * cab.cotiz
			 when asietipo.CodConc = 'DESCTOTAL' then ( cab.desmntosi3 + cab.desmntosi ) * cab.cotiz
			 when asietipo.CodConc = 'DESCVALOR' then cab.desmntosi2 * cab.cotiz
			 when asietipo.CodConc = 'IVACREDITO' and cab.signomov < 0 then cab.fimpuesto * cab.cotiz
			 when asietipo.CodConc = 'DIFREDONDEO' then cab.fajxre * cab.cotiz
			 when asietipo.CodConc = 'VENTAS' and detVentas.Monto is not null then detVentas.Monto * cab.cotiz
			 when asietipo.CodConc = 'IVADEBITO' and cab.signomov > 0 then cab.fimpuesto * cab.cotiz
			 when asietipo.CodConc = 'RECARGOTOTAL' then ( cab.recmntosi + cab.recmntosi2 ) * cab.cotiz
			 when asietipo.CodConc = 'RECARGOVALOR' then cab.recmntosi1 * cab.cotiz
			 when asietipo.CodConc = 'SENIAS' and detSenia.Monto is not null then detSenia.Monto * cab.cotiz
			 when asietipo.CodConc = 'VUELTOS' and vue.Monto is not null then vue.Monto * (-1) * cab.cotiz
			 when asietipo.CodConc = 'PERCEPIVA' and imp.MontoPercepcionIVA is not null then imp.MontoPercepcionIVA * cab.cotiz
			 when asietipo.CodConc = 'PERCEPGAN' and imp.MontoPercepcionGanancias is not null then imp.MontoPercepcionGanancias * cab.cotiz
			 when asietipo.CodConc = 'PERCEPIIBB' and imp.MontoPercepcionIIBB is not null then imp.MontoPercepcionIIBB * cab.cotiz
			 when asietipo.CodConc = 'IMPINTERNOS' then cab.Gravamen * cab.cotiz
			else 0 end as Monto
	 from ZooLogic.COMPROBANTEV cab
	  cross join ( select codigo, codconc, cuentade, cuentaha from @tblAtipodet where codigo = 'FAC.VENTA' ) as asietipo
	  left join ( select det.codigo,
						SUM( det.MNDESSI + det.MNPDSI ) as Monto
						from ZooLogic.COMPROBANTEVDET det
						 left join ( select top 1 valor from registros.puesto where idunico = '1CCBD327E117D814E911B58D14712144911141' ) regSenia on det.FART = regSenia.valor 
                        where regSenia.valor is null
						group by det.codigo
						) detDesc on cab.codigo = detDesc.codigo
	  left join ( select det.codigo, impdir.cuentaDebe, impdir.cuentaHaber,
						sum( det.PrunSinImp * det.fcant ) as Monto
						from ZooLogic.COMPROBANTEVDET det
						 left join Contabilidad.ObtenerImputacionesContablesPorArticulo( @tblAtipodet, @tblImpdirart, @tblBasesAgrup, 'FAC.VENTA', 'VENTAS', 1, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual ) as impdir on det.fart = impdir.Cod
						 left join ( select top 1 valor from registros.puesto where idunico = '1CCBD327E117D814E911B58D14712144911141' ) regSenia on det.FART = regSenia.valor 
                        where regSenia.valor is null
						group by det.codigo, impdir.cuentaDebe, impdir.cuentaHaber
						) detVentas on cab.codigo = detVentas.codigo and asietipo.CodConc = 'VENTAS'
	  left join ( select det.codigo,
						sum( det.PrunSinImp * det.fcant ) as Monto
						from ZooLogic.COMPROBANTEVDET det
						 inner join ( select top 1 valor from registros.puesto where idunico = '1CCBD327E117D814E911B58D14712144911141' ) regSenia on det.FART = regSenia.valor 
						group by det.codigo
						) detSenia on cab.codigo = detSenia.codigo and asietipo.CodConc = 'SENIAS'
	  left join ( select val.jjnum,
				   sum( val.recpesos ) as Monto
				  from ZooLogic.VAL
				  where val.ESVUELTO = 1
				  group by val.jjnum
				 ) vue on cab.codigo = vue.JJNUM
	  left join ( select val.jjnum, 
					case when impdir.cuentaDebe = '' then '' else case when impdirCli.PCuenta is null then impdir.cuentaDebe else impdirCli.PCuenta end end cuentaDebe, 
					case when impdir.cuentaHaber = '' then '' else case when impdirCli.PCuenta is null then impdir.cuentaHaber else impdirCli.PCuenta end end cuentaHaber, 
					sum( val.recpesos ) as Monto
				  from ZooLogic.VAL val
					inner join ZooLogic.COMPROBANTEV c on val.JJNUM = c.codigo
					left join Contabilidad.ObtenerImputacionesContablesPorValor( @tblAtipodet, @tblImpdirval, @tblBasesAgrup, 'FAC.VENTA', 'VALORESRECIB', 1, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual ) as impdir on val.jjco = impdir.Cod
					left join Contabilidad.ObtenerImputacionesContablesPorValorPorCliente( @tblImpdircli, @tblBasesAgrup, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual ) as impdirCli
																								  on impdir.NumeroImpValor = impdirCli.NumeroImpValor 
																								 and c.fperson = impdirCli.Cod
				  where val.ESVUELTO = 0
				  group by val.jjnum, impdir.cuentaDebe, impdir.cuentaHaber, impdirCli.PCuenta 
				 ) val on cab.codigo = val.JJNUM and asietipo.CodConc = 'VALORESRECIB'
	  left join ( select imp.ccod,
				   case when imp.TIPOI='IVA' then impdirIva.cuentaDebe
						when imp.TIPOI='GANANCIAS' then impdirGan.cuentaDebe
						when imp.TIPOI='IIBB' then impdirIibb.cuentaDebe
					 end as CuentaDebe, 
				   case when imp.TIPOI='IVA' then impdirIva.cuentaHaber
						when imp.TIPOI='GANANCIAS' then impdirGan.cuentaHaber
						when imp.TIPOI='IIBB' then impdirIibb.cuentaHaber
					 end as CuentaHaber,
				  imp.TIPOI
					 , 
				   sum( case when imp.TIPOI='IVA' then imp.MONTO else 0 end ) as MontoPercepcionIVA,
				   sum( case when imp.TIPOI='GANANCIAS' then imp.MONTO else 0 end ) as MontoPercepcionGanancias,
				   sum( case when imp.TIPOI='IIBB' then imp.MONTO else 0 end ) as MontoPercepcionIIBB
				  from ZooLogic.IMPVENTAS imp
						 left join Contabilidad.ObtenerImputacionesContablesPorImpuesto( @tblAtipodet, @tblImpdirimp, @tblBasesAgrup, 'FAC.VENTA', 'PERCEPIVA', 1, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual ) as impdirIva on imp.codimp = impdirIva.Cod and imp.TIPOI='IVA'
						 left join Contabilidad.ObtenerImputacionesContablesPorImpuesto( @tblAtipodet, @tblImpdirimp, @tblBasesAgrup, 'FAC.VENTA', 'PERCEPGAN', 1, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual ) as impdirGan on imp.codimp = impdirGan.Cod and imp.TIPOI='GANANCIAS'
						 left join Contabilidad.ObtenerImputacionesContablesPorImpuesto( @tblAtipodet, @tblImpdirimp, @tblBasesAgrup, 'FAC.VENTA', 'PERCEPIIBB', 1, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual ) as impdirIibb on imp.codimp = impdirIibb.Cod and imp.TIPOI='IIBB'
				  group by imp.ccod,
				   case when imp.TIPOI='IVA' then impdirIva.cuentaDebe
						when imp.TIPOI='GANANCIAS' then impdirGan.cuentaDebe
						when imp.TIPOI='IIBB' then impdirIibb.cuentaDebe
					 end, 
				   case when imp.TIPOI='IVA' then impdirIva.cuentaHaber
						when imp.TIPOI='GANANCIAS' then impdirGan.cuentaHaber
						when imp.TIPOI='IIBB' then impdirIibb.cuentaHaber
					 end,
				   imp.tipoi
				  ) imp on cab.codigo = imp.ccod and ( asietipo.CodConc = 'PERCEPIVA' or asietipo.CodConc = 'PERCEPGAN' or asietipo.CodConc = 'PERCEPIIBB' )
	  where cab.ffch between @FechaDesde and @FechaHasta
		and cab.facttipo in (select tipocomp from @tblTipoComp)
)

