Define Class DetalleOrdenDeProduccionOrdenSalidas as din_DetalleOrdenDeProduccionOrdenSalidas of din_DetalleOrdenDeProduccionOrdenSalidas.prg

	#if .f.
		local this as DetalleOrdenDeProduccionOrdenSalidas of DetalleOrdenDeProduccionOrdenSalidas.prg
	#endif

	*--------------------------------------------------------------------------------------------------------
	Function Actualizar( tcClave as String ) as Void
		tcClave = this.ObtenerClaveParaItem( this.oItem )
		DoDefault( tcClave )
	endfunc

EndDefine
