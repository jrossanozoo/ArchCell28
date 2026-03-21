**********************************************************************
Define Class ztestRegistroTerminal As FxuTestCase Of FxuTestCase.prg

	#If .F.
		Local This As ztestRegistroTerminal Of ztestRegistroTerminal.prg
	#Endif

	*-----------------------------------------------------------------------------------------
	function tearDown
		goServicios.Ejecucion.lScriptCargado = .f.
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestHabilitarDeshabilitarServicioRegistroTerminal
		local loapp as aplicacionbase of aplicacionbase.prg, lcTituloParaLaVentanaDelMonitor as String,;
        lcUltimaOperacion as string, lcUsuarioLogueado as String
        
        lcUltimaOperacion = goServicios.Seguridad.cUltimaOperacion
        lcUsuarioLogueado = goServicios.Seguridad.cUsuarioLogueado
		goServicios.Seguridad.cUltimaOperacion = ""
		goServicios.Seguridad.cUsuarioLogueado = ""

		ReestablecerIdentidadDeLaTabladeRegistroTerminal()
		
		loApp = _Screen.zoo.crearobjeto( "AplicacionBase" )
		loApp.NombreProducto = _screen.zoo.app.NombreProducto
		loApp.TipoDeBase = _screen.zoo.app.TipoDeBase		
		
		This.assertnotnull( "No se Instacio la Aplicacion", loApp )
		with loApp
			.lEstoyUsandoTimers = .T.
			 goregistry.Nucleo.UsarServicioRegistroTerminal = .F.
			.iniciarregistroterminal()
			.release()
		endwith
		
		goServicios.Datos.EjecutarSentencias( "Select * From RegistroTerminal", "RegistroTerminal", _Screen.zoo.App.cRutaTablasOrganizacion, "RTerminal", set( "Datasession" ) )
		This.AssertEquals( "No se tendría que haber generado ningun registro", 0, reccount("RTerminal"))
		use in select( "RTerminal" )
		
		loApp = _Screen.zoo.crearobjeto( "AplicacionBase" )
		loApp.NombreProducto = _screen.zoo.app.NombreProducto
		loApp.TipoDeBase = _screen.zoo.app.TipoDeBase
		
		This.assertnotnull( "No se Instacio la Aplicacion", loApp )
		with loApp
			.lEstoyUsandoTimers = .T.
			 goregistry.Nucleo.UsarServicioRegistroTerminal = .T.
			.iniciarregistroterminal()
			.release()
		endwith
		
		goServicios.Datos.EjecutarSentencias( "Select * From RegistroTerminal", "RegistroTerminal", _Screen.zoo.App.cRutaTablasOrganizacion, "RTerminal", set( "Datasession" ) )
		This.AssertEquals( "Tendría que haber generado ningun registro", 1, reccount("RTerminal"))
		use in select( "RTerminal" )
		
        goServicios.Seguridad.cUltimaOperacion = lcUltimaOperacion
        goServicios.Seguridad.cUsuarioLogueado = lcUsuarioLogueado
	Endfunc	
		
	*-----------------------------------------------------------------------------------------
	function zTestVerificarPedidoDeCierre
		local loTerminal as TerminalFake of ztestRegistroTerminal.prg, loBkpppp as mensajes of mensajes.prg

		_screen.mocks.agregarmock( "Mensajes" )
		loBkpppp = goServicios.Mensajes
		goServicios.Mensajes = _screen.zoo.crearobjeto( "Mensajes" )

		goRegistry.Nucleo.TiempoDeEsperaParaCerrarAplicacion = 1

		ReestablecerIdentidadDeLaTabladeRegistroTerminal()		
		
		try
			
			loTerminal = Newobject( "TerminalFake", "ztestRegistroTerminal.prg" )
			loTerminal.Registrar()
			loTerminal.VerificarPedidoDeCierre_AUX()
			
			this.asserttrue( "No se debió llamar al mensaje de cierre", !loTerminal.lPasoPorSalir )
			This.asserttrue( "Paso por el metodo InicializarTimer.", !loTerminal.lPasoPorInicializarTimerDeCierre ) 

			goServicios.Datos.EjecutarSentencias( "Update RegistroTerminal Set Accion = 'Finalizar proceso'" , "RegistroTerminal", _Screen.zoo.App.cRutaTablasOrganizacion )
			*** Fuerza la salida. Sin Formulario abierto.
			
			_screen.mocks.AgregarSeteoMetodoEnCola( 'MENSAJES', 'Alertar', 2, "[La aplicación se cerrará por pedido del administrador en <N> segundos.Presione Aceptar para salir ahora.],0,.F.,.F.,1" )
			loTerminal.VerificarPedidoDeCierre_AUX()

			this.asserttrue( "Se debió llamar al mensaje de cierre.1", loTerminal.lPasoPorSalir )
			This.asserttrue( "Paso por el metodo InicializarTimer.1", !loTerminal.lPasoPorInicializarTimerDeCierre ) 

			*** Solicita la salida. Sin Formulario abierto.
			goServicios.Datos.EjecutarSentencias( "Update RegistroTerminal Set Accion = 'Solicitar salida'" , "RegistroTerminal", _Screen.zoo.App.cRutaTablasOrganizacion )
			loTerminal.lPasoPorSalir = .f.

			_screen.mocks.AgregarSeteoMetodoEnCola( 'MENSAJES', 'Alertar', 2, "[La aplicación se cerrará por pedido del administrador en <N> segundos.Presione Aceptar para salir ahora.],0,.F.,.F.,1" )
			loTerminal.VerificarPedidoDeCierre_AUX()

			this.asserttrue( "No se debió llamar al mensaje de cierre.2", loTerminal.lPasoPorSalir )
			This.asserttrue( "Paso por el metodo InicializarTimer.2", !loTerminal.lPasoPorInicializarTimerDeCierre ) 


			*** Solicita la salida. Con Formulario abierto y No Pospone
			goServicios.Datos.EjecutarSentencias( "Update RegistroTerminal Set Accion = 'Solicitar salida'" , "RegistroTerminal", _Screen.zoo.App.cRutaTablasOrganizacion )
					
			_screen.mocks.AgregarSeteoMetodo( 'MENSAJES', 'Advertir', 1, "[La aplicación se cerrará por pedido del administrador en <N> segundos.¿Desea posponer el cierre?],6,.F.,.F.,1" )
			loTerminal.lRetornoExisteFormularioEnEdicion = .t.
			loTerminal.lPasoPorSalir = .f.
			
			loTerminal.VerificarPedidoDeCierre_AUX()

			this.asserttrue( "No se debió llamar al mensaje de cierre.3", loTerminal.lPasoPorSalir )
			This.asserttrue( "Paso por el metodo InicializarTimer.3", !loTerminal.lPasoPorInicializarTimerDeCierre ) 

			*** Solicita la salida. Con Formulario abierto y Pospone
			goServicios.Datos.EjecutarSentencias( "Update RegistroTerminal Set Accion = 'Solicitar salida'" , "RegistroTerminal", _Screen.zoo.App.cRutaTablasOrganizacion )

			_screen.mocks.AgregarSeteoMetodo( 'MENSAJES', 'Advertir', 2, "[La aplicación se cerrará por pedido del administrador en <N> segundos.¿Desea posponer el cierre?],6,.F.,.F.,1" )
			loTerminal.lRetornoExisteFormularioEnEdicion = .t.
			loTerminal.lPasoPorSalir = .f.
			loTerminal.VerificarPedidoDeCierre_AUX()

			this.asserttrue( "No se debió llamar al mensaje de cierre.4", !loTerminal.lPasoPorSalir )
			This.asserttrue( "Paso por el metodo InicializarTimer.4", loTerminal.lPasoPorInicializarTimerDeCierre ) 

			
			ReestablecerIdentidadDeLaTabladeRegistroTerminal()
		
		catch to loError
			throw loError
		finally
			_Screen.mocks.vaciar()
			goServicios.Mensajes = null
			goServicios.Mensajes = loBkpppp
			goMensajes = loBkpppp
		endtry
		loTerminal.Detener()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestIniciarRegistroTerminal
		local loTerminal as terminal of terminal.prg
		
		ReestablecerIdentidadDeLaTabladeRegistroTerminal()
		
		loTerminal = _Screen.zoo.crearobjeto( "Terminal" )
		loTerminal.Registrar()
		goServicios.Datos.EjecutarSentencias( "Select * From RegistroTerminal", "RegistroTerminal", _Screen.zoo.App.cRutaTablasOrganizacion, "RTerminal", set( "Datasession" ) )
		
		select RTerminal
		if reccount( "RTerminal" ) == 1
			this.assertequals( 'No se seteo  el campo usuario', goServicios.seguridad.cUsuariologueado, alltrim( RTerminal.usuario) )
			this.assertequals( 'No se seteo el campo Bdatos', upper( _screen.zoo.app.csuCURSALACTIVA ), upper( alltrim( RTerminal.bdatos) ) )
			
			this.assertequals( 'No se seteo  el campo serie', _Screen.zoo.app.cSerie, alltrim( RTerminal.serie) )
			this.assertequals( 'No se seteo  el campo version', _Screen.zoo.app.ObtenerVersion(), alltrim( RTerminal.version) )
			this.assertequals( 'No se seteo  el campo conectado correctamente.', .t., RTerminal.conectado )
		else
			this.asserttrue( 'Error al registrar terminal', .f. )
		endif 
		
		use in select( 'RTerminal' )
		loTerminal.Desregistrar()
		loTerminal.Detener()	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestIniciarRegistroTerminalConDosTerminales
		local loTerminal1 as terminal of terminal.prg, loTerminal2 as terminal of terminal.prg
		
		ReestablecerIdentidadDeLaTabladeRegistroTerminal()
				
		loTerminal1 = _Screen.zoo.crearobjeto( "Terminal" )
		loTerminal1.Registrar()
		loTerminal2 = _Screen.zoo.crearobjeto( "Terminal" )
		loTerminal2.Registrar()
		
		
		this.assertequals( "id incorrecto 1.", 1, loTerminal1.nIdSesion )
		this.assertequals( "id incorrecto 2.", 2, loTerminal2.nIdSesion )
		goServicios.Datos.EjecutarSentencias( "Select * From RegistroTerminal", "RegistroTerminal", _Screen.zoo.App.cRutaTablasOrganizacion, "RTerminal", set( "Datasession" ) )
		select RTerminal
		if reccount( "RTerminal" ) == 2
			go top
			this.assertequals( 'No se seteo  el campo conectado correctamente terminal 1.1', .t., RTerminal.conectado )

			skip
			this.assertequals( 'No se seteo  el campo conectado correctamente terminal 2.1', .t., RTerminal.conectado )
		else
			this.asserttrue( 'Error al registrar terminal', .f. )
		endif 
	

		loTerminal1.Desregistrar()
		this.assertequals( "id incorrecto 1.2", 0, loTerminal1.nIdSesion )
		this.assertequals( "id incorrecto 2.2", 2, loTerminal2.nIdSesion )		
		
		goServicios.Datos.EjecutarSentencias( "Select * From RegistroTerminal", "RegistroTerminal", _Screen.zoo.App.cRutaTablasOrganizacion, "RTerminal", set( "Datasession" ) )
		select RTerminal
		if reccount( "RTerminal" ) == 2
			go top
			this.assertequals( 'No se seteo  el campo conectado correctamente terminal 1.2', iif( RTerminal.Sesion==1, .f., .t. ), RTerminal.conectado )

			skip
			this.assertequals( 'No se seteo  el campo conectado correctamente terminal 2.2', iif( RTerminal.Sesion==2, .t., .f. ), RTerminal.conectado )
		else
			this.asserttrue( 'Error al registrar terminal', .f. )
		endif 		


		loTerminal2.Desregistrar()
		this.assertequals( "id incorrecto 1.3", 0, loTerminal1.nIdSesion )
		this.assertequals( "id incorrecto 2.3", 0, loTerminal2.nIdSesion )		
		goServicios.Datos.EjecutarSentencias( "Select * From RegistroTerminal", "RegistroTerminal", _Screen.zoo.App.cRutaTablasOrganizacion, "RTerminal", set( "Datasession" ) )
		select RTerminal
		if reccount( "RTerminal" ) == 2
			go top
			this.assertequals( 'No se seteo  el campo conectado correctamente terminal 1.3', .f., RTerminal.conectado )

			skip
			this.assertequals( 'No se seteo  el campo conectado correctamente terminal 2.3', .f., RTerminal.conectado )
		else
			this.asserttrue( 'Error al registrar terminal', .f. )
		endif 	
				
		use in select( "RTerminal" )		
		
		loTerminal1.Detener()
		loTerminal2.Detener()
	endfunc 
	
		
	*-----------------------------------------------------------------------------------------
	function zTestDesloguearUsuario
		local loTerminal as terminal of terminal.prg
		
		ReestablecerIdentidadDeLaTabladeRegistroTerminal()
		
		loTerminal = _Screen.zoo.crearobjeto( "Terminal" )
		loTerminal.Registrar()
		loTerminal.Logout()
		goServicios.Datos.EjecutarSentencias( "Select * From RegistroTerminal", "RegistroTerminal", _Screen.zoo.App.cRutaTablasOrganizacion, "RTerminal", set( "Datasession" ) )
		
		select RTerminal
		if reccount( "RTerminal" ) == 1
			this.assertequals( 'No se blanqueo el campo usuario al ejecutar Logout', "", alltrim( RTerminal.usuario))
			this.assertequals( 'No se blanqueo el campo Bdatos al ejecutar Logout', "", alltrim( RTerminal.bdatos) )
			this.assertequals( "La terminal al reallizar el logout debe quedar conectado.", .t., RTerminal.conectado )			
			this.assertequals( 'No se seteo  el campo Operacion correctamente.', "Cerrar sesión (VA:", left( RTerminal.UltoPer, 18 ) )			
		else
			this.asserttrue( 'Error al registrar terminal', .f. )
		endif 
		
		use in select( 'RTerminal' )
		loTerminal.Desregistrar()
		loTerminal.Detener()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestRegistrarNoReutilizandoIdDeSession
		local loTerminal as terminal of terminal.prg, lnSesion as Integer, lnSesion2 as Integer

		
		ReestablecerIdentidadDeLaTabladeRegistroTerminal()
		
		loTerminal = _Screen.zoo.crearobjeto( "Terminal" )
		loTerminal.Registrar()
		lnSesion = loTerminal.nIdSesion
		this.assertequals( "El id de sesion es incorrecto (primer sesion).", 1, loTerminal.nIdSesion )

		loTerminal.DesRegistrar()
		this.assertequals( "El id de sesion es incorrecto (despues desregistrar).", 0, loTerminal.nIdSesion )
		
		loTerminal.Registrar()
		lnSesion2 = loTerminal.nIdSesion
		this.assertequals( "El id de sesion es incorrecto (segunda sesion).", 2, loTerminal.nIdSesion )
		
		goServicios.Datos.EjecutarSentencias( "Select * From RegistroTerminal where sesion = " +  transform( lnSesion2 ), "RegistroTerminal", _Screen.zoo.App.cRutaTablasOrganizacion, "RTerminal", set( "Datasession" ) )
		
		select RTerminal
		if reccount( "RTerminal" ) == 1
			this.assertequals( 'No se seteo  el campo usuario', goServicios.seguridad.cUsuariologueado, alltrim( RTerminal.usuario) )
			this.assertequals( 'No se seteo el campo Bdatos', upper( _screen.zoo.app.csuCURSALACTIVA ), upper( alltrim( RTerminal.bdatos) ) )
			
			this.assertequals( 'No se seteo  el campo serie', _Screen.zoo.app.cSerie, alltrim( RTerminal.serie) )
			this.assertequals( 'No se seteo  el campo version', _Screen.zoo.app.ObtenerVersion(), alltrim( RTerminal.version) )
			this.assertequals( 'No se seteo  el campo conectado correctamente.', .t., RTerminal.conectado )
		else
			this.asserttrue( 'Error al registrar terminal', .f. )
		endif 
		
		use in select( 'RTerminal' )
		loTerminal.Desregistrar()
		loTerminal.Detener()	
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestRegistrarConScriptOrganicCargado
		local loTerminal as terminal of terminal.prg, lnSesion as Integer
		
		ReestablecerIdentidadDeLaTabladeRegistroTerminal()
		
		loTerminal = _Screen.zoo.crearobjeto( "Terminal" )
		goServicios.Ejecucion.lScriptCargado = .t.
		loTerminal.Registrar()
		this.assertequals( "El id de sesion es incorrecto 1.", 0, loTerminal.nIdSesion )
		
		loTerminal.reportar()
		this.assertequals( "El id de sesion es incorrecto 2.", 0, loTerminal.nIdSesion )
		
		goServicios.Datos.EjecutarSentencias( "Select * From RegistroTerminal", "RegistroTerminal", _Screen.zoo.App.cRutaTablasOrganizacion, "RTerminal", set( "Datasession" ) )
		this.assertequals( 'Error al registrar terminal', 0, reccount( "RTerminal" ) )
		
		use in select( 'RTerminal' )
		loTerminal.Desregistrar()
		loTerminal.Detener()
	endfunc 	

	*-----------------------------------------------------------------------------------------
	function zTestLimpiarTablaRegistroTerminal
		local loTerminal as terminal of terminal.prg, loTermina2 as terminal of terminal.prg
		
		ReestablecerIdentidadDeLaTabladeRegistroTerminal()
		loTerminal = _Screen.zoo.crearobjeto( "Terminal" )
		loTermina2 = _Screen.zoo.crearobjeto( "Terminal" )
		loTerminal.Registrar()
		loTermina2.Registrar()
		
		goServicios.Datos.EjecutarSentencias( "update RegistroTerminal set tultrep = date()-3 where sesion =" + transform( loTerminal.nIdSesion ), "RegistroTerminal", _Screen.zoo.App.cRutaTablasOrganizacion )		
		goServicios.Datos.EjecutarSentencias( "update RegistroTerminal set tultrep = date()+3 where sesion =" + transform( loTermina2.nIdSesion ), "RegistroTerminal", _Screen.zoo.App.cRutaTablasOrganizacion )		
		
		goServicios.Datos.EjecutarSentencias( "Select * From RegistroTerminal", "RegistroTerminal", _Screen.zoo.App.cRutaTablasOrganizacion, "RTerminal", set( "Datasession" ) )
		this.assertequals( 'Error 1', 2, reccount( "RTerminal" ) )
		go top
		this.assertequals( 'Error 2', .t., RTerminal.Conectado )
		skip
		this.assertequals( 'Error 3', .t., RTerminal.Conectado )
				
		loTerminal.LimpiarTablaRegistroTerminal()
		
		goServicios.Datos.EjecutarSentencias( "Select * From RegistroTerminal", "RegistroTerminal", _Screen.zoo.App.cRutaTablasOrganizacion, "RTerminal", set( "Datasession" ) )
		this.assertequals( 'Error 4', 2, reccount( "RTerminal" ) )
		go top
		this.assertequals( 'Error 5', iif( RTerminal.Sesion == loTerminal.nIdSesion, .f., .t. ), RTerminal.Conectado )
		skip
		this.assertequals( 'Error 6', iif( RTerminal.Sesion == loTermina2.nIdSesion, .t., .f. ), RTerminal.Conectado ) 
				
		use in select( 'RTerminal' )
		loTerminal.Desregistrar()
		loTerminal.Detener()
		loTermina2.Desregistrar()
		loTermina2.Detener()
	endfunc


	*-----------------------------------------------------------------------------------------
	function zTestReportarTerminal
		local loTerminal as terminal of terminal.prg
		
		ReestablecerIdentidadDeLaTabladeRegistroTerminal()
		
		loTerminal = _Screen.zoo.crearobjeto( "Terminal" )
		loTerminal.Registrar()
		goServicios.Datos.EjecutarSentencias( "Select * From RegistroTerminal", "RegistroTerminal", _Screen.zoo.App.cRutaTablasOrganizacion, "RTerminal", set( "Datasession" ) )
		
		select RTerminal
		if reccount( "RTerminal" ) == 1
			this.assertequals( 'No se seteo  el campo usuario', goServicios.seguridad.cUsuariologueado, alltrim( RTerminal.usuario) )
			this.assertequals( 'No se seteo el campo Bdatos', upper( _screen.zoo.app.csuCURSALACTIVA ), upper( alltrim( RTerminal.bdatos) ) )
			
			this.assertequals( 'No se seteo  el campo serie', _Screen.zoo.app.cSerie, alltrim( RTerminal.serie) )
			this.assertequals( 'No se seteo  el campo version', _Screen.zoo.app.ObtenerVersion(), alltrim( RTerminal.version) )
			this.assertequals( 'No se seteo  el campo conectado correctamente.', .t., RTerminal.conectado )
			
			this.assertequals( 'No se seteo  el campo Operacion correctamente.', "Sin actividad (VA:", left( RTerminal.UltoPer, 18 ) )			
		else
			this.asserttrue( 'Error al registrar terminal', .f. )
		endif 
		
		goServicios.Seguridad.cUltimaOperacion = "test"
		loTerminal.Reportar()
		goServicios.Datos.EjecutarSentencias( "Select * From RegistroTerminal", "RegistroTerminal", _Screen.zoo.App.cRutaTablasOrganizacion, "RTerminal", set( "Datasession" ) )
		
		select RTerminal
		if reccount( "RTerminal" ) == 1
			this.assertequals( 'No se seteo  el campo usuario', goServicios.seguridad.cUsuariologueado, alltrim( RTerminal.usuario) )
			this.assertequals( 'No se seteo el campo Bdatos', upper( _screen.zoo.app.csuCURSALACTIVA ), upper( alltrim( RTerminal.bdatos) ) )
			
			this.assertequals( 'No se seteo  el campo serie', _Screen.zoo.app.cSerie, alltrim( RTerminal.serie) )
			this.assertequals( 'No se seteo  el campo version', _Screen.zoo.app.ObtenerVersion(), alltrim( RTerminal.version) )
			this.assertequals( 'No se seteo  el campo conectado correctamente.', .t., RTerminal.conectado )
			
			this.assertequals( 'No se seteo  el campo Operacion correctamente.', "test (VA:", left( RTerminal.UltoPer, 9 ) )			
		else
			this.asserttrue( 'Error al registrar terminal', .f. )
		endif 

		use in select( 'RTerminal' )
		loTerminal.Desregistrar()
		loTerminal.Detener()	
	endfunc 	

		
enddefine

*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------

define class TerminalFake as Terminal of Terminal.prg

	lRetornoExisteFormularioEnEdicion = .f.
	lPasoPorInicializarTimerDeCierre = .f.
	lEntroInicializarTimerReportarTerminal = .f.
	lEntroPorRegistrarTerminal = .f.
	lPasoPorSalir = .f.
	
	*-----------------------------------------------------------------------------------------
	function InicializarTimerDeCierre() as Void
		This.lPasoPorInicializarTimerDeCierre = .t.
		return dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ExisteformularioEnEdicion() as Boolean
		return This.lRetornoExisteFormularioEnEdicion
	endfunc 

	*-----------------------------------------------------------------------------------------
	function VerificarPedidoDeCierre_AUX() as Void
		this.VerificarPedidoDeCierre()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerNumeroSesion_aux() as Void
		return this.ObtenerNumeroSesion()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function InicializarTimerReportar() as Void
		this.lEntroInicializarTimerReportarTerminal = .T.
		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Registrar() as Void
		this.lEntroPorRegistrarTerminal = .T.
		dodefault()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function SalirDelSistema() as Void
		this.lPasoPorSalir = .t.
	endfunc 
	
enddefine

*-----------------------------------------------------------------------------------------
function ReestablecerIdentidadDeLaTabladeRegistroTerminal() as Void
	goServicios.Datos.EjecutarSentencias( "Delete From RegistroTerminal ", "RegistroTerminal", _Screen.zoo.App.cRutaTablasOrganizacion )
	if goServicios.Datos.EsSqlServer()
		goServicios.Datos.EjecutarSentencias( "DBCC CHECKIDENT ('" + _screen.zoo.app.cBdMaster + "." + goServicios.Estructura.ObtenerEsquema( "RegistroTerminal" ) + ".RegistroTerminal', RESEED, 0)", "", "" )
	else
		use in select( "RegistroTerminal" )
		use ( addbs( _Screen.zoo.App.cRutaTablasOrganizacion ) + "RegistroTerminal" ) exclusive
		ALTER TABLE RegistroTerminal ALTER COLUMN Sesion I autoinc nextvalue 1
		use in select( "RegistroTerminal" )			
	endif
endfunc 