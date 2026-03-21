IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerCantidadDiferenciaDeUnPicking]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerCantidadDiferenciaDeUnPicking];
GO;

CREATE FUNCTION [Funciones].[ObtenerCantidadDiferenciaDeUnPicking]
	( 
	@CodigoPicking numeric(10, 0)
	)
RETURNS numeric(16, 3)
AS
BEGIN

	declare @retorno numeric(16, 3);

	set @retorno = isnull((
			select sum( c_ITEMDIFERENCIASPICKING.DPCANTIDAD ) as ITEMDIFERENCIASPICKING_DPCantidad
			from ZooLogic.DETDIFPICKING as c_ITEMDIFERENCIASPICKING
			inner join ZooLogic.PICKING as C_PICKING_CABECERA on C_PICKING_CABECERA.CODIGO = c_ITEMDIFERENCIASPICKING.CODIGO
			where ( not 1 = funciones.empty( c_picking_cabecera.codigo ) )  
				and ( C_PICKING_CABECERA.NUMERO = @CodigoPicking )
				and ( sign( c_ITEMDIFERENCIASPICKING.DPCANTIDAD ) > 0 )
			), 0 );
	return @retorno
END

