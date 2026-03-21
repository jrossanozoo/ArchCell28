---------------
-- Elimina todas las funciones y los tipos de datos utilizados en la version anterior del costo de mercaderia vendida.
-- Se reemplazo por metodos y tipos de datos asociados a contabilidad en vez de a funciones.
---------------

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[sp_CMV_CrearCompAsociadosTablasAgrupadas]') AND type in (N'P'))
DROP PROCEDURE [Funciones].[sp_CMV_CrearCompAsociadosTablasAgrupadas];
GO;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[sp_CMV_CrearComprasTablasAgrupadas]') AND type in (N'P'))
DROP PROCEDURE [Funciones].[sp_CMV_CrearComprasTablasAgrupadas];
GO;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[sp_CMV_CrearMovimientosTablasAgrupadas]') AND type in (N'P'))
DROP PROCEDURE [Funciones].[sp_CMV_CrearMovimientosTablasAgrupadas];
GO;

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[sp_CMV_CrearSaldosInicialesTablasAgrupadas]') AND type in (N'P'))
DROP PROCEDURE [Funciones].[sp_CMV_CrearSaldosInicialesTablasAgrupadas];
GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[CMV_ObtenerLosComprobantesDeStockEntreFechas]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[CMV_ObtenerLosComprobantesDeStockEntreFechas];
GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[CMV_ObtenerDatosParaCostoSaldoInicial]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[CMV_ObtenerDatosParaCostoSaldoInicial];
GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[CMV_ObtenerCostoDeLaCombinacionAFecha]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[CMV_ObtenerCostoDeLaCombinacionAFecha];
GO;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[CMV_ObtenerComprobantesAfectadosPorNC]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[CMV_ObtenerComprobantesAfectadosPorNC];
GO;

IF EXISTS(SELECT 1 FROM sys.types WHERE name = 'udt_TableType_CMVMovimientos' AND is_table_type = 1 AND SCHEMA_ID('Funciones') = schema_id)
	DROP TYPE Funciones.udt_TableType_CMVMovimientos;
GO;

IF EXISTS(SELECT 1 FROM sys.types WHERE name = 'udt_TableType_CMVStockComp' AND is_table_type = 1 AND SCHEMA_ID('Funciones') = schema_id)
	DROP TYPE Funciones.udt_TableType_CMVStockComp;
GO;

IF EXISTS(SELECT 1 FROM sys.types WHERE name = 'udt_TableType_CMVComprasCabDet' AND is_table_type = 1 AND SCHEMA_ID('Funciones') = schema_id)
	DROP TYPE Funciones.udt_TableType_CMVComprasCabDet;
GO;

IF EXISTS(SELECT 1 FROM sys.types WHERE name = 'udt_TableType_CMVAsociados' AND is_table_type = 1 AND SCHEMA_ID('Funciones') = schema_id)
	DROP TYPE Funciones.udt_TableType_CMVAsociados;
GO;
