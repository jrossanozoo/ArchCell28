define class LanzadorDeConsulta as Custom

	#if .f.
		local this as LanzadorDeConsulta of LanzadorDeConsulta.prg
	#endif

	oColIdAccesoConsultas = null
	
	*-----------------------------------------------------------------------------------------
	function Procesar( tcIdFormulario as String ) as Void
		local lcExe as String, lcArchivoDeParametros as String, ;
		loConfiguracionDeConsultaFactory as Object, loConfiguracionDeConsulta as Object, loConfiguracion as Object
		
		*Se chequea la seguridad de las consultas para saber si puede o no acceder a las mismas.
		if !This.TienePermisosParaUsarLasConsultas( tcIdFormulario )
			goServicios.Mensajes.Alertar( "El usuario no tiene permitido el acceso a la consulta seleccionada." )
			return .F.
		endif

		loConfiguracionDeConsultaFactory = _screen.zoo.crearobjeto( "ConfiguracionDeConsultaFactory" )
		loConfiguracionDeConsulta = loConfiguracionDeConsultaFactory.ObtenerObjetoConfiguracion()

		loConfiguracion = loConfiguracionDeConsulta.ObtenerConfiguracion( tcIdFormulario )

		loConfiguracionDeConsulta = null
		
		lcArchivoDeParametros = _screen.zoo.ObtenerRutaTemporal() + sys( 2015 ) + ".xml" 
	
		this.GrabarConfiguracionEnDisco( loConfiguracion, lcArchivoDeParametros )

		lcArchivoDeParametros = ["] + lcArchivoDeParametros + ["]
		lcExe = _screen.zoo.cRutaInicial + "bin\zoologicsa.buscador.lanzador.exe" 
		
		this.EjecutarApp( lcExe, lcArchivoDeParametros )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function GrabarConfiguracionEnDisco( toConfigurador as Object, tcArchivo as String ) as Void
		toConfigurador.GrabarSerializado( tcArchivo )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EjecutarApp( tcExe as string, tcArchivoParametros as String ) as Void
		goServicios.Ejecucion.EjecutarAplicacion( tcExe, tcArchivoParametros , .T., .T. )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function TienePermisosParaUsarLasConsultas( tcIdFormulario as String ) as Boolean
		local llRetorno as Boolean
		llRetorno = .F.
		
		if This.oColIdAccesoConsultas.Buscar( tcIdFormulario )
			lcIdSeguridad = This.oColIdAccesoConsultas.Item( tcIdFormulario )
			llRetorno = goServicios.Seguridad.PedirAccesoMenu( lcIdSeguridad, .F. )
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function oColIdAccesoConsultas_Access() as Variant
		This.oColIdAccesoConsultas = _Screen.zoo.CrearObjeto( "ZooColeccion", "ZooColeccion.prg" )
		This.oColIdAccesoConsultas.Agregar( "IT_2040", "2" ) && Consulta de stock
		This.oColIdAccesoConsultas.Agregar( "IT_2036", "1" ) && Consulta de stock y precios
		This.oColIdAccesoConsultas.Agregar( "IT_9860", "101" ) && Consulta entre locales
		This.oColIdAccesoConsultas.Agregar( "IT_2043", "3" ) && Consulta de consumos y limites vigentes de clientes
		This.oColIdAccesoConsultas.Agregar( "IT_9901", "5" ) && Consulta de deuda de clientes
		This.oColIdAccesoConsultas.Agregar( "IT_10500", "6" ) && Consulta de deuda de proveedores

		return this.oColIdAccesoConsultas
	endfunc 

	
enddefine
