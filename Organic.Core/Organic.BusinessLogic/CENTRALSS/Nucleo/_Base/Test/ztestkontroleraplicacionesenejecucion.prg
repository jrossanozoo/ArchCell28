**********************************************************************
Define Class zTestKontrolerAplicacionesEnEjecucion as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as zTestKontrolerAplicacionesEnEjecucion of zTestKontrolerAplicacionesEnEjecucion.prg
	#ENDIF
	
	*---------------------------------
	Function Setup
		goServicios.Datos.EjecutarSentencias( "Delete From RegistroTerminal ", "RegistroTerminal", _Screen.zoo.App.cRutaTablasOrganizacion )
		if goServicios.Datos.EsSqlServer()
			goServicios.Datos.EjecutarSql( "DBCC CHECKIDENT ('" + _screen.zoo.app.cBDMaster + "." + goServicios.Estructura.ObtenerEsquema( "registroTerminal" ) + ".RegistroTerminal', RESEED, 1)" )
		else
			use in select( "RegistroTerminal" )
			use ( addbs( _Screen.zoo.App.cRutaTablasOrganizacion ) + "RegistroTerminal" ) exclusive
			ALTER TABLE RegistroTerminal ALTER COLUMN Sesion I autoinc nextvalue 1
			use in select( "RegistroTerminal" )			
		EndIf
	endfunc
		*-----------------------------------------------------------------------------------------
	function TearDown
	
		goServicios.Datos.EjecutarSentencias( "Delete From RegistroTerminal ", "RegistroTerminal", _Screen.zoo.App.cRutaTablasOrganizacion )
		if goServicios.Datos.EsSqlServer()
			goServicios.Datos.EjecutarSql( "DBCC CHECKIDENT ('" + _screen.zoo.app.cBDMaster + "." + goServicios.Estructura.ObtenerEsquema( "registroTerminal" ) + ".RegistroTerminal', RESEED, 1)" )
		else
			use in select( "RegistroTerminal" )
			use ( addbs( _Screen.zoo.App.cRutaTablasOrganizacion ) + "RegistroTerminal" ) exclusive
			ALTER TABLE RegistroTerminal ALTER COLUMN Sesion I autoinc nextvalue 1
			use in select( "RegistroTerminal" )			
		EndIf

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestAplicarAccion
		local loForm as Form, loTerminal1 as terminal of terminal.prg, loTerminal2 as terminal of terminal.prg
		
		loForm = newobject( "Form" )
		loForm.AddObject( "grd_terminal", "grid" )
		loForm.NewObject( "oKontroler", 'kontroleraplicacionesenejecucion','kontroleraplicacionesenejecucion.prg' )

		loTerminal1 = _screen.zoo.crearobjeto( "Terminal" )
		loTerminal2 = _screen.zoo.crearobjeto( "Terminal" )
		
		loTerminal1.registrar()
		loTerminal2.registrar()

		loForm.oKontroler.AbrirTablaRegistroTerminal()
		loForm.oKontroler.AbrirTablaAccionesAplicaciones()

		loForm.oKontroler.AplicarAccionSolicitarSalida()
		goServicios.Datos.EjecutarSentencias( "Select * From RegistroTerminal ", "RegistroTerminal", _Screen.zoo.App.cRutaTablasOrganizacion, "RTerminal", set( "Datasession" ) )		
		this.assertequals( "No se actualizo corectamente la tabla de registros (1)", 'solicitar salida', lower( alltrim( RTerminal.accion) ) )
		use in select( "RTerminal" )

		loForm.oKontroler.AplicarAccionFinalizarProceso()
		goServicios.Datos.EjecutarSentencias( "Select * From RegistroTerminal ", "RegistroTerminal", _Screen.zoo.App.cRutaTablasOrganizacion, "RTerminal", set( "Datasession" ) )		
		this.assertequals( "No se actualizo corectamente la tabla de registros (2)", 'finalizar proceso', lower( alltrim( RTerminal.accion) ) )
		use in select( "RTerminal" )

		loForm.oKontroler.BorrarAccion()
		goServicios.Datos.EjecutarSentencias( "Select * From RegistroTerminal ", "RegistroTerminal", _Screen.zoo.App.cRutaTablasOrganizacion, "RTerminal", set( "Datasession" ) )
		this.asserttrue( "No se actualizo corectamente la tabla de registros (3)", empty( RTerminal.accion) )
		use in select( "RTerminal" )

		loForm.oKontroler.AplicarAccionSolicitarSalidaTodos()
		goServicios.Datos.EjecutarSentencias( "Select * From RegistroTerminal ", "RegistroTerminal", _Screen.zoo.App.cRutaTablasOrganizacion, "RTerminal", set( "Datasession" ) )		
		go top in RTerminal
		this.assertequals( "No se actualizo corectamente la tabla de registros (4)", 'solicitar salida', lower( alltrim( RTerminal.accion) ) )
		skip
		this.assertequals( "No se actualizo corectamente la tabla de registros (5)", 'solicitar salida', lower( alltrim( RTerminal.accion) ) )
		use in select( "RTerminal" )
		loForm.oKontroler.AplicarAccionFinalizarProcesoTodos()
		goServicios.Datos.EjecutarSentencias( "Select * From RegistroTerminal ", "RegistroTerminal", _Screen.zoo.App.cRutaTablasOrganizacion, "RTerminal", set( "Datasession" ) )		
		go top in RTerminal
		this.assertequals( "No se actualizo corectamente la tabla de registros (6)", 'finalizar proceso', lower( alltrim( RTerminal.accion) ) )
		skip
		this.assertequals( "No se actualizo corectamente la tabla de registros (7)", 'finalizar proceso', lower( alltrim( RTerminal.accion) ) )				
		use in select( "RTerminal" )
		loForm.oKontroler.BorrarAccionTodos()
		goServicios.Datos.EjecutarSentencias( "Select * From RegistroTerminal ", "RegistroTerminal", _Screen.zoo.App.cRutaTablasOrganizacion, "RTerminal", set( "Datasession" ) )		
		go top in RTerminal
		this.asserttrue( "No se actualizo corectamente la tabla de registros (8)", empty( RTerminal.accion) )
		skip
		this.asserttrue( "No se actualizo corectamente la tabla de registros (9)", empty( RTerminal.accion) )
		use in select( "RTerminal" )
		
		loForm.oKontroler.Salir()
		loForm.oKontroler.release()
		loForm.Release()
		loTerminal1.detener()
		loTerminal2.detener()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestIngresoAlSistema
		local loKontroler as Object, lcEntidad As String
 
 		_screen.mocks.agregarmock( "Mensajes" )
 		_screen.mocks.AgregarSeteoMetodo( 'MENSAJES', 'Enviar', 1, "'¿Confirma deshabilitar el ingreso? IMPORTANTE: Ningún usuario podrá ingresar al sistema.',1,1,1" )
		_screen.mocks.AgregarSeteoMetodo( 'MENSAJES', 'Enviar', 1, "'¿Confirma habilitar el ingreso? IMPORTANTE: Todos los usuarios podrán ingresar al sistema.',1,1,1" )
		loKontroler = newobject( 'kontroleraplicacionesenejecucion','kontroleraplicacionesenejecucion.prg')
		with loKontroler
			.oDatos = _screen.zoo.crearObjeto ( 'ServicioDatos' )
			.oDatos.DataSessionId = set( "Datasession" )
			.oDatos.oAccesoDatos.DataSessionId = set( "Datasession" )
			.oMensajes = _screen.zoo.crearObjeto ( 'Mensajes' )

			goServicios.Datos.EjecutarSentencias( "Delete from AccionesAplicaciones ", "AccionesAplicaciones", _Screen.zoo.App.cRutaTablasORganizacion )
			.AbrirTablaAccionesAplicaciones()
			.ControlarAccesos(.T.)
			this.asserttrue( "No se actualizo la variable lBloqueado 1", !loKontroler.lBloqueado)
			.ControlarAccesos( .f. )
			this.asserttrue( "No se actualizo la variable lBloqueado 2", loKontroler.lBloqueado)

			.AbrirTablaAccionesAplicaciones()
			go top
			this.assertequals( "No se genero el registro correctamente 1", "NUCLEO", upper( alltrim(xx1) ) )
			this.assertequals( "No se genero el registro correctamente 2", "INGRESODENEGADO", upper( alltrim(xx2) ) )
			use in select( .cCursorAcciones )
			.ControlarAccesos(.T.)
			this.asserttrue( "No se actualizo la variable lBloqueado 11", loKontroler.lBloqueado)
			.ControlarAccesos( .f. )
			this.asserttrue( "No se actualizo la variable lBloqueado 22", !loKontroler.lBloqueado)
			use in select( .cCursorAcciones )
			.AbrirTablaAccionesAplicaciones()
			this.assertequals( "No se elimino el registro correctamente", 0, Reccount ( .cCursorAcciones ) )
			use in select( .cCursorAcciones )
			.Salir()
			.release()
		endwith
		
	endfunc 


	*-----------------------------------------------------------------------------------------
	function zTestControlTimeOutRegistroTerminal
		local lcRutaTabla as String, lcCursor as String, loKontroler as Object, lnTimeOut as Number, ;
				lnMinutosRegistroTerminal as Number, ltTime as Datetime, loTerminal as terminal of terminal.prg
				

		lnMinutosRegistroTerminal = goregistry.nucleo.MinutosRegistroTerminal / 1000
		lnTimeOut = goregistry.nucleo.timeoutdesconectarterminal
		loKontroler = newobject( 'kontroleraplicacionesenejecucion','kontroleraplicacionesenejecucion.prg')
		loKontroler.dFechaActualizacion = datetime()
		ltTime = loKontroler.dFechaActualizacion - lnMinutosRegistroTerminal - lnTimeOut - 1
		loTerminal = _screen.zoo.crearobjeto( "Terminal" )
		loTerminal.Registrar()
		goServicios.Datos.EjecutarSentencias( "Update RegistroTerminal Set Terminal = 'term1', usrRed = 'test1', tUltRep = ctot( '" + ttoc( ltTIme ) + "' ) , conectado = .f.", "RegistroTerminal", _Screen.zoo.App.cRutaTablasORganizacion )
			
		loKontroler.ControlTimeOutRegistroTerminal()
		goServicios.Datos.EjecutarSentencias( "Select * From RegistroTerminal", "RegistroTerminal", _Screen.zoo.App.cRutaTablasORganizacion, "RTerminal", set( "Datasession" ) )
		this.asserttrue( "No se actualizo la variable conectado 1", !RTerminal.conectado )
		use in select( "RTerminal" )
		goServicios.Datos.EjecutarSentencias( "Update RegistroTerminal Set conectado = .T.", "RegistroTerminal", _Screen.zoo.App.cRutaTablasORganizacion )
		loKontroler.ControlTimeOutRegistroTerminal()
		goServicios.Datos.EjecutarSentencias( "Select * From RegistroTerminal", "RegistroTerminal", _Screen.zoo.App.cRutaTablasORganizacion, "RTerminal", set( "Datasession" ) )
		this.asserttrue( "No se actualizo la variable conectado 2", !RTerminal.conectado )
		use in select( "RTerminal" )
		ltTime = loKontroler.dFechaActualizacion - lnMinutosRegistroTerminal - lnTimeOut
		goServicios.Datos.EjecutarSentencias( "Update RegistroTerminal Set tUltRep = ctot( '" + ttoc( ltTIme ) + "' ) , conectado = .f.", "RegistroTerminal", _Screen.zoo.App.cRutaTablasORganizacion )
		loKontroler.ControlTimeOutRegistroTerminal()
		goServicios.Datos.EjecutarSentencias( "Select * From RegistroTerminal", "RegistroTerminal", _Screen.zoo.App.cRutaTablasORganizacion, "RTerminal", set( "Datasession" ) )
		this.asserttrue( "No se actualizo la variable conectado 3", !RTerminal.conectado )
		use in select( "RTerminal" )
		goServicios.Datos.EjecutarSentencias( "Update RegistroTerminal Set conectado = .T.", "RegistroTerminal", _Screen.zoo.App.cRutaTablasORganizacion )
		loKontroler.ControlTimeOutRegistroTerminal()
		goServicios.Datos.EjecutarSentencias( "Select * From RegistroTerminal", "RegistroTerminal", _Screen.zoo.App.cRutaTablasORganizacion, "RTerminal", set( "Datasession" ) )
		this.asserttrue( "No se actualizo la variable conectado 4", !RTerminal.conectado )
		use in select( "RTerminal" )
		ltTime = loKontroler.dFechaActualizacion - lnMinutosRegistroTerminal -  ( lnTimeOut - 20 )
		goServicios.Datos.EjecutarSentencias( "Update RegistroTerminal Set tUltRep = ctot( '" + ttoc( ltTIme ) + "' ) , conectado = .f.", "RegistroTerminal", _Screen.zoo.App.cRutaTablasORganizacion )
		loKontroler.ControlTimeOutRegistroTerminal()
		goServicios.Datos.EjecutarSentencias( "Select * From RegistroTerminal", "RegistroTerminal", _Screen.zoo.App.cRutaTablasORganizacion, "RTerminal", set( "Datasession" ) )
		this.asserttrue( "Se actualizo la variable conectado 1", !RTerminal.conectado )
		use in select( "RTerminal" )
		goServicios.Datos.EjecutarSentencias( "Update RegistroTerminal Set conectado = .T.", "RegistroTerminal", _Screen.zoo.App.cRutaTablasORganizacion )
		loKontroler.ControlTimeOutRegistroTerminal()
		goServicios.Datos.EjecutarSentencias( "Select * From RegistroTerminal", "RegistroTerminal", _Screen.zoo.App.cRutaTablasORganizacion, "RTerminal", set( "Datasession" ) )
		this.asserttrue( "Se actualizo la variable conectado 2", RTerminal.conectado )
		use in select( "RTerminal" )
		loKontroler.Salir()
		loKontroler.release()
		loTerminal.Detener()

	endfunc 
EndDefine
