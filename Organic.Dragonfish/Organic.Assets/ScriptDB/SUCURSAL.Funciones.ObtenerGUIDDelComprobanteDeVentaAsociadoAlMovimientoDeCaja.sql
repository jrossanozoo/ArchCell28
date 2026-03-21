IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerGUIDDelComprobanteDeVentaAsociadoAlMovimientoDeCaja]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[ObtenerGUIDDelComprobanteDeVentaAsociadoAlMovimientoDeCaja];
GO;

CREATE FUNCTION [Funciones].[ObtenerGUIDDelComprobanteDeVentaAsociadoAlMovimientoDeCaja]
	( 
	@TipoDeComprobanteDeCaja varchar(2),
	@PuntoDeVenta numeric(4, 0),
	@NumeroDeCaja numeric(2, 0), 
	@NumeroDeComprobante Numeric(9, 0),
	@Secuencia char(2),
	@Accion char(1)
	)
RETURNS char(38)
AS
BEGIN
	declare @retorno char(38);
	declare @LetraDeComprobante char(1);
	declare @TipoDeComprobante numeric( 2, 0);
	declare @Tabla varchar(50);

	set @LetraDeComprobante = Funciones.ObtenerLetraComprobantesYGruposDeCaja( @TipoDeComprobanteDeCaja );
	set @TipoDeComprobante = Funciones.ObtenerTipoComprobantesYGruposDeCaja( @TipoDeComprobanteDeCaja );
	set @Tabla = Funciones.ObtenerTablaDeOrigenDelRegistroComprobantesYGruposDeCaja( @TipoDeComprobanteDeCaja );

	set @retorno = case @Tabla 
						when 'COMPROBANTEV' then 
							(
							select CODIGO
							from zoologic.COMPROBANTEV as cv 
							where ( cv.FACTTIPO = @TipoDeComprobante )
								and ( cv.FLETRA = @LetraDeComprobante )
								and ( cv.FPTOVEN = @PuntoDeVenta )
								and ( cv.FNUMCOMP = @NumeroDeComprobante )
								and ( cv.FACTSEC = @Secuencia )
								and ( cv.IDCAJA = @NumeroDeCaja )
								and ( cv.ANULADO = 0 )
							)

						when 'FACCOMPRA' then 
							(
							select CODIGO
							from zoologic.FACCOMPRA as fc 
							where ( fc.FACTTIPO = @TipoDeComprobante )
								and ( fc.FLETRA = @LetraDeComprobante )
								and ( fc.FPTOVEN = @PuntoDeVenta )
								and ( fc.FNUMCOMP = @NumeroDeComprobante )
								and ( fc.IDCAJA = @NumeroDeCaja )
								and ( fc.ANULADO = 0 )
							)

						when 'NDCOMPRA' then 
							(
							select CODIGO
							from zoologic.NDCOMPRA as ndc 
							where ( ndc.FACTTIPO = @TipoDeComprobante )
								and ( ndc.FLETRA = @LetraDeComprobante )
								and ( ndc.FPTOVEN = @PuntoDeVenta )
								and ( ndc.FNUMCOMP = @NumeroDeComprobante )
								and ( ndc.IDCAJA = @NumeroDeCaja )
								and ( ndc.ANULADO = 0 )
							)

						when 'NCCOMPRA' then 
							(
							select CODIGO
							from zoologic.NCCOMPRA as ncc 
							where ( ncc.FACTTIPO = @TipoDeComprobante )
								and ( ncc.FLETRA = @LetraDeComprobante )
								and ( ncc.FPTOVEN = @PuntoDeVenta )
								and ( ncc.FNUMCOMP = @NumeroDeComprobante )
								and ( ncc.IDCAJA = @NumeroDeCaja )
								and ( ncc.ANULADO = 0 )
							)

						when 'RECIBO' then 
							(
							select CODIGO
							from zoologic.RECIBO as rc 
							where ( rc.FACTTIPO = @TipoDeComprobante )
								and ( rc.FLETRA = @LetraDeComprobante )
								and ( rc.FPTOVEN = @PuntoDeVenta )
								and ( rc.FNUMCOMP = @NumeroDeComprobante )
								and ( rc.IDCAJA = @NumeroDeCaja )
								and ( rc.ANULADO = 0 )
							)

						when 'CANJECUPONES' then 
							(
							select CODIGO
							from zoologic.CANJECUPONES as cv 
							where ( cv.FACTTIPO = @TipoDeComprobante )
								and ( cv.FLETRA = @LetraDeComprobante )
								and ( cv.FPTOVEN = @PuntoDeVenta )
								and ( cv.NUMERO = @NumeroDeComprobante )
								and ( cv.ANULADO = 0 )
							)

						when 'PAGO' then 
							(
							select CODIGO
							from zoologic.PAGO as pg 
							where ( pg.FACTTIPO = @TipoDeComprobante )
								and ( pg.FLETRA = @LetraDeComprobante )
								and ( pg.FPTOVEN = @PuntoDeVenta )
								and ( pg.FNUMCOMP = @NumeroDeComprobante )
								and ( pg.ANULADO = 0 )
							)

						when 'COMPPAGO' then 
							(
							select CODIGO
							from zoologic.COMPPAGO as cp 
							where ( cp.FACTTIPO = @TipoDeComprobante )
								and ( cp.FLETRA = @LetraDeComprobante )
								and ( cp.FPTOVEN = @PuntoDeVenta )
								and ( cp.NUMERO = @NumeroDeComprobante )
								and ( cp.ANULADO = 0 )
							)

						when 'COMCAJ' then 
							convert( char(38), @NumeroDeComprobante )

						else
							null
					end;
	
	return @retorno
END

