IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerMontoTotalDeUnComprobanteDeCaja]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerMontoTotalDeUnComprobanteDeCaja];
GO;

CREATE FUNCTION [Funciones].[ObtenerMontoTotalDeUnComprobanteDeCaja]
	( 
	@CodigoComprobanteDeCaja char( 20 )
	)
RETURNS numeric(15, 2)
AS
BEGIN

	declare @retorno numeric(15, 2);

	set @retorno = isnull((
							select sum( c_ITEMVALORESCAJA.MONTO * case when c_ITEMVALORESCAJA.Cotiza is null or c_ITEMVALORESCAJA.Cotiza = 0 then 1 else c_ITEMVALORESCAJA.Cotiza end * cabecera.SIGNOMOV  )
							from ZooLogic.COMPCAJADET as c_ITEMVALORESCAJA
							inner join ZooLogic.COMCAJ cabecera on cabecera.CODIGO = c_ITEMVALORESCAJA.CODDETVAL
							where ( not c_ITEMVALORESCAJA.CodDetVal is null ) 
								and ( c_ITEMVALORESCAJA.CodDetVal = @CodigoComprobanteDeCaja )
							), 0 );
	return @retorno
END

