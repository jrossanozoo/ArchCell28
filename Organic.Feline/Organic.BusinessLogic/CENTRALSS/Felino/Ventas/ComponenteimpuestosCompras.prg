define class ComponenteImpuestosCompras as ComponenteImpuestos of ComponenteImpuestos.prg

	#If .F.
		Local This As ComponenteImpuestosCompras Of ComponenteImpuestosCompras.prg
	#Endif

	oComponenteFiscal = null

	*-----------------------------------------------------------------------------------------
	protected function Vaciar() as Void
		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Destroy()
		this.ldestroy = .t.
		this.oComponenteFiscal = null
		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function InyectarComponenteFiscal( toCompFiscal as componentefiscal OF componentefiscal.prg ) as Void
		this.oComponenteFiscal = toCompFiscal
	endfunc 

	*-----------------------------------------------------------------------------------------
	function TieneImpuestosManuales() as Boolean
		return this.oComponenteFiscal.TieneImpuestosManuales()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Calcular( toItem as ItemArticulosVenta of ItemArticulosVenta.prg, toDetalleImpuestos as Object ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Recalcular( toDetalle as detalle OF detalle.prg ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CargarImpuestos() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function RecalcularImpuestosPorCambioDeNeto( tnTotalNeto as Integer, toDetalle as detalle OF detalle.prg, tnCoeficienteNetoGravadoIVA as Number, tnCoeficienteParaAplicacionDePercepcionesIVA as Number ) as Void
	endfunc

enddefine
