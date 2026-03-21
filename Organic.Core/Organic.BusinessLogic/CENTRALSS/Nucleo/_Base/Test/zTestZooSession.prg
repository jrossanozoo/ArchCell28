**********************************************************************
Define Class zTestZooSession As FxuTestCase Of FxuTestCase.prg

	#If .F.
		Local This As zTestZooSession Of zTestZooSession.prg
	#Endif

	*-----------------------------------------------------------------------------------------
	function Setup
	endfunc 

	*-----------------------------------------------------------------------------------------
	function TearDown
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestSeteoCentury
		local loZooCentury as Object, lcFechaControl as String, lcCentury as String
		
		lcValorCentury = set( "Century" )
		loZooCentury = newobject( "ZooCentury" )
		
		lcFechaControl = loZooCentury.CargaFecha( "01/01/80" ) 
		This.Assertequals( "El año debe ser 1980", "19", substr( lcFechaControl, 7, 2 ))
		
		lcFechaControl = loZooCentury.CargaFecha( "01/01/79" )
		This.Assertequals( "El año debe ser 2079", "20", substr( lcFechaControl, 7, 2 ))
						
		set century &lcValorCentury 	
		loZooCentury.release()
		
	endfunc	

	*-----------------------------------------------------------------------------------------
	function ztestParsearFecha
		local loObjetoNet as Object, loZooSession as zooSession of zooSession.prg, ldDate as Date, loDate as Object
		Try
			_screen.Zoo.AgregarReferencia( _screen.Zoo.cRutaInicial + "ClasesDePrueba\PruebaNetExtender.dll" )
		catch
		EndTry
		loObjetoNet = _screen.Zoo.CrearObjeto( "ZooLogicSA.Pruebas.PruebaNetExtender" )
		loZooSession = _Screen.zoo.crearobjeto( "zooSession" )
		ldDate = {01/01/2011}
		loObjetoNet.FechaNacimiento = ldDate
		This.Assertequals( "La fecha no es correcta desde .Net", {01/01/2011}, loZooSession.ParsearFecha( loObjetoNet.FechaNacimiento ) )
		This.Assertequals( "La fecha no es correcta desde VFP", {01/01/2011}, loZooSession.ParsearFecha( ldDate ) )
		loObjetoNet = null
		loZooSession.Release()

	endfunc 

	*---------------------------------
	Function zTestExcepcionControladaAlNoEncontrarArchivosDin
		local loZooSession as zooSession of zooSession.prg, loError as Exception, loEx as Exception, ;
			lnerror as integer, loObjeto as object
		
		loZooSession = _Screen.zoo.crearobjeto( "zooSession" )
		
		lnError = 0
		Try
			loObjeto = loZooSession.crearobjeto( "Din_ArchivoInexistenteParaTes" )
		Catch To loError
			loEx = Newobject( "ZooException", "ZooException.prg" )
			With loEx
				.Grabar( loError )
				lnError = .nZooErrorNo
			EndWith
		Finally
		endtry
		
		this.assertequals( "El error no es el controlado", 10, lnError )
		
		if vartype( loObjeto ) = "O"
			loObjeto.destroy()
			loObjeto = null
		endif

		lnError = 0
		Try
			loObjeto = loZooSession.crearobjeto( "Din_EntidadArgentina" )
		Catch To loError
			loEx = Newobject( "ZooException", "ZooException.prg" )
			With loEx
				.Grabar( loError )
				lnError = .nZooErrorNo
			EndWith
		Finally
		endtry
		
		this.assertequals( "el archivo existe, no debe dar error", 0, lnError )

		if vartype( loObjeto ) = "O"
			loObjeto.destroy()
			loObjeto = null
		endif


	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestExistenciaFuncionEnlazar
		local lozoosession as Object
		loZooSession = newobject( "zoosession", "zoosession.prg" )

		this.asserttrue( "No existe la función enlazar", pemstatus( loZooSession , "Enlazar", 5 ) )
		loZooSession = null		
	endfunc	
	*-----------------------------------------------------------------------------------------
	function zTestEjecucionEnlazar
		local loClaseAuxiliar as Object 
		loClaseAuxiliar = createobject("ZooAuxiliar")

		with loClaseAuxiliar
			.enlazar( "Primero", "Segundo" )
			.Primero()
			This.Asserttrue( "Se enlazo correctamente primero con segundo", .lCorrioSegundo )
			.Release()
			loClaseAuxiliar = createobject("ZooAuxiliar")
			.enlazar( ".Primero", "Segundo" )
			.Primero()
			This.Asserttrue( "No se leyo el segundo parametro", .lCorrioSegundo )
			.Release()
			
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestEnlazarDosClases

		local loAuxiliar1 as Object
		loAuxiliar1 = createobject("Auxiliar1")
		loAuxiliar1.Inicializar()
		
		loAuxiliar1.oAuxiliar2.Primero()
		
		This.Asserttrue( "Se enlazo correctamente primero con segundo", loAuxiliar1.lCorrioSegundo )
		loAuxiliar1.Release()

	endfunc 
	*-----------------------------------------------------------------------------------------
	function zTestLoguear
		local loError as Exception, loEx as Exception, loZooSession as zooSession of zooSession.prg, oObjeto as Object

		private goServicios
		goServicios = _screen.zoo.crearobjeto( "ServiciosAplicacion" )
	
		Try
			goServicios.Logueos = newobject( 'mockManagerLogueos' )
			loZooSession = newobject( "MockZooSession" )
	
			loZooSession.Loguear( "txt1", 3 )
			loZooSession.Loguear( "txt2", 1 )
			loZooSession.Loguear( "txt3", 1 )
			loZooSession.Loguear( "txt4", 2 )
			this.assertequals( "Error en la cantidad de pedidos de objetos logueo", 1, goServicios.Logueos.nLlamadas )
			this.assertequals( "Error en los textos logueados", ",txt13,txt21,txt31,txt42", loZooSession.textoLogueado() )
			this.assertequals( "No se seteo la accion en el objeto Logueo (1)", "Creando el logueo", alltrim( loZooSession.mockObtenerAccionObjetoLogueo() ) )
			
			loZooSession.release()
			this.assertequals( "Error en la cantidad de grabaciones", 1, goServicios.Logueos.nGrabaciones )

			loZooSession = newobject( "MockZooSession" )
			loZooSession.Loguear( "txt5", 2 )
			loZooSession.Loguear( "txt6", 3 )
			loZooSession.Loguear( "txt7", 4 )
			
			this.assertequals( "Error en la cantidad de pedidos de objetos logueo 2", 2, goServicios.Logueos.nLlamadas )
			this.assertequals( "Error en los textos logueados 2", ",txt52,txt63,txt74", loZooSession.TextoLogueado() )
			this.assertequals( "No se seteo la accion en el objeto Logueo (2)", "Creando el logueo", alltrim( loZooSession.mockObtenerAccionObjetoLogueo() ) )			
			
			loZooSession.Finalizarlogueo()
			this.assertequals( "Error en la cantidad de grabaciones2", 2, goServicios.Logueos.nGrabaciones )			
			
			loZooSession.Loguear( "txt4", 2 )
			this.assertequals( "Error en la cantidad de pedidos de objetos logueo 2", 3, goServicios.Logueos.nLlamadas )
			this.assertequals( "Error en los textos logueados 3", ",txt42", loZooSession.textoLogueado() )
			this.assertequals( "No se seteo la accion en el objeto Logueo (3)", "Creando el logueo", alltrim( loZooSession.mockObtenerAccionObjetoLogueo() ) )			
			
			loZooSession.release()
			this.assertequals( "Error en la cantidad de grabaciones3", 3, goServicios.Logueos.nGrabaciones )
			
			loZooSession = newobject( "MockZooSession" )
			loZooSession.lLoguear = .F.
			loZooSession.Loguear( "txt5", 2 )
			 && son las 3 anteriores
			this.assertequals( "Error en la cantidad de pedidos de objetos logueo 3", 3, goServicios.Logueos.nLlamadas )
			
			_screen.AddProperty("lUsaServicioRest", .T. )
			loZooSession.lLoguear = .T.
			goservicios.lnologuearrestapi = .T.
			loZooSession.Loguear( "txt6", 2 )
			this.assertequals( "Error en la cantidad de pedidos de objetos logueo 3", 3, goServicios.Logueos.nLlamadas )
			removeproperty( _screen, "lUsaServicioRest" )

		Catch To loError
			loEx = Newobject( "ZooException", "ZooException.prg" )
			With loEx
				.Grabar( loError )
				.Throw()
			EndWith
		endtry 
		goServicios.release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestLoguearConObjetoInyectado
		local loError as Exception, loEx as Exception, loZooSession1 as zooSession of zooSession.prg,;
			loZooSession2 as zooSession of zooSession.prg, loZooSession3 as zooSession of zooSession.prg
			
		private goServicios
		goServicios = _screen.zoo.crearobjeto( "ServiciosAplicacion" )
		Try
			goServicios.Logueos = newobject( 'mockManagerLogueos' )
			loZooSession1 = newobject( "MockZooSession","","","msj1" )
			loZooSession2 = newobject( "MockZooSession","","","msj2" )
			loZooSession3 = newobject( "MockZooSession","","","msj3" )			
			loZooSession1.AddProperty( "oHijo", loZooSession2 )
			loZooSession2.AddProperty( "oNieto", loZooSession3 )			

			loZooSession1.enlazar( "oHijo.EventoObtenerLogueo", "inyectarLogueo" )
			loZooSession2.enlazar( "oNieto.EventoObtenerLogueo", "inyectarLogueo" )
			loZooSession2.loguear( "log1", 2 )
			
			this.assertequals( "No se agrego el log 1", ",log12", loZooSession1.textoLogueado() )
			this.assertequals( "No se seteo la accion en el objeto Logueo (1)", "msj1", alltrim( loZooSession1.mockObtenerAccionObjetoLogueo() ) )			
			loZooSession2.loguear( "log2", 3 )
			this.assertequals( "No se agrego el log 2", ",log12,log23", loZooSession1.textoLogueado() )
			loZooSession1.loguear( "log3", 4 )
			this.assertequals( "No se agrego el log 3", ",log12,log23,log34", loZooSession1.textoLogueado() )
			this.assertequals( "No se seteo la accion en el objeto Logueo (2)", "msj1", alltrim( loZooSession1.mockObtenerAccionObjetoLogueo() ) )						
			loZooSession3.loguear( "log4", 1 )
			this.assertequals( "No se agrego el log 4", ",log12,log23,log34,log41", loZooSession1.textoLogueado() )	
			this.assertequals( "No se seteo la accion en el objeto Logueo (3)", "msj1", alltrim( loZooSession1.mockObtenerAccionObjetoLogueo() ) )								
			this.asserttrue( "El logueo tiene que ser propio", loZooSession1.lLogueoPropio )
			this.asserttrue( "El logueo NO tiene que ser propio 1", !loZooSession2.lLogueoPropio )
			this.asserttrue( "El logueo NO tiene que ser propio 2", !loZooSession3.lLogueoPropio )						
			
			
		Catch To loError
			loEx = Newobject( "ZooException", "ZooException.prg" )
			With loEx
				.Grabar( loError )
				.Throw()
			EndWith
		endtry 
		goServicios.release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestAgregarInformacion
		local loZooSession as Object, loItem as Object, loInfoExtra as Object
	
		loZooSession = createobject( "ZooSessionMockInformacion" )
	
		loZooSession.AgregarInformacion( "Dato C" )
		loZooSession.AgregarInformacion( "Dato B" )
		loZooSession.AgregarInformacion( "Dato D" )
		loZooSession.AgregarInformacion( "Dato A" )
			
		This.assertequals( "La cantidad de datos enviados a la coleccion no es correcta.(1)", 4, loZooSession.oColeccionTest.Count )

		This.assertequals( "Es incorrecto el item 1.(1)", "Dato C", loZooSession.oColeccionTest.item[ 1 ].cMensaje )
		This.assertequals( "Es incorrecto el item 2.(1)", "Dato B", loZooSession.oColeccionTest.item[ 2 ].cMensaje )
		This.assertequals( "Es incorrecto el item 3.(1)", "Dato D", loZooSession.oColeccionTest.item[ 3 ].cMensaje )
		This.assertequals( "Es incorrecto el item 4.(1)", "Dato A", loZooSession.oColeccionTest.item[ 4 ].cMensaje )

		loZooSession.LimpiarInformacion()
		This.assertequals( "La cantidad de datos enviados despues de limpiar no es correcta.(1)", 0, loZooSession.oColeccionTest.Count )				
		
		loZooSession.AgregarInformacion( "1" )
		loZooSession.AgregarInformacion( "2" )
		loZooSession.AgregarInformacion( "Dato 3" )
		loZooSession.AgregarInformacion( "Dato 4" )
		loZooSession.AgregarInformacion( "Dato 5" )
		
		This.assertequals( "La cantidad de datos enviados a la coleccion no es correcta.(2)", 5, loZooSession.oColeccionTest.Count )		
		This.assertequals( "Es incorrecto el item 1.(2)", "1", loZooSession.oColeccionTest.item[ 1 ].cMensaje )
		This.assertequals( "Es incorrecto el item 2.(2)", "2", loZooSession.oColeccionTest.item[ 2 ].cMensaje )
		This.assertequals( "Es incorrecto el item 3.(2)", "Dato 3", loZooSession.oColeccionTest.item[ 3 ].cMensaje )
		This.assertequals( "Es incorrecto el item 4.(2)", "Dato 4", loZooSession.oColeccionTest.item[ 4 ].cMensaje )
		This.assertequals( "Es incorrecto el item 5.(2)", "Dato 5", loZooSession.oColeccionTest.item[ 5 ].cMensaje )

		loZooSession.LimpiarInformacion()
		This.assertequals( "La cantidad de datos enviados despues de limpiar no es correcta.(2)", 0, loZooSession.oColeccionTest.Count )				
		
		with loZooSession
			.AgregarInformacion( "SoloTexto" )
			.AgregarInformacion( "TextoYNum", 10 )
			.AgregarInformacion( "TextoNumYExtra", 12, newobject( "mockObjetoLogueo" ) )
		endwith

		with this
			.AssertEquals( "La Cantidad de items es incorrecta (3)", 3, loZooSession.oColeccionTest.count )
			loItem = loZooSession.oColeccionTest.item[ 1 ]
			this.assertEquals( "El texto del item 1 no es el correcto", "SoloTexto", loItem.cMensaje )
			this.assertequals( "El numero del item 1 no es el correcto", 0, loItem.nNumero )
			this.asserttrue( "La info extra del item 1 no es el correcto", isnull( loItem.xInfoExtra ) )
			
			loItem = loZooSession.oColeccionTest.item[ 2 ]
			this.assertEquals( "El texto del item 2 no es el correcto", "TextoYNum", loItem.cMensaje )
			this.assertequals( "El numero del item 2 no es el correcto", 10, loItem.nNumero )
			this.asserttrue( "La info extra del item 2 no es el correcto", isnull( loItem.xInfoExtra ) )
			
			loItem = loZooSession.oColeccionTest.item[ 3 ]
			this.assertEquals( "El texto del item 3 no es el correcto", "TextoNumYExtra", loItem.cMensaje )
			this.assertequals( "El numero del item 3 no es el correcto", 12, loItem.nNumero )
			this.asserttrue( "La info extra del item 3 no es el correcto", !isnull( loItem.xInfoExtra ) )
			loInfoExtra = loItem.xInfoExtra
			this.assertequals( "El objeto que llego en la info extra no es correcta", "Mockobjetologueo", loInfoExtra.class )
			
		endwith
		loZooSession.release()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function zTestHayInformacion
		local loZooSession as zoosession of zoosession.prg
		
		loZooSession = _screen.zoo.crearobjeto( "ZooSession" )

		This.asserttrue( "El objeto tiene Informacion agregada. 1", !loZooSession.Hayinformacion() )

		loZooSession.Agregarinformacion( "Problema 1" )
		This.asserttrue( "El objeto no tiene Informacion agregada", loZooSession.Hayinformacion() )
	
		loZooSession.release()
	Endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestObtenerInformacion()
		local loZooSession as zoosession of zoosession.prg, loInfo as zooInformacion of ZooInformacion.prg
		
		loZooSession = _screen.zoo.crearobjeto( "ZooSession" )
		loInfo = loZooSession.ObtenerInformacion()
		This.assertequals( "El objecto Informacion tiene informacion ingresada.", 0, loInfo.Count )

		loZooSession.agregarinformacion( "Informacion 1" )
		loInfo = loZooSession.ObtenerInformacion()
		This.assertequals( "El objecto Informacion tiene informacion ingresada.", 1, loInfo.Count )

		loInfo = null
		loZooSession.release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestAgregarInformacionDeExcepcion
		local loZoosession as zoosession of zoosession.prg, loEx as zooexception OF zooexception.prg

		loZoosession = newobject( "ZooAuxiliar" )
		loEx = newobject( "MockZooException" )
		loZoosession.agregarinformaciondeexcepcion( loEx )

		This.asserttrue( "No paso por 'ExceptionToInformacion'." , loEx.lPasoPorExceptionToInformacion )
		This.asserttrue( "No paso por 'AgregarInformacionDeExcepcion'.", loZoosession.lPasoPorAgregarInformacionDeExcepcion )
		
		loEx = null
		loZoosession.release()
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestCargarInformacion
		local loZoosession as zoosession of zoosession.prg, loInformacion as ZooInformacion of ZooInformacion
				
		loZooSession = _screen.zoo.crearobjeto( "ZooSession" )
		loInformacion = _screen.zoo.crearobjeto( "ZooInformacion" )
		
		with loInformacion
			.AgregarInformacion( "Mensaje 1", 3, 10 )
			.AgregarInformacion( "Mensaje 2", 2, 20 )
			.AgregarInformacion( "Mensaje 3", 1, 30 )
		endwith

		loZooSession.CargarInformacion( loInformacion )
		This.assertequals( "No elimino los mensajes del ZooInformacion pasado como parametro.", 0, loInformacion.Count )

		loObjetoInformacion = loZooSession.Obtenerinformacion()

		This.assertequals( "Es incorrecto el mensaje del item 1.", "Mensaje 1", loObjetoInformacion.item[ 1 ].cMensaje )
		This.assertequals( "Es incorrecto el mensaje del item 2.", "Mensaje 2", loObjetoInformacion.item[ 2 ].cMensaje )
		This.assertequals( "Es incorrecto el mensaje del item 3.", "Mensaje 3", loObjetoInformacion.item[ 3 ].cMensaje )
		
		This.assertequals( "Es incorrecto el Error del item 1.", 3, loObjetoInformacion.item[ 1 ].nNumero )
		This.assertequals( "Es incorrecto el Error del item 2.", 2, loObjetoInformacion.item[ 2 ].nNumero )
		This.assertequals( "Es incorrecto el Error del item 3.", 1, loObjetoInformacion.item[ 3 ].nNumero )
		
		This.assertequals( "Es incorrecta la Informacion adicional", 10, loObjetoInformacion.item[ 1 ].xInfoExtra )
		This.assertequals( "Es incorrecta la Informacion adicional", 20, loObjetoInformacion.item[ 2 ].xInfoExtra )
		This.assertequals( "Es incorrecta la Informacion adicional", 30, loObjetoInformacion.item[ 3 ].xInfoExtra )
		
		loInformacion.release()
		loZooSession.release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestSeDebeLoguear
		local loZooSession as Object
		private goServicios		
		
		loZooSession = _screen.zoo.crearobjeto( "ZooSession" )

		goServicios = _screen.zoo.crearobjeto( "serviciosaplicacion" )

		_screen.AddProperty("lUsaServicioRest", .T. )

		goservicios.lnologuearrestapi = .T.
		this.asserttrue("No devolvió el valor esperado(1)", !loZooSession.SeDebeLoguear() )

		goservicios.lnologuearrestapi = .F.
		this.asserttrue("No devolvió el valor esperado(2)", loZooSession.SeDebeLoguear() )

		removeproperty( _screen, "lUsaServicioRest" )
		
		loZooSession.release()
		goServicios.release()
	endfunc 

EndDefine

*-----------------------------------------------------------------------------------------
define class ZooAuxiliar as zoosession of zoosession.prg
	lCorrioPrimero = .F.
	lCorrioSegundo = .F.
	lPasoPorAgregarInformacionDeExcepcion = .f.
	*-----------------------------------------------------------------------------------------
	function primero() as VOID
		this.lCorrioPrimero = .T.
	endfunc
	*-----------------------------------------------------------------------------------------
	function segundo() as Void
		this.lCorrioSegundo = .T.
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function AgregarInformacionDeExcepcion( txParam as Variant ) as Void
		dodefault( txParam )
		This.lPasoPorAgregarInformacionDeExcepcion = .t.
	endfunc 

enddefine

*-----------------------------------------------------------------------------------------
define class Auxiliar1 as zoosession of zoosession.prg
	lCorrioSegundo = .f.
	oAuxiliar2 = null

	*-----------------------------------------------------------------------------------------
	function Inicializar() as VOID
		this.oAuxiliar2 = createobject("Auxiliar2")
		this.Enlazar("oAuxiliar2.Primero","Segundo")
	endfunc

	*-----------------------------------------------------------------------------------------
	function segundo() as Void
		this.lCorrioSegundo = .T.
	endfunc 


enddefine

*-----------------------------------------------------------------------------------------
define class Auxiliar2 as zoosession of zoosession.prg

	*-----------------------------------------------------------------------------------------
	function primero() as VOID
	endfunc

enddefine

*-----------------------------------------------------------------------------------------
define class mockManagerLogueos as ManagerLogueos of ManagerLogueos.prg
	nLlamadas = 0
	nGrabaciones = 0
	*-----------------------------------------------------------------------------------------
	function init() as Void
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ObtenerObjetoLogueo( toQuienLlama ) as Object
		this.nLlamadas = this.nLlamadas + 1
		return newobject( "mockObjetoLogueo" )
	endfunc 
	*-----------------------------------------------------------------------------------------
	function guardar( toObjetoLogueo as Object ) as Void
		this.nGrabaciones = this.nGrabaciones + 1
	endfunc 
enddefine

*-----------------------------------------------------------------------------------------
define class mockObjetoLogueo as objetoLogueo of objetoLogueo.prg
	cEscrituras = ""

	*-----------------------------------------------------------------------------------------
	function Accion_Assign( txVal as Variant ) as Void
		this.Accion = txVal
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Init() as Void
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function escribir( tcTexto as String, tnNivel as String )
		local lnNivel as Integer
		if vartype( tnNivel ) = "N"
			lnNivel = tnNivel
		else
			lnNivel = 0
		endif
		this.cEscrituras = this.cEscrituras + "," + tcTexto + transform( lnNivel )
	endfunc

enddefine
*-----------------------------------------------------------------------------------------
define class MockZooSession as zooSession of zooSession.prg
	cMsjLogueo = ""
	*-----------------------------------------------------------------------------------------
	function init( tcMsjInicial as String ) as Void
		this.cMsjLogueo = tcMsjInicial
	endfunc 
	*-----------------------------------------------------------------------------------------
	protected function MensageLogueoInicial() as String
		return iif( empty( this.cMsjLogueo ) , "Creando el logueo", this.cMsjLogueo )
	endfunc 
	*-----------------------------------------------------------------------------------------
	function textoLogueado() as String
		return this.oLogueo.cEscrituras
	endfunc 
	*-----------------------------------------------------------------------------------------
	function mockObtenerObjetoLogueo() as Object
		return this.oLogueo
	endfunc 
	*-----------------------------------------------------------------------------------------
	function mockObtenerAccionObjetoLogueo() as string 
		return this.oLogueo.Accion
	endfunc 
	
	
endDefine

*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class ZooSessionMockInformacion as ZooSession of ZooSession.prg
	oColeccionTest = null
	*-----------------------------------------------------------------------------------------
	function Init()
		dodefault()
		This.oColeccionTest = This.oInformacion
	endfunc 

enddefine

*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class MockZooException as ZooException of ZooException.prg
	lPasoPorExceptionToInformacion = .f.
	*-----------------------------------------------------------------------------------------
	function ExceptionToInformacion( toInformacion as zooinformacion of zooinformacion.prg ) as VOID
		This.lPasoPorExceptionToInformacion = .t.
	endfunc	

enddefine

*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
Define class ZooCentury as ZooSession of ZooSession.prg

	ldFechaControl = {  /  /  }
	*-----------------------------------------------------------------------------------------
	function CargaFecha( tFecha as String ) as String
			
		set century on
		this.ldFechaControl = ctod( tFecha )
		return dtoc( this.ldFechaControl)
	
	endfunc
	*-----------------------------------------------------------------------------------------
	
enddefine
