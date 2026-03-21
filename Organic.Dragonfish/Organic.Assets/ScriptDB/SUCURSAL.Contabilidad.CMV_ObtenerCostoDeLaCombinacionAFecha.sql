IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[CMV_ObtenerCostoDeLaCombinacionAFecha]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Contabilidad].[CMV_ObtenerCostoDeLaCombinacionAFecha];
GO;

CREATE FUNCTION [Contabilidad].[CMV_ObtenerCostoDeLaCombinacionAFecha]
(
    @P_Articulo Varchar( 15 ), 
    @P_CColor Varchar( 6 ), 
    @P_Talle Varchar( 5 ), 
	@VigenciaParaFecha datetime,
	@Comprobante varchar(200),
	@tbl_CmvCompras as Contabilidad.udt_TableType_CMVTipoCompMovStock READONLY
 )
RETURNS @Retorno TABLE
(
	Costo numeric(15,2),
	FactTipo numeric(2,0),
	Letra varchar(2),
	PtoVenta numeric(5,0),
	NumComp numeric(8,0),
	Comprobante varchar(200)
)
BEGIN
	
	/* Adaptación personalizada de [Funciones].[ObtenerPrecioRealDeLaCombinacionConVigencia] para obtener el costo de una combinación a una fecha, a partir del agrupamiento de las tablas de compras
	   generadas en [Listados].[EjecutorDeConsultasDeListadosCMV] para el cálculo de CMV */
	/* La idea de esta consulta es obtener el costo de una combinación según su jerarquía: art-col-tall, art-col, art-tall, art */

    set @P_ARTICULO = rtrim( @P_ARTICULO );
    set @P_CCOLOR = rtrim( coalesce( @P_CCOLOR, '' ) );
    set @P_TALLE = rtrim( coalesce( @P_TALLE, '' ) );
	
    INSERT INTO @Retorno ( Costo, FactTipo, Letra, PtoVenta, NumComp, Comprobante )

        select top 1
            sc.PDIRECTO, sc.FTIPO, sc.LETRA, sc.PTOVENTA, sc.NUMCOMP, sc.DESCFW
        from
		   (
			select  prc.articulo, prc.CCOLOR, prc.TALLE, prc.PDIRECTO, prc.FECHAVIG, prc.TIMESTAMP, prc.FTIPO, prc.LETRA, prc.PTOVENTA, prc.NUMCOMP, prc.DESCFW, row_number() over( partition by prc.CCOLOR, prc.TALLE order by prc.FECHAVIG desc, prc.TIMESTAMP desc ) AS Prioridad ,
			power(0, len( case when prc.CCOLOR = @P_CCOLOR then replace( prc.CCOLOR, @P_CCOLOR, '' ) else prc.CCOLOR end ) ) * power(0, len( case when prc.talle = @P_TALLE then replace( prc.TALLE, @P_TALLE, '' ) else prc.talle end ) ) * 0.3 + sign( len( prc.CCOLOR ) ) * sign( len( @P_CCOLOR ) ) * power(0, len( case when prc.CCOLOR = @P_CCOLOR then replace( prc.CCOLOR, @P_CCOLOR, '' ) else prc.CCOLOR end ) ) * 0.2 + sign( len( prc.TALLE ) ) * sign( len( @P_TALLE ) ) * power(0, len( case when prc.talle = @P_TALLE then replace( prc.TALLE, @P_TALLE, '' ) else prc.talle end ) ) * 0.1 Grado
			from 
				(

				select ARTICULO as Articulo, COLOR as CColor, TALLE as Talle, PRECIO as PDirecto, FECHA as FechaVig, TIMESTAMP, FACTTIPO as FTIPO, LETRA, PTOVENEXT as PTOVENTA, NUMCOMP, DESCRIP as DESCFW
				from @tbl_CmvCompras 

				) prc 
				 where 1=1
							and prc.ARTICULO = @P_ARTICULO
							and case when prc.CCOLOR = @P_CCOLOR then replace( prc.CCOLOR, @P_CCOLOR, '' ) else prc.CCOLOR end = ''
							and case when prc.talle = @P_TALLE then replace( prc.TALLE, @P_TALLE, '' ) else prc.talle end = ''
							and prc.FECHAVIG <= case when coalesce(@VigenciaParaFecha, '') = '' then getdate() else @VigenciaParaFecha end
							and ( ( @Comprobante is null ) OR ( prc.descfw = @Comprobante ) )
		    ) sc

        where Prioridad = 1
		order by sign( sc.PDIRECTO ) desc, sc.FECHAVIG desc, sc.Grado desc, sc.TIMESTAMP desc

RETURN
END
