IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerObsComprobantesCtaCteCompras]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerObsComprobantesCtaCteCompras];
GO;

CREATE FUNCTION [Funciones].[ObtenerObsComprobantesCtaCteCompras]
(  @GUID char(38) )
RETURNS char(250)
AS

BEGIN
	
	declare @retorno varchar (250)
	
	if @GUID is null
		set @retorno = null
	else
		set @retorno = 
			(
				select fobs from zoologic.faccompra where codigo =  @GUID 
				union all
				select fobs from zoologic.nccompra  where codigo =  @GUID 
				union all
				select fobs from zoologic.NdCompra  where codigo =  @GUID 
				union all
				select funciones.alltrim( fobs ) + ' ' + funciones.alltrim (fopobs ) from zoologic.pago where codigo = @GUID
				union all
				select fobs from ZooLogic.ordpago where codigo = @GUID
				union all
				select fobs from ZooLogic.comppago where codigo = @GUID
				union all
				select fobs from ZooLogic.ajuccpro where codigo = @GUID
			)
	
	return @retorno
END