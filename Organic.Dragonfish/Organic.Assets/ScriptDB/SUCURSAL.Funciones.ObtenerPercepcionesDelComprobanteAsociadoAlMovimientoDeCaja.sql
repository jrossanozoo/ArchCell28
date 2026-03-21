IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerPercepcionesDelComprobanteAsociadoAlMovimientoDeCaja]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerPercepcionesDelComprobanteAsociadoAlMovimientoDeCaja];
GO;

CREATE FUNCTION [Funciones].[ObtenerPercepcionesDelComprobanteAsociadoAlMovimientoDeCaja]
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
	declare @LetraDeComprobante char(1);
	declare @TipoDeComprobante numeric( 2, 0);
	declare @Tabla varchar(50);
	declare @GUID char(38);

	set @LetraDeComprobante = Funciones.ObtenerLetraComprobantesYGruposDeCaja( @TipoDeComprobanteDeCaja );
	set @TipoDeComprobante = Funciones.ObtenerTipoComprobantesYGruposDeCaja( @TipoDeComprobanteDeCaja );
	set @Tabla = Funciones.ObtenerTablaDeOrigenDelRegistroComprobantesYGruposDeCaja( @TipoDeComprobanteDeCaja );
	set @GUID = Funciones.ObtenerGUIDDelComprobanteDeVentaAsociadoAlMovimientoDeCaja( @TipoDeComprobanteDeCaja, @PuntoDeVenta, @NumeroDeCaja, @NumeroDeComprobante, @Secuencia, @Accion )

	if @GUID is null
		set @retorno = null
	else
		set @retorno = case @Tabla 
							when 'COMPROBANTEV' then 
								(
								select cast( cv.SIGNOMOV * cv.TOTIMPUE as numeric( 15, 2 ) )
								from zoologic.comprobantev as cv 
								where cv.codigo = @GUID
								)

							when 'FACCOMPRA' then 
								(
								select cast( fc.SIGNOMOV * fc.TOTIMPUE as numeric( 15, 2 ) )
								from Zoologic.FACCOMPRA as fc 
								where fc.CODIGO = @GUID
								)

							when 'NDCOMPRA' then 
								(
								select cast( ndc.SIGNOMOV * ndc.TOTIMPUE as numeric( 15, 2 ) )
								from Zoologic.NDCOMPRA as ndc 
								where ndc.CODIGO = @GUID
								)

							when 'NCCOMPRA' then 
								(
								select cast( ncc.SIGNOMOV * ncc.TOTIMPUE as numeric( 15, 2 ) )
								from Zoologic.NCCOMPRA as ncc 
								where ncc.CODIGO = @GUID
								)

							--when 'RECIBO' then 
							--	(
							--	select cast( rc.SIGNOMOV * rc.FTOTAL as numeric( 15, 2 ) )
							--	from Zoologic.RECIBO as rc 
							--	where rc.CODIGO = @GUID
							--	)

							--when 'PAGO' then 
							--	(
							--	select cast( rc.SIGNOMOV * rc.FTOTAL as numeric( 15, 2 ) )
							--	from Zoologic.PAGO as rc 
							--	where rc.CODIGO = @GUID
							--	)

							--when 'COMPPAGO' then 
							--	(
							--	select cast( rc.SIGNOMOV * rc.FTOTAL as numeric( 15, 2 ) )
							--	from Zoologic.COMPPAGO as rc 
							--	where rc.CODIGO = @GUID
							--	)

							else
								null
						end;

	return @retorno
END

