**********************************************************************
DEFINE CLASS zTestColaboradorVolumenDeDatos as FxuTestCase OF FxuTestCase.prg
	#IF .f.
	LOCAL THIS AS zTestColaboradorVolumenDeDatos OF zTestColaboradorVolumenDeDatos.PRG
	#ENDIF
	
	********************************************************************
	function Setup
	
	endfunc

	********************************************************************
	FUNCTION TearDown

	ENDFUNC

	*-----------------------------------------------------------------------------------------
	Function zTestI_ObtenerStringSinSaltoDeLineaPorColaborador 
		
		local loColaborador as Object, lnI as Number, lnRepeticiones as Number, lcCadena as String,;
			lcRetorno as String
		
		lcCadena = "Hola mundo"
		lnRepeticiones = 5
		
		loColaborador = _screen.zoo.crearobjeto( "ColaboradorVolumenDeDatos" )
		
		for lnI = 1 to lnRepeticiones
			loColaborador.Escribir( lcCadena )
		endfor
		
		lcRetorno = loColaborador.ObtenerCadenaDeCaracteres()
		
		release loColaborador
		
		this.AssertEquals("Retorno incorrecto.",replicate("Hola mundo",5),lcRetorno)	
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function zTestI_ObtenerStringConSaltoDeLineaPorColaborador 
		
		local loColaborador as Object, lnI as Number, lnRepeticiones as Number, lcCadena as String,;
			lcRetorno as String
		
		lcCadena = "Hola mundo"
		lnRepeticiones = 5
		
		loColaborador = _screen.zoo.crearobjeto( "ColaboradorVolumenDeDatos" )
		
		for lnI = 1 to lnRepeticiones
			loColaborador.EscribirLinea( lcCadena )
		endfor
		
		lcRetorno = loColaborador.ObtenerCadenaDeCaracteres()
		
		release loColaborador
		
		this.AssertEquals("Retorno incorrecto.",replicate("Hola mundo" + chr(13) + chr(10),5),lcRetorno)
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function zTestI_ObtenerArchivoSinSaltoDeLineaPorColaborador 
		
		local loColaborador as Object, lnI as Number, lnRepeticiones as Number, lcCadena as String,;
			lcRetorno as String, lcArchivo as String
		
		lcCadena = "Hola mundo"
		lnRepeticiones = 5
		
		loColaborador = _screen.zoo.crearobjeto( "ColaboradorVolumenDeDatos" )
		
		for lnI = 1 to lnRepeticiones
			loColaborador.Escribir( lcCadena )
		endfor
		
		lcArchivo = SYS(2023) + "\" + SYS(2015) + ".txt"
		
		loColaborador.GuardarEnDocumento( lcArchivo )
		
		this.AssertEquals( "No se ha generado el documento.", .T., file( lcArchivo ))
		
		lcRetorno = filetostr( lcArchivo )
		
		delete file (lcArchivo)
		
		release loColaborador
		
		this.AssertEquals( "El documento no tiene datos.", .F., empty( lcRetorno ))
		
		this.AssertEquals("Retorno incorrecto.",replicate("Hola mundo",5),lcRetorno)
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function zTestI_ObtenerArchivoConSaltoDeLineaPorColaborador 
		
		local loColaborador as Object, lnI as Number, lnRepeticiones as Number, lcCadena as String,;
			lcRetorno as String, lcArchivo as String
		
		lcCadena = "Hola mundo"
		lnRepeticiones = 5
		
		loColaborador = _screen.zoo.crearobjeto( "ColaboradorVolumenDeDatos" )
		
		for lnI = 1 to lnRepeticiones
			loColaborador.EscribirLinea( lcCadena )
		endfor
		
		lcArchivo = SYS(2023) + "\" + SYS(2015) + ".txt"
		
		loColaborador.GuardarEnDocumento( lcArchivo )
		
		this.AssertEquals( "No se ha generado el documento.", .T., file( lcArchivo ))
		
		lcRetorno = filetostr( lcArchivo )
		
		delete file (lcArchivo)
		
		release loColaborador
		
		this.AssertEquals( "El documento no tiene datos.", .F., empty( lcRetorno ))
		
		this.AssertEquals("Retorno incorrecto.",replicate("Hola mundo" + chr(13) + chr(10),5),lcRetorno)

	endfunc

ENDDEFINE
