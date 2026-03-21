**********************************************************************
Define Class ztestsentenciasbuscador as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as ztestsentenciasbuscador of ztestsentenciasbuscador.prg
	#ENDIF
	
	*---------------------------------
	Function Setup

	EndFunc
	
	*---------------------------------
	Function TearDown

	EndFunc

	*-----------------------------------------------------------------------------------------
	function zTestSentenciaString
		local loTarget as Object, lcResultado as String, lcEsperado as String 
		
		loTarget = newobject( "SentenciasBuscador", "SentenciasBuscador.prg" )
		lcResultado = loTarget.ObtenerWhere( "cd", "campo1 ", " C  " )
		
		lcEsperado = "<<occurs( 'CD', 'CAMPO1', 'C' )>>"
		this.assertequals( "El resultado no es el esperado", lcEsperado, lcResultado )
	endfunc 


	*-----------------------------------------------------------------------------------------
	function zTestU_SentenciaBooleano_1
		local loTarget as Object, lcResultado as String, lcEsperado as String, lcIngresado as String
		
		loTarget = newobject( "SentenciasBuscador", "SentenciasBuscador.prg" )
		lcEsperado = "campo23 = 1"
		lcIngresado = "1"
		lcResultado = loTarget.ObtenerWhere( lcIngresado, "campo23 ", "L" )
		this.assertequals( "El resultado ingresando " + lcIngresado + " no es el esperado", lcEsperado, lcResultado )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestU_SentenciaBooleano_SI
		local loTarget as Object, lcResultado as String, lcEsperado as String, lcIngresado as String
		
		loTarget = newobject( "SentenciasBuscador", "SentenciasBuscador.prg" )
		lcEsperado = "campo23 = 1"
		lcIngresado = "SI"
		lcResultado = loTarget.ObtenerWhere( lcIngresado, "campo23 ", "L" )
		this.assertequals( "El resultado ingresando " + lcIngresado + " no es el esperado", lcEsperado, lcResultado )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestU_SentenciaBooleano_TRUE
		local loTarget as Object, lcResultado as String, lcEsperado as String, lcIngresado as String
		
		loTarget = newobject( "SentenciasBuscador", "SentenciasBuscador.prg" )
		lcEsperado = "campo23 = 1"
		lcIngresado = "TRUE"
		lcResultado = loTarget.ObtenerWhere( lcIngresado, "campo23 ", "L" )
		this.assertequals( "El resultado ingresando " + lcIngresado + " no es el esperado", lcEsperado, lcResultado )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestU_SentenciaBooleano_T
		local loTarget as Object, lcResultado as String, lcEsperado as String, lcIngresado as String
		
		loTarget = newobject( "SentenciasBuscador", "SentenciasBuscador.prg" )
		lcEsperado = "campo23 = 1"
		lcIngresado = ".T."
		lcResultado = loTarget.ObtenerWhere( lcIngresado, "campo23 ", "L" )
		this.assertequals( "El resultado ingresando " + lcIngresado + " no es el esperado", lcEsperado, lcResultado )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestU_SentenciaBooleano_si_minusucula
		local loTarget as Object, lcResultado as String, lcEsperado as String, lcIngresado as String
		
		loTarget = newobject( "SentenciasBuscador", "SentenciasBuscador.prg" )
		lcEsperado = "campo23 = 1"
		lcIngresado = "si"
		lcResultado = loTarget.ObtenerWhere( lcIngresado, "campo23 ", "L" )
		this.assertequals( "El resultado ingresando " + lcIngresado + " no es el esperado", lcEsperado, lcResultado )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestU_SentenciaBooleano_true_minuscula
		local loTarget as Object, lcResultado as String, lcEsperado as String, lcIngresado as String
		
		loTarget = newobject( "SentenciasBuscador", "SentenciasBuscador.prg" )
		lcEsperado = "campo23 = 1"
		lcIngresado = "true"
		lcResultado = loTarget.ObtenerWhere( lcIngresado, "campo23 ", "L" )
		this.assertequals( "El resultado ingresando " + lcIngresado + " no es el esperado", lcEsperado, lcResultado )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestU_SentenciaBooleano_t_minuscula
		local loTarget as Object, lcResultado as String, lcEsperado as String, lcIngresado as String
		
		loTarget = newobject( "SentenciasBuscador", "SentenciasBuscador.prg" )
		lcEsperado = "campo23 = 1"
		lcIngresado = ".t."
		lcResultado = loTarget.ObtenerWhere( lcIngresado, "campo23 ", "L" )
		this.assertequals( "El resultado ingresando " + lcIngresado + " no es el esperado", lcEsperado, lcResultado )
	endfunc 
enddefine

