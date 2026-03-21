**********************************************************************
Define Class zTestInstruccionesEnvioMail  as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as zTestInstruccionesEnvioMail  of zTestInstruccionesEnvioMail.prg
	#ENDIF
	
	*---------------------------------
	Function Setup

	EndFunc
	
	*---------------------------------
	Function TearDown

	EndFunc

	*-----------------------------------------------------------------------------------------
	function zTestObtenerSetConGeneracionTktCambioYDisenoComprobanteAdjunto
		local loInstrucciones as InstruccionesEnvioMail of InstruccionesEnvioMail.prg, ;
		loSetInstrucciones as zoocoleccion OF zoocoleccion.prg

		loParametrosColeccion = _screen.zoo.crearobjeto( "parametrosinstruccionesenviomail" )
		loEntidad = _screen.zoo.instanciarentidad( "Francia" )
		loEntidad.addproperty( "cDisenoComprobanteAdjunto", "DISENO1" )
		loEntidad.addproperty( "lTieneTiquetDeCambioPdf", .t. )
		
		loSetInstrucciones = loParametrosColeccion.Obtener( loEntidad , "ParametrosGeneracion" )
	
		this.assertequals( "Cantidad de instrucciones incorrectas.", 5 , loSetInstrucciones.Count )
		this.assertequals( "Parametro 1", "FRANCIA" , loSetInstrucciones["Entidad"] )
		this.assertequals( "Parametro 2", "0" , loSetInstrucciones["ValorAtributoClavePrimaria"] )		
		this.assertequals( "Parametro 3", "ParametrosGeneracion" , loSetInstrucciones["CodigoDisenioMail"] )
		this.assertequals( "Parametro 4", .t.,  loSetInstrucciones["GeneroTiquetDeCambioEnPdf"])
		this.assertequals( "Parametro 5", "DISENO1" , loSetInstrucciones["cDisenoComprobanteAdjunto"] )
		
		loParametrosColeccion = null
		loSetInstrucciones = null
	

	endfunc 



EndDefine
