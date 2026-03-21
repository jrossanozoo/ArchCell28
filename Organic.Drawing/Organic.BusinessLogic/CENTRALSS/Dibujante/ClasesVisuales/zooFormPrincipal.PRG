Define Class zooFormPrincipal As zooFormulario Of zooFormulario.prg

	#if .f.
		local this as zooFormPrincipal of zooFormPrincipal.prg
	#endif

	protected _oScreen 
	
	lEsFormularioPrincipal = .T.
	oManagerFormulariosFox = null
	_oScreen = null
	lDebeCerrar = .t.
	
	*-----------------------------------------------------------------------------------------
	Function Init

		local lcImagen as String, lcImagen2 as String, llExisteImagen as Boolean
		
		ConfigurarSeteosPrivadosDeLaSesion()			

		lcImagen 	= space(0)
		lcImagen2	= space(0)
		llExisteImagen = .F.
		
		With This
			.MaxButton = .T.
			.BorderStyle = 3
			.BackColor = Rgb( 255, 255, 255 )
			.Width = goRegistry.Nucleo.FormularioPrincipalAncho
			.Height = goRegistry.Nucleo.FormularioPrincipalAlto
			.MinWidth = goRegistry.Nucleo.FormularioPrincipalAncho
			.MinHeight = goRegistry.Nucleo.FormularioPrincipalAlto
			
			if !inlist( goRegistry.Nucleo.FormularioPrincipalEstado, 0,1,2)
				goRegistry.Nucleo.FormularioPrincipalEstado = 2
			endif 
			.WindowState = goRegistry.Nucleo.FormularioPrincipalEstado

			.Icon = _Screen.Zoo.App.ObtenerIconoDeLaAplicacion()
			
*!*			Imagen de fondo de la aplicacion (escritorio)
			.Newobject( "imgImagen", "Image" )							

			.imgImagen.Picture = _screen.zoo.app.oAspectoAplicacion.ObtenerRutaImagenFondoArriba()
			
			This.SetearPropiedadesImagenFormulario()	
			
			.imgImagen.Top = 0
			.imgImagen.Left = 0
			.imgImagen.Visible = .T.

			.Caption = _screen.zoo.app.oAspectoAplicacion.ObtenerTituloAplicacion()

			AddProperty( this, "cxml", "")	

			*--- Imagenes de fondo de la pantalla principal

			if lower(_Screen.Zoo.App.cProyecto) == 'colorytalle'
				.UbicarImagenesPieDragon()
			else
				.UbicarImagenesPie()
			endif

		Endwith
	
		this._oScreen = newobject( "_ScreenWrapper" )
		this.oManagerFormulariosFox = _screen.zoo.crearobjeto( "ZooLogicSA.Core.Formularios.ManagerFormModalesFox", , this , this._oScreen )
		dodefault()
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function DebeTraerAlFrenteFormularioHijo() as Boolean
		return .f.
	endfunc

	*-----------------------------------------------------------------------------------------
	function Resize
		dodefault()
		with This
			if lower(_Screen.Zoo.App.cProyecto) == 'colorytalle'
				.LogoFondo.top = .height - .LogoFondo.height - 30 && 440 - 22
				.LogoFondo.left = .width - .LogoFondo.width - 30 && 450
			else
				.ImagenFondo.Top 	= .Height - .ImagenFondo.Height - 22  &&Aca no estaba el 22 Diego
				.ImagenFondo.Left 	= .Width - .ImagenFondo.Width 
				.LogoFondo.Top 		= .Height - .LogoFondo.Height - 22
			endif
		endWith 	

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function SetearBarraDeEstadoPrincipal( tnAltoBarraMenu as Integer ) as Void
		local lcEstadoSeguridad as String
		lcEstadoSeguridad = goServicios.Seguridad.ObtenerEstadoDeSeguridad()
		
		if type( "this.oBarraEstado" ) = "O"
			this.oBarraEstado.setear()
			this.oBarraEstado.SetearEstadoDelSistema( lcEstadoSeguridad, 4, 5 )
		else
			this.Newobject( 'oBarraEstado', 'barraDeEstadoPrincipal', 'BarraDeEstadoPrincipal.prg','',.F.)
			
			with this.oBarraEstado
				.SetearEstadoDelSistema( lcEstadoSeguridad, 4, 5 )
				.Top =  .Top - tnAltoBarraMenu 
				.Anchor = 10
				.Visible = .T.
				.lGruposYaGenerados = .t.
			endwith
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function SetearBarraDeEstadoEntidad( tnAltoBarraMenu as Integer ) as Void
		local lcEstadoSeguridad as String

		this.Newobject( 'oBarraEstado', 'barraDeEstadoFormulario', 'BarraDeEstadoFormulario.prg','',.F.)
		with this.oBarraEstado
			lcEstadoSeguridad = goServicios.Seguridad.ObtenerEstadoDeSeguridad()
			.SetearEstadoDelSistema( lcEstadoSeguridad )
			.AjustarTamaño( This.Width )
			.Top =  .Top - tnAltoBarraMenu 
			.Visible = .T.
		endwith
	endfunc		
	
	*-----------------------------------------------------------------------------------------
	function QueryUnload() as Boolean
		SalidaDelSistema()
		if !this.lDebeCerrar
			nodefault
		endif	
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function FinalizarProceso() as Void
		_SCREEN.ZOO.APP.OSALIDA.oMonitorDeIngresoYSalida.FicharSalida()
		goServicios.Librerias.TerminarProcesosRelacionados( goServicios.Librerias.ObtenerIdProcesoActual() )
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function Unload() As Boolean
		With Thisform
			if pemstatus( Thisform, "cbm", 5 )
				If Pemstatus( Thisform, "oMenu", 5 )
					.oMenu.Visible = .F.
					.oBarraEstado.Visible = .F.
				Endif
				.Refresh()
			Endif
		Endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function HayFormulariosModales() as Boolean
		local llRetorno as Boolean, lni as Number

		llRetorno = .f.
		
		lni = _Screen.FormCount
		for i = 1 to lni
			if goFormularios.EsUnFormularioModal( _Screen.Forms[i] ) and goFormularios.EsUnFormularioVisible( _screen.Forms[ i ] )
				llRetorno = .t.
				exit
			endif
		endfor
		
		return llRetorno

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function CerrarFormularioConPregunta( tni as Number ) as Void
		local lci as String
		lci = transform( tni )

		if type( "_screen.forms[ " + lci + " ]" ) == 'O' and pemstatus( _Screen.Forms[ tni ], "oKontroler", 5 ) and upper( _Screen.Forms[ tni ].parentClass ) = "FORMULARIOEDICION"
			_Screen.Forms[ tni ].oKontroler.Ejecutar( "Salir" )
		else
			if type( "_screen.forms[ tni ]" ) == 'O' and pemstatus( _Screen.Forms[ tni ], "Salir", 5 )
				_Screen.Forms[ tni ].Salir()
			else
				if type( "_screen.forms[ " + lci + " ]" ) == 'O' 
					_Screen.Forms[ tni ].release
				endif	
			endif
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function CerrarFormularioSinPregunta(	tni as Number ) as Void
		local lci as Number
		lci = transform( tni )
	
		if type( "_screen.forms[ " + lci + " ]" ) == 'O' and pemstatus( _Screen.Forms[ tni ], "Salir", 5 )
			_Screen.Forms[ tni ].Salir()
		else
			if type( "_screen.forms[ " + lci + "]" ) == 'O' 
				_Screen.Forms[ tni ].release
			endif	
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function CerrarFormulario( tlPregunta as boolean, tni as Number ) as Void
		if tlPregunta
			this.CerrarFormularioConPregunta( tni )
		else
			this.CerrarFormularioSinPregunta( tnii )
		endif 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CerrarSubFormularios( tlPregunta as Boolean, tcfrmIgnorar as String ) as Boolean
	local lnForm as integer, llRetorno as Boolean, lnI as Integer
		if empty( tcFrmIgnorar )
			tcFrmIgnorar = ""
		Endif	
		llRetorno = .t.
		lnI = _Screen.FormCount
		Do While lnI > 0

			lnForm = _Screen.FormCount

			if	type( "_screen.forms[ lnI ]" ) == 'O' and (lower( alltrim( _Screen.Forms[ lnI ].class ) ) = lower( alltrim( _screen.Zoo.app.cFormularioPrincipal ) ) or ;
				lower( alltrim( _Screen.Forms[ lnI ].class ) ) == lower( alltrim( tcfrmIgnorar ) ))
				
				if _Screen.FormCount =  1 + iif( empty( tcFrmIgnorar ), 0, 1 )
					llRetorno = .t.
					exit
				endif		
			else
				this.CerrarFormulario( tlPregunta, lnI )
				
				if lnForm = _Screen.FormCount 
					llRetorno = .f.
					exit
				endif
			
			endif 
			if lnI = _Screen.FormCount and lnI > 1
				lnI = lnI - 1
			else
				lnI = _Screen.FormCount
			endif

		EndDo

		if llRetorno and goServicios.Ejecucion.HayAppAbiertas()
			llRetorno = .f.
			goMensajes.Advertir( "Debe cerrar las ventanas en ejecución para poder cerrar la aplicación." )
		endif
		
		return llRetorno
	endfunc 

	*-------------------------------------------------------------------------
	Function KeyPress ( nkeycode, nshiftaltctrl )
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function SetearPropiedadesImagenFormulario() As Void
		With This
			if .imgImagen.Width < .minWidth
				.maxwidth 	= .minWidth
			else
				.maxwidth 	= .imgImagen.Width
			endif	

			if .imgImagen.Height < .minHeight
				.maxHeight 	= .minHeight
			else
				.maxHeight 	= .imgImagen.Height
			endif	
		endwith	
	Endfunc

	*-----------------------------------------------------------------------------------------
	function Release() as Void
		dodefault()
		if type( "this.oManagerFormulariosFox" ) == "O"
			this.oManagerFormulariosFox.Dispose()
			this.oManagerFormulariosFox = null
		endif

		if type( "this._oScreen " ) == "O"
			this._oScreen.destroy()
			this._oScreen = null
		endif

	endfunc

	*-----------------------------------------------------------------------------------------
	Protected function UbicarImagenesPie() as Void
		With This
*!*			Imagen de fondo para la botonera (abajo a la derecha)
			.newobject( 'ImagenFondo', 'zooimagen', "zooimagen.prg" )
			.ImagenFondo.top = .height - 532
			.ImagenFondo.left = .width - 450

			lcImagen = _screen.zoo.app.oAspectoAplicacion.ObtenerRutaImagenFondoDerecha()
			
			if file(lcImagen  )
				.ImagenFondo.Picture = lcImagen
				.ImagenFondo.Visible = .T.				
				.ImagenFondo.Stretch = 2				
			else
				.ImagenFondo.Visible = .F.
			EndIf	

*!*			Imagen del logo de la aplicacion (abajo a la izquierda)
			.newobject( 'LogoFondo', 'zooimagen', "zooimagen.prg" )
			.LogoFondo.top = 440 - 22
			.LogoFondo.left = 10 &&-10 y moidifique el archivo LogoTelas.jpg
			
			lcImagen2 = _screen.zoo.app.oAspectoAplicacion.ObtenerRutaImagenFondoIzquierda()
			if file(lcImagen2  )
				.LogoFondo.Picture = lcImagen2
				.LogoFondo.Visible = .T.
				.LogoFondo.Stretch = 2						
			else
				.LogoFondo.Visible = .F.
			EndIf	
		endwith	
	EndFunc 

	*-----------------------------------------------------------------------------------------
	Protected function UbicarImagenesPieDragon() as Void
		With This
*!*			Imagen de fondo para la botonera (abajo a la izquierda)
			.newobject( 'ImagenFondo', 'zooimagen', "zooimagen.prg" )
			.ImagenFondo.top = .height - 532
			.ImagenFondo.left = 10

			lcImagen = _screen.zoo.app.oAspectoAplicacion.ObtenerRutaImagenFondoDerecha()
			
			if file(lcImagen  )
				.ImagenFondo.Picture = lcImagen
				.ImagenFondo.Visible = .T.				
				.ImagenFondo.Stretch = 2				
			else
				.ImagenFondo.Visible = .F.
			EndIf	

*!*			Imagen del logo de la aplicacion (abajo a la derecha)
			.newobject( 'LogoFondo', 'zooimagen', "zooimagen.prg" )
			.LogoFondo.top = .height - .LogoFondo.height -30 && 440 - 22
			.LogoFondo.left = .width - .LogoFondo.width -30 && 450
			
			lcImagen2 = _screen.zoo.app.oAspectoAplicacion.ObtenerRutaImagenFondoIzquierda()
			if file(lcImagen2  )
				.LogoFondo.Picture = lcImagen2
				.LogoFondo.Visible = .T.
				.LogoFondo.Stretch = 2						
			else
				.LogoFondo.Visible = .F.
			EndIf	
		endwith	
	EndFunc 

Enddefine

*-----------------------------------------------------------------------------------------
define class _ScreenWrapper as Custom

	*-----------------------------------------------------------------------------------------
	function ObtenerFormulario( tni as Number ) as form
		return _screen.Forms[tni]
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EsModal( tni as Number) as Boolean
		return goFormularios.EsUnFormularioModal( _screen.Forms[ tni ] )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CantidadDeFormularios() as Integer
		return _screen.FormCount
	endfunc 

enddefine
