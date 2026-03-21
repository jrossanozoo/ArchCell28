IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[ArmarAsientos_CanjesDeValores]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[ArmarAsientos_CanjesDeValores];
GO;
Create Function [Contabilidad].[ArmarAsientos_CanjesDeValores]
	(
		@FechaDesde as DateTime, 
		@FechaHasta as DateTime, 
		@BaseDeDatosActual char(8), 
		@SucursalActual char(10), 
		@TipoSucursalActual char(10),
		@tblBasesAgrup as Contabilidad.udt_TableType_BasesAgrup ReadOnly,
		@tblAtipodet as Contabilidad.udt_TableType_Atipodet ReadOnly, 
		@tblImpdirval as Contabilidad.udt_TableType_Impdirval ReadOnly,
		@tblImpdircaj as Contabilidad.udt_TableType_Impdircaj ReadOnly
	)
RETURNS TABLE
AS
RETURN
(
	select 
		asietipo.codigo as CodigoAsientoTipo,
		convert(date,cab.fecha) as FechaAsiento, 
		'' as TipoComp,
		'' as LetraComp,
		convert(char(150),'Canje de valores ' + cab.fletra + ' ' + right( replicate( '0', 4 ) + ltrim(str( cab.fptoven )), 4 ) + '-' + right( replicate( '0', 8 ) + ltrim(str( cab.numero )), 8 ) ) as Referencia,
		cab.codigo,
		case when asietipo.CodConc = 'VALORESENTREG' and valEnt.CuentaDebe is not null then valEnt.CuentaDebe
			 when asietipo.CodConc = 'VALORESRECIB' and valRec.CuentaDebe is not null then valRec.CuentaDebe
			 else asietipo.cuentade
			 end CuentaDebe,
		case when asietipo.CodConc = 'VALORESENTREG' and valEnt.CuentaHaber is not null then valEnt.CuentaHaber
			 when asietipo.CodConc = 'VALORESRECIB' and valRec.CuentaHaber is not null then valRec.CuentaHaber
			 else asietipo.cuentaha
			 end CuentaHaber,
		'' as CentroDeCostos,
		convert( numeric (15,4),
			case when asietipo.CodConc = 'VALORESENTREG' and valEnt.Monto is not null then valEnt.Monto
				 when asietipo.CodConc = 'VALORESRECIB' and valRec.Monto is not null then valRec.Monto
				 else 0
				 end ) as Monto
	 from zoologic.CANJECUPONES cab
		cross join ( select codigo, codconc, cuentade, cuentaha from @tblAtipodet where codigo = 'CANJEVALOR' ) asietipo
		left join ( select val.jjnum,
						case when impdir.cuentaDebe = '' then '' else case when impdirConc.PCuenta is null then impdir.cuentaDebe else impdirConc.PCuenta end end cuentaDebe, 
						case when impdir.cuentaHaber = '' then '' else case when impdirConc.PCuenta is null then impdir.cuentaHaber else impdirConc.PCuenta end end cuentaHaber, 
					   sum( val.pesos ) as Monto
					  from ZooLogic.CANJECUPONESDET val
						inner join ZooLogic.CANJECUPONES c on val.jjnum = c.codigo
						left join Contabilidad.ObtenerImputacionesContablesPorValor( @tblAtipodet, @tblImpdirval, @tblBasesAgrup, 'CANJEVALOR', 'VALORESRECIB', 1, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual ) as impdir on val.jjco = impdir.Cod
						left join Contabilidad.ObtenerImputacionesContablesPorValorPorConceptoCaja( @tblImpdircaj, @tblBasesAgrup, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual ) as impdirConc
																							  on impdir.NumeroImpValor = impdirConc.NumeroImpValor 
																							 and c.concepto = impdirConc.Cod
					  group by val.jjnum, impdir.cuentaDebe, impdir.cuentaHaber, impdirConc.PCuenta 
					 ) valRec on cab.codigo = valRec.jjnum and asietipo.CodConc = 'VALORESRECIB'
		left join ( select val.codigo,
						case when impdir.cuentaDebe = '' then '' else case when impdirConc.PCuenta is null then impdir.cuentaDebe else impdirConc.PCuenta end end cuentaDebe, 
						case when impdir.cuentaHaber = '' then '' else case when impdirConc.PCuenta is null then impdir.cuentaHaber else impdirConc.PCuenta end end cuentaHaber, 
						sum( val.pesos ) as Monto
					  from ZooLogic.CANJECUPONESENT val
						inner join ZooLogic.CANJECUPONES c on val.codigo = c.codigo
						left join Contabilidad.ObtenerImputacionesContablesPorValor( @tblAtipodet, @tblImpdirval, @tblBasesAgrup, 'CANJEVALOR', 'VALORESENTREG', 1, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual ) as impdir on val.jjco = impdir.Cod
						left join Contabilidad.ObtenerImputacionesContablesPorValorPorConceptoCaja( @tblImpdircaj, @tblBasesAgrup, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual ) as impdirConc
																							  on impdir.NumeroImpValor = impdirConc.NumeroImpValor 
																							 and c.concepto = impdirConc.Cod
					  group by val.codigo, impdir.cuentaDebe, impdir.cuentaHaber, impdirConc.PCuenta 
					 ) valEnt on cab.codigo = valEnt.codigo and asietipo.CodConc = 'VALORESENTREG'
	 where cab.fecha between @FechaDesde and @FechaHasta
)
