IF OBJECT_ID(N'[Funciones].[ObtenerPrecioRealDeLaCombinacionConVigencia]') is not null DROP FUNCTION [Funciones].[ObtenerPrecioRealDeLaCombinacionConVigencia]
GO;

CREATE FUNCTION [Funciones].[ObtenerPrecioRealDeLaCombinacionConVigencia]
(
    @P_ARTICULO Varchar( 23 ), 
    @CodigoLPrecio Varchar(6), 
    @VigenciaParaFecha datetime,
    @NoValidarSiEsListaCalculada bit = 0
 )
RETURNS numeric(15,2)
AS
BEGIN
DECLARE @retorno numeric(15,2)
if @VigenciaParaFecha = ''
	set @VigenciaParaFecha = GETDATE()


set @retorno = (select top 1 CASE p.pdirecto WHEN null THEN 0 ELSE p.pdirecto end 
	from ZL.PRECIOAR p inner join ZL.lprecio lp on lp.lpr_numero = p.listapre and
	lp.LPR_NUMERO = @CodigoLPrecio
	where p.ARTICULO = @P_ARTICULO and  p.FECHAVIG <= @VigenciaParaFecha
	order by ( case p.PDirecto when 0 then 0 else 1 end ) desc, p.FECHAVIG desc, p.TIMESTAMPA desc )

	return @retorno
end

GO;

IF OBJECT_ID(N'[Funciones].[ObtenerPrecioDeLaCombinacionConVigencia]') is not null DROP FUNCTION [Funciones].[ObtenerPrecioDeLaCombinacionConVigencia]
GO;

CREATE FUNCTION [Funciones].[ObtenerPrecioDeLaCombinacionConVigencia]
(
    @P_ARTICULO Varchar( 23 ), 
    @CodigoLPrecio Varchar(6), 
    @VigenciaParaFecha datetime,
    @NoValidarSiEsListaCalculada bit = 0
 )
RETURNS numeric(15,2)
AS
BEGIN
DECLARE @retorno numeric(15,2)
if @VigenciaParaFecha = ''
	set @VigenciaParaFecha = GETDATE()


if @NoValidarSiEsListaCalculada = 0
	BEGIN
		DECLARE @ListaDePrecios TABLE (ListaBase char(6), PCalculado bit, Operador char(1), Coeficiente numeric(15,2), MonedaCotiz char(10), Redondeo numeric(1), Cantidad numeric(2))
		DECLARE @Calculada bit
		insert into @ListaDePrecios select LISTABASE, PCALCULADO, OPERADOR, COEFICIENT, MONEDACOTI, TREDONDEO, CANTIDAD from ZL.LPRECIO where LPR_NUMERO = @CodigoLPrecio;
		select @Calculada = pCalculado from @ListaDePrecios
		if @Calculada = 1
  			select @CodigoLPrecio = ListaBase from @ListaDePrecios
	END

set @retorno = (select isnull((select top 1 CASE p.pdirecto WHEN null THEN 0 ELSE p.pdirecto end 
	from ZL.PRECIOAR p inner join ZL.lprecio lp on lp.lpr_numero = p.listapre and
	lp.LPR_NUMERO = @CodigoLPrecio
	where p.ARTICULO = @P_ARTICULO and  p.FECHAVIG <= @VigenciaParaFecha
	order by ( case p.PDirecto when 0 then 0 else 1 end ) desc, p.FECHAVIG desc, p.TIMESTAMPA desc ), 0))
    
    if @NoValidarSiEsListaCalculada = 0 and @Calculada = 1
    	BEGIN
    		declare @Operador char(1), @Coeficiente numeric(15,2), @MonedaCotiz char(10), @TipoRedondeo numeric(1), @CantRedondeo numeric(2)
    		select @Operador = Operador from @ListaDePrecios
    		select @Coeficiente = Coeficiente from @ListaDePrecios
    		select @MonedaCotiz = MonedaCotiz from @ListaDePrecios
    		select @TipoRedondeo = Redondeo from @ListaDePrecios
    		select @CantRedondeo = Cantidad from @ListaDePrecios
    		if coalesce(@VigenciaParaFecha, '') = ''
    			set @VigenciaParaFecha = getdate()
    		set @retorno = coalesce( Funciones.ObtenerPrecioDeLaCombinacionConVigenciaAlMomento( @retorno, @VigenciaParaFecha, @Operador, @Coeficiente, @MonedaCotiz, @TipoRedondeo, @CantRedondeo ), 0 )
    	END

	return @retorno
end

GO;

IF OBJECT_ID(N'[Funciones].[ObtenerTimestampVigenteDeLaCombinacion]') is not null DROP FUNCTION [Funciones].[ObtenerTimestampVigenteDeLaCombinacion]
GO;

CREATE FUNCTION [Funciones].[ObtenerTimestampVigenteDeLaCombinacion]
(
    @P_ARTICULO Varchar( 23 ), 
    @CodigoLPrecio Varchar(6), 
    @VigenciaParaFecha datetime
 )
RETURNS numeric(15,2)
AS
BEGIN
DECLARE @retorno numeric(15,2)
    
    set @retorno = 
        (
        select top 1
                prc.TIMESTAMPA
            from ZOOLOGIC.PRECIOAR prc
            where 1=1
                and prc.LISTAPRE = @CodigoLPrecio
        	order by sign( prc.PDIRECTO ) desc, prc.FECHAVIG desc, prc.TIMESTAMPA desc
        )

	return @retorno
end

GO;

