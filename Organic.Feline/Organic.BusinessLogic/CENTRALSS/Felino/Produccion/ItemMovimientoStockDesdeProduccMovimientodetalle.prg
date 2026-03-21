define class ItemMovimientoStockDesdeProduccMovimientoDetalle as Din_ItemMovimientoStockDesdeProduccMovimientoDetalle of Din_ItemMovimientoStockDesdeProduccMovimientoDetalle.Prg

	#if .f.
		local this as ItemMovimientoStockDesdeProduccMovimientoDetalle of ItemMovimientoStockDesdeProduccMovimientoDetalle.prg
	#endif
	cContexto = ""
	*--------------------------------------------------------------------------------------------------------
	function Setear_Insumo( txVal as variant ) as void
		dodefault( txVal )
		if !empty( txVal ) and empty( this.Articulo_pk )
			this.Unidad_PK = this.Insumo.RindeUnidad_PK
			this.SetearDatosDeArticuloAsociado( txVal )
		endif
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function Setear_Color( txVal as variant ) as void
		dodefault( txVal )
		if !empty( txVal ) and empty( this.ColorArt_pk )
			this.ColorArt_PK = txVal
		endif
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function Setear_Talle( txVal as variant ) as void
		dodefault( txVal )
		if !empty( txVal ) and empty( this.TalleArt_pk )
			this.TalleArt_PK = txVal
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearDatosDeArticuloAsociado( tcInsumo as String ) as Void
		local lcCursor as String, lcCondicion as String, lcXml as String 
		
		lcCursor = sys( 2015 ) 
		lcCondicion = "Codigo = '" + tcInsumo + "'" 
		lcXml = this.Insumo.oAD.ObtenerDatosEntidad( "Articulo,UnidadDeMedida,RindeCantidad", lcCondicion ) 
		xmltocursor( lcXml, lcCursor ) 
		select ( lcCursor )
		go top
		this.Articulo_pk = &lcCursor..Articulo
		this.UnidadStockDF_PK = &lcCursor..UnidadDeMedida
		if empty( this.rinde )
			this.rinde = &lcCursor..RindeCantidad
		endif
		use in select( lcCursor )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoDespuesDeSetear( toObject as Object, tcAtributo as String, txValOld as Variant, txVal as Variant ) as Void
		dodefault( toObject, tcAtributo, txValOld, txVal )
		if "INSUMO_PK" = upper( tcAtributo ) and txValOld != txVal
** sacar de acá, hacer bindeo
			if !empty(this.oCompStockProduccion.oEntidadPadre.InventarioOrigen_PK)
				this.Inventario_PK = this.oCompStockProduccion.oEntidadPadre.InventarioOrigen_PK
			endif
		endif
	endfunc 

enddefine
