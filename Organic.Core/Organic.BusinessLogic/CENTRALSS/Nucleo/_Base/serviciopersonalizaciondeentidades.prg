define class ServicioPersonalizacionDeEntidades as Servicio Of Servicio.prg

	#If .F.
		Local This As ServicioPersonalizacionDeEntidades As ServicioPersonalizacionDeEntidades.prg
	#Endif

	oColComportamientoEntidadesPersonalizadas = null
	
	*-----------------------------------------------------------------------------------------
	function oColComportamientoEntidadesPersonalizadas_Access() as ZooColeccion of ZooColeccion.prg
		if !this.lDestroy and vartype( this.oColComportamientoEntidadesPersonalizadas ) # "O"
			this.oColComportamientoEntidadesPersonalizadas = _screen.Zoo.CrearObjeto( "ZooColeccion" )
		endif
		return this.oColComportamientoEntidadesPersonalizadas
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerColeccionEtiquetasPersonalizadas() as Object
		return this.oColComportamientoEntidadesPersonalizadas
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerEntidadesAOcultar() as Object
		return _screen.zoo.CrearObjeto( "ZooColeccion" )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerDenominacionSingularDeEntidad( tcEntidad as String ) as String
		return ""
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerDenominacionPluralDeEntidad( tcEntidad as String ) as String
		return ""
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerDenominacionCortaDeEntidad( tcEntidad as String ) as String
		return ""
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerColeccionAtributosInvisibles( tcEntidad as String ) as Object
		return _screen.zoo.CrearObjeto( "ZooColeccion" )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerColeccionComportamientoDeEtiquetasPersonalizadas( tcEntidad as string ) as Object
		return _screen.zoo.CrearObjeto( "ZooColeccion" )
	endfunc

enddefine

