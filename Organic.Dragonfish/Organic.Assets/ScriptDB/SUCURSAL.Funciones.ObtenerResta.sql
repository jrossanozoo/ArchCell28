IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerResta]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerResta];
GO;

CREATE FUNCTION [Funciones].[ObtenerResta]
( @TnMinuendo numeric(15,2) , @TnSustraendo numeric(15,2)  )
RETURNS numeric(15,2)
AS
BEGIN
return (@TnMinuendo - @TnSustraendo)

END
