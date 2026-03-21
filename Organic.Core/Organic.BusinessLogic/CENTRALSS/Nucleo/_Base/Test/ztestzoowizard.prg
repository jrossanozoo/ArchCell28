**********************************************************************
Define Class zTestZooWizard as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as zTestZooWizard of zTestZooWizard.prg
	#ENDIF
	
	*---------------------------------
	Function Setup

	EndFunc
	
	*-----------------------------------
	function zTestInstanciaZooWizard 	

		local loWizard as Object, loError as Exception, lcMensaje as String, llEstadoBotonAnterior as Boolean, ;
			llDatos as Boolean

		Try
			loWizard = newobject("zooWizard","zooWizard.prg")
			this.assertTrue("No se ha instanciado el Wizard",vartype(loWizard) = "O")
			
			llEstadoBotonAnterior = loWizard.CmdAnterior.Enabled
			this.asserttrue("El botón Anterior no está deshabilitado en el Paso 1 del Wizard", llEstadoBotonAnterior = .f.)
			llDatos = pemstatus( loWizard, "oDatos", 5)
			this.asserttrue( "No existe la propiedad oDatos", llDatos)

		Catch to loError	
			if vartype(loError.UserValue) == "O"
				lcMensaje = "MENSAJE: " + transform ( loError.UserValue.uservalue )+ chr (13) ;
							 + "ERROR: " + transform ( loError.UserValue.Message )+ chr (13) ;
							 + "PROGRAMA: " +transform ( loError.uservalue.procedure )+ chr (13);
							 + "FUNCION: "  +transform ( loError.Procedure )+ chr (13);
							 + "LINEA: " + transform ( loError.LineNo) + chr (13);
							 + "SENTENCIA; " + transform ( loError.UserValue.LineContents )
								 
				this.AssertEquals(lcMensaje , .t., .f.)
			else 
				this.AssertEquals(loError.Message, .t., .f.)
			endif	
		Endtry
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestWizardActualizaCaption 
	

		local loWizard as Object, lcCaptionWizard as String, lcCaptionComparar as String

			loWizard = newobject("zooWizard","zooWizard.prg")
			this.assertTrue("No se ha instanciado el Wizard",vartype(loWizard) = "O")
			lcCaption = "Asistente de ... - Paso " + alltrim(str(loWizard.nPaso)) ;
			+ " de " + alltrim(str(loWizard.nTotaldePasos))
			lcCaptionComparar = "Asistente de ... - Paso 1 de 4" 
			this.assertEquals("Error en el Caption del Wizard",lcCaption,lcCaptionComparar)

	endfunc 

	*-----------------------------------------------------------------------------------------

	function zTestPasoAnterior
	
		local loWizard as Object,llEstadoBotonAnterior as Boolean
		
		loWizard = newobject("zooWizard","zooWizard.prg")
		this.assertTrue("No se ha instanciado el Wizard",vartype(loWizard) = "O")
		llEstadoBotonAnterior= loWizard.CmdAnterior.Enabled
		this.assertequals("El Botón Anterior no está deshabilitado en el primer paso", .f., llEstadoBotonAnterior)
		loWizard.CmdSiguiente.Click()
		llEstadoBotonAnterior= loWizard.CmdAnterior.Enabled
		this.assertequals("El Botón Anterior no está habilitado en el primer paso", .t., llEstadoBotonAnterior)
	

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestPasoSiguiente
	
		local loWizard as Object,lcCaptionBotonSiguiente as String, i as Integer, ;
			llEstadoBotonAnterior as Boolean
		
		loWizard = newobject("zooWizard","zooWizard.prg")
		this.assertTrue("No se ha instanciado el Wizard",vartype(loWizard) = "O")
		for i = 1 to loWizard.nTotaldePasos - 1
			loWizard.CmdSiguiente.Click()
		endfor	
		lcCaptionBotonSiguiente = loWizard.CmdSiguiente.Caption
		this.assertequals("El Caption del Botón Siguiente no es el correcto", "Ace\<ptar", lcCaptionBotonSiguiente )
		llEstadoBotonAnterior = loWizard.CmdAnterior.Enabled
		this.assertequals("El Botón Anterior no está habilitado en el último paso", .t., llEstadoBotonAnterior )		


	endfunc 

	*-----------------------------------------------------------------------------------------	

	function zTestNavegacion 
	
		local loWizard as Object, i as Integer, lnPasoActual as Integer, lnValorEsperado as Integer, ;
			llEstadoBotonAnterior as String
		
		loWizard = newobject("zooWizard","zooWizard.prg")
		this.assertTrue("No se ha instanciado el Wizard",vartype(loWizard) = "O")
		for i = 1 to loWizard.nTotaldePasos - 1
			loWizard.CmdSiguiente.Click()
		endfor	
		lnPasoActual = loWizard.nPaso
		lnValorEsperado = loWizard.nTotaldePasos
		this.assertequals("No coincide el número de pasos con el paso actual del Wizard", ;
			lnValorEsperado,lnPasoActual)
		for i = loWizard.nTotaldePasos to 1 step - 1
			loWizard.CmdAnterior.Click()
		endfor	
		lnPasoActual = loWizard.nPaso
		lnValorEsperado = 1
		this.assertequals("No coincide el número de pasos con el paso actual del Wizard", ;
			lnValorEsperado,lnPasoActual)	
		llEstadoBotonAnterior = loWizard.CmdAnterior.Enabled
		this.assertequals("El Botón Anterior no está deshabilitado en el primer paso", .f., llEstadoBotonAnterior)		

	endfunc 
	*-----------------------------------------------------------------------------------------

	function zTestCerrarAsistente
	
		local loWizard as Object
		
		loWizard = newobject("zooWizard","zooWizard.prg")
		this.assertTrue("No se ha instanciado el Wizard",vartype(loWizard) = "O")
		loWizard.CmdCancelar.Click()
		this.assertequals("No se ha cerrado correctamente el Wizard","X",vartype(loWizard))
	

	endfunc 
*-----------------------------------------------------------------------------------------

	
	Function TearDown

	EndFunc

EndDefine
