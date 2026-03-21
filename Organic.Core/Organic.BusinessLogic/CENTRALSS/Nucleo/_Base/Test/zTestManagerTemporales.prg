**********************************************************************
define class zTestManagerTemporales as FxuTestCase of FxuTestCase.prg

	#if .f.
		local this as zTestManagerTemporales of zTestManagerTemporales.prg
	#endif

	oTools = null

	*---------------------------------
	function setup
		this.oTools = newobject( "ToolTest" )
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestI_ObtenerRutaSinProyectoAsignado
		local lcEsperado as string, lcActual as string, lcActualAux as string, loManager as Object

		*Arrange (Preparar)
		loPreparacionTest = newobject( "PreparacionTest" )
		loManager = loPreparacionTest.ArmarPreparacion( this.oServicioMocks )
		lcEsperado = addbs( getenv( "tmp" ) ) + "zooTmp\" + this.oTools.ObtenerSufijoSegunFecha()

		*Act (Actuar)
		lcActual = loManager.ObtenerCarpeta()
		lcActualAux = left( lcActual, len( lcActual ) - 11 )

		*Assert (Afirmar)
		this.assertequals( "Qué macana, no se obtuvo la carpeta esperada :(", upper( lcEsperado ), lcActualAux )
		this.Asserttrue( "Pero, la pucha, no se creó la ruta temporal º_º", directory( lcActual ) )
		loManager.BorrarCarpeta()
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestI_ObtenerRutaConProyectoAsignado
		local lcEsperado as string, lcActual as string, loManager as Object

		*Arrange (Preparar)
		loPreparacionTest = newobject( "PreparacionTest" )
		loManager = loPreparacionTest.ArmarPreparacion( this.oServicioMocks )
		loManager.cProyecto = "TesT"
		lcEsperado = addbs( getenv( "tmp" ) ) + "zooTmp\Test\" + this.oTools.ObtenerSufijoSegunFecha()

		*Act (Actuar)
		lcActual = loManager.ObtenerCarpeta()
		lcActualAux = left( lcActual, len( lcActual ) - 11 )

		*Assert (Afirmar)
		this.assertequals( "Qué macana, no se obtuvo la carpeta esperada :(", upper( lcEsperado ), lcActualAux )
		this.Asserttrue( "Pero, la pucha, no se creó la ruta temporal º_º", directory( lcActual ) )
		loManager.BorrarCarpeta()
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestI_ObtenerRutaConProyectoAsignadoEnElConstructor
		local lcEsperado as string, lcActual as string, loManager as Object

		*Arrange (Preparar)
		loPreparacionTest = newobject( "PreparacionTest" )
		loManager = loPreparacionTest.ArmarPreparacion( this.oServicioMocks, "TesT2" )
		lcEsperado = addbs( getenv( "tmp" ) ) + "zooTmp\Test2\" + this.oTools.ObtenerSufijoSegunFecha()

		*Act (Actuar)
		lcActual = loManager.ObtenerCarpeta()
		lcActualAux = left( lcActual, len( lcActual ) - 11 )

		*Assert (Afirmar)
		this.assertequals( "Qué macana, no se obtuvo la carpeta esperada :(", upper( lcEsperado ), lcActualAux )
		this.Asserttrue( "Pero, la pucha, no se creó la ruta temporal º_º", directory( lcActual ) )
		loManager.BorrarCarpeta()
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestI_ObtenerRutaConRutaInicialModificadaPorConfiguracion
		local lcEsperado as string, lcActual as string, loManager as Object

		*Arrange (Preparar)
		lcEsperado = addbs( _screen.zoo.cRutaInicial ) + "TemporalTest\"
		loPreparacionTest = newobject( "PreparacionTest" )
		loManager = loPreparacionTest.ArmarPreparacion( this.oServicioMocks, "", lcEsperado )

		*Act (Actuar)
		lcActual = loManager.ObtenerCarpeta()
		lcActualAux = left( lcActual, len( lcActual ) - 11 )

		*Assert (Afirmar)
		this.assertequals( "Qué macana, no se obtuvo la carpeta esperada :(", upper( lcEsperado + this.oTools.ObtenerSufijoSegunFecha() ), lcActualAux )
		this.Asserttrue( "Pero, la pucha, no se creó la ruta temporal º_º", directory( lcActual ) )
		loManager.BorrarCarpeta()
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestI_BorrarCarpeta
		local lcEsperado as string, lcActual as string

		*Arrange (Preparar)
		loPreparacionTest = newobject( "PreparacionTest" )
		loManager = loPreparacionTest.ArmarPreparacion( this.oServicioMocks )

		*Act (Actuar)
		lcActual = loManager.ObtenerCarpeta()
		loManager.BorrarCarpeta()

		*Assert (Afirmar)
		this.Asserttrue( "Estamos en el horno! No se borró la ruta temporal ¬_¬", !directory( lcActual ) )
	endfunc
enddefine

*-----------------------------------------------------------------------------------------
define class PreparacionTest as custom
	*-----------------------------------------------------------------------------------------
	function ArmarPreparacion( toServicioMocks as Object, tcProyecto as String, tcRutaTemporales as String ) as Object
		local loParametros as Object, loLectorFpwMock as Object, loManager as Object
		
		loLectorFpwMock = toServicioMocks.GenerarMock( "LectorFpw" )
		loParametros = newobject( "collection" )
		loParametros.Add( "RutaTemporal" )
		loLectorFpwMock.EstablecerExpectativa( "Leer", iif( empty( tcRutaTemporales ), "", tcRutaTemporales ), loParametros )

		loManager = newobject( "ManagerTemporales", "ManagerTemporales.prg", "", ;
							iif( empty( tcProyecto ), "", tcProyecto ), loLectorFpwMock )

		return loManager
	endfunc 

enddefine

*-----------------------------------------------------------------------------------------
define class ToolTest as custom

	*-----------------------------------------------------------------------------------------
	function ObtenerSufijoSegunFecha() as string
		local lcRetorno as string

		lcRetorno = addbs( "A_" + transform( year( date() ) ) ) + ;
			addbs( "M_" + padl( transform( month( date() ) ), 2, "0" ) ) + ;
			addbs( "D_" + padl( transform( day( date() ) ) , 2, "0" ) )

		return lcRetorno
	endfunc
enddefine
