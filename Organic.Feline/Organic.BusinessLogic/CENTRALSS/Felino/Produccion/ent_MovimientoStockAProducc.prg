define class ent_MovimientoStockAProducc as Din_EntidadMovimientoStockAProducc of Din_EntidadMovimientoStockAProducc.prg

	#if .f.
		local this as ent_MovimientoStockAProducc of ent_MovimientoStockAProducc.prg
	#endif

	TipoComprobante = 94

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
		this.oCompMovimientoStockAProducc.InyectarEntidad( this )
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Setear_InventarioDestino( txVal as variant ) as void
		dodefault( txVal )
		if !empty( txVal )
			this.MovimientoDetalle.SetearInventarioEnItems( txVal )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AntesDeGrabar() As Boolean		
		local llRetorno as Boolean
		this.MovimientoDetalle.SetearInventarioEnItems( this.InventarioDestino_PK )
		llRetorno = dodefault()
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function Validar() as Boolean
		local llRetorno as Boolean
		
		llRetorno = dodefault()
		if this.MovimientoDetalle.Count < 1
			this.AgregarInformacion( "No se puede grabar si no tiene movimientos en el detalle." )
			llRetorno = .f.
		else
			llRetorno = llRetorno and this.MovimientoDetalle.ValidarDetalle()
		endif
		return llRetorno
	endfunc 

enddefine
