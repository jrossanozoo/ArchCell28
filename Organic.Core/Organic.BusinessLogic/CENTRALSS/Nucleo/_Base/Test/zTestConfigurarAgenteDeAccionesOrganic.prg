**********************************************************************
Define Class zTestConfigurarAgenteDeAccionesOrganic as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as zTestConfigurarAgenteDeAccionesOrganic of zTestConfigurarAgenteDeAccionesOrganic.prg
	#ENDIF
	
	*-----------------------------------------------------------------------------------------
	function zTestInstanciar
		local loConfigurador as ConfigurarAgenteDeAccionesOrganic of ConfigurarAgenteDeAccionesOrganic.prg

		loConfigurador = _screen.zoo.crearobjeto( "ConfigurarAgenteDeAccionesOrganic" )
		this.assertequals( "No es un objeto de la clase valida.", "CONFIGURARAGENTEDEACCIONESORGANIC", upper( loConfigurador.Class ) )
		loConfigurador.release()

		_screen.mocks.VerificarEjecucionDeMocks()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestConfigurarAgente
		local loConfigurador as ConfigurarAgenteDeAccionesOrganic of ConfigurarAgenteDeAccionesOrganic.prg

		_screen.mocks.agregarmock( "ConfigurarAAOResumenDelDia" )
		_screen.mocks.agregarmock( "ConfigurarAAOEnviarYRecibir" )
		_screen.mocks.agregarmock( "ConfigurarAAODatosAplicacion" )
		_screen.mocks.agregarmock( "DatosAAO" )

		_screen.mocks.AgregarSeteoMetodo( 'CONFIGURARAAOENVIARYRECIBIR', 'Configurar', .T., "'*OBJETO',.F." )
		_screen.mocks.AgregarSeteoMetodo( 'CONFIGURARAAORESUMENDELDIA', 'Configurar', .T., "'*OBJETO',.F." )
		_screen.mocks.AgregarSeteoMetodo( 'ConfigurarAAODatosAplicacion', 'Configurar', .T., "'*OBJETO',.F." )

		loConfigurador = _screen.zoo.crearobjeto( "ConfigurarAgenteDeAccionesOrganic" )
		loConfigurador.ConfigurarAgente()

		loConfigurador.release()

		_screen.mocks.VerificarEjecucionDeMocks()
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestConfigurarAgentePorActualizacion_NoConfigurarPorNoHaberCambioDeVersion
		local loConfigurador as ConfigurarAgenteDeAccionesOrganic of ConfigurarAgenteDeAccionesOrganic.prg

		_screen.mocks.agregarmock( "ConectorAgenteDeAccionesOrganic" )
		_screen.mocks.agregarmock( "InstaladorAgenteDeAccionesOrganic" )
		_screen.mocks.agregarmock( "ConfigurarAAOResumenDelDia" )
		_screen.mocks.agregarmock( "ConfigurarAAOEnviarYRecibir" )
		_screen.mocks.agregarmock( "ConfigurarAAODatosAplicacion" )

		_screen.mocks.AgregarSeteoMetodo( 'InstaladorAgenteDeAccionesOrganic', 'Instalar', .f. )
		_screen.mocks.AgregarSeteoMetodo( 'CONECTORAGENTEDEACCIONESORGANIC', 'Ejecutascriptorganicpormediodelgestor', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'CONFIGURARAAODATOSAPLICACION', 'Configurar', .T., "'*OBJETO',.F." )
		_screen.mocks.AgregarSeteoMetodo( 'CONFIGURARAAOENVIARYRECIBIR', 'Configurar', .T., "'*OBJETO',.F." )
		_screen.mocks.AgregarSeteoMetodo( 'CONFIGURARAAORESUMENDELDIA', 'Configurar', .T., "'*OBJETO',.F." )

		loConfigurador = _screen.zoo.crearobjeto( "ConfigurarAgenteDeAccionesOrganic" )
		loConfigurador.ConfigurarAgentePorActualizacion()

		loConfigurador.release()

		_screen.mocks.VerificarEjecucionDeMocks()
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestConfigurarAgentePorActualizacion_ConfigurarPorHaberCambioDeVersion
		local loConfigurador as ConfigurarAgenteDeAccionesOrganic of ConfigurarAgenteDeAccionesOrganic.prg

		_screen.mocks.agregarmock( "ConectorAgenteDeAccionesOrganic" )
		_screen.mocks.agregarmock( "InstaladorAgenteDeAccionesOrganic" )
		_screen.mocks.agregarmock( "ConfigurarAAOResumenDelDia" )
		_screen.mocks.agregarmock( "ConfigurarAAOEnviarYRecibir" )
		_screen.mocks.agregarmock( "ConfigurarAAODatosAplicacion" )

		_screen.mocks.AgregarSeteoMetodo( 'InstaladorAgenteDeAccionesOrganic', 'Instalar', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'InstaladorAgenteDeAccionesOrganic', 'Marcarcomoactualizado', .T. )
		_screen.mocks.AgregarSeteoMetodo( 'CONECTORAGENTEDEACCIONESORGANIC', 'Ejecutascriptorganicpormediodelgestor', .T. )

		_screen.mocks.AgregarSeteoMetodo( 'CONFIGURARAAOENVIARYRECIBIR', 'Configurar', .T., "'*OBJETO',.T." )
		_screen.mocks.AgregarSeteoMetodo( 'CONFIGURARAAORESUMENDELDIA', 'Configurar', .T., "'*OBJETO',.T." )
		_screen.mocks.AgregarSeteoMetodo( 'CONFIGURARAAODATOSAPLICACION', 'Configurar', .T., "'*OBJETO',.T." )

		loConfigurador = _screen.zoo.crearobjeto( "ConfigurarAgenteDeAccionesOrganic" )
		loConfigurador.ConfigurarAgentePorActualizacion()

		loConfigurador.release()
		
		_screen.mocks.VerificarEjecucionDeMocks()
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestBindeoCambioDeParametros
		local loObjetoBindeoTest as ObjetoBindeo of zTestConfigurarAgenteDeAccionesOrganic.prg, ;
			loConfigurador as ConfigurarAgenteDeAccionesOrganic of ConfigurarAgenteDeAccionesOrganic.prg
		
		_screen.mocks.agregarmock( "ConfigurarAAOResumenDelDia" )
		_screen.mocks.agregarmock( "ConfigurarAAOEnviarYRecibir" )
		_screen.mocks.agregarmock( "ConfigurarAAODatosAplicacion" )
		_screen.mocks.AgregarSeteoMetodo( 'CONFIGURARAAOENVIARYRECIBIR', 'Configurar', .T., "'*OBJETO',.f." )
		_screen.mocks.AgregarSeteoMetodo( 'CONFIGURARAAORESUMENDELDIA', 'Configurar', .T., "'*OBJETO',.f." )
		_screen.mocks.AgregarSeteoMetodo( 'CONFIGURARAAODATOSAPLICACION', 'Configurar', .T., "'*OBJETO',.f." )

		loObjetoBindeoTest = _screen.zoo.crearobjeto( "ObjetoBindeo", "zTestConfigurarAgenteDeAccionesOrganic.prg" )
		loConfigurador = _screen.zoo.crearobjeto( "ConfigurarAgenteDeAccionesOrganic" )
		bindevent( loConfigurador, "ConfigurarAgente", loObjetoBindeoTest, "CambioParametros", 1 )
		
		raiseevent( goParametros.oDatos, "CambioParametros" )
		this.asserttrue( "No se inicio el proceso de configuracion del AAO.", loObjetoBindeoTest.lCambioParametro )

		loObjetoBindeo = null
		loConfigurador.Release()

		_screen.mocks.VerificarEjecucionDeMocks()
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
define class ObjetoBindeo as Custom

	lCambioParametro = .f.
	
	*-----------------------------------------------------------------------------------------
	function CambioParametros( tx1, tx2, tx3, tx4 ) as Void
		this.lCambioParametro = .t.
	endfunc 

enddefine

