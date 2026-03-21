define class ItemLiquidacionDeTallerLiquidacionTallerAdicionales as Din_ItemLiquidacionDeTallerLiquidacionTallerAdicionales of Din_ItemLiquidacionDeTallerLiquidacionTallerAdicionales.prg

	#if .f.
		local this as ItemLiquidacionDeTallerLiquidacionTallerAdicionales of ItemLiquidacionDeTallerLiquidacionTallerAdicionales.prg
	#endif

	*--------------------------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
		this.enlazar( ".Articulo.AjustarObjetoBusqueda","EventoBusquedaArticuloConcepto" )
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoBusquedaArticuloConcepto( toBusqueda as Object ) as Void
		local lcFiltro as String, lcCampoClave as String  
		lcFiltro = ""	
		this.lBuscandoCodigo = .t.
		if vartype( toBusqueda ) = "O"
			toBusqueda.filtro = toBusqueda.filtro + " and art.astock = 2"
		endif
		this.lBuscandoCodigo = .f.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoCambioItem() as Void
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function Validar_Articulo( txVal as variant, txValOld as variant ) as Boolean
		Return dodefault( txVal, txValOld ) and (empty(txVal) or This.ValidarArticuloTipoConcepto())
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Validar_Cantidad( txVal as variant ) as Boolean
		local lRet as Boolean
		txValOld = this.Cantidad
		if this.Resto>0 and txVal > this.Resto
			lRet = .f.
		else
			lRet = dodefault( txVal )	
		endif
		if lRet and !empty(txValOld) and txVal # txValOld
			this.EventoCambioItem() 
		endif
		return lRet 
	endfunc
		
	*--------------------------------------------------------------------------------------------------------
	function Validar_Costo( txVal as variant ) as Boolean
		local lRet as Boolean
		txValOld = this.Costo
		lRet = dodefault( txVal )
		if lRet and !empty(txValOld) and txVal # txValOld
			this.EventoCambioItem() 
		endif
		return lRet 
	endfunc	

	*--------------------------------------------------------------------------------------------------------
	protected function ValidarArticuloTipoConcepto() as void
		if this.Articulo.Comportamiento # 2
			goServicios.Errores.LevantarExcepcion( 'Solo puede ingresar un articulo tipo concepto.' )
		endif
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Setear_Cantidad( txVal as variant ) as void
		dodefault( txVal )
		this.Monto = this.Cantidad*this.Costo
		if txVal = 0
			this.articulo_PK = ""
		endif
		this.cambiosumarizado()
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Setear_Costo( txVal as variant ) as void
		dodefault( txVal )
		this.Monto = this.Cantidad*this.Costo
		this.cambiosumarizado()
	endfunc

enddefine
