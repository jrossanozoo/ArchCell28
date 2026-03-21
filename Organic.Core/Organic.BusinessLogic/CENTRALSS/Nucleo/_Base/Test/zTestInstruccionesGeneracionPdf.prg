**********************************************************************
Define Class zTestInstruccionesGeneracionPdf as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as zTestInstruccionesGeneracionPdf of zTestInstruccionesGeneracionPdf.prg
	#ENDIF
	
	*---------------------------------
	Function Setup

	EndFunc
	
	*---------------------------------
	Function TearDown

	EndFunc

	*-----------------------------------------------------------------------------------------
	function zTestObtenerSet
		local loInstrucciones as InstruccionesGeneracionPdf of InstruccionesGeneracionPdf.prg, ;
		loSetInstrucciones as zoocoleccion OF zoocoleccion.prg

		loParametrosColeccion = _screen.zoo.crearobjeto( "ParametrosInstruccionesGeneracionPdf" )
		loEntidad = _screen.zoo.instanciarentidad( "Francia" )
		
		loSetInstrucciones = loParametrosColeccion.Obtener( loEntidad , "ParametrosGeneracion" )
		
		this.assertequals( "Cantidad de instrucciones incorrectas.", 3 , loSetInstrucciones.Count )
		this.assertequals( "Parametro 1", "FRANCIA" , loSetInstrucciones["Entidad"] )
		this.assertequals( "Parametro 2", "0" , loSetInstrucciones["ValorAtributoClavePrimaria"] )		
		this.assertequals( "Parametro 3", "ParametrosGeneracion" , loSetInstrucciones["CodigoDisenio"] )
		loParametrosColeccion = null
		loSetInstrucciones = null
	

	endfunc 



EndDefine
