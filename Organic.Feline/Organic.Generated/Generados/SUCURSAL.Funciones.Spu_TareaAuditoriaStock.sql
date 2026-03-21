IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[Spu_TareaAuditoriaStock]') AND type in (N'P'))
DROP PROCEDURE [Funciones].[Spu_TareaAuditoriaStock]
GO;

CREATE PROCEDURE [Funciones].[Spu_TareaAuditoriaStock]
	as
	begin
		SET NOCOUNT ON
		DELETE FROM [ZooLogic].[ADT_COMB] 
		WHERE COCANT = 0
		AND ENTRANSITO = 0
		AND PEDCOMPRA = 0
		AND PEDIDO = 0
		AND PRECOMPRA = 0
		AND PREPARADO = 0
		AND PRESUPUEST = 0
		AND REQCOMPRA = 0
		AND SENIADO = 0
		AND SOLCOMPRA = 0
	end

GO;
