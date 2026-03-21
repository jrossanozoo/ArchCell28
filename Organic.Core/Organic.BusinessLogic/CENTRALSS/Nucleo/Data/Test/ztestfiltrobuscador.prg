**********************************************************************
Define Class ztestfiltrobuscador as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as ztestfiltrobuscador of ztestfiltrobuscador.prg
	#ENDIF
	
	*---------------------------------
	Function Setup

	EndFunc
	
	*---------------------------------
	Function TearDown

	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestU_SentenciaFiltroBuscador_Cliente_pk_Lleno
		local loTarget as Object, lcResultado as String, lcEsperado as String, loEntidad as Object, lcTextoAProcesar as String
		
		loTarget = newobject( "FiltroBuscador", "FiltroBuscador.prg" )
		loEntidad = newobject( "MockEntidad" )
		loEntidad.Cliente_PK = "Lleno"

		lcTextoAProcesar = [IIf ( Empty( <<YO.Cliente_pk>>) , "TRUE", "contact.ccliente = '" + <<YO.Cliente.Nombre>> + "' and Contact.desacti = FALSE")]
		lcResultado = loTarget.ObtenerFiltroBuscador( lcTextoAProcesar, loEntidad )
		
		lcEsperado = "contact.ccliente = 'Nombre del cliente' and Contact.desacti = FALSE"
		this.assertequals( "El resultado no es el esperado", lcEsperado, lcResultado )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestU_SentenciaFiltroBuscador_Cliente_pk_Vacio
		local loTarget as Object, lcResultado as String, lcEsperado as String, loEntidad as Object, lcTextoAProcesar as String
		
		lcEsperado = "TRUE"
		loTarget = newobject( "FiltroBuscador", "FiltroBuscador.prg" )
		loEntidad = newobject( "MockEntidad" )

		loEntidad.Cliente_PK = ""
		lcTextoAProcesar = [IIf ( Empty( <<YO.Cliente_pk>>) , "TRUE", "contact.ccliente = '" + <<YO.Cliente.Nombre>> + "' and Contact.desacti = FALSE")]
		lcResultado = loTarget.ObtenerFiltroBuscador( lcTextoAProcesar, loEntidad )
		
		this.assertequals( "El resultado no es el esperado", lcEsperado, lcResultado )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestU_SentenciaFiltroBuscador_SentenciaVacia
		local loTarget as Object, lcResultado as String, lcEsperado as String, loEntidad as Object, lcTextoAProcesar as String
		
		lcEsperado = ""
		loTarget = newobject( "FiltroBuscador", "FiltroBuscador.prg" )
		loEntidad = newobject( "MockEntidad" )

		loEntidad.Cliente_PK = ""
		lcTextoAProcesar = ""
		lcResultado = loTarget.ObtenerFiltroBuscador( lcTextoAProcesar, loEntidad )
		
		this.assertequals( "El resultado no es el esperado", lcEsperado, lcResultado )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestU_SentenciaFiltroBuscador_ConFuncionesSql
		local loTarget as Object, lcResultado as String, lcEsperado as String, loEntidad as Object, lcTextoAProcesar as String
		
		lcEsperado = "year(FecEQSR)>2000"
		loTarget = newobject( "FiltroBuscador", "FiltroBuscador.prg" )
		loEntidad = newobject( "MockEntidad" )

		loEntidad.Cliente_PK = ""
		lcTextoAProcesar = ["year(FecEQSR)>2000"]
		lcResultado = loTarget.ObtenerFiltroBuscador( lcTextoAProcesar, loEntidad )
		
		this.assertequals( "El resultado no es el esperado", lcEsperado, lcResultado )
	endfunc 


enddefine

define class MockEntidad as Custom
	Cliente_PK = "Codigo del cliente"
	Cliente = null
		*-----------------------------------------------------------------------------------------
	function Init() as Void
		this.Cliente = newobject( "custom" )
		this.Cliente.AddProperty( "Nombre", "Nombre del cliente" )
	endfunc 
enddefine
