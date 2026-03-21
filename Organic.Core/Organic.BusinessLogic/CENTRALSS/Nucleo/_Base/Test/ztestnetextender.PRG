**********************************************************************
Define Class zTestNetExtender as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as zTestNetExtender of zTestNetExtender.prg
	#ENDIF
	
	lDesarrollo = .f.
	*---------------------------------
	Function Setup
		this.lDesarrollo = _screen.zoo.lDESARROLLO
	EndFunc
	
	*---------------------------------
	Function TearDown
		try
			_screen.zoo.lDESARROLLO = this.lDesarrollo
		catch to loError
			This.Asserttrue( "Este test dejo mal el valor de _screen.zoo.lDesarrollo", .f. )
		endtry
		
	EndFunc

	*-----------------------------------------------------------------------------------------
	function zTestCrearObjetoYEjecutarMetodos
		local loObjetoNet as Object, loError as zooexception OF zooexception.prg, lcDLLATestear as String
		lcDLLATestear = _screen.Zoo.cRutaInicial + "ClasesDePrueba\PruebaNetExtender.dll"
		_screen.zoo.lDesarrollo = .F.
		_screen.Zoo.AgregarReferencia( lcDLLATestear )

			loObjetoNet = _screen.Zoo.CrearObjeto( "ZooLogicSA.Pruebas.PruebaNetExtender" )
			this.AssertEquals( "El valor que retorno el método Ejecutar es incorrecto (1)", "Prueba Ok", loObjetoNet.Ejecutar( "Prueba Ok" ) )
			this.AssertEquals( "El valor que retorno el método Ejecutar es incorrecto (2)", "Prueba Ok", loObjetoNet.Ejecutar( "Prueba ", "Ok" ) )
		
			loObjetoNet = _screen.Zoo.CrearObjeto( "ZooLogicSA.Pruebas.PruebaNetExtender", "", date(2009,01,21) )
			this.assertequals( "No paso el parametro del constructor, dia", 21, loObjetoNet.FechaNacimiento.Day )
			this.assertequals( "No paso el parametro del constructor, mes", 1, loObjetoNet.FechaNacimiento.Month )
			this.assertequals( "No paso el parametro del constructor, año", 2009, loObjetoNet.FechaNacimiento.Year )
	endfunc

	*-----------------------------------------------------------------------------------------
	function zTestEnlazarYDesEnlazar
		local loClaseTest as object
		
		loClaseTest = newobject( "ClaseConEnlazar" )
		loClaseTest.Testear( this )
		loClaseTest.release()	
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestInstaciarClaseNetNativa
		local loWinForm as Object
		loWinForm = _screen.zoo.crearobjeto( "System.Windows.Forms.Form" )
		loWinForm.Text = "Título del WinForm"
		this.AssertEquals( "El valor de la propiedad text es incorrecto.", "Título del WinForm", loWinForm.Text )
		loWinForm = null
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function zTestInvocarMetodosEstaticos
		local lcDLLATestear as String, lcResultado as String
		lcDLLATestear = _screen.Zoo.cRutaInicial + "ClasesDePrueba\PruebaNetExtender.dll"
		_screen.Zoo.AgregarReferencia( lcDLLATestear )
		lcResultado = _screen.zoo.InvocarMetodoEstatico( "ZooLogicSA.Pruebas.PruebaNetExtender", "MetodoEstatico" )
		this.AssertEquals( "El valor que retorno el método MetodoEstatico es incorrecto (1)", "Resultado de Método Estático", lcResultado )
		lcResultado = _screen.zoo.InvocarMetodoEstatico( "ZooLogicSA.Pruebas.PruebaNetExtender", "MetodoEstatico", "Resultado de Método Estático Un Parámetro" )
		this.AssertEquals( "El valor que retorno el método MetodoEstatico es incorrecto (2)", "Resultado de Método Estático Un Parámetro", lcResultado )
	endfunc

enddefine

*-----------------------------------------------------------------------------------------
define class ClaseConEnlazar as zooSession of zooSession.prg
	ObjetoNet = null
	llEntroAlEvento = .F.
	lcTexto = ""
	*-----------------------------------------------------------------------------------------
	function Testear( toFxu as Object ) as Void
	
		local loObjetoNet as Object, loError as zooexception OF zooexception.prg, lcDLLATestear as String
		lcDLLATestear = _screen.Zoo.cRutaInicial + "ClasesDePrueba\PruebaNetExtender.dll"
		_screen.Zoo.AgregarReferencia( lcDLLATestear )

		this.ObjetoNet = _screen.Zoo.CrearObjeto( "ZooLogicSA.Pruebas.PruebaNetExtender" )
		this.enlazar( "objetoNet.Evento1", "respuestaAlEvento" )
		toFxu.AssertEquals( "El evento no se capturo correctamente", "PrimerParametroAgregadoDesdeC#", this.ObjetoNet.MetodoConEvento( "PrimerParametro" ) )


		this.bindearEvento( this.objetoNet,"EventoConArgumento", this, "RespuestaAlEventoConParametro" )
		this.llEntroAlEvento = .F.
		toFxu.AssertEquals( "El evento no se capturo correctamente", "PrimerParametroDesdeElEventoDesdeRespuesta", this.ObjetoNet.MetodoConEventoConArgumento( "PrimerParametro" ) )
		toFxu.AssertTrue( "Algo fallo en el bindeo", this.llEntroAlEvento )
		
		this.llEntroAlEvento = .F.
		this.DesBindearEvento( this.objetoNet,"EventoConArgumento", this, "RespuestaAlEventoConParametro" )
		toFxu.AssertEquals( "El evento no desbindeo", "PrimerParametro", this.ObjetoNet.MetodoConEventoConArgumento( "PrimerParametro" ) )			
		toFxu.AssertTrue( "Algo fallo en el desbindeo", !this.llEntroAlEvento )

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function RespuestaAlEvento() as Void
		this.llEntroAlEvento = .T.
	endfunc 
	*-----------------------------------------------------------------------------------------
	function RespuestaAlEventoConParametro( toSender as Object , toArgumento as Object ) as Void
		this.llEntroAlEvento = .T.
		toArgumento.Message = toArgumento.Message + "DesdeRespuesta"
	endfunc 

enddefine