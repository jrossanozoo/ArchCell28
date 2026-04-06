define class ServicioRestOperacionesFacturacion as ServicioRestOperacionesBase of ServicioRestOperacionesBase.prg

	*-----------------------------------------------------------------------------------------
	function EjecutarOperacion( tcOperacion as String, toRequest as Object, toResponse as Object ) as Void
		do case
			case tcOperacion == "ObtenerComprobantesPagos"
				this.ObtenerComprobantesPagos( toRequest, toResponse )
		endcase
		do case
			case tcOperacion == "ObtenerDeudas"
				this.ObtenerDeudas( toRequest, toResponse )
		endcase
		do case
			case tcOperacion == "ObtenerFacturaEstimadaCliente"
				this.ObtenerFacturaEstimadaCliente( toRequest, toResponse )
		endcase
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerClaseRequest( tcOperacion as String ) as String
		local lcRetorno as String

		do case
			case tcOperacion == "ObtenerComprobantesPagos"
				lcRetorno = "ZooLogicSA.OrganicServiciosREST.DTO.Base.MostrarBase"
		endcase

		do case
			case tcOperacion == "ObtenerDeudas"
				lcRetorno = "ZooLogicSA.OrganicServiciosREST.DTO.Base.MostrarBase"
		endcase
		
		do case
			case tcOperacion == "ObtenerFacturaEstimadaCliente"
				lcRetorno = "ZooLogicSA.OrganicServiciosREST.DTO.Base.MostrarBase"
		endcase
		
		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerClaseResponse( tcOperacion as String ) as String
		local lcRetorno as String

		do case
			case tcOperacion == "ObtenerComprobantesPagos"
				lcRetorno = "ZooLogicSA.OrganicServiciosREST.Zl.DTO.Facturacion.ObtenerComprobantesPagos"
		endcase
		
		do case
			case tcOperacion == "ObtenerDeudas"
				lcRetorno = "ZooLogicSA.OrganicServiciosREST.Zl.DTO.Facturacion.ObtenerDeudasCliente"
		endcase
		
		do case
			case tcOperacion == "ObtenerFacturaEstimadaCliente"
				lcRetorno = "ZooLogicSA.OrganicServiciosREST.Zl.DTO.Facturacion.ObtenerFacturasEstimadasCliente"
		endcase
		
		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerComprobantesPagos( toRequest as Object, toResponse as Object ) as Void
		local lcCliente as String, lcCursor as String, loRecursoEnRequest as Object, loRespuesta as Object, ;
			loResultadossResponse as Object, loElementoResponse as Object, loError as Object, lcUsuario as String

		loRecursoEnRequest = this.DesempaquetarRequest( toRequest )
		lcCliente = _Screen.DotNetBridge.ObtenerValorPropiedad( loRecursoEnRequest, "Id" )

		try
			lcCursor = this.EjecutarObtenerComprobantesPagos( lcCliente )

			* obtiene el verdadero objeto de tipo ComprobantesPagos
			loRespuesta = _screen.DotNetBridge.ObtenerValorPropiedad( toResponse, "Respuesta" )

			* Obtiene la coleccion de ComprobantesPagos
			loResultadossResponse = _Screen.DotNetBridge.ObtenerValorPropiedad( loRespuesta, "listaComprobantes" )

			scan
				* crea un objeto del tipo ComprobantesPagos
				loElementoResponse = _Screen.DotNetBridge.CrearObjeto( "ZooLogicSA.OrganicServiciosREST.Zl.DTO.Facturacion.ComprobantesPagos" )

				* Setear el valor en el nuevo objeto ComprobantesPagos
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Cliente", alltrim( &lcCursor..Cliente ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "RazonSocial", alltrim( &lcCursor..RazonSocial ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "RZDesc", alltrim( &lcCursor..RZDesc ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Numero", alltrim( &lcCursor..Numero ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Fecha", &lcCursor..Fecha )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Comprobante", alltrim( &lcCursor..Comprobante ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "CompEnc", alltrim( &lcCursor..CompEnc ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "ComprobantePDF", alltrim( &lcCursor..ComprobantePDF ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "CompEncPDF", alltrim( &lcCursor..CompEncPDF ) )

				* Agrega a la coleccion de ComprobantesPagos
				_Screen.DotNetBridge.InvocarMetodo( loResultadossResponse, "Add", loElementoResponse )
			endscan
		catch to loError
			this.CodigoDeRespuesta = _screen.DotNetBridge.ObtenerValorEnum( "System.Net.HttpStatusCode", "NotFound" )
			throw
		endtry
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerDeudas( toRequest as Object, toResponse as Object ) as Void
		local lcCliente as String, lcCursor as String, loRecursoEnRequest as Object, loRespuesta as Object, ;
			loResultadossResponse as Object, loElementoResponse as Object, loError as Object, lcUsuario as String

		loRecursoEnRequest = this.DesempaquetarRequest( toRequest )
		lcCliente = _Screen.DotNetBridge.ObtenerValorPropiedad( loRecursoEnRequest, "Id" )

		try
			lcCursor = this.EjecutarObtenerDeudas( lcCliente )

			* obtiene el verdadero objeto de tipo Deudas
			loRespuesta = _screen.DotNetBridge.ObtenerValorPropiedad( toResponse, "Respuesta" )

			* Obtiene la coleccion de Deudas
			loResultadossResponse = _Screen.DotNetBridge.ObtenerValorPropiedad( loRespuesta, "ListaDeudas" )

			scan
				* crea un objeto del tipo Deudas
				loElementoResponse = _Screen.DotNetBridge.CrearObjeto( "ZooLogicSA.OrganicServiciosREST.Zl.DTO.Facturacion.DeudaCliente" )

				* Setear el valor en el nuevo objeto Deudas
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Cliente", alltrim( &lcCursor..Cliente ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "ClienteNombre", alltrim( &lcCursor..ClienteNombre ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "RZ", alltrim( &lcCursor..RZ ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "RZDesc", alltrim( &lcCursor..RZDesc ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Deuda", &lcCursor..Deuda )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "ComprobanteNormalizado", alltrim( &lcCursor..ComprobanteNormalizado ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Fecha", &lcCursor..Fecha )			
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Tipo", alltrim( &lcCursor..Tipo ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Baja", &lcCursor..Baja )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "MedioPago", alltrim( &lcCursor..MedioPago ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "EstadoDesc", alltrim( &lcCursor..EstadoDesc ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Comprobante", alltrim( &lcCursor..Comprobante ) )

				* Agrega a la coleccion de Deudas
				_Screen.DotNetBridge.InvocarMetodo( loResultadossResponse, "Add", loElementoResponse )
			endscan
		catch to loError
			this.CodigoDeRespuesta = _screen.DotNetBridge.ObtenerValorEnum( "System.Net.HttpStatusCode", "NotFound" )
			throw
		endtry
	endfunc
	
	
	*-----------------------------------------------------------------------------------------
	function ObtenerFacturaEstimadaCliente( toRequest as Object, toResponse as Object ) as Void
		local lcCliente as String, lcCursor as String, loRecursoEnRequest as Object, loRespuesta as Object, ;
			loResultadossResponse as Object, loElementoResponse as Object, loError as Object, lcUsuario as String

		loRecursoEnRequest = this.DesempaquetarRequest( toRequest )
		lcCliente = _Screen.DotNetBridge.ObtenerValorPropiedad( loRecursoEnRequest, "Id" )

		try
			lcCursor = this.EjecutarObtenerFacturaEstimadaCliente( lcCliente )

			* obtiene el verdadero objeto de tipo facturas estimadas
			loRespuesta = _screen.DotNetBridge.ObtenerValorPropiedad( toResponse, "Respuesta" )

			* Obtiene la coleccion de facturas estimadas
			loResultadossResponse = _Screen.DotNetBridge.ObtenerValorPropiedad( loRespuesta, "listaFacturaEstimada" )

			scan
				* crea un objeto del tipo facturasestimadas
				loElementoResponse = _Screen.DotNetBridge.CrearObjeto( "ZooLogicSA.OrganicServiciosREST.Zl.DTO.Facturacion.FacturaEstimada" )

				* Setear el valor en el nuevo objeto facturas estimadas
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Comprobante", alltrim( &lcCursor..Comprobante ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "RZSocial", alltrim( &lcCursor..RZSocial ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Serie", alltrim( &lcCursor..Serie ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Puesto", alltrim( &lcCursor..Puesto ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Concepto", alltrim( &lcCursor..Concepto ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Cantidad", &lcCursor..Cantidad )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Precio", &lcCursor..Precio )			
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Monto", &lcCursor..Monto )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Descripcion", alltrim( &lcCursor..Descripcion ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Detalle", alltrim( &lcCursor..Detalle ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Articulo", alltrim( &lcCursor..Articulo ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Producto", alltrim( &lcCursor..Producto ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Cliente", alltrim( &lcCursor..Cliente ) )

				* Agrega a la coleccion de Deudas
				_Screen.DotNetBridge.InvocarMetodo( loResultadossResponse, "Add", loElementoResponse )
			endscan
		catch to loError
			this.CodigoDeRespuesta = _screen.DotNetBridge.ObtenerValorEnum( "System.Net.HttpStatusCode", "NotFound" )
			throw
		endtry
	endfunc
	
	
	*-----------------------------------------------------------------------------------------
	function EjecutarObtenerComprobantesPagos( tcCliente as String ) as string
		local lcCursor as String, lcSQL as String

		lcCursor = "C" + sys( 2015 )
		text to lcSQL textmerge noshow
			exec [ZL].[sp_zNube_ObtenerComprobantesPagos] "<<alltrim(tcCliente)>>"
		endtext
		goServicios.Datos.EjecutarSQL( lcSQL, lcCursor, set( "DataSession" ) )

		return lcCursor
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EjecutarObtenerDeudas( tcCliente as String ) as string
		local lcCursor as String, lcSQL as String

		lcCursor = "C" + sys( 2015 )
		text to lcSQL textmerge noshow
			exec [ZL].[sp_zNube_ObtenerDeudas] "<<alltrim(tcCliente)>>"
		endtext
		goServicios.Datos.EjecutarSQL( lcSQL, lcCursor, set( "DataSession" ) )

		return lcCursor
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EjecutarObtenerFacturaEstimadaCliente( tcCliente as String ) as string
		local lcCursor as String, lcSQL as String

		lcCursor = "C" + sys( 2015 )
		text to lcSQL textmerge noshow
			exec [ZL].[sp_zNube_ObtenerFacturacionEstimadaXCliente] "<<alltrim(tcCliente)>>"
		endtext
		goServicios.Datos.EjecutarSQL( lcSQL, lcCursor, set( "DataSession" ) )

		return lcCursor
	endfunc

enddefine
