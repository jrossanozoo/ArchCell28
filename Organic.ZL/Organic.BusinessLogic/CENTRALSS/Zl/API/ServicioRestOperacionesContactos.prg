define class ServicioRestOperacionesContactos as ServicioRestOperacionesBase of ServicioRestOperacionesBase.prg

	*-----------------------------------------------------------------------------------------
	function EjecutarOperacion( tcOperacion as String, toRequest as Object, toResponse as Object ) as Void
		do case
			case tcOperacion == "ObtenerMailsContactos"
				this.ObtenerMailsContactos( toRequest, toResponse )
				
			case tcOperacion == "ObtenerMailsContactosEnRazonSocial"
				this.ObtenerMailsContactosEnRazonSocial( toRequest, toResponse )
		endcase
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerClaseRequest( tcOperacion as String ) as String
		local lcRetorno as String

		do case
			case tcOperacion == "ObtenerMailsContactos"
				lcRetorno = "ZooLogicSA.OrganicServiciosREST.DTO.Base.MostrarBase"
				
			case tcOperacion == "ObtenerMailsContactosEnRazonSocial"
				lcRetorno = "ZooLogicSA.OrganicServiciosREST.Zl.DTO.Contactos.ObtenerMailsContactosRazonSocialRequest"
		endcase

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerClaseResponse( tcOperacion as String ) as String
		local lcRetorno as String

		do case
			case tcOperacion == "ObtenerMailsContactos"
				lcRetorno = "ZooLogicSA.OrganicServiciosREST.Zl.DTO.Contactos.ObtenerMailsContactosRazonSocial"
				
			case tcOperacion == "ObtenerMailsContactosEnRazonSocial"
				lcRetorno = "ZooLogicSA.OrganicServiciosREST.Zl.DTO.Contactos.ObtenerMailsContactosRazonSocialResponse"
		endcase
		
		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerMailsContactos( toRequest as Object, toResponse as Object ) as Void
		local lcCliente as String,lcContacto as String, lcCursor as String, loRecursoEnRequest as Object, loRespuesta as Object, ;
			loResultadossResponse as Object, loElementoResponse as Object, loError as Object, lcUsuario as String

		loRecursoEnRequest = this.DesempaquetarRequest( toRequest )
		lcCliente = _Screen.DotNetBridge.ObtenerValorPropiedad( loRecursoEnRequest, "Id" )
		lcContacto = _Screen.DotNetBridge.ObtenerValorPropiedad( loRecursoEnRequest, "Param" )

		try
			lcCursor = this.EjecutarObtenerMailsContactoRazonSocial( lcCliente, lcContacto )

			loRespuesta = _screen.DotNetBridge.ObtenerValorPropiedad( toResponse, "Respuesta" )

			loResultadossResponse = _Screen.DotNetBridge.ObtenerValorPropiedad( loRespuesta, "listaMailsRazonesSociales" )
			
			scan
				loElementoResponse = _Screen.DotNetBridge.CrearObjeto( "ZooLogicSA.OrganicServiciosREST.Zl.DTO.Contactos.MailsRazonesSociales" )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "mail", alltrim( &lcCursor..email ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "rzCod", &lcCursor..rzCod )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "rzDesc", alltrim( &lcCursor..descrip ) )
				_Screen.DotNetBridge.InvocarMetodo( loResultadossResponse, "Add", loElementoResponse )
				
			endscan
		catch to loError
			this.CodigoDeRespuesta = _screen.DotNetBridge.ObtenerValorEnum( "System.Net.HttpStatusCode", "NotFound" )
			throw
		endtry
	endfunc

		*-----------------------------------------------------------------------------------------
	function ObtenerMailsContactosEnRazonSocial( toRequest as Object, toResponse as Object ) as Void
		local lcCliente as String, lcCodigoRazonSocial as String, lcCursor as String, loRecursoEnRequest as Object, loRespuesta as Object, ;
			loResultadossResponse as Object, loElementoResponse as Object, loError as Object, lcUsuario as String

		loRecursoEnRequest = this.DesempaquetarRequest( toRequest )
		lcCliente = _Screen.DotNetBridge.ObtenerValorPropiedad( loRecursoEnRequest, "ClienteId" )
		lcCodigoRazonSocial = _Screen.DotNetBridge.ObtenerValorPropiedad( loRecursoEnRequest, "CodigoRazonSocial" )

		try
			lcCursor = this.EjecutarObtenerMailsContactoEnRazonSocial( lcCliente, lcCodigoRazonSocial )

			loRespuesta = _screen.DotNetBridge.ObtenerValorPropiedad( toResponse, "Respuesta" )

			loResultadossResponse = _Screen.DotNetBridge.ObtenerValorPropiedad( loRespuesta, "listaMailsContacto" )
			
			scan
				loElementoResponse = _Screen.DotNetBridge.CrearObjeto( "ZooLogicSA.OrganicServiciosREST.Zl.DTO.Contactos.MailsContactosEnRazonesSociales" )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Confirmado", &lcCursor..confirmado )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "AsignadoFacturacion", &lcCursor..facturacion )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Email", alltrim( &lcCursor..email ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Contactos", alltrim( &lcCursor..contactos ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "ContactoId", alltrim( &lcCursor..contactoid ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Checked", &lcCursor..checked )
				
				_Screen.DotNetBridge.InvocarMetodo( loResultadossResponse, "Add", loElementoResponse )
				
			endscan
		catch to loError
			this.CodigoDeRespuesta = _screen.DotNetBridge.ObtenerValorEnum( "System.Net.HttpStatusCode", "NotFound" )
			throw
		endtry
	endfunc

	
	*-----------------------------------------------------------------------------------------
	function EjecutarObtenerMailsContactoRazonSocial( tcCliente as String, tCmail as string ) as string
		local lcCursor as String, lcSQL as String

		lcCursor = "C" + sys( 2015 )
		text to lcSQL textmerge noshow
			exec [ZL].[sp_zNube_ObtenerMailsRazonSocialContacto] "<<alltrim(tcCliente)>>", "<<alltrim(tCmail)>>"
		endtext
		goServicios.Datos.EjecutarSQL( lcSQL, lcCursor, set( "DataSession" ) )

		return lcCursor
	endfunc

	*-----------------------------------------------------------------------------------------
	function EjecutarObtenerMailsContactoEnRazonSocial( tcCliente as String, tcCodigoRazonSocial as String) as string
		local lcCursor as String, lcSQL as String

		lcCursor = "C" + sys( 2015 )
		text to lcSQL textmerge noshow
			exec [ZL].[sp_zNube_ObtenerMailsContactosParaRazonesSociales] "<<alltrim(tcCliente)>>", "<<alltrim(tcCodigoRazonSocial)>>"
		endtext
		goServicios.Datos.EjecutarSQL( lcSQL, lcCursor, set( "DataSession" ) )

		return lcCursor
	endfunc

enddefine
