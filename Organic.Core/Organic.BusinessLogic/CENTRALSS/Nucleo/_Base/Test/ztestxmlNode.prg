**********************************************************************
Define Class zTestXmlNode as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as zTestXmlNode of zTestXmlNode.prg
	#ENDIF
	
	oXmlNode = null
	
	*-----------------------------------		
	Function Setup
		this.oXmlNode = _screen.zoo.crearobjeto( 'xmlnode' )
	endfunc 

	*-----------------------------------	
	Function TearDown
		this.oXmlNode = null
	endfunc
	
	*-----------------------------------
	function zTestTransformarCaracteresEspecialesAmpersand
		with this.oXmlNode
			.agregarpropiedad( "Propiedad1", "Val&or" )
			this.assertequals( "El valor de la propiedad Propiedad1 no fue transformada correctamente (1).", "Val&amp;or", .oPROPIEDADES( 1 ) )
		endwith
	endfunc 

	*-----------------------------------
	function zTestTransformarCaracteresEspecialesMayor
		with this.oXmlNode
			.agregarpropiedad( "Propiedad1", "Val>or" )
			this.assertequals( "El valor de la propiedad Propiedad1 no fue transformada correctamente (2).", "Val&gt;or", .oPROPIEDADES( 1 ) )
		endwith
	endfunc 

	*-----------------------------------
	function zTestTransformarCaracteresEspecialesMenor
		local loXmlNode as xmlNode of xmlNode.prg
		
		with this.oXmlNode
			.agregarpropiedad( "Propiedad1", "Val<or" )
			this.assertequals( "El valor de la propiedad Propiedad1 no fue transformada correctamente (3).", "Val&lt;or", .oPROPIEDADES( 1 ) )
		endwith
	endfunc 

	*-----------------------------------
	function zTestTransformarCaracteresEspecialesComillaDoble
		local loXmlNode as xmlNode of xmlNode.prg
		
		with this.oXmlNode
			.agregarpropiedad( "Propiedad1", 'Val"or' )
			this.assertequals( "El valor de la propiedad Propiedad1 no fue transformada correctamente (4).", "Val&quot;or", .oPROPIEDADES( 1 ) )
		endwith
	endfunc 

	*-----------------------------------
	function zTestTransformarCaracteresEspecialesComillaSimple
		local loXmlNode as xmlNode of xmlNode.prg
		
		with this.oXmlNode
			.agregarpropiedad( "Propiedad1", "Val'or" )
			this.assertequals( "El valor de la propiedad Propiedad1 no fue transformada correctamente (5).", "Val&apos;or", .oPROPIEDADES( 1 ) )
		endwith
	endfunc

	*-----------------------------------
	function zTestTransformarCaracteresEspecialesCombinacionAmpensandMayor
		local loXmlNode as xmlNode of xmlNode.prg
		with this.oXmlNode
			.agregarpropiedad( "Propiedad1", "Val&or > que" )
			this.assertequals( "El valor de la propiedad Propiedad1 no fue transformada correctamente (6).", "Val&amp;or &gt; que", .oPROPIEDADES( 1 ) )
		endwith
	endfunc

	*-----------------------------------
	function zTestTransformarCaracteresEspecialesCombinacionCuandoNotieneQueReemplazarNada
		local loXmlNode as xmlNode of xmlNode.prg
		with this.oXmlNode
			.agregarpropiedad( "Propiedad1", "Valor" )
			this.assertequals( "El valor de la propiedad Propiedad1 no fue transformada correctamente (6).", "Valor", .oPROPIEDADES( 1 ) )
		endwith
	endfunc


enddefine

