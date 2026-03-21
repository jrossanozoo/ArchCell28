IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerRemitosSinFacturarDeSalidaDeLaCombinacion]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerRemitosSinFacturarDeSalidaDeLaCombinacion];
GO;
CREATE FUNCTION [Funciones].[ObtenerRemitosSinFacturarDeSalidaDeLaCombinacion]
	(
	@Articulo char(15),
	@Color char(6),
	@Talle char(5),
	@RangoFecha char(20)	
	)
RETURNS numeric(16,3)
AS
BEGIN
	declare @retorno numeric(16, 3) = 0
	declare @FechaDesde date = convert(date,substring(@RangoFecha,2,8),3)
	declare @FechaHasta date = convert(date,substring(@RangoFecha,11,8),3)
		
	--set @Color = nullif(rtrim( @Color ),'')
	--set @Talle = nullif(rtrim( @Talle ),'')
	
	set @retorno = ( 
					select SUM(D.AFESALDO) from ZooLogic.COMPROBANTEVDET AS D
					WHERE D.CODIGO IN(
					select A.codigo from ZooLogic.COMPROBANTEV as A
					where A.FACTTIPO = 11 and A.ffch >= @FechaDesde and A.ffch <= @FechaHasta
					)
					and  D.FART = @Articulo 
					and ( ( @Color is null ) OR ( D.CCOLOR = @Color ) ) 
					and ( ( @Talle is null ) OR ( D.Talle = @Talle ) )
					group by D.FART,D.CCOLOR,D.TALLE

					)

	return case when @retorno is null then 0 else @retorno end

END