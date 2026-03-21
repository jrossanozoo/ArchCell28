**********************************************************************
Define Class zTestCorreccionOrtografia as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as zTestCorreccionOrtografia of zTestCorreccionOrtografia.prg
	#ENDIF
	
	*---------------------------------
	Function Setup

	EndFunc
	
	*-----------------------------------
	function zTestValidarOrtografia
	
		local lcTexto as String, llRetorno as Boolean, loCorrector as correccionortografia of correccionortografia.prg

		loCorrector = newobject("correccionortografia","correccionortografia.prg")
		this.asserttrue("No se ha instanciado el Corrector",vartype(loCorrector) = "O")

		lcTexto = "Juan va al cine"
		llRetorno = loCorrector.Validarortografia( lcTexto)
		
		this.asserttrue("Validación ortográfica incorrecta",llRetorno)
		
		lcTexto = "Juan va al zigne"
		llRetorno = loCorrector.Validarortografia( lcTexto)
		this.asserttrue("Validación ortográfica incorrecta",!llRetorno)		

	endfunc
	*---------------------------------
		function zTestValidarGramatica
	
		local lcTexto as String, llRetorno as Boolean, loCorrector as correccionortografia of correccionortografia.prg

		loCorrector = newobject("correccionortografia","correccionortografia.prg")
		this.asserttrue("No se ha instanciado el Corrector",vartype(loCorrector) = "O")

		lcTexto = "El perro está enfermo"
		llRetorno = loCorrector.ValidarGramatica( lcTexto)
		
		this.asserttrue("Validación gramática incorrecta",llRetorno)
		
		lcTexto = "La perro está enfermo"
		llRetorno = loCorrector.ValidarGramatica( lcTexto)
		this.asserttrue("Validación gramática incorrecta",!llRetorno)		

	endfunc

	*---------------------------------
	Function TearDown

	EndFunc

EndDefine
