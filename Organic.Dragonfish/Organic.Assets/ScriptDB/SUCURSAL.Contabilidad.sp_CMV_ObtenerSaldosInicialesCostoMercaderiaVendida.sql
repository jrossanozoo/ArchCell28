IF EXISTS(SELECT * FROM sys.objects WHERE name = 'sp_CMV_ObtenerSaldosInicialesCostoMercaderiaVendida' AND type in (N'P') and SCHEMA_ID('Contabilidad') = schema_id)
	DROP PROCEDURE [Contabilidad].[sp_CMV_ObtenerSaldosInicialesCostoMercaderiaVendida];
GO;

CREATE PROCEDURE [Contabilidad].[sp_CMV_ObtenerSaldosInicialesCostoMercaderiaVendida]
( 
	@Producto varchar(25),
	@BaseDeDatosActual varchar(8),
	@ListaBaseDeDatos varchar(1000),
	@Ejercicio numeric(8,0),
	@TablaDeRetorno varchar(100)
)
AS
BEGIN
	/* Obteniendo los datos iniciales de stock y precio desde CMVFACCOMPRA para armar los saldos iniciales */

	--declare @Producto varchar(25) = 'DRAGONFISH'
	--declare @BaseDeDatosActual varchar(8) = 'DEMO2'
	--declare @ListaBaseDeDatos varchar(1000) = 'DEMO2,DEMO4'
	--declare @Ejercicio numeric(8,0) = 1
	--declare @TablaDeRetorno varchar(100) = '##tblTmpSaldosIniciales'

	DECLARE @TablaReturn varchar(100) = ltrim( rtrim( @TablaDeRetorno ) )
	
	/*----------------------------------------------------------------------*/
	--DECLARE @tblTmpSaldosIniciales Contabilidad.udt_TableType_CMVTipoCompMovStock
	--SELECT * INTO ##tblTmpSaldosIniciales FROM @tblTmpSaldosIniciales
	--SET @TablaReturn = '##tblTmpSaldosIniciales'
	/*----------------------------------------------------------------------*/

	DECLARE @CatalogoSQL varchar(50)
	SET @CatalogoSQL = '[' + ltrim( rtrim( @Producto ) ) + '_' + ltrim( rtrim( @BaseDeDatosActual ) ) + ']'
	
	DECLARE @Sql nvarchar(max) = ''

	SET @Sql = @Sql + 'SELECT (ROW_NUMBER() OVER (ORDER BY FARTICULO, FCOLOR, FTALLE, FFECHA, TIMESTAMP)) AS ID, * '
	SET @Sql = @Sql + 'INTO #c_SaldosIniales FROM ( '
	SET @Sql = @Sql + '   SELECT Codigo as GlobalId, CodComp as Codigo, FactTipo, FArticulo, FColor, FTalle, FFecha, FLetra, FPtoVenEx, FNumComp, FPtoVen, FNumInt, FCant, FPrecio, Timestamp, FDesc, Base '
	SET @Sql = @Sql + '   FROM ' + ltrim( rtrim( @CatalogoSQL ) ) + '.[ZooLogic].[CMVFACCOMPRA] '
	SET @Sql = @Sql + '   WHERE EJERCICIO = ' + convert( varchar(8), @Ejercicio ) + ' and TINGRESO <> ''C'' and ( Base in  ( SELECT value FROM STRING_SPLIT( ''' + @ListaBaseDeDatos + ''', '','' ) ) ) '
	SET @Sql = @Sql + ') Saldos '

	SET @Sql = @Sql + 'INSERT INTO ' + @TablaReturn + ' '
	SET @Sql = @Sql + 'SELECT ID, GLOBALID, CODIGO, FACTTIPO, FARTICULO, FCOLOR, FTALLE, FFECHA, FLETRA, FPTOVENEX, FNUMCOMP, FPTOVEN, FNUMINT, FCANT, FPRECIO, TIMESTAMP, FDESC, BASE '
	SET @Sql = @Sql + 'FROM #c_SaldosIniales '

	EXEC sp_executesql @Sql

	/*-------------------------------------*/
	--SELECT * FROM ##tblTmpSaldosIniciales
	--DROP TABLE ##tblTmpSaldosIniciales
	/*-------------------------------------*/


	--EXEC [Contabilidad].[sp_CMV_ObtenerSaldosInicialesCostoMercaderiaVendida] 'DRAGONFISH', 'DEMO2', 1, 'DEMO2,DEMO4', '##NombreTabla'

END 
