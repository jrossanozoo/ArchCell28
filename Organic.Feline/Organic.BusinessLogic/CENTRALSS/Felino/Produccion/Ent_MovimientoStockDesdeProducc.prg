define class Ent_MovimientoStockDesdeProducc as Din_EntidadMovimientoStockDesdeProducc of Din_EntidadMovimientoStockDesdeProducc.prg

	#if .f.
		local this as ent_MovimientoStockDesdeProducc of ent_MovimientoStockDesdeProducc.prg
	#endif

	TipoComprobante = 92
	lSaltearValidacionPorAnulacionDesdeComprobanteGenerador = .f.

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
		this.oCompMovimientoStockDesdeProducc.InyectarEntidad( this )
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Setear_InventarioOrigen( txVal as variant ) as void
		dodefault( txVal )
		if !empty( txVal )
			this.MovimientoDetalle.SetearInventarioEnItems( txVal )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AntesDeGrabar() As Boolean		
		local llRetorno as Boolean
		this.MovimientoDetalle.SetearInventarioEnItems( this.InventarioOrigen_PK )
		llRetorno = dodefault()
		return llRetorno
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
		local llRetorno as Boolean, lnTipoComprobanteFinalDeProduccion as Integer, llTieneAfectantes as Boolean
		llRetorno = .f.
		lnTipoComprobanteFinalDeProduccion = 90
		if this.FueGeneradoDesdeOtroComprobante( "ANULAR", lnTipoComprobanteFinalDeProduccion )
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

enddefine
