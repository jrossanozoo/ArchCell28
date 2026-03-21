IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerTotalDelComprobanteAsociadoAlMovimientoDeCaja]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerTotalDelComprobanteAsociadoAlMovimientoDeCaja];
GO;

CREATE FUNCTION [Funciones].[ObtenerTotalDelComprobanteAsociadoAlMovimientoDeCaja]
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
								select cast( cv.SIGNOMOV * cv.FTOTAL * cv.COTIZ as numeric( 15, 2 ) )
								from zoologic.comprobantev as cv 
								where cv.codigo = @GUID
								)

							when 'FACCOMPRA' then 
								(
								select cast( fc.SIGNOMOV * fc.FTOTAL * fc.COTIZ as numeric( 15, 2 ) )
								from Zoologic.FACCOMPRA as fc 
								where fc.CODIGO = @GUID
								)

							when 'NDCOMPRA' then 
								(
								select cast( ndc.SIGNOMOV * ndc.FTOTAL * ndc.COTIZ as numeric( 15, 2 ) )
								from Zoologic.NDCOMPRA as ndc 
								where ndc.CODIGO = @GUID
								)

							when 'NCCOMPRA' then 
								(
								select cast( ncc.SIGNOMOV * ncc.FTOTAL * ncc.COTIZ as numeric( 15, 2 ) )
								from Zoologic.NCCOMPRA as ncc 
								where ncc.CODIGO = @GUID
								)

							when 'RECIBO' then 
								(
								select cast( rc.SIGNOMOV * rc.FTOTAL * rc.COTIZ as numeric( 15, 2 ) )
								from Zoologic.RECIBO as rc 
								where rc.CODIGO = @GUID
								)

							when 'PAGO' then 
								(
								select cast( - sum( pd.RMONTO ) as numeric( 15, 2 ) )
								from Zoologic.PAGODET as pd 
								where pd.CODIGO = @GUID
								)

							when 'COMPPAGO' then 
								(
								select cast( - cp.FTOTAL * cp.COTIZ as numeric( 15, 2 ) )
								from Zoologic.COMPPAGO as cp
								where cp.CODIGO = @GUID
								)

							when 'CANJECUPONES' then 
								(
								select cast( sum( cc.PESOS ) as  numeric( 15, 2 ) )
								from (
									select power( -1, cvd.SIGNO ) * cvd.PESOS as pesos
									from Zoologic.CANJECUPONES as cv 
										inner join ZooLogic.CANJECUPONESDET as cvd on cvd.JJNUM = cv.CODIGO
									where cv.CODIGO = @GUID
									union all
									select power( -1, cve.SIGNO ) * cve.PESOS
									from Zoologic.CANJECUPONES as cv 
										left join ZooLogic.CANJECUPONESENT as cve on cve.CODIGO = cv.CODIGO
									where cv.CODIGO = @GUID
									) as cc
								)

							when 'COMCAJ' then
								case isnumeric( @GUID )
									when 1 then 
										(
										select cast( sum( cc.SIGNOMOV * ccd.CTOTAL * ccd.COTIZA ) as numeric( 15, 2 ) )
										from Zoologic.COMCAJ as cc inner join ZooLogic.COMPCAJADET as ccd on ccd.CODDETVAL = cc.CODIGO
										where cc.NUMERO = convert( int, @GUID )
										)
									else
										null
								end
							else
								null
						end;

	return @retorno
END

