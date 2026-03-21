define class Servicio as zooSession of zooSession.prg

	#IF .f.
		Local this as Servicio of Servicio.prg
	#ENDIF

	*-----------------------------------------------------------------------------------------
	function Iniciar() as Void

	endfunc 

	*-----------------------------------------------------------------------------------------
	function Detener() as Void
		this.Release()
	endfunc 

enddefine
