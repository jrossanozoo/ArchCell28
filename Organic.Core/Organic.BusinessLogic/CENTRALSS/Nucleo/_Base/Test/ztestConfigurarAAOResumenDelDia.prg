**********************************************************************
Define Class zTestConfigurarAAOResumenDelDia as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as zTestConfigurarAAOResumenDelDia of zTestConfigurarAAOResumenDelDia.prg
	#ENDIF
	
	lEmpaquetarResumenDelDiaAlCerrarLaCaja = .f.
	cEnviarALosBuzones = ""
	nPreguntarRespectoDeLaAutomatizacionDelEmpaquetadoDelResumenDelDia = 0
	
	*---------------------------------
	Function Setup
		this.lEmpaquetarResumenDelDiaAlCerrarLaCaja = goServicios.Parametros.nucleo.Comunicaciones.EmpaquetarResumenDelDiaAlCerrarLaCaja
		this.cEnviarALosBuzones = goServicios.Parametros.nucleo.Comunicaciones.EnviarALosBuzones
		this.nPreguntarRespectoDeLaAutomatizacionDelEmpaquetadoDelResumenDelDia	= goServicios.Parametros.Nucleo.Comunicaciones.PreguntarRespectoDeLaAutomatizacionDelEmpaquetadoDelResumenDelDia
	EndFunc
	
	*---------------------------------
	Function TearDown
		goServicios.Parametros.nucleo.Comunicaciones.EmpaquetarResumenDelDiaAlCerrarLaCaja = this.lEmpaquetarResumenDelDiaAlCerrarLaCaja
		goServicios.Parametros.nucleo.Comunicaciones.EnviarALosBuzones = this.cEnviarALosBuzones
		goServicios.Parametros.Nucleo.Comunicaciones.PreguntarRespectoDeLaAutomatizacionDelEmpaquetadoDelResumenDelDia = this.nPreguntarRespectoDeLaAutomatizacionDelEmpaquetadoDelResumenDelDia
	EndFunc

	*-----------------------------------------------------------------------------------------
	function zTestInstanciar
		local loConfigurador as ConfigurarAAOResumenDelDia of ConfigurarAAOResumenDelDia.prg

		_Screen.mocks.agregarmock( "AnalizadorConfiguracionAAO" )
		
		loConfigurador = _screen.zoo.crearobjeto( "ConfigurarAAOResumenDelDia" )
		this.assertequals( "No es un objeto de la clase valida.", "CONFIGURARAAORESUMENDELDIA", upper( loConfigurador.Class ) )
		loConfigurador.release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestConfigurar_OK
		local loConfigurador as ConfigurarAAOResumenDelDia of ConfigurarAAOResumenDelDia.prg, loPar as object

		loPar = _screen.zoo.crearobjeto( "ParametroParaTest", "zTestConfigurarAAOResumenDelDia.prg" )

		_Screen.mocks.agregarmock( "AnalizadorConfiguracionAAO" )
		_screen.mocks.AgregarSeteoMetodo( 'ANALIZADORCONFIGURACIONAAO', 'Obtenerparametrosresumendeldia', loPar )
		_screen.mocks.AgregarSeteoMetodo( 'ANALIZADORCONFIGURACIONAAO', 'Analizarresultado', .T., "'*OBJETO','*OBJETO'" )

		goServicios.Parametros.nucleo.Comunicaciones.EmpaquetarResumenDelDiaAlCerrarLaCaja = .f.
		
		loConfigurador = _screen.zoo.crearobjeto( "ConfigurarAAOResumenDelDia")

		goServicios.Parametros.nucleo.Comunicaciones.EmpaquetarResumenDelDiaAlCerrarLaCaja = .t.

		loConfigurador.Configurar()

		this.assertTrue( "No configuro", loPar.lConfiguro ) 
		this.asserttrue( "No debe restaurar el parametro si configura correctamente", goServicios.Parametros.nucleo.Comunicaciones.EmpaquetarResumenDelDiaAlCerrarLaCaja )
		
		loConfigurador.release()
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestConfigurar_ErrorAlAnalizarelResultado
		local loConfigurador as ConfigurarAAOResumenDelDia of ConfigurarAAOResumenDelDia.prg, loPar as object

		loPar = _screen.zoo.crearobjeto( "ParametroParaTest", "zTestConfigurarAAOResumenDelDia.prg" )

		_Screen.mocks.agregarmock( "AnalizadorConfiguracionAAO" )
		_screen.mocks.AgregarSeteoMetodo( 'ANALIZADORCONFIGURACIONAAO', 'Obtenerparametrosresumendeldia', loPar )
		_screen.mocks.AgregarSeteoMetodo( 'ANALIZADORCONFIGURACIONAAO', 'Analizarresultado', .f., "'*OBJETO','*OBJETO'" )

		goServicios.Parametros.nucleo.Comunicaciones.EmpaquetarResumenDelDiaAlCerrarLaCaja = .f.
		
		loConfigurador = _screen.zoo.crearobjeto( "ConfigurarAAOResumenDelDia")

		goServicios.Parametros.nucleo.Comunicaciones.EmpaquetarResumenDelDiaAlCerrarLaCaja = .t.

		loConfigurador.Configurar()

		this.assertTrue( "Debe configurar", loPar.lConfiguro ) 
		this.asserttrue( "Debe restaurar el parametro si configura incorrectamente", !goServicios.Parametros.nucleo.Comunicaciones.EmpaquetarResumenDelDiaAlCerrarLaCaja )

		loConfigurador.release()
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestAutomatizarAlCerrarLaCajaYElUsuarioCancela
		local loConfiguracion as ConfigurarAAOResumenDelDia of ConfigurarAAOResumenDelDia.prg, loConjuntoDeDestinos as zoocoleccion OF zoocoleccion.prg

		_Screen.mocks.agregarmock( "AnalizadorConfiguracionAAO" )
		
		loConfiguracion = _screen.zoo.crearobjeto( "ConfigurarAAOResumenDelDia_test", "zTestConfigurarAAOResumenDelDia.prg" )
		loConfiguracion.lElUsuarioQuiereAutomatizarElEnvioDelResumenDelDia = .f.

		goServicios.Parametros.Nucleo.Comunicaciones.EmpaquetarResumenDelDiaAlCerrarLaCaja = .f.
		goServicios.Parametros.nucleo.Comunicaciones.EnviarALosBuzones = ""
		goServicios.Parametros.Nucleo.Comunicaciones.PreguntarRespectoDeLaAutomatizacionDelEmpaquetadoDelResumenDelDia = 1

		loConjuntoDeDestinos = _screen.zoo.crearobjeto( "zoocoleccion" )
		
		loConjuntoDeDestinos.agregar( _screen.zoo.crearobjeto( "ItemDestino", "objetoTransferencia.prg" ) )
		loConjuntoDeDestinos[1].cDescripcion = "Box1"
		loConjuntoDeDestinos[1].cDestino = "Box1"
		
		loConjuntoDeDestinos.agregar( _screen.zoo.crearobjeto( "ItemDestino", "objetoTransferencia.prg" ) )
		loConjuntoDeDestinos[2].cDescripcion = "Box2"
		loConjuntoDeDestinos[2].cDestino = "Box2"
		
		loConfiguracion.AutomatizarAlCerrarLaCaja( loConjuntoDeDestinos )
		this.asserttrue( "El usuario no quiere automatizar el envio del paquete.", !goServicios.Parametros.Nucleo.Comunicaciones.EmpaquetarResumenDelDiaAlCerrarLaCaja )
		this.assertequals( "Los buzones seleccionados no son correctos.", "", goServicios.Parametros.nucleo.Comunicaciones.EnviarALosBuzones )
		this.assertequals( "Debe volver a preguntar.", 1, goServicios.Parametros.Nucleo.Comunicaciones.PreguntarRespectoDeLaAutomatizacionDelEmpaquetadoDelResumenDelDia )

		loConfiguracion.release()
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestAutomatizarAlCerrarLaCajaYElUsuarioConfirma
		local loConfiguracion as ConfigurarAAOResumenDelDia of ConfigurarAAOResumenDelDia.prg, ;
			loPar as ParametroParaTest of zTestConfigurarAAOEnviarYRecibir.prg

		loPar = _screen.zoo.crearobjeto( "ParametroParaTest", "zTestConfigurarAAOEnviarYRecibir.prg" )

		_Screen.mocks.agregarmock( "AnalizadorConfiguracionAAO" )
		_screen.mocks.AgregarSeteoMetodo( 'ANALIZADORCONFIGURACIONAAO', 'Obtenerparametrosresumendeldia', loPar )
		_screen.mocks.AgregarSeteoMetodo( 'ANALIZADORCONFIGURACIONAAO', 'Analizarresultado', .T., "'*OBJETO','*OBJETO'" )

		loConfiguracion = _screen.zoo.crearobjeto( "ConfigurarAAOResumenDelDia_test", "zTestConfigurarAAOResumenDelDia.prg" )
		loConfiguracion.lElUsuarioQuiereAutomatizarElEnvioDelResumenDelDia = .t.

		goServicios.Parametros.Nucleo.Comunicaciones.EmpaquetarResumenDelDiaAlCerrarLaCaja = .f.
		goServicios.Parametros.nucleo.Comunicaciones.EnviarALosBuzones = ""
		goServicios.Parametros.Nucleo.Comunicaciones.PreguntarRespectoDeLaAutomatizacionDelEmpaquetadoDelResumenDelDia = 1

		loConjuntoDeDestinos = _screen.zoo.crearobjeto( "zoocoleccion" )

		loConjuntoDeDestinos.agregar( _screen.zoo.crearobjeto( "ItemDestino", "objetoTransferencia.prg" ) )
		loConjuntoDeDestinos[1].cDescripcion = "Box1"
		loConjuntoDeDestinos[1].cDestino = "Box1"
		
		loConjuntoDeDestinos.agregar( _screen.zoo.crearobjeto( "ItemDestino", "objetoTransferencia.prg" ) )
		loConjuntoDeDestinos[2].cDescripcion = "Box2"
		loConjuntoDeDestinos[2].cDestino = "Box2"

		loConjuntoDeDestinos.agregar( _screen.zoo.crearobjeto( "ItemDestino", "objetoTransferencia.prg" ) )
		loConjuntoDeDestinos[3].cDescripcion = "Carpeta"
		loConjuntoDeDestinos[3].cDestino = "Box2"
				
		loConfiguracion.AutomatizarAlCerrarLaCaja(loConjuntoDeDestinos )
		this.asserttrue( "El usuario Quiere automatizar el envio del paquete.", goServicios.Parametros.Nucleo.Comunicaciones.EmpaquetarResumenDelDiaAlCerrarLaCaja )
		this.assertequals( "Los buzones seleccionados no son correctos.", "BOX1,BOX2", goServicios.Parametros.nucleo.Comunicaciones.EnviarALosBuzones )
		this.assertequals( "Debe volver a preguntar.", 1, goServicios.Parametros.Nucleo.Comunicaciones.PreguntarRespectoDeLaAutomatizacionDelEmpaquetadoDelResumenDelDia )

		loConfiguracion.release()
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestNoAutomatizarAlCerrarLaCajaPorSeteoDeParametro
		local loConfiguracion as ConfigurarAAOResumenDelDia of ConfigurarAAOResumenDelDia.prg, ;
			loPar as ParametroParaTest of zTestConfigurarAAOEnviarYRecibir.prg

		loPar = _screen.zoo.crearobjeto( "ParametroParaTest", "zTestConfigurarAAOEnviarYRecibir.prg" )

		_Screen.mocks.agregarmock( "AnalizadorConfiguracionAAO" )
		_screen.mocks.AgregarSeteoMetodo( 'ANALIZADORCONFIGURACIONAAO', 'Obtenerparametrosresumendeldia', loPar )
		_screen.mocks.AgregarSeteoMetodo( 'ANALIZADORCONFIGURACIONAAO', 'Analizarresultado', .T., "'*OBJETO','*OBJETO'" )

		loConfiguracion = _screen.zoo.crearobjeto( "ConfigurarAAOResumenDelDia_test", "zTestConfigurarAAOResumenDelDia.prg" )
		loConfiguracion.lElUsuarioQuiereAutomatizarElEnvioDelResumenDelDia = .t.

		goServicios.Parametros.Nucleo.Comunicaciones.EmpaquetarResumenDelDiaAlCerrarLaCaja = .f.
		goServicios.Parametros.nucleo.Comunicaciones.EnviarALosBuzones = ""

		loConjuntoDeDestinos = _screen.zoo.crearobjeto( "zoocoleccion" )

		loConjuntoDeDestinos.agregar( _screen.zoo.crearobjeto( "ItemDestino", "objetoTransferencia.prg" ) )
		loConjuntoDeDestinos[1].cDescripcion = "Box1"
		loConjuntoDeDestinos[1].cDestino = "Box1"

		goServicios.Parametros.Nucleo.Comunicaciones.PreguntarRespectoDeLaAutomatizacionDelEmpaquetadoDelResumenDelDia = 2
				
		loConfiguracion.AutomatizarAlCerrarLaCaja(loConjuntoDeDestinos )

		this.asserttrue( "El usuario Quiere automatizar el envio del paquete.", !goServicios.Parametros.Nucleo.Comunicaciones.EmpaquetarResumenDelDiaAlCerrarLaCaja )
		this.assertequals( "Los buzones seleccionados no son correctos.", "", goServicios.Parametros.nucleo.Comunicaciones.EnviarALosBuzones )
		this.assertequals( "Debe volver a preguntar.", 2, goServicios.Parametros.Nucleo.Comunicaciones.PreguntarRespectoDeLaAutomatizacionDelEmpaquetadoDelResumenDelDia )

		loConfiguracion.release()
	endfunc
	

	*-----------------------------------------------------------------------------------------
	function zTestSetearSiVuelveAPreguntarLaAutomatizacionAlAceptarElSeteoAutomatico
		local loConfiguracion as ConfigurarAAOResumenDelDia of ConfigurarAAOResumenDelDia.prg, ;
			loPar as ParametroParaTest of zTestConfigurarAAOEnviarYRecibir.prg

		loPar = _screen.zoo.crearobjeto( "ParametroParaTest", "zTestConfigurarAAOEnviarYRecibir.prg" )

		_Screen.mocks.agregarmock( "AnalizadorConfiguracionAAO" )
		_screen.mocks.AgregarSeteoMetodo( 'ANALIZADORCONFIGURACIONAAO', 'Obtenerparametrosresumendeldia', loPar )
		_screen.mocks.AgregarSeteoMetodo( 'ANALIZADORCONFIGURACIONAAO', 'Analizarresultado', .T., "'*OBJETO','*OBJETO'" )

		loConfiguracion = _screen.zoo.crearobjeto( "ConfigurarAAOResumenDelDia_test", "zTestConfigurarAAOResumenDelDia.prg" )
		loConfiguracion.lElUsuarioQuiereAutomatizarElEnvioDelResumenDelDia = .t.
		loConfiguracion.lElUsuarioQuiereQueVuelvaAPreguntar = .f.

		goServicios.Parametros.Nucleo.Comunicaciones.EmpaquetarResumenDelDiaAlCerrarLaCaja = .f.
		goServicios.Parametros.nucleo.Comunicaciones.EnviarALosBuzones = ""

		loConjuntoDeDestinos = _screen.zoo.crearobjeto( "zoocoleccion" )

		loConjuntoDeDestinos.agregar( _screen.zoo.crearobjeto( "ItemDestino", "objetoTransferencia.prg" ) )
		loConjuntoDeDestinos[1].cDescripcion = "Box1"
		loConjuntoDeDestinos[1].cDestino = "Box1"

		goServicios.Parametros.Nucleo.Comunicaciones.PreguntarRespectoDeLaAutomatizacionDelEmpaquetadoDelResumenDelDia = 1
				
		loConfiguracion.AutomatizarAlCerrarLaCaja(loConjuntoDeDestinos )

		this.asserttrue( "El usuario Quiere automatizar el envio del paquete.", goServicios.Parametros.Nucleo.Comunicaciones.EmpaquetarResumenDelDiaAlCerrarLaCaja )
		this.assertequals( "Los buzones seleccionados no son correctos.", "BOX1", goServicios.Parametros.nucleo.Comunicaciones.EnviarALosBuzones )
		this.assertequals( "No debe volver a preguntar.", 1, goServicios.Parametros.Nucleo.Comunicaciones.PreguntarRespectoDeLaAutomatizacionDelEmpaquetadoDelResumenDelDia )
		
		loConfiguracion.release()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestSetearSiVuelveAPreguntarLaAutomatizacionAlNoAceptarElSeteoAutomatico
		local loConfiguracion as ConfigurarAAOResumenDelDia of ConfigurarAAOResumenDelDia.prg, ;
			loPar as ParametroParaTest of zTestConfigurarAAOEnviarYRecibir.prg

		loPar = _screen.zoo.crearobjeto( "ParametroParaTest", "zTestConfigurarAAOEnviarYRecibir.prg" )

		_Screen.mocks.agregarmock( "AnalizadorConfiguracionAAO" )
		_screen.mocks.AgregarSeteoMetodo( 'ANALIZADORCONFIGURACIONAAO', 'Obtenerparametrosresumendeldia', loPar )
		_screen.mocks.AgregarSeteoMetodo( 'ANALIZADORCONFIGURACIONAAO', 'Analizarresultado', .T., "'*OBJETO','*OBJETO'" )

		loConfiguracion = _screen.zoo.crearobjeto( "ConfigurarAAOResumenDelDia_test", "zTestConfigurarAAOResumenDelDia.prg" )
		loConfiguracion.lElUsuarioQuiereAutomatizarElEnvioDelResumenDelDia = .f.
		loConfiguracion.lElUsuarioQuiereQueVuelvaAPreguntar = .f.

		goServicios.Parametros.Nucleo.Comunicaciones.EmpaquetarResumenDelDiaAlCerrarLaCaja = .f.
		goServicios.Parametros.nucleo.Comunicaciones.EnviarALosBuzones = ""

		loConjuntoDeDestinos = _screen.zoo.crearobjeto( "zoocoleccion" )

		loConjuntoDeDestinos.agregar( _screen.zoo.crearobjeto( "ItemDestino", "objetoTransferencia.prg" ) )
		loConjuntoDeDestinos[1].cDescripcion = "Box1"
		loConjuntoDeDestinos[1].cDestino = "Box1"

		goServicios.Parametros.Nucleo.Comunicaciones.PreguntarRespectoDeLaAutomatizacionDelEmpaquetadoDelResumenDelDia = 1
				
		loConfiguracion.AutomatizarAlCerrarLaCaja(loConjuntoDeDestinos )

		this.asserttrue( "El usuario Quiere automatizar el envio del paquete.", !goServicios.Parametros.Nucleo.Comunicaciones.EmpaquetarResumenDelDiaAlCerrarLaCaja )
		this.assertequals( "Los buzones seleccionados no son correctos.", "", goServicios.Parametros.nucleo.Comunicaciones.EnviarALosBuzones )
		this.assertequals( "No debe volver a preguntar.", 2, goServicios.Parametros.Nucleo.Comunicaciones.PreguntarRespectoDeLaAutomatizacionDelEmpaquetadoDelResumenDelDia )
		
		loConfiguracion.release()
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
define class ConfigurarAAOResumenDelDia_test as ConfigurarAAOResumenDelDia of ConfigurarAAOResumenDelDia.prg
	lElUsuarioQuiereAutomatizarElEnvioDelResumenDelDia = .f.
	lElUsuarioQuiereQueVuelvaAPreguntar = .t.

	protected function ConsultarAlUsuarioSiDeseaAutomatizarElEnvioDelResumenDelDia( tcPar1 ) as Boolean
		return this.lElUsuarioQuiereAutomatizarElEnvioDelResumenDelDia
	endfunc

	protected function ConsultarSiVuelveaPreguntar() as Boolean
		return this.lElUsuarioQuiereQueVuelvaAPreguntar 
	endfunc

enddefine

define class ParametroParaTest as custom

	lConfiguro = .f.
	
	function Configurar() as object
		this.lConfiguro = .t.
		return null
	endfunc

enddefine

*!*	*-----------------------------------------------------------------------------------------
*!*	function obtenerXmlBase() as String
*!*	local lcRetorno as String
*!*	text to lcRetorno textmerge noshow pretext 1
*!*	<?xml version="1.0" encoding="utf-8" ?>
*!*	<Tareas>
*!*		<Tarea>
*!*			<id>0</id>
*!*			<Nombre>tarea1</Nombre>
*!*			<Habilitada>true</Habilitada>
*!*			<Periodicidad>
*!*				<MiliSegundos>0</MiliSegundos>
*!*				<Segundos>0</Segundos>
*!*				<Minutos>20</Minutos>
*!*				<Horas>0</Horas>
*!*				<Dias>0</Dias>
*!*			</Periodicidad>
*!*			<Mensaje>
*!*				<id>0</id>
*!*				<Nombre>Enviar y recibir paquete de datos, luego procesar</Nombre>
*!*				<Accion>Script</Accion>
*!*				<Objeto>
*!*					<RutaScript>C:\Dragonfish\Agente Acciones Organic\Scripts\enviarecibeprocesa.sz</RutaScript>
*!*					<RutaExeAplicacion>C:\Dragonfish</RutaExeAplicacion>
*!*					<NombreProducto>Dragonfish</NombreProducto>
*!*				</Objeto>
*!*				<TimeOut>
*!*					<MiliSegundos>0</MiliSegundos>
*!*					<Segundos>0</Segundos>
*!*					<Minutos>0</Minutos>
*!*					<Horas>0</Horas>
*!*					<Dias>0</Dias>
*!*				</TimeOut>
*!*			</Mensaje>
*!*		</Tarea>
*!*	</Tareas>
*!*	return lcRetorno
*!*	endfunc 
