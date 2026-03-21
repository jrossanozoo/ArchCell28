**********************************************************************
define class ztestlibrerias as FxuTestCase of FxuTestCase.prg

	#if .f.
		local this as ztestlibrerias of ztestlibrerias.prg
	#endif

	oLibrerias = null
	cCarpetaTMP = ""

	*-----------------------------------------------------------------------------------------
	function setup
		if !pemstatus( _screen, "zoo", 5 ) 
			_screen.AddProperty( "zoo" )
		endif
		if vartype( _screen.zoo ) != "O"
			_screen.zoo = newobject( "zoo", "zoo.prg" )
		endif
		this.oLibrerias = newObject( "Librerias", "Librerias.prg" )
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestInstanciarLibrerias
		this.assertequals( "No se instanció la clase librerias", "O", vartype( this.oLibrerias ) )
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestValidarCuit
		with this.oLibrerias
			this.asserttrue( "El CUIT con espacios al final no debería ser válido", ! .ValidarCuit( '66999999995          ' ) )
			
			this.asserttrue( "El CUIT no debería ser válido", ! .ValidarCuit( '66999999995' ) )
			
			this.asserttrue( "El CUIT con guiones no debería ser válido", ! .ValidarCuit( '66-99999999-5' ) )
			
			this.asserttrue( "El CUIT con espacios al final debería ser válido", .ValidarCuit( '20137822661          ' ) )
			
			this.asserttrue( "El CUIT debería ser válido", .ValidarCuit( '20137822661' ) )
			
			this.asserttrue( "El CUIT con guiones debería ser válido", .ValidarCuit( '20-13782266-1' ) )
		endwith 		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestValidarRut
		with this.oLibrerias
			this.Asserttrue( "El RUT deberia ser correcto.", .ValidarRut( '7.721.161-6' ) )
			this.Asserttrue( "El RUT deberia ser incorrecto. 1", !.ValidarRut( '7.721.161.6' ) )
			this.Asserttrue( "El RUT deberia ser incorrecto. 2", !.ValidarRut( '7,721,161-6' ) )
			this.Asserttrue( "El RUT deberia ser incorrecto. 3", !.ValidarRut( '7 721 161-6' ) )

			this.Asserttrue( "El RUT deberia ser incorrecto. 4", !.ValidarRut( '7.721.161.6' ) )
			this.Asserttrue( "El RUT deberia ser incorrecto. 5", !.ValidarRut( '7.721.161,6' ) )
			this.Asserttrue( "El RUT deberia ser incorrecto. 6", !.ValidarRut( '7,721.161-6' ) )
			this.Asserttrue( "El RUT deberia ser incorrecto. 7", !.ValidarRut( '7 721.161-6' ) )
			this.Asserttrue( "El RUT deberia ser correcto. 8", !.ValidarRut( ' .   .   - ' ) )
			this.Asserttrue( "El RUT deberia ser correcto. 9", .ValidarRut( '' ) )
		endwith
	endfunc 


	*-----------------------------------------------------------------------------------------
	function zTestValidarSeteos
		local loLibrerias as Object
		
		loLibrerias = newobject( "LibreriasAux" )
		
		this.assertequals( "El set date no es british", "BRITISH", upper( loLibrerias.ObtenerSetDate() ) )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestCompararValores
		local lxValor1 as Variant, lxValor2 as Variant,llDesactivarCaseSensitive as boolean, llRetorno as boolean ;
			, loError as exception, llException as boolean

		with this.oLibrerias
			lxValor1 = 1
			lxValor2 = 1

			llBoolean = .CompararValores( lxValor1, lxValor2 )
			this.assertequals( "La comparacion debe ser .T. ( 1, 1 )", .t., llBoolean )

			lxValor1 = 1
			lxValor2 = 2
			llBoolean = .CompararValores( lxValor1, lxValor2 )
			this.assertequals( "La comparacion debe ser .F. ( 1, 2 )", .f., llBoolean )

			lxValor1 = date()
			lxValor2 = date()
			llBoolean = .CompararValores( lxValor1, lxValor2 )
			this.assertequals( "La comparacion debe ser .T. ( date(), date() )", .t., llBoolean )

			lxValor1 = date()
			lxValor2 = date()+1
			llBoolean = .CompararValores( lxValor1, lxValor2 )
			this.assertequals( "La comparacion debe ser .F. ( date(), date()+1 )", .f., llBoolean )
			
			lxValor1 = "A"
			lxValor2 = "A"
			llBoolean = .CompararValores( lxValor1, lxValor2 )
			this.assertequals( "La comparacion debe ser .T. ( 'A', 'A' )", .t., llBoolean )

			lxValor1 = "A"
			lxValor2 = "B"
			llBoolean = .CompararValores( lxValor1, lxValor2 )
			this.assertequals( "La comparacion debe ser .F. ( 'A', 'B' )", .f., llBoolean )

			lxValor1 = "A"
			lxValor2 = "AA"
			llBoolean = .CompararValores( lxValor1, lxValor2 )
			this.assertequals( "La comparacion debe ser .F. ( 'A', 'AA' )", .f., llBoolean )

			lxValor1 = "A"
			lxValor2 = "a"
			llBoolean = .CompararValores( lxValor1, lxValor2, llDesactivarCaseSensitive  )
			this.assertequals( "La comparacion debe ser .F. ( 'A', 'a' )  sin descativar Case Sensitive = .f.", .f., llBoolean )

			llDesactivarCaseSensitive = .f.
			lxValor1 = "A"
			lxValor2 = "a"
			llBoolean = .CompararValores( lxValor1, lxValor2, llDesactivarCaseSensitive  )
			this.assertequals( "La comparacion debe ser .F. ( 'A', 'a' )  sin descativar Case Sensitive = .f.", .f., llBoolean )

			llDesactivarCaseSensitive = .t.
			lxValor1 = "A"
			lxValor2 = "a"
			llBoolean = .CompararValores( lxValor1, lxValor2, llDesactivarCaseSensitive  )
			this.assertequals( "La comparacion debe ser .t. ( 'A', 'a' ) descativando Case Sensitive = .t.", .t., llBoolean )						
			
			lxValor1 = 1
			lxValor2 = "A"

			llException = .f.
			try
				llBoolean = .CompararValores( lxValor1, lxValor2 )
			catch to loError
				llException = .t.
				*loError.ErrorNo=-10000
				*loError.Message=""
				*throw loError
			endtry

			this.assertequals( "La comparacion debe dar una excepcion ( 1, 'A' )", .t., llException )
		endwith

	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestObtenerArchivoPlano
		local lcTexto as string, lcRutaParametro as string, lcCadenaArchivo as String 
		
text to lcCadenaArchivo noShow
\TECNOVOZ\TBL\RECSAMP7
19442
I
  Serie: 501795 // R. Social: 05374-Esposito Andrea Graciela; // Cliente: 01462-Grisino Ramos Mejia
0
20081002
16212801
004



VIR
7
374136001
1144645061
8100

0

endtext 
		lcRutaParametro =  addbs( _screen.zoo.obtenerrutatemporal() ) + "parametronroserie.TXT"

		strtofile( lcCadenaArchivo, lcRutaParametro )
		
		lcTexto = this.oLibrerias.ObtenerArchivoPlano( alltrim( lcRutaParametro ) , 4 , 10 , 6 )
		
		this.assertequals( "El numero de serie esperado es 501795", "501795", upper( alltrim( lcTexto ) ) ) 
	
		lcRutaParametro = ''
	
		lcTexto = this.oLibrerias.ObtenerArchivoPlano( alltrim( lcRutaParametro ) , 4 , 10 , 6 )
	
		this.assertequals( "No devuelve ningun texto.", "", upper( alltrim( lcTexto ) ) ) 
			
		lcRutaParametro =  addbs( _screen.zoo.obtenerrutatemporal() ) + "parametronroserie.TXT"
		
		lcTexto = this.oLibrerias.ObtenerArchivoPlano( alltrim( lcRutaParametro ) , 900 , 10 , 6 )
	
		this.assertequals( "No devuelve ningun texto 2.", "", upper( alltrim( lcTexto ) ) )	
	
	endfunc 



	*-----------------------------------------------------------------------------------------
	function zTestDecrip
		local lcDecrip as String, lcEncrip as String
		
		lcEncrip = "076104108096097081056"
		
		lcDecrip = this.oLibrerias.Desencriptar( lcEncrip )
		this.assertequals( "No se desencripto correctamente el valor.", "LinceV7", lcDecrip )
		

	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestEncrip
		local lcDecrip as String, lcEncrip as String
		
		lcDecrip = "LinceV7"
		lcEncrip = this.oLibrerias.Encriptar( lcDecrip )
		this.assertequals( "No se desencripto correctamente el valor.", "076104108096097081056", lcEncrip )
		
	endfunc
	
	*-----------------------------------------------------------------------------------------

	function zTestTransformarCadenaCaracteres 

		local loLibrerias as Object, lcRetorno as String, lcCadenaInicial as String
		
		loLibrerias = newobject("Librerias","Librerias.prg")
		this.asserttrue("No se ha instanciado la clase Librerias",vartype(loLibrerias) = "O")
		lcCadenaInicial = "Hola Mundo"
		lcRetorno = loLibrerias.TransformarCadenaCaracteres( lcCadenaInicial )
		this.assertequals("No se transformó correctamente la cadena " + alltrim( lcCadenaInicial ), "HolaMundo", lcRetorno)
		lcCadenaInicial = "Nota de Crédito"
		lcRetorno = loLibrerias.TransformarCadenaCaracteres( lcCadenaInicial )
		this.assertequals("No se transformó correctamente la cadena " + alltrim( lcCadenaInicial ), "NotaDeCredito", lcRetorno)
		

	endfunc 

	*-----------------------------------------------------------------------------------------

	function ZTestObtenerVersion
		local loLibrerias as Object, LcRetorno as string
	
		loLibrerias = newobject( "Librerias","Librerias.prg" )

		this.asserttrue("No se ha instanciado la clase Librerias",vartype(loLibrerias) = "O")
		this.asserttrue("No existe la funcion ObtenerVersion",pemstatus(loLibrerias,"ObtenerVersion",5) )

		set textmerge on noshow
		set textmerge to PruebaTest.prg
			\messagebox("hola mundo")
		set textmerge to
		set textmerge off
		build project PruebaTest from PruebaTest.prg 
		modify project PruebaTest.PJX noshow nowait

		_vfp.ActiveProject.VersionNumber = "4.0.0"
		_vfp.ActiveProject.Build("PruebaTest",3)
		_vfp.ActiveProject.close()
		
		lcRetorno = loLibrerias.ObtenerVersion( "PruebaTest.exe" )
		this.assertequals( "El número de versión no es el correcto", "4.0.0" , lcRetorno )

		delete file PruebaTest.*

	endfunc 


	*-----------------------------------------------------------------------------------------
	function zTestObtenerMatrizSituacionFiscal
		private goParametros as Object
		public laMatriz
		dimension laMatriz[8]

		if !pemstatus( _screen.zoo, "app", 5 ) 
			_screen.zoo.AddProperty( "app" )
		endif
		if vartype( _screen.zoo.app ) != "O"
			_screen.zoo.app = newobject( "aplicacionbase", "aplicacionbase.prg" )
		endif

		goParametros = newobject( "Parametros" )
		_screen.zoo.app.cProyecto = "DLLS"

		this.oLibrerias.ObtenerMatrizSituacionFiscal( "laMatriz", 1, .F.,.T. ) 
		
		for i = 1 to alen( laMatriz ) 
			this.asserttrue( "Se deshabilito una situacion fiscal en la matriz", "\" # left(alltrim(laMatriz[i]),1) )
		endfor
		
		_screen.zoo.app.cProyecto = "FELINO"
		store "" to laMatriz
		
		this.oLibrerias.ObtenerMatrizSituacionFiscal( "laMatriz", 1, .F.,.T. ) 
		
		this.assertequals( "No se deshabilito el 'Reponsable no inscripto' en la matriz", "\", left(alltrim(laMatriz[2]),1) )
		
		_screen.zoo.app = null
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestEncriptacion192
		local lcTexto as String, lcTextoEncriptado as String
		
		lcTexto = "Texto a encriptar"
		lcTextoEncriptado = this.oLibrerias.Encriptar192( lcTexto )
		this.assertequals( "Hubo problemas durante la encriptacion / desencriptacion de un texto", lcTexto, this.oLibrerias.DesEncriptar192( lcTextoEncriptado ) )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestCalcularEdad
		local lnEdad as Integer 
		
		lnEdad = this.oLibrerias.CalcularEdad( date() )

		this.assertequals( "No calculo bien la edad", 0, lnEdad )
		

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestValorVacioSegunTipo

		This.assertEquals( "El valor vacio devuelto es incorrecto 1", "", this.oLibrerias.ValorVacioSegunTipo( "C" ) )
		This.assertEquals( "El valor vacio devuelto es incorrecto 2", 0, this.oLibrerias.ValorVacioSegunTipo( "N" ) )
		This.assertEquals( "El valor vacio devuelto es incorrecto 3", .F., this.oLibrerias.ValorVacioSegunTipo( "L" ) )
		This.assertEquals( "El valor vacio devuelto es incorrecto 4", {}, this.oLibrerias.ValorVacioSegunTipo( "D" ) )
		This.assertEquals( "El valor vacio devuelto es incorrecto 5", 0, this.oLibrerias.ValorVacioSegunTipo( "A" ) )
		This.assertEquals( "El valor vacio devuelto es incorrecto 6", "", this.oLibrerias.ValorVacioSegunTipo( "NADA" ) )

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestComprimir
		local lcArchivoZip as String, loColeccion as zoocoleccion OF zoocoleccion.prg, lcRuta as String, i as Integer, ;
			oArchivos as object, loError as Object
		oArchivos = newobject("manejoarchivos","manejoarchivos.prg")

		lcRuta = addbs( _screen.zoo.ObtenerRutaTemporal() )
		loColeccion = _screen.zoo.CrearObjeto( "zooColeccion", "zooColeccion.prg" )
		
		for i = 1 to 7
			lcArchivo = "Prueba" + transform( i ) + ".txt"
			strtofile( "Prueba", lcRuta + lcArchivo, 0 )
			loColeccion.agregar( lcRuta + lcArchivo )
		endfor

		lcArchivoZip = lcRuta + "TestSinContraseña.zip"
		this.cCarpetaTMP = sys( 2015 )
		lcArchivoZip2 = lcRuta + this.cCarpetaTMP + "\TestSinContraseña.zip"
		
		strtofile( "", lcARchivoZIP, 0 )
		
		oArchivos.setearatributos( "R", lcArchivoZIP )
		try
			this.oLibrerias.Comprimir( lcARchivoZIP, loColeccion )
			this.asserttrue( "Debería haber dado error por archivo de solo lectura", .f. )
		catch to loError
			this.assertequals( "No dio el error correcto (error)", lower( "File access is denied" ), left( lower( loError.UserValue.Message ), 21 ) )
			this.assertequals( "No dio el error correcto (archivo)", lower( "testsincontraseña.zip." ), right( lower( loError.UserValue.Message ), 22 ) )
		endtry

		oArchivos.setearatributos( "N", lcARchivoZIP )
		delete file ( lcARchivoZIP )

		this.oLibrerias.Comprimir( lcARchivoZIP, loColeccion )
		this.oLibrerias.Comprimir( lcARchivoZIP2, loColeccion, "ContraseñaDePrueba" )
		for i = 1 to 7
			delete file ( lcRuta + "Prueba" + transform( i ) + ".txt" )
			this.asserttrue( "No se eliminó el archivo " + upper( lcRuta + "Prueba" + transform( i ) + ".txt" ), !file( lcRuta + "Prueba" + transform( i ) + ".txt" ) )
		endfor
		this.asserttrue( "No se creo el archivo comprimido " + upper( lcARchivoZIP ), file( lcARchivoZIP ) )
		this.asserttrue( "No se creo el archivo comprimido " + upper( lcARchivoZIP2 ), file( lcARchivoZIP2 ) )
	endfunc 


	*-----------------------------------------------------------------------------------------
	function zTestDescomprimir
		local lcArchivoZip as String, loColeccion as zoocoleccion OF zoocoleccion.prg, lcRuta as String, i as Integer, ;
			oArchivos as object, loError as Object

		oArchivos = newobject("manejoarchivos","manejoarchivos.prg")

		lcRuta = addbs( _screen.zoo.ObtenerRutaTemporal() )
		loColeccion = _screen.zoo.CrearObjeto( "zooColeccion", "zooColeccion.prg" )
		
		for i = 1 to 7
			lcArchivo = "Prueba" + transform( i ) + ".txt"
			strtofile( "Prueba", lcRuta + lcArchivo, 0 )
			loColeccion.agregar( lcRuta + lcArchivo )
		endfor

		lcArchivoZip = lcRuta + "TestSinContraseña.zip"
		this.cCarpetaTMP = sys( 2015 )
		lcArchivoZip2 = addbs( lcRuta ) + "\TestConContraseña.zip"
		
		this.oLibrerias.Comprimir( lcARchivoZIP, loColeccion )
		this.oLibrerias.Comprimir( lcARchivoZIP2, loColeccion, "ContraseñaDePrueba" )
		for i = 1 to 7
			delete file ( lcRuta + "Prueba" + transform( i ) + ".txt" )
			this.asserttrue( "No se eliminó el archivo " + upper( lcRuta + "Prueba" + transform( i ) + ".txt" ), !file( lcRuta + "Prueba" + transform( i ) + ".txt" ) )
		endfor
		this.asserttrue( "No se creo el archivo comprimido " + upper( lcARchivoZIP ), file( lcARchivoZIP ) )
		this.asserttrue( "No se creo el archivo comprimido " + upper( lcARchivoZIP2 ), file( lcARchivoZIP2 ) )
		
		This.AssertTrue( "No descomprimio el archivo " + lcArchivozip, this.oLibrerias.Descomprimir( lcARchivoZIP, lcRuta, "" ) )
		for i = 1 to 7
			this.asserttrue( "No se descomprimio el archivo " + upper( lcRuta + "Prueba" + transform( i ) + ".txt" ), file( lcRuta + "Prueba" + transform( i ) + ".txt" ) )
			delete file ( lcRuta + "Prueba" + transform( i ) + ".txt" )
		endfor

		This.AssertTrue( "Descomprimio el archivo " + lcArchivozip2, !this.oLibrerias.Descomprimir( lcARchivoZIP2, lcRuta, "" ) )
		for i = 1 to 7
			this.asserttrue( "Se descomprimio el archivo " + upper( lcRuta + "Prueba" + transform( i ) + ".txt" ), !file( lcRuta + "Prueba" + transform( i ) + ".txt" ) )
			delete file ( lcRuta + "Prueba" + transform( i ) + ".txt" )
		endfor

		This.AssertTrue( "No descomprimio el archivo " + lcArchivozip2, this.oLibrerias.Descomprimir( lcARchivoZIP2, lcRuta, "ContraseñaDePrueba" ) )
		for i = 1 to 7
			this.asserttrue( "No se descomprimio el archivo " + upper( addbs( lcRuta )+ "Prueba" + transform( i ) + ".txt" ), file( addbs( lcRuta ) + "Prueba" + transform( i ) + ".txt" ) )
			delete file ( addbs( lcRuta ) + "Prueba" + transform( i ) + ".txt" )
		endfor
		strtofile( "Basura", lcARchivoZIP, 0 )
		This.AssertTrue( "Descomprimio el archivo basura " + lcArchivozip, !this.oLibrerias.Descomprimir( lcARchivoZIP, lcRuta, "" ) )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestExisteAplicacionEnEjecucion
		local llExisteAplicacion as Boolean

		llExisteAplicacion = this.oLibrerias.ExisteAplicacionEnEjecucion( "svchost.exe" )
		this.asserttrue( "No se encontró la aplicación svchost.exe", llExisteAplicacion )

		llExisteAplicacion = this.oLibrerias.ExisteAplicacionEnEjecucion( "SVCHOST.EXE" )
		this.asserttrue( "No se encontró la aplicación svchost.exe", llExisteAplicacion )

		llExisteAplicacion = this.oLibrerias.ExisteAplicacionEnEjecucion( "aplicacionInexistente.exe" )
		this.asserttrue( "No se encontró la aplicación svchost.exe", !llExisteAplicacion )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestExisteProcesoPorNombreDeVentana
		local llExisteAplicacion as Boolean, lcNombreDeVentanaAProbar as String, lcAbrir as String, ;
			lcRutaActual as String, lcCarpetaACrear as String 

		lcRutaActual = addbs( Sys(5) + Curdir() )
		lcNombreDeVentanaAProbar = 'Ventana_de_prueba' + sys(2015) 
		lcCarpetaACrear = lcRutaActual + lcNombreDeVentanaAProbar

		if directory( lcCarpetaACrear )
		else
			md ( lcCarpetaACrear )
		endif
		
		lcAbrir = '! /n explorer ' + lcCarpetaACrear
		&lcAbrir

		=inkey(0.06)	&& Este delay es necesario para refrescar la lista de ventanas.

		llExisteAplicacion = this.oLibrerias.ExisteProcesoPorNombreDeVentana( lcNombreDeVentanaAProbar )
		this.asserttrue( "No se encontró la ventana con título " + lcNombreDeVentanaAProbar, llExisteAplicacion )

		llExisteAplicacion = this.oLibrerias.ExisteProcesoPorNombreDeVentana( upper( lcNombreDeVentanaAProbar ) )
		this.asserttrue( "No se encontró la ventana con título " + upper( lcNombreDeVentanaAProbar ), llExisteAplicacion )

		lcNombreDeVentanaAProbar = "Ventana_de_prueba" + sys(2015) + ". Esta ventana no debería existir"
		llExisteAplicacion = this.oLibrerias.ExisteProcesoPorNombreDeVentana( lcNombreDeVentanaAProbar )
		this.asserttrue( "Se encontró la ventana con título " + lcNombreDeVentanaAProbar, !llExisteAplicacion )

		rd ( lcCarpetaACrear )
	endfunc 


	*-----------------------------------------------------------------------------------------
	function zTestObtenerDatosDeIni	
	
		local lcArchivo as String , lcContenidoIni as String , lcRetorno as String

		lcArchivo = "c:\TEST.INI"


		TEXT to lcContenidoIni noshow textmerge
[ZDK]
Aplicacion = APLICACIONPEPE
[ADNIMPLANT]
RutaZipGenerados = 

		ENDTEXT
		Strtofile( lcContenidoIni, lcArchivo )

		lcRetorno = this.oLibrerias.ObtenerDatosDeIni( lcArchivo, "ZDK","Aplicacion" )
		This.assertequals( "No se obtuvo el valor correcto para la entrada 'Aplicacion'", "APLICACIONPEPE", lcRetorno )
		
		lcRetorno = this.oLibrerias.ObtenerDatosDeIni( lcArchivo, "ADNIMPLANT","RutaZipGenerados" )
		This.assertequals( "No se obtuvo el valor correcto para la entrada 'RutaZipGenerados'", "", lcRetorno )
		
		lcRetorno = this.oLibrerias.ObtenerDatosDeIni( lcArchivo, "ADNIMPLANT","EntradaTrucha" )
		This.assertequals( "No se obtuvo el valor correcto para la entrada 'EntradaTrucha'", "", lcRetorno )

		delete file ( lcArchivo )
				

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestEstablecerFechaDeSistema
		local ldFechaActual as datetime, ldFecha as date
		
		ldFechaActual = date()
		ldFecha = gomonth( ldFechaActual, -1 )
		this.oLibrerias.EstablecerFechaDeSistema( ldFecha )
		this.assertequals( "No se establecio la fecha correctamente", ldFecha, date() )
		this.oLibrerias.EstablecerFechaDeSistema( ldFechaActual )
		this.assertequals( "No se reestablecio la fecha correctamente", ldFechaActual, date() )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestObtenerIp
	
		local loDatosMaquina as Object
		loDatosMaquina =  newobject ("DatosMaquina", "DatosMaquina.prg")
	
		this.assertequals( "No obtuvo la Ip correctamente", loDatosMaquina.ipAddress(), this.oLibrerias.ObtenerIp() )

		loDatosMaquina = null
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestObtenerMacAdress

		local loDatosMaquina as Object
		loDatosMaquina =  newobject ("DatosMaquina", "DatosMaquina.prg")
	
		this.assertequals( "No obtuvo la Mac correctamente", loDatosMaquina.macaddress(), this.oLibrerias.ObtenerMacAdress() )

		loDatosMaquina = null

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestObtenerGuid
		this.asserttrue( "No obtuvo el guid correctamente", !empty( this.oLibrerias.ObtenerGuid()))
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestObtenerTimeStamp
		local i as Integer
		local array laTimeStamps(100)
		
		this.asserttrue( "No obtuvo el TimeStamp correctamente", !empty( this.oLibrerias.ObtenerTimeStamp() ) )

		for i = 1 to 100
			laTimeStamps(i) = this.oLibrerias.ObtenerTimeStamp()
			wait "" timeout 0.01
		endfor
		
		for i = 1 to 99
			lnPos = ascan( laTimeStamps, laTimeStamps(i), i+1 )
			this.assertequals( "Se repitio el TimeStamps " + alltrim( transform( i ) ) + " en la posicion " + alltrim( transform( lnPos ))+ ;
				" del array.",0, lnPos )
		endfor

	endfunc
	
	*-----------------------------------------------------------------------------------------	
	function TearDown
		local i as Integer, lcRuta

		this.oLibrerias.release()
		delete file ( addbs( _screen.zoo.ObtenerRutaTemporal() ) + "TestConContraseña.zip" )
		delete file ( addbs( _screen.zoo.ObtenerRutaTemporal() ) + "\TestSinContraseña.zip" )
		delete file ( addbs( _screen.zoo.ObtenerRutaTemporal() ) + this.cCarpetaTMP + "\TestSinContraseña.zip" )
		for i  = 1 to 7
			delete file ( addbs( _screen.zoo.ObtenerRutaTemporal() ) + "Prueba" + transform( i ) + ".txt" )
		endfor
		
		if !empty( this.cCarpetaTMP )
			lcRuta = addbs( _screen.zoo.ObtenerRutaTemporal() ) + this.cCarpetaTMP
			if directory( lcRuta )
				rd ( lcRuta )
			endif
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	Function zTestFormateodeFechas
		local ldDate as Date
		
		private goRegistry
		
		goRegistry = newobject( "mockRegistry" )
		_screen.zoo.App = newobject( "AppMock" )
		
		
		_screen.zoo.App.TipoDeBase = "NATIVA"
		ldDate = this.oLibrerias.ObtenerFechaFormateada( date() )

		This.assertequals( "La fecha devuelta no es del tipo correcto. Nativa " , "D" ,vartype( ldDate ) )


		goRegistry.Nucleo.FechaEnBlancoParaSqlServer = "{01/01/1900 00:00:00}"
		
		_screen.zoo.App.TipoDeBase = "SQLSERVER"
		ldDate = this.oLibrerias.ObtenerFechaFormateada( datetime() )

		This.assertequals( "La fecha devuelta no es del tipo correcto. SqlServer " , "D" ,vartype( ldDate ) )


		goRegistry.Nucleo.FechaEnBlancoParaSqlServer = "{01/01/2000 00:00:00}"
		ldDate = this.oLibrerias.ObtenerFechaFormateada( ctot( "01/01/2000 00:00:00" ) )
		
		This.assertequals( "La fecha devuelta no esta vacia", ctod( "" ), ldDate )
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestRedondearSegunMascara
		local lnParametroAnterior as Integer, lnNumero as float
		private goParametros as Object

		goParametros = newobject( "Parametros" )
		goParametros.Dibujante.DecimalesParaMascaraNumericos = 4
		
		this.asserttrue( 'No existe la propiedad nDecimalesParaMascaraNumericos', pemstatus( this.oLibrerias, 'nDecimalesParaMascaraNumericos', 4 ) )
		
		lnNumero = this.oLibrerias.RedondearSegunMascara( 55.3456789012 )
		this.assertequals( 'La propiedad nDecimalesParaMascaraNumericos, debería ser igual al parámetro', goParametros.Dibujante.DecimalesParaMascaraNumericos, this.oLibrerias.nDecimalesParaMascaraNumericos )
		this.assertequals( 'El método RedondearSegunMascara, no retornó lo esperado', 55.3457, lnNumero )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestHashear
		local lcDecrip as String, lcEncrip as String
		
		lcEncrip = "PruebaDeHasheoDeCadena"
		
		lcHash = this.oLibrerias.hashear( lcEncrip )
		this.assertequals( "No se hasheo correctamente el valor.", "2af060542fa10c23bc1aff3ca2e8fef445dc7e98bb9fa3186ce4abc41459dd4b", lcHash )
		

	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestComparar
		local llResultado as Boolean
		
		llResultado = this.oLibrerias.CompararHash( "PruebaDeHasheoDeCadena", "2af060542fa10c23bc1aff3ca2e8fef445dc7e98bb9fa3186ce4abc41459dd4b" )
		this.asserttrue( "La comparacion deberia ser correcta.", llResultado )
		
	endfunc


enddefine

** Se define esta clase acá porque el proyecto DLLs no genera parámetros ni ninguna otra cosa
define class parametros as Custom
	felino = null
	dlls = null
	dibujante = null
	
	*-----------------------------------------------------------------------------------------
	function init() as Void
		this.felino = newobject( "custom" )
		this.felino.addproperty( "DatosImpositivos", newobject( "DatosImpositivos" ) )
		this.dlls = newobject( "custom" )
		this.dlls.addproperty( "DatosImpositivos", newobject( "DatosImpositivos" ) )
		this.dibujante = newobject( "custom" )
		this.dibujante.addproperty( "DecimalesParaMascaraNumericos", 0 )
	endfunc 

enddefine

define class DatosImpositivos as custom

	Tipositfiscalcliente1expandido = 'Responsable Inscripto'
	TipoSitFiscalCliente1Normal = ''
	TipoSitFiscalCliente1Compacto = ''
	Tipositfiscalproveedor1expandido = 'Responsable Inscripto'
	TipoSitFiscalProveedor1Normal = ''
	TipoSitFiscalProveedor1Compacto = ''
	Tipositfiscalcliente2expandido = 'Responsable No Inscripto'
	TipoSitFiscalCliente2Normal = ''
	TipoSitFiscalCliente2Compacto = ''
	Tipositfiscalproveedor2expandido = 'Responsable No Inscripto'
	TipoSitFiscalProveedor2Normal = ''
	TipoSitFiscalProveedor2Compacto = ''
	Tipositfiscalcliente3expandido = 'Consumidor Final'
	TipoSitFiscalCliente3Normal = ''
	TipoSitFiscalCliente3Compacto = ''
	Tipositfiscalproveedor3expandido = 'Consumidor Final'
	TipoSitFiscalProveedor3Normal = ''
	TipoSitFiscalProveedor3Compacto = ''
	Tipositfiscalcliente4expandido = 'Exento'
	TipoSitFiscalCliente4Normal = ''
	TipoSitFiscalCliente4Compacto = ''
	Tipositfiscalproveedor4expandido = 'Exento'
	TipoSitFiscalProveedor4Normal = ''
	TipoSitFiscalProveedor4Compacto = ''
	Tipositfiscalcliente5expandido = 'Inscripto No Responsable'
	TipoSitFiscalCliente5Normal = ''
	TipoSitFiscalCliente5Compacto = ''
	Tipositfiscalproveedor5expandido = 'Inscripto no Responsable'
	TipoSitFiscalProveedor5Normal = ''
	TipoSitFiscalProveedor5Compacto = ''
	Tipositfiscalcliente6expandido = 'Liberado'
	TipoSitFiscalCliente6Normal = ''
	TipoSitFiscalCliente6Compacto = ''
	Tipositfiscalproveedor6expandido = 'Monotributo'
	TipoSitFiscalProveedor6Normal = ''
	TipoSitFiscalProveedor6Compacto = ''
	Tipositfiscalcliente7expandido = 'Responsable Monotributo'
	TipoSitFiscalCliente7Normal = ''
	TipoSitFiscalCliente7Compacto = ''
	Tipositfiscalcliente8expandido = 'OTNI'
	TipoSitFiscalCliente8Normal = ''
	TipoSitFiscalCliente8Compacto = ''
	CodigoUnicoDeIdentificacionTributaria = ''
	CodigoUnicoDeIdentificacionTributariaReducido = ''
	ImpuestoAlValorAgregado = ''
	ImpuestoAlValorAgregadoReducido = ''
	Situacionfiscalpredeterminadaparaclienteminorista = 3
	Situacionfiscalpredeterminadaparaproveedor = 1
	SituacionFiscalPredeterminadaParaClienteMayorista = 1

enddefine

define class LibreriasAux as librerias of librerias.prg

	*-----------------------------------------------------------------------------------------
	function ObtenerSetDate() as String
		return set("Date")
	endfunc 

enddefine


define class AppMock as Custom
	TipoDeBase = ""
enddefine


define class mockRegistry as Custom

Nucleo = null
	*-----------------------------------------------------------------------------------------
	function init() as Void
		This.Nucleo = newobject( "Custom" )
		addProperty( This.Nucleo ,"FechaEnBlancoParaSqlServer" , "" )
	endfunc 
enddefine

