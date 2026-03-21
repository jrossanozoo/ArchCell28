IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[sp_ObtenerAsientosParaAjustePorInflacion]') AND type in (N'P'))
	DROP PROCEDURE [Contabilidad].[sp_ObtenerAsientosParaAjustePorInflacion];
GO;
Create Procedure [Contabilidad].[sp_ObtenerAsientosParaAjustePorInflacion]
		(
		@BaseDeDatosConConfiguracion varchar(40),
		@FechaDesde as DateTime,
		@FechaHasta as DateTime,
		@EsDeAjustePorInflacion bit = null,
		@TiposDeAsientos bit = 1

	) AS
begin
	DECLARE	@tblRetorno AS TABLE
	(
		[BaseDeDatosOrigen] [varchar](8) NULL,
		[Cuenta] [varchar](30) NULL,
		[CuentaDebe] [varchar](30) NULL,
		[CuentaHaber] [varchar](30) NULL,
		[CentroDeCostos] [varchar](20) NULL,
		[MontoDebe] [numeric](15,4) NULL,
		[MontoHaber] [numeric](15,4) NULL,
		[Monto] [numeric](15,4) NULL,
		[Descrip] [varchar](100) NULL,
		[CAjuste] [char](30) NULL,
		[IndiceAju] [char](10) NULL
	)

	insert into @tblRetorno
	select convert(char(8),SUBSTRING(DB_NAME(),CHARINDEX('DRAGONFISH_',@BaseDeDatosConConfiguracion)+11,100)) as BaseDeDatosOrigen, 
		D.PCUENTA as Cuenta,
		'' as CuentaDebe,
		'' as CuentaHaber,
		D.CODCCOS as CentroDeCostos, 
		sum(D.Debe) as MontoDebe,
		sum(D.Haber) as MontoHaber,
		0 as Monto,
		D.PCUENTAD as Descrip, 
		PC.CAJUSTE, 
		PC.INDICEAJU
	from Zoologic.ASIENTO A
	left join Zoologic.ASIENTODET D on D.CODIGO = A.ACOD
	left join Zoologic.PLANCUENTA PC on PC.CTACODIGO = D.PCUENTA
	where A.fecha between @FechaDesde 
		and @FechaHasta
		and PC.AJUSTAINF = @EsDeAjustePorInflacion
		and case when @TiposDeAsientos = 3 then @TiposDeAsientos else A.TIPOASIENT end = @TiposDeAsientos
	group by D.PCUENTA, D.CODCCOS, D.PCUENTAD, PC.CAJUSTE, PC.INDICEAJU

	update @tblRetorno set CuentaDebe = Cuenta, Monto = MontoDebe - MontoHaber where MontoDebe > MontoHaber
	update @tblRetorno set CuentaHaber = Cuenta, Monto = MontoHaber - MontoDebe where MontoHaber > MontoDebe
		
	delete @tblRetorno where Monto = 0
	
	select * from @tblRetorno
	order by CuentaHaber, CuentaDebe
end

--exec [Contabilidad].[sp_ObtenerAsientos] 'DRAGONFISH_DEMO', '20110128', '20190628', 1
