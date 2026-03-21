IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerTotalDeMovimientosDelComprobanteAsociadoAlMovimientoDeCaja]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerTotalDeMovimientosDelComprobanteAsociadoAlMovimientoDeCaja];
GO;

CREATE FUNCTION [Funciones].[ObtenerTotalDeMovimientosDelComprobanteAsociadoAlMovimientoDeCaja]
	( 
	@TipoDeComprobanteDeCaja varchar(2),
	@PuntoDeVenta numeric(4, 0), 
	@NumeroDeCaja numeric(2, 0),
	@NumeroDeComprobante Numeric(9, 0),
	@Secuencia char(2),
	@Accion char(1) 
	)
RETURNS numeric(15, 2)
AS
BEGIN
	declare @retorno numeric(15, 2);

	set @retorno = isnull((
							select sum( mc.MONTO * mc.COTIZ )
							from ZooLogic.MOVCAJA as mc
							where mc.TIPOCOMP = @TipoDeComprobanteDeCaja
								and mc.PTOVTA = @PuntoDeVenta
								and mc.IDCAJA = @NumeroDeCaja
								and mc.NUMCOMP = @NumeroDeComprobante
								and mc.FACTSEC = @Secuencia
								and mc.ACCION = @Accion 
							), 0 );

	return @retorno
END
