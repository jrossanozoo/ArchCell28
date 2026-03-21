**********************************************************************
Define Class zTestInstruccionesScript as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as zTestInstruccionesScript of zTestInstruccionesScript.prg
	#ENDIF
	
	*---------------------------------
	Function zTestU_Init
		local loInstrucciones as ResumenDelDiaInstruccionesScript of ResumenDelDiaInstruccionesScript.prg
		
		loInstrucciones = _Screen.zoo.crearobjeto( "InstruccionesScript" )
		
		this.assertequals( "Error en la Base De Datos", "", loInstrucciones.cBaseDeDatos )
		this.assertequals( "Error en el time out", 0,loInstrucciones.nTimeOut )
		this.assertequals( "Error en la cantidad de instrucciones", 0, loInstrucciones.Count )
		this.assertequals( "Error en la descripcion", "", loInstrucciones.cDescripcion )

		loInstrucciones.release()

		_screen.mocks.verificarejecuciondemocks()
	endfunc
	
	*---------------------------------
	Function zTest_HayAcciones
		local loIns as InstruccionesScript of InstruccionesScript.prg
		
		loIns = _screen.zoo.crearobjeto( "InstruccionesScript" )

		this.Asserttrue( "No debe haber instrucciones", !loIns.HayInstrucciones() )

		loIns.agregar( "comando" )
		
		this.Asserttrue( "Debe haber instrucciones", loIns.HayInstrucciones() )
		
		loIns.release()
	EndFunc

EndDefine
