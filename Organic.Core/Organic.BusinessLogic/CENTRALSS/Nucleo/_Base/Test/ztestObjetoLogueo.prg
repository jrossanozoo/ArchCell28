**********************************************************************
Define Class zTestObjetoLogueo as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as zTestObjetoLogueo of zTestObjetoLogueo.prg
	#ENDIF
	lMockearParametros = .F.
	lGuardaValorModoSystemStartUp = .f.
	lGuardaValorCapaDePresentacion = .f.
	lGuardaValorServicioRest = .f.

	
	*-----------------------------------------------------------------------------------------
	function Setup
		if pemstatus(_screen,"lEsModoSystemStartUp", 5) 
			this.lGuardaValorModoSystemStartUp  = _screen.lEsModoSystemStartUp
		else
			_screen.AddProperty("lEsModoSystemStartUp", .f.)
		endif
		if pemstatus(_screen,"lEsCapaDePresentacion", 5) 
			this.lGuardaValorCapaDePresentacion = _screen.lEsCapaDePresentacion
		else
			_screen.AddProperty("lEsCapaDePresentacion", .f.)
		endif
		if pemstatus(_screen,"lUsaServicioRest", 5) 
			this.lGuardaValorServicioRest = _screen.lUsaServicioRest
		else
			_screen.AddProperty("lUsaServicioRest", .f.)
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function TearDown
		if pemstatus(_screen,"lEsModoSystemStartUp", 5)
			_screen.lEsModoSystemStartUp = this.lGuardaValorModoSystemStartUp
		endif
		if pemstatus(_screen,"lEsCapaDePresentacion", 5) 
			_screen.lEsCapaDePresentacion = this.lGuardaValorCapaDePresentacion 
		endif 		
		if pemstatus(_screen,"lUsaServicioRest", 5) 
			_screen.lUsaServicioRest = this.lGuardaValorServicioRest 
		endif
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestInstanciar
		local loObjetoLogueo as Object, loCol as zoocoleccion OF zoocoleccion.prg

		loObjetoLogueo = _screen.zoo.crearobjeto( "ObjetoLogueo", "ObjetoLogueo.prg" )
		
		This.asserttrue( "No se indico el Id unico del objeto.", !empty( loObjetoLogueo.cIdLogueo ) )
		This.assertequals( "No se instancio el Objeto logueos.", "O", vartype( loObjetoLogueo ) )
		
		loCol = loObjetoLogueo.ObtenerLogueos()
		
		This.assertequals( "No se creo la coleccion de items.", "O", vartype( loCol ) )
		This.assertequals( "La coleccion debe estar vacia.", 0, loCol.Count )
		do Case
			case _Screen.zoo.app.TipodeBase = "NATIVA"
				This.assertequals( "El repositorio por defecto es incorrecto.", "LOG.ERR", alltrim( loObjetoLogueo.cLogger ) )
			case _Screen.zoo.app.TipodeBase = "SQLSERVER"
				This.assertequals( "El repositorio por defecto es incorrecto.", "FULL_LOG.ERR", alltrim( loObjetoLogueo.cLogger ) )
			otherwise
				This.Asserttrue( "TESTEAR !!!!", .F. )
		EndCase		
		loObjetoLogueo.Release()
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestEscribir
		local loObjetoLogueo as Object, loItem as Object, lcUsuarioAnterior as String, loError as zooexception OF zooexception.prg, ;
			loCol as zoocoleccion OF zoocoleccion.prg, lcLog as string, lcArchivoLog as string, lcAuxLog as string

		private goLibrerias
		goLibrerias = createobject( "TestLibrerias" )
		lcArchivoLog = addbs( lower( strtran( _Screen.zoo.cRutaInicial, "\_base", "" ) ) ) + "log\ZooSession.log"
		lcAuxLog = filetostr( lcArchivoLog )
		
		delete file ( lcArchivoLog )
		
		try 
			lcUsuarioAnterior = goServicios.Seguridad.cUsuarioLogueado
			goServicios.Seguridad.cUsuarioLogueado = "TESTADMIN"
			
			loObjetoLogueo = _screen.zoo.crearobjeto( "ObjetoLogueo", "ObjetoLogueo.prg" )
			loObjetoLogueo.SetearCantidadDeLineasDelBuffer( 2 )
			loObjetoLogueo.cLogger = "ZooSession"
			
			*--------------
			loObjetoLogueo.Escribir( "Item 1 Nivel 4 agregado de una sola ves", 4 )
			
			loCol = loObjetoLogueo.ObtenerLogueosDeNivel( 4 )
			loItem = loCol.item[1]

			This.assertequals( "No se seteo correctamente la base de datos.", "PAISES", upper( alltrim( loObjetoLogueo.oInfoLog.BaseDatos ) ) )
			This.assertequals( "No se seteo correctamente el usuario", "TESTADMIN", upper( alltrim( loObjetoLogueo.oInfoLog.Usuario ) ) )
			This.assertequals( "No se seteo correctamente el serie", _screen.zoo.app.cserie, upper( alltrim( loObjetoLogueo.oInfoLog.Serie ) ) )
			This.assertequals( "No se seteo correctamente la version", "01.0001.00000", upper( alltrim( loObjetoLogueo.oInfoLog.Version ) ) )
			This.assertequals( "No se seteo correctamente la aplicacion.", "NUCLEO", upper( alltrim( loObjetoLogueo.oInfoLog.Aplicacion ) ) )
			This.assertequals( "No se seteo correctamente la fecha(item)", {11/12/1976}, loItem.Fecha )
			This.assertequals( "No se seteo correctamente la hora.", "99:99:99", upper( alltrim( loItem.Hora ) ) )
			This.assertequals( "No se seteo correctamente el tipo de log", 4, loItem.TipoDeLogueo )
			This.assertequals( "No se seteo correctamente la descripcion.", "ITEM 1 NIVEL 4 AGREGADO DE UNA SOLA VES", upper( alltrim( loItem.Descripcion ) ) )
			
			*--------------
			loObjetoLogueo.Escribir( "Item 1 Nivel 1 agregado de una sola ves", 1 )

			loCol = loObjetoLogueo.ObtenerLogueosDeNivel( 1 )
			loItem = loCol.item[1]

			This.assertequals( "No se seteo correctamente la base de datos.", "PAISES", upper( alltrim( loObjetoLogueo.oInfoLog.BaseDatos ) ) )
			This.assertequals( "No se seteo correctamente el usuario", "TESTADMIN", upper( alltrim( loObjetoLogueo.oInfoLog.Usuario ) ) )
			This.assertequals( "No se seteo correctamente el serie", _screen.zoo.app.cserie, upper( alltrim( loObjetoLogueo.oInfoLog.Serie ) ) )
			This.assertequals( "No se seteo correctamente la version", "01.0001.00000", upper( alltrim( loObjetoLogueo.oInfoLog.Version ) ) )
			This.assertequals( "No se seteo correctamente la aplicacion.", "NUCLEO", upper( alltrim( loObjetoLogueo.oInfoLog.Aplicacion ) ) )
			This.assertequals( "No se seteo correctamente la hora.", "99:99:99", upper( alltrim( loItem.Hora ) ) )
			This.assertequals( "No se seteo correctamente el tipo de log", 1, loItem.TipoDeLogueo )
			This.assertequals( "No se seteo correctamente la descripcion.", "ITEM 1 NIVEL 1 AGREGADO DE UNA SOLA VES", upper( alltrim( loItem.Descripcion ) ) )

			*--------------
			loObjetoLogueo.Escribir( "Item 2 Nivel 4 agregado de una sola ves", 4 )
			
			loCol = loObjetoLogueo.ObtenerLogueosDeNivel( 4 )
			loItem = loCol.item[2]

			This.assertequals( "No se seteo correctamente la base de datos.", "PAISES", upper( alltrim( loObjetoLogueo.oInfoLog.BaseDatos ) ) )
			This.assertequals( "No se seteo correctamente el usuario", "TESTADMIN", upper( alltrim( loObjetoLogueo.oInfoLog.Usuario ) ) )
			This.assertequals( "No se seteo correctamente el serie", _screen.zoo.app.cserie, upper( alltrim( loObjetoLogueo.oInfoLog.Serie ) ) )
			This.assertequals( "No se seteo correctamente la version", "01.0001.00000", upper( alltrim( loObjetoLogueo.oInfoLog.Version ) ) )
			This.assertequals( "No se seteo correctamente la aplicacion.", "NUCLEO", upper( alltrim( loObjetoLogueo.oInfoLog.Aplicacion ) ) )
			This.assertequals( "No se seteo correctamente la fecha(item)", {11/12/1976}, loItem.Fecha )
			This.assertequals( "No se seteo correctamente la hora.", "99:99:99", upper( alltrim( loItem.Hora ) ) )
			This.assertequals( "No se seteo correctamente el tipo de log", 4, loItem.TipoDeLogueo )
			This.assertequals( "No se seteo correctamente la descripcion.", "ITEM 2 NIVEL 4 AGREGADO DE UNA SOLA VES", upper( alltrim( loItem.Descripcion ) ) )

			*--------------		
			this.assertTrue( "No debe estar creado el aappender ya que el buffer sigue en memoria", !file( lcArchivoLog ) )
			
			loObjetoLogueo.Escribir( "Item 3 Nivel 4 agregado de una sola ves", 4 )
			
			loCol = loObjetoLogueo.ObtenerLogueosDeNivel( 4 )
			This.assertTrue( "Se supero la cantidad de lineas del buffer para el nivel 4. El buffer debe estar vacio", isnull( loCol ) )

			this.assertTrue( "Debe estar creado el aappender ya que el buffer fue vaciado", file( lcArchivoLog ) )
			lcLog = right( lower( filetostr( lcArchivoLog ) ), 100 )
			this.assertTrue( "No se guardo parcialmente el buffer al pasar la cantidad de lineas seteadas en el test", ( "item 1 nivel 1 agregado de una sola ves" $ lcLog ) )

			*--------------
			loObjetoLogueo.Escribir( "Item 4 Nivel 4 agregado de una sola ves", 4 )
			
			loCol = loObjetoLogueo.ObtenerLogueosDeNivel( 4 )
			loItem = loCol.item[1]

			This.assertequals( "No se seteo correctamente la base de datos.", "PAISES", upper( alltrim( loObjetoLogueo.oInfoLog.BaseDatos ) ) )
			This.assertequals( "No se seteo correctamente el usuario", "TESTADMIN", upper( alltrim( loObjetoLogueo.oInfoLog.Usuario ) ) )
			This.assertequals( "No se seteo correctamente el serie", _screen.zoo.app.cserie, upper( alltrim( loObjetoLogueo.oInfoLog.Serie ) ) )
			This.assertequals( "No se seteo correctamente la version", "01.0001.00000", upper( alltrim( loObjetoLogueo.oInfoLog.Version ) ) )
			This.assertequals( "No se seteo correctamente la aplicacion.", "NUCLEO", upper( alltrim( loObjetoLogueo.oInfoLog.Aplicacion ) ) )
			This.assertequals( "No se seteo correctamente la fecha(item)", {11/12/1976}, loItem.Fecha )
			This.assertequals( "No se seteo correctamente la hora.", "99:99:99", upper( alltrim( loItem.Hora ) ) )
			This.assertequals( "No se seteo correctamente el tipo de log", 4, loItem.TipoDeLogueo )
			This.assertequals( "No se seteo correctamente la descripcion.", "ITEM 4 NIVEL 4 AGREGADO DE UNA SOLA VES", upper( alltrim( loItem.Descripcion ) ) )

		catch to loError
			throw loError
			
		finally
			strtofile( lcAuxLog, lcArchivoLog, 0 )
			
			goServicios.Seguridad.cUsuarioLogueado = lcUsuarioAnterior
			loItem = null
			loObjetoLogueo.Release()
			
		endtry

	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestEscribirAlUltimo()
		local loObjetoLogueo as Object, loItem as Object, lcUsuarioAnterior as String, loError as zooexception OF zooexception.prg, ;
			loCol as zoocoleccion OF zoocoleccion.prg

		private goLibrerias
		goLibrerias = createobject( "TestLibrerias" )
		
		Try
			lcUsuarioAnterior = goServicios.Seguridad.cUsuarioLogueado
			goServicios.Seguridad.cUsuarioLogueado = "TESTADMIN"
			loObjetoLogueo = _screen.zoo.crearobjeto( "ObjetoLogueo", "ObjetoLogueo.prg" )
			
			loObjetoLogueo.Escribir( "Item", 4 )
			
			loCol = loObjetoLogueo.ObtenerLogueosDeNivel( 4 )
			loItem = loCol.item[1]

			This.assertequals( "No se seteo correctamente la base de datos (1)", "PAISES", upper( alltrim( loObjetoLogueo.oInfoLog.BaseDatos ) ) )
			This.assertequals( "No se seteo correctamente el usuario (1)", "TESTADMIN", upper( alltrim( loObjetoLogueo.oInfoLog.Usuario ) ) )
			This.assertequals( "No se seteo correctamente el serie (1)", _screen.zoo.app.cserie, upper( alltrim( loObjetoLogueo.oInfoLog.Serie ) ) )
			This.assertequals( "No se seteo correctamente la version (1)", "01.0001.00000", upper( alltrim( loObjetoLogueo.oInfoLog.Version ) ) )
			This.assertequals( "No se seteo correctamente la aplicacion (1)", "NUCLEO", upper( alltrim( loObjetoLogueo.oInfoLog.Aplicacion ) ) )
			This.assertequals( "No se seteo correctamente la hora (1)", "99:99:99", upper( alltrim( loItem.Hora ) ) )
			This.assertequals( "No se seteo correctamente el tipo de log (1)", 4, loItem.TipoDeLogueo )
			This.assertequals( "No se seteo correctamente la descripcion (1)", "ITEM", upper( alltrim( loItem.Descripcion ) ) )
			This.assertequals( "No se seteo correctamente la accion (1)", "NO DISP.", upper( alltrim( loObjetoLogueo.oInfoLog.Accion ) ) )			
			
			loObjetoLogueo.EscribirAlUltimo( "1" )

			loCol = loObjetoLogueo.ObtenerLogueosDeNivel( 4 )
			loItem = loCol.item[1]

			This.assertequals( "No se seteo correctamente la base de datos (2)", "PAISES", upper( alltrim( loObjetoLogueo.oInfoLog.BaseDatos ) ) )
			This.assertequals( "No se seteo correctamente el usuario (2)", "TESTADMIN", upper( alltrim( loObjetoLogueo.oInfoLog.Usuario ) ) )
			This.assertequals( "No se seteo correctamente el serie (2)", _screen.zoo.app.cserie, upper( alltrim( loObjetoLogueo.oInfoLog.Serie ) ) )
			This.assertequals( "No se seteo correctamente la version (2)", "01.0001.00000", upper( alltrim( loObjetoLogueo.oInfoLog.Version ) ) )
			This.assertequals( "No se seteo correctamente la aplicacion (2)", "NUCLEO", upper( alltrim( loObjetoLogueo.oInfoLog.Aplicacion ) ) )
			This.assertequals( "No se seteo correctamente la hora (2)", "99:99:99", upper( alltrim( loItem.Hora ) ) )
			This.assertequals( "No se seteo correctamente el tipo de log (2)", 4, loItem.TipoDeLogueo )
			This.assertequals( "No se seteo correctamente la descripcion (2)", "ITEM1", upper( alltrim( loItem.Descripcion ) ) )
			This.assertequals( "No se seteo correctamente la accion (2)", "NO DISP.", upper( alltrim( loObjetoLogueo.oInfoLog.Accion ) ) )						

			loObjetoLogueo.EscribirAlUltimo( "en3veces." )

			loCol = loObjetoLogueo.ObtenerLogueosDeNivel( 4 )
			loItem = loCol.item[1]

			This.assertequals( "No se seteo correctamente la base de datos (3)", "PAISES", upper( alltrim( loObjetoLogueo.oInfoLog.BaseDatos ) ) )
			This.assertequals( "No se seteo correctamente el usuario (3)", "TESTADMIN", upper( alltrim( loObjetoLogueo.oInfoLog.Usuario ) ) )
			This.assertequals( "No se seteo correctamente el serie (3)", _screen.zoo.app.cserie, upper( alltrim( loObjetoLogueo.oInfoLog.Serie ) ) )
			This.assertequals( "No se seteo correctamente la version (3)", "01.0001.00000", upper( alltrim( loObjetoLogueo.oInfoLog.Version ) ) )
			This.assertequals( "No se seteo correctamente la aplicacion (3)", "NUCLEO", upper( alltrim( loObjetoLogueo.oInfoLog.Aplicacion ) ) )
			This.assertequals( "No se seteo correctamente la hora (3)", "99:99:99", upper( alltrim( loItem.Hora ) ) )
			This.assertequals( "No se seteo correctamente el tipo de log (3)", 4, loItem.TipoDeLogueo )
			This.assertequals( "No se seteo correctamente la descripcion (3)", "ITEM1EN3VECES.", upper( alltrim( loItem.Descripcion ) ) )
			This.assertequals( "No se seteo correctamente la accion (3)", "NO DISP.", upper( alltrim( loObjetoLogueo.oInfoLog.Accion ) ) )						

		catch to loError
			throw loError

		finally
			goServicios.Seguridad.cUsuarioLogueado = lcUsuarioAnterior
			loItem = null
			loObjetoLogueo.Release()
		
		endtry

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestObtenerNivelLog
		local loObjetoLogueo as Object, loError as zooexception OF zooexception.prg, loCol as zoocoleccion OF zoocoleccion.prg, ;
			loItem as object

		try 
			loObjetoLogueo = _screen.zoo.crearobjeto( "ObjetoLogueo", "ObjetoLogueo.prg" )

			loObjetoLogueo.Escribir( "Prueba", 1 )
			loCol = loObjetoLogueo.ObtenerLogueosDeNivel( 1 )
			loItem = loCol.item[1]

			This.assertequals( "Error al setear Nivel de Log 1(Debug)", 1, loItem.TipoDeLogueo )

			loObjetoLogueo.Escribir( "Prueba", 2 )
			loCol = loObjetoLogueo.ObtenerLogueosDeNivel( 2 )
			loItem = loCol.item[1]

			This.assertequals( "Error al setear Nivel de Log 2(Error)", 2, loItem.TipoDeLogueo )

			loObjetoLogueo.Escribir( "Prueba", 3 )
			loCol = loObjetoLogueo.ObtenerLogueosDeNivel( 3 )
			loItem = loCol.item[1]

			This.assertequals( "Error al setear Nivel de Log 3(FATAL)", 3, loItem.TipoDeLogueo )

			loObjetoLogueo.Escribir( "Prueba", 4 )
			loCol = loObjetoLogueo.ObtenerLogueosDeNivel( 4 )
			loItem = loCol.item[1]

			This.assertequals( "Error al setear Nivel de Log 4(INFO)", 4, loItem.TipoDeLogueo )

			loObjetoLogueo.Escribir( "Prueba 2", 2 )
			loCol = loObjetoLogueo.ObtenerLogueosDeNivel( 2 )
			loItem = loCol.item[2]

			This.assertequals( "Error al setear Nivel de Log 2(Error)", 2, loItem.TipoDeLogueo )

			loObjetoLogueo.Escribir( "Prueba", 5 )
			loCol = loObjetoLogueo.ObtenerLogueosDeNivel( 5 )
			loItem = loCol.item[1]

			This.assertequals( "Error al setear Nivel de Log 4(WARN)", 5, loItem.TipoDeLogueo )
		Catch to loError
			throw loError
			
		Finally
			loObjetoLogueo.Release()
			
		endTry
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestObtenerOrigenLogueo_EsRestApi() as Void
		local loObjetoLogueo as Object
			
		_screen.lEsModoSystemStartUp= .f.
		_screen.lEsCapaDePresentacion= .f.
		_screen.lUsaServicioRest= .t.

		loObjetoLogueo = _screen.zoo.crearobjeto( "ObjetoLogueo", "ObjetoLogueo.prg" )
		
		this.assertequals( "El origen de logueo no es el correcto", "RestApi", loObjetoLogueo.oInfoLog.OrigenLogueo )
		
		loObjetoLogueo.Release()

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestObtenerOrigenLogueo_EsUI() as Void
		local loObjetoLogueo as Object
		
		_screen.lEsModoSystemStartUp= .f.
		_screen.lEsCapaDePresentacion= .t.
		_screen.lUsaServicioRest= .f.

		loObjetoLogueo = _screen.zoo.crearobjeto( "ObjetoLogueo", "ObjetoLogueo.prg" )
		
		this.assertequals( "El origen de logueo no es el correcto", "UI", loObjetoLogueo.oInfoLog.OrigenLogueo )
		
		loObjetoLogueo.Release()

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestObtenerOrigenLogueo_EsSystemStartUp() as Void
		local loObjetoLogueo as Object
		
		_screen.lEsModoSystemStartUp = .t.
		_screen.lEsCapaDePresentacion = .f.
		_screen.lUsaServicioRest = .f.

		loObjetoLogueo = _screen.zoo.crearobjeto( "ObjetoLogueo", "ObjetoLogueo.prg" )
		
		this.assertequals( "El origen de logueo no es el correcto", "StartUp", loObjetoLogueo.oInfoLog.OrigenLogueo )
		
		loObjetoLogueo.Release()

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestObtenerOrigenLogueo_EsScript() as Void
		local loObjetoLogueo as Object, loEjecucion as Object
	
		_screen.lEsModoSystemStartUp = .f.
		_screen.lEsCapaDePresentacion = .f.
		_screen.lUsaServicioRest = .f.

		this.agregarmocks( "ManagerEjecucion" )
		 _screen.mocks.AgregarSeteoMetodo( 'MANAGEREJECUCION', 'Tienescriptcargado', .t. )
		
		loObjetoLogueo = _screen.zoo.crearobjeto( "ObjetoLogueo", "ObjetoLogueo.prg" )

		this.assertequals( "El origen de logueo no es el correcto", "Script", loObjetoLogueo.oInfoLog.OrigenLogueo )
		
		loObjetoLogueo.Release()
		
	endfunc 


enddefine

*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class TestLibrerias as librerias of librerias.prg

	*-----------------------------------------------------------------------------------------
	Function ObtenerFecha() As Date
		Return { 11/12/1976 }
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ObtenerHora() As Date
		Return "99:99:99"
	Endfunc

enddefine



