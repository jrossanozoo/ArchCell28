IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Interfaces].[Auxiliar_Icommkt_Cabecera_Orders]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Interfaces].[Auxiliar_Icommkt_Cabecera_Orders];
GO;

CREATE FUNCTION [Interfaces].[Auxiliar_Icommkt_Cabecera_Orders]
(
)
RETURNS TABLE
AS
RETURN
(
select distinct VAL2.JJNUM,
		SUBSTRING(
			(
				SELECT '##' + funciones.alltrim(P1.PROMO) AS [text()]
				FROM ZooLogic.PROMDET P1
				WHERE P1.CODIGO = VAL2.JJNUM
				ORDER BY P1.CODIGO
				FOR XML PATH ('')
			), 3, 1000) PROMOS,
		SUBSTRING (
			(
				select '##' + funciones.alltrim(V.jjco) as [text()]
				FROM ZooLogic.VAL as V
				WHERE V.JJNUM = VAL2.JJNUM
				FOR XML PATH ('')
			), 3, 1000) FORMADEPAGO,
		SUBSTRING (
			(
				select '##' + funciones.alltrim(VAL.CLNOM) as [text()]
				FROM (select V.JJNUM, V.NROITEM, XV.CLCOD, XV.CLNOM
				from ZooLogic.VAL as V
				inner join ZooLogic.XVAL as XV on V.JJCO = XV.CLCOD) as VAL
				WHERE VAL.JJNUM = VAL2.JJNUM
				FOR XML PATH ('')
			), 3, 1000) DESCVALOR,
		SUBSTRING (
			(
				select '##' + funciones.alltrim(EF.EFDES) as [text()]
				FROM ( select V.JJNUM, CUP.ENTFIN, E.EFDES
				from ZooLogic.VAL as V 
				inner join ZooLogic.CUPONES as CUP on V.JJNUM = CUP.COMP
				inner join ZooLogic.ENTFIN as E on CUP.ENTFIN = E.EFCOD) as EF
				where EF.JJNUM = VAL2.JJNUM
				FOR XML PATH ('')
			), 3, 1000) ENTIDADFINANCIERA,
		SUBSTRING (
			(
				select '##' + (case when CUP.CUOTAS = 1 then funciones.alltrim(cast(CUP.CUOTAS as varchar(2))) + 'CUOTA' else funciones.alltrim(cast(CUP.CUOTAS as varchar(2))) + 'CUOTAS' end) as [text()]
				from ZooLogic.CUPONES as CUP
				where CUP.COMP = VAL2.JJNUM
				FOR XML PATH ('')
			), 3, 1000) CUOTAS
FROM (select V.JJNUM, XV.CLCOD, XV.CLNOM
		from ZooLogic.VAL as V
		LEFT join ZooLogic.XVAL as XV on V.JJCO = XV.CLCOD
		LEFT join ZooLogic.GRUPOVALOR as GV on XV.CLGRUP = GV.CODIGO
		LEFT join ZooLogic.CUPONES as CUP on V.JJNUM = CUP.COMP
		LEFT join ZooLogic.ENTFIN as E on CUP.ENTFIN = E.EFCOD) as VAL2
)