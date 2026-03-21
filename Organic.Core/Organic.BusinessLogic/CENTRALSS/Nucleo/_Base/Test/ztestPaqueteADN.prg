**********************************************************************
DEFINE CLASS ztestPaqueteADN as FxuTestCase OF FxuTestCase.prg

	cCurrentdir = ""
	cNombrePaquete = "NOTIENEQUEEXISTIR"	

	#IF .f.
	*
	*  this LOCAL declaration enabled IntelliSense for
	*  the THIS object anywhere in this class
	*
	LOCAL THIS AS ztestPaqueteADN OF ztestPaqueteADN.PRG
	#ENDIF
	*  
	*  declare properties here that are used by one or
	*  more individual test methods of this class
	*
	*  for example, if you create an object to a custom
	*  THIS.Property in THIS.Setup(), estabish the property
	*  here, where it will be available (to IntelliSense)
	*  throughout:
	*
*!*		ioObjectToBeTested = .NULL.
*!*		icSetClassLib = SPACE(0)


	* the icTestPrefix property in the base FxuTestCase class defaults
	* to "TEST" (not case sensitive). There is a setting on the interface
	* tab of the options form (accessible via right-clicking on the
	* main FoxUnit form and choosing the options item) labeld as
	* "Load and run only tests with the specified icTestPrefix value in test classes"
	*
	* If this is checked, then only tests in any test class that start with the
	* prefix specified with the icTestPrefix property value will be loaded
	* into FoxUnit and run. You can override this prefix on a per-class basis.
	*
	* This makes it possible to create ancillary methods in your test classes
	* that can be shared amongst other test methods without being run as
	* tests themselves. Additionally, this means you can quickly and easily 
	* disable a test by modifying it and changing it's test prefix from
	* that specified by the icTestPrefix property
	
	* Additionally, you could set this in the INIT() method of your derived class
	* but make sure you dodefault() first. When the option to run only
	* tests with the icTestPrefix specified is checked in the options form,
	* the test classes are actually all instantiated individually to pull
	* the icTestPrefix value.

*!*		icTestPrefix = "<Your preferred prefix here>"
	
	********************************************************************
	FUNCTION Setup
		this.cCurrentDir = Curdir()
		if ( directory( "Paquetes" ) )
			_screen.zoo.invocarmetodoestatico( "System.IO.Directory", "Delete", addbs(this.cCurrentDir ) + "Paquetes", .t. )
		endif
		if ( !directory( "TerminatorGenerados" ) )
			md "TerminatorGenerados"
		endif
	*
	*  put common setup code here -- this method is called
	*  whenever THIS.Run() (inherited method) to run each
	*  of the custom test methods you add, specific test
	*  methods that are not inherited from FoxUnit
	*
	*  do NOT call THIS.Assert..() methods here -- this is
	*  NOT a test method
	*
    *  for example, you can instantiate all the object(s)
    *  you will be testing by the custom test methods of 
    *  this class:
*!*		THIS.icSetClassLib = SET("CLASSLIB")
*!*		SET CLASSLIB TO MyApplicationClassLib.VCX ADDITIVE
*!*		THIS.ioObjectToBeTested = CREATEOBJECT("MyNewClassImWriting")

	ENDFUNC
	*********** encierra en un gran try-catch cada test para levantar
	******* nuestros propios objetos de error creados con try catch en el codigo

	
	
	**********************************************************************
	function zTestVerificarNombrePaqueteVacio
		Local loPaqueteADN as PaqueteADN of PaqueteADN.prg, llRetorno as boolean
		
		loPaqueteADN = _screen.zoo.CrearObjeto( "PaqueteADN" )		
	
		llRetorno = loPaqueteADN.VerificarNombrePaquete( "" )
		this.AssertTrue( "No debería haber validado, porque no se especificó el nombre del paquete.", !llRetorno )
		
		loPaqueteADN.release()
	endfunc
	
	**********************************************************************	
	function zTestVerificarNombrePaqueteNoExiste
		Local loPaqueteADN as PaqueteADN of PaqueteADN.prg, llRetorno as boolean

		=CargarDatosBasicos( this.cNombrePaquete, .f., .f., .f., .f., .f., .f. )		

		loPaqueteADN = _screen.zoo.CrearObjeto( "PaqueteADN" )		
		loPaqueteADN.oFunciones = CrearObjetoFuncion( this.cCurrentDir )
	
		llRetorno = loPaqueteADN.VerificarNombrePaquete( this.cNombrePaquete )
		this.AssertTrue( "No debería haber validado, porque no existe el nombre del paquete.", !llRetorno )
		
		loPaqueteADN.release()
	endfunc
	
	**********************************************************************	
	function zTestVerificarNombrePaqueteNoExisteFolder
		Local loPaqueteADN as PaqueteADN of PaqueteADN.prg, llRetorno as boolean
										
		=CargarDatosBasicos( this.cNombrePaquete, .f., .f., .f., .f., .f., .f. )		
		
		loPaqueteADN = _screen.zoo.CrearObjeto( "PaqueteADN" )
		loPaqueteADN.oFunciones = CrearObjetoFuncion( this.cCurrentDir )
	
		llRetorno = loPaqueteADN.VerificarNombrePaquete( this.cNombrePaquete )
		this.AssertTrue( "No debería haber validado, porque no existe la carpeta con el nombre del paquete.", !llRetorno )
		
		loPaqueteADN.release()
	endfunc

	**********************************************************************	
	function zTestVerificarNombrePaqueteNoExisteFolderDestino
		Local loPaqueteADN as PaqueteADN of PaqueteADN.prg, llRetorno as boolean
										
		=CargarDatosBasicos( this.cNombrePaquete, .t., .f., .f., .f., .f., .f. )		

		loPaqueteADN = _screen.zoo.CrearObjeto( "PaqueteADN" )
		loPaqueteADN.oFunciones = CrearObjetoFuncion( this.cCurrentDir )
	
		llRetorno = loPaqueteADN.VerificarNombrePaquete( this.cNombrePaquete )
		this.AssertTrue( "No debería haber validado, porque no existe la carpeta destino.", !llRetorno )
		
		loPaqueteADN.release()
	endfunc

	**********************************************************************	
	function zTestVerificarNombrePaqueteExiste
		Local loPaqueteADN as PaqueteADN of PaqueteADN.prg, llRetorno as boolean
										
		=CargarDatosBasicos( this.cNombrePaquete, .t., .t., .t., .f., .f., .f. )		
		
		loPaqueteADN = _screen.zoo.CrearObjeto( "PaqueteADN" )
		loPaqueteADN.oFunciones = CrearObjetoFuncion( this.cCurrentDir )

		llRetorno = loPaqueteADN.VerificarNombrePaquete( this.cNombrePaquete )
		this.AssertTrue( "Debería haber validado, porque existe el nombre del paquete.", llRetorno )
		
		loPaqueteADN.release()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestVerificarIntegridadNoHayCambios
		local loPaqueteADN as PaqueteADN of PaqueteADN.prg, llRetorno as Boolean

		=CargarDatosBasicos( this.cNombrePaquete, .t., .t., .t., .t., .t., .f. )

		loPaqueteADN = _screen.zoo.CrearObjeto( "PaqueteADN" )
		loPaqueteADN.oFunciones = CrearObjetoFuncion( this.cCurrentDir )

		llRetorno = loPaqueteADN.TieneQueAplicarCambios( this.cNombrePaquete )
		this.AssertTrue( "No debería haber detectado cambios.", !llRetorno )
		
		loPaqueteADN.release()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestVerificarIntegridadHayCambiosFaltanArchivos
		local loPaqueteADN as PaqueteADN of PaqueteADN.prg, llRetorno as Boolean

		=CargarDatosBasicos( this.cNombrePaquete, .t., .t., .t., .t., .f., .f. )

		loPaqueteADN = _screen.zoo.CrearObjeto( "PaqueteADN" )
		loPaqueteADN.oFunciones = CrearObjetoFuncion( this.cCurrentDir )

		llRetorno = loPaqueteADN.TieneQueAplicarCambios( this.cNombrePaquete )
		this.AssertTrue( "Debería haber detectado cambios.", llRetorno )
		
		loPaqueteADN.release()
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestVerificarIntegridadHayCambiosHayDiferenciaDeArchivos
		local loPaqueteADN as PaqueteADN of PaqueteADN.prg, llRetorno as Boolean

		=CargarDatosBasicos( this.cNombrePaquete, .t., .t., .t., .t., .t., .t. )

		loPaqueteADN = _screen.zoo.CrearObjeto( "PaqueteADN" )
		loPaqueteADN.oFunciones = CrearObjetoFuncion( this.cCurrentDir )

		llRetorno = loPaqueteADN.TieneQueAplicarCambios( this.cNombrePaquete )
		this.AssertTrue( "Debería haber detectado cambios.", llRetorno )
		
		loPaqueteADN.release()
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestAplicarCambios
		Local loPaqueteADN as PaqueteADN of PaqueteADN.prg, llRetorno as boolean
										
		=CargarDatosBasicos( this.cNombrePaquete, .t., .t., .t., .t., .f., .f. )		

		loPaqueteADN = _screen.zoo.CrearObjeto( "PaqueteADN" )
		loPaqueteADN.oFunciones = CrearObjetoFuncion( this.cCurrentDir )

		loPaqueteADN.AplicarCambios( this.cNombrePaquete )
		lnCant = adir( arrFiles, addbs( loPaqueteADN.oFunciones.ObtenerRutaDestino() ) + "*.prg" )
		this.AssertEquals( "Debería haber copiado los archivos.", 3, lnCant )

		loPaqueteADN.release()
	endfunc 

	
	
	
	
	********************************************************************
	FUNCTION TearDown
		local lcCurrentDir as String
		
		lcCurrentDir = this.ccuRRENTDIR
		chdir &lcCurrentDir
		if ( directory( "Paquetes" ) )
			_screen.zoo.invocarmetodoestatico( "System.IO.Directory", "Delete", addbs(this.cCurrentDir ) + "Paquetes", .t. )
		endif
		if ( directory( "TerminatorGenerados" ) )
			_screen.zoo.invocarmetodoestatico( "System.IO.Directory", "Delete", addbs(this.cCurrentDir ) + "TerminatorGenerados", .t. )
		endif
	*
	*  put common cleanup code here -- this method is called
	*  whenever THIS.Run() (inherited method) to run each
	*  of the custom test methods you add, specific test
	*  methods that are not inherited from FoxUnit
	*
	*  do NOT call THIS.Assert..() methods here -- this is
	*  NOT a test method
	*
    *  for example, you can release  all the object(s)
    *  you will be testing by the custom test methods of 
    *  this class:
*!*	    THIS.ioObjectToBeTested = .NULL.
*!*		LOCAL lcSetClassLib
*!*		lcSetClassLib = THIS.icSetClassLib
*!*		SET CLASSLIB TO &lcSetClassLib        

	ENDFUNC

	*
	*  test methods can use any method name not already used by
	*  the parent FXUTestCase class
	*    MODIFY COMMAND FXUTestCase
	*  DO NOT override any test methods except for the abstract 
	*  test methods Setup() and TearDown(), as described above
	*
	*  the three important inherited methods that you call
	*  from your test methods are:
	*    THIS.AssertTrue("Failure message",<Expression>)
	*    THIS.AssertEquals("Failure message",<ExpectedValue>,<Expression>)
	*    THIS.AssertNotNull("Failure message",<Expression>)
	*  all test methods either pass or fail -- the assertions
	*  either succeed or fail
    
	*
	*  here's a simple AssertNotNull example test method
	*
*!*		*********************************************************************
*!*		FUNCTION TestObjectWasCreated
*!*
*!*			THIS.AssertNotNull("Object was not instantiated during Setup()", ;
*!*			               THIS.ioObjectToBeTested)
*!*		ENDFUNC

	*
	*  here's one for AssertTrue
	*
*!*		*********************************************************************
*!*		FUNCTION TestObjectCustomMethod 
*!*
*!*		THIS.AssertTrue("Object.CustomMethod() failed", ;
*!*			            THIS.ioObjectToBeTested.CustomMethod())
*!*
*!*		ENDFUNC
	*
	*  and one for AssertEquals
	*
*!*		*********************************************************************
*!*		FUNCTION TestObjectCustomMethod100ReturnValue 
*!*
*!*		* Please note that string Comparisons with AssertEquals are
*!*		* case sensitive. 
*!*
*!*		THIS.AssertEquals("Object.CustomMethod100() did not return 'John Smith'", ;
*!*		                "John Smith", ;
*!*			            THIS.ioObjectToBeTested.Object.CustomMethod100())
*!*		ENDFUNC
*!*		*********************************************************************


ENDDEFINE


*-------------------------------------------------------*
*-------------------------------------------------------*
define class FuncionesAux as Funciones of PaqueteAdn.prg

	cRutaIni = ""
	cRutaDes = ""

	*---------------------------------------------------*
	function ObtenerRutaInicial()
		return this.cRutaIni
	endfunc
	
	*---------------------------------------------------*
	function ObtenerRutaDestino()
		return this.cRutaDes
	endfunc

enddefine

*-----------------------------------------------------------------------------------------
function CargarDatosBasicos( tcNombrePaquete as string, tlDirPaquetes as Boolean, ;
							tlDirPaqueteADN as boolean, tlDirGenerados as Boolean, ;
							tlFilesPaquetes as Boolean, tlFilesGenerados as Boolean, ;
							tlModificarFileGenerado ) as Void
	Local lcCurrentDir as string, lcDirectorio as String, lcDirGenerados as string, ;
			lcFile1 as String, lcFile2 as String, lcFile3 as string, lcFile4 as string
									
	lcDirectorio = "Paquetes"
	lcDirGenerados = "TerminatorGenerados"
	lcDirPaquete = tcNombrePaquete
	lcFile1 = tcNombrePaquete + "1.prg"
	lcFile2 = tcNombrePaquete + "2.prg"
	lcFile3 = tcNombrePaquete + "3.prg"
	lcFile4 = tcNombrePaquete + "4.prg"
	lcCurrentDir = curdir()

	if tlDirGenerados
		if ( !directory( lcDirGenerados ) )
			md &lcDirGenerados
		endif
	else
		if ( directory( lcDirGenerados ) )
			_screen.zoo.invocarmetodoestatico( "System.IO.Directory", "Delete", addbs( lcCurrentDir ) + lcDirGenerados, .t. )
		endif
	endif

	if tlDirPaquetes	
		if ( !directory( lcDirectorio ) )
			md &lcDirectorio
		endif
		cd &lcDirectorio
		if tlDirPaqueteADN
			if ( !directory( lcDirPaquete ) )
				md &lcDirPaquete
			endif
			cd &lcDirPaquete
			if tlFilesPaquetes
				strtofile( "A", lcFile1, 1 )
				strtofile( "BB", lcFile2, 1 )
				strtofile( "CCC", lcFile3, 1 )
				if tlFilesGenerados
					cfile = addbs( lcCurrentDir ) + addbs( lcDirGenerados ) + lcFile1
					copy File &lcFile1 to &cfile
					cfile = addbs( lcCurrentDir ) + addbs( lcDirGenerados ) + lcFile2
					copy File &lcFile2 to &cfile
					cfile = addbs( lcCurrentDir ) + addbs( lcDirGenerados ) + lcFile3
					copy File &lcFile3 to &cfile
					if tlModificarFileGenerado
						strtofile( "TENDRIAQUEENCONTRARDIFERENCIADETAMANODEARCHIVO", cfile, 1 )
					Endif
					cfile = addbs( lcCurrentDir ) + addbs( lcDirGenerados ) + lcFile4
					strtofile( "DDDD", cfile, 1 )
				else
					lcFullDirGenerados = addbs( lcCurrentDir ) + lcDirGenerados
					chdir &lcFullDirGenerados
					try
						delete file &lcFile1
					catch
					endtry
					try
						delete file &lcFile2
					catch
					endtry
					try
						delete file &lcFile3
					catch
					endtry
				endif
			else
				try
					delete file &lcFile1
				catch
				endtry
				try
					delete file &lcFile2
				catch
				endtry
				try
					delete file &lcFile3
				catch
				endtry
			endif
		else
			if ( directory( lcDirPaquete ) )
				_screen.zoo.invocarmetodoestatico( "System.IO.Directory", "Delete", addbs( lcCurrentDir) + addbs( lcDirectorio ) + lcDirPaquete, .t. )
			endif
		endif
	else
		if ( directory( lcDirectorio ) )
			_screen.zoo.invocarmetodoestatico( "System.IO.Directory", "Delete", addbs( lcCurrentDir ) + lcDirectorio, .t. )
		endif
	endif		
		
	chdir &lcCurrentDir	
endfunc

*-----------------------------------------------------------------------------------------
function CrearObjetoFuncion( tcCurrentDir as String ) as Object
	local loFunciones as Object
	
	loFunciones = _screen.zoo.CrearObjeto( "FuncionesAux", "ztestPaqueteADN.Prg" )
	loFunciones.cRutaIni = tcCurrentDir
	loFunciones.cRutaDes = addbs( tcCurrentDir ) + "TerminatorGenerados"
	
	return loFunciones
endfunc