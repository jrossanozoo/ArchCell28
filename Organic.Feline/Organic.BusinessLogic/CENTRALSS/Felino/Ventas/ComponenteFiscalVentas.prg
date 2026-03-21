define class ComponenteFiscalVentas as ComponenteFiscal of ComponenteFiscal.prg

	#if .f.
		local this as ComponenteFiscalVentas of ComponenteFiscalVentas.prg
	#endif

	oColaboradorImpuestosInternos = null
	nSituacionFiscalCliente = 0 
	nLimiteComprobanteSinPersonalizar = 0.00
	nLimiteComprobanteSinPersonalizarTarjPagoElec = 0.00
	nLimiteComprobanteA = 0.00
	nLimiteComprobanteB = 0.00
	lTieneCliente = .F.
	oPuntosDeVenta = null
	lAccionCancelatoria = .f.
	nMontoImpuestosInternos = 0

	*-----------------------------------------------------------------------------------------
	function init( tcTipoDeComprobante as String ) as Void
		dodefault( tcTipoDeComprobante )
		this.nSituacionFiscalCliente = This.oSFiscal.ConsumidorFinal
		This.SetearMontoLimiteComprobante()
	endfunc

	*-----------------------------------------------------------------------------------------
	Protected function SetearMontoLimiteComprobante() as Void
		this.ObtenerLimiteTotalDeUnComprobanteSinPersonalizar()
		This.nLimiteComprobanteA = 0.00
		This.nLimiteComprobanteB = 0.00
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerLimiteTotalDeUnComprobanteSinPersonalizar() as Void
		this.nLimiteComprobanteSinPersonalizar = goParametros.Felino.GestionDeVentas.LimiteTotalDeUnComprobanteSinPersonalizar
		this.nLimiteComprobanteSinPersonalizarTarjPagoElec = goParametros.Felino.GestionDeVentas.LimiteTotalDeUnComprobSinPersonalizarUsandoTarjDeCredDebOPagoElectronico 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerLetra() as string
		local lcRetorno as Character, loColaborador as Object
		
		loColaborador = newobject( "proveedorletrafiscal", "proveedorletrafiscal.prg", "",;
			this.lComprobantesAMonotributistas, this.oComprobantes, this.oSFiscal, this.oSFiscalEmpresa, this.nSituacionFiscalEmpresa, this.lTieneCliente, this.cTipoDeComprobante )
			
		return loColaborador.ObtenerLetra( this.nSituacionFiscalCliente, This.cTipoDeComprobante )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCondicionDeIvaDelArticulo( toItem as Object ) as Integer 
		local lnRetorno as Integer
		lnRetorno = toItem.Articulo_CondicionIvaVentas
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerPorcentajeDeIvaDelArticulo( toItem as Object ) as Number 
		local lnRetorno as number
		lnRetorno = toItem.Articulo_PorcentajeIvaVentas 
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsArticuloGravado( toItem as Object ) as Boolean 
		return ( toItem.Articulo_CondicionIvaVentas != this.oTipoIVA.NoGravado )			
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerComponenteImpuestos() as Object 
		return _screen.zoo.crearobjeto( "ComponenteImpuestosVentas" )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function SetearCodigoCliente( tcCodigo as String ) as Void
		if type( "this.oComponenteImpuestos" ) = "O"
			this.oComponenteImpuestos.CodigoCliente =  tcCodigo
		endif 
		this.lTieneCliente = !empty( tcCodigo )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearSituacionFiscalCliente( tnSituacionFiscalCliente as Number ) as Void
		if empty( tnSituacionFiscalCliente )
			this.nSituacionFiscalCliente = This.oSFiscal.ConsumidorFinal
		else
			this.nSituacionFiscalCliente = tnSituacionFiscalCliente
		endif

		if type( "this.oComponenteImpuestos" ) = "O"
			this.oComponenteImpuestos.nSituacionFiscalCliente =  this.nSituacionFiscalCliente
		endif 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearTipoConvenioCliente( tnTipoConvenio as Integer )
		if type( "this.oComponenteImpuestos" ) = "O"
			this.oComponenteImpuestos.TipoConvenioCliente =  tnTipoConvenio
		endif	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerSituacionFiscalCliente() as Integer
		return this.nSituacionFiscalCliente
	endfunc 

	*-----------------------------------------------------------------------------------------
	function PermiteModificarSituacionFiscalDelCliente( tnSituacionfiscalComprobante, tnSituacionFiscalCliente ) as Boolean
		local llRetorno as Boolean
		llRetorno = .f.
		if tnSituacionfiscalComprobante = tnSituacionFiscalCliente
			llRetorno = .t.
		else
			llRetorno = !inlist( goregistry.feLINO.SituacionFiscalClienteInscripto, tnSituacionfiscalComprobante, tnSituacionFiscalCliente )
			if !llRetorno
				if (tnSituacionfiscalComprobante = 1 and tnSituacionFiscalCliente = 7) or (tnSituacionfiscalComprobante = 7 and tnSituacionFiscalCliente = 1)
					llRetorno = .t.
				endif 
			endif
		endif
		
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarClienteParaComprobanteFiscal( toCliente as Object, tnTotalComprobante as Number ) as Boolean
		return .T.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarTotalComprobantePersonalizado( tnTotal as float, tcSimboloMonetarioComprobante as String ) as Boolean
		return .T.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarTotalComprobanteSinPersonalizar( tnTotal as float, tcSimboloMonetarioComprobante as String, tlSoloHayValoresTarjetaOPagoElectronico as Boolean ) As Boolean
		local llRetorno As Boolean, lcMensaje as String

		llRetorno = dodefault( tnTotal, tcSimboloMonetarioComprobante )
		if llRetorno 
			if tlSoloHayValoresTarjetaOPagoElectronico
				if tnTotal >= this.nLimiteComprobanteSinPersonalizarTarjPagoElec and this.nLimiteComprobanteSinPersonalizarTarjPagoElec > 0 
					lcMensaje = "Se superó el límite de " + alltrim( tcSimboloMonetarioComprobante ) + alltrim ( transform( this.nLimiteComprobanteSinPersonalizarTarjPagoElec ,'99,999,999.99') )
					lcMensaje = lcMensaje + " para comprobantes sin personalizar con medio de pago tarjeta de crédito/débito o pago electrónico. "
					lcMensaje = lcMensaje + "Por favor recuerde ingresar el cliente."
					this.AgregarInformacion( lcMensaje )
					llRetorno = .f.
				endif
			else
				if tnTotal >= this.nLimiteComprobanteSinPersonalizar and this.nLimiteComprobanteSinPersonalizar > 0 
					lcMensaje = "Se superó el límite de " + alltrim( tcSimboloMonetarioComprobante ) + alltrim ( transform( this.nLimiteComprobanteSinPersonalizar ,'99,999,999.99') )
					lcMensaje = lcMensaje + " para comprobantes sin personalizar. Si el medio de pago es tarjeta de crédito/débito o pago electrónico, el límite es de "
					lcMensaje = lcMensaje + alltrim( tcSimboloMonetarioComprobante ) + alltrim ( transform( this.nLimiteComprobanteSinPersonalizarTarjPagoElec ,'99,999,999.99') )
					this.AgregarInformacion( lcMensaje )
					llRetorno = .f.
				endif
			endif
		endif
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function VerificarSituacionFiscalDeClienteCoherenteConLetra( tnSituacionFiscalCliente as Integer, tcLetra as String ) as Boolean
		local llRetorno as Boolean
		llRetorno = .F.
		
		do case
			case tcLetra  = "C" or tcLetra = "E"
				llRetorno = .T.
			case tcLetra  = "A" or tcLetra  = "M"
				if tnSituacionFiscalCliente = goregistry.Felino.SituacionFiscalClienteInscripto or ( this.lComprobantesAMonotributistas and ;
				tnSituacionFiscalCliente = goregistry.Felino.SituacionFiscalClienteMonotributo )
					llRetorno = .T.
				endif
			case tcLetra  = "B"
				if tnSituacionFiscalCliente != goregistry.Felino.SituacionFiscalClienteInscripto and !( this.lComprobantesAMonotributistas and tnSituacionFiscalCliente = goregistry.Felino.SituacionFiscalClienteMonotributo )
					llRetorno = .T.
				endif
			case tcLetra = "X" or tcLetra = "R"
				llRetorno = .T.		
		endcase
		
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerMontoLimiteComprobante() as Integer
		return 0.00
	endfunc 

	*-----------------------------------------------------------------------------------------
	function MostrarImpuestos() as Boolean
		local llReturn As Boolean

		llReturn = !( ;
					  ( this.nSituacionFiscalEmpresa = this.oSFiscalEmpresa.Inscripto ) and ;
					  ( this.nSituacionFiscalCliente = this.oSFiscal.Inscripto or ;
					  ( this.lComprobantesAMonotributistas and this.nSituacionFiscalCliente = this.oSFiscal.Monotributo ) );
				    )

		return llReturn
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarSituacionFiscalCliente( tnSitFiscal As Integer ) as Boolean
		return this.oSFiscal.ValidarSituacionFiscal( tnSitFiscal )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsItemRelacionadoASenia( toItem as Object ) as Boolean
		return ( toItem.TipoDeItem > 0 )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarCantidadDePercepciones( tnCantidad as Integer ) as boolean
		return .T.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function RecalcularImpuestos( toDetalleComprobante as Detalle of detalle.prg, ;
			toDetalleImpuestos as detalle of detalle.prg ) as Void
		toDetalleImpuestos.Limpiar()
		this.VaciarColeccionDeImpuestos()
		this.EstablecerSiAplicaImpuestosInternosEnColaborador()
		dodefault( toDetalleComprobante, toDetalleImpuestos )
	endfunc

	*-----------------------------------------------------------------------------------------
	function EstablecerSiAplicaImpuestosInternosEnColaborador() as Void
		this.oColaboradorImpuestosInternos.SetearSiAplicaImpuestosInternos()
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function oColaboradorImpuestosInternos_Access() as variant
		if this.lDestroy
		else
			if ( vartype( this.oColaboradorImpuestosInternos ) != "O" or isnull( this.oColaboradorImpuestosInternos ) )
				this.oColaboradorImpuestosInternos = _Screen.zoo.CrearObjeto( "ColaboradorImpuestosInternos" )
				this.oColaboradorImpuestosInternos.SetearSiAplicaImpuestosInternos()
			endif
		endif
		return this.oColaboradorImpuestosInternos
	endfunc
	
	*--------------------------------------------------------------------------------------------------------
	function oPuntosDeVenta_Access() as variant
		if this.lDestroy
		else
			if ( vartype( this.oPuntosDeVenta ) != "O" or isnull( this.oPuntosDeVenta ) )
				this.oPuntosDeVenta = _Screen.zoo.instanciarEntidad( 'PuntosDeVenta' )
			endif
		endif
		return this.oPuntosDeVenta 
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerPuntoDeVenta( tcletra, tctipoComprobante, tcFuncionalidades ) as Void
		local lnRetorno as String
		with this.oPuntosDeVenta
			.cFuncionalidadesEntidad = tcFuncionalidades 
			lnRetorno = .ObtenerPuntoDeVenta( tcletra, tctipoComprobante )
		endwith	
		return lnRetorno 
	endfunc	

	*-----------------------------------------------------------------------------------------
	protected function ObtenerTasaEfectiva( toItem as Din_FACTURAItemFacturadetalle of Din_FACTURAItemFacturadetalle.prg  ) as Float
		local lnRetorno as Float
		lnRetorno = 0
		if this.CalculaImpuestosInternos()
			lnRetorno = toItem.TasaImpuestoInterno
		endif
		return lnRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function SetearPorcentajeDeImpuestos( toItem as Object ) as Void
		dodefault( toItem )
		with this
			.SetearTasaEfectiva( toItem )
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearTasaEfectiva(toItem as Din_FACTURAItemFacturadetalle of Din_FACTURAItemFacturadetalle.prg) as Void
		if this.CalculaImpuestosInternos()
			this.nTasaEfectivaImpuestoInterno = this.ObtenerTasaEfectiva( toItem )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearMontosImpuestos() as Void
		dodefault()
		if this.CalculaImpuestosInternos()
			this.nImporteImpuestoInterno = .ObtenerImporteImpuestoInterno( this.nImporte, this.nTasaEfectivaImpuestoInterno )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerImporteImpuestoInterno( tnImporte as Integer, tnTasaEfectivaImpuestoInterno as Integer ) as Double
		local lnRetorno as Double
		lnRetorno = 0
		if this.CalculaImpuestosInternos() and tnTasaEfectivaImpuestoInterno > 0
			lnRetorno = tnImporte * ( tnTasaEfectivaImpuestoInterno / 100 )
		endif 
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function TotalImpuestos() as Double
		local lnRetorno as Double
		lnRetorno = dodefault()
		if this.CalculaImpuestosInternos()
			lnRetorno = lnRetorno + this.nImporteImpuestoInterno
		endif
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerMontoImpuestoInterno( toItem as Din_FACTURAItemFacturadetalle of Din_FACTURAItemFacturadetalle.prg ) as Double
		local lnRetorno as Double
		lnRetorno = 0
		if vartype( toItem ) = 'O' and !isnull( toItem ) and this.CalculaImpuestosInternos()
			if vartype(toItem.Neto) = 'N' or vartype( toItem.TasaImpuestoInterno ) = 'N'
				lnRetorno = goLibrerias.RedondearSegunMascara( toItem.Neto * toItem.TasaImpuestoInterno / 100 )
			endif
		endif
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AsignarMontoInternoEnItem( toItem as Din_FACTURAItemFacturadetalle of Din_FACTURAItemFacturadetalle.prg ) as Void
		if vartype( toItem ) = 'O' and !isnull( toItem ) and this.CalculaImpuestosInternos()
			toItem.MontoImpuestoInterno = this.ObtenerMontoImpuestoInterno( toItem)
			this.nImporteImpuestoInterno = toItem.MontoImpuestoInterno
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CalculaImpuestosInternos() as Boolean
		local llRetorno as Boolean
		if this.lAccionCancelatoria
			llRetorno = this.nMontoImpuestosInternos > 0
		else
			llRetorno = this.oColaboradorImpuestosInternos.AplicaImpuestosInternos()
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearPrecio( toItem as Object ) as Void
		with toItem
			*.Precio = goLibrerias.RedondearSegunMascara( iif( This.MostrarImpuestos(), .PrecioConImpuestos, .PrecioSinImpuestos ) )
			
			if this.EvaluarSiCorrespondeAplicarLey19640() 
				.Precio = goLibrerias.RedondearSegunMascara( .PrecioSinImpuestos )
			else
				.Precio = goLibrerias.RedondearSegunMascara( iif( This.MostrarImpuestos(), .PrecioConImpuestos, .PrecioSinImpuestos ) )
			endif
		endwith
	endfunc
	 
	*-----------------------------------------------------------------------------------------
	protected function AsignarMontosDeImpuestos( toItem as Object ) as Void
		local	llMuestraImpuestos as boolean, lnCantidad as Float, lnMontoVisualConImpuestos as Float, lnMontoVisualSinImpuestos as Float, ;
				lnMonto as Float, lnNeto as Float, lnBruto as float, lnPorcentajeDescuento as Float, ;
				lnPorcentajeMontoDescuento as Float, lnPorcentajeMontoDescuentoConImpuestos as Float, lnPorcentajeMontoDescuentoSinImpuestos as Float, ;
				lnMontoDescuento as Float, lnMontoDescuentoSinImpuestos as Float, lnMontoDescuentoConImpuestos as Float, ;
				lnPorcentajeMontoDescuentoVisualConImpuestos as Float, lnPorcentajeMontoDescuentoVisualSinImpuestos as Float

		llMuestraImpuestos = this.MostrarImpuestos()
		lnCantidad	= toItem.Cantidad
		lnNeto		= toItem.PrecioSinImpuestos
*		lnBruto	= toItem.PrecioConImpuestos
		if this.EvaluarSiCorrespondeAplicarLey19640()  
			lnBruto		= toItem.PrecioSinImpuestos
		else
			lnBruto		= toItem.PrecioConImpuestos
		endif
		lnMontoVisualConImpuestos = goLibrerias.RedondearSegunMascara( lnBruto )
		lnMontoVisualSinImpuestos = goLibrerias.RedondearSegunMascara( lnNeto )
		lnPorcentajeImpuestos = this.oComponenteImpuestos.ObtenerPorcentajesDeImpuestos( toItem )

		*** Porcentaje de descuento ***
		lnPorcentajeDescuento = toItem.Descuento  && Porcentaje.
		lnPorcentajeMontoDescuentoVisualConImpuestos = ( lnMontoVisualConImpuestos * lnPorcentajeDescuento / 100 ) * lnCantidad
		lnPorcentajeMontoDescuentoVisualSinImpuestos = ( lnMontoVisualSinImpuestos * lnPorcentajeDescuento / 100 ) * lnCantidad
		lnPorcentajeMontoDescuentoConImpuestos = ( lnBruto * lnPorcentajeDescuento / 100 ) * lnCantidad
		lnPorcentajeMontoDescuentoSinImpuestos = ( lnNeto * lnPorcentajeDescuento / 100 ) * lnCantidad
		*** Monto de descuento ***
		lnMontoDescuento				= toItem.MontoDescuento * iif( lnCantidad < 0, -1, 1 )
		lnMontoDescuentoSinImpuestos	= iif( llMuestraImpuestos, lnMontoDescuento / ( 1 + ( lnPorcentajeImpuestos / 100 ) ), lnMontoDescuento )
		lnMontoDescuentoConImpuestos	= iif( llMuestraImpuestos, lnMontoDescuento, lnMontoDescuento * ( 1 + ( lnPorcentajeImpuestos / 100 ) ) )

		*** ASIGNACIONES ***
		with toItem
			.MontoPorcentajeDescuentoConImpuesto = lnPorcentajeMontoDescuentoConImpuestos
			.MontoPorcentajeDescuentoSinImpuesto = lnPorcentajeMontoDescuentoSinImpuestos
			.MontoDescuentoConImpuestos = lnMontoDescuentoConImpuestos
			.MontoDescuentoSinImpuestos	= lnMontoDescuentoSinImpuestos
			
			.Neto	= ( lnNeto * lnCantidad ) - lnPorcentajeMontoDescuentoSinImpuestos - lnMontoDescuentoSinImpuestos 
			.Bruto	= ( lnBruto * lnCantidad ) - lnPorcentajeMontoDescuentoConImpuestos - lnMontoDescuentoConImpuestos

			this.AsignarMontoInternoEnItem( toItem )
			.MontoIVA = .Bruto - .Neto - this.ObtenerMontoImpuestoInterno( toItem )
			.Impuestos = goLibrerias.RedondearSegunMascara( .MontoIVA )

			lnMontoVisualConImpuestos = ( lnMontoVisualConImpuestos * lnCantidad ) - lnPorcentajeMontoDescuentoVisualConImpuestos - lnMontoDescuentoConImpuestos
			lnMontoVisualSinImpuestos = ( lnMontoVisualSinImpuestos * lnCantidad ) - lnPorcentajeMontoDescuentoVisualSinImpuestos - lnMontoDescuentoSinImpuestos
			.Monto = goLibrerias.RedondearSegunMascara( iif( llMuestraImpuestos, lnMontoVisualConImpuestos, lnMontoVisualSinImpuestos ))
			.AjustePorRedondeoSinImpuestos = ( .Neto - goLibrerias.RedondearSegunMascara( lnMontoVisualSinImpuestos  ) )
			.AjustePorRedondeoConImpuestos = ( .Bruto - goLibrerias.RedondearSegunMascara( lnMontoVisualConImpuestos  ) )
			&& Se usan en otro lado
			this.nImporte = .Neto
			this.nImporteIva = .MontoIVA
		endwith
	endfunc 
 
enddefine

