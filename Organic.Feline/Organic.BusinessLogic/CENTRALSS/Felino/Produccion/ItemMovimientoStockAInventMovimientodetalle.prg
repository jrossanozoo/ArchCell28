define class ItemMovimientoStockAInventMovimientoDetalle as Din_ItemMovimientoStockAInventMovimientoDetalle of Din_ItemMovimientoStockAInventMovimientoDetalle.Prg

	#if .f.
		local this as ItemMovimientoStockAInventMovimientoDetalle of ItemMovimientoStockAInventMovimientoDetalle.prg
	#endif
	cContexto = ""
	*--------------------------------------------------------------------------------------------------------
	function Setear_Insumo( txVal as variant ) as void
		dodefault( txVal )
		if !empty( txVal )
			if !empty(this.oCompStockProduccion.oEntidadPadre.InventarioOrigen_PK)
				this.Inventario_PK = this.oCompStockProduccion.oEntidadPadre.InventarioOrigen_PK
			endif
			if !empty(this.oCompStockProduccion.oEntidadPadre.InventarioDestino_PK) and empty( this.InventarioDestino_PK )
				this.InventarioDestino_PK = this.oCompStockProduccion.oEntidadPadre.InventarioDestino_PK
			endif
		endif
	endfunc 

enddefine
