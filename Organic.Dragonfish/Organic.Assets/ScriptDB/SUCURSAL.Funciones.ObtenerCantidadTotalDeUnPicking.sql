IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerCantidadTotalDeUnPicking]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerCantidadTotalDeUnPicking];
GO;

CREATE FUNCTION [Funciones].[ObtenerCantidadTotalDeUnPicking]
	( 
	@CodigoPicking numeric(10, 0)
	)
RETURNS numeric(16, 3)
AS
BEGIN

	declare @retorno numeric(16, 3);

	set @retorno = isnull((
			select sum( c_ITEMCOMPROBANTESPICKING.CANTIDAD ) as ITEMCOMPROBANTESPICKING_Cantidad
			from ZooLogic.DETCOMPPICKING as c_ITEMCOMPROBANTESPICKING
			inner join ZooLogic.PICKING as C_PICKING_CABECERA on C_PICKING_CABECERA.CODIGO = c_ITEMCOMPROBANTESPICKING.CODIGO
			where ( not 1 = funciones.empty( c_picking_cabecera.codigo ) )  
				and ( C_PICKING_CABECERA.NUMERO = @CodigoPicking )
			), 0 );
	return @retorno
END

