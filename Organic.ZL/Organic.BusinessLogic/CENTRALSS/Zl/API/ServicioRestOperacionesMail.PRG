define class ServicioRestOperacionesMail as ServicioRestOperacionesEntidad of ServicioRestOperacionesEntidad.prg

	cEntidad = "Mail"

	*-----------------------------------------------------------------------------------------
	protected function ObtenerClavePrimariaEnModeloRequest( toModeloRequest as Object ) as Variant
		return _Screen.Dotnetbridge.ObtenerValorPropiedad( toModeloRequest, "Id" )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function SetearClavePrimaria( toEntidad as Object, txValor as Variant ) as Void
		toEntidad.email = txValor 
	endfunc

	*-----------------------------------------------------------------------------------------
	function EjecutarOperacion( tcOperacion as String, toRequest as Object, toResponse as Object ) as Void
		do case
			case tcOperacion == "DesvincularMail"
				this.DesvincularMail( toRequest, toResponse )
		endcase
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerClaseRequest( tcOperacion as String ) as String
		local lcRetorno as String
		do case
			case tcOperacion == "DesvincularMail"  
				lcRetorno = "ZooLogicSA.OrganicServiciosREST.DTO.Base.MostrarBase"
		endcase
		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerClaseResponse( tcOperacion as String ) as String
		local lcRetorno as String

		do case
			case tcOperacion == "DesvincularMail" 
				lcRetorno = "ZooLogicSA.OrganicServiciosREST.Zl.DTO.RespuestasGenericas.ObtenerRespuestaBool"
		endcase

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function DesvincularMail( toRequest as Object, toResponse as Object ) as Void
		local loEntidad as entidad OF entidad.prg, lcId as String, loClienteEnRequest as Object, loRecursoEnRequest as Object, llEncontrado as Boolean, ;
			lcUsuario AS String, lcUserZnube as String, lcRetorno as String

		lcUsuario = 'ZNUBE'
		this.VerificarSeguridad( lcUsuario, "BUSCAR" )		
		loRecursoEnRequest = this.DesempaquetarRequest( toRequest )
		loEntidad = _screen.Zoo.InstanciarEntidad( "Mail" )
		lcRetorno = this.ObtenerClavePrimariaEnModeloRequest( loRecursoEnRequest )
		lcId = alltrim( substr( lcRetorno, 1, at( ",", lcRetorno ) - 1 ) )
		lcUserZnube = alltrim( substr( lcRetorno, at( ",", lcRetorno ) + 1, len( lcRetorno ) ) )
		
		try
			try				
				this.SetearClavePrimaria( loEntidad, lcId )
				llEncontrado = .t.
			catch to loError
				llEncontrado = .f.
			endtry

			loEntidad.CambiarEstadoActivacion( '0', lcUserZnube )
			this.CargarObjetoMailResponse( toResponse )
		catch
			if this.CodigoDeRespuesta < 400
				this.CodigoDeRespuesta = _screen.DotNetBridge.ObtenerValorEnum( "System.Net.HttpStatusCode", "BadRequest" ) 
			endif
			throw
		finally
		endtry
	endfunc

	*-----------------------------------------------------------------------------------------
	function CargarObjetoMailResponse( toResponse ) as Void
		local loRespuesta as objet, loResultadossResponse  as Object 
		loRespuesta = _screen.DotNetBridge.ObtenerValorPropiedad( toResponse, "Respuesta" )
		_screen.DotNetBridge.SetearValorPropiedad( loRespuesta, "Respuesta", .T. )

	endfunc 

enddefine
