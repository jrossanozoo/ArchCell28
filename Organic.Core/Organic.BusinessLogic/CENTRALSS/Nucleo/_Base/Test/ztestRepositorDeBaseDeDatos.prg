**********************************************************************
Define Class ztestRepositorDeBaseDeDatos as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as ztestRepositorDeBaseDeDatos of ztestRepositorDeBaseDeDatos.prg
	#ENDIF
	
	*---------------------------------
	Function Setup

	EndFunc
	
	*---------------------------------
	Function TearDown

	EndFunc

	*-----------------------------------------------------------------------------------------
	function zTestObtenerSucursalPreferenteExisteLaBase
		local loBd as RepositorDeBaseDeDatos of RepositorDeBaseDeDatos.prg

		loBd = _screen.zoo.crearobjeto( "RepositorDeBaseDeDatos" )
		_screen.mocks.agregarmock( "AplicacionBase" )
		_screen.mocks.AgregarSeteoMetodo( 'APLICACIONBASE', 'Verificarexistenciabase', .T., "[BASE1]" )

		goParametros.Nucleo.OrigenDeDatosPreferente = 'BASE1'
		
		loBd.oApp = _screen.zoo.crearobjeto( "AplicacionBase" )
		lcSucursal = loBd.ObtenerBaseDeDatos()
		release loBd
		
		this.assertequals( "La base obtenida no es la correcta.", 'BASE1' , lcSucursal )

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestObtenerSucursalPreferenteNoExisteLaBaseSeSeteaEnOtra
		local loBd as RepositorDeBaseDeDatos of RepositorDeBaseDeDatos.prg

		loBd = _screen.zoo.crearobjeto( "RepositorDeBaseDeDatos" )
		_screen.mocks.agregarmock( "AplicacionBase" )
		_screen.mocks.AgregarSeteoMetodo( 'APLICACIONBASE', 'Verificarexistenciabase', .F., "[BASE1]" )
		_screen.mocks.AgregarSeteoMetodo( 'APLICACIONBASE', 'ObtenerPrimeraSucursalExistente', "BASE2"  )

		goParametros.Nucleo.OrigenDeDatosPreferente = 'BASE1'
		
		loBd.oApp = _screen.zoo.crearobjeto( "AplicacionBase" )
		lcSucursal = loBd.ObtenerBaseDeDatos()
		release loLogin
		
		this.assertequals( "La base obtenida no es la correcta.", 'BASE2' , lcSucursal )

	endfunc 

EndDefine
