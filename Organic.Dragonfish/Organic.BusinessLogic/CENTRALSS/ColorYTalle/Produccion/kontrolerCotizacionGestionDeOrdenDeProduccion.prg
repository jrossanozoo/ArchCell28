Define Class kontrolerCotizacionGestionDeOrdenDeProduccion as din_kontrolerCotizacionGestionDeOrdenDeProduccion of din_kontrolerCotizacionGestionDeOrdenDeProduccion.prg

	#if .f.
		local this as kontrolerCotizacionGestionDeOrdenDeProduccion of kontrolerCotizacionGestionDeOrdenDeProduccion.prg
	#endif

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
		this.BindearEvento( this.oEntidad, "eventoDespuesDeActualizarDetalle", this, "ActualizarDetalle" )
		this.BindearEvento( this.oEntidad, "EventoIniciarProceso", this, "IniciarProceso" )
		this.BindearEvento( this.oEntidad, "EventoFinalizarProceso", this, "FinalizarProceso" )
		This.BindearEvento( This.oEntidad, "EventoPreguntarActualizarDetalle", This, "PreguntarActualizarDetalle" )
		This.BindearEvento( This.oEntidad, "EventoPreguntarActualizarCostos", This, "PreguntarActualizarCostos" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ActualizarDetalle( tcTipoDetalle as String, tnFilaActiva as integer ) as Void
		this.RefrescarDetalle()
		if type("tcTipoDetalle") = 'C' and !empty(tcTipoDetalle) and type('tnFilaActiva') = 'N' and tnFilaActiva >= 0
			dodefault(tcTipoDetalle, tnFilaActiva)
		else
			if type("tcTipoDetalle") = 'C' and !empty(tcTipoDetalle)
				this.RefrescarDetalle(tcTipoDetalle)
			else
				this.RefrescarDetalle("CotizacionOrdenProduccion")
				this.RefrescarDetalle("CotizacionOrdenDescarte")
				this.RefrescarDetalle("CotizacionOrdenInsumos")
				this.RefrescarDetalle("CotizacionOrdenAdicionales")
			endif
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function BindearBusquedaArticuloConcepto() as Void
		local loControl as Control
		if this.ExisteControl( "ARTICULO" ) 
			loControl = this.obtenerControl( "ARTICULO" )
			if pemstatus(loControl,"oentidad",5) and vartype(loControl.oEntidad) = "O"
				bindevent( loControl.oentidad ,"AjustarObjetoBusqueda",this, "FiltrarBusquedaArticuloConcepto", 1 )
			endif
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function FiltrarBusquedaArticuloConcepto( toBusqueda as Object ) as Void
		toBusqueda.filtro = toBusqueda.filtro + iif( empty(toBusqueda.filtro), "", " and ") +  "(comportamiento = 2 )"
	endfunc 

	*-----------------------------------------------------------------------------------------
	function IniciarProceso( tcMensaje as String ) as Void
		this.oMensaje.EnviarSinEsperaProcesandoEnEscritorio( tcMensaje )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function FinalizarProceso() as Void
		this.oMensaje.Enviarsinesperaprocesando()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function PreguntarActualizarDetalle() as Void
		local lcMensaje as String
		lcMensaje = "Atención! Se detectaron los siquientes cambios: " + chr(10) + chr(13)
		lcMensaje = lcMensaje + " - Gestión de producción " + chr(10) + chr(13)
		lcMensaje = lcMensaje + " Se volveran a cargar los detalles en base a la nueva gestión" + chr(10) + chr(13)
		lcMensaje = lcMensaje + " ¿Está seguro que desea continuar?"
		this.oEntidad.lContinuarConActualizacionDeDetalles = ( gomensajes.Preguntar( lcMensaje, 4, 1 ) = 6 )
	endfunc

	*-----------------------------------------------------------------------------------------
	function PreguntarActualizarCostos() as Void
		local lcMensaje as String
		lcMensaje = "Atención! Se detectaron los siquientes cambios: " + chr(10) + chr(13)
		lcMensaje = lcMensaje + " - Lista de costo " + chr(10) + chr(13)
		lcMensaje = lcMensaje + " Los costos se recalcularán en base a la nueva lista" + chr(10) + chr(13)
		lcMensaje = lcMensaje + " ¿Está seguro que desea continuar?"
		this.oEntidad.lContinuarConActualizacionDeCostos = ( gomensajes.Preguntar( lcMensaje, 4, 1 ) = 6 )
	endfunc

EndDefine
