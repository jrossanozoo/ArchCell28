IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerVendedorDelComprobanteDeVentaAsociadoAlMovimientoDeCaja]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[ObtenerVendedorDelComprobanteDeVentaAsociadoAlMovimientoDeCaja];
GO;

CREATE FUNCTION [Funciones].[ObtenerVendedorDelComprobanteDeVentaAsociadoAlMovimientoDeCaja]
	( 
	@TipoDeComprobanteDeCaja varchar(2),
	@PuntoDeVenta numeric(4, 0),
	@NumeroDeCaja numeric(2, 0), 
	@NumeroDeComprobante Numeric(9, 0),
	@Secuencia char(2),
	@Accion char(1)
	)
RETURNS char(10)
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
							select cv.FVEN
							from zoologic.COMPROBANTEV as cv 
							where ( cv.FACTTIPO = @TipoDeComprobante )
								and ( cv.FLETRA = @LetraDeComprobante )
								and ( cv.FPTOVEN = @PuntoDeVenta )
								and ( cv.FNUMCOMP = @NumeroDeComprobante )
								and ( cv.FACTSEC = @Secuencia )
								and ( cv.IDCAJA = @NumeroDeCaja )
								and ( cv.ANULADO = 0 )
							)

						when 'COMCAJ' then 
							(
							select top 1 cc.VENDEDOR
							from zoologic.COMCAJ as cc 
							where ( cc.numero = @NumeroDeComprobante )
							)

						else
							null
					end;
	
	return @retorno
END

