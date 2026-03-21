IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerCotizacionDesdeUnComprobante]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[ObtenerCotizacionDesdeUnComprobante];
GO;

CREATE FUNCTION [Funciones].[ObtenerCotizacionDesdeUnComprobante]
( @NroSecuencia char(2) ,
  @CodigoTipo numeric(2) ,
  @CodigoLetra char(1) ,
  @CodigoPuntoVenta numeric(4) ,
  @CodigoNumero numeric(8) 
)

RETURNS numeric(15,5)
AS
BEGIN

declare @retorno numeric(15,5)

if @CodigoTipo = 13
	set @retorno =  ( select cotiz 
						from ZooLogic.Recibo 
						where FACTTIPO = @CodigoTipo		and
							FLETRA     = @CodigoLetra		and
							FPTOVEN    = @CodigoPuntoVenta	and
							FNUMCOMP   = @CodigoNumero ) 
else
	set @retorno =  ( select cotizdesp 
						from ZooLogic.Comprobantev 
						where FACTSEC  = @NroSecuencia  	and
							  FACTTIPO = @CodigoTipo		and
							  FLETRA   = @CodigoLetra		and
							  FPTOVEN  = @CodigoPuntoVenta	and
							  FNUMCOMP = @CodigoNumero )

return isnull( @retorno, 0 )

END
