IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[ArmarAsientos_Pagos]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[ArmarAsientos_Pagos];
GO;
Create Function [Contabilidad].[ArmarAsientos_Pagos]
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
		@tblImpdirimp as Contabilidad.udt_TableType_Impdirimp ReadOnly
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
		convert(char(150),'Pago ' + cab.fletra + ' ' + right( replicate( '0', 4 ) + ltrim(str( cab.fptoven )), 4 ) + '-' + right( replicate( '0', 8 ) + ltrim(str( cab.fnumcomp )), 8 ) + ' - ' + cab.fperson + ' ' + isnull(prov.clnom,'') ) as Referencia,
		cab.codigo,
		case when asietipo.CodConc = 'ACREEDORESVS' and ImputDeAcreedoresSegunProveedorDirecto.PCuenta is not null and asietipo.cuentade <> '' then  ImputDeAcreedoresSegunProveedorDirecto.PCuenta
			when asietipo.CodConc = 'VALORESENTREG' and val.CuentaDebe is not null then val.CuentaDebe
			when asietipo.CodConc = 'IMPUESTOS' and imp.CuentaDebe is not null then imp.CuentaDebe
			else asietipo.cuentade
		end CuentaDebe,
		case when asietipo.CodConc = 'ACREEDORESVS' and ImputDeAcreedoresSegunProveedorDirecto.PCuenta is not null and asietipo.cuentaha <> '' then  ImputDeAcreedoresSegunProveedorDirecto.PCuenta
			when asietipo.CodConc = 'VALORESENTREG' and val.CuentaHaber is not null then val.CuentaHaber
			when asietipo.CodConc = 'IMPUESTOS' and imp.CuentaHaber is not null then imp.CuentaHaber
			else asietipo.cuentaha
		end CuentaHaber,
	'' as CentroDeCostos,
	case when asietipo.CodConc = 'ACREEDORESVS' and ImputDeAcreedoresSegunProveedorDirecto.Monto is not null then ImputDeAcreedoresSegunProveedorDirecto.Monto * ordpago.Cotiz
			when asietipo.CodConc = 'VALORESENTREG' and val.Monto is not null then val.Monto * ordpago.Cotiz
			when asietipo.CodConc = 'IMPUESTOS' and imp.Monto is not null then imp.Monto * ordpago.Cotiz
			else 0 
			end as Monto
	from ZooLogic.PAGO cab
	cross join ( select codigo, codconc, cuentade, cuentaha from @tblAtipodet where codigo = 'ORDENPAGO' ) asietipo
	inner join zoologic.ordpago on cab.opago = ordpago.codigo
	left join zoologic.prov on cab.fperson = prov.clcod
	left join ( select det.codigo,
						impdirpro.PCuenta,
						SUM( det.rmonto ) as Monto
					from ZooLogic.PAGODET det
						inner join ZooLogic.PAGO c on det.codigo = c.codigo
						left join Contabilidad.ObtenerImputacionesContablesPorValorPorProveedor( @tblImpdirpro, @tblBasesAgrup, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual ) as impdirpro
																								  on impdirpro.NumeroImpValor = 0 
																								 and c.fperson = impdirpro.Cod
					group by det.codigo, impdirpro.PCuenta 
					) ImputDeAcreedoresSegunProveedorDirecto on cab.codigo = ImputDeAcreedoresSegunProveedorDirecto.codigo and asietipo.CodConc = 'ACREEDORESVS'
	left join ( select val.jjnum, 
				case when impdir.cuentaDebe = '' then '' else case when impdirProv.PCuenta is null then impdir.cuentaDebe else impdirProv.PCuenta end end cuentaDebe, 
				case when impdir.cuentaHaber = '' then '' else case when impdirProv.PCuenta is null then impdir.cuentaHaber else impdirProv.PCuenta end end cuentaHaber, 
				sum( val.pesos ) as Monto
				from ZooLogic.PAGOVAL val
				inner join ZooLogic.PAGO c on val.JJNUM = c.codigo
				left join Contabilidad.ObtenerImputacionesContablesPorValor( @tblAtipodet, @tblImpdirval, @tblBasesAgrup, 'ORDENPAGO', 'VALORESENTREG', 2, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual ) as impdir on val.jjco = impdir.Cod
				left join Contabilidad.ObtenerImputacionesContablesPorValorPorProveedor( @tblImpdirpro, @tblBasesAgrup, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual ) as impdirProv
                                                                                            on impdir.NumeroImpValor = impdirProv.NumeroImpValor 
                                                                                            and c.fperson = impdirProv.Cod
			group by val.jjnum, impdir.cuentaDebe, impdir.cuentaHaber, impdirProv.PCuenta 
			) val on cab.codigo = val.JJNUM and asietipo.CodConc = 'VALORESENTREG'
	left join ( select imp.codigo, 
			case when impdir.cuentaDebe = '' then '' else impdir.cuentaDebe end cuentaDebe, 
			case when impdir.cuentaHaber = '' then '' else impdir.cuentaHaber end cuentaHaber, 
			sum( imp.monto ) as Monto
			from ZooLogic.PAGOIMP imp 
				left join Contabilidad.ObtenerImputacionesContablesPorImpuesto( @tblAtipodet, @tblImpdirimp, @tblBasesAgrup, 'ORDENPAGO', 'IMPUESTOS', 2, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual ) as impdir on imp.codimp = impdir.Cod
			group by imp.codigo, impdir.cuentaDebe, impdir.cuentaHaber
			) imp on cab.codigo = imp.codigo and asietipo.CodConc = 'IMPUESTOS'
	where cab.ffch between @FechaDesde and @FechaHasta
	and cab.facttipo = 37
)

