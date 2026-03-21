**********************************************************************
define class zTestU_ModelosControladoresFiscales as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		local this as zTestU_ModelosControladoresFiscales.prg
	#ENDIF
	
	oControladoresFiscales = null
	
	*---------------------------------
	function Setup
		this.oControladoresFiscales = _screen.zoo.CrearObjeto( 'ModelosControladoresFiscales' )
	endfunc
	
	*---------------------------------
	function TearDown
		this.oControladoresFiscales = null
	endfunc

	*---------------------------------
	function zTest_InicializaciónClaseModelosControladoresFiscales
		this.asserttrue( 'No se inicializó el objeto "oModelos"', vartype( this.oControladoresFiscales.oModelos ) = 'O' )
		this.assertequals( 'La colección "oModelos" no tiene la cantidad de ítems correcta', 19, this.oControladoresFiscales.oModelos.count ) 
	endfunc

	*---------------------------------
	function zTest_PropiedadesObjetoModelos
		with this.oControladoresFiscales.oModelos.Item(1)
			this.asserttrue( 'El objeto "oModelos" no contienen la propiedad numérica "nId"', vartype( .nId ) = 'N' )
			this.asserttrue( 'El objeto "oModelos" no contienen la propiedad caracter "cClase"', vartype( .cClase ) = 'C' )
			this.asserttrue( 'El objeto "oModelos" no contienen la propiedad caracter "cMarca"', vartype( .cMarca ) = 'C' )
			this.asserttrue( 'El objeto "oModelos" no contienen la propiedad caracter "cModelo"', vartype( .cModelo ) = 'C' )
			this.asserttrue( 'El objeto "oModelos" no contienen la propiedad caracter "cMarcaModelo"', vartype( .cMarcaModelo ) = 'C' )
			this.asserttrue( 'El objeto "oModelos" no contienen la propiedad boleana "lHabilitado"', vartype( .lHabilitado ) = 'L' )
		endwith
	endfunc


	*---------------------------------
	function zTest_ModeloNinguno
		with this.oControladoresFiscales.oModelos.Item(1)
			this.assertequals( 'Modelo NINGUNO: "nId" incorrecto', 0, .nId )
			this.assertequals( 'Modelo NINGUNO: "cClase" incorrecto', '', .cClase )
			this.assertequals( 'Modelo NINGUNO: "cMarca" incorrecto', '', .cMarca )
			this.assertequals( 'Modelo NINGUNO: "cModelo" incorrecto', 'NINGUNO', .cModelo )
			this.assertequals( 'Modelo NINGUNO: "cMarcaModelo" incorrecto', 'NINGUNO', .cMarcaModelo )
			this.assertequals( 'Modelo NINGUNO: "lHabilitado" incorrecto', .t., .lHabilitado )
		endwith
	endfunc

	*---------------------------------
	function zTest_ModeloEpsonTMU220AF
		local lnKey as integer
		lnKey = this.oControladoresFiscales.oModelos.GetKey( '24' )

		this.asserttrue( 'El ID 24 no existe en la colección', lnKey > 0 )
		with this.oControladoresFiscales.oModelos.Item( lnKey )
			this.assertequals( 'Modelo Epson TM-U220AF: "nId" incorrecto', 24, .nId )
			this.assertequals( 'Modelo Epson TM-U220AF: "cClase" incorrecto', 'ETMU220AF', .cClase )
			this.assertequals( 'Modelo Epson TM-U220AF: "cMarca" incorrecto', 'EPSON', .cMarca )
			this.assertequals( 'Modelo Epson TM-U220AF: "cModelo" incorrecto', 'TM-U220AF', .cModelo )
			this.assertequals( 'Modelo Epson TM-U220AF: "cMarcaModelo" incorrecto', 'EPSON TM-U220AF', .cMarcaModelo )
			this.assertequals( 'Modelo Epson TM-U220AF: "lHabilitado" incorrecto', .t., .lHabilitado )
		endwith
	endfunc

	*---------------------------------
	function zTest_ModeloHasarP715F
		local lnKey as integer
		lnKey = this.oControladoresFiscales.oModelos.GetKey( '10' )

		this.asserttrue( 'El ID 10 no existe en la colección', lnKey > 0 )
		with this.oControladoresFiscales.oModelos.Item( lnKey )
			this.assertequals( 'Modelo Hasar P-715F: "nId" incorrecto', 10, .nId )
			this.assertequals( 'Modelo Hasar P-715F: "cClase" incorrecto', 'HP715F', .cClase )
			this.assertequals( 'Modelo Hasar P-715F: "cMarca" incorrecto', 'HASAR', .cMarca )
			this.assertequals( 'Modelo Hasar P-715F: "cModelo" incorrecto', 'P-715F', .cModelo )
			this.assertequals( 'Modelo Hasar P-715F: "cMarcaModelo" incorrecto', 'HASAR P-715F', .cMarcaModelo )
			this.assertequals( 'Modelo Hasar P-715F: "lHabilitado" incorrecto', .t., .lHabilitado )
		endwith
	endfunc

	*---------------------------------
	function zTest_ModeloDeshabilitado
		local lnKey as integer
		lnKey = this.oControladoresFiscales.oModelos.GetKey( '7' )

		this.asserttrue( 'El ID 7 existe en la colección y es un modelo DESHABILITADO', lnKey = 0 )
	endfunc

enddefine
