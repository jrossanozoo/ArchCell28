IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerTablaDeOrigenDelRegistroComprobantesYGruposDeCaja]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerTablaDeOrigenDelRegistroComprobantesYGruposDeCaja];
GO;

CREATE FUNCTION [Funciones].[ObtenerTablaDeOrigenDelRegistroComprobantesYGruposDeCaja]
( @TipoDeComprobante varchar(2) )
RETURNS varchar (50)
AS
BEGIN
return cast( 'COMPROBANTEV' as varchar (50) )
END