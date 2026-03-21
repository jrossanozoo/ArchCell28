IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[ArmarAsientos_LiquidacionesDeTarjetas]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[ArmarAsientos_LiquidacionesDeTarjetas];
GO;
Create Function [Contabilidad].[ArmarAsientos_LiquidacionesDeTarjetas]
	(
		@FechaDesde as DateTime, 
		@FechaHasta as DateTime, 
		@BaseDeDatosActual char(8), 
		@SucursalActual char(10), 
		@TipoSucursalActual char(10),
		@tblBasesAgrup as Contabilidad.udt_TableType_BasesAgrup ReadOnly,
		@tblAtipodet as Contabilidad.udt_TableType_Atipodet ReadOnly,
		@tblImpdirliq as Contabilidad.udt_TableType_Impdirliq ReadOnly,
		@tblImpdirope as Contabilidad.udt_TableType_Impdirope ReadOnly
	)
RETURNS TABLE
AS
RETURN
(
	select 
		asietipo.codigo as CodigoAsientoTipo,
		convert(date,cab.fechaliq) as FechaAsiento, 
		'' as TipoComp,
		'' as LetraComp,
		convert(char(150),'Liquidación de tarjeta ' + convert(varchar(10),cab.numint) ) as Referencia,
		cab.codigo,
		case when asietipo.CodConc = 'BANCOACREDITAC' and det.CuentaDebe is not null then det.CuentaDebe
			 when asietipo.CodConc = 'ACREDITCUPONES' and OperadoraImputacionDirecta.CuentaDebe is not null then OperadoraImputacionDirecta.CuentaDebe
			 else asietipo.cuentade
			end CuentaDebe,
		case when asietipo.CodConc = 'BANCOACREDITAC' and det.CuentaHaber is not null then det.CuentaHaber
			 when asietipo.CodConc = 'ACREDITCUPONES' and OperadoraImputacionDirecta.CuentaHaber is not null then OperadoraImputacionDirecta.CuentaHaber
			 else asietipo.cuentaha
			end CuentaHaber,
		'' as CentroDeCostos,
		convert( numeric (15,4),
			case when asietipo.CodConc = 'BANCOACREDITAC' and det.Monto is not null then det.Monto
				 when asietipo.CodConc = 'ACREDITCUPONES' then cab.totalliq
				 else 0
				 end ) as Monto
	 from zoologic.LIQMENSUAL cab
	  cross join ( select codigo, codconc, cuentade, cuentaha from @tblAtipodet where codigo = 'LIQUIDAMEN' ) asietipo
	  left join Contabilidad.ObtenerImputacionesContablesPorOperadoraDeTarjeta( @tblAtipodet, @tblImpdirope, @tblBasesAgrup, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual ) as OperadoraImputacionDirecta on cab.operadora = OperadoraImputacionDirecta.Cod
	  left join ( select det.codigo, impdir.cuentaDebe, impdir.cuentaHaber,
						SUM( det.monto ) as Monto
						from ZooLogic.LIQCONMENLDET det
						  left join Contabilidad.ObtenerImputacionesContablesPorConceptoLiquidacion( @tblAtipodet, @tblImpdirliq, @tblBasesAgrup, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual ) as impdir on det.Concepto = impdir.Cod
						group by det.codigo, impdir.cuentaDebe, impdir.cuentaHaber
						) det on cab.codigo = det.codigo and asietipo.CodConc = 'BANCOACREDITAC'
	  where cab.fechaliq between @FechaDesde and @FechaHasta

)

