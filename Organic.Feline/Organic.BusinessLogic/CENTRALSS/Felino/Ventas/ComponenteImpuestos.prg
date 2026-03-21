define class ComponenteImpuestos as zoosession of zoosession

	#if .f.
		local this as ComponenteImpuestos of ComponenteImpuestos.prg
	#endif

	oImpuestosComprobante = null
	oImpuestos = null
	oMontosImpuestosPorArticulo = null
	oEntidadDatosFiscales = Null
	nPorcentajeDescuentoGlobal = 0
	lMontosConIvaIncluido = .t.
	nSituacionFiscalCliente = 0
	TotalSinImpuestosMenosDescuentosMasRecargos = 0
	SumaPorcentajesIIBB = 0
	TipoConvenioCliente = 0
	lComprobanteDeExportacion = .f.
	nCoeficienteNetoGravadoIVA = 0
	cTipoDeComprobante = ""
	lAccionCancelatoria = .f.
	nIvainscriptos = 0
	nPorcentajeRecargo = 0
	nPorcentajeDescuento = 0
	
	*--------------------------------------------------------------------------------------------------------
	function oEntidadDatosFiscales_Access() as Object
		if !this.ldestroy and (vartype( this.oEntidadDatosFiscales ) # 'O' or isnull( this.oEntidadDatosFiscales ))
			this.oEntidadDatosFiscales = _Screen.Zoo.InstanciarEntidad( "DatosFiscales" )
		endif
		return this.oEntidadDatosFiscales
	endfunc

	*-----------------------------------------------------------------------------------------
	function Destroy()
		this.ldestroy = .t.
		this.Vaciar()
		this.oImpuestosComprobante = null
		this.oImpuestos = null
		this.oMontosImpuestosPorArticulo = null
		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function InyectarImpuestosComprobante( toImpuesto as detalle OF detalle.prg ) as Void
		this.oImpuestosComprobante = toImpuesto
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Calcular( toItem as ItemArticulosVenta of ItemArticulosVenta.prg, toDetalleImpuestos as Object ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AsignarNumeroDeItemAlItemCero( tnItem as integer ) as Void
		local loItem as Object
		if type( "this.oMontosImpuestosPorArticulo" ) = "O"
			if this.oMontosImpuestosPorArticulo.Buscar( "0" )
				loItem = this.oMontosImpuestosPorArticulo.Item( "0" )
				loItem.nItemArticulo = tnItem
				this.oMontosImpuestosPorArticulo.Quitar( "0" )
				this.AgregarItemAColeccionDeImpuestosPorArticulo( loItem, transform( tnItem ) )
			endif
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function CargarImpuestos() as Void
		this.Vaciar()
		if this.lAccionCancelatoria
			this.EventoCargarDetalleImpuestosDesdeFactura()
			this.CodigoDeDatoFiscalAplicado = ""
		else
			this.CargarDetalleImpuestos()
		endif
		this.CargarDetalleImpuestosComprobante()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoCargarDetalleImpuestosDesdeFactura() as Void
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function CargarDetalleImpuestosDesdeFactura( toComprobante )as Void
		local loItemImp as Object
		this.oImpuestosBase = _Screen.Zoo.CrearObjeto( 'ZooColeccion' )
		for each loItemImp in toComprobante.ImpuestosComprobante
			if loItemImp.Monto > 0
				loItem = this.oColaboradorPercepciones.ObtenerImpuesto( loItemImp.TipoImpuesto )
				loItem.AddProperty( "Modificado", .f. )
				with loItem
					.TipoImpuesto = loItemImp.TipoImpuesto 
					.Porcentaje = loItemImp.Porcentaje
					.MinimoNoImponible = loItemImp.MinimoNoImponible
					.CodigoInterno = loItemImp.CodigoInterno
					.Jurisdiccion = loItemImp.Jurisdiccion_PK
					.Resolucion = loItemImp.Descripcion
					.lMontosConIvaIncluido = this.lMontosConIvaIncluido
					.Calcula = .f.
					.PorcentajeAnterior = loItemImp.Porcentaje
					.Modificado = .f.
					.CodigoImpuesto = loItemImp.CodigoImpuesto
					.RegimenImpositivo = loItemImp.RegimenImpositivo
					.RG5329AplicaPorArticulo = loItemImp.RG5329AplicaPorArticulo
					.RG5329Porcentaje = loItemImp.RG5329Porcentaje
					if empty( loItemImp.BaseDeCalculo )
						.BaseDeCalculo = this.ObtenerBaseDeCalculo( loItemImp, toComprobante )
					else
						.BaseDeCalculo = loItemImp.BaseDeCalculo
					endif
					if empty( loItemImp.Minimo )
						.Minimo = 0
					else
						.Minimo = loItemImp.Minimo
					endif
					.MontoBase = 0			
				endwith
				this.oImpuestosBase.Agregar( loItem, loItem.CodigoInterno + loItem.CodigoImpuesto )
			endif
		endfor
		this.oImpuestos = _Screen.Zoo.CrearObjeto( 'ZooColeccion' )
		if this.oImpuestosBase.Count > 0
			for lnIndice = 1 to this.oImpuestosBase.Count
				loImpuesto = this.oImpuestosBase[ lnIndice ]
				if this.AgregarTipoImpuestoSegunSituacionFiscal()
					this.AgregarImpuestoAColeccion( loImpuesto )
				endif
			endfor 
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerBaseDeCalculo( toItemImpuesto, toComprobante ) as String
		local lcRetorno as String
		with toItemImpuesto
			do case
				case inlist( alltrim( .TipoImpuesto ), "GANANCIAS", "IMPINT" ) or .MontoBase = this.ObtenerMontoBaseComprobante( "BGI", toComprobante.ImpuestosDetalle )
					lcRetorno = "BGI"
				case alltrim( .TipoImpuesto ) = "IVA" or toItemImpuesto.MontoBase = this.ObtenerMontoBaseComprobante( "GRA", toComprobante.ImpuestosDetalle )
					lcRetorno = "GRA"
			endcase	
		endwith
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerMontoBaseComprobante( tcBaseDeCalculo, toDetalle ) as float
		local loItem as Object, lnRetorno as float
		lnRetorno = 0
		for each loItem in toDetalle
			do case
				case tcBaseDeCalculo = "BGI"
					lnRetorno = lnRetorno + loItem.MontoNoGravado
				case tcBaseDeCalculo = "GRA" and loItem.PorcentajeDeIva > 0                        
					lnRetorno = lnRetorno + loItem.MontoNoGravado
			endcase
		endfor
		return lnRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function Recalcular( toDetalle as detalle OF detalle.prg ) as Void
		local lnIndice as integer, loItem as object
		for lnIndice = 1 to toDetalle.Count
			loItem = toDetalle.Item[lnIndice]
			if toDetalle.oItem.NroItem == loItem.NroItem
			else
				this.Calcular( loItem )
			endif
		endfor
		this.Calcular( toDetalle.oItem )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearMontoImpuesto( tcClaveItemEnColeccion as String, tnMonto as Number, tnMontoBase as Number ) as Void
		local lnIndice as Integer, loItem as ItemArticulosVenta of ItemArticulosVenta.prg
		for lnIndice = 1 to this.oImpuestosComprobante.Count
			loItem = this.oImpuestosComprobante.Item[lnIndice]
			if loItem.CodigoInterno + loItem.CodigoImpuesto == tcClaveItemEnColeccion
				loItem.Monto = tnMonto
				loItem.MontoBase = tnMontoBase
			endif 
		endfor
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function Vaciar() as Void
		with this 
			if vartype( .oImpuestos ) = "O"
				.oImpuestos.remove( - 1 )
			endif
			if vartype( .oMontosImpuestosPorArticulo ) = "O"
				.oMontosImpuestosPorArticulo.remove( - 1 )
			endif
		endwith

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CargarDetalleImpuestos() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarImpuestoAColeccion( toItemImpuesto as Object ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CargarDetalleImpuestosComprobante() as Void
		local loItem as Custom, lnIndice as Integer
		this.ValidarColeccionImpuestos()
		for lnIndice = 1 to this.oImpuestos.Count
			loItem = this.oImpuestosComprobante.CrearItemAuxiliar()
			with loItem
				.Codigo = transform( lnIndice )
				.Nroitem = lnIndice
				.Monto = 0
				.Tipoimpuesto = this.oImpuestos.Item[lnIndice].TipoImpuesto && 'IIBB'
				.Descripcion = this.oImpuestos.Item[lnIndice].Resolucion
				.CodigoInterno = this.oImpuestos.Item[lnIndice].CodigoInterno
				.Porcentaje = this.oImpuestos.Item[lnIndice].Porcentaje
				.MinimoNoImponible = this.oImpuestos.Item[lnIndice].MinimoNoImponible
				.Jurisdiccion_PK = this.oImpuestos.Item[lnIndice].Jurisdiccion				
				.CodigoImpuesto = this.oImpuestos.Item[lnIndice].CodigoImpuesto
				.RegimenImpositivo = this.oImpuestos.Item[lnIndice].RegimenImpositivo
				.MontoBase = this.oImpuestos.Item[lnIndice].MontoBase
				.BaseDeCalculo = this.oImpuestos.Item[lnIndice].BaseDeCalculo
				.Minimo = this.oImpuestos.Item[lnIndice].Minimo
				.RG5329AplicaPorArticulo = this.oImpuestos.Item[lnIndice].RG5329AplicaPorArticulo
				.RG5329Porcentaje = this.oImpuestos.Item[lnIndice].RG5329Porcentaje
			endwith
			this.oImpuestosComprobante.Add( loItem, loItem.Codigo )
		endfor
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ProcesarImpuestos( tcCampo as string, tlSuma as Boolean ) as Integer
		local lnRetorno as Integer, lnIndice as integer, loMontosImpuestos as object
		lnRetorno = 0
		for lnIndice = 1 to this.oMontosImpuestosPorArticulo.Count
			loMontosImpuestos = this.oMontosImpuestosPorArticulo.Item[lnIndice]
			lnRetorno = lnRetorno  + iif( tlSuma, loMontosImpuestos.&tcCampo, 0 )
		endfor
		return round( lnRetorno, 4 )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Setear_nSituacionFiscalCliente( txValor ) as Void
		local lnIndice as Integer 
		dodefault( txValor )
		if type( "this.oImpuestos" ) = "O" 
			for lnIndice = 1 to this.oImpuestos.count
				this.oImpuestos.Item(lnIndice).nSituacionFiscalCliente = txValor
			endfor 
		endif	
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearEnImpuestosDeLaColeccionSiDebenCalcular() as Boolean
	endfunc 

	*-----------------------------------------------------------------------------------------
	function RecalcularImpuestosPorCambioDeNeto( tnTotalNeto as Integer, toDetalle as detalle OF detalle.prg, tnCoeficienteNetoGravadoIVA as Number, tnCoeficienteParaAplicacionDePercepcionesIVA as Number ) as Void
		this.TotalSinImpuestosMenosDescuentosMasRecargos = tnTotalNeto
		this.nCoeficienteNetoGravadoIVA = tnCoeficienteNetoGravadoIVA
		this.nCoeficienteParaAplicacionDePercepcionesIVA = tnCoeficienteParaAplicacionDePercepcionesIVA
		this.Recalcular( toDetalle )
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarColeccionImpuestos() as Void
		if !this.lDestroy and ( vartype( this.oImpuestos) != "O" or isnull( this.oImpuestos) )
			this.CargarDetalleImpuestos()
		endif 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ImpuestosCliente() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SacarPercepcionesConPorcentajeEnCero() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function DarFormatoResolucion( tcDescripcion as String, tnPorcentaje as Integer ) as String
		local lcRetorno as String
		
		lcRetorno = tcDescripcion
		if !empty( tcDescripcion ) and !empty( tnPorcentaje )
			if '#PORCENTAJE' $ tcDescripcion
				lcRetorno = strtran( tcDescripcion, '#PORCENTAJE', transform( tnPorcentaje, '@z 99.99' ))  + '%'
			endif
		endif
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function Aplicar() as Boolean
*!*		Para ser impelentada en la subclase
		return .f.
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarItemAColeccionDeImpuestosPorArticulo( toItem, tcKey ) as Void
		this.oMontosImpuestosPorArticulo.Agregar( toItem, tcKey )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function RestaurarColeccionImpuestosComprobante() as Void
		if vartype( this.oImpuestosComprobante ) = "O"
			this.oImpuestosComprobante.remove( - 1 )
		endif
		this.CargarDetalleImpuestosComprobante()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function TieneImpuestosManuales() as Boolean
		return .f.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerPorcentajesDeImpuestos( toItem as Din_FACTURAItemFacturadetalle of Din_FACTURAItemFacturadetalle.prg ) as Float
		local llRetorno as Float
		llRetorno = toItem.PorcentajeIVA
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function DebeCalcularPercepcionEnNotasDeCreditoDeCaba( toItemImpuesto as Object ) as Boolean
		return .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoAdvertirQueNoSeCalcularanPercepcionesDeIibb( toResolucion as collection ) as Void
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	function CalcularImpuestoEnBaseAGravamen( toDetalle as detalle OF detalle.prg, toColImpuestos as zoocoleccion OF zoocoleccion.prg ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
    function ObtenerCoeficienteFinanciero() as Float
        local lnRetorno as Float, loItem as Object
        lnRetorno = goParametros.Felino.DatosImpositivos.IVAInscriptos
        for each loItem in this.oImpuestos FOXOBJECT
            if upper(alltrim(loItem.TipoImpuesto)) == 'IVA'
                lnRetorno = lnRetorno + loItem.Porcentaje
                exit
            endif
        endfor
        return (lnRetorno  / 100)
    endfunc

	*-----------------------------------------------------------------------------------------
	function EventoCargarPorcentajeDescuentoRecargo() as void
	endfunc 

enddefine
