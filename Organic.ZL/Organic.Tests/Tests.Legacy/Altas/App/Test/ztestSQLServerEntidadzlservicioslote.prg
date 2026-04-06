**********************************************************************
Define Class ztestSQLServerEntidadzlservicioslote As FxuTestCase Of FxuTestCase.prg

	#If .F.
		Local This As ztestSQLServerEntidadzlservicioslote Of ztestSQLServerEntidadzlservicioslote.prg
	#Endif

	lcValorSugeridoContrato = ''
	cClasificcacionDefaultParaClientes = ""

	cArchivoMockZlserviciosloteSubitems = ""
	cArchivoMockZlServiciosLoteBaja = ""	
	CodDireccion = ""
		
	*---------------------------------
	Function Setup
		local loEntidad as entidad OF entidad.prg
		

		this.lcValorSugeridoContrato = goparametros.zl.vALORESSUGERIDOS.ALTADESERVICIOCONTRATODEFAULT 
		this.cClasificcacionDefaultParaClientes = goServicios.Parametros.zl.altas.valorsugeridoparaclasificaciondeclientes
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

		CrearFuncion_funcObtenerArticulosNoVisiblesDeCliente()
		=BlanquearTablas()
		CrearFuncion_FuncObtenerTipoUsuarioZLAD()
		CrearFuncion_func_NormalizarNombre()
		CrearFuncion_funcArticuloConModuloActivacionOnLine()
	Endfunc

	*---------------------------------
	Function TearDown
		goparametros.zl.vALORESSUGERIDOS.ALTADESERVICIOCONTRATODEFAULT = this.lcValorSugeridoContrato 
		goServicios.Parametros.zl.altas.valorsugeridoparaclasificaciondeclientes = this.cClasificcacionDefaultParaClientes 
		
		=BlanquearTablas()
	Endfunc

	*---------------------------------
	function zTestSQLServerBotonesModificarAnular
		local oLote as Object 
	
		oLote = GOFORMULARIOS.procesar('ZLSERVICIOSLOTE')    
		
		this.asserttrue( "No deberia existir el Botón Modificar", !pemstatus( oLote.oTOOLBAR,  "Barra_Modificar", 5 ) )
		this.asserttrue( "No deberia existir el Botón Eliminar", !pemstatus( oLote.oTOOLBAR,  "Barra_Eliminar", 5 ) )

		this.asserttrue( "No deberia existir el Botón Modificar", !pemstatus( oLote.oMenu.mENU_ARCHIVO ,  "Menu_Modificar", 5 ) )
		this.asserttrue( "No deberia existir el Botón Eliminar", !pemstatus( oLote.oMenu.mENU_ARCHIVO,  "Menu_Eliminar", 5 ) )
		
		oLote.release()
							
	endfunc 
      
	*-----------------------------------------------------------------------------------------
	function zTestSQLServerZLSERVICIOSLOTE
	local loLote as Object, loItem as Object, loerror as Exception, loEntItemSer as Object, loEntRela as Object, loSeries as Object, ;
		ldFecha as Date, loEntidadItemEsqComision as Object, lnCodigoItem as Integer, llTalonario as Boolean, loArticulos as Object, ;
		loex as Object, loEntidad as Custom, loZLTIPOUSUARIOZL , loLegajoops 

		private gomensajes as Object
		_screen.mocks.agregarmock( "Mensajes" )
		_Screen.mocks.AgregarSeteoMetodo( "Mensajes", "Enviar", .T., '"No hay mas números de serie disponibles"' )
		goMensajes = _Screen.zoo.crearobjeto( "Mensajes" )

		loError = null

		=CrearItemZlserviciosloteSubitems_Test( this )
		=CrearZlServiciosLoteBaja_Test( this )
		=CrearFuncionAdmEstadoRS()
		=crearfuncObtenerEsquemaDeComision()
		this.CodDireccion = CrearDirecciones()

		try
			_screen.Mocks.AgregarMock( 'ItemZlserviciosloteSubitems', forceext( this.cArchivoMockZlserviciosloteSubitems, '' ) )
			_screen.Mocks.AgregarMock( 'ZlServiciosLoteBaja', forceext( this.cArchivoMockZlServiciosLoteBaja, '' ) )

			ldFecha = date()	
	        this.agregarmocks("ZlRazonSociales,ContratoV2,ZLSeriesTI,ProductoZL,ActualizarZoo,TipoArticuloItemServicio,ZLAmbitosSerie,direcciones,Contactos") 
	        
			_screen.mocks.AgregarSeteoMetodo( 'ActualizarZoo', 'Inicializar', .T. )
	        _screen.mocks.AgregarSeteoMetodo( 'ZlRazonSociales', 'Levantarexcepciontexto', .T., "[El dato buscado 12345 de la entidad ZLRAZONSOCIALES no existe.],9001" ) 
	        _screen.mocks.AgregarSeteoMetodo( 'ZlRazonSociales', 'Codigo_despuesdeasignar', .T. ) 
			_screen.mocks.AgregarSeteoMetodo( 'TipoArticuloItemServicio', 'Ccod_despuesdeasignar', .T. )
			_screen.mocks.AgregarSeteoMetodo( 'ZlRazonSociales', 'Nuevo', .T. )
			_screen.mocks.AgregarSeteoMetodo( 'ZlRazonSociales', 'Validar_Cliente', .T. )
			_screen.mocks.AgregarSeteoMetodo( 'ZlRazonSociales', 'Grabar', .T. )
			_screen.mocks.AgregarSeteoMetodo( 'ZlRazonSociales', 'Eventocambiosituacionfiscal', .T. )
			_screen.mocks.AgregarSeteoMetodo( 'ActualizarZoo', 'Finalizar', .T. )
			_screen.mocks.AgregarSeteoMetodo( 'ActualizarZoo', 'Migrarclientes', .T., "[*COMODIN],[*COMODIN]" )
			_screen.mocks.AgregarSeteoMetodo( 'ZlRazonSociales', 'Enlazar', .T., "[Cliente.EventoObtenerLogueo],[inyectarLogueo]" ) 
			_screen.mocks.AgregarSeteoMetodo( 'ZlRazonSociales', 'Enlazar', .T., "[Cliente.EventoObtenerInformacion],[inyectarInformacion]" ) 
			_screen.mocks.AgregarSeteoMetodo( 'Contactos', 'Codigo_despuesdeasignar', .T. ) 
			_screen.mocks.AgregarSeteoMetodo( 'ZlRazonSociales', 'Cliente_pk_despuesdeasignar', .T. ) 
			_screen.mocks.AgregarSeteoMetodo( 'ZlRazonSociales', 'Validar_Regimencomision', .T., "[*COMODIN],[*COMODIN]" )
			_screen.mocks.AgregarSeteoMetodo( 'ZlRazonSociales', 'ValidarEsquemaActivo' , .T., "[*COMODIN]" )

			
			loEntidad = newobject( "objEntidad" ) 
			_screen.mocks.AgregarSeteoMetodo( 'ZlRazonSociales', 'Cliente_access', loEntidad )

			_screen.mocks.AgregarSeteoMetodoAccesoADatos( 'Zlseries', 'Cargar', .T. )
			_screen.mocks.AgregarSeteoMetodoAccesoADatos( 'Zlseries', 'Eliminar', .T. )
			
			loZLTIPOUSUARIOZL = _Screen.zoo.instanciarentidad( "ZLTIPOUSUARIOZL" )
			With loZLTIPOUSUARIOZL 
				Try
					.cCod = '1'
					.Eliminar()
				Catch
				Endtry
				Try
					.nuevo()
					.cCod = '1'
					.Descrip = 'desc' + Sys( 2015 )
					.grabar()
				catch				
				Endtry
				.Release()
			Endwith
			loZLTIPOUSUARIOZL = Null		
			
			loLegajoops = _Screen.zoo.instanciarentidad( "Legajoops" )
			With loLegajoops 
				Try
					.Codigo = '01'
					.Eliminar()
				Catch
				Endtry
				Try
					.nuevo()
					.Codigo = '01'
					.Cortesia = 'desc' + Sys( 2015 )
					.tipousuarioZL_pk = '1'
					.UsuarioActivo = .t.
					.grabar()
				catch			
				Endtry
				.Release()
			Endwith
			loLegajoops = Null	
			
			loEsquemaComisional = _Screen.zoo.instanciarentidad( "Esquemacomisional" )
			With loEsquemaComisional
				Try
					.cCod = 32
					.Eliminar()
				Catch
				Endtry
				Try
					.nuevo()
					.cCod = 32
					.Descrip = 'Esquema de prueba ' + Sys( 2015 )
					.Owner_Pk = '01'
					.grabar()
				catch 				
				Endtry
			Endwith
			loEsquemaComisional.Release()
			loEsquemaComisional = Null
			
			loSeries = createobject( "serietest" )
			with loSeries
				try
					.nroserie = '407000'
					.eliminar()
				catch to loError

				finally
					.cNumeroSerieTest = '407000'
					.Nuevo()
					.Clave = '10-10-10'
					.Nombre = 'Prueba'
					.Direcc_pk = '01'
					.Ambito_pk = '01'
					.ProductoZoologic_pk = '01'
					.Grabar()
					.Release()
				endtry
			endwith

			loSeries = createobject( "serietest" )
			with loSeries
				try
					.nroserie = '407001'
					.eliminar()
				catch to loError
				finally
					.cNumeroSerieTest = '407001'
					.Nuevo()
					.Clave = '10-10-10'
					.Nombre = 'Prueba 2'
					.Direcc_pk = '01'
					.Ambito_pk = '01'
					.ProductoZoologic_pk = '01'
					.Grabar()
					.Release()
				endtry
			endwith

			*------------------------------------------------------------------------------------------------------
			local loEntidad as entidad OF entidad.prg
			******************************** ALTA DE CLASIFICACION ************************
			loEntidad = _Screen.zoo.instanciarentidad( "CLASIFICACIONV2" )
			with loEntidad
				try
					.Codigo = "00"
					.Eliminar()
				catch
				endtry
				.Nuevo()
				.Codigo = "00"		
				.Nombre = "Minorista"
				.Grabar()

				try
					.Codigo = "01"
					.Eliminar()
				catch
				endtry
				.Nuevo()
				.Codigo = "01"		
				.Nombre = "Grandes Clientes"
				.Grabar()


				try
					.Codigo = "02"
					.Eliminar()
				catch
				endtry
				.Nuevo()
				.Codigo = "02"		
				.Nombre = "Otros Clientes"
				.Grabar()
				
				.Release()
			endwith
			goServicios.Parametros.zl.altas.valorsugeridoparaclasificaciondeclientes = "01"

			local loClasificacionv2 as Object
			loClasificacionv2 = _screen.zoo.instanciarentidad( "Clasificacionv2" )
			with loClasificacionv2
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

			loArticulos = _screen.zoo.instanciarentidad( "zlisarticulos" )
			with loArticulos
				try
					.Codigo = '00-AB'
					.Eliminar()
				catch to loError
				finally
					.Nuevo()
					.Codigo = '00-AB'
					.Descrip = 'Prueba'
					.TipoArticulo_pk = 'AB'
					.Desactivado = .F.
					.ProductoZoologic_pk = '01'
					.DetalleClasificaciones.oItem.Clasificacion_pk = '00'
					.DetalleClasificaciones.oItem.detalleClasificacion = '00 test'
					.DetalleClasificaciones.Actualizar()
					.Grabar()
				endtry

				try
					.Codigo = '00-AC'
					.Eliminar()
				catch to loError
				finally
					.Nuevo()
					.Codigo = '00-AC'
					.Descrip = 'Prueba'
					.TipoArticulo_pk = 'AB'
					.Desactivado = .F.
					.ProductoZoologic_pk = '01'
					.DetalleClasificaciones.oItem.Clasificacion_pk = '01'
					.DetalleClasificaciones.oItem.detalleClasificacion = 'cli test'
					.DetalleClasificaciones.Actualizar()
					.Grabar()
				endtry
				
				try
					.Codigo = '00-TI'
					.Eliminar()
				catch to loError
				finally
					.Nuevo()
					.Codigo = '00-TI'
					.Descrip = 'Prueba TI'
					.TipoArticulo_pk = 'TI'
					.Desactivado = .F.
					.ProductoZoologic_pk = '01'
					.DetalleClasificaciones.oItem.Clasificacion_pk = '01'
					.DetalleClasificaciones.oItem.detalleClasificacion = 'cli test'
					.DetalleClasificaciones.Actualizar()
					.Grabar()
					.Release()
				endtry
			endwith

			******************************** ALTA DE CLIENTE ************************
			local lcCodigoCli as string
			loEntidad = _Screen.zoo.instanciarentidad( "ZLClientes" )
			with loEntidad
				try
					.Nuevo()
					this.assertequals( "La Cantidad de item del detalle de clasificacion deberia ser DOS, ya que debe ingresar la clasificacion DEFAULT.", 2, .DetalleClasificaciones.Count )				
					lcCodigoCli = .Codigo				
					with .DetalleClasificaciones
						.LimpiarItem()
						.oItem.codclasifi_pk = "02"
						.Actualizar()
					endwith
					this.assertequals( "La Cantidad de item del detalle de clasificacion deberia ser TRES, ya que se ingreso otra clasificacion.", 3, .DetalleClasificaciones.Count )				
					.direcc_pk = this.CodDireccion
					.Nombre = 'Cli' + sys(2015)
					.Grabar()
					.Release()
				catch to loError
					this.asserttrue( 'no Deberia haber dado error al dar de alta el cliente.', .f. )
				endtry
			endwith
			*------------------------------------------------------------------------------------------------------
			local lcMensaError as string
			
			llTalonario = CargarTalonarios()

			if llTalonario
				loEntidadItemEsqComision = _Screen.zoo.instanciarentidad( "COMASIGITEMSERESQCOM" )
				loEntidadItemEsqComision.ultimo()
				lnCodigoItem = loEntidadItemEsqComision.numero
				loLote = _screen.zoo.Crearobjeto( "ZLSERVICIOSLOTE_AUX", "ztestSQLServerEntidadzlservicioslote.prg" )
 		        
				with loLote 
					 .oValidacionesEstadoRazonSocial = newobject( "ValidacionesEstadoRazonSocial_Aux" )
			         .nuevo()
			         .razonSocial.Cliente_pk = lcCodigoCli
			         .RazonSocial_pk = '12345'                         
			         .cliente_pk = lcCodigoCli
			         .Contacto_PK = '01'
			         loItem = .subitems.oitem
			         loItem.serie_pk = '407000'

			         try
				         loitem.Articulo_pk = '00-AB'
				         this.assertequals( "El Articulo con clasificion diferente a las del cliente no dio error", .F. )
				     catch to loError
				     	lcMensaError = loError.UserValue.oInformacion.Item[1].cMensaje
				     	this.assertequals( "El mensaje de clasificacion invalida del item es incorrecto. ", "Las clasificaciones (00) del artículo 00-AB no coinciden con las del cliente (01, 37, 02).", lcMensaError )
				     endtry

			         _screen.mocks.agregarseteometodo( "zlisarticulos", "TieneModuloTI", .t. )
			         .subitems.LimpiarItem()
			         with loItem
				         .serie_pk = '407000'
				         .Articulo_pk = '00-AC'
				         .serieTI_pk = '101001'
				         .FechaAltaVigencia = ldFecha +1
					     .PRODUCTOZOOLOGIC_PK = '8888'
				         .PRODUCTOZOOLOGICDetalle = 'DETALLE8'
				     endwith
			         .subitems.Actualizar()
			         .subitems.LimpiarItem()
			         with loItem		         
				         .serie_pk = '407001'
				         .Articulo_pk = '00-TI'
				         .serieTI_pk = '101002'
				         .FechaAltaVigencia = ldFecha
					     .PRODUCTOZOOLOGIC_PK = '8888'
				         .PRODUCTOZOOLOGICDetalle = 'DETALLE8'
			        endwith
			         .subitems.Actualizar()
			         
					try
		         		.grabar()
		         	catch to loex 
		         		this.asserttrue('Deberia haber grabado',.F.) 
		         	finally
		         	endtry
		        endwith 

				try
				 loLote.numero = 2
	         	 loLote.eliminar()
		        endtry

				loLote.release()
				loEntidadItemEsqComision.release() 
			else
				this.asserttrue( "Pinchó en la generación del talonario", .f. )
			endif 
		catch to loError
			throw loError
		finally
			=BorrarItemZlserviciosloteSubitems_Test( this )
			=BorrarZlServiciosLoteBaja_Test( this )
			goMensajes = _Screen.zoo.app.oMensajes
		endtry
     endfunc

	*-----------------------------------------------------------------------------------------
	function zTestSQLServerAsignarValorSugeridos
		local loEntidad as entidad OF entidad.prg
		
		if CargarTalonarios()
			This.agregarmocks( "zlseries,ZLALTAGRUPOCOM, PRODUCTOZL, ZLClientes, CLASIFICACIONV2" )
			_screen.mocks.AgregarSeteoMetodo( 'zlaltagrupocom', 'Numero_despuesdeasignar', .T. )
			_screen.mocks.AgregarSeteoMetodo( 'zlclientes', 'Codigo_despuesdeasignar', .T. )
			_screen.mocks.AgregarSeteoMetodo( 'zlclientes', 'Obtenerclasificaciones', "02" )

			loEntidad = _Screen.zoo.instanciarentidad( "ZLSERVICIOSLOTE" )
			with loEntidad
				.Nuevo()
				.Cliente_Pk = "MAXI"
				with .Subitems.oItem
					.serie_pk = '407000'
					.GrupoCom_Pk = 01
				endwith
				This.assertequals( "Deberia cambiar el parametro.", "MAXI", alltrim( goParametros.Zl.ValoresSugeridos.ClienteSugeridoIS ) )
				
				.Release()
			endwith
		else
			this.asserttrue( "PINCHÓ EN LA GENERACIÓN DEL TALONARIO .5." , .f. )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestSQLServerGrillaDeshabilitadaAlHacerNuevo
		local loEntidad as Object
		
		loEntidad = _Screen.zoo.instanciarentidad( "ZlServiciosLote" )
		loEntidad.Nuevo()
		
		this.asserttrue( "El genhabilitar es incorrecto al hacer nuevo", !loEntidad.lHabilitarSubItems )
		
		loEntidad.Cancelar()
		loEntidad.Release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestSQLServerHabilitarGrillaAlSetearUnCliente
		local loEntidad as Object
		
		this.agregarmocks( "ZLCLIENTES" )
		_screen.mocks.AgregarSeteoMetodo( 'zlclientes', 'Codigo_despuesdeasignar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'zlclientes', 'Obtenerclasificaciones', .T. )

		loEntidad = _Screen.zoo.instanciarentidad( "ZlServiciosLote" )
		loEntidad.Nuevo()
		
		loEntidad.Cliente_pk = "10"
		
		this.asserttrue( "El genhabilitar es incorrecto al setear el cliente", loEntidad.lHabilitarSubItems )
		
		loEntidad.Cancelar()
		loEntidad.Release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestSQLServerDesHabilitarGrillaAlQuitarElCliente
		local loEntidad as Object
		
		this.agregarmocks( "ZLCLIENTES" )
		_screen.mocks.AgregarSeteoMetodo( 'zlclientes', 'Codigo_despuesdeasignar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'zlclientes', 'Obtenerclasificaciones', .T. )

		loEntidad = _Screen.zoo.instanciarentidad( "ZlServiciosLote" )
		loEntidad.Nuevo()
		
		loEntidad.Cliente_pk = "10"

		loEntidad.Cliente_pk = ""
		
		this.asserttrue( "El genhabilitar es incorrecto al setear el cliente", !loEntidad.lHabilitarSubItems )
		
		loEntidad.Cancelar()
		loEntidad.Release()
	endfunc 
enddefine


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


*--------------------------------
function CargarTalonarios() as Boolean 
	local loEntidad as entidad OF entidad.prg, llretorno as Boolean 
	llretorno = .t.

	
	loEntidad = _Screen.zoo.instanciarEntidad( "Talonario" )
	with loEntidad
		try
			.Codigo = "ALTASIS"
			.Eliminar()
		catch 

		endtry
	endwith 
	with loEntidad
		try
			.Nuevo()
			.Codigo = "ALTASIS"
			.entidad = "ZLSERVICIOSLOTE"
			.numero = 1
			.Grabar()
		catch to loerror
			llretorno = .f.
		finally
			.RELEASE()
		endtry
		loEntidad = null
		return 	llretorno
	endwith 
	
endfunc	


define class serietest as ent_zlseries of ent_zlseries.prg

	cNumeroSerieTest = ''

	function ObtenerNumeroString()
		return this.cNumeroSerieTest
	endfunc

enddefine

function BlanquearTablas
	Use In Select( "loteservicio" )

	Use In Select( "DetItemServicio" )

	*!*	 DRAGON 2028
	if _Screen.Zoo.App.lEsLocalDB = .t.
		goServicios.Datos.EjecutarSentencias( 'delete from loteservicio', 'loteservicio' )
		goServicios.Datos.EjecutarSentencias( 'delete from DetItemServicio', 'DetItemServicio' )
	endif
endfunc

*--------------------------------------------------------------------------------------------------
function CrearItemZlserviciosloteSubitems_Test( toFxuTestCase as Object )
	local lcContenido as String 
	
	toFxuTestCase.cArchivoMockZlserviciosloteSubitems = ObtenerNombreDeArchivoItemZlserviciosloteSubitems_Test()

	text to lcContenido textmerge noshow
			define class <<justfname( forceext( toFxuTestCase.cArchivoMockZlserviciosloteSubitems, '' ) )>> as ItemZlserviciosloteSubitems of ItemZlserviciosloteSubitems.prg
			function init() as Void
				dodefault()
				this.oValidacionDeArticulos = newobject( 'ValidacionDeArticulos_aux' )
			endfunc 			
			function ValidaArticuloCentralizador
				return .t.
			endfunc
			function Validar_Serie( txVal as variant, txValOld as variant ) as Boolean
				return .t.
			endfunc
		enddefine
	endtext

	strtofile( lcContenido, toFxuTestCase.cArchivoMockZlserviciosloteSubitems, 0)
endfunc

*--------------------------------------------------------------------------------------------------
function BorrarItemZlserviciosloteSubitems_Test( toFxuTestCase as Object )
	local lcArchivo as String 
	lcArchivo = toFxuTestCase.cArchivoMockZlserviciosloteSubitems
	delete file ( lcArchivo )
endfunc


*--------------------------------------------------------------------------------------------------
function ObtenerNombreDeArchivoItemZlserviciosloteSubitems_Test as String 
	local lcArchivo as String 
	lcArchivo = addbs( _screen.Zoo.ObtenerRutaTemporal() ) + 'Mock_ItemZlserviciosloteSubitems_Test' + sys( 2015 ) + '.prg'
	return lcArchivo
endfunc

*--------------------------------------------------------------------------------------------------
function CrearZlServiciosLoteBaja_Test( toFxuTestCase as Object )
	local lcContenido as String 
	
	toFxuTestCase.cArchivoMockZlServiciosLoteBaja = ObtenerNombreDeArchivoZlServiciosLoteBaja_Test()

	text to lcContenido textmerge noshow
		*--------------------------------------------------------------------------------------------------
		define class <<justfname( forceext( toFxuTestCase.cArchivoMockZlServiciosLoteBaja, '' ) )>> as Ent_ZlServiciosLoteBaja of Ent_ZlServiciosLoteBaja.prg
			function TieneModuloeHost( tcArticulo as String ) as Boolean
				return .t.
			endfunc

			function EjecutaSPDesactivaGrupoComunicacionesxSerie( tcSerie as String, tcFechaBaja as String ) as Void
			endfunc
			
			protected function Ejecuta_sp_AsignacionDeTareaADEVOPS_y_Alta_USUARIOS_DFCLOUD() as Void
				nodefault 
			endfunc			
		enddefine
	endtext

	strtofile( lcContenido, toFxuTestCase.cArchivoMockZlServiciosLoteBaja, 0)
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
define class objEntidad as Custom
	
	codigo = ''
	
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
			.cCod = '01'
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

****************************************************
Function CrearFuncionAdmEstadoRS
	Local lcSQL as String 
	
	text to lcSQL noshow
		IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[AdmEstadoRS]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
		DROP FUNCTION [ZL].[AdmEstadoRS]
	endtext
	
	goServicios.Datos.EjecutarSentencias( lcSQL , '' )	

	TEXT to lcSQL noshow
		CREATE function [ZL].[AdmEstadoRS] ( ) 
		returns table as return 
		(select zl.ASESTRZAD.nrz
                ,zl.ASESTRZAD.cestado
                ,rtrim(ltrim(zl.Estado.Nombre)) as [Estado RS Descripción]
                ,zl.Estado.Inclfac as [Facturable]
                ,case when IsNull(Ltrim(rtrim(zl.Estado.fRAENT)),'')='' then 0 else 1 end as [Dar Código]
                ,zl.Estado.Observmda as [Obtener Servicio MDA]
                ,zl.ASESTRZAD.fecha
 		    from zl.ASESTRZAD WITH (NOLOCK)
    	    inner join ( select nrz as RS, max(numero) as ultimoComprobante 
                       from zl.ASESTRZAD WITH (NOLOCK) group by nrz )   as RsUltimoEstado 
               on zl.ASESTRZAD.numero = RsUltimoEstado.ultimoComprobante 
            left join zl.Estado WITH (NOLOCK) on zl.ASESTRZAD.cestado = zl.Estado.codigo )
	ENDTEXT

	goServicios.daTOS.ejecutarsql( lcSQL )

Endfunc

*-----------------------------------------------------------------------------------------
function CrearfuncObtenerEsquemaDeComision() as Void

	Local  lcSQL as String 

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

Endfunc	


*----------------------------------------------------------------
define class ValidacionesEstadoRazonSocial_Aux as custom 
	*-----------------------------------------------------------------------------------------
	function Validar( txVal ) as Boolean
		return .t.
	endfunc 
enddefine 

*----------------------------------------------------------------
define class COMASIGITEMSERESQCOM_Aux as Ent_COMASIGITEMSERESQCOM of Ent_COMASIGITEMSERESQCOM.prg
	*-----------------------------------------------------------------------------------------
	function ValidarEsquemaActivo( txVal ) as boolean
		return .t.
	endfunc 
enddefine

*-----------------------------------
define class ValidacionDeArticulos_aux  as custom

	*-----------------------------------------------------------------------------------------
	function ValidarArticuloPorSerie( trazonsocial, tserie, tarticulo ) as Boolean
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
	function NoEsRazonSocialDePantera() as Boolean
		return .t.
	endfunc
		
enddefine


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
function CrearFuncion_func_NormalizarNombre() as Void
	Local  lcSQL as String 

	text to lcSQL noshow
		IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[func_NormalizarNombre]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
		DROP FUNCTION [ZL].[func_NormalizarNombre]
	endtext
	
	goServicios.Datos.EjecutarSentencias( lcSQL , '' )
	
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
		
		goServicios.Datos.EjecutarSentencias( lcSQL , '' )

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
