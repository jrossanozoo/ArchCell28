define class kontrolerCurvaDeProduccion as din_kontrolerCurvaDeProduccion of din_kontrolerCurvaDeProduccion.PRG

	#If .F.
		Local This As kontrolerCurvaDeProduccion As kontrolerCurvaDeProduccion.prg
	#Endif

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
		bindevent( this.oEntidad, 'eventoMensajeConfirmar', this, 'MensajeConfirmar', 1 )
		This.BindearEvento( This.oEntidad, "eventoRefrescarDetalle" , This, "RefrescarDetalle" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function MensajeConfirmar( tcMensaje as String, tcMensajeCancelacion as String ) as Void
		if goMensajes.Preguntar(tcMensaje, 1,, 'Cambio de curva de producción') == 2
			this.oEntidad.lActualizarDetalle = .f.
			goServicios.Errores.LevantarExcepcion(tcMensajeCancelacion)
		endif
	EndFunc 

	*-----------------------------------------------------------------------------------------
	function RefrescarDetalle( tcDetalle as String ) as Void
		local loZooGrilla as Object
		if This.Existecontrol( tcDetalle )
			loZooGrilla = This.ObtenerControl( tcDetalle )
			loZooGrilla.RefrescarGrilla()
		endif
	endfunc 

enddefine
