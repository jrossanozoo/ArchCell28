define class ItemCotizacionProduccionCotizacionOrdenDescarte as Din_ItemCotizacionProduccionCotizacionOrdenDescarte of Din_ItemCotizacionProduccionCotizacionOrdenDescarte.prg

	#if .f.
		local this as ItemCotizacionProduccionCotizacionOrdenDescarte of ItemCotizacionProduccionCotizacionOrdenDescarte.prg
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

	*--------------------------------------------------------------------------------------------------------
	function Validar_Articulo( txVal as variant, txValOld as variant ) as Boolean

		Return dodefault( txVal, txValOld ) and (empty(txVal) or This.ValidarArticuloTipoConcepto())

	endfunc

	*--------------------------------------------------------------------------------------------------------
	protected function ValidarArticuloTipoConcepto() as void
		if !empty(this.Articulo.Codigo) and this.Articulo.Comportamiento # 2
			goServicios.Errores.LevantarExcepcion( 'Solo puede ingresar un articulo tipo concepto.' )
		endif
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Setear_Cantidad( txVal as variant ) as void
		local lnCantidad as Number
		lnCantidad = this.Costo
		dodefault( txVal )
		if this.EsModoEdicion() and (txVal # 0 or lnCantidad # txVal)
			this.Monto = this.Cantidad * this.Costo
		endif

	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Setear_Costo( txVal as variant ) as void
		local lnCosto as Number
		lnCosto = this.Costo
		dodefault( txVal )
		if this.EsModoEdicion() and txVal # 0 or lnCosto # txVal
			this.Monto = this.Costo * this.Cantidad
		endif

	endfunc

enddefine
