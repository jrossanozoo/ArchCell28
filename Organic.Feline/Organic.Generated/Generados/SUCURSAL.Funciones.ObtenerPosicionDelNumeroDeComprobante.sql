IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerPosicionDelNumeroDeComprobante]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerPosicionDelNumeroDeComprobante];
GO;

CREATE FUNCTION [Funciones].[ObtenerPosicionDelNumeroDeComprobante]
( @TextoConPosibleReferenciaAComprobante varchar(254) )
RETURNS int
AS
BEGIN
    declare @PosicionEsquema int = Funciones.BuscarPosicionDeReferenciaAComprobanteValida( @TextoConPosibleReferenciaAComprobante );
    declare @Desplazamiento int = 1;
    
    if ( substring( @TextoConPosibleReferenciaAComprobante , @PosicionEsquema + 1, 1) = ' ' ) or ( upper( substring( @TextoConPosibleReferenciaAComprobante , @PosicionEsquema + 1, 1) ) like '%[A-Z]%' )
        set @Desplazamiento = 8;
    
    return @PosicionEsquema + @Desplazamiento

END