**********************************************************************
Define Class ztestLibrerias as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as ztestLibrerias of ztestLibrerias.prg
	#ENDIF
	ldFechaAnterior = ""
	*---------------------------------
	Function Setup
		goRegistry.Nucleo.Actualizaciones.URLParaActualizaciones = addbs(  _Screen.zoo.obtenerRutaTemporal() )
			this.ldFechaAnterior = set("date")
			set date to DMY
	EndFunc
	
	*---------------------------------
	Function TearDown
		set date to (this.ldFechaAnterior)
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestObtenerCaracteresValidos
		local lcEsperado as String, lcObtenido as String, loLibreria as Object, ;
				lPermiteMayusculas as Boolean, lcCaracteresPk as String, ;
				lcLetras as String, lcNumeros as String
		
		loLibreria = _screen.zoo.crearobjeto( "Librerias", "Librerias.prg" )

		lcLetras = alltrim( goRegistry.Nucleo.CadenaDeLetrasValidas )
		lcNumeros = alltrim( goRegistry.Nucleo.CadenaDeNumerosValidos )
		lcCaracteresPk = alltrim( goregistry.nucleo.CadenaDeCaracteresBasicosValidos )

		lcEsperado = lcNumeros + upper( lcLetras ) + lower( lcLetras ) + lcCaracteresPk
		lPermiteMayusculas = .T.
		lcObtenido = loLibreria.ObtenerCaracteresValidos( lPermiteMayusculas )
		This.assertequals( "No es correcta la cadena de caracteres(Permite Mayusculas).", lcEsperado, alltrim( lcObtenido ) )

		lcEsperado = lcNumeros + upper( lcLetras ) + lcCaracteresPk
		lPermiteMayusculas = .F.
		lcObtenido = loLibreria.ObtenerCaracteresValidos( lPermiteMayusculas )
		This.assertequals( "No es correcta la cadena de caracteres(NO Permite Mayusculas).", lcEsperado, alltrim( lcObtenido ) )

		loLibreria.Release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestObtenerCodigosAsciiParaArmarExpresionesTipoString
		local loColEsperado as zoocoleccion OF zoocoleccion.prg, loLibreria as Object
		
		loLibreria = _screen.zoo.crearobjeto( "Librerias", "Librerias.prg" )

		loColEsperado = loLibreria.ObtenerCodigosAsciiParaArmarExpresionesTipoString()
		This.assertequals( "No son correctos la cantidad de códigos ascii para armar expresiones tipo string.", 4, loColEsperado.Count )
		This.asserttrue( "Código ascii no encontrado (1).", loLibreria.EsCodigoAsciiParaArmarExpresionTipoString( 39 ) )
		This.asserttrue( "Código ascii no encontrado (2).", loLibreria.EsCodigoAsciiParaArmarExpresionTipoString( 93 ) )
		This.asserttrue( "Código ascii no encontrado (3).", loLibreria.EsCodigoAsciiParaArmarExpresionTipoString( 91 ) )
		This.asserttrue( "Código ascii no encontrado (4).", loLibreria.EsCodigoAsciiParaArmarExpresionTipoString( 34 ) )

		loLibreria.Release()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestValidarRegistrosCaracteresValidos
		local lcNumeroEsperado as String, lcLetraEsperado as String, lcEspecialesEsperado as String

		lcNumeroEsperado = "0123456789"
		lcLetraEsperado = "ABCDEFGHIJKLMNÑOPQRSTUVWXYZ"
		lcEspecialesEsperado = 'º\ª!@#$%&() =?¿*{}[]<>,;:-áéíóúÁÉÍÓÚ+"'
		
		This.assertequals( "La cadena de numeros validos no es correcta.", lcNumeroEsperado, alltrim( goRegistry.Nucleo.CadenaDeNumerosValidos ) )
		This.assertequals( "La cadena de letras validas no es correcta.", lcLetraEsperado, alltrim( goRegistry.Nucleo.CadenaDeLetrasValidas ) )
		This.assertequals( "La cadena de caracteres especiales validos no es correcta.", lcEspecialesEsperado, alltrim( goRegistry.Nucleo.CadenaDeCaracteresEspecialesValidos ) )
		
	endfunc 


	*-----------------------------------------------------------------------------------------
	function zTestInvertirMayusculasMinusculas
		local loLibrerias as Object
		loLibrerias = _screen.zoo.crearobjeto( "Librerias", "Librerias.prg" )
		
		lcParametro = "AbCdEfGhIjKlMnOpQrStUvWxYz"
		lcValorEsperado = "aBcDeFgHiJkLmNoPqRsTuVwXyZ"
		lcValorRetornado = loLibrerias.InvertirMayusculasMinusculas( lcParametro )
		This.assertequals( "No se inviertieron correctamente las mayúsculas y minúsculas.", lcValorEsperado, lcValorRetornado )
		
		lcParametro = "A!b#C$d%E&f/G(h)I=j?K¡l¿M+n*O{p}Q[r]S,t;U.v:W-x_Y@z"
		lcValorEsperado = "a!B#c$D%e&F/g(H)i=J?k¡L¿m+N*o{P}q[R]s,T;u.V:w-X_y@Z"
		lcValorRetornado = loLibrerias.InvertirMayusculasMinusculas( lcParametro )
		This.assertequals( "No se deben invertir los símbolos.", lcValorEsperado, lcValorRetornado )

		lcParametro = "A1b2C3d4E5f6G7h8I9j0K9l8M7n6O5p4Q3r2S1tUvWxYz"
		lcValorEsperado = "a1B2c3D4e5F6g7H8i9J0k9L8m7N6o5P4q3R2s1TuVwXyZ"
		lcValorRetornado = loLibrerias.InvertirMayusculasMinusculas( lcParametro )
		This.assertequals( "No se deben invertir los símbolos.", lcValorEsperado, lcValorRetornado )
		
		lcParametro = " aaaa     "
		lcValorEsperado = " AAAA"
		lcValorRetornado = loLibrerias.InvertirMayusculasMinusculas( lcParametro, .T. )
		This.assertequals( "No deberia de haber sacado el espacio inicial.", lcValorEsperado, lcValorRetornado )
		
		lcParametro = " AAAA     "
		lcValorEsperado = " aaaa"
		lcValorRetornado = loLibrerias.InvertirMayusculasMinusculas( lcParametro, .T. )
		This.assertequals( "No deberia de haber sacado el espacio inicial.", lcValorEsperado, lcValorRetornado )


		
	endfunc
		*-----------------------------------------------------------------------------------------
	function ztestContenidoZip
		local lcFile as String, loColFiles as Collection, loLibreria as Object
		loLibreria = _screen.zoo.crearobjeto( "Librerias", "Librerias.prg" )
		lcFile = addbs( _Screen.zoo.cRutaInicial ) + "ClasesDePrueba\aart-252.zip"
		loColFiles = loLibreria.ContenidoZip( lcFile )
		This.AssertEquals( "No es correcta la cantidad de archivos", 1, loColFiles.Count )
		This.AssertEquals( "No es correcto el Archivo  0", "AART-252.DBF", upper( loColFiles.Item[0].FileName ) )
		loLibreria.Release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ztestU_ValorStringSegunTipoDato_Numerico
	local loLibrerias as Object, lnValor as Integer
	
		loLibrerias = _screen.zoo.crearobjeto( "Librerias", "Librerias.prg" )
		
		lnValor = loLibrerias.ValorStringSegunDato( "1", "N" )  

		this.Assertequals( "No Convirtio", 1, lnValor  )
		
		loLibrerias.release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ztestU_ValorStringSegunTipoDato_Fecha
	local loLibrerias as Object, ldValor as date, ldFecha as date

		loLibrerias = _screen.zoo.crearobjeto( "Librerias", "Librerias.prg" )
		
		ldFecha = date()
		ldValor = loLibrerias.ValorStringSegunDato( dtoc( ldFecha ), "D" )  

		this.Assertequals( "No Convirtio", ldFecha, ldValor  )
		
		loLibrerias.release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ztestU_ValorStringSegunTipoDato_Logico
	local loLibrerias as Object, llValor as Boolean
	
		loLibrerias = _screen.zoo.crearobjeto( "Librerias", "Librerias.prg" )
		
		llValor = loLibrerias.ValorStringSegunDato( ".T.", "L" )  

		this.Assertequals( "No Convirtio", .T., llValor )
		
		loLibrerias.release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ztestU_ValorStringSegunTipoDato_DateTime
	local loLibrerias as Object, llValor as Boolean
	
		loLibrerias = _screen.zoo.crearobjeto( "Librerias", "Librerias.prg" )
		
		ldFecha = date()
		ldValor = loLibrerias.ValorStringSegunDato( dtoc( ldFecha ), "T" )  

		this.Assertequals( "No Convirtio", ldFecha, ldValor  )
		
		loLibrerias.release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ztestU_ValorStringSegunTipoDato_Indefinido
	local loLibrerias as Object, lcValor as String
	
		loLibrerias = _screen.zoo.crearobjeto( "Librerias", "Librerias.prg" )
		
		lcValor = loLibrerias.ValorStringSegunDato( "1", "X" )  

		this.Assertequals( "No Convirtio", "1", lcValor )
		
		loLibrerias.release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestU_ObtenerFormatoFechaSegunParametros
	local loLibrerias as Object, lcValor as String
	
		loLibrerias = _screen.zoo.crearobjeto( "Librerias", "Librerias.prg" )
		
		goParametros.Dibujante.FormatoParaFecha = 1
		lcValor = loLibrerias.ObtenerMascaraFecha()  

		This.Assertequals( "La mascara no es la correcta", "99/99/99", lcValor )
		
		loLibrerias.release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ztestU_NumeroALetras
		local loLibrerias as librerias of librerias.prg, lcValor as String

		loLibrerias = _screen.zoo.crearobjeto( "Librerias", "Librerias.prg" )

		lcValor = loLibrerias.Numeroaletras( 580.43, .F. )
		This.Assertequals( "El número pasado a letras no es correcto (1).", "Quinientos ochenta con 43/100.-", lcValor )

		lcValor = loLibrerias.Numeroaletras( 125.47, .T. )
		This.Assertequals( "El número pasado a letras no es correcto (2).", "Ciento veinticinco", lcValor )

		loLibrerias.release()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function zTestU_ValidarCadenaConSoloNumeros 
		local loLibrerias as librerias of librerias.prg, llRetorno as Boolean

		loLibrerias = _screen.zoo.crearobjeto( "Librerias", "Librerias.prg" )

		llRetorno = loLibrerias.CadenaConSoloNumeros( "R4T5" )
		
		This.asserttrue( "La cadena no contiene solo números.", !llRetorno ) 

		llRetorno = loLibrerias.CadenaConSoloNumeros( "4654" )
		
		This.asserttrue( "La cadena deberia contener solo números.", llRetorno ) 

		llRetorno = loLibrerias.CadenaConSoloNumeros( "4654d" )
		
		This.asserttrue( "La cadena no contiene solo números. 4654d", !llRetorno ) 

		loLibrerias.release()

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function zTestU_ReemplazarCodigosAsciiParaArmarExpresionesTipoString
		local loLibrerias as librerias of librerias.prg, lcRetorno as String

		loLibrerias = _screen.zoo.crearobjeto( "Librerias", "Librerias.prg" )

		lcRetorno = loLibrerias.ReemplazarCodigosAsciiParaArmarExpresionesTipoString( "DeberiaSerValido" )
		This.AssertEquals( "Error. La cadena contiene codigo asciis validos.", "DeberiaSerValido", lcRetorno ) 

		lcRetorno = loLibrerias.ReemplazarCodigosAsciiParaArmarExpresionesTipoString( "" )
		This.AssertEquals( "Error. La cadena esta vacia.", "", lcRetorno ) 

		lcRetorno = loLibrerias.ReemplazarCodigosAsciiParaArmarExpresionesTipoString( "Re'emplaza" )
		This.AssertEquals( "Error. La cadena contiene codigo asciis invalidos(1).", "Reemplaza", lcRetorno ) 

		this.AddProperty( "lPermiteCaracteresComilla", .T. )
		lcRetorno = loLibrerias.ReemplazarCodigosAsciiParaArmarExpresionesTipoString( 'Reempla"za', this )
		This.AssertEquals( 'Error. La cadena contiene codigo asciis invalidos(2).', 'Reempla"za', lcRetorno ) 

		this.lPermiteCaracteresComilla = .F.
		lcRetorno = loLibrerias.ReemplazarCodigosAsciiParaArmarExpresionesTipoString( 'Reempla"za', this )
		This.AssertEquals( "Error. La cadena contiene codigo asciis invalidos(2 bis).", "Reemplaza", lcRetorno ) 

		lcRetorno = loLibrerias.ReemplazarCodigosAsciiParaArmarExpresionesTipoString( "[Reemplaza" )
		This.AssertEquals( "Error. La cadena contiene codigo asciis invalidos(3).", "Reemplaza", lcRetorno ) 

		lcRetorno = loLibrerias.ReemplazarCodigosAsciiParaArmarExpresionesTipoString( "Reemplaza]" )
		This.AssertEquals( "Error. La cadena contiene codigo asciis invalidos(4).", "Reemplaza", lcRetorno ) 

		loLibrerias.release()

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function zTestU_RepararTablas
		local loLibrerias as librerias of librerias.prg, llRetorno as Boolean, ;
			loMemoria as din_entidadMemoria of din_entidadMemoria.prg, lcTablaMala as String, ;
			loManejoAchivo as ManejosArchivos of ManejoArchivos.Prg
		
		loMemoria = _screen.zoo.InstanciarEntidad( "Memoria" )
		lcRutaDbf = loMemoria.oAd.ObtenerRutaTabla()
		loMemoria.oAd.Release()
		
		lcTablaMala = addbs( _Screen.zoo.cRutaInicial ) + "ClasesDePrueba\mem_xml.dbf"
		copy file &lcTablaMala to lcRutaDbf + "mem_xml.dbf"

		loManejoAchivo = Newobject( "ManejoArchivos","ManejoArchivos.prg" )
		loManejoAchivo.SetearAtributos( "N", lcRutaDbf + "mem_xml.dbf" )
		loManejoAchivo.Destroy()
		loManejoAchivo = null

		loLibrerias = _screen.zoo.crearobjeto( "Librerias", "Librerias.prg" )
		llRetorno = loLibrerias.RepararTabla( lcRutaDbf , "mem_xml.dbf" )
		loLibrerias.release()

		This.asserttrue( "No pudo reparar la tabla memoria_xml", llRetorno )

		loMemoria = _screen.zoo.InstanciarEntidad( "Memoria" )
		with loMemoria as din_entidadMemoria of din_entidadMemoria.prg
			.Nuevo()
			.Usuario = "USER1"
			.Tipo = upper( right( sys( 2015 ), 9 ) )
			.xml = replicate( sys( 2015 ), 15 )
			try
				.Grabar()
			catch to loError
				this.assertequals( "Numero de error incorrecto.",0 ,loError.UserValue.ErrorNo )
				this.asserttrue( "No deberia pinchar por estar corrupta", .f. )
			endtry
		endwith
		loMemoria.Release()

	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestU_ObtenerUltimoDiaDelMes
		local loLibrerias as librerias of librerias.prg, ldFecha as Date
		
		loLibrerias = _screen.zoo.crearobjeto( "Librerias" )
		
		ldFecha = loLibrerias.ObtenerUltimoDiaDelMes( date( 2014,06,16 ) )
		 
		this.assertequals( "Último día del mes incorrecto", date(2014,06,30), ldFecha  )
		loLibrerias.release()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function zTestU_ObtenerFechaFormato_ddMMyy
		local loLibrerias as librerias of librerias.prg, lcFecha as String
		
		loLibrerias = _screen.zoo.crearobjeto( "Librerias" )
		lcFecha = loLibrerias.ConvertirFechaACaracterConFormato( date(2014,06,16), "ddMMyy" ) 

		this.assertequals( "Fecha con formato incorrecto.","160614",lcFecha )
				
		loLibrerias.release()

	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestU_SepararEnSegmentos
		local loLibrerias as librerias of librerias.prg, lcTexto as String, lcTextoSeparado as String, lcSeparador as String, tcAncho as Integer
				
		lcTexto = '12345KFE356945FF'
		tcAncho = 4
		lcSeparador = '-'
		
		loLibrerias = _screen.zoo.crearobjeto( "Librerias" )
		lcTextoSeparado = loLibrerias.SepararEnSegmentos( lcTexto, tcAncho, lcSeparador  )
		
		this.assertequals( "Separación en segmentos incorrecta.", "1234-5KFE-3569-45FF", lcTextoSeparado )
				
		loLibrerias.release()

	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestU_ConvierteABase32ConSimbolosValidos
		local loLibrerias as librerias of librerias.prg, lcTexto as String, lcSimbolos as String, lcTextoConvertido  as String
		
		lcTexto = '65081505141234651552695'
		lcSimbolos = '0123456789ABCDEFGHJKMNPQRSTVWXYZ'
		
		loLibrerias = _screen.zoo.crearobjeto( "Librerias" )
		lcTextoConvertido = loLibrerias.ConvierteABase32( lcTexto , lcSimbolos ) 
		
		this.assertequals( "Conversión a base32 incorrecta.","1Q416MCDBH515PXQ", lcTextoConvertido )
				
		loLibrerias.release()

	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestU_ConvierteABase32ConSimbolosInvalidos
		local loLibrerias as librerias of librerias.prg, lcTexto as String, lcSimbolos as String, lcTextoConvertido  as String
		
		lcTexto = '65081505141234651552695'
		lcSimbolos = 'ABCDEFGHJKMNPQRSTVWXUI'
		
		loLibrerias = _screen.zoo.crearobjeto( "Librerias" )
		lcTextoConvertido = loLibrerias.ConvierteABase32( lcTexto , lcSimbolos ) 
		
		this.assertequals( "Conversión a base32 incorrecta.","", lcTextoConvertido )
			
		loLibrerias.release()

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function zTestU_ConvierteABase32ConDecimales
		local loLibrerias as librerias of librerias.prg, lcTexto as String, lcSimbolos as String, lcTextoConvertido  as String
		
		lcTexto = '65081505141234651552695,2'
		lcSimbolos = '0123456789ABCDEFGHJKMNPQRSTVWXYZ'
		
		loLibrerias = _screen.zoo.crearobjeto( "Librerias" )
		lcTextoConvertido = loLibrerias.ConvierteABase32( lcTexto , lcSimbolos ) 
		
		this.assertequals( "Conversión a base32 incorrecta.","", lcTextoConvertido )
				
		loLibrerias.release()

	endfunc 

	*-----------------------------------------------------------------------------------------
	Function zTestU_DigitoVerificadorDeLuhnConEnteros
		local loLibrerias as librerias of librerias.prg, lcTexto as String, lcDigitoVerificador as String
		
		lcTexto = '7992739871'
		
		loLibrerias = _screen.zoo.crearobjeto( "Librerias" )
		lcDigitoVerificador = loLibrerias.DigitoVerificadorDeLuhn( lcTexto ) 

		this.assertequals( "Digito verificador de Luhn Invalido.", 3, lcDigitoVerificador )
				
		loLibrerias.release()

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function zTestU_DigitoVerificadorDeLuhnConDecimales
		local loLibrerias as librerias of librerias.prg, lcTexto as String, lcDigitoVerificador as String
		
		lcTexto = '7992739871,2'
		
		loLibrerias = _screen.zoo.crearobjeto( "Librerias" )
		lcDigitoVerificador = loLibrerias.DigitoVerificadorDeLuhn( lcTexto ) 

		this.assertequals( "Digito verificador de Luhn Invalido.", 0, lcDigitoVerificador )
				
		loLibrerias.release()

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestU_Comprimir
		local loLibrerias as librerias of librerias.prg, loColArchivos as zoocoleccion of zoocoleccion.prg
		
		_screen.mocks.agregarmock( "Compresor" )
		loLibrerias = _screen.zoo.crearobjeto( "Librerias" )
		loColArchivos = _screen.zoo.crearobjeto( "zoocoleccion" )
		loColArchivos.Add( "Archivo1" )

		_screen.mocks.AgregarSeteoMetodo( 'COMPRESOR', 'Comprimir', .T., "[" + _screen.zoo.cRutaInicial + "Archivo.Zip],'*OBJETO',[PEPE],.T.,.T." ) && ztestlibrerias.ztestu_comprimir 23/12/14 10:11:51

		loLibrerias.Comprimir( _screen.zoo.cRutaInicial + "Archivo", loColArchivos , "PEPE", .t., .t. )
		
		_screen.mocks.verificarejecuciondemocksunaclase( "Compresor" )
		loLibrerias.release()

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestU_DesComprimir
		local loLibrerias as librerias of librerias.prg, loColArchivos as zoocoleccion of zoocoleccion.prg
		
		_screen.mocks.agregarmock( "Compresor" )
		_screen.mocks.AgregarSeteoMetodo( 'COMPRESOR', 'Descomprimir', .T., "[Archivo1.zip],[PASSWORD],[" + _screen.zoo.crutaInicial + "]" )

		loLibrerias = _screen.zoo.crearobjeto( "Librerias" )

		loLibrerias.Descomprimir( "Archivo1.zip", _screen.zoo.crutaInicial, "PASSWORD" )
		
		_screen.mocks.verificarejecuciondemocksunaclase( "Compresor" )
		loLibrerias.release()

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestObtenerLetrasYNumerosValidos 
		local lcEsperado as String, lcObtenido as String, loLibreria as Object, ;
				llIncluyeMinusculas as Boolean, lcNumeros as String, lcLetras as String
		
		loLibreria = _screen.zoo.crearobjeto( "Librerias", "Librerias.prg" )

		lcNumeros = alltrim( goRegistry.Nucleo.CadenaDeNumerosValidos )
		lcLetras = alltrim( goRegistry.Nucleo.CadenaDeLetrasValidas )
		
		lcEsperado = lcNumeros + upper( lcLetras ) + lower( lcLetras )+ " ."
		llIncluyeMinusculas = .t.
		lcObtenido = loLibreria.ObtenerLetrasYNumerosValidos( llIncluyeMinusculas )
		
		This.assertequals( "No es correcta la cadena de caracteres(Incluye Minusculas).", lcEsperado, alltrim( lcObtenido ) )

		lcEsperado = lcNumeros + upper( lcLetras ) + " ."
		llIncluyeMinusculas = .f.
		lcObtenido = loLibreria.ObtenerLetrasYNumerosValidos( llIncluyeMinusculas )
		
		This.assertequals( "No es correcta la cadena de caracteres(NO Incluye Minusculas).", lcEsperado, alltrim( lcObtenido ) )

		loLibreria.Release()
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestI_EjecutarEditorDeTextoPlano
		local loEx as Exception, lcEjecutableEditor as String, loFSWatcher as Object, lcArchivoAEditar as String, ;
			loSuscriptor1 as Object, loSuscriptor2 as Object, loProcesoEditor as Object
			
		lcEjecutableEditor = upper( addbs( _screen.Zoo.cRutaInicial ) + "Componentes\NPP\notepad++.exe" )
		loFSWatcher = null
		loProcesoEditor = null
		if ( !file( lcEjecutableEditor ) )
			if !directory( justpath( lcEjecutableEditor ) )
				md ( justpath( lcEjecutableEditor ) )
			endif
			copy file ( addbs( _screen.Zoo.cRutaInicial ) + "ClasesDePrueba\NotepadPPFake.exe" ) to ( lcEjecutableEditor )
		endif
		lcArchivoAEditar = addbs( _screen.Zoo.ObtenerRutaTemporal() ) + forceext( sys( 2015 ), "txt" )
		loSuscriptor1 = newobject( "SuscriptorACambioDeArchivo" )
		loSuscriptor2 = newobject( "SuscriptorACambioDeArchivo" )
		try
			strtofile( "Crear archivo", lcArchivoAEditar )
			loFSWatcher = goServicios.Librerias.EjecutarEditorDeTextoPlano( lcArchivoAEditar, loSuscriptor1, "RegistrarCambioDeArchivo" )
			loProcesoEditor = goServicios.Ejecucion.oColProcesosEjecutados.Item[ goServicios.Ejecucion.oColProcesosEjecutados.Count ]
			inkey( 6, "H" )
			this.AssertTrue( "El editor no se ejecuto correctamente.", upper( loProcesoEditor.Archivo ) == lcEjecutableEditor )
			this.AssertTrue( "Debería existir el archivo a editar.", file( lcArchivoAEditar ) )
			strtofile( "Modificar archivo 1", lcArchivoAEditar )
			this.AssertEquals( "El suscriptor 1 debería haber registrado 1 cambio de archivo.", 1, loSuscriptor1.nCambioElArchivo )
			this.AssertEquals( "El suscriptor 2 no debería haber registrado cambio de archivo.", 0, loSuscriptor2.nCambioElArchivo )
			loFSWatcher.SuscribirACambios( loSuscriptor1, "RegistrarCambioDeArchivo" )
			loFSWatcher.SuscribirACambios( loSuscriptor2, "RegistrarCambioDeArchivo" )
			strtofile( "Modificar archivo 2", lcArchivoAEditar )
			inkey( 2, "H" )
			this.AssertEquals( "El suscriptor 1 debería haber registrado 3 cambios de archivo.", 3, loSuscriptor1.nCambioElArchivo )
			this.AssertEquals( "El suscriptor debería haber registrado 1 cambio de archivo.", 1, loSuscriptor2.nCambioElArchivo )
			loFSWatcher.DesuscribirACambios( loSuscriptor1, .f. )
			strtofile( "Modificar archivo 3", lcArchivoAEditar )
			inkey( 2, "H" )
			this.AssertEquals( "El suscriptor 1 debería haber registrado 4 cambios de archivo (1).", 4, loSuscriptor1.nCambioElArchivo )
			this.AssertEquals( "El suscriptor 2 debería haber registrado 2 cambios de archivo (1).", 2, loSuscriptor2.nCambioElArchivo )
			loFSWatcher.DesuscribirTodosACambios()
			strtofile( "Modificar archivo 4", lcArchivoAEditar )
			inkey( 2, "H" )
			this.AssertEquals( "El suscriptor 1 debería haber registrado 4 cambios de archivo (2).", 4, loSuscriptor1.nCambioElArchivo )
			this.AssertEquals( "El suscriptor 2 debería haber registrado 2 cambios de archivo (2).", 2, loSuscriptor2.nCambioElArchivo )
		catch to loEx
		finally
			if !isnull( loFSWatcher )
				loFSWatcher.DesuscribirTodosACambios()
			endif
			goServicios.Ejecucion.oCreadorDeProcesos.MatarProceso( loProcesoEditor.Handle )
		endtry
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestU_ObtenerIdentificadorGlobal
		local loLibrerias as Object, lcId as String, lcParteAAAAMMDDHHMMSS as String, lcParteAlfaNumerica as String, i as Integer, ;
			lcChar as String, lcParteAAAAMMDDHHMMSSAnterior as String
		loLibrerias = _screen.Zoo.CrearObjeto( "Librerias" )
		lcId = loLibrerias.ObtenerIdentificadorGlobal()
		this.AssertEquals( "La definicion de la longitud de los Ids globales no es correcta", 20, loLibrerias.ObtenerLongitudMaximaDeIdentificadorGlobal() )
		this.AssertEquals( "La longitud del Id no es correcta", loLibrerias.ObtenerLongitudMaximaDeIdentificadorGlobal(), len( lcId ) )
		
		lcParteAAAAMMDDHHMMSS = substr( lcId, 1, 14 )
		goServicios.Datos.EjecutarSentencias( "SELECT convert( datetime,stuff( stuff( stuff( '" + lcParteAAAAMMDDHHMMSS + "', 9, 0, ' '), 12, 0, ':' ), 15, 0, ':') ) AS DateTime", "", "", "c_DateTimeEnId", set( "Datasession" ) )
		goServicios.Datos.EjecutarSentencias( "SELECT getdate() AS DateTime", "", "", "c_DateTimeTest", set( "Datasession" ) )
		this.AssertTrue( "La parte AÑO MES DIA HORA MINUTO SEGUNDO no es correcta.",  type( "c_DateTimeEnId.DateTime" ) == "T" and c_DateTimeEnId.DateTime <= c_DateTimeTest.DateTime )
		
		lcParteAlfaNumerica = substr( lcId, 16 )
		for i = 1 to len( lcParteAlfaNumerica )
			lcChar = substr( lcParteAlfaNumerica, i, 1 )
			this.AssertTrue( "La parte AlfaNumerico del Id posee caracteres no válidos.", isalpha( lcChar ) or isdigit( lcChar ) )
		endfor
		
		lcParteAAAAMMDDHHMMSSAnterior = substr( loLibrerias.ObtenerIdentificadorGlobal(), 1, 14 )
		for i = 1 to 100
			lcParteAAAAMMDDHHMMSS = substr( loLibrerias.ObtenerIdentificadorGlobal(), 1, 14 )
			this.AssertTrue( "La parte AÑO MES DIA HORA MINUTO SEGUNDO debería ser mayor o igual a la del Id anterior (No se respeta la cualidad necesaria para realizar ordenamientos cronológicos)", lcParteAAAAMMDDHHMMSS >= lcParteAAAAMMDDHHMMSSAnterior )
			lcParteAAAAMMDDHHMMSSAnterior = lcParteAAAAMMDDHHMMSS
		endfor
		
		use in select( "c_DateTimeEnId" )
		use in select( "c_DateTimeTest" )
		loLibrerias = null
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestValidarCuit
		with goLibrerias
			this.asserttrue( "El CUIT con espacios al final no debería ser válido", ! .ValidarCuit( '66999999995          ' ) )
			
			this.asserttrue( "El CUIT no debería ser válido", ! .ValidarCuit( '66999999995' ) )
			
			this.asserttrue( "El CUIT con guiones no debería ser válido", ! .ValidarCuit( '66-99999999-5' ) )
			
			this.asserttrue( "El CUIT con espacios al final debería ser válido", .ValidarCuit( '20137822661          ' ) )
			
			this.asserttrue( "El CUIT debería ser válido", .ValidarCuit( '20137822661' ) )
			
			this.asserttrue( "El CUIT con guiones debería ser válido", .ValidarCuit( '20-13782266-1' ) )
		endwith 		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestObtenerDatosDeIniUTF8
		local lcArchivo as String , lcContenidoIni as String , lcRetorno as String

		lcArchivo = addbs( _screen.zoo.cruTAINICIAL ) + "clasesdeprueba\dataconfigUTF8.ini"
		loLibreria = _screen.zoo.crearobjeto( "Librerias", "Librerias.prg" )

		lcRetorno  = loLibreria.ObtenerDatosDeIniTextoPlano( lcArchivo, "DATOS", "TIPOBASE" )
		This.assertequals( "No se obtuvo el valor correcto para la entrada 'Tipo de base'", "SQLSERVER" , upper( alltrim( lcRetorno ) ) ) 

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestObtenerDatosDeIniUTF8InstanciaVacia
		local lcArchivo as String , lcContenidoIni as String , lcRetorno as String

		lcArchivo = addbs( _screen.zoo.cruTAINICIAL ) + "clasesdeprueba\dataconfigUTF8InstanciaVacia.ini"
		loLibreria = _screen.zoo.crearobjeto( "Librerias", "Librerias.prg" )

		lcRetorno  = loLibreria.ObtenerDatosDeIniTextoPlano( lcArchivo, "DATOS", "TIPOBASE" )
		This.assertequals( "No se obtuvo el valor correcto para la entrada 'Tipo de base'", "", upper( alltrim( lcRetorno ) ) ) 

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTest_ValidarRUTUruguay() 
		local loLibrerias  as Object
	
		loLibrerias = _screen.zoo.crearobjeto( "Librerias" )

		with loLibrerias
			this.asserttrue( "El RUT es incorrecto.1/6", !.ValidarRutUruguay( '1234567891-2' ) )	
			this.asserttrue( "El RUT es incorrecto.2/6", !.ValidarRutUruguay( '' ) )
			this.asserttrue( "El RUT es incorrecto.3/6", !.ValidarRutUruguay( '123456789' ) )	
			this.asserttrue( "El RUT es incorrecto.4/6", !.ValidarRutUruguay( '10084731001-5' ) )
			this.asserttrue( "El RUT es incorrecto.5/6", !.ValidarRutUruguay( '100847310018' ) )
			this.asserttrue( "El RUT es correcto.6/6", .ValidarRutUruguay( '100847310015' ) )
		endwith
		
	endfunc 




enddefine

*-----------------------------------------------------------------------------------------
define class SuscriptorACambioDeArchivo as custom
	nCambioElArchivo = 0

	*-----------------------------------------------------------------------------------------
	function RegistrarCambioDeArchivo( toSender as Object, toArgs as Object  ) as Void
		this.nCambioElArchivo = this.nCambioElArchivo + 1
	endfunc

enddefine

define class AuxMensaje as Custom
	cMensaje = ""
	oInformacion = Null
	*-----------------------------------------------------------------------------------------
	function Informar( toInfo as Object ) as Void
		This.oInformacion = toInfo 
	endfunc 
	*-----------------------------------------------------------------------------------------
	function EnviarSinEspera( tcVar as String ) as Void
		This.cMensaje = This.cMensaje + tcVar
	endfunc 
enddefine


*-----------------------------------------------------------------------------------------
function CrearXMLVersion( tcArchivo as String, tnModulos as Integer ) as Void
	local lcUrl as String
	lcUrl = addbs( _Screen.zoo.cRutaInicial ) + "ClasesDePrueba\"
	delete file addbs( _Screen.zoo.obtenerRutaTemporal() ) + "Versiones.Xml"
	do case
		case tnModulos = 1
			text to lcVariable textmerge
<?xml version = "1.0" encoding="Windows-1252" standalone="yes"?>
<root>
	<versiones>
		<Modulo>TestNucleo</Modulo>
		<Version>0.1.3</Version>
		<Archivo>modulo1_Version_0101.exe</Archivo>
		<ArchivoDescarga><<tcArchivo>></ArchivoDescarga>
		<URL><<lcUrl>></URL>
	</versiones>
</root>
			endtext
		case tnModulos = 2
			text to lcVariable textmerge
<?xml version = "1.0" encoding="Windows-1252" standalone="yes"?>
<root>
	<versiones>
		<Modulo>TestNucleo1</Modulo>
		<Version>0.1.3</Version>
		<Archivo>modulo1_Version_0101.exe</Archivo>
		<ArchivoDescarga><<tcArchivo>></ArchivoDescarga>
		<URL><<lcUrl>></URL>
	</versiones>
	<versiones>
		<Modulo>TestNucleo2</Modulo>
		<Version>0.1.3</Version>
		<Archivo>modulo1_Version_0101.exe</Archivo>
		<ArchivoDescarga><<tcArchivo>></ArchivoDescarga>
		<URL><<lcUrl>></URL>
	</versiones>	
</root>
			endtext
		case tnModulos = 3
			text to lcVariable textmerge
<?xml version = "1.0" encoding="Windows-1252" standalone="yes"?>
<root>
	<versiones>
		<Modulo>TestNucleo1</Modulo>
		<Version>0.1.3</Version>
		<Archivo>modulo1_Version_0101.exe</Archivo>
		<ArchivoDescarga>modulo1_Version_0103.exe</ArchivoDescarga>
		<URL><<lcUrl>></URL>
	</versiones>
	<versiones>
		<Modulo>TestNucleo2</Modulo>
		<Version>0.1.3</Version>
		<Archivo>modulo1_Version_0101.exe</Archivo>
		<ArchivoDescarga><<tcArchivo>></ArchivoDescarga>
		<URL><<lcUrl>></URL>
	</versiones>	
</root>
			endtext
	EndCase
	strtofile( lcVariable, addbs( _Screen.zoo.obtenerRutaTemporal() ) + "Versiones.Xml" )
endfunc 
