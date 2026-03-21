**********************************************************************
Define Class zTestEnviaRecibeYProcesarInstruccionesScript as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as zTestEnviaRecibeYProcesarInstruccionesScript of zTestEnviaRecibeYProcesarInstruccionesScript.prg
	#ENDIF
	
	cBaseDeDatos = ""
	
	*-----------------------------------------------------------------------------------------
	function Setup
		local lcArchivoIni as string

		lcArchivoIni = addbs( _screen.zoo.cRutaInicial ) + "AAO.ini"
		
		if ( file( lcArchivoIni ) )
			delete file ( lcArchivoIni )
		endif

		this.cBaseDeDatos = goServicios.Parametros.Nucleo.Comunicaciones.ProcesarPaquetesDeLTipoABaseDeDatosEnLaBaseDeDatos
		goServicios.Parametros.Nucleo.Comunicaciones.ProcesarPaquetesDeLTipoABaseDeDatosEnLaBaseDeDatos = "PRUEBA"
	endfunc 

	*-----------------------------------------------------------------------------------------
	function TearDown
		local lcArchivoIni as string

		lcArchivoIni = addbs( _screen.zoo.cRutaInicial ) + "AAO.ini"
		
		if ( file( lcArchivoIni ) )
			delete file ( lcArchivoIni )
		endif

		goServicios.Parametros.Nucleo.Comunicaciones.ProcesarPaquetesDeLTipoABaseDeDatosEnLaBaseDeDatos = this.cBaseDeDatos
	endfunc 

	*---------------------------------
	Function zTestU_Init
		local loInstrucciones as EnviaRecibeYProcesarInstruccionesScript of EnviaRecibeYProcesarInstruccionesScript.prg
				
		_screen.mocks.Agregarmock( "DatosAAO" )
		_screen.mocks.AgregarSeteoMetodo( 'DATOSAAO', 'Obtener', "", "[EnviaRecibeYProcesar],[TimeOut]" )

		loInstrucciones = _Screen.zoo.crearobjeto( "EnviaRecibeYProcesarInstruccionesScript" )

		this.assertequals( "Error en la Base De Datos", "PRUEBA", loInstrucciones.cBaseDeDatos )
		this.assertequals( "Error en el nombre de archivo", "EnviaRecibeProcesa.sz", loInstrucciones.cArchivo )
		this.assertequals( "Error en el time out", 21600000,loInstrucciones.nTimeOut )
		this.assertequals( "Error en la cantidad de instrucciones", 0, loInstrucciones.Count )
		this.assertequals( "Error en la descripcion", "EnviaRecibeYProcesar", loInstrucciones.cTipo )
		this.assertequals( "Error en la descripcion", "comunicando y procesando novedades", loInstrucciones.cDescripcion )

		loInstrucciones.release()
		
		_screen.mocks.AgregarSeteoMetodo( 'DATOSAAO', 'Obtener', "999999999999", "[EnviaRecibeYProcesar],[TimeOut]" )

		loInstrucciones = _Screen.zoo.crearobjeto( "EnviaRecibeYProcesarInstruccionesScript" )
		this.assertequals( "Error en el time out", 999999999999,loInstrucciones.nTimeOut )

		loInstrucciones.release()

		_screen.mocks.verificarejecuciondemocks()
	Endfunc

	*---------------------------------
	Function zTestU_Actualizar
		local loInstrucciones as EnviaRecibeYProcesarInstruccionesScript of EnviaRecibeYProcesarInstruccionesScript.prg, lcScript as string, ;
			lcParametroRutaRecibe as string
		
		loInstrucciones = _Screen.zoo.crearobjeto( "EnviaRecibeYProcesarInstruccionesScript" )

		lcScript = loInstrucciones.Actualizar( null )
		
		this.asserttrue( "No se obtuvo un script", !empty( lcScript ) )
		this.assertequals( "Error en la cantidad de instrucciones", 3, loInstrucciones.Count )

		this.assertequals( "Instruccion 1 incorrecta", ;
			"iif( goServicios.Modulos.TieneModuloHabilitadoSegunAlias( 'comunicaciones' ), .t., _Screen.Zoo.App.Salir() )", ;
			loInstrucciones[1] )

		this.assertequals( "Instruccion 1 incorrecta", ;
			"=transmision(4)", ;
			loInstrucciones[2] )

		local lcParametroRutaRecibe as string
		
		lcParametroRutaRecibe = "iif(empty(goParametros.nucleo.transferencias.RutaRecepcion), " + ;
			"addbs(alltrim(_screen.Zoo.cRutaInicial)) + 'Recibe\', " + ;
			"addbs(alltrim(goParametros.nucleo.transferencias.RutaRecepcion)))"
		this.assertequals( "Instruccion 2 incorrecta", ;
			"goServicios.Transferencias.Recibir( " + lcParametroRutaRecibe + ", .f. )", ;
			loInstrucciones[3] )
			
		loInstrucciones.release()
	Endfunc
EndDefine
