define class DetalleModelodeproduccionModeloProcesos as Din_DetalleModelodeproduccionModeloProcesos of Din_DetalleModelodeproduccionModeloProcesos.prg

	#if .f.
		local this as DetalleModelodeproduccionModeloProcesos of DetalleModelodeproduccionModeloProcesos.prg
	#endif

	oEntidad = null
	esDetalleEnProduccion = .t.
	esDetalleConCurvaDeProduccion = .t.
	
	*-----------------------------------------------------------------------------------------
	function InyectarEntidad( toEntidad As Object ) as Void
		This.oEntidad = toEntidad
		This.oItem.InyectarEntidad( toEntidad )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function RefrescarGrillasSegunProceso( tnFila as Integer ) as Void
	endfunc 

enddefine






