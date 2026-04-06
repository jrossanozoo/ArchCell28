**********************************************************************
Define Class zTestRechazoMail as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as zTestRechazoMail of zTestRechazoMail.prg
	#ENDIF
	
	*---------------------------------
	Function Setup

	endfunc
	
	*---------------------------------
	Function zTestValidarDiccionario
		local lcEntidad as String 
	
	
		lcEntidad = "ITEMRECHAZOSMAIL"

		use (addbs(_screen.zoo.crUTAINICIAL) + 'ADN\DBC\Diccionario.dbf') in 0 
		
		select Diccionario
		locate for upper( alltrim( atributo ) ) == 'CLIENTE' and alltrim( upper( entidad ) ) == lcEntidad			
		
		if found()
			This.assertEquals ( "No esta cargado el campo 'ATRIBUTOFORANEO'", 'RAZONSOCIAL.CLIENTE', upper( alltrim( Diccionario.atributoforaneo ) ) )
		else
			This.asserttrue ( "No se encontro el atributo 'RAZONSOCIAL.CLIENTE'  en el campo 'ATRIBUTOFORANEO'", .f.)	
		endif

		select Diccionario
		locate for upper( alltrim( atributo ) ) == 'CONTACTO' and alltrim( upper( entidad ) ) == lcEntidad			
		
		if found()
			This.assertEquals ( "No esta cargado el campo 'ATRIBUTOFORANEO'", 'RAZONSOCIAL.CLIENTE.CONTACTO', upper( alltrim( Diccionario.atributoforaneo ) ) )
		else
			This.asserttrue ( "No se encontro el atributo 'RAZONSOCIAL.CLIENTE.CONTACTO'  en el campo 'ATRIBUTOFORANEO'", .f.)	
		endif

		select Diccionario
		locate for upper( alltrim( atributo ) ) == 'CLIENTEDETALLE' and alltrim( upper( entidad ) ) == lcEntidad			
		
		if found()
			This.assertEquals ( "No esta cargado el campo 'ATRIBUTOFORANEO'", 'CLIENTE.NOMBRE', upper( alltrim( Diccionario.atributoforaneo ) ) )
		else
			This.asserttrue ( "No se encontro el atributo 'RAZONSOCIAL.CLIENTE.NOMBRE' en el campo 'ATRIBUTOFORANEO'", .f.)	
		endif

		select Diccionario
		locate for upper( alltrim( atributo ) ) == 'CONTACTODETALLE' and alltrim( upper( entidad ) ) == lcEntidad			
		
		if found()
			This.assertEquals ( "No esta cargado el campo 'ATRIBUTOFORANEO'", 'CONTACTO.NOMBRE', upper( alltrim( Diccionario.atributoforaneo ) ) )
		else
			This.asserttrue ( "No se encontro el atributo 'RAZONSOCIAL.CLIENTE.CONTACTO.NOMBRE' en el campo 'ATRIBUTOFORANEO'", .f.)	
		endif

		select Diccionario
		use       
		
	Endfunc		


	*---------------------------------
	Function TearDown

	EndFunc




EndDefine
