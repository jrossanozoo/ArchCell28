---------------
-- Primero elimina todas las funciones que reciben como parámetro valores basados en los nuevos tipos de datos
---------------

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[ArmarAsientos_CanjesDeValores]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[ArmarAsientos_CanjesDeValores];
GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[ArmarAsientos_ComprobantesDeCaja]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[ArmarAsientos_ComprobantesDeCaja];
GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[ArmarAsientos_DescargasDeChequesDeTerceros]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[ArmarAsientos_DescargasDeChequesDeTerceros];
GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[ArmarAsientos_FacturasDeCompras]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[ArmarAsientos_FacturasDeCompras];
GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[ArmarAsientos_FacturasDeVentasDeExportacion]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[ArmarAsientos_FacturasDeVentasDeExportacion];
GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[ArmarAsientos_FacturasDeVentas]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[ArmarAsientos_FacturasDeVentas];
GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[ArmarAsientos_LiquidacionesDeTarjetas]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[ArmarAsientos_LiquidacionesDeTarjetas];
GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[ArmarAsientos_NotasDeCreditoDeCompras]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[ArmarAsientos_NotasDeCreditoDeCompras];
GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[ArmarAsientos_NotasDeDebitoDeCompras]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[ArmarAsientos_NotasDeDebitoDeCompras];
GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[ArmarAsientos_OtrosPagos]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[ArmarAsientos_OtrosPagos];
GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[ArmarAsientos_Pagos]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[ArmarAsientos_Pagos];
GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[ArmarAsientos_Recibos]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[ArmarAsientos_Recibos];
GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[ArmarAsientos_Transferencias]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[ArmarAsientos_Transferencias];
GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[ArmarAsientos_AjusteCCCliente]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[ArmarAsientos_AjusteCCCliente];
GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[ArmarAsientos_AjusteCCProveedor]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[ArmarAsientos_AjusteCCProveedor];
GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[ObtenerImputacionesContablesPorMotivo]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[ObtenerImputacionesContablesPorMotivo];
GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[ArmarAsientos_ChequesConciliados]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[ArmarAsientos_ChequesConciliados];
GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[ObtenerImputacionesContablesPorArticulo]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[ObtenerImputacionesContablesPorArticulo];
GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[ObtenerImputacionesContablesPorConceptoCaja]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[ObtenerImputacionesContablesPorConceptoCaja];
GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[ObtenerImputacionesContablesPorConceptoLiquidacion]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[ObtenerImputacionesContablesPorConceptoLiquidacion];
GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[ObtenerImputacionesContablesPorConceptoPago]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[ObtenerImputacionesContablesPorConceptoPago];
GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[ObtenerImputacionesContablesPorDestinoDescargaCheques]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[ObtenerImputacionesContablesPorDestinoDescargaCheques];
GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[ObtenerImputacionesContablesPorImpuesto]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[ObtenerImputacionesContablesPorImpuesto];
GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[ObtenerImputacionesContablesPorOperadoraDeTarjeta]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[ObtenerImputacionesContablesPorOperadoraDeTarjeta];
GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[ObtenerImputacionesContablesPorValor]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[ObtenerImputacionesContablesPorValor];
GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[ObtenerImputacionesContablesPorValorPorCliente]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[ObtenerImputacionesContablesPorValorPorCliente];
GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[ObtenerImputacionesContablesPorValorPorProveedor]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[ObtenerImputacionesContablesPorValorPorProveedor];
GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[ObtenerImputacionesContablesPorCuentaBancaria]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[ObtenerImputacionesContablesPorCuentaBancaria];
GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[ObtenerImputacionesParaCentrosDeCostosPorArticulo]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[ObtenerImputacionesParaCentrosDeCostosPorArticulo];
GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[ObtenerImputacionesParaCentrosDeCostosPorConceptoPago]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[ObtenerImputacionesParaCentrosDeCostosPorConceptoPago];
GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[ObtenerImputacionVerticalDeCentrosDeCostos]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[ObtenerImputacionVerticalDeCentrosDeCostos];
GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[ObtenerImputacionesContablesPorValorPorConceptoCaja]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[ObtenerImputacionesContablesPorValorPorConceptoCaja];
GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[ObtenerImputacionesContablesPorCuentaBancaria]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[ObtenerImputacionesContablesPorCuentaBancaria];
GO;


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[sp_ArmarAsientos]') AND type in (N'P'))
	DROP PROCEDURE [Contabilidad].[sp_ArmarAsientos];
GO;


------
-- Comienza a crear tipos de datos
------

IF EXISTS(SELECT 1 FROM sys.types WHERE name = 'udt_TableType_TipoComp' AND is_table_type = 1 AND SCHEMA_ID('Contabilidad') = schema_id)
	DROP TYPE Contabilidad.udt_TableType_TipoComp;
GO;

CREATE TYPE Contabilidad.udt_TableType_TipoComp AS TABLE
(
	[tipocomp] [numeric](3) NULL
)
GO;

IF EXISTS(SELECT 1 FROM sys.types WHERE name = 'udt_TableType_TipoFcCompra' AND is_table_type = 1 AND SCHEMA_ID('Contabilidad') = schema_id)
	DROP TYPE Contabilidad.udt_TableType_TipoFcCompra;
GO;

CREATE TYPE Contabilidad.udt_TableType_TipoFcCompra AS TABLE
(
	[tcrg1361] [numeric](2) NULL,
	[descr] [varchar](22) NULL
)
GO;


IF EXISTS(SELECT 1 FROM sys.types WHERE name = 'udt_TableType_Atipo' AND is_table_type = 1 AND SCHEMA_ID('Contabilidad') = schema_id)
	DROP TYPE Contabilidad.udt_TableType_Atipo;
GO;

CREATE TYPE Contabilidad.udt_TableType_Atipo AS TABLE
(
	[Codigo] [varchar](10) NULL,
	[Descrip] [varchar](70) NULL,
	[AsientoP] [numeric](1) NULL,
	[DiaDelMes] [numeric](2) NULL,
	[Leyenda] [numeric](1) NULL,
	[LeyProp] [varchar](100) NULL,
	[PorLetra] [numeric](1) NULL,
	[PorTipoC] [numeric](1) NULL,
	[Orden] [numeric](2) NULL
)
GO;

IF EXISTS(SELECT * FROM sys.objects WHERE name = 'sp_ObtenerConfiguracionDeAsientos_ATipo' AND type in (N'P') and SCHEMA_ID('Contabilidad') = schema_id)
	DROP PROCEDURE Contabilidad.sp_ObtenerConfiguracionDeAsientos_ATipo;
GO;
CREATE PROCEDURE [Contabilidad].[sp_ObtenerConfiguracionDeAsientos_ATipo] ( @NombreBaseDeDatos varchar(40) )
	as
	begin
		Declare @Sql nvarchar(max) = ''
		set @Sql = @Sql + 'select Codigo, Descrip, AsientoP, DiaDelMes, Leyenda, LeyProp, PorLetra, PorTipoC, Orden '
		set @Sql = @Sql + ' from ' + ltrim( rtrim( @NombreBaseDeDatos ) ) + '.zoologic.atipo'
		exec sp_executesql @Sql
	end
GO;



IF EXISTS(SELECT 1 FROM sys.types WHERE name = 'udt_TableType_Atipodet' AND is_table_type = 1 AND SCHEMA_ID('Contabilidad') = schema_id)
	DROP TYPE Contabilidad.udt_TableType_Atipodet;
GO;

CREATE TYPE Contabilidad.udt_TableType_Atipodet AS TABLE
(
	[Codigo] [varchar](10) NULL,
	[CodConc] [varchar](15) NULL,
	[CuentaDe] [varchar](30) NULL,
	[CuentaHa] [varchar](30) NULL
)
GO;

IF EXISTS(SELECT * FROM sys.objects WHERE name = 'sp_ObtenerConfiguracionDeAsientos_ATipoDet' AND type in (N'P') and SCHEMA_ID('Contabilidad') = schema_id)
	DROP PROCEDURE Contabilidad.sp_ObtenerConfiguracionDeAsientos_ATipoDet;
GO;
CREATE PROCEDURE [Contabilidad].[sp_ObtenerConfiguracionDeAsientos_ATipoDet] ( @NombreBaseDeDatos varchar(40), @AjustaPorInflacion bit = null  )
	as
	begin
		Declare @Sql nvarchar(max) = ''
		set @Sql = @Sql + 'select Codigo, CodConc, CuentaDe, CuentaHa '
		set @Sql = @Sql + ' from ' + ltrim( rtrim( @NombreBaseDeDatos ) ) + '.zoologic.atipodet'
		if @AjustaPorInflacion = 1
			set @Sql = @Sql + ' as a left join ' + ltrim( rtrim( @NombreBaseDeDatos ) ) + '.Zoologic.PlanCuenta as b on a.CuentaDe = b.CtaCodigo left join ' + ltrim( rtrim					( @NombreBaseDeDatos ) ) + '.ZooLogic.PlanCuenta as c on a.CuentaHa = c.CtaCodigo where b.AjustaInf = 1 or c.AjustaInf = 1';
		exec sp_executesql @Sql
	end
GO;




IF EXISTS(SELECT 1 FROM sys.types WHERE name = 'udt_TableType_PlanCuenta' AND is_table_type = 1 AND SCHEMA_ID('Contabilidad') = schema_id)
	DROP TYPE Contabilidad.udt_TableType_PlanCuenta;
GO;

CREATE TYPE Contabilidad.udt_TableType_PlanCuenta AS TABLE
(
	[CtaCodigo] [varchar](30) NULL,
	[Descrip] [varchar](100) NULL,
	[CtaMayor] [varchar](30) NULL,
	[CtaNumero] [varchar](30) NULL,
	[CtaImput] [bit] NULL,
	[CtaRefund] [bit] NULL,
	[ReqCCosto] [bit] NULL,
	[Apodo] [varchar](50) NULL,
	[DeRefund] [numeric](1) NULL,
	[CtaTipo] [numeric](1) NULL,
	[CAjuste] [char](30) NULL,
	[IndiceAju] [char](10) NULL
)
GO;

IF EXISTS(SELECT * FROM sys.objects WHERE name = 'sp_ObtenerConfiguracionDeAsientos_PlanCuenta' AND type in (N'P') and SCHEMA_ID('Contabilidad') = schema_id)
	DROP PROCEDURE Contabilidad.sp_ObtenerConfiguracionDeAsientos_PlanCuenta;
GO;
CREATE PROCEDURE [Contabilidad].[sp_ObtenerConfiguracionDeAsientos_PlanCuenta] ( @NombreBaseDeDatos varchar(40) )
	as
	begin
		Declare @Sql nvarchar(max) = ''
		set @Sql = @Sql + 'select CtaCodigo, Descrip, CtaMayor, CtaNumero, CtaImput, CtaRefund, ReqCCosto, Apodo, DeRefund, CtaTipo, CAjuste, IndiceAju '
		set @Sql = @Sql + ' from ' + ltrim( rtrim( @NombreBaseDeDatos ) ) + '.zoologic.PlanCuenta'
		exec sp_executesql @Sql
	end
GO;




IF EXISTS(SELECT 1 FROM sys.types WHERE name = 'udt_TableType_DDCCosto' AND is_table_type = 1 AND SCHEMA_ID('Contabilidad') = schema_id)
	DROP TYPE Contabilidad.udt_TableType_DDCCosto;
GO;

CREATE TYPE Contabilidad.udt_TableType_DDCCosto AS TABLE
(
	[Codigo] [varchar](20) NULL,
	[CodCCos] [varchar](20) NULL,
	[Porcenta] [numeric](6,2) NULL
)
GO;

IF EXISTS(SELECT * FROM sys.objects WHERE name = 'sp_ObtenerConfiguracionDeAsientos_DDCCosto' AND type in (N'P') and SCHEMA_ID('Contabilidad') = schema_id)
	DROP PROCEDURE Contabilidad.sp_ObtenerConfiguracionDeAsientos_DDCCosto;
GO;
CREATE PROCEDURE [Contabilidad].[sp_ObtenerConfiguracionDeAsientos_DDCCosto] ( @NombreBaseDeDatos varchar(40) )
	as
	begin
		Declare @Sql nvarchar(max) = ''
		set @Sql = @Sql + 'select Codigo, CodCCos, Porcenta '
		set @Sql = @Sql + ' from ' + ltrim( rtrim( @NombreBaseDeDatos ) ) + '.zoologic.DDCCosto'
		exec sp_executesql @Sql
	end
GO;




IF EXISTS(SELECT 1 FROM sys.types WHERE name = 'udt_TableType_ImpDirArt' AND is_table_type = 1 AND SCHEMA_ID('Contabilidad') = schema_id)
	DROP TYPE Contabilidad.udt_TableType_ImpDirArt;
GO;

CREATE TYPE Contabilidad.udt_TableType_ImpDirArt AS TABLE
(
	[anidesde] [numeric](4) NULL,
	[anihasta] [numeric](4) NULL,
	[artconiva] [numeric](1) NULL,
	[artdesde] [varchar](15) NULL,
	[arthasta] [varchar](15) NULL,
	[artiva] [numeric](1) NULL,
	[base] [varchar](21) NULL,
	[catdesde] [varchar](10) NULL,
	[cathasta] [varchar](10) NULL,
	[cladesde] [varchar](10) NULL,
	[clahasta] [varchar](10) NULL,
	[comp] [numeric](1) NULL,
	[famdesde] [varchar](10) NULL,
	[famhasta] [varchar](10) NULL,
	[fmodifw] [datetime] NULL,
	[grudesde] [varchar](10) NULL,
	[gruhasta] [varchar](10) NULL,
	[hmodifw] [varchar](8) NULL,
	[importanci] [numeric](5) NULL,
	[ivcdesde] [numeric](8,2) NULL,
	[ivchasta] [numeric](8,2) NULL,
	[ivvdesde] [numeric](8,2) NULL,
	[ivvhasta] [numeric](8,2) NULL,
	[lindesde] [varchar](10) NULL,
	[linhasta] [varchar](10) NULL,
	[matdesde] [varchar](10) NULL,
	[mathasta] [varchar](10) NULL,
	[pcuenta] [varchar](30) NULL,
	[prodesde] [varchar](10) NULL,
	[prohasta] [varchar](10) NULL,
	[sucdesde] [varchar](10) NULL,
	[suchasta] [varchar](10) NULL,
	[temdesde] [varchar](5) NULL,
	[temhasta] [varchar](5) NULL,
	[tipdesde] [varchar](10) NULL,
	[tiphasta] [varchar](10) NULL,
	[tipoasi] [numeric](1) NULL,
	[tsucdesde] [varchar](10) NULL,
	[tsuchasta] [varchar](10) NULL,
	[impdesde] [numeric](8,2) NULL,
	[imphasta] [numeric](8,2) NULL
)
GO;

IF EXISTS(SELECT * FROM sys.objects WHERE name = 'sp_ObtenerConfiguracionDeAsientos_ImpDirArt' AND type in (N'P') and SCHEMA_ID('Contabilidad') = schema_id)
	DROP PROCEDURE Contabilidad.sp_ObtenerConfiguracionDeAsientos_ImpDirArt;
GO;
CREATE PROCEDURE [Contabilidad].[sp_ObtenerConfiguracionDeAsientos_ImpDirArt] ( @NombreBaseDeDatos varchar(40) )
	as
	begin
		Declare @Sql nvarchar(max) = ''
		set @Sql = @Sql + 'select anidesde, anihasta, artconiva, artdesde, arthasta, artiva, base, catdesde, cathasta, cladesde, clahasta, '
		set @Sql = @Sql + '  comp, famdesde, famhasta, fmodifw, grudesde, gruhasta, hmodifw, importanci, ivcdesde, ivchasta, ivvdesde, ivvhasta, '
		set @Sql = @Sql + '  lindesde, linhasta, matdesde, mathasta, pcuenta, prodesde, prohasta, sucdesde, suchasta, temdesde, temhasta, tipdesde, '
		set @Sql = @Sql + '  tiphasta, tipoasi, tsucdesde, tsuchasta, impdesde, imphasta '
		set @Sql = @Sql + ' from ' + ltrim( rtrim( @NombreBaseDeDatos ) ) + '.zoologic.ImpDirArt'
		exec sp_executesql @Sql
	end
GO;




IF EXISTS(SELECT 1 FROM sys.types WHERE name = 'udt_TableType_ImpDirCaj' AND is_table_type = 1 AND SCHEMA_ID('Contabilidad') = schema_id)
	DROP TYPE Contabilidad.udt_TableType_ImpDirCaj;
GO;

CREATE TYPE Contabilidad.udt_TableType_ImpDirCaj AS TABLE
(
	[base] [varchar](21) NULL,
	[cladesde] [varchar](10) NULL,
	[clahasta] [varchar](10) NULL,
	[condesde] [varchar](10) NULL,
	[conhasta] [varchar](10) NULL,
	[fmodifw] [datetime] NULL,
	[hmodifw] [varchar](8) NULL,
	[importanci] [numeric](5) NULL,
	[pcuenta] [varchar](30) NULL,
	[sucdesde] [varchar](10) NULL,
	[suchasta] [varchar](10) NULL,
	[tsucdesde] [varchar](10) NULL,
	[tsuchasta] [varchar](10) NULL,
	[cbancdesde] [varchar](5) NULL,
	[cbanchasta] [varchar](5) NULL,
	[estadcarte] [bit] NULL,
	[estadentre] [bit] NULL,
	[estadcobra] [bit] NULL,
	[estaddepos] [bit] NULL,
	[estadrecha] [bit] NULL,
	[estadbaja] [bit] NULL,
	[estaddevol] [bit] NULL,
	[estadprepa] [bit] NULL,
	[estadenvia] [bit] NULL,
	[estadenvre] [bit] NULL,
	[estadtrans] [bit] NULL,
	[impval] [numeric](8) NULL
)
GO;

IF EXISTS(SELECT * FROM sys.objects WHERE name = 'sp_ObtenerConfiguracionDeAsientos_ImpDirCaj' AND type in (N'P') and SCHEMA_ID('Contabilidad') = schema_id)
	DROP PROCEDURE Contabilidad.sp_ObtenerConfiguracionDeAsientos_ImpDirCaj;
GO;
CREATE PROCEDURE [Contabilidad].[sp_ObtenerConfiguracionDeAsientos_ImpDirCaj] ( @NombreBaseDeDatos varchar(40) )
	as
	begin
		Declare @Sql nvarchar(max) = ''
		set @Sql = @Sql + 'select base, cladesde, clahasta, condesde, conhasta, fmodifw, hmodifw, importanci, pcuenta, sucdesde, suchasta, tsucdesde, tsuchasta, cbancdesde, cbanchasta, '
		set @Sql = @Sql + ' estadcarte, estadentre, estadcobra, estaddepos, estadrecha, estadbaja, estaddevol, estadprepa, estadenvia, estadenvre, estadtrans, impval '
		set @Sql = @Sql + ' from ' + ltrim( rtrim( @NombreBaseDeDatos ) ) + '.zoologic.ImpDirCaj'
		exec sp_executesql @Sql
	end
GO;




IF EXISTS(SELECT 1 FROM sys.types WHERE name = 'udt_TableType_ImpDirCli' AND is_table_type = 1 AND SCHEMA_ID('Contabilidad') = schema_id)
	DROP TYPE Contabilidad.udt_TableType_ImpDirCli;
GO;

CREATE TYPE Contabilidad.udt_TableType_ImpDirCli AS TABLE
(
	[catdesde] [varchar](10) NULL,
	[cathasta] [varchar](10) NULL,
	[cladesde] [varchar](10) NULL,
	[clahasta] [varchar](10) NULL,
	[clidesde] [varchar](10) NULL,
	[clihasta] [varchar](10) NULL,
	[fmodifw] [datetime] NULL,
	[hmodifw] [varchar](8) NULL,
	[importanci] [numeric](5) NULL,
	[impval] [numeric](8) NULL,
	[lisdesde] [varchar](6) NULL,
	[lishasta] [varchar](6) NULL,
	[paidesde] [varchar](3) NULL,
	[paihasta] [varchar](3) NULL,
	[pcuenta] [varchar](30) NULL,
	[prodesde] [varchar](2) NULL,
	[prohasta] [varchar](2) NULL,
	[sitfis] [numeric](2) NULL,
	[tipdesde] [varchar](10) NULL,
	[tiphasta] [varchar](10) NULL,
	[vendesde] [varchar](10) NULL,
	[venhasta] [varchar](10) NULL,
	[glodesde] [varchar](38) NULL,
	[glohasta] [varchar](38) NULL,
	[base] [varchar](21) NULL,
	[sucdesde] [varchar](10) NULL,
	[suchasta] [varchar](10) NULL,
	[tsucdesde] [varchar](10) NULL,
	[tsuchasta] [varchar](10) NULL
)
GO;

IF EXISTS(SELECT * FROM sys.objects WHERE name = 'sp_ObtenerConfiguracionDeAsientos_ImpDirCli' AND type in (N'P') and SCHEMA_ID('Contabilidad') = schema_id)
	DROP PROCEDURE Contabilidad.sp_ObtenerConfiguracionDeAsientos_ImpDirCli;
GO;
CREATE PROCEDURE [Contabilidad].[sp_ObtenerConfiguracionDeAsientos_ImpDirCli] ( @NombreBaseDeDatos varchar(40) )
	as
	begin
		Declare @Sql nvarchar(max) = ''
		set @Sql = @Sql + 'select catdesde, cathasta, cladesde, clahasta, clidesde, clihasta, fmodifw, hmodifw, importanci, impval, lisdesde, lishasta, '
		set @Sql = @Sql + '  paidesde, paihasta, pcuenta, prodesde, prohasta, sitfis, tipdesde, tiphasta, vendesde, venhasta, glodesde, glohasta, base, sucdesde, suchasta, tsucdesde, tsuchasta '
		set @Sql = @Sql + ' from ' + ltrim( rtrim( @NombreBaseDeDatos ) ) + '.zoologic.ImpDirCli'
		exec sp_executesql @Sql
	end
GO;

--******************

IF EXISTS(SELECT 1 FROM sys.types WHERE name = 'udt_TableType_ImpDirMot' AND is_table_type = 1 AND SCHEMA_ID('Contabilidad') = schema_id)
	DROP TYPE Contabilidad.udt_TableType_ImpDirMot;
GO;

CREATE TYPE Contabilidad.udt_TableType_ImpDirMot AS TABLE
(
	[motdesde] [varchar](3) NULL,
	[mothasta] [varchar](3) NULL,
	[fmodifw] [datetime] NULL,
	[hmodifw] [varchar](8) NULL,
	[importanci] [numeric](5) NULL,
	[pcuenta] [varchar](30) NULL,
	[base] [varchar](21) NULL,
	[sucdesde] [varchar](10) NULL,
	[suchasta] [varchar](10) NULL,
	[tsucdesde] [varchar](10) NULL,
	[tsuchasta] [varchar](10) NULL
)
GO;

IF EXISTS(SELECT * FROM sys.objects WHERE name = 'sp_ObtenerConfiguracionDeAsientos_ImpDirMot' AND type in (N'P') and SCHEMA_ID('Contabilidad') = schema_id)
	DROP PROCEDURE Contabilidad.sp_ObtenerConfiguracionDeAsientos_ImpDirMot;
GO;

CREATE PROCEDURE [Contabilidad].[sp_ObtenerConfiguracionDeAsientos_ImpDirMot] ( @NombreBaseDeDatos varchar(40) )
	as
	begin
		Declare @Sql nvarchar(max) = ''
		set @Sql = @Sql + 'select motdesde, mothasta, fmodifw, hmodifw, importanci, pcuenta, base, sucdesde, suchasta, tsucdesde, tsuchasta '
		set @Sql = @Sql + ' from ' + ltrim( rtrim( @NombreBaseDeDatos ) ) + '.zoologic.ImpDirMot'
		exec sp_executesql @Sql
	end
GO;

--******************


IF EXISTS(SELECT 1 FROM sys.types WHERE name = 'udt_TableType_ImpDirCon' AND is_table_type = 1 AND SCHEMA_ID('Contabilidad') = schema_id)
	DROP TYPE Contabilidad.udt_TableType_ImpDirCon;
GO;

CREATE TYPE Contabilidad.udt_TableType_ImpDirCon AS TABLE
(
	[cladesde] [varchar](15) NULL,
	[clahasta] [varchar](15) NULL,
	[condesde] [varchar](15) NULL,
	[conhasta] [varchar](15) NULL,
	[fmodifw] [datetime] NULL,
	[hmodifw] [varchar](8) NULL,
	[importanci] [numeric](5) NULL,
	[pcuenta] [varchar](30) NULL,
	[base] [varchar](21) NULL,
	[sucdesde] [varchar](10) NULL,
	[suchasta] [varchar](10) NULL,
	[tsucdesde] [varchar](10) NULL,
	[tsuchasta] [varchar](10) NULL
)
GO;

IF EXISTS(SELECT * FROM sys.objects WHERE name = 'sp_ObtenerConfiguracionDeAsientos_ImpDirCon' AND type in (N'P') and SCHEMA_ID('Contabilidad') = schema_id)
	DROP PROCEDURE Contabilidad.sp_ObtenerConfiguracionDeAsientos_ImpDirCon;
GO;
CREATE PROCEDURE [Contabilidad].[sp_ObtenerConfiguracionDeAsientos_ImpDirCon] ( @NombreBaseDeDatos varchar(40) )
	as
	begin
		Declare @Sql nvarchar(max) = ''
		set @Sql = @Sql + 'select cladesde, clahasta, condesde, conhasta, fmodifw, hmodifw, importanci, pcuenta, base, sucdesde, suchasta, tsucdesde, tsuchasta '
		set @Sql = @Sql + ' from ' + ltrim( rtrim( @NombreBaseDeDatos ) ) + '.zoologic.ImpDirCon'
		exec sp_executesql @Sql
	end
GO;




IF EXISTS(SELECT 1 FROM sys.types WHERE name = 'udt_TableType_ImpDirCue' AND is_table_type = 1 AND SCHEMA_ID('Contabilidad') = schema_id)
	DROP TYPE Contabilidad.udt_TableType_ImpDirCue;
GO;

CREATE TYPE Contabilidad.udt_TableType_ImpDirCue AS TABLE
(
	[fmodifw] [datetime] NULL,
	[hmodifw] [varchar](8) NULL,
	[importanci] [numeric](5) NULL,
	[cuedesde] [varchar](5) NULL,
	[cuehasta] [varchar](5) NULL,
	[nrodesde] [varchar](15) NULL,
	[nrohasta] [varchar](15) NULL,
	[pcuenta] [varchar](30) NULL,
	[base] [varchar](21) NULL,
	[sucdesde] [varchar](10) NULL,
	[suchasta] [varchar](10) NULL,
	[tsucdesde] [varchar](10) NULL,
	[tsuchasta] [varchar](10) NULL
)
GO;

IF EXISTS(SELECT * FROM sys.objects WHERE name = 'sp_ObtenerConfiguracionDeAsientos_ImpDirCue' AND type in (N'P') and SCHEMA_ID('Contabilidad') = schema_id)
	DROP PROCEDURE Contabilidad.sp_ObtenerConfiguracionDeAsientos_ImpDirCue;
GO;
CREATE PROCEDURE [Contabilidad].[sp_ObtenerConfiguracionDeAsientos_ImpDirCue] ( @NombreBaseDeDatos varchar(40) )
	as
	begin
		Declare @Sql nvarchar(max) = ''
		set @Sql = @Sql + 'select fmodifw, hmodifw, importanci, cuedesde, cuehasta, nrodesde, nrohasta, pcuenta, base, sucdesde, suchasta, tsucdesde, tsuchasta '
		set @Sql = @Sql + ' from ' + ltrim( rtrim( @NombreBaseDeDatos ) ) + '.zoologic.ImpDirCue'
		exec sp_executesql @Sql
	end
GO;




IF EXISTS(SELECT 1 FROM sys.types WHERE name = 'udt_TableType_ImpDirDes' AND is_table_type = 1 AND SCHEMA_ID('Contabilidad') = schema_id)
	DROP TYPE Contabilidad.udt_TableType_ImpDirDes;
GO;

CREATE TYPE Contabilidad.udt_TableType_ImpDirDes AS TABLE
(
	[desdesde] [varchar](10) NULL,
	[deshasta] [varchar](10) NULL,
	[fmodifw] [datetime] NULL,
	[hmodifw] [varchar](8) NULL,
	[importanci] [numeric](5) NULL,
	[pcuenta] [varchar](30) NULL,
	[base] [varchar](21) NULL,
	[sucdesde] [varchar](10) NULL,
	[suchasta] [varchar](10) NULL,
	[tsucdesde] [varchar](10) NULL,
	[tsuchasta] [varchar](10) NULL
)
GO;

IF EXISTS(SELECT * FROM sys.objects WHERE name = 'sp_ObtenerConfiguracionDeAsientos_ImpDirDes' AND type in (N'P') and SCHEMA_ID('Contabilidad') = schema_id)
	DROP PROCEDURE Contabilidad.sp_ObtenerConfiguracionDeAsientos_ImpDirDes;
GO;
CREATE PROCEDURE [Contabilidad].[sp_ObtenerConfiguracionDeAsientos_ImpDirDes] ( @NombreBaseDeDatos varchar(40) )
	as
	begin
		Declare @Sql nvarchar(max) = ''
		set @Sql = @Sql + 'select desdesde, deshasta, fmodifw, hmodifw, importanci, pcuenta, base, sucdesde, suchasta, tsucdesde, tsuchasta '
		set @Sql = @Sql + ' from ' + ltrim( rtrim( @NombreBaseDeDatos ) ) + '.zoologic.ImpDirDes'
		exec sp_executesql @Sql
	end
GO;




IF EXISTS(SELECT 1 FROM sys.types WHERE name = 'udt_TableType_ImpDirImp' AND is_table_type = 1 AND SCHEMA_ID('Contabilidad') = schema_id)
	DROP TYPE Contabilidad.udt_TableType_ImpDirImp;
GO;

CREATE TYPE Contabilidad.udt_TableType_ImpDirImp AS TABLE
(
	[aplicacion] [varchar](10) NULL,
	[fmodifw] [datetime] NULL,
	[hmodifw] [varchar](8) NULL,
	[impdesde] [varchar](10) NULL,
	[imphasta] [varchar](10) NULL,
	[importanci] [numeric](5) NULL,
	[jurdesde] [varchar](8) NULL,
	[jurhasta] [varchar](8) NULL,
	[pcuenta] [varchar](30) NULL,
	[tipdesde] [varchar](10) NULL,
	[tiphasta] [varchar](10) NULL,
	[tipoasi] [numeric](1) NULL,
	[base] [varchar](21) NULL,
	[sucdesde] [varchar](10) NULL,
	[suchasta] [varchar](10) NULL,
	[tsucdesde] [varchar](10) NULL,
	[tsuchasta] [varchar](10) NULL
)
GO;

IF EXISTS(SELECT * FROM sys.objects WHERE name = 'sp_ObtenerConfiguracionDeAsientos_ImpDirImp' AND type in (N'P') and SCHEMA_ID('Contabilidad') = schema_id)
	DROP PROCEDURE Contabilidad.sp_ObtenerConfiguracionDeAsientos_ImpDirImp;
GO;
CREATE PROCEDURE [Contabilidad].[sp_ObtenerConfiguracionDeAsientos_ImpDirImp] ( @NombreBaseDeDatos varchar(40) )
	as
	begin
		Declare @Sql nvarchar(max) = ''
		set @Sql = @Sql + 'select aplicacion, fmodifw, hmodifw, impdesde, imphasta, importanci, jurdesde, jurhasta, pcuenta, tipdesde, tiphasta, tipoasi, base, sucdesde, suchasta, tsucdesde, tsuchasta '
		set @Sql = @Sql + ' from ' + ltrim( rtrim( @NombreBaseDeDatos ) ) + '.zoologic.ImpDirImp'
		exec sp_executesql @Sql
	end
GO;




IF EXISTS(SELECT 1 FROM sys.types WHERE name = 'udt_TableType_ImpDirLiq' AND is_table_type = 1 AND SCHEMA_ID('Contabilidad') = schema_id)
	DROP TYPE Contabilidad.udt_TableType_ImpDirLiq;
GO;

CREATE TYPE Contabilidad.udt_TableType_ImpDirLiq AS TABLE
(
	[condesde] [varchar](50) NULL,
	[conhasta] [varchar](50) NULL,
	[fmodifw] [datetime] NULL,
	[hmodifw] [varchar](8) NULL,
	[importanci] [numeric](5) NULL,
	[pcuenta] [varchar](30) NULL,
	[base] [varchar](21) NULL,
	[sucdesde] [varchar](10) NULL,
	[suchasta] [varchar](10) NULL,
	[tsucdesde] [varchar](10) NULL,
	[tsuchasta] [varchar](10) NULL
)
GO;

IF EXISTS(SELECT * FROM sys.objects WHERE name = 'sp_ObtenerConfiguracionDeAsientos_ImpDirLiq' AND type in (N'P') and SCHEMA_ID('Contabilidad') = schema_id)
	DROP PROCEDURE Contabilidad.sp_ObtenerConfiguracionDeAsientos_ImpDirLiq;
GO;
CREATE PROCEDURE [Contabilidad].[sp_ObtenerConfiguracionDeAsientos_ImpDirLiq] ( @NombreBaseDeDatos varchar(40) )
	as
	begin
		Declare @Sql nvarchar(max) = ''
		set @Sql = @Sql + 'select condesde, conhasta, fmodifw, hmodifw, importanci, pcuenta, base, sucdesde, suchasta, tsucdesde, tsuchasta '
		set @Sql = @Sql + ' from ' + ltrim( rtrim( @NombreBaseDeDatos ) ) + '.zoologic.ImpDirLiq'
		exec sp_executesql @Sql
	end
GO;




IF EXISTS(SELECT 1 FROM sys.types WHERE name = 'udt_TableType_ImpDirOpe' AND is_table_type = 1 AND SCHEMA_ID('Contabilidad') = schema_id)
	DROP TYPE Contabilidad.udt_TableType_ImpDirOpe;
GO;

CREATE TYPE Contabilidad.udt_TableType_ImpDirOpe AS TABLE
(
	[fmodifw] [datetime] NULL,
	[hmodifw] [varchar](8) NULL,
	[importanci] [numeric](5) NULL,
	[opedesde] [varchar](15) NULL,
	[opehasta] [varchar](15) NULL,
	[pcuenta] [varchar](30) NULL,
	[base] [varchar](21) NULL,
	[sucdesde] [varchar](10) NULL,
	[suchasta] [varchar](10) NULL,
	[tsucdesde] [varchar](10) NULL,
	[tsuchasta] [varchar](10) NULL
)
GO;

IF EXISTS(SELECT * FROM sys.objects WHERE name = 'sp_ObtenerConfiguracionDeAsientos_ImpDirOpe' AND type in (N'P') and SCHEMA_ID('Contabilidad') = schema_id)
	DROP PROCEDURE Contabilidad.sp_ObtenerConfiguracionDeAsientos_ImpDirOpe;
GO;
CREATE PROCEDURE [Contabilidad].[sp_ObtenerConfiguracionDeAsientos_ImpDirOpe] ( @NombreBaseDeDatos varchar(40) )
	as
	begin
		Declare @Sql nvarchar(max) = ''
		set @Sql = @Sql + 'select fmodifw, hmodifw, importanci, opedesde, opehasta, pcuenta, base, sucdesde, suchasta, tsucdesde, tsuchasta '
		set @Sql = @Sql + ' from ' + ltrim( rtrim( @NombreBaseDeDatos ) ) + '.zoologic.ImpDirOpe'
		exec sp_executesql @Sql
	end
GO;




IF EXISTS(SELECT 1 FROM sys.types WHERE name = 'udt_TableType_ImpDirPro' AND is_table_type = 1 AND SCHEMA_ID('Contabilidad') = schema_id)
	DROP TYPE Contabilidad.udt_TableType_ImpDirPro;
GO;

CREATE TYPE Contabilidad.udt_TableType_ImpDirPro AS TABLE
(
	[cladesde] [varchar](10) NULL,
	[clahasta] [varchar](10) NULL,
	[fmodifw] [datetime] NULL,
	[hmodifw] [varchar](8) NULL,
	[importanci] [numeric](5) NULL,
	[impval] [numeric](8) NULL,
	[lisdesde] [varchar](6) NULL,
	[lishasta] [varchar](6) NULL,
	[paidesde] [varchar](3) NULL,
	[paihasta] [varchar](3) NULL,
	[pcuenta] [varchar](30) NULL,
	[prodesde] [varchar](10) NULL,
	[prohasta] [varchar](10) NULL,
	[prvdesde] [varchar](2) NULL,
	[prvhasta] [varchar](2) NULL,
	[sitfis] [numeric](2) NULL,
	[vendesde] [varchar](10) NULL,
	[venhasta] [varchar](10) NULL,
	[base] [varchar](21) NULL,
	[sucdesde] [varchar](10) NULL,
	[suchasta] [varchar](10) NULL,
	[tsucdesde] [varchar](10) NULL,
	[tsuchasta] [varchar](10) NULL
)
GO;

IF EXISTS(SELECT * FROM sys.objects WHERE name = 'sp_ObtenerConfiguracionDeAsientos_ImpDirPro' AND type in (N'P') and SCHEMA_ID('Contabilidad') = schema_id)
	DROP PROCEDURE Contabilidad.sp_ObtenerConfiguracionDeAsientos_ImpDirPro;
GO;
CREATE PROCEDURE [Contabilidad].[sp_ObtenerConfiguracionDeAsientos_ImpDirPro] ( @NombreBaseDeDatos varchar(40) )
	as
	begin
		Declare @Sql nvarchar(max) = ''
		set @Sql = @Sql + 'select cladesde, clahasta, fmodifw, hmodifw, importanci, impval, lisdesde, lishasta, paidesde, paihasta, '
		set @Sql = @Sql + '  pcuenta, prodesde, prohasta, prvdesde, prvhasta, sitfis, vendesde, venhasta, base, sucdesde, suchasta, tsucdesde, tsuchasta '
		set @Sql = @Sql + ' from ' + ltrim( rtrim( @NombreBaseDeDatos ) ) + '.zoologic.ImpDirPro'
		exec sp_executesql @Sql
	end
GO;




IF EXISTS(SELECT 1 FROM sys.types WHERE name = 'udt_TableType_ImpDirVal' AND is_table_type = 1 AND SCHEMA_ID('Contabilidad') = schema_id)
	DROP TYPE Contabilidad.udt_TableType_ImpDirVal;
GO;

CREATE TYPE Contabilidad.udt_TableType_ImpDirVal AS TABLE
(
	[fmodifw] [datetime] NULL,
	[hmodifw] [varchar](8) NULL,
	[importanci] [numeric](5) NULL,
	[mondesde] [varchar](10) NULL,
	[monhasta] [varchar](10) NULL,
	[numero] [numeric](8) NULL,
	[opedesde] [varchar](15) NULL,
	[opehasta] [varchar](15) NULL,
	[pcuenta] [varchar](30) NULL,
	[tipoasi] [numeric](1) NULL,
	[tipotarj] [varchar](1) NULL,
	[tipoval] [numeric](2) NULL,
	[valdesde] [varchar](5) NULL,
	[valhasta] [varchar](5) NULL,
	[base] [varchar](21) NULL,
	[sucdesde] [varchar](10) NULL,
	[suchasta] [varchar](10) NULL,
	[tsucdesde] [varchar](10) NULL,
	[tsuchasta] [varchar](10) NULL
)
GO;

IF EXISTS(SELECT * FROM sys.objects WHERE name = 'sp_ObtenerConfiguracionDeAsientos_ImpDirVal' AND type in (N'P') and SCHEMA_ID('Contabilidad') = schema_id)
	DROP PROCEDURE Contabilidad.sp_ObtenerConfiguracionDeAsientos_ImpDirVal;
GO;
CREATE PROCEDURE [Contabilidad].[sp_ObtenerConfiguracionDeAsientos_ImpDirVal] ( @NombreBaseDeDatos varchar(40) )
	as
	begin
		Declare @Sql nvarchar(max) = ''
		set @Sql = @Sql + 'select fmodifw, hmodifw, importanci, mondesde, monhasta, numero, opedesde, opehasta, pcuenta, tipoasi, tipotarj, tipoval, valdesde, valhasta, base, sucdesde, suchasta, tsucdesde, tsuchasta '
		set @Sql = @Sql + ' from ' + ltrim( rtrim( @NombreBaseDeDatos ) ) + '.zoologic.ImpDirVal'
		exec sp_executesql @Sql
	end
GO;




IF EXISTS(SELECT 1 FROM sys.types WHERE name = 'udt_TableType_ImpDirCCA' AND is_table_type = 1 AND SCHEMA_ID('Contabilidad') = schema_id)
	DROP TYPE Contabilidad.udt_TableType_ImpDirCCA;
GO;

CREATE TYPE Contabilidad.udt_TableType_ImpDirCCA AS TABLE
(
	[anidesde] [numeric](4) NULL,
	[anihasta] [numeric](4) NULL,
	[artconiva] [numeric](1) NULL,
	[artdesde] [varchar](15) NULL,
	[arthasta] [varchar](15) NULL,
	[artiva] [numeric](1) NULL,
	[catdesde] [varchar](10) NULL,
	[cathasta] [varchar](10) NULL,
	[cladesde] [varchar](10) NULL,
	[clahasta] [varchar](10) NULL,
	[comp] [numeric](1) NULL,
	[famdesde] [varchar](10) NULL,
	[famhasta] [varchar](10) NULL,
	[fmodifw] [datetime] NULL,
	[grudesde] [varchar](10) NULL,
	[gruhasta] [varchar](10) NULL,
	[hmodifw] [varchar](8) NULL,
	[importanci] [numeric](5) NULL,
	[ivcdesde] [numeric](8,2) NULL,
	[ivchasta] [numeric](8,2) NULL,
	[ivvdesde] [numeric](8,2) NULL,
	[ivvhasta] [numeric](8,2) NULL,
	[lindesde] [varchar](10) NULL,
	[linhasta] [varchar](10) NULL,
	[matdesde] [varchar](10) NULL,
	[mathasta] [varchar](10) NULL,
	[ccosto] [varchar](20) NULL,
	[dccosto] [varchar](20) NULL,
	[prodesde] [varchar](10) NULL,
	[prohasta] [varchar](10) NULL,
	[temdesde] [varchar](5) NULL,
	[temhasta] [varchar](5) NULL,
	[tipdesde] [varchar](10) NULL,
	[tiphasta] [varchar](10) NULL,
	[tipoasi] [numeric](1) NULL,
	[impdesde] [numeric](8,2) NULL,
	[imphasta] [numeric](8,2) NULL 
)
GO;

IF EXISTS(SELECT * FROM sys.objects WHERE name = 'sp_ObtenerConfiguracionDeAsientos_ImpDirCCA' AND type in (N'P') and SCHEMA_ID('Contabilidad') = schema_id)
	DROP PROCEDURE Contabilidad.sp_ObtenerConfiguracionDeAsientos_ImpDirCCA;
GO;
CREATE PROCEDURE [Contabilidad].[sp_ObtenerConfiguracionDeAsientos_ImpDirCCA] ( @NombreBaseDeDatos varchar(40) )
	as
	begin
		Declare @Sql nvarchar(max) = ''
		set @Sql = @Sql + 'select anidesde, anihasta, artconiva, artdesde, arthasta, artiva, catdesde, cathasta, cladesde, clahasta, '
		set @Sql = @Sql + '  comp, famdesde, famhasta, fmodifw, grudesde, gruhasta, hmodifw, importanci, ivcdesde, ivchasta, ivvdesde, ivvhasta, '
		set @Sql = @Sql + '  lindesde, linhasta, matdesde, mathasta, ccosto, dccosto, prodesde, prohasta, temdesde, temhasta, tipdesde, tiphasta, tipoasi, impdesde, imphasta '
		set @Sql = @Sql + ' from ' + ltrim( rtrim( @NombreBaseDeDatos ) ) + '.zoologic.ImpDirCCA'
		exec sp_executesql @Sql
	end
GO;




IF EXISTS(SELECT 1 FROM sys.types WHERE name = 'udt_TableType_ImpDirCCC' AND is_table_type = 1 AND SCHEMA_ID('Contabilidad') = schema_id)
	DROP TYPE Contabilidad.udt_TableType_ImpDirCCC;
GO;

CREATE TYPE Contabilidad.udt_TableType_ImpDirCCC AS TABLE
(
	[cladesde] [varchar](15) NULL,
	[clahasta] [varchar](15) NULL,
	[condesde] [varchar](15) NULL,
	[conhasta] [varchar](15) NULL,
	[fmodifw] [datetime] NULL,
	[hmodifw] [varchar](8) NULL,
	[importanci] [numeric](5) NULL,
	[ccosto] [varchar](20) NULL,
	[dccosto] [varchar](20) NULL
)
GO;

IF EXISTS(SELECT * FROM sys.objects WHERE name = 'sp_ObtenerConfiguracionDeAsientos_ImpDirCCC' AND type in (N'P') and SCHEMA_ID('Contabilidad') = schema_id)
	DROP PROCEDURE Contabilidad.sp_ObtenerConfiguracionDeAsientos_ImpDirCCC;
GO;
CREATE PROCEDURE [Contabilidad].[sp_ObtenerConfiguracionDeAsientos_ImpDirCCC] ( @NombreBaseDeDatos varchar(40) )
	as
	begin
		Declare @Sql nvarchar(max) = ''
		set @Sql = @Sql + 'select cladesde, clahasta, condesde, conhasta, fmodifw, hmodifw, importanci, ccosto, dccosto '
		set @Sql = @Sql + ' from ' + ltrim( rtrim( @NombreBaseDeDatos ) ) + '.zoologic.ImpDirCCC'
		exec sp_executesql @Sql
	end
GO;




IF EXISTS(SELECT 1 FROM sys.types WHERE name = 'udt_TableType_ImpVerCC' AND is_table_type = 1 AND SCHEMA_ID('Contabilidad') = schema_id)
	DROP TYPE Contabilidad.udt_TableType_ImpVerCC;
GO;

CREATE TYPE Contabilidad.udt_TableType_ImpVerCC AS TABLE
(
	[razdesde] [varchar](10) NULL,
	[razhasta] [varchar](10) NULL,
	[sucdesde] [varchar](10) NULL,
	[suchasta] [varchar](10) NULL,
	[base] [varchar](21) NULL,
	[tipoasi] [numeric](1) NULL,
	[fmodifw] [datetime] NULL,
	[hmodifw] [varchar](8) NULL,
	[mportancc] [numeric](5) NULL,
	[ccosto] [varchar](20) NULL,
	[disccos] [varchar](20) NULL
)
GO;

IF EXISTS(SELECT * FROM sys.objects WHERE name = 'sp_ObtenerConfiguracionDeAsientos_ImpVerCC' AND type in (N'P') and SCHEMA_ID('Contabilidad') = schema_id)
	DROP PROCEDURE Contabilidad.sp_ObtenerConfiguracionDeAsientos_ImpVerCC;
GO;
CREATE PROCEDURE [Contabilidad].[sp_ObtenerConfiguracionDeAsientos_ImpVerCC] ( @NombreBaseDeDatos varchar(40) )
	as
	begin
		Declare @Sql nvarchar(max) = ''
		set @Sql = @Sql + 'select razdesde, razhasta, sucdesde, suchasta, base, tipoasi, fmodifw, hmodifw, mportancc, ccosto, disccos '
		set @Sql = @Sql + ' from ' + ltrim( rtrim( @NombreBaseDeDatos ) ) + '.zoologic.ImpVerCC'
		exec sp_executesql @Sql
	end
GO;




IF EXISTS(SELECT 1 FROM sys.types WHERE name = 'udt_TableType_BasesAgrup' AND is_table_type = 1 AND SCHEMA_ID('Contabilidad') = schema_id)
	DROP TYPE Contabilidad.udt_TableType_BasesAgrup;
GO;

CREATE TYPE Contabilidad.udt_TableType_BasesAgrup AS TABLE
(
	[agrupamiento] [varchar](21) NULL,
	[basededatos] [varchar](8) NULL
)
GO;




IF EXISTS(SELECT 1 FROM sys.types WHERE name = 'udt_TableType_RazonSocialActual' AND is_table_type = 1 AND SCHEMA_ID('Contabilidad') = schema_id)
	DROP TYPE Contabilidad.udt_TableType_RazonSocialActual;
GO;

CREATE TYPE Contabilidad.udt_TableType_RazonSocialActual AS TABLE
(
	[RazonSocialActual] [varchar](10) NULL
)
GO;




IF EXISTS(SELECT * FROM sys.objects WHERE name = 'sp_ObtenerRazonSocialActual' AND type in (N'P') and SCHEMA_ID('Contabilidad') = schema_id)
	DROP PROCEDURE Contabilidad.sp_ObtenerRazonSocialActual;
GO;
CREATE PROCEDURE [Contabilidad].[sp_ObtenerRazonSocialActual] ( @NombreBaseDeDatosConConfiguraciones varchar(40), @CodigoBaseDeDatosActual varchar(8) )
	as
	begin
		Declare @Sql nvarchar(max) = ''
		set @Sql = @Sql + 'select razons '
		set @Sql = @Sql + ' from ' + ltrim( rtrim( @NombreBaseDeDatosConConfiguraciones ) ) + '.zoologic.arzbd'
		set @Sql = @Sql + ' where basededato = ''' + @CodigoBaseDeDatosActual + ''''
		exec sp_executesql @Sql
	end
GO;

