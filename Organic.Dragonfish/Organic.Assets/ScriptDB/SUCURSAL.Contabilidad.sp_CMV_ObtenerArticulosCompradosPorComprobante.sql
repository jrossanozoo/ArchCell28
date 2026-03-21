IF EXISTS(SELECT * FROM sys.objects WHERE name = 'sp_CMV_ObtenerArticulosCompradosPorComprobante' AND type in (N'P') and SCHEMA_ID('Contabilidad') = schema_id)
	DROP PROCEDURE [Contabilidad].[sp_CMV_ObtenerArticulosCompradosPorComprobante];
GO;

CREATE procedure [Contabilidad].[sp_CMV_ObtenerArticulosCompradosPorComprobante]
(
	@CatalogoSQL varchar(50),
	@Sucursal varchar(8),
	@FechaDesde varchar(8),
	@FechaHasta varchar(8)
)
AS
BEGIN
	/* Esta SP busca todos los comprobantes de compra y sus articulos dentro de un período dado,  para obtención de costos del período */
	
	--DECLARE @CatalogoSQL varchar(50) = 'DRAGONFISH_DEMO2'
	--DECLARE @Sucursal varchar(8) = 'DEMO2'
	--DECLARE @FechaDesde varchar(8) = '20250401'
	--DECLARE @FechaHasta varchar(8) = '20250430'

	DECLARE @Sql nvarchar(max) = ''

	SET @Sql = @Sql + 'DECLARE @c_Comprobantes Contabilidad.udt_TableType_CMVTipoCompMovStock '

	
	---------FACCOMPRA------------------------------------
	SET @Sql = @Sql + 'INSERT INTO @c_Comprobantes '
	SET @Sql = @Sql + 'select 0 as ID, '''' as GLOBALID, CODIGO, FACTTIPO, FART, FCOLO, FTALL, FFCH, FLETRA, FPTOVENEXT, FNUMCOMP, FPTOVEN, NUMINT, CANTIDAD, PRECIO, TIMESTAMP, DESCFW, ''' + @Sucursal + ''' as BASE '
	SET @Sql = @Sql + 'From ( '
	SET @Sql = @Sql + '   select cab.CODIGO, cab.FACTTIPO, det.FART, det.FCOLO, det.FTALL, cab.FFCH, cab.FLETRA, cab.FPTOVENEXT, cab.FNUMCOMP, '
	SET @Sql = @Sql + '      cab.FPTOVEN, cab.NUMINT, det.FCANT as CANTIDAD, (det.PRUNSINIMP * cab.COTIZ) as PRECIO, cab.DESCFW, cab.BDALTAFW, cab.TIMESTAMP '-- + @Timestamp + ' '
	SET @Sql = @Sql + '   from ' + ltrim( rtrim( @CatalogoSQL ) ) + '.Zoologic.FACCOMPRA cab '
	SET @Sql = @Sql + '      left join ' + ltrim( rtrim( @CatalogoSQL ) ) + '.Zoologic.FACCOMPRADET det on cab.CODIGO = det.CODIGO '
	SET @Sql = @Sql + '   where cab.ANULADO = 0 and ( cab.FFCH between ''' + @FechaDesde + ''' and ''' + @FechaHasta + ''' ) '
	SET @Sql = @Sql + ') Compras '
	
	
	---------NCCOMPRA------------------------------------
	SET @Sql = @Sql + 'INSERT INTO @c_Comprobantes '
	SET @Sql = @Sql + 'select 0 as ID, '''' as GLOBALID, CODIGO, FACTTIPO, FART, FCOLO, FTALL, FFCH, FLETRA, FPTOVENEXT, FNUMCOMP, FPTOVEN, NUMINT, CANTIDAD, PRECIO, TIMESTAMP, DESCFW, ''' + @Sucursal + ''' as BASE '
	SET @Sql = @Sql + 'From ( '
	SET @Sql = @Sql + '   select cab.CODIGO, cab.FACTTIPO, det.FART, det.FCOLO, det.FTALL, cab.FFCH, cab.FLETRA, cab.FPTOVENEXT, cab.FNUMCOMP, '
	SET @Sql = @Sql + '      cab.FPTOVEN, cab.NUMINT, det.FCANT as CANTIDAD, (det.PRUNSINIMP * cab.COTIZ) as PRECIO, cab.DESCFW, cab.BDALTAFW, cab.TIMESTAMP '-- + @Timestamp + ' '
	SET @Sql = @Sql + '   from ' + ltrim( rtrim( @CatalogoSQL ) ) + '.Zoologic.NCCOMPRA cab '
	SET @Sql = @Sql + '      left join ' + ltrim( rtrim( @CatalogoSQL ) ) + '.Zoologic.NCCOMPRADET det on cab.CODIGO = det.CODIGO '
	SET @Sql = @Sql + '   where cab.ANULADO = 0 and ( cab.FFCH between ''' + @FechaDesde + ''' and ''' + @FechaHasta + ''' ) '
	SET @Sql = @Sql + ') NC '


	---------NDCOMPRA------------------------------------
	SET @Sql = @Sql + 'INSERT INTO @c_Comprobantes '
	SET @Sql = @Sql + 'select 0 as ID, '''' as GLOBALID, CODIGO, FACTTIPO, FART, FCOLO, FTALL, FFCH, FLETRA, FPTOVENEXT, FNUMCOMP, FPTOVEN, NUMINT, CANTIDAD, PRECIO, TIMESTAMP, DESCFW, ''' + @Sucursal + ''' as BASE '
	SET @Sql = @Sql + 'From ( '
	SET @Sql = @Sql + '   select cab.CODIGO, cab.FACTTIPO, det.FART, det.FCOLO, det.FTALL, cab.FFCH, cab.FLETRA, cab.FPTOVENEXT, cab.FNUMCOMP, '
	SET @Sql = @Sql + '      cab.FPTOVEN, cab.NUMINT, det.FCANT as CANTIDAD, (det.PRUNSINIMP * cab.COTIZ) as PRECIO, cab.DESCFW, cab.BDALTAFW, cab.TIMESTAMP '-- + @Timestamp + ' '
	SET @Sql = @Sql + '   from ' + ltrim( rtrim( @CatalogoSQL ) ) + '.Zoologic.NDCOMPRA cab '
	SET @Sql = @Sql + '      left join ' + ltrim( rtrim( @CatalogoSQL ) ) + '.Zoologic.NDCOMPRADET det on cab.CODIGO = det.CODIGO '
	SET @Sql = @Sql + '   where cab.ANULADO = 0 and ( cab.FFCH between ''' + @FechaDesde + ''' and ''' + @FechaHasta + ''' ) '
	SET @Sql = @Sql + ') ND '

	SET @Sql = @Sql + 'SELECT ID, GLOBALID, CODIGO, FACTTIPO, ARTICULO, COLOR, TALLE, FECHA, LETRA, PTOVENEXT, NUMCOMP, PTOVEN, NUMINT, CANTIDAD, PRECIO, TIMESTAMP, DESCRIP, BASE FROM @c_Comprobantes '

	EXEC sp_executesql @Sql

	--EXEC [Contabilidad].[sp_CMV_ObtenerComprobantesDeCompra] 'DRAGONFISH_DEMO2', 'DEMO2', '20250401', '20250430'

END
