define class DetalleOrdenDeProduccionOrdenInsumos as din_DetalleOrdenDeProduccionOrdenInsumos of din_DetalleOrdenDeProduccionOrdenInsumos.prg

	#if .f.
		local this as DetalleOrdenDeProduccionOrdenInsumos of DetalleOrdenDeProduccionOrdenInsumos.prg
	#endif
	
	lUsaClaveEnItem = .t.

	*--------------------------------------------------------------------------------------------------------
	Function Actualizar( tcClave as String ) as Void
		tcClave = this.ObtenerClaveParaItem( this.oItem )
		DoDefault( tcClave )
	endfunc

enddefine
