**********************************************************************
Define Class ztestAtributoIgualCodigo as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as ztestAtributoIgualCodigo of ztestAtributoIgualCodigo.prg
	#ENDIF
	
	*---------------------------------
	Function Setup
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ztestAtributoIgualCodigo
		local loEntidad as Object, lcCodigo as String
		
		loEntidad = _screen.zoo.instanciarentidad("Korea")
		loEntidad.nuevo()
		
		lcCodigo = substr( sys( 2015 ), 2 )
		loEntidad.Codigo = lcCodigo
		loEntidad.Descripcion = "El Koreanito" + lcCodigo
		loEntidad.campo1 = "Campo1"
		try
			loEntidad.grabar()
		catch
			this.assertequals("No se pudo Grabar la entdad Korea", .f. )
		endtry	

		loEntidad.Limpiar()
		Try
			loEntidad.Codigo = lcCodigo
		catch to loError
			this.assertTrue( "No se encontro el dato buscado", .F. )
		EndTry	
		loEntidad.release()
	endfunc 

	*---------------------------------
	Function TearDown

	EndFunc

EndDefine
