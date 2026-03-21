IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerDescripcionTipoAutorizacionTelefonica]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerDescripcionTipoAutorizacionTelefonica];
GO;

CREATE FUNCTION [Funciones].[ObtenerDescripcionTipoAutorizacionTelefonica]
( @AutorizacionTelefonicaOffLine  int )
RETURNS varchar (8)
AS
BEGIN
declare @retorno varchar(8)
set @retorno =
case @AutorizacionTelefonicaOffLine
	when 0 then 'ON-LINE '
	when 1 then 'OFF-LINE'
	else space(8)
end
return @retorno

END