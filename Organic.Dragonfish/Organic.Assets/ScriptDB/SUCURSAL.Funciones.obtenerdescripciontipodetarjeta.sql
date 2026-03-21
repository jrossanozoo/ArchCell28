IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerDescripcionTipoDeTarjeta]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerDescripcionTipoDeTarjeta];
GO;

CREATE FUNCTION [Funciones].[ObtenerDescripcionTipoDeTarjeta]
( @TipoTarjeta varchar(1) )
RETURNS varchar (10)
AS
BEGIN
declare @retorno varchar(10)
set @retorno =
case @TipoTarjeta
	when 'C'  then 'CREDITO'
	when 'D'  then 'DEBITO '
	else space(10)
end
return @retorno

END

