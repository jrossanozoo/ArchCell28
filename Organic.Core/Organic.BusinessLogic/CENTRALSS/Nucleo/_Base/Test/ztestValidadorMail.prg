**********************************************************************
Define Class ztestValidadorMail as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as ztestValidadorMail of ztestValidadorMail.prg
	#ENDIF
	
	*---------------------------------
	Function Setup

	EndFunc
	
	*---------------------------------
	Function TearDown

	EndFunc


	*-----------------------------------------------------------------------------------------
	function zTestValidarMail
		local loValidador as ValidadorMail of ValidadorMail.prg
		
		loValidador = _screen.zoo.crearobjeto( "ValidadorMail" )
		llResultado = loValidador.Validar( "Cuenta@servidor.dominio" )

		this.asserttrue( "Validacion incorrecta.", llResultado )
		
		release loValidador

	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestValidarMailSinDominio
		local loValidador as ValidadorMail of ValidadorMail.prg
		
		loValidador = _screen.zoo.crearobjeto( "ValidadorMail" )
		llResultado = loValidador.Validar( "Cuenta@dominio" )
		this.asserttrue( "Validacion incorrecta.", !llResultado )
		
		release loValidador

	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestValidarMailSinUsuario
		local loValidador as ValidadorMail of ValidadorMail.prg
		
		loValidador = _screen.zoo.crearobjeto( "ValidadorMail" )
		llResultado = loValidador.Validar( "@servidor.dominio" )

		this.asserttrue( "Validacion incorrecta.", !llResultado )
		
		release loValidador

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestValidarMailCaracteresIncorrectos
		local loValidador as ValidadorMail of ValidadorMail.prg
		
		loValidador = _screen.zoo.crearobjeto( "ValidadorMail" )
		llResultado = loValidador.Validar( "Usuario@ser'vidor.dominio" )

		this.asserttrue( "Validacion incorrecta.", !llResultado )
		
		release loValidador

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestValidarMailMuchosDominios
		local loValidador as ValidadorMail of ValidadorMail.prg
		
		loValidador = _screen.zoo.crearobjeto( "ValidadorMail" )
		llResultado = loValidador.Validar( "Usuario@servidor.dominio.edu.ar" )

		this.asserttrue( "Validacion incorrecta.", llResultado )
		
		release loValidador

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestValidarMailConDominioNumerico
		local loValidador as ValidadorMail of ValidadorMail.prg, llResultado as boolean
		
		loValidador = _screen.Zoo.CrearObjeto( "ValidadorMail" )
		llResultado = loValidador.Validar( "Usuario@1234.com" )
		
		this.AssertTrue( "Debería considerarse válido un mail con dominio numérico.", llResultado )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestValidarMailConVariosDominiosNumericos
		local loValidador as ValidadorMail of ValidadorMail.prg, llResultado as boolean
		
		loValidador = _screen.Zoo.CrearObjeto( "ValidadorMail" )
		llResultado = loValidador.Validar( "Usuario@1234.567.89.com" )
		
		this.AssertTrue( "Debería considerarse válido un mail con varios dominios numéricos.", llResultado )
	endfunc

EndDefine
