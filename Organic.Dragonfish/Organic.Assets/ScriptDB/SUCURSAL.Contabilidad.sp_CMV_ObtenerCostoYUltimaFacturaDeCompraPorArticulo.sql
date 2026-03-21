IF EXISTS(SELECT * FROM sys.objects WHERE name = 'sp_CMV_ObtenerCostoYUltimaFacturaDeCompraPorArticulo' AND type in (N'P') and SCHEMA_ID('Contabilidad') = schema_id)
	DROP PROCEDURE Contabilidad.sp_CMV_ObtenerCostoYUltimaFacturaDeCompraPorArticulo;
GO;

CREATE PROCEDURE [Contabilidad].[sp_CMV_ObtenerCostoYUltimaFacturaDeCompraPorArticulo]
(
	@CatalogoSQL varchar(50),
	@FechaDesde varchar(8),
	@FechaHasta varchar(8)
)
AS
BEGIN
	/* Este SP me busca la ultima factura de compra realizada dentro de un periodo, y me devuelve la cantidad y precio por articulo comprado 
	   La devolucion debe respetar la estructura del tipo de dato: Contabilidad.udt_TableType_CMVTipoCompMovStock, dado que insertara los 
	   datos en una tabla con dicha estructura */

	--DECLARE @CatalogoSQL varchar(50) = 'DRAGONFISH_DEMO2'
	--DECLARE @FechaDesde varchar(8) = '20250301'
	--DECLARE @FechaHasta varchar(8) = '20250331'

	DECLARE @Sql nvarchar(max) = ''

	SET @Sql = @Sql + 'select 0 as ID, '''' as GLOBALID, CODIGO, FACTTIPO, FART, FCOLO, FTALL, FFCH, FLETRA, FPTOVENEXT, FNUMCOMP, FPTOVEN, NUMINT, CANTIDAD, PRECIO, TIMESTAMP, DESCFW, BDALTAFW '
	SET @Sql = @Sql + 'from ( '
	SET @Sql = @Sql + '	  select cab.CODIGO, cab.FACTTIPO, det.FART, det.FCOLO, det.FTALL, cab.FFCH, cab.FLETRA, cab.FPTOVENEXT, '
	SET @Sql = @Sql + '      cab.FNUMCOMP, cab.FPTOVEN, cab.NUMINT, det.FCANT as CANTIDAD, (det.PRUNSINIMP * cab.COTIZ) as PRECIO, cab.TIMESTAMP, cab.DESCFW, cab.BDALTAFW, '
	SET @Sql = @Sql + '      row_number() over( partition by det.FART, det.FCOLO, det.FTALL order by cab.FFCH desc, cab.TIMESTAMP desc ) as Prioridad '
	SET @Sql = @Sql + '	  from ' + ltrim( rtrim( @CatalogoSQL ) ) + '.Zoologic.FACCOMPRA cab '
	SET @Sql = @Sql + '	  left join ' + ltrim( rtrim( @CatalogoSQL ) ) + '.Zoologic.FACCOMPRADET det on cab.CODIGO = det.CODIGO '
	SET @Sql = @Sql + '	  where cab.ANULADO = 0 and ( cab.FFCH between ''' + @FechaDesde + ''' and ''' + @FechaHasta + ''' ) '
	SET @Sql = @Sql + '	 ) facturas '

	EXEC sp_executesql @Sql

	--EXEC [Contabilidad].[sp_CMV_ObtenerFacturasDeCompraDeUnaBaseDeDatos] 'DEMO', '20240101', '20240131'

END