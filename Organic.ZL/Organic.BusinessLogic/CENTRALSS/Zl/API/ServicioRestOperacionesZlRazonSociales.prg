define class ServicioRestOperacionesZlRazonSociales as ServicioRestOperacionesEntidad of ServicioRestOperacionesEntidad.prg

	cEntidad = "ZlRazonSociales"

	*-----------------------------------------------------------------------------------------
	protected function ObtenerClavePrimariaEnModeloRequest( toModeloRequest as Object ) as Variant
		return _Screen.Dotnetbridge.ObtenerValorPropiedad( toModeloRequest, "Codigo" )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function SetearClavePrimaria( toEntidad as Object, txValor as Variant ) as Void
		toEntidad.Nroserie = txValor 
	endfunc

	*-----------------------------------------------------------------------------------------
	function EjecutarOperacion( tcOperacion as String, toRequest as Object, toResponse as Object ) as Void
		do case
			case tcOperacion == "ObtenerRazonesSocialesDelCliente"
				this.ObtenerRazonesSocialesDelCliente( toRequest, toResponse )
			case tcOperacion == "ObtenerContribuyentePadronAFIPWS"
				this.ObtenerContribuyentePadronAFIPWS( toRequest, toResponse )
			case tcOperacion == "ObtenerSeriesProductosParaRazonesSocialesPorCliente"
				this.ObtenerSeriesProductosParaRazonesSocialesPorCliente( toRequest, toResponse )	
			case tcOperacion == "ReenvioMailTerminosYCondiciones"
				this.ReenvioMailTerminosYCondiciones( toRequest, toResponse )					
		endcase
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerClaseRequest( tcOperacion as String ) as String
		local lcRetorno as String

		do case
			case tcOperacion == "ObtenerRazonesSocialesDelCliente" 
				lcRetorno = "ZooLogicSA.OrganicServiciosREST.DTO.Base.MostrarBase"
			case tcOperacion == "ObtenerContribuyentePadronAFIPWS"
				lcRetorno = "ZooLogicSA.OrganicServiciosREST.DTO.Base.MostrarBase"		
			case tcOperacion == "ObtenerSeriesProductosParaRazonesSocialesPorCliente"
				lcRetorno = "ZooLogicSA.OrganicServiciosREST.DTO.Base.MostrarBase"		
			case tcOperacion == "ReenvioMailTerminosYCondiciones"
				lcRetorno = "ZooLogicSA.OrganicServiciosREST.Zl.DTO.ZlRazonSociales.ZLReenvioMailPendienteRequest"		
		endcase

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerClaseResponse( tcOperacion as String ) as String
		local lcRetorno as String

		do case
			case tcOperacion == "ObtenerRazonesSocialesDelCliente"
				lcRetorno = "ZooLogicSA.OrganicServiciosREST.Zl.DTO.ServiciosAlCliente.RazonesSocialesPorCliente"
			case tcOperacion == "ObtenerContribuyentePadronAFIPWS"
				lcRetorno = "ZooLogicSA.OrganicServiciosREST.Zl.DTO.ServiciosAlCliente.ContribuyentePadronAFIPWS"
			case tcOperacion ==  "ObtenerSeriesProductosParaRazonesSocialesPorCliente"
				lcRetorno = "ZooLogicSA.OrganicServiciosREST.Zl.DTO.ServiciosAlCliente.ZLSeriesProductosParaRazonesSocialesPorCliente"		
			case tcOperacion ==  "ReenvioMailTerminosYCondiciones"
				lcRetorno = "ZooLogicSA.OrganicServiciosREST.Zl.DTO.ZlRazonSociales.ZLReenvioMailPendienteResponse"							
		endcase

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerContribuyentePadronAFIPWS( toRequest as Object, toResponse as Object ) as Void
		local  lcCuit as String, loRecursoEnRequest  as Object, loRespuesta  as Object ,;
				loResultadossResponse  as Object, loElementoResponse as Object, loError as Object, loContribuyente as object   
		
		loRecursoEnRequest = this.DesempaquetarRequest( toRequest )
		
		try
			lcCuit = _screen.Dotnetbridge.ObtenerValorPropiedad( loRecursoEnRequest, "id" )
			loEntidad = _screen.Zoo.InstanciarEntidad( "ZlRazonSociales" )
			loContribuyente = loEntidad.ObtenerContribuyentePadronAFIPWS( lcCuit )
			loRespuesta = _screen.DotNetBridge.ObtenerValorPropiedad( toResponse, "Respuesta" )
			_screen.DotNetBridge.SetearValorPropiedad( loRespuesta, "Descripcion", loContribuyente.Descripcion )
			_screen.DotNetBridge.SetearValorPropiedad( loRespuesta, "SituacionFiscal", loContribuyente.SituacionFiscal )
			_screen.DotNetBridge.SetearValorPropiedad( loRespuesta, "idSituacionFiscal", loContribuyente.idSituacionFiscal )
			_screen.DotNetBridge.SetearValorPropiedad( loRespuesta, "DomicilioFiscal", proper(nvl(loContribuyente.DomicilioFiscal, "")))
			_screen.DotNetBridge.SetearValorPropiedad( loRespuesta, "CodigoPostal", loContribuyente.CodigoPostal )
			_screen.DotNetBridge.SetearValorPropiedad( loRespuesta, "ErrorMessage", loContribuyente.MensajeError )
			_screen.DotNetBridge.SetearValorPropiedad( loRespuesta, "Localidad",  proper(nvl(loContribuyente.Localidad, "")))
			_screen.DotNetBridge.SetearValorPropiedad( loRespuesta, "idProvincia", padl(loContribuyente.idProvincia,2, "0") )
			_screen.DotNetBridge.SetearValorPropiedad( loRespuesta, "Provincia", proper(nvl(loContribuyente.Provincia, "")))


		catch to loError
			this.CodigoDeRespuesta = _screen.DotNetBridge.ObtenerValorEnum( "System.Net.HttpStatusCode", "NotFound" )
			throw
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerRazonesSocialesDelCliente( toRequest as Object, toResponse as Object ) as Void
		local  lcId as String, lcCursor as String, loRecursoEnRequest  as Object, loRespuesta  as Object ,;
				loResultadossResponse  as Object, loElementoResponse as Object, loError as Object, lcUsuario as String    
		
		lcUsuario = 'ADMIN'
		this.VerificarSeguridad( lcUsuario, "BUSCAR" )
		loRecursoEnRequest = this.DesempaquetarRequest( toRequest )
		lcId = _Screen.DotNetBridge.ObtenerValorPropiedad( loRecursoEnRequest, "Id" )
		
		try
			lcCursor = this.EjecutarConsultaObtenerRazonesSociales( lcId ) 	
			
			
			** aca cargas la respuesta 
			
			* obtiene el verdadero objeto de tipo SeriesPorCliente
			loRespuesta = _screen.DotNetBridge.ObtenerValorPropiedad( toResponse, "Respuesta" )

			* Obtiene la coleccion de series
			loResultadossResponse = _Screen.DotNetBridge.ObtenerValorPropiedad( loRespuesta, "RazonesSociales" )

			scan
				
				* crea un objeto del tipo Serie
				loElementoResponse = _Screen.DotNetBridge.CrearObjeto( "ZooLogicSA.OrganicServiciosREST.Zl.DTO.ServiciosAlCliente.RazonSocial" )
				
				* Setear el valor en el nuevo objeto serie
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Codigo", alltrim( &lcCursor..Codigo ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Descripcion", alltrim( &lcCursor..Descripcion ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Cliente", alltrim( &lcCursor..Cliente ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "SituacionFiscal", alltrim( &lcCursor..SituacionFiscal ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Cuit", alltrim( &lcCursor..CUIT ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Direccion", alltrim( &lcCursor..Direccion ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "CBU", alltrim( &lcCursor..CBU ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Zadsfw", alltrim( nvl(&lcCursor..ZADSFW,"") ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "FormaDePago", alltrim( &lcCursor..FormaDePago ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Facturable", &lcCursor..Facturable )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "TieneMailsPendientes", &lcCursor..TieneMailsPendientes )
				* Agrega a la coleccion de series
				_Screen.DotNetBridge.InvocarMetodo( loResultadossResponse, "Add", loElementoResponse )
			endscan
		
		catch to loError
			this.CodigoDeRespuesta = _screen.DotNetBridge.ObtenerValorEnum( "System.Net.HttpStatusCode", "NotFound" )
			throw
		endtry
		
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerSeriesProductosParaRazonesSocialesPorCliente( toRequest as Object, toResponse as Object ) as Void
		local  lcId as String, lcCursor as String, loRecursoEnRequest  as Object, loRespuesta  as Object ,;
				loResultadossResponse  as Object, loElementoResponse as Object, loError as Object, lcUsuario as String    
		
		lcUsuario = 'ADMIN'
		this.VerificarSeguridad( lcUsuario, "BUSCAR" )
		loRecursoEnRequest = this.DesempaquetarRequest( toRequest )
		lcId = _Screen.DotNetBridge.ObtenerValorPropiedad( loRecursoEnRequest, "Id" )
		
		try
			lcCursor = this.EjecutarConsultaObtenerSeriesConRazonesSocialesPorCliente( lcId ) 	
			
			
			** aca cargas la respuesta 
			
			* obtiene el verdadero objeto de tipo SeriesPorCliente
			loRespuesta = _screen.DotNetBridge.ObtenerValorPropiedad( toResponse, "Respuesta" )

			* Obtiene la coleccion de SeriesProductos Para Razones Sociales
			loResultadossResponse = _Screen.DotNetBridge.ObtenerValorPropiedad( loRespuesta, "SeriesProductos" )

			scan
				
				* crea un objeto del tipo Serie
				loElementoResponse = _Screen.DotNetBridge.CrearObjeto( "ZooLogicSA.OrganicServiciosREST.Zl.DTO.ServiciosAlCliente.ZLSerieProductos" )
				
				* Setear el valor en el nuevo objeto serie
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "NroSerie", alltrim( &lcCursor..NroSerie ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Clave", alltrim( &lcCursor..Clave ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "NombrePuesto", alltrim( &lcCursor..NombrePuesto ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Direcc", alltrim( &lcCursor..Direcc ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "RazonesSociales", alltrim( &lcCursor..RazonesSociales ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "DireccionCompleta", alltrim( &lcCursor..DireccionCompleta ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Ambito", alltrim( &lcCursor..Ambito ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "PRODUCTOZOOLOGIC", alltrim( nvl(&lcCursor..PRODUCTOZOOLOGIC,"") ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Zadsfw", &lcCursor..Zadsfw )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Baja", &lcCursor..Baja )
				* Agrega a la coleccion de series
				_Screen.DotNetBridge.InvocarMetodo( loResultadossResponse, "Add", loElementoResponse )
			endscan
		
		catch to loError
			this.CodigoDeRespuesta = _screen.DotNetBridge.ObtenerValorEnum( "System.Net.HttpStatusCode", "NotFound" )
			throw
		endtry
		
	endfunc

	*-----------------------------------------------------------------------------------------
	function ReenvioMailTerminosYCondiciones( toRequest as Object, toResponse as Object ) as Void
		local  lcMail as String, lcCuit as String,lcCursor as String, loRecursoEnRequest  as Object, loRespuesta  as Object ,;
				loResultadossResponse  as Object, loElementoResponse as Object, loError as Object, lcUsuario as String    
		
		lcUsuario = 'ADMIN'
		this.VerificarSeguridad( lcUsuario, "BUSCAR" )
		loRecursoEnRequest = this.DesempaquetarRequest( toRequest )
		lcMail = _Screen.DotNetBridge.ObtenerValorPropiedad( loRecursoEnRequest, "Email" )
		lcCuit = _Screen.DotNetBridge.ObtenerValorPropiedad( loRecursoEnRequest, "Cuit" )
		
		try
			lcCursor = this.EjecutarReenvioMail( lcMail, lcCuit ) 	
			
			loRespuesta = _screen.DotNetBridge.ObtenerValorPropiedad( toResponse, "Respuesta" )

			_screen.DotNetBridge.SetearValorPropiedad( loRespuesta, "Resultado", .T. )
		
		catch to loError
			this.CodigoDeRespuesta = _screen.DotNetBridge.ObtenerValorEnum( "System.Net.HttpStatusCode", "NotFound" )
			throw
		endtry
		
	endfunc

	*-----------------------------------------------------------------------------------------	
	function EjecutarConsultaObtenerSeriesConRazonesSocialesPorCliente( tcID as String ) as string
		local lcCursor as String, lcSQL as String 
		lcCursor = 'C' + sys( 2015 )
		text to lcSQL textmerge noshow
			exec [ZL].[Sp_ObtenerSeriesConRazonesSocialesPorCliente] '<<alltrim(tcID)>>'
		endtext 
		goServicios.Datos.ejecutarSQL( lcSQL, lcCursor, Set("datasession") ) 
		return lcCursor
	endfunc 
	
	*-----------------------------------------------------------------------------------------	
	function EjecutarReenvioMail( tcMail as String, tcCuit as  string) as string
		local lcCursor as String, lcSQL as String 
		lcCursor = 'C' + sys( 2015 )
		text to lcSQL textmerge noshow
			exec [ZL].[sp_zNube_MailsAConfirmar_Reenviar] '<<alltrim(tcMail)>>', '<<alltrim(tcCuit)>>', ''
		endtext 
		goServicios.Datos.ejecutarSQL( lcSQL, lcCursor, Set("datasession") ) 
		return lcCursor
	endfunc 
	
		*-----------------------------------------------------------------------------------------	
	function EjecutarConsultaObtenerRazonesSociales( tcID as String ) as string
		local lcCursor as String, lcSQL as String 
		lcCursor = 'C' + sys( 2015 )
		text to lcSQL textmerge noshow
			exec [ZL].[Sp_ObtenerRazonesSocialesPorCliente] '<<alltrim(tcID)>>'
		endtext 
		goServicios.Datos.ejecutarSQL( lcSQL, lcCursor, Set("datasession") ) 
		return lcCursor
	endfunc 
	
enddefine
