IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[Spu_TareaAuditoriaPrecios]') AND type in (N'P'))
DROP PROCEDURE [Funciones].[Spu_TareaAuditoriaPrecios]
GO;

CREATE PROCEDURE [Funciones].[Spu_TareaAuditoriaPrecios]
	as
	begin
		SET NOCOUNT ON
		DELETE FROM [ZooLogic].[ADT_PRECIOAR] 
		WHERE PDIRORI = PDIRECTO
	end

GO;
