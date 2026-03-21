define class ServicioAplicacionesVisual as ServicioAplicaciones of ServicioAplicaciones.Prg

	#IF .f.
		Local this as ServicioAplicacionesVisual of ServicioAplicacionesVisual.prg
	#ENDIF

	oSplash = null

 	*-----------------------------------------------------------------------------------------
	protected function InicializarEstado( tlModoSilencioso as Boolean ) as Void
		if tlModoSilencioso
			Do Form splashscreen.scx with This.cAplicacion, this.cNombreAplicacionUsuario Name this.oSplash linked noshow
		else
			Do Form splashscreen.scx with This.cAplicacion, this.cNombreAplicacionUsuario Name this.oSplash linked
		endif
		Inkey( 0.5 )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function InformarEstado( tcEstado as String, tlEspera as Boolean ) as Void
		if !isnull( This.oSplash )
			This.oSplash.MostrarEstado( tcEstado, tlEspera )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearEtiquetaEstado() as Void
		if !isnull( This.oSplash )
			This.oSplash.lblBase1.Caption = alltrim( strtran( _screen.Zoo.App.ObtenerNombre(), "Zoo Logic", "" ) )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CerrarEntornoVisual() as Void
		if !isnull( This.oSplash )
			this.oSplash.release()
		endif
		
		this.oSplash = null
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function MensajeAdvertencia( tcMensaje as String ) as Void
		goMensajes.Advertir( tcMensaje )
	endfunc 

enddefine