define class ServicioRegistroDeActividad as Servicio of Servicio.prg

	#if .f.
		local this as ServicioRegistroDeActividad of ServicioRegistroDeActividad.prg
	#endif
	
	protected oMonitorDeActividadDeAplicacion, lSeRegistroElTiempoDeInicioDeLaAplicacion, oListaDeActividades, oSentenciasParaAtributoFramework, cSucursalActiva_buffer 

	oMonitorDeActividadDeAplicacion = null
	oSentenciasParaAtributoFramework = null
	oListaDeActividades = null
	lSeRegistroElTiempoDeInicioDeLaAplicacion = .f.
	cSucursalActiva_buffer = ""
	
	#IF .f.
		local this as ServicioRegistroDeActividad of ServicioRegistroDeActividad.prg
	#ENDIF
	
	lEstaHabilitado = .F.
	lTrazaExtendidaHabilitada = .F.
	lTrazaExtendidaHabilitadaMensajeria = .F.

	*-----------------------------------------------------------------------------------------
	function oMonitorDeActividadDeAplicacion_Access() as Object
		if !this.lDestroy and isnull( this.oMonitorDeActividadDeAplicacion )
			this.oMonitorDeActividadDeAplicacion = _screen.Zoo.CrearObjeto( "MonitorDeActividadDeAplicacion" )
		endif
		return this.oMonitorDeActividadDeAplicacion
	endfunc

	*-----------------------------------------------------------------------------------------
	function oListaDeActividades_Access() as ZooColeccion of ZooColeccion.prg
		if !this.lDestroy and isnull( this.oListaDeActividades )
			this.oListaDeActividades = _screen.Zoo.Crearobjeto( "ZooColeccion" )
		endif
		return this.oListaDeActividades
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function oSentenciasParaAtributoFramework_Access() as Object
		if isnull( this.oSentenciasParaAtributoFramework )
			this.oSentenciasParaAtributoFramework = newobject( "SentenciasParaAtributoFramework", "SentenciasParaAtributoFramework.prg" )
		endif
		return this.oSentenciasParaAtributoFramework
	endfunc

	*-----------------------------------------------------------------------------------------
	function Init() as Boolean
		if dodefault()
			this.SetearVariablesDelServicio()
			declare Long GetTickCount in win32api
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function HabilitarTrazaExtendidaMensajeria() as VOID
		This.lTrazaExtendidaHabilitadaMensajeria = .T.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function DeshabilitarTrazaExtendidaMensajeria() as VOID
		This.lTrazaExtendidaHabilitadaMensajeria = .f. or this.SeDebeHabilitarLaTrazaExtendida()
	endfunc

	*-----------------------------------------------------------------------------------------
	function Destroy() as Void
		this.Detener()
		clear dlls "GetTickCount"
		dodefault()
	endfunc

	*-----------------------------------------------------------------------------------------
	function Iniciar() as Void
		dodefault()
		if this.EstaHabilitado()
			this.ConfigurarMonitorDeActividad()
		Endif	
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Detener() as Void
		if this.EstaHabilitado()
			this.DesbindearEvento( this.oMonitorDeActividadDeAplicacion, "EventoAplicacionInactiva", this, "Ejecutar" )
			this.oMonitorDeActividadDeAplicacion.Detener()
			this.PersistirDatos()
		endif
		dodefault()
	endfunc

	*-----------------------------------------------------------------------------------------
	function EstaHabilitado() as Boolean
		local lcSucActiva as string
		
		lcSucActiva = iif( type( "_Screen.zoo.app.cSucursalActiva" ) == "C", _Screen.zoo.app.cSucursalActiva, "" )
		
		if ( this.cSucursalActiva_buffer <> lcSucActiva )
			this.SetearVariablesDelServicio()
		endif
		return this.lEstaHabilitado and type( "goServicios.Timer" ) == "O"
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function SeDebeHabilitarLaTrazaExtendida() as Void
		local ldFechaDesde as Date, ldFechaHasta as Date
		ldFechaDesde = goServicios.Registry.Nucleo.FechaDeHabilitacionDeTrazaExtendida
		ldFechaHasta = ldFechaDesde + 2
		return between( goServicios.Librerias.ObtenerFecha(), ldFechaDesde, ldFechaHasta )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ConfigurarMonitorDeActividad() as Void
		this.oMonitorDeActividadDeAplicacion.nSegundosFrecuenciaDeMonitoreo = 30
		this.BindearEvento( this.oMonitorDeActividadDeAplicacion, "EventoAplicacionInactiva", this, "Ejecutar" )
		this.oMonitorDeActividadDeAplicacion.Iniciar()
	endfunc

	*-----------------------------------------------------------------------------------------
	function Ejecutar() as Void
		if this.EstaHabilitado() and this.oMonitorDeActividadDeAplicacion.VerificarSiElUsuarioNoEstaInteractuando()
			this.PersistirDatos()
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function Registrar( tcInvocador as String, tcActividad as String ) as Void
		local lcCodigo as String
		if this.EstaHabilitado()
			lcCodigo = this.IniciarRegistro( tcInvocador, tcActividad )
			this.FinalizarRegistro( lcCodigo )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function IniciarRegistro( tcInvocador as String, tcActividad as String ) as String
		local loRegistroDeActividad as Object, ltMomentoInicio as Datetime, lcRetorno as String
		lcRetorno = ""
		if this.EstaHabilitado()
			loRegistroDeActividad = newobject( "RegistroDeActividad" )
			loRegistroDeActividad.Codigo = goServicios.Librerias.ObtenerGuidPK()
			loRegistroDeActividad.Invocador = tcInvocador
			loRegistroDeActividad.Actividad = tcActividad
			loRegistroDeActividad.MomentoInicio = GetTickCount()
			ltMomentoInicio = datetime()
			loRegistroDeActividad.FechaInicio = ttod( ltMomentoInicio )
			loRegistroDeActividad.HoraInicio = this.ExtraerHora( ltMomentoInicio )
			this.oListaDeActividades.Agregar( loRegistroDeActividad, loRegistroDeActividad.Codigo )
			lcRetorno = loRegistroDeActividad.Codigo
		endif
		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function EstablecerTiemposEnRegistro( tcCodigo as String ) as Void
		local loRegistroDeActividad as Object, ltMomentoFin as Datetime
		if this.EstaHabilitado() and this.oListaDeActividades.Buscar( tcCodigo )
			loRegistroDeActividad = this.oListaDeActividades.Item[ tcCodigo ]
			loRegistroDeActividad.MomentoFin = GetTickCount()
			ltMomentoFin = datetime()
			loRegistroDeActividad.FechaFin = ttod( ltMomentoFin )
			loRegistroDeActividad.HoraFin = this.ExtraerHora( ltMomentoFin )
			loRegistroDeActividad.TiempoNetoSinInteracciondelUsuario = ( loRegistroDeActividad.MomentoFin - loRegistroDeActividad.MomentoInicio ) / 1000
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function FinalizarRegistros( toColeccionDeRegistros as ZooColeccion of ZooColeccion.prg, tcZADSFW as String ) as Void
		local lcCodigoActividad as String
		for each lcCodigoActividad in toColeccionDeRegistros
			This.FinalizarRegistro( lcCodigoActividad, tcZADSFW )
		endfor
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EliminarRegistros( toColeccionDeRegistros as ZooColeccion of ZooColeccion.prg ) as Void
		local lcCodigoActividad as String
		for each lcCodigoActividad in toColeccionDeRegistros
			This.EliminarRegistro( lcCodigoActividad )
		endfor
	endfunc

	*-----------------------------------------------------------------------------------------
	function EliminarRegistro( tcCodigo as String ) as Void
		if this.EstaHabilitado() and this.oListaDeActividades.Buscar( tcCodigo )
			this.oListaDeActividades.Remove( tcCodigo )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function FinalizarRegistro( tcCodigo as String, tcZADSFW as String ) as Void
		local loRegistroDeActividad as Object
		if this.EstaHabilitado() and this.oListaDeActividades.Buscar( tcCodigo )
			loRegistroDeActividad = this.oListaDeActividades.Item[ tcCodigo ]
			if empty( loRegistroDeActividad.MomentoFin )
				This.EstablecerTiemposEnRegistro( tcCodigo )
			endif
			if !empty( tcZADSFW )
				loRegistroDeActividad.ZADSFW = tcZADSFW
			endif
			loRegistroDeActividad.Finalizado = .T.
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function RegistrarTiempoDeInicioDeAplicacion() as Void
		local lcActividad as string, lnSegundos as Integer, lnSegundosInteractivos as Integer,;
			lcFechaInicio as String, lcHoraInicio as String, ;
			lcFechaFin as String, lcHoraFin as String, lcObservaciones as String, ;
			lcValores as string, loSentenciasAtributosFW as Object, lcCamposInsert as String, lcDatosInsert as String, ;	
			lcNeto as string, loError as Exception, loEx as zooexception OF zooexception.prg
		try
			if this.EstaHabilitado() and !this.lSeRegistroElTiempoDeInicioDeLaAplicacion and vartype( goDatosDeStartupDeLaApp ) == "O"
				goDatosDeStartupDeLaApp.Registrar( 4 )

				if ( goDatosDeStartupDeLaApp.lLogueoInteractivo )
					lnSegundosInteractivos = goDatosDeStartupDeLaApp.nSecondsPostLogin - goDatosDeStartupDeLaApp.nSecondsPreLogin 
					lnSegundos = goDatosDeStartupDeLaApp.nSecondsFormularioPrincipal - goDatosDeStartupDeLaApp.nSecondsInicio
					lnSegundos = lnSegundos - lnSegundosInteractivos
				else
					lnSegundos = goDatosDeStartupDeLaApp.nSecondsFormularioPrincipal - goDatosDeStartupDeLaApp.nSecondsInicio
				endif

				loSentenciasAtributosFW = _Screen.zoo.CrearObjeto( "SentenciasParaAtributoFramework", "SentenciasParaAtributoFramework.prg" )
				lcCamposInsert = loSentenciasAtributosFW.ObtenerSentenciaCamposInsert()
				lcDatosInsert = loSentenciasAtributosFW.ObtenerSentenciaValoresInsert()
				loSentenciasAtributosFW = null

				do case
					case goDatosDeStartupDeLaApp.lLogueoInteractivo
						lcActividad = "INGRESO INTERACTIVO"
					case goDatosDeStartupDeLaApp.lIngresoSystemStartup 
						lcActividad = "INGRESO SYSTEMSTARTUP"
					case goDatosDeStartupDeLaApp.lEsScriptOrganic
						lcActividad = "INGRESO SCRIPT"
					otherwise
						lcActividad = "INGRESO"
				endcase

				lcHoraInicio = substr( transform( goDatosDeStartupDeLaApp.dDateTimeInicio ) , 10 )
				lcHoraFin = substr( transform( goDatosDeStartupDeLaApp.dDateTimeFormularioPrincipal ) , 10 )			

				lcObservaciones = ""
				lcNeto = transform( lnSegundos - goServicios.Mensajes.nSegundosInteraccion  )

				if goServicios.Datos.EsNativa()
					lcFechaInicio = "{" + transform( ttod( goDatosDeStartupDeLaApp.dDateTimeInicio ) )+ "}"
					lcFechaFin = "{" + transform( ttod( goDatosDeStartupDeLaApp.dDateTimeFormularioPrincipal ) ) + "}"
	 			else
		 			lcFechaInicio = "'" + transform( goDatosDeStartupDeLaApp.dDateTimeInicio ) + "'"
	 				lcFechaFin = "'" + transform( goDatosDeStartupDeLaApp.dDateTimeFormularioPrincipal) + "'"
				endif

				lcValores = "'" + goServicios.Librerias.ObtenerGuidPK() + "', " + ;
							"'" + _screen.Zoo.App.cProyecto + "'," + ;
							"'" + lcActividad + "'," + ;
							"" + lcFechaInicio  + "," + ;
							"'" + lcHoraInicio + "'," + ;
							"" + lcFechaFin  + "," + ;
							"'" + lcHoraFin + "'," + ;
							"'" + lcObservaciones + "'," +;
							lcNeto + "," +;
							lcDatosInsert 

				goServicios.Datos.EjecutarSentencias( "INSERT INTO RegActiv ( cCodigo, Invocador, cActividad, cFechaIni, cHoraIni, cFechaFin, cHoraFin, obs, nNeto, "+ lcCamposInsert + ") VALUES ( " + lcValores + " )", "RegActiv", "", "", this.DataSessionId )
				this.lSeRegistroElTiempoDeInicioDeLaAplicacion = .t.
			endif
		catch to loError
			loEx = _Screen.zoo.CrearObjeto( "ZooException" )
			loEx.Message = "Error de baja prioridad mientras que se intentaba grabar datos sobre el inicio de la aplicación."
			loEx.Grabar( loError )
			loEx = null
		endtry 				
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ExtraerHora( tFechaYHora as Datetime ) as String
		return padl( transform( hour( tFechaYHora ) ), 2, "0" ) + ":" + padl( transform( minute( tFechaYHora ) ), 2, "0" ) + ":" + padl( transform( sec( tFechaYHora ) ), 2, "0" )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function PersistirDatos() as Void
		local loRegistroDeActividad as Object, loActividadesFinalizadas as Collection
		
		loActividadesFinalizadas = newobject( "Collection" )
		for each loRegistroDeActividad in this.oListaDeActividades
			if loRegistroDeActividad.Finalizado
				loActividadesFinalizadas.Add( loRegistroDeActividad )
			endif
		endFor
		for each loRegistroDeActividad in loActividadesFinalizadas
			this.InsertarRegistroDeActividad( loRegistroDeActividad )
			this.InsertarInformacionDeContextoAUnaActividad( loRegistroDeActividad )
			this.oListaDeActividades.Remove( loRegistroDeActividad.Codigo )
		endFor

	endfunc

	*-----------------------------------------------------------------------------------------
	protected function InsertarRegistroDeActividad( toRegistroDeActividad as Object ) as Void
		local lcTabla as String, lcComandoInsert as String, loValores as Object
		lcTabla = "REGACTIV"
		loValores = this.oSentenciasParaAtributoFramework.ObtenerObjetoValoresAtributosGenericos()
		loValores.cZADSFW = toRegistroDeActividad.ZADSFW
		lcComandoInsert = "INSERT INTO " + lcTabla + ;
			"( cCodigo, " + ;
			"Invocador, " + ;
			"cActividad, " + ;
			"cFechaIni, " + ;
			"cHoraIni, " + ;
			"cFechaFin, " + ;
			"cHoraFin, " + ;
			"nNeto, " + ;
			this.oSentenciasParaAtributoFramework.ObtenerSentenciaCamposInsert() + " )" + ;
			" values " + ;
			"( " + goServicios.Librerias.ValorAStringSegunTipoBase( toRegistroDeActividad.Codigo ) + ", "  + ;
			goServicios.Librerias.ValorAStringSegunTipoBase( toRegistroDeActividad.Invocador ) + ", " + ;
			goServicios.Librerias.ValorAStringSegunTipoBase( toRegistroDeActividad.Actividad ) + ", " + ;
			goServicios.Librerias.ValorAStringSegunTipoBase( toRegistroDeActividad.FechaInicio ) + ", " + ;
			goServicios.Librerias.ValorAStringSegunTipoBase( toRegistroDeActividad.HoraInicio ) + ", " + ;
			goServicios.Librerias.ValorAStringSegunTipoBase( toRegistroDeActividad.FechaFin ) + ", " + ;
			goServicios.Librerias.ValorAStringSegunTipoBase( toRegistroDeActividad.HoraFin ) + ", " + ;
			goServicios.Librerias.ValorAStringSegunTipoBase( toRegistroDeActividad.TiempoNetoSinInteracciondelUsuario ) + ", " + ;
			this.oSentenciasParaAtributoFramework.ObtenerSentenciaValoresInsert( loValores ) + " )"

		goServicios.Datos.EjecutarSentencias( lcComandoInsert, lcTabla )
		loValores = null
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function InsertarInformacionDeContextoAUnaActividad( toRegistroDeActividad as RegistroDeActividad of ServicioRegistroDeActividad.prg ) as Void
	
		if !toRegistroDeActividad.TieneInformacionDeContexto()
			return 
		endif
		
		local lcTabla as String, lcComandoInsert as String, loValores as Object, loItem as ItemInformacionDeContexto of ServicioRegistroDeActividad.prg
		lcTabla = "REGACTIVDET"
		
		for each loItem in toRegistroDeActividad.oInformacionDeContexto foxObject
			loValores = this.oSentenciasParaAtributoFramework.ObtenerObjetoValoresAtributosGenericos()
			loValores.cZADSFW = toRegistroDeActividad.ZADSFW
			lcComandoInsert = "INSERT INTO " + lcTabla + ;
				"( cCodigo, " + ;
				"cCodigoAvc, " + ;
				"cCodigoCon, " + ;
				"cContexto, " + ;
				this.oSentenciasParaAtributoFramework.ObtenerSentenciaCamposInsert() + " )" + ;
				" values " + ;
				"( " + goServicios.Librerias.ValorAStringSegunTipoBase( goServicios.Librerias.ObtenerGuidPK() ) + ", "  + ;
				goServicios.Librerias.ValorAStringSegunTipoBase( toRegistroDeActividad.Codigo ) + ", " + ;
				goServicios.Librerias.ValorAStringSegunTipoBase( left( loItem.cCodigoDeContexto, 6 ) ) + ", " + ;
				goServicios.Librerias.ValorAStringSegunTipoBase( left( loItem.cInformacion, 250 ) ) + ", " + ;
				this.oSentenciasParaAtributoFramework.ObtenerSentenciaValoresInsert( loValores ) + " )"

			goServicios.Datos.EjecutarSentencias( lcComandoInsert, lcTabla )
			loValores = null
		endfor
	endfunc

	*-----------------------------------------------------------------------------------------
	function AgregarInformacionDeContextoAUnaActividad( tcCodigoActividad as String, tcCodigoDeContexto as String, tcInformacionDeContexto as String ) as VOID
		local loRegistroDeActividad as RegistroDeActividad of ServicioRegistroDeActividad.prg

		if this.EstaHabilitado() and this.oListaDeActividades.Buscar( tcCodigoActividad )
			loRegistroDeActividad = this.oListaDeActividades.Item[ tcCodigoActividad ]
			loRegistroDeActividad.AgregarInformacionDeContexto( alltrim( tcCodigoDeContexto ), alltrim( tcInformacionDeContexto ) )
			loRegistroDeActividad = null
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function SetearVariablesDelServicio() as Void
		&& La idea es que si es una base de Replica este servicio no este habilitado.
		&& Ya que en caso contrario generaria un error en el acceso a datos.
		if type( "_Screen.zoo.app.cSucursalActiva" ) == "C" and !empty( _Screen.zoo.app.cSucursalActiva )
			this.lEstaHabilitado = ( .T. and !_Screen.zoo.EsBuildAutomatico and !_screen.Zoo.App.ObtenerValorReplicaBD() )
			this.lTrazaExtendidaHabilitada = this.SeDebeHabilitarLaTrazaExtendida()
			this.lTrazaExtendidaHabilitadaMensajeria = This.lTrazaExtendidaHabilitada
			this.cSucursalActiva_buffer = _Screen.zoo.app.cSucursalActiva
		endif
	endfunc 
	
enddefine




*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class RegistroDeActividad as custom
	
	Codigo = ""
	Invocador = ""
	Actividad = ""
	FechaInicio = {}
	HoraInicio = ""
	FechaFin = {}
	HoraFin = ""
	TiempoNetoSinInteracciondelUsuario = 0.000
	MomentoInicio = dtot( {} )
	MomentoFin = dtot( {} )
	ZADSFW = ""
	Finalizado = .f.
	oInformacionDeContexto = null
	
	*-----------------------------------------------------------------------------------------
	function TieneInformacionDeContexto() as Boolean
		return !isnull( this.oInformacionDeContexto ) and vartype( this.oInformacionDeContexto ) == "O" and this.oInformacionDeContexto.Count > 0
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarInformacionDeContexto( tcCodigoDeContexto as String, tcInformacion as String ) as Void
		&& Este metodo persiste registros para extender la información de una actividad.
		&& Persiste la información en la entidad/tabla RegActivDet
		if isnull( this.oInformacionDeContexto )
			this.oInformacionDeContexto = newobject( "collection" )
		endif
		local loItemInformacionDeContexto as ItemInformacionDeContexto of ServicioRegistroDeActividad.prg
		loItemInformacionDeContexto = newobject( "ItemInformacionDeContexto" )
		loItemInformacionDeContexto.cCodigoDeContexto = tcCodigoDeContexto
		loItemInformacionDeContexto.cInformacion = strtran( tcInformacion, "'", "" )
		this.oInformacionDeContexto.Add( loItemInformacionDeContexto, tcCodigoDeContexto )
	endfunc 
	
enddefine

*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class ItemInformacionDeContexto as Custom

	cCodigoDeContexto = "0" && 0 > sin declarar código.
	cInformacion = ""
enddefine
