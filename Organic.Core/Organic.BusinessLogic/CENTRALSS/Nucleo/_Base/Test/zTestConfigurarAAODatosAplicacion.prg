**********************************************************************
Define Class zTestConfigurarAAODatosAplicacion as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as zTestConfigurarAAODatosAplicacion of zTestConfigurarAAODatosAplicacion.prg
	#ENDIF
	
	lEnviarRecibirYProcesarAutomaticamente = .f.
	cProcesarPaquetesDelTipoABaseDeDatosEnLaBaseDeDatos = ""
	nFrecuenciaEnMinutos = 0

	*---------------------------------
	Function Setup
		this.lEnviarRecibirYProcesarAutomaticamente = goServicios.Parametros.nucleo.Comunicaciones.EnviarRecibirYProcesarAutomaticamente
		this.cProcesarPaquetesDelTipoABaseDeDatosEnLaBaseDeDatos = goServicios.Parametros.nucleo.Comunicaciones.ProcesarPaquetesDelTipoABaseDeDatosEnLaBaseDeDatos
		this.nFrecuenciaEnMinutos = goServicios.Parametros.nucleo.Comunicaciones.FrecuenciaEnMinutos
	EndFunc
	
	*---------------------------------
	Function TearDown
		goServicios.Parametros.nucleo.Comunicaciones.EnviarRecibirYProcesarAutomaticamente = this.lEnviarRecibirYProcesarAutomaticamente
		goServicios.Parametros.nucleo.Comunicaciones.ProcesarPaquetesDelTipoABaseDeDatosEnLaBaseDeDatos = this.cProcesarPaquetesDelTipoABaseDeDatosEnLaBaseDeDatos
		goServicios.Parametros.nucleo.Comunicaciones.FrecuenciaEnMinutos = this.nFrecuenciaEnMinutos
	EndFunc

	*-----------------------------------------------------------------------------------------
	function zTestInstanciar
		local loConfigurador as ConfigurarAAODatosAplicacion of ConfigurarAAODatosAplicacion.prg

		loConfigurador = _screen.zoo.crearobjeto( "ConfigurarAAODatosAplicacion" )
		this.assertequals( "No es un objeto de la clase valida.", "CONFIGURARAAODATOSAPLICACION", upper( loConfigurador.Class ) )
		loConfigurador.release()
		
		_Screen.mocks.verificarejecuciondemocks()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestConfigurar_OK
		local loConfigurador as ConfigurarAAODatosAplicacion of ConfigurarAAODatosAplicacion.prg, lcArchivo as String, lcTexto as string, ;
			loRetorno as zooinformacion of zooInformacion.prg
		
		lcArchivo = addbs( _screen.zoo.ObtenerRutaTemporal() ) + "archivoTestConfAAOApli.txt"
		if file( lcArchivo )
			delete file( lcArchivo )
		endif

		_screen.mocks.agregarmock( "ZooLogicSA.ConectorDeRedes.Factory.FactoryConectorDeRedes", "FactoryConectorDeRedesTest", "zTestConfigurarAAODatosAplicacion.prg" )
		
		loConfigurador = _screen.zoo.crearobjeto( "ConfigurarAAODatosAplicacion" )

		loRetorno = loConfigurador.Configurar()
		this.assertTrue( "Sebe configurar", file( lcArchivo ) )
		lcTexto = filetostr( lcArchivo )
		this.assertequals( "Debe configurar serie", "SERIE-106046-VERSION01.0001.00000", lcTexto )
		this.assertequals( "No debe haber un mensaje", 0, loRetorno.Count )

		loConfigurador.SetearSerie( "Serie nuevo" )
		loConfigurador.SetearVersion( _screen.zoo.app.ObtenerVersion() )

		loRetorno = loConfigurador.Configurar()
		lcTexto = filetostr( lcArchivo )
		this.assertequals( "Debe configurar serie", "SERIE-106046-VERSION01.0001.00000", lcTexto )
		this.assertequals( "No debe haber un mensaje", 0, loRetorno.Count )

		loConfigurador.SetearSerie( _screen.zoo.app.cSerie )
		loConfigurador.SetearVersion( "Version nueva" )

		loRetorno = loConfigurador.Configurar()
		lcTexto = filetostr( lcArchivo )
		this.assertequals( "No debe configurar version", "SERIE-106046-VERSION01.0001.00000", lcTexto )
		this.assertequals( "No debe haber un mensaje", 0, loRetorno.Count )

		loConfigurador.release()

		_Screen.mocks.verificarejecuciondemocks()
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestConfigurar_ErrorAlAnalizarelResultado
		local loConfigurador as ConfigurarAAODatosAplicacion of ConfigurarAAODatosAplicacion.prg, lcArchivo as String, lcTexto as string, ;
			loRetorno as zooinformacion of zooInformacion.prg
		
		lcArchivo = addbs( _screen.zoo.ObtenerRutaTemporal() ) + "archivoTestConfAAOApli.txt"
		if file( lcArchivo )
			delete file( lcArchivo )
		endif

		_screen.mocks.agregarmock( "ZooLogicSA.ConectorDeRedes.Factory.FactoryConectorDeRedes", "FactoryConectorDeRedesConErrorTest", "zTestConfigurarAAODatosAplicacion.prg" )
		
		loConfigurador = _screen.zoo.crearobjeto( "ConfigurarAAODatosAplicacion")

		loConfigurador.SetearSerie( "Serie nuevo" )
		loRetorno = loConfigurador.Configurar()
		this.assertTrue( "No debe configurar", !file(lcArchivo ) )
		this.assertequals( "Debe haber un mensaje", 1, loRetorno.Count )
		this.assertequals( "Error en el mensaje", "No se pudo configurar la información de la aplicación.", loRetorno.Item[ 1 ].cmensaje )

		loConfigurador.release()

		_Screen.mocks.verificarejecuciondemocks()
	endfunc 

EndDefine



*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class FakeAccionDeAgenteOrganic as AccionDeAgenteOrganic of AccionDeAgenteOrganic.prg
	function GuardarScript()
		this.cArchivoScript = "ArchivoScript"
	endfunc

	*-----------------------------------------------------------------------------------------
	function Release() as Void
	endfunc 
enddefine

define class FactoryConectorDeRedesTest as custom
	
	function Obtener( tx ) as object
		return newobject( "conectoragenteorganicTest" )
	endfunc

enddefine

define class FactoryConectorDeRedesConErrorTest as custom
	
	function Obtener( tx ) as object
		local loError as Exception 
		loError = newobject( "Exception" )
		loError.Message = "Error para test"
		throw loError
	endfunc

enddefine

define class conectoragenteorganicTest as custom
	
	function ObtenerDatosProducto( tcProducto ) as object
		return newobject( "ProductoTest" )
	endfunc

	*-----------------------------------------------------------------------------------------
	function GuardarDatosProducto( toProducto ) as Void
		local lcArchivo

		lcArchivo = addbs( _screen.zoo.ObtenerRutaTemporal() ) + "archivoTestConfAAOApli.txt"
		if file( lcArchivo )
			delete file( lcArchivo )
		endif
		
		strtofile( "SERIE-" + alltrim( upper( toProducto.Serie ) ) + "-VERSION" + toProducto.Version, lcArchivo, 0 )
	endfunc 


enddefine

define class ProductoTest as custom
	
	Serie = ""
	Path = ""
	Version = ""
	Habilitado = .t.
	Nombre = ""

enddefine