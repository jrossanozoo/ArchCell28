define class ent_MovimientoStockAInvent as Din_EntidadMovimientoStockAInvent of Din_EntidadMovimientoStockAInvent.prg

	#if .f.
		local this as ent_MovimientoStockAInvent of ent_MovimientoStockAInvent.prg
	#endif

	TipoComprobante = 93
	lEsUnContraMovimiento = .f.
	lSaltearValidacionPorAnulacionDesdeComprobanteGenerador = .f.

	*-----------------------------------------------------------------------------------------
	function ActualizarEtiquetas() as Void
		*** para que se bindee el kontroler
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsTipoMovimientoSalida() as Boolean
		return ( this.Tipo = 2 )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsTipoMovimientoEntrada() as Boolean
		return ( this.Tipo = 1 )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarAnulacion() as Boolean
		local llRetorno as Boolean 
		llRetorno = .T.
		llRetorno = llRetorno and !this.TieneComprobantesRelacionadosQueImpidanEliminar()
		llRetorno = llRetorno and dodefault()
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function TieneComprobantesRelacionadosQueImpidanEliminar() as Void
		local llRetorno as Boolean, lnTipoComprobanteGestionDeProduccion as Integer, lnTipoComprobanteMovimientoStockAInvent as Integer, llTieneAfectantes as Boolean
		llRetorno = .f.
		lnTipoComprobanteMovimientoStockAInvent = this.TipoComprobante
		lnTipoComprobanteGestionDeProduccion = 91
		if this.FueGeneradoDesdeOtroComprobante( "ANULAR", lnTipoComprobanteMovimientoStockAInvent )
			llRetorno = .t.
		endif
		if this.FueGeneradoDesdeOtroComprobante( "ANULAR", lnTipoComprobanteGestionDeProduccion )
			llRetorno = .t.
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function FueGeneradoDesdeOtroComprobante( tcEstado as string, tnTipoComprobanteAValidar as String ) as Boolean
		local llRetorno as Boolean, lnPosicion as Integer
		llRetorno = .f.
		lnPosicion = 1
		if !this.lSaltearValidacionPorAnulacionDesdeComprobanteGenerador and inlist( tcEstado, "ANULAR" ) 
			for lnPosicion = 1 to this.CompAfec.Count
				if lower( this.compafec.item[lnPosicion].Tipo ) = "afectado" and this.compafec.item[lnPosicion].TipoComprobante = tnTipoComprobanteAValidar
					This.AgregarInformacion( "Este comprobante ha sido generado por el comprobante ";
					+ alltrim( this.compafec.item[lnPosicion].tipocompcaracter ) + ". No puede "+ iif(tcEstado="ANULAR", "anularse", "modificarse") )
					llRetorno = .t.
					exit
				endif
			endfor
		endif
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarInventarioOrigen() as Boolean
		local llRetorno as Boolean
		if this.Ccontexto = "I"
			if this.EsTipoMovimientoEntrada()
				this.InventarioOrigen = this.InventarioDestino
				llRetorno = .T.
			else
				llRetorno = this.ValidarInventarioDestino()
			endif
		else
			llRetorno = dodefault()
		endif
		return llRetorno	
	endfunc 


enddefine
