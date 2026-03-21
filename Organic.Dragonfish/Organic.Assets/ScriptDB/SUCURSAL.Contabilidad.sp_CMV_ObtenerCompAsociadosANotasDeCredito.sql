IF EXISTS(SELECT * FROM sys.objects WHERE name = 'sp_CMV_ObtenerCompAsociadosANotasDeCredito' AND type in (N'P') and SCHEMA_ID('Contabilidad') = schema_id)
	DROP PROCEDURE [Contabilidad].[sp_CMV_ObtenerCompAsociadosANotasDeCredito];
GO;

CREATE PROCEDURE [Contabilidad].[sp_CMV_ObtenerCompAsociadosANotasDeCredito]
( 
	 @CatalogoSQL varchar(50),
	 @FechaDesde varchar(8), 
	 @FechaHasta varchar(8)
)
AS
BEGIN
	/* Devuelve una consulta con los comprobantes asociados a notas de crédito de venta para resolver el CMV (costo de mercadería vendida). 
	   Según doc.funcional 974 el costo de las n/c tiene que ser el de la factura en base a la cual se hizo la n/c */

	--DECLARE @CatalogoSQL varchar(50) = 'DRAGONFISH_DEMO2'
	--DECLARE @FechaDesde varchar(8) = '20250401'
	--DECLARE @FechaHasta varchar(8) = '20250430'

	DECLARE @Sql nvarchar(max) = ''
	SET @Sql = @Sql + 'DECLARE @TblCompAsociados Contabilidad.udt_TableType_CMVCompAsociados '

	---------Comprobante asociados con items afectados----
	SET @Sql = @Sql + 'INSERT INTO @TblCompAsociados '
	SET @Sql = @Sql + 'SELECT DISTINCT comp1.articulo, comp1.color, comp1.talle, comp1.cantidad, comp1.descfw, relacab.FFCH as fecha, relacab.facttipo as facttipo, relacab.codigo as codigo, relacab.descfw as comprobante '
	SET @Sql = @Sql + 'from ( '
	SET @Sql = @Sql + '   select fart as articulo, ccolor as color, talle, sum(fcant) as cantidad, afe_cod, ffch as fecha, facttipo, cab.codigo as codigo, descfw '
	SET @Sql = @Sql + '   from ' + ltrim( rtrim( @CatalogoSQL ) ) + '.zoologic.ComprobantevDet as Det '
	SET @Sql = @Sql + '      inner join ' + ltrim( rtrim( @CatalogoSQL ) ) + '.zoologic.comprobantev as Cab on Det.codigo = Cab.codigo '
	SET @Sql = @Sql + '   where anulado = 0 and afe_cod <> '''' and cab.facttipo in (3, 5, 28, 35, 48, 52, 55) and ( ffch between ''' + @FechaDesde + ''' and ''' + @FechaHasta + ''' ) '
	SET @Sql = @Sql + '   group by fart, ccolor, talle, afe_cod, ffch, facttipo, cab.codigo, descfw '
	SET @Sql = @Sql + ') comp1 '
	SET @Sql = @Sql + '   left join ' + ltrim( rtrim( @CatalogoSQL ) ) + '.zoologic.comprobantevdet as reladet on comp1.afe_cod = reladet.codigo '
	SET @Sql = @Sql + '   left join ' + ltrim( rtrim( @CatalogoSQL ) ) + '.zoologic.comprobantev as relacab on reladet.codigo = relacab.codigo '
	SET @Sql = @Sql + 'where relacab.codigo is not null and ( relacab.ffch between ''' + @FechaDesde + ''' and ''' + @FechaHasta + ''' ) '
	
	SET @Sql = @Sql + 'INSERT INTO @TblCompAsociados '
	SET @Sql = @Sql + 'SELECT DISTINCT comp2.articulo, comp2.color, comp2.talle, comp2.cantidad, comp2.descfw, comp2.fecha, comp2.facttipo as facttipo, comp2.codigo as codigo, comp2.descfw as comprobante '
	SET @Sql = @Sql + 'from ( '
	SET @Sql = @Sql + '   select fart as articulo, ccolor as color, talle, sum(fcant) as cantidad, afe_cod, ffch as fecha, facttipo, cab.codigo as codigo, descfw '
	SET @Sql = @Sql + '   from ' + ltrim( rtrim( @CatalogoSQL ) ) + '.zoologic.ComprobantevDet as Det '
	SET @Sql = @Sql + '      inner join ' + ltrim( rtrim( @CatalogoSQL ) ) + '.zoologic.comprobantev as Cab on Det.codigo = Cab.codigo '
	SET @Sql = @Sql + '   where anulado = 0 and afe_cod = '''' and cab.facttipo in (3, 5, 28, 35, 48, 52, 55) and ( ffch between ''' + @FechaDesde + ''' and ''' + @FechaHasta + ''' ) '
	SET @Sql = @Sql + '   group by fart, ccolor, talle, afe_cod, ffch, facttipo, cab.codigo, descfw '
	SET @Sql = @Sql + ') comp2 '
	SET @Sql = @Sql + 'where comp2.descfw in ( select descfw from  @TblCompAsociados ) '

	SET @Sql = @Sql + 'SELECT Articulo, Color, Talle, Cantidad, Descfw, Fecha, CompTipo, CompCodigo, Comprobante FROM  @TblCompAsociados '

	EXEC sp_executesql @Sql


	--EXEC [Contabilidad].[sp_CMV_ObtenerCompAsociadosANotasDeCredito] 'DRAGONFISH_DEMO2', '20250401', '20250430'

END
