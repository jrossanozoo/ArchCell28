IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[EsElPrecioVigenteALaFecha]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[EsElPrecioVigenteALaFecha];
GO;

CREATE FUNCTION [Funciones].[EsElPrecioVigenteALaFecha]
( 
  @CodigoPkRegistroPrecio char(46),
  @CodigoLPrecio Varchar(6),
  @CodigoArticulo char(15),
  @CodigoColor char(6), 
  @CodigoTalle char(5),
  @FechaParaVigencia datetime )

RETURNS bit
AS
BEGIN
	declare @Retorno bit = 0 ;

	if ( @FechaParaVigencia is null or @FechaParaVigencia = '' ) 
		set @FechaParaVigencia = GETDATE()

		select top 1 @retorno = case when p.Codigo = @CodigoPkRegistroPrecio then 1 else 0 end
		from ZOOLOGIC.PRECIOAR p
		where p.listapre = @CodigoLPrecio
			and p.ARTICULO = @CodigoArticulo 
			and ( (@CodigoColor is null) or (p.CCOLOR = @CodigoColor) ) 
			and ( (@CodigoTalle is null) or (p.TALLE = @CodigoTalle) ) 
			and p.FECHAVIG <= @FechaParaVigencia
		order by p.FECHAVIG desc, 
				 p.TIMESTAMPA desc

	return @retorno
end
