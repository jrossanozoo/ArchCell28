define class ManagerEntidades as Servicio of Servicio.prg

	#IF .f.
		Local this as ManagerEntidades of ManagerEntidades.prg
	#ENDIF	
	
	protected oDatosDeEntidades
	AccionesAutomaticas = null
	oDatosDeEntidades = null
	
	*-----------------------------------------------------------------------------------------
	function AccionesAutomaticas_Access() as Object
		if !this.lDestroy and ( type( "this.AccionesAutomaticas" ) != 'O' or isnull( this.AccionesAutomaticas ) ) 
			this.AccionesAutomaticas = _Screen.zoo.CrearObjeto( "ManagerAccionesAutomaticas" )
		endif
		return this.AccionesAutomaticas
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function oDatosDeEntidades_Access() as Object
		if !this.lDestroy and ( type( "this.oDatosDeEntidades" ) != 'O' or isnull( this.oDatosDeEntidades) ) 
			this.oDatosDeEntidades= _Screen.zoo.CrearObjeto( "Din_DatosDeEntidades" )
		endif
		return this.oDatosDeEntidades
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerIdentificadorDeEntidad( tcEntidad as String ) as String
		return this.oDatosDeEntidades.ObtenerIdentificadorDeEntidad( tcEntidad )
	endfunc 
	
enddefine
