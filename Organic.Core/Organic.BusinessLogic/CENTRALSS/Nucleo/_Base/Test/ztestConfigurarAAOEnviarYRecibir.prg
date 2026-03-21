**********************************************************************
Define Class zTestConfigurarAAOEnviarYRecibir as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as zTestConfigurarAAOEnviarYRecibir of zTestConfigurarAAOEnviarYRecibir.prg
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
		local loConfigurador as ConfigurarAAOEnviarYRecibir of ConfigurarAAOEnviarYRecibir.prg

		loConfigurador = _screen.zoo.crearobjeto( "ConfigurarAAOEnviarYRecibir" )
		this.assertequals( "No es un objeto de la clase valida.", "CONFIGURARAAOENVIARYRECIBIR", upper( loConfigurador.Class ) )
		loConfigurador.release()
		
		_Screen.mocks.verificarejecuciondemocks()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestConfigurar_OK
		local loConfigurador as ConfigurarAAOEnviarYRecibir of ConfigurarAAOEnviarYRecibir.prg, ;
			loAccion as FakeAccionDeAgenteOrganic of zTestConfigurarAAOEnviarYRecibir.prg, ;
			loPar as ParametroParaTest of zTestConfigurarAAOEnviarYRecibir.prg,;
			lcBaseAnt as String

		loPar = _screen.zoo.crearobjeto( "ParametroParaTest", "zTestConfigurarAAOEnviarYRecibir.prg" )
		
		_Screen.mocks.agregarmock( "AnalizadorConfiguracionAAO" )
		_screen.mocks.AgregarSeteoMetodo( 'ANALIZADORCONFIGURACIONAAO', 'Obtenerparametrosenviaryrecibir', loPar )
		_screen.mocks.AgregarSeteoMetodo( 'ANALIZADORCONFIGURACIONAAO', 'Analizarresultado', .T., "'*OBJETO','*OBJETO'" )
		_screen.mocks.AgregarSeteoMetodo( 'ANALIZADORCONFIGURACIONAAO', 'Analizarresultado', .T., "'*OBJETO',.F." )
		
		Try
			lcBaseAnt = goServicios.Parametros.nucleo.Comunicaciones.ProcesarPaquetesDelTipoABaseDeDatosEnLaBaseDeDatos
			
			loConfigurador = _screen.zoo.crearobjeto( "ConfigurarAAOEnviarYRecibir")

			goServicios.Parametros.nucleo.Comunicaciones.ProcesarPaquetesDelTipoABaseDeDatosEnLaBaseDeDatos = lcBaseAnt + "bla"

			loConfigurador.Configurar()

			this.asserttrue( "No configuro", loPar.lConfiguro )
			this.asserttrue( "No debe restaurar el parametro si configura correctamente", goServicios.Parametros.nucleo.Comunicaciones.ProcesarPaquetesDelTipoABaseDeDatosEnLaBaseDeDatos == lcBaseAnt + "bla" )
		finally
			goServicios.Parametros.nucleo.Comunicaciones.ProcesarPaquetesDelTipoABaseDeDatosEnLaBaseDeDatos = lcBaseAnt
		endtry 

		loConfigurador.release()

		_Screen.mocks.verificarejecuciondemocks()
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestConfigurar_ErrorAlAnalizarelResultado
		local loConfigurador as ConfigurarAAOEnviarYRecibir of ConfigurarAAOEnviarYRecibir.prg, ;
			loAccion as FakeAccionDeAgenteOrganic of zTestConfigurarAAOEnviarYRecibir.prg, ;
			loPar as ParametroParaTest of zTestConfigurarAAOEnviarYRecibir.prg,;
			lcBaseAnt as String
		
		loPar = _screen.zoo.crearobjeto( "ParametroParaTest", "zTestConfigurarAAOEnviarYRecibir.prg" )
		
		_Screen.mocks.agregarmock( "AnalizadorConfiguracionAAO" )
		_screen.mocks.AgregarSeteoMetodo( 'ANALIZADORCONFIGURACIONAAO', 'Obtenerparametrosenviaryrecibir', loPar )
		_screen.mocks.AgregarSeteoMetodo( 'ANALIZADORCONFIGURACIONAAO', 'Analizarresultado', .f., "'*OBJETO','*OBJETO'" )
		_screen.mocks.AgregarSeteoMetodo( 'ANALIZADORCONFIGURACIONAAO', 'Analizarresultado', .f., "'*OBJETO',.F." )

		Try
			lcBaseAnt = goServicios.Parametros.nucleo.Comunicaciones.ProcesarPaquetesDelTipoABaseDeDatosEnLaBaseDeDatos
			
			loConfigurador = _screen.zoo.crearobjeto( "ConfigurarAAOEnviarYRecibir")

			goServicios.Parametros.nucleo.Comunicaciones.ProcesarPaquetesDelTipoABaseDeDatosEnLaBaseDeDatos = lcBaseAnt + "bla"

			loConfigurador.Configurar()

			this.asserttrue( "No configuro", loPar.lConfiguro )
			this.asserttrue( "Debe restaurar el parametro si configura con error", goServicios.Parametros.nucleo.Comunicaciones.ProcesarPaquetesDelTipoABaseDeDatosEnLaBaseDeDatos == lcBaseAnt )
		finally
			goServicios.Parametros.nucleo.Comunicaciones.ProcesarPaquetesDelTipoABaseDeDatosEnLaBaseDeDatos = lcBaseAnt
		endtry 
		
		loConfigurador.release()

		_Screen.mocks.verificarejecuciondemocks()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestNoConfigurarDebidoAQueNoHuboCambios
		local loConfigurador as ConfigurarAAOEnviarYRecibir of ConfigurarAAOEnviarYRecibir.prg, ;
			loAccion as FakeAccionDeAgenteOrganic of zTestConfigurarAAOEnviarYRecibir.prg

		_Screen.mocks.agregarmock( "AnalizadorConfiguracionAAO" )
		
		loAccion = _screen.zoo.crearobjeto( "FakeAccionDeAgenteOrganic", "zTestConfigurarAAOEnviarYRecibir.prg" )

		this.agregarmocks( "FactoryAccionDeAgenteOrganic" )
		_screen.mocks.AgregarSeteoMetodo( 'FACTORYACCIONDEAGENTEORGANIC', 'Obtener', loAccion, "[EnviaRecibeYProcesar]" )

		goServicios.Parametros.nucleo.Comunicaciones.EnviarRecibirYProcesarAutomaticamente = .f.
		
		loConfigurador = _screen.zoo.crearobjeto( "ConfigurarAAOEnviarYRecibir")

		loConfigurador.Configurar()

		this.assertequals( "No genero el archivo script", "", alltrim( loAccion.cArchivoScript ) )
		
		loConfigurador.release()
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

define class ParametroParaTest as custom
	
	lConfiguro = .f.
	
	function Configurar() as object
		this.lConfiguro = .t.
		return null
	endfunc

enddefine

