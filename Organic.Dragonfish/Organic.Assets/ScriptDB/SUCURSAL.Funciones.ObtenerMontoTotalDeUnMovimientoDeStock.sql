IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerMontoTotalDeUnMovimientoDeStock]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerMontoTotalDeUnMovimientoDeStock];
GO;

CREATE FUNCTION [Funciones].[ObtenerMontoTotalDeUnMovimientoDeStock]
	( 
	@CodigoMovimientoDeStock numeric(10, 0),
	@CodigoLPrecio Varchar( 6 )
	)
RETURNS numeric(15, 2)
AS
BEGIN

	declare @retorno numeric(15, 2);

	set @retorno = isnull((
			select sum( c_ITEMMOVSTOCK.CANTI * Funciones.ObtenerPrecioDeLaCombinacionConVigencia( c_ITEMMOVSTOCK.MART, c_ITEMMOVSTOCK.CCOLOR, c_ITEMMOVSTOCK.TALLE, @CodigoLPrecio, cabecera.FECHA, default ) )
			from ZooLogic.DETMSTOCK as c_ITEMMOVSTOCK
			inner join ZooLogic.MSTOCK cabecera on cabecera.CODIGO = c_ITEMMOVSTOCK.NUMR 
			where ( not cabecera.NUMERO is null ) 
				and ( cabecera.NUMERO = @CodigoMovimientoDeStock )
			), 0 );
	return @retorno
END

