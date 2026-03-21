IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerCantidadTotalDeUnMovimientoDeStock]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerCantidadTotalDeUnMovimientoDeStock];
GO;

CREATE FUNCTION [Funciones].[ObtenerCantidadTotalDeUnMovimientoDeStock]
	( 
	@CodigoMovimientoDeStock numeric(10, 0)
	)
RETURNS numeric(16, 3)
AS
BEGIN

	declare @retorno numeric(16, 3);

	set @retorno = isnull((
			select sum( c_ITEMMOVSTOCK.CANTI )
			from ZooLogic.DETMSTOCK as c_ITEMMOVSTOCK
			inner join ZooLogic.MSTOCK cabecera on cabecera.CODIGO = c_ITEMMOVSTOCK.NUMR 
			where ( not cabecera.NUMERO is null ) 
				and ( cabecera.NUMERO = @CodigoMovimientoDeStock )
			), 0 );
	return @retorno
END

