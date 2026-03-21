**********************************************************************
Define Class zTestManejoArchivos as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as zTestManejoArchivos of zTestManejoArchivos.prg
	#ENDIF
	cSafety = ""
	*---------------------------------
	Function Setup
		this.cSafety = set("Safety")
		set safety off
	EndFunc
	
	*-----------------------------------
	function zTestNativaInstanciaManejoArchivos
	
		local loManejoArchivos as Object
			
		loManejoArchivos = newobject("ManejoArchivos","ManejoArchivos.prg")	
		this.asserttrue("No se ha instanciado correctamente la clase ManejoArchivos",vartype(loManejoArchivos) = "O")	
        
        loManejoArchivos.destroy()
        loManejoArchivos = Null
	
	endfunc
	*---------------------------------
	function zTestNativaCambiarAtributosArchivo
	
		local loManejoArchivos as Object, lcTextoArchivo as String, llCambioAtributo as Boolean, ;
			lcAtributo as String, lcDirectorio as String, lcRuta as String
    
        lcRuta = addbs( _Screen.zoo.Obtenerrutatemporal() ) + sys(2015) + "\"
        try
            md &lcRuta
        catch
        Endtry
			
		loManejoArchivos = newobject("ManejoArchivos","ManejoArchivos.prg")		
		this.asserttrue("No se ha instanciado correctamente la clase ManejoArchivos",vartype(loManejoArchivos) = "O")	
				
		lcTextoArchivo = ""
		strtofile( lcTextoArchivo, lcRuta + "Textoprueba.txt" )	
		
		llCambioAtributo = loManejoArchivos.SetearAtributos("R", lcRuta + "TextoPrueba.txt","")
		this.asserttrue( "No se ha podido cambiar el atributo del archivo",llCambioAtributo)

		lcAtributo = loManejoArchivos.LeerAtributo( lcRuta + "TextoPrueba.txt")	
		this.asserttrue("El archivo no tiene el atributo correspondiente",lcAtributo = "R")
		llCambioAtributo = loManejoArchivos.SetearAtributos("H", lcRuta + "TextoPrueba.txt","")
		this.asserttrue("No se ha podido cambiar el atributo del archivo",llCambioAtributo)
		lcAtributo = loManejoArchivos.LeerAtributo( lcRuta + "TextoPrueba.txt")	
		this.asserttrue("El archivo no tiene el atributo correspondiente",lcAtributo = "H")

		llCambioAtributo = loManejoArchivos.SetearAtributos("S", lcRuta + "TextoPrueba.txt","")
		this.asserttrue("No se ha podido cambiar el atributo del archivo",llCambioAtributo)
		lcAtributo = loManejoArchivos.LeerAtributo( lcRuta + "TextoPrueba.txt")	
		this.asserttrue("El archivo no tiene el atributo correspondiente",lcAtributo = "S")

		llCambioAtributo = loManejoArchivos.SetearAtributos("A", lcRuta + "TextoPrueba.txt","")
		this.asserttrue("No se ha podido cambiar el atributo del archivo",llCambioAtributo)
		lcAtributo = loManejoArchivos.LeerAtributo( lcRuta + "TextoPrueba.txt")	
		this.asserttrue("El archivo no tiene el atributo correspondiente",lcAtributo = "A")

		llCambioAtributo = loManejoArchivos.SetearAtributos("N", lcRuta + "TextoPrueba.txt","")
		this.asserttrue("No se ha podido cambiar el atributo del archivo",llCambioAtributo)
		lcAtributo = loManejoArchivos.LeerAtributo( lcRuta + "TextoPrueba.txt")	
		this.asserttrue("El archivo no tiene el atributo correspondiente",lcAtributo = "N")
		delete file "TextoPrueba.txt"
		
		lcDirectorio = addbs( _Screen.zoo.Obtenerrutatemporal() ) + sys(2015)
		md (lcDirectorio)

		llCambioAtributo = loManejoArchivos.SetearAtributos("D", lcDirectorio ,"")
		this.asserttrue("No se ha podido cambiar el atributo del archivo",llCambioAtributo)
		lcAtributo = loManejoArchivos.LeerAtributo( lcDirectorio )	
		this.asserttrue("El archivo no tiene el atributo correspondiente",lcAtributo = "D")
		
		rd (lcDirectorio)
        
        loManejoArchivos.destroy()
        loManejoArchivos = Null

	endfunc
	*---------------------------------	
	function zTestNativaLeerAtributo

		local loManejoArchivos as Object, lcTextoArchivo as String, lcAtributo as String, lcRuta as String
    
        lcRuta = addbs( _Screen.zoo.Obtenerrutatemporal() ) + sys(2015) + "\"
        try
            md &lcRuta
        catch
        Endtry
			
		loManejoArchivos = newobject("ManejoArchivos","ManejoArchivos.prg")		
		this.asserttrue("No se ha instanciado correctamente la clase ManejoArchivos",vartype(loManejoArchivos) = "O")	
				
		lcTextoArchivo = ""
		strtofile( lcTextoArchivo, lcRuta + "Textoprueba.txt" )		
		lcAtributo = loManejoArchivos.LeerAtributo(lcRuta + "TextoPrueba.txt")		
		this.asserttrue("El archivo no tiene el atributo correspondiente",lcAtributo = "A")
	
        loManejoArchivos.destroy()
        loManejoArchivos = Null
	endfunc 
	
	*---------------------------------	
	function zTestNativaCambiarAtributosMultiplesArchivos
	
		local loManejoArchivos as Object, lcTextoArchivo as String, llCambioAtributo as Boolean, ;
			lcAtributo as String, lcRuta as String
    
        lcRuta = addbs( _Screen.zoo.Obtenerrutatemporal() ) + sys(2015) + "\"
        try
            md &lcRuta
        catch
        Endtry
	
		loManejoArchivos = newobject("ManejoArchivos","ManejoArchivos.prg")		
		this.asserttrue("No se ha instanciado correctamente la clase ManejoArchivos",vartype(loManejoArchivos) = "O")	

		lcTextoArchivo = ""
		strtofile( lcTextoArchivo, lcRuta + "Textoprueba.txt" )	
		strtofile( lcTextoArchivo, lcRuta + "Textoprueba.bak" )				
		strtofile( lcTextoArchivo, lcRuta + "Textoprueba.pif" )		

		llCambioAtributo = loManejoArchivos.SetearAtributos("R", lcRuta + "textoPrueba.txt","txt,bak,pif")		
		lcAtributo = loManejoArchivos.LeerAtributo(lcRuta + "TextoPrueba.txt" )		
		this.asserttrue( "El archivo no tiene el atributo correspondiente 1",lcAtributo = "R")

		lcAtributo = loManejoArchivos.LeerAtributo(lcRuta + "TextoPrueba.bak" )		
		this.asserttrue( "El archivo no tiene el atributo correspondiente 2",lcAtributo = "R")

		lcAtributo = loManejoArchivos.LeerAtributo(lcRuta + "TextoPrueba.pif" )		
		this.asserttrue( "El archivo no tiene el atributo correspondiente 3",lcAtributo = "R")

		llCambioAtributo = loManejoArchivos.SetearAtributos("A", lcRuta + "textoPrueba","txt,bak,pif")		
		lcAtributo = loManejoArchivos.LeerAtributo(lcRuta + "TextoPrueba.txt" )		
		this.asserttrue( "El archivo no tiene el atributo correspondiente 4",lcAtributo = "A")

		lcAtributo = loManejoArchivos.LeerAtributo(lcRuta + "TextoPrueba.bak" )		
		this.asserttrue( "El archivo no tiene el atributo correspondiente 5",lcAtributo = "A")

		lcAtributo = loManejoArchivos.LeerAtributo(lcRuta + "TextoPrueba.pif" )		
		this.asserttrue( "El archivo no tiene el atributo correspondiente 6",lcAtributo = "A" )
		
		delete file lcRuta + "textoprueba.txt"
		delete file lcRuta + "textoprueba.bak"
		delete file lcRuta + "textoprueba.pif"		
	
	    loManejoArchivos.destroy()
        loManejoArchivos = Null
	endfunc
	*---------------------------------		
	function zTestNativaCambiarAtributosConAsteriscos
	
		local loManejoArchivos as Object, lcTextoArchivo as String, llCambioAtributo as Boolean, ;
			lcAtributo as String, lcRuta as String
	
		lcRuta = addbs( _Screen.zoo.Obtenerrutatemporal() ) + sys(2015) + "\"
		try
			md &lcRuta
		catch
		Endtry

		loManejoArchivos = newobject("ManejoArchivos","ManejoArchivos.prg")		
		this.asserttrue("No se ha instanciado correctamente la clase ManejoArchivos",vartype(loManejoArchivos) = "O")	

		lcTextoArchivo = ""
		strtofile(lcTextoArchivo, lcRuta + "Textoprueba.txt" )	
		strtofile(lcTextoArchivo, lcRuta + "Textoprueba.bak" )				
		strtofile(lcTextoArchivo, lcRuta + "Textoprueba.pif" ) 
		llCambioAtributo = loManejoArchivos.SetearAtributos("R", lcRuta + "*.*")		
		lcAtributo = loManejoArchivos.LeerAtributo(lcRuta + "TextoPrueba.txt")		
		this.asserttrue("El archivo no tiene el atributo correspondiente",lcAtributo = "R")
		lcAtributo = loManejoArchivos.LeerAtributo(lcRuta + "TextoPrueba.bak")		
		this.asserttrue("El archivo no tiene el atributo correspondiente",lcAtributo = "R")
		lcAtributo = loManejoArchivos.LeerAtributo(lcRuta + "TextoPrueba.pif")		
		this.asserttrue("El archivo no tiene el atributo correspondiente",lcAtributo = "R")
		llCambioAtributo = loManejoArchivos.SetearAtributos("A", lcRuta + "*.*")		
		lcAtributo = loManejoArchivos.LeerAtributo(lcRuta + "TextoPrueba.txt")		
		this.asserttrue("El archivo no tiene el atributo correspondiente",lcAtributo = "A")
		lcAtributo = loManejoArchivos.LeerAtributo(lcRuta + "TextoPrueba.bak")		
		this.asserttrue("El archivo no tiene el atributo correspondiente",lcAtributo = "A")
		lcAtributo = loManejoArchivos.LeerAtributo( lcRuta + "TextoPrueba.pif")		
		this.asserttrue("El archivo no tiene el atributo correspondiente",lcAtributo = "A")
		
		delete file ( lcRuta + "textoprueba.txt" )
		delete file ( lcRuta + "textoprueba.bak" )
		delete file ( lcRuta + "textoprueba.pif" )	
	
	     loManejoArchivos.destroy()
        loManejoArchivos = Null
	endfunc
	
	*---------------------------------			
	function zTestNativaMandarleFruta

		local loManejoArchivos as Object, lcTextoArchivo as String, llCambioAtributo as Boolean, ;
			lcAtributo as String, lcRuta as String
    
        lcRuta = addbs( _Screen.zoo.Obtenerrutatemporal() ) + sys(2015) + "\"
        try
            md &lcRuta
        catch
        Endtry
	
		loManejoArchivos = newobject("ManejoArchivos","ManejoArchivos.prg")		
		this.asserttrue("No se ha instanciado correctamente la clase ManejoArchivos",vartype(loManejoArchivos) = "O")	


		lcTextoArchivo = ""
		strtofile( lcTextoArchivo, lcRuta + "Textoprueba.txt" )	
		strtofile( lcTextoArchivo, lcRuta + "Textoprueba.bak" )				
		strtofile( lcTextoArchivo, lcRuta + "Textoprueba.pif" )		
			
		llCambioAtributo = loManejoArchivos.SetearAtributos("R", lcRuta + "textoPrueba","txt,bak,pif")		
		lcAtributo = loManejoArchivos.LeerAtributo(lcRuta + "TextoPrueba.txt")		
		this.asserttrue("El archivo no tiene el atributo correspondiente",lcAtributo = "R")
		lcAtributo = loManejoArchivos.LeerAtributo(lcRuta + "TextoPrueba.bak")		
		this.asserttrue("El archivo no tiene el atributo correspondiente",lcAtributo = "R")
		lcAtributo = loManejoArchivos.LeerAtributo(lcRuta + "TextoPrueba.pif")		
		this.asserttrue("El archivo no tiene el atributo correspondiente",lcAtributo = "R")
		llCambioAtributo = loManejoArchivos.SetearAtributos("A", lcRuta + "textoPrueba","txt,bak,pif")		
		lcAtributo = loManejoArchivos.LeerAtributo(lcRuta + "TextoPrueba.txt")		
		this.asserttrue("El archivo no tiene el atributo correspondiente",lcAtributo = "A")
		lcAtributo = loManejoArchivos.LeerAtributo(lcRuta + "TextoPrueba.bak")		
		this.asserttrue("El archivo no tiene el atributo correspondiente",lcAtributo = "A")
		lcAtributo = loManejoArchivos.LeerAtributo(lcRuta + "TextoPrueba.pif")		
		this.asserttrue("El archivo no tiene el atributo correspondiente",lcAtributo = "A")

		llCambioAtributo = loManejoArchivos.SetearAtributos("R", lcRuta + "textoPrueba.dbf","txt,bak,pif")		
		lcAtributo = loManejoArchivos.LeerAtributo(lcRuta + "TextoPrueba.txt")		
		this.asserttrue("El archivo no tiene el atributo correspondiente",lcAtributo = "R")
		lcAtributo = loManejoArchivos.LeerAtributo(lcRuta + "TextoPrueba.bak")		
		this.asserttrue("El archivo no tiene el atributo correspondiente",lcAtributo = "R")
		lcAtributo = loManejoArchivos.LeerAtributo(lcRuta + "TextoPrueba.pif")		
		this.asserttrue("El archivo no tiene el atributo correspondiente",lcAtributo = "R")
		llCambioAtributo = loManejoArchivos.SetearAtributos("A", lcRuta + "textoPrueba.dbf","txt,bak,pif")		
		lcAtributo = loManejoArchivos.LeerAtributo(lcRuta + "TextoPrueba.txt")		
		this.asserttrue("El archivo no tiene el atributo correspondiente",lcAtributo = "A")
		lcAtributo = loManejoArchivos.LeerAtributo(lcRuta + "TextoPrueba.bak")		
		this.asserttrue("El archivo no tiene el atributo correspondiente",lcAtributo = "A")
		lcAtributo = loManejoArchivos.LeerAtributo(lcRuta + "TextoPrueba.pif")		
		this.asserttrue("El archivo no tiene el atributo correspondiente",lcAtributo = "A")

		delete file lcRuta + "textoprueba.txt"
		delete file lcRuta + "textoprueba.bak"
		delete file lcRuta + "textoprueba.pif"		
        
        loManejoArchivos.destroy()
        loManejoArchivos = Null
	
	endfunc
	
	*---------------------------------		
	function zTestNativaBorrarCarpeta
	
		local lcRutaTemporal as String, loManejoArchivos as Object , lcCarpeta as String, lcSubcarpeta as String 
		
		lcCarpeta = sys( 2015 )
		
		loManejoArchivos = newobject("ManejoArchivos","ManejoArchivos.prg")				
		lcRutaTemporal = addbs( sys(2023) ) 
		lcSubcarpeta =  sys( 2015 )
		
		md ( lcRutaTemporal + lcCarpeta )
		md ( lcRutaTemporal + addbs( lcCarpeta ) + lcSubcarpeta  )

		strtofile( 'hfksjhjafhjkfhjsks', lcRutaTemporal + addbs( lcCarpeta ) + "pepe.txt" )
		strtofile( 'hfksjhjafhjkfhjsks', lcRutaTemporal + addbs( lcCarpeta ) + addbs( lcSubcarpeta ) + "pepedentrodecarpetaloca.txt" )
		
		this.asserttrue( 'No se creo el archivo Temporal "pepe.txt"', file( lcRutaTemporal + addbs( lcCarpeta ) + "pepe.txt" ) )
		this.asserttrue( 'No se creo el archivo Temporal "pepedentrodecarpetaloca.txt"', ;
						file( lcRutaTemporal + addbs( lcCarpeta ) + addbs( lcSubcarpeta ) + "pepedentrodecarpetaloca.txt"  ) )		
		this.asserttrue( "No existe la carpeta temporal", !directory( lcRutaTemporal + "SubCarpetaloca\pepedentrodecarpetaloca.txt" ) )
	
		loManejoArchivos.BorrarCarpeta( lcRutaTemporal + lcCarpeta )
	
		this.asserttrue( "No Se Pudo eliminar la carpeta 2", !Directory( lcRutaTemporal + lcCarpeta ) )
	

		*- Ahora no va a poder Borrarlo 
		md ( lcRutaTemporal + lcCarpeta )
		md ( lcRutaTemporal + addbs( lcCarpeta ) + lcSubcarpeta  )

		strtofile( 'hfksjhjafhjkfhjsks', lcRutaTemporal + addbs( lcCarpeta ) + "pepe.txt" )
		strtofile( 'hfksjhjafhjkfhjsks', lcRutaTemporal + addbs( lcCarpeta ) + addbs( lcSubcarpeta ) + "pepedentrodecarpetaloca.txt" )
		
		this.asserttrue( 'No se creo el archivo Temporal "pepe.txt"', file( lcRutaTemporal + addbs( lcCarpeta ) + "pepe.txt" ) )
		this.asserttrue( 'No se creo el archivo Temporal "pepedentrodecarpetaloca.txt"', ;
						file( lcRutaTemporal + addbs( lcCarpeta ) + addbs( lcSubcarpeta ) + "pepedentrodecarpetaloca.txt"  ) )		
		this.asserttrue( "No existe la carpeta temporal", !directory( lcRutaTemporal + "SubCarpetaloca\pepedentrodecarpetaloca.txt" ) )
		create table ( lcRutaTemporal + addbs( lcCarpeta ) + addbs( lcSubcarpeta ) + "Tabla" ) free ( cod N(1) )
		loManejoArchivos.BorrarCarpeta( lcRutaTemporal + lcCarpeta )
		this.asserttrue( "Se Pudo eliminar la carpeta", Directory( lcRutaTemporal + lcCarpeta ) )
	
		use in select( "tabla" )
		loManejoArchivos.BorrarCarpeta( lcRutaTemporal + lcCarpeta )
		this.asserttrue( "No Se Pudo eliminar la carpeta 3", !Directory( lcRutaTemporal + lcCarpeta ) )
				
		loManejoArchivos.destroy()
		loManejoArchivos = Null
	
	endfunc	
	
	*---------------------------------		
	function zTestNativaBorrarArchivo
	
		local lcRutaTemporal as String, loManejoArchivos as Object , lcCarpeta as String, lcSubcarpeta as String 
		
		lcArchivo = sys( 2015 )
		
		loManejoArchivos = newobject("ManejoArchivos","ManejoArchivos.prg")				
		lcArchivoTemporal = addbs( _Screen.zoo.Obtenerrutatemporal() ) + addbs( sys(2015) ) 
        try
            md &lcArchivoTemporal 
        catch
        Endtry

        lcArchivoTemporal = lcArchivoTemporal + "pepe.txt"
		
		strtofile( 'hfksjhjafhjkfhjsks', lcArchivoTemporal )
		
		this.asserttrue( 'No se creo el archivo Temporal "pepe.txt"', file( lcArchivoTemporal ) )
	
		llRetorno = loManejoArchivos.BorrarArchivo( lcArchivoTemporal )
	
		this.asserttrue( "No se pudo borrar el archivo", !file( lcArchivoTemporal ) )
				
		loManejoArchivos.destroy()
		loManejoArchivos = Null
	
	endfunc	
	
	*---------------------------------
	function zTestNativaMoverArchivo
	
		local lcArchivoOrigen as String, lcArchivoDestino as String, loManejoArchivos as ManejoArchivos of ManejoArchivos.prg

		loManejoArchivos = _screen.zoo.crearobjeto( "ManejoArchivos" )
		lcArchivoOrigen = _screen.zoo.obtenerrutatemporal() + "Test\Archivo.txt"
		lcArchivoDestino = _screen.zoo.obtenerrutatemporal() + "Test2\Archivo2.txt"
	
		loManejoArchivos.BorrarCarpeta( justpath( lcArchivoOrigen ) )
		loManejoArchivos.BorrarCarpeta( justpath( lcArchivoDestino ) )
	
		md ( justpath( lcArchivoOrigen ) )
		md ( justpath( lcArchivoDestino ) )
		strtofile( "Ok.", lcArchivoOrigen, 0 )
		
		loManejoArchivos.MoverArchivo( lcArchivoOrigen, lcArchivoDestino, .f. )
		This.AssertEquals( "No movió el archivo correctamente.", "Ok.", filetostr( lcArchivoDestino ) )
		strtofile( "Ok 2.", lcArchivoOrigen, 0 )
		
		loManejoArchivos.MoverArchivo( lcArchivoOrigen, lcArchivoDestino, .t. )
		This.AssertEquals( "No movió el archivo correctamente.", "Ok 2.", filetostr( lcArchivoDestino ) )
		
		loManejoArchivos.BorrarCarpeta( justpath( lcArchivoOrigen ) )
		loManejoArchivos.BorrarCarpeta( justpath( lcArchivoDestino ) )

        loManejoArchivos.destroy()
        loManejoArchivos = Null
	endfunc	
	
	*---------------------------------
	function zTestNativaSetearAtributoConArchivoErroneo
		local loManejoArchivos as Object, lcTextoArchivo as String, llCambioAtributo as Boolean, ;
			lcAtributo as String, lcRuta as String
    
        lcRuta = addbs( _Screen.zoo.Obtenerrutatemporal() ) + sys(2015) + "\"
        try
            md &lcRuta
        catch
        Endtry
	
		loManejoArchivos = newobject("ManejoArchivos","ManejoArchivos.prg")		
		this.asserttrue("No se ha instanciado correctamente la clase ManejoArchivos",vartype(loManejoArchivos) = "O")	

		lcTextoArchivo = ""
		strtofile( lcTextoArchivo, lcRuta + "Textoprueba.txt" )	
		strtofile( lcTextoArchivo, lcRuta + "Textoprueba.bak" )				
		strtofile( lcTextoArchivo, lcRuta + "Textoprueba.pif" )		

		llCambioAtributo = loManejoArchivos.SetearAtributos("R", lcRuta + "textoPrueba2.txt")		
		this.asserttrue("Deberia devolver falso 1",!llCambioAtributo )

		llCambioAtributo = loManejoArchivos.SetearAtributos("R", ":prueba\*")		
		this.asserttrue("Deberia devolver falso 2",!llCambioAtributo )

		llCambioAtributo = loManejoArchivos.SetearAtributos("R", sys(5) + curdir())		
		this.asserttrue("Deberia devolver true 1",llCambioAtributo )
				
		delete file lcRuta + "textoprueba.txt"
		delete file lcRuta + "textoprueba.bak"
		delete file lcRuta + "textoprueba.pif"		

        loManejoArchivos.destroy()
        loManejoArchivos = Null
	endfunc	

	
	*-----------------------------------	
	Function TearDown
	
		local lcSeguridad as String
		lcSeguridad = this.cSafety
		set Safety &lcSeguridad
		
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ztestObtenerImagenEnDirectorioEspecificoConDirectorioInvalido()
		local loManejoArchivos as ManejoArchivos of ManejoArchivos.prg, lcTextoArchivo as String, llCambioAtributo as Boolean, ;
			lcAtributo as String, lcRuta as String
    
        lcRuta = addbs( _Screen.zoo.Obtenerrutatemporal() ) + sys(2015) + "\"
	
		loManejoArchivos = newobject( "ManejoArchivos", "ManejoArchivos.prg" )
		try
			loManejoArchivos.ObtenerImagenEnDirectorioEspecifico( "*.prg", "", lcRuta )
		catch to loError
			this.assertequals( "El mensaje de error es incorrecto.", "El directorio '"+lcRuta +"' configurado para seleccionar el archivo no existe.", loError.Uservalue.oInformacion.item[1].cMensaje )
		endtry
        loManejoArchivos = Null		
	endfunc 


EndDefine
