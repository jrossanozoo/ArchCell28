IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerResultado]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerResultado];
GO;

/****** Object:  UserDefinedFunction [Funciones].[ObtenerResultado]    Script Date: 28/11/2013 15:50:14 ******/
SET ANSI_NULLS ON
GO;
SET QUOTED_IDENTIFIER ON
GO;

CREATE FUNCTION [Funciones].[ObtenerResultado]( @tnStock numeric(16,3) )

RETURNS numeric(16,3)
	begin
		declare @Retorno numeric(16,3)
		
		set @Retorno = @tnStock

		return @Retorno

	end