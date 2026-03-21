define class ItemOrdenDeProduccionOrdenCurva as din_ItemOrdenDeProduccionOrdenCurva of din_ItemOrdenDeProduccionOrdenCurva.prg

	#if .f.
		local this as ItemOrdenDeProduccionOrdenCurva of ItemOrdenDeProduccionOrdenCurva.prg
	#endif

	esCurvaNueva = .f.
	estaEliminando = .f.
	
	*--------------------------------------------------------------------------------------------------------
	function Validar_Producto( txVal as variant, txValOld as variant ) as Boolean
		local llRetorno as Boolean
		this.esCurvaNueva = .f.
		this.estaEliminando = .f.
		llRetorno = dodefault( txVal, txValOld )
		if !this.lCargando and !this.lLimpiando and !this.oEntidad.lProcesando
			if this.oEntidad.EsModoEdicion()
				if !empty(txVal) and txVal != txValOld
					if txVal != this.oEntidad.ProductoFinal_PK and !empty(this.oEntidad.ProductoFinal_PK)
						goServicios.Errores.LevantarExcepcion( "El producto de la curva debe ser el definido como producto final." )
						this.oEntidad.ProductoFinal_PK = txVal
					endif
				endif
				if empty(txVal) and !empty(txValOld) and !this.lLimpiando
					this.oEntidad.QuitarCurvaDeOrden(this.Color_PK, this.Talle_PK)
				endif
			endif
			this.esCurvaNueva = empty(txValOld) and !empty(txVal)
			this.estaEliminando = empty(txVal) and !empty(txValOld)
		endif
		Return llRetorno 
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Setear_Producto( txVal as variant ) as void
		dodefault( txVal )
		if this.oEntidad.EsModoEdicion() and empty(this.oEntidad.ProductoFinal_PK)
			this.oEntidad.ProductoFinal_PK = txVal
		endif
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Setear_Cantidad( txVal as variant ) as void
		dodefault( txVal )
		if this.oEntidad.EsModoEdicion() and (this.oEntidad.lCargandoCurva or this.oEntidad.lCalcularCantidadDeCurvas) &&  and this.total == 0
			this.ProcesarDespuesDeSetearCantidad()
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function ProcesarDespuesDeSetearCantidad() as Void
		this.Total = iif(this.cantidad > 1, this.cantidad, 1) * iif(this.oEntidad.Cantidad > 1, this.oEntidad.Cantidad, 1)
	endfunc 

enddefine
