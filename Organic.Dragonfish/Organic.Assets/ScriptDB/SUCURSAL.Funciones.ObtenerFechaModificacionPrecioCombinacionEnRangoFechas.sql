IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerFechaModificacionPrecioCombinacionEnRangoFechas]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerFechaModificacionPrecioCombinacionEnRangoFechas];
GO;
CREATE FUNCTION [Funciones].[ObtenerFechaModificacionPrecioCombinacionEnRangoFechas]
(
    @P_ARTICULO Varchar( 25 ), 
    @P_CCOLOR Varchar( 16 ), 
    @P_TALLE Varchar( 15 ), 
    @CodigoLPrecio Varchar(6), 
    @FechaModifDesde date,
	@FechaModifHasta date

 )
RETURNS date
AS
BEGIN
DECLARE @retorno date
    set @P_ARTICULO = rtrim( @P_ARTICULO );
    set @P_CCOLOR = rtrim( coalesce( @P_CCOLOR, '' ) );
    set @P_TALLE = rtrim( coalesce( @P_TALLE, '' ) );

    
    set @retorno = 
        (
     select top 1
			sc.fmodifw
        from
            (    
				select 
				-- PRC.ARTICULO
				--,PRC.CCOLOR
				--,PRC.TALLE
				prc.PDIRECTO
				,PRC.FMODIFW
                , prc.TIMESTAMPA
                , row_number() over( partition by prc.CCOLOR, prc.TALLE order by prc.FECHAVIG desc, prc.TIMESTAMPA desc ) Prioridad
                , power(0, len( case when prc.CCOLOR = @P_CCOLOR then replace( prc.CCOLOR, @P_CCOLOR, '' ) else prc.CCOLOR end ) ) * power(0, len( case when prc.talle = @P_TALLE then replace( prc.TALLE, @P_TALLE, '' ) else prc.talle end ) ) * 0.3 + sign( len( prc.CCOLOR ) ) * sign( len( @P_CCOLOR ) ) * power(0, len( case when prc.CCOLOR = @P_CCOLOR then replace( prc.CCOLOR, @P_CCOLOR, '' ) else prc.CCOLOR end ) ) * 0.2 + sign( len( prc.TALLE ) ) * sign( len( @P_TALLE ) ) * power(0, len( case when prc.talle = @P_TALLE then replace( prc.TALLE, @P_TALLE, '' ) else prc.talle end ) ) * 0.1 Grado
            from ZOOLOGIC.PRECIOAR prc
			  where 1=1
                and prc.LISTAPRE = @CodigoLPrecio
                and prc.ARTICULO = @P_ARTICULO
                and case when prc.CCOLOR = @P_CCOLOR then replace( prc.CCOLOR, @P_CCOLOR, '' ) else prc.CCOLOR end = ''
                and case when prc.talle = @P_TALLE then replace( prc.TALLE, @P_TALLE, '' ) else prc.talle end = ''
                and ((@FechaModifDesde is null ) OR ( prc.FMODIFW >= @FechaModifDesde ) ) 
				and ((@FechaModifHasta is null ) OR ( prc.FMODIFW <= @FechaModifHasta ) ) 
				 ) sc
        where Prioridad = 1
        order by sign( sc.PDIRECTO ) desc, sc.FMODIFW desc, sc.grado, sc.TIMESTAMPA desc
        )

	return @retorno
end
