IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ParticipaDeLaComparacionDePrecios]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[ParticipaDeLaComparacionDePrecios];
GO;

CREATE FUNCTION [Funciones].[ParticipaDeLaComparacionDePrecios]
( 
  @CodigoPkRegistroPrecio char(46),
  @CodigoArticulo char(15),
  @CodigoColor char(6), 
  @CodigoTalle char(5),
  @Lista1 varchar(250),
  @VigenciaL1 varchar(250),
  @Lista2 varchar(250),
  @VigenciaL2 varchar(250))

RETURNS bit
AS
BEGIN
	declare @Retorno bit = 0 ;
	declare @FechaVigenciaL1 datetime;
	declare @FechaVigenciaL2 datetime;
	declare @FechaVigenciaL3 datetime;

	if ( isdate( @VigenciaL1 ) = 1 ) 
		set @FechaVigenciaL1 = convert( datetime, @VigenciaL1 )
	else
		set @FechaVigenciaL1  = GETDATE();

	if ( isdate( @VigenciaL2 ) = 1 ) 
		set @FechaVigenciaL2 = convert( datetime, @VigenciaL2 )
	else
		set @FechaVigenciaL2  = GETDATE();

	select top 1 @retorno = case when p.Codigo = @CodigoPkRegistroPrecio then 1 else 0 end
	from ZOOLOGIC.PRECIOAR p
	where p.ARTICULO = @CodigoArticulo 
		and ( (@CodigoColor is null) or (p.CCOLOR = @CodigoColor) ) 
		and ( (@CodigoTalle is null) or (p.TALLE = @CodigoTalle) ) 
		and ( 
				( ( p.listapre = cast( @Lista1 as varchar(6) ) ) and ( p.FECHAVIG <= @FechaVigenciaL1 ) )
				or
				( ( p.listapre = cast( @Lista2 as varchar(6) ) ) and ( p.FECHAVIG <= @FechaVigenciaL2 ) )
			)
	order by p.FECHAVIG desc, 
				p.TIMESTAMPA desc

	return @retorno
end
