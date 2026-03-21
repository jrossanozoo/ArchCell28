define class ServiciosAplicacion as zooSession of zooSession.prg

	#if .f.
		local this as ServiciosAplicacion of ServiciosAplicacion.prg
	#endif

	Ejecucion = null  && Manager de ejecución de Scripts
	Librerias = null
	Formularios = null
	Listados = null
	Transferencias = null
	Exportaciones = null
	Importaciones = null
	Monitor = null
	Datos = null
	Mensajes = null
	Errores = null
	Timer = null
	Controles = null
	Modulos = null
	Seguridad = null
	Estilos = null
	Memoria = null
	Logueos = null
	Impresion = null
	Parametros = null
	registry = null
	Multimedia = null
	Estructura = null
	Entidades = null
	Terminal = null
	SerializadorDeEntidades = Null
	SaltosDeCampoYValoresSugeridos = null
	PersonalizacionDeEntidades = null
	PoolDeObjetos = null
	RegistroDeActividad = null
	MonitorSaludBasesDeDatos = null
	ConsultaAFIP = null
	NotificacionWindowsToast = null
	WebHook = null
	ServicioNotificacionEnSegundoPlano = null
 
	oColServiciosActivos = null
	PrecisionDecimalEnCantidad = null
	RealTime = null
	
	MercadoPago = null
	*-----------------------------------------------------------------------------------------
	function Init() as Void
		this.oColServiciosActivos = newobject( "Collection" )
		
		this.Exportaciones = this.CrearObjetoServicios( "ManagerExportaciones" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function PrecisionDecimalEnCantidad_Access()
		if !this.lDestroy and !vartype( this.PrecisionDecimalEnCantidad ) = 'O'
			this.PrecisionDecimalEnCantidad = _screen.zoo.Crearobjeto( 'ColaboradorDecimalesEnCantidad' )
			this.AgregarControlDeServicio( this.PrecisionDecimalEnCantidad )
		endif
		return this.PrecisionDecimalEnCantidad
	endfunc

	*-----------------------------------------------------------------------------------------
	function RealTime_Access()
		if ( vartype( this.RealTime ) != 'O' or isnull( this.RealTime ) ) and !this.lDestroy
			this.RealTime = _screen.zoo.CrearObjetoPorProducto( 'tiemporeal' )
			this.AgregarControlDeServicio( this.RealTime )
		endif
		return this.RealTime
	endfunc

	*-----------------------------------------------------------------------------------------
	function MercadoPago_Access()
		if ( vartype( this.MercadoPago ) != 'O' or isnull( this.MercadoPago ) ) and !this.lDestroy
			this.MercadoPago = _screen.zoo.CrearObjetoPorProducto( 'ManagerMercadoPago' )
			this.AgregarControlDeServicio( this.MercadoPago )
		endif
		return this.MercadoPago
	endfunc
		
	*-----------------------------------------------------------------------------------------
	function Ejecucion_Access() as Object
		if ( vartype( this.Ejecucion ) != 'O' or isnull( this.Ejecucion ) ) and !this.lDestroy
			this.Ejecucion = this.CrearObjetoServicios( "ManagerEjecucion" )
			this.AgregarControlDeServicio( this.Ejecucion )
		endif		
		return this.Ejecucion
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Entidades_Access() as Object
		if ( vartype( this.Entidades ) != 'O' or isnull( this.Entidades) ) and !this.lDestroy
			this.Entidades = this.CrearObjetoServicios( "ManagerEntidades" )
			this.AgregarControlDeServicio( this.Entidades )
		endif		
		return this.Entidades
	endfunc 	

	*-----------------------------------------------------------------------------------------
	function Librerias_Access() as Object
		if ( vartype( this.Librerias ) != 'O' or isnull( this.Librerias ) ) and !this.lDestroy
			this.Librerias = this.CrearObjetoServicios( "Librerias" )
			this.AgregarControlDeServicio( this.Librerias )
		endif		
		return this.Librerias
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Errores_Access() as Object
		if ( vartype( this.Errores ) != "O" or isnull( this.Errores ) ) and !this.lDestroy
			this.Errores = this.CrearObjetoServicios( "ManagerErrores" )
			this.AgregarControlDeServicio( this.Errores )
		endif
		return this.Errores
	endfunc

	*-----------------------------------------------------------------------------------------
	function Multimedia_Access() As Object
		if ( vartype( this.Multimedia ) != "O" or isnull( this.Multimedia ) ) and !this.lDestroy
			this.Multimedia = this.CrearObjetoServicios( "Multimedia" )
			this.AgregarControlDeServicio( this.Multimedia )
		endif
		return this.Multimedia
	endfunc

	*-----------------------------------------------------------------------------------------
	function Importaciones_Access() as Object
		if ( vartype( this.Importaciones ) != 'O' or isnull( this.Importaciones ) ) and !this.lDestroy
			this.Importaciones = this.CrearObjetoServicios( "ManagerImportaciones" )
			this.AgregarControlDeServicio( this.Importaciones )
		endif		
		return this.Importaciones
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Listados_Access() as Object
		if ( vartype( this.Listados ) != 'O' or isnull( this.Listados ) ) and !this.lDestroy
			this.Listados = this.CrearObjetoServicios( "ManagerListados" )
			this.AgregarControlDeServicio( this.Listados )
		endif		
		return this.Listados
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Memoria_Access() as Object
		if ( vartype( this.Memoria ) != 'O' or isnull( this.Memoria ) ) and !this.lDestroy
			this.Memoria = this.CrearObjetoServicios( "Memoria" )
			this.AgregarControlDeServicio( this.Memoria )
		endif		
		return this.Memoria
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Impresion_Access() as Object
		if ( vartype( this.Impresion ) != 'O' or isnull( this.Impresion ) ) and !this.lDestroy
			this.Impresion = this.CrearObjetoServicios( "ManagerImpresion" )
			this.AgregarControlDeServicio( this.Impresion )
		endif		
		return this.Impresion
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Seguridad_Access() as Object
		local lcNombreArchivo as String
		
		if ( vartype( this.Seguridad ) != 'O' or isnull( this.Seguridad ) ) and !this.lDestroy
			lcNombreArchivo =  "Seguridad" + _screen.zoo.app.cProyecto
			if file( lcNombreArchivo + ".prg" ) or file( lcNombreArchivo + ".fxp" )
				this.Seguridad = this.CrearObjetoServicios( lcNombreArchivo )
			else
				this.Seguridad = this.CrearObjetoServicios( "Seguridad" )
			endif
			this.AgregarControlDeServicio( this.Seguridad )
		endif		
		return this.Seguridad
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Estructura_Access() as Object	
		if ( vartype( this.Estructura ) != 'O' or isnull( this.Estructura ) ) and !this.lDestroy
			this.Estructura = this.CrearObjetoServicios( "ServicioEstructura" + _screen.zoo.app.TipoDeBase )
			this.Estructura.Inicializar()
			this.AgregarControlDeServicio( this.Estructura )
		endif		
		return this.Estructura 
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Logueos_Access() as Object
		if ( vartype( this.Logueos ) != 'O' or isnull( this.Logueos ) ) and !this.lDestroy
			this.Logueos = this.CrearObjetoServicios( "ManagerLogueos" )
			this.AgregarControlDeServicio( this.Logueos )
		endif		
		return this.Logueos
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SerializadorDeEntidades_Access() as Object
		if ( vartype( this.SerializadorDeEntidades ) != 'O' or isnull( this.SerializadorDeEntidades ) ) and !this.lDestroy
			this.SerializadorDeEntidades = this.CrearObjetoServicios( "SerializadorDeEntidades" )
		endif
		return this.SerializadorDeEntidades
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Mensajes_Access() as Object
		local lcNombreArchivo as String

		if ( vartype( this.Mensajes ) != 'O' or isnull( this.Mensajes ) ) and !this.lDestroy
			this.Mensajes = this.CrearObjetoServicios( "Mensajes" )
			this.AgregarControlDeServicio( this.Mensajes )
		endif		
		return this.Mensajes 
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	function Transferencias_Access() as Object
		if ( vartype( this.Transferencias ) != 'O' or isnull( this.Transferencias ) ) and !this.lDestroy
			this.Transferencias = this.CrearObjetoServicios( "ManagerTransferencias" )
			this.AgregarControlDeServicio( this.Transferencias )
		endif		
		return this.Transferencias
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ConsultaAFIP_Access() as Object
		if ( vartype( this.ConsultaAFIP ) != "O" or isnull( this.ConsultaAFIP ) ) and !this.lDestroy
			this.ConsultaAFIP = this.CrearObjetoServicios( "ManagerConsultaAFIP" )
			this.AgregarControlDeServicio( this.ConsultaAFIP )
		endif
		return this.ConsultaAFIP
	endfunc

	*-----------------------------------------------------------------------------------------
	function NotificacionWindowsToast_Access() as Object

		if ( vartype( this.NotificacionWindowsToast) != "O" or isnull( this.NotificacionWindowsToast) ) and !this.lDestroy
			this.NotificacionWindowsToast = this.CrearObjetoServicios( "WindowsToastNotification" )
			this.AgregarControlDeServicio( this.NotificacionWindowsToast)
		endif
		return this.NotificacionWindowsToast
	endfunc
			
	*-----------------------------------------------------------------------------------------
	function WebHook_Access() as Object
		if ( vartype( this.WebHook ) != "O" or isnull( this.WebHook ) ) and !this.lDestroy
			this.WebHook = this.CrearObjetoServicios( "ManagerWebHook" )
			this.AgregarControlDeServicio( this.WebHook )
		endif
		return this.WebHook
	endfunc
			
	*-----------------------------------------------------------------------------------------
	* Este método debe ser temporal. Los servicios se deben ir pasando hacia esta clase
	*	
	function AsignarServicios() as Void
		this.Formularios = goFormularios
		this.Monitor = goMonitor
		this.Datos = goDatos
		this.Timer = goTimer
		this.Controles = goControles
		this.Modulos = goModulos
		this.Estilos = goEstilos
		this.Parametros = goParametros
		this.Registry  = goRegistry
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarControlDeServicio( toServicio as Object ) as Void
		if !( this.oColServiciosActivos.GetKey( alltrim( upper( toServicio.Class ))) > 0 )
			this.oColServiciosActivos.add( toServicio, alltrim( upper( toServicio.Class )) )
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Terminal_Access() as Object
		if ( vartype( this.Terminal ) != 'O' or isnull( this.Terminal ) ) and !this.lDestroy
			this.Terminal = this.CrearObjetoServicios( "Terminal" )
			this.AgregarControlDeServicio( this.Terminal )
		endif		
		return this.Terminal
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Modulos_Access() as Object
		if ( vartype( this.Modulos ) != 'O' or isnull( this.Modulos ) ) and !this.lDestroy
		
			local lcModulo as String, lcNombreArchivo as String
			lcNombreArchivo =  "Modulos" + _screen.zoo.app.cProyecto
			lcModulo = "Modulos"

			if file(lcNombreArchivo + ".prg") or file(lcNombreArchivo + ".fxp")
				lcModulo = lcNombreArchivo 
			endif
			this.Modulos = this.CrearObjetoServicios( lcModulo )
			this.AgregarControlDeServicio( this.Modulos )
		endif		
		return this.Modulos 
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function SaltosDeCampoYValoresSugeridos_Access() as Object
		if ( vartype( this.SaltosDeCampoYValoresSugeridos ) != 'O' or isnull( this.SaltosDeCampoYValoresSugeridos ) ) and !this.lDestroy
			this.SaltosDeCampoYValoresSugeridos = this.CrearObjetoServicios( "ServicioSaltosDeCampoYValoresSugeridos" )
			this.SaltosDeCampoYValoresSugeridos.Iniciar()
			this.AgregarControlDeServicio( this.SaltosDeCampoYValoresSugeridos )
		endif		
		return this.SaltosDeCampoYValoresSugeridos
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function PersonalizacionDeEntidades_Access() as Object
		if ( vartype( this.PersonalizacionDeEntidades ) != 'O' or isnull( this.PersonalizacionDeEntidades ) ) and !this.lDestroy
			this.PersonalizacionDeEntidades = this.CrearObjetoServicios( "ServicioPersonalizacionDeEntidades" )
			this.PersonalizacionDeEntidades.Iniciar()
			this.AgregarControlDeServicio( this.PersonalizacionDeEntidades )
		endif		
		return this.PersonalizacionDeEntidades
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function PoolDeObjetos_Access() as Object
		if ( vartype( this.PoolDeObjetos ) != 'O' or isnull( this.PoolDeObjetos ) ) and !this.lDestroy
			this.PoolDeObjetos = this.CrearObjetoServicios( "ServicioPoolDeObjetos" )
			this.PoolDeObjetos.Iniciar()
			this.AgregarControlDeServicio( this.PoolDeObjetos )
		endif
		return this.PoolDeObjetos
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ServicioNotificacionEnSegundoPlano_Access() as Object
		if ( vartype( this.ServicioNotificacionEnSegundoPlano) != 'O' or isnull( this.ServicioNotificacionEnSegundoPlano) ) and !this.lDestroy
			this.ServicioNotificacionEnSegundoPlano = this.CrearObjetoServicios( "ServicioNotificacionEnSegundoPlano" )
			this.AgregarControlDeServicio( this.ServicioNotificacionEnSegundoPlano)
		endif		
		return this.ServicioNotificacionEnSegundoPlano
	endfunc

	*-----------------------------------------------------------------------------------------
	function RegistroDeActividad_Access() as Object
		if ( vartype( this.RegistroDeActividad ) != 'O' or isnull( this.RegistroDeActividad ) ) and !this.lDestroy
			this.RegistroDeActividad = this.CrearObjetoServicios( "ServicioRegistroDeActividad" )
			this.RegistroDeActividad.Iniciar()
			this.AgregarControlDeServicio( this.RegistroDeActividad )
		endif		
		return this.RegistroDeActividad
	endfunc

	*-----------------------------------------------------------------------------------------
	function MonitorSaludBasesDeDatos_Access() as Object
		if ( vartype( this.MonitorSaludBasesDeDatos ) != 'O' or isnull( this.MonitorSaludBasesDeDatos ) ) and !this.lDestroy
			this.MonitorSaludBasesDeDatos = this.CrearObjetoServicios( "ServicioMonitorSaludBasesDeDatos" )
			this.MonitorSaludBasesDeDatos.Iniciar()
			this.AgregarControlDeServicio( this.MonitorSaludBasesDeDatos )
		endif		
		return this.MonitorSaludBasesDeDatos
	endfunc

	*-----------------------------------------------------------------------------------------
	function DetenerTodosLosServiciosActivos() as Void
		local loServicio as Object, loServiciosADetener as Collection, i as Integer, lcNombreDeServicio as String
		
		loServiciosADetener = _screen.Zoo.CrearObjeto( "ZooColeccion" )
		
		for i = 1 to this.oColServiciosActivos.Count
			lcNombreDeServicio = this.oColServiciosActivos.GetKey( i )
			loServiciosADetener.Agregar( lcNombreDeServicio )
		endfor

		for each lcNombreDeServicio in loServiciosADetener foxobject
			loServicio = this.oColServiciosActivos.Item[ lcNombreDeServicio ]
			try
				loServicio.Detener()
			catch
			endtry
		endfor

	endfunc 

	*-------------------------------------------------------------------
	Function CrearObjetoServicios( tcClase as String )
		local lxRetorno as Variant
		
		if pemstatus( _screen, "zoo", 5 ) and vartype( _screen.zoo ) == "O" and ;
			pemstatus( _screen.zoo, "app", 5 ) and vartype( _screen.zoo.app ) == "O"
			&& Existe App y Zoo, podemos definir por producto.

			lxRetorno =  _screen.zoo.CrearObjetoPorProducto( tcClase )
		else
			lxRetorno = this.CrearObjeto( tcClase )
		endif
		
		return lxRetorno 
	endfunc
	
enddefine
