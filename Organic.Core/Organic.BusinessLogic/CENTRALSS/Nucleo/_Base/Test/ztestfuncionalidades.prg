**********************************************************************
Define Class ztestfuncionalidades as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as ztestfuncionalidades of ztestfuncionalidades.prg
	#ENDIF
	
	*---------------------------------
	Function Setup

	EndFunc
	
	*---------------------------------
	Function TearDown

	EndFunc
	*-----------------------------------------------------------------------------------------
	function zTestTieneFuncionalidadSimple
		
		local loFunc as Object
		
		loFunc = newobject( "funcionalidades", "funcionalidades.prg" )
		
		this.asserttrue("No encontro correctamente el tag", loFunc.TieneFuncionalidad( "AUDITORIA", "<AUDITORIA>" ))
		
		this.asserttrue("No debe encontrar el tag Auditorias", !loFunc.TieneFuncionalidad( "AUDITORIAS", "<AUDITORIA>" ))
		
		this.asserttrue("No debe encontrar el tag", !loFunc.TieneFuncionalidad( "PAIS", "<AUDITORIA>" ))
		
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestTieneFuncionalidadCompleja
		
		local loFunc as Object
		
		loFunc = newobject( "funcionalidades", "funcionalidades.prg" )
		this.asserttrue("No encontro correctamente el tag PAIS", loFunc.TieneFuncionalidad( "PAIS", "<PAIS:2>" ))
		
		this.asserttrue("No encontro correctamente el tag AUDITORIA", loFunc.TieneFuncionalidad( "AUDITORIA", "<AUDITORIA<MODULOSLISTADO:VSC>>" ))
		this.asserttrue("No encontro correctamente el tag MODULOSLISTADO", loFunc.TieneFuncionalidad( "MODULOSLISTADO", "<AUDITORIA<MODULOSLISTADO:VSC>>" ))
		
		this.asserttrue("No encontro correctamente el tag AUDITORIA 2", loFunc.TieneFuncionalidad( "AUDITORIA", "<AUDITORIA><MODULOSLISTADO:VSC>" ))
		this.asserttrue("No encontro correctamente el tag MODULOSLISTADO 2", loFunc.TieneFuncionalidad( "MODULOSLISTADO", "<AUDITORIA><MODULOSLISTADO:VSC>" ))


	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestObtenerValor
		local loFunc as Object
		
		loFunc = newobject( "funcionalidades", "funcionalidades.prg" )
		
		this.assertequals( "Error en el valor del tag PAIS", "2", loFunc.ObtenerValor( "PAIS" , "<PAIS:2>") )
		this.assertequals( "Error en el valor del tag MODULOSLISTADO", "VSC", loFunc.ObtenerValor( "MODULOSLISTADO", "<AUDITORIA<MODULOSLISTADO:VSC>>" ) )
		this.assertequals( "Error en el valor del tag MODULOSLISTADO", "VSC", loFunc.ObtenerValor( "MODULOSLISTADO" , "<PAIS:2><AUDITORIA<MODULOSLISTADO:VSC>><NOLOGUEAR>") )
		
	endfunc 

EndDefine
