Define Class KontrolerEdicion As Kontroler Of Kontroler.prg

	#if .f.
		local this as KontrolerEdicion of KontrolerEdicion.prg
	#endif

	protected oUltimoControlActivo, llHuboExcepcionPorMensajeria as Boolean

	cAccion = ''
	cestado = "NULO"
	nCantidadDeColumnas = 0
	cEstadoSecundario = ""
	oPrimerControl = null
	oEntidad = Null
	lEstadoUltimoProceso = .f.
	lProcesar_Funcion_Ejecutar = .T.
	lEsAnulable = .f.
	oUltimoControlActivo = null
	cCaptionOriginal = ""
	cUltimoEstadoAntesDeGrabar = ""
	lEntidadConRegistrosBloqueables = .f.
	lEntidadConRegistrosDesactivables = .f.
	lEntidadConRegistrosRechazables = .f.
	llHuboExcepcionPorMensajeria = .f.
	oColControlesVisuales = Null
	oManejadorErrores = null
	lIniciaNuevoDespuesDeGrabar = .f.
	lPuedeHacerNuevoAutomatico = .T.
	oMensaje = null
	oGestor = null
	lEntidadConTextoEspecificoParaLeyendaAlPie = .f.
	cTextoEspecificoParaLeyendaAlPie = ""
	oControlesARecorrer = null	
	lSacandoFocoDeGrilla = .f.
	lDebeConcatenarUsuarioAutorizante = .F.
	lEntidadInicializada = .f.
	lHayQueValidarCancelar = .t.
	lVieneDelSalir = .f.
	
	*-----------------------------------------------------------------------------------------
	Function Inicializar() As Void
		local lcFuncionalidades as String
		lcFuncionalidades = this.oEntidad.ObtenerFuncionalidades()
		This.oColControlesVisuales = This.CrearColeccionAtributosVisuales()
		this.oControlesARecorrer = this.CrearColeccionDeControlesVisuales()		
		this.SetearAtributoEsObligatorioEnControlesDefinidosPorElUsuario()
		this.SetearInvisibilidadEnControlesDefinidosPorElUsuario()
		this.SetearEtiquetasDefinidasPorElUsuario()
		this.SetearTituloPersonalizadoDeFromulario()
		this.InicializarPrimerControl()

		if vartype( This.oEntidad ) = "O"
			this.lEsAnulable = "<ANULABLE>" $ lcFuncionalidades
		
			if pemstatus( This.oEntidad, "EventoPreguntarEliminar",5 )
				this.enlazar( "oEntidad.EventoPreguntarEliminar", "PreguntarEliminar" )
			endif
			if pemstatus( This.oEntidad, "EventoMensajeria",5 )
				this.enlazar( "oEntidad.EventoMensajeria", "ServicioMensajeriaStatusBar" )
			endif
			
			this.enlazar( "oEntidad.lProcesando", "actualizarbarra" )
			
			this.enlazar( "oEntidad.EventoObtenerLogueo", "inyectarLogueo" )
			this.enlazar( "oEntidad.EventoObtenerInformacion", "inyectarInformacion" )

			if this.lEsAnulable
				this.enlazar( "oEntidad.EventoPreguntarAnular", "PreguntarAnular" )
				this.enlazar( "oEntidad.Anulado", "SetearEtiquetaComprobanteAnuladoSegunEstadoDelComprobante" )	
			else
				if pemstatus( this.oEntidad, "BloquearRegistro",5 )
					this.enlazar( "oEntidad.Grabar", "SetearEtiquetaAlPie" )
				endif
			endif

			if type( "thisform" ) == "O"
				this.cCaptionOriginal = thisform.caption
			endif

			if pemstatus( this.oEntidad, "BloquearRegistro",5 )
				this.lEntidadConRegistrosBloqueables = .t.
				this.enlazar( "oEntidad.BloquearRegistro", "SetearEtiquetaAlPie" )
			endif
			if pemstatus( this.oEntidad, "lEstadoRechazado",5 )
				this.lEntidadConRegistrosRechazables = .t.
				this.enlazar( "oEntidad.lEstadoRechazado", "SetearEtiquetaAlPie" )
			endif
			
			this.enlazar( "oEntidad.ActualizarProgressBar", "ActualizarProgressBar" )
			this.enlazar( "oEntidad.EventoMensajeDenegarModificar_Anular_EliminarEmpaquetado", "MensajeDenegarEmpaquetado" )
			this.enlazar( "oEntidad.EventoSetearUltimaAccionYEstado", "SetearUltimaAccionYEstado" )
			this.enlazar( "oEntidad.PreguntarConfirmacionImpresion", "PreguntarConfirmacionImpresion" )
		Endif	
		
		this.SetearValorParametro()
		this.enlazar( "oEntidad.Nuevo", "EncenderNuevoAutomatico" )
		this.enlazar( "oEntidad.EventoTalonarioLleno", "ApagarNuevoAutomatico" )
		
		dodefault() 
		this.SetearColorPageFrame()
	endfunc

	*-----------------------------------------------------------------------------------------
	Protected function oMensaje_access() as Object
		if !this.ldestroy and ( !vartype( this.oMensaje ) = 'O' or isnull( this.oMensaje ) )
			this.oMensaje = _screen.zoo.CrearObjetoPorProducto( "Mensajes" )
		endif
		return this.oMensaje
	EndFunc 

	*-----------------------------------------------------------------------------------------
	function CrearColeccionAtributosVisuales() as ZooColeccion of ZooColeccion.prg
		&& se genera el metodo
		return _Screen.Zoo.CrearObjeto( "zooColeccion" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CrearColeccionDeControlesVisuales() as Void
		return _Screen.Zoo.CrearObjeto( "zooColeccion" )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ServicioMensajeriaStatusBar( tcMensaje as String, tnCantidadDePasos as Integer ) as Void
		if vartype( ThisForm ) = 'O' and vartype( ThisForm.oBarraEstado ) = 'O'
			ThisForm.oBarraEstado.Mensajeria( tcMensaje, tnCantidadDePasos )
		Endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function InicializarPrimerControl() as Void
		local lcAtributo as String
		
		with this
			if pemstatus( thisform, "cPrimerControl", 5 ) and !empty( thisform.cPrimerControl )
				.oPrimerControl = .ObtenerControl( thisform.cPrimerControl )
			endif
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function Outlook() As Void
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function Ejecutar( tcAccion As String ) As boolean
		Local llProcesar as Boolean, llRetorno as Boolean, llOk as Boolean, loError as Exception, lcAccionAnterior as string 
		this.oUltimoControlActivo = null
		llRetorno = .T.
		With This
			if .lProcesar_Funcion_Ejecutar
				If .ExisteEntidad()

					if ThisForm.oEntidad.EstaEnProceso()
						*-- Se esta ejecutando otro proceso, por lo tanto no se puede ejecutar otra accion hasta que dicho proceso termine  -DM-
						llRetorno = .F.
					else
						thisform.lockscreen = .t.
						llProcesar = .T.
						llOk = .F.
						.lEstadoUltimoProceso = llOk
						.oInformacionUltimoProceso.limpiar()
						lcAccionAnterior = .cAccion
						.cAccion = tcAccion
						this.SetearClosable( .f. )

						llOk = This.RefrescarControlActivo()
						if llOk
							try
								this.VerificarEstadoRegistroTerminal( tcAccion )
								llOk = .Procesar()
							Catch To loError
								llOk = .f.
								this.ManejarErrorProceso( loError, "Alertar" )
							finally
								if upper(alltrim(.cAccion )) != "ESCAPAR"
									this.SetearClosable( .t. )
								endif 
								thisform.lockscreen = .f.
							endtry

							.SetearComportamiento()
						endif

						if upper( alltrim( .cEstado ) ) = "NULO"
							.finalizarLogueo()
						endif

						.EventoDespuesDeProcesar( llOk )
						.lEstadoUltimoProceso = llOk
						thisform.lockscreen = .f.
						this.SetearClosable( .T. )

						if !llOk and upper(alltrim(.cAccion )) = "ESCAPAR"
							.cAccion = lcAccionAnterior 
						endif
						if llOk and Alltrim( Upper( .cAccion )) = "CANCELAR"
							this.PostCancelar()
						endif	
						if llOk and Alltrim( Upper( .cAccion )) = "SALIR"
							thisform.salir()
						endif	
			
					Endif
					thisform.lockscreen = .f.
				Endif			
			EndIf	
		endwith

		return llRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	function seDebeHabilitarGuardarComo() as Boolean 
		if pemstatus( this.oEntidad, "HabilitarGuardarComoCondicionado",5 )
			return this.oEntidad.HabilitarGuardarComoCondicionado
		else 
			return .t.
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearEtiquetaAlPie() as Void
		local lcTexto as String, llVisible as Boolean

		lcTexto = this.ObtenerTextoDeEtiquetaAlPie()

		thisform.caption = this.cCaptionOriginal

		thisform.EtiquetaComprobanteAnulado.Visible = len( lcTexto ) > 0
		thisform.EtiquetaComprobanteAnulado.Caption = lcTexto
		thisform.EtiquetaComprobanteAnulado.Rotation = 0
		thisform.EtiquetaComprobanteAnulado.FontSize = 50
		thisform.EtiquetaComprobanteAnulado.Top = thisform.height - 150

		thisform.EtiquetaComprobanteAnulado.Height = 80

		if this.oEntidad.lEsEntidadConEdicionRestringida
			if upper( this.cAccion ) = "MODIFICAR" or upper( this.cAccion ) = "NUEVO"
				thisform.EtiquetaComprobanteAnulado.Visible = .f.
			else
				thisform.EtiquetaComprobanteAnulado.Visible = .t.
			endif
		endif

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerTextoDeEtiquetaAlPie() as String
		local lcTexto as String
		
		lcTexto = ""
		llVisible = .f.
		 
		if this.lEntidadConRegistrosBloqueables and this.oEntidad.BloquearRegistro
			if this.oEntidad.lEsEntidadConEdicionRestringida
				lcTexto = " / Edición parcial"
			else
				lcTexto = " / Sólo lectura"
			endif
		endif
		
		if this.lEntidadConRegistrosDesactivables and this.oEntidad.InactivoFW
			lcTexto = lcTexto + this.ObtenerTextoParaLeyendaAlPieEstadoInactivo()
		endif
		
		if this.lEntidadConRegistrosRechazables and this.oEntidad.lEstadoRechazado
			lcTexto = lcTexto + " / Rechazado"
		endif
	
		if this.lEntidadConTextoEspecificoParaLeyendaAlPie
			lcTexto = lcTexto + this.ObtenerTextoEspecificoParaLeyendaAlPie()
		endif
		
		lcTexto = substr( lcTexto, 4 )
		
		return lcTexto
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	hidden function ObtenerTextoParaLeyendaAlPieEstadoInactivo() as String
		return " / Inactivo"
	endfunc
	
	*-----------------------------------------------------------------------------------------
	hidden function ObtenerTextoEspecificoParaLeyendaAlPie() as String
		return " / " + alltrim( this.cTextoEspecificoParaLeyendaAlPie )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function SeteosEspeciales() As Void
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ValidarHabilitar() As boolean
		Return ( goMensajes.Preguntar( "¿Está seguro que desea habilitar?", 4 , 1 ) = 6 )
	Endfunc

	*-----------------------------------------------------------------------------------------
	function Procesar() As boolean
		Local lcAccion As String, llRetorno As boolean

		if ThisForm.oEntidad.EstaEnProceso()
			llRetorno = .F.
		else
			lcAccion = "this." + Alltrim( This.cAccion ) + iif( at( ")", This.cAccion ) = 0,"()","")
			llRetorno = &lcAccion	
		endif 
			
		return llRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	protected function Imprimir() As boolean
		Local llRetorno As Boolean, loError as Exception

		llRetorno = .F.

		if ThisForm.oEntidad.EstaEnProceso()
		Else
			this.oInformacionUltimoProceso.limpiar()

			if goServicios.Seguridad.PedirAccesoEntidad( this.oEntidad.ObtenerNombreOriginal(), "IMPRIMIR", .F., thisform.oEntidad.ObtenerDescripcion() )
				This.SetearUltimaAccion("Imprimir")

				try
					this.DeshabilitarAcciones()
					llRetorno = this.oEntidad.Imprimir()
				Catch To loError
					this.ManejarErrorProceso( loError, "Advertir" )
				finally
					this.HabilitarAcciones()
				EndTry
			else
				goMensajes.Advertir( goServicios.Seguridad.ObtenerInformacion() )
			endif
		endif 
				
		Return llRetorno
	endfunc	

	*-----------------------------------------------------------------------------------------
	protected function GenerarPdf() As boolean
		Local llRetorno As Boolean, loError as Exception

		llRetorno = .F.

		if ThisForm.oEntidad.EstaEnProceso()
		Else
			this.oInformacionUltimoProceso.limpiar()

			if goServicios.Seguridad.PedirAccesoEntidad( this.oEntidad.ObtenerNombreOriginal(), "GENERARPDF", .F., thisform.oEntidad.ObtenerDescripcion() )
				This.SetearUltimaAccion("GenerarPdf")

				try
					this.DeshabilitarAcciones()
					llRetorno = this.oEntidad.GenerarPdf()
				Catch To loError
					this.ManejarErrorProceso( loError, "Advertir" )
				finally
					this.HabilitarAcciones()
				EndTry
			else
				goMensajes.Advertir( goServicios.Seguridad.ObtenerInformacion() )
			endif
		endif 
				
		Return llRetorno
	endfunc	
	
	*-----------------------------------------------------------------------------------------
	function Nuevo() As Boolean
		Local llRetorno As Boolean, loError as Exception, lcRegistroDeActividad as String, lcUsuarioAutorizante as String
		llRetorno = .f.
		
		if ThisForm.oEntidad.EstaEnProceso()
		Else
			this.oInformacionUltimoProceso.Limpiar()

			lcUsuarioAutorizante = this.DeboGuardarUsuarioAutorizante()

			if goServicios.Seguridad.PedirAccesoEntidad( thisform.oEntidad.ObtenerNombreOriginal(), "NUEVO", .F., thisform.oEntidad.ObtenerDescripcion(), @lcUsuarioAutorizante )
				if !empty( lcUsuarioAutorizante )
					thisform.oEntidad.cUsuarioQueAutorizoSeguridad = lcUsuarioAutorizante
				endif
				
				try
					lcRegistroDeActividad = goServicios.RegistrodeActividad.IniciarRegistro( proper( Thisform.oEntidad.ObtenerNombre() ), "Nuevo" )
					Thisform.oEntidad.Nuevo()
					goServicios.RegistroDeActividad.FinalizarRegistro( lcRegistroDeActividad )
					llRetorno = .t.
				Catch To loError
					this.ManejarErrorProceso( loError, "Advertir" )
				EndTry
			else
				goMensajes.Advertir( goServicios.Seguridad.ObtenerInformacion() )
			endif

			if llRetorno
				This.SetearUltimaAccion( "Nuevo" )
				This.cEstado = "NUEVO"
			else
				this.Ejecutar( "CANCELAR" )
			endif
		endif 
				
		Return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function GuardarComo() As Boolean
		Local llRetorno As Boolean, loError as Exception
		llRetorno = .f.

		if ThisForm.oEntidad.EstaEnProceso()
		Else
			this.oInformacionUltimoProceso.Limpiar()
	
			if goServicios.Seguridad.PedirAccesoEntidad( thisform.oEntidad.ObtenerNombreOriginal(), "NUEVO", .F., thisform.oEntidad.ObtenerDescripcion() )
				try
					Thisform.oEntidad.GuardarComo()
					llRetorno = .t.
				Catch To loError
					this.ManejarErrorProceso( loError, "Advertir" )
				EndTry
			else
				goMensajes.Advertir( goServicios.Seguridad.ObtenerInformacion() )
			endif

			if llRetorno
				This.SetearUltimaAccion( "Guardar como" )
				This.cEstado = "GUARDARCOMO"
			else
				thisform.oEntidad.limpiar()
			endif
		endif 
				
		Return llRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	function oManejadorErrores_Access() as Void
		if !this.ldestroy
			if ( !vartype( this.oManejadorErrores ) = 'O' or isnull( this.oManejadorErrores ) )
				this.oManejadorErrores = _screen.zoo.crearobjeto( 'ManejadorErroresKontroler' )
				this.enlazar( "oManejadorErrores.EventoObtenerInformacion", "inyectarInformacion" )
			else 
				this.oManejadorErrores.oInformacionUltimoProceso = this.oInformacionUltimoProceso
			endif
		endif
		return this.oManejadorErrores
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Grabar() As Boolean
		Local llRetorno As Boolean, loError as Exception
		if ThisForm.oEntidad.EstaEnProceso()
			llRetorno = .F.
		Else
			this.ActualizarProgressBar( 5 )
			this.oInformacionUltimoProceso.limpiar()

			llRetorno = .T.		
			This.SetearUltimaAccion("Guardar")
			this.ActualizarProgressBar( 10 )

			llRetorno = This.validar()
			
			this.ActualizarProgressBar( 15 )
			If llRetorno
				thisform.KeyPreview = .f.
				Try
					this.DeshabilitarAcciones()
					Thisform.oEntidad.Grabar()
				Catch To loError
					llRetorno = .F.
					This.oManejadorErrores.ManejarExcepcion( loError )
				finally 
					this.HabilitarAcciones()
					thisform.KeyPreview = .t.
				Endtry
			Endif
			this.ActualizarProgressBar( 100 )

			If llRetorno
				thisform.lHayDatos = This.HayDatos()
				this.cUltimoEstadoAntesDeGrabar = this.cEstado
				This.cestado = "NULO"				
			endif			
		Endif 
		this.ActualizarProgressBar( 0 )

		If llRetorno and upper( this.ObtenerUltimoEstadoAntesDeGrabar() ) = "NUEVO"
			this.EventoFinalizoGrabar()
		endif
		Return llRetorno

	Endfunc

	*-----------------------------------------------------------------------------------------
	function AgregarMensajeTituloParaMasDeUnMensaje() as Void
		this.AgregarInformacion( "El proceso de grabación no se puede completar.", 0 )
	endfunc

	*-----------------------------------------------------------------------------------------
	function Eliminar() As boolean
		Local llRetorno As Boolean, loError as Exception

		llRetorno = .f.
		if ThisForm.oEntidad.EstaEnProceso()
		Else
			this.oInformacionUltimoProceso.Limpiar()
			llRetorno  = this.AplicarSeguridadAlEliminar()
		endif 
		
		Return llRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	function AplicarSeguridadAlEliminar() as Boolean
		local llRetornoEliminar as Boolean

		if goServicios.Seguridad.PedirAccesoEntidad( thisform.oEntidad.ObtenerNombreOriginal() , "ELIMINAR", .F., thisform.oEntidad.ObtenerDescripcion() )
			This.SetearUltimaAccion( "Eliminar" )
			Try
				Thisform.oEntidad.Eliminar( )
				llRetornoEliminar = .t.
			catch to loError
				this.ManejarErrorProceso( loError, "Advertir", "Error al eliminar" )
			Endtry
			
			this.CambiarEstado( llRetornoEliminar )
		else
			goMensajes.Advertir( goServicios.Seguridad.ObtenerInformacion() )
		endif
		return llRetornoEliminar
		
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function CambiarEstado(tlRetorno as Boolean) as Void
		if tlRetorno
			thisform.lhaydatos = this.haydatos()
			this.cestado = "NULO"
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function PreguntarEliminar( ) as Void
		this.oEntidad.lEliminar = ( gomensajes.Preguntar( "¿Está seguro que desea eliminar el registro? ", 4, 1 ) = 6 )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function PreguntarAnular( tcComprobante as String ) as Void
		this.oEntidad.lAnular = ( gomensajes.Preguntar( "¿Confirma anular el registro " + tcComprobante + "?", 4, 1 ) = 6 )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function Anular( ) as Boolean
		local loError as Object, llRetorno as Boolean
		llRetorno = .f.
		if ThisForm.oEntidad.EstaEnProceso()
		else
			llRetorno = this.AplicarSeguridadAlAnular()
		endif
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function AplicarSeguridadAlAnular() as Boolean
		local llRetornoAnular as Boolean
		
		llRetornoAnular = .f.
		if goServicios.Seguridad.PedirAccesoEntidad( thisform.oEntidad.ObtenerNombreOriginal(), "ANULAR" )
			This.SetearUltimaAccion( "Anular" )
			try
				ThisForm.oEntidad.Anular()
				llRetornoAnular = .t.
			catch to loError
				goServicios.Errores.LevantarExcepcion( loError )
			endtry
		else
			goMensajes.Advertir( goServicios.Seguridad.ObtenerInformacion() )
		endif
		return llRetornoAnular 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearEtiquetaComprobanteAnuladoSegunEstadoDelComprobante() as Void
		thisform.EtiquetaComprobanteAnulado.Visible = Thisform.oEntidad.Anulado
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Modificar( ) As Boolean
		Local llRetorno As Boolean,	loError as Exception

		llRetorno = .f.
		if ThisForm.oEntidad.EstaEnProceso()
		Else
			llRetorno = this.AplicarSeguridadAlModificar()
		endif 
		
		Return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function AplicarSeguridadAlModificar() as Boolean
		local llRetornoModificar, lcUsuarioAutorizante as String

		lcUsuarioAutorizante = this.DeboGuardarUsuarioAutorizante()

		if goServicios.Seguridad.PedirAccesoEntidad( thisform.oEntidad.ObtenerNombreOriginal(), "MODIFICAR", .F., thisform.oEntidad.ObtenerDescripcion(), @lcUsuarioAutorizante )
			if !empty( lcUsuarioAutorizante )
				Thisform.oEntidad.cUsuarioQueAutorizoSeguridad = lcUsuarioAutorizante
			endif

			This.SetearUltimaAccion( "Modificar" )
			This.cEstado = "EDICION"
			try
				llRetornoModificar = Thisform.oEntidad.Modificar()
			catch to loError
				This.cEstado = "NULO"		
				goServicios.Errores.LevantarExcepcion( loError )			
			endtry
		else
			goMensajes.Advertir( goServicios.Seguridad.ObtenerInformacion() )
		endif
		return llRetornoModificar
	endfunc

	*-----------------------------------------------------------------------------------------
	Function DespuesdeProcesar() As Void
		With This
			Do Case
				Case alltrim( upper( .cAccion ) ) == "BUSCAR"
					.cAccion = ""
					.cEstado = "NULO"
					.ActualizarFormulario()
					.ActualizarBarra()
				Case alltrim( upper( .cAccion ) ) == "PRIMERO"
					with thisform
						with .oMenu.menu_Archivo
							if type( ".menu_primero" ) = "O"
								.menu_primero.enabled = .f.
							endif 
							if type( ".menu_Anterior" ) = "O"
								.menu_Anterior.enabled = .f.
							endif 						
						endwith 
						with .oToolBar
							if type( ".barra_primero" ) = "O"
								.barra_primero.enabled = .f.
							endif 
							if type( ".barra_Anterior" ) = "O"
								.barra_Anterior.enabled = .f.
							endif 						
						endwith
					endwith
				Case alltrim( upper( .cAccion ) ) == "ULTIMO"	
					with thisform
						with .oMenu.menu_Archivo
							if type( ".menu_ultimo" ) = "O"
								.menu_ultimo.enabled = .f.
							endif 						

							if type( ".menu_siguiente" ) = "O"
								.menu_siguiente.enabled = .f.
							endif 						
						endwith
						with .oToolBar
							if type( ".barra_ultimo" ) = "O"
								.barra_ultimo.enabled = .f.
							endif 						

							if type( ".barra_siguiente" ) = "O"
								.barra_siguiente.enabled = .f.
							endif 											
						endwith
					endwith
			Endcase

		Endwith
	Endfunc

	*-----------------------------------------------------------------------------------------
	protected Function SetearPrimerControl() As Void
		If !Isnull( this.oPrimerControl )
			this.oPrimerControl.SetFocus
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function oPrimerControl_Access() as Object
			local lnI as Integer, loObjeto as Object, loItem as Object,lnFila as Integer, lnColumna as Integer
		if !this.ldestroy and (( !vartype( this.oPrimerControl ) = 'O' or isnull( this.oPrimerControl ) )) and !isnull( This.oColControlesVisuales )
			for lnI = 1 to This.oColControlesVisuales.Count
				loObjeto = This.ObtenerControl( This.oColControlesVisuales.Item[lnI] )
				if this.EsUnObjetoConFoco( loObjeto )
 					This.oPrimerControl = loObjeto
					exit For
				Endif
			endfor
			loItem = null
			loObjeto = null
		endif
		Return This.oPrimerControl
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsUnObjetoConFoco( toControl ) as Boolean
		local llRetorno as Boolean, llParentVisible as Boolean
		llParentVisible = iif( pemstatus( toControl, "Parent", 5 ) and pemstatus(toControl.Parent, "Visible", 5 ), toControl.Parent.Visible, .T. )
		llRetorno = toControl.Enabled and toControl.Visible and llParentVisible and (!pemstatus( toControl, "ReadOnly", 5 ) or !toControl.ReadOnly )
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function ExisteEntidad() As boolean
		Local llRetorno As Boolean

		llRetorno = Pemstatus(Thisform,"oEntidad",5) 

		Return llRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ExisteFormularioActivo As boolean
		Local llRetorno

		try
			llRetorno = ( Vartype(Thisform) = "O" )
		catch
			llRetorno = .f.
		endtry

		Return llRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ActualizarFormulario() As Void
		local loError as Exception
		This.SeteaEstadoFormulario()
		If Vartype( Thisform.oParche ) = "O"
			Thisform.oParche.Enabled = ( Vartype( This.cEstado ) # "C" Or upper( This.cEstado ) == "NULO" )
			if Thisform.oParche.Enabled and thisform.visible
				try
					Thisform.oParche.SetFocus()
				catch to loError
					if loError.ErrorNo = 2012 &&si se ejecuta desde un valid, when o gotfocus
					else
						goServicios.Errores.LevantarExcepcion( loError )
					endif
				endtry
			endif
		Endif

	endfunc

	*-----------------------------------------------------------------------------------------
	Function RefrescarControlActivo() As Boolean
		local lnAux as Integer, llRetorno as Boolean, lxValor as Variant, loError as Exception, llEsOParche as Boolean, loUltimoControlActivo as Object
		llEsOParche = .f.
		if ThisForm.oEntidad.EstaEnProceso()
			llRetorno = .F.
		Else
			llretorno = .t.
			
			If inlist( upper( this.cAccion ), "CANCELAR", "SIGUIENTE", "ANTERIOR", "ULTIMO", "PRIMERO", "ESCAPAR" )
			else
				if type( "thisform.oParche" ) == "O" and Type( "thisform.ActiveControl" ) == "O" and thisform.ActiveControl == thisform.oParche
					llEsOParche = .t.
				endif
				If Type( "thisform.ActiveControl" ) == "O" and !llEsOParche
					this.oUltimoControlActivo = thisform.ActiveControl
					loUltimoControlActivo = this.oUltimoControlActivo
					if pemstatus( loUltimoControlActivo, "valid", 5 )
						if  pemstatus( loUltimoControlActivo, "value", 5 )
							lxValor = loUltimoControlActivo.value
						endif

						lnAux = this.ForzarEjecucionDeValidDeControlActivo()

						if pemstatus( loUltimoControlActivo, "value", 5 )
							loUltimoControlActivo.value = lxValor
						endif
						
						llRetorno = iif( vartype( lnAux ) = "L", lnaux, lnAux # 0 )

					endif

					if llRetorno 
						if alltrim( upper( this.cAccion ) )= "SALIR" and ;
									!thisform.oentidad.EsNuevo() and !thisform.oEntidad.EsEdicion()
						else
							if pemstatus( loUltimoControlActivo, "setfocus", 5 )
								try
									loUltimoControlActivo.SetFocus()
								Catch To loError									
									if loError.ErrorNo = 2012
									else
										goServicios.Errores.LevantarExcepcion( loError )
									endif 
								endtry 
							endif
						endif
					endif
				endif

				This.LostFocusDeControles()
				
				if llRetorno
					llRetorno = This.SacarFocoControlActivo()
				endif

			endif
			
		endif
				
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ForzarEjecucionDeValidDeControlActivo() as Variant
		local lvRetorno as Variant, loExcepcion as Exception

		if pemstatus( thisform._Botonera.cmdAceptar, "SetFocus", 5 )
			try
			
				this.BindearEvento( goServicios.Mensajes, "Enviar", this, "CapturarExcepcionMostradaPorMensajeria" )
				this.llHuboExcepcionPorMensajeria = .f.

				thisform._Botonera.cmdAceptar.SetFocus()
				lvRetorno = !this.llHuboExcepcionPorMensajeria
			catch to loExcepcion
				if loExcepcion.ErrorNo = 2012
				else
					goServicios.Errores.LevantarExcepcion( loExcepcion )
				endif
			finally
				this.DesBindearEvento( goServicios.Mensajes, "Enviar", this, "CapturarExcepcionMostradaPorMensajeria" )
			endtry
		else
			lvRetorno = this.oUltimoControlActivo.Valid()
		endif
		
		return lvRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function CapturarExcepcionMostradaPorMensajeria( tvMensaje as Variant, tnBotones as integer , tnIcono as integer, tnBotonDefault as integer, tcTitulo as string, tnTiempoEspera as Integer ) as Integer
		if vartype( tvMensaje ) = "O" and upper( tvMensaje.BaseClass ) == "EXCEPTION"
			this.llHuboExcepcionPorMensajeria = .t.
		else
			this.llHuboExcepcionPorMensajeria = .f.
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function LostFocusDeControles() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function SacarFocoControlActivo() As boolean
		local llRetorno as Boolean
		llRetorno = .T.
		If Type( "thisform.ActiveControl" ) == "O" and upper( alltrim( thisform.ActiveControl.Name ) ) # "OPARCHE"
			llRetorno = This.SacarFocoControl( Thisform.ActiveControl )
		endif
		return llRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function SacarFocoControl( toControl As Object ) As Boolean
		local llRetorno as Boolean
		llRetorno = .T.		
		If Pemstatus( toControl, "parent", 5 ) And Type( "toControl.parent" ) = "O"
			llRetorno = This.SacarFocoControl( toControl.Parent )
		Endif
		If Pemstatus( toControl, "LostFocus", 5 )
			Raiseevent( toControl, "LostFocus" )
			if pemstatus( toControl, "lMalLostFocus", 5 )
				llRetorno = !toControl.lMalLostFocus
				toControl.lMalLostFocus = .F.
			Endif	
		Endif
		return llRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	function setearEnabledMenu( tcMenu as String, tcOpcion as String, tlEnabled as Boolean ) as Void
		local lcSentencia as String 
		if type( "thisform.oMenu.menu_" + alltrim( tcMenu ) + ".menu_" + alltrim( tcOpcion ) ) = "O"
			lcSentencia = "thisform.oMenu.menu_" + alltrim( tcMenu ) + ".menu_" + alltrim( tcOpcion ) + ".Enabled = " + iif( tlEnabled, ".T.", ".F." ) 
			&lcSentencia
		endif
		this.SetearEnabledToolbar( tcOpcion, tlEnabled )
	endfunc

	*-----------------------------------------------------------------------------------------
	function setearEnabledMenuDeSubMenu( tcMenu as String, tcSubMenu, tcOpcion as String, tlEnabled as Boolean ) as Void
		local lcSentencia as String 
		if type( "thisform.oMenu.menu_" + alltrim( tcMenu ) + ".menu_" + alltrim( tcSubMenu ) + ".menu_" + alltrim( tcOpcion ) ) = "O"
			lcSentencia = "thisform.oMenu.menu_" + alltrim( tcMenu )+ ".menu_" + alltrim( tcSubMenu ) + ".menu_" + alltrim( tcOpcion ) + ".Enabled = " + iif( tlEnabled, ".T.", ".F." ) 
			&lcSentencia
		endif
		this.SetearEnabledToolbar( tcOpcion, tlEnabled )
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerEnabledMenu( tcMenu as String, tcOpcion as String ) as Boolean
		local llRetorno as Boolean, lcSentencia as String 
		llRetorno = .F.
		if type( "thisform.oMenu.menu_" + alltrim( tcMenu ) + ".menu_" + alltrim( tcOpcion ) ) = "O"
			lcSentencia = "llRetorno = thisform.oMenu.menu_" + alltrim( tcMenu ) + ".menu_" + alltrim( tcOpcion ) + ".Enabled" 
			&lcSentencia
		endif
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function setearEnabledToolbar( tcOpcion as String, tlEnabled as Boolean )as Void
        local lcSentencia as String
        if type( "thisform.oToolBar.Barra_" + alltrim( tcOpcion ) ) = "O"
                   lcSentencia = "thisform.oToolBar.Barra_" + alltrim( tcOpcion ) + ".Enabled = " + iif( tlEnabled, ".T.", ".F." ) 
                   &lcSentencia
        endif
        if type( "thisform.oToolBarInfo.Barra_" + alltrim( tcOpcion ) ) = "O"
                   lcSentencia = "thisform.oToolBarInfo.Barra_" + alltrim( tcOpcion ) + ".Enabled = " + iif( tlEnabled, ".T.", ".F." ) 
                   &lcSentencia
        endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerEnabledToolbar( tcOpcion as String ) as Boolean
		local llRetorno as Boolean, lcSentencia as String 
		llRetorno = .F.
		if type( "thisform.oToolBar.Barra_" + alltrim( tcOpcion ) ) = "O"
			lcSentencia = "llRetorno = thisform.oToolBar.Barra_" + alltrim( tcOpcion ) + ".Enabled"
			&lcSentencia
		endif
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	Function ActualizarBarra( tcEstado as String ) As Void
		local llCampoPrincipalVacio as Boolean, lcEstado as String , lcAtributoPK as string, llErrorTimeStamp as Boolean,; 
		llEsNuevo as Boolean, llBloqueaRegistro as Boolean, llActivo as Boolean
 
		If Vartype( tcEstado ) != "C"
			lcEstado = upper( This.cEstado )
		Else
			lcEstado = upper( tcEstado )
		endif

		llErrorTimeStamp = ( this.oManejadorErrores.HuboErrorUP( goServicios.Errores.ObtenerCodigoErrorParaValidacionTimestamp() ) > 0 ) &&Codigo de errro para TimeStamp
		local loEntidad as entidad OF entidad.prg
		loEntidad = thisform.oEntidad
		with thisform
			if loEntidad.EstaEnProceso()
				This.SetearEstadoControlesMenuCuandoEstaProcesando( .F. )
			else
				This.SetearEnabledMenu( "archivo", "salir", .T. )	
				this.SetearEstadoCerrarFormulario( .t. )

				llEsNuevo = loEntidad.EsNuevo() 		
				if llEsNuevo or loEntidad.EsEdicion()
					this.SetearEnabledMenu( "archivo", "primero", .F. )
					this.SetearEnabledMenu( "archivo", "anterior", .F. )
					this.SetearEnabledMenu( "archivo", "siguiente", .F. )
					this.SetearEnabledMenu( "archivo", "ultimo", .F. )
					this.SetearEnabledMenu( "archivo", "modificar", .F. )					
					this.SetearEnabledMenu( "archivo", "grabar", !llErrorTimeStamp )		
					this.SetearEnabledMenu( "archivo", "eliminar", .F. )					
					this.SetearEnabledMenu( "archivo", "cancelar", .T. )
					this.SetearEnabledMenu( "archivo", "nuevo", .F. )
					this.SetearEnabledMenu( "archivo", "nuevoenbasea", .F. )
					this.SetearEnabledMenu( "archivo", "buscar", .F. )
					this.SetearEnabledMenu( "archivo", "imprimir", .F. )
					this.SetearEnabledMenu( "archivo", "generarpdf", .F. )
					this.SetearEnabledMenu( "archivo", "guardarcomo", .F. )
					this.SetearEnabledMenu( "acciones", "activar", .F. )
					this.SetearEnabledMenu( "acciones", "desactivar", .F. )
					this.SetearEnabledMenu( "acciones", "completardesdeventas", .T.)
					if this.lEsAnulable
						this.SetearEnabledMenu( "archivo", "anular", .F. )						
					endif
					if llErrorTimeStamp
						This.SetearAyuda( "Reg. modificado por otro Usuario" )
						this.bloquearBarraEstado()

						if type( "thisform._Botonera.cmdAceptar" ) = "O"
							thisform._Botonera.cmdAceptar.enabled = .F.
						endif
					endif
				else
					this.SetearEnabledMenu( "acciones", "completardesdeventas", .F.)
					If Isnull( this.oPrimerControl )
						llCampoPrincipalVacio = .t.
					else
						if pemstatus( loEntidad, "oAtributos", 5 )
							llCampoPrincipalVacio = empty( loEntidad.ObtenerValorAtributo( loEntidad.ObtenerAtributoClavePrimaria()))
						else
							lcatributoPK = loEntidad.ObtenerAtributoClavePrimaria()
							llCampoPrincipalVacio = empty( loEntidad.&lcAtributoPK )
						endif
					endif
					if pemstatus( loEntidad, "InactivoFW", 5 )
						llActivo = loEntidad.InactivoFW
					endif 
					if pemstatus( loEntidad, "BloquearRegistro", 5)
						llBloqueaRegistro = loEntidad.BloquearRegistro
					else
						llBloqueaRegistro = .F.
					endif
					
					if alltrim( upper( This.cAccion ) ) == "BUSCAR"
						this.SetearEnabledMenu( "archivo", "primero", (lcEstado = "NULO") )
						this.SetearEnabledMenu( "archivo", "anterior", (lcEstado = "NULO") )
						this.SetearEnabledMenu( "archivo", "siguiente", (lcEstado = "NULO") )						
						this.SetearEnabledMenu( "archivo", "ultimo", (lcEstado = "NULO") )
						this.SetearEnabledMenu( "archivo", "modificar", !llCampoPrincipalVacio and !llBloqueaRegistro )
						this.SetearEnabledMenu( "archivo", "grabar", .F. )
						this.SetearEnabledMenu( "archivo", "eliminar", !llCampoPrincipalVacio and !llBloqueaRegistro )
						this.SetearEnabledMenu( "archivo", "cancelar", !(lcEstado = "NULO") )
						this.SetearEnabledMenu( "archivo", "nuevo", (lcEstado = "NULO") )
						this.SetearEnabledMenu( "archivo", "nuevoenbasea", (lcEstado = "NULO") )
						this.SetearEnabledMenu( "archivo", "buscar", (lcEstado = "NULO") )		
						this.SetearEnabledMenu( "archivo", "imprimir", .F. )
						this.SetearEnabledMenu( "archivo", "generarpdf", .F. )
						this.SetearEnabledMenu( "archivo", "guardarcomo", .F. )
						this.SetearEnabledMenu( "acciones", "activar", .F. )
						this.SetearEnabledMenu( "acciones", "desactivar", .F. )
						if this.lEsAnulable
							this.SetearEnabledMenu( "archivo", "anular", (lcEstado = "NULO") )						
						endif
					else
						this.SetearEnabledMenu( "archivo", "primero", icase( !thisform.lHaydatos, .f. ,this.cAccion = "PRIMERO", .f. , .T. ) )
						this.SetearEnabledMenu( "archivo", "anterior", icase( !thisform.lHaydatos, .f. ,this.cAccion = "PRIMERO", .f. , .T. ) )
						this.SetearEnabledMenu( "archivo", "siguiente", icase( !thisform.lHaydatos, .f. ,this.cAccion = "ULTIMO", .f. , .T. ) )						
						this.SetearEnabledMenu( "archivo", "ultimo", icase( !thisform.lHaydatos, .f. ,this.cAccion = "ULTIMO", .f. , .T. ) )
						this.SetearEnabledMenu( "archivo", "modificar", !llCampoPrincipalVacio and ( !llBloqueaRegistro or ( llBloqueaRegistro and this.oEntidad.lEsEntidadConEdicionRestringida ) ) )
						this.SetearEnabledMenu( "archivo", "grabar", .F. )
						do case
							case this.lEsAnulable
								this.SetearEnabledMenu( "archivo", "anular", !llCampoPrincipalVacio and !this.oEntidad.EstaAnulado() )
								this.SetearEnabledMenu( "archivo", "eliminar", !llCampoPrincipalVacio and !llBloqueaRegistro and this.oEntidad.EstaAnulado() )
							case this.lEntidadConRegistrosDesactivables
								this.SetearEnabledMenu( "archivo", "eliminar", !llCampoPrincipalVacio and !llBloqueaRegistro )
							otherwise
								this.SetearEnabledMenu( "archivo", "eliminar", !llCampoPrincipalVacio and !llBloqueaRegistro )
						endcase
						this.SetearEnabledMenu( "archivo", "cancelar", .F. )
						this.SetearEnabledMenu( "archivo", "nuevo", .T. )
						this.SetearEnabledMenu( "archivo", "nuevoenbasea", .T. )
						this.SetearEnabledMenu( "archivo", "buscar", thisform.lHaydatos )
						this.SetearEnabledMenu( "archivo", "imprimir", !llCampoPrincipalVacio ) &&and llTieneDiseno )
						this.SetearEnabledMenu( "archivo", "generarpdf", !llCampoPrincipalVacio ) &&and llTieneDiseno )
						this.SetearEnabledMenu( "archivo", "guardarcomo", icase( this.cAccion = "GUARDARCOMO", .F. ,this.cAccion = "MODIFICAR", .F., !llCampoPrincipalVacio and this.seDebeHabilitarGuardarComo() ))		
						this.SetearEnabledMenu( "acciones", "activar", !llCampoPrincipalVacio and !llBloqueaRegistro and llActivo )
						this.SetearEnabledMenu( "acciones", "desactivar", !llCampoPrincipalVacio and !llBloqueaRegistro and !llActivo )
					endif
				endif
				this.SetearEnabledMenu( "acciones", "EstadoTransferencia", !( llCampoPrincipalVacio or This.ObtenerEnabledMenu( "Archivo", "Grabar" ) ) )
				this.SetearEnabledMenu( "archivo", "Transferencia", !llCampoPrincipalVacio and !( loEntidad.EsNuevo() or loEntidad.EsEdicion() ) )
				this.SetearEnabledMenu( "archivo", "generarPdf", !llCampoPrincipalVacio and !( loEntidad.EsNuevo() or loEntidad.EsEdicion() ) )		
				this.SetearEnabledMenu( "archivo", "Enviarmail", !llCampoPrincipalVacio and !( loEntidad.EsNuevo() or loEntidad.EsEdicion() ) )						
				this.SetearEnabledMenu( "Ver", "InformacionAdicional", this.HabilitaInformacionAdicional() )

				this.SetearBarraInformacion( tcEstado )
				
				If lcEstado = "NULO"
					This.SetearAyuda( "" )
				Endif	
				this.ActualizarBarraOpcionesNoGenericas( lcEstado )
			endif 		
			
		endwith 
		loEntidad = null
	Endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function SetearEstadoControlesMenuCuandoEstaProcesando( tlEstado as Boolean ) as Void
	
		this.SetearEnabledMenu( "archivo", "primero", tlEstado )
		this.SetearEnabledMenu( "archivo", "anterior", tlEstado )
		this.SetearEnabledMenu( "archivo", "siguiente", tlEstado )
		this.SetearEnabledMenu( "archivo", "ultimo", tlEstado )
		this.SetearEnabledMenu( "archivo", "modificar", tlEstado )					
		this.SetearEnabledMenu( "archivo", "grabar", tlEstado )					
		this.SetearEnabledMenu( "archivo", "eliminar", tlEstado )					
		this.SetearEnabledMenu( "archivo", "cancelar", tlEstado )
		this.SetearEnabledMenu( "archivo", "nuevo", tlEstado )
		this.SetearEnabledMenu( "archivo", "nuevoenbasea", tlEstado )
		this.SetearEnabledMenu( "archivo", "buscar", tlEstado )
		this.SetearEnabledMenu( "archivo", "salir", tlEstado )		
		this.SetearEnabledMenu( "archivo", "imprimir", tlEstado )
		this.SetearEnabledMenu( "archivo", "generarpdf", tlEstado )
		this.SetearEnabledMenu( "archivo", "guardarcomo", tlEstado )
		this.SetearEnabledMenu( "archivo", "enviaremail", tlEstado )		
		
		this.SetearEstadoCerrarFormulario( tlEstado )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearEstadoCerrarFormulario( tlEstado as Boolean ) as Void

		with ThisForm
			this.SetearClosable( tlEstado )
			
			If Type( ".oToolBarInfo.barra_cancelar" ) = "O"
				.oToolBarInfo.barra_cancelar.Enabled = tlEstado 
			endif			

			if type( "thisform.oMenu" ) = "O"
				if pemstatus( .oMenu.menu_Archivo, "Menu_EstadoTransferencia",5 )
				 	.oMenu.menu_Archivo.Menu_EstadoTransferencia.enabled = tlEstado 
				 endif 	

				if type( "thisform.oMenu.menu_Ver.menu_InformacionAdicional" ) = "O" 
					.omenu.menu_Ver.menu_InformacionAdicional.enabled = tlEstado 
				endif
			endif
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearBarraInformacion( tcEstado as String ) as VOID
		local lcEstadoTransf as string, lcImagen as string, ldFechaTransf as date, lcTexto as string, lcAtributoPK as string
		
		if type( "thisform.oToolBar.Barra_EstadoTransferencia" ) = "O"
			with thisform.oToolBar

				lcEstadoTransf = alltrim( this.oEntidad.EstadoTransferencia )
				ldFechaTransf = this.oEntidad.FechaTransferencia

				lcTexto = this.ObtenerTextoTrasnferencia( lcEstadoTransf, ldFechaTransf )
				lcImagen = this.ObtenerImagenTransferencia( lcEstadoTransf, ldFechaTransf )
			
				.Barra_EstadoTransferencia.Visible = .f.
			
				.Barra_EstadoTransferencia.ToolTip = lcTexto 
				.Barra_EstadoTransferencia.SetPicture( lcImagen )
				.Barra_EstadoTransferencia.Visible = !empty( lcEstadoTransf ) 
 
				if type( "thisform.oMenu.Menu_Ver.Menu_EstadoTransferencia" ) = "O" 
					thisform.oMenu.Menu_Ver.Menu_EstadoTransferencia.visible = .visible
					thisform.oMenu.Menu_Ver.Menu_EstadoTransferencia.SetPicture( lcImagen )
				endif
			endwith
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerTextoTrasnferencia( tcEstadoTransf as string, tdFechaTransf as Date ) as string
		local lcImagen as string, lcRetorno as string, lcAtributoPK as string
		
		with this
			lcRetorno = ""
			lcAtributoPK = .oEntidad.ObtenerAtributoClavePrimaria()
			if !empty( .oEntidad.&lcAtributoPK )
				lcRetorno = "Estado de transferencia"
				
				if empty( tcEstadoTransf )
					lcRetorno = lcRetorno + ": NO TRANSFERIDO"
				else
					lcRetorno = lcRetorno + ": " + tcEstadoTransf + " (" + dtoc( tdFechaTransf ) + ")"
				endif
			endif
		endwith
		
		return lcRetorno  
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerImagenTransferencia( tcEstadoTransf as string, tdFechaTransf as Date ) as string
		local lcRetorno as string, lcAtributoPK as string
		
		with this
			lcRetorno = "noenviado.bmp"

			lcAtributoPK = .oEntidad.ObtenerAtributoClavePrimaria()
			if !empty( .oEntidad.&lcAtributoPK )
				if !empty( tcEstadoTransf )
					if tcEstadoTransf = "ENVIADO"
						lcRetorno = "enviado.bmp"
					else
						lcRetorno = "recibido.bmp"
					endif
				endif
			endif
		endwith
		
		return lcRetorno  
	endfunc 

	*-----------------------------------------------------------------------------------------
	function MostrarEstadoTransferencia() as Void
		local lcEstadoTransf as string, ldFechaTransf as date, loError as Exception, lcTexto as string
		
		if type( "thisform.oToolBar" ) = "O"
			lcEstadoTransf = alltrim( this.oEntidad.EstadoTransferencia )
			ldFechaTransf = this.oEntidad.FechaTransferencia
		
			lcTexto = this.ObtenerTextoTrasnferencia( lcEstadoTransf, ldFechaTransf )

			if !empty( lcTexto )		
				this.SetearEstadoMenuYToolBar( .f. )

				try		
					gomensajes.enviar( lcTexto, , 3, , "Estado de transferencia" )
				catch to loError
					throw loError
				finally
					this.SetearEstadoMenuYToolBar( .t. )
				endtry
			endif
		endif
	endfunc 

	*--------------------------------------------------------------------------------------------
	Function ObtenerEstadoFormulario( toEntidad As Object, tcAccion As String ) As String
		Local lcEstado As String

		lcEstado = ""
		With toEntidad
			Do Case
				Case .EsNuevo() And .EsEdicion()
					lcEstado = "NUEVO"
				Case !.EsNuevo() And .EsEdicion()
					lcEstado = "EDICION"
				Case .EsBusqueda()
					lcEstado = "BUSQUEDA"
				Case !.EsNuevo() And !.EsEdicion() And !.EsBusqueda ()
					lcEstado = "NULO"
			Endcase
		Endwith

		Return lcEstado
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function SetearAyuda( tcTexto As String ) As Void
		If This.ExisteFormularioActivo() and Vartype( Thisform.oBarraEstado ) = "O"
			Thisform.oBarraEstado.SetearPanel( tcTexto, 3 )
			Thisform.oBarraEstado.SetearTooltip( tcTexto, 3 )
		Endif
	Endfunc
	
	*-----------------------------------------------------------------------------------------
	Function SetearUltimaAccion( tcTexto As String ) As Void		
		If This.ExisteFormularioActivo() and Vartype( Thisform.oBarraEstado ) = "O"
			Thisform.oBarraEstado.SetearPanel( tcTexto, 4 )
			Thisform.oBarraEstado.SetearTooltip( tcTexto, 4 )
		endif
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ObtenerUltimoEstadoAntesDeGrabar() As String
		return this.cUltimoEstadoAntesDeGrabar
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function Ultimo() As Boolean
		Local llRetorno As Boolean

		llRetorno = .f.
		if ThisForm.oEntidad.EstaEnProceso()
		Else
			if goServicios.Seguridad.PedirAccesoEntidad( thisform.oEntidad.ObtenerNombreOriginal(), "BUSCAR", .F., thisform.oEntidad.ObtenerDescripcion() )
				This.cEstado = "NULO"
				llRetorno = Thisform.oEntidad.Ultimo()
				If llRetorno
					This.SetearUltimaAccion( "Ultimo registro" )
				else
					goMensajes.Informar( "No hay " + Proper( Alltrim( Thisform.oEntidad.cDescripcion ) ) ;
						+ " en los archivos." )
				Endif
			else
				goMensajes.Advertir( goServicios.Seguridad.ObtenerInformacion() )
			endif
		endif
		
		Return llRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function Siguiente() As Boolean
		Local llRetorno As Boolean
		
		llRetorno = .f.

		if ThisForm.oEntidad.EstaEnProceso()
		Else
			if goServicios.Seguridad.PedirAccesoEntidad( thisform.oEntidad.ObtenerNombreOriginal(), "BUSCAR", .F., thisform.oEntidad.ObtenerDescripcion() )
				This.cEstado = "NULO"

				llRetorno = Thisform.oEntidad.Siguiente()
				If llRetorno
					This.SetearUltimaAccion( "Registro siguiente" )
				Else
					if Thisform.oEntidad.haydatos()
					else
						goMensajes.Informar( "No hay " + Proper( Alltrim( Thisform.oEntidad.cDescripcion ) ) ;
							+ " en los archivos." )
					endif
					This.SetearUltimaAccion( "Ultimo registro" )
				Endif
			else
				goMensajes.Advertir( goServicios.Seguridad.ObtenerInformacion() )
			endif
		EnDif
		Return llRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function Primero() As Boolean
		Local llRetorno As Boolean

		llRetorno = .f.
		if ThisForm.oEntidad.EstaEnProceso()
		Else
			if goServicios.Seguridad.PedirAccesoEntidad( thisform.oEntidad.ObtenerNombreOriginal(), "BUSCAR", .F., thisform.oEntidad.ObtenerDescripcion() )
				This.cEstado = "NULO"
				
				llRetorno = Thisform.oEntidad.Primero()
				If llRetorno
					This.SetearUltimaAccion( "Primer registro" )
				else
					goMensajes.Informar( "No hay " + Proper( Alltrim( Thisform.oEntidad.cDescripcion ) ) ;
						+ " en los archivos." )
				Endif
			else
				goMensajes.Advertir( goServicios.Seguridad.ObtenerInformacion() )
			endif
		endif 
		Return llRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function Anterior() As Boolean
		Local llRetorno As Boolean

		llRetorno = .F.
		if ThisForm.oEntidad.EstaEnProceso()
		Else
			if goServicios.Seguridad.PedirAccesoEntidad( thisform.oEntidad.ObtenerNombreOriginal(), "BUSCAR", .F., thisform.oEntidad.ObtenerDescripcion() )
				This.cEstado = "NULO"

				llRetorno = Thisform.oEntidad.Anterior()
				If llRetorno
					This.SetearUltimaAccion( "Registro anterior" )
				Else
					if Thisform.oEntidad.haydatos()
					else
						goMensajes.Informar( "No hay " + Proper( Alltrim( Thisform.oEntidad.cDescripcion ) ) ;
							+ " en los archivos." )
					endif
					This.SetearUltimaAccion( "Primer registro" )
				Endif
			else
				goMensajes.Advertir( goServicios.Seguridad.ObtenerInformacion() )
			endif
		EndIf
		Return llRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function Cancelar() As Boolean
		Local llRetorno As Boolean , llContinua as Boolean 
		llContinua = .t.
		if ThisForm.oEntidad.EstaEnProceso()
			llRetorno = .F.
		Else
			if this.LHAYQUEVALIDARCANCELAR and !this.lVieneDelSalir 
				 llContinua = ( this.ConfirmarCancelar() = 6)
				
			endif	 
			this.lVieneDelSalir = .f. 
			if  llcontinua	 
				This.SetearUltimaAccion("Cancelada")
				This.cEstado = "NULO"

				if thisform.oEntidad.lNuevo or thisform.oEntidad.lEdicion
					llRetorno = Thisform.oEntidad.Cancelar()
				else
					llRetorno = Thisform.oEntidad.limpiar()
				endif
				
				if llRetorno
					this.DesbloquearBarraEstado()
				endif 
			endif 
			this.LHAYQUEVALIDARCANCELAR = .t.	
		endif 		
		Return llRetorno
	endfunc
	*-----------------------------------------------------------------------------------------
	function ConfirmarCancelar() as Integer
		local lnOpcion as Integer, lnResultado as Integer, lnBotonDefault as Integer 
		lnOpcion = goparametros.Nucleo.AvisarAlCancelarUnaEntidadMedianteLaTeclaEsc

		if lnOpcion = 3
			lnResultado = 6
		else
			lnBotonDefault = iif( lnOpcion = 3, 1, lnOpcion - 1 )
			lnResultado = goMensajes.Preguntar( "¿Desea cancelar?", 4, lnBotonDefault )
		endif		
	
		return lnResultado 
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function Escapar() As Boolean
		Local llRetorno As Boolean, lcAccionAnterior as String 
		llRetorno = .f.	

		if ThisForm.oEntidad.EstaEnProceso()
			llRetorno = .F.
		Else	

			if thisform.oEntidad.lNuevo or thisform.oEntidad.lEdicion 
				if this.ConfirmarCancelar() = 6
					this.lHayQueValidarCancelar = .f.
					this.PreCancelar()
					This.SetearUltimaAccion("Cancelada")
					This.cAccion = "cancelar"
					This.cEstado = "NULO"
					llRetorno = this.cancelar()
					this.lHayQueValidarCancelar = .t.
					if llRetorno
						this.DesbloquearBarraEstado()
					endif 
				else
					llRetorno = .F.
				endif
			else
				this.PreCancelar()
				This.SetearUltimaAccion("Cancelada")
				This.caccion = "cancelar"
				This.cEstado = "NULO"
				llRetorno = This.Cancelar()
			endif			
		endif 		

		Return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function Buscar() As Void
		Local llRetorno As Boolean
		
		llRetorno = .F.
		if this.oEntidad.EstaEnProceso()
		Else		
			if goServicios.Seguridad.PedirAccesoEntidad( this.oEntidad.ObtenerNombreOriginal(), "BUSCAR", .F., this.oEntidad.ObtenerDescripcion() )
				llRetorno = .t.
				If this.oEntidad.HayDatos()
					This.SetearUltimaAccion( "Busqueda" )
					This.cestado = "BUSQUEDA"
					this.oEntidad.Limpiar()
				Else
					This.cEstado = "NULO"
					goMensajes.Informar( "No hay " + Proper( Alltrim( this.oEntidad.cDescripcion ) ) ;
						+ " en los archivos." )
				Endif
			else
				goMensajes.Advertir( goServicios.Seguridad.ObtenerInformacion() )
			endif
		endif 
		
		return llRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function Salir() As Boolean
		Local llNuevo As boolean, llEdicion As boolean, llSalida as Boolean, lnResultado as Integer

		if ThisForm.oEntidad.EstaEnProceso()
			llSalida = .F.
		Else
			llSalida = .T.

			if this.OpcionHabilitadaMenu( "archivo", "grabar" )
				llNuevo = Thisform.oentidad.esnuevo()
				llEdicion = Thisform.oentidad.Esedicion()
				
				If llNuevo Or llEdicion
					
					if thisform.visible
						
						thisform.show()
						lnResultado = goMensajes.Preguntar( "¿Desea guardar los cambios?", 3, 1 )
						
						Do Case
							Case lnResultado = 6
								llSalida = This.Grabar()
							Case lnResultado = 2

								llSalida = .F.
							Case lnResultado = 7
								this.lVieneDelSalir = .t.
								this.Cancelar()
						endcase
					
					else
						this.Cancelar()
					endif

				Endif
			endif
		endif 		
		return llSalida
	Endfunc

	*-----------------------------------------------------------------------------------------
	function PreCancelar() as Void

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function PostCancelar() as Void

	endfunc 

	*-----------------------------------------------------------------------------------------
	Function Edit_Cortar() As Void
		Local lcPrimeraParte As String, lcUltimaParte As String

		_Cliptext = Thisform.ActiveControl.SelText

		With Thisform.ActiveControl
			lcPrimeraParte = Left( .Value, .SelStart )
			lcUltimaParte = Right( .Value, Len( .Value )- ( .SelStart + .SelLength ) )
			.Value = lcPrimeraParte + lcUltimaParte
		Endwith

		This.cEstado = "EDICION"

	Endfunc

	*-----------------------------------------------------------------------------------------
	Function Edit_Copiar() As Void

		_Cliptext = Thisform.ActiveControl.SelText
		This.cEstado = "EDICION"

	Endfunc

	*-----------------------------------------------------------------------------------------
	Function Edit_Pegar() As Void
		Local lcTextoSeleccionado As String ,lcPrimeraParte As String;
			, lcUltimaParte As String

		With Thisform.ActiveControl
			lcTextoSeleccionado = .SelText
			lcPrimeraParte = Left( .Value, .SelStart )
			lcUltimaParte = Right( .Value, Len(.Value )	- ( .SelStart + .SelLength ) )
			.Value = lcPrimeraParte + _Cliptext + lcUltimaParte
		Endwith

	Endfunc

	*-----------------------------------------------------------------------------------------
	Function AgregarEvento( txObjetoOrig As Variant, tcEventoOrig As String, ;
			txObjetoDest As Variant, tcEventoDest As String, tnFlag As Integer ) As Void
		Local loObjetoOrig As Object, loObjetoDest As Object, llRetorno As Boolean

		If Vartype( tnFlag ) != "N"
			tnFlag = 0
		Endif

		If Vartype( txObjetoOrig ) = "C"
			loObjetoOrig = This.ObtenerControl( txObjetoOrig )
		Else
			loObjetoOrig = txObjetoOrig
		Endif

		If Vartype( txObjetoDest ) = "C"
			loObjetoDest = This.ObtenerControl( txObjetoDest )
		Else
			loObjetoDest = txObjetoDest
		Endif

		llRetorno = Iif( Bindevent( loObjetoOrig, tcEventoOrig, loObjetoDest, tcEventoDest, tnFlag ) = 1, .T., .F. )
		
		Return llRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function Validar() As Void
	endfunc

	*-----------------------------------------------------------------------------------------
	function SeteaEstadoFormulario() as void
		local lcEstado as string, locontrol
		lcEstado = iif( Vartype( This.cestado ) = "C", upper( This.cestado ), "NULO" )
		this.SetearEstadoInternamente( thisform, lcEstado )
	
	endfunc

	*-----------------------------------------------------------------------------------------
	function DeshabilitarControl( toControl as Object )

		toControl.cEstado = "NULO"
		This.SetearEstadoInternamenteDeUnControl( toControl  , "NULO" )

	endfunc
	
	*-----------------------------------------------------------------------------------------
	function HabilitarControl( toControl as Object )
		local llEstado as boolean
		
		toControl.cEstado = ""
		llEstado = upper( This.cEstado ) # "NULO"
		
		This.SetearEstadoInternamenteDeUnControl( toControl  , upper( This.cEstado ) )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function SetearEstadoInternamente( toControl, tcEstado ) as Void
		local loCtrl as object, loError as zooexception OF zooexception.prg

		try
			for each loCtrl in toControl.controls
				this.SetearEstadoInternamenteDeUnControl( loCtrl, tcEstado )
				if pemstatus( toControl, "DesactivarColorAdvertencia", 5 )
					toControl.DesactivarColorAdvertencia()
				endif
			endfor
	
		catch to loError
			if type( " loError.UserValue.nZooErrorNo" ) = "N"
				if vartype( loError.UserValue ) = "O" and loError.UserValue.nZooErrorNo = 9001 and ;
					goParametros.Dibujante.AdvertirInexistenciaDeSubentidad and ;
					pemstatus( toControl, "ActivarColorAdvertencia", 5 )
					toControl.ActivarColorAdvertencia()
				else
					throw loError
				endif
			else
				throw loError
			endif
		endtry
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function SetearEstadoInternamenteDeUnControl( toControl, tcEstado ) as Void

		local loPage as object, loColu as object,	lcClass as character, ;
			lnKey as integer, lcKey as character, lnRetVal as integer, lcEstado as string

		lcEstado = upper( tcEstado )

		if this.SePuedeRecorrer( toControl )
			lcEstado = this.SetearYActualizar( toControl, tcEstado )
			lcClass = upper(toControl.baseclass)
				do case
				case  lcClass = 'PAGEFRAME'
					for each loPage in toControl.pages
						this.SetearEstadoInternamente( lopage, lcEstado  )
					endfor

					case lcClass = 'GRID'
					for each loColu in toControl.columns
						this.SetearEstadoInternamente( loColu, lcEstado  )
					endfor

				case pemstatus(toControl, 'ControlCount', 5) and ;
						goControles.EsUnControlSeteableInternamente( toControl )

					this.SetearEstadoInternamente( toControl, lcEstado  )

				case pemstatus(toControl, 'ButtonCount', 5)

				endcase

			if pemstatus(toControl, "DespuesDeSetearEstado", 5 )
				toControl.DespuesDeSetearEstado( lcEstado  )
			endif

			if pemstatus(toControl, "DespuesDeActualizar", 5 )
				toControl.DespuesDeActualizar()
			endif
			
			tcEstado = lcEstado
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function TieneSaltoDeCampoDefinidoPorElUsuario( toCtrl as Object ) as Boolean
		local llRetorno as Boolean, lcAtributo as String, loCtrl as Object
		llRetorno = .F.
		Try
			if upper( toCtrl.Class ) == "BOTON"
				loCtrl = toCtrl.Parent.txtDato
			else
				loCtrl = toCtrl
			Endif	
 
			if This.EsControlConSaltoDeCampoDefiniblePorElUsuario( loCtrl )
				lcAtributo = iif( loCtrl.lEsSubEntidad, loCtrl.cAtributoPadre, loCtrl.cAtributo )
				if this.EsAtributoTipoCodigo( lcAtributo ) and this.oEntidad.oComportamientoCodigoSugerido.TieneComportamientoCargado()
					llRetorno = this.oEntidad.oComportamientoCodigoSugerido.EsCodigoConSaltoDeCampoDefinidoPorElUsuario( this.oEntidad )
				else
					llRetorno = goServicios.SaltosDeCampoyValoresSugeridos.DebeSaltarElCampo( loCtrl.cEntidad, "", lcAtributo )
				endif
			Endif
		catch to loError
		finally
			loCtrl = Null
		EndTry
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsAtributoTipoCodigo( tcAtributo as String ) as Boolean
		local llRetorno as Boolean

		llRetorno = .F.
		if !empty( tcAtributo ) and !isnull( this.oEntidad )
			llRetorno = upper( alltrim( tcAtributo ) ) == upper( alltrim( this.oEntidad.ObtenerAtributoClavePrimaria() ) )
		endif
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearAtributoEsObligatorioEnControlesDefinidosPorElUsuario() as Void
		local loColAtributos as zoocoleccion OF zoocoleccion.prg, lnI as Integer, loControl as Object, ;
				lcAtributo as String
		loColAtributos = goServicios.SaltosDeCampoyValoresSugeridos.ObtenerColeccionAtributosObligatorios( this.oEntidad.ObtenerNombre() )
		for lnI = 1 to loColAtributos.Count
			if empty( loColAtributos.Item( lnI ).cDetalle )
				lcAtributo = upper( alltrim ( loColAtributos.Item( lnI ).cAtributo ) )
				if this.ExisteControl( lcAtributo )
					loControl = this.ObtenerControl( lcAtributo )
					goServicios.Controles.EstablecerObligatoriedadDeControl( loControl )
				endif
			endif
		next
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearInvisibilidadEnControlesDefinidosPorElUsuario() as Void
		local loColAtributos as zoocoleccion OF zoocoleccion.prg, lnI as Integer, loControl as Object, ;
				lcAtributo as String

		loColAtributos = goServicios.SaltosDeCampoyValoresSugeridos.ObtenerColeccionAtributosNoVisibles( this.oEntidad.ObtenerNombre() )
		for lnI = 1 to loColAtributos.Count
			lcAtributo = upper( alltrim ( loColAtributos.Item( lnI ).cAtributo ) )
			loControl = this.ObtenerControlParaOcultar( lcAtributo )
			if !isnull( loControl )
				loControl.Visible = .F.
			endif
		next
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearEtiquetasDefinidasPorElUsuario() as Void
		local loColAtributos as zoocoleccion OF zoocoleccion.prg, itemAtributo as Object , loControl as Object, ;
				lcAtributo as String, loContenido as Object

		loColAtributos = goServicios.SaltosDeCampoyValoresSugeridos.ObtenerPersonalizacionDeEtiquetas( this.oEntidad.ObtenerNombre() )
 	
		for each itemAtributo in loColAtributos
			if empty( itemAtributo.cDetalle )
				this.AsignarEtiqueta( itemAtributo )
			else
				loControl = this.ObtenerControl( upper( alltrim(itemAtributo.cDetalle ) ) )
				for each loContenido in loControl.objects
					if lower( loContenido.class ) = lower( "Encabezadogrillaext" )
						if upper( alltrim( loContenido.cAtributo ) ) = upper( alltrim( itemAtributo.cAtributo ) )
							loContenido.otitulo.caption	= itemAtributo.cEtiqueta
						endif
					endif 
				endfor
			endif 
		endfor
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AsignarEtiqueta( toItemAtributo as Object ) as Void
		local loControl as Object, lcNombreControl as String, lEsPosibleBloque as Boolean, lcContenedor as String  

		lcContenedor = "LABEL" + upper(alltrim(toItemAtributo.cAtributo ))
		loControl = this.ObtenerControlParaOcultar( upper( alltrim( toItemAtributo.cAtributo ) ))
		if !isnull(loControl) 
			if pemstatus( loControl, "cEtiqueta", 5)
				loControl.cEtiqueta		= toItemAtributo.cEtiqueta
				loControl.lbletiqueta.width	= loControl.txtdato.left-2-loControl.lbletiqueta.left
			else 
				if vartype( loControl.&lcContenedor ) = "O"
					loControl.&lcContenedor..cEtiqueta = toItemAtributo.cEtiqueta
					loControl.&lcContenedor..lbletiqueta.width	= loControl.&lcContenedor..txtdato.left-2-loControl.&lcContenedor..lbletiqueta.left
				endif 
			endif
		endif

	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerControlParaOcultar( tcNombreControl as String ) as Object
		local lcNombrePosileParent as String, loRetorno as Object, lcNombreControl as String
		
		loRetorno = null
		lcNombrePosileParent = this.ObtenerPosibleNombreDelControlParent( tcNombreControl )
		lcNombreControl = alltrim( upper( tcNombreControl ) )

		if this.ExisteControl( lcNombrePosileParent )
			loRetorno = this.ObtenerControl( lcNombrePosileParent )
		else
			if this.ExisteControl( lcNombreControl )
				loRetorno = this.ObtenerControl( lcNombreControl )
			endif
		endif
		
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerPosibleNombreDelControlParent( tcNombreControl as String ) as Void
		local lcRetorno as String, tcNombreHijo as String
		
		tcNombreHijo = upper( alltrim( tcNombreControl ) )
		lcRetorno = tcNombreHijo + "_" + upper( alltrim( this.oEntidad.ObtenerNombre() ) ) + tcNombreHijo
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsControlConSaltoDeCampoDefiniblePorElUsuario( toCtrl as Object ) as Boolean
		return vartype( toCtrl.lEsControlConSaltoDeCampoDefiniblePorElUsuario ) = "L" and toCtrl.lEsControlConSaltoDeCampoDefiniblePorElUsuario
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearPropiedadesDeComportamientoDeAtributos( toControlPadre, tcfullpath ) as Void
		local lSubControl as Object, lcFullpath as String, loControl as Object
		
		for each loControl in this.oControlesARecorrer
			this.SetearPropiedadesAControl( this.obtenercontrol( loControl ))
		endfor
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearPropiedadesAControl( toControlVisual ) as Boolean
		local loCtrl as object, loError as zooexception OF zooexception.prg, loControlX as Object, llRet as Boolean
		&& Funcion que sirve para cargar propiedades booleanas a los controles y no volver a preguntar a 
		&& los servicios de comportamiento de atributos
		
		try 
		
			try
				toControlVisual.lTieneSaltoCampo = goServicios.Controles.TieneSaltoCampo( toControlVisual  ) 
			catch
				addproperty( toControlVisual , "lTieneSaltoCampo", goServicios.Controles.TieneSaltoCampo( toControlVisual  ) )
			endtry

			try
				toControlVisual.lTieneSaltoDeCampoDefinidoPorElUsuario = This.TieneSaltoDeCampoDefinidoPorElUsuario( toControlVisual  ) 
			catch
				addproperty( toControlVisual , "lTieneSaltoDeCampoDefinidoPorElUsuario",  This.TieneSaltoDeCampoDefinidoPorElUsuario( toControlVisual  ) )
			endtry

			try
				toControlVisual.lEsAtributoNoEditableEnEntidadConEdicionRestringida = this.EsControlConAtributoNoEditable( toControlVisual  ) 
			catch
				addproperty( toControlVisual , "lEsAtributoNoEditableEnEntidadConEdicionRestringida", this.EsControlConAtributoNoEditable( toControlVisual  )  )
			endtry

		catch to loError
			&& Los controles creados dinamicamente pueden no tener las propiedades que se intenta setear
		endtry 
		return .t.
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function SetearYActualizar( toCtrl, tcEstado ) as string
		local lcEstado as String
	
		lcEstado = upper( tcEstado )
		try

			if  upper( toCtrl.Class ) == "BOTON" and pemstatus( toCtrl, "parent",5 ) and pemstatus( toCtrl.parent, "txtDato",5 ) and pemstatus( toCtrl.parent.txtDato, "lTieneSaltoCampo",5 ) and toCtrl.parent.txtDato.lTieneSaltoCampo
				toCtrl.lTieneSaltoCampo = toCtrl.parent.txtDato.lTieneSaltoCampo 
			endif	
					
			if ( toCtrl.lTieneSaltoCampo and ( !pemstatus( toCtrl, "lDetalle ",5 ) or !toCtrl.lDetalle ) ) or toCtrl.lTieneSaltoDeCampoDefinidoPorElUsuario
				toCtrl.cEstado = "NULO"

			else
				if this.EsAtributoNoEditableEnEntidadConEdicionRestringida( toCtrl )
					if pemstatus( toCtrl, "cEstado", 5 ) and lcEstado = "EDICION"
						toCtrl.cEstado = "NULO"
					else
						toCtrl.cEstado = ""
					endif
				endif
			endif
		catch to loError
			&& Esto es para los casos donde desde el evento init del formulario sin hacer set general de las propiedades TieneSaltoCampo,TieneSaltoDeCampoDefinidoPorElUsuario,lEsAtributoNoEditableEnEntidadConEdicionRestringida 
		endtry

		if pemstatus( toCtrl, "cEstado", 5 ) and !empty( toCtrl.cEstado )
			if  upper( this.cAccion ) = "BUSCAR" and ( ( pemstatus( toCtrl, "lClavePrimaria", 5 ) and toCtrl.lClavePrimaria and ;
													pemstatus( toCtrl, "lEsSubEntidad", 5 ) and !toCtrl.lEsSubEntidad ) or ;
													( pemstatus( toCtrl.Parent, "lClavePrimaria", 5 ) and toCtrl.Parent.lClavePrimaria and ;
													pemstatus( toCtrl.Parent, "lEsSubEntidad", 5 ) and !toCtrl.Parent.lEsSubEntidad ) )
				lcEstado = "BUSQUEDA"
			else
				lcEstado = toCtrl.cEstado
			endif
		endif

		this.SetearControl( toCtrl, lcEstado )

		if pemstatus( toCtrl, "Actualizar", 5 )
			toCtrl.Actualizar()
		endif
		
		return lcEstado
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function EsControlConAtributoNoEditable( toCtrl as Object ) as Boolean
		local llRetorno as Boolean, loCtrl as Object, l1 as Boolean, l2 as Boolean, l3 as Boolean, l4 as Boolean
		l1 = This.oEntidad.oAtributosConEdicionRestringida.Count > 0
		l2 = pemstatus( toCtrl, "lEsControlConSaltoDeCampoDefiniblePorElUsuario", 5 )
		l3 = This.oEntidad.lEsEntidadConEdicionRestringida
		l4 = !This.EsAtributoEditableEnEntidadConEdicionRestringida( toCtrl  )		
		llRetorno = l1 and l2 and l3 and l4 
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsAtributoNoEditableEnEntidadConEdicionRestringida( toCtrl as Object ) as Boolean
		local llRetorno as Boolean, loCtrl as Object, l1 as Boolean, l2 as Boolean
		l1 = toCtrl.lEsAtributoNoEditableEnEntidadConEdicionRestringida
		l2 = ( pemstatus( this.oEntidad, "BloquearRegistro",5 ) and this.oEntidad.BloquearRegistro ) 
		llRetorno = l1 and l2
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsAtributoEditableEnEntidadConEdicionRestringida( toCtrl as Object ) as Boolean
		local llRetorno as Boolean
		llRetorno = .f.
		if This.EsControlConSaltoDeCampoDefiniblePorElUsuario( toCtrl )
			lcAtributo = iif( toCtrl.lEsSubEntidad, toCtrl.cAtributoPadre, toCtrl.cAtributo )

			if pemstatus(this.oEntidad,"EsAtributoEditableEnEntidadConEdicionRestringida",5) and this.oEntidad.EsAtributoEditableEnEntidadConEdicionRestringida( lcAtributo )
				llRetorno = .T.
			endif
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SePuedeRecorrer( toCtrl ) as Boolean
		local llRetorno as Boolean
		&& Significa que no es un Control Nuestro (Menu Ruso)

		llRetorno = !pemstatus(toCtrl, 'BaseClass', 2) and !( upper( toCtrl.BaseClass ) = "SESSION" ) and ;
			!inlist( alltrim( upper( toCtrl.name ) ), "OMENU", "OTOOLBAR", "LBLTITULO", "LNLLINEA", "IMGLOGODERECHO", "IMGLOGOIZQUIERDO", "_IMAGENARTICULO", "LBLETIQUETA", "PROPERTIES", "COMMANDBARCONTROLS", "CBM", "OBARRAESTADO", "MAINMENU", "TOOLBAR1", "OPARCHE" )

		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function SetearControl( toCtrl, tcEstado ) as void
		with goControles
			if pemstatus( toCtrl, "enabled", 5 ) and .EsUnContenedorSeteable( toCtrl ) and .EsUnControlSeteable( toCtrl )
				toCtrl.enabled = ( upper( tcEstado ) = "NUEVO" or upper( tcEstado ) = "EDICION" or upper( tcEstado ) = "GUARDARCOMO")
				if upper( tcEstado ) = "GUARDARCOMO" and pemstatus( toCtrl, 'HabilitarBotonGuardarComo', 5)
					toCtrl.enabled =  toCtrl.HabilitarBotonGuardarComo 
				endif				
			endif
		endwith

		if pemstatus( toCtrl, "SetearEstado", 5 )
			toCtrl.SetearEstado( tcEstado )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	Function DeshabilitarBarra() As void
		this.SetearClosable( .f. )
		
		this.SetearEnabledDeUnControl( thisform.oMenu.menu_Archivo, "menu_primero", .f. )
		this.SetearEnabledDeUnControl( thisform.oMenu.menu_Archivo, "menu_Anterior", .f. )	
		this.SetearEnabledDeUnControl( thisform.oMenu.menu_Archivo, "menu_siguiente", .f. )
		this.SetearEnabledDeUnControl( thisform.oMenu.menu_Archivo, "menu_ultimo", .f. )
		this.SetearEnabledDeUnControl( thisform.oMenu.menu_Archivo, "menu_modificar", .f. )
		this.SetearEnabledDeUnControl( thisform.oMenu.menu_Archivo, "menu_Grabar", .f. )
		this.SetearEnabledDeUnControl( thisform.oMenu.menu_Archivo, "menu_eliminar", .f. )
		this.SetearEnabledDeUnControl( thisform.oMenu.menu_Archivo, "menu_cancelar", .f. )
		this.SetearEnabledDeUnControl( thisform.oMenu.menu_Archivo, "menu_nuevo", .f. )
		this.SetearEnabledDeUnControl( thisform.oMenu.menu_Archivo, "menu_buscar", .f. )		
		this.SetearEnabledDeUnControl( thisform.oMenu.menu_Archivo, "menu_imprimir", .f. )
		this.SetearEnabledDeUnControl( thisform.oMenu.menu_Archivo, "menu_generarpdf", .f. )		
			
		
		this.SetearEnabledDeUnControl( thisform.oToolBar, "barra_primero", .f. )
		this.SetearEnabledDeUnControl( thisform.oToolBar, "barra_Anterior", .f. )
		this.SetearEnabledDeUnControl( thisform.oToolBar, "barra_siguiente", .f. )
		this.SetearEnabledDeUnControl( thisform.oToolBar, "barra_ultimo", .f. )
		this.SetearEnabledDeUnControl( thisform.oToolBar, "barra_modificar", .f. )
		
		this.SetearEnabledDeUnControl( thisform.oToolBar, "barra_Grabar", .f. )
		this.SetearEnabledDeUnControl( thisform.oToolBar, "barra_eliminar", .f. )
		this.SetearEnabledDeUnControl( thisform.oToolBar, "barra_nuevo", .f. )
		this.SetearEnabledDeUnControl( thisform.oToolBar, "barra_buscar", .f. )
		
		
		if type( "Thisform.oToolBarInfo.barra_cancelar" ) == "O"
			this.SetearEnabledDeUnControl( thisform.oToolBar, "barra_cancelar", .f. )
			thisform.oToolBarInfo.Refresh()
		endif
	Endfunc

	*-----------------------------------------------------------------------------------------
	protected function SetearEnabledDeUnControl( toControl as Object, tcPropiedad as String, tlEnabled as Boolean ) as Void
		local lcControl as String
		lcControl = "toControl." + tcPropiedad
		If type( lcControl ) == "O"
			lcControl = lcControl + ".Enabled = " + transform( tlEnabled )
			&lcControl
		Endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoDespuesDeProcesar( tlValor as Boolean ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarEntidadRelacionada( tcEntidad ) as Void
		local loFormulario as Object

		assert empty( tcEntidad ) = .F. message "Debe recibir el nombre de la entidad por parametro."
	
		if upper( this.cEstado ) = "NUEVO"
			if goMensajes.Preguntar("Es necesario guardar el  " + thisform.oEntidad.cNombre + ". " + "¿Desea grabar ahora?", 4 , 1 ) = 6 
				
				this.Grabar()
				this.Modificar()	
			endif 
		endif 
		
		if upper( this.cEstado ) = "EDICION" or upper( this.cEstado ) = "NULO"
			loFormulario = goFormularios.procesar( tcEntidad )		
			if vartype( loFormulario ) = "O"
				loFormulario.show()
			endif
		endif 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function MostrarEntidadRelacionada( tcEntidadHija as String ) as Void
		local lcEntidadPadre as String, lcValorClavePrimaria as String, lcAtributoClavePrimaria as String

		with thisform
			lcEntidadPadre = strtran(.oEntidad.ObtenerNombre(),"'","")
			lcAtributoClavePrimaria = .oEntidad.ObtenerAtributoClavePrimaria()
			if pemstatus( .oentidad, "oAtributos", 5 )
				lcValorClavePrimaria = goLibrerias.ValorAString( .oEntidad.ObtenerValorAtributo( lcAtributoClavePrimaria ))
			else
				lcValorClavePrimaria = goLibrerias.ValorAString( .oEntidad..&lcAtributoClavePrimaria )
			endif
		endwith

		goformularios.MostrarScx("EntidadRelacionada", .f., tcEntidadHija, lcEntidadPadre, lcValorClavePrimaria )

	endfunc 

	*-----------------------------------------------------------------------------------------
	function HayDatos() as Boolean 
		return thisform.oEntidad.HayDatos()
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearEstadoDelMenu( tlEstado ) as Void
		local lni as Integer, lcAccion as String, loMenu as object 
		lcAccion = ""
	
		for each loMenu in thisform.oMenu.objects foxObject
			if lomenu.class = "_menubaritem"
				lomenu.enabled = tlestado
			endif
		endfor
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearEstadoMenuYToolBar( tlEstado as Boolean ) as Void
	
		if pemstatus( thisform, "oToolbar", 5 ) and vartype( thisform.oToolbar ) == 'O'
			if tlEstado
				this.ActualizarBarra()
			else
				this.DeshabilitarBarra()
			endif
		else
			this.SetearEstadoCerrarFormulario( tlEstado )
		endif 
				
		if pemstatus( thisform, "oMenu", 5 ) and vartype( thisform.oMenu ) == "O"
			this.SetearEstadoDelMenu( tlEstado )
			thisform.oMenu.enabled = tlEstado 
			thisform.cbm.enabled = tlEstado 
		endif 	
		if pemstatus( thisform, "oToolbar", 5 ) and vartype( thisform.oToolbar ) == "O"
			thisform.oToolbar.enabled = tlEstado 
		endif 		
	endfunc

	*-----------------------------------------------------------------------------------------
	function SetearEntidad( toEntidad ) as Void
		This.oEntidad = toEntidad
		this.lEntidadInicializada = vartype( toEntidad ) = 'O'
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Destroy() as Void
		This.oEntidad = Null
		This.oMensaje = null
		dodefault()
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	function SetearEstadoMenuCabeceras( tlEstado as Boolean ) as Void
		local lnCantidad as Integer, lnIndice as Integer,  lcEjecutar as String
		local array laMiembros[1]
		
		if type( "thisForm.oMenu" ) = "O"
			thisForm.oMenu.Enabled = tlEstado
			thisForm.oMenu.refresh()
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function SetearEstadoMenuItems( tlEstado as Boolean, toCabecera as Object ) as Void
		local lnCantidad as Integer, lnIndice as Integer,  lcEjecutar as String
		local array laMiembros[1]
		
		lnCantidad = amembers( laMiembros, toCabecera, 3 )
		for lnIndice = 1 to lnCantidad
			if upper( alltrim( left( laMiembros[ lnIndice, 1 ], 5 ) )) == "MENU_"
				lcEjecutar = "toCabecera."+ laMiembros[ lnIndice, 1 ] + ".Enabled = tlEstado"
				&lcEjecutar.
			endif
		endfor
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function DeshabilitarToolBarCompleta() as Void
		local lnCantidad as Integer, lnIndice as Integer,  lcEjecutar as String
		local array laMiembros[1]
		if type( "thisForm.oToolbar" ) = "O"
			lnCantidad = amembers( laMiembros, thisForm.oToolbar,3 )
			for lnIndice = 1 to lnCantidad
				if upper( alltrim( left( laMiembros[ lnIndice, 1 ], 6 ) )) == "BARRA_"
					lcEjecutar = "thisForm.oToolbar."+ laMiembros[ lnIndice, 1 ] + ".Enabled = .f."
					&lcEjecutar.
				endif
			endfor
			thisForm.oToolbar.refresh()
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearEstadoBotonera( tlEstado as Boolean ) as Void
		if type( "thisform._Botonera.cmdAceptar" ) = "O"
			thisform._Botonera.cmdAceptar.enabled = tlEstado 
		endif
		if type( "thisform._Botonera.cmdCancelar" ) = "O"
			thisform._Botonera.cmdCancelar.enabled = tlEstado 
		endif
		if type( "thisform._Botonera" ) = "O"
			thisform._Botonera.refresh()
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function EstaAccionBloqueaRefrescoDePantalla( tcAccion as string ) as Boolean
		return upper( alltrim( tcAccion ) ) == "GRABAR"
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EjecutarTransferencia() as Boolean 
		local llRetorno as Boolean , loItem as Object, loError as zooexception OF zooexception.prg, ;
			loEx as zooexception OF zooexception.prg 

		llRetorno = .T.
		if ThisForm.oEntidad.EstaEnProceso()
			llRetorno = .F.		
		else
			try
				loItem = This.CrearItemTransferencia()
				goServicios.Transferencias.Mostrar( This.ObtenerNombreTransferencia() , .F., loItem )
			catch to loError
				llRetorno = .F.
				loEx = newobject( "ZooException", "ZooException.prg" )
				with loEx
					loEx.Message = "Error al realizar el empaquetado."
					.Grabar( loError )
					
				endwith
				goServicios.Mensajes.Alertar( loEx )
			endtry			
		endif 
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerNombreTransferencia() as String
		return alltrim( this.oEntidad.ObtenerNombreTransferencia() )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CrearItemTransferencia() as Object
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearComportamiento() as Void
		with this
			If !inlist ( Alltrim( Upper( .cAccion )), "SALIR", "ESCAPAR" )
				.ActualizarFormulario()
				.ActualizarBarra()
				this.SetearClosable( .T. )
				Thisform.Refresh()
				If alltrim( upper( .cEstado ) ) == "NULO"  or alltrim( upper( .cEstado ) ) == "BUSQUEDA"
				else
					if .ManejoValidacionObligatorios()
					else
						.SetearFoco()
					endif
				endif
			endif
		endwith	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function BloquearBarraEstado() as Void
		If This.ExisteFormularioActivo() and Vartype( Thisform.oBarraEstado ) = "O"
			Thisform.oBarraEstado.bloquear()
		Endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function DesbloquearBarraEstado() as Void
		If This.ExisteFormularioActivo() and Vartype( Thisform.oBarraEstado ) = "O"
			Thisform.oBarraEstado.desbloquear()
		Endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function OpcionHabilitadaMenu( tcMenu as string, tcOpcion as String ) as Boolean 
		local llRetorno as Boolean 

		llRetorno = .F.
		if type( "thisform.oMenu.menu_" + alltrim( tcMenu ) + ".menu_" + alltrim( tcOpcion ) ) = "O"
			local lcSentencia as String 
			lcSentencia = "llRetorno = thisform.oMenu.menu_" + alltrim( tcMenu ) + ".menu_" + alltrim( tcOpcion ) + ".Enabled"
			&lcSentencia
		endif
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function OpcionHabilitadaMenuDeSubMenu( tcMenu as string, tcSubMenu as String, tcOpcion as String ) as Boolean 
		local llRetorno as Boolean 

		llRetorno = .F.
		if type( "thisform.oMenu.menu_" + alltrim( tcMenu ) + ".menu_" + alltrim( tcSubMenu ) + ".menu_" + alltrim( tcOpcion ) ) = "O"
			local lcSentencia as String 
			lcSentencia = "llRetorno = thisform.oMenu.menu_" + alltrim( tcMenu ) + ".menu_" + alltrim( tcSubMenu ) + ".menu_" + alltrim( tcOpcion ) + ".Enabled"
			&lcSentencia
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ManejoValidacionObligatorios() as Boolean  
		local lnUbicacion as Integer, llRetorno as Boolean 
		llRetorno = .F.
		lnUbicacion = this.oManejadorErrores.huboErrorUP( 9005 )
		if lnUbicacion > 0
			local lcAtributo as String, loControl as Object 
			lcAtributo = this.oInformacionUltimoProceso.item[ lnUbicacion ].xInfoExtra
			if this.ExisteControl( lcAtributo )
				loControl = this.obtenerControl( lcAtributo )
				loControl.setFocus()
				llRetorno = .T.
			Endif	
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function MensageLogueoInicial() as String
		local lcRetorno as String 
	
		lcRetorno = dodefault()
		return lcRetorno + this.DescripcionEntidad() + " -> " + this.cAccion
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function DescripcionEntidad() as String 
		local lcRetorno as String 
		lcRetorno = ""

		if pemstatus( this.oEntidad, "ObtenerDescripcion", 5 )
			lcRetorno = this.oEntidad.ObtenerDescripcion()
		else
			if pemstatus( this.oEntidad, "cDescripcion", 5 ) and vartype( this.oentidad.cDescripcion ) = "C"
				lcRetorno = this.oEntidad.cDescripcion
			else
				lcRetorno = this.oEntidad.name
			endif
		endif 

		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function DeshabilitarAcciones() as void
		This.SetearEstadoMenuCabeceras( .f. )
		this.DeshabilitarToolBarCompleta()
		this.SetearEstadoBotonera( .f. )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function HabilitarAcciones() as Void
		This.SetearEstadoMenuCabeceras( .t. )
		if type( "thisForm.oToolbar" ) = "O" and type( "thisForm.oMenu" ) = "O"
			This.ActualizarBarra()
		endif
		this.SetearEstadoBotonera( .t. )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearFoco() as Void
		if this.SetearFocoEnUltimoControlActivo()
			this.oUltimoControlActivo.SetFocus()
		else
			this.SetearPrimerControl()
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearFocoEnUltimoControlActivo() as Boolean
		return !inlist( upper( alltrim( this.cAccion ) ), "NUEVO", "MODICIAR" ) and type( "this.oUltimoControlActivo" ) == "O" and !isnull( this.oUltimoControlActivo )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ActualizarBarraOpcionesNoGenericas( tcEstado as String ) as Void
		** Implementar en los kontroler's.
	endfunc 
	
 	*-----------------------------------------------------------------------------------------
	function ActualizarProgressBar( tnValor as Integer ) as void
		if pemstatus( thisform, "oBarraEstado", 5 )
			with thisform.oBarraEstado.oProgressBar
				inkey(0.01)
				.Max = .Max 
				.Value = iif( tnValor = 0, .Value, tnValor )
				.Visible = iif( tnValor = 0, .f., .t. )
			endwith
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoMensaje( tcTipoMensaje as String, toObjeto as object, tcMensaje as string, tnBotones as Integer, tnBotonDefault as Integer, tcTitulo as String, tnTiempo as Integer ) as Void
		*** Bindeado a la entidad, detalle, item
		toObjeto.oMensaje.SetearRespuesta( goServicios.Mensajes.&tcTipoMensaje.( tcMensaje, tnBotones, tnBotonDefault, tcTitulo, tnTiempo ))
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	hidden function Activar() as Void
		this.EjecutarActivacionDesactivacion( "Activar" )
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	hidden function Desactivar() as Void
		this.EjecutarActivacionDesactivacion( "Desactivar" )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	hidden function EjecutarActivacionDesactivacion( tcAccion as String ) as Boolean
		local lcAccion as String, loError as Exception

		if goServicios.Seguridad.PedirAccesoEntidad( this.oEntidad.ObtenerNombreOriginal(), upper( tcAccion ), .F., thisform.oEntidad.ObtenerDescripcion() )
			This.SetearUltimaAccion( proper( tcAccion ) )
			lcAccion = "this.oEntidad.oDesactivador." + Alltrim( tcAccion ) + iif( at( ")", tcAccion ) = 0,"()","")
			try
				&lcAccion
				this.ActualizarProgressBar( 100 )
			catch to loError
				goServicios.Errores.LevantarExcepcion( loError )			
			finally
				this.ActualizarProgressBar( 0 )
			endtry
		else
			goServicios.Mensajes.enviar( goServicios.Seguridad.ObtenerInformacion() )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function HabilitaInformacionAdicional() as Boolean
		Local llRetorno as Boolean, lcCursor as Object, lcXML as String, lcAtributoPK as string, llCampoPrincipalVacio as Boolean

		llRetorno = .F.
		if vartype( This.oEntidad ) = "O" &&and pemstatus( This.oEntidad, "lNuevo", 5 ) and pemstatus( This.oEntidad, "lEdicion", 5 ) &&and type( "thisform.oToolBar.Barra_grabar" ) = "O"
			if this.oEntidad.lNuevo or this.oEntidad.lEdicion
			else
				lcAtributoPK = this.oEntidad.ObtenerAtributoClavePrimaria()
				llCampoPrincipalVacio = empty( this.oEntidad.&lcAtributoPK )
				llRetorno =	!llCampoPrincipalVacio &&and !thisform.oToolBar.barra_grabar.enabled 	
			EndIf	
		endif
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function MostrarInformacionAdicional() as Void
		local loFormInfAdicional as Object
		loFormInfAdicional = goFormularios.procesar( "InformacionAdicionalCompVtas" )
		if vartype( loFormInfAdicional ) == "O"
			loFormInfAdicional.oKontroler.LlenarDatosDeInformacionAdicional( this.oEntidad )
			loFormInfAdicional.Show()
		endif
	endfunc
		
	*-----------------------------------------------------------------------------------------
	function ObtenerReferenciaInformacionAdicional( toEntidad as Object ) as Void
		local lcReferencia as string

		lcReferencia = toEntidad.oAd.ObtenerIdentificador( toEntidad )
		
		return lcReferencia
	endfunc

	*-----------------------------------------------------------------------------------------
	function SetearColorDeFondo() as Void
		local lnColor as Integer
		lnColor = this.ObtenerColorDeFondo()
		if !empty( lnColor )
			thisform.BackColor = lnColor
			this.SetearColorPageFrame()
		endif 	
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerColorDeFondo() as Integer 
		local lnColor as Integer 
		lnColor = getcolor()
		return lnColor 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearColorPageFrame() as Void
		thisform.SetearColorPageFrame()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearValorParametro() as Void
		this.lIniciaNuevoDespuesDeGrabar = goServicios.Entidades.AccionesAutomaticas.LaEntidadTieneIniciarDespuesDeGuardar( this.oEntidad.cNombre )
		this.lDebeConcatenarUsuarioAutorizante = goParametros.nucleo.Generales.AgregaAlUsuarioLogueadoElUltimoUsuarioQueInvocaLaSeguridad
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EncenderNuevoAutomatico() as Void
		this.lPuedeHacerNuevoAutomatico = .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ApagarNuevoAutomatico() as Void
		this.lPuedeHacerNuevoAutomatico = .f.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoFinalizoGrabar() as Void
		if this.lIniciaNuevoDespuesDeGrabar and this.lPuedeHacerNuevoAutomatico 
			this.Ejecutar( "NUEVO" )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CorregirControlVisualEnFormularioSubentidad( toForm as Form ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function MostrarFormAgrupamientoPublicaciones( tcValorCombo as Object ) as Void
		local loLanzador as Object, lcDespachos as String
		
		if !inlist( alltrim( tcValorCombo ), "Publicación: Todas", "Publicación: Ninguna" ) && es 'Personalizado' o la que muestra los agrupamientos
			This.oEntidad.cValorComboToolbarAnterior = This.oEntidad.cValorComboToolbar
			this.SetearEstadoMenuYToolbar(.f.)
			loLanzador = _screen.zoo.crearobjeto("LanzadorAgrupamientoPublicaciones")
			loLanzador.Lanzar( this )
			loLanzador = null
			This.AnalizarRetornoYSetearValores()
			this.SetearEstadoMenuYToolbar(.T.)
		else
			This.oEntidad.cValorComboToolbarAnterior = tcValorCombo
			This.oEntidad.TipoAgrupamientoPublicaciones = iif( alltrim( tcValorCombo ) = "Publicación: Todas", 1, 2 )
			Thisform.oToolbar.Combo_bases.ToolTipText = "Destino para publicaciones: " + iif( This.oEntidad.TipoAgrupamientoPublicaciones = 1, "Todas", "Ninguna" )
			
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function AnalizarRetornoYSetearValores() as Void
		local cValorComboDeAgrupamiento as String, lcValorToolTip as String
		
		if empty( alltrim( This.oEntidad.cValorComboToolbar ) )
			cValorComboDeAgrupamiento = alltrim( This.oEntidad.cValorComboToolbarAnterior )
			* Si vuelve vacío (borró todo), borro el detalle y selecciono valor del combo por default (Todas)
			if !inlist( This.oEntidad.cValorComboToolbarAnterior, "Publicación: Todas","Publicación: Ninguna" )
				This.oEntidad.TipoAgrupamientoPublicaciones = 1 && 1 = Todas
				Thisform.oToolbar.Combo_bases.RowSource = "Publicación: Todas,Publicación: Ninguna,Personalizado"
				Thisform.oToolbar.Combo_bases.ReQuery()
				Thisform.oToolbar.Combo_bases.ListIndex = 1
				This.oEntidad.LimpiarDatosDetalleAgrupamientoPublicaciones()
				cValorComboDeAgrupamiento = "Todas"
			else  && Si es Todas o ninguna, seteo la posicion de ese valor en el atributo TipoAgrupamientoPublicaciones de la entidad
				if alltrim( This.oEntidad.cValorComboToolbarAnterior ) == "Publicación: Todas"
					This.oEntidad.TipoAgrupamientoPublicaciones = 1 && 1 = Todas
					Thisform.oToolbar.Combo_bases.ListIndex = 1
				else
					This.oEntidad.TipoAgrupamientoPublicaciones = 2 && 2 = Ninguna
					Thisform.oToolbar.Combo_bases.ListIndex = 2
				endif
			endif
			lcValorToolTip = cValorComboDeAgrupamiento
		else
			cValorComboDeAgrupamiento = alltrim( This.oEntidad.cValorComboToolbar )
			if cValorComboDeAgrupamiento == "Cancelo"
				if this.oEntidad.AgruPubliDetalle.CantidadDeItemsCargados() = 0
					cValorComboDeAgrupamiento = "Todas"
					Thisform.oToolbar.Combo_bases.RowSource = "Publicación: Todas,Publicación: Ninguna,Personalizado"
					Thisform.oToolbar.Combo_bases.ReQuery()
					lcValorToolTip = cValorComboDeAgrupamiento
					This.oEntidad.TipoAgrupamientoPublicaciones = 1 && 1 = Todas
					Thisform.oToolbar.Combo_bases.ListIndex = 2
					Thisform.oToolbar.Combo_bases.ListIndex = 1
				else
					*cValorComboDeAgrupamiento = alltrim( This.oEntidad.cValorComboToolbarAnterior )
					cValorComboDeAgrupamiento =  This.oEntidad.CargarCadenaAgrupamientosParaComboToolbar( 1 )
					lcValorToolTip = This.oEntidad.CargarCadenaAgrupamientosParaComboToolbar( 2 ) && Aca cargo los agrupamientos sin limite de caracteres, ya que lo muestro en el tooltip
					This.oEntidad.TipoAgrupamientoPublicaciones = 3 && 1 = Personalizado
					Thisform.oToolbar.Combo_bases.RowSource = "Publicación: Todas,Publicación: Ninguna,Personalizado," + cValorComboDeAgrupamiento
					Thisform.oToolbar.Combo_bases.ReQuery()
					Thisform.oToolbar.Combo_bases.ListIndex = 3
					Thisform.oToolbar.Combo_bases.ListIndex = 4
				endif
			else
				Thisform.oToolbar.Combo_bases.RowSource = "Publicación: Todas,Publicación: Ninguna,Personalizado," + cValorComboDeAgrupamiento
				Thisform.oToolbar.Combo_bases.ReQuery()
				Thisform.oToolbar.Combo_bases.ListIndex = 3
				Thisform.oToolbar.Combo_bases.ListIndex = 4
				This.oEntidad.cValorComboToolbarAnterior = cValorComboDeAgrupamiento
				lcValorToolTip = This.oEntidad.CargarCadenaAgrupamientosParaComboToolbar( 2 ) && Aca cargo los agrupamientos sin limite de caracteres, ya que lo muestro en el tooltip
				This.oEntidad.TipoAgrupamientoPublicaciones = 3 && 3 = Personalizado
			endif
		endif
		Thisform.oToolbar.Combo_bases.ToolTipText = "Destino para publicaciones: " + lcValorToolTip
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EnviarMail() as Void
		
		local llRetorno as Boolean 
		llRetorno = .f.
		if ThisForm.oEntidad.EstaEnProceso()
		Else
			this.oInformacionUltimoProceso.Limpiar()
			This.SetearUltimaAccion( "Enviar e-mail" )
			Try
				this.oEntidad.EnviarMail()	
				llRetorno = .t.
			catch to loError
				this.ManejarErrorProceso( loError, "Advertir", "Error al enviar e-mail" )
			Endtry
			
			if llretorno
				thisform.lhaydatos = this.haydatos()
				this.cestado = "NULO"
			endif
		endif 
		
		Return llRetorno
	
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function SetearClosable( tlClosable as Boolean ) as Void
		&& tlClosable => .t. => Permite cerrar el formulario con la X (Cruz).
		&& tlClosable => .f. => NO Permite cerrar el formulario con la X (Cruz).
		thisform.Closable = tlClosable
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function DespuesDeMover() as Void
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function MensajeDenegarEmpaquetado( tcTexto as String ) as Void
		loInformacion = goServicios.Seguridad.ObtenerInformacion()
		if loInformacion.count >= 1
			goMensajes.Advertir( goServicios.Seguridad.ObtenerInformacion() )
		else
			goServicios.Mensajes.informar( tcTexto )
		endif
	endfunc
		
	*-----------------------------------------------------------------------------------------
	protected function SetearUltimaAccionYEstado(tcAccion as String, tcEstado as String) as Void
		This.SetearUltimaAccion( tcAccion )
		This.cEstado = iif(empty(tcEstado), This.cEstado, tcEstado)
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function VerificarEstadoRegistroTerminal( tcAccion as String ) as Void
		if !_screen.zoo.app.lDesarrollo and Alltrim( Upper( .cAccion )) != "SALIR" and _screen.zoo.app.lSalidaDesdeRegistroTerminalFallo
			goServicios.Errores.LevantarExcepcion( "Se encontraron inconsistencias en uso del serie actual. Para continuar utilizando el sistema es necesario cerrarlo y volverlo abrir." )	
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function SetearTituloPersonalizadoDeFromulario() as Void
		local lcTitulo as String
		lcTitulo = this.ObtenerDenominacionPersonalizaPluralDeEntidad()
		if !empty( lcTitulo )
			thisform.Caption = lcTitulo
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function DeboGuardarUsuarioAutorizante() as VOID
		local lxRetorno as Variant

		if this.lDebeConcatenarUsuarioAutorizante and vartype( This.oEntidad ) = "O" and pemstatus( This.oEntidad, "cUsuarioQueAutorizoSeguridad",5 ) &&and "<VENTAS>" $ this.oEntidad.ObtenerFuncionalidades()
			this.oEntidad.cUsuarioQueAutorizoSeguridad = ""						
			lxRetorno = ""
		endif

		return lxRetorno

	endfunc 

	*-----------------------------------------------------------------------------------------
	function PreguntarConfirmacionImpresion( tcMensaje as String, tnBotones as Integer, tnRespuestaSugerida as Integer ) as void 

		this.oEntidad.lConfirmarImpresion = goServicios.Mensajes.Preguntar( tcMensaje, tnBotones, tnRespuestaSugerida )

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerDenominacionPersonalizaPluralDeEntidad() as String
&& Se genera si la entidad tiene la funcionalidad personalizacion
		return ''
	endfunc 

enddefine

