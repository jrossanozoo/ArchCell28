IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Listados].[EstadoDeComprobantesDeCompras]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Listados].[EstadoDeComprobantesDeCompras];
GO;

CREATE FUNCTION [Listados].[EstadoDeComprobantesDeCompras]
( @FactTipo numeric(2,0) )
RETURNS TABLE
AS
RETURN
(
	with ComprobantesRelacionados( FactTipoRaiz, CodigoRaiz, ItemRaiz, FACTTIPO, CODIGO, NROITEM, AFE_COD, AFENROITEM, AFETIPOCOM, FCANT ) AS
	(
	SELECT det.FACTTIPO as FactTipoRaiz
		, det.CODIGO as CodigoRaiz
		, det.NROITEM as ItemRaiz
		, det.FACTTIPO
		, det.CODIGO
		, det.NROITEM
		, det.AFE_COD
		, det.AFENROITEM
		, det.AFETIPOCOM
		, det.FCANT
	from listados.VistaParcial_CircuitoCOMPRASDetEx as det 
	where 1=1
		-- and det.FCANT != 0
		-- and det.AFETIPOCOM = 0 -- Si activa esta condición trae solo los comprobantes del tipo @FactTipo que son la raíz de un circuito transaccional
		and det.FACTTIPO = @FactTipo
	union all
	select refrec.FacttipoRaiz
		, refrec.CodigoRaiz
		, refrec.ItemRaiz
		, subsecuente.FACTTIPO 
		, subsecuente.CODIGO
		, subsecuente.NROITEM
		, subsecuente.AFE_COD 
		, subsecuente.AFENROITEM
		, subsecuente.AFETIPOCOM
		, subsecuente.FCANT
	from listados.VistaParcial_CircuitoCOMPRASDetEx as subsecuente 
		inner join ComprobantesRelacionados as refrec on subsecuente.AFE_COD = refrec.CODIGO and subsecuente.AFENROITEM = refrec.NROITEM 
	) -- refrec: referencia recursiva
	
	select /*+ parallel */ sub.FactTipoRaiz, sub.CodigoRaiz, sub.ItemRaiz
		, sum( case when facttipo = 42 then fcant else 0 end ) as requerido,	sum( case when facttipo = 41 and afetipocom = 42 then fcant else 0 end ) as canreq
		, sum( case when facttipo = 39 then fcant else 0 end ) as solicitado,	sum( case when facttipo = 41 and afetipocom = 39 then fcant else 0 end ) as cansol
		, sum( case when facttipo = 30 then fcant else 0 end ) as presupuestado,sum( case when facttipo = 41 and afetipocom = 30 then fcant else 0 end ) as canpre
		, sum( case when facttipo = 38 then fcant else 0 end ) as pedido,		sum( case when facttipo = 41 and afetipocom = 38 then fcant else 0 end ) as canped
		, sum( case when facttipo = 40 then fcant else 0 end ) as remitido,		sum( case when facttipo = 41 and afetipocom = 40 then fcant else 0 end ) as canrem
		, sum( case when facttipo =  8 then fcant else 0 end ) as facturado,	sum( case when facttipo = 10 then fcant else 0 end ) as ncredito
	from ComprobantesRelacionados sub
	group by sub.FacttipoRaiz, sub.CodigoRaiz, sub.ItemRaiz
)