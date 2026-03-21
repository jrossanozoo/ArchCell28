define class managerEjecucion as Servicio of Servicio.prg

	#IF .f.
		Local this as managerEjecucion of managerEjecucion.prg
	#ENDIF

	protected oComunicacionInterprocesos as Object

	#define GW_CHILD        5 && 0x00000005
	#define GW_HWNDNEXT     2 && 0x00000002
	#define SW_MAXIMIZE     3 && 0x00000003
	#define SW_SHOWNORMAL       1 && 0x00000002
	#define SWP_NOACTIVATE  0x0010
	protected cContenidoScriptCargado
	lScriptCargado = .f.
	oColAtributos = null
	oColAcciones = null
	oColAplicacionesId = null
	oCreadorDeProcesos = null
	oAtributoAuxiliar1 = null
	oColProcesosEjecutados = null
	cScriptCargado = ""
	lFuncionesDeclaradas = .f.
	oComunicacionInterprocesos = null
	cIdAplicacion = ""	
	oPoolDeAplicacion = Null
	cContenidoScriptCargado = ""
	lInformarVisualmenteElBloqueoDelSistema = .f.
	lHabilitarMonitorSaludBasesDeDatosEnEjecucionDeScript = .t.
	lInformarVisualmenteErrores = .f.
	oFormularioMsgSinEspera = null
	cCanal = ""	
	oColFormulariosAgrupados = null
	*-----------------------------------------------------------------------------------------
	function Init()
		dodefault()
		this.DeclararFunciones()
		this.AgregarReferencia( "ZooLogicSA.Framework.Modelo.dll" )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function oComunicacionInterprocesos_Access() as Object
		if !this.lDestroy and isnull( this.oComunicacionInterprocesos )
			this.oComunicacionInterprocesos = _screen.Zoo.CrearObjeto( "ComunicacionInterprocesos" )
		endif
		return this.oComunicacionInterprocesos
	endfunc

	*-----------------------------------------------------------------------------------------
	function oPoolDeAplicacion_Access() as Object
		if !this.lDestroy and isnull( this.oPoolDeAplicacion )
			this.oPoolDeAplicacion = _screen.Zoo.CrearObjeto( "PoolDeAplicacion" )
		endif
		return this.oPoolDeAplicacion
	endfunc

	*-----------------------------------------------------------------------------------------
	function AgregarProveedorInterprocesos( toProveedor as Object, tcCanal as String ) as Void
		this.oComunicacionInterprocesos.RegistrarProveedor( toProveedor, tcCanal )
	endfunc

	*-----------------------------------------------------------------------------------------
	function EnviarMensajeAOtroProceso( tcMensaje as string, tcCanal as string ) as Void
		this.oComunicacionInterprocesos.EnviarMensaje( tcMensaje, tcCanal )
	endfunc

	*-----------------------------------------------------------------------------------------
	function EnviarMensajeAOtroProcesoYEsperarRespuestaEnModoSincronico( tcMensaje as string, tcCanal as string, tnSegundosDeEspera as Integer ) as String
		return this.oComunicacionInterprocesos.EnviarMensajeYEsperarRespuestaEnModoSincronico( tcMensaje, tcCanal, tnSegundosDeEspera )
	endfunc

	*-----------------------------------------------------------------------------------------
	function EnviarMensajeAOtroProcesoYEsperarRespuestaEnModoAsincronico( tcMensaje as string, tcCanal as string, toProveedorInterproceso as Object ) as Void
		this.oComunicacionInterprocesos.EnviarMensajeYEsperarRespuestaEnModoAsincronico( tcMensaje, tcCanal, toProveedorInterproceso )
	endfunc

	*-----------------------------------------------------------------------------------------
	function DesregistrarProveedor( toProveedor as Object, tcCanal as String ) as Void
		this.oComunicacionInterprocesos.DesregistrarComunicacion( toProveedor )
	endfunc

	*-----------------------------------------------------------------------------------------
	function DesregistrarTodosLosProveedores() as Void
		this.oComunicacionInterprocesos.DesregistrarTodosLosProveedores()
	endfunc

	*-----------------------------------------------------------------------------------------
	function CargarScript( tcRutaScriptEjecucion as String ) as Void
		local lcScript as String
		if !empty( tcRutaScriptEjecucion )
			this.cContenidoScriptCargado = ""
			if !file( tcRutaScriptEjecucion )
				goServicios.Errores.LevantarExcepcion( "Archivo de script inexistente." )
			endif
			
			lcScript = this.ObtenerScriptDeArchivo( tcRutaScriptEjecucion )
			this.ObtenerScriptDesencriptado( lcScript )
			this.SetearIdAplicacion()
			this.cScriptCargado = tcRutaScriptEjecucion
			this.lScriptCargado = .t.
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerScriptDesencriptado( tcScript as String ) as Void
		local lnCantLineas as Integer, i as Integer, loItem as Object, lcAtributo as String, lcTipoDato as String, lcValor as String, ;
			llAgrega as Boolean, lcDesencriptado as String
		local array laLineas[ 1 ]
		
		this.oColAtributos = _screen.zoo.crearobjeto( "ZooColeccion" )
		this.oColAcciones = _screen.zoo.crearobjeto( "ZooColeccion" )

		lnCantLineas = alines( laLineas, tcScript, 5, chr( 13 ) + chr( 10 ) )
		for i = 1 to lnCantLineas
			lcDesencriptado = goServicios.Librerias.Desencriptar( laLineas[ i ] )
			this.cContenidoScriptCargado = this.cContenidoScriptCargado + chr(13) + chr(10) + lcDesencriptado
			
			lcAtributo = strextract( lcDesencriptado, "<", ">", 1 )
			lcTipoDato = upper( strextract( lcDesencriptado, "<", ">", 2 ) )
			lcValor = strextract( lcDesencriptado, "<", ">", 3 )
			if !empty( lcAtributo ) and !empty( lcTipoDato )
				if lcTipoDato = "ACCION"
					this.oColAcciones.Agregar( lcAtributo )
				else
					llAgrega = .t.
					if atc( "_SCREEN.ZOO.APP.LMODOSILENCIOSO", upper( lcAtributo ) ) > 0  &&Mantener por compatibilidad para atras.
						_Screen.lUsaCapaDePresentacion = !evaluate( lcValor )
						llAgrega = .f.
					else
						if atc( "_SCREEN.LUSACAPADEPRESENTACION", upper( lcAtributo ) ) > 0
							_Screen.lUsaCapaDePresentacion = evaluate( lcValor )
							llAgrega = .f.
						endif
					endif
	
					if llAgrega
						loItem = newobject( "ItemAtributo" )
						with loItem
							.cAtributo = upper( lcAtributo )
							.cTipoDato = lcTipoDato
							.cValor = lcValor
						endwith				
						this.oColAtributos.Agregar( loItem, upper( lcAtributo ) )
					endif
				endif
			endif
		endfor
	endfunc 

	*-----------------------------------------------------------------------------------------
	function TieneScriptCargado() as Boolean
		return this.lScriptCargado
	endfunc 

	*-----------------------------------------------------------------------------------------
	function LogIn() as Void
		local lcSucursalActiva as String, lcVersionBD as String, loRepositorio as RepositorDeBaseDeDatos of RepositorDeBaseDeDatos.prg
		
		with goServicios.Seguridad
			.cUsuarioLogueado = this.ObtenerValorAtributo( "cUsuarioLogueado" )
			.lEsAdministrador = .EsPerfilAdministrador( .cIdUsuarioLogueado )
			this.lInformarVisualmenteElBloqueoDelSistema = this.ObtenerValorAtributo( "lInformarVisualmenteElBloqueoDelSistema", .t., .f. )
			this.lHabilitarMonitorSaludBasesDeDatosEnEjecucionDeScript = this.ObtenerValorAtributo( "lHabilitarMonitorSaludBasesDeDatos", .t., .f. )
			this.lInformarVisualmenteErrores = this.ObtenerValorAtributo( "lInformarVisualmenteErrores", .t., .f. )
			goServicios.MonitorSaludBasesDeDatos.VerificarEjecucionDeADNImplantEnBasesDeDatosDeSistema()
		endwith
		with _screen.zoo.app
			.lSinSucursalActiva = .f.
			lcSucursalActiva = alltrim( upper( this.ObtenerValorAtributo( "cSucursalActiva" ) ) )
			if lcSucursalActiva = "[PREF]"
				loRepositorio = _screen.zoo.crearobjeto( "RepositorDeBaseDeDatos" )
				lcSucursalActiva = loRepositorio.ObtenerBaseDeDatos()
				release loRepositorio
			endif
			.cSucursalActiva = lcSucursalActiva

			lcVersionBD = goServicios.Seguridad.ValidarVersionBD( .cSucursalActiva )			
			if empty( lcVersionBD )
			else
				lcMensaje  = "La versión de la Base de datos " + upper( alltrim( _screen.zoo.app.cSucursalActiva ) ) + " (" + lcVersionBD + ") es superior a la de la aplicación (" + alltrim( upper( _screen.zoo.app.ObtenerVersion() ) ) + "). "
				lcAdvertir = "Se debe actualizar la versión."							
				this.Loguear( lcMensaje + lcAdvertir )
				this.SalirDeLaAplicacion()
			endif
			
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerValorAtributo( tcAtributo as String, llNoVentarError as Boolean, txValorDefault as Variant ) as Variant
		local lxRetorno as Variant, loItem as Object, lcAtributo as String
		
		lcAtributo = upper( tcAtributo )
		if this.oColAtributos.buscar( lcAtributo )
			loItem = this.oColAtributos.item( lcAtributo )
			lxRetorno = this.ObtenerValorConvertido( loItem.cValor, loItem.cTipoDato )
		else
			if llNoVentarError
				lxRetorno = txValorDefault
			else
				goServicios.Errores.LevantarExcepcion( "Error al obtener el atributo '" + lcAtributo + "'." )
			endif
		endif
		
		return lxRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerValorConvertido( tcValor as string, tcTipoDato as string ) as Variant
		local lxRetorno as Variant
		
		do case
			case tcTipoDato = "C"
				lxRetorno = tcValor
			case tcTipoDato = "L"
				lxRetorno = evaluate( tcValor )
			case tcTipoDato = "N"
				lxRetorno = evaluate( tcValor )
			case tcTipoDato = "D"
				lxRetorno = ctod( tcValor )
			otherwise
				lxRetorno = tcValor
		endcase
		
		return lxRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EjecutarAcciones() as Void
		local loError as Exception, i as Integer, lcAsignacion as String, lcValor as String, lcAccion as String
		try
			this.Loguear( "Ejecutando script: " + this.cScriptCargado )
			for i = 1 to this.oColAcciones.count
				lcAccion = this.oColAcciones[ i ]
				if occurs( "=", lcAccion ) > 0 and occurs( "IIF", upper( lcAccion ) ) = 0
					lcAsignacion = alltrim( left( lcAccion, at( "=", lcAccion ) - 1 ) )
					lcValor = alltrim( substr( lcAccion, at( "=", lcAccion ) + 1 ) )
					&lcAsignacion = &lcValor
				else
					if alltrim( upper( lcAccion ) ) == "_SCREEN.ZOO.APP.SALIR()"
						this.Loguear( "El script finalizó con éxito." )
						this.SalirDeLaAplicacion()
					else
						evaluate( lcAccion )
					endif				
				endif
			endfor
			if _Screen.lUsaCapaDePresentacion
				_screen.zoo.app.RegistrarTerminalSiCorresponde()
			endif
		catch to loError
			this.Loguear( "Se produjo un error al ejecutar el script." )
			goServicios.Errores.LevantarExcepcion( loError )
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SalirDeLaAplicacion() as Void
		local loError as Exception
		try
			_SCREEN.ZOO.APP.SALIR()
		catch to loError
			Do DesglosarError in main.prg With loError, null
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SalidaAnticipadaAlLanzarListado( tcNotificarAlCanal as String) as Void
		local loError as Exception
		try
			goServicios.Ejecucion.EnviarMensajeAOtroProceso("CerrarIndicadorDeProceso", tcNotificarAlCanal )
			_screen.zoo.app.Salir(.t.)
		catch to loError
			Do DesglosarError in main.prg With loError, null
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CerrarEjecuciones() as Void
		if !isnull( this.oFormularioMsgSinEspera ) and vartype( this.oFormularioMsgSinEspera ) == "O"
			this.oFormularioMsgSinEspera.Release()
		endif
		clear events
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EjecutarAplicacion( tcExe as String, tcParametros as String, tlForzarSalida as Boolean, tlCerrarAlSalir as Boolean ) as Void
		local lcProcessInfo as string, loItemProceso as Object
		
		lcProcessInfo = replicate( chr( 0 ), 128 )
		lnResult = this.oCreadorDeProcesos.CrearProceso32BitConReferencia( tcExe, tcParametros, 1, @lcProcessInfo )
		
		loItemProceso = newobject( "Proceso" )
		loItemProceso.Archivo = tcExe
		loItemProceso.PID = this.oCreadorDeProcesos.ObtenerPID( lcProcessInfo )
		loItemProceso.Handle = this.oCreadorDeProcesos.ObtenerHandle( lcProcessInfo )
		loItemProceso.ForzarSalida = tlForzarSalida
		loItemProceso.CerrarAlSalir = tlCerrarAlSalir 
		
		this.oColProcesosEjecutados.add( loItemProceso )
	endfunc 

	*-----------------------------------------------------------------------------------------
	hidden function TextoAInstrucciones( tcContenido as String, toInstrucciones as ZooColeccion of ZooColeccion.prg ) as Void
		local lnCantidadLineas as Integer, lnI as Integer
		
		lnCantidadLineas = ALINES( aLineasScript, tcContenido )

		for lnI = 3 to lnCantidadLineas
			 toInstrucciones.Agregar( aLineasScript(lnI) )
		endfor

	endfunc 

	*-----------------------------------------------------------------------------------------
	function MostrarEnNuevoHilo( tcEntidad as String, toColAcciones as Collection, tcMensajeDeEspera as String ) as Void
		local lcIdApp as String, loInstrucciones as zoocoleccion OF zoocoleccion.prg, lcRutaScript as String,;
			loAccion as Object, lcBuscar as String, lncantform 
	
		if goServicios.Modulos.EntidadHabilitada( tcEntidad )
			lcRutaScript = addbs( _screen.zoo.ObtenerRutaTemporal() ) + sys( 2015 ) + ".zs"
			loInstrucciones = _screen.zoo.crearobjeto( "ZooColeccion" )
			with loInstrucciones
				.Agregar( "_Screen.lUsaCapaDePresentacion = .t." )
				if !empty( tcMensajeDeEspera )
					.Agregar( "this.oFormularioMsgSinEspera = goServicios.Mensajes.EnviarSinEsperaProcesandoEnEscritorio( '" + proper( tcMensajeDeEspera ) + "' )" )
				endif
				.Agregar( "this.oAtributoAuxiliar1 = goFormularios.Procesar( '" + tcEntidad + "' )" )
				.Agregar( "bindevent( this.oAtributoAuxiliar1, 'Release', this, 'CerrarEjecuciones' )" )
				if empty(this.cCanal)
					this.cCanal = sys(2015)
				endif
				lncantform = this.ObtenerCantidadDeFormulariosInstanciados( tcentidad) + 1
				.Agregar( "this.AgregarProveedorInterprocesos( _screen.Zoo.CrearObjeto( 'ProveedorInterprocesosMostrarAsistentePromocion' ), '" + ;
							this.cCanal + "' )" )
							.Agregar( "this.cCanal = '"+this.cCanal+"'" )

				if vartype( toColAcciones ) = 'O' and lower( toColAcciones.BaseClass ) = "collection" and toColAcciones.Count > 0 
					for each loAccion in toColAcciones 
						if left( upper( loAccion ) , 6 ) = "BUSCAR"
							lcBuscar =  substr( loAccion, 8, len( loAccion ) ) 
							.Agregar( "this.oAtributoAuxiliar1.oEntidad." + lcBuscar )
						else	
							.Agregar( "this.oAtributoAuxiliar1.oKontroler.ejecutar('" + alltrim( upper( loAccion ) ) +"')" )
						endif 	
					endfor
				else
					.Agregar( "this.oAtributoAuxiliar1.show()" )
				endif 	
				if !empty( tcMensajeDeEspera )
					.Agregar( "this.oFormularioMsgSinEspera.Release()" )
				endif	
			endwith
			lcIdApp = this.GenerarScript( "", "", loInstrucciones, lcRutaScript, .f., .t. )
			this.oColAplicacionesId.add( lcIdApp )
			this.EjecutarScript( lcRutaScript )
			do while this.ObtenerIdInternoDeAplicacion( lcIdApp ) = 0 and !this.lDesarrollo
				inkey( 0.2 )
			enddo
			this.TraerAlFrente( lcIdApp )
		EndIf

	endfunc 

	*-----------------------------------------------------------------------------------------
	function IniciarNuevaInstanciaDeAplicacion( tnVentanaAActivar as Integer ) as Void
		if !_Screen.zoo.EsModoSystemStartUp() and This.oPoolDeAplicacion.EstaHabilitado()
			if This.oPoolDeAplicacion.ExisteAplicacionInactiva()
			Else
				This.oPoolDeAplicacion.IniciarNuevaInstanciaDeAplicacion( "COMPROBANTECONCF", tnVentanaAActivar )
			Endif	
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ReiniciarPoolDeAplicacionesInactivos() as Void
		this.CerrarInstanciasDeAplicacionInactivas( .T. )
		if This.oPoolDeAplicacion.EstaHabilitado()
			this.IniciarNuevaInstanciaDeAplicacion()
		Endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function MostrarFormularioEnOtraInstanciaDeAplicacion( tcEntidad as String, tcMensajeDeEspera as String ) as Void

		if _Screen.zoo.app.UtilizaCF()
			if This.oPoolDeAplicacion.EstaHabilitado()
				This.oPoolDeAplicacion.MostrarFormularioEnOtraInstanciaDeAplicacion( tcEntidad, tcMensajeDeEspera )
			else
				goServicios.Ejecucion.MostrarEnNuevoHilo( tcEntidad, null, tcMensajeDeEspera )			
			Endif
		else
			goServicios.Formularios.Mostrar( tcEntidad )
		Endif	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CerrarInstanciasDeAplicacion( tlForzada as Boolean ) as Void
		This.oPoolDeAplicacion.CerrarInstanciasDeAplicacion( tlForzada )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CerrarInstanciasDeAplicacionInactivas( tlForzada as Boolean ) as Void
		This.oPoolDeAplicacion.CerrarInstanciasDeAplicacionInactivas( tlForzada )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function MostrarScxEnNuevoHilo( tcFormulario as String ) as Void
		local lcIdApp as String, loInstrucciones as zoocoleccion OF zoocoleccion.prg, lcRutaScript as String

		lcRutaScript = addbs( _screen.zoo.ObtenerRutaTemporal() ) + sys( 2015 ) + ".zs"

		loInstrucciones = _screen.zoo.crearobjeto( "ZooColeccion" )
		with loInstrucciones
			.Agregar( "this.oAtributoAuxiliar1 = goFormularios.ProcesarScx( '" + tcFormulario + "' )" )
			.Agregar( "bindevent( this.oAtributoAuxiliar1, 'Destroy', goServicios.Ejecucion, 'CerrarEjecuciones' )" )
			.Agregar( "this.oAtributoAuxiliar1.show(1)" )
		endwith

		lcIdApp = this.GenerarScript( "", "", loInstrucciones, lcRutaScript, .f., .t. )
		this.oColAplicacionesId.add( lcIdApp )
		
		this.EjecutarScript( lcRutaScript )
		do while this.ObtenerIdInternoDeAplicacion( lcIdApp ) = 0 and !this.lDesarrollo
			inkey( 0.2 )
		enddo
		this.TraerAlFrente( lcIdApp )
	endfunc 
	*-----------------------------------------------------------------------------------------
	function MostrarfrmEnNuevoHilo( tcFormulario as String ) as Void
		local lcIdApp as String, loInstrucciones as zoocoleccion OF zoocoleccion.prg, lcRutaScript as String

		lcRutaScript = addbs( _screen.zoo.ObtenerRutaTemporal() ) + sys( 2015 ) + ".zs"
		loInstrucciones = _screen.zoo.crearobjeto( "ZooColeccion" )

		with loInstrucciones
			.Agregar( "_Screen.lUsaCapaDePresentacion = .t." )		
			.Agregar( "this.oAtributoAuxiliar1 = _screen.zoo.crearObjeto( '" + tcFormulario + "' )" )
			.Agregar( "bindevent( this.oAtributoAuxiliar1, 'Destroy', this, 'CerrarEjecuciones' )" )
			.Agregar( "this.oAtributoAuxiliar1.show()" )
		endwith

		lcIdApp = this.GenerarScript( "", "", loInstrucciones, lcRutaScript, .f., .t. )
		this.oColAplicacionesId.add( lcIdApp )
		this.EjecutarScript( lcRutaScript )
		do while this.ObtenerIdInternoDeAplicacion( lcIdApp ) = 0 and !this.lDesarrollo
			inkey( 0.2 )
		enddo
		this.TraerAlFrente( lcIdApp )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerScriptLogin( tcUsuario as String, tcSucursal as String ) as String
		local lcRetorno as String, lcEnter as String
		
		if empty( tcUsuario )
			tcUsuario = iif(empty(goServicios.Seguridad.cUsuarioLogueado),"ADMIN",goServicios.Seguridad.cUsuarioLogueado)
		endif
		if empty( tcSucursal )
			tcSucursal = alltrim( _screen.zoo.app.cSucursalActiva )
		endif
		lcEnter = chr( 13 ) + chr( 10 )
		with goServicios.Librerias
			lcRetorno = .Encriptar( "<cUsuarioLogueado><C><" + alltrim( tcUsuario ) + ">" ) + lcEnter
			lcRetorno = lcRetorno + .Encriptar( "<cSucursalActiva><C><" + alltrim( tcSucursal ) + ">" ) + lcEnter
		endwith
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EjecutarScript( tcRutaScript as String, tnVentanaAActivar as Integer  ) as Void
		local lcParametros as String, lcParametrosDev as String
		lcParametros = '"' + tcRutaScript + '"'
		lcParametrosDev = tcRutaScript
		if !empty( tnVentanaAActivar )
			lcParametros = lcParametros + ' "' + transform( tnVentanaAActivar ) + '"'
			lcParametrosDev = lcParametrosDev + " " + transform( tnVentanaAActivar )
		endif

		if _screen.zoo.lDesarrollo
			_cliptext = set( "Path" )
			this.CrearProceso32Bit( _vfp.FullName, "-t -cC:\ZOO\COLORYTALLE\CONFIG.FPW c:\zoo\nucleo\_base\EjecutarEnDesarrollo.prg '" + _Screen.Zoo.cRutaInicial + "' " + lcParametrosDev, 1, .f. )
		else
			this.CrearProceso32Bit( sys( 16, 0 ), lcParametros, 1, .f. )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oColAplicacionesId_Access() as Void
		if vartype( this.oColAplicacionesId ) != "O" or isnull( this.oColAplicacionesId )
			this.oColAplicacionesId = newobject( "Collection" )
		endif
		
		return this.oColAplicacionesId
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function oColProcesosEjecutados_Access() as Void
		if vartype( this.oColProcesosEjecutados ) != "O" or isnull( this.oColProcesosEjecutados )
			this.oColProcesosEjecutados = newobject( "Collection" )
		endif
		
		return this.oColProcesosEjecutados
	endfunc 
	

	*-----------------------------------------------------------------------------------------
	function Destroy()
		clear dlls "BringWindowToTop", "GetDesktopWindow", "GetProp", "GetWindow","SetWindowPos", ;
			"SetProp", "ShowWindow","SetForegroundWindow","SetActiveWindow" 
		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function HayAppAbiertas() as Boolean
		local lcIdApp as String, lnHandler as Integer, llRetorno as Boolean, loProceso as Object
		
		llRetorno = .f.
		for each lcIdApp in this.oColAplicacionesId foxobject
			lnHandler = this.ObtenerIdInternoDeAplicacion( lcIdApp )
			if lnHandler > 0
				llRetorno = .t.
				exit
			endif
		endfor

		for each loProceso in this.oColProcesosEjecutados foxobject
			if loProceso.ForzarSalida
				if loProceso.CerrarAlSalir
					this.oCreadorDeProcesos.MatarProceso( loProceso.Handle )
				endif
				if goLibrerias.VerificarExistenciaDeProceso(loProceso.Archivo, loProceso.PID)
					llRetorno = .T.
					exit
				endif
			endif
		endfor
		
		return llRetorno
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ObtenerHWNRelacionado( tcid ) as Void
		return this.ObtenerIdInternoDeAplicacion( tcId )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerIdInternoDeAplicacion( tcId as String ) as integer
		local lnHwnd as Integer
		lnHwnd = GetWindow( GetDesktopWindow(), GW_CHILD )
		do while lnHwnd != 0 and GetProp( lnHwnd, tcId ) != 1
			lnHwnd = GetWindow( lnHwnd, GW_HWNDNEXT )
		enddo

		return lnHwnd
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function SetearIdAplicacion() as Void
		SetProp( _vfp.hWnd, this.ObtenerValorAtributo( "IdAplicacion" ), 1 )
		This.cIdAplicacion = this.ObtenerValorAtributo( "IdAplicacion" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function TraerAlFrente( tcId as String ) as Void
		local lnHandler as Integer

		lnHandler = this.ObtenerIdInternoDeAplicacion( tcId )
		if lnHandler > 0
			BringWindowToTop( lnHandler )
		endif

	endfunc 

	*-----------------------------------------------------------------------------------------
	function oCreadorDeProcesos_Access() as Object
		if !this.lDestroy and ( vartype( this.oCreadorDeProcesos ) != 'O' or isnull( this.oCreadorDeProcesos ) )
			this.oCreadorDeProcesos = _screen.zoo.crearobjeto( "CreadorDeProcesos" )
		endif		
		return this.oCreadorDeProcesos
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CrearProceso32Bit( tcExe as string, tcParametros as string, tnShowWindow as integer, tlEsperar as Boolean ) as Boolean
		return this.oCreadorDeProcesos.CrearProceso32Bit( tcExe, tcParametros, tnShowWindow, tlEsperar )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function GenerarArchivo( tcScript as String, tcRutaArchivo as String ) as Void
		if strtofile( tcScript, tcRutaArchivo ) = 0	
			goServicios.Errores.LevantarExcepcion( "Problemas al intentar generar el archivo " + alltrim( tcRutaArchivo ) )
		endif
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerScriptDeArchivo( tcRutaScriptEjecucion ) as String
		local lcScript as String, lcCheckSum as String, lcRetorno as String, lcEnter as String
		lcEnter = chr(13) + chr(10)
		lcScript = filetostr( tcRutaScriptEjecucion )
		lcCheckSum = strextract( lcScript, "", lcEnter , 1 )
		lcScript = strtran( lcScript, lcCheckSum + lcEnter, "", 1, 1, 1 )
		if !this.ValidarCheckSum( lcScript, lcCheckSum )
			goServicios.Errores.LevantarExcepcion( "Archivo de script corrupto." )
		endif
		
		return lcScript
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarCheckSum( tcScript as String, tcCheckSum as String ) as Boolean
		local lcCheckSum as String, llRetorno as Boolean, loHasher as Object
		llRetorno = .f.
		
		lcCheckSum = sys(2007, tcScript, -1, 1 )
		if lcCheckSum = tcCheckSum 
			llRetorno = .t.
		else
			loHasher = _screen.zoo.crearobjeto( "ZooLogicSA.Framework.Modelo.Seguridad.ServiciosCriptograficos.Hasher" )
			lcCheckSum = loHasher.Encriptar( tcScript, "scriptManagerEjecucion" )
								  
			if lcCheckSum = tcCheckSum 
				llRetorno = .t.
			endif
		endif
		
		return llRetorno
	endfunc 


	*-----------------------------------------------------------------------------------------
	protected function ObtenerCheckSum( tcDato as String ) as String
		return sys(2007, tcDato, -1, 1 )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarContenidoDelScriptScript( tcUsuario as String, tcBaseDeDatos as String, ;
			toInstrucciones as zoocoleccion OF zoocoleccion.prg, tlSalir as Boolean, tlUsaCapaDePresentacion as Boolean, tcIdApp as String ) as String

		local lcEnter as String, lcScript as String, lcIdApp as String, lcInstruccion as String, lcCheckSum as String

		if empty( tcIdApp )
			lcIdApp = sys( 2015 )
		else
			lcIdApp = tcIdApp
		endif
		lcEnter = chr( 13 ) + chr( 10 )
		lcScript = ""
		if tlUsaCapaDePresentacion
			lcScript = lcScript + goServicios.Librerias.Encriptar( "<_Screen.lUsaCapaDePresentacion><L><.t.>" ) + lcEnter
		endif
		
		lcScript = lcScript + goServicios.Librerias.Encriptar( "<IdAplicacion><C><" + lcIdApp + ">" ) + lcEnter
		lcScript = lcScript + this.ObtenerScriptLogin( tcUsuario, tcBaseDeDatos )

		for each lcInstruccion in toInstrucciones foxobject
			lcScript = lcScript + goServicios.Librerias.Encriptar( "<" + alltrim( lcInstruccion ) + "><accion><>" ) + lcEnter
		endfor
		
		if tlSalir
			lcScript = lcScript + goServicios.Librerias.Encriptar( "<_Screen.Zoo.App.Salir()><accion><>" )
		endif

		lcCheckSum = this.GenerarCheckSum( lcScript )
		lcScript = lcCheckSum + chr(13) + chr(10) + lcScript 
		
		return lcScript
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function GenerarCheckSum( tcScript as String ) as string
		local loHasher as Object
		loHasher = _screen.zoo.crearobjeto( "ZooLogicSA.Framework.Modelo.Seguridad.ServiciosCriptograficos.Hasher" )
		
		return loHasher.Encriptar( tcScript, "scriptManagerEjecucion" )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function GenerarScript( tcUsuario as String, tcBaseDeDatos as String, toInstrucciones as zoocoleccion OF zoocoleccion.prg, ;
			tcArchivo as String, tlSalir as Boolean, tlUsaCapaDePresentacion as Boolean ) as String
		
		local lcScript as String, lcIdApp as String, lcInstruccion as String

		lcIdApp = sys( 2015 )
		lcScript = this.GenerarContenidoDelScriptScript( tcUsuario, tcBaseDeDatos, toInstrucciones, tlSalir, tlUsaCapaDePresentacion, lcIdApp )

		this.GenerarArchivo( lcScript, tcArchivo )
		
		return lcIdApp
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Loguear( tcTexto as String, tnNivel as Integer ) as Void
		dodefault( tcTexto, tnNivel )
		this.FinalizarLogueo()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	* Este metodo es para sacarle el tiempo de declaracion de las funciones al init y distribuirlo en el consumo.
	protected function DeclararFunciones() as Void
		if !this.lFuncionesDeclaradas
			declare integer BringWindowToTop in Win32API integer hwnd
			declare integer SetForegroundWindow in Win32API integer hwnd
			declare integer GetDesktopWindow in User32
			declare integer GetProp in User32 integer hwnd, string  lpString
			declare integer GetWindow in User32 integer hwnd, integer uCmd
			declare integer SetProp in User32 integer hwnd, string lpString, integer hData
			Declare ShowWindow In WIN32API Integer nHandle, Integer nState	

			declare integer SetWindowPos IN win32api ;
			  integer hWnd,            ; && handle to window
			  integer hWndInsertAfter, ; && placement-order handle
			  integer X,               ; && horizontal position
			  integer Y,               ; && vertical position  
			  integer cx,              ; && width
			  integer cy,              ; && height
			  integer uFlags             && window-positioning flags

			declare CloseWindow in User32 integer hwnd	
			this.lFuncionesDeclaradas = .t.
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerContenidoScriptCargado() as String
		local lcRetorno as string
		lcRetorno = this.cContenidoScriptCargado
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function InformarVisualmenteElBloqueoDelSistema() as Boolean
		return this.lInformarVisualmenteElBloqueoDelSistema
	endfunc

	*-----------------------------------------------------------------------------------------
	function HabilitarMonitorSaludBasesDeDatos()as Boolean
		return !_Screen.Zoo.EsBuildAutomatico and !_Screen.Zoo.lDesarrollo and _screen.Zoo.App.cProyecto != "ZL" and !_Screen.Zoo.EsModoSystemStartUp() and ( !this.TieneScriptCargado() or this.lHabilitarMonitorSaludBasesDeDatosEnEjecucionDeScript )
	endfunc

	*-----------------------------------------------------------------------------------------
	function ProcesarEnNuevoHilo( tcEntidad as String, toColAcciones as Collection, tcMensajeDeEspera as String, tnHwndRelacionado as Integer )
		local lcIdApp as String, loInstrucciones as zoocoleccion OF zoocoleccion.prg, lcRutaScript as String,;
			loAccion as Object, lcBuscar as String, lncantform
	
		if goServicios.Modulos.EntidadHabilitada( tcEntidad )
			lcRutaScript = addbs( _screen.zoo.ObtenerRutaTemporal() ) + sys( 2015 ) + ".zs"
			loInstrucciones = _screen.zoo.crearobjeto( "ZooColeccion" )
			with loInstrucciones
				.Agregar( "_Screen.lUsaCapaDePresentacion = .t." )
				if !empty( tcMensajeDeEspera )
					.Agregar( "this.oFormularioMsgSinEspera = goServicios.Mensajes.EnviarSinEsperaProcesandoEnEscritorio( '" + proper( tcMensajeDeEspera ) + "' )" )
				endif
				if _Screen.zoo.app.UtilizaCF()
					.Agregar( "_Screen.zoo.app.VerificarInicializacionControladorFiscal()")
				endif
				if empty(this.cCanal)
					this.cCanal = sys(2015)
				endif
				lncantform = this.ObtenerCantidadDeFormulariosInstanciados( tcentidad) + 1
				.Agregar( "this.cCanal = '"+this.cCanal+"'" )

				.Agregar( "this.oAtributoAuxiliar1 = goFormularios.Procesar( '" + tcEntidad + "' )" )
				.Agregar( "bindevent( this.oAtributoAuxiliar1, 'Release', this, 'CerrarEjecuciones' )" )
				.Agregar( "this.oAtributoAuxiliar1.nhwndRelacionado = "+ transform(tnhwndRelacionado) )
				.Agregar( "this.oAtributoAuxiliar1.oKontroler.esprincipal = .f. ")
				.Agregar( "this.oAtributoAuxiliar1.oKontroler.idProceso = '"+ transform( this.cIdAplicacion)+"'" )
				.Agregar( "this.AgregarAColeccionDeFormulariosAgrupados('"+ tcEntidad + "',"+ transform( lncantform )+"  )" )
				.Agregar( "this.oAtributoAuxiliar1.oKontroler.SetearCaptionFormularioRelacionado()") 
				.Agregar( "this.oAtributoAuxiliar1.oKontroler.SetearProveedoresComunicacion()") 
				this.AgregarAColeccionDeFormulariosAgrupados( tcEntidad, 1 ) 
				if vartype( toColAcciones ) = 'O' and lower( toColAcciones.BaseClass ) = "collection" and toColAcciones.Count > 0 
					for each loAccion in toColAcciones 
						if left( upper( loAccion ) , 6 ) = "BUSCAR"
							lcBuscar =  substr( loAccion, 8, len( loAccion ) ) 
							.Agregar( "this.oAtributoAuxiliar1.oEntidad." + lcBuscar )
						else	
							.Agregar( "bindevent( this.oAtributoAuxiliar1.okontroler, 'Eventoporinsertar', this.oAtributoAuxiliar1.okontroler, 'MostrarNuevoFormulario',1 )" )
							.Agregar( "this.oAtributoAuxiliar1.oKontroler.ejecutar('" + alltrim( upper( loAccion ) ) +"')" )
							if goServicios.Parametros.Felino.GestionDeVentas.Minorista.Promociones.MostrarAsistente
								.Agregar( "this.oAtributoAuxiliar1.oKontroler.BindearEventosComplementarios()")
							endif				
						endif 	
					endfor
				else
				endif 	
				
				if !empty( tcMensajeDeEspera )
					.Agregar( "this.oFormularioMsgSinEspera.Release()" )
				endif	
			endwith
			lcIdApp = this.GenerarScript( "", "", loInstrucciones, lcRutaScript, .f., .f. )
			this.oColAplicacionesId.add( lcIdApp )

			this.EjecutarScript( lcRutaScript )
			do while this.ObtenerIdInternoDeAplicacion( lcIdApp ) = 0
				inkey( 0.2 )
			enddo
			return lcIdApp 

		EndIf

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ActivarVentana( tnHandler as Integer, tnHwndActivo ) as Void

		wait window "" timeout 0.2 && NO SACAR !!!!
		if tnHandler <>  0
			BringWindowToTop( tnHandler )
		endif

	endfunc 
	*-----------------------------------------------------------------------------------------
	function CerrarFormularioRelacionado( tnHandler ) as Void
		if tnHandler <>  0
			CloseWindow( tnHandler )
		endif

	endfunc 
	*-----------------------------------------------------------------------------------------
	function VerificarSiSigueVivoElComprobanteRelacionado() as Void
		local llRetorno
		llRetorno = ""
		llRetorno = this.EnviarMensajeAOtroProcesoYEsperarRespuestaEnModoSincronico("ValidarExistencia" , this.cCanal,4)	
		
		return llRetorno
	endfunc 


	*-----------------------------------------------------------------------------------------
	function ActivarAsistente() as Void
		local lnI as Integer, lcCanal as String
		this.EnviarMensajeAOtroProceso("MostrarAsistente" , this.cCanal )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oColFormulariosAgrupados_Access() as Object
		if !this.lDestroy and isnull( this.oColFormulariosAgrupados )
			this.oColFormulariosAgrupados = _screen.Zoo.CrearObjeto( "ZooColeccion" )
		endif
		return this.oColFormulariosAgrupados
	endfunc
  

	*-----------------------------------------------------------------------------------------
	function AcomodarFormulario( tnHwnd, tnHwndPadre , tnLeft,tnTop,tnWidth,tnHeight ) as Void
		SetWindowPos( tnHwnd, tnHwndPadre , tnLeft,tnTop,tnWidth,tnHeight, SWP_NOACTIVATE )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarAColeccionDeFormulariosAgrupados( tcEntidad, tnCantidad) as Void
		local lnNro as Integer, lcEntidad as String, loError as Object 
		lnNro = 0
		lcEntidad = upper(alltrim( tcEntidad ))
		try
			lnNro = this.oColFormulariosAgrupados.item( lcEntidad ).cantidad
		catch to loError
			this.oColFormulariosAgrupados.agregar( createobject("ItemFormAgrupado"), lcEntidad ) 
		finally 
			this.oColFormulariosAgrupados.item( lcEntidad ).cantidad = lnNro + tnCantidad
		endtry
		
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ObtenerCantidadDeFormulariosInstanciados( tcEntidad ) as Void
		local lnNro, lcEntidad as String 
		lcEntidad = upper(alltrim( tcEntidad ))

		try
			lnNro = this.oColFormulariosAgrupados.item( lcEntidad ).cantidad
		catch
			lnnRo = 0
		endtry
		return lnNro		

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function PuedeRegistrarTerminal() as Boolean
		return this.TieneScriptCargado()
	endfunc 

enddefine

*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class ItemAtributo as Custom

	cAtributo = ""
	cTipoDato = ""
	cValor = ""

enddefine

define class Proceso as custom
	Archivo = ""
	handle = null
	PID = null
	ForzarSalida = .T.
	CerrarAlSalir = .F.
enddefine

define class ItemFormAgrupado as custom
	cantidad = 0
	canal = ''

enddefine

