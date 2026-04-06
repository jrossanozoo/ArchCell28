IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerNumeracionDeComprobanteAuditoria]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerNumeracionDeComprobanteAuditoria];
GO;

CREATE FUNCTION [Funciones].[ObtenerNumeracionDeComprobanteAuditoria]
( @Comprobante varchar(50) )
RETURNS varchar (20)
AS
BEGIN
declare @retorno varchar (20)
set @retorno = 
funciones.padr( ltrim( rtrim( substring( @Comprobante, Funciones.BuscarPosicionDeReferenciaAComprobanteValida( @Comprobante ), 50 ) ) ),20, ' ' )
return @retorno

END