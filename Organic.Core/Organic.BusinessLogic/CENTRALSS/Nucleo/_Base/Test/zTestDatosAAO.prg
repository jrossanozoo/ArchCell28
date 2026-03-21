**********************************************************************
Define Class zTestDatosAAO As FxuTestCase Of FxuTestCase.prg

	#If .F.
		Local This As zTestDatosAAO Of zTestDatosAAO.prg
	#Endif

	*-----------------------------------------------------------------------------------------
	function SetUp
		local lcArchivoIni as string

		lcArchivoIni = addbs( _screen.zoo.cRutaInicial ) + "AAO.ini"
		
		if ( file( lcArchivoIni ) )
			delete file ( lcArchivoIni )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function TearDown
		local lcArchivoIni as string

		lcArchivoIni = addbs( _screen.zoo.cRutaInicial ) + "AAO.ini"
		
		if ( file( lcArchivoIni ) )
			delete file ( lcArchivoIni )
		endif
	endfunc 

	*---------------------------------
	Function zTestU_Constructor
		local loTarget as DatosAAO of DatosAAO.prg, lcArchivoIni as string, lcRetorno as string
		
		lcArchivoIni = addbs( _screen.zoo.cRutaInicial ) + "AAO.ini"
		
		if ( file( lcArchivoIni ) )
			delete file ( lcArchivoIni )
		endif
		
		loTarget = _Screen.zoo.crearobjeto( "DatosAAO" )
		
		this.AssertTrue( "No se creó el archivo de configuracion", file( lcArchivoIni ) )
		
		loTarget.Release()
	Endfunc

	*---------------------------------
	Function zTestI_SetearYObtenerVersionUltimaActualizacion
		local loTarget as DatosAAO of DatosAAO.prg
		
		loTarget = _Screen.zoo.crearobjeto( "DatosAAO" )
		loTarget.lDesarrollo = .f.
		loTarget.lEsBuildAutomatico = .f.

		loTarget.SetearVersionUltimaActualizacion( "VersionParaTest" )
		lcRetorno = loTarget.ObtenerVersionUltimaActualizacion()
		
		this.assertequals( "No se seteo la version correctamente", "VersionParaTest", lcRetorno )

		loTarget.Release()
	Endfunc

	*---------------------------------
	Function zTestI_SetearYObtener
		local loTarget as DatosAAO of DatosAAO.prg, lcRetorno as string
		
		loTarget = _Screen.zoo.crearobjeto( "DatosAAO" )

		loTarget.Setear( "Seccion", "Variable", "Valor" )

		lcRetorno = loTarget.Obtener( "Seccion", "Variable" )
		
		this.assertequals( "No se obtuvo la version", "Valor", lcRetorno )
		loTarget.Release()
	Endfunc

Enddefine
