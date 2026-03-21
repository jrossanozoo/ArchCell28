define class DetalleModelodeProduccionModeloInsumos as Din_DetalleModelodeproduccionModeloinsumos of Din_DetalleModelodeproduccionModeloinsumos.prg

	#if .f.
		local this as DetalleModelodeProduccionModeloInsumos of DetalleModelodeProduccionModeloInsumos.prg
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
