IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[sp_ArmarAsientos]') AND type in (N'P'))
	DROP PROCEDURE [Contabilidad].[sp_ArmarAsientos];
GO;
Create Procedure [Contabilidad].[sp_ArmarAsientos]
	(
		@BaseDeDatosConConfiguracion varchar(40),
		@FechaDesde as DateTime, 
		@FechaHasta as DateTime,
		@ContabilizaVentasLocales bit,
		@ContabilizaVentasExportacion bit,
		@ContabilizaRecibos bit,
		@ContabilizaCompras bit,
		@ContabilizaPagos bit,
		@ContabilizaOtrosPagos bit,
		@ContabilizaCaja bit,
		@ContabilizaCanjes bit,
		@ContabilizaDescargas bit,
		@ContabilizaLiqTarjetas bit,
		@ContabilizaTransferencias bit,
		@ContabilizaAjusteCCCliente bit,
		@ContabilizaAjusteCCProveedor bit,
		@ContabilizaChequesConciliados bit,
		@ContabilizaFacturaManual bit,
		@ContabilizaNotaDebitoManual bit,
		@ContabilizaNotaCreditoManual bit,
		@ContabilizaFacturaFiscal bit,
		@ContabilizaNotaDebitoFiscal bit,
		@ContabilizaNotaCreditoFiscal bit,
		@ContabilizaFacturaElectronica bit,
		@ContabilizaNotaDebitoElectronica bit,
		@ContabilizaNotaCreditoElectronica bit,
		@ContabilizaFacturaDeCompra bit,
		@ContabilizaNotaCreditoDeCompra bit,
		@ContabilizaNotaDebitoDeCompra bit,
		@ContabilizaDespachoImportacCompra bit,
		@ContabilizaLiquidacionesCompra bit,
		@ContabilizaLiqServPublCompra bit,
		@ContabilizaRecibosCompra bit,
		@EsDeAjustePorInflacion bit = null

	) AS
begin
	DECLARE	@tblRetorno AS TABLE
	(
		[BaseDeDatosOrigen] [varchar](8) NULL, 
		[CodigoAsientoTipo] [varchar](10) NULL, 
		[OrdenAsientoTipo] [numeric](2,0) NULL, 
		[ClaveAsiento] [varchar](100) NULL, 
		[FechaAsiento] [datetime] NULL, 
		[Referencia] [varchar](150) NULL, 
		[CuentaDebe] [varchar](30) NULL, 
		[CuentaHaber] [varchar](30) NULL, 
		[CentroDeCostos] [varchar](20) NULL, 
		[Monto] [numeric](16,4) NULL, 
		[EsCuentaDifRedondeo] bit NULL,
		[Descrip] [varchar](100) NULL,
		[CAjuste] [char](30) NULL,
		[IndiceAju] [char](10) NULL
	)

	DECLARE	@tblTipoComp Contabilidad.udt_TableType_TipoComp
	if @ContabilizaFacturaManual = '1'
		INSERT INTO @tblTipoComp values (1)
	if @ContabilizaNotaCreditoManual = '1'
		INSERT INTO @tblTipoComp values (3)
	if @ContabilizaNotaDebitoManual = '1'
		INSERT INTO @tblTipoComp values (4)
	if @ContabilizaFacturaFiscal = '1'
		INSERT INTO @tblTipoComp values (2)
	if @ContabilizaNotaCreditoFiscal = '1'
		INSERT INTO @tblTipoComp values (5)
	if @ContabilizaNotaDebitoFiscal = '1'
		INSERT INTO @tblTipoComp values (6)
	if @ContabilizaFacturaElectronica = '1'
		BEGIN
		INSERT INTO @tblTipoComp values (27)
		INSERT INTO @tblTipoComp values (54)
		END
	if @ContabilizaNotaCreditoElectronica = '1'
		BEGIN
		INSERT INTO @tblTipoComp values (28)
		INSERT INTO @tblTipoComp values (55)
		END
	if @ContabilizaNotaDebitoElectronica = '1'
		BEGIN
		INSERT INTO @tblTipoComp values (29)
		INSERT INTO @tblTipoComp values (56)
		END


	DECLARE	@tblTipoFcCompra Contabilidad.udt_TableType_TipoFcCompra
	if @ContabilizaFacturaDeCompra = '1'
		BEGIN
		INSERT INTO @tblTipoFcCompra values (1, '')
		INSERT INTO @tblTipoFcCompra values (2, '')
		INSERT INTO @tblTipoFcCompra values (3, '')
		END
	if @ContabilizaDespachoImportacCompra = '1'
		INSERT INTO @tblTipoFcCompra values (4, 'Despacho importac.')
	if @ContabilizaLiquidacionesCompra = '1'
		BEGIN
		INSERT INTO @tblTipoFcCompra values (5, 'Liquidaciones A')
		INSERT INTO @tblTipoFcCompra values (6, 'Liquidaciones B')
		END
	if @ContabilizaLiqServPublCompra = '1'
		BEGIN
		INSERT INTO @tblTipoFcCompra values (7, 'Liq. serv. públicos A')
		INSERT INTO @tblTipoFcCompra values (8, 'Liq. serv. públicos B')
		END
	if @ContabilizaRecibosCompra = '1'
		BEGIN
		INSERT INTO @tblTipoFcCompra values (9, 'Recibo A')
		INSERT INTO @tblTipoFcCompra values (10, 'Recibo C')
		END

	

	DECLARE @BaseDeDatosActual char(8) = convert(char(8),SUBSTRING(DB_NAME(),CHARINDEX('DRAGONFISH_',DB_NAME())+11,100))

	DECLARE @SucursalActual char(10) = ( select valor from parametros.SUCURSAL where idunico = '1C2D17A2C1F31514C5C1A25410222710684731' )

	DECLARE @TipoSucursalActual char(10) = ( select tcod from ORGANIZACION.TSUCUR where tcod = 
		( select tipo from ORGANIZACION.SUC where codigo = @SucursalActual ) )
	if @TipoSucursalActual is null
		set @TipoSucursalActual = ''

	DECLARE	@tblRazonSocialActual Contabilidad.udt_TableType_RazonSocialActual
	INSERT INTO @tblRazonSocialActual
		exec Contabilidad.[sp_ObtenerRazonSocialActual] @NombreBaseDeDatosConConfiguraciones = @BaseDeDatosConConfiguracion, @CodigoBaseDeDatosActual = @BaseDeDatosActual
	DECLARE @RazonSocialActual char(10) = ( select RazonSocialActual from @tblRazonSocialActual )
	if @RazonSocialActual is null
		set @RazonSocialActual = ''

	DECLARE	@tblBasesAgrup Contabilidad.udt_TableType_BasesAgrup
	INSERT INTO @tblBasesAgrup
	 exec [Contabilidad].[sp_ObtenerBasesDeDatosDeTodosLosAgrupamientos] 

	
	DECLARE
		@tblPlanCuenta Contabilidad.udt_TableType_PlanCuenta,
		@tblDDCCosto   Contabilidad.udt_TableType_DDCCosto,
		@tblAtipo      Contabilidad.udt_TableType_Atipo,
		@tblAtipodet   Contabilidad.udt_TableType_Atipodet,
		@tblImpdirart Contabilidad.udt_TableType_Impdirart,
		@tblImpdircaj Contabilidad.udt_TableType_Impdircaj,
		@tblImpdircli Contabilidad.udt_TableType_Impdircli,
		@tblImpdircon Contabilidad.udt_TableType_Impdircon,
		@tblImpdirdes Contabilidad.udt_TableType_Impdirdes,
		@tblImpdirimp Contabilidad.udt_TableType_Impdirimp,
		@tblImpdirliq Contabilidad.udt_TableType_Impdirliq,
		@tblImpdirope Contabilidad.udt_TableType_Impdirope,
		@tblImpdirpro Contabilidad.udt_TableType_Impdirpro,
		@tblImpdirval Contabilidad.udt_TableType_Impdirval,
		@tblImpdircue Contabilidad.udt_TableType_Impdircue,
		@tblImpdircca Contabilidad.udt_TableType_Impdircca,
		@tblImpdirccc Contabilidad.udt_TableType_Impdirccc,
		@tblImpvercc Contabilidad.udt_TableType_Impvercc,
		@tblImpdirmot Contabilidad.udt_TableType_ImpdirMot

	INSERT INTO @tblPlanCuenta
	 exec [Contabilidad].[sp_ObtenerConfiguracionDeAsientos_PlanCuenta] @NombreBaseDeDatos= @BaseDeDatosConConfiguracion
	INSERT INTO @tblDDCCosto
	 exec [Contabilidad].[sp_ObtenerConfiguracionDeAsientos_DDCCosto] @NombreBaseDeDatos= @BaseDeDatosConConfiguracion
	INSERT INTO @tblAtipo
	 exec [Contabilidad].[sp_ObtenerConfiguracionDeAsientos_ATipo] @NombreBaseDeDatos= @BaseDeDatosConConfiguracion
	INSERT INTO @tblAtipodet
	 exec [Contabilidad].[sp_ObtenerConfiguracionDeAsientos_ATipoDet] @NombreBaseDeDatos= @BaseDeDatosConConfiguracion, @AjustaPorInflacion = @EsDeAjustePorInflacion
	INSERT INTO @tblImpdirArt
	 exec [Contabilidad].[sp_ObtenerConfiguracionDeAsientos_ImpdirArt] @NombreBaseDeDatos= @BaseDeDatosConConfiguracion
	INSERT INTO @tblImpdirCaj
	 exec [Contabilidad].[sp_ObtenerConfiguracionDeAsientos_ImpdirCaj] @NombreBaseDeDatos= @BaseDeDatosConConfiguracion
	INSERT INTO @tblImpdirCli
	 exec [Contabilidad].[sp_ObtenerConfiguracionDeAsientos_ImpdirCli] @NombreBaseDeDatos= @BaseDeDatosConConfiguracion
	INSERT INTO @tblImpdirCon
	 exec [Contabilidad].[sp_ObtenerConfiguracionDeAsientos_ImpdirCon] @NombreBaseDeDatos= @BaseDeDatosConConfiguracion
	INSERT INTO @tblImpdirDes
	 exec [Contabilidad].[sp_ObtenerConfiguracionDeAsientos_ImpdirDes] @NombreBaseDeDatos= @BaseDeDatosConConfiguracion
	INSERT INTO @tblImpdirImp
	 exec [Contabilidad].[sp_ObtenerConfiguracionDeAsientos_ImpdirImp] @NombreBaseDeDatos= @BaseDeDatosConConfiguracion
	INSERT INTO @tblImpdirLiq
	 exec [Contabilidad].[sp_ObtenerConfiguracionDeAsientos_ImpdirLiq] @NombreBaseDeDatos= @BaseDeDatosConConfiguracion
	INSERT INTO @tblImpdirOpe
	 exec [Contabilidad].[sp_ObtenerConfiguracionDeAsientos_ImpdirOpe] @NombreBaseDeDatos= @BaseDeDatosConConfiguracion
	INSERT INTO @tblImpdirPro
	 exec [Contabilidad].[sp_ObtenerConfiguracionDeAsientos_ImpdirPro] @NombreBaseDeDatos= @BaseDeDatosConConfiguracion
	INSERT INTO @tblImpdirVal
	 exec [Contabilidad].[sp_ObtenerConfiguracionDeAsientos_ImpdirVal] @NombreBaseDeDatos= @BaseDeDatosConConfiguracion
	INSERT INTO @tblImpdirCue
	 exec [Contabilidad].[sp_ObtenerConfiguracionDeAsientos_ImpdirCue] @NombreBaseDeDatos= @BaseDeDatosConConfiguracion
	INSERT INTO @tblImpdirCCA
	 exec [Contabilidad].[sp_ObtenerConfiguracionDeAsientos_ImpdirCCA] @NombreBaseDeDatos= @BaseDeDatosConConfiguracion
	INSERT INTO @tblImpdirCCC
	 exec [Contabilidad].[sp_ObtenerConfiguracionDeAsientos_ImpdirCCC] @NombreBaseDeDatos= @BaseDeDatosConConfiguracion
	INSERT INTO @tblImpverCC
	 exec [Contabilidad].[sp_ObtenerConfiguracionDeAsientos_ImpverCC] @NombreBaseDeDatos= @BaseDeDatosConConfiguracion
	INSERT INTO @tblImpdirmot
	 exec [Contabilidad].[sp_ObtenerConfiguracionDeAsientos_ImpDirMot] @NombreBaseDeDatos= @BaseDeDatosConConfiguracion

	--print '@FechaDesde: ' + convert( varchar(100), @FechaDesde)
	--print '@FechaHasta: ' + convert( varchar(100), @FechaHasta)
	--print '@BaseDeDatosActual: ' + convert( varchar(100), @BaseDeDatosActual)
	--print '@SucursalActual: ' + convert( varchar(100), @SucursalActual)
	--print '@TipoSucursalActual: ' + convert( varchar(100), @TipoSucursalActual)
	 
	insert into @tblRetorno
	select  convert(char(8),SUBSTRING(DB_NAME(),CHARINDEX('DRAGONFISH_',DB_NAME())+11,100)) AS BaseDeDatosOrigen,
			Asiento.CodigoAsientoTipo, 
			Atipo.orden AS OrdenAsientoTipo,
			max(
				DB_NAME() + ' ' + Asiento.CodigoAsientoTipo + ' ' +
				case when atipo.asientop = 3    -- por comprobante
						then ' ' + Asiento.Codigo
					 when atipo.asientop = 2    -- por mes
						then ' ' + convert( char(7), Asiento.FechaAsiento, 120 )
							+ ' ' + case when atipo.porletra = 1 then Asiento.LetraComp else '' end
							+ ' ' + case when atipo.portipoc = 1 then Asiento.TipoComp else '' end
					 when atipo.asientop = 1    -- por día
						then ' ' + convert( char(10), Asiento.FechaAsiento, 120 )
							+ ' ' + case when atipo.porletra = 1 then Asiento.LetraComp else '' end
							+ ' ' + case when atipo.portipoc = 1 then Asiento.TipoComp else '' end
					 else
						''
				end
				) AS ClaveAsiento, 
			-- asientop: 1 por día, 2 por mes, 3 por comprobante
			max(
			case when atipo.asientop = 2
				then DATEADD( dd, 
							  -( DAY( Asiento.FechaAsiento ) ) + case when atipo.diadelmes <= day( DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,Asiento.FechaAsiento) +1,0)) )
																		then atipo.diadelmes
																		else day( DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,Asiento.FechaAsiento) +1,0)) )
																 end,
							  Asiento.FechaAsiento )
				else Asiento.FechaAsiento
				end )FechaAsiento,

			-- asientop: 1 por día, 2 por mes, 3 por comprobante
			-- leyenda: 1 por sistema, 2 propia
			max(
				convert(char(150),
					case when atipo.leyenda = 2
							then atipo.leyprop
						 when atipo.asientop = 3 
							then Asiento.Referencia 
						 else atipo.descrip
							 + case when atipo.portipoc = 1 then ' ' + rtrim(Asiento.TipoComp) else '' end
							 + case when atipo.porletra = 1 then ' ' + rtrim(Asiento.LetraComp) else '' end
						end )
				) as Referencia,


			max(Asiento.CuentaDebe) CuentaDebe, 
			max(Asiento.CuentaHaber) CuentaHaber, 

			Asiento.CentroDeCostos, 

			sum( Asiento.Monto * ( case when Asiento.CuentaDebe = '' then (-1) else 1 end ) ) as Monto,

			max( case when CuentaDifRedondeo.CodConc is not null
						 and case when CuentaDifRedondeo.CuentaHa = '' then CuentaDifRedondeo.CuentaDe else CuentaDifRedondeo.CuentaHa end
						   = case when Asiento.CuentaHaber = '' then Asiento.CuentaDebe else Asiento.CuentaHaber end
					then 1
					else 0
					end
				) as EsCuentaDifRedondeo, 

			PlanCuenta.Descrip, --ver si hace falta dejar la descripcion
			PlanCuenta.CAjuste,
			PlanCuenta.IndiceAju
	from 
	(

		select  CodigoAsientoTipo, FechaAsiento, TipoComp, LetraComp, Referencia, Codigo, CuentaDebe, CuentaHaber,
				case when asi0.CentroDeCostos <> '' then asi0.CentroDeCostos
					 when impVert.CentroDeCostos is not null then impVert.CentroDeCostos
					 else ''
					end as CentroDeCostos,
				case when asi0.CentroDeCostos <> '' then asi0.Monto
					 when impVert.CentroDeCostos is not null then asi0.Monto * ( impVert.Porcentaje / 100 )
					 else asi0.Monto
					end as Monto
			from (

					select 3 as TipoAsi, CodigoAsientoTipo, FechaAsiento, TipoComp, LetraComp, Referencia, Codigo, CuentaDebe, CuentaHaber, CentroDeCostos, Monto
						from Contabilidad.ArmarAsientos_CanjesDeValores( @FechaDesde, @FechaHasta, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual, @tblBasesAgrup, @tblAtipodet, @tblImpdirval, @tblImpdircaj )
						where @ContabilizaCanjes = 1
					union all
					select 3 as TipoAsi, CodigoAsientoTipo, FechaAsiento, TipoComp, LetraComp, Referencia, Codigo, CuentaDebe, CuentaHaber, CentroDeCostos, Monto
						from Contabilidad.ArmarAsientos_ComprobantesDeCaja( @FechaDesde, @FechaHasta, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual, @tblBasesAgrup, @tblAtipodet, @tblImpdircaj, @tblImpdirval )
						where @ContabilizaCaja = 1
					union all
					select 3 as TipoAsi, CodigoAsientoTipo, FechaAsiento, TipoComp, LetraComp, Referencia, Codigo, CuentaDebe, CuentaHaber, CentroDeCostos, Monto
						from Contabilidad.ArmarAsientos_DescargasDeChequesDeTerceros( @FechaDesde, @FechaHasta, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual, @tblBasesAgrup, @tblAtipodet, @tblImpdirval, @tblImpdirdes )
						where @ContabilizaDescargas = 1
					union all
					select 2 as TipoAsi, CodigoAsientoTipo, FechaAsiento, TipoComp, LetraComp, Referencia, Codigo, CuentaDebe, CuentaHaber, CentroDeCostos, Monto
						from Contabilidad.ArmarAsientos_FacturasDeCompras( @FechaDesde, @FechaHasta, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual, @tblBasesAgrup, @tblAtipodet, @tblImpdirval, @tblImpdirpro, @tblImpdirart, @tblImpdirimp, @tblPlanCuenta, @tblDDCCosto, @tblImpdirCCA, @tblTipoFcCompra )
						where @ContabilizaCompras = 1
					union all
					select 1 as TipoAsi, CodigoAsientoTipo, FechaAsiento, TipoComp, LetraComp, Referencia, Codigo, CuentaDebe, CuentaHaber, CentroDeCostos, Monto
						from Contabilidad.ArmarAsientos_FacturasDeVentasDeExportacion( @FechaDesde, @FechaHasta, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual, @tblBasesAgrup, @tblAtipodet, @tblImpdirval, @tblImpdircli, @tblImpdirart )
						where @ContabilizaVentasExportacion = 1
					union all
					select 1 as TipoAsi, CodigoAsientoTipo, FechaAsiento, TipoComp, LetraComp, Referencia, Codigo, CuentaDebe, CuentaHaber, CentroDeCostos, Monto
						from Contabilidad.ArmarAsientos_FacturasDeVentas( @FechaDesde, @FechaHasta, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual, @tblBasesAgrup, @tblAtipodet, @tblImpdirval, @tblImpdircli, @tblImpdirart, @tblImpdirimp, @tblTipoComp )
						where @ContabilizaVentasLocales = 1
					union all
					select 3 as TipoAsi, CodigoAsientoTipo, FechaAsiento, TipoComp, LetraComp, Referencia, Codigo, CuentaDebe, CuentaHaber, CentroDeCostos, Monto
						from Contabilidad.ArmarAsientos_LiquidacionesDeTarjetas( @FechaDesde, @FechaHasta, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual, @tblBasesAgrup, @tblAtipodet, @tblImpdirliq, @tblImpdirope )
						where @ContabilizaLiqTarjetas = 1
					union all
					select 2 as TipoAsi, CodigoAsientoTipo, FechaAsiento, TipoComp, LetraComp, Referencia, Codigo, CuentaDebe, CuentaHaber, CentroDeCostos, Monto
						from Contabilidad.ArmarAsientos_NotasDeCreditoDeCompras( @FechaDesde, @FechaHasta, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual, @tblBasesAgrup, @tblAtipodet, @tblImpdirval, @tblImpdirpro, @tblImpdirart, @tblImpdirimp, @tblPlanCuenta, @tblDDCCosto, @tblImpdirCCA )
						where @ContabilizaCompras = 1 and @ContabilizaNotaCreditoDeCompra = 1
					union all
					select 2 as TipoAsi, CodigoAsientoTipo, FechaAsiento, TipoComp, LetraComp, Referencia, Codigo, CuentaDebe, CuentaHaber, CentroDeCostos, Monto
						from Contabilidad.ArmarAsientos_NotasDeDebitoDeCompras( @FechaDesde, @FechaHasta, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual, @tblBasesAgrup, @tblAtipodet, @tblImpdirval, @tblImpdirpro, @tblImpdirart, @tblImpdirimp, @tblPlanCuenta, @tblDDCCosto, @tblImpdirCCA )
						where @ContabilizaCompras = 1 and @ContabilizaNotaDebitoDeCompra = 1
					union all
					select 2 as TipoAsi, CodigoAsientoTipo, FechaAsiento, TipoComp, LetraComp, Referencia, Codigo, CuentaDebe, CuentaHaber, CentroDeCostos, Monto
						from Contabilidad.ArmarAsientos_OtrosPagos( @FechaDesde, @FechaHasta, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual, @tblBasesAgrup, @tblAtipodet, @tblImpdirval, @tblImpdirpro, @tblImpdircon, @tblPlanCuenta, @tblDDCCosto, @tblImpdirCCC )
						where @ContabilizaOtrosPagos = 1
					union all
					select 2 as TipoAsi, CodigoAsientoTipo, FechaAsiento, TipoComp, LetraComp, Referencia, Codigo, CuentaDebe, CuentaHaber, CentroDeCostos, Monto
						from Contabilidad.ArmarAsientos_Pagos( @FechaDesde, @FechaHasta, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual, @tblBasesAgrup, @tblAtipodet, @tblImpdirval, @tblImpdirpro, @tblImpdirimp )
						where @ContabilizaPagos = 1
					union all
					select 1 as TipoAsi, CodigoAsientoTipo, FechaAsiento, TipoComp, LetraComp, Referencia, Codigo, CuentaDebe, CuentaHaber, CentroDeCostos, Monto
						from Contabilidad.ArmarAsientos_Recibos( @FechaDesde, @FechaHasta, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual, @tblBasesAgrup, @tblAtipodet, @tblImpdirval, @tblImpdircli, @tblImpdirimp ) asi
						where @ContabilizaRecibos = 1
					union all
					select 3 as TipoAsi, CodigoAsientoTipo, FechaAsiento, TipoComp, LetraComp, Referencia, Codigo, CuentaDebe, CuentaHaber, CentroDeCostos, Monto
						from Contabilidad.ArmarAsientos_Transferencias( @FechaDesde, @FechaHasta, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual, @tblBasesAgrup, @tblAtipodet, @tblImpdircue ) asi
						where @ContabilizaTransferencias = 1
					union all
					select 1 as TipoAsi, CodigoAsientoTipo, FechaAsiento, TipoComp, LetraComp, Referencia, Codigo, CuentaDebe, CuentaHaber, CentroDeCostos, Monto
						from Contabilidad.ArmarAsientos_AjusteCCCliente( @FechaDesde, @FechaHasta, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual, @tblBasesAgrup, @tblAtipodet, @tblImpdirmot ) asi
						where @ContabilizaAjusteCCCliente = 1
					union all
					select 2 as TipoAsi, CodigoAsientoTipo, FechaAsiento, TipoComp, LetraComp, Referencia, Codigo, CuentaDebe, CuentaHaber, CentroDeCostos, Monto
						from Contabilidad.ArmarAsientos_AjusteCCProveedor( @FechaDesde, @FechaHasta, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual, @tblBasesAgrup, @tblAtipodet, @tblImpdirmot ) asi
						where @ContabilizaAjusteCCProveedor = 1
					union all
					select 3 as TipoAsi, CodigoAsientoTipo, FechaAsiento, TipoComp, LetraComp, Referencia, Codigo, CuentaDebe, CuentaHaber, CentroDeCostos, Monto
						from Contabilidad.ArmarAsientos_ChequesConciliados( @FechaDesde, @FechaHasta, @BaseDeDatosActual, @SucursalActual, @TipoSucursalActual, @tblBasesAgrup, @tblAtipodet, @tblImpdircue ) asi
						where @ContabilizaChequesConciliados = 1
				) asi0
			left join @tblPlanCuenta PlanCuenta on case when asi0.CuentaDebe = '' then asi0.CuentaHaber else asi0.CuentaDebe end = PlanCuenta.CtaCodigo
			left join ( select 1 as TipoAsi, CentroDeCostos, Porcentaje from [Contabilidad].[ObtenerImputacionVerticalDeCentrosDeCostos]
							( @tblImpvercc, 1, @BaseDeDatosActual, @SucursalActual, @RazonSocialActual, @tblBasesAgrup, @tblDDCCosto )
						 union
						select 2 as TipoAsi, CentroDeCostos, Porcentaje from [Contabilidad].[ObtenerImputacionVerticalDeCentrosDeCostos]
							( @tblImpvercc, 2, @BaseDeDatosActual, @SucursalActual, @RazonSocialActual, @tblBasesAgrup, @tblDDCCosto )
						 union
						select 3 as TipoAsi, CentroDeCostos, Porcentaje from [Contabilidad].[ObtenerImputacionVerticalDeCentrosDeCostos]
							( @tblImpvercc, 3, @BaseDeDatosActual, @SucursalActual, @RazonSocialActual, @tblBasesAgrup, @tblDDCCosto )
					  ) impVert on asi0.TipoAsi = impVert.TipoAsi  
								and ( asi0.CentroDeCostos = '' )
								and ( PlanCuenta.ReqCCosto is not null and PlanCuenta.ReqCCosto = 1 )
	) Asiento
	left join @tblAtipo ATipo on Asiento.CodigoAsientoTipo = ATipo.Codigo
	left join @tblAtipoDet CuentaDifRedondeo on Asiento.CodigoAsientoTipo = CuentaDifRedondeo.Codigo and CuentaDifRedondeo.CodConc = 'DIFREDONDEO'
	left join @tblPlanCuenta PlanCuenta on case when Asiento.CuentaDebe = '' then Asiento.CuentaHaber else Asiento.CuentaDebe end = PlanCuenta.CtaCodigo
	where Asiento.monto <> 0

		-- Condición para mantener las cuentas que correspondan a diferencia de redondeo (según cada asiento tipo) aunque estén en cero
		-- para después poder agregar posibles diferencias que se generen en el asiento
		or (	case when CuentaDifRedondeo.CodConc is not null
						 and case when CuentaDifRedondeo.CuentaHa = '' then CuentaDifRedondeo.CuentaDe else CuentaDifRedondeo.CuentaHa end
						   = case when Asiento.CuentaHaber = '' then Asiento.CuentaDebe else Asiento.CuentaHaber end
					then 1
					else 0
					end
				) = 1

	Group by
			Asiento.CodigoAsientoTipo, 
			Atipo.Orden, 

---			Asiento.ClaveAsiento, 

			-- asientop: 1 por día, 2 por mes, 3 por comprobante
			case when atipo.asientop = 1 then Asiento.FechaAsiento else '' end,
			case when atipo.asientop = 2 then MONTH( Asiento.FechaAsiento) else '' end,
			case when atipo.asientop = 3 then ( DB_NAME() + ' ' + Asiento.CodigoAsientoTipo + ' ' + Asiento.Codigo ) else '' end,

			case when atipo.porletra = 1 then Asiento.LetraComp else '' end,
			case when atipo.portipoc = 1 then Asiento.TipoComp else '' end,

			-- Hace este case para poder consolidar por una misma cuenta contable dentro de un mismo asiento (se complementa con un par de updates posteriores)
			case when Asiento.CuentaDebe <> '' then Asiento.CuentaDebe else Asiento.CuentaHaber end,

			Asiento.CentroDeCostos,
			PlanCuenta.Descrip, --ver si hace falta dejar la descripcion
			PlanCuenta.CAjuste,
			PlanCuenta.IndiceAju




	-- Updates que complementan la acción de consolidar por una misma cuenta contable dentro de un mismo asiento
	-- El primer update resuelve los casos en que (debido al agrupamiento por cuenta contable) queda la misma cuenta en el debe y en el haber
	-- (si el monto es cero igual se deja la cuenta en el debe, esto es para que mantenga el registro el concepto de diferencia por redondeo aún cuando todavía esté en cero)
	-- El segundo update resuelve los casos en que quedaron cuentas de Debe con saldos negativos (lo debe pasar al haber)
	-- El tercer update resuelve los casos en que quedaron cuentas de Haber con saldos positivos (lo debe pasar al debe)
	-- El cuarto update pone todos los montos en positivo (porque ya está seteado el debe y haber según en qué lugar quedó grabada la cuenta contable)
	update @tblRetorno
	 set CuentaDebe = case when Monto >= 0 then CuentaDebe else '' end,
		 CuentaHaber = case when Monto < 0 then CuentaHaber else '' end
	 where CuentaDebe <> '' and CuentaHaber <> ''
	update @tblRetorno
	 set CuentaDebe = '',
		 CuentaHaber = CuentaDebe
	 where CuentaDebe <> '' and Monto < 0
	update @tblRetorno
	 set CuentaDebe = CuentaHaber,
		 CuentaHaber = ''
	 where CuentaHaber <> '' and Monto > 0
	update @tblRetorno
	 set Monto = abs( Monto )


	-- Updates para corregir diferencias por redondeo.
	-- El primer update detecta si hay una diferencia de balanceo en cada asiento y la agrega al Monto en el concepto DIFREDONDEO, y copia la misma cuenta en Debe y Haber
	-- El segundo y tercer updates vuelven a determinar si la cuenta termina correspondiendo al debe o al haber según el signo del monto (teniendo en cuenta 
	-- que en el primer update se copió la misma cuenta al debe y al haber)
	update @tblRetorno
		set CuentaDebe = Sub1.pcuenta,
			CuentaHaber = Sub1.pcuenta,
			Monto = ( case when CuentaDebe = '' then Monto * (-1) else Monto end ) - Sub1.DifAsiento
		from @tblRetorno asi
		inner join (
					select asi.ClaveAsiento, 
							max( case when tip.cuentaha = '' then tip.cuentade else tip.cuentaha end ) pcuenta ,
							sum( asi.Monto * ( case when asi.CuentaDebe <> '' then 1 else (-1) end ) ) as [DifAsiento]
						from @tblRetorno asi
							inner join @tblAtipoDet tip on asi.CodigoAsientoTipo = tip.codigo and tip.codconc = 'DIFREDONDEO'
						group by asi.ClaveAsiento
						having sum( asi.Monto * ( case when asi.CuentaDebe = '' then (-1) else 1 end ) ) <> 0
					) Sub1 on asi.ClaveAsiento = Sub1.ClaveAsiento
						  and ( case when asi.CuentaHaber = '' then asi.CuentaDebe else asi.CuentaHaber end ) = Sub1.pcuenta
	update @tblRetorno
	 set CuentaDebe = case when Monto > 0 then CuentaDebe else '' end,
		 CuentaHaber = case when Monto < 0 then CuentaHaber else '' end
	 where CuentaDebe <> '' and CuentaHaber <> ''
	update @tblRetorno
	 set Monto = abs( Monto )



	delete @tblRetorno where Monto = 0


	select * from @tblRetorno
	 order by FechaAsiento, OrdenAsientoTipo, Referencia, ClaveAsiento, CuentaHaber, CuentaDebe
end

-- exec [Contabilidad].[sp_ArmarAsientos] 'DRAGONFISH_DEMO', '20240201', '20240229', 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0



