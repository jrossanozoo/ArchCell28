**********************************************************************
Define Class zTestProblema as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as zTestProblema of zTestProblema.prg
	#ENDIF
	
	oProblema = null
	
	*---------------------------------
	Function Setup
		this.oProblema = newobject( "Problema", "Problema.prg" )
	EndFunc



	*---------------------------------------------------------------------------------
	function zTestProblema

		this.assertequals( "Instancio Problemas", "O", vartype( this.oProblema ) )		

	endfunc


	*---------------------------------
	Function TearDown
		this.oProblema.release()
	endfunc
	
EndDefine
