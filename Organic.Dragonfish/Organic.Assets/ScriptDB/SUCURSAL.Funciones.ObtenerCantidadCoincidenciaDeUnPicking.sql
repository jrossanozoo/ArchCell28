IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerCantidadCoincidenciaDeUnPicking]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerCantidadCoincidenciaDeUnPicking];
GO;

CREATE FUNCTION [Funciones].[ObtenerCantidadCoincidenciaDeUnPicking]
	( 
	@CodigoPicking numeric(10, 0)
	)
RETURNS numeric(15, 2)
AS
BEGIN

	declare @retorno numeric(15, 2);

	set @retorno = isnull((
			select sum( c_ITEMOKPICKING.OPCANTIDAD ) as ITEMOKPICKING_OPCantidad
			from ZooLogic.DETOKPICKING as c_ITEMOKPICKING
			inner join ZooLogic.PICKING as C_PICKING_CABECERA on C_PICKING_CABECERA.CODIGO = c_ITEMOKPICKING.CODIGO
			where ( not 1 = funciones.empty( c_picking_cabecera.codigo ) )  
				and ( C_PICKING_CABECERA.NUMERO = @CodigoPicking )
			), 0 );
	return @retorno
END

