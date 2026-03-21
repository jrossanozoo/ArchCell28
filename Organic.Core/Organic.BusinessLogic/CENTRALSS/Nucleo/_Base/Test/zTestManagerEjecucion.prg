**********************************************************************
define class zTestManagerEjecucion as FxuTestCase of FxuTestCase.prg

	#if .f.
		local this as zTestManagerEjecucion of zTestManagerEjecucion.prg
	#endif
	lMockearParametros = .F.
	
	*-----------------------------------------------------------------------------------------
	function Setup
		if vartype( _screen.lUsaCapaDePresentacion ) == "L"			
		else
			_Screen.AddProperty( "lUsaCapaDePresentacion", .F. )
		Endif
	endfunc

	*---------------------------------
	function TearDown
		goServicios.Modulos = goModulos
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestCargarScript
		local lcIdApp as string, loEjecucion as managerEjecucion of managerEjecucion.prg

		lcIdApp = CrearArchivoScript()

		loEjecucion = _screen.zoo.crearobjeto( "ManagerEjecucion" )

		this.asserttrue( "No debe tener un script cargado", !loEjecucion.TieneScriptCargado() )
		loEjecucion.CargarScript( addbs( _screen.zoo.ObtenerRutaTemporal() ) + "script.zs" )

		this.asserttrue( "Debe tener un script cargado", loEjecucion.TieneScriptCargado() )

		with loEjecucion.oColAtributos
			this.assertequals( "La cantidad de items en la coleccion de atributos es incorrecta", 3, .count )
			this.assertequals( "El atributo del item 1 es incorrecto", "IDAPLICACION", 			.item( 1 ).cAtributo )
			this.assertequals( "El tipo de dato del item 1 es incorrecto", "C", 				.item( 1 ).cTipoDato )
			this.assertequals( "El valor del item 1 es incorrecto", lcIdApp,					.item( 1 ).cValor )
			this.assertequals( "El atributo del item 2 es incorrecto", "CUSUARIOLOGUEADO", 		.item( 2 ).cAtributo )
			this.assertequals( "El tipo de dato del item 2 es incorrecto", "C", 				.item( 2 ).cTipoDato )
			this.assertequals( "El valor del item 2 es incorrecto", "idusuario",				.item( 2 ).cValor )
			this.assertequals( "El atributo del item 5 es incorrecto", "CSUCURSALACTIVA",		.item( 3 ).cAtributo )
			this.assertequals( "El tipo de dato del item 5 es incorrecto", "C", 				.item( 3 ).cTipoDato )
			this.assertequals( "El valor del item 5 es incorrecto", _screen.zoo.app.cSucursalActiva, .item( 3 ).cValor )
		endwith

		with loEjecucion.oColAcciones
			this.assertequals( "La cantidad de items en la coleccion de acciones es incorrecta", 2, .count )
			this.assertequals( "La accion 1 es incorrecta", "pp = 100", .item( 1 ) )
			this.assertequals( "La accion 2 es incorrecta", "goServicios.Seguridad.cUsuarioAdministrador = 'Test'", .item( 2 ) )
		endwith

		loEjecucion.release()
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestLogIn
		local loInfo as object, loError as exception, loEjecucion as managerEjecucion of managerEjecucion.prg

		CrearArchivoScript()

		loEjecucion = _screen.zoo.crearobjeto( "ManagerEjecucion" )
		with loEjecucion as managerEjecucion of managerEjecucion.prg

			.CargarScript( addbs( _screen.zoo.ObtenerRutaTemporal() ) + "script.zs" )
			.LogIn()

			this.assertequals( "El valor de lEsAdministrador es incorrecto", .f., goServicios.Seguridad.lEsAdministrador )
			this.assertequals( "El valor de cUsuarioLogueado es incorrecto", "IDUSUARIO", goServicios.Seguridad.cUsuarioLogueado )
			this.assertequals( "El valor de cUsuarioAdministrador es incorrecto", "ADMIN", goServicios.Seguridad.cUsuarioAdministrador )
			this.assertequals( "El valor de cIdPerfilAdministrador es incorrecto", "", goServicios.Seguridad.cIdPerfilAdministrador )

			loEjecucion.oColAtributos.remove( 1 )

			try
				.LogIn()
			catch to loError
				loInfo = loError.uservalue.ObtenerInformacion()
				this.assertequals( "El error no es el esperado", "Error al obtener el atributo", loInfo.item[ 1 ].cMensaje )
			endtry

		endwith
		loEjecucion.release()
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestLogInSucursalPreferente
		local loInfo as object, loError as exception, loEjecucion as managerEjecucion of managerEjecucion.prg

		_screen.mocks.agregarmock( "RepositorDeBaseDeDatos" )
		_screen.mocks.AgregarSeteoMetodo( 'RepositorDeBaseDeDatos', 'ObtenerBaseDeDatos', "Paises" )

		CrearArchivoScriptSucursalPreferente()

		loEjecucion = _screen.zoo.crearobjeto( "ManagerEjecucion" )
		with loEjecucion as managerEjecucion of managerEjecucion.prg
			.CargarScript( addbs( _screen.zoo.ObtenerRutaTemporal() ) + "script.zs" )
			.LogIn()
		endwith
		_screen.mocks.verificarejecuciondemocks( "RepositorDeBaseDeDatos" )
		loEjecucion.release()
	endfunc


	*-----------------------------------------------------------------------------------------
	function zTestEjecutarAcciones
		local loInfo as object, loError as exception, loEjecucion as managerEjecucion of managerEjecucion.prg

		CrearArchivoScript()

		loEjecucion = _screen.zoo.crearobjeto( "ManagerEjecucion" )
		loEjecucion.CargarScript( addbs( _screen.zoo.ObtenerRutaTemporal() ) + "script.zs" )

		loEjecucion.EjecutarAcciones()
		this.assertequals( "La accion no se ejecuto correctamente", "Test", goServicios.Seguridad.cUsuarioAdministrador )

		loEjecucion.oColAcciones.Agregar( "a = b" )

		try
			loEjecucion.EjecutarAcciones()
		catch to loError
			this.assertequals( "El error no es el esperado", "Variable 'B' is not found.", loError.uservalue.message )
		endtry

		loEjecucion.release()
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestGenerarScript
		local loEjecucion as object, loColInstrucciones as zoocoleccion of zoocoleccion.prg, lcIdApp as string, ;
			lcArchivo as string, loError as exception, loEjecucion as managerEjecucion of managerEjecucion.prg

		loEjecucion = _screen.zoo.crearobjeto( "ManagerEjecucion" )
		loColInstrucciones = _screen.zoo.crearobjeto( "zooColeccion" )
		lcArchivo = addbs( _screen.zoo.obtenerrutatemporal() ) + "scriptprueba.txt"

		with loEjecucion
			lcIdApp = .GenerarScript( "ADMIN", "PRUEBA", loColInstrucciones, lcArchivo, .t. )
			this.asserttrue( "No se generó el archivo", file( lcArchivo ) )
			this.asserttrue( "El id de aplicacion esta vacío", !empty( lcIdApp ) )

			try
				lcIdApp = .GenerarScript( "ADMIN", "PRUEBA", loColInstrucciones, "Ñ:\cadorna.txt", .t. )
				this.asserttrue( "Debe dar error por no existir la ubicación del archivo.", .f. )
			catch to loError
				this.assertequals( "El error es incorrecto", "Problemas al intentar generar el archivo Ñ:\cadorna.txt", loError.uservalue.oInformacion.item[1].cMensaje )
			endtry
			.release()
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestGenerarContenidoDelScriptScript_SalirON_ModoSilenciosoOFF
		local loEjecucion as object, loColInstrucciones as zoocoleccion of zoocoleccion.prg, lcScript as string, lnCantLineas as Integer, i as Integer,;
			lcArchivo as string, loError as exception, loEjecucion as managerEjecucion of managerEjecucion.prg, lcComandos as string, ;
			lcAtributo as String, lcTipoDato as String, lcValor as string

		local array laLineas[1]
		
		loEjecucion = _screen.zoo.crearobjeto( "ManagerEjecucion" )
		loColInstrucciones = _screen.zoo.crearobjeto( "zooColeccion" )
		lcArchivo = addbs( _screen.zoo.obtenerrutatemporal() ) + "scriptprueba.txt"

		with loEjecucion
			lcScript = .GenerarContenidoDelScriptScript( "ADMIN", "PRUEBA", loColInstrucciones, .t., .t., "idApp" )

			lnCantLineas = alines( laLineas, lcScript, 5, chr( 13 ) + chr( 10 ) )
			
			this.assertequals( "La cantidad de lineas es incorrecta", 6, lnCantLineas )
			
			lcAtributo = strextract( goServicios.Librerias.Desencriptar( laLineas[ 2 ] ), "<", ">", 1 )
			lcTipoDato = upper( strextract( goServicios.Librerias.Desencriptar( laLineas[ 2 ] ), "<", ">", 2 ) )
			lcValor = strextract( goServicios.Librerias.Desencriptar( laLineas[ 2 ] ), "<", ">", 3 )
			
			this.assertequals( "El atributo es erroneo (2)", "_Screen.lUsaCapaDePresentacion", lcAtributo )
			this.assertequals( "El tipodato es erroneo (2)", "L", lcTipoDato )
			this.assertequals( "El valor es erroneo (2)", ".t.", lcValor )

			lcAtributo = strextract( goServicios.Librerias.Desencriptar( laLineas[ 3 ] ), "<", ">", 1 )
			lcTipoDato = upper( strextract( goServicios.Librerias.Desencriptar( laLineas[ 3 ] ), "<", ">", 2 ) )
			lcValor = strextract( goServicios.Librerias.Desencriptar( laLineas[ 3 ] ), "<", ">", 3 )
			
			this.assertequals( "El atributo es erroneo (3)", "IdAplicacion", lcAtributo )
			this.assertequals( "El tipodato es erroneo (3)", "C", lcTipoDato )
			this.assertequals( "El valor es erroneo (3)", "idApp", lcValor )

			lcAtributo = strextract( goServicios.Librerias.Desencriptar( laLineas[ 4 ] ), "<", ">", 1 )
			lcTipoDato = upper( strextract( goServicios.Librerias.Desencriptar( laLineas[ 4 ] ), "<", ">", 2 ) )
			lcValor = strextract( goServicios.Librerias.Desencriptar( laLineas[ 4 ] ), "<", ">", 3 )
			
			this.assertequals( "El atributo es erroneo (4)", "cUsuarioLogueado", lcAtributo )
			this.assertequals( "El tipodato es erroneo (4)", "C", lcTipoDato )
			this.assertequals( "El valor es erroneo (4)", "ADMIN", lcValor )

			lcAtributo = strextract( goServicios.Librerias.Desencriptar( laLineas[ 5 ] ), "<", ">", 1 )
			lcTipoDato = upper( strextract( goServicios.Librerias.Desencriptar( laLineas[ 5 ] ), "<", ">", 2 ) )
			lcValor = strextract( goServicios.Librerias.Desencriptar( laLineas[ 5 ] ), "<", ">", 3 )
			
			this.assertequals( "El atributo es erroneo (5)", "cSucursalActiva", lcAtributo )
			this.assertequals( "El tipodato es erroneo (5)", "C", lcTipoDato )
			this.assertequals( "El valor es erroneo (5)", "PRUEBA", lcValor )

			lcAtributo = strextract( goServicios.Librerias.Desencriptar( laLineas[ 6 ] ), "<", ">", 1 )
			lcTipoDato = upper( strextract( goServicios.Librerias.Desencriptar( laLineas[ 6 ] ), "<", ">", 2 ) )
			lcValor = strextract( goServicios.Librerias.Desencriptar( laLineas[ 6 ] ), "<", ">", 3 )
			
			this.assertequals( "El atributo es erroneo (6)", "_Screen.Zoo.App.Salir()", lcAtributo )
			this.assertequals( "El tipodato es erroneo (6)", "ACCION", lcTipoDato )
			this.assertequals( "El valor es erroneo (6)", "", lcValor )
		
			.release()
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestGenerarContenidoDelScriptScript_SalirOFF_ModoSilenciosoON
		local loEjecucion as object, loColInstrucciones as zoocoleccion of zoocoleccion.prg, lcScript as string, lnCantLineas as Integer, i as Integer,;
			lcArchivo as string, loError as exception, loEjecucion as managerEjecucion of managerEjecucion.prg, lcComandos as string, ;
			lcAtributo as String, lcTipoDato as String, lcValor as string

		local array laLineas[1]
		
		loEjecucion = _screen.zoo.crearobjeto( "ManagerEjecucion" )
		loColInstrucciones = _screen.zoo.crearobjeto( "zooColeccion" )
		lcArchivo = addbs( _screen.zoo.obtenerrutatemporal() ) + "scriptprueba.txt"

		with loEjecucion
			lcScript = .GenerarContenidoDelScriptScript( "ADMIN", "PRUEBA", loColInstrucciones, .f., .f., "idApp" )

			lnCantLineas = alines( laLineas, lcScript, 5, chr( 13 ) + chr( 10 ) )
			
			this.assertequals( "La cantidad de lineas es incorrecta", 4, lnCantLineas )
			
			lcAtributo = strextract( goServicios.Librerias.Desencriptar( laLineas[ 2 ] ), "<", ">", 1 )
			lcTipoDato = upper( strextract( goServicios.Librerias.Desencriptar( laLineas[ 2 ] ), "<", ">", 2 ) )
			lcValor = strextract( goServicios.Librerias.Desencriptar( laLineas[ 2 ] ), "<", ">", 3 )
			
			this.assertequals( "El atributo es erroneo (2)", "IdAplicacion", lcAtributo )
			this.assertequals( "El tipodato es erroneo (2)", "C", lcTipoDato )
			this.assertequals( "El valor es erroneo (2)", "idApp", lcValor )

			lcAtributo = strextract( goServicios.Librerias.Desencriptar( laLineas[ 3 ] ), "<", ">", 1 )
			lcTipoDato = upper( strextract( goServicios.Librerias.Desencriptar( laLineas[ 3 ] ), "<", ">", 2 ) )
			lcValor = strextract( goServicios.Librerias.Desencriptar( laLineas[ 3 ] ), "<", ">", 3 )
			
			this.assertequals( "El atributo es erroneo (3)", "cUsuarioLogueado", lcAtributo )
			this.assertequals( "El tipodato es erroneo (3)", "C", lcTipoDato )
			this.assertequals( "El valor es erroneo (3)", "ADMIN", lcValor )

			lcAtributo = strextract( goServicios.Librerias.Desencriptar( laLineas[ 4 ] ), "<", ">", 1 )
			lcTipoDato = upper( strextract( goServicios.Librerias.Desencriptar( laLineas[ 4 ] ), "<", ">", 2 ) )
			lcValor = strextract( goServicios.Librerias.Desencriptar( laLineas[ 4 ] ), "<", ">", 3 )
			
			this.assertequals( "El atributo es erroneo (4)", "cSucursalActiva", lcAtributo )
			this.assertequals( "El tipodato es erroneo (4)", "C", lcTipoDato )
			this.assertequals( "El valor es erroneo (4)", "PRUEBA", lcValor )

			.release()
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestMostrarEnNuevoHilo
		local loEjecucion as object, loEjecucion as managerEjecucion of managerEjecucion.prg
		private goModulos

		_screen.Mocks.AgregarMock( "Modulos" )
		_screen.mocks.AgregarSeteoMetodo( 'MODULOS', 'Entidadhabilitada', .t., "[ENTIDAD]" )

		goModulos = _screen.Zoo.CrearObjeto( "Modulos" )
		goServicios.Modulos = goModulos

		loEjecucion = newobject( "managerEjecucionTest" )

		with loEjecucion
			.MostrarEnNuevoHilo( "ENTIDAD" )

			this.asserttrue( "No paso por EjecutarScript", .lEjecutarScript )
			this.asserttrue( "No paso por TraerAlFrente", .lTraerAlFrente )
			this.asserttrue( "No paso por ObtenerIdInternoDeAplicacion", .lObtenerIdInternoDeAplicacion )
			this.assertequals( "La cantidad de aplicaciones en ejecucion es incorrecta", 1, .oColAplicacionesId.count )
			this.assertequals( "La aplicacion en ejecucion es incorrecta", "id", .oColAplicacionesId.item[ 1 ] )

			.release()
		endwith
		goServicios.Modulos = null
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestMostrarScxEnNuevoHilo
		local loEjecucion as object, loEjecucion as managerEjecucion of managerEjecucion.prg

		loEjecucion = newobject( "managerEjecucionTest" )

		with loEjecucion
			.MostrarScxEnNuevoHilo( "ENTIDAD" )

			this.asserttrue( "No paso por EjecutarScript", .lEjecutarScript )
			this.asserttrue( "No paso por TraerAlFrente", .lTraerAlFrente )
			this.asserttrue( "No paso por ObtenerIdInternoDeAplicacion", .lObtenerIdInternoDeAplicacion )
			this.assertequals( "La cantidad de aplicaciones en ejecucion es incorrecta", 1, .oColAplicacionesId.count )
			this.assertequals( "La aplicacion en ejecucion es incorrecta", "id", .oColAplicacionesId.item[ 1 ] )

			.release()
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestMostrarfrmEnNuevoHilo
		local loEjecucion as object, loEjecucion as managerEjecucion of managerEjecucion.prg

		loEjecucion = newobject( "managerEjecucionTest" )

		with loEjecucion
			.MostrarfrmEnNuevoHilo( "frmtransferencias" )

			this.asserttrue( "No paso por EjecutarScript", .lEjecutarScript )
			this.asserttrue( "No paso por TraerAlFrente", .lTraerAlFrente )
			this.asserttrue( "No paso por ObtenerIdInternoDeAplicacion", .lObtenerIdInternoDeAplicacion )
			this.assertequals( "La cantidad de aplicaciones en ejecucion es incorrecta", 1, .oColAplicacionesId.count )
			this.assertequals( "La aplicacion en ejecucion es incorrecta", "id", .oColAplicacionesId.item[ 1 ] )

			.release()
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function zTestU_EjecutarAplicacionForzandoSalida
		
		*Arrange (Preparar)
		local loManager as Object, loCreador as Object, loParametrosCreador as Object

		loManager = _Screen.zoo.crearobjeto("managerEjecucion")

		loCreador = this.oserviciomocks.generarMock("creadorDeProcesos")
		loParametrosCreador = newobject("collection")
		loParametrosCreador.add( "ejecutable.exe" )
		loParametrosCreador.add( "parametro1, parametro2" )
		loParametrosCreador.add( 1 )
		loParametrosCreador.add( replicate( chr( 0 ), 128 ) )
		loCreador.EstablecerExpectativa("CrearProceso32BitConReferencia",8, loParametrosCreador )

		loParametrosCreador = newobject("collection")
		loParametrosCreador.add( replicate( chr( 0 ), 128 ) )
		loCreador.EstablecerExpectativa("ObtenerHandle",1234, loParametrosCreador )

		loManager.oCreadorDeProcesos = loCreador

		*Act (Actuar)
		loManager.EjecutarAplicacion("ejecutable.exe", "parametro1, parametro2", .T.)
		*Assert (Afirmar)
		this.assertequals("En la coleccion de procesos ejecutados no esta el item esperado. :(", 1, loManager.oColProcesosEjecutados.count )
		this.assertequals("El proceso en la coleccion no es el correcto", "ejecutable.exe", loManager.oColProcesosEjecutados.item(1).archivo )
		this.assertequals("El PID en la coleccion no es el correcto", 1234, loManager.oColProcesosEjecutados.item(1).handle )
		this.assertequals("El flag de forzar salida no es correcto", .T., loManager.oColProcesosEjecutados.item(1).ForzarSalida )
		
		loCreador.ValidarLlamadas()
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestU_EjecutarAplicacionSinForzarSalida
		
		*Arrange (Preparar)
		local loManager as Object, loCreador as Object, loParametrosCreador as Object

		loManager = _Screen.zoo.crearobjeto("managerEjecucion")

		loCreador = this.oserviciomocks.generarMock("creadorDeProcesos")
		loParametrosCreador = newobject("collection")
		loParametrosCreador.add( "ejecutable.exe" )
		loParametrosCreador.add( "parametro1, parametro2" )
		loParametrosCreador.add( 1 )
		loParametrosCreador.add( replicate( chr( 0 ), 128 ) )
		loCreador.EstablecerExpectativa("CrearProceso32BitConReferencia",8, loParametrosCreador )

		loParametrosCreador = newobject("collection")
		loParametrosCreador.add( replicate( chr( 0 ), 128 ) )
		loCreador.EstablecerExpectativa("ObtenerHandle",1234, loParametrosCreador )
		loCreador.EstablecerExpectativa("ObtenerPID",4321, loParametrosCreador )

		loManager.oCreadorDeProcesos = loCreador

		*Act (Actuar)
		loManager.EjecutarAplicacion("ejecutable.exe", "parametro1, parametro2")
		*Assert (Afirmar)
		this.assertequals("En la coleccion de procesos ejecutados no esta el item esperado. :(", 1, loManager.oColProcesosEjecutados.count )
		this.assertequals("El proceso en la coleccion no es el correcto", "ejecutable.exe", loManager.oColProcesosEjecutados.item(1).archivo )
		this.assertequals("El PID en la coleccion no es el correcto", 4321, loManager.oColProcesosEjecutados.item(1).pid )
		this.assertequals("El Handle en la coleccion no es el correcto", 1234, loManager.oColProcesosEjecutados.item(1).handle )
		this.assertequals("El flag de forzar salida no es correcto", .F., loManager.oColProcesosEjecutados.item(1).ForzarSalida )
		
		loCreador.ValidarLlamadas()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ztestU_ztesthayappabiertas_SinAppAbiertas
		private goLibrerias as Object
		local loManager as Object, loColProcesos as Object, llRetorno as Boolean
		
		goLibrerias = newobject( "mockLibrerias" )
		goLibrerias.oFxu = this
		loManager = _Screen.zoo.crearobjeto("managerEjecucion")
		
		llRetorno = loManager.HayAppAbiertas()
		
		this.asserttrue("No tiene que encontrar app abiertas", !llRetorno)

	endfunc 


	*-----------------------------------------------------------------------------------------
	function ztestU_ztesthayappabiertas_ConAppAbiertas
		private goLibrerias as Object
		local loManager as Object, loColProcesos as Object, llRetorno as Boolean, loProceso as Object
		
		goLibrerias = newobject( "mockLibrerias" )
		goLibrerias.oFxu = this
		goLibrerias.retorno = .T.
		loManager = _Screen.zoo.crearobjeto("managerEjecucion")
		
		loProceso = newobject("proceso","managerEjecucion.prg")
		loProceso.archivo = "ejecutable.exe"
		loProceso.handle = 4321
		loProceso.PID = 1234
		loManager.oColProcesosEjecutados.add(loProceso)
		
		llRetorno = loManager.HayAppAbiertas()
		
		this.asserttrue("Tiene que encontrar app abiertas", llRetorno)

	endfunc 	
	*-----------------------------------------------------------------------------------------
	function ztestU_ztesthayappabiertas_ConAppAbiertasPeroYaCerradas
	**Representa en caso en que se hayan lanzado durante la ejecucion de organic una aplicacion, pero que el usuario ya cerro
		private goLibrerias as Object
		local loManager as Object, loColProcesos as Object, llRetorno as Boolean, loProceso as Object
		
		goLibrerias = newobject( "mockLibrerias" )
		goLibrerias.oFxu = this
		goLibrerias.retorno = .F.
		loManager = _Screen.zoo.crearobjeto("managerEjecucion")
		
		loProceso = newobject("proceso","managerEjecucion.prg")
		loProceso.archivo = "ejecutable.exe"
		loProceso.handle = 4321
		loProceso.pid = 1234
		loManager.oColProcesosEjecutados.add(loProceso)
		
		llRetorno = loManager.HayAppAbiertas()
		
		this.asserttrue("No tiene que encontrar app abiertas", !llRetorno)

	endfunc 	

	*-----------------------------------------------------------------------------------------
	function ztestU_ztesthayappabiertas_ConAppAbiertasForzarSalidaCerrarAlSalir
	**Representa en caso en que se hayan lanzado durante la ejecucion de organic una aplicacion, pero que el usuario ya cerro
		private goLibrerias as Object
		local loManager as Object, loColProcesos as Object, llRetorno as Boolean, loProceso as Object, loMockCreador as Object
		
		loMockCreador = newobject( "mockCreadorDeProcesos" )
		
		goLibrerias = newobject( "mockLibrerias" )
		goLibrerias.oFxu = this
		goLibrerias.retorno = .F.
		loManager = _Screen.zoo.crearobjeto("managerEjecucion")
		
		loManager.oCreadorDeProcesos = loMockCreador
		
		loProceso = newobject( "proceso", "managerEjecucion.prg" )
		loProceso.archivo = "ejecutable.exe"
		loProceso.handle = 4321
		loProceso.pid = 1234
		loProceso.ForzarSalida = .T.
		loProceso.CerrarAlSalir = .T.
		loManager.oColProcesosEjecutados.add(loProceso)
		
		llRetorno = loManager.HayAppAbiertas()
		
		this.asserttrue("No tiene que encontrar app abiertas", !llRetorno)
		this.assertequals("Tiene que llamar a librerias", 1, golibrerias.llamadas)
		this.Assertequals( "No mato al proceso correcto", 4321, loMockCreador.Handle )

	endfunc 


	*-----------------------------------------------------------------------------------------
	function zTestCargarScriptCorrupto
		local loEjecucion as managerEjecucion of managerEjecucion.prg, lcArchivoCorrupto as String, ;
			loError as zooexception OF zooexception.prg
		lcArchivoCorrupto = addbs( _screen.zoo.obtenerrutaTemporal() ) + sys( 2015 ) + ".zs" 
		loEjecucion = _screen.zoo.crearobjeto( "ManagerEjecucion" )

		strtofile( "Este archivo es corrupto por que no tiene CRC.", lcArchivoCorrupto )
		try
			loEjecucion.CargarScript( lcArchivoCorrupto  )
		catch to loError
			this.assertequals( "El mensaje es incorrecto.", "Archivo de script corrupto." ,loError.UserValue.oInformacion.item(1).cMensaje )
		endtry
		this.asserttrue( "No debe tener un script cargado.", !loEjecucion.TieneScriptCargado() )
		loEjecucion.release()
	endfunc	
	
	*-----------------------------------------------------------------------------------------
	function zTestCargarScriptInexistente
		local loEjecucion as managerEjecucion of managerEjecucion.prg, lcArchivoCorrupto as String, ;
			loError as zooexception OF zooexception.prg

		lcArchivoCorrupto = addbs( _screen.zoo.obtenerrutaTemporal() ) + sys( 2015 ) + ".zs" 
		loEjecucion = _screen.zoo.crearobjeto( "ManagerEjecucion" )
		
		try
			loEjecucion.CargarScript( lcArchivoCorrupto  )
		catch to loError
			this.assertequals( "El mensaje es incorrecto.", "Archivo de script inexistente." ,loError.UserValue.oInformacion.item(1).cMensaje )
		endtry
		this.asserttrue( "No debe tener un script cargado.", !loEjecucion.TieneScriptCargado() )
		loEjecucion.release()
	endfunc		
enddefine

*-----------------------------------------------------------------------------------------
define class mockLibrerias as custom
	oFxu = null
	retorno = .T.
	llamadas = 0
	*-----------------------------------------------------------------------------------------
	function VerificarExistenciaDeProceso( archivo as string, handle as Integer ) as boolean
		this.llamadas = this.llamadas + 1
		this.oFxu.AssertEquals( "El archivo no concuerda", "ejecutable.exe", archivo )
		this.oFxu.AssertEquals( "El handle no concuerda", 1234, handle )
		return this.retorno
	endfunc 
function init

endfunc

enddefine


*-----------------------------------------------------------------------------------------
define class mockCreadorDeProcesos as custom
	handle = 0
	*-----------------------------------------------------------------------------------------
	function MatarProceso( tnHandle as Integer) as Void
		this.handle = tnHandle
	endfunc 

enddefine


*-----------------------------------------------------------------------------------------
function CrearArchivoScript() as string
	local loInstrucciones as zoocoleccion of zoocoleccion.prg, lcIdApp as string, loEjecucion as managerEjecucion of managerEjecucion.prg

	loInstrucciones = _screen.zoo.crearobjeto( "ZooColeccion" )
	with loInstrucciones
		.Agregar( "pp = 100" )
		.Agregar( "goServicios.Seguridad.cUsuarioAdministrador = 'Test'" )
	endwith
	loEjecucion = _screen.zoo.crearobjeto( "ManagerEjecucion" )
	lcIDApp = loEjecucion.GenerarScript( "idusuario", alltrim( _screen.zoo.app.cSucursalActiva ), loInstrucciones, ;
		addbs( _screen.zoo.ObtenerRutaTemporal() ) + "script.zs", .f. )

	return lcIdApp
endfunc

*-----------------------------------------------------------------------------------------
function CrearArchivoScriptSucursalPreferente() as string
	local loInstrucciones as zoocoleccion of zoocoleccion.prg, lcIdApp as string, loEjecucion as managerEjecucion of managerEjecucion.prg

	loInstrucciones = _screen.zoo.crearobjeto( "ZooColeccion" )
	with loInstrucciones
		.Agregar( "pp = 100" )
		.Agregar( "goServicios.Seguridad.cUsuarioAdministrador = 'Test'" )
	endwith
	loEjecucion = _screen.zoo.crearobjeto( "ManagerEjecucion" )
	lcIDApp = loEjecucion.GenerarScript( "idusuario", '[PREF]', loInstrucciones, ;
		addbs( _screen.zoo.ObtenerRutaTemporal() ) + "script.zs", .f. )

	return lcIdApp
endfunc

*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class managerEjecucionTest as managerEjecucion of managerEjecucion.prg

	lEjecutarScript = .f.
	lTraerAlFrente = .f.
	lObtenerIdInternoDeAplicacion = .f.

	*-----------------------------------------------------------------------------------------
	protected function EjecutarScript( tcRutaScript as string ) as Void
		this.lEjecutarScript = .t.
		
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function TraerAlFrente( tcId as string ) as Void
		this.lTraerAlFrente = .t.
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerIdInternoDeAplicacion( tcId as string ) as integer
		this.lObtenerIdInternoDeAplicacion = .t.
		return 1
	endfunc

	*-----------------------------------------------------------------------------------------
	function GenerarScript( tcUsuario as string, tcBaseDeDatos as string, toInstrucciones as zoocoleccion of zoocoleccion.prg, ;
			tcArchivo as string, tlSalir as Boolean, tlModoSilenciosoOff as Boolean ) as string

		return "id"
	endfunc
enddefine
