IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerCantidadContrapuestaEnUnReciboConResultadoEnCero]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[ObtenerCantidadContrapuestaEnUnReciboConResultadoEnCero];
GO;

CREATE FUNCTION [Funciones].[ObtenerCantidadContrapuestaEnUnReciboConResultadoEnCero]
( 
	@CodigoDeComprobante char(38)	
 )
RETURNS numeric(15,2)
AS
BEGIN
	declare @Resultado numeric(15,2) = 0.0;
	
	select @resultado = sum( abs( rdet.RMONTO ) ) / 2 from ZooLogic.RECIBOdet as rdet where rdet.CODIGO = @CodigoDeComprobante having sum( rdet.RMONTO ) = 0;
	
	return @Resultado;
END