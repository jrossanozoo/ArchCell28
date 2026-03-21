define class ItemModelodeproduccionModeloSalidas as din_ItemModelodeproduccionModeloSalidas of din_ItemModelodeproduccionModeloSalidas.prg

	#if .f.
		local this as ItemModelodeproduccionModeloMaquinas of ItemModelodeproduccionModeloMaquinas.prg
	#endif

	*--------------------------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
		this.enlazar( ".colorM.AjustarObjetoBusqueda","EventoBusquedaDeColor" )
		this.enlazar( ".talleM.AjustarObjetoBusqueda","EventoBusquedaDeTalle" )
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Validar_Proceso( txVal as variant, txValOld as variant ) as Boolean
		local llRetorno as Boolean
		llRetorno = This.EsModoEdicion() and dodefault( txVal, txValOld )
		if llRetorno and !empty(txval)
			llRetorno = this.oEntidad.ValidarProcesoEnModelo(txVal)
			if !llRetorno
				goServicios.Errores.LevantarExcepcion('El proceso debe formar parte del modelo')
			endif
		endif
		Return llRetorno
	endfunc

enddefine
