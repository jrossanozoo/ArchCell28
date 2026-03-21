IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerDescripcionTipoDeCupon]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerDescripcionTipoDeCupon];
GO;

CREATE FUNCTION [Funciones].[ObtenerDescripcionTipoDeCupon]
( @TipoCupon varchar(2) )
RETURNS varchar (23)
AS
BEGIN
declare @retorno varchar(23)
set @retorno =
case @TipoCupon
	when 'C'  then 'COMPRA                 '
	when 'AC' then 'ANULACIÓN DE COMPRA    '
	when 'D'  then 'DEVOLUCIÓN             '
	when 'AD' then 'ANULACIÓN DE DEVOLUCIÓN'
	else space(23)
end
return @retorno

END