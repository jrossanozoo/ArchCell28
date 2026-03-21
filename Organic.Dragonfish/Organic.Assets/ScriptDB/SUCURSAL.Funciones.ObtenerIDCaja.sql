IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerIDCaja]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerIDCaja];
GO;

/*
	Cuando se produce una anulación de un comprobante en la tabla COMPROBANTEV se registra con 
	IDCaja = 0
*/
CREATE FUNCTION [Funciones].[ObtenerIDCaja]
	( 
	@TipoDeComprobanteDeCaja varchar(2),
	@PuntoDeVenta numeric(4, 0),
	@NumeroDeCaja numeric(2, 0), 
	@NumeroDeComprobante Numeric(9, 0),
	@Secuencia char(2),
	@Accion char(1)
	)
RETURNS numeric(2, 0)
AS
BEGIN
	declare @retorno numeric(2, 0);
	declare @ExisteComprobante bit;
	declare @LetraDeComprobante char(1);
	declare @TipoDeComprobante numeric( 2, 0);
	
	set @LetraDeComprobante = Funciones.ObtenerLetraComprobantesYGruposDeCaja( @TipoDeComprobanteDeCaja );
	set @TipoDeComprobante = Funciones.ObtenerTipoComprobantesYGruposDeCaja( @TipoDeComprobanteDeCaja );
	
	set @ExisteComprobante = cast( case when Funciones.ObtenerGUIDDelComprobanteDeVentaAsociadoAlMovimientoDeCaja( @TipoDeComprobanteDeCaja, @PuntoDeVenta, @NumeroDeCaja, @NumeroDeComprobante, @Secuencia, @Accion ) is null then 0 else 1 end as bit ); 
							
	if @ExisteComprobante = 0 and @Accion <> 'M'
		set @retorno = 0
	else
		set @retorno = @NumeroDeCaja;
	
	return @retorno
END

