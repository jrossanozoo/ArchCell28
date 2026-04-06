**********************************************************************
Define Class zTestNocturnosZlBajaDeServicios as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as zTestNocturnosZlBajaDeServicios of zTestNocturnosZlBajaDeServicios.prg
	#ENDIF

	cArchivoMock1 = ""
	cArchivoMockZlServiciosLoteBaja = ""
	CodDireccion = ""
	ldFechaAnterior = ""
	
	*---------------------------------
	Function Setup
		local loEntidad as entidad OF entidad.prg
	
		loEntidad = _screen.zoo.instanciarentidad( "Talonario" )
		with loentidad
			try
				.Codigo = "ITEMSERCOD"
			catch to loError
				.nuevo()
				.Codigo = "ITEMSERCOD"
				.Numero = 1
				.Grabar()
			catch to loError
			finally
				.release()
			endtry
		endwith
		CrearFuncion_funcCOMEsquemaComisionalVigentePorCliente()
		CrearFuncion_funcObtenerArticulosNoVisiblesDeCliente()	
		CrearFuncion_funcCOMEsquemaComisionalVigentePorRazonSocial()
		CrearSP_SP_ValidarSerieLinceClasificacionArticulo()
		CrearFuncion_func_NormalizarNombre()
		CrearFuncion_funcArticuloConModuloActivacionOnLine()
		this.ldFechaAnterior = set("date")
		set date to DMY
	EndFunc

	*---------------------------------
	Function TearDown
		set date to (this.ldFechaAnterior)
	endfunc
	
	*---------------------------------
      function zTestSqlServerZLBAJADESERVICIOS
	
		local loRazonSocial as Object, loCliente as Object, loZlServiciosLote as Object, loArticulo as Object,;
			  loProducto as Object, ldFechaBaja as Date, loTalonario as Object, loModulos as Object, lcProductoZL as String,;
			  loClasificacionCte as Object, loClasificacionv2 as Object, loSerie as Object, loBajaDeServicios as Object,;
			  lnNroItemServicio1  as Integer, loItemServicio as Object, ldFechaDeVigencia as date, lnNumeroDeBaja as Integer,;
			  loEntidad as Custom, loPais as Object, loProvincia as Object, lcolClasificaciones as zoocoleccion OF zoocoleccion.prg

		private gomensajes as Object
		_screen.mocks.agregarmock( "Mensajes" )
		_Screen.mocks.AgregarSeteoMetodo( "Mensajes", "Enviar", .T., '"No hay mas números de serie disponibles"' )
		goMensajes = _Screen.zoo.crearobjeto( "Mensajes" )


		this.CodDireccion = CrearDirecciones()
		
		loEntidad = newobject( "objEntidad" ) 
		
		this.agregarmocks( "ListadePrecios,Valor,Direcciones,Actualizarzoo,estadov2,ZLASIGESTADOSRZADM,contactos, TIPOARTICULOITEMSERVICIO, ZLAMBITOSSERIE,zlaltagrupocom, TIPOMODULOS, LEGAJOOPS, COMMOTIVOBAJA, ESQUEMACOMISIONAL, zlClientes")

		_screen.mocks.agregarseteopropiedad("ESQUEMACOMISIONAL","CCOD",32)
		_screen.mocks.agregarseteopropiedad("ESQUEMACOMISIONAL","DESCRIP","Esquema")

		_screen.mocks.AgregarSeteoMetodo( 'zlclientes', 'Codigo_despuesdeasignar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'zlclientes', 'Obtenersentenciasupdate', '' )
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

		_screen.mocks.AgregarSeteoMetodo( 'zlasigestadosrzadm', 'razonsocial_access', loEntidad )
		_screen.mocks.AgregarSeteoMetodo( 'contactos', 'Codigo_despuesdeasignar', .T. ) 
		_screen.mocks.AgregarSeteoMetodo( 'MENSAJEENTIDAD', 'Advertir', .T., "[Se ha producido una excepción no controlada durante el proceso posterior a la grabación.Verifique el log de errores para mas detalles.]" ) 

		=CrearZlServiciosLoteBaja_Test( This )
	
		try
			=CrearZlServiciosLoteBaja_Test( this )
			_screen.Mocks.AgregarMock( 'ZlServiciosLoteBaja', forceext( this.cArchivoMockZlServiciosLoteBaja, '' ) )

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
				loTalonario.codigo = "ITEMSERCOD" 
			Catch To loError
				loTalonario.nuevo()
				loTalonario.codigo = "ITEMSERCOD"
				loTalonario.ENTIDAD = "ZLITEMSSERVICIOS"
				loTalonario.GRABAR()
			endtry 

			try
				loTalonario.codigo = "ZLCLASIFICACIONCLIENTES" 
			Catch To loError
				loTalonario.nuevo()
				loTalonario.codigo = "ZLCLASIFICACIONCLIENTES"
				loTalonario.GRABAR()
			endtry 
		
			loTalonario.RELEASE()

			loClasificacionv2 = _screen.zoo.instanciarentidad("Clasificacionv2")

			with loClasificacionv2
				Try
					loClasificacionv2.codigo = '99' 
				Catch To loError
					loClasificacionv2.nuevo()
					loClasificacionv2.codigo = '99'
					loClasificacionv2.nombre = 'Clasificacion 99'
					loClasificacionv2.GRABAR()
				endtry 

				Try
					loClasificacionv2.codigo = '39' 
				Catch To loError
					loClasificacionv2.nuevo()
					loClasificacionv2.codigo = '39'
					loClasificacionv2.nombre = 'Clasificacion 39'
					loClasificacionv2.GRABAR()
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
			endwith 
			loModulos.release()
			
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
					.detalleclasificaciones.oitem.clasificacion_pk = '99'
					.detalleclasificaciones.oitem.detalleclasificacion = '99'
					.detalleclasificaciones.actualizar()
					.grabar()
				endtry 

				try
					.codigo = '00-AA'
				catch
				finally 
					.modificar()
					.detalleclasificaciones.oitem.clasificacion_pk = '39'
					.detalleclasificaciones.oitem.detalleclasificacion = '39'
					.detalleclasificaciones.actualizar()
					.grabar()
				endtry 
			endwith 

			
			_screen.mocks.AgregarSeteoMetodo( 'zlclientes', 'Codigo_despuesdeasignar', .T. )
			_screen.mocks.AgregarSeteoMetodo( 'zlclientes', 'Enlazar', .T., "[*COMODIN],[*COMODIN]" ) 
			_screen.mocks.AgregarSeteoMetodo( 'zlclientes', 'Modificar', .T. )
			_screen.mocks.AgregarSeteoMetodo( 'zlclientes', 'Cambiosdetalledetalleclasificaciones', .T. )
			_screen.mocks.AgregarSeteoMetodo( 'zlclientes', 'Grabar', .T. ) 
			_screen.mocks.AgregarSeteoMetodo( 'zlclientes', 'Nuevo', .T. ) 
			_screen.mocks.agregarseteopropiedad("ZLCLIENTES","CODIGO","00001")
			_screen.mocks.agregarseteopropiedad("ZLCLIENTES","direcc_pk",this.CodDireccion)
			_screen.mocks.agregarseteopropiedad("ZLCLIENTES","nombre", "cliente test cambioRZ")

			loCliente = _screen.zoo.instanciarentidad( "ZLCLIENTES" )
				
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
					.detalleclasificaciones.oitem.CodClasifi_pk = '99'
					.detalleclasificaciones.Actualizar()
					.grabar()
				endtry
			endwith
				
			 lcolClasificaciones = _screen.zoo.crearobjeto( "zooColeccion" )
			 lcolClasificaciones.agregar( "99" )
			 _screen.mocks.AgregarSeteoMetodo( 'zlclientes', 'Obtenerclasificaciones', lcolClasificaciones )
					
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

			loRazonSocial = _Screen.zoo.Crearobjeto( "ZLRazonSociales_AUX", "zTestNocturnosZlBajaDeServicios.prg" ) 

			with loRazonSocial
				.nuevo()
				.descripcion = 'rz test'
				.listadeprecios_pk = '99999'
				.cliente_pk = loCliente.codigo
				.SituacionFiscal_Pk = 1
				.cuit = '11111111113'
				.FormaDePago_pk = 'EFE'
				.direcc_pk = this.CodDireccion
				.reGIMENCOMISION = 32
				.VersionSistema = 88.88
				.Direccion = "Direccion de prueba"
				.Provincia_pk = "00"
				.grabar()
			endwith 

			loZlServiciosLote = _screen.zoo.Crearobjeto( "ZLSERVICIOSLOTE_AUX", "zTestNocturnosZlBajaDeServicios.prg" )
			loZlServiciosLote.oValidacionesEstadoRazonSocial = newobject( "ValidacionesEstadoRazonSocial_Aux" )

			with loZlServiciosLote
				 .nuevo()
				 .RazonSocial_pk = loRazonSocial.Codigo
				 .contacto_pk = '01'
				 .subitems.oitem.Serie_Pk = '507000'
				 .subitEMS.oiteM.CCLASIFICACION = "99"
				 .subitems.oitem.Articulo_pk = '00-AA'
				 ldFechaDeVigencia = .subitems.oitem.FechaAltaVigencia
				 .subitems.Actualizar()
				.grabar()
			endwith
			loZlServiciosLote.release()
			
			loItemServicio = _screen.zoo.instanciarentidad( "zlitemsservicios" )
			with loItemServicio
				.ultimo()
				lnNroItemServicio1 = .codigo
			endwith		

			loBajaDeServicios = _screen.zoo.instanciarentidad( "ZLSERVICIOSLOTEbaja" )
			with loBajaDeServicios 
				 .nuevo()
				 .regpor_pk = 'ADMIN'
				 .RazonSocial_pk = loRazonSocial.codigo
				 .Contacto_pk = "01"
				 .MotivoBaja_pk = "01"
				 loItemBaja = .subitems.oitem
				 loItemBaja.nroitemserv_pk = lnNroItemServicio1
				 .subitems.Actualizar()
			try
	       		.grabar()
	       		lnNumeroDeBaja = alltrim( STR( int ( .Numero ) ) )
	         	catch to loerror 
	         		this.asserttrue('Deberia haber grabado la baja',.F.) 
	         	finally
	       		endtry
	   		endwith 

			 loItemServicio.ultimo()

			 this.asserttrue( "La fecha de baja deberia estar completa" , !empty( loItemServicio.FechaBajaRegistro) ) 
			 this.asserttrue( "La Registracion de baja deberia estar completa" , !empty( loItemServicio.BajaRegPor_pk ) )
			 this.asserttrue( "La fecha de vigencia de baja deberia estar completa" , !empty( loItemServicio.FechaBajaVigencia ) )

			 this.assertequals( "El numero de comprobante de baja no es la correcta", lnNumeroDeBaja, alltrim( loItemServicio.RelaLoteBaja ) )

			 if ( day( ldFechaDeVigencia ) > 15 )
				ldFechaDeVigencia = ( gomonth( ldFechaDeVigencia-Day( ldFechaDeVigencia )+1, 2 ) - 1 )
			 else
				ldFechaDeVigencia = ( gomonth( ldFechaDeVigencia-Day( ldFechaDeVigencia )+1, 1 ) - 1 )
			 endif

			 this.assertequals( "La fecha de vigencia de baja no es la correcta" , loItemServicio.FechaBajaVigencia, ldFechaDeVigencia )

		catch to loError
  				throw loError
		finally
		
			if VARTYPE(loBajaDeServicios) = 'O' AND !isnull(loBajaDeServicios)
				loBajaDeServicios.release()
			endif
			
			if VARTYPE(loRazonSocial) = 'O' AND !isnull(loRazonSocial)
				loRazonSocial.release()
			ENDIF

			if VARTYPE(loClasificacionCte) = 'O' AND !isnull(loClasificacionCte)
				loClasificacionCte.release()
			ENDIF

  			if VARTYPE(loCliente) = 'O' AND !isnull(loCliente)
				loCliente.release()
			ENDIF

  		  	if VARTYPE(loArticulo) = 'O' AND !isnull(loArticulo)
				loArticulo.release()
			ENDIF
  				
   		  	if VARTYPE(loClasificacionCte) = 'O' AND !isnull(loClasificacionCte)
				loClasificacionCte.release()
			ENDIF

  		  	if VARTYPE(loBajaDeServicios) = 'O' AND !isnull(loBajaDeServicios)
				loBajaDeServicios.release()
			ENDIF

   			if VARTYPE(loSerie) = 'O' AND !isnull(loSerie)
				loSerie.release()
			ENDIF

  			if VARTYPE(loPais) = 'O' AND !isnull(loPais)
				loPais.release()
			ENDIF
  				
   			if VARTYPE(loProvincia) = 'O' AND !isnull(loProvincia)
				loProvincia.release()
			endif
			
   			if VARTYPE(lcolClasificaciones) = 'O' AND !isnull(lcolClasificaciones)
				lcolClasificaciones.release()
			endif
			
			if VARTYPE(loItemBaja) = 'O' AND !isnull(loItemBaja)
				loItemBaja.release()
			endif
			
  			if VARTYPE(loItemServicio) = 'O' AND !isnull(loItemServicio)
				loItemServicio.release()
			endif

			=BorrarItemZlserviciosloteSubitems_Test( this )
			=BorrarZlServiciosLoteBaja_Test( this )
			goMensajes = _Screen.zoo.app.oMensajes
			
		endtry
		if VARTYPE(loEntidad) = 'O' AND !isnull(loEntidad)
			loEntidad.release()
		ENDIF

     endfunc

EndDefine

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

define class serieTest as ent_zlseries of ent_zlseries.prg
	cNumeroSugeridoTest = ''
	function ObtenerNumeroString() as String
		return this.cNumeroSugeridoTest 
	endfunc

enddefine

*--------------------------------------------------------------------------------------------------

function CrearItemZlserviciosloteSubitems_Test( toFxuTestCase as Object ) as Void

	local lcContenido as String 
	
	toFxuTestCase.cArchivoMock1 = ObtenerNombreDeArchivoItemZlserviciosloteSubitems_Test()

	text to lcContenido textmerge noshow
	*--------------------------------------------------------------------------------------------------
	define class <<justfname( forceext( toFxuTestCase.cArchivoMock1, '' ) )>> as ItemZlserviciosloteSubitems of ItemZlserviciosloteSubitems.prg

		*-----------------------------------------------------------------------------------------
		function Init() as Void
			dodefault()
			this.oValidacionDeArticulos = newobject( 'ValidacionDeArticulos_Aux' )			
		endfunc 
				
		function ValidaArticuloCentralizador
			return .t.
		endfunc

	enddefine
	endtext

	strtofile( lcContenido, toFxuTestCase.cArchivoMock1, 0)

endfunc 

*--------------------------------------------------------------------------------------------------

function ObtenerNombreDeArchivoItemZlserviciosloteSubitems_Test() as string
	local lcArchivo as String 
	lcArchivo = addbs( _screen.Zoo.ObtenerRutaTemporal() ) + 'Mock_ItemZlserviciosloteSubitems_Test' + sys( 2015 ) + '.prg'
	return lcArchivo
endfunc 

*-----------------------------------------------------------------------------------------
function BorrarItemZlserviciosloteSubitems_Test( toFxuTestCase as Object )
	local lcArchivo as String 
	lcArchivo = toFxuTestCase.cArchivoMock1
	delete file ( lcArchivo )
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
		catch to loError	
		finally 
			.Release()
		endtry 	
	endwith 
	
	loent = null
	loent1 = _Screen.zoo.instanciarentidad( 'TIPODIRECCIONES' )	

	with loent1
	
		try 
			.cCod = '01'
			.Eliminar()
		catch to loError
		endtry 
			
		try 
			.NUEVO()
			.cCod = '01'
			.Descrip = 'Tipo 1'
			.grabar()
		catch to loError
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
		catch to loError
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
			.TIPO_PK = '01'
			.Pais_pk = 'AR'
			.Grabar()
		catch to loError
		finally
			.Ultimo()
			lcCodRetorno = .Codigo
			.Release()
		endtry 	
			
	endwith 

	loent3 = null

	return lcCodRetorno
	
endfunc 

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
	function ValidarEsquemaActivo( txVal ) as boolean
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

********************************************************************************************
define class ValidacionDeArticulos_Aux as Custom

	*-----------------------------------------------------------------------------------------
	function ValidarArticuloPorSerie( tRazonSocial as String, tSerie as String, tArticulo as String ) as Boolean
		return .t.
	endfunc 

enddefine

*!*	********************************************************************************************
*!*	define class ItemZlserviciosloteSubitems_Aux as Din_ItemZlserviciosloteSubitems of Din_ItemZlserviciosloteSubitems.prg

*!*		*-----------------------------------------------------------------------------------------
*!*		protected function ValidacionesDeArticulos() as Boolean
*!*			return .t.
*!*		endfunc
*!*		
*!*	enddefine
*----------------------------------------------------------------
define class ZLSERVICIOSLOTE_AUX as ent_ZLSERVICIOSLOTE of ent_ZLSERVICIOSLOTE.PRG

	*-----------------------------------------------------------------------------------------
	function CrearCuentaComunicaciones() as Void
		nodefault
	endfunc

enddefine

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

*--------------------------------------------------------------------------------------------------
Function CrearZlServiciosLoteBaja_Test( toFxuTestCase As Object )
	Local lcContenido As String, lcSQL as String 

	toFxuTestCase.cArchivoMockZlServiciosLoteBaja = ObtenerNombreDeArchivoZlServiciosLoteBaja_Test()

	TEXT to lcContenido textmerge noshow
		*--------------------------------------------------------------------------------------------------
		define class <<justfname( forceext( toFxuTestCase.cArchivoMockZlServiciosLoteBaja, '' ) )>> as Ent_ZlServiciosLoteBaja of Ent_ZlServiciosLoteBaja.prg
			function TieneModuloeHost( tcArticulo as String ) as Boolean
				return .t.
			endfunc
		enddefine
	ENDTEXT

	Strtofile( lcContenido, toFxuTestCase.cArchivoMockZlServiciosLoteBaja, 0)
	
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
	
	goServicios.Datos.EjecutarSql( lcSQL )
	
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
		
		goServicios.Datos.EjecutarSql( lcSQL )

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
