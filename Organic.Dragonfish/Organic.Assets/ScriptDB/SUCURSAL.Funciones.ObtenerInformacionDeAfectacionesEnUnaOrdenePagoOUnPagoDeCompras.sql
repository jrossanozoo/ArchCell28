IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerInformacionDeAfectacionesEnUnaOrdenePagoOUnPagoDeCompras]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerInformacionDeAfectacionesEnUnaOrdenePagoOUnPagoDeCompras];
GO;

CREATE FUNCTION [Funciones].[ObtenerInformacionDeAfectacionesEnUnaOrdenePagoOUnPagoDeCompras]
(
	@CodigoDeComprobante char(38),
	@TipoDeComprobante int,
	@SignoEnCtaCte int,
	@MontoComprometido numeric(15,2),
	@CodigoDeValor char(5)
)
RETURNS nVarchar(max)
AS
BEGIN
	declare @Simbolo varchar(5);
	declare @Resultado nVarchar(max);
	declare @SoloPagoACuenta as bit;

	set @SoloPagoACuenta = ( 1 - Funciones.LaOrdenDePagoAfectaSaldo( @CodigoDeComprobante, @TipoDeComprobante, @MontoComprometido ) ) * sign( abs( @MontoComprometido ) );

	if @TipoDeComprobante = 31
		select @Simbolo = rtrim(mnda.SIMBOLO) from ZooLogic.ORDPAGO op inner join ZooLogic.MONEDA mnda on mnda.CODIGO = op.MONEDA where op.CODIGO = @CodigoDeComprobante;
	else 
		if @TipoDeComprobante = 37 
			select @Simbolo = rtrim(mnda.SIMBOLO) from ZooLogic.PAGO pg inner join ZooLogic.MONEDA mnda on mnda.CODIGO = pg.MONEDA where pg.CODIGO = @CodigoDeComprobante;
		else 
			set @Simbolo = '';

	set @Resultado = case 
						when @TipoDeComprobante = 31 
							then coalesce( 
									stuff(( 
											SELECT '; ' 
												+ @Simbolo 
												+ convert( nvarchar, opdet.RMONTO ) + ' ' 
												+ case when @SignoEnCtaCte = -1 
													then 
														case when ( opdet.CODCOMP = '')
															then 'Pago a cuenta'
															else Funciones.IdentificadorDeComprobanteParaListado(opdet.TIPO, opdet.LETRAAFEC,opdet.PTOAFEC,opdet.NUMAFEC) 
														end
													else 'Refinanciados'
												end
											FROM ZooLogic.ORDPAGODET as opdet
											WHERE opdet.CODIGO = @CodigoDeComprobante
												and opdet.RMONTO != 0 
												and ( ( ( @SoloPagoACuenta = 1 ) and ( opdet.TIPO = 31 ) ) or ( ( @SoloPagoACuenta = 0 ) and ( opdet.TIPO != 31) ) )
											FOR XML PATH('') 
											), 1, 2, '') 
								, '') 
						when @TipoDeComprobante = 37 
							then coalesce( 
									stuff(( 
											SELECT '; ' 
												+ @Simbolo  
												+ convert( nvarchar, pdet.RMONTO ) + ' ' 
												+ case when ( pdet.CODCOMP = '')
													then 'Pago a cuenta' 
													else Funciones.IdentificadorDeComprobanteParaListado(pdet.TIPO, pdet.LETRAAFEC, pdet.PTOAFEC, pdet.NUMAFEC) 
												end
											FROM ZooLogic.PAGODET as pdet
											WHERE pdet.CODIGO = @CodigoDeComprobante
												and pdet.RMONTO != 0 
												and ( ( len( rtrim( @CodigoDeValor ) ) > 0  and pdet.TIPO = 31 ) or ( len( rtrim( @CodigoDeValor ) ) = 0 and pdet.TIPO != 31 ) )
											FOR XML PATH('') 
											), 1, 2, '') 
								, '') 
						else 
							''
					end;

	return @Resultado
END
