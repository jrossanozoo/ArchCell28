define class zooTextbox as textbox

	#IF .f.
		Local this as zooTextbox of zooTextbox.prg
	#ENDIF

	#INCLUDE constantesDibujante.h
	
	protected lAceptarMouseDown as Boolean

	datasession = 1

	Margin = 0
	IntegralHeight = .T.

***** esto es de la historia del PAGE DOWN
	lTabForzado = .f.

	nColumna = 0
	nFila = 0

	oItem = null
	
	cAyuda = ""

	lEsSeteable = .T.
	EsAjustable = .F.

	nForeColorConFoco = 0
	nBackColorConFoco = 0
	nForeColorSinFoco = 0
	nBackColorSinFoco = 0
	
	nBackColorObligSinFoco = 0	
	nForeColorObligSinFoco = 0		
	
	lEsObligatorio = .f.

	oEntidad = null
	lEsSubEntidad = .f.

	nTipoDeOrdenIzquierdo = NO_ACOMODAR
	nTipoDeOrdenSuperior = NO_ACOMODAR

	lSePuedeOrdenar = .t.
	lSeSuperpone = .f.

	oControlesOrdenados = null

	cAtributoPadre = ""
	
	lClavePrimaria = .f.
	cClaveForanea = ""
	cAtributo = ""
	cDominio = ""
	cEntidad = ""
	lSaltoCampo = .f.
	nLongitud = 0
	nDecimales = 0
	cTipoDato = ""
	lDetalle = .f.
	lEsControlConSaltoDeCampoDefiniblePorElUsuario = .T.
	
	xValorAnterior = null
	xValorInicial = null
	
	dimension aEventos( 1, 4 )
	
	lEsTraducible = .t.
	cEstado = ""
	
	lValidaSoloSiModifico = .f.

	cMascara	= ""
	lOld = .f.

	cToolTip = ""
	SelectOnEntry = .t.
	lAceptarMouseDown = .f.
	
	lUtilizaReadOnlyEnLugarDeEnabled = .f.
	cTags = ""

	cFiltroBusqueda = ""
	cRelacionesBusqueda = ""
	cTablaDetalle = ""
	
	cFiltroInterviniente = ""
	cRelacionInterviniente = ""
	cTablasInterviniente = ""
	
	lArmando = .F.
	lTieneSaltoDeCampoDefinidoPorElUsuario = .f.

	*-----------------------------------------------------------------------------------------
	function Init( toItem as object )
		if vartype(toItem)="C" and toItem = "NO"
			return
		endif

		dodefault()

		with this
			if vartype( toItem ) = "O"
				.SetearControl( toItem )
				.Armar()
			endif

		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function Armar() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearControl( toItem as Object ) as Void
	
		with this
			if vartype(toItem) = "O"
				.oItem = toItem

				.maxLength = .oItem.Longitud

				.cAyuda = alltrim( .oItem.Ayuda )

				.lClavePrimaria = .oItem.ClavePrimaria
				.cClaveForanea = alltrim( .oItem.ClaveForanea )
				.cAtributo = alltrim(.oItem.Atributo)
				.cDominio = alltrim(.oItem.Dominio)
				.cEntidad = alltrim(.oItem.Entidad)
				.lSaltoCampo = .oItem.SaltoCampo
				.nLongitud = .oItem.Longitud
				.nDecimales = .oItem.Decimales
				.cTipoDato = alltrim( .oItem.TipoDato )
				.lDetalle = .oItem.Detalle
				.lEsSubEntidad = .oItem.lEsSubEntidad
				.lValidaSoloSiModifico = .oItem.ValidaModificacion
				.Format = iif(!empty( .oItem.Formato ) , .oItem.Formato, .Format )				
				.lEsObligatorio = .oItem.Obligatorio

				.cTooltip =	alltrim( .oItem.ToolTip )  
	
				if pemstatus( .oItem, "Mascara", 5 )
					.cMascara = alltrim( .oItem.Mascara )
				endif 

				if vartype(.oItem.Tags)="C"
					.cTags = alltrim( .oItem.Tags )
				endif
			endif
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function KeyPress( nKeyCode as Integer, nShiftAltCtrl as Integer )
		local lcTexto as String
		
		if this.NoPermitirComillas( nKeyCode )
			nodefault 
		endif 
		if inlist( nKeyCode, 127) and this.selStart = 0 and this.SelLength = 0
			nodefault 
		endif 
		if inlist( nKeyCode, -6)
			nodefault 
		endif 
		if inlist( nKeyCode, 1, 6 )
			nodefault 
			
			lcTexto = this.value
			if vartype( lcTexto ) = "C"
				lcTexto = alltrim( lcTexto )
			else
				lcTexto = transform( lcTexto )
			endif
			this.selStart = iif( nKeyCode =1, 0, len( lcTexto ) )
			
			this.selLength = 0
		endif
		
		thisform.SetearUltimaTecla( nKeyCode, nShiftAltCtrl )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function gotFocus()
		local loError as Exception, loEx as Exception 
		
		dodefault()
		
		try 
			goControles.ObtenerFoco( this, thisform )
			this.lAceptarMouseDown = .f.
			_screen.zoo.BindearEvento( thisform, "Paint", this, "AceptarMouseDown" )
		Catch To loError
			loEx = Newobject( "ZooException", "ZooException.prg" )
			With loEx
				.Grabar( loError )
				goServicios.Mensajes.Enviar( loEx )
			EndWith
		endtry
	endfunc

	*-----------------------------------------------------------------------------------------
	function LostFocus()
		local loError as Exception, loEx as Exception 
		
		dodefault()
		
		try 
			goControles.PerderFoco( this, thisform )
			_screen.zoo.DesBindearEvento( thisform, "Paint", this, "AceptarMouseDown" )
		Catch To loError
			loEx = Newobject( "ZooException", "ZooException.prg" )
			With loEx
				.Grabar( loError )
				goServicios.Mensajes.Enviar( loEx )
			EndWith
		endtry
	endfunc 

	*-----------------------------------------------------------------------------------------
	function valid() as Integer
		local lnRetorno as integer, loError as Exception, loEx as Exception 

		try
			if this.ReadOnly
				lnRetorno = this.ObtenerProximoControl()
			else
				lnRetorno = goControles.Validar( this, thisform )
				this.ActualizarValorAnterior( lnRetorno )
			endif 
		Catch To loError
			lnRetorno = 0

			loEx = Newobject( "ZooException", "ZooException.prg" )
			With loEx
				.Grabar( loError )
				goServicios.Mensajes.Enviar( loEx )
			EndWith
		EndTry

		return lnRetorno
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ActualizarValorAnterior( tnRetorno as integer ) as Void
		with this
			if tnRetorno != 0
				.xValorAnterior = .Value
			else
				.xValorAnterior = null
			endif
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Actualizar() as Void
		goControles.Actualizar( this )
		
		if this.cdominio = 'FECHA' and This.lEsObligatorio
			goControles.PerderFoco( this, thisform )		
		endif
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarAntesDeSetearAtributo() as boolean
		return .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function TransformarValorParaSetear( txValor as variant ) as variant
		return txValor
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarDespuesDeSetearAtributo() as boolean	
		return .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function DespuesDelValid( tnRetorno as integer ) as boolean
		return .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearValorEnElAtributo( txValor as Variant ) as Void
		local  lcAtributo as string, loError as Exception, loEx as Exception
		lcAtributo = this.ObtenerAtributoRelacionado()
		if vartype( thisform.oKontroler.&lcAtributo ) != "U"
			thisform.oKontroler.&lcAtributo = txValor
		Endif	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerValorDelAtributo() as variant
		local  lcAtributo as string, lxRetorno as variant

		lcAtributo = this.ObtenerAtributoRelacionado()
		lxRetorno = thisform.oKontroler.&lcAtributo
		
		return lxRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerAtributoRelacionado() as string
		local lcAtributo as String
		
		lcAtributo = ""
		
		with this
			if empty( .cAtributoPadre )
				lcAtributo = alltrim( .cAtributo )
			else
				if .lClavePrimaria
					lcAtributo = alltrim( .cAtributoPadre ) + "_PK"
				else
					lcAtributo = alltrim( .cAtributoPadre ) + "_" + alltrim( .cAtributo )
				endif
			endif
		endwith
		
		return lcAtributo
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function TransformarValorParaObtener( txValor as variant ) as variant
		return txValor
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerProximoControl() as integer
		return goControles.ObtenerProximoControl( thisform )
	endfunc

	*-----------------------------------------------------------------------------------------
	function RightClick() as Void
		local loItemMenu as Object, loPopup as Object
	
		if vartype( thisform.oMenu ) = "0"	
			for each loItemMenu in thisform.oMenu.controls
				if pemstatus(loItemMenu, "Caption", 5)
					if "Edición" $ loItemMenu.caption
						loPopup = loItemMenu
					endif
				endif	
			next
			if vartype( loPopup ) = "O"
				thisform.cBM.showpopupmenu( loPopup )
			Endif	
		endif
			
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Ordenar() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearEstado( tcEstado as String ) as Void
		do case

			case upper( tcEstado ) = "NUEVO"
				this.enabled = .t.
				
			case upper( tcEstado ) = "EDICION"
				this.enabled = .t.

			case upper( tcEstado ) = "GUARDARCOMO"
				this.enabled = .t.

			otherwise
				this.enabled = .f.
		endcase
	
		goControles.SetearColoresEnControl( this )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function AplicarEstilo( toEstilos as object ) as Void

		this.AntesDeAplicarEstilos( toEstilos )
		
		with this
			.nForeColorSinFoco = .ForeColor
			.nBackColorSinFoco = .BackColor
		endwith
		
		this.DespuesDeAplicarEstilos( toEstilos )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearLuegoDeOrdenar( toAcomodadorControles as object ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AntesDeAplicarEstilos( toEstilos as object ) as Void
	endfunc

	*-----------------------------------------------------------------------------------------
	function DespuesDeAplicarEstilos( toEstilos as object ) as Void
	endfunc

	*-----------------------------------------------------------------------------------------
	function when() as Boolean 
		this.xValorAnterior = this.Value
		return dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Destroy
		with this
			.oItem = null
			.oControlesOrdenados = null
			.oEntidad = null
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerAyuda() as String
		local lcRetorno as String

		lcRetorno = alltrim( this.cAyuda )

		with thisform
			if this.EsFormularioConDetalleDeValores()
				lcRetorno = lcRetorno + " (Comandos Abreviados: Ctrl+Shift+O Valores)"
			endif
		endwith
				
		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EsFormularioConDetalleDeValores() as Booloean
		local llRetorno as Boolean

		llRetorno = pemstatus( .oKontroler, "oEntidad", 5 ) and vartype( .oKontroler.oEntidad ) = 'O' and !isnull( .oKontroler.oEntidad ) and ;
				pemstatus( .oKontroler.oEntidad, "ValoresDetalle", 5 ) and ;
				pemstatus ( .oKontroler.oEntidad, "cNombre", 5 ) and upper( alltrim( .oKontroler.oEntidad.cNombre ) ) != upper( "EquiValorLince" )
		
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function MouseEnter( nButton, nShift, nXCoord, nYCoord ) as Void
		local lcTooltip as String, lcToolTipSiDaError as String
		
		dodefault( nButton, nShift, nXCoord, nYCoord )

		if !empty( this.cToolTip )
			try 
				lcTooltip = this.cToolTip 
				this.ToolTipText = evaluate( lcToolTip )
			catch to loError
				if "THISFORM.OKONTROLER" $ upper( This.cToolTip ) && Hay una función para obtener el texto y por algun motivo pinchó
					lcToolTipSiDaError = ""
				else && Si dió error el evaluate, y no tiene Thisform.oKontroler, quiere decir que era texto y no necesitaba evaluarse.
					lcToolTipSiDaError = This.cToolTip
				endif
				this.ToolTipText = lcToolTipSiDaError
			endtry
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function MouseDown( tnButton as Integer, tnShift as Integer, tnXCoord as Integer, tnYCoord as Integer ) as Void
		if this.SeDebeSeleccionarContenido( tnButton )
			nodefault
			this.AceptarMouseDown()
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function AceptarMouseDown() as Void
		this.lAceptarMouseDown = .t.
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function SeDebeSeleccionarContenido( tnButton as Integer ) as Boolean
		return this.SelectOnEntry and tnButton == 1 and !this.lAceptarMouseDown
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function NoValidarSiCancelaOBusca( toObjeto as Object ) as Boolean
		local llRetorno as Boolean

		llRetorno = .F.		
		If Vartype( toObjeto ) = 'O' and pemstatus( toObjeto, "class", 5) and pemstatus( toObjeto, "name", 5)
			do Case
				case ( upper( alltrim( toObjeto.class ) ) == "BOTONCONFOCO" ) and ( upper( alltrim( toObjeto.name ) ) == "CMDCANCELAR" )
					llRetorno = .T.
				case upper( alltrim( toObjeto.class ) ) == "BOTON"
					&& Si apretó el botón de la lupita, verifico que pertenezcan al mismo contenedor
					if ( this.Parent == toObjeto.Parent ) and right( alltrim( this.Parent.cDominio ), 14) != "DesdeHastaBusc"
						llRetorno = .T.
					endif
			EndCase
		EndIf
		
		return llRetorno
	endfunc 
	
    *-----------------------------------------------------------------------------------------
    function ControlaSalirCancelarOBuscar() as Void
		Do Case		
			Case Mdown()
				if thisform.ReleaseType > 0
					&& Controlo si quiere cerrar el formulario o salir de fox
					this.value = ""
				else
					&& Controlo si hice click en un control como buscar o cancelar, y pongo el valor en "" para que pase los Valid
		            loObject = Sys( 1270 )
		            If this.NoValidarSiCancelaOBusca( loObject )
						this.value = ""
		            endif
					loObject = Null
				endif							
		endcase
    endfunc 

	*-----------------------------------------------------------------------------------------
	function enabled_assign( tlValue as Boolean ) as Void
		this.Enabled = tlValue
		if this.DebeUtilizarReadOnlyEnLugarDeEnabledYAunNoSeSeteo()
			this.ReadOnly = .t.
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Value_assign( txValue as Variant) as Void
		this.Value = txValue 
		if !isnull( txValue ) and isnull( this.xValorInicial )
			this.xValorInicial = this.Value 
		endif
	endfunc
	*-----------------------------------------------------------------------------------------
	hidden function DebeUtilizarReadOnlyEnLugarDeEnabledYAunNoSeSeteo() as boolean
		return this.lUtilizaReadOnlyEnLugarDeEnabled and !this.ReadOnly
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function NoPermitirComillas( tnKeyCode as Integer ) as boolean
		return inlist( tnKeyCode, 39, 34, 91, 93 )
	endfunc

	*-----------------------------------------------------------------------------------------
	function TieneComportamientoPorTecla( nKeyCode, nShiftAltCtrl ) as Boolean
		return .f.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ActivarComportamientoPorTecla( nKeyCode, nShiftAltCtrl ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerAyudaComportamientoPorTecla() as String
		return ""
	endfunc 

enddefine
