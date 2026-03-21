define class ServicioMonitorSaludBasesDeDatos as Servicio of Servicio.prg

	#IF .f.
		Local this as ServicioMonitorSaludBasesDeDatos of ServicioMonitorSaludBasesDeDatos.prg
	#ENDIF

	protected oMonitorDeActividadDeAplicacion as Object
	protected oGestorDeSaludBasesDeDatos as Object
	protected lMonitorPeriodicoEstaHabilitado as Boolean
	protected nMinutosDesdeLaUltimaEjecucion as Integer
	protected lEstaEjecutando as Boolean
	protected lSeRealizoLaValidacionYReparacionDeBasesDeDatos as Boolean

	oMonitorDeActividadDeAplicacion = null
	oGestorDeSaludBasesDeDatos = null
	lMonitorPeriodicoEstaHabilitado = .f.
	nMinutosDesdeLaUltimaEjecucion = 0
	lEstaEjecutando = .f.
	lSeRealizoLaValidacionYReparacionDeBasesDeDatos = .f.

	#IF .f.
		local this as ServicioMonitorSaludBasesDeDatos of ServicioMonitorSaludBasesDeDatos.prg
	#ENDIF

	*-----------------------------------------------------------------------------------------
	function oMonitorDeActividadDeAplicacion_Access() as Object
		if !this.lDestroy and isnull( this.oMonitorDeActividadDeAplicacion )
			this.oMonitorDeActividadDeAplicacion = _screen.zoo.CrearObjeto( "MonitorDeActividadDeAplicacion" )
		endif
		return this.oMonitorDeActividadDeAplicacion
	endfunc

	*-----------------------------------------------------------------------------------------
	function oGestorDeSaludBasesDeDatos_Access() as Object
		if !this.lDestroy and isnull( this.oGestorDeSaludBasesDeDatos )
			this.oGestorDeSaludBasesDeDatos = _screen.zoo.CrearObjeto( "ZooLogicSA.SaludDeBasesDeDatos.GestorSaludSQLServer", "", goDatos.oManagerConexionASql.ObtenerCadenaConexionNet(), _screen.Zoo.App.NombreProducto )
			_screen.Zoo.BindearEvento( this.oGestorDeSaludBasesDeDatos, "InicioDeValidacionYReparacionDeBasesDeDatos", this, "AdvertirInicioDeValidacionYReparacionDeBasesDeDatos" )
		endif
		return this.oGestorDeSaludBasesDeDatos
	endfunc

	*-----------------------------------------------------------------------------------------
	function Iniciar() as Void
		dodefault()
		This.lMonitorPeriodicoEstaHabilitado = goServicios.Ejecucion.HabilitarMonitorSaludBasesDeDatos()
		if this.EstaHabilitadoElMonitorPeriodico()
			this.ConfigurarMonitorDeActividad()
		endif
		if _screen.Zoo.EsModoSystemStartUp()
			this.ForzarPreCompilacionDelGestorDeSalud()
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function Detener() as Void
		if this.EstaHabilitadoElMonitorPeriodico()
			this.DesbindearEvento( this.oMonitorDeActividadDeAplicacion, "EventoAplicacionInactiva", this, "VerificarEstadoDelServidorYSusBases" )
			this.oMonitorDeActividadDeAplicacion.Detener()
		endif
		dodefault()
	endfunc

	*-----------------------------------------------------------------------------------------
	function EstaHabilitadoElMonitorPeriodico() as Boolean
		local llEstaHabilitado as Boolean
		llEstaHabilitado = .f.
		do case
			case _vfp.StartMode == 0
				llEstaHabilitado = this.lMonitorPeriodicoEstaHabilitado and !wexist( "debugger" )
			case _vfp.StartMode == 4
				llEstaHabilitado = this.lMonitorPeriodicoEstaHabilitado
		endcase
		return llEstaHabilitado
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function VerificarSaludEnBasesDeDatosDeSistema() as Void
		if this.DebeEjecutarControl()
			*!*	To do
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function VerificarSaludEnBaseDeDatosDeNegocio( tcBaseDeDatos as String ) as Void
		if this.DebeEjecutarControl()
			*!*	To do
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function VerificarEjecucionDeADNImplantEnBasesDeDatosDeSistema() as Void
		local loEx as Exception
		
		if this.DebeEjecutarControl()
			try
				this.lEstaEjecutando = .t.
				if this.VerificarConexionABasesDeDatosDeSistema() and ;
					this.oGestorDeSaludBasesDeDatos.VerificarEjecucionDeADNImplantEnBasesDeDatosDeSistema( this.ObtenerParametrosLanzadorProcesos() )
				else
					_screen.Zoo.App.oMonitorDeIngresoYSalida.FicharSalida()
					goServicios.Librerias.TerminarProcesosRelacionados( goServicios.Librerias.ObtenerIdProcesoActual(), null )
				endif
			catch to loEx
				goServicios.Errores.LevantarExcepcion( loEx )
			finally
				this.lEstaEjecutando = .f.
			endtry
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function VerificarEjecucionDeADNImplantEnBaseDeDatosDeNegocio( tcBaseDeDatos as String ) as Boolean
		local loEx as Exception, llRetorno as Boolean
		llRetorno = .t.
		
		if this.DebeEjecutarControl()
			try
				this.lEstaEjecutando = .t.
				if this.VerificarConexionABasesDeDatosDeNegocio( tcBaseDeDatos ) and ;
					this.oGestorDeSaludBasesDeDatos.VerificarEjecucionDeADNImplantEnBaseDeDatosDeNegocio( this.ObtenerParametrosLanzadorProcesos(), tcBaseDeDatos )
				else
					llRetorno = .f.
				endif
			catch to loEx
				goServicios.Errores.LevantarExcepcion( loEx )
			finally
				this.lEstaEjecutando = .f.
			endtry
		endif
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarVersion( tcBaseDeDatos as String ) as Object
		local loResultadoValidacion as Object
		loResultadoValidacion = this.oGestorDeSaludBasesDeDatos.ValidarVersion( this.ObtenerVersion(), tcBaseDeDatos )
		return loResultadoValidacion
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerVersion() as String 
		local lcRetorno as String 

		if _Screen.Zoo.lDesarrollo
			lcRetorno = ""
		else
			lcRetorno = _Screen.Zoo.App.ObtenerVersion()
		endif
		
		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function VerificarEstadoDelServidorYSusBases() as Void
		local loBasesDeDatosConError as Object, loError as Object, loEx as Exception, lnIdProcesoRestore as Integer, loProcesosAMantenerAbiertos as ZooColeccion of ZooColeccion.prg
		if this.EstaHabilitadoElMonitorPeriodico() and this.DebeEjecutarControlPeriodico()
			try
				this.lEstaEjecutando = .t.
				_screen.Zoo.App.InformarEstado( "Verificando salud de las bases de datos." )
				this.lSeRealizoLaValidacionYReparacionDeBasesDeDatos = .f.
				loBasesDeDatosConError = this.ObtenerBasesQueNoSePudieronReparar( this.oGestorDeSaludBasesDeDatos.VerificarEstadoDelServidorYSusBases( this.ObtenerParametrosLanzadorProcesos() ) )
				if loBasesDeDatosConError.Count > 0
					loProcesosAMantenerAbiertos = _screen.Zoo.CrearObjeto( "ZooColeccion" )
					lnIdProcesoRestore = this.oGestorDeSaludBasesDeDatos.EjecutarRestore( loBasesDeDatosConError, _screen.Zoo.cRutaInicial )
					if lnIdProcesoRestore > 0
						loProcesosAMantenerAbiertos.Agregar( lnIdProcesoRestore, transform( lnIdProcesoRestore ) )
					endif
					_screen.Zoo.App.oMonitorDeIngresoYSalida.FicharSalida()
					goServicios.Librerias.TerminarProcesosRelacionados( goServicios.Librerias.ObtenerIdProcesoActual(), loProcesosAMantenerAbiertos )
				else
					if this.lSeRealizoLaValidacionYReparacionDeBasesDeDatos
						goServicios.Mensajes.Informar( "La verificación de salud de las bases de datos de la aplicación ha finalizado, las mismas se encuentran en estado consistente.", 0, 0, "Monitor de salud de bases de datos" )
					endif
				endif
			catch to loError
				loEx = newobject( "ZooException", "ZooException.prg" )
				loEx.Grabar( loError )
			finally
				this.lEstaEjecutando = .f.
			endtry
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerBasesQueNoSePudieronReparar( toBasesDeDatosValidadas as Object ) as Object
		local loBasesQueNoSePudieronReparar as Object, loResultadoDeValidacion as Object, i as Integer
		loBasesQueNoSePudieronReparar = _screen.Zoo.CrearObjeto( "System.Collections.Generic.List`1[System.String]" )
		for i = 0 to toBasesDeDatosValidadas.Count - 1
			loResultadoDeValidacion = toBasesDeDatosValidadas.Item[ i ]
			if loResultadoDeValidacion.ErrorCheckDB or loResultadoDeValidacion.ErrorIntegridad
				loBasesQueNoSePudieronReparar.Add( loResultadoDeValidacion.BaseDeDatos )
			endif
		endfor
		return loBasesQueNoSePudieronReparar
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ConfigurarMonitorDeActividad() as Void
		this.oMonitorDeActividadDeAplicacion.nSegundosFrecuenciaDeMonitoreo = 60
		this.oMonitorDeActividadDeAplicacion.nSegundosDeUltimaEntradaUsuario = 10
		this.BindearEvento( this.oMonitorDeActividadDeAplicacion, "EventoAplicacionInactiva", this, "VerificarEstadoDelServidorYSusBases" )
		this.oMonitorDeActividadDeAplicacion.Iniciar()
	endfunc

	*-----------------------------------------------------------------------------------------
	function AdvertirInicioDeValidacionYReparacionDeBasesDeDatos( toSender as Object, toArgs as Object ) as Void
		local lcBasesConErrores as String, i as Integer, lcNuevaLinea as String, lcMensaje as String
		lcNuevaLinea = chr( 13 ) + chr( 10 )
		lcMensaje = "Se va ha iniciar un diagnóstico de las bases de datos de la aplicación, de hallar inconvenientes se intentarán repararlos." + lcNuevaLinea + lcNuevaLinea
		do case
			case toArgs.Estado = 0 && El servicio se detuvo de forma incorrecta.
				lcMensaje = lcMensaje + "Motivo: " + this.ObtenerMensajeDeApagadoIncorrectoDelServicioSQL( .t. ) + " Para evitar esta situación en el futuro, asegurese de apagar correctamente " + this.ObtenerMensajeDeEquipoServidorDeDatos( .f. ) + "."
			case toArgs.Estado = 1 && Bases de datos con errores.
				lcMensaje = lcMensaje + "Motivo: Bases de datos con errores."
			case toArgs.Estado = 2 && Tareas de diagnóstico vencidas.
				lcMensaje = lcMensaje + "Motivo: Posible fallo en la ejecución del agente de acciones organic o no se detectó actividad en este equipo en los últimos 5 días."
			case toArgs.Estado = 3 && Bases de datos reconectadas.
				lcMensaje = lcMensaje + "Motivo: Se detectaron bases de datos cuya unidad de almacenamiento ha sido reconectada."
		endcase
		this.lSeRealizoLaValidacionYReparacionDeBasesDeDatos = .t.
		goServicios.Mensajes.Advertir( lcMensaje, 0, 0, "Monitor de salud de bases de datos" )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerMensajeDeApagadoIncorrectoDelServicioSQL( tlCapitalizar as boolean ) as String
		local lcRetorno as String, lcEquipo as String
		lcRetorno = this.ObtenerMensajeDeEquipoServidorDeDatos( tlCapitalizar ) + " se apagó de forma incorrecta o bien el servicio de SQL Server se detuvo de forma inesperada."
		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerMensajeDeEquipoServidorDeDatos( tlCapitalizar  as Boolean ) as String
		local lcRetorno as String
		if this.ElServidorDeSQLEstaEnEsteEquipo()
			lcRetorno = iif( tlCapitalizar, "Este", "este" ) + " equipo"
		else
			lcRetorno = iif( tlCapitalizar, "El", "el" ) + " equipo utilizado como servidor de datos"
		endif
		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ElServidorDeSQLEstaEnEsteEquipo() as Boolean
		local lcServidor as String
		lcServidor = upper( getwordnum( _Screen.Zoo.App.cNombreDelServidorSQL, 1, "\"  ) )
		return upper( goServicios.Librerias.ObtenerNombrePuesto() ) == lcServidor or lcServidor == "."
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function DebeEjecutarControlPeriodico() as Boolean
		local llRetorno as Boolean
		llRetorno = .f.
		
		if !_screen.zoo.app.lEsEntornoCloud
			if !this.lEstaEjecutando 
				this.nMinutosDesdeLaUltimaEjecucion = this.nMinutosDesdeLaUltimaEjecucion + 1
				if this.nMinutosDesdeLaUltimaEjecucion >= 30
					llRetorno = .t.
					this.nMinutosDesdeLaUltimaEjecucion = 0
				endif
			endif
		endif
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerParametrosLanzadorProcesos() as Object
		local loRetorno as Object, loAdnImplant as Object
		loAdnImplant = _Screen.zoo.Crearobjeto( "AdnImplant" )
		loRetorno = loAdnImplant.ObtenerObjetoParametros()
		loAdnImplant = null
		return loRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function VerificarConexionABasesDeDatosDeSistema() as Boolean
		local llRetorno as Boolean, loEx as Exception
		llRetorno = .f.
		try
			if goDatos.VerificarConexionADBEspecifica( goDatos.ObtenerNombreBD( "ZOOLOGICMASTER" ) ) and ;
				goDatos.VerificarConexionADBEspecifica( goDatos.ObtenerNombreBD( "ADNIMPLANT" ) )
				llRetorno = .t.
			endif
		catch to loEx
		endtry

		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function VerificarConexionABasesDeDatosDeNegocio( tcBaseDeDatos as String ) as Boolean
		local llRetorno as Boolean, loEx as Exception
		llRetorno = .f.
		try
			if goDatos.VerificarConexionADBEspecifica( tcBaseDeDatos )
				llRetorno = .t.
			endif
		catch to loEx
		endtry

		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function DebeEjecutarControl() as Boolean
		local llRetorno
	
		llRetorno = !_screen.Zoo.App.lEsEntornoCloud
		llRetorno = llRetorno and !_screen.Zoo.EsModoSystemStartUp()
		llRetorno = llRetorno and ( !goServicios.Ejecucion.TieneScriptCargado() or goServicios.Ejecucion.lHabilitarMonitorSaludBasesDeDatosEnEjecucionDeScript )
		
		return llRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ForzarPreCompilacionDelGestorDeSalud() as Void
		local loEx as Exception
		try
			&& Esto es solo para forzar el lazy y precompilar la DLL del gestor de Salud que se va a utilizar siempre en los logueos interactivos.
			this.oGestorDeSaludBasesDeDatos.BaseSinDiscoFisico( "SYSTEMSTARTUP_FAKE" )
		Catch To loEx
		endtry 
	endfunc 

enddefine