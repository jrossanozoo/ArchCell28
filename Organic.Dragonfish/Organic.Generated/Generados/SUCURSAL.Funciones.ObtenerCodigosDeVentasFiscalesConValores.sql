IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerCodigosDeVentasFiscalesConValores]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerCodigosDeVentasFiscalesConValores];
GO;

CREATE FUNCTION [Funciones].[ObtenerCodigosDeVentasFiscalesConValores]
( @Entidad varchar(40) )
RETURNS varchar (76)
AS
BEGIN
declare @retorno varchar (76)
set @retorno = '1, 2, 3, 4, 5, 6, 27, 28, 29, 33, 35, 36, 47, 48, 49, 51, 52, 53, 54, 55, 56'
return @retorno

END