**********************************************************************
Define Class zTestInstaladorAgenteDeAccionesOrganic As FxuTestCase Of FxuTestCase.prg

	#If .F.
		Local This As zTestInstaladorAgenteDeAccionesOrganic Of zTestInstaladorAgenteDeAccionesOrganic.prg
	#Endif

	*---------------------------------
	Function zTestNoInstalarPorNoHaberActualizacion
		local loInstalador as InstaladorAgenteDeAccionesOrganic of InstaladorAgenteDeAccionesOrganic.prg
		
		_screen.mocks.AgregarMock( "DatosAAO" )
		_screen.mocks.AgregarSeteoMetodo( 'DATOSAAO', 'Obtenerversionultimaactualizacion', _screen.zoo.app.ObtenerVersion() )

		loInstalador = _Screen.zoo.crearobjeto( "InstaladorAgenteDeAccionesOrganic" )
		
		loInstalador.Instalar()
		
		loInstalador.Release()
		
		_screen.mocks.verificarejecuciondemocks()
	Endfunc

	*---------------------------------
	Function zTestInstalarEnElMismoHilo
		local loInstalador as InstaladorAgenteDeAccionesOrganic of InstaladorAgenteDeAccionesOrganic.prg

		_screen.mocks.AgregarMock( "DatosAAO" )
		_screen.mocks.AgregarSeteoMetodo( 'DATOSAAO', 'Obtenerversionultimaactualizacion', "cualquiercosa" )

		loInstalador = _Screen.zoo.crearobjeto( "InstaladorAgenteDeAccionesOrganicParaTest", "zTestInstaladorAgenteDeAccionesOrganic.prg" )
		loInstalador.lForzarDesinstalacion = .f.
		loInstalador.Instalar()
		
		this.asserttrue( "Debe instalar en el mismo hilo", loInstalador.lCorrioEnElMismoHilo )
		loInstalador.Release()

		_screen.mocks.verificarejecuciondemocks()
	Endfunc

	*---------------------------------
	Function zTestMarcarComoActualizado
		local loInstalador as InstaladorAgenteDeAccionesOrganic of InstaladorAgenteDeAccionesOrganic.prg
		
		_screen.mocks.AgregarMock( "DatosAAO" )
		_screen.mocks.AgregarSeteoMetodo( 'DATOSAAO', 'Setearversionultimaactualizacion', .T., "[" + _screen.zoo.app.ObtenerVersion() + "]" )

		loInstalador = _Screen.zoo.crearobjeto( "InstaladorAgenteDeAccionesOrganic" )
		
		loInstalador.MarcarComoActualizado()
		
		loInstalador.Release()

		_screen.mocks.verificarejecuciondemocks()
	Endfunc
Enddefine

define class InstaladorAgenteDeAccionesOrganicParaTest as InstaladorAgenteDeAccionesOrganic of InstaladorAgenteDeAccionesOrganic.prg

	lCorrioEnElMismoHilo = .f.
	
	*-----------------------------------------------------------------------------------------
	protected function InstalarEnElMismoHilo() as Boolean 
		this.lCorrioEnElMismoHilo = .t.
		
		return .t.
	endfunc 


enddefine

