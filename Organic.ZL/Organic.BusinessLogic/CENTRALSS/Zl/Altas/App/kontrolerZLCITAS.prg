define class kontrolerZLCitas as DIN_KontrolerZLCitas of DIN_KontrolerZLCitas.prg

	*-----------------------------------------------------------------------------------------
	function Inicializar()
		dodefault()
		bindevent( this.oEntidad, "EventoResultadoCreacionCita", this, "InformarResultadoCreacionCita", 1 )
	endfunc

	*-----------------------------------------------------------------------------------------
	function InformarResultadoCreacionCita( tcMensaje as String ) as Void
		goServicios.Mensajes.Enviar( tcMensaje )
	endfunc

enddefine
