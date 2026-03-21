IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerInformacionDeAfectacionesEnUnReciboDeVenta]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerInformacionDeAfectacionesEnUnReciboDeVenta];
GO;

CREATE FUNCTION [Funciones].[ObtenerInformacionDeAfectacionesEnUnReciboDeVenta]
(
	@CodigoDeComprobante char(38),
	@SignoEnCtaCte int,
	@TotalCtaCte numeric(15,2)
)
RETURNS nVarchar(max)
AS
BEGIN
	declare @Simbolo varchar(5);
	declare @Resultado nVarchar(max);
	
	select @Simbolo = rtrim(mnda.SIMBOLO) from ZooLogic.RECIBO rcbo inner join ZooLogic.MONEDA mnda on mnda.CODIGO = rcbo.MONEDA where rcbo.CODIGO = @CodigoDeComprobante; 

	select @Resultado = case when @SignoEnCtaCte < 0 then
							coalesce( 
								stuff(( 
										SELECT '; ' 
											+ @Simbolo + ' ' 
											+ convert( nvarchar, rdet.RMONTO ) 
											+ case when rdet.tipo = rcbo.facttipo and rdet.NUMAFEC = rcbo.FNUMCOMP 
												then ' Pago a cuenta' 
												else ' de ' + Funciones.IdentificadorDeComprobanteParaListado(rdet.tipo, rdet.LETRAAFEC,rdet.PTOAFEC,rdet.NUMAFEC) 
											end
										FROM ZooLogic.RECIBODET as rdet
										WHERE rdet.CODIGO = rcbo.CODIGO 
											and rdet.RMONTO != 0 
											and ( 
												rdet.tipo != rcbo.facttipo  
												or ( 
													rdet.tipo = rcbo.facttipo 
													and ( 
														@TotalCtaCte != 0 
														or rdet.NUMAFEC != rcbo.FNUMCOMP 
														) 
													) 
												)
										FOR XML PATH('') 
										), 1, 2, '') 
							, '') 
						else 
							case when rcbo.FTOTAL != 0 
								then 
									case when @TotalCtaCte != 0 then 'Refinancia ' + @Simbolo + ' ' + convert( nvarchar, @TotalCtaCte) else '' end
								else '' 
							end  
						end 
	from ZooLogic.RECIBO rcbo 
	where rcbo.CODIGO = @CodigoDeComprobante;

	return @Resultado
END
