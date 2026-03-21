IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerNombreDeComprobanteAuditoria]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerNombreDeComprobanteAuditoria];
GO;

CREATE FUNCTION [Funciones].[ObtenerNombreDeComprobanteAuditoria]
( @Comprobante varchar(50) )
RETURNS varchar (50)
AS
BEGIN
declare @retorno varchar (50)
set @retorno = 
replace(funciones.padr( rtrim( left( @Comprobante, Funciones.BuscarPosicionDeReferenciaAComprobanteValida( @Comprobante ) ) ), 50, ' ' ),'-','')
return @retorno

END