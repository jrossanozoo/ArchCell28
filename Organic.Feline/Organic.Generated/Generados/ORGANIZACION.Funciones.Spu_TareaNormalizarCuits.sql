IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[Spu_TareaNormalizarCuits]') AND type in (N'P'))
DROP PROCEDURE [Funciones].[Spu_TareaNormalizarCuits]
GO;

CREATE PROCEDURE [Funciones].[Spu_TareaNormalizarCuits]
	as
	begin
		SET NOCOUNT ON
	end

GO;
