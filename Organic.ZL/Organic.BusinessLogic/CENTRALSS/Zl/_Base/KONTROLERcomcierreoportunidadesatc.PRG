Define Class kontrolercomcierreoportunidadesatc As din_kontrolercomcierreoportunidadesatc Of din_kontrolercomcierreoportunidadesatc.prg

	*-----------------------------------------------------------------------------------------
	Function inicializar() As Void
		DoDefault()
		This.enlazar( "oEntidad.EventoActualizarRazonSocial", "RefrescarCombo" )
		This.enlazar( "oEntidad.EventoRefrescarRZ", "RefrescarRZ" )
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function RefrescarCombo() As Void
		Local loControl As Object, lxValor As String
		loControl = This.obtenerControl( "RAZONSOCIAL" )
		With loControl
			.CargarDatosEnCursor( This.oentidad.cCursorCombo )
			.lDesplegarLista = Iif( .ObtenerCantidadDeElementos() > 1, .T., .F. )
			This.oentidad.lDesplegarComboRz = .lDesplegarLista 

			If .lDesplegarLista
			Else
				.EjecutarValid()
			Endif

			.refrescar()
		Endwith
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function RefrescarRZ() As Void
		Local loControl As Object, lcSql As String, lcValor As String, lcDescripcionRazonSocial As String
		lcValor = Alltrim( This.oentidad.Razonsocial_PK )
		loControl = This.obtenerControl( "RAZONSOCIAL" )

		With loControl
			lcDescripcionRazonSocial = .ObtenerDescripcionRAzonSocial( lcValor )
			.BorrarCursor()
			.ActualizarDatosControl( lcDescripcionRazonSocial, lcValor )
			.lDesplegarLista = Iif( .ObtenerCantidadDeElementos() > 1, .T., .F. )
			.refrescar()
		Endwith
	Endfunc


Enddefine
