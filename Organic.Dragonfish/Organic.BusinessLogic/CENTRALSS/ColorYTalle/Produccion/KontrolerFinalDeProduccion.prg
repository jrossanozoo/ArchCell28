define class KontrolerFinalDeProduccion as din_KontrolerFinalDeProduccion of din_KontrolerFinalDeProduccion.prg

	#if .f.
		local this as KontrolerFinalDeProduccion of KontrolerFinalDeProduccion.prg
	#endif

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
		This.BindearEvento( This.oEntidad.Proceso, "AjustarObjetoBusqueda" , This.oEntidad, "SetearFiltroBuscadorProceso" )
		This.BindearEvento( This.oEntidad, "EventoPreguntarActualizarDetalle", This, "PreguntarActualizarDetalle" )
	endfunc

	*-----------------------------------------------------------------------------------------
	function PreguntarActualizarDetalle() as Void
		this.oEntidad.lContinuarConActualizacionDelDetalle = ( gomensajes.Preguntar( "Al cambiar el proceso se volverá a cargar el detalle. ¿Está seguro que desea continuar?", 4, 1 ) = 6 )
	endfunc

enddefine
