**********************************************************************
Define Class zTestManagerLogueos as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as zTestManagerLogueos of zTestManagerLogueos.prg
	#ENDIF
	oLogueo = null
	SMTPHost =	""
	Puerto = 0
	ModoAutenticacion = ""
	Usuario = ""
	Password =	""
	Destinatario =	""
	Remitente = ""
	Asunto = ""
	HabilitarLogueoInterno = .f.
	ArchivoParaLogueoInterno = ""

	*-----------------------------------------------------------------------------------------
	function Setup
		this.oLogueo = goServicios.Logueos
		this.SMTPHost =	goParametros.Nucleo.Logueos.SMTPHost
		this.Puerto = goParametros.Nucleo.Logueos.Puerto
		this.ModoAutenticacion = goParametros.Nucleo.Logueos.ModoAutenticacion
		this.Usuario = goParametros.Nucleo.Logueos.Usuario
		this.Password =	goParametros.Nucleo.Logueos.Password
		this.Destinatario =	goParametros.Nucleo.Logueos.Destinatario
		this.Remitente = goParametros.Nucleo.Logueos.Remitente
		this.Asunto = goParametros.Nucleo.Logueos.Asunto
		this.HabilitarLogueoInterno = goParametros.Nucleo.Logueos.HabilitarLogueoInterno
		this.ArchivoParaLogueoInterno = goRegistry.Nucleo.ArchivoParaLogueoInterno
	endfunc

	*-----------------------------------------------------------------------------------------
	function TearDown
		goServicios.Logueos = this.oLogueo
		goParametros.Nucleo.Logueos.SMTPHost = this.SMTPHost
		goParametros.Nucleo.Logueos.Puerto = this.Puerto
		goParametros.Nucleo.Logueos.ModoAutenticacion = this.ModoAutenticacion
		goParametros.Nucleo.Logueos.Usuario = this.Usuario
		goParametros.Nucleo.Logueos.Password = this.Password
		goParametros.Nucleo.Logueos.Destinatario = this.Destinatario
		goParametros.Nucleo.Logueos.Remitente = this.Remitente
		goParametros.Nucleo.Logueos.Asunto = this.Asunto
		goParametros.Nucleo.Logueos.HabilitarLogueoInterno = this.HabilitarLogueoInterno
		goRegistry.Nucleo.ArchivoParaLogueoInterno = this.ArchivoParaLogueoInterno
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestInstanciar

		local loManagerLogueos as Object

		loManagerLogueos = _screen.zoo.crearobjeto( "ManagerLogueos", "ManagerLogueos.prg" )
	
		This.assertequals( "No se instancio el manager logueos.", "O", vartype( loManagerLogueos ) )
		This.assertequals( "El repositorio no es una coleccion.", "Collection", loManagerLogueos.oObjetosEntregados.BaseClass )
		This.asserttrue( "La ruta del XML de configucarion es incorrecta.", addbs( _screen.zoo.Obtenerrutatemporal()) + "XMLLOGUEOS.XML" $ upper( alltrim( loManagerLogueos.cArchivoXMLSeteo ) ) )		

		loManagerLogueos = null
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestObtenerObjetoLogueo
		local loManagerLogueos as Object, loObjetoLogueo as Object, loCol as zoocoleccion OF zoocoleccion.prg

		loManagerLogueos = _screen.zoo.crearobjeto( "ManagerLogueos", "ManagerLogueos.prg" )

		loObjetoLogueo = loManagerLogueos.ObtenerObjetoLogueo( This )
		loCol = loObjetoLogueo.ObtenerLogueos()
		
		This.asserttrue( "No se indico el Id unico del objeto.", !empty( loObjetoLogueo.cIdLogueo ) )
		This.assertequals( "No se instancio el Objeto logueos.", "O", vartype( loObjetoLogueo ) )
		This.assertequals( "No se creo la coleccion de items.", 0, loCol.Count )

		This.Assertequals( "El objeto obtenido no se encuentra en la coleccion.", loObjetoLogueo.cIdLogueo, loManagerlogueos.oObjetosEntregados.item[1].cidlogueo )

		loObjetoLogueo.Release()
		loManagerLogueos.Release()

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestRecorrerHerencia
		local loManagerLogueos as Object, loObjetoLogueo as Object, loColeccionMock as zoocoleccion OF zoocoleccion.prg
		local lcPrefijo as String
		do Case
			case _Screen.zoo.app.TipodeBase = "NATIVA"
				lcPrefijo = ""
			case _Screen.zoo.app.TipodeBase = "SQLSERVER"
				lcPrefijo = "FULL_"
			otherwise
				This.Asserttrue( "TESTEAR !!!!", .F. )
		EndCase		


		loManagerLogueos = Newobject( "mockManagerLogueosSerializacion" )

		*--
		loColeccionMock = _screen.zoo.crearobjeto( "ZooColeccion" )
		loColeccionMock.agregar( "PRIMERO", "PRIMERO" )
		loColeccionMock.agregar( "SEGUNDO", "SEGUNDO" )
		loColeccionMock.agregar( "TERCERO", "TERCERO" )

		loManagerLogueos.oClasesHerencias = loColeccionMock
		loObjetoLogueo = loManagerLogueos.ObtenerObjetoLogueo( This )
		This.assertequals( "No es correcta la asignacion del repositorio 1.", lcPrefijo + "PRIMERO", upper( alltrim( loObjetoLogueo.cLogger ) ) )
		loColeccionMock = null

		*--
		loColeccionMock = _screen.zoo.crearobjeto( "ZooColeccion" )
		loColeccionMock.agregar( "PRIMERONO", "PRIMERONO" )
		loColeccionMock.agregar( "SEGUNDO", "SEGUNDO" )
		loColeccionMock.agregar( "TERCERO", "TERCERO" )

		loManagerLogueos.oClasesHerencias = loColeccionMock		
		loObjetoLogueo = loManagerLogueos.ObtenerObjetoLogueo( This )
		This.assertequals( "No es correcta la asignacion del repositorio 2.", lcPrefijo + "SEGUNDO", upper( alltrim( loObjetoLogueo.cLogger ) ) )
		loColeccionMock = null
		
		*--
		loColeccionMock = _screen.zoo.crearobjeto( "ZooColeccion" )
		loColeccionMock.agregar( "PRIMERONO", "PRIMERONO" )
		loColeccionMock.agregar( "SEGUNDONO", "SEGUNDONO" )
		loColeccionMock.agregar( "TERCERO", "TERCERO" )

		loManagerLogueos.oClasesHerencias = loColeccionMock		
		loObjetoLogueo = loManagerLogueos.ObtenerObjetoLogueo( This )
		This.assertequals( "No es correcta la asignacion del repositorio 3.", lcPrefijo + "TERCERO", upper( alltrim( loObjetoLogueo.cLogger ) ) )
		loColeccionMock = null

		loColeccionMock = _screen.zoo.crearobjeto( "ZooColeccion" )
		loColeccionMock.agregar( "BOCHA", "BOCHA" )
		loColeccionMock.agregar( "NADA", "NADA" )
		loColeccionMock.agregar( "PARA", "PARA" )

		loManagerLogueos.oClasesHerencias = loColeccionMock		
		loObjetoLogueo = loManagerLogueos.ObtenerObjetoLogueo( This )
		This.assertequals( "No es correcta la asignacion del repositorio 4.", lcPrefijo + "LOG.ERR", upper( alltrim( loObjetoLogueo.cLogger ) ) )
		loColeccionMock = null		
		
		loObjetoLogueo.Release()
		loManagerLogueos.Release()

	endfunc 		

	*-----------------------------------------------------------------------------------------
	function zTestGuardar

		local loManagerLogueos as Object, loObjetoLogueo as Object, loEnvio as Object, i as Integer
		
		loManagerLogueos = newobject( "mockManagerLogueos" )
		loObjetoLogueo = loManagerLogueos.ObtenerObjetoLogueo( This )
		
		This.Assertequals( "El objeto obtenido no se encuentra en la coleccion.", loObjetoLogueo.cIdLogueo, loManagerlogueos.oObjetosEntregados.item[1].cidlogueo )

		loObjetoLogueo.Escribir( "Texto de algun debug", 1 )
		loObjetoLogueo.Escribir( "Texto de algun debug2", 1 )
		loObjetoLogueo.Escribir( "Texto de algun fatal", 3 )
		loObjetoLogueo.Escribir( "Texto de algun error", 2 )
		loObjetoLogueo.Escribir( "Texto de algun mensaje por defecto" )

		loManagerLogueos.Guardar( loObjetoLogueo )
		This.Assertequals( "No se elimino el item de la coleccion.", 0, loManagerlogueos.oObjetosEntregados.Count )
		This.Assertequals( "Se debe eliminar el objeto logueo.", "X", vartype( loObjetoLogueo ) )

		this.assertequals( "Error en la cantidad de envios", 4, loManagerLogueos.oEnvios.count )
		
		i = 1
		
		loEnvio = loManagerLogueos.oEnvios.item[ i ]
		this.assertequals( "Error en el nivel del TipoLogueo " + transform( i ) , 0, loEnvio.TipoLogueo )
		this.assertequals( "Error en la base de datos " + transform( i ) , _screen.zoo.app.obtenersucursalactiva(), loEnvio.BaseDatos )
		this.assertequals( "Error en el usuario " + transform( i ), goServicios.Seguridad.ObtenerUltimoUsuarioLogueado(), loEnvio.Usuario )
		this.assertequals( "Error en el serie " + transform( i ) , _screen.zoo.app.cSerie, loEnvio.Serie )
		this.assertequals( "Error en la version " + transform( i ), _screen.zoo.app.obtenerversion(), loEnvio.Version )
		this.assertequals( "Error en la aplicacion " + transform( i ), _screen.zoo.app.nombre, loEnvio.Aplicacion )		
		this.assertequals( "Error en el estado del sistema " + transform( i ) , goServicios.Seguridad.nEstadoDelSistema, loEnvio.EstadoSistema )
		this.assertequals( "Error en el nombre de pc " + transform( i ), alltrim( substr( sys( 0 ), 1, at( "#", sys( 0 ) ) - 1) ), loEnvio.NombrePc )
		this.assertequals( "Error en el usuario de pc " + transform( i ), alltrim( substr( sys( 0 ), at( "#", sys( 0 ) ) + 1 ) ), loEnvio.UsuarioPc )
		this.assertequals( "Error en el origen logueo " + transform( i ), "UI", loEnvio.OrigenLogueo )		
		this.assertequals( "Error en el mensaje " + transform( i ), "Detalle serializado 1Detalle serializado 2", loEnvio.Mensaje )				

		i = i + 1 
		loEnvio = loManagerLogueos.oEnvios.item[ i ]
		this.assertequals( "Error en el nivel del TipoLogueo " + transform( i ) , 2, loEnvio.TipoLogueo )
		this.assertequals( "Error en la base de datos " + transform( i ) , _screen.zoo.app.obtenersucursalactiva(), loEnvio.BaseDatos )
		this.assertequals( "Error en el usuario " + transform( i ), goServicios.Seguridad.ObtenerUltimoUsuarioLogueado(), loEnvio.Usuario )
		this.assertequals( "Error en el serie " + transform( i ) , _screen.zoo.app.cSerie, loEnvio.Serie )
		this.assertequals( "Error en la version " + transform( i ), _screen.zoo.app.obtenerversion(), loEnvio.Version )
		this.assertequals( "Error en la aplicacion " + transform( i ), _screen.zoo.app.nombre, loEnvio.Aplicacion )		
		this.assertequals( "Error en el estado del sistema " + transform( i ) , goServicios.Seguridad.nEstadoDelSistema, loEnvio.EstadoSistema )
		this.assertequals( "Error en el nombre de pc " + transform( i ), alltrim( substr( sys( 0 ), 1, at( "#", sys( 0 ) ) - 1) ), loEnvio.NombrePc )
		this.assertequals( "Error en el usuario de pc " + transform( i ), alltrim( substr( sys( 0 ), at( "#", sys( 0 ) ) + 1 ) ), loEnvio.UsuarioPc )		
		this.assertequals( "Error en el origen logueo " + transform( i ), "UI", loEnvio.OrigenLogueo )	
		this.assertequals( "Error en el mensaje " + transform( i ), "Detalle serializado 3", loEnvio.Mensaje )				
		
		i = i + 1 
		loEnvio = loManagerLogueos.oEnvios.item[ i ]
		this.assertequals( "Error en el nivel del TipoLogueo " + transform( i ) , 1, loEnvio.TipoLogueo )
		this.assertequals( "Error en la base de datos " + transform( i ) , _screen.zoo.app.obtenersucursalactiva(), loEnvio.BaseDatos )
		this.assertequals( "Error en el usuario " + transform( i ), goServicios.Seguridad.ObtenerUltimoUsuarioLogueado(), loEnvio.Usuario )
		this.assertequals( "Error en el serie " + transform( i ) , _screen.zoo.app.cSerie, loEnvio.Serie )
		this.assertequals( "Error en la version " + transform( i ), _screen.zoo.app.obtenerversion(), loEnvio.Version )
		this.assertequals( "Error en la aplicacion " + transform( i ), _screen.zoo.app.nombre, loEnvio.Aplicacion )		
		this.assertequals( "Error en el estado del sistema " + transform( i ) , goServicios.Seguridad.nEstadoDelSistema, loEnvio.EstadoSistema )
		this.assertequals( "Error en el nombre de pc " + transform( i ), alltrim( substr( sys( 0 ), 1, at( "#", sys( 0 ) ) - 1) ), loEnvio.NombrePc )
		this.assertequals( "Error en el usuario de pc " + transform( i ), alltrim( substr( sys( 0 ), at( "#", sys( 0 ) ) + 1 ) ), loEnvio.UsuarioPc )		
		this.assertequals( "Error en el origen logueo " + transform( i ), "UI", loEnvio.OrigenLogueo )	
		this.assertequals( "Error en el mensaje " + transform( i ), "Detalle serializado 4", loEnvio.Mensaje )				
	

		i = i + 1 
		loEnvio = loManagerLogueos.oEnvios.item[ i ]
		this.assertequals( "Error en el nivel del TipoLogueo " + transform( i ) , 3, loEnvio.TipoLogueo )
		this.assertequals( "Error en la base de datos " + transform( i ) , _screen.zoo.app.obtenersucursalactiva(), loEnvio.BaseDatos )
		this.assertequals( "Error en el usuario " + transform( i ), goServicios.Seguridad.ObtenerUltimoUsuarioLogueado(), loEnvio.Usuario )
		this.assertequals( "Error en el serie " + transform( i ) , _screen.zoo.app.cSerie, loEnvio.Serie )
		this.assertequals( "Error en la version " + transform( i ), _screen.zoo.app.obtenerversion(), loEnvio.Version )
		this.assertequals( "Error en la aplicacion " + transform( i ), _screen.zoo.app.nombre, loEnvio.Aplicacion )		
		this.assertequals( "Error en el estado del sistema " + transform( i ) , goServicios.Seguridad.nEstadoDelSistema, loEnvio.EstadoSistema )
		this.assertequals( "Error en el nombre de pc " + transform( i ), alltrim( substr( sys( 0 ), 1, at( "#", sys( 0 ) ) - 1) ), loEnvio.NombrePc )
		this.assertequals( "Error en el usuario de pc " + transform( i ), alltrim( substr( sys( 0 ), at( "#", sys( 0 ) ) + 1 ) ), loEnvio.UsuarioPc )		
		this.assertequals( "Error en el origen logueo " + transform( i ), "UI", loEnvio.OrigenLogueo )	
		this.assertequals( "Error en el mensaje " + transform( i ), "Detalle serializado 5", loEnvio.Mensaje )				
	
		
		loManagerLogueos.Release()

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestGuardarParcialmente

		local loManagerLogueos as Object, loObjetoLogueo as Object, loEnvio as Object, i as Integer

		loManagerLogueos = newobject( "mockManagerLogueos" )
		loObjetoLogueo = loManagerLogueos.ObtenerObjetoLogueo( This )

		This.Assertequals( "El objeto obtenido no se encuentra en la coleccion.", loObjetoLogueo.cIdLogueo, loManagerlogueos.oObjetosEntregados.item[1].cidlogueo )

		loObjetoLogueo.Escribir( "Texto de algun debug", 1 )
		loObjetoLogueo.Escribir( "Texto de algun debug2", 1 )
		loObjetoLogueo.Escribir( "Texto de algun fatal", 3 )
		loObjetoLogueo.Escribir( "Texto de algun error", 2 )
		loObjetoLogueo.Escribir( "Texto de algun mensaje por defecto" )

		loManagerLogueos.GuardarParcialmente( loObjetoLogueo )
		This.Assertequals( "No se debe eliminar el objeto logueo de la coleccion.", 1, loManagerlogueos.oObjetosEntregados.Count )
		This.Assertequals( "No se debe eliminar el objeto logueo.", "O", vartype( loObjetoLogueo ) )

		this.assertequals( "Error en la cantidad de envios", 4, loManagerLogueos.oEnvios.count )
		
		i = 1
		
		loEnvio = loManagerLogueos.oEnvios.item[ i ]
		this.assertequals( "Error en el nivel del TipoLogueo " + transform( i ) , 0, loEnvio.TipoLogueo )
		this.assertequals( "Error en la base de datos " + transform( i ) , _screen.zoo.app.obtenersucursalactiva(), loEnvio.BaseDatos )
		this.assertequals( "Error en el usuario " + transform( i ), goServicios.Seguridad.ObtenerUltimoUsuarioLogueado(), loEnvio.Usuario )
		this.assertequals( "Error en el serie " + transform( i ) , _screen.zoo.app.cSerie, loEnvio.Serie )
		this.assertequals( "Error en la version " + transform( i ), _screen.zoo.app.obtenerversion(), loEnvio.Version )
		this.assertequals( "Error en la aplicacion " + transform( i ), _screen.zoo.app.nombre, loEnvio.Aplicacion )		
		this.assertequals( "Error en el estado del sistema " + transform( i ) , goServicios.Seguridad.nEstadoDelSistema, loEnvio.EstadoSistema )
		this.assertequals( "Error en el nombre de pc " + transform( i ), alltrim( substr( sys( 0 ), 1, at( "#", sys( 0 ) ) - 1) ), loEnvio.NombrePc )
		this.assertequals( "Error en el usuario de pc " + transform( i ), alltrim( substr( sys( 0 ), at( "#", sys( 0 ) ) + 1 ) ), loEnvio.UsuarioPc )		
		this.assertequals( "Error en el origen logueo " + transform( i ), "UI", loEnvio.OrigenLogueo )	
		this.assertequals( "Error en el mensaje " + transform( i ), "Detalle serializado 1Detalle serializado 2", loEnvio.Mensaje )				

		i = i + 1 
		loEnvio = loManagerLogueos.oEnvios.item[ i ]
		this.assertequals( "Error en el nivel del TipoLogueo " + transform( i ) , 2, loEnvio.TipoLogueo )
		this.assertequals( "Error en la base de datos " + transform( i ) , _screen.zoo.app.obtenersucursalactiva(), loEnvio.BaseDatos )
		this.assertequals( "Error en el usuario " + transform( i ), goServicios.Seguridad.ObtenerUltimoUsuarioLogueado(), loEnvio.Usuario )
		this.assertequals( "Error en el serie " + transform( i ) , _screen.zoo.app.cSerie, loEnvio.Serie )
		this.assertequals( "Error en la version " + transform( i ), _screen.zoo.app.obtenerversion(), loEnvio.Version )
		this.assertequals( "Error en la aplicacion " + transform( i ), _screen.zoo.app.nombre, loEnvio.Aplicacion )		
		this.assertequals( "Error en el estado del sistema " + transform( i ) , goServicios.Seguridad.nEstadoDelSistema, loEnvio.EstadoSistema )
		this.assertequals( "Error en el nombre de pc " + transform( i ), alltrim( substr( sys( 0 ), 1, at( "#", sys( 0 ) ) - 1) ), loEnvio.NombrePc )
		this.assertequals( "Error en el usuario de pc " + transform( i ), alltrim( substr( sys( 0 ), at( "#", sys( 0 ) ) + 1 ) ), loEnvio.UsuarioPc )		
		this.assertequals( "Error en el origen logueo " + transform( i ), "UI", loEnvio.OrigenLogueo )	
		this.assertequals( "Error en el mensaje " + transform( i ), "Detalle serializado 3", loEnvio.Mensaje )				
		
		i = i + 1 
		loEnvio = loManagerLogueos.oEnvios.item[ i ]
		this.assertequals( "Error en el nivel del TipoLogueo " + transform( i ) , 1, loEnvio.TipoLogueo )
		this.assertequals( "Error en la base de datos " + transform( i ) , _screen.zoo.app.obtenersucursalactiva(), loEnvio.BaseDatos )
		this.assertequals( "Error en el usuario " + transform( i ), goServicios.Seguridad.ObtenerUltimoUsuarioLogueado(), loEnvio.Usuario )
		this.assertequals( "Error en el serie " + transform( i ) , _screen.zoo.app.cSerie, loEnvio.Serie )
		this.assertequals( "Error en la version " + transform( i ), _screen.zoo.app.obtenerversion(), loEnvio.Version )
		this.assertequals( "Error en la aplicacion " + transform( i ), _screen.zoo.app.nombre, loEnvio.Aplicacion )		
		this.assertequals( "Error en el estado del sistema " + transform( i ) , goServicios.Seguridad.nEstadoDelSistema, loEnvio.EstadoSistema )
		this.assertequals( "Error en el nombre de pc " + transform( i ), alltrim( substr( sys( 0 ), 1, at( "#", sys( 0 ) ) - 1) ), loEnvio.NombrePc )
		this.assertequals( "Error en el usuario de pc " + transform( i ), alltrim( substr( sys( 0 ), at( "#", sys( 0 ) ) + 1 ) ), loEnvio.UsuarioPc )		
		this.assertequals( "Error en el origen logueo " + transform( i ), "UI", loEnvio.OrigenLogueo )	
		this.assertequals( "Error en el mensaje " + transform( i ), "Detalle serializado 4", loEnvio.Mensaje )				
	

		i = i + 1 
		loEnvio = loManagerLogueos.oEnvios.item[ i ]
		this.assertequals( "Error en el nivel del TipoLogueo " + transform( i ) , 3, loEnvio.TipoLogueo )
		this.assertequals( "Error en la base de datos " + transform( i ) , _screen.zoo.app.obtenersucursalactiva(), loEnvio.BaseDatos )
		this.assertequals( "Error en el usuario " + transform( i ), goServicios.Seguridad.ObtenerUltimoUsuarioLogueado(), loEnvio.Usuario )
		this.assertequals( "Error en el serie " + transform( i ) , _screen.zoo.app.cSerie, loEnvio.Serie )
		this.assertequals( "Error en la version " + transform( i ), _screen.zoo.app.obtenerversion(), loEnvio.Version )
		this.assertequals( "Error en la aplicacion " + transform( i ), _screen.zoo.app.nombre, loEnvio.Aplicacion )		
		this.assertequals( "Error en el estado del sistema " + transform( i ) , goServicios.Seguridad.nEstadoDelSistema, loEnvio.EstadoSistema )
		this.assertequals( "Error en el nombre de pc " + transform( i ), alltrim( substr( sys( 0 ), 1, at( "#", sys( 0 ) ) - 1) ), loEnvio.NombrePc )
		this.assertequals( "Error en el usuario de pc " + transform( i ), alltrim( substr( sys( 0 ), at( "#", sys( 0 ) ) + 1 ) ), loEnvio.UsuarioPc )		
		this.assertequals( "Error en el origen logueo " + transform( i ), "UI", loEnvio.OrigenLogueo )	
		this.assertequals( "Error en el mensaje " + transform( i ), "Detalle serializado 5", loEnvio.Mensaje )				
	
		
		loManagerLogueos.Release()

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestSerializarDetalle
		local loManager as Object, loDetalle as Object, lcSerializado as String, lcEsperado as String

		loManager = newobject( "mockManagerLogueosSerializacion" )
		
		loDetalle = newobject( "custom" )
		loDetalle.addProperty( "Fecha", ctod("10/10/10"))
		loDetalle.addProperty( "Hora", "10:10" )
		loDetalle.addProperty( "TipoDeLogueo", 0 )
		loDetalle.addProperty( "Descripcion", "" )
		loManager.cCaracterDelimitador = "|"

		loDetalle.TipoDeLogueo = 1
		loDetalle.Descripcion = "Descripcion del detalle " + transform( loDetalle.TipoDeLogueo )
		lcEsperado = "    10:10|" + alltrim( loDetalle.Descripcion ) + chr( 13 ) + chr( 10 )
		lcSerializado = loManager.MockSerializarDetalle( loDetalle )
		this.assertequals( "Serializo mal el detalle " + transform( loDetalle.TipoDeLogueo ) , lcEsperado, lcSerializado )
		
		loDetalle.TipoDeLogueo = 2
		loDetalle.Descripcion = "Descripcion del detalle " + transform( loDetalle.TipoDeLogueo )
		lcEsperado = "[E] 10:10|" + alltrim( loDetalle.Descripcion ) + chr( 13 ) + chr( 10 )
		lcSerializado = loManager.MockSerializarDetalle( loDetalle )
		this.assertequals( "Serializo mal el detalle " + transform( loDetalle.TipoDeLogueo ), lcEsperado, lcSerializado )

		loDetalle.TipoDeLogueo = 3
		loDetalle.Descripcion = "Descripcion del detalle " + transform( loDetalle.TipoDeLogueo )
		lcEsperado = "    10:10|" + alltrim( loDetalle.Descripcion ) + chr( 13 ) + chr( 10 )
		lcSerializado = loManager.MockSerializarDetalle( loDetalle )
		this.assertequals( "Serializo mal el detalle " + transform( loDetalle.TipoDeLogueo ) , lcEsperado, lcSerializado )

		loDetalle.TipoDeLogueo = 4
		loDetalle.Descripcion = "Descripcion del detalle " + transform( loDetalle.TipoDeLogueo )
		lcEsperado = "    10:10|" + alltrim( loDetalle.Descripcion ) + chr( 13 ) + chr( 10 )
		lcSerializado = loManager.MockSerializarDetalle( loDetalle )
		this.assertequals( "Serializo mal el detalle " + transform( loDetalle.TipoDeLogueo ) , lcEsperado, lcSerializado )

		loDetalle.TipoDeLogueo = 5
		loDetalle.Descripcion = "Descripcion del detalle " + transform( loDetalle.TipoDeLogueo )
		lcEsperado = "    10:10|" + alltrim( loDetalle.Descripcion ) + chr( 13 ) + chr( 10 )
		lcSerializado = loManager.MockSerializarDetalle( loDetalle )
		this.assertequals( "Serializo mal el detalle " + transform( loDetalle.TipoDeLogueo ) , lcEsperado, lcSerializado )
				
		loManager.release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestServicioLogueos
 		local loManagerLogueos as Object, loObjetoLogueo as Object, lcTestLogueo as String, lcCursor as String

		private goLibrerias as Object
		goLibrerias = createobject( "TestLibrerias" )

		loManagerLogueos = newobject( "MockManagerLogueosIntegracion" )

		loObjetoLogueo = loManagerLogueos.ObtenerObjetoLogueo( This )
		loObjetoLogueo.Escribir( "Esto deberia llegar al logger en net1", 1 )
		loObjetoLogueo.Escribir( "Esto deberia llegar al logger en net2", 2 )
		loObjetoLogueo.Escribir( "Esto deberia llegar al logger en net3", 3 )
		loObjetoLogueo.Escribir( "Esto deberia llegar al logger en net4", 4 )
		loObjetoLogueo.Escribir( "Esto deberia llegar al logger en net5", 5 )
		loManagerLogueos.guardar( loObjetoLogueo )

		lcCursor = sys( 2015 )
		create cursor &lcCursor(texto c(250))
		lcTestLogueo = addbs( loManagerLogueos.cRutaTemporal ) + "LOGTEST.LOG"
		select &lcCursor
		append from &lcTestLogueo type sdf

		locate for "99:99:99,ESTO DEBERIA LLEGAR AL LOGGER EN NET1" == upper( alltrim( &lcCursor..texto ) )
		
		This.assertequals( "No se encontro el mensaje logueado 1", .T., found() )

		skip +2
		This.assertequals( "No se encontro el mensaje logueado 2", "[E] 99:99:99,Esto deberia llegar al logger en net2", alltrim(( &lcCursor..texto ) ) )

		skip +2
		This.assertequals( "No se encontro el mensaje logueado 4", "99:99:99,Esto deberia llegar al logger en net3", alltrim(( &lcCursor..texto ) ) )
		
		skip +2
		This.assertequals( "No se encontro el mensaje logueado 5", "99:99:99,Esto deberia llegar al logger en net4",  alltrim(( &lcCursor..texto ) ) ) 
		
		goServicios.Logueos.terminar()
		delete file &lcTestLogueo 

		use in select ( lcCursor )
		loManagerLogueos.release()
	endfunc 		
	
	*-----------------------------------------------------------------------------------------
	function zTestIntegralLogueosNativa
		local loprocesodinamico as object, llexistefile as boolean, lozoosession as object,;
			loobjetologueo as object, lcarchivolog as string, lcTexto as String, lnId as Integer, lcFecha as String, lxCentury as Variant,;
			lcCurLoggers as string, lcCurAppenders as String, lcCurTipoAppenders as String, lcXml as String, lcXmlLoggers as String, lcXmlAppenders as String,;
			lcXmlTipoAppenders as String, lcOrigenLogueo as string

		lxCentury = set("Century")
		set century on
		lcFecha = dtoc( date())
		set century &lxCentury
		
		lcarchivolog = alltrim( goRegistry.Nucleo.RutaLogueoPorDefecto ) + "ZOOSESSION.LOG"
		lcarchivolog = _screen.zoo.cRutaInicial + substr( alltrim( lcarchivolog ), 3, len( alltrim( lcarchivolog ) ) )
		
		if file ( lcarchivolog )
			delete file ( lcarchivolog )
		endif
				
		*-- cargar adn de prueba
		try
			lcCurLoggers = sys( 2015 )
			lcCurAppenders = sys( 2015 )
			lcCurTipoAppenders = sys( 2015 )
			
			use loggers in 0 shared
			use appenders in 0 shared
			use tipoAppenders in 0 shared

			select *, "NUCLEO     " as proyecto from loggers where .f. into cursor &lcCurLoggers readwrite
			select *, "NUCLEO     " as proyecto from appenders where .f. into cursor &lcCurAppenders readwrite
			select *, "NUCLEO     " as proyecto from tipoAppenders where .f. into cursor &lcCurTipoAppenders readwrite
			
			insert into &lcCurLoggers ( clase, appender, proyecto ) values ( "ZOOSESSION", "AP_ZOOSESSION", "NUCLEO" )
			insert into &lcCurAppenders ( appender, tipoAppender , proyecto ) values ( "AP_ZOOSESSION", "TipoArchivo", "NUCLEO" )
			
			text to lcXml noshow
	<appender name="<<allt(.APPENDER)>>" type="ZooLogicSA.Core.zooRollingfileappender">
		<file value="<< allt( goRegistry.Nucleo.RutaLogueoPorDefecto ) + allt(.CLASE)>>.log"/>
		<appendToFile value="true"/>
		<maximumFileSize value="2048KB"/>
		<rollingStyle value="size"/>
		<maxSizeRollBackups value="10"/>
		<lockingModel type="log4net.Appender.FileAppender+MinimalLock"/>
		<layout type="log4net.Layout.PatternLayout">
			<conversionPattern value="%date{dd/MM/yyyy}, Base: %property{BaseDatos}, Usuario: %property{Usuario}, Aplicaci&#243;n: %property{Aplicacion}, Versi&#243;n: %property{Version}, Serie: %property{Serie}%newline	           Estado del sistema: %property{EstadoSistema}, Nombre de la PC: %property{NombrePc}, Usuario de la PC: %property{UsuarioPc}, Origen logueo: %property{OrigenLogueo}%newline %message%newline"/>
		</layout>
	</appender>			
			endtext
			insert into &lcCurTipoAppenders ( tipo, xml , proyecto ) values ( "TipoArchivo", lcXml, "NUCLEO" )

			cursortoxml( lcCurLoggers, "lcXmlLoggers" )
			cursortoxml( lcCurAppenders, "lcXmlAppenders" )
			cursortoxml( lcCurTipoAppenders, "lcXmlTipoAppenders" )
			
		catch to loerror
			throw loerror
		finally
			use in select( lcCurLoggers )
			use in select( lcCurAppenders )
			use in select( lcCurTipoAppenders )
			use in select( "loggers" )
			use in select( "appenders" )
			use in select( "tipoAppenders" )
		endtry

		*-- generar din_logueos y el xml
		loprocesodinamico = _screen.zoo.crearobjeto( "procesodinamico" , "procesodinamico.prg" )
		with loProcesoDinamico
			.cPath = _screen.zoo.obtenerrutatemporal()
			.generarcoleccionlogueos( lcXmlLoggers, lcXmlAppenders, lcXmlTipoAppenders )
			.release()
		endwith
		
		llexistefile = file( _screen.zoo.obtenerrutatemporal() + 'generados\din_logueos.prg' )
		this.asserttrue( 'no se creo el archivo din_logueos.prg', llexistefile )
			
		llexistefile = file( _screen.zoo.obtenerrutatemporal() + 'generados\din_logueos.xml' )
		this.asserttrue( 'no se creo el archivo din_logueos.xml', llexistefile )

		*-- Se configura el servicio de logueos para el test.
		goServicios.Logueos = newobject( "TestManagerLogueos" )
		
		*-- Hacer la prueba
		lozoosession = newobject( 'mockzoosession' )
		loObjetoLogueo = lozoosession.mockobtenerobjetologueo() 
		lcOrigenLogueo = loObjetoLogueo.oInfoLog.OrigenLogueo

		lozoosession.Loguear( "bailar es vida" )
		lozoosession.finalizarlogueo()
		
		this.asserttrue( 'No se destruyo el objeto "loobjetologueo" ', isnull( loobjetologueo ) )
	
		*-- Chequear el logueo
		try
			lnId = fopen( lcarchivolog )
			
			lcTexto = fgets( lnId )
			this.Assertequals( "El logueo no es correcto 1", lcFecha + ", BASE: PAISES, USUARIO: , APLICACIÓN: NUCLEO, VERSIÓN: 01.0001.00000, SERIE: " + _screen.zoo.app.cserie, alltrim( upper( lcTexto )))
			lcTexto = fgets( lnId )
			this.Assertequals( "El logueo no es correcto 2", "ESTADO DEL SISTEMA: 1, NOMBRE DE LA PC: " + alltrim( upper( substr( sys( 0 ), 1, at( "#", sys( 0 ) ) - 1))) + ", USUARIO DE LA PC: " + alltrim( upper( substr( sys( 0 ), at( "#", sys( 0 ) ) + 1 )) + ", ORIGEN LOGUEO: " + upper(lcOrigenLogueo)), alltrim( upper( lcTexto ))) 
			fseek( lnId, 14, 1 )
			lcTexto = fgets( lnId )
			this.Assertequals( "El logueo no es correcto 3", "BAILAR ES VIDA", alltrim( upper( lcTexto )))
			lcTexto = fread( lnId, fseek( lnId, 0, 2 ) - fseek( lnId, 0, 1 ))
			this.Assertequals( "El logueo no es correcto 4", "", alltrim( upper( lcTexto )))
			this.AssertTrue( "No es fin de archivo", feof( lnId ))
		catch to loError
			throw loerror
		finally
			fclose( lnId )
		endtry
		
		*-- Reestablecer el seteo del logueo original	
		goServicios.Logueos.terminar()

		if file ( lcarchivolog )
			delete file ( lcarchivolog )
		endif		

		this.asserttrue( 'No se eliminó el archivo de logueo temporal', !file ( lcarchivolog ) )
		goServicios.logueos.setearnet()
		lozoosession.release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ztestSqlServerintegrallogueos

		local loprocesodinamico as object, lccursoradn as string, lcxmlparagenerar as string, llexistefile as boolean, lozoosession as object,;
			loobjetologueo as object, lcarchivolog as string, lcTexto as String, lnId as Integer, lcCursor as String, lcXml as String, ;
			lcTipoBase as String, lcFecha as String, lxCentury as Variant, lcCurLoggers as string, lcCurAppenders as String,;
			lcCurTipoAppenders as String, lcXml as String, lcXmlLoggers as String, lcXmlAppenders as String, lcXmlTipoAppenders as String, lcOrigenLogueo as String

		lxCentury = set("Century")
		set century on
		lcFecha = dtoc( date() )
		set century &lxCentury
				
		lcarchivolog = alltrim( goRegistry.Nucleo.RutaLogueoPorDefecto ) + "ZOOSESSION.LOG"
		lcarchivolog = _screen.zoo.cRutaInicial + substr( alltrim( lcarchivolog ), 3, len( alltrim( lcarchivolog ) ) )
		goDatos.EjecutarSql( "delete from " + _screen.zoo.app.cSchemaDefault + ".Logueos" )
		
		*-- cargar adn de prueba
		try
			lcCurLoggers = sys( 2015 )
			lcCurAppenders = sys( 2015 )
			lcCurTipoAppenders = sys( 2015 )
			
			use loggers in 0 shared
			use appenders in 0 shared
			use tipoAppenders in 0 shared

			select *, "NUCLEO     " as proyecto from loggers where .f. into cursor &lcCurLoggers readwrite
			select *, "NUCLEO     " as proyecto from appenders where .f. into cursor &lcCurAppenders readwrite
			select *, "NUCLEO     " as proyecto from tipoAppenders where .f. into cursor &lcCurTipoAppenders readwrite
			
			insert into &lcCurLoggers ( clase, appender, proyecto ) values ( "ZOOSESSION", "AP_ZOOSESSION", "NUCLEO" )
			insert into &lcCurAppenders ( appender, tipoAppender , proyecto ) values ( "AP_ZOOSESSION", "TipoArchivo", "NUCLEO" )
			
			text to lcXml noshow
	<appender name="<<allt(.APPENDER)>>" type="ZooLogicSA.Core.zooRollingfileappender">
		<file value="<< allt( goRegistry.Nucleo.RutaLogueoPorDefecto ) + allt(.CLASE)>>.log"/>
		<appendToFile value="true"/>
		<maximumFileSize value="2048KB"/>
		<rollingStyle value="size"/>
		<maxSizeRollBackups value="10"/>
		<lockingModel type="log4net.Appender.FileAppender+MinimalLock"/>
		<layout type="log4net.Layout.PatternLayout">
			<conversionPattern value="%date{dd/MM/yyyy}, Base: %property{BaseDatos}, Usuario: %property{Usuario}, Aplicaci&#243;n: %property{Aplicacion}, Versi&#243;n: %property{Version}, Serie: %property{Serie}%newline	           Estado del sistema: %property{EstadoSistema}, Nombre de la PC: %property{NombrePc}, Usuario de la PC: %property{UsuarioPc}, Origen logueo: %property{OrigenLogueo}%newline %message%newline"/>
		</layout>
	</appender>			
			endtext
			insert into &lcCurTipoAppenders ( tipo, xml , proyecto ) values ( "TipoArchivo", lcXml, "NUCLEO" )

			cursortoxml( lcCurLoggers, "lcXmlLoggers" )
			cursortoxml( lcCurAppenders, "lcXmlAppenders" )
			cursortoxml( lcCurTipoAppenders, "lcXmlTipoAppenders" )
			
		catch to loerror
			throw loerror
		finally
			use in select( lcCurLoggers )
			use in select( lcCurAppenders )
			use in select( lcCurTipoAppenders )
			use in select( "loggers" )
			use in select( "appenders" )
			use in select( "tipoAppenders" )
		endtry


		*-- generar din_logueos y el xml
		loprocesodinamico = _screen.zoo.crearobjeto( "procesodinamico" , "procesodinamico.prg" )
		with loProcesoDinamico
			.cPath = _screen.zoo.obtenerrutatemporal()
			.generarcoleccionlogueos( lcXmlLoggers, lcXmlAppenders, lcXmlTipoAppenders )
			.release()
		endwith
		
		llexistefile = file( _screen.zoo.obtenerrutatemporal() + 'generados\din_logueos.prg' )
		this.asserttrue( 'no se creo el archivo din_logueos.prg', llexistefile )

		llexistefile = file( _screen.zoo.obtenerrutatemporal() + 'generados\din_logueosSqlServer.xml' )
		this.asserttrue( 'no se creo el archivo din_logueos.xml', llexistefile )

		*-- Se configura el servicio de logueos para el test.
		goServicios.Logueos = newobject( "TestManagerLogueos" )
		
		*-- Hacer la prueba
		lozoosession = newobject( 'mockzoosession' )
		loObjetoLogueo = lozoosession.mockobtenerobjetologueo()
		lcOrigenLogueo = loObjetoLogueo.oInfoLog.OrigenLogueo

		lozoosession.Loguear( "bailar es vida sql",2 )
		lozoosession.finalizarlogueo()
		
		this.asserttrue( 'No se destruyo el objeto "loobjetologueo" ', isnull( loobjetologueo ) )
	
		*-- Chequear el logueo
		try
			lnId = fopen( lcarchivolog )
			
			lcTexto = fgets( lnId )
			this.Assertequals( "El logueo no es correcto 1", lcFecha + ", BASE: PAISES, USUARIO: , APLICACIÓN: NUCLEO, VERSIÓN: 01.0001.00000, SERIE: " + _screen.zoo.app.cserie, alltrim( upper( lcTexto )))
			lcTexto = fgets( lnId )
			this.Assertequals( "El logueo no es correcto 2", "ESTADO DEL SISTEMA: 1, NOMBRE DE LA PC: " + alltrim( upper( substr( sys( 0 ), 1, at( "#", sys( 0 ) ) - 1))) + ", USUARIO DE LA PC: " + alltrim( upper( substr( sys( 0 ), at( "#", sys( 0 ) ) + 1 ))) + ", ORIGEN LOGUEO: " + alltrim( upper(lcOrigenLogueo)), alltrim( upper( lcTexto )))
			fseek( lnId, 14, 1 )
			lcTexto = fgets( lnId )
			this.Assertequals( "El logueo no es correcto 3", "BAILAR ES VIDA SQL", alltrim( upper( lcTexto )))
			lcTexto = fread( lnId, fseek( lnId, 0, 2 ) - fseek( lnId, 0, 1 ))
			this.Assertequals( "El logueo no es correcto 4", "", alltrim( upper( lcTexto )))
			this.AssertTrue( "No es fin de archivo", feof( lnId ))
		catch to loError
			throw loerror
		finally
			fclose( lnId )
		endtry
		
		*-- Reestablecer el seteo del logueo original	
		goServicios.Logueos.terminar()

		lcXml = goDatos.EjecutarSql( "select * from " + _screen.zoo.app.cSchemaDefault + ".Logueos" )
		lcCursor = sys( 2015 )

		xmltocursor( lcXml, lcCursor )
		
		select ( lcCursor )

		this.assertequals( "El nivel no es el correcto", "ERROR", alltrim( upper( &lcCursor..Nivel )) )
		this.assertequals( "El logger no es el correcto", "FULL_ZOOSESSION", alltrim( upper( &lcCursor..Logger )) )
		this.assertequals( "La accion no es la correcta", "NO DISP.", alltrim( upper( &lcCursor..Accion )) )
		this.assertequals( "La base de datos no es la correcta", "PAISES", alltrim( upper( &lcCursor..BaseDeDatos )) )
		this.assertequals( "El estado del sistema no es el correcto", 1, &lcCursor..EstadoDelSistema )
		this.assertequals( "La aplicacion no es la correcta", "NUCLEO", alltrim( upper( &lcCursor..Aplicacion )) )
		this.assertequals( "La version no es la correcta", "01.0001.00000", alltrim( upper( &lcCursor..Version )) )
		this.assertequals( "El serie no es el correcto", _screen.zoo.app.cserie, alltrim( upper( &lcCursor..Serie )) )
		this.assertequals( "El usuario del sistema no es el correcto", "", alltrim( upper( &lcCursor..Usuario )) )
		this.assertequals( "El nombre de la pc no es el correcto", alltrim( upper( substr( sys( 0 ), 1, at( "#", sys( 0 ) ) - 1))), alltrim( upper( &lcCursor..NombrePc )) )
		this.assertequals( "El usuario de la pc no es el correcto", alltrim( upper( substr( sys( 0 ), at( "#", sys( 0 ) ) + 1 ))),alltrim( upper( &lcCursor..UsuarioPc )) )
		this.assertequals( "El origen logueo no es el correcto", alltrim( upper(lcOrigenLogueo)),alltrim( upper( &lcCursor..OrigenLogueo )) )
		this.assertequals( "El mensaje no es el correcto", "BAILAR ES VIDA SQL", substr( alltrim( upper( &lcCursor..Mensaje )), 14 ) )

		use in select( lcCursor )
		
		goDatos.EjecutarSql( "delete from " + _screen.zoo.app.cSchemaDefault + ".Logueos" )
		if file ( lcarchivolog )
			delete file ( lcarchivolog )
		endif		

		this.asserttrue( 'No se eliminó el archivo de logueo temporal', !file ( lcarchivolog ) )
		goServicios.Logueos.setearnet()
		
		lozoosession.release()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestConfiguracionEnvioDeMails
		local loManagerLogueos as ManagerLogueos of ManagerLogueos.prg, lcXMLLogueos as String, ;
			loXMLDoc as Object, loAtributo as Object

		lcSMTPHost = goLibrerias.ObtenerGuid()
		lnPuerto = goParametros.Nucleo.Logueos.Puerto + 1
		lcModoAutenticacion = goLibrerias.ObtenerGuid()
		lcUsuario = goLibrerias.ObtenerGuid()
		lcPassword = goLibrerias.ObtenerGuid()
		lcDestinatario = goLibrerias.ObtenerGuid()
		lcRemitente = goLibrerias.ObtenerGuid()
		lcAsunto = goLibrerias.ObtenerGuid()
		
		goParametros.Nucleo.Logueos.SMTPHost = lcSMTPHost
		goParametros.Nucleo.Logueos.Puerto = lnPuerto
		goParametros.Nucleo.Logueos.ModoAutenticacion = lcModoAutenticacion
		goParametros.Nucleo.Logueos.Usuario = lcUsuario
		goParametros.Nucleo.Logueos.Password = lcPassword
		goParametros.Nucleo.Logueos.Destinatario = lcDestinatario
		goParametros.Nucleo.Logueos.Remitente = lcRemitente
		goParametros.Nucleo.Logueos.Asunto = lcAsunto
		
		loManagerLogueos = _screen.Zoo.CrearObjeto( "ManagerLogueos", "ManagerLogueos.prg" )
		lcXMLLogueos = loManagerLogueos.ObtenerXmlLogueos()

		loXMLDoc = _screen.Zoo.CrearObjeto( "System.XML.XMLDocument" )
		loXMLDoc.Load( lcXMLLogueos )

		loAtributo = loXMLDoc.SelectSingleNode( "//appender[./@name='AP_SMTPAPPENDERADVERTENCIAS']/smtpHost/@value" )
		this.AssertEquals( "El valor para el atributo SMTPHost no es el correcto.", lcSMTPHost, loAtributo.value )
		loAtributo = loXMLDoc.SelectSingleNode( "//appender[./@name='AP_SMTPAPPENDERADVERTENCIAS']/port/@value" )
		this.AssertEquals( "El valor para el atributo port no es el correcto.", transform( int( lnPuerto ) ), loAtributo.value )
		loAtributo = loXMLDoc.SelectSingleNode( "//appender[./@name='AP_SMTPAPPENDERADVERTENCIAS']/authentication/@value" )
		this.AssertEquals( "El valor para el atributo authentication no es el correcto.", lcModoAutenticacion, loAtributo.value )
		loAtributo = loXMLDoc.SelectSingleNode( "//appender[./@name='AP_SMTPAPPENDERADVERTENCIAS']/userName/@value" )
		this.AssertEquals( "El valor para el atributo userName no es el correcto.", lcUsuario, loAtributo.value )
		loAtributo = loXMLDoc.SelectSingleNode( "//appender[./@name='AP_SMTPAPPENDERADVERTENCIAS']/password/@value" )
		this.AssertEquals( "El valor para el atributo password no es el correcto.", lcPassword, loAtributo.value )
		loAtributo = loXMLDoc.SelectSingleNode( "//appender[./@name='AP_SMTPAPPENDERADVERTENCIAS']/to/@value" )
		this.AssertEquals( "El valor para el atributo to no es el correcto.", lcDestinatario, loAtributo.value )
		loAtributo = loXMLDoc.SelectSingleNode( "//appender[./@name='AP_SMTPAPPENDERADVERTENCIAS']/from/@value" )
		this.AssertEquals( "El valor para el atributo from no es el correcto.", lcRemitente, loAtributo.value )
		loAtributo = loXMLDoc.SelectSingleNode( "//appender[./@name='AP_SMTPAPPENDERADVERTENCIAS']/subject/@value" )
		this.AssertEquals( "El valor para el atributo subject no es el correcto.", lcAsunto, loAtributo.value )
		loAtributo = loXMLDoc.SelectSingleNode( "//appender[./@name='AP_SMTPAPPENDERADVERTENCIAS']/bufferSize/@value" )
		this.AssertEquals( "El valor para el atributo bufferSize no es el correcto.", "1", loAtributo.value )
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestHabilitarDesHabilitarLogInterno
		local lcArchivoParaLogInterno as String, loManagerLogueos as ManagerLogueos of ManagerLogueos.prg

		goRegistry.Nucleo.ArchivoParaLogueoInterno = sys( 2015 ) + ".log"
		lcArchivoParaLogInterno = alltrim( _screen.zoo.cRutaInicial ) + addbs( goRegistry.Nucleo.RutaLogueoPorDefecto ) + alltrim( goRegistry.Nucleo.ArchivoParaLogueoInterno )
		
		goParametros.Nucleo.Logueos.HabilitarLogueoInterno = .f.
		loManagerLogueos = _screen.Zoo.CrearObjeto( "ManagerLogueos", "ManagerLogueos.prg" )
		loManagerLogueos.SetearNET()
		this.AssertTrue( "No debería existir el archivo de logueos internos", !file( lcArchivoParaLogInterno ) )

		goParametros.Nucleo.Logueos.HabilitarLogueoInterno = .t.
		loManagerLogueos.SetearNET()
		this.AssertTrue( "Debería existir el archivo de logueos internos", file( lcArchivoParaLogInterno ) )
		
		goParametros.Nucleo.Logueos.HabilitarLogueoInterno = .f.
		loManagerLogueos.SetearNET()
		if file( lcArchivoParaLogInterno )
			delete file ( lcArchivoParaLogInterno )
		endif
		
	endfunc

EndDefine	

define class TestManagerLogueos as ManagerLogueos of ManagerLogueos.prg

	*-----------------------------------------------------------------------------------------
	function Init() as VOID
		if ( _Screen.zoo.app.TipoDeBase = "NATIVA" )
			this.cArchivoXMLSeteo = addbs( _screen.zoo.obtenerrutatemporal() ) + "GENERADOS\din_logueos.xml" 
		else
			this.cArchivoXMLSeteo = addbs( _screen.zoo.obtenerrutatemporal() ) + "GENERADOS\din_logueosSqlServer.xml" 
		endif
		
		this.oRepositorios = _Screen.zoo.crearobjeto( 'din_logueos', addbs( _screen.zoo.obtenerrutatemporal() ) + "GENERADOS\din_logueos.prg"  )
		dodefault()
		this.oRepositorios = _Screen.zoo.crearobjeto( 'din_logueos', addbs( _screen.zoo.obtenerrutatemporal() ) + "GENERADOS\din_logueos.prg"  )
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerXmlLogueos() as string
		local lcXml as String
		
		if ( _Screen.zoo.app.TipoDeBase = "NATIVA" )
		else
			lcXml = filetostr( This.cArchivoXMLSeteo )
			lcXml = this.ReemplazarStringConnection( lcXml )
			
			******Reemplazo los parametros y variables que estan entre |@variable@|
					lcOldTextMerge = set("Textmerge")
					set textmerge On
			*jbarrionuevo # 27/05/2010 19:46:28 No quitar esta "doble" linea, es necesario en SqlServer para que haga los reemplazos
					lnIntentos = 0
					do while "|@" $ lcXml and "@|" $ lcXml and lnIntentos < 5
						lnIntentos = lnIntentos + 1 
						lcXml = textmerge( lcXml, .F., "|@", "@|" )
					enddo
			**********************************************************************************************************
			set textmerge &lcOldTextMerge	
		
			strtofile( lcXml, This.cArchivoXMLSeteo )
		endif
		
		return This.cArchivoXMLSeteo
	endfunc 	
enddefine

	
*-----------------------------------------------------------------------------------------
define class mockManagerLogueos as ManagerLogueos of ManagerLogueos.prg
	oEnvios = null
	cantSerializados = 0
	*-----------------------------------------------------------------------------------------
	function init() as Void
		dodefault()
		this.oEnvios = _Screen.zoo.crearobjeto( "zooColeccion" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function MockSepararPorNiveles( toParametro as Object ) as zoocoleccion OF zoocoleccion.prg
		return this.SepararPorNiveles( toParametro )
	endfunc 
	*-----------------------------------------------------------------------------------------
	function enviarANet( toObjetoLogueo as Object ) as Void
		local loEnviado as Custom
		loEnviado = newobject( "Custom" )
		
		with toObjetoLogueo.oInfoLog
			loEnviado.AddProperty( "TipoLogueo", .TipoLogueo )
			loEnviado.AddProperty( "BaseDatos", .BaseDatos )
			loEnviado.AddProperty( "Usuario", .Usuario )
			loEnviado.AddProperty( "Serie", .Serie )
			loEnviado.AddProperty( "Version", .Version )
			loEnviado.AddProperty( "Aplicacion", .Aplicacion )
			loEnviado.AddProperty( "EstadoSistema", .EstadoSistema )
			loEnviado.AddProperty( "NombrePc", .NombrePc )
			loEnviado.AddProperty( "UsuarioPc", .UsuarioPc )
			loEnviado.AddProperty( "OrigenLogueo", .OrigenLogueo)
			loEnviado.AddProperty( "Mensaje", .Mensaje )
		endwith
				
		this.oEnvios.agregar( loEnviado )
	endfunc 
	*-----------------------------------------------------------------------------------------
	function SerializarDetalle( toDetalle as Object ) as String
		this.cantSerializados = this.cantSerializados + 1
		return "Detalle serializado " + transform( this.cantSerializados )
	endfunc

enddefine

*-----------------------------------------------------------------------------------------
define class mockManagerLogueosSerializacion as ManagerLogueos of ManagerLogueos.prg
	oClasesHerencias = null

	*-----------------------------------------------------------------------------------------
	function Init() as VOID
		dodefault()
		This.oClasesHerencias = _screen.zoo.crearobjeto( "ZooColeccion" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function MockSerializarCabecera( toObjeto as Object ) as String
		return this.SerializarCabecera( toObjeto )
	endfunc 
	*-----------------------------------------------------------------------------------------
	function MockSerializarDetalle( toObjeto as Object ) as String
		return this.SerializarDetalle( toObjeto )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerColeccionRepositorios() as Void
		with this.oRepositorios
			loItem = newobject( "custom" )
			loItem.AddProperty( "cClave", "PRIMERO" )
*			loItem.AddProperty( "cRepositorio", "Testear1.txt" )
			.Agregar( loItem, "PRIMERO" )
			
			loItem = newobject( "custom" )
			loItem.AddProperty( "cClave", "SEGUNDO" )
*			loItem.AddProperty( "cRepositorio", "Testear2.txt" )
			.Agregar( loItem, "SEGUNDO" )
			
			loItem = newobject( "custom" )
			loItem.AddProperty( "cClave", "TERCERO" )
*			loItem.AddProperty( "cRepositorio", "Testear3.txt" )
			.Agregar( loItem, "TERCERO" )
		endwith

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerHerencias( toQuienPide as Object ) as array
		return This.oClasesHerencias
	endfunc 
	
enddefine 

*-----------------------------------------------------------------------------------------
define class MockManagerLogueosIntegracion as ManagerLogueos of ManagerLogueos.prg
	cRutaTemporal = ""
	
	*-----------------------------------------------------------------------------------------
	function Init() as VOID
		with this
			.cRutaTemporal = _Screen.zoo.obtenerrutatemporal()
		endwith
		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerXmlLogueos() as string
		local lcArchivo as string, lcXMLTemp as string

		with this
			.cArchivoXMLSeteo = .cRutaTemporal + "Din_Logueos2.xml"
			lcXMLTemp = filetostr( addbs( _screen.zoo.cRutaInicial ) + "clasesdeprueba\Din_Logueos.xml" )
			lcXMLTemp = strtran( lcXMLTemp, "%RUTATEMPDETEST%", .cRutaTemporal + "LOGTEST.LOG" )
			do Case
				case _Screen.zoo.app.TipodeBase = "NATIVA"
				case _Screen.zoo.app.TipodeBase = "SQLSERVER"
					lcXMLTemp = strtran( lcXMLTemp, "'FXUTESTCASE'", "'FULL_FXUTESTCASE'" )
				otherwise
					This.Asserttrue( "TESTEAR !!!!", .F. )
			EndCase		

			
			strtofile( lcXMLTemp, This.cArchivoXMLSeteo, 0 )
		endwith
		
		return This.cArchivoXMLSeteo
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerColeccionRepositorios() as Void
		This.oRepositorios = newobject( "TestColeccionLogueo", "TestColeccionLogueo.prg" )
	endfunc

enddefine

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

*-----------------------------------------------------------------------------------------
define class MockZooSession as zooSession of zooSession.prg

	*-----------------------------------------------------------------------------------------
	function mockObtenerObjetoLogueo() as Object
		return this.oLogueo
	endfunc 

enddefine
