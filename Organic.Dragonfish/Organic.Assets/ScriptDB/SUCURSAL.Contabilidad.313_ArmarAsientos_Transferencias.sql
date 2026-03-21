IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[ArmarAsientos_Transferencias]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[ArmarAsientos_Transferencias];
GO;
Create Function [Contabilidad].[ArmarAsientos_Transferencias]
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
        convert(date,cab.fectran) as FechaAsiento, 
        '' as TipoComp,
        '' as LetraComp,
        convert(char(150),'Transferencia entre cuentas bancarias ' + convert(varchar(10),cab.numero) ) as Referencia,
        cab.codigo,
        case when asietipo.CodConc = 'CUENTASORIGEN' and CuentaTransfiereImputacionDirecta.CuentaDebe is not null then CuentaTransfiereImputacionDirecta.CuentaDebe
             when asietipo.CodConc = 'CUENTASDESTINO' and CuentaRecibeImputacionDirecta.CuentaDebe is not null then CuentaRecibeImputacionDirecta.CuentaDebe
             else asietipo.cuentade
             end CuentaDebe,
        case when asietipo.CodConc = 'CUENTASORIGEN' and CuentaTransfiereImputacionDirecta.CuentaHaber is not null then CuentaTransfiereImputacionDirecta.CuentaHaber
             when asietipo.CodConc = 'CUENTASDESTINO' and CuentaRecibeImputacionDirecta.CuentaHaber is not null then CuentaRecibeImputacionDirecta.CuentaHaber
             else asietipo.cuentaha
             end CuentaHaber,
        '' as CentroDeCostos,
        convert( numeric (15,4),
            case when asietipo.CodConc = 'CUENTASORIGEN' then cab.TraPesos
                 when asietipo.CodConc = 'CUENTASDESTINO' then cab.RecPesos
                 else 0
                 end ) as Monto
     from zoologic.TRANCTAS cab
        cross join ( select codigo, codconc, cuentade, cuentaha from @tblAtipodet where codigo = 'TRANSF' ) asietipo
        left join Contabilidad.ObtenerImputacionesContablesPorCuentaBancaria( @tblAtipodet, @tblImpdircue, @tblBasesAgrup, 'TRANSF', 'CUENTASDESTINO', @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual ) as CuentaRecibeImputacionDirecta on cab.CtaRec = CuentaRecibeImputacionDirecta.Cod
        left join Contabilidad.ObtenerImputacionesContablesPorCuentaBancaria( @tblAtipodet, @tblImpdircue, @tblBasesAgrup, 'TRANSF', 'CUENTASORIGEN', @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual ) as CuentaTransfiereImputacionDirecta on cab.CtaTran = CuentaTransfiereImputacionDirecta.Cod
     where cab.fectran between @FechaDesde and @FechaHasta
)