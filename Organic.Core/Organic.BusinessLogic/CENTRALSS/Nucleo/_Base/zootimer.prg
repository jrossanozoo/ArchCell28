define class zootimer as zooClaseBase of zooClaseBase.prg

	#IF .f.
		Local this as zootimer of zootimer.prg
	#ENDIF

	llamadas = 0

	*-----------------------------------------------------------------------------------------
	function init()
		bindevent( _screen.zoo.app.oTimerBase, "evento1sec", this, "evento1sec", 1 )
	endfunc

	*-----------------------------------------------------------------------------------------
	function evento1sec() as Void
		***Sin codigo, es solo un evento para que desde afuera se bindeen
	endfunc 

enddefine
