
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Listados].[HER_ADT_STOCKCOMBINACION_CMV_ADT_STOCKCOMBINACION]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Listados].[HER_ADT_STOCKCOMBINACION_CMV_ADT_STOCKCOMBINACION];
GO;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[ObtenerEjercicioDeAperturaAsociadoAlEjercicioDeCierre]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[ObtenerEjercicioDeAperturaAsociadoAlEjercicioDeCierre];
GO;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[CMV_ObtenerStockYPrecioInicialesEnAperturaEjercicio]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[CMV_ObtenerStockYPrecioInicialesEnAperturaEjercicio];
GO;
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[CMV_ObtenerCostosComprobantesMuevenStockEntreFechas]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[CMV_ObtenerCostosComprobantesMuevenStockEntreFechas];
GO;
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[CMV_ObtenerCostoDelStockEnProcesoSegunCosteo]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[CMV_ObtenerCostoDelStockEnProcesoSegunCosteo];
GO;
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[CMV_ObtenerCostoDeLaCombinacionAFecha]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[CMV_ObtenerCostoDeLaCombinacionAFecha];
GO;
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[CMV_ObtenerComprobantesAfectadosPorNC]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[CMV_ObtenerComprobantesAfectadosPorNC];
GO;
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[CMV_ArmarAsientos_CostoMercaderiaVendida]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[CMV_ArmarAsientos_CostoMercaderiaVendida];
GO;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[sp_ObtenerEjercicioSegunRangoDeFechas]') AND type in (N'P'))
	DROP PROCEDURE [Contabilidad].[sp_ObtenerEjercicioSegunRangoDeFechas];
GO;
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[sp_CMV_ObtenerStockYPrecioDeArticulosComprados]') AND type in (N'P'))
	DROP PROCEDURE [Contabilidad].[sp_CMV_ObtenerStockYPrecioDeArticulosComprados];
GO;
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[sp_CMV_ObtenerSaldosStockAlCerrarEjercicio]') AND type in (N'P'))
	DROP PROCEDURE [Contabilidad].[sp_CMV_ObtenerSaldosStockAlCerrarEjercicio];
GO;
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[sp_CMV_ObtenerSaldosInicialesDeArticulosComprados]') AND type in (N'P'))
	DROP PROCEDURE [Contabilidad].[sp_CMV_ObtenerSaldosInicialesDeArticulosComprados];
GO;
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[sp_CMV_ObtenerSaldosInicialesCostoMercaderiaVendida]') AND type in (N'P'))
	DROP PROCEDURE [Contabilidad].[sp_CMV_ObtenerSaldosInicialesCostoMercaderiaVendida];
GO;
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[sp_CMV_ObtenerMovimientosDeArticulosComprados]') AND type in (N'P'))
	DROP PROCEDURE [Contabilidad].[sp_CMV_ObtenerMovimientosDeArticulosComprados];
GO;
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[sp_CMV_ObtenerFechaDeInicioDelEjercicio]') AND type in (N'P'))
	DROP PROCEDURE [Contabilidad].[sp_CMV_ObtenerFechaDeInicioDelEjercicio];
GO;
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[sp_CMV_ObtenerFacturasAsociadasANotasDeCredito]') AND type in (N'P'))
	DROP PROCEDURE [Contabilidad].[sp_CMV_ObtenerFacturasAsociadasANotasDeCredito];
GO;
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[sp_CMV_ObtenerCostoYUltimaFacturaDeCompraPorArticulo]') AND type in (N'P'))
	DROP PROCEDURE [Contabilidad].[sp_CMV_ObtenerCostoYUltimaFacturaDeCompraPorArticulo];
GO;
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[sp_CMV_ObtenerComprobantesDeCompra]') AND type in (N'P'))
	DROP PROCEDURE [Contabilidad].[sp_CMV_ObtenerComprobantesDeCompra];
GO;
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[sp_CMV_ObtenerCompAsociadosANotasDeCredito]') AND type in (N'P'))
	DROP PROCEDURE [Contabilidad].[sp_CMV_ObtenerCompAsociadosANotasDeCredito];
GO;
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[sp_CMV_ObtenerCambiosDeStockPorComprobante]') AND type in (N'P'))
	DROP PROCEDURE [Contabilidad].[sp_CMV_ObtenerCambiosDeStockPorComprobante];
GO;
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[sp_CMV_ObtenerArticulosCompradosPorComprobante]') AND type in (N'P'))
	DROP PROCEDURE [Contabilidad].[sp_CMV_ObtenerArticulosCompradosPorComprobante];
GO;
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[sp_CMV_ImportarSaldosIniciales]') AND type in (N'P'))
	DROP PROCEDURE [Contabilidad].[sp_CMV_ImportarSaldosIniciales];
GO;
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[sp_CMV_ArmarAsientos]') AND type in (N'P'))
	DROP PROCEDURE [Contabilidad].[sp_CMV_ArmarAsientos];
GO;



---------------
-- Creo los nuevos tipos de datos
---------------


IF EXISTS(SELECT 1 FROM sys.types WHERE name = 'udt_TableType_CMVTipoCompMovStock' AND is_table_type = 1 AND SCHEMA_ID('Contabilidad') = schema_id)
	DROP TYPE Contabilidad.udt_TableType_CMVTipoCompMovStock;
GO;
CREATE TYPE Contabilidad.udt_TableType_CMVTipoCompMovStock AS TABLE
(
	[Id] [int] NULL,
	[GlobalId] [char](20) NULL,
	[Codigo] [char](38) NULL,
	[FactTipo] [numeric](2,0) NULL,
	[Articulo] [char](15) NULL,
	[Color] [char](6) NULL,
	[Talle] [char](5) NULL,
	[Fecha] [datetime] NULL,
	[Letra] [varchar](2) NULL,
	[PtoVenExt] [numeric](5,0) NULL,
	[NumComp] [numeric](8,0) NULL,
	[PtoVen] [numeric](4,0) NULL,
	[NumInt] [numeric](10,0) NULL,
	[Cantidad] [numeric](8,2) NULL,
	[Precio] [numeric](15,4) NULL,
	[Timestamp] [numeric](20,0) NULL,
	[Descrip] [varchar](200) NULL,
	[Base] [varchar](21) NULL
)
GO;

IF EXISTS(SELECT 1 FROM sys.types WHERE name = 'udt_TableType_CMVStockComp' AND is_table_type = 1 AND SCHEMA_ID('Contabilidad') = schema_id)
	DROP TYPE Contabilidad.udt_TableType_CMVStockComp;
GO;
CREATE TYPE Contabilidad.udt_TableType_CMVStockComp AS TABLE
(
	[Id] [int] identity (1,1),
	[BD] [varchar](8) NULL,
	[Referencia] [char](20) NULL,
	[CompTipo] [numeric](2,0) NULL,
	[CompCodigo] [char](38) NULL,
	[Articulo] [char](15) NULL,
	[Color] [char](6) NULL,
	[Talle] [char](5) NULL,
	[Cantidad] [numeric](15, 2) NULL,
	[Costo] [numeric](15, 2) NULL,
	[Fecha] [datetime] NULL,
	[RelaFactTipo] [numeric](2,0) NULL,
	[RelaLetra] [varchar](2) NULL,
	[RelaPtoVenta] [numeric](5,0) NULL,
	[RelaNumComp] [numeric](8,0) NULL,
	[RelaComprob] [varchar](200) NULL,
	[CostoTotal] [numeric](15,2) NULL,
	[Stock] [numeric](15,2) NULL,
	[CostoUnitarioInventario] [numeric](15,2) NULL,
	[CostoTotalInventario] [numeric](15,2) NULL
)
GO;

IF EXISTS(SELECT 1 FROM sys.types WHERE name = 'udt_TableType_CMVMovimientos' AND is_table_type = 1 AND SCHEMA_ID('Contabilidad') = schema_id)
	DROP TYPE Contabilidad.udt_TableType_CMVMovimientos;
GO;
CREATE TYPE Contabilidad.udt_TableType_CMVMovimientos AS TABLE
(
	[Id] [int] identity (1,1),
	[BD] [varchar](8) NULL,
	[Referencia] [char](20) NULL,
	[Articulo] [char](15) NULL,
	[Color] [char](6) NULL,
	[Talle] [char](5) NULL,
	[Cantidad] [numeric](15, 2) NULL,
	[Stock] [numeric](15, 2) NULL,
	[Precio] [numeric](15, 2) NULL, 
	[Fecha] [datetime] NULL,
	[Timestampa] [numeric](20,0) NULL,
	[CompTipo] [numeric](2,0) NULL,
	[CompCodigo] [char](38) NULL,
	[Comprobante] [varchar](200) NULL,
	[RelaFactTipo] [numeric](2,0) NULL,
	[RelaLetra] [varchar](2) NULL,
	[RelaPtoVenta] [numeric](5,0) NULL,
	[RelaNumComp] [numeric](8,0) NULL,
	[RelaComprob] [varchar](200) NULL,
	[CostoInvAnt] [numeric](15,2) NULL,
	[CostoInvAcum] [numeric](15,2) NULL,
	[NCStockAfectado] [numeric](15,2) NULL 
)
GO;

IF EXISTS(SELECT 1 FROM sys.types WHERE name = 'udt_TableType_CMVDescComprobante' AND is_table_type = 1 AND SCHEMA_ID('Contabilidad') = schema_id)
	DROP TYPE Contabilidad.udt_TableType_CMVDescComprobante;
GO;
CREATE TYPE Contabilidad.udt_TableType_CMVDescComprobante as TABLE
(
	[Codigo] [char](38) NULL,
	[FactTipo] [numeric](2,0) NULL,
	[Fecha] [datetime] NULL,
	[Letra] [varchar](2) NULL,
	[PtoVenExt] [numeric](5,0) NULL,
	[NumComp] [numeric](8,0) NULL,
	[PtoVen] [numeric](4,0) NULL,
	[NumInt] [numeric](10,0) NULL,
	[Descrip] [varchar](200) NULL,
	[Timestamp] [numeric](20,0) NULL
)
GO;

IF EXISTS(SELECT 1 FROM sys.types WHERE name = 'udt_TableType_CMVCompAsociados' AND is_table_type = 1 AND SCHEMA_ID('Contabilidad') = schema_id)
	DROP TYPE Contabilidad.udt_TableType_CMVCompAsociados;
GO;
CREATE TYPE Contabilidad.udt_TableType_CMVCompAsociados AS TABLE
(
	[Articulo] [char](15) NULL,
	[Color] [char](6) NULL,
	[Talle] [char](5) NULL,
	[Cantidad] [numeric](10, 2) NULL,
	[Descfw] [varchar](200) NULL, 
	[Fecha] [datetime] NULL,
	[CompTipo] [numeric](2,0) NULL,
	[CompCodigo] [char](38) NULL,
	[Comprobante] [varchar](200) NULL
)
GO;

IF EXISTS(SELECT 1 FROM sys.types WHERE name = 'udt_TableType_CMVInfoResultado' AND is_table_type = 1 AND SCHEMA_ID('Contabilidad') = schema_id)
	DROP TYPE Contabilidad.udt_TableType_CMVInfoResultado;
GO;
CREATE TYPE Contabilidad.udt_TableType_CMVInfoResultado AS TABLE
(
	[BD] [varchar](8) NULL,
	[Referencia] [char](20) NULL,
	[Codigo] [char](26) NULL,
	[Articulo] [char](15) NULL, 
	[Color] [char](6) NULL,
	[Talle] [char](5) NULL,
	[Cantidad] [numeric](15,2) NULL,
	[Stock] [numeric](15,2) NULL,
	[CostoUnitario] [numeric](15,2) NULL,
	[Fecha] [datetime] NULL,
	[CompTipo] [numeric](2,0) NULL,
	[CompCodigo] [char](38) NULL,
	[CompDesc] [varchar](200) NULL,
	[CostoInvAnt] [numeric](15,2) NULL,
	[CostoInvAcum] [numeric](15,2) NULL
)
GO;
