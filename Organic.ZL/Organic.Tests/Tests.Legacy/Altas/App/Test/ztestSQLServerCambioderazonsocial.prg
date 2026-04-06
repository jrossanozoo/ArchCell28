**********************************************************************
Define Class ztestSQLServerCambioderazonsocial as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as ztestSQLServerCambioderazonsocial of ztestSQLServerCambioderazonsocial.prg
	#ENDIF
	
	cArchivoMock = ""
	cArchivoMock1= ""
	cArchivoMockZlServiciosLoteBaja = ""
	dFecha = null
	CodDireccion = ""
	
	*---------------------------------
	Function Setup
		this.CodDireccion = CrearDirecciones()
		this.CodDireccion = CrearDirecciones()
		CrearZlRrhhPuestosActivos()
		CrearFuncion_funcObtenerArticulosNoVisiblesDeCliente()
		CrearFuncion_funcObtenerArticulosNoVisiblesDeRazonSocial()
		CrearFuncion_FuncObtenerTipoUsuarioZLAD()
		CrearFuncion_funcCOMEsquemaComisionalVigentePorCliente()
		CrearFuncion_funcCOMEsquemaComisionalVigentePorRazonSocial()
		CrearSP_SP_ValidarSerieLinceClasificacionArticulo()
		CrearFuncion_func_NormalizarNombre()
		CrearFuncion_funcArticuloConModuloActivacionOnLine()
	EndFunc
	
	*---------------------------------
	Function TearDown

	EndFunc

	*-----------------------------------------------------------------------------------------
	function ztestSQLServerInstanciacion
		local loEntidad as Object
		loEntidad = _screen.zoo.instanciarentidad( "CambioDeRazonSocial" )

		this.assertequals( "No se insatnció la entidad Cambio de Razón Social", "O", vartype( loEntidad ) )
		this.asserttrue( "El detalle No tiene el atributo Serie", pemstatus( loentidad.Subitems.oItem , "Serie" , 5 ))
		this.asserttrue( "El detalle No tiene el atributo Articulo", pemstatus( loentidad.Subitems.oItem , "Articulo" , 5 ))
		this.asserttrue( "El detalle No tiene el atributo Vigencia", pemstatus( loentidad.Subitems.oItem , "FechaBajaVigencia" , 5 ))
		this.asserttrue( "El detalle No tiene el atributo ArtículoAnterior", pemstatus( loentidad.Subitems.oItem , "ArticuloAnterior" , 5 ))
		this.asserttrue( "El detalle No tiene el atributo ArtículoClasificacion", pemstatus( loentidad.Subitems.oItem , "ArticuloClasificacion" , 5 ))
		this.asserttrue( "El detalle No tiene el atributo SerieTI", pemstatus( loentidad.Subitems.oItem , "SerieTI" , 5 ))
		this.asserttrue( "El detalle No tiene el atributo Grupocom", pemstatus( loentidad.Subitems.oItem , "Grupocom" , 5 ))
		
		loEntidad.release()
		
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ztestSQLServerEfecuarCambioRazonSocial
		local loRZVieja as enttidad, loRZNueva as enttidad, loEntCambioRZ as entidad, loCliente as entidad OF entidad.prg ,;
			  loZlServiciosLote as entidad OF entidad.prg, loArticulo as entidad OF entidad.prg , loISAlta as entidad OF entidad.prg,;
			  lnNroISALTA as Integer, loProducto as Object , ldFechaBaja as Date , loTalonario as Object, loModulos as Object, lcProductoZL as String,;
			  lcModulo1 as String, lcModulo2 as String, loClasificacionCte as Object, loClasificacionv2 as Object, loContactos as Object, ;
			  loError as Exception, loEsquemaComisional as Object , loEntidad as Custom, loLibrerias as Object, loCol as zoocoleccion OF zoocoleccion.prg, ;
			  loPais as Object, loProvincia as Object
		
private gomensajes as Object
_screen.mocks.agregarmock( "Mensajes" )
_Screen.mocks.AgregarSeteoMetodo( "Mensajes", "Enviar", .T., '"No hay mas números de serie disponibles"' )
goMensajes = _Screen.zoo.crearobjeto( "Mensajes" )

		loLibrerias = goServicios.Librerias
		private goLibrerias
		goLibrerias = newobject( "LibreriasTest" )
		goServicios.Librerias = goLibrerias

		loError = null
		this.dFecha = goServicios.Librerias.ObtenerFecha()
		=CrearZlServiciosLoteBaja_Test( this )

		loCol = newobject( "zoocoleccion", "zoocoleccion.PRG" )
		try
		
			_screen.Mocks.AgregarMock( 'ZlServiciosLoteBaja', forceext( this.cArchivoMockZlServiciosLoteBaja, '' ) )

			this.agregarmocks( "ComponenteEsquemacomision,ListadePrecios,Valor,Direcciones,Actualizarzoo,estadov2,ZLASIGESTADOSRZADM, TIPOARTICULOITEMSERVICIO, ZLAMBITOSSERIE,zlaltagrupocom, TIPOMODULOS, TITULOS, LEGAJOOPS, COMMOTIVOBAJA")

			_screen.mocks.AgregarSeteoMetodo( 'MENSAJEENTIDAD', 'Advertir', .T., "[Se ha producido una excepción no controlada durante el proceso posterior a la grabación.Verifique el log de errores para mas detalles.]" ) 
			_screen.mocks.AgregarSeteoMetodo( 'COMPONENTEESQUEMACOMISION', 'Inicializar', .T. )
			_screen.mocks.AgregarSeteoMetodo( 'COMPONENTEESQUEMACOMISION', 'Votarcambioestadonuevo', .T., "[NULO]" ) 
			_screen.mocks.AgregarSeteoMetodo( 'COMPONENTEESQUEMACOMISION', 'Setearcoleccionsentenciasanterior_nuevo', .T. ) 
			_screen.mocks.AgregarSeteoMetodo( 'COMPONENTEESQUEMACOMISION', 'Votarcambioestadograbar', .T., "[NUEVO]" )
			_screen.mocks.AgregarSeteoMetodo( 'COMPONENTEESQUEMACOMISION', 'Votarcambioestadocancelar', .T., "[NUEVO]" )
			_screen.mocks.AgregarSeteoMetodo( 'COMPONENTEESQUEMACOMISION', 'Votarcambioestadonuevo', .T., "[NULO]" )
			_screen.mocks.AgregarSeteoMetodo( 'COMPONENTEESQUEMACOMISION', 'Setearcoleccionsentenciasanterior_nuevo', .T. )
			_screen.mocks.AgregarSeteoMetodo( 'COMPONENTEESQUEMACOMISION', 'Votarcambioestadograbar', .T., "[NUEVO]" ) 
			_screen.mocks.AgregarSeteoMetodo( 'COMPONENTEESQUEMACOMISION', 'Grabar', loCol ) 

			_screen.mocks.AgregarSeteoMetodo( 'zlclientes', 'Codigo_despuesdeasignar', .T. )
			_screen.mocks.AgregarSeteoMetodo( 'ACTUALIZARZOO', 'Inicializar', .T. ) 
			_screen.mocks.AgregarSeteoMetodo( 'ACTUALIZARZOO', 'Finalizar', .T. ) 
			_screen.mocks.AgregarSeteoMetodo( 'ACTUALIZARZOO', 'Migrarclientes', .T., "[*COMODIN],[cliente test cambioRZ]" ) 
			_screen.mocks.AgregarSeteoMetodo( 'zlasigestadosrzadm', 'Nuevo', .T. ) 
			_screen.mocks.AgregarSeteoMetodo( 'zlasigestadosrzadm', 'Grabar', .T. )
			_screen.mocks.AgregarSeteoMetodo( 'ACTUALIZARZOO', 'Migrarrazonsocial', .T., "[*COMODIN],[rz vieja],[*COMODIN],88.88" )
			_screen.mocks.AgregarSeteoMetodo( 'tipoarticuloitemservicio', 'Ccod_despuesdeasignar', '01' )
			_screen.mocks.AgregarSeteoMetodo( 'ACTUALIZARZOO', 'Migrarrazonsocial', .T., "[*COMODIN]" )
			_screen.mocks.AgregarSeteoMetodo( 'ACTUALIZARZOO', 'Migrarrazonsocial', .T., "[*COMODIN]" )
			_screen.mocks.AgregarSeteoMetodo( 'zlaltagrupocom', 'Numero_despuesdeasignar', .T. ) 

			_screen.mocks.AgregarSeteoMetodo( 'zlasigestadosrzadm', 'Enlazar', .T., "[Razonsocial.EventoObtenerLogueo],[inyectarLogueo]" ) 
			_screen.mocks.AgregarSeteoMetodo( 'zlasigestadosrzadm', 'Enlazar', .T., "[Razonsocial.EventoObtenerInformacion],[inyectarInformacion]" ) 
			_screen.mocks.AgregarSeteoMetodo( 'zlasigestadosrzadm', 'Enlazar', .T., "[Estadorz.EventoObtenerLogueo],[inyectarLogueo]" ) 
			_screen.mocks.AgregarSeteoMetodo( 'zlasigestadosrzadm', 'Enlazar', .T., "[Estadorz.EventoObtenerInformacion],[inyectarInformacion]" ) 
			_screen.mocks.AgregarSeteoMetodo( 'zlasigestadosrzadm', 'Enlazar', .T., "[Registradopor.EventoObtenerLogueo],[inyectarLogueo]" ) 
			_screen.mocks.AgregarSeteoMetodo( 'zlasigestadosrzadm', 'Enlazar', .T., "[Registradopor.EventoObtenerInformacion],[inyectarInformacion]" ) 

			loEntidad = newobject( "objEntidad" ) 
			_screen.mocks.AgregarSeteoMetodo( 'zlasigestadosrzadm', 'razonsocial_access', loEntidad )

			=CrearItemzlvinculacionitemsdetalleitems_Test( this )	
			_screen.Mocks.AgregarMock( 'Itemzlvinculacionitemsdetalleitems', forceext( this.cArchivoMock, '' ) )

			=CrearItemZlserviciosloteSubitems_Test( this )	
			_screen.Mocks.AgregarMock( 'ItemZlserviciosloteSubitems', forceext( this.cArchivoMock1, '' ) )


			loTalonario = _screen.zoo.instanciarentidad("talonario")
			local loError as Exception, loEx as Exception
			Try
				loTalonario.codigo = "ALTASIS" 
			Catch To loError
				loTalonario.nuevo()
				loTalonario.codigo = "ALTASIS" 
				loTalonario.ENTIDAD = "ZLSERVICIOSLOTE"
				loTalonario.GRABAR()
			endtry 

			Try
				loTalonario.codigo = "BAJASIS" 
			Catch To loError
				loTalonario.nuevo()
				loTalonario.codigo = "BAJASIS" 
				loTalonario.ENTIDAD = "ZLSERVICIOSLOTEBAJA"
				loTalonario.GRABAR()
			endtry 

			Try
				loTalonario.codigo = "CAMBIORZ" 
			Catch To loError
				loTalonario.nuevo()
				loTalonario.codigo = "CAMBIORZ"
				loTalonario.ENTIDAD = "CAMBIODERAZONSOCIAL"
				loTalonario.GRABAR()
			endtry 

			Try
				loTalonario.codigo = "ITEMSERCOD" 
			Catch To loError
				loTalonario.nuevo()
				loTalonario.codigo = "ITEMSERCOD"
				loTalonario.ENTIDAD = "ZLITEMSSERVICIOS"
				loTalonario.GRABAR()
			endtry 

			Try
				loTalonario.codigo = "VINCULACIONITEMS" 
			Catch To loError
				loTalonario.nuevo()
				loTalonario.codigo = "VINCULACIONITEMS"
				loTalonario.GRABAR()
			endtry 

			Try
				loTalonario.codigo = "ZLCLASIFICACIONCLIENTES" 
			Catch To loError
				loTalonario.nuevo()
				loTalonario.codigo = "ZLCLASIFICACIONCLIENTES"
				loTalonario.GRABAR()
			endtry 
		
			loTalonario.RELEASE()

			loEsquemaComisional = _screen.zoo.instanciarentidad( "Esquemacomisional" )
			with loEsquemaComisional
				try
					.cCod = 32
					.Eliminar()
				catch
				endtry
				try
					.Nuevo()
					.cCod = 32
					.Descrip = 'Esquema de prueba ' + sys( 2015 )
					.Grabar()
				catch
				endtry
			endwith
			loEsquemacomisional.Release()
			loEsquemacomisional = null

			loClasificacionv2 = _screen.zoo.instanciarentidad("Clasificacionv2")

			with loClasificacionv2
				Try
					loClasificacionv2.codigo = '39' 
				Catch To loError
					loClasificacionv2.nuevo()
					loClasificacionv2.codigo = '39'
					loClasificacionv2.nombre = 'Clasificacion 39'
					loClasificacionv2.GRABAR()
				endtry 

				try
					.Codigo = '37'
					.Eliminar()
				catch
				finally
					.Nuevo()
					.Codigo = '37'
					.Nombre = 'Clasificacion 37'
					.Grabar()
				endtry 
			endwith
			loClasificacionv2.release()


			loModulos = _screen.zoo.instanciarentidad( "zlismodulo" )
			with loModulos
				.nuevo()
				lcModulo1 = .ccod
				.Descrip = "Toma de inventario"
				.TipoModulo_pk = "1"			
				.grabar()	

				.nuevo()
				lcModulo2 = .ccod
				.Descrip = "Comuica"
				.TipoModulo_pk = "2"			
				.grabar()	

				.release()
			endwith 
			
			loProducto = _screen.zoo.instanciarentidad( "productozl" )
			with loProducto
				.nuevo()
				lcProductoZL = .ccod
				.descrip = 'prod test'
				.grabar()
			endwith	

			loProducto.release()
			loSerie = createobject( "serieTest" )
			with loSerie
				try
					.nroserie = '507000'
					.eliminar()
				catch
				finally	
					.cNumeroSugeridoTest = '507000'
					.nuevo()
					.ambito_pk = "0001"
					.productozoologic_pk = lcProductoZL
					.nombre = "serie test"
					.direcc_pk = '00001'
					.grabar()
				endtry 

				try
					.nroserie = '507001'
					.eliminar()
				catch
				finally	
					.cNumeroSugeridoTest = '507001'
					.nuevo()
					.ambito_pk = "0001"
					.productozoologic_pk = lcProductoZL
					.nombre = "serie TI test"
					.direcc_pk = '00001'
					.grabar()
				endtry
			endwith 

			loArticulo = _screen.zoo.instanciarentidad( "zlIsarticulos" ) 
			with loArticulo
				try
					.codigo = '00-AA'
					.eliminar()
				catch
				finally 
					.nuevo()
					.codigo = '00-AA'
					.descrip = 'art 00-AA'
					.tipoArticulo_pk = '01'
					.productozoologic_pk = lcProductoZL
					.desactivado = .f.
					.detalleclasificaciones.oitem.clasificacion_pk = '39'
					.detalleclasificaciones.oitem.detalleclasificacion = '39'
					.detalleclasificaciones.actualizar()
					.grabar()
				endtry 
				try
					.codigo = '00-TI'
					.eliminar()
				catch
				finally 
					.nuevo()
					.codigo = '00-TI'
					.descrip = 'art 00-TI'
					.tipoArticulo_pk = '01'
					.productozoologic_pk = lcProductoZL
					.desactivado = .f.
					.detalleclasificaciones.oitem.clasificacion_pk = '39'
					.detalleclasificaciones.oitem.detalleclasificacion = '39'
					.detalleclasificaciones.actualizar()
					
					.detalleModulos.oItem.CodigoModulo_pk = lcModulo1
					.detalleModulos.oItem.descrip = "Toma inventario"
					.detalleModulos.Actualizar()
					.grabar()
				endtry 
				try
					.codigo = '00-HS'
					.eliminar()
				catch
				finally 
					.nuevo()
					.codigo = '00-HS'
					.descrip = 'art 00-HS'
					.tipoArticulo_pk = '01'
					.productozoologic_pk = lcProductoZL
					.desactivado = .f.
					.detalleclasificaciones.oitem.clasificacion_pk = '39'
					.detalleclasificaciones.oitem.detalleclasificacion = '39'
					.detalleclasificaciones.actualizar()
					
					.detalleModulos.oItem.CodigoModulo_pk = lcModulo2
					.detalleModulos.oItem.descrip = "Comunica"
					.detalleModulos.Actualizar()
					.grabar()
				endtry 
			endwith 
			
			loCliente = _screen.zoo.instanciarentidad( "ZLCLIENTES" )
			
			with loCliente
				.nuevo()
				.nombre = "cliente test cambioRZ"
				.direcc_pk = this.CodDireccion
				.grabar()
			endwith 

			loContactos = _screen.zoo.instanciarentidad( "CONTACTOS" )
			with loContactos
				.Nuevo()
				.Cliente_pk = loCliente.codigo
				.Titulo_pk = "0001"
				.PrimerNombre = "Test"
				.Apellido = "Test"
				.Grabar()
			endwith 

			loClasificacionCte = _screen.zoo.instanciarentidad( "ZLCMPCLASCLIENTE" )

			with loClasificacionCte
				try
					.codigo = loCliente.codigo
					.eliminar()
				catch
				finally 
					.nuevo()
					.FKClie_pk = loCliente.codigo
					.Registrado_pk = "ZTEST"
					.detalleclasificaciones.oitem.CodClasifi_pk = '39'
					.detalleclasificaciones.Actualizar()
					.grabar()
				endtry
			endwith

			loPais = _screen.zoo.instanciarentidad( "NACIONALIDAD" )
			with loPais
				try
					.Ccod = "00"
					.Eliminar()
				catch
				finally
					.Nuevo()
					.Ccod = "00"
					.Descrip = "00"
					.Grabar()
				endtry
			endwith	

			loProvincia = _screen.zoo.instanciarentidad( "PROVINCIA" )
			with loProvincia
				try
					.Codigo = "00"
					.Eliminar()
				catch
				finally
					.Nuevo()
					.Codigo = "00"
					.Descripcion = "00"
					.Pais_pk = "00"
					.Grabar()
				endtry
			endwith	

			loRZVieja = _Screen.zoo.Crearobjeto( "ZLRazonSociales_AUX", "ztestSQLServerCambioderazonsocial.prg" ) 	

			with loRZVieja
				.nuevo()
				.descripcion = 'rz vieja'
				.listadeprecios_pk = '99999'
				.cliente_pk = loCliente.codigo
				.SituacionFiscal_pk = 1
				.cuit = '11111111113'
				.FormaDePago_pk = 'EFE'
				.direcc_pk = this.CodDireccion
				.VersionSistema = 88.88
				.reGIMENCOMISION = 32
				.VersionSistema = 88.88
				.Direccion = "Direccion de prueba"
				.Provincia_pk = "00"
				.grabar()
			endwith 

			loZlServiciosLote = _screen.zoo.Crearobjeto( "ZLSERVICIOSLOTE_AUX", "ztestSQLServerCambioderazonsocial.prg" )
			loZlServiciosLote.oValidacionesEstadoRazonSocial = newobject( "ValidacionesEstadoRazonSocial_Aux", "ztestSQLServerCambioderazonsocial.prg" )			

			with loZlServiciosLote
				 .nuevo()
				 .RazonSocial_pk = loRZVieja.Codigo
				 .contacto_pk = '01'

				 .subitems.oitem.Serie_Pk = '507000'
				 .subitems.oitem.Articulo_pk = '00-AA'
				 .subitems.Actualizar()
				 
				 .subitems.LimpiarItem()
				 .subitems.oitem.Serie_Pk = '507000'
				 .subitems.oitem.Articulo_pk = '00-TI'
				 .subitems.oitem.SerieTI_Pk = '507001'
				 .subitems.Actualizar()
				 
				 .subitems.LimpiarItem()
				 .subitems.oitem.Serie_Pk = '507000'
				 .subitems.oitem.Articulo_pk = '00-HS'
				 .subitems.oitem.GrupoCom_Pk = 9999
				 .subitems.Actualizar()
				.grabar()	
			endwith
		
			loISAlta = _screen.zoo.instanciarentidad( "zlitemsservicios" )
			with loISAlta
				.ultimo()
				lnNroISALTA = loISAlta.codigo - 2			
				this.assertequals( "Debería tener el artículo 00-HS", "00-HS", alltrim( .Articulo_pk ))
				this.assertequals( "Debería tener el serie 507000", "507000", alltrim( .NumeroSerie_pk ))
				this.assertequals( "Debería tener la RZ ", alltrim( loRZVieja.Codigo ), alltrim( .RazonSocial_pk ))						
				this.assertequals( "Debería estar vacía la fecha de desactivación item 0", {//}, .fechadesactivacion )
				this.assertequals( "Debería estar vacía la fecha de registracion de baja", {//}, .fechabajaregistro )			
				this.assertequals( "Debería estar vacía la fecha de vigencia de baja", {//}, .fechabajaVigencia )
				this.assertequals( "Debería estar vacío el Nro de comprobante de baja", "", alltrim( .relalotebaja ))
				.anterior()
				this.assertequals( "Debería tener el artículo 00-TI", "00-TI", alltrim( .Articulo_pk ))
				this.assertequals( "Debería tener el serie 507000", "507000", alltrim( .NumeroSerie_pk ))
				this.assertequals( "Debería tener la RZ ", alltrim( loRZVieja.Codigo ), alltrim( .RazonSocial_pk ))						
				this.assertequals( "Debería estar vacía la fecha de desactivación item 1", {//}, .fechadesactivacion )
				this.assertequals( "Debería estar vacía la fecha de registracion de baja", {//}, .fechabajaregistro )			
				this.assertequals( "Debería estar vacía la fecha de vigencia de baja", {//}, .fechabajaVigencia )
				this.assertequals( "Debería estar vacío el Nro de comprobante de baja", "", alltrim( .relalotebaja ))
				.anterior()
				this.assertequals( "Debería tener el artículo 00-AA", "00-AA", alltrim( .Articulo_pk ))
				this.assertequals( "Debería tener el serie 507000", "507000", alltrim( .NumeroSerie_pk ))
				this.assertequals( "Debería tener la RZ ", alltrim( loRZVieja.Codigo ), alltrim( .RazonSocial_pk ))						
				this.assertequals( "Debería estar vacía la fecha de desactivación item 2", {//}, .fechadesactivacion )
				this.assertequals( "Debería estar vacía la fecha de registracion de baja", {//}, .fechabajaregistro )			
				this.assertequals( "Debería estar vacía la fecha de vigencia de baja", {//}, .fechabajaVigencia )
				this.assertequals( "Debería estar vacío el Nro de comprobante de baja", "", alltrim( .relalotebaja ))
				
			endwith 

			
			loISAlta.release()
			_screen.mocks.AgregarSeteoMetodo( 'ACTUALIZARZOO', 'Inicializar', .T. ) 
			_screen.mocks.AgregarSeteoMetodo( 'ACTUALIZARZOO', 'Migrarrazonsocial', .T., "[*COMODIN],[rz nueva],[*COMODIN],99.99" ) 
			_screen.mocks.AgregarSeteoMetodo( 'ACTUALIZARZOO', 'Finalizar', .T. ) 
			_screen.mocks.AgregarSeteoMetodo( 'zlasigestadosrzadm', 'Nuevo', .T. ) 
			_screen.mocks.AgregarSeteoMetodo( 'zlasigestadosrzadm', 'Grabar', .T. )
			
			loRZNueva = _Screen.zoo.Crearobjeto( "ZLRazonSociales_AUX", "ztestSQLServerCambioderazonsocial.prg" ) 		&&_screen.zoo.instanciarentidad( "ZlRAZONSOCIALES" )
			
			with loRZNueva
				.nuevo()
				.descripcion = 'rz nueva'
				.cliente_pk = loCliente.codigo
				.listadeprecios_pk= 'LISTA8'
				.SituacionFiscal_Pk = 1
				.cuit = '11111111113'
				.FormaDePago_pk = 'TAR'
				.Direcc_pk = '99999'
				.VersionSistema = 99.99
				.direcc_pk = this.CodDireccion
				.reGIMENCOMISION = 32
				.Direccion = "Direccion de prueba"
				.Provincia_pk = "00"
				.grabar()
			endwith 

			loEntCambioRZ = _screen.zoo.instanciarentidad( "CAMBIODERAZONSOCIAL" )
			loEntCambioRZ.oValidacionesEstadoRazonSocial = newobject( "ValidacionesEstadoRazonSocial_Aux", "ztestSQLServerCambioderazonsocial.prg" )
			loEntCambioRZ.OCOMPCAMBIORAZONSOCIAL.OZLSERVICIOSLOTE = newobject( "ZLSERVICIOSLOTE_AUX", "ztestSQLServerCambioderazonsocial.prg" )
			loEntCambioRZ.oCompCambioRazonSocial.oZlServiciosLote.oValidacionesEstadoRazonSocial = newobject( "ValidacionesEstadoRazonSocial_Aux" )

			with loEntCambioRZ
				.nuevo()
		
				.RzViejo_pk = loRZVieja.codigo
				.RzNuevo_pk = loRZNueva.codigo
				.contacto_pk = loContactos.Codigo &&'111'
				.MotivoBaja_pk = '12'

				.subitems.oitem.NroItemServ_pk = lnNroISALTA
				.subitems.actualizar()
				 
				.subitems.LimpiarItem()
				.subitems.oitem.NroItemServ_pk = lnNroISALTA + 1
				.subitems.actualizar()
				 
				.subitems.LimpiarItem()
				.subitems.oitem.NroItemServ_pk = lnNroISALTA + 2
				.subitems.actualizar()

				.grabar()
			endwith
			* VERIFICO QUE SE HAYA GENERADO BIEN EL COMPROBANTE ITEM DE SERVICIOS


			with loZlServiciosLote
				.ultimo()
				this.assertequals( "El comprobante tiene mal la RZ "   , loRZNueva.codigo , alltrim( .RazonSocial_pk ))			
				this.assertequals( "El item 1 deberia tener el Serie 507000" , '507000' , alltrim( .subitems.item(1).Serie_pk ))
				this.assertequals( "El item 1 deberia tener el art 00-AA" , "00-AA" , alltrim( .subitems.item(1).Articulo_pk ))
				this.assertequals( "El item 1 deberia tener el Serie TI vacio " , "" , alltrim( .subitems.item(1).SerieTI_pk ))
				this.assertequals( "El item 1 deberia tener el Grupo Com 0 " , 0 ,  .subitems.item(1).GrupoCom_pk )
				this.assertequals( "El item 2 deberia tener el Serie 507000"  , '507000' , alltrim( .subitems.item(2).Serie_pk ))
				this.assertequals( "El item 2 deberia tener el art 00-AA" , "00-TI" , alltrim( .subitems.item(2).Articulo_pk ))
				this.assertequals( "El item 2 deberia tener el Serie TI 507001 " , "507001" , alltrim( .subitems.item(2).SerieTI_pk ))
				this.assertequals( "El item 2 deberia tener el Grupo Com 0 " , 0 ,  .subitems.item(2).GrupoCom_pk )
				this.assertequals( "El item 3 deberia tener el Serie 507000" , '507000' , alltrim( .subitems.item(3).Serie_pk ))
				this.assertequals( "El item 3 deberia tener el art 00-HS" , "00-HS" , alltrim( .subitems.item(3).Articulo_pk ))
				this.assertequals( "El item 3 deberia tener el Serie TI vacio " , "" , alltrim( .subitems.item(3).SerieTI_pk ))
				this.assertequals( "El item 3 deberia tener el Grupo Com 0 " , 0 ,  .subitems.item(3).GrupoCom_pk )
			endwith 

			ldfechabaja = this.dFecha
			loISAlta = _screen.zoo.instanciarentidad( "zlitemsservicios" )
			with loISAlta
				.ultimo()
				this.assertequals( "Debería tener el artículo 00-HS", "00-HS", alltrim( .Articulo_pk ))
				this.assertequals( "Debería tener el serie 507000", "507000", alltrim( .NumeroSerie_pk ))
				this.assertequals( "Debería tener la RZ ", alltrim( loRZNueva.codigo ), alltrim( .RazonSocial_pk ))						
				this.assertequals( "Debería estar vacía la fecha de desactivación item 0 bis", {//}, .fechadesactivacion )
				this.assertequals( "Debería estar vacía la fecha de registracion de baja", {//}, .fechabajaregistro )			
				this.assertequals( "Debería estar vacía la fecha de vigencia de baja", {//}, .fechabajaVigencia )
				this.assertequals( "Debería estar vacío el Nro de comprobante de baja", "", alltrim( .relalotebaja ))
				.anterior()
				this.assertequals( "Debería tener el artículo 00-TI", "00-TI", alltrim( .Articulo_pk ))
				this.assertequals( "Debería tener el serie 507000", "507000", alltrim( .NumeroSerie_pk ))
				this.assertequals( "Debería tener la RZ ", alltrim( loRZNueva.codigo ), alltrim( .RazonSocial_pk ))						
				this.assertequals( "Debería estar vacía la fecha de desactivación item 3", {//}, .fechadesactivacion )
				this.assertequals( "Debería estar vacía la fecha de registracion de baja", {//}, .fechabajaregistro )			
				this.assertequals( "Debería estar vacía la fecha de vigencia de baja", {//}, .fechabajaVigencia )
				this.assertequals( "Debería estar vacío el Nro de comprobante de baja", "", alltrim( .relalotebaja ))
				.anterior()
				this.assertequals( "Debería tener el artículo 00-AA", "00-AA", alltrim( .Articulo_pk ))
				this.assertequals( "Debería tener el serie 507000", "507000", alltrim( .NumeroSerie_pk ))
				this.assertequals( "Debería tener la RZ ", alltrim( loRZNueva.codigo ), alltrim( .RazonSocial_pk ))						
				this.assertequals( "Debería estar vacía la fecha de desactivación item 4", {//}, .fechadesactivacion )
				this.assertequals( "Debería estar vacía la fecha de registracion de baja", {//}, .fechabajaregistro )			
				this.assertequals( "Debería estar vacía la fecha de vigencia de baja", {//}, .fechabajaVigencia )
				this.assertequals( "Debería estar vacío el Nro de comprobante de baja", "", alltrim( .relalotebaja ))
				.anterior()
				this.assertequals( "Debería tener el artículo 00-HS", "00-HS", alltrim( .Articulo_pk ))
				this.assertequals( "Debería tener el serie 507000", "507000", alltrim( .NumeroSerie_pk ))
				this.assertequals( "Debería tener la RZ ", alltrim( loRZVieja.Codigo ), alltrim( .RazonSocial_pk ))						
				this.assertequals( "NO Debería estar vacía la fecha de alta de vigencia item 0 pri", ldFechaBaja, .FechaAltaVigencia )
				this.assertequals( "NO Debería estar vacía la fecha de registracion de baja", ldFechaBaja, .fechabajaregistro )			
				this.asserttrue( "NO Debería estar vacía la fecha de vigencia de baja", !empty( .fechabajaVigencia ))
				this.asserttrue ( "No Debería estar vacío el Nro de comprobante de baja", !empty( .relalotebaja ))
				.anterior()
				this.assertequals( "Debería tener el artículo 00-TI", "00-TI", alltrim( .Articulo_pk ))
				this.assertequals( "Debería tener el serie 507000", "507000", alltrim( .NumeroSerie_pk ))
				this.assertequals( "Debería tener la RZ ", alltrim( loRZVieja.Codigo ), alltrim( .RazonSocial_pk ))						
				this.assertequals( "NO Debería estar vacía la fecha de alta de vigencia item 1", ldFechaBaja, .FechaAltaVigencia )
				this.assertequals( "NO Debería estar vacía la fecha de registracion de baja", ldFechaBaja, .fechabajaregistro )			
				this.asserttrue( "NO Debería estar vacía la fecha de vigencia de baja", !empty( .fechabajaVigencia ))
				this.asserttrue ( "No Debería estar vacío el Nro de comprobante de baja", !empty( .relalotebaja ))
				.anterior()
	
				this.assertequals( "Debería tener el artículo 00-AA", "00-AA", alltrim( .Articulo_pk ))
				this.assertequals( "Debería tener el serie 507000", "507000", alltrim( .NumeroSerie_pk ))
				this.assertequals( "Debería tener la RZ ", alltrim( loRZVieja.Codigo ), alltrim( .RazonSocial_pk ))						
				this.assertequals( "No Debería estar vacía la fecha de alta de vigencia item 2", ldFechaBaja, .FechaAltaVigencia )
				this.assertequals( "NO Debería estar vacía la fecha de registracion de baja", ldFechaBaja, .fechabajaregistro )			
				this.asserttrue( "NO Debería estar vacía la fecha de vigencia de baja", !empty(.fechabajaVigencia ))
				this.asserttrue ( "No Debería estar vacío el Nro de comprobante de baja", !empty( .relalotebaja ))
			endwith 

			loISAlta.release()
			loSerie.release()
			loArticulo.release()
			loContactos.release()
			loCliente.release()
			loRZNueva.release()
			loRZVieja.release()
			loZlServiciosLote.release()
			loEntCambioRZ.release()
			loClasificacionCte.release()
			loPais.Release()
			loProvincia.Release()

		catch to loError
			throw loError
		finally
			=BorrarZlServiciosLoteBaja_Test( this )
			=BorrarItemzlvinculacionitemsdetalleitems_Test( this )
			=Borrarzlvinculacionitemsdetalleitems_Test( this )
						
			goLibrerias.Release()
			goLibrerias = loLibrerias
			goServicios.Librerias = goLibrerias			
goMensajes = _Screen.zoo.app.oMensajes
		endtry

	endfunc 

enddefine



*-----------------------------------------------------------------------------------------
Function CrearFuncion_funcObtenerArticulosNoVisiblesDeRazonSocial
	Local lcTexto

	TEXT to lcTexto noshow
		IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[funcObtenerArticulosNoVisiblesDeRazonSocial]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
		DROP FUNCTION [ZL].[funcObtenerArticulosNoVisiblesDeRazonSocial]
	ENDTEXT
	goServicios.Datos.EjecutarSQL( lcTexto )

	TEXT to lcTexto noshow
		CREATE FUNCTION [ZL].[funcObtenerArticulosNoVisiblesDeRazonSocial]
		(@RZ varchar(5), @Art varchar(13))
		RETURNS TABLE
		AS
		RETURN
		(
			select distinct cli.Cliente, art.Ccod as Articulo, dana.Cmpclasif as Clasificacion
			from ZL.Isarticu art
				inner join ZL.DCLAARTNO dana on dana.Codcla = art.Ccod
				inner join ZL.DETCLASCLIE dc on dc.Fkclasifi = dana.Cmpclasif
				inner join ZL.Razonsocial cli on cli.Cliente = dc.Fkcliente
			where cli.Cmpcod = @RZ and art.Ccod = @Art
		)
	ENDTEXT
	goServicios.Datos.EjecutarSQL( lcTexto )
Endfunc

*-----------------------------------------------------------------------------------------
Function CrearFuncion_funcObtenerArticulosNoVisiblesDeCliente
	Local lcTexto

	TEXT to lcTexto noshow
		IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[funcObtenerArticulosNoVisiblesDeCliente]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
		DROP FUNCTION [ZL].[funcObtenerArticulosNoVisiblesDeCliente]
	ENDTEXT
	goServicios.Datos.EjecutarSQL( lcTexto )

	TEXT to lcTexto noshow
		CREATE FUNCTION [ZL].[funcObtenerArticulosNoVisiblesDeCliente]
		(@Cliente varchar(5), @Art varchar(13))
		RETURNS TABLE
		AS
		RETURN
		(
			select cli.Cmpcodigo as Cliente, art.Ccod as Articulo, dana.Cmpclasif as Clasificacion
			from ZL.Isarticu art
				inner join ZL.DCLAARTNO dana on dana.Codcla = art.Ccod
				inner join ZL.DETCLASCLIE dc on dc.Fkclasifi = dana.Cmpclasif
				inner join ZL.Clientes cli on cli.Cmpcodigo = dc.Fkcliente
			where cli.Cmpcodigo = @Cliente and art.Ccod = @Art
		)
	ENDTEXT
	goServicios.Datos.EjecutarSQL( lcTexto )
Endfunc

*--------------------------------------------------------------------------------------------------
function CrearZlRrhhPuestosActivos()
	local lcSQL as String

	text to lcSQL noshow
		IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[RrhhPuestosActivos]'))
			DROP VIEW [ZL].[RrhhPuestosActivos]
	endtext

	goServicios.Datos.EjecutarSentencias( lcSQL , '' )
	
	text to lcSQL noshow
		CREATE VIEW [ZL].[RrhhPuestosActivos]
		AS
		SELECT     ZL.Legajo.Ccod AS Legajo, LTRIM(RTRIM(ZL.Legops.Ccod)) AS Empleado, LTRIM(RTRIM(ZL.puestosrh.Sector)) AS Sector, LTRIM(RTRIM(ZL.puestosrh.AREA)) AS Area, 
		                      ZL.puestosrh.Reportaa, ZL.puestosrh.Cod AS Puesto
		FROM         ZL.Carrzl INNER JOIN
		                      ZL.Legops ON ZL.Legops.Clegajo = ZL.Carrzl.Ccod INNER JOIN
		                      ZL.Legajo ON ZL.Legajo.Ccod = ZL.Legops.Clegajo INNER JOIN
		                      ZL.puestosrh ON ZL.puestosrh.Cod = ZL.Carrzl.Cpuesto
		WHERE     (ZL.Carrzl.Ffin <= '01/01/1900') AND (ZL.Carrzl.Finicio > '01/01/1900') AND (ZL.Legajo.Fegreso <= '01/01/1900') AND (ZL.Carrzl.Cpuesto <> '')

	endtext
		
	goServicios.Datos.EjecutarSentencias( lcSQL , '' )	
endfunc


*-----------------------------------------------------------------------------------------
function CrearDirecciones
	local loent as Object, loerror as Object, lcCodRetorno as String, loent1 as Object , loent2 as Object, loent3 as Object

	lcCodRetorno = ''
	
	loent = _Screen.zoo.instanciarentidad( 'PROVINCIA' )

	with loent
		try 
			.codigo = '01'
			.Eliminar()
		catch to loError	
		endtry 
			
		try 
			.NUEVO()
			.codigo = '01'
			.Descripcion = 'BA'
			.grabar()
		finally 
			.Release()
		endtry 	
	endwith 
	
	loent = null
	loent1 = _Screen.zoo.instanciarentidad( 'TIPODIRECCIONES' )	

	with loent1
		try 
			.cCod = '0001'
			.Eliminar()
		catch to loError
		endtry 
			
		try 
			.NUEVO()
			.cCod = '0001'
			.Descrip = 'Tipo 1'
			.grabar()
		finally 
			.Release()
		endtry 			
	endwith 	
	loent1 = null
	loent2 = _Screen.zoo.instanciarentidad( 'NACIONALIDAD' )

	with loent2
		try 
			.cCod = 'AR'
			.Eliminar()
		catch to loError
		endtry 
			
		try 
			.NUEVO()
			.cCod = 'AR'
			.Descrip = 'Aryentain'
			.grabar()
		finally 
			.Release()
		endtry 				
	endwith 	

	loent2 = null
	loent3 = _Screen.zoo.instanciarentidad( 'DIRECCIONESALTAS' )
	
	with loent3	
		try 
			.nuevo()
			.Calle = 'LA CALLE'
			.Provincia_PK ='01'
			.TIPO_PK = '0001'
			.Pais_pk = 'AR'
			.Grabar()
		finally
			.Ultimo()
			lcCodRetorno = .Codigo
			.Release()
		endtry 	
			
	endwith 

	loent3 = null

	return lcCodRetorno
	
endfunc 

*-----------------------------------------------------------------------------------------
function CrearItemzlvinculacionitemsdetalleitems_Test(  toFxuTestCase as Object ) as Void
	local lcContenido as String, ldFecha as string  
	
	toFxuTestCase.cArchivoMock = ObtenerNombreDeArchivoItemzlvinculacionitemsdetalleitems_Test()
	ldFecha = "ctod('" + transform(toFxuTestCase.dFecha) +"')"

	text to lcContenido textmerge noshow
	*--------------------------------------------------------------------------------------------------
	define class <<justfname( forceext( toFxuTestCase.cArchivoMock, '' ) )>> as itemZLVINCULACIONITEMSDetalleItems of itemZLVINCULACIONITEMSDetalleItems.prg

		function CargarFecFact
			this.FechaFacturacion = <<ldFecha>>
			return .t.
		endfunc

	enddefine
	endtext

	strtofile( lcContenido, toFxuTestCase.cArchivoMock, 0)
	
endfunc 

*-----------------------------------------------------------------------------------------
function CrearItemZlserviciosloteSubitems_Test( toFxuTestCase as Object ) as Void

	local lcContenido as String 
	
	toFxuTestCase.cArchivoMock1 = ObtenerNombreDeArchivoItemZlserviciosloteSubitems_Test()

	text to lcContenido textmerge noshow
	*--------------------------------------------------------------------------------------------------
	define class <<justfname( forceext( toFxuTestCase.cArchivoMock1, '' ) )>> as ItemZlserviciosloteSubitems of ItemZlserviciosloteSubitems.prg

		function init() as Void
			dodefault()
			this.oValidacionDeArticulos = newobject( 'ValidacionDeArticulos_aux' )
		endfunc 

		function ValidaArticuloCentralizador
			return .t.
		endfunc

	enddefine
	endtext

	strtofile( lcContenido, toFxuTestCase.cArchivoMock1, 0)

endfunc 

*--------------------------------------------------------------------------------

define class serieTest as ent_zlseries of ent_zlseries.prg
	cNumeroSugeridoTest = ''
	function ObtenerNumeroString() as String
		return this.cNumeroSugeridoTest
	endfunc

enddefine

*-----------------------------------------------------------------------------------------
function ObtenerNombreDeArchivoItemzlvinculacionitemsdetalleitems_Test as String 
	local lcArchivo as String 
	lcArchivo = addbs( _screen.Zoo.ObtenerRutaTemporal() ) + 'Mock_Itemzlvinculacionitemsdetalleitems_Test' + sys( 2015 ) + '.prg'
	return lcArchivo
endfunc

*-----------------------------------------------------------------------------------------
function ObtenerNombreDeArchivoItemZlserviciosloteSubitems_Test() as string
	local lcArchivo as String 
	lcArchivo = addbs( _screen.Zoo.ObtenerRutaTemporal() ) + 'Mock_ItemZlserviciosloteSubitems_Test' + sys( 2015 ) + '.prg'
	return lcArchivo
endfunc 

*-----------------------------------------------------------------------------------------
function BorrarItemzlvinculacionitemsdetalleitems_Test( toFxuTestCase as Object )
	local lcArchivo as String 
	lcArchivo = toFxuTestCase.cArchivoMock
	delete file ( lcArchivo )
endfunc

*-----------------------------------------------------------------------------------------
function Borrarzlvinculacionitemsdetalleitems_Test( toFxuTestCase as Object )
	local lcArchivo as String 
	lcArchivo = toFxuTestCase.cArchivoMock1
	delete file ( lcArchivo )
endfunc


*--------------------------------------------------------------------------------------------------
function CrearZlServiciosLoteBaja_Test( toFxuTestCase as Object )
	local lcContenido as String , lcSQL as String 
	
	toFxuTestCase.cArchivoMockZlServiciosLoteBaja = ObtenerNombreDeArchivoZlServiciosLoteBaja_Test()

	text to lcContenido textmerge noshow
		*--------------------------------------------------------------------------------------------------
		define class <<justfname( forceext( toFxuTestCase.cArchivoMockZlServiciosLoteBaja, '' ) )>> as Ent_ZlServiciosLoteBaja of Ent_ZlServiciosLoteBaja.prg
			function TieneModuloeHost( tcArticulo as String ) as Boolean
				return .t.
			endfunc
			protected function Ejecuta_sp_AsignacionDeTareaADEVOPS_y_Alta_USUARIOS_DFCLOUD() as Void
				nodefault 
			endfunc			
		enddefine
	endtext

	strtofile( lcContenido, toFxuTestCase.cArchivoMockZlServiciosLoteBaja, 0)
	
	text to lcSQL noshow
		IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[funcObtenerEsquemaDeComision]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
		DROP FUNCTION [ZL].[funcObtenerEsquemaDeComision]
	endtext

	goServicios.Datos.EjecutarSentencias( lcSQL , '' )
	
	text to lcSQL noshow
		CREATE FUNCTION [ZL].[funcObtenerEsquemaDeComision]
		(	
			@RazonSocial varchar(5)
		)
		RETURNS TABLE 
		AS
		RETURN 
		(
			Select 
					a.NUMERO AS NUMERO
					,a.CREGIMEN AS REGIMENCOMISION 
				from ZL.ASESCOMAC a
				inner join ZL.esqcom e  on a.cregimen = e.ccod
				inner join  ZL.Legops l on l.ccod = e.dueno
			 Where  a.NUMERO != 0 
				and a.nrz = @RazonSocial 
				and l.activo = 1  
		)
		endtext
		
		goServicios.Datos.EjecutarSentencias( lcSQL , '' )	

endfunc

*--------------------------------------------------------------------------------------------------
function BorrarZlServiciosLoteBaja_Test( toFxuTestCase as Object )
	local lcArchivo as String 
	lcArchivo = toFxuTestCase.cArchivoMockZlServiciosLoteBaja
	delete file ( lcArchivo )
endfunc


*--------------------------------------------------------------------------------------------------
function ObtenerNombreDeArchivoZlServiciosLoteBaja_Test as String 
	local lcArchivo as String 
	lcArchivo = addbs( _screen.Zoo.ObtenerRutaTemporal() ) + 'Mock_ZlServiciosLoteBaja_Test' + sys( 2015 ) + '.prg'
	return lcArchivo
endfunc


*-----------------------------------------------------------------------------------------
define class objEntidad as Entidad of Entidad.prg 

	*-----------------------------------------------------------------------------------------
	function SoportaBusquedaExtendida() as Void
		return .f.
	endfunc 

enddefine

*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class LibreriasTest as librerias of librerias.prg
	*-----------------------------------------------------------------------------------------
	Function ObtenerFecha() As Date
		return ctod( "11/11/2011" )
	endfunc
enddefine

*------------------------------------------------------------------------------
define class ZLRazonSociales_Aux as Ent_ZLRazonSociales of Ent_ZLRazonSociales.prg

	*-----------------------------------------------------------------------------------------
	function ValidarPermisoAsignacionTipoRazonSocial()
		return .t.
	endfunc  

	*--------------------------------------------------------------------------------------------------------
	function Validar_Regimencomision( txVal as variant ) as Boolean
		return .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerDatosAFIP() as Void
		this.Direccion = "Direccion de prueba"
		this.Localidad = ""
		this.Provincia_pk = "00"
		this.CodigoPostal = ""
	endfunc 

enddefine

*----------------------------------------------------------------
define class ValidacionesEstadoRazonSocial_Aux as custom 

	*-----------------------------------------------------------------------------------------
	function Validar( txVal ) as Boolean
		return .t.
	endfunc 
enddefine 

*-----------------------------------
define class ValidacionDeArticulos_aux  as custom

	*-----------------------------------------------------------------------------------------
	function ValidarArticuloPorSerie( tRazonSocial, tSerie, tArticulo ) as Boolean
		return .t.
	endfunc	
	
enddefine


*----------------------------------------------------------------
define class ZLSERVICIOSLOTE_AUX as ent_ZLSERVICIOSLOTE of ent_ZLSERVICIOSLOTE.PRG

	*-----------------------------------------------------------------------------------------
	function CrearCuentaComunicaciones() as Void
		nodefault
	endfunc

	protected function Ejecuta_sp_AsignacionDeTareaADEVOPS_y_Alta_USUARIOS_DFCLOUD() as Void
		nodefault
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function NoEsRazonSocialDePantera() as Void
		return .t.
	endfunc 
	
enddefine

*-----------------------------------------------------------------------------------------
Function CrearFuncion_funcArticuloConModuloActivacionOnLine
	Local lcTexto

	TEXT to lcTexto noshow
		IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[funcArticuloConModuloActivacionOnLine]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
		DROP FUNCTION [ZL].[funcArticuloConModuloActivacionOnLine]
	endtext
	goServicios.Datos.EjecutarSQL( lcTexto )
		
	TEXT to lcTexto noshow
		CREATE FUNCTION [ZL].[funcArticuloConModuloActivacionOnLine]
		(	
			@Articulo varchar(13)
		)
		RETURNS TABLE 
		AS
		RETURN 
		(
			select '' as Ccod where 1 = 0
		)
	ENDTEXT
	goServicios.Datos.EjecutarSQL( lcTexto )
endfunc

*-----------------------------------------------------------------------------------------
Function CrearFuncion_FuncObtenerTipoUsuarioZLAD
	Local lcTexto

	TEXT to lcTexto noshow
		IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[FuncObtenerTipoUsuarioZLAD]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
		DROP FUNCTION [ZL].[FuncObtenerTipoUsuarioZLAD]
	ENDTEXT
	goServicios.Datos.EjecutarSQL( lcTexto )

	TEXT to lcTexto noshow
		CREATE function [ZL].[FuncObtenerTipoUsuarioZLAD]
		( 
			@UsuarioZL Varchar(100) 
		)
		returns Varchar(7)
		as
		begin
			declare @ret Varchar(4);
			
					select @ret = L.Tipousu 
						from  ZL.DUsrZLAD D
						JOIN ZL.Legops L on upper(D.codusu) = L.ccod
						where upper(D.USUAD) = upper( @UsuarioZL )
			
			return ISNULL(@ret, '' )
		end
	ENDTEXT
	goServicios.Datos.EjecutarSQL( lcTexto )
endfunc

*-----------------------------------------------------------------------------------------
Function CrearFuncion_funcCOMEsquemaComisionalVigentePorCliente
	Local lcTexto

	TEXT to lcTexto noshow
		IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[funcCOMEsquemaComisionalVigentePorCliente]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
		DROP FUNCTION [ZL].[funcCOMEsquemaComisionalVigentePorCliente]
	endtext
	goServicios.Datos.EjecutarSQL( lcTexto )
		
	TEXT to lcTexto noshow
		CREATE FUNCTION [ZL].[funcCOMEsquemaComisionalVigentePorCliente]
		(	
			
		)
		RETURNS TABLE 
		AS
		RETURN 
		(
			select 
					E.Ccod as Esquema ,
					CLIENTE  as Cliente ,
					case when (e.INACTIVOFW = 1 Or isnull(l.activo,1) = 0) then 1 else 0 end as Inactivo ,
					case when (e.INACTIVOFW = 1 Or isnull(l.activo,1) = 0) then 'Inactivo' else 'Activo' end as Estado,
					e.dueno as Duenio
				from ZL.esqcom E
				left join (select Cliente, CREGIMEN from zl.ASESCOMCLI 
								where NUMERO in ( select max(numero)
									from zl.ASESCOMCLI
									group by   CLIENTE
												)      
							) as ASESCOMCLI on e.ccod = ASESCOMCLI.CREGIMEN 
				join ZL.Legops l on l.ccod = e.dueno 
				
		)
	ENDTEXT
	goServicios.Datos.EjecutarSQL( lcTexto )
endfunc

*-----------------------------------------------------------------------------------------
Function CrearSP_SP_ValidarSerieLinceClasificacionArticulo
	Local lcTexto

	TEXT to lcTexto noshow
		IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[SP_ValidarSerieLinceClasificacionArticulo]') AND type in (N'P', N'IF', N'TF', N'FS', N'FT'))
		DROP PROCEDURE [ZL].[SP_ValidarSerieLinceClasificacionArticulo]
	ENDTEXT
	goServicios.Datos.EjecutarSQL( lcTexto )

	TEXT to lcTexto noshow
		CREATE PROCEDURE [ZL].[SP_ValidarSerieLinceClasificacionArticulo]
			@Serie varchar(7), @Articulo varchar(13)
		AS
		BEGIN
			select convert(bit, 1) as Retorno
		END
	ENDTEXT
	goServicios.Datos.EjecutarSQL( lcTexto )
Endfunc

*-----------------------------------------------------------------------------------------
function CrearFuncion_func_NormalizarNombre() as Void
	Local  lcSQL as String 

	text to lcSQL noshow
		IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[func_NormalizarNombre]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
		DROP FUNCTION [ZL].[func_NormalizarNombre]
	endtext
	
	goServicios.Datos.EjecutarSQL( lcSQL )
	
	text to lcSQL noshow
		CREATE FUNCTION [ZL].[func_NormalizarNombre]
				(@Texto varchar(max))
			RETURNS VARCHAR(MAX) AS
			BEGIN

				declare @Text varchar(max) = ltrim(rtrim((case when @Texto is null then '' else lower(replace(@Texto, '.', '')) end)))
				while charindex('  ', @Text) > 0
					begin
						set @Text = replace(@Text, '  ', ' ')
					end
				declare @LastTextIndex int = (select charindex(' ', reverse(@Text))), @LastText varchar(max) = ''
				declare @New varchar(max) = ''
				declare @Index int = 1, @Len int = len(@Text)

				while (@Index <= @Len)
					begin
						if (substring(@Text, @Index, 1) like '[^a-z]' and @Index + 1 <= @Len)
							begin
								select @New = @New + upper(substring(@Text, @Index, 2)), @Index = @Index + 2
							end
						else
							begin
								select @New = @New + substring(@Text, @Index, 1), @Index = @Index + 1
							end
					end

				set @New = (upper(left(@New, 1)) + right(@New, abs(@Len - 1)))
				set @LastText = right(lower(@New), abs(@Len - (@Len - @LastTextIndex + 1)))
				set @New =
					case
						when @LastText = 'sa' then left(@New, @Len - @LastTextIndex + 1) + 'S.A.'
						when @LastText = 'srl' then left(@New, @Len - @LastTextIndex + 1) + 'S.R.L.'
						when @LastText = 'sas' then left(@New, @Len - @LastTextIndex + 1) + 'S.A.S.'
						else @New
					end

				return ltrim(rtrim(@New))

			END
		endtext
		
		goServicios.Datos.EjecutarSQL( lcSQL )

endfunc

*-----------------------------------------------------------------------------------------
Function CrearFuncion_funcCOMEsquemaComisionalVigentePorRazonSocial
	Local lcTexto

	TEXT to lcTexto noshow
		IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[funcCOMEsquemaComisionalVigentePorRazonSocial]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
		DROP FUNCTION [ZL].[funcCOMEsquemaComisionalVigentePorRazonSocial]
	endtext
	goServicios.Datos.EjecutarSQL( lcTexto )
		
	TEXT to lcTexto noshow
		CREATE FUNCTION [ZL].[funcCOMEsquemaComisionalVigentePorRazonSocial]
		(	
		)
		RETURNS TABLE 
		AS
		RETURN 
		(
		select 
				E.Ccod as Esquema ,
				E.Descr as Descripcion,
				Nrz    as RazonSocial ,
				case when (e.INACTIVOFW = 1 Or isnull(l.activo,1) = 0) then 1 else 0 end as Inactivo ,
				case when (e.INACTIVOFW = 1 Or isnull(l.activo,1) = 0) then 'Inactivo' else 'Activo' end as Estado,
				e.dueno as Duenio,
				l.Ccortesia as DescripcionDuenio
				--,	ASESCOMAC.Asignacion as Asignacion
			from ZL.esqcom E
			left join (select Nrz, CREGIMEN, Numero as Asignacion  from zl.ASESCOMAC 
							where NUMERO in ( select max(numero)
								from zl.ASESCOMAC
								group by   Nrz
											)      
						) as ASESCOMAC on e.ccod = ASESCOMAC.CREGIMEN 
			join ZL.Legops l on l.ccod = e.dueno 
			)
	ENDTEXT
	goServicios.Datos.EjecutarSQL( lcTexto )
	
endfunc
