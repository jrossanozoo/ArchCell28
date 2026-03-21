Define Class zooformulario As Form

	#if .f.
		local this as zooformulario of zooformulario.prg
	#endif

	ShowWindow = 2
	ScrollBars = 0
	DoCreate = .T.
	ShowTips = .T.
	BorderStyle = 2
	MaxButton = .F.
	WindowState = 0
	LockScreen = .F.
	KeyPreview = .t.
	Autocenter = .t.
	DataSession = 2 && Cada ZooFormulario genera un DataSessionID privado.
	
	lEsSeteable = .T.
	oControlesOrdenados = Null
	lSePuedeOrdenar = .T.
	cPrimerControl = ""
	nKeyCode = 0
	nShiftAltCtrl = 0
	lGuardaMemoria = .t.
	
	nEstilo = 0
	xmlMemoria = ""
	cCurMemoria = ""
	lMemoriaTamanio = .T.
	lMemoriaPosicion = .T.
	lMemoriaColorDeFondo = .T.
	lEsFormularioPrincipal = .F.
	PunteroMoussePorDefecto = 0
	oUltimoFormularioHijo = null
	oFormularioPadre = null
	dimension aEventos( 1,4 )
	nColorFondoDefault = 16777215
	cRegistroDeActividadTiempoDeUso = ""
	nhwndRelacionado = 0
	
	oAspectoAplicacion = null

	*-----------------------------------------------------------------------------------------
	function oAspectoAplicacion_Access() as Void
		if (type("this.oAspectoAplicacion") <> "O" or isnull(this.oAspectoAplicacion))
			this.oAspectoAplicacion = _screen.zoo.CrearObjetoPorProducto("AspectoAplicacion")
		endif
		Return this.oAspectoAplicacion
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function Init( tlGeneracion as boolean ) As Void
		
		ConfigurarSeteosPrivadosDeLaSesion()
		
		With This
			.Armar()
			.LlenarColeccionDeControles()
			if tlGeneracion 
				.lGuardaMemoria = .F.
			else
				.DespuesDelInit()
			endif
		endwith
	Endfunc

	*-----------------------------------------------------------------------------------------
	function Closable_assign( tlVal as Boolean ) as Void
		This.Closable = tlVal
		if tlVal
			local loError as Exception
			Try
				EnableMenuItem( GetSystemMenu( This.HWnd, .f. ), 61536, .T. )
				EnableMenuItem( GetSystemMenu( This.HWnd, .f. ), 61536, .F. )
			catch to loError
			EndTry	
		Endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ConfigurarSegunMemoriaDelFormulario() as Void
		local loError as Exception
		
		goServicios.Memoria.SetearDatosFormulario( this )
		with this
			try
				.AplicarXmlMemoria()
				.SetearColorPageFrame()
			catch to loError
				if loError.UserValue.ErrorNo = 1435  && "XML PARSE ERROR"
					.AutoCenter = .T.
				else
					goServicios.Errores.LevantarExcepcion( loError )
				endif
			endtry
			.AcomodarPosicion()
		endwith 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function DespuesDelInit() as Void

		this.EventoAntesDeConfigurarUbicacion()
		if this.lGuardaMemoria
			this.ConfigurarSegunMemoriaDelFormulario()
		else
			thisform.AutoCenter = .t.
		endif
		
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoAntesDeConfigurarUbicacion() as Void
	endfunc

	*-----------------------------------------------------------------------------------------
	function AcomodarPosicion() as Void
		with this

			local lnDiferencia as Integer 
			lnDiferencia = ( .left + .width ) - this.ScreenWidth()
			if lnDiferencia > 0
				.left = .left - lnDiferencia
			endif
			lnDiferencia = ( .top + .height ) - this.ScreenHeight()
			if lnDiferencia > 0
				.top = .top - lnDiferencia
			endif
			if .left < 0
				.left = 0
			endif
			if .top < 0
				.top = 0
			endif		
			
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------	
	protected function  ScreenWidth() as Integer
		return sysmetric( 21 ) - 7
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function  ScreenHeight() as Integer
		return ( sysmetric( 22 ) - sysmetric( 25 ) )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarstatusBar() as Void
		local lcObjeto as String
		
		lcObjeto = "oBarraEstado"
		
*		this.Newobject( "oBarraEstado", 'BarraDeEstadoFormulario', 'BarraDeEstadoFormulario.prg','',.F.)
		_Screen.zoo.NuevoObjeto( this, "oBarraEstado", "BarraDeEstadoFormulario"  )		
		with this.oBarraEstado
			.AjustarTamaño( This.Width )
			.tabstop = .f.

			.SetearColor()

			.oProgressBar.left = .Panel4.left
			.oProgressBar.width = .Panel4.width
			.Visible = .T.
		endwith

	endfunc 

	*-----------------------------------------------------------------------------------------
	function Resize() as Void
		if type( "this.oBarraEstado" ) = "O"
			this.oBarraEstado.top = this.Height - this.oBarraEstado.height
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function Armar() As Void
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function LlenarColeccionDeControles() As Void
		This.oControlesOrdenados = Null

		If This.SePuedeOrdenar()
			This.oControlesOrdenados = This.GenerarControlesOrdenados()
		Endif
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function SePuedeOrdenar() As boolean
		Return This.lSePuedeOrdenar
	Endfunc

	*-------------------------------------------------------------------------------------
	Function GenerarControlesOrdenados() As Collection
		Local loRetorno As Collection, loObjeto As Object, lnColumna As Integer, lnFila As Integer, ;
			lnMaxFila As Integer, lnMaxColumna As Integer, lnItem As Integer

		loRetorno = _Screen.zoo.crearobjeto( "zoocoleccion" )

		lnMaxFila = 0
		lnMaxColumna = 0
		For Each loObjeto In This.Controls
			if pemstatus( loObjeto, "nFila", 5 ) and pemstatus( loObjeto, "nColumna", 5 )
				lnMaxFila = Max(lnMaxFila, loObjeto.nFila )
				lnMaxColumna = Max(lnMaxColumna, loObjeto.nColumna )
			endif
		Endfor

		loRetorno.AddProperty("MaxColumna", lnMaxColumna+1)
		loRetorno.AddProperty("MaxFila", lnMaxFila+1)

		For lnFila = 0 To lnMaxFila
			For lnColumna = 0 To lnMaxColumna
				lnItem = 1
				&&llEsta = .f.
				Do While lnItem <= This.ControlCount &&and !llEsta
					loObjeto = This.Controls[ lnItem ]
					
					if pemstatus( loObjeto, "nFila", 5 ) and pemstatus( loObjeto, "nColumna", 5 )

						If lnColumna = loObjeto.nColumna And lnFila = loObjeto.nFila
							loRetorno.Add( loObjeto )
							&&llEsta = .t.
						endif
					endif

					lnItem = lnItem + 1
				Enddo
			Endfor
		Endfor

		Return loRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ObtenerControlesOrdenados() As Void
		Return This.oControlesOrdenados
	Endfunc

	*-------------------------------------------------------------------------
	Function salir()
		Thisform.Release()
	Endfunc

	*-------------------------------------------------------------------------
	Function recorrercontroles ( tocontrol As Object)

		Local loctrl As Object, lopage As Object, locolu As Object,	lcclass As Character, ;
			lnkey As Integer, lckey As Character, lnretval As Integer

		For Each loctrl In tocontrol.Controls
			If !Pemstatus(loctrl,"BaseClass",2)
				lcclass = Upper(loctrl.BaseClass)

				If Pemstatus(loctrl,"oItem", 5)
					loctrl.oitem = Null
				endif	

				If Pemstatus(loctrl,"oControlesOrdenados", 5)
					
					if vartype( loctrl.oControlesOrdenados ) = "O"
						if Pemstatus(loctrl.oControlesOrdenados,"Release", 5)
							loctrl.oControlesOrdenados.release()
						else
							loctrl.oControlesOrdenados = Null
						Endif
					endif 

				Endif

				If Pemstatus(loctrl,"EliminarReferencias", 5)
					loctrl.EliminarReferencias()
				Endif

				Do Case
					Case  lcclass = 'PAGEFRAME'
						For Each lopage In loctrl.Pages
							This.recorrercontroles(lopage)
						Endfor

					Case lcclass = 'GRID'
						For Each locolu In loctrl.Columns
							This.recorrercontroles(locolu)
						Endfor

					Case Pemstatus(loctrl, 'ControlCount', 5)
						This.recorrercontroles(loctrl)

				Endcase
			Else
				loctrl = Null
				Release loctrl
			Endif
		Endfor

	Endfunc

	*-------------------------------------------------------------------------
	Function KeyPress ( nkeycode, nshiftaltctrl )

		If nkeycode = 27
			this.Salir()
		Endif
	Endfunc

	*-----------------------------------------------------------------------------------------
	function Release() as Void
		local loError as zooexception OF zooexception.prg
			
		if this.lGuardaMemoria
			try
				this.GrabarMemoriaDelFormulario()
				goServicios.Memoria.GrabarDatosFormulario( this )
			catch to loError
				goServicios.Errores.LevantarExcepcion( loError )
			endtry
		endif
		if type( "goServicios.Formularios" ) == "O"
			goServicios.Formularios.EliminarReferenciasFormularioPadreHijo( this )
		endif

		dodefault()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function GrabarMemoriaDelFormulario() as Void
		this.AbrirCursorTemporal()
		
		this.LlenarXmlMemoria()
		this.AgregarOtrosComandosDeMemoria()
		this.ConvertirMemoria()
		
		this.CerrarCursorTemporal()
	endfunc 

	*-------------------------------------------------------------------------
	Function Destroy()
		this.oControlesOrdenados = Null
		this.oAspectoAplicacion = Null
		This.recorrercontroles( This )
		This.RegistrarFinDeActividad()
	Endfunc

	*-----------------------------------------------------------------------------------------
	function MargenSup() as Integer
		Local lnRetorno as integer
		
		lnRetorno = 0
		
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function MargenInf() as Integer
		Local lnRetorno as integer
		
		lnRetorno = 0
		
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function MargenIzq() as Integer
		Local lnRetorno as integer
		
		lnRetorno = 0
		
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function MargenDer() as Integer
		Local lnRetorno as integer
		
		lnRetorno = 0
		
		return lnRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function SetearUltimaTecla( tnKeyCode as integer, tnShiftAltCtrl as Integer ) as Void
		this.nKeyCode = tnKeyCode
		this.nShiftAltCtrl = tnShiftAltCtrl
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function VerificarSiDebeAplicarComandosDeMemoria( tcCursor as String ) as Boolean
		return .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AplicarXmlMemoria() as Void
		****Agarra todo lo que levanto el goServicios.Memoria en xmlMemoria y lo evaluo linea por linea.
		local loError as Exception, loEx as Exception, lcCursor as String

		if empty( this.xmlMemoria )
		else
			lcCursor = "c_CargaMemo" + sys( 2015 )
			try
				=xmltocursor( this.xmlMemoria, lcCursor, 4 )
				select ( lcCursor )
				if this.VerificarSiDebeAplicarComandosDeMemoria( lcCursor )
					scan
						this.aplicarComandoMemoria( Comando )
					endscan
				endif

			catch To loError		
				loEx = Newobject( "ZooException", "ZooException.prg" )
				With loEx
					.Grabar( loError )
					.Throw()
				EndWith
			finally	
				use in select( lcCursor )
			endtry
		endif		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AplicarComandoMemoria( tcComando as String ) as Void
		local lcPropiedad as String, lcValor as String 
		lcPropiedad = left( tcComando, at( "=" , tcComando ) - 1)
		lcValor = substr( tcComando, at( "=" , tcComando ) + 1 )
		try
			&lcPropiedad = &lcValor
		catch
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AbrirCursorTemporal() as Void
		this.cCurMemoria = "memoria" + sys( 2015 )
		if !used( this.cCurMemoria )
			create cursor ( this.cCurMemoria ) ( Comando C( 254 ) )			
		endif 
		
		this.xmlMemoria = ""	
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function LlenarXmlMemoria() as Void
		with this
			if .lMemoriaPosicion
				.agregarAXmlMemoria( "thisform.left = " + transform( .left ) )
				.agregarAXmlMemoria( "thisform.top = " + transform( .Top ) )
			endif
			
			if .lMemoriaTamanio
				.agregarAXmlMemoria( "thisform.width = " + transform( .width ) )
				.agregarAXmlMemoria( "thisform.height = " + transform( .Height ) )						
			endif
						
			if .lMemoriaColorDeFondo
				.agregarAXmlMemoria( "thisform.BackColor = " + transform( .BackColor ) )
			endif				
		endwith	
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarOtrosComandosDeMemoria() as Void
		loMemoria = _Screen.Zoo.CrearObjeto( "ZooColeccion", "ZooColeccion.prg" )
		this.EventoAgregarMemoriaExtra( loMemoria )
		if loMemoria.Count > 0
			this.AgregarMemoriaExtra( loMemoria )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function agregarAXmlMemoria( tcComando as String ) as Void
		insert into ( this.cCurMemoria ) ( Comando ) values ( tcComando )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ConvertirMemoria() as Void
		local lcXml as String 
		
		lcXml = ""
		if used( this.cCurMemoria )
			cursortoxml( this.cCurMemoria, "lcXml", 3, 1 )
		endif
			
		this.xmlMemoria = lcXml
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CerrarCursorTemporal() as Void
		use in select( this.cCurMemoria )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearMousePointerEnEspera() as Void &&Antes del exe
		local loControl as Object
		
		this.CompletarMousePointer()
		this.MousePointer = 11
		this.SetAll( 'MousePointer', 11 )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearMousePointerPorDefecto() as Void &&Despues del exe
		local loControl as Object
		
		this.MousePointer = this.PunteroMoussePorDefecto
		for each loControl in This.Controls
			 if pemstatus( loControl, 'PunteroMoussePorDefecto',5 )
			 	loControl.MousePointer = loControl.PunteroMoussePorDefecto
			 endif
		next 
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CompletarMousePointer() as Void
		local loControl as Object
		
		this.PunteroMoussePorDefecto = this.MousePointer
		
		for each loControl in This.Controls
			if pemstatus( loControl, 'MousePointer',5 )
				if !pemstatus( loControl, 'PunteroMoussePorDefecto',5 )	 	
					loControl.AddProperty( 'PunteroMoussePorDefecto', 0)
				endif
				loControl.PunteroMoussePorDefecto = loControl.MousePointer
			Endif
		next 
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function Show( tnModo as Integer) As Void
		dodefault( tnModo )
		This.RegistrarActividad()
		if type( "goServicios.Formularios" ) == "O" and goServicios.Formularios.EsUnFormularioModal( this, tnModo )
			goServicios.Formularios.SetearReferenciasFormularioPadreHijo( this )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function RegistrarActividad() as Void
		if vartype( This.oEntidad ) = "O"
			This.cRegistroDeActividadTiempoDeUso = goServicios.RegistroDeActividad.IniciarRegistro( proper( This.oEntidad.ObtenerNombre()) , "Uso de formulario" )
		else
			This.cRegistroDeActividadTiempoDeUso = goServicios.RegistroDeActividad.IniciarRegistro( This.Class , "Uso de formulario" )
		Endif	
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function Activate() As Void
		dodefault()
		if type( "goServicios.Formularios" ) == "O" and this.DebeTraerAlFrenteFormularioHijo()
			goServicios.Formularios.TraerAlFrente( this.oUltimoFormularioHijo )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function DebeTraerAlFrenteFormularioHijo() as Boolean
		return goServicios.Formularios.DebeTraerAlFrenteFormularioHijo( this )
	endfunc

	*-----------------------------------------------------------------------------------------
	function Hide() as Void
		dodefault()
		This.RegistrarFinDeActividad()
		if type( "goServicios.Formularios" ) == "O"
			goServicios.Formularios.EliminarReferenciasFormularioPadreHijo( this )
		endif
	endfunc
	 
	*-----------------------------------------------------------------------------------------
	protected function RegistrarFinDeActividad() as Void
		if !empty( this.cRegistroDeActividadTiempoDeUso )
			goServicios.RegistroDeActividad.FinalizarRegistro( this.cRegistroDeActividadTiempoDeUso )
			this.cRegistroDeActividadTiempoDeUso = ""
		Endif
	endfunc

 	*-----------------------------------------------------------------------------------------	
	function SetearColorPageFrame() as Void
		local lnSolapa as Integer, lcSolapa as String
		if pemstatus( this ,"pnlGrupos",5 ) 
			this.pnlGrupos.Themes = this.VerificarSiAceptaTemas()
			for lnSolapa = 1 to this.pnlGrupos.pagecount
				lcSolapa = "this.pnlGrupos.page" + alltrim(str( lnSolapa ))
				&lcSolapa..backcolor = this.backcolor
			endfor 	
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------	
	function EventoAgregarMemoriaExtra( loColeccionMemoriaExtra as Object ) as void
	endfunc 
	*-----------------------------------------------------------------------------------------
	protected function VerificarSiAceptaTemas() as Boolean  
		local llRetorno as Boolean 

		if this.nColorFondoDefault = this.backColor 
			llRetorno = .t.
		else
			llRetorno = .f.
		endif
		return llRetorno 
	endfunc 
	*-----------------------------------------------------------------------------------------	
	protected function AgregarMemoriaExtra( loColeccionMemoriaExtra as Object ) as Void
		for each memoria as String in loColeccionMemoriaExtra
			this.agregarAXmlMemoria( memoria )
		endfor
	endfunc 

Enddefine
