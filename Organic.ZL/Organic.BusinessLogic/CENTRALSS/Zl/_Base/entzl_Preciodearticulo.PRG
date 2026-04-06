define class EntZl_PrecioDeArticulo as Ent_PrecioDeArticulo of Ent_PrecioDeArticulo.prg
	*-----------------------------------------------------------------------------------------
	function ReasignarPk_Con_CC() as Void
		This.Codigo = padr( alltrim( str( this.TimestampAlta, 14 ) ), 14) + padr( This.ListaDePrecio_Pk, 6 ) + padr( This.Articulo_Pk, 13 ) + padr( This.Talle, 3 )
	endfunc
	*-----------------------------------------------------------------------------------------
enddefine
