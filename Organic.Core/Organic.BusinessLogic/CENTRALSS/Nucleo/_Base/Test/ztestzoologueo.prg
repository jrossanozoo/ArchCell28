**********************************************************************
Define Class zTestZooLogueo as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as zTestZooLogueo of zTestZooLogueo.prg
	#ENDIF
	
	oLog = null 
	
	*---------------------------------
	Function Setup
		this.oLog = _screen.zoo.crearobjeto( "ZooLogueo" )
	EndFunc
	
	*-----------------------------------------------------------------------------------------
	function zTestInstanciar
			this.assertequals( "No se Instacion la clase de Logueo", "O", vartype( this.oLog ) ) 

	endfunc 
	*-----------------------------------------------------------------------------------------
	function zTestSetearRutaLogueo
		local lcDirectorio as String, lcDirectorioLog As String
		lcDirectorio = addbs( sys( 5 ) ) + "Directorio_zTestSetearRutaLogueo" + sys( 2015 ) 
		lcDirectorioLog = lcDirectorio + "\Log"

		if directory( lcDirectorioLog )
			rd (lcDirectorioLog)
			rd (lcDirectorio)
		EndIf	

		This.oLog.SetearRutaLogueo( lcDirectorio )
		this.assertTrue( "No se creo el Directorio ", directory( lcDirectorioLog ) ) 

		&& Se ejecuta de vuelta para verificar que al existir no lo cree de vuelta
		This.oLog.SetearRutaLogueo( lcDirectorio )
		this.assertTrue( "No se creo el Directorio ", directory( lcDirectorioLog ) ) 

		if directory( lcDirectorioLog )
			rd (lcDirectorioLog)
			rd (lcDirectorio)
		EndIf	

	endfunc 
	
	*---------------------------------
	Function TearDown
		this.oLog.release()
	EndFunc

EndDefine
