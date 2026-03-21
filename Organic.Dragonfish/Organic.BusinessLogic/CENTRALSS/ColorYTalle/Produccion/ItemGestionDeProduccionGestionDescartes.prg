define class ItemGestionDeProduccionGestionDescartes as Din_ItemGestionDeProduccionGestionDescartes of Din_ItemGestionDeProduccionGestionDescartes.Prg

	#if .f.
		local this as ItemGestionDeProduccionGestionDescartes of ItemGestionDeProduccionGestionDescartes.prg
	#endif

	*--------------------------------------------------------------------------------------------------------
	function Setear_N( txVal as variant ) as void
		dodefault( txVal )
		if !empty( txVal ) &&and empty( this.Insumo_pk )
			this.Unidad = this.articulo.UnidadDeMedida_PK
			this.SetearDatosDeInsumoAsociado( txVal )
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
*!*			this.UnidadInsumo = &lcCursor..RindeUnidad
*!*			if empty( this.rinde )
*!*				this.rinde = &lcCursor..RindeCantidad
*!*			endif
		use in select( lcCursor )
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function Setear_MotDescarte( txVal as variant ) as void
		dodefault( txVal )
*!*			if !empty( txVal )
			this.InventarioDest_PK = this.MotDescarte.Inventario_PK
*!*			endif
	endfunc 

enddefine
