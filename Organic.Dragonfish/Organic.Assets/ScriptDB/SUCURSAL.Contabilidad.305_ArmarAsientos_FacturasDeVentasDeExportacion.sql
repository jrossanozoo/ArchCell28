IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[ArmarAsientos_FacturasDeVentasDeExportacion]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[ArmarAsientos_FacturasDeVentasDeExportacion];
GO;
Create Function [Contabilidad].[ArmarAsientos_FacturasDeVentasDeExportacion]
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
		@tblImpdirart as Contabilidad.udt_TableType_Impdirart ReadOnly
	)
RETURNS TABLE
AS
RETURN
(
	select 
		asietipo.codigo as CodigoAsientoTipo,
		convert(date,cab.ffch) as FechaAsiento, 
		case when (cab.facttipo = 47 or cab.facttipo = 33) then 'FC'
			 when (cab.facttipo = 48 or cab.facttipo = 35) then 'NC'
			 when (cab.facttipo = 49 or cab.facttipo = 36) then 'ND'
			 else ''
			end as TipoComp,
		cab.fletra as LetraComp,
		convert(char(150), 'Ventas - '
							+ case when ( cab.facttipo = 1 or cab.facttipo = 2 or cab.facttipo = 27 ) then 'FC'
								 when ( cab.facttipo = 3 or cab.facttipo = 5 or cab.facttipo = 28 ) then 'NC'
								 when ( cab.facttipo = 4 or cab.facttipo = 6 or cab.facttipo = 29 ) then 'ND'
								 else ''
								end
							+ ' ' + cab.fletra 
							+ ' ' + right( replicate( '0', 4 ) + ltrim(str( cab.fptoven )), 4 ) 
							+ '-' + right( replicate( '0', 8 ) + ltrim(str( cab.fnumcomp )), 8 ) 
							+ '  [' + cab.fperson + ' - ' + cab.fcliente + ']' ) as Referencia,
		cab.codigo,
		case when cab.signomov = 1  -- Invierte cuentas para NCs
			then 
				case when asietipo.CodConc = 'VENTAS' and detVentas.CuentaDebe is not null then detVentas.CuentaDebe
					 when asietipo.CodConc = 'VALORESRECIB' and val.CuentaDebe is not null then val.CuentaDebe
					 else asietipo.cuentade
				end
			else
				case when asietipo.CodConc = 'VENTAS' and detVentas.CuentaHaber is not null then detVentas.CuentaHaber
					 when asietipo.CodConc = 'VALORESRECIB' and val.CuentaHaber is not null then val.CuentaHaber
					 else asietipo.cuentaha
				end
			end CuentaDebe,
		case when cab.signomov = 1  -- Invierte cuentas para NCs
			then 
				case when asietipo.CodConc = 'VENTAS' and detVentas.CuentaHaber is not null then detVentas.CuentaHaber
					 when asietipo.CodConc = 'VALORESRECIB' and val.CuentaHaber is not null then val.CuentaHaber
					 else asietipo.cuentaha
				end
			else
				case when asietipo.CodConc = 'VENTAS' and detVentas.CuentaDebe is not null then detVentas.CuentaDebe
					 when asietipo.CodConc = 'VALORESRECIB' and val.CuentaDebe is not null then val.CuentaDebe
					 else asietipo.cuentade
				end
			end CuentaHaber,
		'' as CentroDeCostos,
		case when asietipo.CodConc = 'VALORESRECIB' and val.Monto is not null then val.Monto * cab.cotiz
			 when asietipo.CodConc = 'DESCLINEA' and detDesc.Monto is not null then detDesc.Monto * cab.cotiz
			 when asietipo.CodConc = 'DESCTOTAL' then ( ( cab.desmntosi3 + cab.desmntosi ) * cab.cotiz )
			 when asietipo.CodConc = 'DESCVALOR' then cab.desmntosi2 * cab.cotiz
			 when asietipo.CodConc = 'DIFREDONDEO' then cab.fajxre * cab.cotiz
			 when asietipo.CodConc = 'VENTAS' and detVentas.Monto is not null then detVentas.Monto * cab.cotiz
			 when asietipo.CodConc = 'RECARGOTOTAL' then ( cab.recmntosi + cab.recmntosi2 ) * cab.cotiz
			 when asietipo.CodConc = 'RECARGOVALOR' then cab.recmntosi1 * cab.cotiz
			 when asietipo.CodConc = 'SENIAS' and senia.prunsinimp is not null then senia.prunsinimp * cab.cotiz
			 when asietipo.CodConc = 'VUELTOS' and vue.Monto is not null then vue.Monto * cab.cotiz * (-1)
			else 0 end  as Monto
	 from ZooLogic.COMPROBANTEV cab
	  cross join ( select codigo, codconc, cuentade, cuentaha from @tblAtipodet where codigo = 'EXPORTA' ) asietipo
	  left join ( select det.codigo,
						SUM( det.MNDESSI + det.MNPDSI ) as Monto
						from ZooLogic.COMPROBANTEVDET det
						where det.fart <> 'SEÑA'
						group by det.codigo
						) detDesc on cab.codigo = detDesc.codigo
	  left join ( select det.codigo, impdir.cuentaDebe, impdir.cuentaHaber,
						sum( det.PrunSinImp * det.fcant ) as Monto
						from ZooLogic.COMPROBANTEVDET det
						 left join Contabilidad.ObtenerImputacionesContablesPorArticulo( @tblAtipodet, @tblImpdirart, @tblBasesAgrup, 'EXPORTA', 'VENTAS', 1, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual ) as impdir on det.fart = impdir.Cod
						where det.fart <> 'SEÑA'
						group by det.codigo, impdir.cuentaDebe, impdir.cuentaHaber
						) detVentas on cab.codigo = detVentas.codigo and asietipo.CodConc = 'VENTAS'
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
					left join Contabilidad.ObtenerImputacionesContablesPorValor( @tblAtipodet, @tblImpdirval, @tblBasesAgrup, 'EXPORTA', 'VALORESRECIB', 1, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual ) as impdir on val.jjco = impdir.Cod
					left join Contabilidad.ObtenerImputacionesContablesPorValorPorCliente( @tblImpdircli, @tblBasesAgrup, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual ) as impdirCli
																							  on impdir.NumeroImpValor = impdirCli.NumeroImpValor 
																							 and c.fperson = impdirCli.Cod
				  where val.ESVUELTO = 0
				  group by val.jjnum, impdir.cuentaDebe, impdir.cuentaHaber, impdirCli.PCuenta 
				 ) val on cab.codigo = val.JJNUM and asietipo.CodConc = 'VALORESRECIB'
	  left join ZooLogic.SENIA on cab.codigo = senia.comp
	  where cab.ffch between @FechaDesde and @FechaHasta
		and cab.facttipo in (47,48,49,33,35,36)
)

