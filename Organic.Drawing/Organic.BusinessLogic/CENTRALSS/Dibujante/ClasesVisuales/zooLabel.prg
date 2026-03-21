define class zooLabel as label

	#IF .f.
		Local this as zooLabel of zooLabel.prg
	#ENDIF

	#INCLUDE constantesDibujante.h

	AutoSize = .F.
	BackStyle = 0

	nColumna = 0
	nFila = 0

	cAyuda = ""

	lAplicaEstilo = .T.
	lEsSeteable = .F.
	EsAjustable = .F.

	lSePuedeOrdenar = .t.
	lSeSuperpone = .f.

	nForeColorConFoco = 0
	nBackColorConFoco = 0
	nForeColorSinFoco = 0
	nBackColorSinFoco = 0

	nTipoDeOrdenIzquierdo = NO_ACOMODAR
	nTipoDeOrdenSuperior = NO_ACOMODAR
	
	nRenglones = 1

	dimension aEventos( 1, 4 )

	lEsTraducible = .t.
	cEstado = ""
	lBlanquearToolTip = .t.
	
	*-----------------------------------------------------------------------------------------
	function Init( toItem as object )
		if vartype(toItem)="C" and toItem = "NO"
			return
		endif

		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AplicarEstilo(toEstilos as object ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearLuegoDeOrdenar( toAcomodadorControles as object ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function caption_assign( tcValor as String ) as Void
		local lcTexto as String
		lcTexto = tcValor

		if this.lBlanquearToolTip
			this.ToolTipText = ""
		endif
				
		if upper( this.Caption ) == tcValor &&Me estan asignando el texto en mayúsculas
			if ( this.Width * This.nRenglones ) < goLibrerias.ObtenerAnchoTexto( lcTexto, this )
				this.ToolTipText = this.Caption
				lcTexto = this.CalcularNuevoCaption( lcTexto )
			endif
		endif
		this.Caption = lcTexto
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CalcularNuevoCaption( tcTexto as String ) as string
		local i as Integer, lcTexto as String, lcRetorno as String, lnAnchoLabel as Integer, llHayEspacio as boolean
		
		llHayEspacio = .t.

		lcRetorno = ""
		lcTexto = alltrim( tcTexto )
		for i = 1 to This.nRenglones
			lnAnchoLabel = this.Width
			llHayEspacio = .t.
			do while llHayEspacio and !Empty( This.ObtenerPrimeraPalabra( lcTexto ) )
				if lnAnchoLabel > goLibrerias.ObtenerAnchoTexto( This.ObtenerPrimeraPalabra( lcTexto ), this ) 
					lnAnchoLabel = lnAnchoLabel - goLibrerias.ObtenerAnchoTexto( This.ObtenerPrimeraPalabra( lcTexto ), this )
					lcRetorno = lcRetorno + This.ObteneryQuitarPrimerPalabra( @lcTexto )
					llHayEspacio = .t.					
				else
					llHayEspacio = .f.
				endif
			enddo
		endfor

		if empty( lcRetorno )
			local lcTexto2 as String
			for i = 1 to len( lcTexto )
				lcTexto2 = substr( lcTexto, 1, len( lcTexto ) - i )
				if goLibrerias.ObtenerAnchoTexto( lcTexto2 + "...", this ) <= this.Width
					lcRetorno = lcTexto2
					exit
				endif
			endfor
		endif

		if !empty( alltrim( lcTexto ) )
			if llHayEspacio
				if ( ( lnAnchoLabel - 22 ) > goLibrerias.ObtenerAnchoTexto( "...", this ) )
					lcRetorno = alltrim( lcRetorno ) + "..."
				else
					lcRetorno = substr( alltrim( lcRetorno ) , 1, ( len( alltrim( lcRetorno ) ) - 5 )) + "..."
				endif				
			else
				lcRetorno = substr( alltrim( lcRetorno ) , 1, ( len( alltrim( lcRetorno ) ) - 5 )) + "..."
			endif
		endif
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerPrimeraPalabra( tcTexto as String ) as String
		lcRetorno = substr( tcTexto, 1, at( " ", tcTexto, 1 ) )
		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObteneryQuitarPrimerPalabra( tcTexto as String ) as string
		local lcRetorno  as String 

		lcRetorno = This.ObtenerPrimeraPalabra( tcTexto )
		tcTexto = strtran( tctexto, lcRetorno , "", 1 , 1 )

		return lcRetorno

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerFactor() as Integer
		local lcFuenteAnt as String, lnFuenteAnt as Integer, lnFactor as Integer, ;
			loError as zooexception OF zooexception.prg
		
		lcFuenteAnt = _screen.FontName
		lnFuenteAnt = _screen.FontSize
		_screen.FontName = this.lblEtiqueta.FontName
		_screen.FontSize = this.lblEtiqueta.FontSize

		try
			lnFactor = _screen.TextWidth( this.lblEtiqueta.caption ) / this.lblEtiqueta.width
			
			if lnFactor != int( lnFactor )
				lnFactor = int( lnFactor ) + 1
			endif
		catch to loError
			throw loError
		finally
			_screen.FontName = lcFuenteAnt
			_screen.FontSize = lnFuenteAnt
		endtry
		
		return lnFactor
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerAyuda() as String
		return this.cAyuda
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerRenglonesRequeridos( tcParaEsteTexto as String ) as Integer
		local lcTexto as String, lcFuenteAnt as String, lnFuenteAnt as Integer, lnFactor as Integer, ;
			  lnAnchoDelTexto as Integer, loError as zooexception OF zooexception.prg
		
		if ( vartype( tcParaEsteTexto ) == "C" ) and ( !empty( tcParaEsteTexto ) )
			lcTexto = tcParaEsteTexto 
		else
			lcTexto = this.Caption
		endif
		
		lcFuenteAnt = _screen.FontName
		lnFuenteAnt = _screen.FontSize
		_screen.FontName = this.FontName
		_screen.FontSize = this.FontSize

		try
			lnFactor = 0
			if this.width != 0
				lnAnchoDelTexto = _screen.TextWidth( lcTexto )
				lnFactor = lnAnchoDelTexto / this.width
			endif
			
			if lnFactor != int( lnFactor ) or lnFactor = 0
				lnFactor = int( lnFactor ) + 1
			endif
		catch to loError
			throw loError
		finally
			_screen.FontName = lcFuenteAnt
			_screen.FontSize = lnFuenteAnt
		endtry
		
		return lnFactor
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AdaptarMisDimiensionesAlContenidoSinSuperarElTope( tnTopeADerecha as Integer ) as Integer
		local lnRenglonesRequeridos as Integer, lnAltoAnterior as Integer, lnAncho as Integer
		
		with this
			if tnTopeADerecha > .left
				.width = tnTopeADerecha - .left
			endif
			
			lnRenglonesRequeridos = .ObtenerRenglonesRequeridos()
			.wordwrap = ( lnRenglonesRequeridos > 1 )
			
			lnAltoAnterior = .height
			if ( .nRenglones != lnRenglonesRequeridos ) 
				if ( .nRenglones > 1 )
					.height = .height / .nRenglones
				endif
				
				.height = .height * lnRenglonesRequeridos
				.nRenglones = lnRenglonesRequeridos
			endif
		endwith
		
		return this.height - lnAltoAnterior
	endfunc 

enddefine
