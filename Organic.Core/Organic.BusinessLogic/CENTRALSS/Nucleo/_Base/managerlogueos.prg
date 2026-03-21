define class ManagerLogueos As Servicio of Servicio.prg

	#if .f.
		local this as ManagerLogueos of ManagerLogueos.prg
	#endif

	protected lConfiguroAppenderSQLServer
	cDinConfiguracion = "Din_Logueos"
	oObjetosEntregados = null
	oRepositorios = null
	oLogger = null
	oLoggerV2 = null
	cArchivoXMLSeteo = "" 
	cCaracterDelimitador = ","
	cRespuestaNet = ""
	lConfiguroAppenderSQLServer = .f.

	*-----------------------------------------------------------------------------------------
	function Init() as VOID
		dodefault()
		
		This.InstanciarClaseNET()
		this.SetearNet()
		this.CargarRepositorios()
		This.BindearEvento( goParametros.oDatos, "CambioParametros", this, "SetearNet" )
	endfunc

	*-----------------------------------------------------------------------------------------
	function terminar() as Void
		this.oLogger.terminar()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearNet() as Void
		local lcArchivoParaLogInterno as String
		lcArchivoParaLogInterno = alltrim( _screen.zoo.cRutaInicial ) + addbs( goRegistry.Nucleo.RutaLogueoPorDefecto ) + alltrim( goRegistry.Nucleo.ArchivoParaLogueoInterno )

		if pemstatus(goParametros,"Nucleo",5) and !isnull(goParametros.Nucleo) and goParametros.Nucleo.Logueos.HabilitarLogueoInterno
			this.oLogger.ActivarLogInterno( lcArchivoParaLogInterno )
		else
			this.oLogger.DesactivarLogInterno( lcArchivoParaLogInterno )
		endif

		this.cArchivoXMLSeteo = this.ObtenerXmlLogueos()
		this.oLogger.setear( this.cArchivoXMLSeteo )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerXmlLogueos() as String
		local lcXml as String, lcArchivoXmlDestino as String, lnIntentos as Integer

		lcArchivoXmlDestino = addbs( _screen.zoo.Obtenerrutatemporal()) + "XmlLogueos.xml"
		lcXml = this.ObtenerContenidoDelArchivoDin_Logueos()
		
		* Reemplazo los parametros y variables que estan entre |@variable@|
		lcOldTextMerge = set("Textmerge")
		set textmerge On
		lnIntentos = 0
		do while "|@" $ lcXml and "@|" $ lcXml and lnIntentos < 5
			lnIntentos = lnIntentos + 1 
			lcXml = textmerge( lcXml, .F., "|@", "@|" )
		enddo
		set textmerge &lcOldTextMerge		
		
		strtofile( lcXml, lcArchivoXmlDestino )

		return lcArchivoXmlDestino 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerContenidoDelArchivoDin_Logueos() as string
		local lcRetorno as String, lcArchivoXML as String
		lcArchivoXML = addbs( _screen.zoo.cRutaInicial + "GENERADOS\" ) + alltrim( This.cDinConfiguracion ) + "SqlServer.xml"
		lcRetorno = filetostr( lcArchivoXML )
		lcRetorno = this.ReemplazarStringConnection( lcRetorno )
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ReemplazarStringConnection( tcXml as String ) as string
		local lcStringConecion as String, loDatos as ServicioDatos of ServicioDatos.prg, lcRetorno as string
		loDatos = null
		lcRetorno = tcXml 
		if type( "goServicios.Datos" ) = "O" and !isnull( goServicios.Datos )
			loDatos = goServicios.Datos
		else
			if type( "goDatos" ) = "O" and !isnull( goDatos )
				loDatos = goDatos
			endif
		endif
		
		if !isnull( loDatos ) and vartype( loDatos ) == "O"
			lcStringConecion = loDatos.oManagerConexionASql.ObtenerCadenaConexionNet()
			lcRetorno = strtran( tcXml, "[{STRINGCONNECTIONSQLSERVER}]", alltrim( lcStringConecion ))
			this.lConfiguroAppenderSQLServer = .t.
			loDatos = null
		endif
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function InstanciarClaseNET() as Void
		this.oLogger = _screen.DotNetBridge.CrearObjeto( "ZooLogicSA.Core.ManagerLogueo" )
		this.oLogger.RutaLogueo = _screen.zoo.cRutaInicial

		this.InstanciarLogueoNet()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Destroy() as Void

		if type( "this.oRepositorios" ) = "O" and !isnull( this.oRepositorios )
			this.oRepositorios.Release()
		endif
		
		if type( "this.oObjetosEntregados" ) = "O" and !isnull( this.oObjetosEntregados )
			this.oObjetosEntregados.Release()
		endif

		if type( "this.oLogger" ) = "O" and !isnull( this.oLogger )
			this.oLogger = null
		endif

		if type( "this.oLoggerV2" ) = "O" and !isnull( this.oLoggerV2 )
			this.oLoggerV2 = null
		endif
		
		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CargarRepositorios() as Void
		with this
			.oObjetosEntregados = _screen.zoo.crearobjeto( 'zooColeccion' )
			.oRepositorios = _screen.zoo.crearobjeto( 'zooColeccion' )
			.ObtenerColeccionRepositorios()
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerColeccionRepositorios() as Void
		this.oRepositorios = _screen.zoo.crearobjeto( alltrim( This.cDinConfiguracion ), alltrim( This.cDinConfiguracion ) + ".prg" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerObjetoLogueo( toQuienPide as Object ) as Object
		local loObjetoLogueo as Object
		
		loObjetoLogueo = _screen.zoo.crearobjeto( "ObjetoLogueo", "ObjetoLogueo.Prg" )
		this.AsignarRepositorio( loObjetoLogueo, toQuienPide )
		This.AgregarAObjetosEntregado( loObjetoLogueo )

		return loObjetoLogueo
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AsignarRepositorio( toObjeto as objetologueo of objetologueo.prg, toQuienPide as Object )as Void
		local loClasesHerencia as zoocoleccion OF zoocoleccion.prg, lcClase as String
		
		loClasesHerencia = This.ObtenerHerencias( toQuienPide )
		
		for each lcClase in loClasesHerencia foxobject
			if this.oRepositorios.buscar( lcClase )
				toObjeto.cLogger = alltrim( this.oRepositorios.item[ lcClase ].cClave )
				exit for
			endif
		endfor
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerHerencias( toQuienPide as Object ) as zoocoleccion OF zoocoleccion.prg
		local loRetorno as zoocoleccion OF zoocoleccion.prg, lnCont as Integer
		local array laClasesDeQuienPide(1)

		loRetorno = _screen.zoo.crearobjeto( "ZooColeccion" )
		aclass( laClasesDeQuienPide, toQuienPide )

		for lnCont = 1 to alen( laClasesDeQuienPide )
			loRetorno.agregar( laClasesDeQuienPide[ lnCont ], laClasesDeQuienPide[ lnCont ] )
		endfor
		
		return loRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarAObjetosEntregado( toObjetoLogueo as Object ) as Void
		This.oObjetosEntregados.Agregar( toObjetoLogueo, alltrim( toObjetoLogueo.cIdLogueo ) )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Guardar( toObjetoLogueo as Object ) as Void
		if !this.lConfiguroAppenderSQLServer
			this.SetearNet()
		endif
		this.Bajar( toObjetoLogueo )
		This.EliminarObjetoLogueo( toObjetoLogueo )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function GuardarParcialmente( toObjetoLogueo as Object ) as Void
		this.Bajar( toObjetoLogueo )
		toObjetoLogueo.EliminarLogueos()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function Bajar( toObjetoLogueo as Object ) as Void
		local loNivel as zoocoleccion OF zoocoleccion.prg, loColeccion as zoocoleccion OF zoocoleccion.prg

		with toObjetoLogueo
			loColeccion = .ObtenerLogueos()

			for each loNivel in loColeccion foxobject
				.oInfoLog.Mensaje = This.SerializarNivel( loNivel )
				.oInfoLog.TipoLogueo = int( loNivel.item[ 1 ].TipoDeLogueo - 1 )

				this.enviarANet( toObjetoLogueo )
			endfor
		endwith

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function SerializarNivel( toNivel as zoocoleccion OF zoocoleccion.prg ) as String
		local lcRetorno as String, loItem as Object, lnI as Integer 
		lcRetorno = ""	
		&& Se saco el For each, ya que causaba un error de FOX, se soluciono poniendo el FOR.
		&& El error era "La instrucción no está permitida en modo interactivo." -DP-.
		for lnI = 1 to toNivel.Count
			lcRetorno = lcRetorno + this.SerializarDetalle( toNivel.item( lnI ) )
		endfor  

		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SerializarDetalle( toDetalle as Object ) as String
		local lcRetorno as String
		with this
			lcRetorno = .ObtenerTabuladoDetalle( toDetalle ) + ;
						.DelimitarString( toDetalle.Hora ) + ;
						.DelimitarString( toDetalle.Descripcion, .t. )
		endwith
		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerTabuladoDetalle( toDetalle as Object ) as string
		local lcTagDeNivel as String
		if toDetalle.TipoDeLogueo = 2
			lcTagDeNivel = "[" + left( This.ObtenerNombreDeNivel( toDetalle.TipoDeLogueo ), 1 ) + "] "
		else
			lcTagDeNivel = space( 4 )
		endif	
		
		return lcTagDeNivel
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function SetearCabecera( toObjetoLogueo as Object ) as String 
		local lcRetorno as String, lcNombrePC as String, lcUsuarioPC as String 

		lcNombrePC = alltrim( substr( sys( 0 ), 1, at( "#", sys( 0 ) ) - 1) )
		lcUsuarioPC = alltrim( substr( sys( 0 ), at( "#", sys( 0 ) ) + 1 ) )

		with toObjetoLogueo.oInfoLog
			.EstadoSistema = goServicios.Seguridad.nEstadoDelSistema
			.NombrePc = lcNombrePc
			.UsuarioPc = lcUsuarioPc
		endwith
		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function DelimitarString( tcString as String, tlRetornoCarro as Boolean ) as String
		return tcString + iif( tlRetornoCarro, chr( 13 ) + chr( 10 ), This.cCaracterDelimitador )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function enviarANet( toObjetoLogueo as Object ) as Void
		local lcRespuesta as String
		
		lcRespuesta = This.oLogger.Loguear( toObjetoLogueo.oInfoLog )

		this.oLoggerV2.Loguear( toObjetoLogueo.oInfoLog.Mensaje, toObjetoLogueo.oInfoLog.TipoLogueo )
				
		if !empty( lcRespuesta )
			goServicios.Errores.LevantarExcepcion( "Problemas al loguear :" + lcRespuesta )
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerNombreDeNivel( tnNivel as integer ) as String
		local lcRetorno as String
		
		do case
			case tnNivel = 1
				lcRetorno = "DEBUG"

			case tnNivel = 2
				lcRetorno = "ERROR"

			case tnNivel = 3
				lcRetorno = "FATAL"

			case tnNivel = 4
				lcRetorno = "INFO"
				
			case tnNivel = 5
				lcRetorno = "WARN"
				
			otherwise 
				lcRetorno = "INFO"
		endcase
				
		Return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function EliminarObjetoLogueo( toObjetoLogueo as objet ) as VOID

		*-- Lo elimino de la coleccion
		This.oObjetosEntregados.Quitar( toObjetoLogueo.cIdLogueo )
		
		*-- Libero el objeto Logueo
		toObjetoLogueo.Release()

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function InstanciarLogueoNet as Void
		LOCAL loExtractorValores as Object, loProveedorValores as Object, loInfoCabecera as Object, loSeccion as Object, loDatosCabecera as Object,;
			loError as Exception, loConfiguraciones as Object, lcRutaAppenders as String, lcRutaLoggers as String
		
		this.oLoggerV2 = null
		
		try
			loInfoCabecera = _Screen.Zoo.Crearobjeto( "ZooLogicSA.Core.Logueo.InformacionCabecera", "ZooLogicSA.Core.Logueo.InformacionCabecera" )
			loDatosCabecera = _Screen.Zoo.crearobjeto( "ObjetoLogueo" )
			with loInfoCabecera
				.Usuario = loDatosCabecera.oInfoLog.Usuario 
				.BaseDatos = loDatosCabecera.oInfoLog.BaseDatos 
				.Aplicacion = loDatosCabecera.oInfoLog.Aplicacion 
				.Version = loDatosCabecera.oInfoLog.Version 
				.Serie = loDatosCabecera.oInfoLog.Serie 
				.EstadoSistema = loDatosCabecera.oInfoLog.EstadoSistema 
				.OrigenLogueo = loDatosCabecera.oInfoLog.OrigenLogueo 
			endwith
			
			loConfiguraciones = _Screen.Zoo.CrearObjeto( "ZooLogicSA.Core.Configuraciones.Configuraciones", "ZooLogicSA.Core.Configuraciones.Configuraciones" )
			loExtractorValores = _Screen.Zoo.Crearobjeto( "ZooLogicSA.Core.Configuraciones.ExtractorDeValoresXml", "ZooLogicSA.Core.Configuraciones.ExtractorDeValoresXml", loConfiguraciones.Archivo )
			loProveedorValores = _Screen.Zoo.Crearobjeto( "ZooLogicSA.Core.Configuraciones.ProveedorDeValores", "ZooLogicSA.Core.Configuraciones.ProveedorDeValores", loExtractorValores )			
			loSeccion = _Screen.Zoo.Crearobjeto( "ZooLogicSA.Core.Configuraciones.Secciones.SeccionLogueos", "ZooLogicSA.Core.Configuraciones.Secciones.SeccionLogueos", loProveedorValores )
			
			lcRutaAppenders = _Screen.Zoo.cRutaInicial
			lcRutaLoggers = addbs( _Screen.Zoo.cRutaInicial ) + "Generados"
			this.oLoggerV2 = _Screen.Zoo.Crearobjeto( "ZooLogicSA.Core.Logueo.Logueos", "ZooLogicSA.Core.Logueo.Logueos", loInfoCabecera, loSeccion, lcRutaAppenders, lcRutaLoggers )
		catch to loError
			goServicios.Errores.LevantarExcepcion( loError )
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Reconfigurar as Void
		this.InstanciarLogueoNet()
	endfunc 

enddefine