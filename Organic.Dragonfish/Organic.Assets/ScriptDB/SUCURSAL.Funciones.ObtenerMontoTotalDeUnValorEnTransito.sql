IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerMontoTotalDeUnValorEnTransito]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerMontoTotalDeUnValorEnTransito];
GO;

CREATE FUNCTION [Funciones].[ObtenerMontoTotalDeUnValorEnTransito]
	( 
	@CodigoValorEnTransito char( 20 )
	)
RETURNS numeric(15, 2)
AS
BEGIN

	declare @retorno numeric(15, 2);

	set @retorno = isnull((
							select sum( c_ITEMVALORESENTRANSITO.MONTO * c_VALORESENTRANSITO.Cotiz )
							from ZooLogic.VTRANSDET as c_ITEMVALORESENTRANSITO
							inner join ZooLogic.VTRANS c_VALORESENTRANSITO on c_VALORESENTRANSITO.CODIGO = c_ITEMVALORESENTRANSITO.CODDETVAL
							where ( not c_ITEMVALORESENTRANSITO.CodDetVal is null ) 
								and ( c_ITEMVALORESENTRANSITO.CodDetVal = @CodigoValorEnTransito )
							), 0 );
	return @retorno

END

