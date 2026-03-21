Define Class ent_ComprobanteDeFondos as Ent_ComprobanteDeVentasConValores of Ent_ComprobanteDeVentasConValores.prg

	#if .f.
		Local this as ent_ComprobanteDeFondos of ent_ComprobanteDeFondos.prg
	#endif

	lEsComprobanteDeMovimientoDeFondos = .T.
	lEsComprobanteConStock = .f.
	lRecalcularVuelto = .f.
	lAplicarDescuentoDeValores = .f.
	lAsignarCodigoDeValorSugeridoParaVuelto = .f.
	lComprobanteConVuelto = .f.
	lTieneVuelto = .f.
	lDebeCalcularVuelto = .f.
	lRecalcularPorCambioDeListaDePrecios = .f.
	lMostrarAdvertenciaRecalculoPrecios = .f.
	llPermiteTipoAjusteDeCupon  = .f.
	lPermiteAgregarArticulos = .f.
	lItemControlaDisponibilidad = .f.
	lCancelaDiferenciasDePicking = .f.
	lComprobanteConDescuentosAutomaticos = .f.
	lImprimirTicketFaltantes = .f.
	lItemControlaDisponibilidad = .f.
	lComprobanteDebeValidarDevolucionDeArticulo = .f.
	cValoresDetalle	= ""
	lQueHacerConCambio = .f.

	*-----------------------------------------------------------------------------------------
	protected function SetearListaDePreciosPreferenteOValorSugerido() as String 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearCotizacion() as Void
		this.cotizacion = 1
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function SetearValidadorCombinacionesRepetidas as Void
	endfunc 

 	*-----------------------------------------------------------------------------------------
	function CotizarVuelto() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function DebeValidarItemsSinEquivalencias() as Boolean
		return .f.
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function DebeRecalcularEnElAntesDeGrabar() as Boolean
		return .f.
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function RecorrerYAcumular() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarVueltoEnCaja() as boolean 
		return .t.
	endfunc

	*-----------------------------------------------------------------------------------------
	function AjusteDeRecargoPorSubtotalEnCero() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AplicarProrrateo() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarEquivalencias() as Boolean
		return .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ExisteMontoDeRecargoEnUnCambio() as Boolean
		return .f.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarCantidadItems() As Boolean
		return .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarDescuentosYRecargos() as Boolean
		return .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarRestriccionDeDescuentos() as Boolean
	    return .t.
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarVueltoSegunTipoValor() as boolean
	    return .t.
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function SuperaLimiteDescuentoEnControladorFiscalIBM( tnAtributoPorcentajeDescuento as Integer ) as boolean
	    return .f.
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function DebeValidarLimiteEnControladorFiscalIBM() as boolean
	    return .f.
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarTotalRecargosValoresEnPositivo() as Boolean
	    return .t.
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarLimiteTicketFactura() as Boolean
	    return .t.
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function RecalcularRecargos()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function DebeQuitarImpuestosAlDescuento() as Boolean
		return .f.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarAlivioDeCaja() as Void
		return .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CargarValoresCpteRelacionado( toEntidad as Object, toRequest as Object ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ActualizarSubTotal(  ) as Void	
	endfunc

enddefine
