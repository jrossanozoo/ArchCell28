define class ServicioPantalla as Servicio of Servicio.Prg

	#IF .f.
		Local this as ServicioPantalla of ServicioPantalla.prg
	#ENDIF

	lHayKontroler = .F.
	lEstadoAnterior = .F.
	lLockScreen = .F.
	oFormulario = Null
	*-----------------------------------------------------------------------------------------
	function DeshabilitarFormularioActivo() as Void
		with This
			.lHayKontroler = .F.
			if	Type( "_Screen.ActiveForm.Name" ) = "C" and ;
				pemstatus( _screen.ActiveForm , "oKontroler", 5 ) and ;
				pemstatus( _screen.ActiveForm.oKontroler , "lProcesar_Funcion_Ejecutar", 5 ) 
				
				.lHayKontroler = .T.
				.oFormulario = _screen.ActiveForm
				.lLockScreen = .oFormulario.LockScreen
				.oFormulario.LockScreen = .f.
				.lEstadoAnterior = .oFormulario.oKontroler.lProcesar_Funcion_Ejecutar
	 			.oFormulario.oKontroler.lProcesar_Funcion_Ejecutar = .F.
			endif
		EndWith
	endfunc 
	*-----------------------------------------------------------------------------------------
	function HabilitarFormularioActivo() as Void
		with this
			if .lHayKontroler
				.oFormulario.oKontroler.lProcesar_Funcion_Ejecutar = .lEstadoAnterior
				.oFormulario.LockScreen = .lLockScreen
			Endif
			.oFormulario = Null
		EndWith
	endfunc 
enddefine
