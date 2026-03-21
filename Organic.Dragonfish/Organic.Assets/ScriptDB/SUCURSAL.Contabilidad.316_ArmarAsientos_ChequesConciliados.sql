IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[ArmarAsientos_ChequesConciliados]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[ArmarAsientos_ChequesConciliados];
GO;
Create Function [Contabilidad].[ArmarAsientos_ChequesConciliados]
	(
		@FechaDesde as DateTime, 
		@FechaHasta as DateTime, 
		@BaseDeDatosActual char(8), 
		@SucursalActual char(10), 
		@TipoSucursalActual char(10),
		@tblBasesAgrup as Contabilidad.udt_TableType_BasesAgrup ReadOnly,
		@tblAtipodet as Contabilidad.udt_TableType_Atipodet ReadOnly, 
		@tblImpdircue as Contabilidad.udt_TableType_Impdircue ReadOnly
	)
RETURNS TABLE
AS
RETURN
(
	select 
		asietipo.codigo as CodigoAsientoTipo,
		convert(date,cab.FECHA) as FechaAsiento, 
		'' as TipoComp,
		'' as LetraComp,
		convert(char(150),'Cheque ' + cab.ident + ' (Reg. conciliable ' + cab.codigo + ')' ) as Referencia,
		cab.codigo,


		asietipo.cuentade CuentaDebe,  /*
		case when asietipo.CodConc = 'VALORESENTREG' and CuentaTransfiereImputacionDirecta.CuentaDebe is not null then CuentaTransfiereImputacionDirecta.CuentaDebe
			 when asietipo.CodConc = 'CUENTASDESTINO' and CuentaRecibeImputacionDirecta.CuentaDebe is not null then CuentaRecibeImputacionDirecta.CuentaDebe
			 else asietipo.cuentade
			 end CuentaDebe,*/

		case when asietipo.CodConc = 'BANCOSPAGOS' and BancoPagosImpDir.CuentaHaber is not null then BancoPagosImpDir.CuentaHaber
			 --when asietipo.CodConc = 'CUENTASDESTINO' and CuentaRecibeImputacionDirecta.CuentaHaber is not null then CuentaRecibeImputacionDirecta.CuentaHaber
			 else asietipo.cuentaha
			 end CuentaHaber,

		'' as CentroDeCostos,
		convert( numeric (15,4),
			case when asietipo.CodConc = 'VALORESENTREG' then abs( cab.Importe )
				 when asietipo.CodConc = 'BANCOSPAGOS' then abs( cab.Importe )
				 else 0
				 end ) as Monto
	 from zoologic.REGCTA cab
		cross join ( select codigo, codconc, cuentade, cuentaha from @tblAtipodet where codigo = 'CONCILIA' and (codconc = 'BANCOSPAGOS' or codconc = 'VALORESENTREG' ) ) asietipo
		inner join zoologic.DETREGCON det_conc on cab.codigo = det_conc.reg
		inner join zoologic.CONCILIACION cab_conc on cab_conc.codigo = det_conc.codigo
		left join Contabilidad.ObtenerImputacionesContablesPorCuentaBancaria( @tblAtipodet, @tblImpdircue, @tblBasesAgrup, 'CONCILIA', 'BANCOSPAGOS', @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual ) as BancoPagosImpDir on cab.CtaBanc = BancoPagosImpDir.Cod
	 where cab.FECHA between @FechaDesde and @FechaHasta
		and (cab.tipoval = 14 or cab.TIPOVAL=12)
)

/*
select * from zoologic.regcta where faltafw = '20220601'
select * from zoologic.detregcon where codigo = '1BDCB1DD01F5CB14B9B1A99B10622634078001'
select * from zoologic.conciliacion where faltafw = '20220601'
*/


