define class ItemModeloDeProduccionModeloProcesos as din_ItemModelodeproduccionModeloProcesos of din_ItemModelodeproduccionModeloProcesos.prg

	#if .f.
		local this as ItemModeloDeProduccionModeloProcesos of ItemModeloDeProduccionModeloProcesos.prg
	#endif

	*--------------------------------------------------------------------------------------------------------
	function Validar_Proceso( txVal as variant, txValOld as variant ) as Boolean
		local llRetorno as Boolean
		llRetorno = This.EsModoEdicion() and dodefault( txVal, txValOld )
		if llRetorno and !empty(txValOld) and not (alltrim(upper(txVal)) == alltrim(upper(txValOld)))
			llRetorno = this.oEntidad.ValidarProcesoEnItems(txValOld)
			if !llRetorno
				goServicios.Errores.LevantarExcepcion('El proceso esta usado en los items')
			endif
		endif
		Return llRetorno
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Setear_Proceso( txVal as variant ) as void
		dodefault( txVal )
		if this.oEntidad.EsModoEdicion() and !empty(txVal)
			this.oEntidad.ProcesoActivo = txVal
		else
			this.oEntidad.ProcesoActivo = ''
		endif
	endfunc

enddefine
