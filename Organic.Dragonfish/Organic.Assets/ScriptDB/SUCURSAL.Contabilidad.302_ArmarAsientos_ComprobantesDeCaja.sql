IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[ArmarAsientos_ComprobantesDeCaja]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[ArmarAsientos_ComprobantesDeCaja];
GO;
Create Function [Contabilidad].[ArmarAsientos_ComprobantesDeCaja]
	(
		@FechaDesde as DateTime, 
		@FechaHasta as DateTime, 
		@BaseDeDatosActual char(8), 
		@SucursalActual char(10), 
		@TipoSucursalActual char(10),
		@tblBasesAgrup as Contabilidad.udt_TableType_BasesAgrup ReadOnly,
		@tblAtipodet as Contabilidad.udt_TableType_Atipodet ReadOnly,
		@tblImpdircaj as Contabilidad.udt_TableType_Impdircaj ReadOnly,
		@tblImpdirval as Contabilidad.udt_TableType_Impdirval ReadOnly
	)
RETURNS TABLE
AS
RETURN
(
	select 
		asietipo.codigo as CodigoAsientoTipo,
		convert(date,cab.fecha) as FechaAsiento, 
		case when cab.tipo = 1 then 'de entrada' else 'de salida' end TipoComp,
		' ' as LetraComp,
		convert(char(150),'Comprobante de caja ' + convert(varchar(10),cab.numero) ) as Referencia,
		cab.codigo,
		case when asietipo.CodConc = 'MOVCAJA' and ( ConcImputacion.CuentaDebe is not null and ConcImputacion.CuentaHaber is not null ) then ( case when cab.signomov = 1 then ConcImputacion.CuentaDebe else ConcImputacion.CuentaHaber end )
			 when asietipo.CodConc = 'VALORES' and ( val.CuentaDebe is not null and val.CuentaHaber is not null ) then ( case when cab.signomov = 1 then val.CuentaDebe else val.CuentaHaber end )
			 else ( case when cab.signomov = 1 then asietipo.cuentade else asietipo.cuentaha end )
			end CuentaDebe,
		case when asietipo.CodConc = 'MOVCAJA' and ( ConcImputacion.CuentaDebe is not null and ConcImputacion.CuentaHaber is not null ) then ( case when cab.signomov = 1 then ConcImputacion.CuentaHaber else ConcImputacion.CuentaDebe end )
			 when asietipo.CodConc = 'VALORES' and ( val.CuentaDebe is not null and val.CuentaHaber is not null ) then ( case when cab.signomov = 1 then val.CuentaHaber else val.CuentaDebe end )
			 else ( case when cab.signomov = 1 then asietipo.cuentaha else asietipo.cuentade end )
			end CuentaHaber,
		'' as CentroDeCostos,
		case when asietipo.CodConc = 'MOVCAJA' then ConcImputacion.Monto
			when asietipo.CodConc = 'VALORES' then val.Monto
			else 0 
			end as Monto
	 from zoologic.COMCAJ cab
	  cross join ( select codigo, codconc, cuentade, cuentaha from @tblAtipodet where codigo = 'COMP.CAJA' ) asietipo
	  left join ( select coddetval, cod, cuentaDebe, cuentaHaber, sum(Monto) as Monto
					from ( select det.coddetval, 
						case when ImpCont.Cod is not null then ImpCont.cod else impdirConc.cod end Cod,
						case when ImpCont.Cod is not null then ImpCont.CuentaDebe else (case when impdirConc.Cod is not null then (case when impdir.cuentaDebe = '' then '' else impdirConc.PCuenta end) end) end cuentaDebe,
						case when ImpCont.Cod is not null then ImpCont.cuentaHaber else (case when impdirConc.Cod is not null then (case when impdir.cuentaHaber = '' then '' else impdirConc.PCuenta end) end)  end cuentaHaber,
						sum( det.monto * det.cotiza ) as Monto
					  from zoologic.COMPCAJADET det
						inner join zoologic.COMCAJ c on det.coddetval = c.codigo 
						left join [Contabilidad].[ObtenerImputacionesContablesPorConceptoCaja]( @tblAtipodet, @tblImpdircaj, @tblBasesAgrup, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual ) as ImpCont on c.Concepto = ImpCont.Cod
						left join Contabilidad.ObtenerImputacionesContablesPorValor( @tblAtipodet, @tblImpdirval, @tblBasesAgrup, 'COMP.CAJA', 'MOVCAJA', 1, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual ) as impdir 
																				  on det.codval = impdir.Cod
						left join Contabilidad.ObtenerImputacionesContablesPorValorPorConceptoCaja( @tblImpdircaj, @tblBasesAgrup, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual ) as impdirConc
																				  on c.concepto = impdirConc.Cod 
																				  and impdir.NumeroImpValor = impdirConc.NumeroImpValor
					  where ( det.tipo = 1 or det.tipo = 2 or det.tipo = 12 or det.tipo = 14 ) 
					  group by det.coddetval, ImpCont.cod, ImpCont.cuentaDebe, ImpCont.cuentaHaber, impdirConc.cod, impdirConc.NumeroImpValor, impdir.cuentaDebe, impdir.cuentaHaber, impdirConc.PCuenta
					) as CtaCont
				    group by coddetval, cod, cuentaDebe, cuentaHaber
				 ) as ConcImputacion on cab.Codigo = ConcImputacion.coddetval and asietipo.CodConc = 'MOVCAJA'
	  left join ( select det.coddetval, 
					sum( det.monto * det.cotiza ) as Monto
				  from ZooLogic.COMPCAJADET det
				  where ( det.tipo = 1 or det.tipo = 2 or det.tipo = 12 or det.tipo = 14 )
				  group by det.coddetval
				 ) ConcImporte on cab.codigo = ConcImporte.coddetval
	  left join ( select val.coddetval, impdir.cuentaDebe, impdir.cuentaHaber,
				   sum( val.monto * val.cotiza ) as Monto
				  from ZooLogic.COMPCAJADET val
					left join Contabilidad.ObtenerImputacionesContablesPorValor( @tblAtipodet, @tblImpdirval, @tblBasesAgrup, 'COMP.CAJA', 'VALORES', 1, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual ) as impdir on val.codval = impdir.Cod
				  where ( val.tipo = 1 or val.tipo = 2 or val.tipo = 12 or val.tipo = 14 )
				  group by val.coddetval, impdir.cuentaDebe, impdir.cuentaHaber
				 ) val on cab.codigo = val.coddetval and asietipo.CodConc = 'VALORES'
	where cab.fecha between @FechaDesde and @FechaHasta

)
