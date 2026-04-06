**********************************************************************
Define Class ztestNocturnosItemZlservicioslotebajaSubitems as FxuTestCase of FxuTestCase.prg

	#If .f.
		Local This as ztestNocturnosItemZlservicioslotebajaSubitems of ztestNocturnosItemZlservicioslotebajaSubitems.PRG
	#Endif
	
	cCodigoDeclasificacionSugeridad = ""
	cArchivoMock = ""
	CodDireccion = ""

	*---------------------------------
	Function Setup
		local loEntidad as entidad OF entidad.prg
		
		this.CodDireccion = CrearDirecciones()	
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
				throw loError 
			finally
				.release()
			endtry
		endwith
	
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
				.grabar()
			catch				
			Endtry
		Endwith
		loEsquemaComisional.Release()
		
		this.cCodigoDeclasificacionSugeridad = goServicios.Parametros.zl.altas.valorsugeridoparaclasificaciondeclientes
		CrearFuncion_funcObtenerArticulosNoVisiblesDeCliente()
		CrearFuncion_funcCOMEsquemaComisionalVigentePorCliente()
		CrearFuncion_funcCOMEsquemaComisionalVigentePorRazonSocial()
		CrearfuncObtenerEsquemaDeComision()
		CrearFuncion_func_NormalizarNombre()
		CrearFuncion_funcArticuloConModuloActivacionOnLine()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function TearDown()
		goServicios.Parametros = goParametros
		goServicios.Registry = goRegistry
		goServicios.Parametros.zl.altas.valorsugeridoparaclasificaciondeclientes = this.cCodigoDeclasificacionSugeridad
	endfunc

	*-----------------------------------------------------------------------------------------
	Function ztestSqlServerBajaLoteServicios
		Local loEntidad as Object, lcMensaje as String, lnCodigo as Integer, loErrorReintento as zooexception OF zooexception.prg, ;
			loError as zooexception OF zooexception.prg, llTalonario as Boolean, llExisteParam as Boolean, lcRZ1 as String, lcRZ2 as String, ;
			loSeries as Object, loArticulos as Object, loPais as Object, loProvincia as Object

		private goParametros
		private goRegistry

private gomensajes as Object
_screen.mocks.agregarmock( "Mensajes" )
_Screen.mocks.AgregarSeteoMetodo( "Mensajes", "Enviar", .T., '"No hay mas números de serie disponibles"' )
goMensajes = _Screen.zoo.crearobjeto( "Mensajes" )
		
		store null to loError, loEntidad, loSeries, loArticulos
		
		=CrearItemZlserviciosloteSubitems_Test( this )
		*!*	 DRAGON 2028
		set procedure to ( this.cArchivoMock ) additive
		try
			_screen.Mocks.AgregarMock( 'ItemZlserviciosloteSubitems', forceext( this.cArchivoMock, '' ) )

			This.agregarmocks( "ListaDePrecios, Direcciones, valor, PRODUCTOZL, Actualizarzoo, EstadoV2, ZlasigestadosrzADM, ZLAMBITOSSERIE,Contactos" )

			_screen.mocks.AgregarSeteoMetodo( 'ACTUALIZARZOO', 'Inicializar', .T. )
			_screen.mocks.AgregarSeteoMetodo( 'ACTUALIZARZOO', 'Migrarrazonsocial', .T., "[99999],[RazonSocial1],[99999],3.25" )
			_screen.mocks.AgregarSeteoMetodo( 'ACTUALIZARZOO', 'Migrarrazonsocial', .T., "[88888],[RazonSocial1],[88888],3.26" )
			_screen.mocks.AgregarSeteoMetodo( 'ACTUALIZARZOO', 'Migrarrazonsocial', .T., "[88888],[RazonSocial1],[88888],3.25" )
			_screen.mocks.AgregarSeteoMetodo( 'ACTUALIZARZOO', 'Finalizar', .T. )		
			
			_screen.mocks.AgregarSeteoMetodo( 'zlasigestadosrzadm', 'Nuevo', .T. ) 
			_screen.mocks.AgregarSeteoMetodo( 'zlasigestadosrzadm', 'Grabar', .T. )
			_screen.mocks.AgregarSeteoMetodo( 'zlasigestadosrzadm', 'Enlazar', .T., "[Razonsocial.EventoObtenerLogueo],[inyectarLogueo]" ) && ztestitemzlservicioslotebajasubitems.ztestbajaloteservicios 20/09/11 17:03:24
			_screen.mocks.AgregarSeteoMetodo( 'zlasigestadosrzadm', 'Enlazar', .T., "[Razonsocial.EventoObtenerInformacion],[inyectarInformacion]" ) && ztestitemzlservicioslotebajasubitems.ztestbajaloteservicios 20/09/11 17:03:24
			_screen.mocks.AgregarSeteoMetodo( 'zlasigestadosrzadm', 'Enlazar', .T., "[Estadorz.EventoObtenerLogueo],[inyectarLogueo]" ) && ztestitemzlservicioslotebajasubitems.ztestbajaloteservicios 20/09/11 17:03:25
			_screen.mocks.AgregarSeteoMetodo( 'zlasigestadosrzadm', 'Enlazar', .T., "[Estadorz.EventoObtenerInformacion],[inyectarInformacion]" ) && ztestitemzlservicioslotebajasubitems.ztestbajaloteservicios 20/09/11 17:03:25
			toEntidad = newobject( "objEntidad" ) 
			_screen.mocks.AgregarSeteoMetodo( 'zlasigestadosrzadm', 'razonsocial_access', toEntidad )			

			
			_screen.mocks.AgregarSeteoMetodoAccesoADatos( 'Zlseries', 'Cargar', .T. )
			_screen.mocks.AgregarSeteoMetodoAccesoADatos( 'Zlseries', 'Eliminar', .T. )
			
			_screen.mocks.AgregarSeteoMetodo( 'ACTUALIZARZOO', 'Migrarrazonsocial', .T., "[*COMODIN]" )
			
			_screen.mocks.AgregarSeteoMetodo( 'Direcciones', 'Nuevo', .T. )
			_screen.mocks.AgregarSeteoMetodo( 'Direcciones', 'buscar', .T. )
			_screen.mocks.AgregarSeteoMetodo( 'Direcciones', 'cargar', .T. )
			_screen.mocks.AgregarSeteoMetodo( 'Direcciones', 'Eliminar', .T. )
			_screen.mocks.AgregarSeteoMetodo( 'Direcciones', 'Grabar', .T. )
			_screen.mocks.AgregarSeteoMetodo( 'contactos', 'Codigo_despuesdeasignar', .T. )
			
			goServicios.Parametros = _screen.zoo.app.crearobjeto( "Din_Parametros" )
			goParametros = goServicios.Parametros
			goServicios.Registry = _screen.zoo.app.crearobjeto( "Din_Registros" )
			goRegistry = goServicios.Registry
			goServicios.Parametros.zl.altas.valorsugeridoparaclasificaciondeclientes = "01"
			llExisteParam = pemstatus( goParametros.Zl.Altas, "valorinicialsugeridoparaestadodelarazonsocial", 5 )
			This.Asserttrue( "No existe el parametro 'VALOR INICIAL SUGERIDO PARA ESTADO DE LA RAZON SOCIAL'", llExisteParam)		
					
			llTalonario = CargarTalonarios()
			if llTalonario

				loEntidad = _Screen.Zoo.InstanciarEntidad( "TIPOARTICULOITEMSERVICIO" )
				with loEntidad
					try
						.cCod = "AB"
					catch to loError
						.Nuevo()
						.cCod = "AB"
						.Grabar()
					endtry
					.Release()
				Endwith
				loEntidad = null
				
				loEntidad = _Screen.Zoo.InstanciarEntidad( "ClasificacionV2" )
				with loEntidad
					try
						.Codigo = "01"
						.Eliminar()
					catch to loError
					endtry

					.Nuevo()
					.Codigo = "01"
					.Grabar()
					.Release()
				Endwith
				loEntidad = null

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

				loEntidad = _Screen.Zoo.InstanciarEntidad( "Clientev2" )
				with loEntidad
					try
						.Codigo = "99999"
						.Eliminar()
					catch to loError
					endtry
					.Nuevo()
					.Codigo = "99999"
					.Grabar()

					try
						.Codigo = "88888"
						.Eliminar()
					catch to loError
					endtry
					.Nuevo()
					.Codigo = "88888"
					.Grabar()
					.Release()
				Endwith
				loEntidad = null

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

				loPais.Release()
				loProvincia.Release()

				loEntidad= _Screen.zoo.Crearobjeto( "ZLRazonSociales_AUX", "ztestnocturnositemzlservicioslotebajasubitems.prg" ) 
				
				with loEntidad
					.Nuevo()
					lcRZ1 = .Codigo
					.Descripcion = "RazonSocial1"
					.Cliente_Pk = "99999"
					.SituacionFiscal_pk = 1
					.Cuit = "30-12345678-1"
					.ListaDePrecios_Pk = "999999"
					.direcc_pk = this.CodDireccion
					.reGIMENCOMISION = 32					
					.FormaDePago_Pk = "9999"
					.VersionSistema = 3.25
					.Direccion = "Direccion de prueba"
					.Provincia_pk = "00"
					.Grabar()

					.Nuevo()
					lcRZ2 = .codigo
					.Descripcion = "RazonSocial1"
					.Cliente_Pk = "88888"
					.SituacionFiscal_pk = 1
					.Cuit = "30-12345678-1"
					.ListaDePrecios_Pk = "999999"
					.direcc_pk = this.CodDireccion
					.reGIMENCOMISION = 32							
					.FormaDePago_Pk = "9999"
					.VersionSistema = 3.25
					.Direccion = "Direccion de prueba"
					.Provincia_pk = "00"
					.Grabar()
					.Release()
				Endwith
				loEntidad = null

				loEntidad = _Screen.Zoo.InstanciarEntidad( "ZLISArticulos" )
				with loEntidad
					try
						.Codigo = "99999"
						.Eliminar()
					catch to loError
					endtry
					.Nuevo()
					.Codigo = "99999"
					.Descrip = "Articulo1"
					.TipoArticulo_pk = "AB"
					With .DetalleClasificaciones
						.LimpiarItem()
						.oItem.Clasificacion_Pk = "01"
						.Actualizar()
					endwith
					.Grabar()

					try
						.Codigo = "88888"
						.Eliminar()
					catch to loError
					endtry
					.Nuevo()
					.Codigo = "88888"
					.Descrip = "Articulo2"
					.TipoArticulo_pk = "AB"
					With .DetalleClasificaciones
						.LimpiarItem()
						.oItem.Clasificacion_Pk = "01"
						.Actualizar()
					endwith

					.Grabar()
					.Release()
				endwith

				loSeries = createobject( "serietest" )
				with loSeries
					try
						.nroserie = '99999'
						.eliminar()
					catch to loerror
					finally
						.cNumeroSerieTest = '99999'
						.Nuevo()
						.Clave = '10-10-10'
						.Nombre = 'Prueba 1'
						.Direcc_pk = '01'
						.Ambito_pk = '01'
						.ProductoZoologic_pk = '01'
						.Grabar()
						.Release()
					endtry
				endwith
				loSeries = null
				
				loArticulos = _screen.zoo.instanciarentidad( "zlisarticulos" )
				with loArticulos
					try
						.Codigo = '99999'
						.Eliminar()
					catch to loError
					finally
						.Nuevo()
						.Codigo = '99999'
						.Descrip = 'Prueba 1'
						.TipoArticulo_pk = 'AB'
						.ProductoZoologic_pk = '01'
						.DetalleClasificaciones.oItem.Clasificacion_pk = '01'
						.DetalleClasificaciones.oItem.detalleClasificacion = 'Clasificacion General'
						.DetalleClasificaciones.Actualizar()
						.Grabar()
						.Release()
					endtry
				endwith
				loArticulos = null
				
*				loEntidad = _Screen.Zoo.InstanciarEntidad( "ZLServiciosLote" )
				loEntidad = _screen.zoo.Crearobjeto( "ZLSERVICIOSLOTE_AUX", "ztestNocturnosItemZlservicioslotebajaSubitems.prg" )
				loEntidad.oValidacionesEstadoRazonSocial = newobject( "ValidacionesEstadoRazonSocial_Aux" )			
				
				With loEntidad
					.Nuevo()
					.RazonSocial_Pk = lcRZ1
					.Contacto_PK = '01'

					With .Subitems
						.LimpiarItem()
						.oItem.Serie_Pk = "99999"
						.oItem.Articulo_Pk = "99999"
						.oItem.PRODUCTOZOOLOGIC_PK = '9999'
			         	.oItem.PRODUCTOZOOLOGICDetalle = 'DETALLE'				
						.Actualizar()
					endwith
					.Grabar()
					.Release()
				Endwith
				loEntidad = null

				loEntidad = _Screen.Zoo.InstanciarEntidad( "zlitemsservicios" )
				with loEntidad
					.ultimo()
					lnCodigo = .Codigo
					.release()
				endwith
				loEntidad = null

				loEntidad = _Screen.Zoo.InstanciarEntidad( "ZLServiciosLoteBaja" )
				With loEntidad
					.Nuevo()
					.RazonSocial_Pk = lcRZ1
					With .Subitems
						.LimpiarItem()
						try
							.oItem.NroItemServ_Pk = lnCodigo
							if empty( .oItem.SerieDetalle )
								This.Asserttrue( "No se completo la descripcion del SERIE.", .f.)	
							endif
							
							if empty( .oItem.ArticuloDetalle )
								This.Asserttrue( "No se completo la descripcion del ARTICULO.", .f.)	
							endif						
							
							if empty( .oItem.FechaBajaVigencia )
								This.Asserttrue( "No se completo la Fecha de baja vigencia.", .f.)							
							endif
							.oItem.Limpiar()
							if !empty( .oItem.SerieDetalle )
								This.Asserttrue( "No borro la descripcion del SERIE.", .f.)	
							endif
							
							if !empty( .oItem.ArticuloDetalle )
								This.Asserttrue( "No borro la descripcion del ARTICULO.", .f.)	
							endif					
						catch to loError
							This.asserttrue( "No deberia pinchar" + loError.Message, .f. )
						endtry
					endwith
					.Cancelar()

					.Nuevo()
					.RazonSocial_Pk = lcRZ1
					With .Subitems
						.LimpiarItem()
						Try
							.oItem.NroItemServ_Pk = 777
						catch to loError
							lcMensaje = "El item de servicio debe pertenecer a la razón social ingresada y que no haya sido dado de baja anteriormente"
							This.assertequals( "El mensaje de error es incorrecto.", lcMensaje, loError.UserValue.oInformacion.Item[ 1 ].cMensaje )
						endtry
					endwith
					.Cancelar()
					
					.Release()
				endwith
				loEntidad = null
				
			else
				this.asserttrue( "No se generó el talonario de Baja", .f. )
			endif 
		catch to loError
			throw loError
		finally
			loEntidad = null
			loSeries = null
			loArticulos = null
			=BorrarItemZlserviciosloteSubitems_Test( this )
goMensajes = _Screen.zoo.app.oMensajes
		endtry
	Endfunc

Enddefine


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


*------------------------------------------
*------------------------------------------
*------------------------------------------
*------------------------------------------
*------------------------------------------
*------------------------------------------
*------------------------------------------
*------------------------------------------
*------------------------------------------
*------------------------------------------
*------------------------------------------
*------------------------------------------
function CargarTalonarios() as Boolean 
	local loEntidad as entidad OF entidad.prg, llretorno as Boolean, loEntidad2 as entidad OF entidad.prg, lnProxIdAlta as Integer, lnProxIdBaja as Integer   

	llretorno = .t.
	loEntidad = _Screen.zoo.instanciarEntidad( "Talonario" )
	
	loEntidad2 = _Screen.zoo.instanciarEntidad( "ZLSERVICIOSLOTE" )
	loEntidad2.oValidacionesEstadoRazonSocial = newobject( "ValidacionesEstadoRazonSocial_Aux" )
	
	loEntidad2.Ultimo()
	lnProxIdAlta = loEntidad2.Numero + 1
	
	loEntidad2.Release()
	
	loEntidad2 = _Screen.zoo.instanciarEntidad( "ZLSERVICIOSLOTEBAJA" )
	loEntidad2.Ultimo()
	lnProxIdBaja = loEntidad2.Numero + 1
	
	loEntidad2.Release()
	
	with loEntidad
		try
			.Codigo = "BAJASIS"
			.Eliminar()
		catch
		endtry
		try			
			.Codigo = "ALTASIS"
			.Eliminar()			
		catch
		endtry
	endwith 
	with loEntidad
		try
			.Nuevo()
			.Codigo = "BAJASIS"
			.entidad = "ZLSERVICIOSLOTEBAJA"
			.numero = lnProxIdBaja 
			.Grabar()
		catch to loerror
			llretorno = .f.
		finally
		endtry			
			
		try			
			.Nuevo()
			.Codigo = "ALTASIS"
			.entidad = "ZLSERVICIOSLOTE"
			.numero = lnProxIdAlta
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

*--------------------------------------------------------------------------------------------------
function CrearItemZlserviciosloteSubitems_Test( toFxuTestCase as Object )
	local lcContenido as String 
	
	toFxuTestCase.cArchivoMock = ObtenerNombreDeArchivoItemZlserviciosloteSubitems_Test()

	text to lcContenido textmerge noshow
		*--------------------------------------------------------------------------------------------------
		define class <<justfname( forceext( toFxuTestCase.cArchivoMock, '' ) )>> as ItemZlserviciosloteSubitems of ItemZlserviciosloteSubitems.prg
			
			*-----------------------------------------------------------------------------------------
			function Init() as Void
				dodefault()
				this.oValidacionDeArticulos = newobject( 'ValidacionDeArticulos_Aux' )			
			endfunc 
			
			function ValidaArticuloCentralizador
				return .t.
			endfunc

			function VerificarClasificacionArticulo
				return .t.
			endfunc
			
			
			
		enddefine
	endtext

	strtofile( lcContenido, toFxuTestCase.cArchivoMock, 0)
endfunc

*--------------------------------------------------------------------------------------------------
function BorrarItemZlserviciosloteSubitems_Test( toFxuTestCase as Object )
	local lcArchivo as String 
	lcArchivo = toFxuTestCase.cArchivoMock
	delete file ( lcArchivo )
endfunc


*--------------------------------------------------------------------------------------------------
function ObtenerNombreDeArchivoItemZlserviciosloteSubitems_Test as String 
	local lcArchivo as String 
	lcArchivo = addbs( _screen.Zoo.ObtenerRutaTemporal() ) + 'Mock_ItemZlserviciosloteSubitems_Test' + sys( 2015 ) + '.prg'
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

*----------------------------------------------------------------
define class ZLSERVICIOSLOTE_AUX as ent_ZLSERVICIOSLOTE of ent_ZLSERVICIOSLOTE.PRG

	*-----------------------------------------------------------------------------------------
	function CrearCuentaComunicaciones() as Void
		nodefault
	endfunc

	protected function Ejecuta_sp_AsignacionDeTareaADEVOPS_y_Alta_USUARIOS_DFCLOUD() as Void
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
		
		goServicios.Datos.EjecutarSql( lcSQL  )

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
