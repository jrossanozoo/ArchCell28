IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[ArmarAsientos_DescargasDeChequesDeTerceros]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[ArmarAsientos_DescargasDeChequesDeTerceros];
GO;
Create Function [Contabilidad].[ArmarAsientos_DescargasDeChequesDeTerceros]
	(
		@FechaDesde as DateTime, 
		@FechaHasta as DateTime, 
		@BaseDeDatosActual char(8), 
		@SucursalActual char(10), 
		@TipoSucursalActual char(10),
		@tblBasesAgrup as Contabilidad.udt_TableType_BasesAgrup ReadOnly,
		@tblAtipodet as Contabilidad.udt_TableType_Atipodet ReadOnly,
		@tblImpdirval as Contabilidad.udt_TableType_Impdirval ReadOnly,
		@tblImpdirdes as Contabilidad.udt_TableType_Impdirdes ReadOnly
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
		convert(char(150),'Descarga de cheques ' + cab.letra + ' ' + right( replicate( '0', 4 ) + ltrim(str( cab.ptoven )), 4 ) + '-' + right( replicate( '0', 8 ) + ltrim(str( cab.numcomp )), 8 ) ) as Referencia,
		cab.codigo,
		case when asietipo.CodConc = 'VALORESENTREG' and val.CuentaDebe is not null then val.CuentaDebe
			 when asietipo.CodConc = 'DESTINOVALORES' and DestinoImputacionDirecta.CuentaDebe is not null then  DestinoImputacionDirecta.CuentaDebe
			 else asietipo.cuentade
			 end CuentaDebe,
		case when asietipo.CodConc = 'VALORESENTREG' and val.CuentaHaber is not null then val.CuentaHaber
			 when asietipo.CodConc = 'DESTINOVALORES' and DestinoImputacionDirecta.CuentaHaber is not null then  DestinoImputacionDirecta.CuentaHaber
			 else asietipo.cuentaha
			 end CuentaHaber,
		'' as CentroDeCostos,
		Convert( numeric (15,4), 
			case when asietipo.CodConc = 'VALORESENTREG' then val.Monto
				 when asietipo.CodConc = 'DESTINOVALORES' then DestImporte.Monto
				 else 0
				 end ) as Monto
	 from zoologic.DESCARGACHEQUE cab
	  cross join ( select codigo, codconc, cuentade, cuentaha from @tblAtipodet where codigo = 'DESCARGACH' ) asietipo
	  left join Contabilidad.ObtenerImputacionesContablesPorDestinoDescargaCheques( @tblAtipodet, @tblImpdirdes, @tblBasesAgrup, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual ) as DestinoImputacionDirecta on cab.destino = DestinoImputacionDirecta.Cod
	  left join ( select det.codigo, sum( det.pesos ) as Monto
				  from ZooLogic.DETDESCCHEQUE det
				  group by det.codigo
				 ) DestImporte on cab.codigo = DestImporte.codigo
	  left join ( select val.codigo, impdir.cuentaDebe, impdir.cuentaHaber,
				   sum( val.pesos ) as Monto
				  from ZooLogic.DETDESCCHEQUE val
					inner join ZooLogic.CHEQUE cheq on val.NROCHEQUE = cheq.ccod
					left join Contabilidad.ObtenerImputacionesContablesPorValor( @tblAtipodet, @tblImpdirval, @tblBasesAgrup, 'DESCARGACH', 'VALORESENTREG', 1, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual ) as impdir on cheq.cvalor = impdir.Cod
				  group by val.codigo, impdir.cuentaDebe, impdir.cuentaHaber
				 ) val on cab.codigo = val.codigo and asietipo.CodConc = 'VALORESENTREG'
	 where cab.ffch between @FechaDesde and @FechaHasta

)
