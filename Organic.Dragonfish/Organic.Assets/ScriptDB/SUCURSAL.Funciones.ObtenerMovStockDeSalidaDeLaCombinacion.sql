IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerMovStockDeSalidaDeLaCombinacion]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerMovStockDeSalidaDeLaCombinacion];
GO;
CREATE FUNCTION [Funciones].[ObtenerMovStockDeSalidaDeLaCombinacion]
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
					select SUM(M.CANTI) AS CANTIDAD from ZooLogic.DETMSTOCK as M
					where M.NUMR in 
					(select CODIGO from ZooLogic.MSTOCK where DIRMOV = 2 and FECHA >= @FechaDesde and FECHA <= @FechaHasta)
					and  M.MART = @Articulo 
					and ( ( @Color is null ) OR ( M.CCOLOR = @Color ) ) 
					and ( ( @Talle is null ) OR ( M.Talle = @Talle ) )
					group by M.MART,M.CCOLOR,M.TALLE
					)

	return case when @retorno is null then 0 else @retorno end

END