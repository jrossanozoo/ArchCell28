define class DetalleMovimientoStockDesdeProduccMovimientoDetalle as Din_DetalleMovimientoStockDesdeProduccMovimientoDetalle of Din_DetalleMovimientoStockDesdeProduccMovimientoDetalle.prg

	*-----------------------------------------------------------------------------------------
	function SetearInventarioEnItems( tcInventarioOrigen as String ) as Void
		local loItem as Object
		for each loItem in this
			loItem.Inventario_PK = tcInventarioOrigen
		endfor
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Actualizar( tcClave as string ) as Void
		with this.oItem
			if !empty( .Insumo_PK ) and ( .Cantidad <= 0 or .CantidadStockDF <= 0 or empty( .Articulo_PK ) )
				goServicios.Errores.LevantarExcepcionTexto( 'El artículo y las cantidades son datos obligatorios' )
			else
				dodefault( tcClave )
			endif
		endwith
	endfunc

enddefine
