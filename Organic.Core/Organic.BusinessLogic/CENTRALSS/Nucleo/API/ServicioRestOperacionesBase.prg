define class ServicioRestOperacionesBase as ZooSession of ZooSession.prg

	#IF .f.
		Local this as ServicioRestOperacionesBase of ServicioRestOperacionesBase.prg
	#ENDIF

	CodigoDeRespuesta = 0
	MensajeStatus = ""
	cError = ""
	cDetallesError = ""
	
	*-----------------------------------------------------------------------------------------
	function EjecutarOperacion( tcOperacion as String, toRequest as Object, toResponse as Object ) as Void
		* Implementar en subclases
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerClaseRequest( tcOperacion as String ) as String
		* Implementar en subclases
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerClaseResponse( tcOperacion as String ) as String
		* Implementar en subclases
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function DesempaquetarRequest( toRequest as Object ) as Object
		return _Screen.DotNetBridge.ObtenerValorPropiedad( toRequest, "Request" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function DesempaquetarRespuesta( toResponse as Object ) as Object
		return _Screen.DotNetBridge.ObtenerValorPropiedad( toResponse, "Respuesta" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerNombre() as Void
		return this.Class
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function SetearAtributo( toDestino as Object, tcAtributo as String, txValor as Variant ) as Void
		local loError as Exception, loEx as Exception
		Try
			if !isnull( txValor )
				_screen.dotnetbridge.setearvalorpropiedad( toDestino, tcAtributo, txValor )
			endif
		Catch To loError
			goServicios.Errores.levantarexcepcionenmascarada( "Error aplicando atributo " + tcAtributo + " en respuesta.", loError )
		endtry 
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function SetearAtributoPorReflection( toDestino as Object, tcAtributo as String, txValor as Variant ) as Void
		local loError as Exception, loEx as Exception
		Try
			if !isnull( txValor )
				_screen.dotnetbridge.invocarmetodo( toDestino, "AsignarValorLong", toDestino, tcAtributo, txValor )
			endif
		Catch To loError
			goServicios.Errores.levantarexcepcionenmascarada( "Error aplicando atributo " + tcAtributo + " en respuesta.", loError )
		endtry 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearAtributoString( toDestino as Object, tcAtributo as String, tcValor as String  ) as Void
		local lcValor as String
		local loError as Exception, loEx as Exception
		Try
			lcValor = rtrim( tcValor )
			this.SetearAtributo( toDestino, tcAtributo, lcValor )
		Catch To loError
			goServicios.Errores.LevantarExcepcion( loError )
		endtry 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearAtributoInteger( toDestino as Object, tcAtributo as String, tnValor as Object ) as Void
		local lnValor as Integer
		local loError as Exception, loEx as Exception
		Try
			lnValor = cast( tnValor  as Integer )
			this.SetearAtributo( toDestino, tcAtributo, lnValor )
		Catch To loError
			goServicios.Errores.LevantarExcepcion( loError )
		endtry 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearAtributoDecimal( toDestino as Object, tcAtributo as String, tnValor as Object ) as Void
		local lnValor as Integer
		local loError as Exception, loEx as Exception
		Try
			lnValor = cast( tnValor  as Currency )
			this.SetearAtributo( toDestino, tcAtributo, lnValor )
		Catch To loError
			goServicios.Errores.LevantarExcepcion( loError )
		endtry 
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function SetearAtributoLong( toDestino as Object, tcAtributo as String, tnValor as Object ) as Void
		local lcValor as Integer
		local loError as Exception, loEx as Exception
		Try
			lcValor = transform( int( tnValor ) )
			this.SetearAtributoPorReflection( toDestino, tcAtributo, lcValor )
		Catch To loError
			goServicios.Errores.LevantarExcepcion( loError )
		endtry 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearAtributoDatetime( toDestino as Object, tcAtributo as String, tdValor as Date ) as Void
		local ldValor as DateTime
		local loError as Exception, loEx as Exception
		Try
			ldValor = dtot( tdValor )
			if !empty( ldValor )
				this.SetearAtributo( toDestino, tcAtributo, ldValor )
			endif
		Catch To loError
			goServicios.Errores.levantarexcepcionenmascarada( "Error aplicando atributo " + tcAtributo + " en respuesta.", loError )
			goServicios.Errores.LevantarExcepcion( loError )
		endtry 
	endfunc 
	
enddefine
