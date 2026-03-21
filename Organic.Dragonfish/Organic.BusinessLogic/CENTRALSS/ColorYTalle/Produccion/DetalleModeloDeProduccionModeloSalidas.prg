define class DetalleModeloDeProduccionModeloSalidas as Din_DetalleModelodeproduccionModeloSalidas of Din_DetalleModelodeproduccionModeloSalidas.prg

	#if .f.
		local this as DetalleModeloDeProduccionModeloSalidas of DetalleModeloDeProduccionModeloSalidas.prg
	#endif

	oEntidad = null
	esDetalleEnProduccion = .t.
	esDetalleConCurvaDeProduccion = .t.
	
	*-----------------------------------------------------------------------------------------
	function InyectarEntidad( toEntidad As Object ) as Void
		This.oEntidad = toEntidad
		This.oItem.InyectarEntidad( toEntidad )
	endfunc 

enddefine
