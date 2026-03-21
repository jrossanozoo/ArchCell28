**********************************************************************
Define Class zTestGestorBaseDeDatos as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as zTestGestorBaseDeDatos of zTestGestorBaseDeDatos.prg
	#ENDIF

	*-----------------------------------------------------------------------------------------
	function zTestVerificarExistenciaBDEliminada
		local loGestorDB as Object
		
		loGestorDB = _screen.zoo.crearobjeto( "GestorBaseDeDatos" ) 
		
		if goServicios.Datos.EsNativa()
			lcBaseDeDatos = addbs( _screen.zoo.cRutaInicial ) + alltrim( _screen.zoo.apP.cSucursalActiva )
		else
			lcBaseDeDatos = alltrim( _screen.zoo.apP.cSucursalActiva )
		endif
		
		this.asserttrue( "No encontró una base de datos existente", loGestorDB.VerificarExistenciaBDEliminada( lcBaseDeDatos ) )
		
		if goServicios.Datos.EsNativa()
			lcBaseDeDatos = _screen.zoo.cRutaInicial
		else
			lcBaseDeDatos = alltrim( _screen.zoo.apP.cSucursalActiva + sys( 2015 ) )
		endif

		this.asserttrue( "Falló la validación con una base de datos inexistente", !loGestorDB.VerificarExistenciaBDEliminada( lcBaseDeDatos ))
		
		loGestorDB.release()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestSiFallaDebeEliminarDeLaEmp
		local loGestorDB as GestorBaseDeDatos of GestorBaseDeDatos.prg, ;
			loHelper as TEST_HelperGestorBaseDeDatos of zTestGestorBaseDeDatos.prg
			
		_Screen.mocks.agregarmock( "adnimplant" )

		_screen.mocks.AgregarSeteoMetodo( 'ADNIMPLANT', 'Ejecutaradnimplantv2', .F., "1,'PRUEBA',.T." ) && Se hace fallar el adn implant!
		
		loHelper = _screen.zoo.crearobjeto( "TEST_HelperGestorBaseDeDatos", "zTestGestorBaseDeDatos.prg" )
		loHelper.cBaseDeDatos = "PRUEBA"
		loHelper.lZTESTPasoPorEliminarCreacionErronea  = .f.
		loHelper.lzTESTPASOPORFINALIZAR = .f.
		loGestorDB = _screen.zoo.crearobjeto( "GestorBaseDeDatos", "", loHelper ) 
		loGestorDB.GenerarBaseDeDatos()
		
		this.asserttrue( "Si falla el adnimplant debe eliminar el registro de la emp que no se pudo crear!", loHelper.lZTESTPasoPorEliminarCreacionErronea  )
		this.asserttrue( "Si falla el adnimplant debe pasar por el finalizar del acceso a datos para que cierre la conexion sql!", loHelper.lzTESTPASOPORFINALIZAR )		
		loGestorDB.release()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestU_VerificarSiEsBDMarcadaComoReplica
		local loGestor as GestorBaseDeDatos of GestorBaseDeDatos.prg
		loGestorDB = _screen.Zoo.CrearObjeto( "GestorBaseDeDatos", "GestorBaseDeDatos.prg", null )
		this.AssertTrue( "La base de datos PAISES no es de replica.", !loGestorDB.VerificarSiEsBDMarcadaComoReplica( "PAISES" ) )
	endfunc

EndDefine




*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class TEST_HelperGestorBaseDeDatos as Custom

	cBaseDeDatos = ""
	lZTESTPasoPorEliminarCreacionErronea = .f.
	lZTESTPasoPorFinalizar = .f.
	
	*-----------------------------------------------------------------------------------------
	function ObtenerSucursalOrigen() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerBaseDeDatos() as Void
		return this.cBaseDeDatos
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerRutaOrigen() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerRutaDestino() as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EliminarCreacionErronea() as Void
		this.lZTESTPasoPorEliminarCreacionErronea = .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Finalizar() as Void
		this.lZTESTPasoPorFinalizar = .t.
	endfunc 
	
	function EsSQLServer() as Boolean
		return .f.
	endfunc 


enddefine