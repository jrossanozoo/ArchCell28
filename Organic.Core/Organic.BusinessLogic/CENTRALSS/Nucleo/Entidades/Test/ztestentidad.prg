**********************************************************************
define class zTestEntidad as FxuTestCase of FxuTestCase.prg

	#if .f.
		local this as zTestEntidad of zTestEntidad.prg
	#endif

	oEntidad = null
	cCodigo= ""
	cRutaPuesto = ""
	oLibrerias = null
	*-----------------------------------------------------------------------------------------
	function Setup
		this.cRutaPuesto = _Screen.zoo.app.cRutaTablasPuesto
		This.oLibrerias = goServicios.Librerias
	endfunc 

	*-----------------------------------------------------------------------------------------
	function tearDown
		_Screen.zoo.app.cRutaTablasPuesto = this.cRutaPuesto
		goServicios.Librerias = This.oLibrerias
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestInstanciar
		local loEntidad as entidad of entidad.prg
		
		loEntidad = newobject( "TestEntidadAbstracta" )
		
		this.assertequals( "No se instancio la entidad", "O", vartype( loEntidad ) )
		this.assertequals( "No se instancio la validacion de dominios", "O", vartype( loEntidad.oValidacionDominios ) )
		this.asserttrue( "No se encuentra el metodo SetearComponentes", pemstatus( loEntidad, "SetearComponentes", 5 ) )

		loEntidad.release()

	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestSQLServer_VerificarRegistroDeActividadAlGrabarComprobantesConExtencion
		local loEntidad as Din_EntidadBolivia as Din_EntidadBolivia.prg, lcADSFW as String
		goServicios.Registry.Nucleo.FechaDeHabilitacionDeTrazaExtendida = goServicios.Librerias.ObtenerFecha()
		goServicios.RegistroDeActividad.Detener()

		goServicios.Datos.EjecutarSentencias( "Delete from Bolivia", "Bolivia" )
		goServicios.Datos.EjecutarSentencias( "Delete from RegActiv", "RegActiv" )
		goServicios.RegistroDeActividad.lEstaHabilitado = .T.
		loEntidad = _Screen.zoo.instanciarentidad( "Bolivia" )
		loEntidad.Nuevo()
		loEntidad.Codigo = "1"
		loEntidad.Descripcion = "1"
		loEntidad.Grabar()
		goServicios.RegistroDeActividad.Detener()
		=goServicios.RegistroDeActividad

		goServicios.Datos.EjecutarSentencias( "Select * from RegActiv order by cActividad", "RegActiv", ,"c_Ver", set( "Datasession" ) )
		select c_Ver
		This.Assertequals( "No es correcta actividad 1", "AntesDeGrabar", alltrim( c_ver.cActividad ) )
		This.Assertequals( "No es correcta el Invocador 1", "Bolivia", alltrim( c_ver.Invocador ) )
		This.AssertTrue( "No es correcta el ZADSFW 1", "<PK:1>" $ alltrim( c_ver.ZADSFW ) )
		lcADSFW = alltrim( c_ver.ZADSFW )
		skip
		This.Assertequals( "No es correcta actividad 2", "DespuesDeGrabar", alltrim( c_ver.cActividad ) )
		This.Assertequals( "No es correcta el Invocador 2", "Bolivia", alltrim( c_ver.Invocador ) )
		This.Assertequals( "No es correcta el ZADSFW 2", lcADSFW, alltrim( c_ver.ZADSFW ) )
		skip
		This.Assertequals( "No es correcta actividad 3", "Grabar", alltrim( c_ver.cActividad ) )
		This.Assertequals( "No es correcta el Invocador 3", "Bolivia", alltrim( c_ver.Invocador ) )
		This.Assertequals( "No es correcta el ZADSFW 3", lcADSFW, alltrim( c_ver.ZADSFW ) )
		skip
		This.Assertequals( "No es correcta actividad 4", "oAD_Insertar", alltrim( c_ver.cActividad ) )
		This.Assertequals( "No es correcta el Invocador 4", "Bolivia", alltrim( c_ver.Invocador ) )
		This.Assertequals( "No es correcta el ZADSFW 4", lcADSFW, alltrim( c_ver.ZADSFW ) )
		skip
		This.Assertequals( "No es correcta actividad 5", "Validar", alltrim( c_ver.cActividad ) )
		This.Assertequals( "No es correcta el Invocador 5", "Bolivia", alltrim( c_ver.Invocador ) )
		This.Assertequals( "No es correcta el ZADSFW 5", lcADSFW, alltrim( c_ver.ZADSFW ) )
		
		use in select( "c_Ver" )
		goServicios.Datos.EjecutarSentencias( "Delete from RegActiv", "RegActiv" )
		goServicios.RegistroDeActividad.lEstaHabilitado = .T.
		loEntidad.Codigo = "1"
		loEntidad.Modificar()
		loEntidad.Grabar()
		goServicios.RegistroDeActividad.Detener()
		=goServicios.RegistroDeActividad
		goServicios.Datos.EjecutarSentencias( "Select * from RegActiv order by cActividad", "RegActiv", ,"c_Ver", set( "Datasession" ) )
		select c_Ver
		This.Assertequals( "No es correcta actividad 11", "AntesDeGrabar", alltrim( c_ver.cActividad ) )
		This.Assertequals( "No es correcta el Invocador 11", "Bolivia", alltrim( c_ver.Invocador ) )
		This.AssertTrue( "No es correcta el ZADSFW 11", "<PK:" + loEntidad.Codigo + ">" $ alltrim( c_ver.ZADSFW ) )
		lcADSFW = alltrim( c_ver.ZADSFW )
		skip
		This.Assertequals( "No es correcta actividad 12", "DespuesDeGrabar", alltrim( c_ver.cActividad ) )
		This.Assertequals( "No es correcta el Invocador 12", "Bolivia", alltrim( c_ver.Invocador ) )
		This.Assertequals( "No es correcta el ZADSFW 12", lcADSFW, alltrim( c_ver.ZADSFW ) )
		skip
		This.Assertequals( "No es correcta actividad 13", "Grabar", alltrim( c_ver.cActividad ) )
		This.Assertequals( "No es correcta el Invocador 13", "Bolivia", alltrim( c_ver.Invocador ) )
		This.Assertequals( "No es correcta el ZADSFW 13", lcADSFW, alltrim( c_ver.ZADSFW ) )
		skip
		This.Assertequals( "No es correcta actividad 14", "oAD_Actualizar", alltrim( c_ver.cActividad ) )
		This.Assertequals( "No es correcta el Invocador 14", "Bolivia", alltrim( c_ver.Invocador ) )
		This.Assertequals( "No es correcta el ZADSFW 14", lcADSFW, alltrim( c_ver.ZADSFW ) )
		skip
		This.Assertequals( "No es correcta actividad 15", "Validar", alltrim( c_ver.cActividad ) )
		This.Assertequals( "No es correcta el Invocador 15", "Bolivia", alltrim( c_ver.Invocador ) )
		This.Assertequals( "No es correcta el ZADSFW 15", lcADSFW, alltrim( c_ver.ZADSFW ) )
		
		use in select( "c_Ver" )


		loEntidad.Release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestI_VerificarRegistroDeActividadAlGrabarComprobantesSinExtencion
		local loEntidad as Din_EntidadBolivia as Din_EntidadBolivia.prg, lcADSFW as String
		goServicios.Registry.Nucleo.FechaDeHabilitacionDeTrazaExtendida = {}
		goServicios.RegistroDeActividad.Detener()

		goServicios.Datos.EjecutarSentencias( "Delete from Bolivia", "Bolivia" )
		goServicios.Datos.EjecutarSentencias( "Delete from RegActiv", "RegActiv" )
		goServicios.RegistroDeActividad.lEstaHabilitado = .T.
		loEntidad = _Screen.zoo.instanciarentidad( "Bolivia" )
		loEntidad.Nuevo()
		loEntidad.Codigo = "1"
		loEntidad.Descripcion = "1"
		loEntidad.Grabar()
		goServicios.RegistroDeActividad.Detener()
		=goServicios.RegistroDeActividad

		goServicios.Datos.EjecutarSentencias( "Select * from RegActiv order by cActividad", "RegActiv", ,"c_Ver", set( "Datasession" ) )
		select c_Ver
		This.Assertequals( "No es correcta actividad 3", "Grabar", alltrim( c_ver.cActividad ) )
		This.Assertequals( "No es correcta el Invocador 3", "Bolivia", alltrim( c_ver.Invocador ) )
		This.Assertequals( "No es correcta la cantidad de registros 3", 1, reccount( "c_Ver" ) )
		
		goServicios.Datos.EjecutarSentencias( "Delete from RegActiv", "RegActiv" )
		goServicios.RegistroDeActividad.lEstaHabilitado = .T.
		loEntidad.Codigo = "1"
		loEntidad.Modificar()
		loEntidad.Grabar()
		goServicios.RegistroDeActividad.Detener()
		=goServicios.RegistroDeActividad
		goServicios.Datos.EjecutarSentencias( "Select * from RegActiv order by cActividad", "RegActiv", ,"c_Ver", set( "Datasession" ) )
		select c_Ver
		This.Assertequals( "No es correcta actividad 13", "Grabar", alltrim( c_ver.cActividad ) )
		This.Assertequals( "No es correcta el Invocador 13", "Bolivia", alltrim( c_ver.Invocador ) )
		This.Assertequals( "No es correcta la cantidad de registros 13", 1, reccount( "c_Ver" ) )
		
		use in select( "c_Ver" )


		loEntidad.Release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestSQLServer_VerificarRegistroDeActividadAlGrabarEntidadConExtencion
		local loEntidad as Din_EntidadBolivia as Din_EntidadBolivia.prg, lcADSFW as String
		goServicios.Registry.Nucleo.FechaDeHabilitacionDeTrazaExtendida = goServicios.Librerias.ObtenerFecha()
		goServicios.RegistroDeActividad.Detener()

		goServicios.Datos.EjecutarSentencias( "Delete from Bulgaria", "Bulgaria" )
		goServicios.Datos.EjecutarSentencias( "Delete from RegActiv", "RegActiv" )
		goServicios.RegistroDeActividad.lEstaHabilitado = .T.
		loEntidad = NewObject( "BulgariaAux" )
		loEntidad.Nuevo()
		loEntidad.Codigo = "1"
		loEntidad.Descripcion = "1"
		loEntidad.Grabar()
		goServicios.RegistroDeActividad.Detener()
		=goServicios.RegistroDeActividad

		goServicios.Datos.EjecutarSentencias( "Select * from RegActiv order by cActividad", "RegActiv", ,"c_Ver", set( "Datasession" ) )
		select c_Ver
		This.Assertequals( "No es correcta actividad 1", "AntesDeGrabar", alltrim( c_ver.cActividad ) )
		This.Assertequals( "No es correcta el Invocador 1", "Bulgaria", alltrim( c_ver.Invocador ) )
		This.AssertTrue( "No es correcta el ZADSFW 1", "<PK:1>" $ alltrim( c_ver.ZADSFW ) )
		lcADSFW = alltrim( c_ver.ZADSFW )
		skip
		This.Assertequals( "No es correcta actividad 2", "DespuesDeGrabar", alltrim( c_ver.cActividad ) )
		This.Assertequals( "No es correcta el Invocador 2", "Bulgaria", alltrim( c_ver.Invocador ) )
		This.Assertequals( "No es correcta el ZADSFW 2", lcADSFW, alltrim( c_ver.ZADSFW ) )
		skip
		This.Assertequals( "No es correcta actividad 3", "Grabar", alltrim( c_ver.cActividad ) )
		This.Assertequals( "No es correcta el Invocador 3", "Bulgaria", alltrim( c_ver.Invocador ) )
		This.Assertequals( "No es correcta el ZADSFW 3", lcADSFW, alltrim( c_ver.ZADSFW ) )
		skip
		This.Assertequals( "No es correcta actividad 4", "oAD_Insertar", alltrim( c_ver.cActividad ) )
		This.Assertequals( "No es correcta el Invocador 4", "Bulgaria", alltrim( c_ver.Invocador ) )
		This.Assertequals( "No es correcta el ZADSFW 4", lcADSFW, alltrim( c_ver.ZADSFW ) )
		skip
		This.Assertequals( "No es correcta actividad 5", "Validar", alltrim( c_ver.cActividad ) )
		This.Assertequals( "No es correcta el Invocador 5", "Bulgaria", alltrim( c_ver.Invocador ) )
		This.Assertequals( "No es correcta el ZADSFW 5", lcADSFW, alltrim( c_ver.ZADSFW ) )
		
		use in select( "c_Ver" )
		goServicios.Datos.EjecutarSentencias( "Delete from RegActiv", "RegActiv" )
		goServicios.RegistroDeActividad.lEstaHabilitado = .T.
		loEntidad.Codigo = "1"
		loEntidad.Modificar()
		loEntidad.Grabar()
		goServicios.RegistroDeActividad.Detener()
		=goServicios.RegistroDeActividad
		goServicios.Datos.EjecutarSentencias( "Select * from RegActiv order by cActividad", "RegActiv", ,"c_Ver", set( "Datasession" ) )
		select c_Ver
		This.Assertequals( "No es correcta actividad 11", "AntesDeGrabar", alltrim( c_ver.cActividad ) )
		This.Assertequals( "No es correcta el Invocador 11", "Bulgaria", alltrim( c_ver.Invocador ) )
		This.AssertTrue( "No es correcta el ZADSFW 11", "<PK:" + loEntidad.Codigo + ">" $ alltrim( c_ver.ZADSFW ) )
		lcADSFW = alltrim( c_ver.ZADSFW )
		skip
		This.Assertequals( "No es correcta actividad 12", "DespuesDeGrabar", alltrim( c_ver.cActividad ) )
		This.Assertequals( "No es correcta el Invocador 12", "Bulgaria", alltrim( c_ver.Invocador ) )
		This.Assertequals( "No es correcta el ZADSFW 12", lcADSFW, alltrim( c_ver.ZADSFW ) )
		skip
		This.Assertequals( "No es correcta actividad 13", "Grabar", alltrim( c_ver.cActividad ) )
		This.Assertequals( "No es correcta el Invocador 13", "Bulgaria", alltrim( c_ver.Invocador ) )
		This.Assertequals( "No es correcta el ZADSFW 13", lcADSFW, alltrim( c_ver.ZADSFW ) )
		skip
		This.Assertequals( "No es correcta actividad 14", "oAD_Actualizar", alltrim( c_ver.cActividad ) )
		This.Assertequals( "No es correcta el Invocador 14", "Bulgaria", alltrim( c_ver.Invocador ) )
		This.Assertequals( "No es correcta el ZADSFW 14", lcADSFW, alltrim( c_ver.ZADSFW ) )
		skip
		This.Assertequals( "No es correcta actividad 15", "Validar", alltrim( c_ver.cActividad ) )
		This.Assertequals( "No es correcta el Invocador 15", "Bulgaria", alltrim( c_ver.Invocador ) )
		This.Assertequals( "No es correcta el ZADSFW 15", lcADSFW, alltrim( c_ver.ZADSFW ) )
		
		use in select( "c_Ver" )


		loEntidad.Release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestI_VerificarRegistroDeActividadAlGrabarEntidadSinExtencion
		local loEntidad as Din_EntidadBolivia as Din_EntidadBolivia.prg, lcADSFW as String
		goServicios.Registry.Nucleo.FechaDeHabilitacionDeTrazaExtendida = {}
		goServicios.RegistroDeActividad.Detener()

		goServicios.Datos.EjecutarSentencias( "Delete from Bulgaria", "Bulgaria" )
		goServicios.Datos.EjecutarSentencias( "Delete from RegActiv", "RegActiv" )
		goServicios.RegistroDeActividad.lEstaHabilitado = .T.
		loEntidad = NewObject( "BulgariaAux" )
		loEntidad.Nuevo()
		loEntidad.Codigo = "1"
		loEntidad.Descripcion = "1"
		loEntidad.Grabar()
		goServicios.RegistroDeActividad.Detener()
		=goServicios.RegistroDeActividad

		goServicios.Datos.EjecutarSentencias( "Select * from RegActiv order by cActividad", "RegActiv", ,"c_Ver", set( "Datasession" ) )
		select c_Ver
		This.Assertequals( "No es correcta la cantidad de registros", 0, reccount( "c_Ver" ) )
		
		goServicios.Datos.EjecutarSentencias( "Delete from RegActiv", "RegActiv" )
		goServicios.RegistroDeActividad.lEstaHabilitado = .T.
		loEntidad.Codigo = "1"
		loEntidad.Modificar()
		loEntidad.Grabar()
		goServicios.RegistroDeActividad.Detener()
		=goServicios.RegistroDeActividad
		goServicios.Datos.EjecutarSentencias( "Select * from RegActiv order by cActividad", "RegActiv", ,"c_Ver", set( "Datasession" ) )
		select c_Ver
		This.Assertequals( "No es correcta la cantidad de registros 1", 0, reccount( "c_Ver" ) )
	
		use in select( "c_Ver" )
		loEntidad.Release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestObtenerCantidadRegistrosConYSinFiltro
		local loEntidad as entidad OF entidad.prg, lcCodigo1 as String,;
				lcCodigo2 as String, lnCantidadDeRegistrosOriginal as Integer, lnCantidadDeRegistros as Integer
		
		loEntidad = _Screen.Zoo.InstanciarEntidad( "CONGO" )
		lcCodigo1 = replicate( "X", 38 )
		lcCodigo2 = replicate( "W", 38 )

		with loEntidad
			try
				.Codigo = lcCodigo1
				.Eliminar()
			catch
			endtry
			
			try
				.Codigo = lcCodigo2
				.Eliminar()
			catch
			endtry

			lnCantidadDeRegistrosOriginal = .ObtenerCantidadRegistros()
	
			.Nuevo()
			.Codigo = lcCodigo1
			.Descripcion = "BLA"			
			.Grabar()			
						
			.Nuevo()
			.Codigo = lcCodigo2
			.Descripcion = "PETER"
			.Grabar()

			lnCantidadDeRegistros = .ObtenerCantidadRegistros()			
			this.assertequals( "La cantidad de registros es incorrecta. 1", lnCantidadDeRegistros, lnCantidadDeRegistrosOriginal + 2 )

			lnCantidadDeRegistros = .ObtenerCantidadDeRegistrosConFiltro( "" )
			this.assertequals( "La cantidad de registros es incorrecta. 2", lnCantidadDeRegistros, lnCantidadDeRegistrosOriginal + 2 )

			lnCantidadDeRegistros = .ObtenerCantidadDeRegistrosConFiltro( "CODIGO='" + lcCodigo1 + "'" )
			this.assertequals( "La cantidad de registros es incorrecta. 3", lnCantidadDeRegistros, 1)

			lnCantidadDeRegistros = .ObtenerCantidadDeRegistrosConFiltro( "CODIGO='" + sys( 2015 ) + "'" )
			this.assertequals( "La cantidad de registros es incorrecta. 4", lnCantidadDeRegistros, 0 )

			.Release()
		endwith

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ztestEventoMensajeria
		
		local loEntidad as entidad of entidad.prg
		loEntidad = newobject( "TestEntidadAbstracta" )
		this.asserttrue( "No se encuentra el Evento EventoMensajeria", pemstatus( loEntidad, "EventoMensajeria", 5 ) )
		try 
			loEntidad.Eventomensajeria( "MENSAJE", 10 )
			loEntidad.Eventomensajeria( "MENSAJE" )
			loEntidad.Eventomensajeria( "" )
			loEntidad.Eventomensajeria( )	
		catch to loError
			This.Asserttrue( "No deberia pinchar en ninguno de estos llamados", .F. )
		endtry
		loEntidad.Release()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestVerificarFlagProcesando

		local loEntidad as entidad of entidad.prg

		loEntidad = _screen.zoo.instanciarentidad( 'Alemania' )
		with loEntidad
			
			.lProcesando = .T.
			.lCargando = .f.
			.lLimpiando = .f.
			.lDestroy = .f.
			This.asserttrue( "Fallo al setear en LPROCEANDO.", .EstaEnProceso() )
			
			.lProcesando = .f.
			.lCargando = .T.
			.lLimpiando = .f.
			.lDestroy = .f.
			This.asserttrue( "Fallo al setear en LCARGANDO.", .EstaEnProceso() )
			
			.lProcesando = .f.
			.lCargando = .f.
			.lLimpiando = .T.
			.lDestroy = .f.
			This.asserttrue( "Fallo al setear en LLIMPIANDO.", .EstaEnProceso() )
			
			.lProcesando = .f.
			.lCargando = .f.
			.lLimpiando = .f.
			.lDestroy = .T.
			This.asserttrue( "Fallo al setear en LDESTROY.", .EstaEnProceso() )

			.lProcesando = .f.
			.lCargando = .f.
			.lLimpiando = .f.
			.lDestroy = .f.
			This.asserttrue( "Fallo al setear con todos los atributos.", !.EstaEnProceso() )

			.lProcesando = .T.
			.lCargando = .T.
			.lLimpiando = .T.
			.lDestroy = .T.
			This.asserttrue( "Fallo al setear con todos los atributos.", .EstaEnProceso() )

			.release()
		endwith
		
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ztestSetearComponentes
		local loEntidad As Entidad of entidad.prg
		loEntidad = newobject( "TestComponente" )

		loEntidad.Nuevo()		
		try 
			loEntidad.Grabar()
			This.AssertTrue( "No se ejecuto el metodo SetearComponentes desde el Grabar", .F. )
		catch
			This.AssertTrue( "No Se ejecuto el metodo SetearComponentes", loEntidad.lEjecutoSetearComponentes )
		endtry
		loEntidad.Release()
		
	endfunc 
	*-----------------------------------------------------------------------------------------
	function zTestNuevo
		local loEntidad as entidad of entidad.prg, ldFecha as Date, lcHora as String, lcTimeStamp as String
		
		ldFecha = date()
		lcHora = time()
		lcTimeStamp = goServicios.Librerias.ObtenerTimeStamp()

		private goLibrerias
		_screen.mocks.agregarmock( "Librerias" )
		_screen.mocks.agregarseteometodo( "Librerias", "ObtenerFecha", ldFecha )
		_screen.mocks.agregarseteometodo( "Librerias", "ObtenerHora", lcHora )
		_screen.mocks.AgregarSeteoMetodo( 'LIBRERIAS', 'Obtenertimestamp', lcTimeStamp )
		
		goLibrerias = _screen.zoo.crearobjeto( "Librerias" )
		loEntidad = newobject( "TestEntidadRusia" )

		with loentidad
			.lEdicion = .t.
			.lNuevo = .f.
			.Nuevo()
			goServicios.Librerias = goLibrerias
			this.assertTrue( "Debe estar seteado el flag de edicion", !.lEdicion )
			this.assertTrue( "Debe estar seteado el flag de nuevo", .lNuevo )
			this.assertTrue( "Debe ejecutar el limpiar", .lejecutoLimpiar )
			this.asserttrue( "Debe ejecutar el actualizarEstado", .lEjecutoActualizarEstado )
			this.asserttrue( "Debe pasar por LIMPIARINFORMACION.", .lEjecutoLimpiarInformacion )
			
			this.asserttrue( "El atributo FechaAltaFW debe estar cargado.", between( .FechaAltaFW, ldFecha, ldFecha + 1 ) )
			this.assertequals( "El atributo HoraAltaFW debe estar cargado.", lcHora, .HoraAltaFW )
			this.asserttrue( "El atributo FechaModificacionFW debe estar cargado.", .FechaModificacionFW = .FechaAltaFw )
			this.assertequals( "El atributo HoraModificacionFW debe estar cargado.", lcHora, .HoraModificacionFW )
			this.assertequals( "El atributo UsuarioAltaFW debe estar cargado.", alltrim( goServicios.Seguridad.ObtenerUltimoUsuarioLogueado() ), .UsuarioAltaFW )
			this.assertequals( "El atributo UsuarioModificacionFW debe estar cargado.", alltrim( goServicios.Seguridad.ObtenerUltimoUsuarioLogueado() ), .UsuarioModificacionFW )
			this.assertequals( "El atributo SerieAltaFW debe estar cargado.", alltrim( _screen.Zoo.App.cSerie ), .SerieAltaFW )
			this.assertequals( "El atributo SerieModificacionFW debe estar cargado.", alltrim( _screen.Zoo.App.cSerie ), .SerieModificacionFW )
			this.assertequals( "El atributo BaseDeDatosAltaFW debe estar cargado.", alltrim( _screen.Zoo.App.cSucursalActiva ), .BaseDeDatosAltaFW )
			this.assertequals( "El atributo BaseDeDatosModificacionFW debe estar cargado.", alltrim( _screen.Zoo.App.cSucursalActiva ), .BaseDeDatosModificacionFW )
			
			Try
				.Nuevo()
				this.asserttrue( "No se deberia poder hacer nuevo dos veces seguidas sin cancelar o grabar el anterior", .f. )
			Catch 
			endtry 
		endwith
		loEntidad.release()
	endfunc 
	*-----------------------------------------------------------------------------------------

	function zTestVotaciones
		local loEntidad as entidad of entidad.prg
		
		_screen.mocks.AgregarSeteoMetodo( 'COMPONENTERIO', 'Votarcambioestadoeliminar', .T., "[NUEVO]" )
		loEntidad = newobject( "TestEntidadRusia" )
		with loentidad
			.lEdicion = .t.
			.lNuevo = .f.
			.lEjecutoVotacionCambioEstadoNuevo = .f.
			.lEjecutoActualizarEstado = .F.
			.lRetornoValidarPk = .T.

			.Nuevo()
			this.asserttrue( "Tendria que haber pasado por la votacion", .lEjecutoVotacionCambioEstadoNuevo )
			this.asserttrue( "Debe ejecutar el actualizarEstado", .lEjecutoActualizarEstado )
			
			.lEjecutoActualizarEstado = .F.
			.lEjecutoVotacionCambioEstadoNuevo = .f.

			.Cancelar()
			this.asserttrue( "Tendria que haber pasado por la votacion2", .lEjecutoVotacionCambioEstadoCancelar )
			this.asserttrue( "Debe ejecutar el actualizarEstado2", .lEjecutoActualizarEstado )

			.lEjecutoActualizarEstado = .F.
			.lEjecutoVotacionCambioEstadoCancelar = .f.

			.modificar()
			this.asserttrue( "Tendria que haber pasado por la votacion3", .lEjecutoVotacionCambioEstadoModificar )
			this.asserttrue( "Debe ejecutar el actualizarEstado3", .lEjecutoActualizarEstado )

			.Cancelar()			
			.lEjecutoActualizarEstado = .F.
			.lEjecutoVotacionCambioEstadoModificar = .f.
					
			.eliminar()
			this.asserttrue( "Tendria que haber pasado por la votacion4", .lEjecutoVotacionCambioEstadoEliminar )
			this.asserttrue( "Debe ejecutar el actualizarEstado4", .lEjecutoActualizarEstado )

			.lEjecutoActualizarEstado = .F.
			.lVotacionCambioEstadoNUEVO = .t.
			.lVotacionCambioEstadoCancelar = .t.
			.lVotacionCambioEstadoMODIFICAR = .t.
			.lVotacionCambioEstadoELIMINAR = .t.
			.LimpiarInformacion()				
			.lNuevo = .F.			
			try
				.Nuevo()
				this.asserttrue( "tendria que haber tirado la excepcion por votar en contra 1", .F. )
			catch to loError
				this.assertequals( "El error no es el correcto 1", "PROBLEMA AL VOTAR POR NUEVO", upper( alltrim( loError.uservalue.oInformacion.item[ 1 ].cMensaje ) ) )
			endtry
			this.asserttrue( "No tendria que actualizar Estado porque se voto en contra", !.lEjecutoActualizarEstado )
			.LimpiarInformacion()
			.lNuevo = .T.			
			try
				.Cancelar()
				this.asserttrue( "tendria que haber tirado la excepcion por votar en contra 2", .F. )
			catch to loError
				this.assertequals( "El error no es el correcto 1", "PROBLEMA AL VOTAR POR CANCELAR", upper( alltrim( loError.uservalue.oInformacion.item[ 1 ].cMensaje ) ) )
			endtry
			this.asserttrue( "No tendria que actualizar Estado porque se voto en contra2", !.lEjecutoActualizarEstado )
			.LimpiarInformacion()			
		
			try
				.Modificar()
				this.asserttrue( "tendria que haber tirado la excepcion por votar en contra 3", .F. )
			catch to loError
				this.assertequals( "El error no es el correcto 1", "PROBLEMA AL VOTAR POR MODIFICAR", upper( alltrim( loError.uservalue.oInformacion.item[ 1 ].cMensaje ) ) )
			endtry
			this.asserttrue( "No tendria que actualizar Estado porque se voto en contra3", !.lEjecutoActualizarEstado )
			.LimpiarInformacion()			
	
			try
				.Eliminar()
				this.asserttrue( "tendria que haber tirado la excepcion por votar en contra 4", .F. )
			catch to loError
				this.assertequals( "El error no es el correcto 1", "PROBLEMA AL VOTAR POR ELIMINAR", upper( alltrim( loError.uservalue.oInformacion.item[ 1 ].cMensaje ) ) )
			endtry
			this.asserttrue( "No tendria que actualizar Estado porque se voto en contra4", !.lEjecutoActualizarEstado )
			.LimpiarInformacion()			
		endwith
		
		loEntidad.release()
	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestGrabar
		local loEntidad as entidad of entidad.prg, llError as boolean

		_screen.mocks.agregarmock( "Numeraciones" )
		_screen.mocks.AgregarSeteoMetodo( 'NUMERACIONES', 'Inicializar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'NUMERACIONES', 'Setearentidad', .T., "'*OBJETO'" )
		_screen.mocks.AgregarSeteoMetodo( 'NUMERACIONES', 'Grabar', "", "'descripcion'" )
		_screen.mocks.AgregarSeteoMetodo( 'NUMERACIONES', 'Obtenernumero', 1, "'Codigo'" )
		_screen.mocks.AgregarSeteoMetodo( 'NUMERACIONES', 'Talonarioconnumeraciondisponible', .T. )
		
		loEntidad = newobject( "TestEntidad_DIn_Alemania" )
		with loEntidad
			.oAD = newobject( "TestAccesoDatosEntidad" )

			*** la grabacion dio ok (Nuevo)
			.Nuevo()
			.Codigo = "PEPE"

			.lEjecutoAntesDeGrabar = .f.
			.lejecutoValidar = .f.
			.oAD.lInserto = .f.
			.oAD.lActualizo = .f.
			.lejecutoDespuesdeGrabar = .f.
			.lEjecutoImprimirDespuesDeGrabar = .f.
			.lEjecutoImprimir = .f.

			.lRetornoAntesDeGrabar = .t.
			.lRetornoValidar = .t.
			.lRetornoDepuesDeGrabar = .t.
			.lRetornoValidarPK = .t.
			.oAd.lRetornoConsultarPorClavePrimaria = .t.
			.lEjecutoLimpiarInformacion = .f.
			
			.Grabar()

			this.assertTrue( "Debe ejecutar el antes de grabar (1)", .lEjecutoAntesDeGrabar )
			this.assertTrue( "Debe ejecutar el validar (1)", .lejecutoValidar )
			this.assertTrue( "Debe insertar (1)", .oAD.lInserto )
			this.assertTrue( "No Debe actualizar (1)", !.oAD.lActualizo )
			this.assertTrue( "Debe ejecutar el despues de grabar (1)", .lejecutoDespuesdeGrabar )
			this.assertTrue( "Debe estar seteado el flag de edicion (1)", !.lEdicion )
			this.assertTrue( "Debe estar seteado el flag de nuevo (1)", !.lNuevo )
			this.assertTrue( "Debe estar seteado el flag lProcesando (1)", !.lProcesando )			
			this.assertTrue( "Debe Ejecutar LIMPIARINFORMACION (1)", .lEjecutoLimpiarInformacion )
			this.assertTrue( "Debe Ejecutar ImprimirDespuesDeGrabar (1)", .lEjecutoImprimirDespuesDeGrabar )
			this.assertTrue( "Debe Ejecutar Imprimir (1)", .lEjecutoImprimir )
					
			Try
				.Grabar()
			Catch To loError
				this.assertequals( "No se generó el error correcto 1", "Error al intentar Grabar", loError.UserValue.Message )
				this.assertequals( "No se generó el error correcto 1", "No se puede grabar sin estar en estado NUEVO o EDICION", loError.UserValue.Details )				
				this.assertTrue( "Debe estar seteado el flag lProcesando (2)", !.lProcesando )						
				this.assertTrue( "Debe Ejecutar LIMPIARINFORMACION (2)", .lEjecutoLimpiarInformacion )
			Endtry
			

			*** la grabacion dio ok (Edicion)
			.oAd.lRetornoConsultarPorClavePrimaria = .t.
			.Modificar()
			this.assertTrue( "Debe estar seteado el flag lProcesando (3)", !.lProcesando )				

			.lEjecutoAntesDeGrabar = .f.
			.lejecutoValidar = .f.
			.oAD.lInserto = .f.
			.oAD.lActualizo = .f.
			.lejecutoDespuesdeGrabar = .f.
			.lEjecutoImprimirDespuesDeGrabar = .f.
			.lEjecutoImprimir = .f.

			.lRetornoAntesDeGrabar = .t.
			.lRetornoValidar = .t.
			.lRetornoDepuesDeGrabar = .t.
			.lRetornoValidarPK = .t.
			.lEjecutoLimpiarInformacion = .f.

			.Grabar()
			this.assertTrue( "Debe ejecutar el antes de grabar (1.1)", .lEjecutoAntesDeGrabar )
			this.assertTrue( "Debe ejecutar el validar (1.1)", .lejecutoValidar )
			this.assertTrue( "No Debe insertar (1.1)", !.oAD.lInserto )
			this.assertTrue( "Debe actualizar (1.1)", .oAD.lActualizo )
			this.assertTrue( "Debe ejecutar el despues de grabar (1.1)", .lejecutoDespuesdeGrabar )
			this.assertTrue( "Debe estar seteado el flag de edicion (1.1)", !.lEdicion )
			this.assertTrue( "Debe estar seteado el flag de nuevo (1.1)", !.lNuevo )
			this.assertTrue( "Debe estar seteado el flag lProcesando (4)", !.lProcesando )
			this.assertTrue( "Debe Ejecutar LIMPIARINFORMACION (3)", .lEjecutoLimpiarInformacion )
			this.assertTrue( "Debe ejecutar ImprimirDespuesDeGrabar (1)", .lEjecutoImprimirDespuesDeGrabar )
			this.assertTrue( "No debe ejecutar Imprimir (1)", !.lEjecutoImprimir )

			Try
				.Grabar()
			Catch To loError
				this.assertequals( "No se generó el error correcto 2", "Error al intentar Grabar", loError.UserValue.Message )
				this.assertequals( "No se generó el error correcto 2", "No se puede grabar sin estar en estado NUEVO o EDICION", loError.UserValue.Details )				
				this.assertTrue( "Debe estar seteado el flag lProcesando (5)", !.lProcesando )						
				this.assertTrue( "Debe Ejecutar LIMPIARINFORMACION (4)", .lEjecutoLimpiarInformacion )
			Endtry

			.oAd.lRetornoConsultarPorClavePrimaria = .f.			
			*** la grabacion pincha en el antes de grabar
			.Nuevo()
			this.assertTrue( "Debe estar seteado el flag lProcesando (6)", !.lProcesando )					
			.Codigo = "PEPE"

			.lEjecutoAntesDeGrabar = .f.
			.lejecutoValidar = .f.
			.oAD.lInserto = .f.
			.oAD.lActualizo = .f.
			.lejecutoDespuesdeGrabar = .f.

			.lRetornoAntesDeGrabar = .f.
			.lRetornoValidar = .f.
			.lRetornoValidarPK = .t.
			.lEjecutoLimpiarInformacion = .f.
			
			llError = .f.
			try
				.Grabar()
			catch
				llError = .t.
			endtry

			this.assertTrue( "Debe estar seteado el flag lProcesando (7)", !.lProcesando )		
			this.assertTrue( "el grabar debe dar error (2)", llError )
			this.assertTrue( "Debe ejecutar el antes de grabar (2)", .lEjecutoAntesDeGrabar )
			this.assertTrue( "No Debe ejecutar el validar (2)", !.lejecutoValidar )
			this.assertTrue( "No Debe insertar (2)", !.oAD.lInserto )
			this.assertTrue( "No Debe actualizar (2)", !.oAD.lActualizo )
			this.assertTrue( "No Debe ejecutar el despues de grabar (2)", !.lejecutoDespuesdeGrabar )
			this.assertTrue( "No Debe estar seteado el flag de edicion (2)", !.lEdicion )
			this.assertTrue( "No Debe estar seteado el flag de nuevo (2)", .lNuevo )
			this.assertTrue( "Debe Ejecutar LIMPIARINFORMACION (5)", .lEjecutoLimpiarInformacion )

			*** la grabacion pincha en el validar
			.Cancelar()
			
			Try
				.Grabar()
			Catch To loError
				this.assertequals( "No se generó el error correcto 3", "Error al intentar Grabar", loError.UserValue.Message )
				this.assertequals( "No se generó el error correcto 3", "No se puede grabar sin estar en estado NUEVO o EDICION", loError.UserValue.Details )				
				this.assertTrue( "Debe estar seteado el flag lProcesando (8)", !.lProcesando )						
				this.assertTrue( "Debe Ejecutar LIMPIARINFORMACION (6)", .lEjecutoLimpiarInformacion )
			Endtry			
			
			.Nuevo()
			this.assertTrue( "Debe estar seteado el flag lProcesando (9)", !.lProcesando )					
			.Codigo = "PEPE"

			.lEjecutoAntesDeGrabar = .f.
			.lejecutoValidar = .f.
			.oAD.lInserto = .f.
			.oAD.lActualizo = .f.
			.lejecutoDespuesdeGrabar = .f.

			.lRetornoAntesDeGrabar = .t.
			.lRetornoValidar = .f.
			.lRetornoDepuesDeGrabar = .f.
			.lRetornoValidarPK = .t.
			.lEjecutoLimpiarInformacion = .f.
			
			llError = .f.
			try
				.Grabar()
			catch
				llError = .t.
			endtry

			this.assertTrue( "Debe estar seteado el flag lProcesando (10)", !.lProcesando )		
			this.assertTrue( "el grabar debe dar error (3)", llError )
			this.assertTrue( "Debe ejecutar el antes de grabar (3)", .lEjecutoAntesDeGrabar )
			this.assertTrue( "Debe ejecutar el validar (3)", .lejecutoValidar )
			this.assertTrue( "No Debe insertar (3)", !.oAD.lInserto )
			this.assertTrue( "No Debe actualizar (3)", !.oAD.lActualizo )
			this.assertTrue( "No Debe ejecutar el despues de grabar (3)", !.lejecutoDespuesdeGrabar )
			this.assertTrue( "No Debe estar seteado el flag de edicion (3)", !.lEdicion )
			this.assertTrue( "No Debe estar seteado el flag de nuevo (3)", .lNuevo )
			this.assertTrue( "Debe Ejecutar LIMPIARINFORMACION (7)", .lEjecutoLimpiarInformacion )

			*** la grabacion pincha en el Despues de grabar
			.Cancelar()
			.Nuevo()
			this.assertTrue( "Debe estar seteado el flag lProcesando (11)", !.lProcesando )					
			.Codigo = "PEPE"

			.lEjecutoAntesDeGrabar = .f.
			.lejecutoValidar = .f.
			.oAD.lInserto = .f.
			.oAD.lActualizo = .f.
			.lejecutoDespuesdeGrabar = .f.

			.lRetornoAntesDeGrabar = .t.
			.lRetornoValidar = .t.
			.lRetornoDepuesDeGrabar = .f.
			.lRetornoValidarPK = .t.
			.lEjecutoLimpiarInformacion = .f.
			
			llError = .f.
			try
				.Grabar()
			catch
				llError = .t.
			endtry

			this.assertTrue( "Debe estar seteado el flag lProcesando (12)", !.lProcesando )		
			this.assertTrue( "el grabar debe dar error (4)", llError )
			this.assertTrue( "Debe ejecutar el antes de grabar (4)", .lEjecutoAntesDeGrabar )
			this.assertTrue( "Debe ejecutar el validar (4)", .lejecutoValidar )
			this.assertTrue( "Debe insertar (4)", .oAD.lInserto )
			this.assertTrue( "No Debe actualizar (4)", !.oAD.lActualizo )
			this.assertTrue( "Debe ejecutar el despues de grabar (4)", .lejecutoDespuesdeGrabar )
			this.assertTrue( "No Debe estar seteado el flag de edicion (4)", !.lEdicion )
			this.assertTrue( "No Debe estar seteado el flag de nuevo (4)", !.lNuevo )
			this.assertTrue( "Debe Ejecutar LIMPIARINFORMACION (8)", .lEjecutoLimpiarInformacion )
		endwith

		loEntidad.release()
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestEliminar
		local loEntidad as entidad of entidad.prg, llError as boolean
		
		loEntidad = newobject( "TestEntidadRusia" )

		*
		loEntidad.lWHEliminar = .T.
		goservicios.webhook = newobject("WebHook_fake")
		*
		
		with loentidad
			.oAD = newobject( "TestAccesoDatosEntidad" )

			*** la eliminacion dio ok
			.oAD.lRetornoConsultarPorClavePrimaria = .t.
			.Codigo = "PEPE"

			.lEjecutoValidarPK = .f.
			.lEjecutoLimpiar = .f.
			.oAD.lElimino = .f.
			.lRetornoValidarPK = .t.
			.lEjecutoLimpiarInformacion = .f.

			.Eliminar()

			this.assertTrue( "Debería haber ejecutado el método goservicios.webhook.Enviar()", goservicios.webhook.lPasoPorElEnviar )
			this.assertTrue( "Debería haber ejecutado el método goservicios.webhook.Enviar()", goservicios.webhook.lPasoPorElEnviar )
			this.assertequals("El evento a enviar del servicio WebHook no es el esperado","ELIMINAR", goservicios.webhook.cEvento )

			this.assertTrue( "Debe ejecutar el validar PK (1)", .lEjecutoValidarPK )
			this.assertTrue( "Debe ejecutar el eliminar (1)", .oAD.lElimino )
			this.assertTrue( "Debe ejecutar el limpiar (1)", .lEjecutoLimpiar )
			this.assertTrue( "Debe estar seteado el flag de edicion (1)", !.lEdicion )
			this.assertTrue( "Debe estar seteado el flag de nuevo (1)", !.lNuevo )
			this.assertTrue( "Debe Ejecutar LIMPIARINFORMACION (1)", .lEjecutoLimpiarInformacion )
			
			*** la eliminacion dio mal en validarPK
			.Codigo = "PEPE"
			.lEjecutoValidarPK = .f.
			.lEjecutoLimpiar = .f.
			.oAD.lElimino = .f.
			.lRetornoValidarPK = .f.
			.lEjecutoLimpiarInformacion = .f.

			llError = .f.
			try
				.Eliminar()
			catch
				llError = .t.
			endtry

			this.assertTrue( "el eliminar debe dar error (2)", llError )

			this.assertTrue( "Debe ejecutar el validar PK (2)", .lEjecutoValidarPK )
			this.assertTrue( "NO Debe ejecutar el eliminar (2)", !.oAD.lElimino )
			this.assertTrue( "NO Debe ejecutar el limpiar (2)", !.lEjecutoLimpiar )
			this.assertTrue( "Debe estar seteado el flag de edicion (2)", !.lEdicion )
			this.assertTrue( "Debe estar seteado el flag de nuevo (2)", !.lNuevo )
			this.assertTrue( "Debe Ejecutar LIMPIARINFORMACION (2)", .lEjecutoLimpiarInformacion )

			.Release()
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestRetrocederNumeracionesAlGrabarConErrorelUltimoRegistro
		local loEntidad as din_EntidadLetonia of din_EntidadLetonia.prg, llError as boolean, lnPrimerCodigoGrabado as Integer, lnSegundoCodigoGrabado as integer, ;
			loNumeraciones as Numeraciones of Numeraciones.prg, loTal as ent_talonario of ent_talonario.prg

		goServicios.Datos.EjecutarSentencias( "delete from alemania", "alemania", addbs( _Screen.zoo.cRutaInicial ) + "paises\dbf\" )
			
		loTal = _screen.zoo.instanciarentidad( "Talonario" )
		Try
			loTal.Codigo = "TALLETONIADESCTEST"
			loTal.Eliminar()
		catch
		endtry

		loTal.Nuevo()
		loTal.Formula = "'TalLetonia' + #descripcion@"
		loTal.Atributo = "Codigo"
		loTal.Entidad = "ALEMANIA"
		loTal.Descripcion = "DescTest"
		loTal.Grabar()

		loEntidad = _screen.zoo.instanciarentidad( "ALEMANIA" )
		
		loEntidadParaNumeraciones = _screen.zoo.instanciarentidad( "ALEMANIA" )
		loEntidadParaNumeraciones.Nuevo()
		loEntidadParaNumeraciones.Descripcion = "DescTest"
		loNumeraciones = _screen.zoo.CrearObjeto( 'Numeraciones' )
		loNumeraciones.Inicializar()
		loNumeraciones.SetearEntidad( loEntidadParaNumeraciones )

		with loentidad
			.Nuevo()
			.Descripcion = "DescTest"
			.Grabar()
			lnPrimerCodigoGrabado = .Codigo

			this.assertequals( "No se actualizó correctamente la numeración de alemania al grabar el primer registro", ;
				lnPrimerCodigoGrabado + 1, loNumeraciones.ObtenerNumero( "Codigo" ))

			.Nuevo()
			.Descripcion = "DescTest"
			.Grabar()

			this.assertequals( "No se actualizó correctamente la numeración de alemania al grabar el segundo registro", ;
				lnPrimerCodigoGrabado + 2, loNumeraciones.ObtenerNumero( "Codigo" ))


			.Codigo = lnPrimerCodigoGrabado 
			.Modificar()
			
			do Case
				case _Screen.zoo.app.TipodeBase = "NATIVA"
					select 0
					use ( addbs( _Screen.zoo.cRutaInicial ) + "paises\dbf\alemania" ) alias c_alemaniatest
					flock ( "c_alemaniatest" )
				case _Screen.zoo.app.TipodeBase = "SQLSERVER"
					goDatos.EjecutarSQL( "sp_rename [Zoologic.Alemania], [Alemania2]" )
				otherwise
					This.Asserttrue( "TESTEAR !!!!", .F. )
			EndCase	
				
			try
				.Grabar()
				this.assertTrue( "Deberia pinchar la grabacion para poder testear correctamente el retroceso de la numeracion (1)", .f. )
			catch
			endtry

			do Case
				case _Screen.zoo.app.TipodeBase = "NATIVA"
					unlock in "c_alemaniatest"
					use in select( "c_alemaniatest" )
				case _Screen.zoo.app.TipodeBase = "SQLSERVER"
					goDatos.EjecutarSQL( "sp_rename [Zoologic.Alemania2], [Alemania]" )
				otherwise
					This.Asserttrue( "TESTEAR !!!!", .F. )
			EndCase	
			
			this.assertequals( "No debe retroceder la numeración de alemania al pinchar la grabacion del registro modificado", ;
				lnPrimerCodigoGrabado + 2, loNumeraciones.ObtenerNumero( "Codigo" ) )

			
			.Nuevo()
			.Descripcion = "DescTest"

			do Case
				case _Screen.zoo.app.TipodeBase = "NATIVA"
					select 0
					use ( addbs( _Screen.zoo.cRutaInicial ) + "paises\dbf\alemania" ) alias c_alemaniatest
					flock ( "c_alemaniatest" )
				case _Screen.zoo.app.TipodeBase = "SQLSERVER"
					goDatos.EjecutarSQL( "sp_rename [Zoologic.Alemania], [Alemania2]" )
				otherwise
					This.Asserttrue( "TESTEAR !!!!", .F. )
			EndCase	
		
			try
				.Grabar()
				this.assertTrue( "Deberia pinchar la grabacion para poder testear correctamente el retroceso de la numeracion (2)", .f. )
			catch
			endtry

			do Case
				case _Screen.zoo.app.TipodeBase = "NATIVA"
					unlock in "c_alemaniatest"
					use in select( "c_alemaniatest" )
				case _Screen.zoo.app.TipodeBase = "SQLSERVER"
					goDatos.EjecutarSQL( "sp_rename [Zoologic.Alemania2], [Alemania]" )
				otherwise
					This.Asserttrue( "TESTEAR !!!!", .F. )
			EndCase	
				
			this.assertequals( "No se retrocedió la numeración de alemania al pinchar la grabacion del último registro", ;
				lnPrimerCodigoGrabado + 2, loNumeraciones.ObtenerNumero( "Codigo" ) )
	
			.Cancelar()
			.Codigo = lnPrimerCodigoGrabado 
			.Eliminar()
		endwith
		
		loTal.Codigo = "TALLETONIADESCTEST"
		loTal.Eliminar()

			
		loTal.release()
		loEntidad.Release()
		
		try
			loEntidad.Codigo = lnPrimerCodigoGrabado
			loEntidad.Eliminar()
		catch
		endtry

		try
			loEntidad.Codigo = lnSegundoCodigoGrabado 
			loEntidad.Eliminar()
		catch
		endtry

		loNumeraciones.release()
		loEntidadParaNumeraciones.release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestModificar
		local loEntidad as entidad of entidad.prg, llError as boolean, ldFecha as Date, lcHora as String, lcTimeStamp as String

		ldFecha = date()
		lcHora = time()
		lcTimeStamp = goServicios.Librerias.ObtenerTimeStamp()
		
		private goLibrerias
		_screen.mocks.agregarmock( "Librerias" )
		_screen.mocks.agregarseteometodo( "Librerias", "ObtenerFecha", ldFecha )
		_screen.mocks.agregarseteometodo( "Librerias", "ObtenerHora", lcHora )
		_screen.mocks.AgregarSeteoMetodo( 'LIBRERIAS', 'Obtenertimestamp', lcTimeStamp )
		
		goLibrerias = _screen.zoo.crearobjeto( "Librerias" )
		
		loEntidad = newobject( "TestEntidadRusia" )
		with loentidad
			.oAD = newobject( "TestAccesoDatosEntidad" )
			goServicios.Librerias = goLibrerias
			*** la eliminacion dio ok
			.oAD.lRetornoConsultarPorClavePrimaria = .t.			
			.Codigo = "PEPE"

			.lEjecutoValidarPK = .f.
			.lRetornoValidarPK = .t.
			.oAd.lRetornoConsultarPorClavePrimaria = .t.
			.lEjecutoLimpiarInformacion = .f.

			.FechaAltaFW = {01/01/2009}
			.HoraAltaFW = "00:00:01"
			.UsuarioAltaFW = "USERALTA"
			.SerieAltaFW = "1122334"
			.BaseDeDatosAltaFW = "BDALTA"

			.Modificar()
			this.assertTrue( "Debe ejecutar el validar PK (1)", .lEjecutoValidarPK )
			this.assertTrue( "Debe estar seteado el flag de edicion (1)", .lEdicion )
			this.assertTrue( "Debe estar seteado el flag de nuevo (1)", !.lNuevo )
			this.assertTrue( "Debe ejecutar LIMPIARINFORMACION (1)", .lEjecutoLimpiarInformacion )
			
			this.assertequals( "El atributo FechaAltaFW debe estar cargado.", {01/01/2009}, .FechaAltaFW )
			this.assertequals( "El atributo HoraAltaFW debe estar cargado.", "00:00:01", .HoraAltaFW )
			this.asserttrue( "El atributo FechaModificacionFW debe estar cargado.", between( .FechaModificacionFW, ldFecha, ldFecha + 1 ) )
			this.assertequals( "El atributo HoraModificacionFW debe estar cargado.", lcHora, .HoraModificacionFW )
			
			this.assertequals( "El atributo UsuarioAltaFW debe estar cargado.", "USERALTA", .UsuarioAltaFW )
			this.assertequals( "El atributo UsuarioModificacionFW debe estar cargado.", alltrim( goServicios.Seguridad.ObtenerUltimoUsuarioLogueado() ), .UsuarioModificacionFW )
			this.assertequals( "El atributo SerieAltaFW debe estar cargado.", "1122334", .SerieAltaFW )
			this.assertequals( "El atributo SerieModificacionFW debe estar cargado.", alltrim( _screen.Zoo.App.cSerie ), .SerieModificacionFW )
			this.assertequals( "El atributo BaseDeDatosAltaFW debe estar cargado.", "BDALTA", .BaseDeDatosAltaFW )
			this.assertequals( "El atributo BaseDeDatosModificacionFW debe estar cargado.", alltrim( _screen.Zoo.App.cSucursalActiva ), .BaseDeDatosModificacionFW )

			
			
			*** la eliminacion dio mal en validarPK
			.Cancelar()
			.Codigo = "PEPE"

			.lEjecutoValidarPK = .f.
			.lRetornoValidarPK = .f.
			.lEjecutoLimpiarInformacion = .f.

			llError = .f.
			try
				.Modificar()
			catch
				llError = .t.
			endtry

			this.assertTrue( "el eliminar debe dar error (2)", llError )

			this.assertTrue( "Debe ejecutar el validar PK (2)", .lEjecutoValidarPK )
			this.assertTrue( "Debe estar seteado el flag de edicion (2)", !.lEdicion )
			this.assertTrue( "Debe estar seteado el flag de nuevo (2)", !.lNuevo )
			this.assertTrue( "Debe ejecutar LIMPIARINFORMACION (2)", .lEjecutoLimpiarInformacion )

			.Release()
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestTransformaralAsignar()
		local loEntidad as entidad of entidad.prg

		loEntidad = _screen.zoo.instanciarentidad( 'Cuba' )
		with loEntidad
			try
				.Codigo = "123"
				.Eliminar()
			catch to loError
			endtry

			.Nuevo()
			.Codigo = "123"
			.Grabar()
			
			This.assertEquals( "No se transformo correctamente el codigo.", "XXXXXXX123", upper( alltrim( .Codigo ) ) )

		endwith
		
		loEntidad.release()		
	
	endfunc 

	
	*-----------------------------------------------------------------------------------------
	function zTestValidarPK
		local loEntidad as entidad of entidad.prg, llRetorno as Boolean, loInfo as zooInformacion of zooInformacion.prg
		loInfo = _Screen.zoo.crearobjeto( "zooInformacion" )
		loEntidad = newobject( "TestEntidadAbstracta" )
		loEntidad.setearinformacion( loInfo )
		loEntidad.nuevo()
		loEntidad.Codigo = "PEPE"
		llRetorno = loentidad.ValidarPK()
		this.asserttrue( "La validacion debe ser correcta", llRetorno )

		loEntidad.Codigo = ""
		llRetorno = loentidad.ValidarPK()
		this.asserttrue( "La validacion debe ser incorrecta", !llRetorno )
		this.assertequals( "El mensaje de la validacion no es correcta", "Seleccione un registro", loInfo.Item[ 1 ].cMensaje )
		
		loentidad.release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestValidar
		local loEntidad as entidad of entidad.prg, llRetorno as Boolean

		loEntidad = newobject( "TestEntidadValidar" )
		with loEntidad
			.oAD = newobject( "TestAccesoDatosEntidad" )

			.nuevo()
			.lRetornoValidacionBasica = .f.
			.lEjecutoValidacionBasica = .f.
			.oAD.lRetornoConsultarPorClavePrimaria = .f.

			llRetorno = .Validar()
			this.asserttrue( "La validacion debe ser incorrecta (1)", !llRetorno )
			this.assertTrue( "Debe ejecutar el validarbasica (1)", .lEjecutoValidacionBasica )
		
			.Cancelar()
			.nuevo()
			.lRetornoValidacionBasica = .t.
			.lEjecutoValidacionBasica = .f.
			.oAD.lRetornoConsultarPorClavePrimaria = .f.

			llRetorno = .Validar()
			this.assertTrue( "Debe ejecutar el validarbasica (2)", .lEjecutoValidacionBasica )

			.Cancelar()
			.nuevo()
			.Codigo = "PEPE"
			.lRetornoValidacionBasica = .t.
			.lEjecutoValidacionBasica = .f.

			.oAD.lRetornoConsultarPorClavePrimaria = .f.

			llRetorno = .Validar()
			this.asserttrue( "La validacion debe ser incorrecta (3)", llRetorno )
			this.assertTrue( "Debe ejecutar el validarbasica (3)", .lEjecutoValidacionBasica )

			.Cancelar()
			.nuevo()
			.Codigo = "PEPE"
			.lRetornoValidacionBasica = .t.
			.lEjecutoValidacionBasica = .f.
			.oAD.lRetornoConsultarPorClavePrimaria = .f.

			llRetorno = .Validar()
			this.asserttrue( "La validacion debe ser correcta (4)", llRetorno )
			this.assertTrue( "Debe ejecutar el validarbasica (4)", .lEjecutoValidacionBasica )

			.oAd.lRetornoConsultarPorClavePrimaria = .t.
			.Modificar()
			.Codigo = "PEPE"
			.lRetornoValidacionBasica = .t.
			.lEjecutoValidacionBasica = .f.
			.oAD.lRetornoConsultarPorClavePrimaria = .f.

			llRetorno = .Validar()
			this.asserttrue( "La validacion debe ser incorrecta (5)", !llRetorno )
			this.assertTrue( "Debe ejecutar el validarbasica (5)", .lEjecutoValidacionBasica )

			.oAd.lRetornoConsultarPorClavePrimaria = .t.
			.Cancelar()
			.oAd.lRetornoConsultarPorClavePrimaria = .f.
			.nuevo()
			.Codigo = "PEPE"
			.lRetornoValidacionBasica = .t.
			.lEjecutoValidacionBasica = .f.
			.oAD.lRetornoConsultarPorClavePrimaria = .t.

			llRetorno = .Validar()
			this.asserttrue( "La validacion debe ser incorrecta (6)", !llRetorno )
			this.assertTrue( "Debe ejecutar el validarbasica (6)", .lEjecutoValidacionBasica )

			.oAd.lRetornoConsultarPorClavePrimaria = .t.
			.modificar()
			.Codigo = "PEPE"
			.lRetornoValidacionBasica = .t.
			.lEjecutoValidacionBasica = .f.
			.oAD.lRetornoConsultarPorClavePrimaria = .t.

			llRetorno = .Validar()
			this.asserttrue( "La validacion debe ser correcta (6)", llRetorno )
			this.assertTrue( "Debe ejecutar el validarbasica (6)", .lEjecutoValidacionBasica )

			.release()
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestCancelar
		local loEntidad as entidad of entidad.prg, llTiroExcepcion as Boolean
			
		loEntidad = newobject( "TestEntidadRusia" )
		
		llTiroExcepcion = .f.
		
		with loEntidad
			.lejecutoCargar = .f.
			.lejecutoLimpiar = .f.
			.lEjecutoLimpiarInformacion = .f.
			try
				.Cancelar()
			catch 
				llTiroExcepcion = .t.
			endtry
			
			this.asserttrue( "No paso por la excepcion cuando debia hacerlo.", llTiroExcepcion )

			.lejecutoCargar = .f.
			.lejecutoLimpiar = .f.
			.Nuevo()

			.lEjecutoLimpiarInformacion = .f.
			.Cancelar()

			this.asserttrue( "No Debe ejecutar cargar (2)", !.lejecutoCargar )
			this.asserttrue( "Debe ejecutar limpiar (2)", .lejecutoLimpiar )
			this.assertTrue( "Debe estar seteado el flag de edicion (2)", !.lEdicion )
			this.assertTrue( "Debe estar seteado el flag de nuevo (2)", !.lNuevo )
						
			.lRetornoValidarPK = .t.
			.lejecutoCargar = .f.
			.lejecutoLimpiar = .f.
			.Modificar()

			.lEjecutoLimpiarInformacion = .f.
			.Cancelar()

			this.asserttrue( "Debe ejecutar cargar (3)", .lejecutoCargar )
			this.asserttrue( "No Debe ejecutar limpiar (3)", !.lejecutoLimpiar )
			this.assertTrue( "Debe estar seteado el flag de edicion (3)", !.lEdicion )
			this.assertTrue( "Debe estar seteado el flag de nuevo (3)", !.lNuevo )
						
			.release()
		endwith
	endfunc	
	*-----------------------------------------------------------------------------------------
	function zTestPrimero
		local loEntidad as entidad of entidad.prg

		loEntidad = newobject( "TestEntidad" )
		
		with loEntidad
			.oAD = newobject( "TestAccesoDatosEntidad" )

			.oAd.lPrimero = .f.
			.lEjecutoCargar = .f.
			.lNuevo = .f.
			.lEdicion = .f.
			.lEjecutoLimpiarInformacion = .f.
			.Primero()

			this.asserttrue( "Debe ejecutar cargar.", .lejecutoCargar )
			this.asserttrue( "Debe ejecutar primero.", .oAd.lPrimero )
			this.assertTrue( "Debe estar seteado el flag de edicion.", !.lEdicion )
			this.assertTrue( "Debe estar seteado el flag de nuevo.", !.lNuevo )
			this.assertTrue( "Debe ejecutar LIMPIARINFORMACION.", .lEjecutoLimpiarInformacion )
			
			.release()
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestUltimo
		local loEntidad as entidad of entidad.prg

		loEntidad = newobject( "TestEntidad" )
		
		with loEntidad
			.oAD = newobject( "TestAccesoDatosEntidad" )

			.oAd.lUltimo = .f.
			.lEjecutoCargar = .f.
			.lNuevo = .f.
			.lEdicion = .f.
			.lEjecutoLimpiarInformacion = .f.
			.Ultimo()

			this.asserttrue( "Debe ejecutar cargar.", .lejecutoCargar )
			this.asserttrue( "Debe ejecutar Ultimo.", .oAd.lUltimo )
			this.assertTrue( "Debe estar seteado el flag de edicion.", !.lEdicion )
			this.assertTrue( "Debe estar seteado el flag de nuevo.", !.lNuevo )
			this.assertTrue( "Debe ejecutar LIMPIARINFORMACION.", .lEjecutoLimpiarInformacion )
			
			.release()
		endwith
	endfunc
	*-----------------------------------------------------------------------------------------
	function zTestSiguiente
		local loEntidad as entidad of entidad.prg

		loEntidad = newobject( "TestEntidad" )
		
		with loEntidad
			.oAD = newobject( "TestAccesoDatosEntidad" )

			.oAd.lsiguiente = .f.
			.lEjecutoCargar = .f.
			.lNuevo = .f.
			.lEdicion = .f.
			.lEjecutoLimpiarInformacion = .f.
			.Siguiente()

			this.asserttrue( "Debe ejecutar cargar (1)", .lejecutoCargar )
			this.asserttrue( "Debe ejecutar primero (1)", .oAd.lPrimero )
			this.assertTrue( "Debe estar seteado el flag de edicion (1)", !.lEdicion )
			this.assertTrue( "Debe estar seteado el flag de nuevo (1)", !.lNuevo )
			this.assertTrue( "Debe ejecutar LIMPIARINFORMACION(1).", .lEjecutoLimpiarInformacion )

			.oAd.lsiguiente = .f.
			.lEjecutoCargar = .f.
			.lNuevo = .f.
			.lEdicion = .f.
			.lEjecutoLimpiarInformacion = .f.
			.Codigo = "PEPE"

			.Siguiente()

			this.asserttrue( "Debe ejecutar cargar (2)", .lejecutoCargar )
			this.asserttrue( "Debe ejecutar siguiente (2)", .oAd.lSiguiente )
			this.assertTrue( "Debe estar seteado el flag de edicion (2)", !.lEdicion )
			this.assertTrue( "Debe estar seteado el flag de nuevo (2)", !.lNuevo )
			this.assertTrue( "Debe ejecutar LIMPIARINFORMACION(2).", .lEjecutoLimpiarInformacion )

			.release()
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestAnterior
		local loEntidad as entidad of entidad.prg

		loEntidad = newobject( "TestEntidad" )
		
		with loEntidad
			.oAD = newobject( "TestAccesoDatosEntidad" )

			.oAd.lAnterior = .f.
			.lEjecutoCargar = .f.
			.lNuevo = .f.
			.lEdicion = .f.
			.lEjecutoLimpiarInformacion = .f.
			.Anterior()

			this.asserttrue( "Debe ejecutar cargar (1)", .lejecutoCargar )
			this.asserttrue( "Debe ejecutar primero (1)", .oAd.lPrimero )
			this.assertTrue( "Debe estar seteado el flag de edicion (1)", !.lEdicion )
			this.assertTrue( "Debe estar seteado el flag de nuevo (1)", !.lNuevo )
			this.assertTrue( "Debe ejecutar LIMPIARINFORMACION(1).", .lEjecutoLimpiarInformacion )			

			.oAd.lAnterior = .f.
			.lEjecutoCargar = .f.
			.lNuevo = .f.
			.lEdicion = .f.
			.lEjecutoLimpiarInformacion = .f.
			.Codigo = "PEPE"

			.Anterior()

			this.asserttrue( "Debe ejecutar cargar (2)", .lejecutoCargar )
			this.asserttrue( "Debe ejecutar Anterior (2)", .oAd.lAnterior )
			this.assertTrue( "Debe estar seteado el flag de edicion (2)", !.lEdicion )
			this.assertTrue( "Debe estar seteado el flag de nuevo (2)", !.lNuevo )
			this.assertTrue( "Debe ejecutar LIMPIARINFORMACION(2).", .lEjecutoLimpiarInformacion )			

			.release()
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestBuscar
		local loEntidad as entidad of entidad.prg
		local lcEntidad As String, lcPrefijo as String
		do Case
			case _Screen.zoo.app.TipodeBase = "NATIVA"
				lcPrefijo = "AD"
			case _Screen.zoo.app.TipodeBase = "SQLSERVER"
				lcPrefijo = "AD_SQLSERVER"
			otherwise
				This.Asserttrue( "TESTEAR !!!!", .F. )
		EndCase				
		
		lcEntidad = "Rusia"
		_Screen.Mocks.AgregarMock( lcEntidad + lcPrefijo )
		_screen.mocks.AgregarSeteoMetodo( lcEntidad + lcPrefijo, 'Inyectarentidad', .T., "'*OBJETO'" )
		loEntidad = _screen.zoo.instanciarentidad( "rusia" )

		with loEntidad
			.lLimpiando = .T.
			.Codigo = "1"
			_screen.mocks.AgregarSeteoMetodo( lcEntidad + lcPrefijo , 'Consultarporclaveprimaria', '*THROW' )
			try 
				.Buscar()
				This.AssertTrue( "Debio haber pasado por el Consultarporclaveprimaria1", .F. )
			catch

			endtry
			_screen.mocks.AgregarSeteoMetodo( lcEntidad + lcPrefijo , 'Consultarporclaveprimaria', .T. )

			try 
				.Buscar()
			catch
				This.AssertTrue( "Debio haber pasado por el Consultarporclaveprimaria 2", .F. )
			endtry
			_screen.mocks.AgregarSeteoMetodo( lcEntidad + lcPrefijo , 'Consultarporclaveprimaria', .F. )
			try 
				.Buscar()
				This.AssertTrue( "Debio haber pasado por el Consultarporclaveprimaria 3", .F. )
			catch
			endtry

			_screen.mocks.AgregarSeteoMetodo( lcEntidad + lcPrefijo , 'Consultarporclaveprimaria', .T. )
			_screen.mocks.AgregarSeteoMetodo( lcEntidad + lcPrefijo , 'ConsultarPorClaveCandidata', '*THROW' )
			.Codigo = ""
			try 
				.Buscar()
				This.AssertTrue( "Debio haber pasado por el ConsultarPorClaveCandidata 1", .F. )
			catch
			endtry
			_screen.mocks.AgregarSeteoMetodo( lcEntidad + lcPrefijo , 'ConsultarPorClaveCandidata', .T. )
			try 
				.Buscar()
			catch
				This.AssertTrue( "Debio haber pasado por el ConsultarPorClaveCandidata 2", .F. )
			endtry
			_screen.mocks.AgregarSeteoMetodo( lcEntidad + lcPrefijo , 'ConsultarPorClaveCandidata', .F. )
			try 
				.Buscar()
				This.AssertTrue( "Debio haber pasado por el ConsultarPorClaveCandidata 3", .F. )
			catch
			endtry

		endwith 			
		loEntidad.release()
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestLimpiarEntidad
		local loEntidad as object, llExiste as Boolean, llRetorno as Boolean

		this.AgregarMocks( "Rio" )
		local loCol As zoocoleccion OF zoocoleccion.prg
		loCol = _Screen.zoo.Crearobjeto( "ZooColeccion" )
		_screen.mocks.AgregarSeteoMetodo( 'Rio', 'Obtenersentenciasinsert', loCol )
		_screen.mocks.AgregarSeteoMetodo( 'Rio', 'Obtenersentenciasdelete', loCol )
		_screen.mocks.AgregarSeteoMetodo( 'Rio', 'ObtenersentenciasUpdate', loCol )
		
		loEntidad =_screen.Zoo.instanciarentidad( "rusia" )
		with loEntidad
			try
				.codigo = '1'
				.lEliminar = .T.
				.eliminar()
			catch to loError
			endtry 
			.nuevo()
			.codigo = '1'
			.descripcion = 'descri'
			.republicas = 'lalala'
			.Fecha = Date()
			.grabar()		
									
			.Codigo = '1'
			this.assertequals( 'La descripciónes son distintas', 'descri', alltrim( .descripcion ) )

			.limpiar( )
			
			this.AssertTrue( "No limpió el código", empty( .Codigo ) )
			
			.codigo = '1'
			.eliminar()
		
		endwith

		loEntidad.release()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ztestMemo
		local lcObserv0 As String, lcObserv1 As String, lcObserv2 As String, loEntidad as Object
		this.AgregarMocks( "Rio" )
		local loCol As zoocoleccion OF zoocoleccion.prg
		loCol = _Screen.zoo.Crearobjeto( "ZooColeccion" )
		_screen.mocks.AgregarSeteoMetodo( 'Rio', 'Obtenersentenciasinsert', loCol )
		_screen.mocks.AgregarSeteoMetodo( 'Rio', 'Obtenersentenciasdelete', loCol )
		_screen.mocks.AgregarSeteoMetodo( 'Rio', 'ObtenersentenciasUpdate', loCol )

		lcObserv0 =	replicate( "X", 300 )
		lcObserv1 =	"123456789012345678901234 567890123456789012345678901 2345678901234567890" + chr(13) + chr(10) + ;
					"123456789012345678901234567890123456789012345678901234567890" + chr(13) + chr(10) + ;
					"ABCDEFGHIJKMNOPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
		lcObserv2 =	"OBS2"

		loEntidad = _screen.Zoo.instanciarentidad( "rusia" )
		with loEntidad
	
			*-- Elimino los posibles codigos existentes
			try
				.codigo = '.0'
				.eliminar()
			catch 
			endtry 

			try
				.codigo = '.1'
				.eliminar()
			catch 
			endtry 
			
			try
				.codigo = '.2'
				.eliminar()
			catch 
			endtry 
			
			*-- Agrego los datos que necesito
			.nuevo()
			.Codigo = ".0"
			.descripcion = 'Descripcion .0'
			.republicas = 'lalala'
			.fecha = date()
			.Observacion = lcObserv0
			.grabar()
						
			*-- 
			.nuevo()
			.Codigo = ".1"
			.descripcion = 'Descripcion .1'
			.republicas = 'lalala'
			.fecha = date()
			.Observacion = lcObserv1
			.grabar()
		
			*-- 
			.nuevo()
			.Codigo = ".2"
			.descripcion = 'Descripcion .2'
			.republicas = 'lalala'
			.fecha = date()
			.Observacion = lcObserv2
			.grabar()
			
			*-- Verifico que los datos de la entidad se grabaron bien
			.Primero()
			.Codigo = ".2" 
			.Buscar()
			this.assertequals( "La observaciones en la entidad son distintas 1", lcObserv2 , alltrim( .Observacion ) )
			
			.Primero()
			.Codigo = ".1" 
			.Buscar()
			this.assertequals( "La observaciones en la entidad son distintas 2", lcObserv1 , alltrim( .Observacion ) )
			
			.Ultimo()
			.Codigo = ".0" 
			.Buscar()
			this.assertequals( "La observaciones en la entidad son distintas 3", lcObserv0 , alltrim( .Observacion ) )
			
			*-- Modifico todas las observaciones y vuelvo a probar
			.Codigo = ".0" 
			.Buscar()
			.Modificar()
			lcObserv0 = lcObserv0 + replicate( "Z", 300 ) + chr(13) + chr(10)
			.Observacion = lcObserv0
			.Grabar()
		
			.Codigo = ".1" 
			.Buscar()
			.Modificar()
			lcObserv1 = lcObserv1 + "123456789012345678901234567890123456789012345678901234567890" + chr(13) + chr(10)
			.Observacion = lcObserv1
			.Grabar()
			
			.Codigo = ".2" 
			.Buscar()
			.Modificar()
			lcObserv2 = lcObserv2 + "1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0" + chr(13) + chr(10)
			.Observacion = lcObserv2
			.Grabar()
			
			*-- Verifico que los datos de la entidad se grabaron bien
			.Primero()
			.Codigo = ".2" 
			.Buscar()
			this.assertequals( "La observaciones en la entidad son distintas 1", lcObserv2 , alltrim( .Observacion ) )
			
			.Primero()
			.Codigo = ".1" 
			.Buscar()
			this.assertequals( "La observaciones en la entidad son distintas 2", lcObserv1 , alltrim( .Observacion ) )
			
			.Ultimo()
			.Codigo = ".0" 
			.Buscar()
			this.assertequals( "La observaciones en la entidad son distintas 3", lcObserv0 , alltrim( .Observacion ) )

			*-- Elimina el dato
			.Codigo = ".0" 
			.Eliminar()

			.Codigo = ".1" 
			.Eliminar()

			.Codigo = ".2" 
			.Eliminar()

		endwith
		loEntidad.release()
	EndFunc

	*-----------------------------------------------------------------------------------------
	Function zTestValidarCaracteresInvalidos
		local loEntidad as Object, lcTexto as String, llRetornoOk as Boolean , ;
			llPermiteCaracteresEspeciales as Boolean

		loEntidad = newobject( "TestEntidad" )

		lcTexto = "ERGHPOKJRFGH"
		llPermiteCaracteresEspeciales = .f.
		
		with loEntidad
			
			
			llRetornoOk = .ValidarIngreso( lcTexto,llPermiteCaracteresEspeciales  )
			this.Asserttrue( "Se valido incorrectamente el ingreso de texto. Ingreso " + lcTexto , llRetornoOk )
		


			lcTexto = "ERGHPO:KJRFGH"
			llRetornoOk = .ValidarIngreso( lcTexto,llPermiteCaracteresEspeciales  )
			this.Asserttrue( "No se valido correctamente el ingreso de texto. Ingreso " + lcTexto , !llRetornoOk )


			lcTexto = "?"
			llPermiteCaracteresEspeciales = .f.

			llRetornoOk = .ValidarIngreso( lcTexto,llPermiteCaracteresEspeciales )
			this.Asserttrue( "Se valido incorrectamente el ingreso de texto 1. Ingreso " + lcTexto , !llRetornoOk )


			lcTexto = "?"
			llPermiteCaracteresEspeciales = .t.

			llRetornoOk = .ValidarIngreso( lcTexto,llPermiteCaracteresEspeciales )
			this.Asserttrue( "Se valido correctamente el ingreso de texto 2. Ingreso " + lcTexto , llRetornoOk )




			lcTexto = "ERGHPOKJRFGHfghgf"
			.lPermiteMinusculasPK = .f.
			
			llRetornoOk = .ValidarIngreso( lcTexto,llPermiteCaracteresEspeciales  )
			this.Asserttrue( "No se valido correctamente el ingreso de texto. lPermiteMinusculas = .f., Ingreso " + lcTexto , !llRetornoOk )



			lcTexto = "ERGHPOKJRFGHfghgf"
			.lPermiteMinusculasPK = .t.
			loEntidad.cCaracteres = ""
			
			llRetornoOk = .ValidarIngreso( lcTexto,llPermiteCaracteresEspeciales  )
			this.Asserttrue( "Se valido correctamente el ingreso de texto. lPermiteMinusculas = .t., Ingreso " + lcTexto , llRetornoOk )


		Endwith
		loEntidad.Release()

	Endfunc 
	*-----------------------------------------------------------------------------------------
	function zTestCargaManual
		local loEntidad As Entidad of Entidad.Prg
		loEntidad = newobject( "AuxCargaMAnual" )
		loEntidad.lCargando = .T.
		loEntidad.lLimpiando = .T.
		loEntidad.lDestroy = .T.
		This.AssertTrue( "Error en CargaManual con lCargando = .T., lLimpiando = .T., lDestroy = .T.", !loEntidad.CargaManual() )
		loEntidad.lCargando = .T.
		loEntidad.lLimpiando = .F.
		loEntidad.lDestroy = .T.
		This.AssertTrue( "Error en CargaManual con lCargando = .T., lLimpiando = .F., lDestroy = .T.", !loEntidad.CargaManual() )
		loEntidad.lCargando = .T.
		loEntidad.lLimpiando = .T.
		loEntidad.lDestroy = .F.
		This.AssertTrue( "Error en CargaManual con lCargando = .T., lLimpiando = .T., lDestroy = .F.", !loEntidad.CargaManual() )
		loEntidad.lCargando = .T.
		loEntidad.lLimpiando = .F.
		loEntidad.lDestroy = .F.
		This.AssertTrue( "Error en CargaManual con lCargando = .T., lLimpiando = .F., lDestroy = .F.", !loEntidad.CargaManual() )
		loEntidad.lCargando = .F.
		loEntidad.lLimpiando = .T.
		loEntidad.lDestroy = .T.
		This.AssertTrue( "Error en CargaManual con lCargando = .F., lLimpiando = .T., lDestroy = .T.", !loEntidad.CargaManual() )
		loEntidad.lCargando = .F.
		loEntidad.lLimpiando = .F.
		loEntidad.lDestroy = .T.
		This.AssertTrue( "Error en CargaManual con lCargando = .F., lLimpiando = .F., lDestroy = .T.", !loEntidad.CargaManual() )
		loEntidad.lCargando = .F.
		loEntidad.lLimpiando = .T.
		loEntidad.lDestroy = .F.
		This.AssertTrue( "Error en CargaManual con lCargando = .F., lLimpiando = .T., lDestroy = .F.", !loEntidad.CargaManual() )
		loEntidad.lCargando = .F.
		loEntidad.lLimpiando = .F.
		loEntidad.lDestroy = .F.
		This.AssertTrue( "Error en CargaManual con lCargando = .F., lLimpiando = .F., lDestroy = .F.", loEntidad.CargaManual() )
		loEntidad.release()
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestObtenerSentencias
		local loEntidad as Din_EntidadTanzania of Din_EntidadTanzania.prg, loColeccionInsert as zoocoleccion OF zoocoleccion.prg, ;
			loColeccionUpdate as zoocoleccion OF zoocoleccion.prg, loColeccionDelete as zoocoleccion OF zoocoleccion.prg, ;
			loColeccion as zoocoleccion OF zoocoleccion.prg
		
		
		loColeccionInsert = _screen.zoo.CrearObjeto( "zoocoleccion" )
		loColeccionInsert.agregar( "Insert" )
		loColeccionUpdate = _screen.zoo.CrearObjeto( "zoocoleccion" )
		loColeccionUpdate.agregar( "Update" )
		loColeccionDelete = _screen.zoo.CrearObjeto( "zoocoleccion" )
		loColeccionDelete.agregar( "Delete" )
		
		local lcEntidad As String, lcPrefijo as String
		lcEntidad = "Tanzania"
		do Case
			case _Screen.zoo.app.TipodeBase = "NATIVA"
				lcPrefijo = "AD"
			case _Screen.zoo.app.TipodeBase = "SQLSERVER"
				lcPrefijo = "AD_SQLSERVER"
			otherwise
				This.Asserttrue( "TESTEAR !!!!", .F. )
		EndCase				

		_Screen.Mocks.AgregarMock( lcEntidad + lcPrefijo )
		_screen.mocks.AgregarSeteoMetodo( lcEntidad + lcPrefijo, 'Inyectarentidad', .T., "'*OBJETO'" )
		_screen.mocks.AgregarSeteoMetodo( lcEntidad + lcPrefijo, 'Verificarexistencia', .T. )
		_screen.mocks.AgregarSeteoMetodo( lcEntidad + lcPrefijo, 'Obtenersentenciasinsert', loColeccionInsert )
		_screen.mocks.AgregarSeteoMetodo( lcEntidad + lcPrefijo, 'Obtenersentenciasupdate', loColeccionUpdate )
		_screen.mocks.AgregarSeteoMetodo( lcEntidad + lcPrefijo, 'ObtenersentenciasDelete', loColeccionDelete )
 
		loEntidad = _screen.zoo.instanciarentidad( "Tanzania" )
		loColeccion = loEntidad.ObtenerSentenciasInsert()
		this.assertequals( "No se devolvió la colección de inserts", "Insert", loColeccion[1] )
		loColeccion = loEntidad.ObtenerSentenciasUpdate()
		this.assertequals( "No se devolvió la colección de update", "Update", loColeccion[1] )
		loColeccion = loEntidad.ObtenerSentenciasDelete()
		this.assertequals( "No se devolvió la colección de delete", "Delete", loColeccion[1] )
		loEntidad.release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestVerificarContexto
		local loEntidad as object

		loEntidad =_screen.Zoo.instanciarentidad( "rusia" )
		
		this.AssertTrue( 'No existe la propiedad cContexto', pemstatus( loEntidad, "cContexto", 5 ) )
		this.AssertEquals( 'El valor default de la propiedad cContexto debe ser vacio. Entidad', "", alltrim( loEntidad.cContexto ) )

		this.AssertTrue( 'El contexto debe estar vacio (1)', loEntidad.VerificarContexto() )
		this.AssertTrue( 'El contexto debe estar vacio (2)', loEntidad.VerificarContexto("") )
		this.AssertTrue( 'El contexto debe estar vacio (3)', loEntidad.VerificarContexto(" ") )
		this.AssertTrue( 'El contexto debe estar vacio (4)', !loEntidad.VerificarContexto( "T" ) )
		this.AssertTrue( 'El contexto debe estar vacio (5)', !loEntidad.VerificarContexto( "I" ) )
		this.AssertTrue( 'El contexto debe estar vacio (6)', !loEntidad.VerificarContexto( "TI" ) )
		this.AssertTrue( 'El contexto debe estar vacio (7)', !loEntidad.VerificarContexto( "IT" ) )

		loEntidad.cContexto = "T"

		this.AssertTrue( 'El contexto debe ser Transferencia (1)', !loEntidad.VerificarContexto() )
		this.AssertTrue( 'El contexto debe ser Transferencia (2)', !loEntidad.VerificarContexto("") )
		this.AssertTrue( 'El contexto debe ser Transferencia (3)', !loEntidad.VerificarContexto(" ") )
		this.AssertTrue( 'El contexto debe ser Transferencia (4)', loEntidad.VerificarContexto( "T" ) )
		this.AssertTrue( 'El contexto debe ser Transferencia (5)', !loEntidad.VerificarContexto( "I" ) )
		this.AssertTrue( 'El contexto debe ser Transferencia (6)', loEntidad.VerificarContexto( "TI" ) )
		this.AssertTrue( 'El contexto debe ser Transferencia (7)', loEntidad.VerificarContexto( "IT" ) )

		loEntidad.cContexto = "I"

		this.AssertTrue( 'El contexto debe ser Importacion (1)', !loEntidad.VerificarContexto() )
		this.AssertTrue( 'El contexto debe ser Importacion (2)', !loEntidad.VerificarContexto("") )
		this.AssertTrue( 'El contexto debe ser Importacion (3)', !loEntidad.VerificarContexto(" ") )
		this.AssertTrue( 'El contexto debe ser Importacion (4)', !loEntidad.VerificarContexto( "T" ) )
		this.AssertTrue( 'El contexto debe ser Importacion (5)', loEntidad.VerificarContexto( "I" ) )
		this.AssertTrue( 'El contexto debe ser Importacion (6)', loEntidad.VerificarContexto( "TI" ) )
		this.AssertTrue( 'El contexto debe ser Importacion (7)', loEntidad.VerificarContexto( "IT" ) )

		loEntidad.cContexto = "TI"

		this.AssertTrue( 'El contexto debe ser Transferencia / Importacion (1)', !loEntidad.VerificarContexto() )
		this.AssertTrue( 'El contexto debe ser Transferencia / Importacion (2)', !loEntidad.VerificarContexto("") )
		this.AssertTrue( 'El contexto debe ser Transferencia / Importacion (3)', !loEntidad.VerificarContexto(" ") )
		this.AssertTrue( 'El contexto debe ser Transferencia / Importacion (4)', loEntidad.VerificarContexto( "T" ) )
		this.AssertTrue( 'El contexto debe ser Transferencia / Importacion (5)', loEntidad.VerificarContexto( "I" ) )
		this.AssertTrue( 'El contexto debe ser Transferencia / Importacion (6)', loEntidad.VerificarContexto( "TI" ) )
		this.AssertTrue( 'El contexto debe ser Transferencia / Importacion (7)', loEntidad.VerificarContexto( "IT" ) )

		loEntidad.cContexto = "IT"

		this.AssertTrue( 'El contexto debe ser Importacion / Transferencia (1)', !loEntidad.VerificarContexto() )
		this.AssertTrue( 'El contexto debe ser Importacion / Transferencia (2)', !loEntidad.VerificarContexto("") )
		this.AssertTrue( 'El contexto debe ser Importacion / Transferencia (3)', !loEntidad.VerificarContexto(" ") )
		this.AssertTrue( 'El contexto debe ser Importacion / Transferencia (4)', loEntidad.VerificarContexto( "T" ) )
		this.AssertTrue( 'El contexto debe ser Importacion / Transferencia (5)', loEntidad.VerificarContexto( "I" ) )
		this.AssertTrue( 'El contexto debe ser Importacion / Transferencia (6)', loEntidad.VerificarContexto( "TI" ) )
		this.AssertTrue( 'El contexto debe ser Importacion / Transferencia (7)', loEntidad.VerificarContexto( "IT" ) )

		loEntidad.release()
		
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestLimpiarFlag
		local loEntidad as entidad of entidad.prg, lnCodigo as Integer, loObjetoBindeo as Object, ;
				loError as zooexception OF zooexception.prg

		try 
			loObjetoBindeo = newobject( "ObjetoBindeo" )
			loEntidad = _screen.zoo.instanciarentidad( "Suiza" )
			bindevent( loEntidad, [LimpiarFlag], loObjetoBindeo, [LimpiarFlag] )
		
			with loEntidad
				*-- Test nuevo y Grabar
				loObjetoBindeo.lPasoPorLimpiar = .f.
				.Nuevo()
				This.Asserttrue( "No ejecuto LIMPIARFLAG en NUEVO.", loObjetoBindeo.lPasoPorLimpiar )
								
				.Descripcion = "123456789"
				
				.Grabar()
				lnCodigo = .Codigo

				*-- Test Cancelar
				.Nuevo()
				loObjetoBindeo.lPasoPorLimpiar = .f.
				.Cancelar()
				This.Asserttrue( "No ejecuto LIMPIARFLAG en CANCELAR.", loObjetoBindeo.lPasoPorLimpiar )
			
				*-- Modificar
				loObjetoBindeo.lPasoPorLimpiar = .f.
			
				.Codigo = lnCodigo
				.Modificar()
				This.Asserttrue( "No ejecuto LIMPIARFLAG en MODIFICAR.", loObjetoBindeo.lPasoPorLimpiar )
				
				*-- Eliminar
				loObjetoBindeo.lPasoPorLimpiar = .f.
				.Eliminar()
				This.Asserttrue( "No ejecuto LIMPIARFLAG en ELIMINAR.", loObjetoBindeo.lPasoPorLimpiar )
			endwith
			
		catch to loError
			throw loError
			
		finally
			loEntidad.release()
			loObjetoBindeo = null
			
		EndTry
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestValidarProcesandoEnEventosGenericos
		local loEntidad as entidad OF entidad.prg, loError as zooexception OF zooexception.prg

		_screen.mocks.agregarmock( "alemaniaad" )
		_screen.mocks.agregarmock( "alemaniaad_sqlserver" )
		_screen.mocks.agregarseteometodo( 'Alemaniaad', 'Inyectarentidad', .T., "'*OBJETO'" )
		_screen.mocks.agregarseteometodo( 'Alemaniaad', 'Limpiar', .T. ) 
		_screen.mocks.agregarseteometodo( 'Alemaniaad', 'Insertar', .T. )
		_screen.mocks.agregarseteometodo( 'Alemaniaad_sqlserver', 'Inyectarentidad', .T., "'*OBJETO'" )
		_screen.mocks.agregarseteometodo( 'Alemaniaad_sqlserver', 'Limpiar', .T. ) 
		_screen.mocks.agregarseteometodo( 'Alemaniaad_sqlserver', 'Insertar', .T. )
		
		goServicios.Datos.EjecutarSentencias( "delete from alemania", "alemania", addbs( _Screen.zoo.cRutaInicial ) + "paises\dbf\" )
		
		try 
			loEntidad = newobject( "TestAlemania" )
				
			with loEntidad
				.Nuevo()
				This.asserttrue( "El flag LPROCESANDO debe estar en .T. al hacer NUEVO.", .lPasoPor_Nuevo )
				
				.Eliminar()
				This.asserttrue( "El flag LPROCESANDO debe estar en .T. al hacer ELIMINAR.", .lPasoPor_EliminarSinValidaciones )
				
				.Modificar()
				This.asserttrue( "El flag LPROCESANDO debe estar en .T. al hacer ELIMINAR.", .lPasoPor_Modificar )

				.Cancelar()
				This.asserttrue( "El flag LPROCESANDO debe estar en .T. al hacer CANCELAR.", .lPasoPor_Cancelar )

				.lNuevo = .t.
				.Grabar()
				This.asserttrue( "El flag LPROCESANDO debe estar en .T. al hacer GRABAR.", .lPasoPor_Grabar )
				
			endwith 
	
			
		catch to loError
			loEntidad.lProcesando = .f.
			throw loError
		finally
			loEntidad.Release
		endtry
		
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestImprimir
		local loEntidad as entidad OF entidad.prg, loBindeo as Object

		loBindeo = newobject( "Bindeo" )

		goServicios.Impresion.Detener()
		goServicios.Impresion = newobject( "mockManagerImpresion" )

		loEntidad = _screen.zoo.instanciarentidad( "chipre2" )
		loBindeo.oEntidad = loEntidad
		bindevent( loEntidad, "LimpiarInformacion", loBindeo, "LimpiarInformacion" )

		with this
			loBindeo.lPasoPorPrevisualizarDiseno = .F.
			loBindeo.lPrevisualizarDiseno = .F.
			loBindeo.lEjecutoLimpiarInformacion = .f.
			goServicios.Impresion.lPrevisualizar = .F.
			goServicios.Impresion.oEntidad = null
			goServicios.Impresion.lPasoPorImprimir = .F.

			loEntidad.imprimir()
		
			.AssertTrue( "No llego al goServicios.Impresion", goServicios.Impresion.lPasoPorImprimir )
			.AssertTrue( "Debe ejecutar LIMPIARINFORMACION(2)", loBindeo.lEjecutoLimpiarInformacion )
			.AssertEquals( "La entidad no fue enviada al goServicios.Impresion", loEntidad, goServicios.Impresion.oEntidad )
		
			loBindeo.lEjecutoLimpiarInformacion = .f.
			goServicios.Impresion.oEntidad = null
			goServicios.Impresion.lPasoPorImprimir = .F.
	
			loEntidad.imprimir()

			.AssertTrue( "No llego al goServicios.Impresion", goServicios.Impresion.lPasoPorImprimir )
			.AssertTrue( "Debe ejecutar LIMPIARINFORMACION(2)", loBindeo.lEjecutoLimpiarInformacion )
			.AssertEquals( "La entidad no fue enviada al goServicios.Impresion", loEntidad, goServicios.Impresion.oEntidad )
			
		endwith 

		loBindeo = null
		loEntidad = null
		goServicios.Impresion = null
	endfunc 
	*-----------------------------------------------------------------------------------------
	Function ztestVotacionesNuevo
		local loEntidad as entidad OF entidad.prg, loError as Exception
		
		_screen.mocks.agregarmock( "COMPONENTERIO" )

		_screen.mocks.AgregarSeteoMetodo( 'COMPONENTERIO', 'Inicializar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'COMPONENTERIO', 'Votarcambioestadonuevo', .T., "[NULO]" )
		_screen.mocks.AgregarSeteoMetodo( 'COMPONENTERIO', 'Votarcambioestadocancelar', .T., "[NUEVO]" )
		_screen.mocks.AgregarSeteoMetodo( 'COMPONENTERIO', 'Setearcoleccionsentenciasanterior_nuevo', .T. )
		
		loEntidad = _screen.zoo.instanciarentidad( "Rio2" )

		try 
			loEntidad.nuevo()
		catch to loError 
			This.asserttrue( "Fallo la votacion Estado nuevo.", .f. )
		endtry
		loEntidad.Cancelar()

		_screen.mocks.AgregarSeteoMetodo( 'COMPONENTERIO', 'Votarcambioestadonuevo', .F., "[NULO]" )
		try 
			loEntidad.nuevo()
			This.asserttrue( "No Fallo la votacion Estado nuevo.", .f. )
		catch to loError 
		endtry

		loEntidad.Release()
		
		endfunc

	*-----------------------------------------------------------------------------------------
	function ztestVotacionGrabar
		local loEntidad as entidad OF entidad.prg, loError as Exception, loColRetorno as zoocoleccion OF zoocoleccion.prg

		loColRetorno = _screen.zoo.CrearObjeto( "ZooColeccion" )
		
		_screen.mocks.agregarmock( "COMPONENTERIO" )
		_screen.mocks.AgregarSeteoMetodo( 'COMPONENTERIO', 'Inicializar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'COMPONENTERIO', 'Grabar', loColRetorno )
		_screen.mocks.AgregarSeteoMetodo( 'COMPONENTERIO', 'Votarcambioestadoeliminar', .T., "[NULO]" )
		_screen.mocks.AgregarSeteoMetodo( 'COMPONENTERIO', 'Votarcambioestadonuevo', .T., "[NULO]" )
		_screen.mocks.AgregarSeteoMetodo( 'COMPONENTERIO', 'Setearcoleccionsentenciasanterior_Eliminar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'COMPONENTERIO', 'Setearcoleccionsentenciasanterior_Modificar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'COMPONENTERIO', 'Setearcoleccionsentenciasanterior_nuevo', .T. )

		loEntidad = _screen.zoo.instanciarentidad( "Rio2" )
		try
			loEntidad.Codigo = "UNO"
			loEntidad.Eliminar()
		catch to loError
		endtry

		_screen.mocks.AgregarSeteoMetodo( 'COMPONENTERIO', 'Votarcambioestadograbar', .T., "[NUEVO]" )
		loEntidad.Nuevo()
		loEntidad.Codigo = "UNO"
		try
			loEntidad.Grabar()
		catch to loError
			This.asserttrue( "Fallo la grabacion.", .f. )
		endtry

		try
			loEntidad.Codigo = "DOS"
			loEntidad.Eliminar()
		catch to loError
		endtry

		_screen.mocks.AgregarSeteoMetodo( 'COMPONENTERIO', 'Votarcambioestadograbar', .F., "[NUEVO]" )
		loEntidad.Nuevo()
		loEntidad.Codigo = "DOS"
		try
			loEntidad.Grabar()
			This.asserttrue( "No fallo la grabacion.", .f. )
		catch to loError
		endtry
		
		loEntidad.Release()

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ztestVotacionEliminar
		local loEntidad as entidad OF entidad.prg, loError as Exception, loColRetorno as zoocoleccion OF zoocoleccion.prg

		loColRetorno = _screen.zoo.CrearObjeto( "ZooColeccion" )

		_screen.mocks.agregarmock( "COMPONENTERIO" )
		_screen.mocks.AgregarSeteoMetodo( 'COMPONENTERIO', 'Inicializar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'COMPONENTERIO', 'Grabar', loColRetorno )
		_screen.mocks.AgregarSeteoMetodo( 'COMPONENTERIO', 'Votarcambioestadonuevo', .T., "[NULO]" )
		_screen.mocks.AgregarSeteoMetodo( 'COMPONENTERIO', 'Votarcambioestadocancelar', .T., "[NUEVO]" )
		_screen.mocks.AgregarSeteoMetodo( 'COMPONENTERIO', 'Votarcambioestadograbar', .T., "[NUEVO]" )
		_screen.mocks.AgregarSeteoMetodo( 'COMPONENTERIO', 'Setearcoleccionsentenciasanterior_nuevo', .T. )

		loEntidad = _screen.zoo.instanciarentidad( "Rio2" )
		try
			loEntidad.Nuevo()
			loEntidad.Codigo = "UNO"
			loEntidad.Grabar()
		catch to loError
			loEntidad.cancelar()
		endtry

		_screen.mocks.AgregarSeteoMetodo( 'COMPONENTERIO', 'Votarcambioestadoeliminar', .F., "[NULO]" )
		loEntidad.Codigo = "UNO"
		try
			loEntidad.Eliminar()
			This.asserttrue( "No fallo el eliminar.", .f. )
		catch to loError
		endtry

		_screen.mocks.AgregarSeteoMetodo( 'COMPONENTERIO', 'Votarcambioestadonuevo', .T., "[NULO]" )
		_screen.mocks.AgregarSeteoMetodo( 'COMPONENTERIO', 'Votarcambioestadocancelar', .T., "[NUEVO]" )
		loEntidad.Nuevo()
	
		try
			loEntidad.Cancelar()
		catch to loError
			This.asserttrue( "Fallo el cancelar.", .f. )
		endtry
		
		loEntidad.Release()

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ztestVotacionCancelar
		local loEntidad as entidad OF entidad.prg, loError as Exception

		_screen.mocks.agregarmock( "COMPONENTERIO" )
		_screen.mocks.AgregarSeteoMetodo( 'COMPONENTERIO', 'Inicializar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'COMPONENTERIO', 'Votarcambioestadonuevo', .T., "[NULO]" )
		_screen.mocks.AgregarSeteoMetodo( 'COMPONENTERIO', 'Setearcoleccionsentenciasanterior_nuevo', .T. )
	
		loEntidad = _screen.zoo.instanciarentidad( "Rio2" )

		loEntidad.Nuevo()
		_screen.mocks.AgregarSeteoMetodo( 'COMPONENTERIO', 'Votarcambioestadocancelar', .T., "[NUEVO]" )	
		
		try
			loEntidad.Cancelar()
		catch to loError
			This.asserttrue( "Fallo el cancelar.", .f. )
		endtry

		_screen.mocks.AgregarSeteoMetodo( 'COMPONENTERIO', 'Votarcambioestadocancelar', .F., "[NUEVO]" )
		loEntidad.Nuevo()		
		try
			loEntidad.Cancelar()
			This.asserttrue( "No fallo el cancelar.", .f. )
		catch to loError
		endtry

		loEntidad.Release()
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	Function ztestVotacionModificar
		local loEntidad as entidad OF entidad.prg, loError as Exception

		_screen.mocks.agregarmock( "COMPONENTERIO" )
		_screen.mocks.AgregarSeteoMetodo( 'COMPONENTERIO', 'Inicializar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'COMPONENTERIO', 'Votarcambioestadonuevo', .T., "[NULO]" )
		_screen.mocks.AgregarSeteoMetodo( 'COMPONENTERIO', 'Votarcambioestadograbar', .T., "[NUEVO]" )	
		_screen.mocks.AgregarSeteoMetodo( 'COMPONENTERIO', 'Votarcambioestadocancelar', .T., "[NUEVO]" )
		_screen.mocks.AgregarSeteoMetodo( 'COMPONENTERIO', 'Setearcoleccionsentenciasanterior_modificar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'COMPONENTERIO', 'Setearcoleccionsentenciasanterior_nuevo', .T. )

		loEntidad = _screen.zoo.instanciarentidad( "Rio2" )

		try
			loEntidad.Nuevo()
			loEntidad.Codigo = "UNO"
			loEntidad.Grabar()
		catch to loError
			loEntidad.Cancelar()
		endtry

		_screen.mocks.AgregarSeteoMetodo( 'COMPONENTERIO', 'Votarcambioestadomodificar', .T., "[NULO]" )
		_screen.mocks.AgregarSeteoMetodo( 'COMPONENTERIO', 'Votarcambioestadocancelar', .T., "[EDICION]" )
		loEntidad.Codigo = "UNO"
		try
			loEntidad.Modificar()
			loEntidad.Cancelar()
		catch to loError
			This.asserttrue( "Fallo la modificacion.", .f. )
		endtry
	

		_screen.mocks.AgregarSeteoMetodo( 'COMPONENTERIO', 'Votarcambioestadomodificar', .F., "[NULO]" )

		loEntidad.Codigo = "UNO"
		try
			loEntidad.Modificar()
			This.asserttrue( "No fallo la modificacion.", .f. )
		catch to loError
		endtry

		loEntidad.Release()

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestNativaEntidadPuesto
		local loEntidad as din_entidadBasededatos OF din_entidadBasededatos.prg, lcRutaAnt as string, lcRutaTemp as string, lcArchivo as string,;
		lcArcObs as String, lcArcObs2 as String

		lcRutaAnt = _Screen.zoo.app.cRutaTablasPuesto
		lcRutaTemp = _Screen.zoo.ObtenerRutaTemporal()
		_Screen.zoo.app.cRutaTablasPuesto = lcRutaTemp
		lcArchivo = addbs( lcRutaTemp ) + "host.dbf"
		lcArcObs = addbs( lcRutaTemp ) + "host_obs.dbf"
		lcArcObs2 = addbs( lcRutaTemp ) + "host_ZADSFW.dbf"
		
		copy file ( addbs( lcRutaAnt ) + "host.*" ) to ( addbs( lcRutaTemp ) + "host.*" )
		copy file ( addbs( lcRutaAnt ) + "host_obs.*" ) to ( addbs( lcRutaTemp ) + "host_obs.*" )
		copy file ( addbs( lcRutaAnt ) + "host_ZADSFW.*" ) to ( addbs( lcRutaTemp ) + "host_ZADSFW.*" )		
		
		select 0
		use ( lcArchivo )
		delete all
		use
		
		loEntidad = _screen.zoo.instanciarentidad( "buzon" )	
		this.assertequals( "Error en la ruta de las tablas", lcRutaTemp, loEntidad.oAd.cRutaTablas )
		
		loEntidad.Nuevo()
		loEntidad.Codigo = "COD1"
		loEntidad.serie = 123345
		loEntidad.directorio = lcRutaTemp
		loEntidad.Grabar()

		loEntidad.Nuevo()
		loEntidad.Codigo = "COD2"
		loentidad.Serie = 123345
		loEntidad.Directorio = lcRutaTemp
		loEntidad.Grabar()

		select 0
		use ( lcArchivo ) shared again
		go top
		this.assertequals( "No se grabó COD1 en el puesto", "COD1", alltrim( upper( host.HOSCOD ) ) )
		skip
		this.assertequals( "No se grabó COD2 en el puesto", "COD2", alltrim( upper( host.HOSCOD ) ) )
		use
		
		loEntidad.Primero()
		this.assertequals( "No se obtuvo el primero dato en el puesto", "COD1", alltrim( upper( loEntidad.Codigo ) ) )
		
		loEntidad.Ultimo()
		this.assertequals( "No se obtuvo el último dato en el puesto", "COD2", alltrim( upper( loEntidad.Codigo ) ) )
		
		loEntidad.Anterior()
		this.assertequals( "No se obtuvo el anterior dato en el puesto", "COD1", alltrim( upper( loEntidad.Codigo ) ) )
		
		loEntidad.Siguiente()
		this.assertequals( "No se obtuvo el siguiente dato en el puesto", "COD2", alltrim( upper( loEntidad.Codigo ) ) )
		
		loEntidad.Codigo = "COD1"
		this.assertequals( "No se obtuvo el dato buscado en el puesto", "COD1", alltrim( upper( loEntidad.Codigo ) ) )
		
		loEntidad.Eliminar()
		
		select 0
		use ( lcArchivo ) shared again
		locate for !deleted() and alltrim( upper( host.HOSCOD ) ) == "COD1"
		this.assertequals( "No se eliminó el dato en el puesto", found() )
		use
		loEntidad.release()
		_Screen.zoo.app.cRutaTablasPuesto = lcRutaAnt
		if file( lcArchivo )
			delete file ( lcArchivo )
		endif
		if file( lcArcObs )
			delete file ( lcArcObs )
		endif		
		if file( lcArcObs2 )
			delete file ( lcArcObs2 )
		endif	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestEntidadOrganizacion_SqlServer
		local loEntidad as din_entidadBasededatos OF din_entidadBasededatos.prg, lcArchivo as string, ;
				loError as Exception, loEx as zooexception OF zooexception.prg 
		
		loEntidad = _screen.zoo.instanciarentidad( "SeguridadOperacion" )	
		this.assertequals( "Error en la ubicacion de las tablas", "ORGANIZACION", loEntidad.oAd.cUbicacionDB )
		
		try
			loEntidad.Codigo = "AAA"
			loEntidad.Eliminar()
		catch
		endtry
		
		try
			loEntidad.Codigo = "ZZZ1"
			loEntidad.Eliminar()
		catch
		endtry
		
		try
			loEntidad.Codigo = "ZZZ2"
			loEntidad.Eliminar()
		catch
		endtry

		loEntidad.Nuevo()
		loEntidad.Codigo = "AAA"
		loEntidad.Grabar()

		loEntidad.Nuevo()
		loEntidad.Codigo = "ZZZ1"
		loEntidad.Grabar()

		loEntidad.Nuevo()
		loEntidad.Codigo = "ZZZ2"
		loEntidad.Grabar()

		loEntidad.Primero()
		this.assertequals( "No se obtuvo el primero dato en el organizacion", "AAA", alltrim( upper( loEntidad.Codigo ) ) )
		
		loEntidad.Ultimo()
		this.assertequals( "No se obtuvo el último dato en el organizacion", "ZZZ2", alltrim( upper( loEntidad.Codigo ) ) )
		
		loEntidad.Anterior()
		this.assertequals( "No se obtuvo el anterior dato en el organizacion", "ZZZ1", alltrim( upper( loEntidad.Codigo ) ) )
		
		loEntidad.Siguiente()
		this.assertequals( "No se obtuvo el siguiente dato en el organizacion", "ZZZ2", alltrim( upper( loEntidad.Codigo ) ) )
		
		loEntidad.Codigo = "AAA"
		this.assertequals( "No se obtuvo el dato buscado en el organizacion", "AAA", alltrim( upper( loEntidad.Codigo ) ) )

		loEntidad.Eliminar()
		
		try
			loEntidad.Codigo = "AAA"
			this.asserttrue( "Debe dar error", .f. )
		catch to loError
			loEx = Newobject( "ZooException", "ZooException.prg" )
			With loEx
				.Grabar( loError )
			EndWith
			
			this.assertequals( "El error no se debio a que el codigo fue eliminado", "El dato buscado AAA de la entidad OPERACIONES DE SEGURIDAD no existe.", loEx.oInformacion.item[ 1 ].cMensaje )
		endtry

		try
			loEntidad.Codigo = "ZZZ1"
			loEntidad.Eliminar()
		catch
		endtry
		
		try
			loEntidad.Codigo = "ZZZ2"
			loEntidad.Eliminar()
		catch
		endtry
		loEntidad.Release()	
	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	function ztestEntidadYRegistroModificable
		local loEntidad as Object, loError as zooexception OF zooexception.prg

		loEntidad = _Screen.Zoo.InstanciarEntidad( 'Cuba' )

		try
			loEntidad.Codigo = "C1"
			loEntidad.oAd.Eliminar()
		catch
		endtry
		
		loEntidad.Nuevo()
		loEntidad.Codigo = "C1"
		loEntidad.BloquearRegistro = .t.
		loEntidad.Grabar()

		try
			loEntidad.Nuevo()
		catch to loError
			this.Asserttrue( "No deberia tirar error al hacer nuevo", .f. )		
		endtry
		loEntidad.Cancelar()
		
		try
			loEntidad.Codigo = "C1"
			loEntidad.Modificar()
			this.Asserttrue( "Deberia tirar error al modificar el registro (1)", .f. )
		catch to loError
		endtry
		
		this.Assertequals( "El error es incorrecto (1)", "EL REGISTRO DE LA ENTIDAD CUBA NO PUEDE SER MODIFICADO PORQUE ES SÓLO LECTURA.", alltrim( upper( loError.Uservalue.oInformacion.Item[1].cMensaje )))
		
		try
			loEntidad.Codigo = "C1"
			loEntidad.Eliminar()
			this.Asserttrue( "Deberia tirar error al eliminar el registro (2)", .f. )
		catch to loError
		endtry
		
		this.Assertequals( "El error es incorrecto (2)", "EL REGISTRO DE LA ENTIDAD CUBA NO PUEDE SER ELIMINADO PORQUE ES SÓLO LECTURA.", alltrim( upper( loError.Uservalue.oInformacion.Item[1].cMensaje )))
		
		loEntidad.Release()
		
		loEntidad = _screen.zoo.instanciarentidad( "Bulgaria" )
		
		try
			loEntidad.Nuevo()
			this.Asserttrue( "Deberia tirar error al hacer nuevo", .f. )
		catch to loError
		endtry

		this.Assertequals( "El error es incorrecto (1)", "LA ENTIDAD BULGARIA NO PUEDE SER MODIFICADA.", alltrim( upper( loError.Uservalue.oInformacion.Item[1].cMensaje )))

		try
			loEntidad.Modificar()
			this.Asserttrue( "Deberia tirar error al modificar", .f. )
		catch to loError
		endtry
		
		this.Assertequals( "El error es incorrecto (2)", "LA ENTIDAD BULGARIA NO PUEDE SER MODIFICADA.", alltrim( upper( loError.Uservalue.oInformacion.Item[1].cMensaje )))
		
		try
			loEntidad.Eliminar()
			this.Asserttrue( "Deberia tirar error al eliminar", .f. )
		catch to loError
		endtry
		
		this.Assertequals( "El error es incorrecto (3)", "LA ENTIDAD BULGARIA NO PUEDE SER MODIFICADA.", alltrim( upper( loError.Uservalue.oInformacion.Item[1].cMensaje )))			

		loEntidad.Release()		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function ztestValidarExtensionesVarias
		local loEnt as entidad OF entidad.prg, llValidar as Boolean

		=CopiarExtension()
		loEnt = _screen.zoo.instanciarentidad( "Argentina" )
		with loEnt
			.Nuevo()
			.Codigo = 19
			.Descripcion = "SOLO ARG"
			llValidar = .validar()
			This.asserttrue( "La extension no permite una descripcion SOLO ARG", !llValidar )
			
			.Cancelar()
			.oExtension = null
			.Release()
		endwith		
		=BorrarExtension()
		loEnt = _screen.zoo.instanciarentidad( "Argentina" )
		with loEnt
			.Nuevo()
			.Codigo = 19
			.Descripcion = "SOLO ARG"
			llValidar = .validar()
			This.asserttrue( "La extension permite una descripcion SOLO ARG", llValidar )
			
			.Cancelar()
			.oExtension = null
			.Release()
		endwith		

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function ztestEsExtensionValidaParaFox
		local loEnt as entidad OF entidad.prg, loCol as zoocoleccion OF zoocoleccion.prg

		loEnt = newobject( "ArgentinaAux" )

		this.AssertTrue( "No debería validar esta extension.", !loEnt.EsExtensionValidaParaFoxAux( ".BAK" ) )
		this.AssertTrue( "Debería validar esta extension.", loEnt.EsExtensionValidaParaFoxAux( ".PRG" ) )
		
		loEnt.Release()

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function ztestObtenerExtensionesValidasParaFox
		local loEnt as entidad OF entidad.prg, loCol as zoocoleccion OF zoocoleccion.prg

		loEnt = newobject( "ArgentinaAux" )

		loCol = loEnt.ObtenerExtensionesValidasParaFoxAux()
		this.AssertEquals( "No coinciden las cantidades de extensiones.", 2, loCol.Count )
		this.AssertEquals( "Extension incorrecta(1).", ".FXP", loCol(1) )
		this.AssertEquals( "Extension incorrecta(2).", ".PRG", loCol(2) )
		
		loEnt.Release()

	endfunc 

	*-----------------------------------------------------------------------------------------
	Function ztestValidarFiltradoExtensiones
		local loEnt as entidad OF entidad.prg, loCol as zoocoleccion OF zoocoleccion.prg

		=CopiarExtension()
		loEnt = newobject( "ArgentinaAux" )

		loCol = loEnt.ObtenerExtensionesAux()
		this.AssertEquals( "No filtro correctamente las extensiones.", 2, loCol.Count )
		
		=BorrarExtension()
		loEnt.Release()

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestLogueoAcciones
		local loEntidad as entidad OF entidad.prg, loLogueos as Object 
		this.agregarmocks( "Numeraciones" )
		_screen.mocks.AgregarSeteoMetodo( 'NUMERACIONES', 'Inicializar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'NUMERACIONES', 'Setearentidad', .T., "'*OBJETO'" )
		_screen.mocks.AgregarSeteoMetodo( 'NUMERACIONES', 'Obtenernumero', 1, "[Habitantes]" )
		_screen.mocks.AgregarSeteoMetodo( 'NUMERACIONES', 'Grabar', 1, "[Habitantes]" )
		_screen.mocks.AgregarSeteoMetodo( 'NUMERACIONES', 'Obtenerservicio', .T., "[Habitantes]" )
		_screen.mocks.AgregarSeteoMetodo( 'NUMERACIONES', 'Talonarioconnumeraciondisponible', .T. )
		
		loLogueos = goServicios.Logueos
		goServicios.Logueos = _Screen.zoo.crearobjeto( "mock_managerlogueos" )
		****El mock me guarda todo lo que se va mandando a loguear, y me elimina los chr(10) y chr(13)
				
		loEntidad = _Screen.zoo.instanciarentidad( "RepublicaDominicana" )
				
		with loEntidad
			try
				.Codigo = "COD1"
				.Eliminar()
			catch 
			endtry
			goServicios.logueos.cMensajesSerializados = ""

			.Nuevo()
			.Cancelar()
			
			this.assertequals( "Error en el texto logueado 1", "", goServicios.logueos.cMensajesSerializados )
						
			.Nuevo()
			.Codigo = "COD1"
			.Nombre = "Una desc."
			.Grabar()

			this.assertequals( "Error en el texto logueado 2", "REPUBLICADOMINICANA -> Nuevo: CODIGO COD1." ,;
			 goServicios.logueos.cMensajesSerializados )
						
			.Codigo = "COD1"
			.Modificar()
			.Cancelar()
			
			this.assertequals( "Error en el texto logueado 3", "REPUBLICADOMINICANA -> Nuevo: CODIGO COD1.", ;
			 goServicios.logueos.cMensajesSerializados )
						
			.Modificar()
			.Nombre = "Otra desc."
			.Grabar()
			
			this.assertequals( "Error en el texto logueado 4", ;
			"REPUBLICADOMINICANA -> Nuevo: CODIGO COD1.REPUBLICADOMINICANA -> Modificar: CODIGO COD1.", goServicios.logueos.cMensajesSerializados )

			.release()
		endwith
		
		loEntidad = _Screen.zoo.instanciarEntidad( "Mexico" )
	
		with loEntidad
			try
				.Codigo = 1
				.Anular()
				.Eliminar()
			catch 
			endtry
			goServicios.logueos.cMensajesSerializados = ""
			
			.Nuevo()
			.Cancelar()
			
			this.assertequals( "Error en el texto logueado 5", "", goServicios.logueos.cMensajesSerializados )
			
			.Nuevo()
			.Codigo = 1
			.Nombre = "Nombre1"
			.Presidente = "UnPresidente"
			.Habitantes = 2
			.Grabar()

			this.assertequals( "Error en el texto logueado 6", "MEXICO -> Nuevo: NOMBRE Nombre1, PRESIDENTE UnPresidente, CODIGO 1.", goServicios.logueos.cMensajesSerializados )
			
			.Codigo = 1
			.Modificar()
			.Cancelar()
			
			this.assertequals( "Error en el texto logueado 7", "MEXICO -> Nuevo: NOMBRE Nombre1, PRESIDENTE UnPresidente, CODIGO 1.", goServicios.logueos.cMensajesSerializados )
						
			.Modificar()
			.Presidente = "OtroPresidente"
			.Grabar()
			
			this.assertequals( "Error en el texto logueado 8", ;
			 "MEXICO -> Nuevo: NOMBRE Nombre1, PRESIDENTE UnPresidente, CODIGO 1.MEXICO -> Modificar: NOMBRE Nombre1, PRESIDENTE OtroPresidente, CODIGO 1.", ;
			 goServicios.logueos.cMensajesSerializados )

			.Anular()
			this.assertequals( "Error en el texto logueado 9", ; 
			 "MEXICO -> Nuevo: NOMBRE Nombre1, PRESIDENTE UnPresidente, CODIGO 1.MEXICO -> Modificar: NOMBRE Nombre1, PRESIDENTE OtroPresidente, CODIGO 1.MEXICO -> Anular: NOMBRE Nombre1, PRESIDENTE OtroPresidente, CODIGO 1.", ;
			 goServicios.logueos.cMensajesSerializados )
			
			.Eliminar()
			this.assertequals( "Error en el texto logueado 10", ; 
			 "MEXICO -> Nuevo: NOMBRE Nombre1, PRESIDENTE UnPresidente, CODIGO 1.MEXICO -> Modificar: NOMBRE Nombre1, PRESIDENTE OtroPresidente, CODIGO 1.MEXICO -> Anular: NOMBRE Nombre1, PRESIDENTE OtroPresidente, CODIGO 1." + ;
			 "MEXICO -> Eliminar: NOMBRE Nombre1, PRESIDENTE OtroPresidente, CODIGO 1.", ;
			 goServicios.logueos.cMensajesSerializados )
			
			.release()
		endwith
		goServicios.logueos = loLogueos 
	endfunc	
	
	*-----------------------------------------------------------------------------------------
	function zTestValidacionDetalleObligatorio
		local loEntidad as entidad OF entidad.prg, loObjetoValidacion as zooinformacion of zooInformacion.prg, llValida as Boolean
		
		loEntidad = _Screen.Zoo.InstanciarEntidad( "NASDROVIA" )
		with loEntidad
			.Nuevo()
			
			.Codigo = right( sys( 2015 ), 5 )
			llValida = .Validar()
			loObjetoValidacion = .ObtenerInformacion()

			This.asserttrue( "Deberia haber fallado la validacion.", !llValida )
			This.Assertequals( "La cantidad de mensajes es incorrecta(1).", 1, loObjetoValidacion.Count )
		
				
			with .Republicas
				.LimpiarItem()
				.oItem.Codigo = "1"
				.oItem.Nombre = "Nobre"
				.oItem.Descripcion = "Descrip"
				.Actualizar()
			endwith

			.LimpiarInformacion()
			llValida = .Validar()
			loObjetoValidacion = .ObtenerInformacion()

			This.asserttrue( "No deberia haber fallado la validacion.", llValida )
			This.Assertequals( "La cantidad de mensajes es incorrecta.(2)", 0, loObjetoValidacion.Count )
			
			.Release()
			
		Endwith
	
	endfunc 	


	*-----------------------------------------------------------------------------------------
	function zTestEntidadAnulableGenerica
		local loEntidad as entidad OF entidad.prg, loex as exception, loBindeos as Object

		this.agregarmocks( "Numeraciones" )
		_screen.mocks.AgregarSeteoMetodo( 'NUMERACIONES', 'Inicializar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'NUMERACIONES', 'Setearentidad', .T., "'*OBJETO'" )
		_screen.mocks.AgregarSeteoMetodo( 'NUMERACIONES', 'Obtenernumero', 1, "[Habitantes]" )
		_screen.mocks.AgregarSeteoMetodo( 'NUMERACIONES', 'Grabar', 1, "[Habitantes]" )
		_screen.mocks.AgregarSeteoMetodo( 'NUMERACIONES', 'Obtenerservicio', .T., "[Habitantes]" )
		_screen.mocks.AgregarSeteoMetodo( 'NUMERACIONES', 'Talonarioconnumeraciondisponible', .T. )
	
		loEntidad = _Screen.zoo.instanciarentidad("mexico")
		loBindeos = newobject("objetoBindeos")
		loBindeos.oEntidad = loEntidad
	
		bindevent(loEntidad, "EventoPreguntarEliminar", loBindeos, "EventoPreguntarEliminar" )
		bindevent(loEntidad, "EventoPreguntarAnular", loBindeos, "EventoPreguntarAnular" )
		
		with loEntidad as entidad OF entidad.prg
			try
				.codigo = 1
				.anular()
				.eliminar()
			catch 
			endtry
			try
				.codigo = 2
				.anular()
				.eliminar()
			catch 
			endtry

			loBindeos.nLlamadasAnular = 0
			loBindeos.nLlamadasEliminar = 0

			.nuevo()
			.codigo = 1
			.presidente = "Este no se va a anular"
			.grabar()
			
			.nuevo()
			.codigo = 2
			.presidente = "Este SI se va a anular"
			.grabar()

			.primero()			

			try
				.eliminar()
				this.asserttrue( "Tiene que dar error al eliminar sin anular", .F. )
			Catch To loError
				this.assertequals( "Esta mal el mensaje al eliminar sin anular", "No se puede eliminar un comprobante no anulado", loError.uservalue.oInformacion.item(1).cmensaje )
			Finally
			EndTry
			
			this.assertequals( "No tendria que haber llamado al evento preguntareliminar", 0, loBindeos.nLlamadasEliminar )

			.ultimo()
			Try
				.anular()
			Catch To loError
				this.asserttrue( "No debe dar error al anular", .F. )
			Finally
			EndTry
			this.assertequals( "Tendria que haber llamado al evento preguntarAnular", 1, loBindeos.nLlamadasAnular )
			
			Try
				.eliminar()
			Catch To loError
				this.asserttrue( "No tiene que pinchar al eliminar un anulado", .f. )
			Finally
			endtry
			this.assertequals( "Tendria que haber llamado al evento preguntarEliminar", 1, loBindeos.nLlamadasEliminar )
	
			
			.Primero()
			loBindeos.lRespuestaAnular = .F.
			Try
				.anular()
			Catch To loError
				this.asserttrue( "No debe dar error al anular", .F. )
			Finally
			endtry
				
			
			this.asserttrue( "Error en el lAnulado, NO tendria que haber anulado", !loEntidad.Anulado )
			this.assertequals( "Tendria que haber llamado al evento preguntarAnular", 2, loBindeos.nLlamadasAnular )			
			
			loBindeos.lRespuestaAnular = .T.
			Try
				.anular()
			Catch To loError
				this.asserttrue( "No debe dar error al anular", .F. )
			Finally
			endtry
			
			this.asserttrue( "Error en el lAnulado, SI tendria que haber anulado", loEntidad.Anulado )
			this.assertequals( "Tendria que haber llamado al evento preguntarAnular", 3, loBindeos.nLlamadasAnular )
	
			Try
				.anular()
				this.asserttrue("No tendria que volver a anular un registro ya anulado", .F.)
			Catch To loError
				this.assertequals("Error al intentar anular por segunda vez", "El comprobante ya se encuentra anulado", loError.uservalue.oinformacion.item(1).cmensaje )
			Finally
			endtry

			Try
				.eliminar()
			Catch To loError
				this.asserttrue( "No debe dar error al eliminar", .F. )
			Finally
			endtry						

			.release()
		endwith
	endfunc 	

	*-----------------------------------------------------------------------------------------
	function zTestU_DespuesDeAnular
		local loEntidad as entidad OF entidad.prg, loBindeos as Object
		
		loEntidad = _screen.zoo.instanciarentidad( "Mexico" )
		loBindeos = newobject( "ObjetoBindeos" )
		bindevent( loEntidad, "DespuesDeAnular", loBindeos, "EventoDespuesDeAnular" )
		loBindeos.lPasoPorDespuesDeAnular = .f.

		*
		loEntidad.lWHModificar = .T.
		goservicios.webhook = newobject("WebHook_fake")
		*

		with loEntidad as entidad OF entidad.prg
			try
				.codigo = 1
				.anular()
				.eliminar()
			catch
			finally
				.nuevo()
				.codigo = 1
				.presidente = "nada"
				.grabar()
			endtry

			try
				.codigo = 1
				.anular()
				.eliminar()
			catch
			endtry
		endwith

		this.asserttrue( "No pasó...!!!", loBindeos.lPasoPorDespuesDeAnular )
		this.assertTrue( "Debería haber ejecutado el método goservicios.webhook.Enviar()", goservicios.webhook.lPasoPorElEnviar )		
		this.assertequals("El evento a enviar del servicio WebHook no es el esperado","MODIFICAR", goservicios.webhook.cEvento )
		
		loEntidad.release()
		loBindeos = null
	endfunc
	*-----------------------------------------------------------------------------------------
	function ztestU_ImportarSinTransaccion
		*ImportarSinTransaccion
		local loEntidad as entidad of entidad.prg
		loEntidad = newobject( "TestEntidadAbstracta" )
		loEntidad.oAd = newobject( "TestAccesoDatosEntidadAbstracta" )
		This.Asserttrue( "debia estar en verdadero 1", loEntidad.oAd.lProcesarConTransaccion )
		loEntidad.Importar_SinTransaccion()
		This.Asserttrue( "no paso por el metodo importar del acceso a datos", loEntidad.oAd.lPasoPorMetodoImportar )
		This.Asserttrue( "no proceso sin transaccion", !loEntidad.oAd.lProcesarConTransaccionEstabaEn )
		This.Asserttrue( "debia estar en verdadero 2", loEntidad.oAd.lProcesarConTransaccion )		
		
		loEntidad.release()
	endfunc 
	*-----------------------------------------------------------------------------------------
	function zTestValidarExistenciaDelEventoAdvertirLimitePorDiseno
		local loEntidad as entidad of entidad.prg
		
		loEntidad = newobject( "TestEntidadAbstracta" )
		this.asserttrue( "No se encuentra el evento EventoAdvertirLimitePorDiseno", pemstatus( loEntidad, "EventoAdvertirLimitePorDiseno", 5 ) )
		loEntidad.release()

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ztestU_EventoVerificarLimitesEnDisenoImpresion
		local loEntidad as entidad of entidad.prg
		
		loEntidad = newobject( "TestEntidadAbstracta" )
		loEntidad.EventoVerificarLimitesEnDisenoImpresion( "VALOR" )
		loEntidad.release()

	endfunc 
	*-----------------------------------------------------------------------------------------
	function ztestU_VerificarLimitesEnDisenoImpresion
		local loEntidad as entidad of entidad.prg, loObjetoLimite as Object

		loEntidad = newobject( "TestEntidadAbstracta" )
		loEntidad.AddProperty( "DetalleAbstracto" )
		loEntidad.DetalleAbstracto = newobject( "AbstractoDetalle" )

		goServicios.Impresion.Detener()
		_Screen.Mocks.Agregarmock( "ManagerImpresion" )
		goServicios.Impresion = _Screen.zoo.Crearobjeto( "ManagerImpresion" )
		_Screen.Mocks.AgregarSeteometodo( "ManagerImpresion", "ObtenerObjetoConLimitesDeImpresion", null, "'*OBJETO','DetalleAbstracto'" ) 


		loEntidad.VerificarLimitesEnDisenoImpresion( "DetalleAbstracto" )
		This.AssertEquals( "Se modifico el detalle nLimiteSegunDisenoImpresion", 0, loEntidad.DetalleAbstracto.nLimiteSegunDisenoImpresion )
		This.AssertEquals( "Se modifico el detalle nTipoDeValidacionSegunDisenoImpresion", 0, loEntidad.DetalleAbstracto.nTipoDeValidacionSegunDisenoImpresion )
		This.AssertEquals( "Se modifico el detalle cDisenoLimitador", "", loEntidad.DetalleAbstracto.cDisenoLimitador )
		This.AssertEquals( "Se modifico el detalle cAtributosAgrupamiento", "NroItem", loEntidad.DetalleAbstracto.cAtributosAgrupamiento )
								
		loObjetoLimite = _Screen.Zoo.CrearObjeto( "ObjetoLimite", "ManagerImpresion.Prg" )
		loObjetoLimite.Limite = 1000		
		loObjetoLimite.Restriccion = 1
		loObjetoLimite.Diseno = "MANZANA"
		loObjetoLimite.AtributosAgrupamiento = "TITO"

		_Screen.Mocks.AgregarSeteometodo( "ManagerImpresion", "ObtenerObjetoConLimitesDeImpresion", loObjetoLimite, "'*OBJETO','DetalleAbstracto'" ) 		
		loEntidad.VerificarLimitesEnDisenoImpresion( "DetalleAbstracto" )
		This.AssertEquals( "Se modifico el detalle nLimiteSegunDisenoImpresion 1", 1000, loEntidad.DetalleAbstracto.nLimiteSegunDisenoImpresion )
		This.AssertEquals( "Se modifico el detalle nTipoDeValidacionSegunDisenoImpresion 1", 1, loEntidad.DetalleAbstracto.nTipoDeValidacionSegunDisenoImpresion )
		This.AssertEquals( "Se modifico el detalle cDisenoLimitador 1", "MANZANA", loEntidad.DetalleAbstracto.cDisenoLimitador )
		This.AssertEquals( "Se modifico el detalle cAtributosAgrupamiento 1", "TITO", loEntidad.DetalleAbstracto.cAtributosAgrupamiento )

		_Screen.Mocks.AgregarSeteometodo( "ManagerImpresion", "ObtenerObjetoConLimitesDeImpresion", null, "'*OBJETO','DetalleAbstracto'" ) 
		
		loEntidad.VerificarLimitesEnDisenoImpresion( "DetalleAbstracto" )
		This.AssertEquals( "Se modifico el detalle nLimiteSegunDisenoImpresion 2", 0, loEntidad.DetalleAbstracto.nLimiteSegunDisenoImpresion )
		This.AssertEquals( "Se modifico el detalle nTipoDeValidacionSegunDisenoImpresion 2", 0, loEntidad.DetalleAbstracto.nTipoDeValidacionSegunDisenoImpresion )
		This.AssertEquals( "Se modifico el detalle cDisenoLimitador 2", "", loEntidad.DetalleAbstracto.cDisenoLimitador )
		This.AssertEquals( "Se modifico el detalle cAtributosAgrupamiento 2", "NroItem", loEntidad.DetalleAbstracto.cAtributosAgrupamiento )

		goServicios.Impresion = null
		loEntidad.Release()	

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestU_ObtenerSentenciasUpdateFechaHoraModificacion
		local loEntidad as entidad of entidad.prg, loSentencias as collection

		*Arrange (Preparar)
		this.agregarmocks( "Librerias" )
		_screen.mocks.AgregarSeteoMetodo( 'Librerias', 'ObtenerFecha', {05/02/2004} )
		_screen.mocks.AgregarSeteoMetodo( 'Librerias', 'ObtenerHora', "12:45:00" )
		_screen.mocks.AgregarSeteoMetodo( 'Librerias', 'Obtenernombresucursal', _screen.zoo.app.cBDMaster, "["+_screen.zoo.app.cBDMaster+"]" )

		goServicios.Librerias = _screen.zoo.CrearObjeto( "Librerias" )
		loSentencias = newobject( "collection" )
		this.mockearaccesodatos( "honduras" )
		_screen.mocks.AgregarSeteoMetodo( 'Hondurasad', 'Obtenersentenciasupdate', loSentencias )
		_screen.mocks.AgregarSeteoMetodo( 'Hondurasad_sqlserver', 'Obtenersentenciasupdate', loSentencias )
		loEntidad = _screen.zoo.InstanciarEntidad( "honduras" )

		*Act (Actuar)
		loSentencias = loEntidad.ObtenerSentenciasUpdate()

		*Assert (Afirmar)
		this.assertequals( "No se seteó la fecha de modificación de framework correctamente", {05/02/2004}, loEntidad.FechaModificacionFW )
		this.assertequals( "No se seteó la hora de modificación de framework correctamente", "12:45:00", loEntidad.HoraModificacionFW )
		goServicios.Librerias = goLibrerias
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestU_ObtenerNombreTransferencia
		local loEntidad as entidad of entidad.prg, loSentencias as collection

		loEntidad = _screen.zoo.InstanciarEntidad( "honduras" )

		this.assertEquals( "El nombre de la transferencia es incorrecto. 1", "HONDURAS", loEntidad.ObtenerNombreTransferencia() )
		this.assertEquals( "El nombre de la transferencia es incorrecto. 2", loEntidad.obtenernombre(), loEntidad.ObtenerNombreTransferencia() )
		loEntidad.release()
	endfunc	

	*-----------------------------------------------------------------------------------------
	Function zTestU_LlamarVerificarDisponibilidadTalonarioDespuesDeGrabar
		
		local loEntidad as entidad of entidad.prg

		*Arrange (Preparar)
		loEntidad = newobject( "TestEntidadConTalonario" )
		
		*Act (Actuar)
		loEntidad.DespuesDeGrabar()

		*Assert (Afirmar)
		this.AssertTrue( "No llamo a la verificacion de disponibilidad de talonario despues de grabar", loEntidad.lLlamoVerificarDisponibilidadTalonario )

		loEntidad.Release()

	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestU_ErrorAlModificarUnRegistroInactivo
		local loEntidad as Object, lcCodigo as String, loError as Exception

	*Arrange (Preparar)
		loEntidad = _screen.zoo.InstanciarEntidad( "Honduras" )
		lcCodigo = substr( sys( 2015 ), 2 )
		loEntidad.Nuevo()
		loEntidad.Codigo = lcCodigo
		loEntidad.InactivoFW = .t.
		loEntidad.Grabar()
	*Act (Actuar)
		try
			loEntidad.Modificar()
			this.asserttrue( "Debería dar error", .f. )
		catch to loError
	*Assert (Afirmar)
			this.assertequals( "El error no es el correcto", "El registro de la entidad " + ;
				"Honduras no puede ser modificado porque está Inactivo.", loError.UserValue.oInformacion.Item[1].cMensaje )
		finally
			loEntidad.Eliminar()
			loEntidad.Release()
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestU_SINErrorAlModificarUnRegistroActivo
		local loEntidad as Object, lcCodigo as String, loError as Exception

	*Arrange (Preparar)
		loEntidad = _screen.zoo.InstanciarEntidad( "Honduras" )
		lcCodigo = substr( sys( 2015 ), 2 )
		loEntidad.Nuevo()
		loEntidad.Codigo = lcCodigo
		loEntidad.Grabar()
	*Act (Actuar)
		try
			loEntidad.Modificar()
		catch to loError
	*Assert (Afirmar)
			this.asserttrue( "No debería dar error", .f. )
		finally
			loEntidad.oDesactivador.Desactivar()
			loEntidad.Eliminar()
			loEntidad.Release()
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestU_SINErrorAlEliminarUnRegistroActivo
		local loEntidad as Object, lcCodigo as String, loError as Exception

	*Arrange (Preparar)
		loEntidad = _screen.zoo.InstanciarEntidad( "Honduras" )
		lcCodigo = substr( sys( 2015 ), 2 )
		loEntidad.Nuevo()
		loEntidad.Codigo = lcCodigo
		loEntidad.InactivoFW = .t.
		loEntidad.Grabar()
	*Act (Actuar)
		try
			loEntidad.Eliminar()
		catch to loError
	*Assert (Afirmar)
			this.asserttrue( "No debería dar error", .f. )
		finally
			loEntidad.Release()
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestU_SINErrorAlEliminarUnRegistroInactivo
		local loEntidad as Object, lcCodigo as String, loError as Exception

	*Arrange (Preparar)
		loEntidad = _screen.zoo.InstanciarEntidad( "Honduras" )
		lcCodigo = substr( sys( 2015 ), 2 )
		loEntidad.Nuevo()
		loEntidad.Codigo = lcCodigo
		loEntidad.InactivoFW = .f.
		loEntidad.Grabar()
	*Act (Actuar)
		try
			loEntidad.Eliminar()
		catch to loError
	*Assert (Afirmar)
			this.asserttrue( "No debería dar error", .f. )
		finally
			loEntidad.Release()
		endtry
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function zTestU_AntesDeFinalizarRecibir
		local loEntidad as entidad OF entidad.prg, loSubscriptor as Object
		loEntidad = _screen.zoo.instanciarentidad( "CUBA" )
		loEntidad.oAd = _screen.zoo.crearobjeto( "AccesoDatosAuxiliar", "zTestEntidad.prg" )
		loSubscriptor = _screen.zoo.crearobjeto( "SubscriptorAntesDeFinalizarRecibir", "zTestEntidad.prg" )
		bindevent( loEntidad, "AntesDeFinalizarRecibir", loSubscriptor, "DelegadoAntesDeFinalizar" )
		loEntidad.Recibir( _screen.zoo.crearobjeto( "ZooColeccion" ), .f. )
		this.asserttrue( "Debería haber invocado al método AntesDeFinalizarRecibir.", loSubscriptor.lPaso )
		loEntidad.release()
	endfunc

		*-----------------------------------------------------------------------------------------
	function zTestU_AccessFechaYHoraModificacionAlAnular
		local loEnt as entidad OF entidad.prg, ldFecha as date(), lcHora as String 
		ldFecha = date()
		lcHora = time()

		goServicios.Librerias = this.oServicioMocks.GenerarMock( "librerias" )
		goServicios.Librerias.EstablecerExpectativa( "ObtenerFecha", ldFecha )
		goServicios.Librerias.EstablecerExpectativa( "ObtenerHora", lcHora )
		goServicios.Librerias.EstablecerExpectativa( "Obtenernombresucursal", _screen.zoo.app.cBDMaster, "["+_screen.zoo.app.cBDMaster+"]" )
	
		loEnt = newobject( "TestEntidadAbstracta" )
		loEnt.HoraModificacionFW = "hora1"
		loEnt.FechaModificacionFW = ldFecha - 1
		
		this.assertequals( "Error en la hora sin anular", "hora1", loEnt.HoraModificacionFW )
		this.assertequals( "Error en la fecha sin anular", ldFecha - 1 , loEnt.FechaModificacionFW )
		
		loEnt.lAnular = .T.
		
		this.assertequals( "Error en la hora anulando", lcHora, loEnt.HoraModificacionFW )
		this.assertequals( "Error en la fecha anulando", ldFecha, loEnt.FechaModificacionFW )
		
		loEnt.release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestU_ErrorAlEliminarUnRegistroDeUnaBaseReplica
		local loEntidad as Object, lcCodigo as String, loError as Exception, loApp as Object

	*Arrange (Preparar)
		loEntidad = _screen.zoo.InstanciarEntidad( "Chipre" )
		lcCodigo = Right( sys( 2015 ), 5 )
		try
			loEntidad.Nuevo()
			loEntidad.Codigo = lcCodigo
			loEntidad.Grabar()
		catch
		endtry

	*Act (Actuar)
		loApp = newobject( "AppMock" )
		loApp.lPermiteAbm = .F.
		try
			loEntidad.Eliminar()
			this.asserttrue( "Debería dar error", .f. )
		catch to loError
	*Assert (Afirmar)
			this.assertequals( "El error no es el correcto", "El registro de la entidad " + ;
				"Chipre no puede ser eliminado porque la sucursal " + _screen.zoo.app.ObtenerSucursalActiva() + " pertenece a una base réplica.", loError.UserValue.oInformacion.Item[1].cMensaje )
		finally
			loEntidad.Release()
			loApp.release()
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestU_SINErrorAlEliminarUnRegistroDeUnaBaseNoReplica
		local loEntidad as Object, lcCodigo as String, loError as Exception, loApp as Object

	*Arrange (Preparar)
		loEntidad = _screen.zoo.InstanciarEntidad( "Chipre" )
		lcCodigo = Right( sys( 2015 ), 5 )
		try
			loEntidad.Nuevo()
			loEntidad.Codigo = lcCodigo
			loEntidad.Grabar()
		catch
		endtry

	*Act (Actuar)
		loApp = newobject( "AppMock" )
		loApp.lPermiteAbm = .T.
		try
			loEntidad.Eliminar()
		catch to loError
	*Assert (Afirmar)
			this.asserttrue( "No debería dar error", .F. )
		finally
			loEntidad.Release()
			loApp.release()
		endtry
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function zTestU_ErrorAlModificarUnRegistroDeUnaBaseReplica
		local loEntidad as Object, lcCodigo as String, loError as Exception, loApp as Object

	*Arrange (Preparar)
		loEntidad = _screen.zoo.InstanciarEntidad( "Chipre" )
		lcCodigo = Right( sys( 2015 ), 5 )
		try
			loEntidad.Nuevo()
			loEntidad.Codigo = lcCodigo
			loEntidad.Grabar()
		catch
		endtry
		loEntidad.Ultimo()

	*Act (Actuar)
		loApp = newobject( "AppMock" )
		loApp.lPermiteAbm = .F.
		try
			loEntidad.Modificar()
			this.asserttrue( "Debería dar error", .f. )
		catch to loError
	*Assert (Afirmar)
			this.assertequals( "El error no es el correcto", "El registro de la entidad " + ;
				"Chipre no puede ser modificado porque la sucursal " + _screen.zoo.app.ObtenerSucursalActiva() + " pertenece a una base réplica.", loError.UserValue.oInformacion.Item[1].cMensaje )
		finally
			loEntidad.Release()
			loApp.release()
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestU_SINErrorAlModificarUnRegistroDeUnaBaseNoReplica
		local loEntidad as Object, lcCodigo as String, loError as Exception, loApp as Object

	*Arrange (Preparar)
		loEntidad = _screen.zoo.InstanciarEntidad( "Chipre" )
		lcCodigo = Right( sys( 2015 ), 5 )
		try
			loEntidad.Nuevo()
			loEntidad.Codigo = lcCodigo
			loEntidad.Grabar()
		catch
		endtry
		loEntidad.Ultimo()

	*Act (Actuar)
		loApp = newobject( "AppMock" )
		loApp.lPermiteAbm = .T.
		try
			loEntidad.Modificar()
		catch to loError
	*Assert (Afirmar)
			this.asserttrue( "No debería dar error", .F. )
		finally
			loEntidad.Release()
			loApp.release()
		endtry
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function zTestU_ErrorAlHacerNuevoEnUnaEntidadDeUnaBaseReplica
		local loEntidad as Object, lcCodigo as String, loError as Exception, loApp as Object

	*Arrange (Preparar)
		this.MockearAccesoDatos( "Chipre" )
		loEntidad = _screen.zoo.InstanciarEntidad( "Chipre" )

	*Act (Actuar)
		loApp = newobject( "AppMock" )
		loApp.lPermiteAbm = .F.
		try
			loEntidad.Nuevo()
			this.asserttrue( "Debería dar error", .f. )
		catch to loError
	*Assert (Afirmar)
			this.assertequals( "El error no es el correcto", "La entidad Chipre no permite hacer nuevo " + ;
				"porque la sucursal " + _screen.zoo.app.ObtenerSucursalActiva() + " pertenece a una base réplica.", loError.UserValue.oInformacion.Item[1].cMensaje )
		finally
			loEntidad.Release()
			loApp.release()
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestU_SINErrorAlHacerNuevoEnUnaEntidadDeUnaBaseNoReplica
		local loEntidad as Object, lcCodigo as String, loError as Exception, loApp as Object

	*Arrange (Preparar)
		this.MockearAccesoDatos( "Chipre" )
		loEntidad = newobject( "ChipreAux" )

	*Act (Actuar)
		loApp = newobject( "AppMock" )
		loApp.lPermiteAbm = .T.
		try
			loEntidad.Nuevo()
		catch to loError
	*Assert (Afirmar)
			this.asserttrue( "No debería dar error", .F. )
		finally
			loEntidad.Release()
			loApp.release()
		endtry
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function zTestU_ErrorAlAnularUnRegistroDeUnaBaseReplica
		local loEntidad as Object, lnCodigo as Integer, loError as Exception, loApp as Object

	*Arrange (Preparar)
		loEntidad = _screen.zoo.InstanciarEntidad( "Mexico" )
		lnCodigo = 6666
		try
			loEntidad.Nuevo()
			loEntidad.Codigo = lnCodigo
			loEntidad.Grabar()
		catch
		endtry
		loEntidad.Ultimo()

	*Act (Actuar)
		loApp = newobject( "AppMock" )
		loApp.lPermiteAbm = .F.
		try
			loEntidad.Anular()
			this.asserttrue( "Debería dar error", .f. )
		catch to loError
	*Assert (Afirmar)
			this.assertequals( "El error no es el correcto", "El registro de la entidad mexico no puede ser anulado " + ;
				"porque la sucursal " + _screen.zoo.app.ObtenerSucursalActiva() + " pertenece a una base réplica.", loError.UserValue.oInformacion.Item[1].cMensaje )
		finally
			loEntidad.Release()
			loApp.release()
		endtry
		goDatos.EjecutarSentencias( "Delete From Mexico where CCod = 6666", "Mexico" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestU_SINErrorAlAnularUnRegistroDeUnaBaseNoReplica
		local loEntidad as Object, lnCodigo as Integer, loError as Exception, loApp as Object

	*Arrange (Preparar)
		loEntidad = _screen.zoo.InstanciarEntidad( "Mexico" )
		lnCodigo = 6666
		try
			with loEntidad
				.Nuevo()
				.Codigo = lnCodigo
				.Grabar()
			endwith
		catch
		endtry
		loEntidad.Ultimo()

	*Act (Actuar)
		loApp = newobject( "AppMock" )
		loApp.lPermiteAbm = .T.
		try
			loEntidad.Anular()
		catch to loError
	*Assert (Afirmar)
			this.asserttrue( "No debería dar error", .F. )
		finally
			loEntidad.Release()
			loApp.release()
		endtry
		goDatos.EjecutarSentencias( "Delete From Mexico where CCod = 6666", "Mexico" )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function zTestU_ErrorAlGuardarComoUnRegistroDeUnaBaseReplica
		local loEntidad as Object, lcCodigo as Integer, loError as Exception, loApp as Object

	*Arrange (Preparar)		
		loEntidad = _screen.zoo.InstanciarEntidad( "Tanzania" )
		lcCodigo = sys( 2015 )
		try
			loEntidad.Nuevo()
			loEntidad.Codigo = lcCodigo
			loEntidad.Grabar()
		catch
		endtry
		loEntidad.Ultimo()

	*Act (Actuar)
		loApp = newobject( "AppMock" )
		loApp.lPermiteAbm = .F.
		try
			loEntidad.GuardarComo()
			this.asserttrue( "Debería dar error", .f. )
		catch to loError
	*Assert (Afirmar)
			this.assertequals( "El error no es el correcto", "El registro de la entidad TANZANIA no puede guardarse como " + ;
				"porque pertenece a una base réplica.", loError.UserValue.oInformacion.Item[1].cMensaje )
		finally
			loEntidad.Release()
			loApp.release()
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestU_SINErrorAlGuardarComoUnRegistroDeUnaBaseNoReplica
		local loEntidad as Object, lcCodigo as Integer, loError as Exception, loApp as Object

	*Arrange (Preparar)
		loEntidad = _screen.zoo.InstanciarEntidad( "Tanzania" )
		lcCodigo = sys( 2015 )
		try
			with loEntidad
				.Nuevo()
				.Codigo = lnCodigo
				.Grabar()
			endwith
		catch
		endtry
		loEntidad.Ultimo()

	*Act (Actuar)
		loApp = newobject( "AppMock" )
		loApp.lPermiteAbm = .T.
		try
			loEntidad.GuardarComo()
			loEntidad.Cancelar()
		catch to loError
	*Assert (Afirmar)
			this.asserttrue( "No debería dar error", .F. )
		finally
			loEntidad.Release()
			loApp.release()
		endtry
	endfunc 
	
enddefine

*-----------------------------------------------------------------------------------------
define class SubscriptorAntesDeFinalizarRecibir as custom

	lPaso = .f.
	
	*-----------------------------------------------------------------------------------------
	function DelegadoAntesDeFinalizar() as Void
		this.lPaso = .t.
	endfunc 

enddefine

define class AccesoDatosAuxiliar as AccesoDatosEntidad of AccesoDatosEntidad.prg
	*-----------------------------------------------------------------------------------------
	protected function AbrirCursoresRecepcion( toListaTablas as zoocoleccion OF zoocoleccion.prg ) as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function BlanquearCamposTransferencia() as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function FinalizarRecibir() as Void
	endfunc 
enddefine

*-----------------------------------------------------------------------------------------
define class TestEntidadConTalonario as entidad of entidad.prg

	lLlamoVerificarDisponibilidadTalonario = .f.
	*-----------------------------------------------------------------------------------------
	function VerificarDisponibilidadTalonario() as Void
		this.lLlamoVerificarDisponibilidadTalonario = .t.
	endfunc

enddefine

************************
define class ObjetoBindeos as custom
	oEntidad = null
	lRespuestaAnular = .T.
	lRespuestaEliminar = .T.
	nLlamadasEliminar = 0
	nLlamadasAnular = 0
	lPasoPorDespuesDeAnular = .f.

	*-----------------------------------------------------------------------------------------
	function EventoPreguntarEliminar() as boolean
		this.oEntidad.lEliminar = this.lRespuestaEliminar
		this.nLlamadasEliminar = this.nLlamadasEliminar + 1
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoPreguntarAnular( tcMensaje as String ) as boolean
		this.oEntidad.lAnular = this.lRespuestaAnular
		this.nLlamadasAnular = this.nLlamadasAnular + 1
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	function EventoDespuesDeAnular() as void
		this.lPasoPorDespuesDeAnular = .t.
	endfunc

enddefine

************************
define class mockManagerImpresion as custom
	lPrevisualizar = .F.
	oEntidad = null
	lPasoPorImprimir = .F.

	*-----------------------------------------------------------------------------------------
	function imprimir( toQuienLlama as Object, tlPrevisualizar as Boolean  ) as Boolean
		with this
			.oEntidad = toQuienLlama
			.lPrevisualizar = tlPrevisualizar
			.lPasoPorImprimir = .T.
		endwith
		
		return .T.
	endfunc

enddefine

*-----------------------------------------------------------------------------------------
define class Bindeo as custom
	lPasoPorPrevisualizarDiseno = .F.
	oEntidad = null
	lPrevisualizarDiseno = .F.
	lEjecutoLimpiarInformacion = .f.
	
	*-----------------------------------------------------------------------------------------
	function PrevisualizarDiseno() as Void
		this.lPasoPorPrevisualizarDiseno = .T.
		this.oEntidad.lPrevisualizarDiseno = this.lPrevisualizarDiseno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function LimpiarInformacion() as Void
		this.lEjecutoLimpiarInformacion = .T.
	endfunc

enddefine

*-----------------------------------------------------------------------------------------
define class TestEntidadAbstracta as entidad of entidad.prg
	cAtributoPK = "Codigo"
	Codigo = ""

	function Init
		dodefault()
		this.oAd = newobject( "oAdAux" )
	endfunc 

enddefine

*-----------------------------------------------------------------------------------------
define class oAdAux as custom
	cTablaPrincipal = ""
enddefine


*-----------------------------------------------------------------------------------------
define class TestAccesoDatosEntidadAbstracta as Accesodatosentidad of Accesodatosentidad.prg
 	lPasoPorMetodoImportar = .F.
 	lProcesarConTransaccionEstabaEn = .T.
	*-----------------------------------------------------------------------------------------
	Function Importar( tcXmlDatos As String ) As Void
		This.lPasoPorMetodoImportar = .T.
		This.lProcesarConTransaccionEstabaEn = This.lProcesarConTransaccion
	Endfunc

enddefine
************************
define class TestEntidadValidar as din_entidadrusia of din_entidadrusia.prg

	cAtributoPK = "Codigo"
	Codigo = ""
	lEjecutoValidacionbasica = .f.
	lRetornoValidacionBasica = .f.

	*-----------------------------------------------------------------------------------------
	function ValidacionBasica() as Boolean
		this.lEjecutoValidacionbasica = .t.
		return this.lRetornoValidacionBasica 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oAD_Access() as variant
		if !this.ldestroy and !vartype( this.oAD ) = 'O'
			this.oAD = newobject( 'TestAccesoDatosEntidad' )
		endif
		return this.oAD
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Release() as Void
		this.oAd.release()
		this.oAd = Null
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Cargar() as Boolean
		return .T.
	endfunc

enddefine

************************
define class TestComponente as Din_EntidadRio2 of Din_EntidadRio2.Prg
	lEjecutoSetearComponentes = .F.
	*-----------------------------------------------------------------------------------------
	function init
		dodefault()
	endfunc
	*-----------------------------------------------------------------------------------------
	function SetearComponentes() as Void
		This.lEjecutoSetearComponentes = .T.
		local loEx as Exception
		loEx = Newobject( "ZooException", "ZooException.prg" )
		loEx.Throw()
	endfunc 
	*-----------------------------------------------------------------------------------------
	function Validar() as boolean
		return .T.
	endfunc 
enddefine
************************
define class AuxCargaManual as Entidad of Entidad.Prg
	function init
	endfunc

enddefine

************************
define class TestEntidad_DIn_Alemania as DIn_EntidadAlemania of DIn_EntidadAlemania.prg

	lEjecutoLimpiar = .f.
	lEjecutoCargar = .f.
	lEjecutoAntesDeGrabar = .f.
	lejecutoValidar = .f.
	lejecutoDespuesdeGrabar = .f.
	lejecutoValidarPK = .f.

	lRetornoAntesDeGrabar = .f.
	lRetornoDepuesDeGrabar = .f.
	lRetornoValidar = .f.
	lRetornoValidarPK = .f.
	lEjecutoLimpiarInformacion = .f.
	
	lEjecutoImprimirDespuesDeGrabar = .f.
	lEjecutoImprimir = .f.
	

	*-----------------------------------------------------------------------------------------
	protected function ImprimirDespuesDeGrabar() as Boolean
		dodefault()
		this.lEjecutoImprimirDespuesDeGrabar = .t.
	endfunc

	*-----------------------------------------------------------------------------------------
	function AntesDeGrabar() as Void
		local llRetorno as Boolean 
		
		this.lEjecutoAntesDeGrabar = .t.
		llRetorno = this.lRetornoAntesDeGrabar
		dodefault()
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Validar() as Boolean
		this.lejecutoValidar = .t.
		return this.lRetornoValidar
	endfunc 

	*-----------------------------------------------------------------------------------------
	function DespuesDeGrabar() as Boolean
		dodefault()
		this.lejecutoDespuesdeGrabar = .t.
		return this.lRetornoDepuesDeGrabar 
	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	function Cargar() as Boolean
		this.lEjecutoCargar = .t.
		return this.lEjecutoCargar
	endfunc

	*-----------------------------------------------------------------------------------------
	function LimpiarInformacion() as Void
		This.lEjecutoLimpiarInformacion = .t.
	endfunc
	
	*-----------------------------------------------------------------------------------------				
	protected function DeboImprimir() as Boolean
		return .t.
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Imprimir() as Boolean
		this.lEjecutoImprimir = .t.
		return .t.
	endfunc

enddefine
***********************
define class TestEntidad as entidad of entidad.prg

	cAtributoPK = "Codigo"
	Codigo = ""
	
	lEjecutoLimpiar = .f.
	lEjecutoCargar = .f.
	lEjecutoAntesDeGrabar = .f.
	lejecutoValidar = .f.
	lejecutoDespuesdeGrabar = .f.
	lejecutoValidarPK = .f.
	lEjecutoActualizarEstado = .f.

	lEjecutoVotacionCambioEstadoNuevo = .f.
	lVotacionCambioEstadoNUEVO = .f.
	
	lEjecutoVotacionCambioEstadoModificar = .f.
	lVotacionCambioEstadoModificar = .f.

	lEjecutoVotacionCambioEstadoEliminar = .f.
	lVotacionCambioEstadoEliminar = .f.

	lEjecutoVotacionCambioEstadoCancelar = .f.
	lVotacionCambioEstadoCancelar = .f.


	lRetornoAntesDeGrabar = .f.
	lRetornoDepuesDeGrabar = .f.
	lRetornoValidar = .f.
	lRetornoValidarPK = .f.
	lEjecutoLimpiarInformacion = .f.
	oAd = Null


	*-----------------------------------------------------------------------------------------
	function VotacionCambioEstadoNUEVO( ) as void
	
		this.lEjecutoVotacionCambioEstadoNuevo = .T.
		if this.lVotacionCambioEstadoNUEVO
			toValidacion.agregarProblema( "Problema al votar por nuevo" )
		endif 
	
	endfunc 
	*-----------------------------------------------------------------------------------------
	function VotacionCambioEstadoMODIFICAR( ) as void
	
		this.lEjecutoVotacionCambioEstadoModificar = .T.
		if this.lVotacionCambioEstadoModificar
			toValidacion.agregarProblema( "Problema al votar por modificar" )
		endif 
	
	endfunc 
	*-----------------------------------------------------------------------------------------
	function VotacionCambioEstadoEliminar( ) as void
	
		this.lEjecutoVotacionCambioEstadoEliminar = .T.
		if this.lVotacionCambioEstadoEliminar
			toValidacion.agregarProblema( "Problema al votar por Eliminar" )
		endif 
	
	endfunc 
	*-----------------------------------------------------------------------------------------
	function VotacionCambioEstadoCancelar( ) as void
	
		this.lEjecutoVotacionCambioEstadoCancelar = .T.
		if this.lVotacionCambioEstadoCancelar
			toValidacion.agregarProblema( "Problema al votar por Cancelar" )
		endif 
	
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	function actualizarEstado() as Void
		this.lEjecutoActualizarEstado = .T.
		return dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Limpiar() as Void
		this.lEjecutoLimpiar = .t.
		return dodefault()
	endfunc 
	*-----------------------------------------------------------------------------------------
	function Cargar() as Boolean
		this.lEjecutoCargar = .t.
		return .T.
	endfunc 
	*-----------------------------------------------------------------------------------------
	function AntesDeGrabar() as Void
		local llRetorno as Boolean
		this.lEjecutoAntesDeGrabar = .t.
		llRetorno = this.lRetornoAntesDeGrabar
		return llRetorno
	endfunc 
	*-----------------------------------------------------------------------------------------
	function Validar() as Boolean
		this.lejecutoValidar = .t.
		return this.lRetornoValidar
	endfunc 
	*-----------------------------------------------------------------------------------------
	function DespuesDeGrabar() as Boolean
		this.lejecutoDespuesdeGrabar = .t.
		return this.lRetornoDepuesDeGrabar 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarPK() as Boolean
		this.lejecutoValidarPK = .t.
		return this.lRetornoValidarPK
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function oAD_Access() as variant
		if !this.ldestroy and !vartype( this.oAD ) = 'O'
			this.oAD = newobject( 'TestAccesoDatosEntidad' )
		endif
		return this.oAD
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Release() as Void
		this.oAd.release()
		this.oAd = Null
	endfunc 

	*-----------------------------------------------------------------------------------------
	function LimpiarInformacion() as Void
		this.lEjecutoLimpiarInformacion = .t.
	endfunc 	

enddefine


************************
define class TestAccesoDatosEntidad as AccesoDatosEntidad of AccesoDatosEntidad.prg

	lInserto = .f.
	lActualizo = .f.
	lElimino = .f.
	lUltimo = .f.
	lPrimero = .f.
	lSiguiente = .f.
	lAnterior = .f.
	lObtenerAtributoClavePrimaria = .f.
	lConsultarPorClaveCandidata = .f.
	
	lRetornoConsultarPorClavePrimaria = .f.
	*-----------------------------------------------------------------------------------------
	function Insertar() as Void
		this.lInserto = .t.
		dodefault()
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ConsultarPorClavePrimaria() as Boolean
		return This.lRetornoConsultarPorClavePrimaria
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Actualizar() as Void
		this.lActualizo = .t.
		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Eliminar() as Void
		this.lElimino = .t.
		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Primero() as Void
		this.lPrimero = .t.
		return dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Anterior() as Void
		this.lAnterior = .t.
		return dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Siguiente() as Void
		this.lSiguiente = .t.
		return dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Ultimo() as Void
		this.lUltimo = .t.
		return dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ConsultarPorClaveCandidata() as boolean
		this.lConsultarPorClaveCandidata = .t.
		return dodefault()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerAtributoClavePrimaria() as String
		this.lObtenerAtributoClavePrimaria = .t.
		return ""
	endfunc 


enddefine

***********************
define class TestEntidadRusia as din_entidadrusia of din_entidadrusia.prg

	cAtributoPK = "Codigo"
	Codigo = ""
	
	lEjecutoLimpiar = .f.
	lEjecutoCargar = .f.
	lEjecutoAntesDeGrabar = .f.
	lejecutoValidar = .f.
	lejecutoDespuesdeGrabar = .f.
	lejecutoValidarPK = .f.
	lEjecutoActualizarEstado = .f.

	lEjecutoVotacionCambioEstadoNuevo = .f.
	lVotacionCambioEstadoNUEVO = .f.
	
	lEjecutoVotacionCambioEstadoModificar = .f.
	lVotacionCambioEstadoModificar = .f.

	lEjecutoVotacionCambioEstadoEliminar = .f.
	lVotacionCambioEstadoEliminar = .f.

	lEjecutoVotacionCambioEstadoCancelar = .f.
	lVotacionCambioEstadoCancelar = .f.

	lRetornoAntesDeGrabar = .f.
	lRetornoDepuesDeGrabar = .f.
	lRetornoValidar = .f.
	lRetornoValidarPK = .f.
	oAd = Null
	lEjecutoLimpiarInformacion = .f.


	*-----------------------------------------------------------------------------------------
	function VotacionCambioEstadoNUEVO( tcEstado as String ) as boolean
	
		this.lEjecutoVotacionCambioEstadoNuevo = .T.
		if this.lVotacionCambioEstadoNUEVO
			This.agregarInformacion( "Problema al votar por nuevo" )
			return .F.
		endif 
	
	endfunc 
	*-----------------------------------------------------------------------------------------
	function VotacionCambioEstadoMODIFICAR( tcEstado as String ) as Boolean
	
		this.lEjecutoVotacionCambioEstadoModificar = .T.
		if this.lVotacionCambioEstadoModificar
			This.agregarInformacion( "Problema al votar por modificar" )
			return .F.
		endif 
	
	endfunc 
	*-----------------------------------------------------------------------------------------
	function VotacionCambioEstadoEliminar( tcEstado as String ) as Boolean
	
		this.lEjecutoVotacionCambioEstadoEliminar = .T.
		if this.lVotacionCambioEstadoEliminar
			this.agregarInformacion( "Problema al votar por Eliminar" )
			return .F.
		endif 
	
	endfunc 
	*-----------------------------------------------------------------------------------------
	function VotacionCambioEstadoCancelar( tcEstado as String ) as Boolean
	
		this.lEjecutoVotacionCambioEstadoCancelar = .T.
		if this.lVotacionCambioEstadoCancelar
			This.agregarInformacion( "Problema al votar por Cancelar" )
			return .F.
		endif 
	
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	function actualizarEstado() as Void
		this.lEjecutoActualizarEstado = .T.
		return dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Limpiar() as Void
		this.lEjecutoLimpiar = .t.
		return dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Cargar() as boolean
		this.lEjecutoCargar = .t.
		return .T.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AntesDeGrabar() as Void
		local llRetorno as Boolean
		
		this.lEjecutoAntesDeGrabar = .t.
		llRetorno = this.lRetornoAntesDeGrabar
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Validar() as Boolean
		this.lejecutoValidar = .t.
		return this.lRetornoValidar
	endfunc 

	*-----------------------------------------------------------------------------------------
	function DespuesDeGrabar() as Boolean
		this.lejecutoDespuesdeGrabar = .t.
		return This.lRetornoDepuesDeGrabar 
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarPK() as Boolean
		this.lejecutoValidarPK = .t.
		return this.lRetornoValidarPK
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oAD_Access() as variant
		if !this.ldestroy and !vartype( this.oAD ) = 'O'
			this.oAD = newobject( 'TestAccesoDatosEntidad' )
		endif
		return this.oAD
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Release() as Void
		this.oAd.release()
		this.oAd = Null
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function LimpiarInformacion() as Void
		This.lEjecutoLimpiarInformacion = .t.
	endfunc 

enddefine

*-*-*-*-*-*-
define class ObjetoBindeo as Custom

	lPasoPorLimpiar = .f.
	*-----------------------------------------------------------------------------------------
	function LimpiarFlag() as void
		This.lPasoPorLimpiar = .t.
	endfunc 


enddefine

*****************************************************
define class TestAlemania as din_entidadalemania of din_entidadalemania.prg

	lPasoPor_Nuevo = .f.
	lPasoPor_Modificar = .f.
	lPasoPor_EliminarSinValidaciones = .f.
	lPasoPor_Cancelar = .f.
	lPasoPor_Grabar = .f.

	*--------------------------------------------------------------------------------------------------------
	Protected Function _Nuevo() As Boolean
		This.lPasoPor_Nuevo = This.EstaEnProceso()
		return .t.
	endfunc

	*--------------------------------------------------------------------------------------------------------
	Protected Function _Modificar() As void
		This.lPasoPor_Modificar = This.EstaEnProceso()
	endfunc
	
	*--------------------------------------------------------------------------------------------------------
	Protected function _EliminarSinValidaciones() as Void
		This.lPasoPor_EliminarSinValidaciones = This.EstaEnProceso()
	endfunc
	
	*--------------------------------------------------------------------------------------------------------
	Protected Function _Cancelar() As void
		This.lPasoPor_Cancelar = This.EstaEnProceso()
	endfunc

	*--------------------------------------------------------------------------------------------------------	
	Function SetearComponentes() As Void	&& es para el grabar
		This.lPasoPor_Grabar = This.EstaEnProceso()
	endfunc


	*--------------------------------------------------------------------------------------------------------	
	Function Validar() As Boolean
		Return .T.
	endfunc

enddefine


*-----------------------------------------------------------------------------------------
function CopiarExtension
local lcDirectorio as String

	lcDirectorio = addbs( _screen.zoo.cRutaInicial ) + "Personal\Extensiones\"

	if directory( lcDirectorio )
	else
		md ( lcDirectorio )
	endif

	copy file ( addbs( _screen.zoo.cRutaInicial ) ) + "ClasesDePrueba\ext_Argentina_Zoologic.prg" to ;
		( addbs ( _screen.zoo.cRutaInicial ) ) + "Personal\ext_Argentina_Zoologic.prg"

	copy file ( addbs( _screen.zoo.cRutaInicial ) ) + "ClasesDePrueba\ext_Argentina_Zoologic.prg" to ;
		( addbs ( _screen.zoo.cRutaInicial ) ) + "Personal\ext_Argentina_Zoologic.fxp"

	copy file ( addbs( _screen.zoo.cRutaInicial ) ) + "ClasesDePrueba\ext_Argentina_Zoologic.prg" to ;
		( addbs ( _screen.zoo.cRutaInicial ) ) + "Personal\ext_Argentina_Zoologic.prg.backup"

endfunc 

*-----------------------------------------------------------------------------------------
function BorrarExtension

	clear class "ext_Argentina_Zoologic"
	delete file ( addbs ( _screen.zoo.cRutaInicial ) ) + "Personal\ext_Argentina_Zoologic.*"

endfunc 

*-----------------------------------------------------------------------------------------
define class AbstractoDetalle as Detalle of Detalle.Prg
enddefine

*-----------------------------------------------------------------------------------------

define class PoolFake as custom

	*-----------------------------------------------------------------------------------------
	function DevolverConexion( toConexion as Object, toEntidad as Object ) as Void
	endfunc 
	
	function ObtenerConexion( toEntidad as Object ) as Void
		return goServicios.Datos
	endfunc

enddefine


*-----------------------------------------------------------------------------------------
define class AppMock as Mock_AplicacionNucleo of Mock_AplicacionNucleo.prg

	oAppAnt = null
	lPermiteAbm = .F.
	oPoolConexiones = null

	*-----------------------------------------------------------------------------------------
	function init
		
		loPoolFake = _screen.zoo.crearobjeto("PoolFake", "zTestEntidad.prg")
		
		_screen.mocks.Agregarmock( "APLICACIONNUCLEO" )
		_screen.mocks.AgregarSeteoMetodo( 'APLICACIONNUCLEO', 'Obtenersucursalactiva', _Screen.Zoo.App.cSucursalActiva )
		_screen.mocks.AgregarSeteoMetodo( 'APLICACIONNUCLEO', 'Obtenerversion', _Screen.Zoo.App.ObtenerVersion() )
		_screen.mocks.AgregarSeteoMetodo( 'APLICACIONNUCLEO', 'Permitemodificaroeliminarenbase', .T., "[*COMODIN]" )
		_screen.mocks.AgregarSeteoMetodo( 'APLICACIONNUCLEO', 'Obtenerrutasucursal', _Screen.Zoo.App.ObtenerRutaSucursal( _Screen.Zoo.App.cSucursalActiva ), "[*COMODIN]" )		
		_screen.mocks.AgregarSeteoMetodo( 'APLICACIONNUCLEO', 'Cargarsucursales', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'APLICACIONNUCLEO', 'Csucursalactiva_assign', .T., "[*COMODIN]" )
		_screen.mocks.AgregarSeteoMetodo( 'APLICACIONNUCLEO', 'Obtenervalorreplicabd', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'APLICACIONNUCLEO', 'Cbdmaster_access', 'NUCLEO_ZOOLOGICMASTER' ) && ztestentidad.ztestu_sinerroralanularunregistrodeunabasenoreplica 20/01/15 14:27:18
		_screen.mocks.AgregarSeteoMetodo( 'APLICACIONNUCLEO', 'Obtenerprefijodb', 'NUCLEO_' ) && ztestentidad.ztestu_sinerroralanularunregistrodeunabasenoreplica 20/01/15 14:27:19
		_screen.mocks.AgregarSeteoMetodo( 'APLICACIONNUCLEO', 'oPoolConexiones_Access', loPoolFake ) && ztestentidad.ztestu_sinerroralanularunregistrodeunabasenoreplica 20/01/15 14:27:19
		
		this.oAppAnt = _Screen.Zoo.App
		this.cSucursalActiva = _screen.zoo.app.cSucursalActiva
		this.TipoDeBase = _screen.zoo.app.TipoDeBase
		this.cNombreBaseDeDatosSql = _screen.zoo.app.cNombreBaseDeDatosSql
		this.Nombre = "Nucleo"
		this.NombreProducto = "NUCLEO"
		this.cProyecto = "NUCLEO"
		this.CargarSucursales()
		this.oPoolConexiones = null
		_Screen.Zoo.App = this
	endfunc

	*-----------------------------------------------------------------------------------------
	function Destroy
		_Screen.Zoo.App = this.oAppAnt
	endfunc 

	*-----------------------------------------------------------------------------------------
	function PermiteABM( tcTabla as String ) as Boolean
		return this.lPermiteAbm
	endfunc
	
enddefine

*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class ChipreAux as Din_EntidadCHIPRE of Din_EntidadCHIPRE.prg

	*--------------------------------------------------------------------------------------------------------
	Protected Function _Nuevo() As Boolean
		return .t.
	endfunc

enddefine

*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class ArgentinaAux as Din_EntidadArgentina of Din_EntidadArgentina.prg

	*-----------------------------------------------------------------------------------------
	Function Init( t1, t2, t3, t4 ) As Boolean
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerExtensionesAux() as zoocoleccion OF zoocoleccion.prg
		local lcRuta as String, lcUltimaExtension as string, lcNombreObj as string, lcRutaExtensiones as string
		
		lcRuta = alltrim( addbs( _Screen.zoo.cRutaInicial ) + "Personal\" )
		lcUltimaExtension = ""
		lcNombreObj =  "Ext_" + This.ObtenerNombre()
		lcRutaExtensiones = lcRuta + lcNombreObj

		return this.ObtenerExtensiones( lcRutaExtensiones )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EsExtensionValidaParaFoxAux( tcNombre as String ) as Boolean
		return this.EsExtensionValidaParaFox( tcNombre )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerExtensionesValidasParaFoxAux() as zoocoleccion OF zoocoleccion.prg
		return this.ObtenerExtensionesValidasParaFox()
	endfunc 

enddefine


define class BulgariaAux as Din_EntidadBulgaria of DIn_entidadBUlgaria.prg
	lEntidadEditable = .t.
enddefine

*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class WebHook_fake as custom
	
	lPasoPorElEnviar = .F.
	cEvento = ""
	
	*-----------------------------------------------------------------------------------------	
	function Enviar( toEntidad as Object, tcEvento as String )
		this.lPasoPorElEnviar = .T.
		this.cEvento = tcEvento
	endfunc

enddefine
