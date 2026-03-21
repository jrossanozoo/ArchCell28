#INCLUDE build.h
#INCLUDE registry.h
#INCLUDE AccesoADatos.h

*-----------------------------------------------------------------------------------------
define class AplicacionBase as ZooSession of ZooSession.prg

	#IF .f.
		Local this as Aplicacionbase of Aplicacionbase.prg
	#ENDIF
		
	TipoDeBase = MOTORDEBASEDEDATOS
	cNombreDelServidorSQL = NOMBREDELSERVIDOR
	cNombreDriverSQL = ""
	cSchemaDefault = ESQUEMAPORDEFECTO
	cSchemaListadosDefault = ESQUEMALISTADOSPORDEFECTO

	oTimerBase = null
	oLibrerias = null
	oParametros = null
	oRegistry =  null
	oMenu = null
	oFormPrincipal = null

	oExportaciones = null
	oMonitor	 = null
	oFormularios = null
	oMensajes = null
	oControladorFiscal = null
	oServicioControles = null
	oDatos = null
	oModulos = null
	oSalida = null
	oEstilos = null
	oLogueos = null
	oMonitorQA = null	
	
	lSaliendo = .f.
	* Estas Propiedades no van aca
	cNombre = ""
	cOrganizacion = ""
	
	cProducto = "00"
	cVersionPKW = space(0)

	cSerie = ""
	cEstadoDelSistema = ""
	lSemaforo = .f.
	lEsSimple = .f.

	Nombre = ""
	NombreProducto = ""
	cProyecto = ''
	cSucursalActiva = ""
	cRutaParametrosOrganizacion = ""
	cRutaTablasSeguridad = ''
	cRutaDataConfig = ""

	lSinSucursalActiva = .f.
	nColorBD = 0
	cListaDeEjecutables = ""
	lMostrarMenuPrincipal = .t.
	lEnEsperaDeCierre = .f.

	lEstoyUsandoTimers = .f.
	lDebeInicializarElServicioRegistroTerminal = .t.
	
	cRutaTablasPuesto = ""
	cRutaTablasOrganizacion = ""
	cNombreExe = ""
	cArchivoDeAyuda = ""
	cFormularioPrincipal = "ZooFormPrincipal"	
	
	lSeccion9 = .T.
		
	dimension aSucursales [ 1, 3 ]
	dimension aArchivosIni[1]
	oCrearArchivosIni = null
	CBASESQLSERVER = ""

	lUtilizaPrefijoDB = .t.	
	cBDMaster = ""
	cNombreMaster = "ZOOLOGICMASTER"
	cNombreBaseDeDatosSQL = ""
	lMostrarAdnImplant = .f.
	
	lF2 = .T.
	tUltimoControl	= 0
	lForzarSalida = .F.
	lSalioDeAcercaDe = .F.
	nHandleTimerAcercaDe = 0
	oFixParametros = null
	lClaveActivacionIncorrecta = .F.
	lEstoyCambiandoSerieEnAcercaDe = .F.

	oManagerDeConfiguracionDeAgenteDeAccionesOrganic = null
	cVersionSegunIni = ""
	oVersion = null
	oTablasPermitenABMReplica = null
	
	oMonitorDeIngresoYSalida = null
	
	lEstoyEnMigrador = .F.
	cOrigenDeDatosParaMigracion = ""
	cUtilizarWinExec = ""
	oAdmistradorDeEnergia = null
	oPoolConexiones = null
	
	lSalidaForzada = .f. && se utiliza cuando detecta que hay formulario modales al salir del sistema
	lDesplegarCombos = .t.
	
	oContextoCloud = null
	lEsEntornoCloud = .f.
	lSalidaDesdeRegistroTerminal = .f.
	lSalidaDesdeRegistroTerminalFallo = .f.
	oAspectoAplicacion = null
		
	cRutaAppDataLocal = ""
	
	*-----------------------------------------------------------------------------------------
	function init() as Void
		this.AsignarClaveMenu()
		this.SetearBufferDeMemoria()
		dodefault()
		this.SetearPropiedadesBasicas()	
		This.InstanciarNetExtender()
		This.InstanciarWWDotNetBridge()
		this.AgregarReferencias()
		this.InstanciarMonitorQA()
 		this.ConfigurarAdministracionDeEnergia( .t. )
 		this.SetearEntornoCloud()
	endfunc

	*-----------------------------------------------------------------------------------------
	function SetearEntornoCloud() as Void
		this.oContextoCloud = _screen.zoo.crearobjeto( "contextoCloud" ,,this.nombreProducto )
		
		if this.oContextoCloud.EsEntornoCloud()
			this.lEsEntornoCloud = .t. 
			this.NombreProducto = this.oContextoCloud.ObtenerPrefijoDB()
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oPoolConexiones_Access() as variant
		if !this.ldestroy and ( !vartype( this.oPoolConexiones ) = 'O' or isnull( this.oPoolConexiones ) )
			this.oPoolConexiones = _screen.zoo.crearObjeto( "PoolDeConexiones" )
		endif
		return this.oPoolConexiones
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function cRutaAppDataLocal_Access() as variant
		local loDirectoriosSOFactory as Object, loDirectoriosSO as Object, lcRutaAppDataLocal as String, lcNombreProducto as String
		if !this.ldestroy and empty( this.cRutaAppDataLocal )
			local loDirectoriosSOFactory, loDirectoriosSO 
			loDirectoriosSOFactory = _screen.zoo.crearobjeto( "ZooLogicSA.Framework.Windows.Definiciones.DirectoriosSOFactory" )
			loDirectoriosSO = loDirectoriosSOFactory.Crear()
			lcRutaAppDataLocal = loDirectoriosSO.ObtenerCarpetaSistema( 12  ).FullPath
			
			lcNombreProducto = goServicios.Librerias.ObtenerDatosDeINI( addbs( _screen.zoo.app.cRutaDataconfig ) + "Dataconfig.ini", "SQL", "NombreProducto" )
	
			if !directory( addbs( lcRutaAppDataLocal  ) + "ZOOLOGIC" )
				md addbs( lcRutaAppDataLocal  ) + "ZOOLOGIC"
			endif
		
			if !directory( addbs( lcRutaAppDataLocal  ) + "ZOOLOGIC\" + _screen.zoo.app.NombreProducto )
				md addbs( lcRutaAppDataLocal  ) + "ZOOLOGIC\" + _screen.zoo.app.NombreProducto
			endif

			this.cRutaAppDataLocal = addbs( lcRutaAppDataLocal  ) + "ZOOLOGIC\" + _screen.zoo.app.NombreProducto
		endif

		return this.cRutaAppDataLocal
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function AsignarClaveMenu() as Void
		if vartype( _3EC687BB ) == "U"
	    	public _3EC687BB
	    	_3EC687BB = "3ec687bb-4880-4c4c-885e-2e716cf97813"
	    endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function oMonitorDeIngresoYSalida_Access() as Void
		if  !this.lDestroy and !( vartype( this.oMonitorDeIngresoYSalida ) == "O" )
			this.oMonitorDeIngresoYSalida = _screen.Zoo.CrearObjeto( "ZooLogicSA.Core.MonitorDeIngresoYSalida" )
			this.oMonitorDeIngresoYSalida.RutaArchivo = _Screen.Zoo.crutainicial
		endif
		return this.oMonitorDeIngresoYSalida
	endfunc

	*-----------------------------------------------------------------------------------------
	function cNombreDriverSQL_Access() as String
		if !this.lDestroy and empty( this.cNombreDriverSQL )
			this.cNombreDriverSQL = "Sql Server Native Client 10.0"
			try
				if ( !empty( goServicios.Librerias.ObtenerValorRegistroWindows( "Version", "SOFTWARE\Microsoft\Microsoft SQL Server Native Client 11.0\CurrentVersion\", "HKLM" ) ) )
					this.cNombreDriverSQL = "Sql Server Native Client 11.0"
				endif
			catch
				this.Loguear( "Falló la comprobación para determinar si el driver SQL Server Native Client 11.0 se encuentra instalado." )
			endtry
		endif
		return this.cNombreDriverSQL
	endfunc

	*-----------------------------------------------------------------------------------------
	function oAdmistradorDeEnergia_Access() as Object
		if !this.lDestroy and !( vartype( this.oAdmistradorDeEnergia ) == "O" )
			this.oAdmistradorDeEnergia = _screen.Zoo.CrearObjeto( "ZooLogicSA.Interoperabilidad.PowerManagment" )
		endif
		return this.oAdmistradorDeEnergia
	endfunc

	*-----------------------------------------------------------------------------------------
	function cBDMaster_Access() as Void
		this.cBDMaster = this.ObtenerPrefijoDB() + this.cNombreMaster
		return this.cBDMaster
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oTablasPermitenABMReplica_Access() as Object
		local loCol as zoocoleccion OF zoocoleccion.prg, lcXml as String, lcCursor as String
		
		if !this.lDestroy and isnull( this.oTablasPermitenABMReplica )
			lcXml = "ControlABMReplica.xml"					
			lcCursor = sys( 2015 )
			loCol = _screen.zoo.CrearObjeto( "ZooColeccion" )
			if file( lcXml )
				XmltoCursor( lcXml, lcCursor, 512 )
				select ( lcCursor )
				scan
					loCol.Agregar( &lcCursor..Tabla )
				endscan
				use in select( lcCursor )
			endif
			this.oTablasPermitenABMReplica = loCol
		endif
		
		return this.oTablasPermitenABMReplica
	endfunc 

	*-----------------------------------------------------------------------------------------
	function cSucursalActiva_Assign( txVal as Variant ) as Void
		local lcSucAnt as String, lcNomBaseAnt as string, loError as Exception, lcBaseDeDatos as string, lnColorant as Integer
		
		lcSucAnt = this.cSucursalActiva 
		lcNomBaseAnt = this.cNombreBaseDeDatosSql
		lnColorant = this.nColorBD
		
		try
			this.cSucursalActiva = rtrim( txVal )

			if empty( txVal )
				lcBaseDeDatos = this.cBDMaster
			else
				lcBaseDeDatos = goServicios.Librerias.ObtenerNombreSucursal( txVal )
				if !this.lSinSucursalActiva		
					goDatos.oAccesoDatos.cRutaTablas = this.ObtenerRutaSucursal( txVal )
					this.nColorBD = this.ObtenerColorBD()
				endif
			endif

			this.cNombreBaseDeDatosSql = lcBaseDeDatos
			goDatos.DesconectarMotorSql()
			goDatos.oManagerConexionASql.MarcarDBParaInicializar()
			
			this.oPoolConexiones.DesconectarTodo()

		catch to loError
			this.cSucursalActiva = lcSucAnt 
			this.cNombreBaseDeDatosSql = lcNomBaseAnt
			this.nColorBD = lnColorant
		
			goServicios.Errores.LevantarExcepcion( loError )
		endtry

		if !empty( this.cSucursalActiva ) && -> and !empty( lcSucAnt ) <- Se quita el AND..
										  &&    ya que dejaba de funcionar el ChequarParametrosPorCambioDeSucursal salvo que estes cambiando base de datos.
			this.ChequearPametrosPorCambioDeSucursal()
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function InstanciarMonitorQA() as Void
		_Screen.AddProperty( "EventoCreacionOcxFiscal" )

		if file( addbs( _screen.zoo.cRutaInicial ) + "MonitorQA.app" )
			local lcClase as String
			lcClase = "MonitorQA"
			this.oMonitorQA = newobject( lcClase, lcClase + ".app" )
		endif 
	endfunc

	*-----------------------------------------------------------------------------------------
	function ConfigurarAdministracionDeEnergia( tlEvitarQueEntreEnModoSuspendido as Boolean ) as Void
		local loExcepcion as Exception
		try
			if tlEvitarQueEntreEnModoSuspendido
				this.oAdmistradorDeEnergia.AvoidSleep()
			else
				this.oAdmistradorDeEnergia.RestorePreviousExecutionState()
			endif
		catch to loExcepcion
		endtry
	endfunc

	*-----------------------------------------------------------------------------------------
	function InstanciarNetExtender() as Void
		if !pemstatus( _screen, "NetExtender", 5 )
			_screen.AddProperty( "NetExtender", null )
		endif

		if type( "_screen.NetExtender" ) != "O" or isnull( _screen.NetExtender )
			_screen.NetExtender = this.CrearObjeto( "NetExtender" )
		endif	
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function InstanciarWWDotNetBridge() as Void
		if !pemstatus( _screen, "DotNetBridge", 5 )
			_screen.AddProperty( "DotNetBridge", null )
		endif

		if type( "_screen.DotNetBridge" ) != "O" or isnull( _screen.DotNetBridge )
			_screen.DotNetBridge = this.CrearObjeto( "WrapperDotNetBridge" )
		endif	
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function IniciarConServiciosBasicos() as Void
		this.oSalida = _screen.zoo.crearObjeto( "SalidaUnicaSistema" )
		this.LevantarSeteosIni()
		this.SetearAplicacion()					
		this.IniciarServiciosSinDependencia() 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FicharIngresoAlSistema() as Void
		if ( this.ejecutoDesdeMain() or this.ejecutoDesdeExe() or this.EjecutoDesdeFormulario() )

			if this.oMonitorDeIngresoYSalida.HaySalidasErroneas()
				this.EventoMensajeAdvertencia("El sistema se cerró de forma inesperada. El cierre incorrecto puede provocar perdida de datos." + chr(10)+ "Utilice la opcion 'Salir' del menú 'Sistema' para cerrarlo.")
				this.loguear("Hay Salidas Erroneas")
			endif

			this.oMonitorDeIngresoYSalida.FicharEntrada()
			this.loguear("Marcar Entrada")
			this.FinalizarLogueo()
		endif
	endfunc 

	*-----------------------------------------------------------------------------------
	function Iniciar( tcSerie as string, tcClave as string, tcSitio as String ) as Boolean
		local llTieneScriptCargado as Boolean, llRetorno as Boolean

		llRetorno = .t.
		with this as Aplicacionbase of Aplicacionbase.prg
			if .EjecutoDesdeExe()
				.SacarAtributosSoloLectura( upper( _screen.zoo.cRutaInicial ) )
			endif
			
			.oSalida = _screen.zoo.crearObjeto( "SalidaUnicaSistema" )
			.oSalida.InyectarMonitorIngresoYSalida( this.oMonitorDeIngresoYSalida )

			.SetearAplicacion()

			.InformarEstado( "Cargando configuraciones (INI)" )

			.LevantarSeteosIni() && Carga Dataconfig.ini & Aplicacion.Ini & Config.fpw
			.SetearTituloDeLaAplicacion()
			.SetearIconoDeLaAplicacion()
			.IniciarServiciosSinDependencia()
			
			llTieneScriptCargado = goServicios.Ejecucion.TieneScriptCargado()
			.ActualizarEntornoPorCambioDeVersion( llTieneScriptCargado )
			
			if !.VerificarAccesoAParametrosYRegistros( llTieneScriptCargado )
				return .f.
			endif
			
			.IniciarServiciosConDependencia() 

			if !(llTieneScriptCargado or this.lEsEntornoCloud)
				.VerificarExistenciaDLL()	
			endif

			if !(llTieneScriptCargado or this.lEsEntornoCloud)
				.VerificacionesGenerales()	
			endif

			.CargarSucursales()
			
			.SetarUsoDeTimers()

			.ResetearSerieApp( tcSerie, tcClave, tcSitio )

			.IniciarRegistroTerminal()
			goTimer.inicializarTimers()

			.FicharIngresoAlSistema()

			.VerificarInicioDeServiciosRest()

			if .lClaveActivacionIncorrecta
				.Salir()
			endif
			
			.SetearBasesDeDatos( llTieneScriptCargado )

			if !_screen.zoo.ldesarrollo or _vfp.startmode = 4
				.SetearAyuda()
			else
				.InformarEstado( "Inicializando menú" )
				goServicios.Seguridad.CrearColeccionHabilitaMenu()
			endif
			goServicios.AsignarServicios()
			.VerificarBDPreferente()
			.SetearComplejidadEnConsultas()

			if !empty( _screen.Zoo.App.cSucursalActiva )
				.ChequearPametrosPorCambioDeSucursal()
			endif
		endwith
				
		if !llTieneScriptCargado
			this.BuscarActualizacionesSegunParametro()
		endif
		
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function VerificarRutaDataConfig() as Void
		local loError as Exception
		** Existencia.
		if !this.lEsEntornoCloud 
			if !directory( This.cRutaDataConfig ) 
				local lcMensaje  as String
				lcMensaje = "No existe la ruta '" + alltrim( lower( This.cRutaDataConfig ) ) + "' del archivo dataconfig.ini"
				Do MostrarMensaje in Main.prg with lcMensaje, 16, "Configuración de servidor de datos" 
				this.crearGoLibrerias()
				goServicios.Librerias.TerminarProcesosRelacionados( goServicios.Librerias.ObtenerIdProcesoActual() )			
			endif
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function VerificarServidorDataconfig() as Void
		** Definición de servidor.
		if !this.lEsEntornoCloud 
			if empty( This.cNombreDelServidorSQL ) and upper( alltrim( this.TipoDeBase ) ) == "SQLSERVER"
				local lcMensaje as String 
				lcMensaje = "No se encuentra configurado el servidor SQL Server al cual debe conectarse " + this.Nombre + "." + chr(13) +;
													"Modifique el archivo [" +  this.aArchivosIni[2] + "] y configure el nombre del servidor SQL Server que desea utilizar." + chr(13) + chr(13) + ;
							"Para recibir asistencia comuníquese con Mesa de Ayuda." + chr(13) + ;
							"Por consultas de teléfonos de contacto y horarios de atención ingrese a nuestro sitio web en www.zoologic.com.ar "

				Do MostrarMensaje in Main.prg with chr(13) + lcMensaje, 48, "Configuración de servidor de datos" 
				
				this.crearGoLibrerias()
				goServicios.Librerias.TerminarProcesosRelacionados( goServicios.Librerias.ObtenerIdProcesoActual() )
			endif		
		endif
	endfunc 	

	*-----------------------------------------------------------------------------------------
	protected function BuscarActualizacionesSegunParametro() as Void
		local llEjecutaDesdeExe as Boolean
		llEjecutaDesdeExe = !_screen.zoo.esBuildAutomatico and ( this.ejecutoDesdeMain() or this.ejecutoDesdeExe() or this.EjecutoDesdeFormulario() )
		
		if llEjecutaDesdeExe and !_screen.Zoo.EsModoSystemStartUp() 
			if goParametros.Nucleo.Actualizaciones.BuscarActualizacionesAlIniciar
				this.InformarEstado( "Verificando actualizaciones" )
				goServicios.Librerias.BuscarActualizaciones( .T. )
			else
				goServicios.Librerias.RegistrarVersionActualEnZooLogic()
			endif
			goServicios.Librerias.NotificarActualizacionesQueEstenPendientesDePublicar(.f.)
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarReferencias() as Void
		this.AgregarReferencia( "ZooLogicSA.Core.dll" )
		this.AgregarReferencia( "ZooLogicSA.ManejadorArchivos.dll" )
		this.AgregarReferencia( "ZooLogicSA.Buscador.dll" )
		this.AgregarReferencia( "ZooLogicSA.Buscador.Negocio.dll" )		
		this.AgregarReferencia( "ZooLogicSA.EjecutadorDeScripts.dll" )
		this.AgregarReferencia( "Ionic.Zip.dll" )
		this.AgregarReferencia( "ZooLogicSA.ZED.dll" )
		this.AgregarReferencia( "ZooLogicSA.Core.Logueo.dll" )
		this.AgregarReferencia( "ZooLogicSA.Core.Configuraciones.dll" )
		this.AgregarReferencia( "ZooLogicSA.Core.Correcciones.dll" )
		this.AgregarReferencia( "ZooLogicSA.AccesoDatos.dll" )
		this.AgregarReferencia( "ZooLogicSA.AdnImplant.dll" )
		this.AgregarReferencia( "ZooLogicSA.AdnImplant.Sql.Lanzador.dll" )
		this.AgregarReferencia( "ZooLogicSA.AdnImplant.Core.dll" )
		this.AgregarReferencia( "ZooLogicSA.AdnImplant.InterfazVisual.dll" )
		this.AgregarReferencia( "ZooLogicSA.Core.ADN.dll" )
		this.AgregarReferencia( "XDMessaging.dll" )
		this.AgregarReferencia( "ZooLogicSA.Promociones.dll" )
		this.AgregarReferencia( "ZooLogicSA.Promociones.Asistente.dll" )
		this.AgregarReferencia( "ZooLogicSA.PrePantalla.UI.dll" )
		this.AgregarReferencia( "ZooLogicSA.CopiadorDeParametros.UI.dll" )
		this.AgregarReferencia( "ZooLogicSA.Interoperabilidad.dll" )
		this.AgregarReferencia( "ZooLogicSA.RemitoElectronicoArba.DLL" )
		this.AgregarReferencia( "ZooLogicSA.Core.BasesDeDatos.dll" )
		this.AgregarReferencia( "ZooLogicSA.AdnImplant.Sql.dll" )
		this.AgregarReferencia( "ZooLogicSA.Core.Configuraciones.dll" )
		this.AgregarReferencia( "ZooLogicSA.ImportadorDeFeriados.dll" )
		this.AgregarReferencia( "ZooLogicSA.CondicionDePago.UI.DLL" )
		this.AgregarReferencia( "ZooLogicSA.CondicionDePago.Componente.DLL" )
		this.AgregarReferencia( "ZooLogicSA.SaludDeBasesDeDatos.dll" )
		this.AgregarReferencia( "ZooLogicSA.Mail.dll" )
		this.AgregarReferencia( "Newtonsoft.json.dll" )
		this.AgregarReferencia( "Zoologicsa.Core.ServiciosWeb.dll" )
		this.AgregarReferencia( "ZooLogicSA.ReemplazadorSentencias.dll" )
		this.AgregarReferencia( "ZooLogicSA.Core.Formularios.dll" )
		this.AgregarReferencia( "Zoologicsa.Core.AdministracionServicios.dll" )
		this.AgregarReferencia( "ZooLogicSA.Core.DatosAplicacion.dll" )
		this.AgregarReferencia( "ZooLogicSA.Core.Common.dll" )
		this.AgregarReferencia( "ZooLogicSA.OrganicServiciosREST.dll" )
		this.AgregarReferencia( "ZooLogicSA.OrganicServiciosREST.Cliente.Configurador.dll")
		this.AgregarReferencia( "ZooLogicSA.PrePantallaDePrecios.UI.dll" )
		this.AgregarReferencia( "ZooLogicSA.ValidarCombinacionesRepetidas.dll" )
		this.AgregarReferencia( "ZooLogicSA.Ecommerce.dll" )
		this.AgregarReferencia( "ZoologicSA.ControlDeImpresoras.dll" )
		this.agregarreferencia( "ZooLogicSA.OrganicServiciosREST.Cliente.Core.dll")
		this.agregarreferencia( "ZooLogicSA.ColaboradorActiveDir.dll")
		this.agregarreferencia( "ZoologicSA.S3Amazon.dll")
		this.AgregarReferencia( "ZooLogicSA.Crypto.dll" )
		this.AgregarReferencia( "ZooLogicSA.Framework.Windows.dll" )
		this.AgregarReferencia( "ZooLogicSA.ConectorDeRedes.Factory.dll" )
		this.AgregarReferencia( "ZooLogicSA.ManagerWebHook.dll" )
	endfunc

	*-----------------------------------------------------------------------------------------
	function IniciarServiciosSinDependencia() as Void
		local lcNombreArchivo as string

		with This
			.IniciarServicio( "ManagerFormularios", "oFormularios", "goFormularios", ,"Formularios" )
			goFormularios.dDChk = date()
					
			.IniciarServicio( "ManagerMonitor", "oMonitor", "goMonitor", ,"Monitor" )
			.IniciarServicio( "ServicioDatos", "oDatos", "goDatos", ,"Datos" )
			goDatos.cTipoDeBase = this.TipoDeBase && Esto deberia ser temporal.
			
			.SetearDatosDelMotor()
				
			This.CrearGoLibrerias()
			
			public goMensajes
			this.oMensajes = goServicios.Mensajes
			goMensajes = this.oMensajes
			
			.IniciarServicio( "TimerBase", "oTimerBase", "goTimer", ,"Timers" )
			
			if .CargarParametrosYRegistros()
			else
				.BajarServiciosYSalirSiFallo()	
			endif
			.IniciarServicio( "ServicioControles", "oServicioControles", "goControles", ,"Controles" )
			
			this.IniciarServicioModulos() 
						
			goDatos.oManagerConexionASql.nTimeOut = val( goServicios.Librerias.ObtenerDatosDeINI( .aArchivosIni[2], "SQL", "TimeOut" ))
			goDatos.oManagerConexionASql.nreintentos = val( goServicios.Librerias.ObtenerDatosDeINI( .aArchivosIni[2], "SQL", "Reintentos" ))

			.IniciarManagerDeConfiguracionDeAgenteDeAccionesOrganic()
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function VerificarInicioDeServiciosRest() as Void
		local loFactory as Object, loConector as Object

		if  _screen.zoo.UsaCapaDePresentacion() or _screen.Zoo.EsModoSystemStartUp() 
			this.loguear("Verificación de inicio de servicios REST")
			try
				if this.UtilizarElAAO()
					this.loguear( "Conectando al servicio de AAO" )
					loFactory = _screen.zoo.Crearobjeto( "ZooLogicSA.ConectorDeRedes.Factory.FactoryConectorDeRedes" )
					loConector = loFactory.Obtener( "conectoragenteorganic" )
					this.loguear( "Enviando mensaje de verificación" )
					loConector.VerificarInicioAPIRest()
					this.loguear( "Mmensaje enviado." )
					loConector = null
					loFactory = null
				endif
			catch to loError
				this.loguear( "Falló la notificación de verificación de inicio de servicios REST a AAO." )
				loex = newobject(  "zooexception", "zooexception.prg" )
				with loex
					.message = "Falló la notificación de verificación de inicio de servicios REST a AAO"
					.details = .message
					.grabar( loError )
				endwith
			endtry
			this.FinalizarLogueo()
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function IniciarServicioModulos() as Void
		local lcModulo as String, lcNombreArchivo as String
		lcNombreArchivo =  "Modulos" + this.cProyecto
		lcModulo = "Modulos"

		if file(lcNombreArchivo + ".prg") or file(lcNombreArchivo + ".fxp")
			lcModulo = lcNombreArchivo 
		endif
		
		this.IniciarServicio( lcModulo, "oModulos", "goModulos", ,"Módulos" )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function CrearGoLibrerias()  as Void
		public goLibrerias
		this.oLibrerias = goServicios.Librerias
		goLibrerias = this.oLibrerias
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function IniciarServiciosConDependencia() as Void
		with this
			.IniciarServicio( "estilos", "oEstilos", "goEstilos", ,"Estilos" )
			bindevent( goparametros.dibujante, "Estilo", .oEstilos, "ActualizarEstilo", 1 )
		endwith 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function LevantarSeteosIni() as Void
		local lcNombreAplicacion as String

		if upper( right( sys(16), 3) ) == "FXP"
			lcNombreAplicacion = strtran( substr( addbs( _screen.zoo.cRutaInicial ), rat( "\", addbs( _screen.zoo.cRutaInicial ),2 ) + 1 ), "\", "" )
		else
			lcNombreAplicacion = juststem( sys( 16,0 ) )	
		endif 
		
		** Levantar datos del Aplicacion.ini
		this.LevantarSeteosAplicacionIni( This.aArchivosIni[1], lcNombreAplicacion )
		
		** Config.fpw
		this.ValidarConfig()
		** Levantar datos del Dataconfig.ini
		this.cRutaDataConfig = addbs( iif( empty( this.cRutaDataConfig ), _screen.zoo.cRutaInicial, this.cRutaDataConfig ) )
		this.aArchivosIni[2] = this.cRutaDataConfig + "DataConfig.ini"
		this.VerificarRutaDataConfig()
		this.LevantarSeteosDataConfigIni( this.aArchivosIni[2] )
		this.VerificarServidorDataconfig()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function LevantarSeteosAplicacionIni( tcArchivo as String, tcNombreAplicacion as String ) as Void
		local loCrear as crearAplicacionIni of crearAplicacionIni.prg
		
		loCrear = this.CrearObjeto( "CrearAplicacionIni", "CrearAplicacionIni.prg", justpath( tcArchivo ) )
		loCrear.ValidarExistencia( addbs( _screen.zoo.cRutaInicial ), tcNombreAplicacion, this.NombreProducto, this.Nombre )
		loCrear.release()
		this.LevantarDatosDeAplicacionIni( tcArchivo )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function LevantarSeteosDataConfigIni( tcArchivo as String ) as Void
		local loCrear as CreardataConfigIni of CreardataConfigIni.prg
		
		loCrear = this.CrearObjeto( "CreardataConfigIni", "CreardataConfigIni.prg", justpath( tcArchivo ) )		
		loCrear.ValidarExistencia( this.TipoDeBase, this.cNombreDelServidorSQL, this.cNombreDriverSQL, TIMEOUT, REINTENTOS )
		loCrear.release()
		
		this.LevantarDatosDeDataConfigIni( tcArchivo )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function LevantarDatosDeAplicacionIni( tcArchivo as string ) as Void
		local lcRetorno as String

		lcRetorno = goServicios.Librerias.ObtenerDatosDeINI( tcArchivo, "DATOS", "RutaDataConfig" )
		this.cRutaDataConfig = iif( !empty( lcRetorno ), alltrim( lcRetorno ), addbs( _screen.zoo.cRutaInicial ) )
		lcRetorno = goServicios.Librerias.ObtenerDatosDeINI( tcArchivo, "SETEOSAPLICACION", "VersionDelProducto" )
		this.cVersionSegunIni = alltrim( lcRetorno )
		lcRetorno = goServicios.Librerias.ObtenerDatosDeINI( tcArchivo, "SETEOSAPLICACION", "UtilizarWinExec" )
		this.cUtilizarWinExec = upper( alltrim( lcRetorno ) )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function LevantarDatosDeDataConfigIni( tcArchivo as String ) as Void
		local lcRetorno as String
		
		lcRetorno = upper( goServicios.Librerias.ObtenerDatosDeINI( tcArchivo, "DATOS", "TIPOBASE" ) )
		&& Se define en NATIVA ya que la etapa de generación de todos los productos instanacia servicios basicos con Acceso a datos NATIVA.
		&& Esto se hace ya que los servidores y base de datos se definen luego de la corrida del ADN Implant, y la etapa de generación esta acoplada a NATIVA 
		&& por falta de existencia de bases de datos SQL Server.
		this.TipoDeBase = iif( !empty( lcRetorno ), alltrim( lcRetorno ), "NATIVA" )
		
		this.cNombreDelServidorSQL = goServicios.Librerias.ObtenerDatosDeINI( tcArchivo, "SQL", "Servidor" )
		this.cNombreBaseDeDatosSQL = this.cBDMaster
		
		lcRetorno = goServicios.Librerias.ObtenerDatosDeINI( tcArchivo, "SQL", "Driver" )
		this.cNombreDriverSQL = iif( !empty( alltrim( lcRetorno ) ), alltrim( lcRetorno ), this.cNombreDriverSQL )

		lcRetorno = goServicios.Librerias.ObtenerDatosDeINI( tcArchivo, "NATIVA", "RUTAORGANIZACION" )
		this.cRutaTablasOrganizacion = iif( !empty( lcRetorno ), alltrim( lcRetorno ), _screen.zoo.cRutaInicial )

		lcRetorno = goServicios.Librerias.ObtenerDatosDeINI( tcArchivo, "NATIVA", "RUTAPUESTO" )
		this.cRutaTablasPuesto = iif( !empty( lcRetorno ), alltrim( lcRetorno ), _screen.zoo.cRutaInicial )
	endfunc

	*-----------------------------------------------------------------------------------------
	function VerificacionesGenerales() as Void

		with This
			.InformarEstado( "Verificando archivos ejecutables del sistema" )
			if .ValidarExistenciaEjecutables()
			else
				.BajarServiciosYSalirSiFallo()
			endif
			
			.InformarEstado( "Verificando fuentes tipográficas del sistema" )
			.ValidarExistenciaDeFuentes()
			
			.InformarEstado( "Verificando versión librerías de impresión" )

			if !.ValidarVersionLibreriasCrystal()
				if .ValidarActualizacionDeLibreriasCrystal()
					.ActualizarLibreriasCrystal()
				else
					goMensajes.enviar( "Necesita actualizar las librerías de impresión y listados (Crystal Report)")
				endif	
			endif
			
		endwith 
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetarUsoDeTimers() as Void
		if !_screen.zoo.esBuildAutomatico and ( this.ejecutoDesdeMain() or this.ejecutoDesdeExe() )
			this.lEstoyUsandoTimers = .t.
		else
			this.lEstoyUsandoTimers = .f.
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function IniciarRegistroTerminal() as Void
		this.lDebeInicializarElServicioRegistroTerminal = goregistry.Nucleo.UsarServicioRegistroTerminal
		if this.lEstoyUsandoTimers and this.lDebeInicializarElServicioRegistroTerminal
			this.InformarEstado( "Registrando terminal" )
			goServicios.Terminal.Registrar()
		endif
	endfunc
		
	*-----------------------------------------------------------------------------------------
	function ejecutoDesdeMain() as Boolean
		return This.ObtenerExtencionProcesoEnEjecucion( "FXP" )
	endfunc

	*-----------------------------------------------------------------------------------------
	function ejecutoDesdeExe() as Boolean
		return This.ObtenerExtencionProcesoEnEjecucion( "EXE" )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EjecutoDesdeFormulario() as Boolean
		return This.ObtenerExtencionProcesoEnEjecucion( "VCT" )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerExtencionProcesoEnEjecucion( tipoArchivo as string ) as Boolean
		return upper( right( sys(16, 0 ), 3 ) ) == upper( tipoArchivo )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function BorrarTabla( tcTabla as string ) as Boolean
		local loManejoArchivos as object, llRetorno as Boolean, loError as Exception,loEx as Exception
				
		llRetorno = .t.

		use in select( juststem( tcTabla ) )
		loManejoArchivos = _screen.zoo.crearobjeto( "manejoarchivos" )
		loManejoArchivos.SetearAtributos( "N", forceext( tcTabla, "dbf" ) )
		try
			delete file	( forceext( tcTabla, "dbf" )  )
		catch to loError
			loex = newobject(  "zooexception", "zooexception.prg" )
			with loex
				.message = "No se pudo borrar la tabla " + tctabla + "."
				.details = .message
				.grabar( loError )
				This.agregarinformacion( .message )
				llRetorno = .f.
			endwith
		finally
		endtry

		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ValidarAperturaAuditoria( tcRutaTabla as string, tcTabla as string  ) as Boolean
		local llRetorno as Boolean, lnArea as integer

		llRetorno = .t.
		lnArea = select()

		try
			use ( addbs( tcRutaTabla ) + alltrim( tcTabla ) ) in 0
		catch to loError
			llRetorno = .f.
			This.agregarinformacion( "No se pudo abrir la tabla " + alltrim( tcTabla ) + " en la ruta " + alltrim( lower ( tcRutaTabla ) ) )
			if this.BorrarTabla( addbs( tcRutaTabla ) + alltrim( tcTabla ) )
			else
				This.agregarinformacion( "Problemas al borrar la tabla" )
			endif
		finally
			use in select( juststem( tcTabla ) )
		endtry

		select ( lnArea )

		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function SeteoEsquemaSeguridad() as VOID
		with this
			if empty( alltrim( goRegistry.Nucleo.RutaRegistrosOrganizacion ) )
			else
				.cRutaParametrosOrganizacion = addbs( goRegistry.Nucleo.RutaRegistrosOrganizacion )
			endif
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarConsistenciaInternaTabla( tcTabla as string ) as Boolean
		local llRetorno as Boolean
		llRetorno = .t.

		try
			godatos.oAccesoDatos.abretabla( tcTabla )
		catch to loError 
			llRetorno = .f.
			This.agregarinformacion( "Está dañada la tabla: " + juststem( tcTabla ) + "." )
		endtry

		godatos.oAccesoDatos.cierratabla( juststem( tcTabla ) )

		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerRutaSucursal( tcSucursal ) as string
		local lcRetorno as string, lnInd as integer, llRetorno as Boolean

		llRetorno = .t.
		lcRetorno = ''
		if empty( this.aSucursales )
			llRetorno = this.CargarSucursales()
		endif

		if llRetorno
			lnInd = ascan( this.aSucursales, alltrim( upper( tcSucursal ) ), 1, 0, 1, 8 )
			if lnInd > 0
				lcRetorno = this.aSucursales[lnInd,3] + ':' + iif( left( alltrim( this.aSucursales[lnInd,2] ), 1 ) = "\", "", "\" ) + ;
					addbs( alltrim( this.aSucursales[lnInd,2] ) ) + addbs( alltrim( this.aSucursales[lnInd,1] ) )
			else
				goServicios.Errores.LevantarExcepcion( "No se encuentra la base de datos " + tcSucursal )
			endif
		endif
		
		return lcRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerRutaSegunTablaYSucursal( tcTabla as String, tcSucursal as String ) as Void
		local lcRuta as String, lcUbicacion as String
		
		lcUbicacion = goServicios.Estructura.ObtenerUbicacion( tcTabla )
		lcRuta = ""
		do case
			case lcUbicacion == "SUCURSAL"
				lcRuta = addbs( this.ObtenerRutaSucursal( tcSucursal ) ) + 'DBF\'
			case lcUbicacion == "PUESTO"
				lcRuta = addbs( this.cRutaTablasPuesto )
			case lcUbicacion == "ORGANIZACION"
				lcRuta = addbs( this.cRutaTablasOrganizacion )
			case lcUbicacion == "SEGURIDAD"
				lcRetorno = addbs( this.cRutaTablasSeguridad )
		endcase
		
		return lcRuta
	endfunc 
	
	*-----------------------------------------------------------------------------------------	
	function EjecutarReindexador( tcBaseDeDatos as string ) as Boolean
		return .t.
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerClaseLogin() as String
		return "KontrolerLogin"
	endfunc

	*-----------------------------------------------------------------------------------------
	function SetearAplicacion() as Void
		with this
			.oVersion = _screen.zoo.crearobjeto( "ZooLogicSA.Core.Aplicacion.VersionOrganic", "ZooLogicSA.Core.Aplicacion", transform( NUMEROMAJOR ), transform( NUMERORELEASE ), transform( NUMEROBUILD ) )
			.cNombreExe = NOMBREEXE
			.cEstadoDelSistema	=	""
		endwith
	endfunc

	*-----------------------------------------------------------------------------------
	function Login() as Boolean
		Local llRetorno as boolean, loRepositorDeBaseDeDatos as Custom

		if _screen.Zoo.EsModoSystemStartUp()
			goServicios.Seguridad.cUsuarioLogueado = goServicios.Seguridad.cUsuarioAdministrador
			goServicios.Seguridad.lEsAdministrador = .t.
			loRepositorDeBaseDeDatos = _screen.zoo.crearobjeto( "RepositorDeBaseDeDatos" )
			this.cSucursalActiva = loRepositorDeBaseDeDatos.ObtenerBaseDeDatos()
			release loRepositorDeBaseDeDatos
			llRetorno = .t.
		else
			llRetorno = goServicios.Seguridad.Login()
		endif
		if This.lDebeInicializarElServicioRegistroTerminal
			If llRetorno
				this.InformarEstado( "Reportando terminal" )
				this.ReportarRegistroTerminal()
			else
				this.InformarEstado( "Desregistrando terminal" )
				this.DesRegistrarRegistroTerminal()
			EndIf
		EndIf		
				
		if this.ejecutoDesdeExe()
			this.InformarEstado( "Verificando archivos solo lectura" )
		endif
		
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------
	Function InicializarBaseDeDatos()
		this.InformarEstado( "Seteando base de datos " + Alltrim( Upper( this.ObtenerSucursalActiva() ) ) )
		do case 
			case !empty( goServicios.Seguridad.cBaseDeDatosSeleccionada )
				this.cSucursalActiva = goServicios.Seguridad.cBaseDeDatosSeleccionada
			case !empty( _Screen.Zoo.App.cSucursalActiva )	
				this.cSucursalActiva = _Screen.Zoo.App.cSucursalActiva
			other
				this.cSucursalActiva = this.ObtenerSucursalDefault()
		endcase
		this.EjecutarMigradorDeParametros()
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerSucursalDefault() as Void
		return "Demo"
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CargarParametrosYRegistros() as Boolean
		local llRetorno as Boolean, llRetornoExistencia_Din as Boolean 
		llRetornoExistencia_Din = .t.
		llRetorno = .T.
		if _screen.zoo.lDesarrollo or !_vfp.startmode = 4 or _screen.zoo.EsBuildAutomatico
		else
			llRetornoExistencia_Din = this.ValidarExistencia_Din_Parametros_y_Din_Registros_y_Din_MenuPrincipal()
		endif
		if llRetornoExistencia_Din
			this.IniciarServicio( "din_parametros", "oParametros", "goParametros" )
			this.IniciarServicio( "din_registros", "oRegistry", "goRegistry" )
			
			goServicios.Parametros = goParametros
			goServicios.Registry = goRegistry
		
			this.SetearParametrosModoAvanzadoyEstilo()
		else
			llRetorno = .f.
			This.agregarinformacion( "Error de Integridad del Sistema ( Error Nº 1 )." )
		endif
		
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function CrearFormPrincipal() as Void
		with this
			if _screen.zoo.EsBuildAutomatico
			else
				.oFormPrincipal = .crearObjeto( this.cFormularioPrincipal )
				.IniciarMenuPrincipal()
				if !_screen.Zoo.EsModoSystemStartUp()
					.oFormPrincipal.show()
				endif
			endif
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function IniciarMenuPrincipal( tlReutilizarXmlMenuDelFormulario as Boolean) as Void
		local lcMensajeError as String , loFormulario as form,loMenuManager as Object, ;
			loMenuprincipal as Object, loError as exception, loEx as exception, lnAltoBarraMenu as integer

		public __ACBDEBUG__		&& esto es para el manejo de error
		__ACBDEBUG__ = .t.

		with this
			.oMenu = null
			if vartype( .oFormPrincipal ) = "O"
				loFormulario = .oFormPrincipal
			
				if type( "loFormulario.cbm" ) == "O" and not isnull( loFormulario.cbm )
				else
					loFormulario.newobject( "CBM", "CommandbarsManager", "argcommandbars.vcx" )
				endif 
	
				this.actualizarBarraDeEstado()
				
				loMenuprincipal = newobject( "MenuPrincipal", "MenuPrincipal.prg" ) 
				loMenuprincipal.AgregarMenu( loFormulario, tlReutilizarXmlMenuDelFormulario )
				this.AsignarClaveMenu()
				loFormulario.CBM.InitCommandBars()
				
				lcNameCBM = loFormulario.CBM.clientarea.name
				lcBindeo = 'loFormulario.CBM.' + lcNameCBM
				bindevent( &lcBindeo , "Resize", this, "ReubicarStatusBar" )
			endif
		
			.AperturaAutomaticaDeEntidades()
			
		endwith

	endfunc

	*-----------------------------------------------------------------------------------------
	function ActualizarBarraDeEstado() as Void
		local loFormulario as object, lnAltoBarraMenu as integer

		this.nColorBD = this.ObtenerColorBD()

		loFormulario = this.oFormprincipal
		lnAltoBarraMenu = loFormulario.CBM.height + 4
		loFormulario.SetearBarraDeEstadoPrincipal( lnAltoBarraMenu )
		loFormulario.oBarraEstado.SetearColor()
	endfunc

	*-----------------------------------------------------------------------------------------
	function MostrarFormularioPrincipal() as Void
		this.oFormPrincipal.show()
	endfunc

	*--------------------------------------------------------------------
	function CargarSucursales( tcBaseDeDatos as string ) as Boolean
		local llRetorno as Boolean, lcWhere as string, lcSql as String, loError as Object, lcAux as string
		local array laAux[1]
		
		llRetorno = .t.
		lcWhere = ""
		if !empty( tcBaseDeDatos )
			lcWhere = "  and upper( alltrim( empcod ) ) = '" + upper( alltrim( tcBaseDeDatos ) )+ "'"
			this.cSucursalActiva = upper( alltrim( tcBaseDeDatos ) )
		endif

		try
			goDatos.EjecutarSentencias( "select rtrim( empcod ) empcod, rtrim( epath ) epath, rtrim( eunid ) " + ;
				"eunid, rtrim( NC1 ) NC1, rtrim( usuario ) usuario, fchlog, rtrim( descrip ) descrip, color_bd, replica " + ;
				"from emp where empcod != '' and empcod is not null " + lcWhere, "emp.dbf", _screen.zoo.cRutaInicial, "c_emp", ;
				this.DataSessionId )
			select * from c_emp into array This.aSucursales

		catch to loError
			do MostrarMensaje in Main.prg with "Verifique la ruta o que se encuentre en el directorio de inicio." ,16, "Zoo Logic - Error en la tabla Emp" 

			llRetorno = .f.
		finally
			use in select( "c_emp" )		
		endtry

		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ChequearPametrosPorCambioDeSucursal() as Void
		local loChequeador as object, loError as Exception, loEx as zooexception OF zooexception.prg, lcClasechequeador as String

		try
			lcClasechequeador =  "ChequeoParametros" + this.cProyecto

			if !file(lcClasechequeador + ".prg") and !file(lcClasechequeador + ".fxp")
				lcClasechequeador = "ChequeoParametrosNucleo"
			endif

			loChequeador = _Screen.zoo.crearobjeto( lcClasechequeador  )
			loChequeador.Chequear()
		catch to loError
			loEx = Newobject( "ZooException", "ZooException.prg" )
			loEx.Grabar( loError )
			
			do MostrarMensaje in Main.prg with "Error al chequer los parámetros de sistema. "+ chr(13) + chr(10) + loEx.Message + " - " + loEx.Details  ,16, "Zoo Logic - Cheque de parámetros" 
		finally
			if vartype( loChequeador ) = "O"
				loChequeador.Destroy()
			endif
		endtry
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function destroy()
		this.oVersion = null
		dodefault()
		with this
			.oLibrerias = null
			.oParametros = null
			.oRegistry = null
			.oMenu = null
			.oServicioControles = null
			.oControladorFiscal = null
			.oTimerBase = null
			
			if type( "this.oMonitorQA" ) = "O" and !isnull( this.oMonitorQA )
				try
					.oMonitorQA.Dispose()
					.oMonitorQA = null
				catch
				endtry
			endif
			
			if type( "this.oMonitorDeIngresoYSalida" ) = "O" and !isnull( this.oMonitorDeIngresoYSalida)
				try
					.oMonitorDeIngresoYSalida.Dispose()
					.oMonitorDeIngresoYSalida = null
				catch
				endtry
			endif
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarExistencia_Din_Parametros_y_Din_Registros_y_Din_MenuPrincipal() as Boolean
		local llRetorno as Boolean, lcRuta as String

		llRetorno = .t.
		lcRuta = addbs( _screen.Zoo.cRutaInicial ) + "Generados\"
		if !file( lcRuta + "din_parametros.fxp" )
			llRetorno = .f.
			This.Agregarinformacion( "No se encuentra el archivo din_parametros.fxp" )
		endif

		if !file( lcRuta + "din_Registros.fxp" )
			llRetorno = .f.
			This.agregarinformacion( "No se encuentra el archivo din_registros.fxp" )
		endif

		if !file( lcRuta + "Din_MenuPrincipal.fxp" )
			llRetorno = .f.		
			This.agregarinformacion( "No se encuentra el archivo din_menuprincipal.fxp" )
		endif

		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function VerificarExistenciaDeEjecutables() as Boolean
		local lnCanEjecutables as integer, llRetorno as Boolean, lnInd as Integer

		llRetorno = .t.
		if empty( this.cListaDeEjecutables )
		else
			lnCanEjecutables = alines( laEjecutables, this.cListaDeEjecutables,4 , "," )

			for lnInd = 1 to alen( laEjecutables )
				if file( addbs( _screen.zoo.cRutaInicial )  + alltrim( laEjecutables[ lnInd ] ) )
				else
					llRetorno = .f.
					This.agregarinformacion( "No se encuentra el archivo " + alltrim( laEjecutables[ lnInd ] ) )
				endif
			endfor
		endif

		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarExistenciaEjecutables() as Boolean
		local llRetorno as Boolean

		llRetorno = .t.

		if _screen.zoo.lDesarrollo or !_vfp.startmode = 4 or _screen.zoo.esBuildAutomatico
		else
			llRetorno = this.VerificarExistenciaDeEjecutables()
		endif

		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function Procesar( tcIdSeguridad as String ) as Boolean
		local llAccesoAutorizado as Boolean
		llAccesoAutorizado = .t.

		if empty( tcIdSeguridad )
		else
			llAccesoAutorizado = goServicios.Seguridad.PedirAcceso( tcIdSeguridad )
		endif

		return llAccesoAutorizado
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerSucursalActiva() as string
		return this.cSucursalActiva
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EjecutarComandoMenu( tcComando as string, tcIdentificadorParaOpcionesDeMenuYToolbar as String, tcIdSeguridad as String ) as Void
		local loError as Exception, loEx as zooexception OF zooexception.prg, loControlErrores as object, loForm as form,;
				llRetorno as Boolean, loFormularioAsociadoAlComando as Object
				
		llRetorno = .t.
		try
			if empty( tcIdSeguridad )
			else
				This.LimpiarInformacion()
				llRetorno = goServicios.Seguridad.PedirAccesoMenu( tcIdSeguridad ) 
			endif			
			if llRetorno
				if vartype( tcIdentificadorParaOpcionesDeMenuYToolbar ) = "C"
					for each loForm in _screen.forms
						if pemstatus( loForm, "cIdentificadorParaOpcionesDeMenuYToolbar", 5 ) and loForm.cIdentificadorParaOpcionesDeMenuYToolbar $ alltrim( upper( tcIdentificadorParaOpcionesDeMenuYToolbar ) )
							loFormularioAsociadoAlComando = loForm
							tcComando = strtran( lower( tcComando ), "thisform", "loForm" )
							exit
						endif
					endfor
				endif

				if !( type("loFormularioAsociadoAlComando.oKontroler.lProcesar_Funcion_Ejecutar") == "L" and !loFormularioAsociadoAlComando.oKontroler.lProcesar_Funcion_Ejecutar )
					&tcComando
				endif
			
			else
				This.CargarInformacion( goServicios.Seguridad.ObtenerInformacion() )
				goServicios.Mensajes.Enviar( This.ObtenerInformacion(), 0, 2, , "Información del Sistema" )
				This.LimpiarInformacion()
			endif

		catch to loError
			loEx = newobject( "ZooException", "ZooException.prg" )
			with loEx
				.Grabar( loError )
			endwith
			loControlErrores = newobject( "ControlErrores", "controlErrores.prg" )
			if loControlErrores.EsErrorControlado( loEx )
				if loControlErrores.ControlarError( loEx )
				else
					loEx.throw()
				endif
			else
				goMensajes.Alertar( loEx )
				loEx.throw()
			endif
		endtry
	endfunc

	*-----------------------------------------------------------------------------------------
	function CopiarDBSucursales( tcSucursalOrigen as String, tcRutaOrigen as String, tcSucursalDestino as String, tcRutaDestino as String ) as Void
		return .f. &&& SQL
	endfunc 

	*-----------------------------------------------------------------------------------------
	function PuedoEliminarBaseDeDatos( tcBaseDeDatos ) as boolean
		local llRetorno as Boolean, lcCursor as String

		llRetorno = .t.
		
		if upper( rtrim( this.cSucursalActiva ) ) == upper( rtrim( tcBaseDeDatos ) )
			This.AgregarInformacion( "No se puede anular la base de datos en la cual se esta trabajando en estos momentos, cambie de base de datos y reintente." )
			llRetorno = .f.
		endif

		if llRetorno
			lcCursor = sys( 2015 )
			goDatos.EjecutarSentencias( "select empcod from emp where ltrim( rtrim( upper( empcod ) ) ) = '" ;
				+ upper( rtrim( tcBaseDeDatos ) ) + "'", "emp.dbf", addbs( _screen.zoo.cRutaInicial ) ;
				, lcCursor, this.DataSessionId )

			if reccount( lcCursor ) = 0
				This.AgregarInformacion( "No se encontró la base de datos." )
				llRetorno = .f.
			endif

			use in select( lcCursor )
		endif
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ReubicarStatusBar()
		with _screen.Zoo.app.oFormPrincipal

			if .oMenu.dockposition = 0
				.oBarraEstado.top = .height - .oBarraEstado.height
			else
				.oBarraEstado.top = .height - .CBM.height - 4
			endif
			.resize()
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerColorBD() as integer
		local lnColor as integer , lnFila as integer, loError as zooexception OF zooexception.prg
		lnColor = 0
		try
			lnFila = asubscript( this.aSucursales,ascan( this.aSucursales, this.cSucursalActiva, 1, 0, 1, 1 ),1 )
			if lnFila > 0
				lnColor = this.aSucursales[ lnFila, 8 ]
			endif
		catch to loError
			lnColor = 0
		endtry
		return lnColor
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerValorReplicaBD() as Boolean
		local llReplica as Boolean, lnFila as integer

		llReplica = .f.
		try
			lnFila = asubscript( this.aSucursales, ascan( this.aSucursales, this.cSucursalActiva, 1, 0, 1, 1 ), 1 )
			if lnFila > 0
				llReplica = this.aSucursales[ lnFila, 9 ]
				llReplica = iif( vartype( llReplica ) <> "L", .f., llReplica )
			endif
		catch
			llReplica = .f.
		endtry
		
		return llReplica
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function PermiteABM( tcTabla as String ) as Boolean
		local llPermite as Boolean

		if pcount() = 1 and !empty( tcTabla )
			if this.EsUnaTablaQuePermiteABMEnReplica( tcTabla )
				llPermite = .T.
			else
				&& refactoring...
				llPermite = iif( this.EsTablaDeSucursal( tcTabla ), !this.ObtenerValorReplicaBD(), .T. )
			endif
		else
			llPermite = !this.ObtenerValorReplicaBD()
		endif
		
		return llPermite
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsTablaDeSucursal( tcTabla as String ) as Boolean
		local lcUbicacion as string
		
		lcUbicacion = goServicios.Estructura.ObtenerUbicacion( tcTabla )
		return ( upper( alltrim ( lcUbicacion ) ) == "SUCURSAL" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function BajarServiciosYSalirSiFallo( tcMensaje as string, tlNoEspera as Boolean ) as Void
		if empty( tcMensaje ) or vartype( tcMensaje )!= 'C'
		else
			This.AgregarInformacion( tcMensaje )
		endif
		This.AgregarInformacion( "Fallo en el sistema, se cerrará la aplicación. Reinicie, en caso de persistir el problema comuníquese con Mesa de Ayuda." )
		if tlNoEspera 
			goMensajes.EnviarSinEspera( tcMensaje )
			inkey( 20 )
			goMensajes.EnviarSinEspera()
		else
			goMensajes.Enviar( This.ObtenerInformacion() )
		endif
		This.Salir()
	endfunc

	*-----------------------------------------------------------------------------------------
	function Salir( tlSalidaForzada as Boolean ) as Void

		_screen.Zoo.App.oSalida.SalidaDelSistema( tlSalidaForzada )

		if EsIyD()
			on shutdown
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function VerificarExistenciaBase( tcSucursal as string ) as Boolean
		local	lcTabla as string, lcSql as string, lcXML as string, ;
				lnReccount as integer, llRetorno as Boolean, lcSucursal as String
		llRetorno = .t.
		goDatos.EjecutarSentencias( "select * from emp where upper( rtrim( ltrim( empcod ) ) ) = '" ;
			+ upper( alltrim( tcSucursal ) ) + "'", "emp.dbf", addbs( rtrim( _screen.Zoo.cRutaInicial ) ) ;
			, "c_ValidEmp", this.DataSessionId )
		lnReccount = reccount()
		do case
			case lnReccount = 0
				llRetorno = .f.
				This.agregarinformacion( "La base de datos: '" + tcSucursal + "' no existe." )
			case lnReccount > 1
				goMensajes.Enviar( "Existe más de una base de datos con el mismo nombre." )
			otherwise
				do case 
					case alltrim( upper( This.TipoDeBase ) ) = "SQLSERVER"
						lcSucursal = goServicios.Librerias.ObtenerNombreSucursal( tcSucursal )
					case alltrim( upper( This.TipoDeBase ) ) = "NATIVA"
						lcSucursal = lower( alltrim( c_ValidEmp.eUnid  ))+ ':' + proper( addbs( alltrim( c_ValidEmp.ePath ))) + proper( addbs( alltrim( tcSucursal )))						
				endcase
				llRetorno = goServicios.Librerias.ExisteBaseDeDatos( lcSucursal )
				if !llRetorno
					This.agregarinformacion( "La base de datos: '" + lcSucursal + "' no existe." )
				endif
		endcase
		use in select( "c_ValidEmp" )
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerNombre() as string
		return this.Nombre
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerNombreProyecto() as string
		return this.cProyecto
	endfunc

	*-----------------------------------------------------------------------------------------
	function VerificarExistenciaConfig() as Boolean
		local llRetorno as Boolean
		&& Validar Config.fpw
		llRetorno = file( addbs( _screen.zoo.cRutaInicial ) + "config.fpw" )
		
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarConfig() as Void
		&& Validar Config.fpw
		if this.VerificarExistenciaConfig()
		else
			this.CrearConfig()
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function CrearConfig() as Void
		strtofile( "Screen = OFF" , addbs( _screen.zoo.cRutaInicial ) + "config.fpw" )
	endfunc

	*-----------------------------------------------------------------------------------------
	function SePuedeIngresar() as Boolean
		local lcSQL as string, lcXML as string, llRetorno as Boolean

		llRetorno = .t.

		lcSQL = "select goServicios.Librerias.DesEncriptar192( alltrim( XX2 ) ) as Accion " + ;
			" from AccionesAplicaciones " + ;
			" where upper( goServicios.Librerias.DesEncriptar192( alltrim( XX1 ) ) ) = '" + ;
			alltrim( upper( this.Nombre ) ) + "'"
			
		goDatos.EjecutarSentencias( lcSql, "AccionesAplicaciones.dbf", addbs( this.cRutaTablasOrganizacion ), "c_AccionesAplicaciones", this.DataSessionId )
		
		if reccount( "c_AccionesAplicaciones" ) > 0 and alltrim( upper( c_AccionesAplicaciones.Accion ) ) == "INGRESODENEGADO"
			This.Agregarinformacion( "Acceso denegado." )
			llRetorno = .f.
		endif
		
		use in select( "c_AccionesAplicaciones" )

		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function VerificarExistenciaDLL() as VOID
		local loVerificador as VerificadorDll of VerificadorDll.prg
		
		this.InformarEstado( "Verificando librerias del sistema" )
		loVerificador = _screen.zoo.crearobjeto( "VerificadorDll" )
		loVerificador.InyectarInformacion( this )
		if !loVerificador.Verificar()
			this.BajarServiciosYSalirSiFallo( "Faltan archivos requeridos por el sistema." )
		endif
		loVerificador.Release()
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarExistenciaDeFuentes() as Void
		local llTahoma as Boolean, llDINMittelschriftStd as Boolean, lcMensaje as string, lcMensaje1 as string,;
			  lcMensaje2 as string, lcMensaje3 as string
		local array laFuentes [1]
		
		lcMensaje  = space( 0 )
		lcMensaje1 = Space( 0 )
		lcMensaje2 = Space( 0 )		
		lcMensaje3 = 'Es posible que no pueda visualizar correctamente las pantallas.'		

		llTahoma = AFONT( "laFuentes", "Tahoma", 8 )
		llDINMittelschriftStd = AFONT( "laFuentes", "DIN Mittelschrift Std", 24 )

		if llTahoma 
		else
			lcMensaje1 = 'Tahoma'
		endif
		
		if llDINMittelschriftStd
		else
			lcMensaje2 = 'DIN Mittelschrift Std'
		endif
		
		if empty( lcMensaje1 )
			lcMensaje = 'El sistema no tiene instalada la fuente '			
		else
			lcMensaje = 'El sistema no tiene instalada la fuente ' + lcMensaje1 			
		EndIf	
		
		if empty( lcMensaje2 ) 
		else
			if empty( lcMensaje1 )
				lcMensaje = lcMensaje + lcMensaje2
			else
				lcMensaje = lcMensaje + ' ni la fuente ' + lcMensaje2
			Endif		
		endif	
		
		if empty( lcMensaje )
		else
			lcMensaje = lcMensaje + '. '+ lcMensaje3
		endif
						
		if ( llTahoma and llDINMittelschriftStd )
		else
			gomensajes.enviar( lcMensaje )
		endif	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearEstadoMenuPrincipal( tlHabilitado as Boolean ) as Void
		local lnCantidad as Integer, lnIndice as Integer,  lcEjecutar as String
		local array laMiembros[1]
		
		if type( "this.oFormPrincipal" ) = "O" and !isnull( this.oFormPrincipal )
			lnCantidad = amembers( laMiembros, this.oFormPrincipal.oMenu,3 )
			for lnIndice = 1 to lnCantidad
				if inlist( upper( alltrim( left( laMiembros[ lnIndice, 1 ], 3 ) )), "ME_", "IT_" )
					lcEjecutar = "this.oFormPrincipal.oMenu."+ laMiembros[ lnIndice, 1 ] + ".Enabled = tlHabilitado"
					&lcEjecutar.
				endif
			endfor

			this.oFormPrincipal.refresh()		
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarVersionDemo() as Boolean
		local loValidador as ValidadorDemo of Validadodemo.Prg, llOk as Boolean, lcNombreArchivo as string, llValidar as Boolean

		if empty( This.tUltimoControl ) or ( datetime() - This.tUltimoControl > 7200 )
			This.tUltimoControl = datetime()
			llValidar = .T.
		else
			llValidar = .F.
		Endif
		if llValidar
			lcNombreArchivo =  "ValidadorDemo" + this.cProyecto
			if file(lcNombreArchivo + ".prg") or file(lcNombreArchivo + ".fxp")
				loValidador = _screen.zoo.crearobjeto( "ValidadorDemo" + this.cProyecto )
			else
				loValidador = _screen.zoo.crearobjeto( "ValidadorDemo" )
			endif
			
			llOk = loValidador.Validar()
			if llOk
			else
				llOk = goFormularios.MostrarScx( "MensajeDemo", .t. )
				llOk = llOk and !this.lSaliendo
				if llOk
				else
					This.tUltimoControl = 0
				EndIf	
			endif
		else
			llOk = .T.
		EndIf
		return llOk
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerVersion() as String
		This.ObtenerVersionPKW()
		return this.oVersion.Version
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerBuild() as string
		return this.oVersion.BuildString
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerMajor() as string
		return this.oVersion.MajorString
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerRelease() as string
		return this.oVersion.ReleaseString
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerVersionPKW() as Void
		local lcVersion as String, lcRelease as String  

		lcVersion = alltrim( str( this.oVersion.Major ) ) + '.'
		lcRelease = alltrim( str( this.oVersion.Release ) )
		lcRelease = iif( len( lcRelease )< 2, '0' + lcRelease, iif( len( lcRelease ) > 2, right( lcRelease, 2 ), lcRelease ) )

		This.cVersionPKW = alltrim( lcVersion + lcRelease )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function SetearAyuda() as Void
		if  _screen.zoo.UsaCapaDePresentacion()
			if file( _screen.zoo.crutainicial + "ayuda\index.html" )
				declare integer ShellExecute in "shell32.dll" integer hwnd, string lpszOp, ;
					string lpszFile, string lpszParams, string lpszDir, integer FsShowCmd
				
				on key label F1 Shellexecute( 0,"Open",_screen.zoo.crutainicial + "ayuda\index.html",null,null,1 )
				this.cArchivoDeAyuda = _screen.zoo.crutainicial + "ayuda\index.html"
			else
				on key label F1 gomensajes.informar( "Ayuda no disponible" )
			endif
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EjecutarAyuda() as Void
		
		if empty( this.cArchivoDeAyuda )
			goMensajes.Informar( "Ayuda no disponible" )
		else
			local lcArchivoDeAyuda as String
			lcArchivoDeAyuda = this.cArchivoDeAyuda

			declare integer ShellExecute in "shell32.dll" integer hwnd, string lpszOp, ;
				string lpszFile, string lpszParams, string lpszDir, integer FsShowCmd
			
			=Shellexecute( 0,"Open",lcArchivoDeAyuda,null,null,1 )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function InicializarTimerAlarmaChecklineHost() as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function DetenerTimerAlarmaChecklineHost() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ChequeoAlarmaChecklineHost( tdFecha as Datetime ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SacarAtributosSoloLectura( tcRuta as string ) as Void
		&& Antes del 08/2016 se llamaba a código comentado ManejoArchivo.SetearAtributosConFiltroDeCarpeta.
		&& Pero al encontrarse que tenia un bug y en verdad nunca funciono, se decidio arreglar el metodo de la clase manejoArchivos.
		&& y dejar comentada la llamada, ya que incrementaba 1/2 segundo el ingreso al sistema para paliar una hipotesis de conflicto que en realidad nunca sucedio.
		* ---- COMENTADO ----
		* loManejoAchivo = newobject( "ManejoArchivos","ManejoArchivos.prg" )
		* loManejoAchivo.SetearAtributosConFiltroDeCarpeta( "N", addbs( tcRuta ) + "*", "", "\Ayuda" )
		* ---- COMENTADO ----
	endfunc 

	*-----------------------------------------------------------------------------------------
	function IniciarServicio( tcClase as String, tcObjetoApp as String, tcObjetoGlobal as string, txPar1 as variant, tcDescripcion as String ) as Void
	
		if !empty( tcDescripcion )
			this.InformarEstado( "Inicializando servicios (" + alltrim( tcDescripcion ) + ")" )
		endif
		
		if empty( tcObjetoGlobal )
			tcObjetoGlobal = "g" + tcObjetoApp 
		endif
		
		public &tcObjetoGlobal
		
		with this
			if type( "." + tcObjetoApp ) = "O" and !isnull( .&tcObjetoApp )
			else
				if empty( txPar1 ) and vartype( txPar1 ) == "L"
					.&tcObjetoApp = _screen.zoo.crearObjetoPorProducto( tcClase )
				else
					.&tcObjetoApp = _screen.zoo.crearObjetoPorProducto( tcClase, tcClase + ".prg", txPar1 )
				endif
			endif
			
			&tcObjetoGlobal = .&tcObjetoApp
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function BajarServicio( tcObjetoApp as String, tcObjetoGlobal as string ) as Void

		if empty( tcObjetoGlobal )
			tcObjetoGlobal = "g" + tcObjetoApp 
		endif

		public &tcObjetoGlobal 
				
		with this
			&tcObjetoGlobal = null
			
			if type( "." + tcObjetoApp ) = "O"
				if pemstatus( .&tcObjetoApp, "release", 5 )
					.&tcObjetoApp..release()
				endif
			endif
				
			.&tcObjetoApp = null
			
			release &tcObjetoGlobal
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function BajarServiciosParaReindexar() as Void  &&este metodo vuela cuando pertenescan a una collecion que administre los Servicios 15-12-08 (Malu)
		if goServicios.oColServiciosActivos.GetKey( "Memoria" ) > 0
			goServicios.Memoria.Detener()
		endif
		
		if goServicios.oColServiciosActivos.GetKey( "Impresion" ) > 0
			goServicios.Impresion.Detener()
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ReiniciarServicios( tlSaltar as Boolean ) as Void

		if vartype( this.oLibrerias.Logueos ) = "O"
			this.oLibrerias.Logueos.Reconfigurar()
		endif

		if goServicios.oColServiciosActivos.GetKey( "MEMORIA" ) > 0
			goServicios.Memoria.Detener()
		endif
	endfunc 		
	*-----------------------------------------------------------------------------------------
	function InformarEstado( tcTexto as string, tlEspera as Boolean ) as void
		*!*	Evento para binding al inicio de la aplicación.
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function CambiarS( tnCantidadPantallas as Integer, tlNoMostrarAdvertencia as Boolean ) as Boolean
		local loObjeto as Object, llPidioCodigo as Boolean
		
		llPidioCodigo = .F.
		
		if empty( tnCantidadPantallas )
			tnCantidadPantallas = 2 
		endif
		
		llHayPantallasAbiertas = this.VerificarPantallasAbiertas( tnCantidadPantallas )
		
		if llHayPantallasAbiertas  
			goMensajes.Advertir( "No se puede realizar el cambio de serie. Debe cerrar las pantallas abiertas." )
		else
			with goFormularios
				if _screen.zoo.app.cSerie = "DEMO"
					llPidioCodigo = goServicios.Librerias.Verificar()
				else
					if tlNoMostrarAdvertencia
						llRespuestaAdvertencia = 1
					else
						llRespuestaAdvertencia = gomensajes.informar( This.ObtenerDescripcionAdvertenciaCambioDeSerie(), 1, 1 )
					endif									

					if llRespuestaAdvertencia = 1 and .PDBRMSE( "L" ) > 0 
						.Escribir( 1, "" )
						.Escribir( 3, "" )
						llPidioCodigo = goServicios.Librerias.Verificar()
						this.ReasignarGuidDeSerie()
						this.ReasignarSerieEnSesion()
						this.ReportarRegistroTerminal()
					endif
				endif
				
			endwith
			if vartype( _screen.zoo.app.oFormPrincipal ) = "O"
				_screen.zoo.app.oFormPrincipal.oBarraEstado.RefrescarGrupos()
			endif

		endif	
		
		return llPidioCodigo
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoMensajeAdvertencia( tcMensaje as String ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerDescripcionAdvertenciaCambioDeSerie() as String
		local lcRetorno as String
		lcRetorno = "El número de serie identifica su licencia para utilizar este producto, " + ;
					"presione Aceptar si desea cambiarlo." + chr( 13 ) + chr( 10 ) + chr( 13 ) + chr( 10 ) + ;
					"Importante: necesitará comunicarse con Atención al Cliente para realizar esta operacón." + chr( 13 ) + chr( 10 ) + ;
					"Por consultas de teléfonos de contacto y horarios de atención ingrese a nuestro sitio web en www.zoologic.com.ar"
					
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function VerificarPantallasAbiertas( tnCantidadPantallas as Integer ) as boolean
		local lnCount as Integer, lnCantidadFormsVisibles as Integer

		lnCantidadFormsVisibles = 0 

		for lnCount = 1 to _screen.FormCount
			if _screen.Forms[ lnCount ].visible
				lnCantidadFormsVisibles = lnCantidadFormsVisibles + 1
			endif
		endfor

		return lnCantidadFormsVisibles > tnCantidadPantallas
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ReasignarGuidDeSerie() as Void
		&& No Borrar se consume en una subclase (linceOrganic)
	endfunc 		

	*-----------------------------------------------------------------------------------------
	function ObtenerPrefijoDB() as String 
		local lcPrefijoDB as String 
		lcPrefijoDB = "" 
		if this.lUtilizaPrefijoDB or this.lEsEntornoCloud
			lcPrefijoDB = alltrim( upper( this.nombreproducto ) ) + "_"
		endif
		return lcPrefijoDB 
	endfunc		

	*-----------------------------------------------------------------------------------------
	function LlamaAcercaDe() as Void
		This.nHandleTimerAcercaDe = goservicios.timer.crearnuevotimer( 1000, "_screen.zoo.app", "EfectuarSalidaDelSistema" )
		_Screen.zoo.App.lSalioDeAcercaDe = .F.
		goFormularios.MostrarScxSingleton( "AcercaDe" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EfectuarSalidaDelSistema() as Void
		if _Screen.zoo.App.lSalioDeAcercaDe
			goservicios.timer.mataruntimerespecifico( This.nHandleTimerAcercaDe )		
		endif
		
		if _Screen.Zoo.App.lForzarSalida
			_screen.Zoo.app.Salir( .T. )
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerMesAnioDeCompilacionDeLaVersionActual() as String
		return MESDELBUILD + ' ' + ANIODELBUILD
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ProcesoDeDatosFixParametros() as Void
		with this
			.oFixParametros = _Screen.zoo.CrearObjetoPorProducto( "FixParametros" )
			.oFixParametros.Procesar()
			.oFixParametros = null
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function PuedoAccederAParametrosYRegistros() as Boolean
        local loPermisos as Object, loFactoryNet as Object, loGestorPermisos as Object, lcConnectionString as String

		loFactoryNet = _screen.Zoo.CrearObjeto( "ZooLogicSA.AdnImplant.Sql.Lanzador.FactoryOrganic" )  		
		lcConnectionString = loFactoryNet.ObtenerConnectionString( _screen.zoo.cRutaInicial, goServicios.Librerias.ObtenerNombreSucursal( this.cBDMaster ) ) 

		loGestorPermisos = loFactoryNet.ObtenerGestorDePermisos()			
		
		loPermisos = loGestorPermisos.ObtenerPermisosDB( lcConnectionString )
		return loPermisos.ConectarBaseDeDatos		

	endfunc 

	*-----------------------------------------------------------------------------------------
	function oManagerDeConfiguracionDeAgenteDeAccionesOrganic_Access() as variant
		if !this.lDestroy and ( !vartype( this.oManagerDeConfiguracionDeAgenteDeAccionesOrganic ) = 'O' or isnull( this.oManagerDeConfiguracionDeAgenteDeAccionesOrganic ) )
			this.oManagerDeConfiguracionDeAgenteDeAccionesOrganic = _screen.zoo.crearobjeto( "ConfigurarAgenteDeAccionesOrganic", "ConfigurarAgenteDeAccionesOrganic.prg" )
		endif
		return this.oManagerDeConfiguracionDeAgenteDeAccionesOrganic 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function IniciarManagerDeConfiguracionDeAgenteDeAccionesOrganic() as Void
		
		if !goServicios.Ejecucion.TieneScriptCargado() and this.UtilizarElAAO()
			this.InformarEstado( "Verificando Agente de Acciones Organic" )
			this.oManagerDeConfiguracionDeAgenteDeAccionesOrganic.ConfigurarAgentePorActualizacion()
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ConfigurarAgente() as Void
		try
			if ( this.UtilizarElAAO() )
				this.oManagerDeConfiguracionDeAgenteDeAccionesOrganic.ConfigurarAgente()
			endif
		catch 
			goServicios.Errores.LevantarExcepcion( "Error al intentar configurar el Agente de Acciones Organic" )
		endtry			
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearTituloDeLaAplicacion() as Void
		if !_screen.zoo.esBuildAutomatico and ( this.ejecutoDesdeMain() or this.ejecutoDesdeExe() or this.EjecutoDesdeFormulario() )
			_screen.Caption = alltrim( this.Nombre )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearIconoDeLaAplicacion() as Void
		if !_screen.zoo.esBuildAutomatico and ( this.ejecutoDesdeMain() or this.ejecutoDesdeExe() or this.EjecutoDesdeFormulario() )
			_screen.Icon = this.ObtenerIconoDeLaAplicacion()
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerIconoDeLaAplicacion() as String
				local lcIcono as String
		lcIcono = "Icono" + alltrim( this.cProyecto ) + ".ico"
		if !file( lcIcono )
			if vartype( goRegistry ) == "O" and  vartype( goRegistry.Dibujante ) == "O"
				lcIcono = alltrim( goRegistry.Dibujante.IconoDefaultDeLosFormularios )
			else
				lcIcono = "zoo" + "logic" + "." + "ico" &&ZooLogic.Ico
				if !file( lcIcono )
					lcIcono = ""
				endif
			endif
		endif
		return lcIcono
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function InformarProblemaEnLaBaseDeDatos() as Void
		local lcMensaje as String
		
		lcMensaje = "No se pudo establecer la conexión con la base de datos: " + alltrim( this.cBDMaster ) + chr(13) +;
						"Por favor verifique la conexión de red y los permisos de acceso a la base de datos SQL." + chr(13)
		Do MostrarMensaje in Main.prg with lcMensaje, 16, "Error" 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearComplejidadEnConsultas() as Void
		local lnComplejidadEnConsultas as Integer, loError as Exception
		try
			lnComplejidadEnConsultas = val( goServicios.Librerias.ObtenerDatosDeINI( this.aArchivosIni[1], "SETEOSAPLICACION", "ComplejidadEnConsultas" ))
			if lnComplejidadEnConsultas >= 320 and lnComplejidadEnConsultas <= 2040
				Sys( 3055, lnComplejidadEnConsultas )
			endif
		catch to loError
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ResetearSerieApp( tcSerie as string, tcClave as string, tcSitio as string ) as Void
		if this.lSeccion9
			goServicios.Librerias.Verificar( tcSerie, tcClave, tcSitio )
		else
			this.cSerie = goFormularios.Leer( 1 )
		endif
		this.ActualizarSerieEnAplicacionIni()
		this.CrearSerieEnUsuarioSystemSiNoExiste()
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function CrearSerieEnUsuarioSystemSiNoExiste() as Void
		local lcNombrePerfilLocalSystem as String

		lcNombrePerfilLocalSystem = goFormularios.ArmarNombrePerfilSegunEntorno( goLibrerias.ObtenerNombreEquipo() + "$" )

		if ( lcNombrePerfilLocalSystem != goFormularios.cNombrePerfil )
			if !goFormularios.EstaInstalado( lcNombrePerfilLocalSystem )
				goFormularios.CopiarInstalacion( goFormularios.cNombrePerfil, lcNombrePerfilLocalSystem )
			else
				if this.cSerie != "DEMO" and !goFormularios.EsModoDemo( lcNombrePerfilLocalSystem )
					goFormularios.CopiarInstalacion( goFormularios.cNombrePerfil, lcNombrePerfilLocalSystem )
				endif
			endif
		endif

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ActualizarSerieEnAplicacionIni() as Void
		goServicios.Librerias.EscribirDatosDeIni( this.aArchivosIni[ 1 ], "SETEOSAPLICACION", "Serie", this.cSerie )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function SetearBasesDeDatos( tlTieneScriptCargado as Boolean ) as Void
		if !tlTieneScriptCargado
			if !this.lSinSucursalActiva
				this.InicializarBaseDeDatos()
				this.InformarEstado( "Inicializando bases de datos" )	
			endif				
		endif
		this.SeteoEsquemaSeguridad()
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearBufferDeMemoria() as Void
		try
			Sys( 3050, 1, VAL( SYS ( 3050, 1, 0 ) ) / 3 )
			Sys( 3050, 2, VAL( SYS ( 3050, 1, 0 ) ) / 3 )
		catch
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearPropiedadesBasicas() as Void
		with this	
			dimension .aArchivosIni[2]
			.aArchivosIni[1] = addbs( _screen.zoo.cRutaInicial ) + "Aplicacion.INI"
			.aArchivosIni[2] = addbs( _screen.zoo.cRutaInicial ) + "DataConfig.INI"
			.cRutaParametrosOrganizacion = _screen.zoo.cRutaInicial
			.cRutaTablasPuesto = _screen.zoo.cRutaInicial
			.cRutaTablasOrganizacion = _screen.zoo.cRutaInicial
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function VerificarAccesoAParametrosYRegistros( tlTieneScriptCargado as Boolean ) as Void
		local llRetorno as Boolean
		llRetorno = .t.
		if !tlTieneScriptCargado
			if !this.PuedoAccederAParametrosYRegistros()		
				llRetorno = .f.
				this.InformarProblemaEnLaBaseDeDatos()
			endif
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ActualizarEntornoPorCambioDeVersion( tlTieneScriptCargado as Boolean ) as Void
		local loGestor as GestionDeEntornoPorCambioDeVersion of GestionDeEntornoPorCambioDeVersion.prg
		
		
		if !_screen.zoo.esBuildAutomatico and !tlTieneScriptCargado
			lcVersionActual = alltrim( this.ObtenerVersion() )
			if ( this.cVersionSegunIni != lcVersionActual )
				loGestor = _screen.zoo.CrearObjeto( "GestionDeEntornoPorCambioDeVersion" )
				loGestor.EjecutarControlDeEntorno()
				loGestor = null
				goServicios.Librerias.EscribirDatosDeIni( this.aArchivosIni[1], "SETEOSAPLICACION", "VersionDelProducto", lcVersionActual )
				this.cVersionSegunIni = lcVersionActual
			endif
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function DespuesDelLogin() as Void
		&& Logica que debe suceder despues de se ejecuto el logueo del usuario. solo se va a pasar por aca si el logue es exitoso.
		&& Vea ServicioAplicaciones
		lcConsulta = "_Screen.Zoo.App.EjecutarConsulta()"
		on key label F12 &lcConsulta
		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EjecutarConsulta() as String
		local loObtenedorConsulta as Object, lcEjecutar as String
		loObtenedorConsulta = newobject( "ObtenedorConsulta", "ObtenedorConsulta.prg" )
		lcEjecutar = loObtenedorConsulta.ObtenerConsulta()
		loObtenedorConsulta = NULL
		&lcEjecutar
	endfunc 

	*-----------------------------------------------------------------------------------------
	function VerificacionDeParametrosRZ() as Void
		&& Reescrito en Felino		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function PermiteModificarOEliminarEnBase( tcSentencia as String, tcTablas as string ) as Boolean
		local llRetorno as Boolean, lcTabla as String, llPermiteAbm as Boolean, lnTablas as Integer, lnInd as Integer

		llRetorno = .t.
		llPermiteAbm = .F.
		if pcount() < 2
			lcTabla = ""
		else
			if occurs( "," , tcTablas ) > 0
				lcTabla = alltrim( substr( tcTablas, 1, at( ",", tcTablas ) - 1 ) )
				lnTablas = alines( laTablas, tcTablas, 1 + 4, "," )
				llPermiteAbm = .T.
				for lnInd = 1 to lnTablas
					llPermiteAbm = this.EsUnaTablaQuePermiteABMEnReplica( juststem( laTablas[ lnInd ] ) ) and llPermiteAbm
				endfor
			else
				lcTabla = alltrim( tcTablas )
				llPermiteAbm = this.EsUnaTablaQuePermiteABMEnReplica( lcTabla )
			endif
		endif
		
		if !llPermiteAbm and this.ObtenerValorReplicaBD() and iif( empty( lcTabla ), .T., this.EsTablaDeSucursal( lcTabla ) )
			llRetorno = !this.EsSentenciaDeUpdateOInsertODelete( tcSentencia )
		endif
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsSentenciaDeUpdateOInsertODelete( tcSentencia as String ) as Boolean
		local lcAccion as String
		
		lcAccion = SubStr( Alltrim( tcSentencia ), 1 , At( " ", Alltrim( tcSentencia ) ) )
		return ( occurs( "INSERT ", upper( lcAccion ) ) > 0 or occurs( "UPDATE ", upper( lcAccion ) ) > 0 or occurs( "DELETE ", upper( lcAccion ) ) > 0 )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsUnaTablaQuePermiteABMEnReplica( tcTabla as String ) as Boolean
		local llRetorno as Boolean, lnI as Integer, lcTabla as string

		llRetorno = .F.
		lcTabla = iif( occurs( ".dbf", tcTabla ) > 0, substr( tcTabla, 1, at( ".dbf", tcTabla ) - 1 ), tcTabla )
		for lnI = 1 to this.oTablasPermitenABMReplica.Count
			if upper( alltrim( lcTabla ) ) == upper( alltrim( this.oTablasPermitenABMReplica.item[ lnI ] ) )
				llRetorno = .T.
				exit
			endif
		next
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarVersionLibreriasCrystal() as Boolean 
		local llRtetorno as Boolean, loValidador as Object 	 
		loValidador = newobject( "ValidadorCrystal", "ValidadorCrystal.prg" )
		llRtetorno = loValidador.ValidarVersionLibrerias()
		return llRtetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ActualizarLibreriasCrystal() as Void
		local loInstalador as Object, loError as Exception  
		try 	
			loInstalador = _screen.zoo.crearobjeto("InstaladorLibreriasCrystal")
			loInstalador.instalar()
		catch to loError
			this.agregarinformaciondeexcepcion("No se pudieron actualizar las libreías de impresión.")
		finally
			loInstalador.release()
		endtry	
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ValidarActualizacionDeLibreriasCrystal() as Boolean 
		local llRetorno as Boolean, loConfiguraciones as Object 
		loConfiguraciones = _screen.zoo.crearobjeto( "ZooLogicSA.Core.Configuraciones.Configuraciones" )
		llRetorno = loConfiguraciones.Aplicacion.ActualizarLibreriasCrystal 
		loConfiguraciones = null
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ProcesarInstanciacionErroneaDeAplicacion() as Void
		* Se llama despues del login, servicioaplicaciones decide no ejecutar nada porque ADN Implant no valido DB
		this.oMonitorDeIngresoYSalida.FicharSalida()
		if ( vartype( _Screen.Zoo )='O' and vartype( _Screen.Zoo.App )='O' )
			_Screen.Zoo.App.Loguear("Marcar Salida")
			_Screen.Zoo.App.FinalizarLogueo()
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerPrimeraSucursalExistente() as String
		local llRetorno as Boolean, lcRetorno as String, lnInd as Integer
		
		lcRetorno = ""
		llRetorno = .t.
		if empty( this.aSucursales )
			llRetorno = this.CargarSucursales()
		endif
		if llRetorno and alen( this.aSucursales, 1 ) > 0
			for lnInd = 1 to alen( this.aSucursales, 1 )
				if this.VerificarExistenciaBase( alltrim( this.aSucursales[ lnInd, 1 ] ) ) and this.aSucursales[ lnInd, 1 ] <> this.ObtenerSucursalDefault()
					lcRetorno = alltrim( this.aSucursales[ lnInd, 1 ] )
					exit
				endif
			next
		endif
		
		if empty( lcRetorno ) 
			lcRetorno = this.ObtenerSucursalDefault()
		endif
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function HabilitaPoolDeAplicaciones() as Boolean
		return .T.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function UtilizarElAAO() as Boolean
		return upper( alltrim(_screen.Zoo.app.NombreProducto ) ) != "ZL" and !goLibrerias.EsAutoBuildDistribuido()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function UtilizaCF() as Boolean
		return .F.
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EjecutarMigradorDeParametros() as Void
		&& Reescrito en Felino		
	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	function UtilizarOptimizacionDeConsultasPorFechaModificacion() as Boolean
		return .f.
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function SetearParametrosModoAvanzadoyEstilo() as Void
	
		if vartype( goServicios.Parametros.Dibujante ) = "O" 
			if  pemstatus( goServicios.Parametros.Dibujante, "ModoAvanzado", 5 ) and !goServicios.Parametros.Dibujante.ModoAvanzado
				goServicios.Parametros.Dibujante.ModoAvanzado = .t.
			endif
			if  pemstatus( goServicios.Parametros.Dibujante, "Estilo", 5 ) and goServicios.Parametros.Dibujante.Estilo <> 2
				goServicios.Parametros.Dibujante.Estilo = 2
			endif
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EjecutandoSalidaDelSistema() as Void
		*Evento
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function VerificarBDPreferente() as Void
		&& verifico si la base de datos preferente no es una de réplica
		local loGestorDB as Object, lnI as integer, llTieneDemo as Boolean, lcPreferenteOld as String
		lcPreferenteOld = goParametros.Nucleo.OrigenDeDatosPreferente
		loGestorDB = _screen.zoo.crearobjeto( "GestorBaseDeDatos", "GestorBaseDeDatos.prg" )

		if loGestorDB.VerificarSiEsBDMarcadaComoReplica( goParametros.Nucleo.OrigenDeDatosPreferente )
			for lnI = 1 to alen( _Screen.Zoo.App.aSucursales, 1 )
				lcBaseDeDatos = _Screen.Zoo.App.aSucursales[ lnI, 1 ]
				if !loGestorDB.VerificarSiEsBDMarcadaComoReplica( lcBaseDeDatos )
					if alltrim( upper( lcBaseDeDatos ) ) = "DEMO"
						llTieneDemo = .t.				
					else
						goParametros.Nucleo.OrigenDeDatosPreferente = lcBaseDeDatos
						exit
					endif
				endif
			endfor
			if alltrim( goParametros.Nucleo.OrigenDeDatosPreferente ) = alltrim( lcPreferenteOld ) and llTieneDemo 
				goParametros.Nucleo.OrigenDeDatosPreferente = "DEMO"
			endif
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ReasignarSerieEnSesion() as Void
		goServicios.Terminal.ReasignarSerieEnSesion()
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ReportarRegistroTerminal() as Void
		goServicios.Terminal.Reportar()
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function DesRegistrarRegistroTerminal() as Void
		goServicios.Terminal.DesRegistrar()
	endfunc 

	
	*-----------------------------------------------------------------------------------------
	function RegistrarTerminalSiCorresponde() as Void
		if goServicios.Ejecucion.PuedeRegistrarTerminal() and _screen.lUsaCapaDePresentacion and !goServicios.Terminal.lSeRegistro
			goServicios.Terminal.lForzarInicioRegistro = .t.
			this.IniciarRegistroTerminal()
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oAspectoAplicacion_Access() as Void
		if !this.lDestroy and (type("this.oAspectoAplicacion") <> "O" or isnull(this.oAspectoAplicacion))
			this.oAspectoAplicacion = _screen.zoo.CrearObjetoPorProducto("AspectoAplicacion")
		endif
		Return this.oAspectoAplicacion
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AperturaAutomaticaDeEntidades() as Void
		local loEntidadAPERTURAAUTOMATICAENTIDADES as Object, loItemForm as Object, loError as zooexception OF zooexception.prg   
		try 
			if !empty( alltrim( goServicios.Seguridad.cUltimoUsuarioLogueado  ) )
				loEntidadAPERTURAAUTOMATICAENTIDADES  = _screen.zoo.instanciarentidad('APERTURAAUTOMATICAENTIDADES') 
				loEntidadAPERTURAAUTOMATICAENTIDADES.Usuario = goServicios.seGURIDAD.cUltimoUsuarioLogueado 
				for each loItemForm in loEntidadAPERTURAAUTOMATICAENTIDADES.AccionesDetalle
					goServicios.Formularios.Mostrar( alltrim(loItemForm.Entidad))
				endfor
			endif 	
		catch to loError
		finally 
			if vartype( loEntidadAPERTURAAUTOMATICAENTIDADES ) = 'O'
				loEntidadAPERTURAAUTOMATICAENTIDADES.release()
			endif 	
		endtry 	
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearDatosDelMotor() as Void
		local loColaborador as Objects
		loColaborador = _screen.zoo.CrearObjeto( "ColaboradorBarraDeEstadoMotorDB", "ColaboradorBarraDeEstadoMotorDB.prg" )
		loColaborador.EjecutarSentenciaMotorDB( "c_DatosMotor", this.DataSessionId )

		if used( "c_DatosMotor" ) and reccount( "c_DatosMotor" ) > 0
			select c_DatosMotor

			go top

			lcNumVersion = alltrim( c_DatosMotor.numVersion )
			
			do case
				case left(lcNumVersion ,3) = '17.'
					lnVersionSQL = 2025
					lcVersionSQL = '2025'
				case left(lcNumVersion ,3) = '16.'
					lnVersionSQL = 2022
					lcVersionSQL = '2022'
				case left(lcNumVersion ,3) = '15.'
					lnVersionSQL = 2019
					lcVersionSQL = '2019'
				case left(lcNumVersion ,3) = '14.'
					lnVersionSQL = 2017
					lcVersionSQL = '2017'
				case left(lcNumVersion ,3) = '13.'
					lnVersionSQL = 2016
					lcVersionSQL = '2016'
				case left(lcNumVersion ,3) = '12.'
					lnVersionSQL = 2014
					lcVersionSQL = '2014'
				case left(lcNumVersion ,3) = '11.'
					lnVersionSQL = 2012
					lcVersionSQL = '2012'
				case left(lcNumVersion ,3) = '10.5'
					lnVersionSQL = 2008
					lcVersionSQL = '2008 R2'
				case left(lcNumVersion ,3) = '10.'
					lnVersionSQL = 2008
					lcVersionSQL = '2008'
				case left(lcNumVersion ,2) = '9.'
					lnVersionSQL = 2005
					lcVersionSQL = '2005'
				otherwise
					lnVersionSQL = 0
					lcVersionSQL = ''
			endcase
			_Screen.Zoo.nVersionSQLNo = lnVersionSQL
			_Screen.Zoo.cVersionSQLNo = lcVersionSQL

			use in( "c_DatosMotor" )
		endif

		release loColaborador

	endfunc 

enddefine
