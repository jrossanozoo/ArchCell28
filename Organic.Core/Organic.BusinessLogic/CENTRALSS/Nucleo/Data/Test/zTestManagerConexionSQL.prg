**********************************************************************
Define Class zTestManagerConexionSQL as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as zTestManagerConexionSQL of zTestManagerConexionSQL.prg
	#ENDIF
	
	oLibrerias = Null
	lExisteVariable = .F.
	lUsaCapaDePresentacion = .F.
	*-----------------------------------------------------------------------------------------
	function Setup
		This.oLibrerias = goServicios.Librerias
		goServicios.Librerias = null
		if vartype( _screen.lUsaCapaDePresentacion ) == "L"
			This.lExisteVariable = .T.
			This.lUsaCapaDePresentacion = _screen.lUsaCapaDePresentacion
			_screen.lUsaCapaDePresentacion = .F.
		else
			_Screen.AddProperty( "lUsaCapaDePresentacion", .F. )
		Endif
	endfunc 
	*-----------------------------------------------------------------------------------------
	function TearDown
		goServicios.Librerias = This.oLibrerias
		This.oLibrerias = null
		if This.lExisteVariable
			_screen.lUsaCapaDePresentacion = This.lUsaCapaDePresentacion
		else
			removeproperty( _Screen, "lUsaCapaDePresentacion" )
		Endif
	endfunc 
	*-----------------------------------------------------------------------------------------
	Function zTestSQLSERVERU_ObtenerConexionFallida
		local loManager as ManagerConexionASql of ManagerConexionASql.prg , loError as Exception
		loManager = newobject( "AuxManager" )
		_Screen.Mocks.Agregarmock( "Librerias" )
		_Screen.Mocks.AgregarSeteoMetodo( "Librerias", "ObtenerIdProcesoActual", 1 )
		_Screen.Mocks.AgregarSeteoMetodo( "Librerias", "TerminarProcesosRelacionados", "*THROW", "1" )
		goServicios.Librerias = _Screen.Zoo.CrearObjeto( "Librerias" )
		try
			loManager.lServicioFrenado = .T.
			loManager.Obtenerconexion()
			This.AssertTrue( "Debio Tirar Excepcion", .F. )
		catch to loError		
			This.AssertEquals( "La excepcion no es la esperada", "Error Generador por Mock Terminarprocesosrelacionados(1)", loError.UserValue.message )
		Endtry
	endfunc 
enddefine

*-----------------------------------------------------------------------------------------
define class AuxManager as ManagerConexionASql of ManagerConexionASql.Prg

	*-----------------------------------------------------------------------------------------
	protected function GetConnectionHandler( tcStringConnect as String ) as Integer
		return -1
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerIdConexion( tcStringConnect as String ) as Integer
		return this.TryConnect( tcStringConnect )
	endfunc 

enddefine
