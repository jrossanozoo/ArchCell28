define class zooEditBox as EditBox

	#IF .f.
		Local this as zooEditBox of zooEditBox.prg
	#ENDIF

	#INCLUDE constantesDibujante.h

	datasession = 1

	IntegralHeight = .T.
	Margin = 0
	
	nColumna = 0
	nFila = 0

	cAyuda = ""

	lEsSeteable = .F.
	EsAjustable = .F.

	oItem = null
	nForeColorConFoco = 0
	nBackColorConFoco = 0
	nForeColorSinFoco = 0
	nBackColorSinFoco = 0

	nBackColorObligSinFoco = 0	
	nForeColorObligSinFoco = 0		
	
	lEsObligatorio = .f.	

	lDetalle = .f.
	lEsControlConSaltoDeCampoDefiniblePorElUsuario = .T.

	oEntidad = null
	lEsSubEntidad = .f.

	nTipoDeOrdenIzquierdo = NO_ACOMODAR
	nTipoDeOrdenSuperior = NO_ACOMODAR

	lSePuedeOrdenar = .t.
	lSeSuperpone = .f.

	oControlesOrdenados = null

	nRenglones = 2

	cAtributoPadre = ""
	
	cAtributo = ""
	cClaveForanea = ""
	lClavePrimaria = .f.
	lSaltoCampo = .f.
	cTipoDato = ""
	cEntidad = ""

	lTabForzado = .f.
	xValorAnterior = ""
	
	dimension aEventos( 1, 4 )

	lEsTraducible = .t.
	cEstado = ""
	lValidaSoloSiModifico = .f.

	lZoomeable = .t.
	oVentanaZoom = Null
	cTituloVentanaZoom = 'Zoom'

	lOld = .f.
	lMuestraRelacion = .f.
	lPermiteCaracteresComilla = .f.
	lPermiteExpresion = .f.
	cToolTip = ""
		
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
	function Armar() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearLuegoDeOrdenar( toAcomodadorControles as object ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearControl( toItem as Object ) as Void
		with this
			if vartype(toItem) = "O"
				.oItem = toItem

				.lSaltoCampo = .oItem.SaltoCampo
				if .oItem.Longitud > 0
					.maxLength = .oItem.Longitud
				endif
				.cAyuda = .oItem.Ayuda
				
				.cAtributo = alltrim(.oItem.Atributo)
				.cClaveForanea = alltrim( .oItem.ClaveForanea )
				.cTipoDato = alltrim( .oItem.TipoDato )
				.lDetalle = .oItem.Detalle
				.cEntidad = alltrim( .oItem.Entidad )
 
				.lEsSubEntidad = .oItem.lEsSubEntidad
				.lValidaSoloSiModifico = .oItem.ValidaModificacion
				.lEsObligatorio = iif( pemstatus( .oItem, 'Obligatorio', 5 ), .oItem.Obligatorio, .F. )			
			
				.lMuestraRelacion = .oItem.MuestraRelacion
				.cToolTip = .oItem.ToolTip
				
				if empty( .oItem.Formato )
				else
					.Format = .oItem.Formato
				endif
				
				with .oItem
					if empty( .Ayuda )
						if empty( .etiqueta )
							if empty( .DescripcionSubgrupo )
								This.cTituloVentanaZoom = "Zoom"
							else
								This.cTituloVentanaZoom = .DescripcionSubgrupo
							endif 
						else
							This.cTituloVentanaZoom = .etiqueta
						endif 
					else
						This.cTituloVentanaZoom = .Ayuda
					endif
				endwith 
				
			endif
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function gotFocus()
		local loError as Exception, loEx as Exception 
		
		if this.readonly
		else
			this.SelStart = len( this.value )
			dodefault()

			with this
				.ForeColor = .nForeColorConFoco
				.BackColor = .nBackColorConFoco

				try
					if vartype( thisform.oKontroler ) == "O"
						thisform.oKontroler.SetearAyuda( .cayuda )
					endif
				Catch To loError
					loEx = Newobject( "ZooException", "ZooException.prg" )
					With loEx
						.Grabar( loError )
						goServicios.Mensajes.Enviar( loEx )
					EndWith
				endtry		
				
			endwith
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function LostFocus()
		local loError as Exception, loEx as Exception 
	
		this.SelStart = 0
		dodefault()
		this.value = rtrim( this.value )
	
		try
			goControles.PerderFoco( this, thisform )
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
		local lnRetorno as integer, lcCadena as String, loError as Exception, loEx as Exception 
		
		try
			lcCadena = ""
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
		endtry

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
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarAntesDeSetearAtributo() as boolean
		return .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function TransformarValorParaSetear( txValor as variant ) as variant
		return strtran( txValor, "", "" )
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
		local  lcAtributo as string

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
	
		if pemstatus( thisform, "oMenu", 5 )
			for each loItemMenu in thisform.oMenu.controls
				if pemstatus(loItemMenu, "Caption", 5)
					if "Edición" $ loItemMenu.caption
						loPopup = loItemMenu
					endif
				endif	
			next	
			if pemstatus( thisform, "CBM", 5 ) .and. vartype( loPopup ) = "O"
				thisform.cBM.showpopupmenu( loPopup )
			endif 
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function DblClick() as Void
		with this
			if .lZoomeable
				.VentanaZoom()
			endif
		endwith 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Ordenar() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearEstado( tcEstado as String ) as Void
		local llEstado as Boolean, lcEstadoDelCursor as String 
		
		if this.lMuestraRelacion and !this.lDetalle and this.lEsSubEntidad 
			llEstado = .t.
		else
			llEstado = iif( inlist( tcEstado, "EDICION", "NUEVO" ,"GUARDARCOMO" ), .f., .t. )
		endif
		
		this.ReadOnly = llEstado 
		this.TabStop = !llEstado
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
	function AntesDeAplicarEstilos( toEstilos as object ) as Void
	endfunc

	*-----------------------------------------------------------------------------------------
	function DespuesDeAplicarEstilos( toEstilos as object ) as Void
	endfunc

	*-----------------------------------------------------------------------------------------
	function KeyPress( nKeyCode, nShiftAltCtrl )

		if this.lTabForzado
			this.lTabForzado = .f.
		else
			thisform.SetearUltimaTecla( nKeyCode, nShiftAltCtrl )
			local lcTexto as string

			do case
				case nKeyCode = 13

					if empty( alltrim( this.value ) ) or ;	&&El campo esta vacio
						Right( alltrim( this.value ), 2 ) == ( chr(13) + chr( 10 ) ) or ; &&hay un enter con retroceso de campo al final
						Right( alltrim( this.value ), 1 ) == chr(13) or ; &&hay un enter sin retroceso de campo al final
						( !empty( this.maxlength ) and len( this.value ) > this.maxlength - 2 )&& los dos ultimos caracteres son ocupados por el enter

						lcTexto = right( this.value, len( this.value ) - this.SelStart )
						lcTexto = strtran( lcTexto, chr( 13 ), "" )
						lcTexto = strtran( lcTexto, chr( 9 ), "" )
						lcTexto = alltrim( lcTexto )

						if empty( lcTexto ) or ( !empty( this.maxlength ) and len( this.value ) > this.maxlength - 2 )
							this.lTabForzado = .t.
							keyboard '{tab}'

							nodefault	&&para que no agregue los dos enters en en el texto
						endif
					endif

				case nKeyCode = 4 &&FLECHA DERECHA
					if this.SelStart = len( this.value )
						this.value = alltrim( this.value )

						this.lTabForzado = .t.
						keyboard '{tab}'
					endif

				case nKeyCode = 24 &&FLECHA ABAJO
					if this.UltimaFila()
						this.value = alltrim( this.value )

						this.lTabForzado = .t.
						keyboard '{tab}'
					endif

				case nKeyCode = 19 &&FLECHA IZQUIERDA
					if this.SelStart = 0
						this.value = alltrim( this.value )

						this.lTabForzado = .t.
						keyboard '{tab}'
					endif
					
				case nKeyCode = 5 &&FLECHA ARRIBA
					if this.PrimerFila()
						this.value = alltrim( this.value )
						this.lTabForzado = .t.
						keyboard '{tab}'
					endif
			endcase
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function PrimerFila() as Boolean
		local lnAnchoScroll as integer, lnAnchoEditBox as integer, lnAnchoActual as integer, llRetorno as boolean, lcTexto as string
		
		with this
			lnAnchoScroll = Sysmetric( 5 )
			lnAnchoEditBox = .Width - lnAnchoScroll

			llRetorno = .t.

			lnPrimerEnter = at( chr( 13 ), .value )
			if !empty( lnPrimerEnter ) and .SelStart > lnPrimerEnter
				llRetorno = .f.
			else
				lcTexto = substr( .value, 1,  .SelStart )
				lnAnchoActual = goServicios.Librerias.ObtenerAnchoTexto( lcTexto, this )
				
				llRetorno = ( lnAnchoEditBox > lnAnchoActual )
			endif
		endwith
		return llRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function UltimaFila() as Boolean
		local lnPrimerEnter as integer, llRetorno as boolean, lcTexto as string
		
		with this
			llRetorno = .t.

			lnPrimerEnter = rat( chr( 13 ), .value )
			if !empty( lnPrimerEnter ) and .SelStart < lnPrimerEnter
				llRetorno = .f.
			else
				llRetorno = ( .SelStart = len( .value ) )
			endif
		endwith
		return llRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function when() as Boolean
		if !empty ( this.Value )  
			this.xValorAnterior = this.Value
		endif
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
	function VentanaZoom() as Void
		if pemstatus( thisform, "oKontroler", 5 ) and vartype( thisform.oKontroler ) = "O"
			thisform.oKontroler.SetearEstadoMenuYToolBar( .f. )
		endif		
		
		goFormularios.MostrarScxSingleton( "zoomform",.t.,this,thisform )
		if pemstatus( thisform, "oKontroler", 5 ) and vartype( thisform.oKontroler ) = "O"
			thisform.oKontroler.SetearEstadoMenuYToolBar( .T. )
		endif		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerAyuda() as String
		return this.cAyuda
	endfunc 

	*-----------------------------------------------------------------------------------------
	function MouseEnter( nButton, nShift, nXCoord, nYCoord ) as Void
		local lcTooltip as String
		
		dodefault( nButton, nShift, nXCoord, nYCoord )

		if !empty( this.cToolTip )
			try 
				lcTooltip = this.cToolTip 
				this.ToolTipText = evaluate( lcToolTip )
			catch to loError
				this.ToolTipText = this.cToolTip
			endtry
		endif
	endfunc

enddefine
