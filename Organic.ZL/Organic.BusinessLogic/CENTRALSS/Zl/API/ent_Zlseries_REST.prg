define class ent_Zlseries_REST as Din_EntidadZlseries_REST of Din_EntidadZlseries_REST.prg

	*-----------------------------------------------------------------------------------------
	function EjecutarOperacion( tcOperacion as String, toRequest as Object, toResponse as Object ) as Void
		do case
			case tcOperacion == "CambiarNombre"
				this.CambiarNombre( toRequest, toResponse )
			case tcOperacion == "ObtenerSeriesCliente"
				this.CambiarNombre( toRequest, toResponse )
			otherwise
				dodefault( tcOperacion, toRequest, toResponse )
		endcase
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerClaseRequest( tcOperacion as String ) as String
		local lcRetorno as String

		do case
			case tcOperacion == "CambiarNombre"
				lcRetorno = "ZooLogicSA.OrganicServiciosREST.Zl.DTO.ZlSeries.ZlSeriesRequest"
			otherwise
				lcRetorno = dodefault( tcOperacion )
		endcase

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerClaseResponse( tcOperacion as String ) as String
		local lcRetorno as String

		do case
			case tcOperacion == "CambiarNombre"
				lcRetorno = "ZooLogicSA.OrganicServiciosREST.Zl.Generados.DTO.Zlseries.ZlseriesModelo"
			otherwise
				lcRetorno = dodefault( tcOperacion )
		endcase

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function CambiarNombre( toRequest as Object, toResponse as Object ) as Void
		local loEntidad as entidad of entidad.prg, lcId as String, loClienteEnRequest as Object, loRecursoEnRequest as Object, llEncontrado as Boolean

		loRecursoEnRequest = this.DesempaquetarRequest( toRequest )
		loEntidad = _screen.Zoo.InstanciarEntidad( "ZlSeries" )
		lcId = _screen.Dotnetbridge.ObtenerValorPropiedad( loRecursoEnRequest, "Serie" )

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
				_Screen.DotNetBridge.SetearValorPropiedad( toResponse, "MensajeStatus", "Número de serie no encontrado" )
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
	function ObtenerSeriesCliente( toRequest as Object, toResponse as Object ) as Void
		local loEntidad as entidad of entidad.prg, lcId as String, loClienteEnRequest as Object, loRecursoEnRequest as Object, llEncontrado as Boolean

		loRecursoEnRequest = this.DesempaquetarRequest( toRequest )
		loEntidad = _screen.Zoo.InstanciarEntidad( "ZlSeries" )
		lcId = _screen.Dotnetbridge.ObtenerValorPropiedad( loRecursoEnRequest, "Serie" )

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
				_Screen.DotNetBridge.SetearValorPropiedad( toResponse, "MensajeStatus", "Número de serie no encontrado" )
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

enddefine
