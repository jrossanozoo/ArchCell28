**********************************************************************
Define Class zTestLanzadorDeConsulta as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as zTestLanzadorDeConsulta of zTestLanzadorDeConsulta.prg
	#ENDIF
	cTipoDeBase = ""
	cCentury = ""
	tFechaBlanco = {}
	
	*-----------------------------------------------------------------------------------------
	function ztestTransformarValorSegunTipoDeDato
		local loLanzador as LanzadorDeConsulta_TEST of zTestLanzadorDeConsulta.prg
		
		loLanzador = _Screen.zoo.crearobjeto( "LanzadorDeConsulta_TEST", "zTestLanzadorDeConsulta.prg" )
		loLanzador.Procesar( "78" )
		
		this.Asserttrue( "El archivo para persistir en disco debe ser shortname o soportar 8.3 formated.", ;
			_screen.zoo.ObtenerRutaTemporal() $ loLanzador.cArchivoParaGrabarEnDisco_TEST )
			**C:\USERS\CAMPEONDELAVIDA\APPDATA\LOCAL\TEMP\ZOOTMP\NUCLEO\A_2013\M_04\D_17\_3RI13FS2A\_3RI13KD0O.xml

		this.Asserttrue( "El archivo exe es incorrecto.", ;
			"zoologicsa.buscador.lanzador.exe" $ loLanzador.cArchivoExe )
			**C:\ZOO\NUCLEO\bin\zoologicsa.buscador.lanzador.exe
			
		this.assertequals( "El archivo que se envia al exe con los parametros es incorrecto debe empezar con comillas.", ;
			left( loLanzador.cArchivoParametrosExe,1), '"' )
			
		this.assertequals( "El archivo que se envia al exe con los parametros es incorrecto debe terminar con comillas.", ;
			right( loLanzador.cArchivoParametrosExe,1), '"' )			
			
		*La prueba importante es enviar rutas que contengan espacio al exe y que estas no den error. envolviendolas entre comillas se salva.
		loLanzador = null
	endfunc 

EndDefine


*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class LanzadorDeConsulta_TEST as LanzadorDeConsulta of LanzadorDeConsulta.Prg

	cArchivoParaGrabarEnDisco_TEST = ""
	cArchivoExe = ""
	cArchivoParametrosExe = ""

	*-----------------------------------------------------------------------------------------
	protected function GrabarConfiguracionEnDisco( toConfigurador as Object, tcArchivo as String ) as Void
		this.cArchivoParaGrabarEnDisco_TEST = tcArchivo
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EjecutarApp( tcExe as string, tcArchivoParametros as String ) as Void
		this.cArchivoExe = tcExe
		this.cArchivoParametrosExe = tcArchivoParametros
	endfunc 
	*-----------------------------------------------------------------------------------------
	function TienePermisosParaUsarLasConsultas( tcIdFormulario as String ) as Boolean
		return .t.
	endfunc 


enddefine
