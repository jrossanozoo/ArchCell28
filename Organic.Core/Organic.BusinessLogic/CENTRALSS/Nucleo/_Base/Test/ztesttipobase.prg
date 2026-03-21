**********************************************************************
Define Class zTestTipoBase As FxuTestCase Of FxuTestCase.prg

	#If .F.
		Local This As zTestTipoBase Of zTestTipoBase.prg
	#Endif
	*---------------------------------
	Function zTestAbstracta
		Local loTipo as TipoBase Of TipoBase.prg
		loTipo = NewObject( "TipoBase", "TipoBase.prg" )
		this.AssertTrue( "No tiene que poder instanciarse", vartype( loTipo ) # "O" )
	Endfunc
	*---------------------------------
	Function zTestConcreta
		Local loTipo As TipoBase Of TipoBase.prg
		loTipo = CreateObject( "Concreta" )
		This.AssertTrue( "No se pudo instanciar", Vartype( loTipo ) = "O" )
		loTipo.release()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestPropiedad_oMensajeEntidad
		Local loTipo As TipoBase Of TipoBase.prg
		loTipo = CreateObject( "Concreta" )
		This.AssertTrue( "No existe la propiedad oMensaje", pemstatus( loTipo, "oMensaje", 5 ) )
		loTipo.release()		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTest_MensajeMetodosPublicos
		Local loTipo As TipoBase Of TipoBase.prg
		loTipo = CreateObject( "Concreta" )
		This.AssertTrue( "No existe el metodo publico oMensaje.Advertir", pemstatus( loTipo.oMensaje, "Advertir", 5 ) )
		This.AssertTrue( "No existe el metodo publico oMensaje.Preguntar", pemstatus( loTipo.oMensaje, "Preguntar", 5 ) )
		This.AssertTrue( "No existe el metodo publico oMensaje.Alertar", pemstatus( loTipo.oMensaje, "Alertar", 5 ) )
		This.AssertTrue( "No existe el metodo publico oMensaje.Informar", pemstatus( loTipo.oMensaje, "Informar", 5 ) )						
		loTipo.release()		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function zTestPropiedad_ParametrosEventoMensaje
		Local loTipo As TipoBase Of TipoBase.prg, loError as zooexception OF zooexception.prg
		loTipo = CreateObject( "Concreta" )
		
		try
			loTipo.oMensaje.Advertir( "Mensaje", 1, 1, "Titulo", 10 )
		catch to loError 
			This.AssertTrue( "No deberia pinchar por los parametros", .f. )
			throw loError
		endtry
		
		loTipo.release()		
	endfunc 
Enddefine
*============
Define Class Concreta As TipoBase Of TipoBase.prg
Enddefine

