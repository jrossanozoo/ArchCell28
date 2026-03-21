**********************************************************************
Define Class zTestMensajeEntidad as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as zTestMensajeEntidad of zTestMensajeEntidad.prg
	#ENDIF
	
	*---------------------------------
	Function Setup

	EndFunc
	
	*---------------------------------
	Function TearDown

	EndFunc

	*-----------------------------------------------------------------------------------------
	function zTestU_Metodos
		Local loTipo As mensajeentidad Of mensajeentidad.prg

		loTipo = _screen.zoo.crearobjeto( "mensajeentidad", "", this )
		This.AssertTrue( "No existe el metodo Alertar", pemstatus( loTipo, "Alertar", 5 ) )
		This.AssertTrue( "No existe el metodo Advertir", pemstatus( loTipo, "Advertir", 5 ) )		
		This.AssertTrue( "No existe el metodo Preguntar", pemstatus( loTipo, "Preguntar", 5 ) )				
		This.AssertTrue( "No existe el metodo Informar", pemstatus( loTipo, "Informar", 5 ) )						
		This.AssertTrue( "No existe el metodo EventoMensaje", pemstatus( loTipo, "EventoMensaje", 5 ) )
		This.AssertTrue( "No existe el metodo SetearRespuesta", pemstatus( loTipo, "SetearRespuesta", 5 ) )				
		This.AssertTrue( "No existe el metodo ObtenerRespuesta", pemstatus( loTipo, "ObtenerRespuesta", 5 ) )						
		loTipo = null	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestU_ParametrosEventoMensaje
		Local loTipo As mensajeentidad Of mensajeentidad.prg, loError as zooexception OF zooexception.prg
		loTipo = _screen.zoo.crearobjeto( "mensajeentidad", "", this )
		
		try
			loTipo.Preguntar( "Mensaje", 1, 1, "Titulo", 10 )
		catch to loError
			This.AssertTrue( "No deberia pinchar por los parametros", .f. )
			throw loError
		endtry
		
		loTipo = null			
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestPropiedad_DefaultRespuestaEventoMensaje
		Local loTipo As mensajeentidad Of mensajeentidad.prg
		loTipo = _screen.zoo.crearobjeto( "mensajeentidad", "", this )
		
		this.AssertEquals( "La respuesta es incorrecta (0)", 1, loTipo.Alertar( "Mensaje" ) )
		
		this.AssertEquals( "La respuesta es incorrecta (1)", 1, loTipo.Advertir( "Mensaje", 1 ) )		
		this.AssertEquals( "La respuesta es incorrecta (1.1)", 2, loTipo.Advertir( "Mensaje", 1, 1 ) )				
		
		this.AssertEquals( "La respuesta es incorrecta (2)", 3, loTipo.Preguntar( "Mensaje", 2 ) )
		this.AssertEquals( "La respuesta es incorrecta (2.1)", 4, loTipo.Preguntar( "Mensaje", 2, 1 ) )
		this.AssertEquals( "La respuesta es incorrecta (2.2)", 5, loTipo.Preguntar( "Mensaje", 2, 2 ) )
						
		this.AssertEquals( "La respuesta es incorrecta (3)", 6, loTipo.Informar( "Mensaje", 3 ) )
		this.AssertEquals( "La respuesta es incorrecta (3.1)", 7, loTipo.Informar( "Mensaje", 3, 1 ) )
		this.AssertEquals( "La respuesta es incorrecta (3.2)", 2, loTipo.Informar( "Mensaje", 3, 2 ) )
		
		this.AssertEquals( "La respuesta es incorrecta (4)", 6, loTipo.Alertar( "Mensaje", 4 ) )
		this.AssertEquals( "La respuesta es incorrecta (4.1)", 7, loTipo.Alertar( "Mensaje", 4, 1 ) )
				
		this.AssertEquals( "La respuesta es incorrecta (5)", 4, loTipo.Advertir( "Mensaje", 5 ) )
		this.AssertEquals( "La respuesta es incorrecta (5.1)", 2, loTipo.Advertir( "Mensaje", 5, 1 ) )
				
		this.AssertEquals( "La respuesta es incorrecta (6)", 1, loTipo.Advertir( "Mensaje", 6 ) )		
		this.AssertEquals( "La respuesta es incorrecta (6.1)", 2, loTipo.Advertir( "Mensaje", 6, 1 ) )		
				
		this.AssertEquals( "La respuesta es incorrecta (10)", 2, loTipo.Preguntar( "Mensaje", 10 ) )
		
		loTipo = null			
	endfunc 
EndDefine
