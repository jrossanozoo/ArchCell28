**********************************************************************
Define Class zTestAnalizadorConfiguracionAAO as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as zTestAnalizadorConfiguracionAAO of zTestAnalizadorConfiguracionAAO.prg
	#ENDIF
	
	*---------------------------------
	function zTestInstanciar
		local loTarget as AnalizadorConfiguracionAAO of AnalizadorConfiguracionAAO.prg
		
		loTarget = _Screen.zoo.crearobjeto( "AnalizadorConfiguracionAAO" )
		this.assertequals( "No se instancio el analizador", "Analizadorconfiguracionaao", loTarget.Class )

		loTarget.Release()
	EndFunc

	*---------------------------------
	function zTestObtenerParametrosResumenDelDia
		local loTarget as AnalizadorConfiguracionAAO of AnalizadorConfiguracionAAO.prg, loPar as object
		
		_Screen.mocks.agregarmock( "ZooLogicSA.SR.AO.Configurador.ParametrosOrganicDTO", "ParametrosOrganicDTOParaTest", "zTestAnalizadorConfiguracionAAO.prg" )

		loTarget = _Screen.zoo.crearobjeto( "AnalizadorConfiguracionAAO" )
		loPar = loTarget.ObtenerParametrosResumenDelDia()

		this.assertequals( "No se instancio el parametro 1", .F., loPar.lHabilitada )
		this.assertequals( "No se instancio el parametro 2", .F., loPar.cNombreAplicacion )
		this.assertequals( "No se instancio el parametro 3", .F., loPar.cRutaAplicacion )
		this.assertequals( "No se instancio el parametro 4", .F., loPar.nFrecuenciaEnMinutos )
		this.assertequals( "No se instancio el parametro 5", .F., loPar.cScript )
		this.assertequals( "No se instancio el parametro 6", .F., loPar.nTimeOut )
		this.assertequals( "No se instancio el parametro 7", .F., loPar.cDescripcion )
		
		loPar = null
		loTarget.Release()
		
		_screen.mocks.verificarejecuciondemocks()
	EndFunc

	*---------------------------------
	function zTestObtenerParametrosEnviarYRecibir
		local loTarget as AnalizadorConfiguracionAAO of AnalizadorConfiguracionAAO.prg, loPar as object
		
		_Screen.mocks.agregarmock( "ZooLogicSA.SR.AO.Configurador.ParametrosOrganicDTO", "ParametrosOrganicDTOParaTest", "zTestAnalizadorConfiguracionAAO.prg" )
		
		loTarget = _Screen.zoo.crearobjeto( "AnalizadorConfiguracionAAO" )
		loPar = loTarget.ObtenerParametrosEnviarYRecibir()

		this.assertequals( "No se instancio el parametro 1", .f., loPar.lHabilitada )
		this.asserttrue( "No se instancio el parametro 2", JUSTFNAME( _vfp.FullName ) $ loPar.cNombreAplicacion or ;
			strtran( strtran( forceext( _screen.zoo.app.cNombreExe, "" ), "_CORE", ""), "_NOREFOXEADO", "" ) $ loPar.cNombreAplicacion )
		this.asserttrue( "No se instancio el parametro 3", justpath( _vfp.FullName ) $ loPar.cRutaAplicacion or _screen.zoo.cRutaInicial $ loPar.cRutaAplicacion )
		this.assertequals( "No se instancio el parametro 4", 20, loPar.nFrecuenciaEnMinutos )
		this.assertTrue( "No se instancio el parametro 5", "EnviaRecibeProcesa.sz" $ loPar.cScript )
		this.assertequals( "No se instancio el parametro 6", 21600000, loPar.nTimeOut )
		this.assertequals( "No se instancio el parametro 7", "comunicando y procesando novedades", loPar.cDescripcion )

		loPar = null
		loTarget.Release()

		_screen.mocks.verificarejecuciondemocks()
	EndFunc

	*---------------------------------
	function zTestObtenerParametrosEnviarYRecibir_VerificarValores
		local loTarget as AnalizadorConfiguracionAAO of AnalizadorConfiguracionAAO.prg, loPar as object
		
		_Screen.mocks.agregarmock( "ZooLogicSA.SR.AO.Configurador.ParametrosOrganicDTO", "ParametrosOrganicDTOParaTest", "zTestAnalizadorConfiguracionAAO.prg" )

		loTarget = _Screen.zoo.crearobjeto( "AnalizadorConfiguracionAAO" )
		loTarget.lDesarrollo = .f.
		loTarget.lEsBuildAutomatico = .f.

		loPar = loTarget.ObtenerParametrosEnviarYRecibir()

		this.assertequals( "Error parametro 1 del constructor", .t., loPar.lHabilitada )
*		this.assertequals( "Error parametro 2 del constructor", _screen.zoo.app.NombreProducto, loPar.cNombreAplicacion )
		this.assertequals( "Error parametro 2 del constructor", strtran( strtran( forceext( _screen.zoo.app.cNombreExe, "" ), "_CORE", ""), "_NOREFOXEADO", "" ), loPar.cNombreAplicacion )
		this.assertequals( "Error parametro 3 del constructor", _screen.zoo.cRutaInicial, loPar.cRutaAplicacion )
		this.assertequals( "Error parametro 4 del constructor", 20, loPar.nFrecuenciaEnMinutos )
		this.assertTrue( "Error parametro 5 del constructor", "EnviaRecibeProcesa.sz" $ loPar.cScript )
		this.assertequals( "Error parametro 6 del constructor", 21600000, loPar.nTimeOut )
		this.assertequals( "Error parametro 7 del constructor", "comunicando y procesando novedades", loPar.cDescripcion )
			
		loPar = null
		loTarget.Release()
		
		_screen.mocks.verificarejecuciondemocks()
	EndFunc

	*---------------------------------
	function zTestAnalizarResultado_Resultado_NULL
		local loTarget as AnalizadorConfiguracionAAO of AnalizadorConfiguracionAAO.prg, loResultado as object, llRetorno as Boolean
				
		loResultado = null
		
		loTarget = _Screen.zoo.crearobjeto( "AnalizadorConfiguracionAAO" )
		llRetorno = loTarget.AnalizarResultado( loResultado )

		this.asserttrue( "Error al analizar el resultado", llRetorno )

		loTarget.Release()

		_screen.mocks.verificarejecuciondemocks()
	EndFunc

	*---------------------------------
	function zTestAnalizarResultadoCorrecto
		local loTarget as AnalizadorConfiguracionAAO of AnalizadorConfiguracionAAO.prg, loResultado as object, llRetorno as Boolean
				
		loResultado = _Screen.zoo.crearobjeto( "resultadoParaTest", "zTestAnalizadorConfiguracionAAO.prg" )
		
		loTarget = _Screen.zoo.crearobjeto( "AnalizadorConfiguracionAAO" )
		llRetorno = loTarget.AnalizarResultado( loResultado )

		this.asserttrue( "Error al analizar el resultado", llRetorno )

		loTarget.Release()

		_screen.mocks.verificarejecuciondemocks()
	EndFunc

	*---------------------------------
	function zTestAnalizarResultadoConReglasErroneas
		local loTarget as AnalizadorConfiguracionAAO of AnalizadorConfiguracionAAO.prg, loResultado as object, llRetorno as Boolean, ;
			loInformacion as zooinformacion of zooInformacion.prg
				
		loResultado = _Screen.zoo.crearobjeto( "resultadoParaTest", "zTestAnalizadorConfiguracionAAO.prg" )
		loResultado.ReglasValidadas = .f.
		
		loTarget = _Screen.zoo.crearobjeto( "AnalizadorConfiguracionAAO" )

		loInformacion = _Screen.zoo.crearobjeto( "zooinformacion" )
		
		llRetorno = loTarget.AnalizarResultado( loResultado, loInformacion )

		this.asserttrue( "Error al analizar el resultado", !llRetorno )
		this.assertEquals( "Error en la cantidad de reusltados.", 2, loInformacion.Count )
		this.assertEquals( "Error en el resultado 1", "regla 1", alltrim( loInformacion.Item[1].cMensaje ) )
		this.assertEquals( "Error en el resultado 2", "regla 2", alltrim( loInformacion.Item[2].cMensaje ) )

		loTarget.Release()

		_screen.mocks.verificarejecuciondemocks()
	EndFunc

	*---------------------------------
	function zTestAnalizarResultadoConAccionesErroneas
		local loTarget as AnalizadorConfiguracionAAO of AnalizadorConfiguracionAAO.prg, loResultado as object, llRetorno as Boolean, ;
			loInformacion as zooinformacion of zooInformacion.prg
							
		loResultado = _Screen.zoo.crearobjeto( "resultadoParaTest", "zTestAnalizadorConfiguracionAAO.prg" )
		loResultado.AccionesCompletadas = .f.
		
		loTarget = _Screen.zoo.crearobjeto( "AnalizadorConfiguracionAAO" )

		loInformacion = _Screen.zoo.crearobjeto( "zooinformacion" )

		llRetorno = loTarget.AnalizarResultado( loResultado, loInformacion )

		this.asserttrue( "Error al analizar el resultado", !llRetorno )
		this.assertEquals( "Error en la cantidad de reusltados.", 2, loInformacion.Count )
		this.assertEquals( "Error en el resultado 1", "accion 1", alltrim( loInformacion.Item[1].cMensaje ) )
		this.assertEquals( "Error en el resultado 2", "accion 2", alltrim( loInformacion.Item[2].cMensaje ) )

		loTarget.Release()

		_screen.mocks.verificarejecuciondemocks()
	EndFunc

EndDefine


define class resultadoParaTest as custom
	ReglasValidadas = .t.
	AccionesCompletadas= .t.
	Reglas = null
	Resultados = null
	
	*-----------------------------------------------------------------------------------------
	function Init() as Void
		local loAux as object
		
		this.Reglas = newobject( "collection" )
		
		loAux = newobject( "ReglaTest" )
		loaux.Mensaje = "regla 1"
		this.Reglas.Add( loAux ) 

		loAux = newobject( "ReglaTest" )
		loaux.Mensaje = "regla 2"
		this.Reglas.Add( loAux ) 

		loAux = newobject( "ReglaTest" )
		loaux.Mensaje = "regla 1"
		this.Reglas.Add( loAux ) 
		
		**********
		this.Resultados = newobject( "collection" )

		loAux = newobject( "AccionTest" )
		loaux.Mensaje = "accion 1"
		this.Resultados.Add( loAux ) 

		loAux = newobject( "AccionTest" )
		loaux.Mensaje = "accion 2"
		this.Resultados.Add( loAux ) 

		loAux = newobject( "AccionTest" )
		loaux.Mensaje = "accion 1"
		this.Resultados.Add( loAux ) 

		loAux = newobject( "AccionTest" )
		loaux.Mensaje = "accion 3"
		this.Resultados.Add( loAux ) 
	endfunc 
enddefine

define class ReglaTest as custom
	SeCumple = .f.
	Mensaje = ""
enddefine

define class AccionTest as custom
	ReglasValidadas = .f.
	AccionesCompletadas = .f.
	Mensaje = ""
enddefine

define class ParametrosOrganicDTOParaTest as custom

	lHabilitada = .f.
	cNombreAplicacion = ""
	cRutaAplicacion = ""
	nFrecuenciaEnMinutos = 0
	cScript = ""
	nTimeOut = 0
	cDescripcion = ""
	
	function init( tlHabilitada, tcDescripcion, tcNombreAplicacion, tcRutaAplicacion, tnFrecuenciaEnMinutos, tcScript, tnTimeOut )
		with this
			.lHabilitada = tlHabilitada 
			.cNombreAplicacion = tcNombreAplicacion
			.cRutaAplicacion = tcRutaAplicacion
			.nFrecuenciaEnMinutos = tnFrecuenciaEnMinutos
			.cScript = tcScript
			.nTimeOut = tnTimeOut
			.cDescripcion = tcDescripcion
		endwith
	endfunc

enddefine