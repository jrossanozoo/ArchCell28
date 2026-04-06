**********************************************************************
Define Class ztestzlusuariosivrweb as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as ztestzlusuariosivrweb of ztestzlusuariosivrweb.prg
	#ENDIF

	*-----------------------------------------------------------------------------------------
	function ztestAtributoszlusuariosivrweb() 
		local lnCantidad as Integer

		lncantidad = 0

		*!*	 DRAGON 2028
		Use ( Addbs( _Screen.zoo.cRutaInicial ) + "\adn\dbc\diccionario" ) 

		locate for upper( alltrim( Entidad ) ) == "ZLUSUARIOSIVRWEB" and upper( alltrim( Atributo ) ) == "CLIENTE" 
		This.AssertTrue( "El atributo CLIENTE no existe en la entidad ZLUSUARIOSIVRWEB", found() )

		locate for upper( alltrim( Entidad ) ) == "ZLUSUARIOSIVRWEB" and upper( alltrim( Atributo ) ) == "CODIGO" 
		This.AssertTrue( "El atributo CODIGO no existe en la entidad ZLUSUARIOSIVRWEB", found() )

		locate for upper( alltrim( Entidad ) ) == "ZLUSUARIOSIVRWEB" and upper( alltrim( Atributo ) ) == "NOMBRE" 
		This.AssertTrue( "El atributo NOMBRE no existe en la entidad ZLUSUARIOSIVRWEB", found() )

		locate for upper( alltrim( Entidad ) ) == "ZLUSUARIOSIVRWEB" and upper( alltrim( Atributo ) ) == "PERFIL" 
		This.AssertTrue( "El atributo PERFIL  no existe en la entidad ZLUSUARIOSIVRWEB", found() )

		locate for upper( alltrim( Entidad ) ) == "ZLUSUARIOSIVRWEB" and upper( alltrim( Atributo ) ) == "CLAVE" 
		This.AssertTrue( "El atributo CLAVE no existe en la entidad ZLUSUARIOSIVRWEB", found() )

		locate for upper( alltrim( Entidad ) ) == "ZLUSUARIOSIVRWEB" and upper( alltrim( Atributo ) ) == "CANTIDADINTENTOS" 
		This.AssertTrue( "El atributo CANTIDADINTENTOS no existe en la entidad ZLUSUARIOSIVRWEB", found() )

		locate for upper( alltrim( Entidad ) ) == "ZLUSUARIOSIVRWEB" and upper( alltrim( Atributo ) ) == "BLOQUEADO" 
		This.AssertTrue( "El atributo BLOQUEADO no existe en la entidad ZLUSUARIOSIVRWEB", found() )

		select diccionario
		count to lnCantidad for upper( alltrim( Diccionario.entidad ) ) == upper( alltrim( "ZLUSUARIOSIVRWEB" ) ) 
		
		This.assertequals( "La cantidad de atributos de la entidad ZLUSUARIOSIVRWEB no es correcta", 9, lnCantidad )
		
		use in select( "Diccionario" )
		
	endfunc 


enddefine
	