define class KontrolerValor as din_KontrolerValor of din_KontrolerValor.prg

	#if .f.
		local this as KontrolerValor of KontrolerValor.prg
	#endif

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
		this.RefrescarSolapas()
		this.ActualizarComboPrestador()
		this.enlazar( "oEntidad.EventoHacerFocoCuentaBancaria", "HacerFocoCuentaBancaria" )	
		This.enlazar( "oEntidad.EventoPreguntarSiEliminaPorCtaCte", "PreguntarSiEliminaPorCtaCte" )	
	endfunc

	*-----------------------------------------------------------------------------------------
	function Tipo_assign( txValor as variant ) as Void
		dodefault( txValor )
		this.RefrescarSolapas()
		this.SetearAtributosObligatorios()
	endfunc

	*-----------------------------------------------------------------------------------------
	function Prestador_assign( txValor as variant ) as Void
		dodefault( txValor )
		this.RefrescarSolapas()
	endfunc

	*-----------------------------------------------------------------------------------------
	function HabilitarRetiroEfectivo_assign( txValor as variant ) as Void
		dodefault( txValor )
		this.SetearAtributosObligatoriosParaRetiroEfectivo( txValor )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function RefrescarSolapas() as Void
		local loPanel as Object, lcTituloSolapa as String
		for each loPanel in thisform.pnlgrupos.objects foxobject
			lcTituloSolapa = upper( alltrim( loPanel.Caption ) )
			loPanel.enabled = .F.
			do case
				case lcTituloSolapa == "GENERALES" or lcTituloSolapa == "FUNCIONALIDADES"
					loPanel.enabled = .T.
				case lcTituloSolapa == "CHEQUE DE TERCEROS"
					loPanel.enabled = this.Tipo == 12 
				case lcTituloSolapa == "EQUIVALENCIAS"
					loPanel.enabled = .t.
				case "TARJETA" $ lcTituloSolapa and this.Tipo == 3
					loPanel.enabled = .t.
				case lcTituloSolapa == "PAGO ELECTRÓNICO" and this.Tipo == 11
					loPanel.enabled = .t.
				case lcTituloSolapa == "CUENTA BANCARIA" and this.Tipo == 13
					loPanel.enabled = .t.
				case lcTituloSolapa == "RETIRO DE EFECTIVO" and ( this.Tipo == 3 or (this.Tipo == 11 and inlist( this.prestador, "MPQR2" )))
					loPanel.enabled = .t.
			endcase
		endfor

		lcSolapa = "thisform.pnlgrupos.page" + transform( thisform.pnlgrupos.ActivePage ) + ".enabled"
		if ! &lcSolapa
			thisform.pnlgrupos.ActivePage = 1
		endif
		
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearAtributosObligatorios() as Void
		local loPrestador as object, loTipoDeTarjeta as CODIGODESCRIPCION of CODIGODESCRIPCION.prg, ;
			  loOperadoraDeTarjeta as CODIGODESCRIPCION of CODIGODESCRIPCION.prg
			 		
		loTipoDeTarjeta = null
		loOperadoraDeTarjeta = null
        loPrestador = null

		if this.ExisteControl( "TIPOTARJETA" )
			loTipoDeTarjeta = this.ObtenerControl( "TIPOTARJETA" )
			loTipoDeTarjeta.lEsObligatorio = ( this.Tipo == 3 )
			this.SetearColorYRefrescarUnControl( loTipoDeTarjeta )
		endif					
		
		if Thisform.oEntidad.RequiereOperadoraDeTarjetas() and  this.ExisteControl( "OPERADORATARJETA" )
			loOperadoraDeTarjeta = this.ObtenerControl( "OPERADORATARJETA" )
			loOperadoraDeTarjeta.lEsObligatorio = ( this.Tipo == 3 )
			this.SetearColorYRefrescarUnControl( loOperadoraDeTarjeta )
		endif
         
        if this.ExisteControl( "PRESTADOR" )
            loPrestador = this.ObtenerControl( "PRESTADOR" )
            loPrestador.lEsObligatorio = ( this.Tipo == 11 )
            this.SetearColorYRefrescarUnControl( loPrestador)
        endif        
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearAtributosObligatoriosParaRetiroEfectivo( tlObligatorio as variant ) as Void
		this.MarcarUnAtributoComoObligatorio( "ValorParaRetiroDeEfectivo", tlObligatorio )
		this.MarcarUnAtributoComoObligatorio( "MontoMaximoDeRetiro", tlObligatorio )
		this.MarcarUnAtributoComoObligatorio( "ValorDeAcreditacion", tlObligatorio )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function MarcarUnAtributoComoObligatorio( tcAtributo as String, tlObligatorio as Boolean ) as Void
		local loControl as Object
	
		if this.ExisteControl( tcAtributo )
			loControl = this.ObtenerControl( tcAtributo ) 
			loControl.lEsObligatorio = tlObligatorio 
			this.SetearColorYRefrescarUnControl( loControl )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearColorYRefrescarUnControl( toControl as Object ) as Void
		goServicios.Controles.SetearColoresEnControl( toControl )
		goServicios.Controles.Actualizar( toControl )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ActualizarComboPrestador() as Void
		local loCombo as Object	
		loCombo = this.ObtenerControl( "PRESTADOR" )
		loCombo.CrearCursor(.t.)
	endfunc		
	
	*-----------------------------------------------------------------------------------------
	function HacerFocoCuentaBancaria() as Void
		thisform.PNLGRUPOS.ActivePage = 6
	endfunc 

	*-----------------------------------------------------------------------------------------
	function PreguntarSiEliminaPorCtaCte( tlMensajeVta, tlMensajeCpra ) as Void
		local lcMensaje as String, lcMensajeAdvertencia as String
		
		lcMensaje = ""
		lcMensajeAdvertencia = "Para evitar inconsistencias en los datos se recomienda que salde dichos movimientos. ¿Desea continuar de todas maneras?"

		do case 
			case tlMensajeVta and tlMensajeCpra
				lcMensaje = "ATENCION!! Para este valor existen movimientos en cuenta corriente ventas y compras con saldo pendiente. " + lcMensajeAdvertencia 
			case tlMensajeVta
				lcMensaje = "ATENCION!! Para este valor existen movimientos en cuenta corriente ventas con saldo pendiente. " + lcMensajeAdvertencia 
			case tlMensajeCpra
				lcMensaje = "ATENCION!! Para este valor existen movimientos en cuenta corriente compras con saldo pendiente. " + lcMensajeAdvertencia 
		endcase 
		if goServicios.Mensajes.alertar( lcMensaje , 4, 1 ) == 6   && si
			this.oEntidad.lPreguntarSiDebeEliminar = .t.
		endif

	endfunc 

enddefine

