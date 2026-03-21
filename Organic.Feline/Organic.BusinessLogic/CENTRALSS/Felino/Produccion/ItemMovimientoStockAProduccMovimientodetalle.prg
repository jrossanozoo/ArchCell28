define class ItemMovimientoStockAProduccMovimientodetalle as Din_ItemMovimientoStockAProduccMovimientodetalle of Din_ItemMovimientoStockAProduccMovimientodetalle.Prg
	
	#if .f.
		local this as ItemMovimientoStockAProduccMovimientodetalle of ItemMovimientoStockAProduccMovimientodetalle.prg
	#endif
	
	cContexto = ""
	*-----------------------------------------------------------------------------------------
	function EventoDespuesDeSetear( toObject as Object, tcAtributo as String, txValOld as Variant, txVal as Variant ) as Void

		dodefault( toObject, tcAtributo, txValOld, txVal )

		if this.CargaManual()
			if "ARTICULO_PK" = upper( tcAtributo ) and !( alltrim( txValOld ) == alltrim( txVal ) )
				this.Unidad = this.articulo.UnidadDeMedida_PK
				this.SetearDatosDeInsumoAsociado( txVal )
			endif
			if "INSUMO_PK" = upper( tcAtributo ) and !( alltrim( txValOld ) == alltrim( txVal ) )
				this.UnidadInsumo = this.Insumo.RindeUnidad_PK
				this.Rinde = this.Insumo.RindeCantidad
			endif
		endif

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearDatosDeInsumoAsociado( tcArticulo as String ) as Void
		local lcCursor as String, lcCondicion as String, lcXml as String 
		
		lcCursor = sys( 2015 ) 
		lcCondicion = "Articulo = '" + tcArticulo + "'" 
		lcXml = this.Insumo.oAD.ObtenerDatosEntidad( "Codigo,RindeUnidad,RindeCantidad", lcCondicion ) 
		xmltocursor( lcXml, lcCursor ) 
		select ( lcCursor )
		go top
		this.Insumo_pk = &lcCursor..Codigo
		use in select( lcCursor )
	endfunc 

enddefine
