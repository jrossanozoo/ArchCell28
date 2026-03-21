Define Class zTestCompresor as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as zTestCompresor of zTestCompresor.prg
	#ENDIF
	
	*---------------------------------
	Function Setup

	EndFunc
	
	*---------------------------------
	Function TearDown

	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestComprimir
		local loCompresor as compresor of compresor.prg, lcArchivoZip as String, loColArchivos as Collection

		loCompresor = _screen.zoo.crearobjeto( "Compresor" )
		
		lcArchivoZip = _screen.zoo.obtenerrutatemporal() + "ArchivoZip.zip" 
		delete file &lcArchivoZip
		This.asserttrue( "Existe el archivo zip", !file( lcArchivoZip ) )

		loColArchivos = newobject( "Collection" )	
		loColArchivos.Add( _screen.zoo.cRutaInicial + "ClasesDePrueba\*.prg" )
		loCompresor.Comprimir( lcArchivoZip, loColArchivos )
		
		This.asserttrue( "No existe el archivo zip", file( lcArchivoZip ) )
		
		release loCompresor
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestComprimirConPassword
		local loCompresor as Compresor of Compresor.prg, lcArchivoZip as String, lcContenido as  String, lcArchivoAComprimir as String, loColArchivos as Collection, ;
			lcDestinoDeDescompresion as String, loError as Object
		
		loCompresor = _screen.Zoo.CrearObjeto( "Compresor" )

		lcContenido = sys( 2015 )
		lcArchivoAComprimir = _screen.Zoo.ObtenerRutaTemporal() + sys( 2015 ) + sys( 2015 ) + ".txt"
		lcArchivoZip = _screen.Zoo.ObtenerRutaTemporal() + sys( 2015 ) + ".zip"

		if file( lcArchivoAComprimir )
			delete file ( lcArchivoAComprimir )
		endif
	
		if file( lcArchivoZip )
			delete file ( lcArchivoZip )
		endif

		strtofile( lcContenido, lcArchivoAComprimir )
		loColArchivos = newobject( "Collection" )
		loColArchivos.Add( lcArchivoAComprimir )
		loCompresor.Comprimir( lcArchivoZip, loColArchivos, "4444", .f., .f. )
		
		lcDestinoDeDescompresion = _screen.Zoo.ObtenerRutaTemporal() + sys( 2015 )
		
		md ( lcDestinoDeDescompresion )
		
		try
			loCompresor.DesComprimir( lcArchivoZip, "1234", lcDestinoDeDescompresion )
		catch to loError
			this.AssertTrue( "Debió fallar por password incorrecto.", "The password did not match." $ loError.Message )
		endtry
		
		
		loCompresor.DesComprimir( lcArchivoZip, "4444", lcDestinoDeDescompresion )
		this.AssertEquals( "El archivo no se comprimió correctamente.", lcContenido, filetostr( addbs( lcDestinoDeDescompresion ) + justfname( lcArchivoAComprimir ) ) )
		
		release loCompresor
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestDesComprimir
		local loCompresor as compresor of compresor.prg, lcArchivoZip as String, loColArchivos as Collection

		lcRutaTemporal = _screen.zoo.obtenerrutatemporal()

		loCompresor = _screen.zoo.crearobjeto( "Compresor" )
		loCompresor.DesComprimir( _screen.zoo.cRutaInicial + "clasesdeprueba\Tr__Campo_Sobrante_Comun.zip", goServicios.Parametros.Nucleo.Transferencias.PassWord, lcRutaTemporal )

		This.asserttrue( "No descomprimio archivo.", file( lcRutaTemporal + "Archivo1.xml" ) )
		
		release loCompresor
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestDesComprimirPassWordIncorrecta
		local loCompresor as compresor of compresor.prg, lcArchivoZip as String, loColArchivos as Collection

		lcRutaTemporal = _screen.zoo.obtenerrutatemporal()

		loCompresor = _screen.zoo.crearobjeto( "Compresor" )
		try
			loCompresor.DesComprimir( _screen.zoo.cRutaInicial + "clasesdeprueba\Tr__Campo_Sobrante_Comun.zip", sys( 2015 ), lcRutaTemporal )
			This.asserttrue( "No dio error por contraseña incorrecta.", .f. )
		catch to loError
			This.asserttrue( "Error incorrecto.", "The password did not match." $ loError.Message )
		endtry
		
		release loCompresor
	endfunc 

	
	*-----------------------------------------------------------------------------------------
	function zTestComprimirDosTiposDeArchivos
		local loCompresor as compresor of compresor.prg, lcArchivoZip as String, loColArchivos as Collection

		loCompresor = _screen.zoo.crearobjeto( "Compresor" )
		
		lcArchivoZip = _screen.zoo.obtenerrutatemporal() + "ArchivoZip.zip" 
		delete file &lcArchivoZip
		This.asserttrue( "Existe el archivo zip", !file( lcArchivoZip ) )

		loColArchivos = newobject( "Collection" )	
		loColArchivos.Add( _screen.zoo.cRutaInicial + "ClasesDePrueba\*.prg" )
		loColArchivos.Add( _screen.zoo.cRutaInicial + "ClasesDePrueba\*.xml" )		
		loCompresor.Comprimir( lcArchivoZip, loColArchivos )
		
		This.asserttrue( "No existe el archivo zip", file( lcArchivoZip ) )
		
		release loCompresor

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestComprimirArchivoConEspaciosEnElNombre
		local loCompresor as compresor of compresor.prg, lcArchivoZip as String, loColArchivos as Collection

		loCompresor = _screen.zoo.crearobjeto( "Compresor" )
		
		lcArchivoZip = _screen.zoo.obtenerrutatemporal() + "ArchivoZip.zip" 
		delete file &lcArchivoZip
		This.asserttrue( "Existe el archivo zip", !file( lcArchivoZip ) )

		loColArchivos = newobject( "Collection" )	
		loColArchivos.Add( _screen.zoo.cRutaInicial + "ClasesDePrueba\Archivo con espacios.prg" )
		loCompresor.Comprimir( lcArchivoZip, loColArchivos )
		
		This.asserttrue( "No existe el archivo zip", file( lcArchivoZip ) )
		
		release loCompresor
	endfunc 	

EndDefine
