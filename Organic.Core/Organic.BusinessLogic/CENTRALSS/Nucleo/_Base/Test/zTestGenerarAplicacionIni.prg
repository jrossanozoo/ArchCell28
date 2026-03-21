**********************************************************************
Define Class zTestGenerarAplicacionIni as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as zTestGenerarAplicacionIni of zTestGenerarAplicacionIni.prg
	#ENDIF
	
	*---------------------------------
	Function Setup

	EndFunc
	
	*---------------------------------
	Function TearDown

	endfunc
	

	*-----------------------------------------------------------------------------------------
	function zTestGenerarAplicacionIni
		local loAplicacionBase as Object, lcRutaTemporal as String, lcContenido as String

		loAplicacionBase = newObject( "aplicacionAuxiliar" )
		lcRutaTemporal = _Screen.zoo.ObtenerRutaTemporal()
		delete file ( addbs( lcRutaTemporal ) + "*.ini" )
		
		loAplicacionBase.aArchivosIni[ 1 ] = Addbs( lcRutaTemporal ) + "Aplicacion.INI"
		loAplicacionBase.aArchivosIni[ 2 ] = Addbs( lcRutaTemporal ) + "Dataconfig.INI"

		loAplicacionBase.GenerarINIdePrueba( loAplicacionBase.aArchivosIni[ 1 ] )
		this.asserttrue( "No se generó el archivo 'Aplicacion.INI' ", file( loAplicacionBase.aArchivosIni[ 1 ] ) )
		lcContenido = filetostr( loAplicacionBase.aArchivosIni[ 1 ] )

		alines( laArray, lcContenido, 4, chr(13) + chr(10) )
		this.aSSErtequals( "No se generó correctamente la entrada DATOS", alltrim( upper( laArray[1] ) ), "[DATOS]" )

		this.aSSErtequals( "No se generó correctamente la entrada RUTADATACONFIG", addbs( alltrim( upper( laArray[2] ) ) ) , ;
																			"RUTADATACONFIG=" + upper( alltrim( addbs( _screen.zoo.cRUTAINICIAL ) ) ) ) 
		
		delete file ( addbs( lcRutaTemporal ) + "*.ini" )
		loAplicacionBase.Release()
	endfunc 	

enddefine

*-----------------------------------------------------------------------------------------

define class AplicacionAuxiliar as AplicacionBase of AplicacionBase.prg
	*-----------------------------------------------------------------------------------------
	function Init() as Void
		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AsignarClaveMenu() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearBufferDeMemoria() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function InstanciarNetExtender() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarReferencias() as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function InstanciarMonitorQA() as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ConfigurarAdministracionDeEnergia( txParam as Boolean ) as Void
	endfunc 	
		
	*-----------------------------------------------------------------------------------------	
	function GenerarINIdePrueba( tcRutaTemporal ) as VOID	
		this.LevantarSeteosAplicacionIni( tcRutaTemporal, "NUCLEO" )	
	endfunc
	
enddefine