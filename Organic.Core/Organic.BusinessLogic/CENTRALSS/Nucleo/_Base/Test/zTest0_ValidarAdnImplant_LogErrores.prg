**********************************************************************
DEFINE CLASS zTest0_ValidarAdnImplant_LogErrores as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		LOCAL THIS AS zTest0_ValidarAdnImplant_LogErrores OF zTest0_ValidarAdnImplant_LogErrores.PRG
	#ENDIF

	*----------------------------------------------------------------------------------------
	function zTestU_ValidarExistaArchivosLog
		local loControladorDeLogsADNImplant as ControladorDeLogsADNImplant of ControladorDeLogsADNImplant.prg
		loControladorDeLogsADNImplant = _Screen.zoo.crearObjeto( "ControladorDeLogsADNImplant" )
		loControladorDeLogsADNImplant.ControlarLogsExistentes( this )
		loControladorDeLogsADNImplant.Release()
		loControladorDeLogsADNImplant = null
	endfunc
	
	*----------------------------------------------------------------------------------------
	function zTestU_ValidarLogConErrores
		local loControladorDeLogsADNImplant as ControladorDeLogsADNImplant of ControladorDeLogsADNImplant.prg
		loControladorDeLogsADNImplant = _Screen.zoo.crearObjeto( "ControladorDeLogsADNImplant" )
		loControladorDeLogsADNImplant.ValidarLogConErroresV3( this )
		loControladorDeLogsADNImplant.Release()
		loControladorDeLogsADNImplant = null
	endfunc

enddefine