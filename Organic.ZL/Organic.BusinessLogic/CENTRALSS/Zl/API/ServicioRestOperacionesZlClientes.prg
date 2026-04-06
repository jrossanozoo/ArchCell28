define class ServicioRestOperacionesZlClientes as ServicioRestOperacionesEntidad of ServicioRestOperacionesEntidad.prg

	cEntidad = "ZlClientes"

	*-----------------------------------------------------------------------------------------
	protected function ObtenerClavePrimariaEnModeloRequest( toModeloRequest as Object ) as Variant
		return _Screen.Dotnetbridge.ObtenerValorPropiedad( toModeloRequest, "Codigo" )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function SetearClavePrimaria( toEntidad as Object, txValor as Variant ) as Void
		toEntidad.Codigo = txValor 
	endfunc

	*-----------------------------------------------------------------------------------------
	function EjecutarOperacion( tcOperacion as String, toRequest as Object, toResponse as Object ) as Void
		do case
			case tcOperacion == "ObtenerCodigoDeClienteParaZnube"
				this.ObtenerCodigoDeClienteParaZnube( toRequest, toResponse )
		endcase
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerClaseRequest( tcOperacion as String ) as String
		local lcRetorno as String

		do case
			case tcOperacion == "ObtenerCodigoDeClienteParaZnube"
				lcRetorno = "ZooLogicSA.OrganicServiciosREST.DTO.Base.MostrarBase"
		endcase

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerClaseResponse( tcOperacion as String ) as String
		local lcRetorno as String

		do case
			case tcOperacion == "ObtenerCodigoDeClienteParaZnube"
				lcRetorno = "ZooLogicSA.OrganicServiciosREST.Zl.DTO.ServiciosAlCliente.ObtenerCodigoDeClienteParaZnube"
		endcase

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerCodigoDeClienteParaZnube( toRequest as Object, toResponse as Object ) as Void
		local  lcId as String, lcCursor as String, loRecursoEnRequest  as Object, loRespuesta  as Object ,;
				loResultadosResponse  as Object, loElementoResponse as Object, loError as Object, lcUsuario as String    
		
		lcUsuario = 'ADMIN'
		this.VerificarSeguridad( lcUsuario, "BUSCAR" )
		loRecursoEnRequest = this.DesempaquetarRequest( toRequest )
		lcId = _Screen.DotNetBridge.ObtenerValorPropiedad( loRecursoEnRequest, "Id" )
		
		try
			lcCursor = this.EjecutarObtenerCodigoDeClienteParaZnube( lcId ) 	
			loRespuesta = _screen.DotNetBridge.ObtenerValorPropiedad( toResponse, "Respuesta" )
			scan
				_screen.DotNetBridge.SetearValorPropiedad( loRespuesta, "ClienteCodigo", alltrim( &lcCursor..Cliente ) )
				_screen.DotNetBridge.SetearValorPropiedad( loRespuesta, "EsquemaComisional", int( &lcCursor..Esquema ) )
			endscan
		catch to loError
			this.CodigoDeRespuesta = _screen.DotNetBridge.ObtenerValorEnum( "System.Net.HttpStatusCode", "NotFound" )
			throw
		endtry
	endfunc

	*-----------------------------------------------------------------------------------------
	function EjecutarObtenerCodigoDeClienteParaZnube( tcID as String ) as string
		local lcCursor as String, lcSQL as String 
		lcCursor = 'C' + sys( 2015 )
		text to lcSQL textmerge noshow
			exec [ZL].[Sp_ObtenerCodigoDeClienteParaZnube] '<<alltrim(tcID)>>'
		endtext 
		goServicios.Datos.ejecutarSQL( lcSQL, lcCursor, Set("datasession") ) 
		return lcCursor
	endfunc 

enddefine
