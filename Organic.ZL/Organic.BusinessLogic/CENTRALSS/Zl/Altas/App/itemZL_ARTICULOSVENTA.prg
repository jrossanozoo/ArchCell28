define class itemzl_articulosventa as ItemArticulosVenta of ItemArticulosVenta.prg

*-----------------------------------------------------------------------------------------
	function AsignarCondicionYPorcentajeDeIva()as Void

	endfunc
*-----------------------------------------------------------------------------------------
	function eventoComponenteStock( tcAtributo As String, toItem as object ) as Void
		dodefault( tcAtributo , toItem )
		if !This.lTieneStockDisponible
			This.LimpiarAtributosRelacionadosAPieza()
		endif
	endfunc

enddefine 