Define Class KontrolerCONTACTOSBASE as KontrolerConDetalle of KontrolerConDetalle.prg

	oFormCRMAIL = Null

	*-----------------------------------------------------------------------------------------
	Function inicializar() As VOID
		DoDefault()
		This.enlazar("oEntidad.EventoLanzarAsignacionesDeAccionesDeMails", "LanzarAsignacionesDeAccionesDeMails")
		Bindevent( This.oEntidad.codigoMails.oItem, "MostrarErroresMailAsignadoAOtroContacto", This, "MostrarErroresMailAsignadoAOtroContacto", 1 )
		Bindevent( This.oEntidad.codigoMails.oItem, "MostrarErroresMailAsignadoAlMismoContacto", This, "MostrarErroresMailAsignadoAlMismoContacto", 1 )
		Bindevent( This.oEntidad.codigoMails.oItem, "MostrarErroresMailIngresoCaracteresBasicos", This, "MostrarErroresMailIngresoCaracteresBasicos", 1 )
		Bindevent( This.oEntidad, "MostrarErroresEnCambioDeCliente", This, "MostrarErroresEnCambioDeCliente", 1 )
		Bindevent( This.oEntidad, "MostrarErrores", This, "MostrarErrores", 1 )
		this.enlazar( "oEntidad.EventoRefrescarDetalles", "RefrescarDetalles" )
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function LanzarAsignacionesDeAccionesDeMails( tcemail As String ) As VOID
		With This

			.setearestadomenuytoolbar(.F.)

			For Each loItem In tcemail
				With This.oFormCRMAIL
					.okontroler.cliente_pk = This.oEntidad.cliente_pk
					.okontroler.contacto = This.oEntidad.codigo
					.oEntidad.lhabilitaremail_pk = .T.
					.okontroler.email_pk = loItem
					.oEntidad.lhabilitaremail_pk = .F.
	
					.Show(1)
				Endwith
			Endfor
			.setearestadomenuytoolbar(.T.)
		Endwith
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function oFormCRMAIL_Access()
		If  !This.ldestroy And !Vartype( This.oFormCRMAIL ) = 'O'
			This.oFormCRMAIL = goformularios.procesarsubentidad( "CRMAIL" )
			This.oFormCRMAIL.Nuevo()
			Bindevent( This.oFormCRMAIL.okontroler.oEntidad, "DespuesdeGrabar", This, "OcultarFormulario", 1 )
			Bindevent( This.oFormCRMAIL.okontroler.oEntidad, "Cancelar", This, "OcultarFormulario", 1 )
			This.oFormCRMAIL.oEntidad.ArmarGrillasAccionesDeMails( This.oEntidad.tcXMLAccionesDeMail )
		Endif

		Return This.oFormCRMAIL

	Endfunc

	*-----------------------------------------------------------------------------------------
	Function  OcultarFormulario()  As VOID
		This.oFormCRMAIL.Visible = .F.
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function MostrarErroresMailAsignadoAOtroContacto( toError As Object ) As Boolean
		This.oEntidad.codigoMails.oItem.lRetorno = ( gomensajes.enviar( toError, 4, 1, 1 ) = 6 )
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function MostrarErroresEnCambioDeCliente( toError As Object ) As Boolean
		This.oEntidad.lRetorno = ( gomensajes.enviar( toError, 4, 1, 1 ) = 6 )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function MostrarErroresMailAsignadoAlMismoContacto( toError As Object ) As Boolean
		gomensajes.enviar( toError )
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function MostrarErroresMailIngresoCaracteresBasicos( toError As Object ) As Boolean
		gomensajes.enviar( toError )
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function MostrarErrores( toError As Object ) As Boolean
		gomensajes.enviar( toError )
	endfunc

	*-----------------------------------------------------------------------------------------
	function RefrescarDetalles() as Void
		local loControl as Object
		loControl = this.ObtenerControl( "DetalleAsigaccmail" )
		loControl.RefrescarGrilla()
	endfunc	

enddefine 
