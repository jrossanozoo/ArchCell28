Define Class zTestCreardataConfigIni As FxuTestCase Of FxuTestCase.prg

	#If .F.
		Local This As zTestCreardataConfigIni Of zTestCreardataConfigIni.prg
	#Endif

	*-----------------------------------------------------------------------------------------
	function Setup() as Void
		delete file ( addbs( _screen.zoo.ObtenerRutaTemporal() ) + "dataconfig.ini" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function tearDown() as Void
		delete file ( addbs( _screen.zoo.ObtenerRutaTemporal() ) + "dataconfig.ini" )
	endfunc 	
	*-----------------------------------------------------------------------------------------
	function zTestCreardataConfigIniSQLServer
		local loCrearDataConfig as Object, lcRuta as String, lcBien as String, lcGenerado as String, lcPasswordAdministrativa as String, loCredencialesSQLServer as Object
		local lcTCodigoServidor as String
		loCrearDataConfig = _screen.zoo.crearobjeto( "CreardataConfigIni", "", _screen.zoo.ObtenerRutaTemporal() )
		
		this.assertequals( "El nombre del archivo es incorrecto.", "DataConfig.ini" , loCrearDataConfig.cArchivo )

		loCrearDataConfig.ValidarExistencia( "SQLSERVER", _Screen.Zoo.App.cNombreDelServidorSQL, "SQL Server Native Client 11.0", 8, 3 )

		lcPasswordAdministrativa = _screen.Zoo.InvocarMetodoEstatico( "ZooLogicSA.Core.BasesDeDatos.InfoUsuariosServidorSql", "ObtenerPasswordAdministrativa" )
		loCredencialesSQLServer = _screen.Zoo.CrearObjeto( "ZooLogicSA.Core.BasesDeDatos.CredencialesSqlServer", "", _Screen.Zoo.App.cNombreDelServidorSQL, lcPasswordAdministrativa, _screen.Zoo.App.NombreProducto )

		lcTCodigoServidor = iif(golibrerias.esautobuilddistribuido(),"",[CODIGODESERVIDOR=]+loCredencialesSQLServer.CodigoDeServidor+chr(13))
		
		lcGenerado = upper( filetostr( loCrearDataConfig.cPathArchivoIni ) )
		
		this.AssertTrue( "No se genero correctamente TipoBase", "TIPOBASE=SQLSERVER" $ lcGenerado)
		this.AssertTrue( "No se genero correctamente Servidor", upper("Servidor="+_Screen.Zoo.App.cNombreDelServidorSQL) $ lcGenerado)
		this.AssertTrue( "No se genero correctamente Driver", upper("Driver=SQL Server Native Client 11.0") $ lcGenerado)
		this.AssertTrue( "No se genero correctamente Timeout", upper("Timeout=8") $ lcGenerado)
		this.AssertTrue( "No se genero correctamente Reintentos", upper("Reintentos=3") $ lcGenerado)
		this.AssertTrue( "No se genero correctamente SeguridadIntegrada", upper("SeguridadIntegrada=SI") $ lcGenerado)
		if !empty(lcTCodigoServidor)
			this.AssertTrue( "No se genero correctamente CodigoDeServidor", upper(lcTCodigoServidor ) $ lcGenerado)
		endif
		loCrearDataConfig.release()	
	endfunc

enddefine
