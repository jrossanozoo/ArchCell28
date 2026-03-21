#include registry.h
**********************************************************************
Define Class zTestServicioAplicaciones as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as zTestServicioAplicaciones of zTestServicioAplicaciones.prg
	#ENDIF
	
	oZoo		= null
	cPath		= ""
	cDirAct		= ""
	cSetDefa	= ""
	cRuta		= ""

	oServiciosAnterior = null
	
	*---------------------------------
	Function Setup
		this.oServiciosAnterior = goServicios
	EndFunc

	*---------------------------------
	Function TearDown
		goServicios = this.oServiciosAnterior
	EndFunc
	
	*-----------------------------------------------------------------------------------------
	function zTestInstanciar
		local loServicioAplicaciones as Object
		
		loServicioAplicaciones = _screen.zoo.crearobjeto( "ServicioAplicaciones", "ServicioAplicaciones.prg", "Nucleo" )
		this.assertequals( "No se instanció ServicioAplicaciones", "O", vartype( loServicioAplicaciones ))
		this.assertequals( "No se seteo correctamente la variable", "Nucleo", loServicioAplicaciones.cAplicacion )
		
		loServicioAplicaciones.Release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestInstanciarAplicacion
		local	loServicioAplicaciones as Object, llGenerarFXP as Boolean, llGenerarDin as boolean, llOk as boolean, ;
				lcRutaTablas as String, lcRutaInicial as String, lcTipoDeBase as String, lcBase as String, lcDriver as String, lcServidor as String

		lcRutaTablas = upper( goDatos.oAccesoDatos.cRutaTablas )
		lcRutaInicial = upper( _screen.zoo.cRutaInicial )

		with this
			.oZoo		= _screen.zoo
			.cPath		= set( "path" )
			.cDirAct	= curdir()
			.cSetDefa	= set( "Default" )
			.cRuta		= _screen.zoo.crUTAINICIAL 
			lcTipoDeBase = _Screen.zoo.App.TipoDeBase
			lcBase = _Screen.Zoo.App.cNombreBaseDeDatosSQL
			lcDriver = _Screen.Zoo.App.cNombreDriverSQL
			lcServidor = _Screen.Zoo.App.cNombreDelServidorSQL
			_screen.zoo	= null
			REMOVEPROPERTY( _screen, "zoo" )
		endwith

		_screen.mocks.agregarmock("Mensajes")
		_screen.mocks.AgregarSeteoMetodo( 'MENSAJES', 'Enviar', .T., "'Faltan archivos generados'" )
		_screen.mocks.AgregarSeteoMetodo( 'MENSAJES', 'Habilitarmensajeria', .T., ".T." )

		_Screen.mocks.agregarmock( "AplicacionNucleo", "MockAplicacionBase" )
		_screen.mocks.AgregarSeteoMetodo( 'APLICACIONNUCLEO', 'Iniciar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'APLICACIONNUCLEO', 'CrearFormPrincipal', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'APLICACIONNUCLEO', 'Login', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'APLICACIONNUCLEO', 'Obtenersucursalactiva', "Paises" )
		_screen.mocks.AgregarSeteoMetodo( 'APLICACIONNUCLEO', 'Inicializarbasededatos', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'APLICACIONNUCLEO', 'ObtenerNombre', "NUCLEO" )
		_screen.mocks.AgregarSeteoMetodo( 'APLICACIONNUCLEO', 'Reportarterminal', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'APLICACIONNUCLEO', 'Sepuedeingresar', .t. )
		_screen.mocks.AgregarSeteoMetodo( 'APLICACIONNUCLEO', 'Bajarserviciosysalirsifallo', .T., "'*OBJETO','Ingreso denegado al sistema. Por favor comuníquese con el administrador.'" )
		_screen.mocks.AgregarSeteoMetodo( 'APLICACIONNUCLEO', 'Verificardiferenciasdeestructura', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'APLICACIONNUCLEO', 'Sacaratributossololectura', .T., "[" + lcRutaTablas + "]" )
		_screen.mocks.AgregarSeteoMetodo( 'APLICACIONNUCLEO', 'Sacaratributossololectura', .T., "[" + lcRutaInicial + "]" )
		_screen.mocks.AgregarSeteoMetodo( 'APLICACIONNUCLEO', 'Inicializartimeralarmachecklinehost', .T. ) 
		_screen.mocks.AgregarSeteoMetodo( 'APLICACIONNUCLEO', 'Chequeosdeiniciodesucursal', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'APLICACIONNUCLEO', 'cRutaTablasPuesto_access', this.cRuta )	
		_screen.mocks.AgregarSeteoMetodo( 'APLICACIONNUCLEO', 'Procesodedatosfixparametros', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'APLICACIONNUCLEO', 'Despuesdellogin', .T. )		
		_screen.mocks.AgregarSeteoMetodo( 'APLICACIONNUCLEO', 'Obtenerversion', "" )
		_screen.mocks.AgregarSeteoMetodo( 'APLICACIONNUCLEO', 'InformarEstadisticasViaApi', "" )
		
		_screen.mocks.agregarmock( 'CreadorAccesosDirectosListados' )
		_screen.mocks.AgregarSeteoMetodo( 'CREADORACCESOSDIRECTOSLISTADOS', 'Crear', .T. )
		
		_screen.mocks.agregarmock( "SEGURIDAD" )
		
		local loError as Exception
		Try
*			lcValor = ""
			**************************
*			loRegistry = newobject( "registry", "registry.vcx" )
*			loRegistry.GetRegKey( "rlGenDin", @lcValor, "Software\Zoo Logic\Nucleo", HKEY_LOCAL_MACHINE )
*			llGenerarDin = !empty( lcValor ) and lcValor == "1"
*			loRegistry.GetRegKey( "rlGenFxp", @lcValor, "Software\Zoo Logic\Nucleo", HKEY_LOCAL_MACHINE )
*			llGenerarFxp = !empty( lcValor ) and lcValor == "1"
			
*			loRegistry.SetRegKey( "rlGenDin", "0", "Software\Zoo Logic\Nucleo", HKEY_LOCAL_MACHINE, .t. )
*			loRegistry.SetRegKey( "rlGenFxp", "0", "Software\Zoo Logic\Nucleo", HKEY_LOCAL_MACHINE, .t. )

			loServicioAplicaciones = newobject( "ServicioAplicacionesMock", "", "","NUCLEO", "ZOO LOGIC SA NUCLEO" )
			cd ( this.cRuta )
			loServicioAplicaciones.TipoDeBase = lcTipoDeBase
			loServicioAplicaciones.cNombreBaseDeDatosSQl = lcBase
			loServicioAplicaciones.cNombreDriverSQL = lcDriver
			loServicioAplicaciones.cNombreDelServidorSQL = lcServidor
			loServicioAplicaciones.InstanciarAplicacion()

			this.assertequals( "No se instanció Zoo", "O", vartype( _screen.zoo ))
			this.assertequals( "No se instanció App", "O", vartype( _screen.zoo.App ))
			this.asserttrue( "No debe estar vivo el splash", vartype( loServicioAplicaciones.oSplash ) # "O" )
*			this.asserttrue( "Genero FXP", !loServicioAplicaciones.lGeneroFxp )
*			this.asserttrue( "Genero DIN", !loServicioAplicaciones.lGeneroDin )
			this.asserttrue( "No ejecuto (1)", loServicioAplicaciones.lejecuto )

			_Screen.zoo.app.release()

			_Screen.zoo.release()
			REMOVEPROPERTY( _screen, "zoo" )
			loServicioAplicaciones.Release()

			*****************************
*			loRegistry.SetRegKey( "rlGenFxp", "1", "Software\Zoo Logic\Nucleo", HKEY_LOCAL_MACHINE, .t. )
*			loRegistry.SetRegKey( "rlGenDin", "0", "Software\Zoo Logic\Nucleo", HKEY_LOCAL_MACHINE, .t. )

			loServicioAplicaciones = newobject( "ServicioAplicacionesMock", "", "","NUCLEO", "ZOO LOGIC SA NUCLEO" )
			loServicioAplicaciones.TipoDeBase = lcTipoDeBase
			loServicioAplicaciones.cNombreBaseDeDatosSQl = lcBase
			loServicioAplicaciones.cNombreDriverSQL = lcDriver
			loServicioAplicaciones.cNombreDelServidorSQL = lcServidor

			cd ( this.cRuta )
			loServicioAplicaciones.InstanciarAplicacion()
*			this.asserttrue( "No genero FXP", loServicioAplicaciones.lGeneroFxp )
*			this.asserttrue( "Genero DIN", !loServicioAplicaciones.lGeneroDin )
			this.asserttrue( "No ejecuto (2)", loServicioAplicaciones.lejecuto )

*			loRegistry.GetRegKey( "rlGenFxp", @lcValor, "Software\Zoo Logic\Nucleo", HKEY_LOCAL_MACHINE )
*			this.asserttrue( "No se restauro el flag", empty( lcValor ) or lcValor == "0" )
			
			_Screen.zoo.app.release()
			_Screen.zoo.release()
			REMOVEPROPERTY( _screen, "zoo" )
			loServicioAplicaciones.Release()

			*****************************
*			loRegistry.SetRegKey( "rlGenFxp", "1", "Software\Zoo Logic\Nucleo", HKEY_LOCAL_MACHINE, .t. )
*			loRegistry.SetRegKey( "rlGenDin", "1", "Software\Zoo Logic\Nucleo", HKEY_LOCAL_MACHINE, .t. )

			loServicioAplicaciones = newobject( "ServicioAplicacionesMock", "", "","NUCLEO", "ZOO LOGIC SA NUCLEO" )
			cd ( this.cRuta )

			loServicioAplicaciones.TipoDeBase = lcTipoDeBase
			loServicioAplicaciones.cNombreBaseDeDatosSQl = lcBase
			loServicioAplicaciones.cNombreDriverSQL = lcDriver
			loServicioAplicaciones.cNombreDelServidorSQL = lcServidor
			
			llOk = loServicioAplicaciones.InstanciarAplicacion()
*			this.asserttrue( "Debe pinchar por falta de din", !llOk )
*			this.asserttrue( "No genero FXP", loServicioAplicaciones.lGeneroFxp )
*			this.asserttrue( "No Genero DIN", loServicioAplicaciones.lGeneroDin )
			this.asserttrue( "Ejecuto (2)", loServicioAplicaciones.lejecuto )
			_Screen.zoo.app.release()
			_Screen.zoo.release()
			REMOVEPROPERTY( _screen, "zoo" )
			loServicioAplicaciones.Release()

			*****************************
*			loRegistry.SetRegKey( "rlGenFxp", iif( llGenerarFxp, "1", "0" ), "Software\Zoo Logic\Nucleo", HKEY_LOCAL_MACHINE, .t. )
*			loRegistry.SetRegKey( "rlGenDin", iif( llGenerarDin, "1", "0" ), "Software\Zoo Logic\Nucleo", HKEY_LOCAL_MACHINE, .t. )

		Catch To loError
			throw loError
		Finally
			with this
				_screen.AddProperty( "zoo" )
				_screen.zoo = .oZoo
				set path to ( .cPath )
				cd ( .cDirAct )
				set default to ( .cSetDefa )
				
				.assertequals( "No se restauro bien el APP", "APLICACIONNUCLEO", upper( alltrim( _screen.zoo.app.Class ) ) )
				
				use in select( "reporte" )
				
				 .oZoo = null
			endwith
		
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ztestVerificarSplash()
		local loServicioAplicaciones as ServicioAplicaciones of ServicioAplicaciones.prg, lcRuta as string
				
		loServicioAplicaciones = newobject( "ServicioAplicacionesMock", "", "","TELAS", "ZOO LOGIC SA NUCLEO" )	
		strtofile( "imagen1", "Splashimagen1.jpg" )
		
		lcRuta = lower( _Screen.zoo.cRutaInicial )
		lcRuta = strtran( lcRuta, "_base", "" )
		lcRuta = strtran( lcRuta, "\nucleo", "" )
		
		copy file ( addbs( lcRuta ) + "imagenes\iconos\zoologic.ico" ) to  "Iconoimagen1.ico" 
		
		loServicioAplicaciones.Splashscreen1( "Imagen1" )
		This.assertequals( "La imagen en el splash no es la correcta.", "SPLASHIMAGEN1.JPG", ;
			alltrim( upper( justfname( loServicioAplicaciones.oSplash.imgbase1.picture ) ) ) )

		This.assertequals( "El icono en el splash no es el correcta.", "ICONOIMAGEN1.ICO", ;
			alltrim( upper( justfname( loServicioAplicaciones.oSplash.icon) ) ) )

		This.assertequals( "El caption en el splash no es el correcta.", "ZOO LOGIC SA NUCLEO", ;
			alltrim( upper( justfname( loServicioAplicaciones.oSplash.caption ) ) ) )

		This.assertequals( "EL splash debe mostrarse en la task bar.", ;
			.t., loServicioAplicaciones.oSplash.ShowInTaskBar )

		delete file "imagen.jpg"

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ztestNoMostrarMensajeSalida()
		local loServicioAplicaciones as ServicioAplicaciones of ServicioAplicaciones.prg
		private goMensajes

		goMensajes = newobject( "goMensajesMock" )

		private goServicios
		goServicios = _screen.zoo.crearobjeto( "ServiciosAplicacion" )
		goServicios.Seguridad = newobject( "goSeguridadMock" )		
		
		loServicioAplicaciones = newobject( "ServicioAplicacionesMock2", "", "","NUCLEO" )
		loServicioAplicaciones.login1()

		This.assertTrue( "Paso por el metodo que muestra mensaje de salida", !goMensajes.MostroMensaje )
		loServicioAplicaciones.Release()
		goServicios.Release()
	endfunc 

enddefine


*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class ServicioAplicacionesMock as ServicioAplicacionesVisual of ServicioAplicacionesVisual.prg
	lEjecuto = .f.
*	lGeneroFxp = .f.
*	lGeneroDin = .f. 
	TipoDeBase = ""
	cNombreBaseDeDatosSQL = ""
	cNombreDriverSQL = ""
	cNombreDelServidorSQL = ""
	*-----------------------------------------------------------------------------------------
	function SetearEtiquetaEstado() as Void
		dodefault()
		_Screen.zoo.App.TipoDeBase = This.TipoDeBase
		_Screen.zoo.App.cNombreBaseDeDatosSql = This.cNombreBaseDeDatosSQL
		_Screen.Zoo.App.cNombreDriverSQL = This.cNombreDriverSQL
		_Screen.Zoo.App.cNombreDelServidorSQL = This.cNombreDelServidorSQL
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function GenerarDin() as Void
	*************** en este punto no existe el gomensajes y ademasd el gomensajes usa parametros (por ahora es asi)
*		this.lGeneroDin = .t. 
	endproc

	*-----------------------------------------------------------------------------------------
	protected function GenerarFxp()
*		dodefault()
*		this.lGeneroFxp = .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function GenerarFXPEspecifico( tcRuta as String ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function splashscreen1( tcAplicacion as String ) as Void
		This.cAplicacion = tcAplicacion
		This.InicializarEstado()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function 	IniciarServicioPoolDeObjetos() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function IniciarServicioPoolDeAplicaciones() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function Ejecutar() as Void
	
		this.lEjecuto = .t.

	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function RegistrarTiempoDeInicioDeAplicacion() as Void
	endfunc

	*-----------------------------------------------------------------------------------------
	function InformarEstadisticasViaApi() as Void
	endfunc 


enddefine


*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class ServicioAplicacionesMock2 as ServicioAplicacionesVisual of ServicioAplicacionesVisual.prg

	oSplash = null
	*-----------------------------------------------------------------------------------------
	function SetearEtiquetaEstado() as Void
		dodefault()
		_Screen.zoo.App.TipoDeBase = ""
	endfunc 
	*-----------------------------------------------------------------------------------------
	function Init( tcString as String ) as Void
		dodefault( tcString )
		This.oSplash = newobject( "SplashMock" )
	endfunc 

	function LogIn1() as Void
		this.Login() 
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function SalidaQuit() as Void
		
	endfunc 


	
enddefine

*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class goMensajesMock as mensajes of mensajes.prg

	MostroMensaje = .f.	

	*-----------------------------------------------------------------------------------------
	Function enviar( tcMensaje as String ) as Void
		This.MostroMensaje = .t.
	endfunc 

enddefine


*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class goSeguridadMock as Custom
	*-----------------------------------------------------------------------------------------
	Function Login() as Boolean
		return .f.
	endfunc 

enddefine




define class SplashMock as custom

	*-----------------------------------------------------------------------------------------
	function MostrarEstado( tcString as String, tlEspera as Boolean ) as Void

	endfunc 

enddefine

