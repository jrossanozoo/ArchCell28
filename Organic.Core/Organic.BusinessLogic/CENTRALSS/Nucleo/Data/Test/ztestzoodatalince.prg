**********************************************************************
Define Class zTestZooDataLince as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as zTestZooDataLince of zTestZooDataLince.prg
	#ENDIF
	
	oZooDataLince = null

	*---------------------------------
	Function Setup
		this.oZooDataLince = newobject("ZooDataLince", "ZooDataLince.prg")			

		_screen.zoo.app.cSucursalActiva = "Paises"

	EndFunc
	
	*---------------------------------
	Function TearDown
		this.oZooDataLince.release()
	EndFunc
	
	*-----------------------------------------------------------------------------------------
	function zTestZooDataLince
		this.assertequals("No se pudo instaciar la clase" ,"O", vartype(this.oZooDataLince) )
	endfunc 
EndDefine
