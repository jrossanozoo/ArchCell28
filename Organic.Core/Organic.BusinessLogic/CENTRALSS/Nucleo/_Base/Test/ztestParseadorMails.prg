**********************************************************************
Define Class ztestParseadorMails as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as ztestParseadorMails of ztestParseadorMails.prg
	#ENDIF
	
	*---------------------------------
	Function Setup

	EndFunc
	
	*---------------------------------
	Function TearDown

	EndFunc

	*-----------------------------------------------------------------------------------------
	function ztestValidarParseoMailsConPuntoYComa
		local loParseador as ParserMails of ParserMails.prg, lcResultado as String

		loParseador = _screen.zoo.crearobjeto( "ParserMails" )
		lcCadenaAParsear = "mails1@sevidor1.com;mails1@sevidor2.com"
		loColeccionMails = loParseador.parsear( lcCadenaAParsear , ";" )
		
		this.assertequals( "Cantidad de mails.", 2, loColeccionMails.count )
		this.assertequals( "cadena correcta.", "mails1@sevidor1.com", loColeccionMails(1) )
		this.assertequals( "cadena correcta.", "mails1@sevidor2.com", loColeccionMails(2) )		
		
		release loParseador

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ztestValidarParseoMailsConPuntoYComaAlPrincipio
		local loParseador as ParserMails of ParserMails.prg, lcResultado as String

		loParseador = _screen.zoo.crearobjeto( "ParserMails" )
		lcCadenaAParsear = ";mails1@sevidor1.com;mails1@sevidor2.com"
		loColeccionMails = loParseador.parsear( lcCadenaAParsear , ";" )
		
		this.assertequals( "Cantidad de mails.", 2, loColeccionMails.count )
		this.assertequals( "cadena correcta.", "mails1@sevidor1.com", loColeccionMails(1) )
		this.assertequals( "cadena correcta.", "mails1@sevidor2.com", loColeccionMails(2) )		
		
		release loParseador

	endfunc 


	*-----------------------------------------------------------------------------------------
	function ztestValidarParseoMailsConComa
		local loParseador as ParserMails of ParserMails.prg, lcResultado as String

		loParseador = _screen.zoo.crearobjeto( "ParserMails" )
		lcCadenaAParsear = "mails1@sevidor1.com,mails1@sevidor2.com"
		loColeccionMails = loParseador.parsear( lcCadenaAParsear , ";" )
		
		this.assertequals( "Cantidad de mails.", 2, loColeccionMails.count )
		this.assertequals( "cadena correcta.", "mails1@sevidor1.com", loColeccionMails(1) )
		this.assertequals( "cadena correcta.", "mails1@sevidor2.com", loColeccionMails(2) )		
		
		release loParseador

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ztestValidarParseoMailsConEspacio
		local loParseador as ParserMails of ParserMails.prg, lcResultado as String

		loParseador = _screen.zoo.crearobjeto( "ParserMails" )
		lcCadenaAParsear = "mails1@sevidor1.com mails1@sevidor2.com"
		loColeccionMails = loParseador.parsear( lcCadenaAParsear , ";" )
		
		this.assertequals( "Cantidad de mails.", 2, loColeccionMails.count )
		this.assertequals( "cadena correcta.", "mails1@sevidor1.com", loColeccionMails(1) )
		this.assertequals( "cadena correcta.", "mails1@sevidor2.com", loColeccionMails(2) )		
		
		release loParseador

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ztestValidarParseoMailsConEspacioYpuntoYComa
		local loParseador as ParserMails of ParserMails.prg, lcResultado as String

		loParseador = _screen.zoo.crearobjeto( "ParserMails" )
		lcCadenaAParsear = "mails1@sevidor1.com ;mails1@sevidor2.com"
		loColeccionMails = loParseador.parsear( lcCadenaAParsear , ";" )
		
		this.assertequals( "Cantidad de mails.", 2, loColeccionMails.count )
		this.assertequals( "cadena correcta.", "mails1@sevidor1.com", loColeccionMails(1) )
		this.assertequals( "cadena correcta.", "mails1@sevidor2.com", loColeccionMails(2) )		
		
		release loParseador

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ztestValidarParseoMailsConEspacioYpuntoYComaMasEspacio
		local loParseador as ParserMails of ParserMails.prg, lcResultado as String

		loParseador = _screen.zoo.crearobjeto( "ParserMails" )
		lcCadenaAParsear = "mails1@sevidor1.com ; mails1@sevidor2.com"
		loColeccionMails = loParseador.parsear( lcCadenaAParsear , ";" )
		
		this.assertequals( "Cantidad de mails.", 2, loColeccionMails.count )
		this.assertequals( "cadena correcta.", "mails1@sevidor1.com", loColeccionMails(1) )
		this.assertequals( "cadena correcta.", "mails1@sevidor2.com", loColeccionMails(2) )		
		
		release loParseador

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ztestValidarEsUnAtributoOrganic
		local loParseador as ParserMails of ParserMails.prg, lcResultado as String

		loParseador = _screen.zoo.crearobjeto( "ParserMails" )
		lcCadenaAParsear = " .Cliente.eMail "
		loColeccionMails = loParseador.parsear( lcCadenaAParsear , ";" )
		
		this.assertequals( "Cantidad de mails.", 1, loColeccionMails.count )
		this.assertequals( "cadena correcta.", ".Cliente.eMail", loColeccionMails(1) )
		
		release loParseador

	endfunc 

EndDefine
