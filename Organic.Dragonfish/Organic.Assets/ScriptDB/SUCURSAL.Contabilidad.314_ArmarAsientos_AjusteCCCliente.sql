IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[ArmarAsientos_AjusteCCCliente]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[ArmarAsientos_AjusteCCCliente];
GO;
Create Function [Contabilidad].[ArmarAsientos_AjusteCCCliente]
	(
		@FechaDesde as DateTime, 
		@FechaHasta as DateTime, 
		@BaseDeDatosActual char(8), 
		@SucursalActual char(10), 
		@TipoSucursalActual char(10),
		@tblBasesAgrup as Contabilidad.udt_TableType_BasesAgrup ReadOnly,
		@tblAtipodet as Contabilidad.udt_TableType_Atipodet ReadOnly, 
		@tblImpdirmot as Contabilidad.udt_TableType_ImpdirMot ReadOnly
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
		convert(char(150),'Ajuste CC Cliente ' + cab.fletra + ' ' + right( replicate( '0', 4 ) + ltrim(str( cab.fptoven )), 4 ) + '-' + right( replicate( '0', 8 ) + ltrim(str( cab.fnumcomp )), 8 ) ) as Referencia,
		cab.codigo,
		case 
			when detalle.rmonto >= 0
				then ( case when asietipo.CodConc = 'DEUDORESXVTA' then asietipo.CuentaDe
						when asietipo.CodConc = 'CTAPUENTE' then ''
						else ''
					   end )
			else ( case when asietipo.CodConc = 'DEUDORESXVTA' then ''
					when asietipo.CodConc = 'DIFREDONDEO' then asietipo.CuentaHa
					when asietipo.CodConc = 'CTAPUENTE' and impdir.cuentaHaber <> '' then impdir.cuentaHaber
					end )
			end CuentaDebe,
		case 
			when detalle.rmonto >= 0 
				then ( case when asietipo.CodConc = 'CTAPUENTE' and impdir.cuentahaber <> '' then impdir.cuentaHaber
						when asietipo.CodConc = 'DEUDORESXVTA' then ''
						else asietipo.CuentaHa
					   end )
			else ( case when asietipo.CodConc = 'CTAPUENTE' then ''
					when asietipo.CodConc = 'DIFREDONDEO' then ''
					when asietipo.CodConc = 'DEUDORESXVTA' then asietipo.CuentaDe
					else asietipo.CuentaHa
					end )
			end CuentaHaber,
		 '' as CentroDeCostos,
		 case when asietipo.CodConc = 'DIFREDONDEO'  then 0
			 else abs(detalle.rmonto) 
			 end Monto,
		 asietipo.CodConc as concepto,
		 asietipo.cuentaDe as debe,
		 asietipo.cuentaHa as haber,
		 impdir.cuentaDebe as debe2,
		 impdir.cuentaHaber as haber2,
		 detalle.rmonto as monto2

	 from ZooLogic.detajucccli detalle
	  cross join ( select codigo, codconc, cuentade, cuentaha from @tblAtipodet where codigo = 'ACCCLI' ) asietipo
	  inner join ( select * from ZooLogic.ajucccli ) cab on cab.codigo = detalle.CODIGO
	  inner join ZooLogic.MOTIVO as M on M.MOTCOD = cab.motivo and M.ASIENTO=1
	  left join Contabilidad.ObtenerImputacionesContablesPorMotivo( @tblAtipodet, @tblImpdirmot, @tblBasesAgrup, 'ACCCLI', 'CTAPUENTE', @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual ) 
				as impdir on cab.MOTIVO = impdir.cod
	  where cab.FFCH between @FechaDesde and @FechaHasta
)
GO;




