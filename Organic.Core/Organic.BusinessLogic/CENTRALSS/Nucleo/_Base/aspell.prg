define class Aspell as Custom

	#IF .f.
		Local this as Aspell of Aspell.prg
	#ENDIF

	cLang = "es"
	lAspellInicializado = .f.
	nAspellChecker = 0
	nAspellConfig = 0
	cAspellVersion = ""
	cAspellPath = ""
	cAspellDll = ""

	*-----------------------------------------------------------------------------------------
	function Init() as Void
	endfunc

	*-----------------------------------------------------------------------------------------
	function iniciar() as boolean
		local lnAspellPossibleError as Integer, loWshShell as WScript.Shell

		this.cAspellDll = _screen.Zoo.cRutaInicial + "..\Taspein\Aspell\Bin\aspell-15.dll"
	
		*----- Comprobando que exista la libreria
		if file( this.cAspellDll )

			*----- Registrando las funciones de la libreria
			declare integer new_aspell_config in (this.cAspellDll)
			declare integer aspell_config_replace in (this.cAspellDll) integer, string, string
			declare integer new_aspell_speller in (this.cAspellDll) integer
			declare integer aspell_error_number in (this.cAspellDll) integer
			declare integer to_aspell_speller in (this.cAspellDll) integer
			declare integer aspell_speller_check in (this.cAspellDll) integer, string, integer
			declare integer aspell_speller_suggest in (this.cAspellDll) integer, string, integer
			declare integer aspell_word_list_elements in (this.cAspellDll) integer
			declare integer delete_aspell_string_manag in (this.cAspellDll) integer
			declare integer delete_aspell_speller in (this.cAspellDll) integer
			declare integer aspell_speller_add_to_session in (this.cAspellDll) integer, string, integer 
			declare integer aspell_speller_add_to_personal in (this.cAspellDll) integer, string, integer 
			declare integer aspell_speller_save_all_word_lists in (this.cAspellDll) integer
			declare string  aspell_string_enumeration_next in (this.cAspellDll) integer
			declare string  aspell_error_message in (this.cAspellDll) integer
			
			*----- Iniciadno la configuración
			this.nAspellConfig = new_aspell_config()
			
			aspell_config_replace( this.nAspellConfig, "dict-dir", _screen.Zoo.cRutaInicial + "..\Taspein\Aspell")	&& location of the main word list (diccionario principal de palabras)
			aspell_config_replace( this.nAspellConfig, "home-dir", _screen.Zoo.cRutaInicial + "..\Taspein\Aspell")	&& location for personal files (diccionario con palabras agregadas)
			aspell_config_replace( this.nAspellConfig, "ignore-case", "true") 										&& ignore case when checking words

			if aspell_config_replace( this.nAspellConfig, "lang", this.cLang) == 01
				
				*----- Instanciando la corrección
				lnAspellPossibleError = new_aspell_speller( this.nAspellConfig )
				this.nAspellChecker = 0

				if aspell_error_number( lnAspellPossibleError ) != 0
					*=MESSAGEBOX(aspell_error_message(lnAspellPossibleError),0+16+256+4096,"Aspell")
				else
					this.nAspellChecker = to_aspell_speller( lnAspellPossibleError )
					this.lAspellInicializado = iif( this.nAspellChecker > 0, .t., .f. )
				endif
			else
				*=MESSAGEBOX("Imposible iniciar la libreria Aspell",0+16+256+4096,"Aspell")
			endif 
		else
			*=MESSAGEBOX("No se encontro la dll "+.cAspellDll+". Descarguelo desde el sitio web de " + "Aspell para Windows http://aspell.net/win32",0+16+256+4096,"Aspell")
		endif

		return this.lAspellInicializado 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Corregir( tcPalabra ) as string
		local lcPalabra as String, lcSugerencias as String, lnPalabra as Integer, lnAspellSuggestions as Integer, lnAspellElements as Integer

		lcPalabra = ""
		lcSugerencias = ""
		lnAspellSuggestions = 0
		lnAspellElements = 0

		if this.lAspellInicializado
			lnPalabra = len( tcPalabra )

			if aspell_speller_check( this.nAspellChecker, tcPalabra, lnPalabra ) == 0
				lnAspellSuggestions = aspell_speller_suggest( this.nAspellChecker, tcPalabra, lnPalabra )
				lnAspellElements = aspell_word_list_elements( lnAspellSuggestions )
				lcPalabra = ''

				do while !isnull( lcPalabra )
					try
						lcPalabra = aspell_string_enumeration_next( lnAspellElements )
						lcSugerencias = lcSugerencias + iif( empty( lcSugerencias ), '', ',') + lcPalabra
					catch to loError
						lcPalabra = null
					endtry
				enddo
			endif
		else
			*=MESSAGEBOX("La libreria Aspell no se encuenra inicializada",0+16+256+4096,"Error Aspell")
		endif

		return lcSugerencias
	endfunc

	*-----------------------------------------------------------------------------------------
	* Esto agrega palabras al diccionario personal (no es el mismo que el principal). El archivo suele tener extensión "pws".
	*-----------------------------------------------------------------------------------------
	function AgregarPalabra( tcPalabra ) as Void
		local lnAncho, lnResultado
		tcPalabra = alltrim( tcPalabra )

		if !empty( tcPalabra )
			lnAncho = len( tcPalabra )

			lnResultado = aspell_speller_add_to_personal( this.nAspellChecker, tcPalabra, lnAncho )

			if lnResultado == 1
				aspell_speller_save_all_word_lists( this.nAspellChecker )
			else
				=MESSAGEBOX( "No se pudo agregar la palabra.", 0+16+256+4096, "Aspell" )
			endif
		endif

		return lnResultado == 1
	endfunc

	*-----------------------------------------------------------------------------------------
	function Destroy() as Void
		clear dlls 	"new_aspell_config", "aspell_config_replace", "new_aspell_speller", "aspell_error_number", "to_aspell_speller", ;
					"aspell_speller_check", "aspell_speller_suggest", "aspell_word_list_elements", "delete_aspell_string_manag", "delete_aspell_speller", ;
					"aspell_speller_add_to_session", "aspell_speller_add_to_personal", "aspell_speller_save_all_word_lists", "aspell_string_enumeration_next", ;
					"aspell_error_message"
	endfunc 
enddefine