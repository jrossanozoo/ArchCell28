define class ServicioRestOperacionesZlSeries as ServicioRestOperacionesEntidad of ServicioRestOperacionesEntidad.prg

	cEntidad = "Zlseries"

	*-----------------------------------------------------------------------------------------
	protected function ObtenerClavePrimariaEnModeloRequest( toModeloRequest as Object ) as Variant
		return _Screen.Dotnetbridge.ObtenerValorPropiedad( toModeloRequest, "Nroserie" )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function SetearClavePrimaria( toEntidad as Object, txValor as Variant ) as Void
		toEntidad.Nroserie = txValor 
	endfunc

	*-----------------------------------------------------------------------------------------
	function EjecutarOperacion( tcOperacion as String, toRequest as Object, toResponse as Object ) as Void
		do case
			case tcOperacion == "CambiarNombre"
				this.CambiarNombre( toRequest, toResponse )
			case tcOperacion == "ObtenerSeriesCliente"
				this.ObtenerSeriesCliente( toRequest, toResponse )
			case tcOperacion == "ObtenerArticulosPorRazonSocialYProducto"	
				this.ObtenerArticulosPorRazonsocialYProducto( toRequest, toResponse )
			case tcOperacion == "ObtenerArticulosPorSerie"	
				this.ObtenerArticulosPorSerie( toRequest, toResponse )
			case tcOperacion == "ObtenerArticulosPorSerieParaModificar"
				this.ObtenerArticulosPorSerieParaModificar( toRequest, toResponse )
			case tcOperacion == "ObtenerRazonSocialxSeriexCliente"
				this.ObtenerRazonSocialxSeriexCliente( toRequest, toResponse )
		endcase
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerClaseRequest( tcOperacion as String ) as String
		local lcRetorno as String

		do case
			case tcOperacion == "CambiarNombre"  
				lcRetorno = "ZooLogicSA.OrganicServiciosREST.Zl.DTO.ZlSeries.ZlSeriesRequest"
			case tcOperacion == "ObtenerSeriesCliente"
				lcRetorno = "ZooLogicSA.OrganicServiciosREST.DTO.Base.MostrarBase"
			case tcOperacion == "ObtenerArticulosPorRazonSocialYProducto"
				lcRetorno = "ZooLogicSA.OrganicServiciosREST.Zl.DTO.ZlRazonSociales.ObtenerArticulosPorRazonSocialYProducto"
			case tcOperacion == "ObtenerArticulosPorSerie"
				lcRetorno = "ZooLogicSA.OrganicServiciosREST.Zl.DTO.ZlRazonSociales.ObtenerArticulosPorSerie"
			case tcOperacion == "ObtenerArticulosPorSerieParaModificar"
				lcRetorno = "ZooLogicSA.OrganicServiciosREST.Zl.DTO.ZlSeries.ObtenerArticulosPorSerieParaModificar"
			case tcOperacion == "ObtenerRazonSocialxSeriexCliente"
				lcRetorno = "ZooLogicSA.OrganicServiciosREST.Zl.DTO.ZlRazonSociales.ObtenerRazonSocialxSeriexCliente"
		endcase

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerClaseResponse( tcOperacion as String ) as String
		local lcRetorno as String

		do case
			case tcOperacion == "CambiarNombre" 
				lcRetorno = "ZooLogicSA.OrganicServiciosREST.Zl.Generados.DTO.Zlseries.ZlseriesModelo"
			case tcOperacion == "ObtenerSeriesCliente"
				lcRetorno = "ZooLogicSA.OrganicServiciosREST.Zl.DTO.ServiciosAlCliente.SeriesPorCliente"
			case inlist( tcOperacion, "ObtenerArticulosPorRazonSocialYProducto", "ObtenerArticulosPorSerie", "ObtenerArticulosPorSerieParaModificar" )	
				lcRetorno = "ZooLogicSA.OrganicServiciosREST.Zl.DTO.ServiciosAlCliente.Articulos"
			case inlist( tcOperacion, "ObtenerRazonSocialxSeriexCliente" )
				lcRetorno = "ZooLogicSA.OrganicServiciosREST.Zl.DTO.ServiciosAlCliente.RazonSocialxSeriexCliente"
		endcase

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function CambiarNombre( toRequest as Object, toResponse as Object ) as Void
		local loEntidad as entidad OF entidad.prg, lcId as String, loClienteEnRequest as Object, loRecursoEnRequest as Object, llEncontrado as Boolean, ;
			lcUsuario AS String 

		loRecursoEnRequest = this.DesempaquetarRequest( toRequest )
		loEntidad = _screen.Zoo.InstanciarEntidad( "ZlSeries" )
		lcId = this.ObtenerClavePrimariaEnModeloRequest( loRecursoEnRequest )
		
		try
			try				
				this.SetearClavePrimaria( loEntidad, lcId )
				llEncontrado = .t.
			catch to loError
				llEncontrado = .f.
			endtry

			lcUsuario = _Screen.DotNetBridge.ObtenerValorPropiedad( toRequest, "UsuarioOrganic" )
		
			if llEncontrado 
				this.VerificarSeguridad( lcUsuario, "MODIFICAR" )
				loEntidad.Modificar()
			endif
		
			this.SetearEntidadConDatosModelo( loEntidad, loRecursoEnRequest )
			loEntidad.Grabar()
			this.CargarResponse( toResponse, loEntidad)
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
		local  lcId as String, lcCursor as String, loRecursoEnRequest  as Object, loRespuesta  as Object ,;
				loResultadossResponse  as Object, loElementoResponse as Object, loError as Object, lcUsuario as String    
		
		lcUsuario = 'ADMIN'
		this.VerificarSeguridad( lcUsuario, "BUSCAR" )
		loRecursoEnRequest = this.DesempaquetarRequest( toRequest )
		lcId = _Screen.DotNetBridge.ObtenerValorPropiedad( loRecursoEnRequest, "Id" )
		
		try
			lcCursor = this.EjecutarConsultaObtenerSeries( lcId ) 	
			
			
			** aca cargas la respuesta 
			
			* obtiene el verdadero objeto de tipo SeriesPorCliente
			loRespuesta = _screen.DotNetBridge.ObtenerValorPropiedad( toResponse, "Respuesta" )

			* Obtiene la coleccion de series
			loResultadossResponse = _Screen.DotNetBridge.ObtenerValorPropiedad( loRespuesta, "Series" )

			scan
				
				* crea un objeto del tipo Serie
				loElementoResponse = _Screen.DotNetBridge.CrearObjeto( "ZooLogicSA.OrganicServiciosREST.Zl.DTO.ServiciosAlCliente.Serie" )
				
				* Setear el valor en el nuevo objeto serie
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "NroSerie", alltrim( &lcCursor..NroSerie ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Clave", alltrim( goFormularios.ObtenerC( alltrim( &lcCursor..NroSerie ) ) ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "NombrePuesto", alltrim( &lcCursor..NombrePuesto ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Direcc", alltrim( &lcCursor..Direcc ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "DireccionCompleta", alltrim( &lcCursor..DireccionCompleta ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Ambito", alltrim( &lcCursor..Ambito ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "PRODUCTOZOOLOGIC", alltrim( &lcCursor..PRODUCTOZOOLOGIC ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "ProductoNombre", alltrim( &lcCursor..ProductoNombre ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Zadsfw", alltrim( nvl( &lcCursor..ZADSFW, "" ) ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Baja", alltrim( &lcCursor..Baja ) )
	
				* Agrega a la coleccion de series
				_Screen.DotNetBridge.InvocarMetodo( loResultadossResponse, "Add", loElementoResponse )
			endscan
		
		catch to loError
			this.CodigoDeRespuesta = _screen.DotNetBridge.ObtenerValorEnum( "System.Net.HttpStatusCode", "NotFound" )
			throw
		endtry
		
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EjecutarConsultaObtenerSeries( tcID as String  ) as string
		local lcCursor as String, lcSQL as String 
		lcCursor = 'C' + sys( 2015 )
		text to lcSQL textmerge noshow
			exec [ZL].[Sp_ObtenerSeriesPorCliente] '<<alltrim(tcID)>>'
		endtext 
		goServicios.Datos.ejecutarSQL( lcSQL, lcCursor, Set("datasession") ) 
		return lcCursor
	endfunc 


	*-----------------------------------------------------------------------------------------
	function ObtenerArticulosPorRazonsocialYProducto( toRequest as Object, toResponse as Object ) as Void
		local  lcRSoc as String, lcProd as string, lcCursor as String, loRecursoEnRequest  as Object, loRespuesta  as Object ,;
				loResultadossResponse  as Object, loElementoResponse as Object, loError as Object, lcUsuario as String    
		
		lcUsuario = 'ADMIN'
		this.VerificarSeguridad( lcUsuario, "BUSCAR" )
		loRecursoEnRequest = this.DesempaquetarRequest( toRequest )
	
		lcRSoc = _Screen.DotNetBridge.ObtenerValorPropiedad( loRecursoEnRequest, "RazonSocial" )
		lcProd = _Screen.DotNetBridge.ObtenerValorPropiedad( loRecursoEnRequest, "Producto" )
		
		try
			lcCursor = this.EjecutarConsultaObtenerArticulosPorRazonSocialYProducto( lcRSoc, lcProd ) 	
		
			** siempre va asì
			loRespuesta = _screen.DotNetBridge.ObtenerValorPropiedad( toResponse, "Respuesta" )
			* atributo de la clase net a donde va a cargars la lista
			loResultadossResponse = _Screen.DotNetBridge.ObtenerValorPropiedad( loRespuesta, "ListaDeArticulos" )

			scan
				* crea un objeto del tipo Serie
				loElementoResponse = _Screen.DotNetBridge.CrearObjeto( "ZooLogicSA.OrganicServiciosREST.Zl.DTO.ServiciosAlCliente.ArticuloConPrecio" )
				
				* Setear el valor en el nuevo objeto serie
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Codigo", alltrim( &lcCursor..Codigo ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Descripcion", alltrim( &lcCursor..Descripcion ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Modulos", alltrim( &lcCursor..Modulos ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "TieneModuloTI", &lcCursor..TieneModuloTI )

				*- Esta propiedad la seteo asi a manopla, xq el DotNetBridge.SetearValorPropiedad no se estaria bancando el tipo "Decimal".
				loElementoResponse.Precio = nvl(&lcCursor..Precio,0)

				* Agrega a la coleccion de series
				_Screen.DotNetBridge.InvocarMetodo( loResultadossResponse, "Add", loElementoResponse )
			endscan
		
		catch to loError
			this.CodigoDeRespuesta = _screen.DotNetBridge.ObtenerValorEnum( "System.Net.HttpStatusCode", "NotFound" )
			throw
		endtry
		
	endfunc
	*-----------------------------------------------------------------------------------------
	function EjecutarConsultaObtenerArticulosPorRazonSocialYProducto( tcID as String, tcProducto as String ) as string
		local lcCursor as String, lcSQL as String 
		lcCursor = 'C' + sys( 2015 )
		text to lcSQL textmerge noshow
			exec [ZL].[Sp_ObtenerArticulosPorRazonSocialPorProductoZNube] '<<alltrim(tcID)>>', '<<alltrim(tcProducto)>>'
		endtext 
		goServicios.Datos.ejecutarSQL( lcSQL, lcCursor, Set("datasession") ) 
		return lcCursor
	endfunc 


	*-----------------------------------------------------------------------------------------
	function ObtenerArticulosPorSerie( toRequest as Object, toResponse as Object ) as Void
		local lcNroSerie as String, lcCursor as String, loRecursoEnRequest as Object, loRespuesta as Object, loResultadossResponse as Object, ;
			loElementoResponse as Object, loError as Object, lcUsuario as String, lcCliente as String
		
		lcUsuario = 'ADMIN'
		this.VerificarSeguridad( lcUsuario, "BUSCAR" )
		loRecursoEnRequest = this.DesempaquetarRequest( toRequest )
		lcNroSerie = _Screen.DotNetBridge.ObtenerValorPropiedad( loRecursoEnRequest, "NroSerie" )
		lcCliente = _Screen.DotNetBridge.ObtenerValorPropiedad( loRecursoEnRequest, "Cliente" )
		
		try
			lcCursor = this.EjecutarConsultaObtenerArticulosPorSerie( lcNroSerie, lcCliente )
		
			** siempre va asì
			loRespuesta = _screen.DotNetBridge.ObtenerValorPropiedad( toResponse, "Respuesta" )
			* atributo de la clase net a donde va a cargars la lista
			loResultadossResponse = _Screen.DotNetBridge.ObtenerValorPropiedad( loRespuesta, "ListaDeArticulos" )

			scan
				* crea un objeto del tipo Serie
				loElementoResponse = _Screen.DotNetBridge.CrearObjeto( "ZooLogicSA.OrganicServiciosREST.Zl.DTO.ServiciosAlCliente.ArticuloConPrecio" )
				
				* Setear el valor en el nuevo objeto serie
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Codigo", alltrim( &lcCursor..Codigo ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Descripcion", alltrim( &lcCursor..Descripcion ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "ItemDeServicio", &lcCursor..ItemDeServicio )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Modulos", alltrim( &lcCursor..Modulos ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "RazonSocial", alltrim( &lcCursor..RazonSocial ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "FechaActivacion", &lcCursor..FechaActivacion )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "TieneModuloTI", &lcCursor..TieneModuloTI )
				
				*- Esta propiedad la seteo asi a manopla, xq el DotNetBridge.SetearValorPropiedad no se estaria bancando el tipo "Decimal".
				loElementoResponse.Precio = nvl(&lcCursor..Precio,0)
				
				* Agrega a la coleccion de series
				_Screen.DotNetBridge.InvocarMetodo( loResultadossResponse, "Add", loElementoResponse )
			endscan
		
		catch to loError
			this.CodigoDeRespuesta = _screen.DotNetBridge.ObtenerValorEnum( "System.Net.HttpStatusCode", "NotFound" )
			throw
		endtry
		
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EjecutarConsultaObtenerArticulosPorSerie( tcNroSerie as String, tcCliente as String ) as string
		local lcCursor as String, lcSQL as String 
		lcCursor = 'C' + sys( 2015 )
		text to lcSQL textmerge noshow

			exec [ZL].[Sp_ObtenerArticulosAsignadosPorSerieZNube] '<<alltrim(tcNroSerie)>>', '<<alltrim(tcCliente)>>'
		endtext
		goServicios.Datos.ejecutarSQL( lcSQL, lcCursor, Set("datasession") ) 
		return lcCursor
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerRazonSocialxSeriexCliente( toRequest as Object, toResponse as Object ) as Void
		local lcSerie as String, lcCliente as String, lcCursor as String, loRecursoEnRequest as Object, loRespuesta as Object, ;
			loResultadosResponse as Object, loElementoResponse as Object, loError as Object, lcUsuario as String

		lcUsuario = 'ADMIN'
		this.VerificarSeguridad( lcUsuario, "BUSCAR" )
		loRecursoEnRequest = this.DesempaquetarRequest( toRequest )
		lcSerie = _Screen.DotNetBridge.ObtenerValorPropiedad( loRecursoEnRequest, "Serie" )
		lcCliente = _Screen.DotNetBridge.ObtenerValorPropiedad( loRecursoEnRequest, "Cliente" )

		try
			lcCursor = this.EjecutarConsultaObtenerRazonSocialxSeriexCliente( lcSerie, lcCliente )
			loRespuesta = _Screen.DotNetBridge.ObtenerValorPropiedad( toResponse, "Respuesta" )
			scan
				_Screen.DotNetBridge.SetearValorPropiedad( loRespuesta, "RazonSocial", alltrim( &lcCursor..Razonsocial ) )
			endscan
		catch to loError
			this.CodigoDeRespuesta = _Screen.DotNetBridge.ObtenerValorEnum( "System.Net.HttpStatusCode", "NotFound" )
			throw
		endtry
	endfunc

	*-----------------------------------------------------------------------------------------
	function EjecutarConsultaObtenerRazonSocialxSeriexCliente( tcSerie as String, tcCliente as String ) as string
		local lcCursor as String, lcSQL as String
		lcCursor = 'C' + sys( 2015 )
		text to lcSQL textmerge noshow
			exec [ZL].[Sp_ObtenerRazonSocialxSeriexCliente] '<<alltrim(tcSerie)>>', '<<alltrim(tcCliente)>>'
		endtext
		goServicios.Datos.EjecutarSQL( lcSQL, lcCursor, set( "datasession" ) )
		return lcCursor
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerArticulosPorSerieParaModificar( toRequest as Object, toResponse as Object ) as Void
		local lcNroSerie as String, lcCursor as String, loRecursoEnRequest as Object, loRespuesta as Object, loResultadossResponse as Object, ;
			loElementoResponse as Object, loError as Object, lcUsuario as String, lcCliente as String

		lcUsuario = 'ADMIN'
		this.VerificarSeguridad( lcUsuario, "BUSCAR" )
		loRecursoEnRequest = this.DesempaquetarRequest( toRequest )
		lcNroSerie = _Screen.DotNetBridge.ObtenerValorPropiedad( loRecursoEnRequest, "NroSerie" )
		lcCliente = _Screen.DotNetBridge.ObtenerValorPropiedad( loRecursoEnRequest, "Cliente" )

		try
			lcCursor = this.EjecutarConsultaObtenerArticulosPorSerieParaModificar( lcNroSerie, lcCliente )
			** siempre va asì
			loRespuesta = _screen.DotNetBridge.ObtenerValorPropiedad( toResponse, "Respuesta" )
			* atributo de la clase net a donde va a cargars la lista
			loResultadossResponse = _Screen.DotNetBridge.ObtenerValorPropiedad( loRespuesta, "ListaDeArticulos" )

			scan
				* crea un objeto del tipo Serie
				loElementoResponse = _Screen.DotNetBridge.CrearObjeto( "ZooLogicSA.OrganicServiciosREST.Zl.DTO.ServiciosAlCliente.ArticuloConPrecio" )

				* Setear el valor en el nuevo objeto serie
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Codigo", alltrim( &lcCursor..Codigo ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Descripcion", alltrim( &lcCursor..Descripcion ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "ItemDeServicio", &lcCursor..ItemDeServicio )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Modulos", alltrim( &lcCursor..Modulos ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "RazonSocial", alltrim( &lcCursor..RazonSocial ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "NombreRZ", alltrim( &lcCursor..NombreRZ ) )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "FechaActivacion", &lcCursor..FechaActivacion )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "Checked", &lcCursor..Checked )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "SolicitudBaja", &lcCursor..SolicitudBaja )
				_screen.DotNetBridge.SetearValorPropiedad( loElementoResponse, "TieneModuloTI", &lcCursor..TieneModuloTI )

				*- Esta propiedad la seteo asi a manopla, xq el DotNetBridge.SetearValorPropiedad no se estaria bancando el tipo "Decimal".
				loElementoResponse.Precio = nvl(&lcCursor..Precio,0)

				* Agrega a la coleccion de series
				_Screen.DotNetBridge.InvocarMetodo( loResultadossResponse, "Add", loElementoResponse )
			endscan
		catch to loError
			this.CodigoDeRespuesta = _screen.DotNetBridge.ObtenerValorEnum( "System.Net.HttpStatusCode", "NotFound" )
			throw
		endtry
	endfunc

	*-----------------------------------------------------------------------------------------
	function EjecutarConsultaObtenerArticulosPorSerieParaModificar( tcNroSerie as String, tcCliente as String ) as string
		local lcCursor as String, lcSQL as String

		lcCursor = "C" + sys( 2015 )
		text to lcSQL textmerge noshow
			exec [ZL].[Sp_ObtenerArticulosPorSerieParaModificarZNube] "<<alltrim(tcNroSerie)>>", "<<alltrim(tcCliente)>>"
		endtext
		goServicios.Datos.ejecutarSQL( lcSQL, lcCursor, set( "datasession" ) )
		return lcCursor
	endfunc

enddefine
