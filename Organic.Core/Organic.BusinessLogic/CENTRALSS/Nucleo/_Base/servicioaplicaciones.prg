define class ServicioAplicaciones as zooSession of ZooSession.Prg
	
	#include registry.h

	#IF .f.
		Local this as ServicioAplicaciones of ServicioAplicaciones.prg
	#ENDIF
	
	cAplicacion = ""
	cNombreAplicacionUsuario = ""
	cVersion = ""
	cSerie = ""
	cEstadoDelSistema = ""
	lSalioDelSistema = .f.
	lMostrarAdnImplant = .f.
	oRegistry = null

	*-----------------------------------------------------------------------------------------
	function Init( tcAplicacion as String, tcNombreAplicacionUsuario as string ) as Void
		dodefault()
		this.cAplicacion = tcAplicacion
		this.cNombreAplicacionUsuario = tcNombreAplicacionUsuario

		_screen.AddProperty( "lUsaCapaDePresentacion", .f. )
		_screen.AddProperty( "lEsModoSystemStartUp", .f. )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function InstanciarAplicacion( tcRutaScriptEjecucion as String, tlModoSilencioso as Boolean, tcSerie as string, tcClave as string, tcSitio as string ) as boolean
		local loError as Exception, loEx as Exception, loMensajes as object, llOk as Boolean

		********** Esta debe ser la primer linea!!!!!!!!!!!!!!!!!!!!!!!
		_Screen.lUsaCapaDePresentacion = empty( tcRutaScriptEjecucion )
		_Screen.lEsModoSystemStartUp = tlModoSilencioso
		***************************************************************		
		
		llOk = .t.

		this.InicializarEstado( tlModoSilencioso )
		this.InformarEstado( "Iniciando aplicación" )
		this.CrearInstanciaZoo()
		this.CrearInstanciaDeLaAplicacion() &&Crear app y tambien goServicios
		this.CargarScriptOrganic( tcRutaScriptEjecucion )
		this.SetearEtiquetaEstado()
		this.oRegistry = _screen.zoo.CrearObjeto( "registry", "registry.vcx" )			
		this.SetearPath()		
		goServicios.Mensajes.HabilitarMensajeria( !goServicios.Ejecucion.lScriptCargado ) 
		bindevent(_screen.Zoo.App, "EventoMensajeAdvertencia", this, "MensajeAdvertencia" )
		bindevent(_screen.Zoo.App, "EjecutandoSalidaDelSistema", this, "SetearSalidaDelSistema" )
		
		On shutdown do SalidaDelSistema in main
		
		if this.IniciarAplicacionBase( tcSerie, tcClave, tcSitio )
			goServicios.Mensajes.HabilitarMensajeria( .t. )
			this.PedirLogin()
			if this.lSalioDelSistema
				llOK = .F.
			else
				this.DespuesDelLogin()
				_Screen.zoo.App.ProcesoDeDatosFixParametros()
				this.ControlarBloqueoDeSistema()
				this.ControlDeSerieDemo()
				if goServicios.Ejecucion.TieneScriptCargado()					
					this.RegistrarTiempoDeInicioDeAplicacion()
					goServicios.Ejecucion.EjecutarAcciones()
				else
					this.ConfigurarMenuPrincipalExtendido()
					this.ConfigurarMenuPrincipal()
					this.CerrarEntornoVisual()
					this.IniciarServicioPoolDeObjetos()
					this.IniciarServicioPoolDeAplicaciones()
					this.InformarEstadisticasViaApi()
					this.RegistrarTiempoDeInicioDeAplicacion()
										
				endif				
				unbindevents( _screen.Zoo.App, "InformarEstado", this, "InformarEstado" )

				if !tlModoSilencioso
					this.Ejecutar()
				endif
			EnDif		
		else
			llOk = .f.
		endif
		
		return llOk
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function SetearSalidaDelSistema() as Void
		this.lSalioDelSistema = .t.
		on shutdown
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function IniciarServicioPoolDeObjetos() as Void
		bindevent( goparametros.oDatos, "CambioParametros", goServicios.PoolDeObjetos, "Liberar" )
		goServicios.PoolDeObjetos.Iniciar()
	endfunc

	*-----------------------------------------------------------------------------------------
	function IniciarServicioPoolDeAplicaciones() as Void
		bindevent( goparametros.oDatos, "CambioParametros", goServicios.Ejecucion, "ReiniciarPoolDeAplicacionesInactivos", 1 )
		if type( "_screen.Zoo.App.oFormPrincipal.hWnd" ) == "N"
			goServicios.Ejecucion.IniciarNuevaInstanciaDeAplicacion( _screen.Zoo.App.oFormPrincipal.hWnd )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function GenerarDin() as Void
	endproc

	*-----------------------------------------------------------------------------------------
	protected function Ejecutar() as Void
		Read Events
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function GenerarFXP() as void
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function GenerarFXPEspecifico( tcRuta as String ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerPath() as string
		local lcRutaInicial as String, lcPath as String

		&& El siguiente SYS le indica a VFP que cualquier NewObject para instanciar un objeto, primero debe buscar 
		&& La libreria dentro del EXE y de no encontrarla ahí la deberia buscar en todo el PATH en el Orden declaro del path.
		&& Sys(2450,1) => Indica a VFP que debe buscar los prg/fxp/xml/img etc dentro del EXE contenedor y luego fuera en el path.
		&& Sys(2450,0) => Indica a VFP que debe buscar los prg/fxp/xml/img etc primero en el path y luego en el EXE.
		Sys(2450,1)

		lcRutaInicial = addbs( _screen.zoo.cRutaInicial )
		
		&& Aca se define el path de la aplicación en el EXE.
		&& La prioridad la tiene el Curdir(), luego el path que aquí se define.
		&& Cada path que se agrega infiere levemente en la performance, ya que FOX internamente revisa todos los paths 
		&& para encontrar que PRG instanciar, siempre revisa TODOS no importa si el PRG se encuentra dentro del EXE.
		&& Los invito a mantener este set path lo más magro posible.
		
		&& El path Personal debe ir primero según Funcionalidad Nº 1766
		lcPath = lcRutaInicial + 'personal\;' + lcRutaInicial + 'Hooks\;' + lcRutaInicial + "Generados\;" + lcRutaInicial + 'Bin\;'
		
		&& Rutas de las imagenes
		lcPath = lcPath + lcRutaInicial + 'imagenes\;' + lcRutaInicial + 'imagenes\bmps\;' + ;
		lcRutaInicial + 'imagenes\cursores\;' + lcRutaInicial + 'imagenes\gifs\;' + lcRutaInicial + 'imagenes\iconos\;' + ;
		lcRutaInicial + 'imagenes\pngs\;' + lcRutaInicial + 'imagenes\psd\;'

			 
		
		return lcPath
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearPath() As Void
		local lcPath as String
		
		this.InformarEstado( "Cargando rutas del sistema" )
		lcPath = this.ObtenerPath()
		Set Path To ( lcPath ) Additive
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function LogIn() as Void
		with _Screen.zoo.App
			this.InformarEstado( "Esperando login y/o selección de base de datos" )

			If .Login()
				.InicializarBaseDeDatos()
				.InicializarTimerAlarmaChecklineHost()
			Else
				This.SalidaQuit()
			endif
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function LevantarFlags() void
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SalidaQuit() as Void
		Local loError As Exception, loEx, loControlErrores As Object
		try 
			_screen.Zoo.App.oSalida.SalidaDelSistema()
		Catch To loError
			Local llDesglosar
			llDesglosar = .T.

			If File( "ZooException.prg" ) Or File( "ZooException.fxp" )

				loEx = Newobject( "ZooException", "ZooException.prg" )
				With loEx
					.Grabar( loError )
				Endwith

				loControlErrores = Newobject( "ControlErrores", "controlErrores.prg" )
				If loControlErrores.EsErrorControlado( loEx )
					If loControlErrores.ControlarError( loEx )
						llDesglosar = .F.
					Endif
				Endif

			Else
				loEx = Null
			Endif

			If llDesglosar
				Do DesglosarError With loError, loEx
			Endif

		finally
			This.lSalioDelSistema = .T.
		endtry
			
	endfunc

	*-----------------------------------------------------------------------------------------
	function InicializarEstado( tlModoSilencioso as Boolean) as Void
		* debe implementarse en las subclases con entorno visual
	endfunc 

	*-----------------------------------------------------------------------------------------
	function InformarEstado( tcEstado as String, tlEspera as Boolean ) as Void
		* debe implementarse en las subclases con entorno visual
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function SetearEtiquetaEstado() as Void
		* debe implementarse en las subclases con entorno visual
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CerrarEntornoVisual() as Void
		* debe implementarse en las subclases con entorno visual
	endfunc 

	*-----------------------------------------------------------------------------------------
	function MensajeAdvertencia( tcMensaje as String ) as Void
		* debe implementarse en las subclases con entorno visual
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CrearInstanciaZoo() as Void
		_Screen.AddProperty( "Zoo" )
		_Screen.Zoo = Newobject( "Zoo", "Zoo.prg" )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function CrearInstanciaDeLaAplicacion() as Void
		local lcUbicacion as String, loMapeadorADN as Object, loEstructura as Object
		_screen.Zoo.IniciarAplicacion( "Aplicacion" + this.cAplicacion )
		bindevent( _screen.Zoo.App, "InformarEstado", this, "InformarEstado", 1 )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CargarScriptOrganic( tcRutaScriptEjecucion as String ) as Void
		goServicios.Ejecucion.CargarScript( tcRutaScriptEjecucion )
		if !empty( tcRutaScriptEjecucion ) and file( tcRutaScriptEjecucion )
			_screen.zoo.app.lSeccion9 = .f.
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function IniciarAplicacionBase( tcSerie as string, tcClave as string, tcSitio as String ) as Boolean
		local llInicioOk as Boolean
		this.InformarEstado( "Inicializando servicios" )
		with _Screen.zoo.App as aplicacionBase of aplicacionBase.prg
			.lSinSucursalActiva = .T.
			.lMostrarAdnImplant = this.lMostrarAdnImplant
			llInicioOk = .Iniciar( tcSerie, tcClave, tcSitio )
		endwith
		return llInicioOk
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function PedirLogin() as Void
		if goServicios.Ejecucion.TieneScriptCargado()
			goServicios.Ejecucion.LogIn()
		else
			goServicios.MonitorSaludBasesDeDatos.VerificarEjecucionDeADNImplantEnBasesDeDatosDeSistema()
*!*				goServicios.MonitorSaludBasesDeDatos.VerificarSaludEnBasesDeDatosDeSistema()
			this.LogIn()
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ControlarBloqueoDeSistema() as Void
		local llEsAdmin as Boolean, llPuedeIngresar as Boolean, lcMensaje as string, lcMensajeDos as string

		llPuedeIngresar = _Screen.zoo.App.SePuedeIngresar() && Verifica si el ingreso a la app esta bloqueado. (ej, desde registro terminal se puede bloquear el ing.)
		
		if !llPuedeIngresar
			llEsAdmin = goServicios.Seguridad.lEsAdministrador && Si un admin ingresa por script Organic es .F.
			
			lcMensaje = "¡¡ATENCIÓN!! El sistema puede no estar funcionando con todas sus caracteristicas ya que el ingreso se encuentra " + ;
						 		'deshabilitado y solo pueden acceder usuarios que tengan perfil "Administrador"'			
			lcMensajeDos = 'Le sugerimos habilitar el ingreso al sistema desde el menú "Seguridad-Aplicaciones en ejecución"'

			this.LoguearInformacion( lcMensaje )
			this.LoguearInformacion( lcMensajeDos )
			
			if goServicios.Ejecucion.InformarVisualmenteElBloqueoDelSistema()
				goServicios.Mensajes.HabilitarMensajeria( .t.) 
				 _Screen.lUsaCapaDePresentacion = .t. 
			endif
			
			if llEsAdmin
				if !goServicios.Ejecucion.TieneScriptCargado() or goServicios.Ejecucion.InformarVisualmenteElBloqueoDelSistema()
					goServicios.Mensajes.Alertar( lcMensaje)					
					goServicios.Mensajes.Informar( lcMensajeDos )				
				endif
			else
				lcMensaje = "Ingreso denegado al sistema. Por favor comuníquese con el administrador."
				this.LoguearInformacion( lcMensaje )
				if goServicios.Ejecucion.TieneScriptCargado() and goServicios.Ejecucion.InformarVisualmenteElBloqueoDelSistema()
					goServicios.Mensajes.Informar( lcMensaje )	
				endif
				_Screen.zoo.App.BajarServiciosYSalirSiFallo( lcMensaje, .t. )
			endif
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ControlDeSerieDemo() as Void
		if _Screen.Zoo.App.cSerie = "DEMO" and !goServicios.Ejecucion.TieneScriptCargado()
			goFormularios.MostrarScx( "EsperaDemo" )
			read events
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ConfigurarMenuPrincipalExtendido() as Void
		local loCreadorAccesoDirecto as CreadorAccesosDirectosListados of CreadorAccesosDirectosListados.prg
		if !_Screen.zoo.EsModoSystemStartup()
			this.InformarEstado( "Configurando menú principal extendido" )
			loCreadorAccesoDirecto = _screen.zoo.CrearObjetoPorProducto( "CreadorAccesosDirectosListados" ) 
			loCreadorAccesoDirecto.Crear()
			loCreadorAccesoDirecto = null
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ConfigurarMenuPrincipal() as Void
		this.InformarEstado( "Configurando menú principal" )
		_Screen.Zoo.App.CrearFormPrincipal()
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function DespuesDelLogin() as Void
		&& Acciones despues de estar logueado y posicionado en una base de datos.
		with _Screen.zoo.App as aplicacionBase of aplicacionBase.prg
			if this.lSalioDelSistema
				.ProcesarInstanciacionErroneaDeAplicacion()
			endif
			.DespuesDelLogin()
		endwith		
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function RegistrarTiempoDeInicioDeAplicacion() as Void
		goServicios.RegistroDeActividad.RegistrarTiempoDeInicioDeAplicacion()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function LoguearInformacion( tcMensaje as String ) as Void
		if ( vartype( _Screen.Zoo )='O' and vartype( _Screen.Zoo.App )='O' )
			_Screen.Zoo.App.Loguear( alltrim( tcMensaje ) )
			_Screen.Zoo.App.FinalizarLogueo()
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function InformarEstadisticasViaApi() as Void
	local loEntBD as Object

			loEntBD = newobject("ent_basededatos","ent_basededatos.prg")
			if !isnull(loEntBD) and vartype(loEntBD) = 'O' and _vfp.StartMode = 4 and _screen.zoo.app.cProducto = '06'
				loEntBD.InformarEstadisticasAPI()
			endif
	endfunc 
	
enddefine