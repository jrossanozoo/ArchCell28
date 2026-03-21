define class ItemColorYTalle_MovimientoStockDesdeProducc as ItemMovStock of ItemMovStock.Prg

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
		this.enlazar(".color.AjustarObjetoBusqueda","EventoBusquedaDeColor")
		this.enlazar(".talle.AjustarObjetoBusqueda","EventoBusquedaDeTalle")

	endfunc 
	*-----------------------------------------------------------------------------------------
	function EventoBusquedaDeColor( toBusqueda as Object ) as Void
		local lcFiltro as String, lcCodigos as String, lcCampoClave as String  
		lcFiltro = ""	
		lcCodigos = ""
		this.lBuscandoCodigo = .t.
		lcCampoClave = this.color.oad.obtenercampoentidad( this.color.obteneratributoclaveprimaria())
		if vartype( toBusqueda ) = "O"
			lcCodigos = this.oCompStockProduccion.oColaboradorColoryTalle.ObtenerColores( this.insumo )
			if !empty( lcCodigos )
				lcCodigos = " and " + lcCampoClave + " in ("+lcCodigos+")"
			endif 
			toBusqueda.filtro = toBusqueda.filtro + lcCodigos
		endif
		this.lBuscandoCodigo = .f.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoBusquedaDeTalle( toBusqueda as Object ) as Void
		local lcFiltro as String, lcCodigos as String, lcCampoClave as String  
		lcFiltro = ""	
		lcCodigos = ""
		this.lBuscandoCodigo = .t.
		lcCampoClave = this.talle.oad.obtenercampoentidad( this.talle.obteneratributoclaveprimaria())
		if vartype( toBusqueda ) = "O"
			lcCodigos = this.oCompStockProduccion.oColaboradorColoryTalle.ObtenerTalles( this.insumo )
			if !empty( lcCodigos )
				lcCodigos = " and codigo in ("+lcCodigos+")"
			endif 
			toBusqueda.filtro = toBusqueda.filtro + lcCodigos
		endif
		this.lBuscandoCodigo = .f.
	endfunc 

*!*		*--------------------------------------------------------------------------------------------------------
*!*		function SetearValoresSugeridos() as void
*!*			dodefault()
*!*			if !empty( this.oEntidad.InventarioOrigen_PK ) and this.EsNuevo()
*!*				this.InventarioDestino_PK = this.oEntidad.InventarioOrigen_PK
*!*			endif
*!*		endfunc

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