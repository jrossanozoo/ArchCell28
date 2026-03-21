**********************************************************************
Define Class zTestDatosMaquina as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as zTestDatosMaquina of zTestDatosMaquina.prg
	#ENDIF
	
	*-----------------------------------------------------------------------------------------
	function zTestIp

		local loDatosMaquina as Object
		loDatosMaquina =  newobject ("DatosMaquina", "DatosMaquina.prg")
	
		this.asserttrue( "No obtuvo la Ip correctamente", !empty( loDatosMaquina.ipaddress()) )

		loDatosMaquina = null

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestMacAdress

		local loDatosMaquina as Object
		loDatosMaquina =  newobject ("DatosMaquina", "DatosMaquina.prg")
	
		this.asserttrue( "No obtuvo la Mac correctamente", !empty( loDatosMaquina.macaddress()) )

		loDatosMaquina = null

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestGuid
	
		local loDatosMaquina as Object
		loDatosMaquina =  newobject ("DatosMaquina", "DatosMaquina.prg")
	
		this.asserttrue( "No obtuvo el GUID correctamente", !empty( loDatosMaquina.getguid()) )

		loDatosMaquina = null
	endfunc 	

EndDefine
