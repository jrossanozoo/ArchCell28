define class ent_ServicioRest as Din_EntidadServicioRest of Din_EntidadServicioRest.prg

	#IF .f.
		Local this as ent_ServicioRest of ent_ServicioRest.prg
	#ENDIF

	oServer = null
	oFactoryServicioProducto = null
	oTimer = null 
	oEjecutor = null
	oAccesoImpresoras = null 
	oLogueosServicio = null
	oEntidadAux  = null
	
	*-----------------------------------------------------------------------------------------
	Function Nuevo() As Boolean
		dodefault()		
		if _screen.zoo.app.lEsEntornoCloud 
			this.Puesto = "localhost"
			this.lHabilitarPuesto = .F.
		endif
	Endfunc

	
	*-----------------------------------------------------------------------------------------
	function oFactoryServicioProducto_Access() as Void
		if !this.ldestroy and ( !vartype( this.oFactoryServicioProducto ) = 'O' or isnull( this.oFactoryServicioProducto ) )
			this.oFactoryServicioProducto = _screen.zoo.crearobjetoPorProducto( "FactoryServicioProducto" )
		endif
		return this.oFactoryServicioProducto
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function oEntidadAux_Access() as Void
		if !this.ldestroy and ( !vartype( this.oEntidadAux ) = 'O' or isnull( this.oEntidadAux ) )
			this.oEntidadAux = _screen.zoo.instanciarentidad(  "SERVICIOREST", , .t. )
		endif
		return this.oEntidadAux
	endfunc 
		
	*--------------------------------------------------------------------------------------------------------
	function Valor_PK_Assign( txVal as variant ) as void		
		Local loEntidadValor as Object	
		dodefault( txVal )
		loEntidadValor = _screen.zoo.instanciarentidad( "VALOR" )
		loEntidadValor.Codigo = txVal
		if ( txVal != "" and loEntidadValor.Tipo != 6 )
			this.Setear_Valor( "" )
			this.Valor_PK = ""
			goMensajes.enviar( "Debe ingresar un valor de tipo cuenta corriente.", 0, 2 )
		endif
		loEntidadValor.Release()
	endfunc
		
	*--------------------------------------------------------------------------------------------------------
	function PercepcionesACtaCte_Assign( txVal as variant ) as void		
		dodefault( txVal )
		this.EventoActualizarControlValor()
	endfunc
	
	*--------------------------------------------------------------------------------------------------------
	function EventoActualizarControlValor( ) as void
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function oAccesoImpresoras_Access() as Void
		if !this.ldestroy and ( !vartype( this.oAccesoImpresoras ) = 'O' or isnull( this.oAccesoImpresoras ) )
			this.oAccesoImpresoras = _screen.dotnetbridge.crearobjeto( "ZoologicSA.ControlDeImpresoras.AccesoImpresoras" )
		endif
		return this.oAccesoImpresoras
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function oLogueosServicio_Access() as Void
		if !this.ldestroy and ( !vartype( this.oLogueosServicio ) = 'O' or isnull( this.oLogueosServicio ) )
			this.oLogueosServicio = _screen.zoo.crearobjeto( "LogueosServicioREST" )
		endif
		return this.oLogueosServicio
	endfunc
	
	*--------------------------------------------------------------------------------------------------------
	function Validar_Puerto( txVal as variant ) as Boolean
		local llRetorno as Boolean
		llRetorno = dodefault( txVal )
		if !between( txVal, 1, 65535 )
			goServicios.Errores.LevantarExcepcion( "El puerto de escucha debe ser un valor entre 1 y 65535." )
		endif
		
		Return llRetorno
	endfunc

	*-------------------------------------------------------------------------------------------------
	Function AntesDeGrabar() As Boolean
		local llRetorno as Boolean, lccod as String  
		llRetorno = dodefault()
		
		if this.PercepcionesACtaCte and empty( alltrim( this.Valor_PK ) )
			this.AgregarInformacion( "Debe cargar el campo Valor a utilizar en diferencia por percepciones" )
			llRetorno = .F.
		endif

		if llRetorno and empty( this.ImpresoraPredeterminada )
			llRetorno = .f.
			goServicios.Errores.LevantarExcepcion( "Debe seleccionar una impresora válida." )
		endif
		if llRetorno 
			lccod = this.ValidarPuertoEnUso( this.Puerto )
			if ! empty( lccod )
				llRetorno = .f.
				goServicios.Errores.LevantarExcepcion( "El puerto de escucha " + transform(this.Puerto ) + ' está siendo utilizado por el Servicio "' + alltrim(lccod) + '", seleccione otro valor entre 1 y 65535.' )
			endif
		endif 
		if llRetorno and !this.EsNuevo() and this.HuboAlgunCambioDeConfiguracion()
			this.EventoInformarReinicioServicio()
		endif

		if llRetorno and _screen.zoo.app.lEsEntornoCloud 
			this.lHabilitarPuesto = .T.
			this.Puesto = getenv( "COMPUTERNAME" )
			this.lHabilitarPuesto = .F.
		endif

		Return llRetorno 
	endfunc

	*-----------------------------------------------------------------------------------------
	function HuboAlgunCambioDeConfiguracion() as as Boolean
		local llRetorno as Boolean
		with this.oEntidadAux
			llRetorno = ( .Puerto !=  this.Puerto or .Puesto != this.Puesto or ;
					 .Activo != this.Activo or .BaseDeDatos != this.BaseDeDatos or ;
					 .CajaActiva_pk !=  this.CajaActiva_pk or .OrigenComprobante !=  this.OrigenComprobante or ;
					 .ImpresoraPredeterminada != this.ImpresoraPredeterminada )
		endwith 	
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarPuertoEnUso( txVal ) as string
		Local lcAtributos As String, lcXml as string, lcCursor as String, llRetorno as string 
		llRetorno = '' 
		lcAtributos = 'Puerto, Codigo'
		lcCursor = 'C' + sys(2015)
		lcXml = this.oad.obtenerDatosEntidad( lcAtributos, "", "", "", "" )
		this.xmlacursor( lcXml, lcCursor )
		locate for puerto = txVal  and alltrim(codigo) != alltrim( this.Codigo )
		if found()
			llRetorno = &lcCursor..Codigo
		endif 	
		use in select ( lcCursor ) 
		return llRetorno
	Endfunc

	*--------------------------------------------------------------------------------------------------------
	function Cargar() as Boolean
		local llRetorno as Boolean

		llRetorno = dodefault()
	
		if !empty( nvl( this.TipoComprobante, "" ) )

			do case
				case upper(alltrim( this.TipoComprobante ) ) == "FACTURA"
					this.OrigenComprobante = 0
					this.TipoComprobante = ""
				case upper(alltrim( this.TipoComprobante ) ) == "TICKETFACTURA"
					this.OrigenComprobante = 1
					this.TipoComprobante = ""
				case upper(alltrim( this.TipoComprobante ) ) == "FACTURAELECTRONICA"
					this.OrigenComprobante = 2
					this.TipoComprobante = ""
			endcase

		endif

		return llRetorno
	endfunc
		
	*-----------------------------------------------------------------------------------------
	function IniciarServicio() as Void
		local loEjecutor as Object, loEjecutorNET as Object, loUri as Object, loOrganicServicio as Object,;
			loServicioType as Object, loTypeContrato as Object, loInterfaces as Array, lcBaseDatos as String, lnPuerto as Integer, lcClaseServicio as String,;
			lnParametroCajaActiva as Integer
		
		local array loInterfaces(1)

		this.IniciarlizarInformacionSerieEnUsuarioSyste()

		if goModulos.EntidadHabilitada("SERVICIOREST") && script
			lcBaseDatos = iif( alltrim( this.BaseDeDatos ) == '[PREF]', goParametros.Nucleo.OrigenDeDatosPreferente, this.BaseDeDatos )
			lnPuerto = this.Puerto 
			
			_screen.zoo.app.cSucursalActiva = rtrim( lcBaseDatos )

			*-------------------------
			this.EventoProgresoDeInstanciaServicio( "Seteando informacion aplicacion" )
			loInfo = _screen.Zoo.CrearObjeto( "ZooLogicSA.OrganicServiciosREST.Administracion.InformacionOrganic" )
			loInfo.RutaInstalacion = _screen.zoo.cRutaInicial
			loInfo.BaseDeDatosActiva = rtrim( lcBaseDatos )
			loInfo.CodigoServidor = rtrim( this.Codigo )
			loInfo.Descripcion = rtrim( this.Descripcion )
			loInfo.PuertoConfigurado = lnPuerto
			loInfo.TipoComprobante = rtrim( str( this.OrigenComprobante ) )
			loInfo.Version = _screen.zoo.app.ObtenerVersion()
			loInfo.CajaActiva = this.CajaActiva.Id
			loInfo.ImpresoraPredeterminada = rtrim( this.ImpresoraPredeterminada )
			loInfo.OcultarVentasEnHome = this.OcultarVentasEnApp
			this.ObtenerBasesDeDatos( loInfo )
			this.IniciarControladorFiscal( this.OrigenComprobante )
			this.DefinirGenerarLogueos()
			*-------------------------
			
			*-------------------------
			this.EventoProgresoDeInstanciaServicio( "Instanciado Ejecutor" )
			this.oEjecutor = _screen.Zoo.CrearObjeto( this.oFactoryServicioProducto.ObtenerClaseEjecutor(),, this, .t. )

			loRegistroOrganic = _screen.Zoo.CrearObjeto( "ZooLogicSA.OrganicServiciosREST.DTO.Seguridad.SeguridadOrganicConfiguracion" )
			loRegistroOrganic.CifradoJWT = .f.
			loRegistroOrganic.EjecutorOrganic = this.oEjecutor
			loRegistroOrganic.CodigoServidor = rtrim( this.Codigo )
			loRegistroOrganic.EntidadClavesPrivadas = _screen.zoo.InstanciarEntidad( "CLAVESECRETAREST" )
			loRegistroOrganic.StringConexionSql = goServicios.Datos.oManagerConexionaSQL.ObtenerCadenaConexionNet()
			
			loFactoryServicio = _screen.Zoo.CrearObjeto( "ZooLogicSA.OrganicServiciosREST.Servicio.FactoryServicio", , loRegistroOrganic )
			*-------------------------

			this.EventoProgresoDeInstanciaServicio( "Creando URI" )
			loUri = _screen.Zoo.CrearObjeto( "System.Uri",, "http://localhost:" + transform( lnPuerto ) + "/" + this.oFactoryServicioProducto.ObtenerNombreEndpoint() )

			this.EventoProgresoDeInstanciaServicio( "Creando Servicio" )
			lcClaseServicio = this.oFactoryServicioProducto.ObtenerClaseServicio()
			loOrganicServicio = _screen.Zoo.CrearObjeto( lcClaseServicio, "", loInfo, loFactoryServicio )
			loTypeContrato = loOrganicServicio.ObtenerTipoContrato()

			if vartype(this.oServer) != "X"
				this.oServer.Detener()
			endif	

			this.EventoProgresoDeInstanciaServicio( "Creando Servidor" )
			this.oServer = _screen.Zoo.CrearObjeto( 'ZooLogicSA.OrganicServiciosREST.Servidor.OrganicServidorREST',, goRegistry.Nucleo.ServicioREST.DesactivarOptimizacionDeFrameworkNET )

			this.EventoProgresoDeInstanciaServicio( "Iniciando Servidor" )

			this.oLogueosServicio.InformarEventViewerForzado( "Servicio Código: " + this.Codigo + ", Puerto: " + transform( lnPuerto ) + " iniciando servidor." )

			this.oServer.Iniciar( loUri, loOrganicServicio, loTypeContrato )

			this.oLogueosServicio.InformarEventViewerForzado( "Servidor Código: " + this.Codigo + ", Puerto: " + transform( lnPuerto ) + " iniciado." )
			
			this.EventoServicioInstanciado()
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function IniciarControladorFiscal( tnOrigenComprobante as Integer ) as Void
		local llUsaCapaDePresentacion as Boolean
		if tnOrigenComprobante == 1
			if vartype( goControladorFiscal ) == "O" and !isnull( goControladorFiscal )
			else
				llUsaCapaDePresentacion = _screen.lUsaCapaDePresentacion
				_screen.lUsaCapaDePresentacion = .t.
				goServicios.Mensajes.HabilitarMensajeria( .F. )
				_Screen.zoo.app.VerificarInicializacionControladorFiscal()
				goServicios.Mensajes.HabilitarMensajeria( .T. )
				_screen.lUsaCapaDePresentacion = llUsaCapaDePresentacion
			endif
		endif
	endfunc
	
	*--------------------------------------------------------------------------------------------------------
	function Destroy()
		this.lDestroy = .t.
		if vartype(this.oServer)!="X"
			this.oServer.Detener()
			if !pemstatus(_screen,"lUsaServicioRest", 5) 
				_screen.AddProperty("lUsaServicioRest", .f.)
			endif
			goServicios.Impresion.cImpresoraForzada = ""
		endif	
		this.oServer = null
		dodefault()
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoProgresoDeInstanciaServicio( tcMensaje as String ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoServicioInstanciado() as Void
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function ValorSugeridoTipocomprobante() as void
		local lcTipocomprobante as String
		with goParametros.Felino
			if !empty( .ControladoresFiscales.Codigo )
				lcTipocomprobante = 'TICKETFACTURA'
			else
				if !empty( .GestionDeVentas.FacturacionElectronica.RutaDelCertificado )
					lcTipocomprobante = 'FACTURAELECTRONICA'
				else
					lcTipocomprobante = 'FACTURA'
				endif
			endif
		endwith 
		
		this.Tipocomprobante = lcTipocomprobante 

		dodefault()
	endfunc

	*-----------------------------------------------------------------------------------------
	function CerrarHost() as Void
		this.oTimer = newobject("Timer")
		this.oTimer.Interval = 1000
		bindevent(this.oTimer, "Timer", this, "CerrarHostAsync" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CerrarHostAsync() as Void
		clear events
		_screen.Zoo.app.Salir()
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EnviarSolicitudDeCierre( tcNombreEndpoint as String, tnPuerto as Integer ) as Integer
		local loSol as Object, loRespuesta as Object, lnCodigoEstado as Integer 

		loSol = _screen.dotnetbridge.crearobjeto("ZooLogicSA.OrganicServiciosREST.Cliente.Core.Solicitud")
		_screen.dotnetbridge.setearvalorpropiedad( loSol, "Url", "http://localhost:" + transform( tnPuerto ) + "/" + tcNombreEndpoint + "/CerrarHost" )

		Try
			loRespuesta = _screen.dotnetbridge.invocarmetodo ( loSol, "Procesar" )
			lnCodigoEstado = _screen.dotnetbridge.ObtenerValorpropiedad( loRespuesta, "CodigoEstado" )
		Catch To loError
			lnCodigoEstado = 599
		endtry 

		return lnCodigoEstado 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerValorCodigo( toJsonInformacionServicio as String ) as String
		local loInfo as Object, loInfoServicio as Object, loInfoOrganic as Object, lcCodigoRespuesta as String
		loInfo = _screen.DotNetBridge.crearobjeto("ZooLogicSA.OrganicServiciosREST.Administracion.InformacionServicio")
		loInfoServicio = _screen.DotNetBridge.InvocarMetodoEstatico( "Newtonsoft.Json.JsonConvert", "DeserializeObject", toJsonInformacionServicio, _screen.dotnetbridge.invocarmetodo( loInfo, "getType" ) )
		loInfoOrganic = _screen.DotNetBridge.obtenervalorPropiedad( loInfoServicio, "InformacionOrganic" )
		lcCodigoRespuesta = _screen.DotNetBridge.obtenervalorPropiedad( loInfoOrganic, "CodigoServidor" )

		return lcCodigoRespuesta
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function InvocarMetodoObtenerInformacionServicio( tcNombreEndpoint as String, tnPuerto as Integer ) as Void
		local loSol as Object
		loSol = _screen.dotnetbridge.crearobjeto("ZooLogicSA.OrganicServiciosREST.Cliente.Core.Solicitud")
		_screen.dotnetbridge.setearvalorpropiedad( loSol, "Url", "http://localhost:" + transform( tnPuerto ) + "/" + tcNombreEndpoint + "/ObtenerInformacionServicio" )
		return _screen.dotnetbridge.invocarmetodo ( loSol, "Procesar" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CerrarServicio() as Void
		local loError as Exception, loRespuesta as Object, lnCodigoEstado as Integer,;
		 lcEstado as String , lcMensaje as String,;
		 lcNombreEndpoint as String, lcCodigoEnResponse as String, lnRespuesta as Integer, lCierreDeHostConfirmado as Boolean

		lcNombreEndpoint = this.oFactoryServicioProducto.ObtenerNombreEndpoint()

		try
			this.EventoProgresoDeInstanciaServicio( "Contactando Servicio en puerto " + transform( this.Puerto ) )
			loRespuesta = this.InvocarMetodoObtenerInformacionServicio( lcNombreEndpoint, this.Puerto )
			lnCodigoEstado = _screen.dotnetbridge.ObtenerValorpropiedad( loRespuesta, "CodigoEstado" )
		
			lcMensaje = ""
			do case
				case lnCodigoEstado == 200
					this.EventoProgresoDeInstanciaServicio( "Verificando código de host" )
					lcCodigoEnResponse = this.ObtenerValorCodigo( _screen.dotnetbridge.ObtenerValorpropiedad( loRespuesta, "Cuerpo" ) )
	
					lCierreDeHostConfirmado = .t.

					if lcCodigoEnResponse != this.Codigo
						lcMensaje = "El servicio escuchando en el puerto " + transform( this.Puerto ) + " (" + lcCodigoEnResponse + ") no coincide con el código actual (" + this.Codigo + "). Desea continuar?"
						lCierreDeHostConfirmado = ( this.oMensaje.Advertir( lcMensaje, 1, 1 ) == 1 )
					endif
	
					if lCierreDeHostConfirmado
						lnRespuesta = this.EnviarSolicitudDeCierre( lcNombreEndpoint, this.Puerto ) 
						this.EventoProgresoDeInstanciaServicio( "Verificando respuesta de cierre" )
						if lnRespuesta == _screen.DotNetBridge.ObtenerValorEnum( "System.Net.HttpStatusCode", "OK" )
							lcMensaje = "Se procesó correctamente el mensaje enviado al servicio."
						else
							lcEstado  = _screen.dotnetbridge.ObtenerValorpropiedad( loRespuesta, "Status" )
							lcMensaje = "El mensaje enviado al servicio no se procesó correctamnente." + chr(13) + chr(10) + "Código de respuesta: " + transform( lnRespuesta ) + " - " + lcEstado 
						endif
					endif

				case lnCodigoEstado == 405
					lcMensaje = "El servicio esta inicializando y aún no puede atender mensajes. Intente en unos minutos (Código de respuesta: " + transform( lnCodigoEstado ) + ")"
				otherwise
					lcMensaje = "El servicio en el puerto " + transform( this.Puerto ) + " se encuentra en un estado erróneo. No se puede enviar mensaje de cierre."
			endcase
			this.EventoInformarEstadoCierreServicio( lcMensaje )
		Catch To loError
			this.EventoInformarEstadoCierreServicio( "Servicio no disponible en el puerto " + transform( this.Puerto ) + ". Verifique que el host corresponda al equipo actual, o intente más tarde." )
		Endtry

	endfunc 
	*-----------------------------------------------------------------------------------------
	function EventoInformarEstadoCierreServicio( tcMensaje as String ) as Void

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ExisteImpresora( tcImpresora ) as Void
		local lnPosicion as Integer
		=aprinters( laListaDeImpresoras, 1 )
		lnPosicion = ascan( laListaDeImpresoras, tcImpresora, 1, alen( laListaDeImpresoras, 1 ), 1, 1 + 8 )
		return lnPosicion>0
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerImpresoraPredeterminadaDelSistema() as String
		return this.oAccesoImpresoras.ObtenerImpresoraPredeterminadaDelSistema()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoInformarReinicioServicio() as Void
	endfunc 
	
	*-------------------------------------------------------------------------------------------
	Function Modificar() As void
		dodefault()
		this.oEntidadAux.Codigo = this.Codigo
	Endfunc

	*-----------------------------------------------------------------------------------------
	function VerificarIniciarServicios() as Void
		local loCrearReglasFirewall as Object, lcCursor as String, lcXml as String, loListaIniciados as zoocoleccion OF zoocoleccion.prg;
				lnCantidadServicios as Integer, lcNombrePuesto as String

		loCrearReglasFirewall = _screen.dotnetbridge.crearobjeto("ZooLogicSA.Core.Firewall.CrearReglasEnFirewall")
		
		if _screen.zoo.app.lEsEntornoCloud 
			lcNombrePuesto = getenv( "COMPUTERNAME" )
		else
			lcNombrePuesto = upper( rtrim( goServicios.Librerias.ObtenerNombrePuesto() ) )
		endif
		
		lcCursor = sys(2015)
		lcXml = loEnt.oad.obtenerdatosentidad( "Codigo,Puerto,FECHAALTAFW,HORAALTAFW", "(Puesto='" + lcNombrePuesto + "' or Puesto='localhost') and Activo=1" )
		this.XmlACursor( lcXml, lcCursor )
		
		select &lcCursor.
		
		loListaIniciados = _screen.zoo.crearobjeto( "ZooColeccion" )
		
		count to lnCantidadServicios
		
		if lnCantidadServicios>0
			scan
				
				if ( loListaIniciados.Buscar( &lcCursor..Puerto ) )
					this.oLogueosServicio.AdvertirEventViewer( "Se encontraron más de un servicio ( Código: " + &lcCursor..Codigo + ", Puerto: " + transform( &lcCursor..Puerto ) + " ) habilitados para iniciar, se inicia la configuración mas reciente." )
				else
					loListaIniciados.Agregar( &lcCursor..Puerto )
					
					*** abrir firewall
					if _screen.dotnetbridge.invocarmetodo( loCrearReglasFirewall , "EstaBloqueado", &lcCursor..Puerto)
						_screen.dotnetbridge.invocarmetodo( loCrearReglasFirewall , "AbrirPuerto", "Zoo Logic - Servicio API Rest", &lcCursor..Puerto)
					endif
					
					** ejecutar servicio
					if !this.EstaIniciado( &lcCursor..Codigo,  &lcCursor..Puerto )
						this.IniciarScriptServicio( &lcCursor..Codigo,  &lcCursor..Puerto )
						this.oLogueosServicio.InformarEventViewerForzado( "El servicio Código: " + &lcCursor..Codigo + ", Puerto: " + transform( &lcCursor..Puerto ) + " se inició correctamente." )
					else
						this.oLogueosServicio.InformarEventViewerForzado( "El servicio Código: " + &lcCursor..Codigo + ", Puerto: " + transform( &lcCursor..Puerto ) + " ya se esta ejecutando." )
					endif
				endif
				
				
			endscan
		else
			this.oLogueosServicio.InformarEventViewerForzado( "No se encontraron servicios habilitados para iniciar." )
		endif

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function IniciarScriptServicio( tcCodigoServicio as String, tnPuerto as Integer ) as Void
		local lcRutaScript as String, loInstrucciones as zoocoleccion OF zoocoleccion.prg, llSalir as Boolean, llUsaCapaDePresentacion as Boolean

		lcRutaScript = addbs( _screen.zoo.ObtenerRutaTemporal() ) + this.ObtenerNombewArchivoScript( tcCodigoServicio, tnPuerto )

		loInstrucciones = _screen.zoo.crearobjeto( "ZooColeccion" )
		
		with loInstrucciones
			.Agregar( [loEnt = _screen.zoo.instanciarentidad('serviciorest')] )
			.Agregar( [loEnt.Codigo='] + tcCodigoServicio + ['] )
			.Agregar( [loEnt.Iniciarservicio()] )
			.Agregar( [_vfp.DoCmd( 'read events' )] )
		endwith
	
		llSalir = .t.
		llUsaCapaDePresentacion = .f.
		goServicios.Ejecucion.GenerarScript( "", "", loInstrucciones, lcRutaScript, llSalir, llUsaCapaDePresentacion )

		goServicios.Ejecucion.EjecutarScript( lcRutaScript )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerNombewArchivoScript( tcCodigoServicio as String, tnPuerto as Integer ) as String
		return "inicioapi_" + tcCodigoServicio + "_" + transform( tnPuerto ) + ".zs"
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EstaIniciado( tcCodigoServicio as String, tnPuerto as Integer ) as Void
		local llResult as Boolean, lcArchivoScript as String, lcNombreExe as String, loProcesos as Object, loItem as Object, lcArgument as String
		
		llResult = .f.

        lcArchivoScript = this.ObtenerNombewArchivoScript( tcCodigoServicio, tnPuerto )
		
		if _screen.zoo.lDesarrollo
			lcNombreExe = _vfp.FullName
		else
			lcNombreExe = sys( 16, 0 )
		endif

		loProcesos = golibrerias.obtenerinfoproceso(justfname(lcNombreExe))
		
		For Each loItem In loPRocesos
	
            lcArgument = loItem.CommandLine 

            if lcArchivoScript $ lcArgument
                llResult = .t.
                exit
            endif
		endfor

        return llResult
	endfunc
	
	*-----------------------------------------------------------------------------------------
    function PrepararEntornoOrganic() as Void
        local lnCodigoRetorno as Integer, loE as Object, lcMensajeLog as String, lnParametroCajaActiva as Integer
            if !pemstatus( _screen,"lUsaServicioRest", 5 ) 
                _screen.AddProperty( "lUsaServicioRest", .t. )
            endif

			this.IniciarlizarInformacionSerieEnUsuarioSyste()

            if !empty( this.ImpresoraPredeterminada )
                goServicios.Impresion.cImpresoraForzada = this.ImpresoraPredeterminada
                if !this.ExisteImpresora( this.ImpresoraPredeterminada )
                    lnCodigoRetorno = this.oAccesoImpresoras.AgregarImpresora( this.ImpresoraPredeterminada )
                    if lnCodigoRetorno != 0
                        loE = _screen.dotnetbridge.crearobjeto( "System.ComponentModel.Win32Exception", 1801 )
                        lcMensajeLog = loE.Message
                        this.oLogueosServicio.AlertarEventViewer( "Error al agregar la impresora: " + lcMensajeLog )
                    endif
                endif
            endif
            lnParametroCajaActiva = goParametros.Felino.GestiondeVentas.NumerodeCaja
            if !empty( this.CajaActiva_PK )
                goParametros.Felino.GestiondeVentas.NumerodeCaja = this.CajaActiva_PK
            else
                goParametros.Felino.GestiondeVentas.NumerodeCaja = lnParametroCajaActiva
            endif
    endfunc
    
   	*-----------------------------------------------------------------------------------------
	function ObtenerBasesDeDatos( toInfoOrganic as Object) as Void
		local lcCursorBD as string
		lcCusrosBD = "c_" + sys(2015)
		goDatos.EjecutarSentencias( "select empcod from emp where empcod != '' and empcod is not null order by empcod" ;
			, "emp.dbf", addbs( _screen.zoo.cRutaInicial ), lcCusrosBD, this.DataSessionId )	
				
		select ( lcCusrosBD )
		scan
			toInfoOrganic.BasesDeDatos.Add( rtrim( empcod ) )
		endscan
		
		use in select ( lcCusrosBD )
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function IniciarlizarInformacionSerieEnUsuarioSyste() as Void
		local lcNombrePerfilLocalSystem as String
 
		lcNombrePerfilLocalSystem = goFormularios.ArmarNombrePerfilSegunEntorno( goLibrerias.ObtenerNombreEquipo() + "$" )

		if ( lcNombrePerfilLocalSystem = goFormularios.cNombrePerfil )
			this.IniciarlizarInformacionSerie()
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function IniciarlizarInformacionSerie() as Void
		local lcXmlCursorPerfiles as String, lcCursorPerfiles as Stirng, lcPerfil as Stirng, llPerfilRecordadoEsDemo as Boolean
		local lcArchivo1 as Stirng, lcArchivo2 as String, lcNombrePerfil as String

		lcXmlCursorPerfiles = goFormularios.CargarPerfilesMismoMA()
		lcCursorPerfiles = sys( 2015 )

		this.xmlACursor( lcXmlCursorPerfiles , lcCursorPerfiles )
		
		lcPerfil = ""
		llPerfilRecordadoEsDemo = .f.
		llPerfilTieneModuloREST = .f. 

		llPerilEncontrado = .f.
 
		select &lcCursorPerfiles.
		scan		
			if llPerilEncontrado
				loop
			endif
			With goFormularios

				lcArchivo1 = .cArchivo1
				lcArchivo2 = .cArchivo2
				lcNombrePerfil = .cNombrePerfil
				try
					.cArchivo1 = Addbs( Justpath( Strtran( .cRutaArchivoInstalacion1, '"', "" ) ) ) + sys(2015) + ".sys"
					.cArchivo2 = Addbs( Justpath( Strtran( .cRutaArchivoInstalacion2, '"', "" ) ) ) + sys(2015) + ".dat"
					.cNombrePerfil = rtrim( &lcCursorPerfiles..Perfil )
					
					loModulos = _screen.zoo.crearobjeto( goModulos.Class )
					
					* Si no tiene los modulos para instanciar, no sirve
					if loModulos.EntidadHabilitada( "SERVICIOREST" )

						* DEMO siempre es igual, asi que ya recuerda uno identico, no importa seguir
						if llPerfilRecordadoEsDemo and upper(alltrim( &lcCursorPerfiles..Serie ) ) == "DEMO"
							loop
						endif

						if loModulos.ModuloHabilitado("H")
							lcPerfil = rtrim( &lcCursorPerfiles..Perfil )
							llPerfilTieneModuloREST = .t.
							llPerfilRecordadoEsDemo = (upper(alltrim( &lcCursorPerfiles..Serie ) ) == "DEMO")
							
							if !llPerfilRecordadoEsDemo
								llPerilEncontrado = .t.
								exit
							endif
						else
							if !llPerfilTieneModuloREST
								lcPerfil = rtrim( &lcCursorPerfiles..Perfil )
								llPerfilRecordadoEsDemo = (upper(alltrim( &lcCursorPerfiles..Serie ) ) == "DEMO")
							endif
						endif
					endif
				Catch To loError
					goServicios.Errores.LevantarExcepcion( loError )
				Finally
					.cArchivo1 = lcArchivo1
					.cArchivo2 = lcArchivo2
					.cNombrePerfil = lcNombrePerfil 
				endtry 
			endwith
		endscan

		if empty(_screen.zoo.app.cSerie)
			_screen.zoo.app.cSerie = "DEMO"
		endif
		
		if !empty( lcPerfil ) or _screen.zoo.app.cSerie = "DEMO"
			goFormularios.LimpiarInformacionLocalSeriesPorPerfil( lcPerfil )
			goModulos = null
			_screen.zoo.app.oModulos = null
			_screen.zoo.app.IniciarServicioModulos()
		else
			goServicios.Errores.LevantarExcepcionTexto( "Ningun perfil del sistema es apto para iniciar el servicio" )
		endif
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function Validar_LogueosHasta( txVal as variant ) as Boolean
		local llRetorno as Boolean, lnDiasMaximosDeLogueos as Integer
		
		llRetorno = dodefault( txVal )

		lnDiasMaximosDeLogueos = goServicios.Registry.Nucleo.ServicioREST.MaximaCantidadDeDiasEnLogueosRestApi

		if ( txVal - date() ) >  lnDiasMaximosDeLogueos
			goServicios.Errores.LevantarExcepcion( "La fecha ingresada solo puede ser hasta " + transform( lnDiasMaximosDeLogueos ) + " días posteriores a la fecha del día." )
		endif
	
		Return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function DefinirGenerarLogueos() as void

		if empty( this.LogueosHasta ) or this.LogueosHasta < date()
			goservicios.lnologuearrestapi = .T.
		else
			goservicios.lnologuearrestapi = .F.
		endif
		
	endfunc
	
enddefine
