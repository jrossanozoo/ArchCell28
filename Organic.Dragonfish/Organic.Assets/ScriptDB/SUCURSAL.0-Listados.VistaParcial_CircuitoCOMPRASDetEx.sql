IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[Listados].[VistaParcial_CircuitoCOMPRASDetEx]') AND type = N'V')
	DROP VIEW [Listados].[VistaParcial_CircuitoCOMPRASDetEx];
GO;

CREATE VIEW [Listados].[VistaParcial_CircuitoCOMPRASDetEx] AS
(
	select 41 as FACTTIPO, det.CODIGO, det.NROITEM, det.AFETIPOCOM, det.AFE_COD, det.AFENROITEM, det.FCANT from [ZooLogic].CANCOMPRADET as det
	union all
	select  8 as FACTTIPO, det.CODIGO, det.NROITEM, det.AFETIPOCOM, det.AFE_COD, det.AFENROITEM, det.FCANT from [ZooLogic].FACCOMPRADET as det
	union all
	select 10 as FACTTIPO, det.CODIGO, det.NROITEM, det.AFETIPOCOM, det.AFE_COD, det.AFENROITEM, det.FCANT from [ZooLogic].NCCOMPRADET  as det
	union all
	select 38 as FACTTIPO, det.CODIGO, det.NROITEM, det.AFETIPOCOM, det.AFE_COD, det.AFENROITEM, det.FCANT from [ZooLogic].PEDCOMPRADET as det
	union all
	select 30 as FACTTIPO, det.CODIGO, det.NROITEM, det.AFETIPOCOM, det.AFE_COD, det.AFENROITEM, det.FCANT from [ZooLogic].PRECOMPRADET as det
	union all
	select 40 as FACTTIPO, det.CODIGO, det.NROITEM, det.AFETIPOCOM, det.AFE_COD, det.AFENROITEM, det.FCANT from [ZooLogic].REMCOMPRADET as det
	union all
	select 42 as FACTTIPO, det.CODIGO, det.NROITEM, det.AFETIPOCOM, det.AFE_COD, det.AFENROITEM, det.FCANT from [ZooLogic].REQCOMPRADET as det
	union all
	select 39 as FACTTIPO, det.CODIGO, det.NROITEM, det.AFETIPOCOM, det.AFE_COD, det.AFENROITEM, det.FCANT from [ZooLogic].SOLCOMPRADET as det
)
