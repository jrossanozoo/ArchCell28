**********************************************************************
Define Class ztesttimerbase as FxuTestCase OF FxuTestCase.prg

	#IF .f.
		Local this as ztesttimerbase of ztesttimerbase.prg
	#ENDIF
	
	lEstoyUsandoTimers = .F.
	oColleccionDeTimerOriginales = null
	
	*---------------------------------
	Function Setup
		this.lEstoyUsandoTimers = _screen.zoo.app.lEstoyUsandoTimers 
	EndFunc
	
	*---------------------------------
	Function TearDown
		_screen.zoo.app.lEstoyUsandoTimers = this.lEstoyUsandoTimers 			
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ztesttimerbase
		local lnEntradas as Integer, loObjeto as Object, lnCantidadDeTimerActuales as Integer, llBajarServicioTimer as Boolean
		
		_screen.zoo.app.lEstoyUsandoTimers = .T.

 
		private goTimer
		goTimer = _screen.zoo.crearobjeto( "TimerBase" )
		
		lnCantidadDeTimerActuales = goTimer.nCantidadDeTimers
		goTimer.inicializarTimers()
		this.asserttrue( "Luego de inicializar el timer base, no se incremento " + ;
				"la cantidad de timer del objeto timer.", lnCantidadDeTimerActuales < goTimer.nCantidadDeTimers )
		
		lnEntradas = 0
		loObjeto = newobject("ClasePrueba")
		
		bindevent( goTimer , "evento1sec", loObjeto, "evento1sec", 1 )
		
		do while !loObjeto.lTermine and lnentradas < 12		
			inkey(1)
			lnentradas = lnentradas + 1
		enddo 

		this.asserttrue( "Fallo el bindeo del timer base de 1 segundo de la aplicacion", loObjeto.lTermine )
		
		_screen.zoo.app.lEstoyUsandoTimers = .F.
		goTimer.MatarTodosLosTimers()
		loObjeto = null	
		goTimer = _Screen.zoo.app.oTimerBase
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestInicializarYMatarUnTimerEspecifico
		local lnEntradas as Integer, lnManejadorDeEsteTimer as Integer, lnCantidadDeTimerActuales as Integer, llBajarServicioTimer  as Boolean
		public goObjectoPublico

		private goTimer
		goTimer = _screen.zoo.crearobjeto( "TimerBase" )

		if vartype(goObjectoPublico) == "O"
			goObjectoPublico = null
		endif				
		_screen.zoo.app.lEstoyUsandoTimers = .T.
	
		lnEntradas = 0
		goObjectoPublico = newobject("ClasePrueba")
		
		lnCantidadDeTimerActuales = goTimer.nCantidadDeTimers

		lnManejadorDeEsteTimer = goTimer.CrearNuevoTimer( 1500, "goObjectoPublico", "evento1sec" )
		this.asserttrue( "Luego de Crear un nuevo timer, no se incremento " +;
				"la cantidad de timer del objeto timer.", lnCantidadDeTimerActuales < goTimer.nCantidadDeTimers )	
				
		do while !goObjectoPublico.lTermine and lnentradas < 12		
			inkey(1)
			lnentradas = lnentradas + 1
		enddo 

		this.asserttrue( "Fallo el bindeo del crearnuevotimer 1 segundo de la aplicacion", goObjectoPublico.lTermine )
		
		_screen.zoo.app.lEstoyUsandoTimers = .F.
		goTimer.MatarUnTimerEspecifico( lnManejadorDeEsteTimer )
		goObjectoPublico = null
		goTimer = _Screen.zoo.app.oTimerBase			
	endfunc
	*-----------------------------------------------------------------------------------------
	function zTestMatarTodosLosTimers
		local lnEntradas as Integer, loObjeto as Object, lnCantidadDeTimerActuales as Integer, llBajarServicioTimer  AS Boolean
		public goObjectoPublico

		lnEntradas = 0
		_screen.zoo.app.lEstoyUsandoTimers = .T.
		private goTimer
		goTimer = _screen.zoo.crearobjeto( "TimerBase" )
		
		if vartype( goObjectoPublico ) == "O"
			goObjectoPublico = null
		endif

		lnCantidadDeTimerActuales = goTimer.nCantidadDeTimers
		goTimer.inicializarTimers()
		this.asserttrue( "Luego de inicializar el timer base (zTestMatarTodosLosTimers), no se incremento " +;
				"la cantidad de timer del objeto timer.", (lnCantidadDeTimerActuales + 1 ) == goTimer.nCantidadDeTimers )
	
		loObjeto = newobject("ClasePrueba")
		goObjectoPublico = loObjeto
		
		bindevent( goTimer, "evento1sec", loObjeto, "evento1sec", 1 )
		
		lnCantidadDeTimerActuales = goTimer.nCantidadDeTimers
		goTimer.CrearNuevoTimer( 2000, "goObjectoPublico", "EventoLoko" )
		this.asserttrue( "Luego de crear el nuevo timer (zTestMatarTodosLosTimers), no se incremento " +;
				"la cantidad de timer del objeto timer.", (lnCantidadDeTimerActuales + 1 ) == goTimer.nCantidadDeTimers )
		
		do while lnentradas < 12		
			inkey(1)
			lnEntradas = lnEntradas + 1
		enddo 
		this.asserttrue( "No se iniciaron estos timers 2.", loObjeto.lTermine and goObjectoPublico.lEntroAlEventoLoko )
		
		goTimer.MatarTodosLosTimers()
		this.asserttrue( "Luego de Matar todos los timers, el contador de timer del objeto " + ;
					" timer no desconto ningun timer..", goTimer.nCantidadDeTimers == 0 )
		lnEntradas = 0
		loObjeto.entradas = 0
		loObjeto.lTermine = .f.
		goObjectoPublico.lEntroAlEventoLoko = .f.
		
		do while lnentradas < 6		
			inkey(1)
			lnEntradas = lnEntradas + 1
		enddo 
		this.asserttrue( "Luego de matartodos los timer, los timer siguieron corriendo.", !loObjeto.lTermine and !goObjectoPublico.lEntroAlEventoLoko )	
		
		_screen.zoo.app.lEstoyUsandoTimers = .F.
		loObjeto = null
		goObjectoPublico = null

		goTimer = _Screen.zoo.app.oTimerBase		
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function zTestFrenarYEncenderTodosLosTimers
		local lnEntradas as Integer, loObjeto as Object, lnCantidadDeTimerActuales as Integer, llBajarServicioTimer  AS Boolean
		public goObjectoPublico

		lnEntradas = 0
		_screen.zoo.app.lEstoyUsandoTimers = .T.

		private goTimer
		goTimer = _screen.zoo.crearobjeto( "TimerBase" )



		if vartype( goObjectoPublico ) == "O"
			goObjectoPublico = null
		endif

		goTimer.inicializarTimers()

		loObjeto = newobject("ClasePrueba")
		goObjectoPublico = loObjeto
		
		bindevent( goTimer, "evento1sec", loObjeto, "evento1sec", 1 )
		
		goTimer.CrearNuevoTimer( 1500, "goObjectoPublico", "EventoLoko" )
		
		do while lnentradas < 6		
			inkey(1)
			lnEntradas = lnEntradas + 1
		enddo
		
		this.asserttrue( "No se iniciaron estos timers 3.", loObjeto.lTermine and goObjectoPublico.lEntroAlEventoLoko )

		goTimer.FrenarTodosLosTimers()
		
		&&&&& Reseteamos el objeto de test  &&&&&&&&
		lnEntradas = 0
		loObjeto.entradas = 0
		loObjeto.lTermine = .f.
		goObjectoPublico.lEntroAlEventoLoko = .f.
		
		do while lnentradas < 6		
			inkey(1)
			lnEntradas = lnEntradas + 1
		enddo 
		this.ASSertequals( "La propiedad cEstadoDeLosTimers del objeto timer no dice 'FRENADOS' ERROR", "FRENADOS", goTimer.cEstadoDeLosTimers )
		this.asserttrue( "Luego de FRENAR los timer, los timer siguieron corriendo!!!!ERROR.", !loObjeto.lTermine and !goObjectoPublico.lEntroAlEventoLoko )	
		
		goTimer.EncenderTodosLosTimersFrenados()

		&&&&& Reseteamos el objeto de test  &&&&&&&&
		lnEntradas = 0
		loObjeto.entradas = 0
		loObjeto.lTermine = .f.
		goObjectoPublico.lEntroAlEventoLoko = .f.
		do while lnentradas < 6		
			inkey(1)
			lnEntradas = lnEntradas + 1
		enddo
		this.ASSertequals( "La propiedad cEstadoDeLosTimers del objeto timer no dice 'INICIADOS' ERROR", "INICIADOS", goTimer.cEstadoDeLosTimers )
		this.asserttrue( "Luego de EncenderTodosLosTimerFrenados No se iniciaron los Timers!! ! ERROR.", loObjeto.lTermine and goObjectoPublico.lEntroAlEventoLoko )
		
		_screen.zoo.app.lEstoyUsandoTimers = .F.
		loObjeto = null
		goObjectoPublico = null
		goTimer = _Screen.zoo.app.oTimerBase		
		
		
	endfunc 

enddefine


*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class clasePrueba as custom

	entradas = 0
	lTermine = .F.
	lEntroAlEventoLoko = .f.
	
	*-----------------------------------------------------------------------------------------
	function evento1sec()

		this.entradas = this.entradas + 1
		if this.entradas > 3
			this.lTermine = .T.
		endif 
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoLoko()
		this.lEntroAlEventoLoko = .t.
	endfunc 

enddefine