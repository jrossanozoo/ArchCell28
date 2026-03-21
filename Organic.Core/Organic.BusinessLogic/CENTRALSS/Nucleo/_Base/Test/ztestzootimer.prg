**********************************************************************
Define Class ztestzootimer as FxuTestCase OF FxuTestCase.prg

	#IF .f.
	Local this as ztestzootimer of ztestzootimer.prg
	#ENDIF
	oTimerBaseOriginal = null
	*---------------------------------
	Function Setup
		this.oTimerBaseOriginal = _screen.Zoo.app.oTimerBase
	EndFunc
	
	*---------------------------------
	Function TearDown
		_screen.Zoo.app.oTimerBase = this.oTimerBaseOriginal
	EndFunc
	*-----------------------------------------------------------------------------------------
	function ztestzootimer
		
		local loTimer as object, loClasePrueba as object, loTimerBaseMock as object 

		loTimerBaseMock = newobject("TimerBaseMock")
		_screen.Zoo.app.oTimerBase = loTimerBaseMock

		loTimer = _screen.Zoo.crearObjeto("zootimer")
		loClasePrueba = newobject("ClasePrueba")

		
		bindevent( loTimer , "evento1sec", loClasePrueba, "evento1sec", 1 )
		
		_screen.Zoo.app.oTimerBase.evento1sec()		
		
		this.assertequals( "El evento del timer no llego 1 ", 1, loClasePrueba.entradas )

		_screen.Zoo.app.oTimerBase.evento1sec()		
		_screen.Zoo.app.oTimerBase.evento1sec()		
		_screen.Zoo.app.oTimerBase.evento1sec()		
		
		this.assertequals( "El evento del timer no llego 2 ", 4, loClasePrueba.entradas )
		
		loTimerBaseMock = _screen.Zoo.app.oTimerBase
		
		loClasePrueba = null

		loTimer.release()
		loTimer = null

		loTimerBaseMock = null

	endfunc 

enddefine

*-----------------------------------------------------------------------------------------
define class clasePrueba as custom
	entradas = 0
	function evento1sec()
		this.entradas = this.entradas + 1
	endfunc
enddefine
*-----------------------------------------------------------------------------------------
define class TimerBaseMock as custom
	function evento1sec()

	endfunc
enddefine


