IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerPrecioDeLaCombinacionConOSinImpuestosALaFecha]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerPrecioDeLaCombinacionConOSinImpuestosALaFecha];
GO;

CREATE FUNCTION [Funciones].[ObtenerPrecioDeLaCombinacionConOSinImpuestosALaFecha]
	(
	@CodigoArticulo Varchar( 25 ),
	@CodigoColor Varchar( 16 ), 
	@CodigoTalle Varchar( 15 ),
	@CodigoLPrecio Varchar( 6 ),
	@ConImpuesto int,
	@VigenciaParaFecha date,
    @NoValidarSiEsListaCalculada bit = 0
	)
RETURNS numeric( 15, 2 )
AS
BEGIN
	declare @retorno numeric( 15, 2 );
	declare @ListaConIVA int;
	declare @TasaDeIVA numeric( 7, 4 );
	declare @FactorCorrector numeric( 12, 8 );
	
	if coalesce( @VigenciaParaFecha, '' ) = ''
		set @VigenciaParaFecha = GETDATE()
		
	set @retorno = Funciones.ObtenerPrecioRealDeLaCombinacionConVigencia( @CodigoArticulo, @CodigoColor,  @CodigoTalle, @CodigoLPrecio, @VigenciaParaFecha, @NoValidarSiEsListaCalculada )
	
	if @retorno IS NULL
		set @retorno = 0	
	if coalesce( @ConImpuesto, 1 ) = 1
		set @ConImpuesto = 1
	else
		set @ConImpuesto = 0
		
	select @ListaConIVA = 	case when C_LISTA.LPR_CONDIV = 1 
								then 1 
								else 0 
							end 
	from ZooLogic.lprecio C_LISTA 
	where C_LISTA.LPR_NUMERO = @CodigoLPrecio; 
	
	select @TasaDeIVA = case when C_ARTICULO.ARTCONIVA <= 1 
							then ( select cast( valor as numeric( 5, 2 ) ) from parametros.SUCURSAL where IDUNICO = '1B58BD40911092149E118F2816855050858001' ) 
							else C_ARTICULO.ARTPORIVA 
						end / 100.0
	from ZooLogic.ART as C_ARTICULO
	where C_ARTICULO.ARTCOD = @CodigoArticulo;
	
	set @FactorCorrector = 	case when @ConImpuesto = @ListaConIVA
								then 1
								else
									case when @ConImpuesto = 1
										then 1.0 + @TasaDeIVA
										else 1.0 / ( 1.0 + @TasaDeIVA )
									end
							end
	
	set @retorno = @retorno * @FactorCorrector
	
	return @retorno
END
