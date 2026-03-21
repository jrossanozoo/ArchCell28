IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerMontoRemitosPendientesDelCliente]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerMontoRemitosPendientesDelCliente];
GO;

CREATE FUNCTION [Funciones].[ObtenerMontoRemitosPendientesDelCliente]
(@Cliente as varchar(10), 
 @GuidAExcluir as varchar(38))
RETURNS TABLE
AS

RETURN
(
	select sum(( MNTPTOT * afesaldo / fcant )) as saldo_remitos
		from ZOOLOGIC.COMPROBANTEV  left join ZOOLOGIC.COMPROBANTEVDET on COMPROBANTEV.CODIGO = ZOOLOGIC.COMPROBANTEVDET.CODIGO 
		WHERE COMPROBANTEV.anulado = 0 and
  		    COMPROBANTEV.CODIGO != '' AND 
			COMPROBANTEV.FACTTIPO = 11 AND 
			COMPROBANTEV.FPERSON = @Cliente and
			COMPROBANTEVDET.AFESALDO > 0 and
			COMPROBANTEV.CODIGO != @GuidAExcluir and 
			AFE_COD not in (select codigo 
								from [ZooLogic].[COMPROBANTEV] 
								where ENTREGAPOS = 1 and COMPROBANTEV.FPERSON = @Cliente )
)