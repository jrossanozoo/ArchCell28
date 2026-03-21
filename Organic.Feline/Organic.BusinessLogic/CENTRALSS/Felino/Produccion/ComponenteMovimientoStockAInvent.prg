define class ComponenteMovimientoStockAInvent as din_ComponenteMovimientoStockAInvent of din_ComponenteMovimientoStockAInvent.prg

	*-----------------------------------------------------------------------------------------
	function InyectarEntidad( toEntidad as Object ) as Void
		This.oEntidadPadre = toEntidad
	endfunc 
	
	*** Genera sentencias de ContraMovimiento directamente desde el componenteStockProduccion

enddefine
