**********************************************************************
Define Class ztestGarbageCollector as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as ztestGarbageCollector of ztestGarbageCollector.prg
	#ENDIF
		
	*-----------------------------------------------------------------------------------------
	Function zTestU_GarbageCollectorDBF
		local loCol as zoocoleccion OF zoocoleccion.prg, loObj as Object, lcDir as string, ;
				lnCant as Integer
		
	*Arrange (Preparar)
		lcDir = "TERMIFOLDER"
		=ArmarEscenario( lcDir )
		loObj = newobject( "GarbageCollector_Aux" )
		
	*Act (Actuar)
		loObj.GarbageCollectorSegunExtension_Aux( lcDir, "dbf" )
		lnCant = adir( laDir, addbs( lcDir ) + "*.dbf" )

	*Assert (Afirmar)
		this.AssertEquals( "No eliminó la cantidad correcta de archivos basura.", 3, lnCant )
		this.AssertEquals( "No mantuvo el archivo correcto(1).", "TABLAVALIDA1.DBF", upper( laDir( 1, 1 ) ) )
		this.AssertEquals( "No mantuvo el archivo correcto(2).", "TABLAVALIDA2.DBF", upper( laDir( 2, 1 ) ) )
		this.AssertEquals( "No mantuvo el archivo correcto(3).", "_INVALIDAMISMAFECHA.DBF", upper( laDir( 3, 1 ) ) )

		loObj = null
		=DesarmarEscenario( lcDir )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function zTestU_GarbageCollectorCDX
		local loCol as zoocoleccion OF zoocoleccion.prg, loObj as Object, lcDir as string, ;
				lnCant as Integer
		
	*Arrange (Preparar)
		lcDir = "TERMIFOLDER"
		=ArmarEscenario( lcDir )
		loObj = newobject( "GarbageCollector_Aux" )
		
	*Act (Actuar)
		loObj.GarbageCollectorSegunExtension_Aux( lcDir, "cdx" )
		lnCant = adir( laDir, addbs( lcDir ) + "*.cdx" )

	*Assert (Afirmar)
		this.AssertEquals( "No eliminó la cantidad correcta de archivos basura.", 3, lnCant )
		this.AssertEquals( "No mantuvo el archivo correcto(1).", "TABLAVALIDA1.CDX", upper( laDir( 1, 1 ) ) )
		this.AssertEquals( "No mantuvo el archivo correcto(2).", "TABLAVALIDA2.CDX", upper( laDir( 2, 1 ) ) )
		this.AssertEquals( "No mantuvo el archivo correcto(3).", "_INVALIDAMISMAFECHA.CDX", upper( laDir( 3, 1 ) ) )

		loObj = null
		=DesarmarEscenario( lcDir )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function zTestU_ObtenerColeccionGarbageDBF
		local loCol as zoocoleccion OF zoocoleccion.prg, loObj as Object, lcDir as string
		
	*Arrange (Preparar)
		lcDir = "TERMIFOLDER"
		=ArmarEscenario( lcDir )
		loObj = newobject( "GarbageCollector_Aux" )
		
	*Act (Actuar)
		loCol = loObj.ObtenerColeccionGarbage_Aux( lcDir, "dbf" )

	*Assert (Afirmar)
		this.AssertEquals( "No trajo la cantidad correcta de archivos basura.", 3, loCol.Count )
		this.AssertEquals( "No trajo el archivo correcto(1).", "_TABLAINVALIDA1.DBF", loCol(1) )
		this.AssertEquals( "No trajo el archivo correcto(2).", "_TABLAINVALIDA2.DBF", loCol(2) )
		this.AssertEquals( "No trajo el archivo correcto(3).", "_TABLAINVALIDA3.DBF", loCol(3) )

		loObj = null
		=DesarmarEscenario( lcDir )
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestU_ObtenerColeccionGarbageCDX
		local loCol as zoocoleccion OF zoocoleccion.prg, loObj as Object, lcDir as string
		
	*Arrange (Preparar)
		lcDir = "TERMIFOLDER"

		=ArmarEscenario( lcDir )
		loObj = newobject( "GarbageCollector_Aux" )
		
	*Act (Actuar)
		loCol = loObj.ObtenerColeccionGarbage_Aux( lcDir, "cdx" )

	*Assert (Afirmar)
		this.AssertEquals( "No trajo la cantidad correcta de archivos basura.", 3, loCol.Count )
		this.AssertEquals( "No trajo el archivo correcto(1).", "_TABLAINVALIDA1.CDX", loCol(1) )
		this.AssertEquals( "No trajo el archivo correcto(2).", "_TABLAINVALIDA2.CDX", loCol(2) )
		this.AssertEquals( "No trajo el archivo correcto(3).", "_TABLAINVALIDA3.CDX", loCol(3) )

		loObj = null
		=DesarmarEscenario( lcDir )
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	Function zTestU_GarbageCollectorSegunExtension
		local loCol as zoocoleccion OF zoocoleccion.prg, loObj as Object, lcDir as string, ;
				lnCant as Integer
		
	*Arrange (Preparar)
		lcDir = "TERMIFOLDER"

		=ArmarEscenarioConArchivosSZ( lcDir )
		loObj = newobject( "GarbageCollector_Aux" )
		
	*Act (Actuar)

		loObj.GarbageCollectorSegunExtension( lcDir, "sz" )
		lnCant = adir( laDir, addbs( lcDir ) + "*.sz" )

	*Assert (Afirmar)
		this.AssertEquals( "No eliminó la cantidad correcta de archivos basura.", 3, lnCant )
		this.AssertEquals( "No mantuvo el archivo correcto(1).", "1.SZ", upper( laDir( 1, 1 ) ) )
		this.AssertEquals( "No mantuvo el archivo correcto(2).", "2.SZ", upper( laDir( 2, 1 ) ) )
		this.AssertEquals( "No mantuvo el archivo correcto(3).", "3.SZ", upper( laDir( 3, 1 ) ) )

		loObj = null
		=DesarmarEscenario( lcDir )
	endfunc 
	
EndDefine

*-----------------------------------------------------------------------------------------
define class GarbageCollector_Aux as GarbageCollector of GarbageCollector.prg

	*-----------------------------------------------------------------------------------------
	function ObtenerColeccionGarbage_Aux( tcPath as String, tcExtension as String ) as zoocoleccion OF zoocoleccion.prg
		return this.ObtenerColeccionGarbage( tcPath, tcExtension )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function GarbageCollectorSegunExtension_Aux( tcPath as String, tcExtension as String ) as Void
		this.GarbageCollectorSegunExtension( tcPath, tcExtension )
	endfunc 


enddefine

*-----------------------------------------------------------------------------------------
function ArmarEscenario( tcDir as String ) as Void
	local lcDir as String, lcFile as string, loManejador as Object
	
	if !directory( tcDir )
		md( tcDir )
	endif
	cd &tcDir
	=CrearDBF( "tablaValida1" )
	=CrearDBF( "tablaValida2" )
	=CrearDBF( "_tablaInvalida1" )
	=CrearDBF( "_tablaInvalida2" )
	=CrearDBF( "_tablaInvalida3" )
	=CrearDBF( "_InvalidaMismaFecha" )
	loManejador = _screen.zoo.app.crearobjeto( "ManejoArchivos", "ManejoArchivos.prg" )
	=loManejador.WinSetFileTime( "_tablaInvalida1.dbf", "c" , 2002, 01, 01, 18, 59, 59, 300 )
	=loManejador.WinSetFileTime( "_tablaInvalida1.dbf", "w" , 2002, 01, 01, 18, 59, 59, 300 )
	=loManejador.WinSetFileTime( "_tablaInvalida2.dbf", "c" , 2002, 01, 01, 18, 59, 59, 300 )
	=loManejador.WinSetFileTime( "_tablaInvalida2.dbf", "w" , 2002, 01, 01, 18, 59, 59, 300 )
	=loManejador.WinSetFileTime( "_tablaInvalida3.dbf", "c" , 2002, 01, 01, 18, 59, 59, 300 )
	=loManejador.WinSetFileTime( "_tablaInvalida3.dbf", "w" , 2002, 01, 01, 18, 59, 59, 300 )
	=loManejador.WinSetFileTime( "_tablaInvalida1.cdx", "c" , 2002, 01, 01, 18, 59, 59, 300 )
	=loManejador.WinSetFileTime( "_tablaInvalida1.cdx", "w" , 2002, 01, 01, 18, 59, 59, 300 )
	=loManejador.WinSetFileTime( "_tablaInvalida2.cdx", "c" , 2002, 01, 01, 18, 59, 59, 300 )
	=loManejador.WinSetFileTime( "_tablaInvalida2.cdx", "w" , 2002, 01, 01, 18, 59, 59, 300 )
	=loManejador.WinSetFileTime( "_tablaInvalida3.cdx", "c" , 2002, 01, 01, 18, 59, 59, 300 )
	=loManejador.WinSetFileTime( "_tablaInvalida3.cdx", "w" , 2002, 01, 01, 18, 59, 59, 300 )
	loManejador = null
	cd..
endfunc 

*-----------------------------------------------------------------------------------------
function ArmarEscenarioConArchivosSZ( tcDir as String ) as Void
	local lcDir as String, lcFile as string, loManejador as Object
	
	if !directory( tcDir )
		md( tcDir )
	endif
	cd &tcDir
	strtofile( "1", sys(5) + addbs( curdir() ) + "1.sz" )
	strtofile( "2", sys(5) + addbs( curdir() ) + "2.sz" )
	strtofile( "3", sys(5) + addbs( curdir() ) + "3.sz" )
	
	loManejador = _screen.zoo.app.crearobjeto( "ManejoArchivos", "ManejoArchivos.prg" )
	=loManejador.WinSetFileTime( "1.dbf", "c" , 2002, 01, 01, 18, 59, 59, 300 )
	=loManejador.WinSetFileTime( "1.dbf", "w" , 2002, 01, 01, 18, 59, 59, 300 )
	=loManejador.WinSetFileTime( "2.dbf", "c" , 2002, 01, 01, 18, 59, 59, 300 )
	=loManejador.WinSetFileTime( "2.dbf", "w" , 2002, 01, 01, 18, 59, 59, 300 )
	=loManejador.WinSetFileTime( "3.dbf", "c" , 2002, 01, 01, 18, 59, 59, 300 )
	=loManejador.WinSetFileTime( "3.dbf", "w" , 2002, 01, 01, 18, 59, 59, 300 )
	loManejador = null
	cd..
endfunc 

*-----------------------------------------------------------------------------------------
function CrearDBF( tcNombre as String ) as Void
	create table &tcNombre ( campo C( 10 ) )
	index on campo tag campo
	use in &tcNombre
endfunc 

*-----------------------------------------------------------------------------------------
function DesarmarEscenario( tcDir as String ) as Void
	local lcDir as String, lcFile as string
	
	if directory( tcDir )
		cd &tcDir
		delete file "tablaValida1.cdx"
		delete file "tablaValida2.cdx"
		delete file "_tablaInvalida1.cdx"
		delete file "_tablaInvalida2.cdx"
		delete file "_tablaInvalida3.cdx"
		delete file "_InvalidaMismaFecha.cdx"
		delete file "tablaValida1.dbf"
		delete file "tablaValida2.dbf"
		delete file "_tablaInvalida1.dbf"
		delete file "_tablaInvalida2.dbf"
		delete file "_tablaInvalida3.dbf"
		delete file "_InvalidaMismaFecha.dbf"
		delete file "1.sz"
		delete file "2.sz"
		delete file "3.sz"
		cd..
		rd( tcDir )
	endif
endfunc 
