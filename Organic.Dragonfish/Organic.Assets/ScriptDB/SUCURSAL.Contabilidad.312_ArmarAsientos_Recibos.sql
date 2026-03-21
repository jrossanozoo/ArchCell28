IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[ArmarAsientos_Recibos]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[ArmarAsientos_Recibos];
GO;
Create Function [Contabilidad].[ArmarAsientos_Recibos]
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
		convert(char(150),cab.descfw + ' - ' + cab.fperson + ' ' + cab.fcliente) as Referencia,
		cab.codigo,
		case when asietipo.CodConc = 'DEUDORESXVTA' and ImputDeVentasSegunCliente.PCuenta is not null and asietipo.cuentade <> '' then  ImputDeVentasSegunCliente.PCuenta
			 when asietipo.CodConc = 'VALORESRECIB' and val.CuentaDebe is not null then val.CuentaDebe
			 when asietipo.CodConc = 'IMPUESTOS' and ret.CuentaDebe is not null then ret.CuentaDebe
			 else asietipo.cuentade
			end CuentaDebe,
		case when asietipo.CodConc = 'DEUDORESXVTA' and ImputDeVentasSegunCliente.PCuenta is not null and asietipo.cuentaha <> '' then  ImputDeVentasSegunCliente.PCuenta
			 when asietipo.CodConc = 'VALORESRECIB' and val.CuentaHaber is not null then val.CuentaHaber
			 when asietipo.CodConc = 'IMPUESTOS' and ret.CuentaHaber is not null then ret.CuentaHaber
			 else asietipo.cuentaha
			end CuentaHaber,
		'' as CentroDeCostos,
		case when asietipo.CodConc = 'DEUDORESXVTA' and ImputDeVentasSegunCliente.Monto is not null then ImputDeVentasSegunCliente.Monto * cab.COTIZ
			 when asietipo.CodConc = 'VALORESRECIB' and val.Monto is not null then val.Monto * cab.cotiz
			 when asietipo.CodConc = 'IMPUESTOS' and ret.Monto is not null then ret.Monto * cab.cotiz
			 when asietipo.CodConc = 'VUELTOS' and vue.Monto is not null then vue.Monto * (-1) * cab.cotiz
			else 0 end as Monto
	 from ZooLogic.RECIBO cab
	  cross join ( select codigo, codconc, cuentade, cuentaha from @tblAtipodet where codigo = 'RECIBO' ) asietipo
	  left join ( select det.codigo,
						impdirCli.PCuenta,
						SUM( det.rmonto ) as Monto
					from ZooLogic.RECIBODET det
						inner join ZooLogic.RECIBO c on det.codigo = c.codigo
	  left join Contabilidad.ObtenerImputacionesContablesPorValorPorCliente( @tblImpdircli, @tblBasesAgrup, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual ) as impdirCli
																								  on impdirCli.NumeroImpValor = 0
																								 and c.fperson = impdirCli.Cod
	group by det.codigo, impdirCli.PCuenta 
					) ImputDeVentasSegunCliente on cab.codigo = ImputDeVentasSegunCliente.codigo and asietipo.CodConc = 'DEUDORESXVTA'
	  left join ( select val.jjnum, 
					case when impdir.cuentaDebe = '' then '' else case when impdirCli.PCuenta is null then impdir.cuentaDebe else impdirCli.PCuenta end end cuentaDebe, 
					case when impdir.cuentaHaber = '' then '' else case when impdirCli.PCuenta is null then impdir.cuentaHaber else impdirCli.PCuenta end end cuentaHaber, 
					sum( val.recpesos ) as Monto
				  from ZooLogic.VAL val
					inner join ZooLogic.RECIBO c on val.JJNUM = c.codigo
					left join Contabilidad.ObtenerImputacionesContablesPorValor( @tblAtipodet, @tblImpdirval, @tblBasesAgrup, 'RECIBO', 'VALORESRECIB', 1, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual ) as impdir on val.jjco = impdir.Cod
					left join Contabilidad.ObtenerImputacionesContablesPorValorPorCliente( @tblImpdircli, @tblBasesAgrup, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual ) as impdirCli
																							  on impdir.NumeroImpValor = impdirCli.NumeroImpValor 
																							 and c.fperson = impdirCli.Cod
				  where val.ESVUELTO = 0
				  group by val.jjnum, impdir.cuentaDebe, impdir.cuentaHaber, impdirCli.PCuenta 
				 ) val on cab.codigo = val.JJNUM and asietipo.CodConc = 'VALORESRECIB'
	  left join ( select val.jjnum,
				   sum( val.recpesos ) as Monto
				  from ZooLogic.VAL
				  where val.ESVUELTO = 1
				  group by val.jjnum
				 ) vue on cab.codigo = vue.JJNUM
	  left join ( select ret.codigo, 
					case when impdir.cuentaDebe = '' then '' else impdir.cuentaDebe end cuentaDebe, 
					case when impdir.cuentaHaber = '' then '' else impdir.cuentaHaber end cuentaHaber, 
				   sum( ret.monto ) as Monto
				  from ZooLogic.RECIRETE ret 
					 left join Contabilidad.ObtenerImputacionesContablesPorImpuesto( @tblAtipodet, @tblImpdirimp, @tblBasesAgrup, 'RECIBO', 'IMPUESTOS', 1, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual ) as impdir on ret.impuesto = impdir.Cod
				  group by ret.codigo, impdir.cuentaDebe, impdir.cuentaHaber
				 ) ret on cab.codigo = ret.codigo and asietipo.CodConc = 'IMPUESTOS'
	  where cab.ffch between @FechaDesde and @FechaHasta
		and cab.facttipo = 13
)


