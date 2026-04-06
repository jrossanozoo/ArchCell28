IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerTipoDeComprobanteAsociadoALaEntidad]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerTipoDeComprobanteAsociadoALaEntidad];
GO;

CREATE FUNCTION [Funciones].[ObtenerTipoDeComprobanteAsociadoALaEntidad]
( @Entidad varchar(40) )
RETURNS numeric(2,0)
AS
BEGIN
declare @retorno numeric(2,0)
set @retorno = 
case upper(@Entidad)
	when 'FACTURA' then 1
	when 'NOTADECREDITO' then 3
	when 'NOTADEDEBITO' then 4
	else 0
end
return @retorno

END