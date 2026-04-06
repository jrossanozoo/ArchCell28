define class ent_ZlRazonSociales_REST as Din_EntidadZlRazonSociales_REST of Din_EntidadZlRazonSociales_REST.prg

	*-----------------------------------------------------------------------------------------
	function EjecutarOperacion( tcOperacion as String, toRequest as Object, toResponse as Object ) as Void
		do case
			case tcOperacion == "ObtenerRazonesSocialesDelCliente"
				this.ObtenerRazonesSocialesDelCliente( toRequest, toResponse )
			case tcOperacion == "ObtenerContribuyentePadronAFIPWS"
				this.ObtenerContribuyentePadronAFIPWS( toRequest, toResponse )
			otherwise
				dodefault( tcOperacion, toRequest, toResponse )
		endcase
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerRazonesSocialesDelCliente( toRequest as Object, toResponse as Object ) as Void
		local loEntidad as entidad of entidad.prg, lcId as String, loClienteEnRequest as Object, loRecursoEnRequest as Object, llEncontrado as Boolean

		loRecursoEnRequest = this.DesempaquetarRequest( toRequest )
		loEntidad = _screen.Zoo.InstanciarEntidad( "ZlRazonSociales" )
		lcId = _screen.Dotnetbridge.ObtenerValorPropiedad( loRecursoEnRequest, "RazonSocial" )

		try
			try
				this.SetearClavePrimaria( loEntidad, lcId )
				llEncontrado = .t.
			catch to loError
				llEncontrado = .f.
			endtry

			lcUsuario = _screen.DotNetBridge.ObtenerValorPropiedad( toRequest, "UsuarioOrganic" )
			if llEncontrado
				this.VerificarSeguridad( lcUsuario, "MODIFICAR" )
				loEntidad.Modificar()
				this.SetearAtributoModeloEnEntidad( loRecursoEnRequest, "Nombre", loEntidad, "Nombre" )
				loEntidad.Grabar()
			else
				this.CodigoDeRespuesta = _screen.DotNetBridge.ObtenerValorEnum( "System.Net.HttpStatusCode", "NotFound" )
				_Screen.DotNetBridge.SetearValorPropiedad( toResponse, "MensajeStatus", "Número de razón social no encontrado" )
			endif
		catch
			if this.CodigoDeRespuesta < 400
				this.CodigoDeRespuesta = _screen.DotNetBridge.ObtenerValorEnum( "System.Net.HttpStatusCode", "BadRequest" )
			endif
			throw
		finally
			if loEntidad.EsEdicion()
				loEntidad.Cancelar()
			endif
		endtry
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerContribuyentePadronAFIPWS() as Void

	endfunc 

enddefine
