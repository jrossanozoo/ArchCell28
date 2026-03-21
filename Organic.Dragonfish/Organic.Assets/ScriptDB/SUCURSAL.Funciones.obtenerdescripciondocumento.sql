IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerDescripcionDocumento]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerDescripcionDocumento];
GO;

CREATE FUNCTION [Funciones].[ObtenerDescripcionDocumento]
( @TipoDocumento varchar(2) )
RETURNS varchar (4)
AS
BEGIN
declare @retorno varchar(4)
set @retorno =
case 
	when @TipoDocumento = '01' then 'CUIT'
	when @TipoDocumento = '03' then 'LE  '
	when @TipoDocumento = '04' then 'LC  '
	when @TipoDocumento = '05' then 'DNI '
	when @TipoDocumento = '06' then 'PAS '
	when @TipoDocumento between '07' and '30' then 'CI  '
	else '    '
end
return @retorno

END