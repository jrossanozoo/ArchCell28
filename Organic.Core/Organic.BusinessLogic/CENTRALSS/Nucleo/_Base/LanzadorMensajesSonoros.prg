define class LanzadorMensajesSonoros as LanzadorMensajes of LanzadorMensajes.prg

	#IF .f.
		Local this as LanzadorMensajesSonoros of LanzadorMensajesSonoros.prg
	#ENDIF

	nRetorno = 0
	nEstilo = 2
	oMensajeSinEspera = null
	lEsBuildAutomatico = .f.
	
	*-----------------------------------------------------------------------------------------
	function init() as Void
		dodefault()
		this.nEstilo = Iif( Vartype( goParametros ) = "O" and Vartype( goParametros.Dibujante ) = "O", goParametros.Dibujante.Estilo, 2 )
		this.oMensajeSinEspera = this.crearobjeto( "MensajeSinEspera" )
		
		this.lEsBuildAutomatico = _screen.zoo.EsBuildAutomatico
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Enviar( tvMensaje as Variant, tnBotones as integer , tnIcono as integer, tnBotonDefault as integer, tcTitulo as string, tnTiempoEspera as Integer ) as Integer
		local lnRetorno, lnParametros as integer, loFrm as Object , loInfo as zooinformacion of zooInformacion.prg, ;
		 lvMensaje as Variant, llHayKontroler as Boolean , loFormulario as Object, llLockScreen as Boolean

		llHayKontroler = .f.
		store 0 to lnRetorno, this.nRetorno
		if empty( tnBotones )
			tnBotones = 0
		endif
		store pcount() to lnParametros

		if this.lEsBuildAutomatico
			if lnParametros = 1
				lnRetorno = 1
			else
				do case
					case tnBotones <= 1
						lnRetorno = 1
					case tnBotones = 2
						lnRetorno = 5
					case inlist( tnBotones, 3, 4 )
						lnRetorno = 6
					case tnBotones = 5
						lnRetorno = 2
					case tnBotones = 10
						lnRetorno = 2
				endcase
			endif
			this.nRetorno = lnRetorno
			try
				tvMensaje.Limpiar()
			catch
			endtry
		else
			if ( Type( "_Screen.ActiveForm.Name" ) = "C" ) and pemstatus( _screen.ActiveForm , "oKontroler", 5 ) ; 
					and pemstatus(_screen.ActiveForm.oKontroler , "lProcesar_Funcion_Ejecutar", 5)
				&& es kontroler asociado a una entidad.
				llHayKontroler = .t.
				local lEstadoAnterior As Boolean
				loFormulario = _screen.ActiveForm
				llLockScreen = loFormulario.LockScreen
				if pemstatus(loFormulario.oKontroler,"BloquearPantalla",5)
					loFormulario.oKontroler.BloquearPantalla( .f. )
				else
					loFormulario.LockScreen = .f.
				endif
				lEstadoAnterior = loFormulario.oKontroler.lProcesar_Funcion_Ejecutar
	 			loFormulario.oKontroler.lProcesar_Funcion_Ejecutar = .F.

				if pemstatus( loFormulario.oKontroler , "SetearEstadoMenuYToolBar", 5)
		 			loFormulario.oKontroler.SetearEstadoMenuYToolBar( .f. )
	 			endif

			endif
			
			lvMensaje = this.ObtenerInformacionParaMostrar( tvMensaje )			

			this.CrearFormularioInformacion( tnBotones, tnBotonDefault, tnIcono, tcTitulo, tnTiempoEspera )
			bindevent( this.oForm, "nRetorno", this, "ValorRetorno", 1 )

			this.oForm.FormatearMensaje( lvMensaje )
			this.EnviarEventoSonoro( tnIcono )		

			if type( "_screen.ActiveForm" ) = 'O'
				this.oForm.show(1)
			else
				this.oForm.show()
			endif

			if vartype( lvMensaje ) = "O" and alltrim( upper( lvMensaje.class ) ) = "ZOOINFORMACION"
				lvMensaje.Limpiar()
			endif
		endif
		if llHayKontroler 
			loFormulario.oKontroler.lProcesar_Funcion_Ejecutar = lEstadoAnterior
			loFormulario.LockScreen = llLockScreen
			if pemstatus( loFormulario.oKontroler , "SetearEstadoMenuYToolBar", 5)
	 			loFormulario.oKontroler.SetearEstadoMenuYToolBar( .t. )
 			endif
		endif 
		return this.nRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValorRetorno( txVal as Variant ) as Void
		if vartype( this.oForm ) = "O"
			this.nRetorno = this.oForm.nRetorno
		else
			this.nRetorno = 0
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EnviarSinEspera( tcMensaje as String, tcTitulo as string, tcTextoBoton as String, tcIcono as String, tlNoHacePausa as Boolean ) as Form
		local i as Integer, loForm as form

		loForm = null
				
		if type( "tcMensaje" ) = "C"
			loForm = this.oMensajeSinEspera.Enviar( tcMensaje, tcTitulo, tcTextoBoton, tcIcono, .F., tlNoHacePausa )
		else
			this.oMensajeSinEspera.Ocultar()
		endif

		return loForm
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EnviarEventoSonoro( tnTipoDeEventoSonoro as Integer ) as Void
		local lcAlarmaEspecial as string
		
		if !this.lEsBuildAutomatico and goParametros.Nucleo.SonidosYNotificaciones.ReproducirSonidos
			if vartype( tnTipoDeEventoSonoro ) != "N"
				tnTipoDeEventoSonoro = 2
			endif
			do case
				case type( "this.oForm" ) = "O" and pemstatus( this.oForm, "lEmitirAlarmaEspecial", 5 ) and this.oForm.lEmitirAlarmaEspecial
					lcAlarmaEspecial = 	addbs( _screen.zoo.cRutaInicial ) + "videos\alarmaespecial.wav"
					if file( lcAlarmaEspecial )
						set bell to lcAlarmaEspecial
						??chr(7)
						set bell to
					endif
				case tnTipoDeEventoSonoro == 0
					goServicios.Multimedia.ReproducirAlertar()
				case tnTipoDeEventoSonoro == 1 or tnTipoDeEventoSonoro == 2
					goServicios.Multimedia.ReproducirExclamacion()
				case tnTipoDeEventoSonoro == 3
					goServicios.Multimedia.ReproducirInformar()
				otherwise
					goServicios.Multimedia.ReproducirExclamacion()
			endcase
		endif
	endfunc 
	
enddefine

