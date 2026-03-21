IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerListaDeCostoProduccionParaListado]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[ObtenerListaDeCostoProduccionParaListado];
GO;

CREATE FUNCTION [Funciones].[ObtenerListaDeCostoProduccionParaListado]
( )
RETURNS varchar(6)
AS 
	begin
		Declare @cRetorno varchar(6)
		
   		Set @cRetorno = (select top 1 Funciones.Alltrim( p.valor ) from Parametros.Sucursal p where p.IDUNICO = '19B66F572131AA1404418B8019669345145691')
								--goparametros.felino.Generales.ListaDecostosPreferenteParaCotizacionesYLiquidacionesDeProduccion

		return @cRetorno
	End
 

