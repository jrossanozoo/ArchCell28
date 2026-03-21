**********************************************************************
Define Class zTestAccionDeAgenteOrganic as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as zTestAccionDeAgenteOrganic of zTestAccionDeAgenteOrganic.prg
	#ENDIF
	
	oInstrucciones = null
	
	*-----------------------------------------------------------------------------------------
	function Setup
		this.oInstrucciones = _Screen.zoo.crearobjeto( "FakeInstruccionesScript", "zTestAccionDeAgenteOrganic.prg" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function TearDown
		if ( type( "this.oInstrucciones" ) == "O" ) and !isnull( this.oInstrucciones )
			this.oInstrucciones.Release()
		endif
	endfunc 

	*---------------------------------
	Function zTestU_Init
		local loAccion as AccionDeAgenteOrganic of AccionDeAgenteOrganic.prg

		loAccion = _Screen.zoo.crearobjeto( "AccionDeAgenteOrganic", "", this.oInstrucciones )
		
		this.assertequals( "Error en la Ruta Aplicacion", _screen.zoo.cRutaInicial, loAccion.cRutaAplicacion )
		this.assertequals( "Error en la Nombre Producto", strtran( strtran( forceext( _screen.zoo.app.cNombreExe, "" ), "_CORE", ""), "_NOREFOXEADO", "" ), loAccion.cNombreProducto )

		this.assertequals( "Error en la cantidad de parametros", 0, loAccion.oParametros.Count )
		this.asserttrue( "Debe haber acciones", !loAccion.HayInstrucciones() )

		loAccion.release()
	Endfunc

	*---------------------------------
	Function zTestU_ObtenerScript_Ok
		local loAccion as AccionDeAgenteOrganic of AccionDeAgenteOrganic.prg, lcScript as string, lnCantLineas as Integer
		local array lcScript[1]
			
		
		loAccion = _Screen.zoo.crearobjeto( "AccionDeAgenteOrganic", "", this.oInstrucciones )

		lcScript = loAccion.ObtenerScript()
		
		this.asserttrue( "Se debe obtener un script", !empty( lcScript ) )
		this.assertequals( "Error en la cantidad de parametros", 0, loAccion.oParametros.Count )
		this.asserttrue( "Debe haber acciones", loAccion.HayInstrucciones() )

		lnCantLineas = alines( laLineas, lcScript, 5, chr( 13 ) + chr( 10 ) )
		this.assertequals( "Error en la cantidad de  lineas", 7, lnCantLineas )
		this.assertTrue( "El contenido del script es incorrecto 2", "<IdAplicacion><C><" $ goServicios.Librerias.Desencriptar( laLineas[ 2 ] ))
		this.assertequals( "El contenido del script es incorrecto 3", "<cUsuarioLogueado><C><ADMIN>", goServicios.Librerias.Desencriptar( laLineas[ 3 ] ))
		this.assertequals( "El contenido del script es incorrecto 4", "<cSucursalActiva><C><Paises>", goServicios.Librerias.Desencriptar( laLineas[ 4 ] ))
		this.assertequals( "El contenido del script es incorrecto 6", "<Comando1><accion><>", goServicios.Librerias.Desencriptar( laLineas[ 5 ] ))
		this.assertequals( "El contenido del script es incorrecto 7", "<Comando2><accion><>", goServicios.Librerias.Desencriptar( laLineas[ 6 ] ))
		this.assertequals( "El contenido del script es incorrecto 8", "<_Screen.Zoo.App.Salir()><accion><>", goServicios.Librerias.Desencriptar( laLineas[ 7 ] ))
			
		loAccion.release()
	Endfunc

	*---------------------------------
	Function zTestU_ObtenerScript_Ok_ConBaseDeDatos
		local loAccion as AccionDeAgenteOrganic of AccionDeAgenteOrganic.prg, lcScript as string, lnCantLineas as Integer
		local array lcScript[1]
			
		this.oInstrucciones.cBaseDeDatos = "OTRA"
		
		loAccion = _Screen.zoo.crearobjeto( "AccionDeAgenteOrganic", "", this.oInstrucciones )

		lcScript = loAccion.ObtenerScript()
		
		this.asserttrue( "Se debe obtener un script", !empty( lcScript ) )
		this.assertequals( "Error en la cantidad de parametros", 0, loAccion.oParametros.Count )
		this.asserttrue( "Debe haber acciones", loAccion.HayInstrucciones() )

		lnCantLineas = alines( laLineas, lcScript, 5, chr( 13 ) + chr( 10 ) )
		this.assertequals( "Error en la cantidad de  lineas", 7, lnCantLineas )
		this.assertTrue( "El contenido del script es incorrecto 2", "<IdAplicacion><C><" $ goServicios.Librerias.Desencriptar( laLineas[ 2 ] ))
		this.assertequals( "El contenido del script es incorrecto 3", "<cUsuarioLogueado><C><ADMIN>", goServicios.Librerias.Desencriptar( laLineas[ 3 ] ))
		this.assertequals( "El contenido del script es incorrecto 4", "<cSucursalActiva><C><OTRA>", goServicios.Librerias.Desencriptar( laLineas[ 4 ] ))
		this.assertequals( "El contenido del script es incorrecto 6", "<Comando1><accion><>", goServicios.Librerias.Desencriptar( laLineas[ 5 ] ))
		this.assertequals( "El contenido del script es incorrecto 7", "<Comando2><accion><>", goServicios.Librerias.Desencriptar( laLineas[ 6 ] ))
		this.assertequals( "El contenido del script es incorrecto 8", "<_Screen.Zoo.App.Salir()><accion><>", goServicios.Librerias.Desencriptar( laLineas[ 7 ] ))
			
		loAccion.release()
	Endfunc

	*---------------------------------
	Function zTestU_GuardarScript_Ok
		local loAccion as AccionDeAgenteOrganic of AccionDeAgenteOrganic.prg, lcArchivo as string, lnCantLineas as Integer
		local array lcScript[1]
		
		this.oInstrucciones.cArchivo = "tempo.sz"
		
		lcArchivo = addbs( _screen.zoo.cRutaInicial ) + "AAO\Script\" + this.oInstrucciones.cArchivo 
		if file( lcArchivo )
			delete file ( lcArchivo )
		endif
		
		loAccion = _Screen.zoo.crearobjeto( "AccionDeAgenteOrganic", "", this.oInstrucciones )
		loAccion.GuardarScript()
		
		this.assertequals( "Error en la cantidad de parametros", 0, loAccion.oParametros.Count )
		this.asserttrue( "Debe haber acciones", loAccion.HayInstrucciones() )
		this.assertequals( "No se seteo el nombre del script", lcArchivo, loAccion.cARCHIVOSCRIPT )
		this.assertTrue( "Debe existir el archivo", file( lcArchivo ) )

		lcAux = filetostr( lcArchivo )
		
		lnCantLineas = alines( laLineas, lcAux , 5, chr( 13 ) + chr( 10 ) )
		this.assertequals( "Error en la cantidad de  lineas", 7, lnCantLineas )
		this.assertTrue( "El contenido del script es incorrecto 2", "<IdAplicacion><C><" $ goServicios.Librerias.Desencriptar( laLineas[ 2 ] ))
		this.assertequals( "El contenido del script es incorrecto 3", "<cUsuarioLogueado><C><ADMIN>", goServicios.Librerias.Desencriptar( laLineas[ 3 ] ))
		this.assertequals( "El contenido del script es incorrecto 4", "<cSucursalActiva><C><Paises>", goServicios.Librerias.Desencriptar( laLineas[ 4 ] ))
		this.assertequals( "El contenido del script es incorrecto 6", "<Comando1><accion><>", goServicios.Librerias.Desencriptar( laLineas[ 5 ] ))
		this.assertequals( "El contenido del script es incorrecto 7", "<Comando2><accion><>", goServicios.Librerias.Desencriptar( laLineas[ 6 ] ))
		this.assertequals( "El contenido del script es incorrecto 8", "<_Screen.Zoo.App.Salir()><accion><>", goServicios.Librerias.Desencriptar( laLineas[ 7 ] ))
			
		loAccion.release()
	Endfunc

	*---------------------------------
	Function zTestU_EnviarScript_Ok
		local loAccion as AccionDeAgenteOrganic of AccionDeAgenteOrganic.prg, loEx as zooexception OF zooexception.prg
		
		this.Agregarmocks( "ConectorAgenteDeAccionesOrganic" )
		_screen.mocks.AgregarSeteoMetodo( 'CONECTORAGENTEDEACCIONESORGANIC', 'Enviainstrucciones', .T., "'*OBJETO'" )
		
		loAccion = _Screen.zoo.crearobjeto( "AccionDeAgenteOrganic", "", this.oInstrucciones )

		this.asserttrue( "No debe dar error", loAccion.Enviar() )
		
		this.assertequals( "Error en la cantidad de parametros", 0, loAccion.oParametros.Count )
		this.asserttrue( "Debe haber acciones", loAccion.HayInstrucciones() )

		loEx = loAccion.ObtenerUltimoError()
		this.asserttrue( "No debe estar cargado el ultimo error", isnull( loEx ) )

		loAccion.release()
	Endfunc


	*---------------------------------
	Function zTestU_EnviarScript_LanzandoExcepcion
		local loAccion as AccionDeAgenteOrganic of AccionDeAgenteOrganic.prg, loEx as zooexception OF zooexception.prg
		
		this.Agregarmocks( "ConectorAgenteDeAccionesOrganic" )
		_screen.mocks.AgregarSeteoMetodo( 'CONECTORAGENTEDEACCIONESORGANIC', 'Enviainstrucciones', "*THROW", "'*OBJETO'" )

		this.Agregarmocks( "zooException" )
		_screen.mocks.AgregarSeteoMetodo( 'ZOOEXCEPTION', 'Grabar', .T., "'*OBJETO'" )
		
		loAccion = _Screen.zoo.crearobjeto( "AccionDeAgenteOrganic", "", this.oInstrucciones )

		this.asserttrue( "Debe dar error", !loAccion.Enviar() )
		
		this.assertequals( "Error en la cantidad de parametros", 0, loAccion.oParametros.Count )
		this.asserttrue( "Debe haber acciones", loAccion.HayInstrucciones() )

		loEx = loAccion.ObtenerUltimoError()
		this.assertnotnull( "No se cargo el ultimo error", loEx )
		this.assertequals( "El ultimo error no es el esperado", "No se pudieron enviar las instrucciones al agente organic (Fakeinstruccionesscript).", loEx.Message )

		loAccion.release()
	Endfunc

EndDefine

define class FakeInstruccionesScript as InstruccionesScript of InstruccionesScript.prg

	function Actualizar( p1 ) 
		this.Agregar( "Comando1")
		this.Agregar( "Comando2")
	endfunc

enddefine

