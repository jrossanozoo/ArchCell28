define class DetalleMovimientostockaproduccMovimientoDetalle as Din_DetalleMovimientostockaproduccMovimientoDetalle of Din_DetalleMovimientostockaproduccMovimientoDetalle.prg

	#if .f.
		local this as DetalleMovimientostockaproduccMovimientoDetalle of DetalleMovimientostockaproduccMovimientoDetalle.prg
	#endif

	*-----------------------------------------------------------------------------------------
	function SetearInventarioEnItems( tcInventarioDestino as String ) as Void
		local loItem as Object
		for each loItem in this
			loItem.Inventario_PK = tcInventarioDestino
		endfor
	endfunc

	*-----------------------------------------------------------------------------------------
	function Actualizar( tcClave as string ) as Void

		with this.oItem
			if !empty( .Articulo_PK ) and ( .Cantidad <= 0 or .CantidadInsumo <= 0 or empty( .Insumo_PK ) )
				goServicios.Errores.LevantarExcepcionTexto( 'El insumo y las cantidades son datos obligatorios' )
			else
				dodefault( tcClave )
			endif
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarDetalle() as Boolean
		local loItem as Object, llRetorno as Boolean
		llRetorno = .t.
		for each loItem in this FOXOBJECT	
			with loItem
				if !empty( .Articulo_PK ) and ( .Cantidad <= 0 or .CantidadInsumo <= 0 or empty( .Insumo_PK ) )
					llRetorno = .f.
					goServicios.Errores.LevantarExcepcionTexto( 'El insumo y las cantidades son datos obligatorios en cada artículo del detalle' )
				endif
			endwith
		next
		return llRetorno
	endfunc 


enddefine
