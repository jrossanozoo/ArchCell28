**********************************************************************
define class zTestLectorFpw as FxuTestCase of FxuTestCase.prg

	#if .f.
		local this as zTestLectorFpw of zTestLectorFpw.prg
	#endif

	oLectorFpw = null
	oTools = null
	
	*---------------------------------
	function setup
		this.oLectorFpw = newobject( "LectorFpw", "LectorFpw.prg", "", _screen.zoo.ObtenerRutaTemporal() )
		this.oTools = newobject( "ToolTest", "", "", _screen.zoo.ObtenerRutaTemporal() )
	endfunc

	*---------------------------------
	function TearDown
		this.oLectorFpw = null
		this.oTools.BorrarArchivo()
		this.oTools = null
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestI_LeerEntradaDeArchivoInexistente
		local lcEsperado as String, lcActual as String
		
		*Arrange (Preparar)
		lcEsperado = ""
		
		*Act (Actuar)
		lcActual = this.oLectorFpw.Leer( "EntradaTest" )

		*Assert (Afirmar)
		this.assertequals( "BWWWWAAAAAA!!!!!!! No es correcta la entrada leída :'(", lcEsperado, lcActual )
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestI_LeerEntradaDeArchivoExistenteEntradaInexistente
		local lcEsperado as String, lcActual as String
		
		*Arrange (Preparar)
		lcEsperado = ""
		this.oTools.CrearArchivoConfiguracionRutaTemporal()
		
		*Act (Actuar)
		lcActual = this.oLectorFpw.Leer( "EntradaInexistente" )

		*Assert (Afirmar)
		this.assertequals( "BWWWWAAAAAA!!!!!!! No es correcta la entrada leída :'(", lcEsperado, lcActual )
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestI_LeerEntradaDeArchivoExistenteEntradaExistenteAlFinal
		local lcEsperado as String, lcActual as String
		
		*Arrange (Preparar)
		lcEsperado = "kdfafhlaskjdfhlasjkdfhlaskdj"
		this.oTools.CrearArchivoConfiguracionRutaTemporal()
		
		*Act (Actuar)
		lcActual = this.oLectorFpw.Leer( "EntradaTest" )

		*Assert (Afirmar)
		this.assertequals( "BWWWWAAAAAA!!!!!!! No es correcta la entrada leída :'(", lcEsperado, lcActual )
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestI_LeerEntradaDeArchivoExistenteEntradaExistenteAlPrincipio
		local lcEsperado as String, lcActual as String
		
		*Arrange (Preparar)
		lcEsperado = "OFF"
		this.oTools.CrearArchivoConfiguracionRutaTemporal()
		
		*Act (Actuar)
		lcActual = this.oLectorFpw.Leer( "screen" )

		*Assert (Afirmar)
		this.assertequals( "BWWWWAAAAAA!!!!!!! No es correcta la entrada leída :'(", lcEsperado, lcActual )
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestI_LeerEntradaDeArchivoExistenteEntradaExistenteEnMedio
		local lcEsperado as String, lcActual as String
		
		*Arrange (Preparar)
		lcEsperado = "ON"
		this.oTools.CrearArchivoConfiguracionRutaTemporal()
		
		*Act (Actuar)
		lcActual = this.oLectorFpw.Leer( "REsourCE" )

		*Assert (Afirmar)
		this.assertequals( "BWWWWAAAAAA!!!!!!! No es correcta la entrada leída :'(", lcEsperado, lcActual )
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestI_LeerEntradaDeArchivoExistenteEntradaExistenteVacia
		local lcEsperado as String, lcActual as String
		
		*Arrange (Preparar)
		lcEsperado = ""
		this.oTools.CrearArchivoConfiguracionRutaTemporal()
		
		*Act (Actuar)
		lcActual = this.oLectorFpw.Leer( "PROGCACHE" )

		*Assert (Afirmar)
		this.assertequals( "BWWWWAAAAAA!!!!!!! No es correcta la entrada leída :'(", lcEsperado, lcActual )
	endfunc
enddefine

define class ToolTest as custom
	cRuta = ""

	*-----------------------------------------------------------------------------------------
	function Init( tcRuta as String )
		this.cRuta = tcRuta
	endfunc 

	*-----------------------------------------------------------------------------------------
	function BorrarArchivo() as Void
		delete file ( addbs( this.cRuta ) + "config.fpw" )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function CrearArchivoConfiguracionRutaTemporal() as string
		local lcTexto as String, lcArchivo as String
		
		lcArchivo = addbs( this.cRuta ) + "config.fpw"
		text to lcTexto noshow textmerge
SCREEN = OFF
RESOURCE = ON
PROGCACHE =
EntradaTest = kdfafhlaskjdfhlasjkdfhlaskdj
		endtext
		strtofile( lcTexto, lcArchivo )
		
		return addbs( _screen.zoo.cRutaInicial ) + "TemporalTest"
	endfunc
enddefine
