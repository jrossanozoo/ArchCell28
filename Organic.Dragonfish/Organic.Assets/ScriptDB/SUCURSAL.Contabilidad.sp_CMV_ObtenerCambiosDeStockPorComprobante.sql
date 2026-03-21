IF EXISTS(SELECT * FROM sys.objects WHERE name = 'sp_CMV_ObtenerCambiosDeStockPorComprobante' AND type in (N'P') and SCHEMA_ID('Contabilidad') = schema_id)
	DROP PROCEDURE Contabilidad.sp_CMV_ObtenerCambiosDeStockPorComprobante;
GO;

CREATE PROCEDURE [Contabilidad].[sp_CMV_ObtenerCambiosDeStockPorComprobante]
(
	@CatalogoSQL varchar(50),
	@Sucursal varchar(8),
	@FechaDesde varchar(8),
	@FechaHasta varchar(8)
)
AS
BEGIN
	/* Esta SP busca todos los comprobantes que mueven stock y me devuelve las cantidades modificadas dentro de un período dado.
	   Las cantidades mencionadas son obtenidas de la ADT_COMB, dado que es el unico registro cierto de los cambios realizados. */
	
	--DECLARE @CatalogoSQL varchar(50) = 'DRAGONFISH_DEMO2'
	--DECLARE @Sucursal varchar(8) = 'DEMO2'
	--DECLARE @FechaDesde varchar(8) = '20250301'
	--DECLARE @FechaHasta varchar(8) = '20250331'

	DECLARE @Sql nvarchar(max) = ''

	SET @Sql = @Sql + 'DECLARE @c_Comprobantes Contabilidad.udt_TableType_CMVDescComprobante '

	---------ComprobanteV------------------------------------
	SET @Sql = @Sql + 'INSERT INTO @c_Comprobantes '
	SET @Sql = @Sql + '   select CODIGO, FACTTIPO, FFCH, FLETRA, FPTOVEN as FPTOVENEX, FNUMCOMP, FPTOVEN, 0 as NUMINT, DESCFW, TIMESTAMP '-- + @Timestamp + ' '
	SET @Sql = @Sql + '   from ' + ltrim( rtrim( @CatalogoSQL ) ) + '.Zoologic.ComprobanteV '
	SET @Sql = @Sql + '   where anulado = 0 and ( ffch between ''' + @FechaDesde + ''' and ''' + @Fechahasta + ''' ) '
		
	-------- FACCOMPRA -------------------------------------
	SET @Sql = @Sql + 'INSERT INTO @c_Comprobantes '
	SET @Sql = @Sql + '   select CODIGO, FACTTIPO, FFCH, FLETRA, FPTOVENEXT, FNUMCOMP, FPTOVEN, NUMINT, DESCFW, TIMESTAMP '-- + @Timestamp + ' '
	SET @Sql = @Sql + '   from ' + ltrim( rtrim( @CatalogoSQL ) ) + '.Zoologic.Faccompra '
	SET @Sql = @Sql + '   where anulado = 0 and ( ffch between ''' + @FechaDesde + ''' and ''' + @Fechahasta + ''' ) '
		
	-------- NCCOMPRA -------------------------------------
	SET @Sql = @Sql + 'INSERT INTO @c_Comprobantes '
	SET @Sql = @Sql + '   select CODIGO, FACTTIPO, FFCH, FLETRA, FPTOVENEXT, FNUMCOMP, FPTOVEN, NUMINT, DESCFW, TIMESTAMP '-- + @Timestamp + ' '
	SET @Sql = @Sql + '   from ' + ltrim( rtrim( @CatalogoSQL ) ) + '.Zoologic.NcCompra '
	SET @Sql = @Sql + '   where anulado = 0 and ( ffch between ''' + @FechaDesde + ''' and ''' + @Fechahasta + ''' ) '
		
	-------- NDCOMPRA -------------------------------------
	SET @Sql = @Sql + 'INSERT INTO @c_Comprobantes '
	SET @Sql = @Sql + '   select CODIGO, FACTTIPO, FFCH, FLETRA, FPTOVENEXT, FNUMCOMP, FPTOVEN, NUMINT, DESCFW, TIMESTAMP '-- + @Timestamp + ' '
	SET @Sql = @Sql + '   from ' + ltrim( rtrim( @CatalogoSQL ) ) + '.Zoologic.NdCompra '
	SET @Sql = @Sql + '   where anulado = 0 and ( ffch between ''' + @FechaDesde + ''' and ''' + @Fechahasta + ''' ) '
		
	-------- REMCOMPRA -------------------------------------
	SET @Sql = @Sql + 'INSERT INTO @c_Comprobantes '
	SET @Sql = @Sql + '   select CODIGO, FACTTIPO, FFCH, FLETRA, FPTOVENEXT, FNUMCOMP, FPTOVEN, NUMINT, DESCFW, TIMESTAMP '-- + @Timestamp + ' '
	SET @Sql = @Sql + '   from ' + ltrim( rtrim( @CatalogoSQL ) ) + '.Zoologic.RemCompra '
	SET @Sql = @Sql + '   where anulado = 0 and ( ffch between ''' + @FechaDesde + ''' and ''' + @Fechahasta + ''' ) '
		
	-------- CANCOMPRA -------------------------------------
	SET @Sql = @Sql + 'INSERT INTO @c_Comprobantes '
	SET @Sql = @Sql + '   select CODIGO, FACTTIPO, FFCH, FLETRA, FPTOVEN as FPTOVENEXT, FNUMCOMP, FPTOVEN, 0 as NUMINT, DESCFW, TIMESTAMP '-- + @Timestamp + ' '
	SET @Sql = @Sql + '   from ' + ltrim( rtrim( @CatalogoSQL ) ) + '.Zoologic.CanCompra '
	SET @Sql = @Sql + '   where anulado = 0 and ( ffch between ''' + @FechaDesde + ''' and ''' + @Fechahasta + ''' ) '

	----------MStock--------------------------------------------
	--SET @Sql = @Sql + 'INSERT INTO @c_Comprobantes '
	--SET @Sql = @Sql + '   select CODIGO, 0 as FACTTIPO, FECHA, '''' as LETRA, 0 as PTOVENEX, 0 as NUMCOMP, 0 as PTOVEN, NUMERO, DESCFW, TIMESTAMP '-- + @Timestamp + ' '
	--SET @Sql = @Sql + '   from ' + ltrim( rtrim( @CatalogoSQL ) ) + '.Zoologic.MStock '
	--SET @Sql = @Sql + '   where anulado = 0 and ( fecha between ''' + @FechaDesde + ''' and ''' + @Fechahasta + ''' ) '


	

	-------- JOINEO LOS COMPROBANTES CON LA ADT_COMB -------
	SET @Sql = @Sql + 'SELECT (ROW_NUMBER() OVER (ORDER BY COART, COCOL, COTALLE, COFECHA, TIMESTAMP)) AS ID, '''' AS GLOBALID, * '
	SET @Sql = @Sql + 'INTO #c_Movimientos FROM ( '
	SET @Sql = @Sql + 'SELECT CODIGO, FACTTIPO, COART, COCOL, COTALLE, COFECHA, LETRA, PTOVENEXT, NUMCOMP, PTOVEN, NUMINT, COCANT, 0 as PRECIO, TIMESTAMP, CODESC, ''' + @Sucursal + ''' as BASE '
	SET @Sql = @Sql + '   from ('
	SET @Sql = @Sql + '      select CODIGO, FACTTIPO, COART, COCOL, TALLE as COTALLE, LETRA, PTOVENEXT, NUMCOMP, PTOVEN, NUMINT '
	SET @Sql = @Sql + '         , sum(COCANT) as COCANT, DESCRIP as CODESC, max(t.FECHA) as COFECHA, max(timestamp) as TIMESTAMP '
	SET @Sql = @Sql + '      from ' + ltrim( rtrim( @CatalogoSQL ) ) + '.ZooLogic.ADT_COMB adt '
	SET @Sql = @Sql + '         left join @c_Comprobantes as t on t.DESCRIP = adt.ADT_COMP '
	SET @Sql = @Sql + '       where t.Descrip is not null and adt.adt_ext = 0 '
	SET @Sql = @Sql +  '      group by CODIGO, FACTTIPO, COART, COCOL, TALLE, LETRA, PTOVENEXT, NUMCOMP, PTOVEN, NUMINT, DESCRIP '
	SET @Sql = @Sql + '   ) as c_adt_comb '
	SET @Sql = @Sql + 'where c_adt_comb.COART is not null and c_adt_comb.COCANT <> 0 '
	SET @Sql = @Sql + '   and ( COFECHA between ''' + @FechaDesde + ''' and ''' + @Fechahasta + ''' ) '
	SET @Sql = @Sql + ') Movimientos '




	-------- CONSULTA PARA OBTENER LOS DATOS FINALES -------
	SET @Sql = @Sql + 'SELECT ID, GLOBALID, CODIGO, FACTTIPO, COART, COCOL, COTALLE, COFECHA, LETRA, PTOVENEXT, NUMCOMP, PTOVEN, NUMINT, COCANT, PRECIO, TIMESTAMP, CODESC, BASE '
	SET @Sql = @Sql + 'FROM #c_Movimientos '

	EXEC sp_executesql @Sql


	--EXEC [Contabilidad].[sp_CMV_ObtenerCambiosDeStockSegunComprobante] 'DRAGONFISH_DEMO', 'DEMO', '20240101', '20240131'

END