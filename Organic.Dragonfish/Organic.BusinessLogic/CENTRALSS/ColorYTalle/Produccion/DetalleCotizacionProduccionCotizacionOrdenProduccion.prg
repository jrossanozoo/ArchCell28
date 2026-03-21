define class DetalleCotizacionProduccionCotizacionOrdenProduccion as Din_DetalleCotizacionproduccionCotizacionordenproduccion of Din_DetalleCotizacionproduccionCotizacionordenproduccion.prg

	#if .f.
		local this as DetalleCotizacionProduccionCotizacionOrdenProduccion of DetalleCotizacionProduccionCotizacionOrdenProduccion.prg
	#endif

	*-----------------------------------------------------------------------------------------
	function ObtenerItemAuxiliar() as Object
		local loItem as Object
		loItem = newobject('ItemAuxiliar', 'DetalleCotizacionProduccionCotizacionOrdenProduccion.prg')
		return loItem
	endfunc 

enddefine