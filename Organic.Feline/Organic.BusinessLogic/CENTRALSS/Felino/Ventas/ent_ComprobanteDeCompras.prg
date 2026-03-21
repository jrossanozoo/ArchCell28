 define class Ent_ComprobanteDeCompras as Ent_Comprobante of Ent_Comprobante.prg

	#if .f.
		local this as Ent_ComprobanteDeCompras of Ent_ComprobanteDeCompras.prg
	#endif

	protected oAtributosObligatorios as zoocoleccion OF zoocoleccion.prg
	
	Codigo = 0
	SubtotalBruto = 0.00
	SubtotalNeto = 0.00
	Descuento = 0
	Impuestos = 0
	PorcentajeDescuento = 0
	SituacionFiscal = 0
	Cotizacion = 0
	Numero = 0
	PuntoDeVenta = 0
	Vuelto = 0	
	FacturaDetalle = 0
	SignoDeMovimiento = 0
	Total = 0
	
	FechaModificacion = {//}
	Fecha = {//}
	
	ListaDePrecios_Pk = ""
	Hora = ""
	cHoraDescuentos = ""
	ListaDePreciosPreferente = ""
	cDetalleComprobante = "FacturaDetalle"
	Letra = ""
	MonedaComprobante_Pk = ""
	SimboloMonetarioComprobante = ""
	cDetalleComprobanteDuplicado = []
	lDuplicadoConCuentaCorriente = .f.
			
	cDescuentoAnterior = 0
	nPorcentajeRecargo1 = 0
	nPorcentajeRecargo2 = 0
	nPorcentajeDeDescuentoAnterior = 0
	nPorcentajeDeDescuento1Anterior = 0
	nPorcentajeDeDescuento2Anterior = 0
	nMontoDescuentoConImpuestos3Anterior = 0
	PorcentajeDescuento3 = 0
	nPorcentajeDeRecargoAnterior = 0
	nRecargoMontoConImpuestos1Anterior = 0
	nRecargoMontoConImpuestos2Anterior = 0

	nRecargoMonto1Anterior = 0
	nRecargoMonto2Anterior = 0
	
	lCalculando = .f.
	lAgregueRecargoDe1Centavo = .f.
	lPermiteAccionesDeAbm = .F.
	lPasoPorKontroler = .F.
	lEliminarComprobantePorFalloDeImpresion = .F.
	lActualizandoSaldos = .f.
	lAvisoPersonalizaciondelComprobante = .F.
	mostrarPercepciones = .F.
	lCancelacionExterna = .F.
	anulado = .F.	
	lAsignandoDescuento = .F.	
	lImprimir = .F.
	lEliminar = .T.
		
	oAtributosObligatorios = null
	ImpuestosDetalle = null
	ImpuestosComprobante = null
	oAtributosAnulacion = null
	Percepcion = null
	oValidacionDominios = null
	ListaDePrecios = null
	oComponenteFiscal = null
	lEsComprobanteElectronico = .F.
	lCambioProveedor = .F.
	proveedor_pk = ""
	oDatosFiscales = null
	oColaboradorRetenciones = null
	SumImpuestos = 0
	ImpuestosManuales = .f.
	proveedor = ""
	lRecalcularPorCambioDeProveedor = .f.
	lCambioMonedaComprobante = .f.

	lComprobanteDebeValidarDevolucionDeArticulo = .F.
	lComprobanteAfectadoDebeValidarDevolucionDeArticulo = .F.
	oPercepciones = null
	
	IvaDelSistema = 0
	lEsEntidadConPuntoDeVentaExtendido = .f.
	
	oColaboradorSireWS = null	
	oSireAModificar = null
	
	nPais = 0
	nMontoDeDescuento3IngresadoManualmente = 0.00	
	nMontoDeRecargo2IngresadoManualmente = 0.00		

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		
		dodefault()		
		if type( "this." + This.cDetalleComprobante ) = "O"
			this.enlazar( This.cDetalleComprobante + ".EventoCambioSub_Monto", "CalcularTotal" )
			
			if type( "this.FacturaDetalle.oItem" ) = "O"
				This.FacturaDetalle.oItem.InyectarListaDePrecios( This.ListaDePrecios )
				This.FacturaDetalle.oItem.cNombreComprobante = this.obtenerNombre()
			endif		
			if type( "this.oCompDescuentos" ) = "O"
				this.oCompDescuentos.InyectarEntidad( this )
				this.enlazar( This.cDetalleComprobante + ".EventoCambioSum_Monto", "AplicarDescuentosPorComponente" )
				this.enlazar( "oCompDescuentos.EventoPreguntarSiAplicaDescuento", "EventoPreguntarSiAplicaDescuento" )
			endif
		endif
		if type( "this.ImpuestosDetalle" ) = "O"
			this.enlazar( "ImpuestosDetalle.Actualizar", "AsignarTotalImpuesto" )
		endif
		if type( "this.ImpuestosComprobante.oItem" ) = "O"
			this.Bindearevento( this.ImpuestosComprobante, "actualizar", this,"AsignarTotalImpuestoComprobante" )
		endif
		this.oComponenteFiscal = _screen.Zoo.CrearObjeto( "ComponenteFiscalcompras", "ComponenteFiscalcompras.prg", this.cComprobante )
		this.oComponenteFiscal.InyectarEntidadPadre( this )
		this.enlazar( "oComponenteFiscal.EventoPreguntarImprimir", "EventoPreguntarImprimir" )
		this.enlazar( "oComponenteFiscal.EventoMensajeControlador", "EventoMensajeControlador" )
		this.enlazar( "oComponenteFiscal.EventoRecalcularImpuestos", "EventoRecalcularImpuestos" )
		this.enlazar( "oComponenteFiscal.EventoObtenerInformacion", "inyectarInformacion" )
		if type( "This.oAD" ) == "O"
			bindevent( this.oAD, "Insertar", this.oComponenteFiscal, "BloquearCF" )
		Endif	
		this.cParametroPreciosNuevoEnBaseA = "goParametros.Felino.GestionDeCompras.NuevoBasadoEn.ActualizarPreciosEnComprobantesNuevosEnBaseACompra"
		if pemstatus( this, "oCompEnBaseA", 5 ) 
			if pemstatus( this.oCompEnBaseA, "InyectarConsulta", 5 )
				bindevent( this.oCompEnBaseA, "InyectarConsulta", this, "CalcularTotal", 1 )				
			endif
		endif
		
		if pemstatus( this, "ValorSugeridoListaDePrecios", 5 )
			bindevent( this, "ValorSugeridoListaDePrecios", this, "EventoValorSugeridoListaDePrecios", 1 )
		endif
		if type( "this.FacturaDetalle" ) = "O"
			this.oPercepciones = this.oComponenteFiscal.ObtenerPercepciones()
		endif
		
		this.nPais = goParametros.Nucleo.DatosGenerales.Pais
		
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoValorSugeridoListaDePrecios() as Void
		with this
			try
				if 	vartype( .Proveedor ) = "O" and !isnull( .Proveedor ) and !empty( .Proveedor.ListaDePrecio_pk ) and !( 'ELECTRONICAEXPORTACION' $ .cComprobante )
					.Listadeprecios_PK = .Proveedor.ListaDePrecio_pk
					.Listadeprecios.Codigo = .Listadeprecios_PK
				endif
			catch
				.Listadeprecios_PK=[]
			endtry 
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function oDatosFiscales_Access() as Void
		if !this.lDestroy and vartype( this.oDatosFiscales ) # "O"
			if !empty( goParametros.Felino.DatosImpositivos.CodigoDeDatoFiscalAUtilizar )
				this.oDatosFiscales = _screen.Zoo.InstanciarEntidad( "DatosFiscales" )
				this.oDatosFiscales.Codigo = alltrim( goParametros.Felino.DatosImpositivos.CodigoDeDatoFiscalAUtilizar )
			endif
		endif
		return this.oDatosFiscales
	endfunc

	*-----------------------------------------------------------------------------------------
	function oColaboradorRetenciones_Access() as Void
		if !this.lDestroy and vartype( this.oColaboradorRetenciones ) # "O"
			this.oColaboradorRetenciones = _screen.Zoo.CrearObjeto( "ColaboradorRetenciones" )
			this.oColaboradorRetenciones.InyectarComprobante( this )
		endif
		return this.oColaboradorRetenciones
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Destroy()
		this.lDestroy = .t.

		if vartype( this.oDatosFiscales ) = "O" and !isnull( this.oDatosFiscales )
			this.oDatosFiscales.lDestroy = .t.
			this.oDatosFiscales.Release()
		endif

		this.oColaboradorRetenciones = null
		dodefault()
	endfunc

	*-----------------------------------------------------------------------------------------	
	function oComponenteFiscal_Assign( toVal ) as Void

		if this.lDestroy 
		else
			this.oComponenteFiscal = toVal
			if type( "this.oComponenteFiscal" ) = "O" and !isnull( this.oComponenteFiscal )
				this.lPermiteAccionesDeAbm = this.oComponenteFiscal.PermiteAccionesDeAbm()
				this.oComponenteFiscal.InyectarImpuestosDetalle( this.ImpuestosDetalle )
				this.oComponenteFiscal.InyectarImpuestosComprobante( this.ImpuestosComprobante )
				this.DespuesDeInicializarElComponenteFiscal()
			endif
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function PermiteAccionesDeAbm() as boolean
		return this.lPermiteAccionesDeAbm
	endfunc 

	*-----------------------------------------------------------------------------------------	
	function AsignarTotalImpuesto() as Void
		if type( "this.ImpuestosDetalle" ) = "O"
			this.Impuestos = goLibrerias.RedondearSegunMascara( This.ImpuestosDetalle.Sum_Montodeiva )
		Endif	
	endfunc 

	*-----------------------------------------------------------------------------------------	
	function Nuevo() as Void
		with this
			.cHoraDescuentos = goLibrerias.ObtenerHora()
			dodefault()
			.SetearMonedaComprobante()
			.oComponenteFiscal.SetearSituacionFiscalProveedor( goRegistry.felino.SituacionFiscalClienteConsumidorFinal )
			.nPorcentajeRecargo1 = 0
			.nPorcentajeRecargo2 = 0
			.SumImpuestos = 0
			.SetearAtributosDeDescuentosYRecargosAnteriores( .t. )
			.SetearListaDePreciosPreferenteOValorSugerido()
			
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function SetearListaDePreciosPreferenteOValorSugerido() as Void
			local lValorComportamiento as String
			
			try
				lValorComportamiento = goServicios.SaltosDeCampoYValoresSugeridos.ObtenerValorSugerido( this.ObtenerNombre(), "", "Listadeprecios" )
			catch
			endtry
			
			if !isnull( lValorComportamiento )
				if !empty( lValorComportamiento )
					this.ListaDePreciosPreferente = &lValorComportamiento 
				endif
			else
				this.ListaDePreciosPreferente = strtran( goParametros.Felino.Precios.ListasDePrecios.ListaDePreciosPreferenteCompras, " ", "" )
			endif
			
			return
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Modificar() as Void
		local llAnuladoAntesDeModificar as boolean, lcCertificadoSire as String, lDebeProcesarCertificadoSire as Boolean	
		
		llAnuladoAntesDeModificar = this.EstaAnulado()
		
		lDebeProcesarCertificadoSIRE = GoParametros.Felino.Interfases.AFIP.RG452319Sire.HabilitarRetenciones and this.TieneRetencionIVA()
		if lDebeProcesarCertificadoSIRE
			lcCertificadoSire = this.oColaboradorSireWS.ObtenerCertificadoSireParaModificacionOP( this.codigo )
			if !empty( lcCertificadoSire ) and pemstatus( this, "oSireAModificar", 5  ) 
				this.oSireAModificar = this.oColaboradorSireWS.ObtenerDatosParaAnularSire( this, lcCertificadoSire )
			endif	
		endif	
		
		dodefault()

		this.oComponenteFiscal.cLetraComprobante = this.Letra
		this.oComponenteFiscal.SetearSituacionFiscalProveedor( This.SituacionFiscal_pk )
		if empty( this.MonedaComprobante_Pk )
			this.SetearMonedaComprobante()
		else
			This.SetearMonedaEnDetalleValores()
		endif

		this.InicializarPreciosDeListaEnArticulos()
		This.LlenarColeccionDeImpuestos()
		if This.TipoComprobante # 98	&& 98-Comprobante de caja
			This.anulado = .F.
			This.FechaModificacion = {//}
		endif 
		this.SetearListaDePreciosPreferenteOValorSugerido()

		if llAnuladoAntesDeModificar 
			this.SetearValoresSugeridosAlModificarAnulado()			
		endif
		
		this.SetearAtributosDeDescuentosYRecargosAnteriores( .f. )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function SetearValoresSugeridosAlModificarAnulado() as Void
		with this
			.lEstaSeteandoValorSugerido = .T.
			.ValorSugeridoTipocomprobante()
			.ValorSugeridoObs()
			.ValorSugeridoFecha()
			.ValorSugeridoNumero()
			.ValorSugeridoProveedor()
			.SetearValoresSugeridosAlModificarAnuladoExclusivosDeCadaEntidad()	
			.lEstaSeteandoValorSugerido = .F.
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function SetearValoresSugeridosAlModificarAnuladoExclusivosDeCadaEntidad() as Void
		if pemstatus( this, "ValorSugeridoPuntodeventa", 5 )		
			.ValorSugeridoLetra()			
			.ValorSugeridoPuntodeventa()			
		endif
		if pemstatus( this, "ValorSugeridoNumint", 5 )
			.ValorSugeridoCondicionpagopreferente()
			.ValorSugeridoListadeprecios()
			.ValorSugeridoFechavtocai()
			.ValorSugeridoRecargoporcentaje()
			.ValorSugeridoRecargomonto2()
			.ValorSugeridoFechafactura()
			.ValorSugeridoPorcentajedescuento()
		endif	
		if pemstatus( this, "ValorSugeridoDistribucionPorCentroDeCosto", 5 )
			.ValorSugeridoDistribucionporcentrodecosto()
		endif
		if pemstatus( this, "ValorSugeridoMotivo", 5 )
			.ValorSugeridoMotivo()
		endif			
		if pemstatus( this, "ValorSugeridoTransportista", 5 )
			.ValorSugeridoTransportista()
		endif
		if pemstatus( this, "ValorSugeridoFechavencimiento", 5 )
			.ValorSugeridoFechavencimiento()
		endif
		if pemstatus( this, "ValorSugeridoCai", 5 )
			.ValorSugeridoCai()
			.ValorSugeridoRemito()
			.ValorSugeridoCentrodecosto()
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearMonedaEnDetalleValores() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearAtributosDeDescuentosYRecargosAnteriores( tlBlanquear as Boolean ) as Void
		if tlBlanquear
			this.nPorcentajeDeDescuentoAnterior = 0
			this.nPorcentajeDeDescuento1Anterior = 0
			this.nPorcentajeDeDescuento2Anterior = 0
			this.nMontoDescuentoConImpuestos3Anterior = 0
			this.cDescuentoAnterior = 0
			this.nPorcentajeDeRecargoAnterior = 0
			this.nRecargoMontoConImpuestos1Anterior = 0
			this.nRecargoMonto1Anterior = 0
			this.nRecargoMonto2Anterior = 0
		else
			this.nPorcentajeDeDescuentoAnterior = this.PorcentajeDescuento
			this.nPorcentajeDeDescuento1Anterior = this.PorcentajeDescuento1
			this.nPorcentajeDeDescuento2Anterior = this.PorcentajeDescuento2
			this.nMontoDescuentoConImpuestos3Anterior = this.MontoDescuentoConImpuestos3
			this.cDescuentoAnterior = this.Descuento
			
			this.nPorcentajeDeRecargoAnterior = this.RecargoPorcentaje
			this.nRecargoMontoConImpuestos1Anterior = this.RecargoMontoConImpuestos1
			this.nRecargoMontoConImpuestos2Anterior = this.RecargoMontoConImpuestos2
			this.nRecargoMonto1Anterior = this.RecargoMonto1
			this.nRecargoMonto2Anterior = this.RecargoMonto2
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function Setear_Cotizacion( txVal as variant ) as void
		dodefault( txVal )
		
		if This.CargaManual() and !empty( txVal ) and txVal != 1 and this.ValidarSiEsComprobanteEnMonedaExtranjera() 
			this.ActualizarCotizacionMoneda( txVal )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ActualizarCotizacion() as Void
		this.SetearCotizacion()
	endfunc

	*-----------------------------------------------------------------------------------------
	function PermiteEmitirMonedaExtranjera() as Boolean
		local llRetorno as Boolean
	
		llRetorno = goparametros.felino.gestionDeCompras.PermiteCargarComprobantesDeCompraEnMonedaExtranjera
		
		return llRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearMonedaEnDetalleValoresParaActualizarCotizacion() as Void		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerFechaDeUltimaCotizacion() as Date
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function DebeCambiarListaDePrecios() as Boolean
		return this.Proveedor.ListaDePrecio.Moneda_Pk = this.MonedaComprobante_Pk and this.lCambioMonedaComprobante
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ProrratearTotalPorItem( toItem as object ) as Void

		with toItem
			.MontoProrrateoTotal = goLibrerias.RedondearSegunMascara( .Neto - .MontoProrrateoDescuentoSinImpuestos + .MontoProrrateoRecargoSinImpuestos + .MontoProrrateoIva + .MontoProrrateoPercepciones )

			if this.FacturaDetalle.oItem.NroItem == .NroItem 
				this.FacturaDetalle.oItem.MontoProrrateoTotal = .MontoProrrateoTotal
			endif
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ProrratearDescuento( toItem as object ) as Void
		local lnDesNeto  as Integer
		
		with toItem
			lnDesNeto = 0
			lnDesNeto = .Neto - ( .Neto * this.PorcentajeDescuento * 0.01 )
			lnDesNeto = lnDesNeto - ( lnDesNeto * this.PorcentajeDescuento1 * 0.01 )
			lnDesNeto = lnDesNeto - ( lnDesNeto * this.PorcentajeDescuento2 * 0.01 )
			.MontoProrrateoDescuentoSinImpuestos = goLibrerias.RedondearSegunMascara( .Neto - lnDesNeto )
			
			lnDesNeto = 0
			lnDesNeto = .Monto - ( .Monto * this.PorcentajeDescuento * 0.01 )
			lnDesNeto = lnDesNeto - ( lnDesNeto * this.PorcentajeDescuento1 * 0.01 )
			lnDesNeto = lnDesNeto - ( lnDesNeto * this.PorcentajeDescuento2 * 0.01 )
			.MontoProrrateoDescuentoConImpuestos = goLibrerias.RedondearSegunMascara( .Monto - lnDesNeto )

			if this.FacturaDetalle.oItem.NroItem == .NroItem 
				this.FacturaDetalle.oItem.MontoProrrateoDescuentoSinImpuestos = .MontoProrrateoDescuentoSinImpuestos 
				this.FacturaDetalle.oItem.MontoProrrateoDescuentoConImpuestos = .MontoProrrateoDescuentoConImpuestos 
			endif			
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ProrratearRecargo( toItem as object ) as Void
		local lnPorcentajeSumarizadoRecargoConImpuestos as Integer, lnPorcentajeSumarizadoRecargoSinImpuestos as Integer, ;
			llMuestraImpuestos as Boolean, lnSumarizadoDescuentoSinImpuestos as Integer 

		with this
			if type( "this.oComponenteFiscal" ) = "O"
				llMuestraImpuestos = .oComponenteFiscal.MostrarImpuestos()  
			else
				llMuestraImpuestos = .f.
			endif
			
			lnSumarizadoDescuentoSinImpuestos = .TotalDescuentosSinImpuestos 
			if .SubtotalBruto - .TotalDescuentos > 0
				lnPorcentajeSumarizadoRecargoConImpuestos = ( .TotalRecargos * 100 ) / ( .SubtotalBruto - .TotalDescuentos )
			else
				lnPorcentajeSumarizadoRecargoConImpuestos = 0 
			endif
			
			if .SubtotalNeto - lnSumarizadoDescuentoSinImpuestos > 0
				lnPorcentajeSumarizadoRecargoSinImpuestos = ( .TotalRecargosSinImpuestos * 100 ) / ( .SubtotalNeto - lnSumarizadoDescuentoSinImpuestos )
			else
				lnPorcentajeSumarizadoRecargoSinImpuestos = 0
			endif
		endwith
		
		with toItem
			.MontoProrrateoRecargoSinImpuestos = goLibrerias.RedondearSegunMascara( ( lnPorcentajeSumarizadoRecargoSinImpuestos * ( iif( llMuestraImpuestos, .Monto - .MontoIva, .Monto ) - .MontoProrrateoDescuentoSinImpuestos ) ) / 100 )
			.MontoProrrateoRecargoConImpuestos = goLibrerias.RedondearSegunMascara( ( lnPorcentajeSumarizadoRecargoConImpuestos * ( iif( llMuestraImpuestos, .Monto, .Monto + .MontoIva ) - .MontoProrrateoDescuentoConImpuestos ) ) / 100 )     			

			if this.FacturaDetalle.oItem.NroItem == .NroItem 
				this.FacturaDetalle.oItem.MontoProrrateoRecargoSinImpuestos = .MontoProrrateoRecargoSinImpuestos 
				this.FacturaDetalle.oItem.MontoProrrateoRecargoConImpuestos = .MontoProrrateoRecargoConImpuestos 
			endif			
		endwith

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ProrratearPercepciones( toItem as object, toPercepciones as number ) as Void
		local lnArticuloNeto  as Integer, lnPorcentajeSumarizadoIIBB, loError as Exception

		lnArticuloNeto = 0
		with toItem
			lnArticuloNeto = .Neto
			lnMontoPercepcionIva = toPercepciones.nPercepcionesIva
			lnMontoPercepcionResto = toPercepciones.nPercepcionesResto
			lnMontoPercepIvaProrrateo = 0
			lnCoeficientePercepcionesResto = iif( this.subtotalneto = 0 or lnArticuloNeto = 0, 0, ( lnArticuloNeto * 100 ) / this.subtotalneto)
			lnMontoPercepSinIvaProrrateo = ( ( lnMontoPercepcionResto ) / 100 ) * lnCoeficientePercepcionesResto
			if toItem.porcentajeiva > 0
				lnSubNetoMenosNoGravado = ( this.subtotalneto - this.ObtenerNoGravado()  )
				lnCoeficientePercepcionesIva = iif(lnSubNetoMenosNoGravado = 0, 0, ( lnArticuloNeto * 100 ) / lnSubNetoMenosNoGravado)
				lnMontoPercepIvaProrrateo = ( lnMontoPercepcionIva  / 100 ) * lnCoeficientePercepcionesIva 
			endif	
			.MontoProrrateoPercepciones = lnMontoPercepIvaProrrateo + lnMontoPercepSinIvaProrrateo
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ProrratearIva( toItem as object ) as Void
		local lnNetoProrrateado as long
		lnNetoProrrateado = 0.00
		lnPorcentajeDeIva = this.ObtenerPorcentajeAplicadoDeIVA( toItem )
		with toItem
			lnNetoProrrateado = .Neto - .MontoProrrateoDescuentoSinImpuestos + .MontoProrrateoRecargoSinImpuestos
			.MontoProrrateoIva = goLibrerias.RedondearSegunMascara( lnNetoProrrateado * ( lnPorcentajeDeIva  * 0.01 ) )
			if this.FacturaDetalle.oItem.NroItem == .NroItem 
				this.FacturaDetalle.oItem.MontoProrrateoIva = .MontoProrrateoIva 
			endif			
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ProrratearItems() as Void
		local lnNroItem as Integer, loItem as Object
		
		*** 13/07/2010 - mrusso
		*** No considera el item activo (cuando el NroItem es igual a 0) ya que se ejecuta ANTES DE GRABAR y todo ya esta aplanado.
		*** En caso de que se ejecute desde otro lado hay que refactorizar teniendo en cuenta que el item activo puede tener info si tiene NroItem = 0
		
		if this.CargaManual() and type( "this.FacturaDetalle" ) = "O"
			loPercepciones = this.ObtenerPercepciones()
			for lnNroItem = 1 to this.FacturaDetalle.count
				loItem = this.FacturaDetalle.Item(lnNroItem)
				this.ProrratearDescuento( loItem )
				this.ProrratearRecargo( loItem )
				this.ProrratearIva( loItem )
				this.ProrratearPercepciones( loItem, loPercepciones )
				this.ProrratearTotalPorItem( loItem )
			endfor
		endif
	endfunc 

    *-----------------------------------------------------------------------------------------
    function ProrratearDescuentoEnDetalle() as Void
        local lnNroItem as Integer, loItem as Object
		if this.CargaManual() and type( "this.FacturaDetalle.oItem" ) = "O"
			with this.FacturaDetalle
				for lnNroItem = 1 to .count
					loItem = .Item[ lnNroItem ]
					if this.FacturaDetalle.oItem.NroItem == loItem.NroItem
						this.ProrratearDescuento( .oItem )				
					else
						this.ProrratearDescuento( loItem )
					endif
				endfor

				if .oItem.NroItem = 0
					**** Esto es porque este método se llama al procesar el item activo, por ende puede ser que se esté cargando un item nuevo
					**** No se pone dentro del FOR ya que el metodo ProrratearDescuento lo actualiza					
					this.ProrratearDescuento( .oItem )				
				endif
			endwith
        endif
    endfunc 
    
    *-----------------------------------------------------------------------------------------
    function ProrratearRecargoEnDetalle() as Void
        local lnNroItem as Integer, loItem as Object
        
        if this.CargaManual() and type( "this.FacturaDetalle.oItem" ) = "O"
        	with this.FacturaDetalle
				for lnNroItem = 1 to .count
					loItem = .Item[ lnNroItem ]
					if this.FacturaDetalle.oItem.NroItem == loItem.NroItem
						this.ProrratearRecargo( .oItem )
					else
						this.ProrratearRecargo( loItem )
					endif
				endfor

				if .oItem.NroItem = 0  
					**** Esto es porque este método se llama al procesar el item activo, por ende puede ser que se esté cargando un item nuevo
					**** No se pone dentro del FOR ya que el metodo ProrratearRecargo lo actualiza
					this.ProrratearRecargo( .oItem )
				endif
			endwith
        endif
    endfunc

	*-----------------------------------------------------------------------------------------
	function SetearFlagRecargoPorCambio( tlEstado as Boolean ) as Void
		With This
			.lAgregueRecargoDe1Centavo = tlEstado 
			if type( "this.oComponenteFiscal" ) = "O"
				this.oComponenteFiscal.lSeAgregoRecargoPorCambio = tlEstado
			endif
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function AntesDeGrabar() As Boolean
		Local llAntesDeGrabar as Boolean, lnTotal as float

		lnTotal = this.Total

		if type( "this.oComponenteFiscal" ) = "O" and type( "this.ImpuestosDetalle" ) = "O" and type( "this.FacturaDetalle" ) = "O" and !This.VerificarContexto( "B" )
			This.oComponenteFiscal.RecalcularImpuestos( this.FacturaDetalle, this.ImpuestosDetalle )
		EndIf	
		this.SetearFlagRecargoPorCambio( .f. )
		if this.EsNuevo() and type( "this.oNumeraciones" ) = 'O'
			if This.VerificarContexto( "C" )
			Else
                if pemstatus(this,"numint",5)
	                this.NUMint = this.oNumeraciones.ObtenerNumero( 'NUMINT' , .F., .T. )
                endif
            endif    
		endif
		llAntesDeGrabar = dodefault()
		if llAntesDeGrabar and !This.VerificarContexto( "B" )
			this.ProrratearItems()
			this.AjustarProrrateo()
		endif

		if This.Total != lnTotal
			if This.Total = 0.01 and lnTotal = 0 and This.lAgregueRecargoDe1Centavo
			Else
				If !this.EstaEnContexto()
					&& Llamar al equipo naranja si alguna vez algun test tira esta excepcion
					goServicios.errores.LevantarExcepcion( "El recálculo de impuestos modificó el total del comprobante." )
				endif
			EndIf	
		endif
		this.ActualizarCotizacion()		
		this.ActualizarPuntoDeVentaExtendidoConPuntoDeVenta()
		Return llAntesDeGrabar
	Endfunc

	*-----------------------------------------------------------------------------------------
	function DespuesDeGrabar() As Boolean
		local llRetorno as Boolean, loError as exception ,loEx as zooexception OF zooexception.prg

		llRetorno = .T.
		try
			llRetorno = dodefault()
		catch to loError
			loEx = Newobject( "ZooException", "ZooException.prg" )
			With loEx
				.Grabar( loError )
				this.CargarInformacion( .Obtenerinformacion() )
			endwith
			llRetorno = .F.
		endtry
		if llRetorno
			This.ObtenerCertificadoSire()
		Else
			This.lEliminarComprobantePorFalloDeImpresion = .F.
			This.EventoPreguntarEliminarComprobantePorFalloDeImpresion( This.ObtenerInformacion() )
			if This.lEliminarComprobantePorFalloDeImpresion
				this.AnularoEliminarComprobanteSinMensajes()
				this.limpiar( .T. )
			endif
			if vartype( goControladorFiscal ) = "O" and !isnull( goControladorFiscal )
				goControladorFiscal.CancelarCF()
			endif
		endif
		return .T.
	endfunc

	*-----------------------------------------------------------------------------------------
	function  ObtenerCertificadoSire() as Void
		local loSire as object, lcCertificadoSire as String, llModificarSiCambiaMonto as Boolean
		loSire = null	

		lDebeProcesarCertificadoSIRE = GoParametros.Felino.Interfases.AFIP.RG452319Sire.HabilitarRetenciones and this.TieneRetencionIVA()

		if this.cComprobante = "ORDENDEPAGO" and lDebeProcesarCertificadoSIRE 
			if ( this.EsEdicion() or this.EstaAnulado() ) and ( pemstatus( this, "oSireAModificar", 5  ) and vartype ( this.oSireAModificar ) == "O" )
				this.oColaboradorSireWS.AnularCertificadoSIREWS( this.oSireAModificar ) 
				this.oSireAModificar = null
			endif

			if !this.EstaAnulado()
				loSire = this.oColaboradorSireWS.ObtenerDatosParaSire( this )
				lcCertificado = this.oColaboradorSireWS.ObtenerCertificadoSIREWS( loSire ) 
				this.oColaboradorSireWS.ActualizarTablaCRIMPDETParaSIRE( lcCertificado, this.codigo )
				loSire = null
			endif	
		endif

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function oColaboradorSireWS_Access()as Object	
		if !this.lDestroy and vartype( this.oColaboradorSireWS ) # "O" Or Isnull(this.oColaboradorSireWS )
			this.oColaboradorSireWS = _Screen.zoo.crearobjeto( "ColaboradorSireWS", "ColaboradorSireWS.prg" )
		endif
		Return this.oColaboradorSireWS

	endfunc

	*-----------------------------------------------------------------------------------------
	function MostrarMensajesDeSistema() as string
		local lcRetorno as String
		lcRetorno = ""
		if type( "this.oComponenteFiscal" ) = "O"
			lcRetorno = this.oComponenteFiscal.ChequearCorrectaInicializacion() 
		Endif
		return lcRetorno
	endfunc	

	*-----------------------------------------------------------------------------------------
	function EventoPreguntarEliminarComprobantePorFalloDeImpresion( toInformacion as ZooInformacion of ZooInformacion.Prg ) as Void
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoPreguntarImprimir( tnRespuestaSugerida as Integer ) as Void
		&&Evento para suscribirse desde el kontroler
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Validar() as boolean
		local llRetorno as boolean, lcAtributoPuntoVta as string
		llRetorno = dodefault()
		llRetorno = llRetorno and this.ValidarExistenciaDeComprobanteAntesDeGrabar( This.Proveedor_Pk, This.Letra, This.PuntoDeVenta, This.Numero )
        lcAtributoPuntoVta = iif(this.lEsEntidadConPuntoDeVentaExtendido,"PUNTODEVENTAEXTENDIDO","PUNTODEVENTA")
        
        if !this.ElAtributoEsObligatorio( lcAtributoPuntoVta )
			if !This.ValidarPuntoDeVenta()
				llRetorno = .F.
			endif
		endif

		if This.ValidarTotales()
		else
			this.AgregarInformacion( "Problemas con el total del comprobante", 1 )
			llRetorno = .F.
		endif
				
		llRetorno = llRetorno and This.ValidarCantidadItems()
		llRetorno = llRetorno and this.ValidarVueltoSegunTipoValor()
		
		if type( "this.oComponenteFiscal" ) = "O" and !isnull( this.oComponenteFiscal )
			if This.VerificarContexto( "CB" )
			else 
				if this.cComprobante != "FACTURADECOMPRA"
					this.SetearDatosFiscalesComprobante()
				endif 
			endif 

			if This.VerificarContexto( "CB" ) or this.oComponenteFiscal.ValidarFechaComprobanteFiscal( this.Fecha )
			else
				this.AgregarInformacion( "La fecha del comprobante no coincide con la fecha del controlador fiscal", 1 )
				llRetorno = .F.
			endif 

			if this.oComponenteFiscal.ValidarItemsDetalleArticulos( this.FacturaDetalle )
			else
				this.AgregarInformacion( "Problema con los artículos", 1 )
				llRetorno = .F.
			endif
		endif
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------		
	function ValidarPuntoDeVenta() as boolean
		local llRetorno as boolean

		llRetorno = dodefault()

		if !this.ElAtributoEsObligatorio( "PUNTODEVENTA" ) and this.nPais != 3
			if  pemstatus(this, "TipoComprobanteRG1361", 5 ) and inlist( this.TipoComprobanteRG1361, 1, 3 ) and empty( this.Letra ) and this.PuntoDeVenta >= 0
			else
				if this.PuntoDeVenta > 0
				else
					this.AgregarInformacion( "Debe cargar el campo Punto de venta.", 9005, "PuntoDeVenta" )
					llRetorno = .F.
				endif
			endif
		endif

		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function ValidarTotales() As boolean
		Local llRetorno As boolean, lnTotalFactura As Float

		llRetorno = dodefault()

		With This
			lnTotalFactura = goLibrerias.RedondearSegunMascara( .Total )
			If lnTotalFactura < 0
				this.agregarInformacion( "El total del comprobante no puede ser negativo." )
				llRetorno = .F.
			Endif
		Endwith

		Return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EventoPreguntarEliminar( ) as Void
		&&Evento para suscribirse desde el kontroler
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ValidarAntesDeAnular() As Boolean
		Local llRetorno as Boolean

		llRetorno = dodefault()

		if llRetorno
			this.VotacionCambioEstadoANULAR( This.ObtenerEstado() )
			llRetorno = !This.HayInformacion()
		endif

		Return llRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	function actualizarEstado() as Void
		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarCantidadItems() As Boolean
		Local llRetorno As boolean, llCantItemsEnCero as Boolean, loItem as Object

		llRetorno = dodefault()

		if type( "This.FacturaDetalle" ) == "O"
			llCantItemsEnCero = .t.

			for each loItem in this.FacturaDetalle
				if empty( loItem.articulo_pk )
				else
					llCantItemsEnCero = .f.
					exit
				endif
			endfor
			
			if llCantItemsEnCero
				this.AgregarInformacion( "Debe agregar por lo menos un articulo al comprobante" )
				llRetorno = .F.
			EndIf
		EndIf
		Return llRetorno	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AntesDeAnular() as Void
		dodefault()
		this.RestaurarStock()
	endfunc

	*-----------------------------------------------------------------------------------------
	function LanzarEventoPreguntarAnular() as Void
		local lnPais as Integer 
		lnPais = goParametros.Nucleo.DatosGenerales.Pais

		with this
			do case
			case lnPais = 1
				.EventoPreguntarAnular( iif( empty( .Letra ), "", .Letra + " " ) + iif( empty( .PuntoDeVenta ), "", transform( .PuntoDeVenta, "@LZ 9999" ) + "-" ) + transform( .Numero, "@LZ 99999999" ) )

			case lnPais = 2
				.EventoPreguntarAnular( transform( .Numero ) )

			otherwise
				.EventoPreguntarAnular( "" )

			endcase
		endwith
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function EsModificacionDeUsuario() as Boolean
		return ( this.EsNuevo() or this.EsEdicion() ) and this.CargaManual()
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoRecalcularImpuestos() as Void
		&& Para que se enganche alguien
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoNotificarEstadoImpuestosManuales( tlImpuestosManuales as Boolean ) as Void
		&& Para que se enganche alguien
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function Setear_Impuestosmanuales( txVal as variant ) as void
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerValorClavePrimaria() as Variant
		local lxRetorno as Variant, lcEjecutar as String
		
		lcEjecutar = "this." + alltrim( this.cAtributoPK )
		lxRetorno = &lcEjecutar
		return lxRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CalcularTotal() as Float
		local llMuestraImpuestos as Boolean, loError as Object, lnDescuentos as Integer, lnRecargos as Integer, ;
				lnSubTotalNeto as Long, lnSubTotalBruto as Long, lnTotal as Long
		lnDescuentos = 0
		
		if !this.lCalculando
			this.lCalculando = .t.		
			llMuestraImpuestos = .T.
			if type( "this.oComponenteFiscal" ) = "O"
				llMuestraImpuestos = This.oComponenteFiscal.MostrarImpuestos()
			endif
			
			if type( "this.FacturaDetalle" ) = "O" and this.CargaManual()				
				with this
					try

						lnSubTotalBruto = .FacturaDetalle.Sum_Monto + iif( llMuestraImpuestos, 0, .ImpuestosDetalle.Sum_MontoDeIvaSinDescuento )
						.SubTotalBruto = goLibrerias.RedondearSegunMascara( lnSubTotalBruto )
						
						lnSubTotalNeto = .FacturaDetalle.Sum_Monto - iif( llMuestraImpuestos, .ImpuestosDetalle.Sum_MontoDeIvaSinDescuento, 0 )
						.SubTotalNeto  = goLibrerias.RedondearSegunMascara( lnSubTotalNeto )

						.Recalcular()

						if llMuestraImpuestos
							lnDescuentos = .Descuento + .MontoDescuentoConImpuestos1 + .MontoDescuentoConImpuestos2 + .MontoDescuentoConImpuestos3
						else
							lnDescuentos = .MontoDescuentoSinImpuestos + .MontoDescuentoSinImpuestos1 + .MontoDescuentoSinImpuestos2 + .MontoDescuentoSinImpuestos3
						endif

						this.ProrratearDescuentoEnDetalle() &&Aplicar performance, solo prorratear cuando se esta aplicando descuento o quitando uno.
						
						if llMuestraImpuestos
							lnRecargos = .RecargoMontoConImpuestos + .RecargoMontoConImpuestos1 + .RecargoMontoConImpuestos2
						else
							lnRecargos = .RecargoMontoSinImpuestos + .RecargoMontoSinImpuestos1 + .RecargoMontoSinImpuestos2
						endif
						this.ProrratearRecargoEnDetalle() &&Aplicar performance, solo prorratear cuando se esta aplicando Recargo o quitando uno.

						.SumarImpuestos()
						if llMuestraImpuestos
							lnTotal = .FacturaDetalle.Sum_Monto - lnDescuentos + lnRecargos + .SumImpuestos
						else
							lnTotal = .SubtotalNeto - lnDescuentos + lnRecargos + .Impuestos + .SumImpuestos	
							&&.Impuestos contiene el iva del recargo y del descuento.
						endif
						.Total = goLibrerias.RedondearSegunMascara( lnTotal )
						.TotalImpuestos = .SumImpuestos
					catch to loError
						goServicios.Errores.LevantarExcepcion( loError )
					finally 
						this.lCalculando = .f.						
					endtry
				endwith
			endif
			
			this.lCalculando = .f.
		endif 
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function SumarImpuestos()
		local i as Integer, lcPropiedad as String
		this.SumImpuestos = 0

		for i =  1 to this.ImpuestosComprobante.count
			this.SumImpuestos = this.SumImpuestos + this.ImpuestosComprobante.Item[i].Monto
		endfor
	endfunc

	*-----------------------------------------------------------------------------------------
	function Setear_percepcion( txVal ) as Void
		dodefault( txVal )
		if this.CargaManual()
			this.CalcularTotal()
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearDatosFiscalesComprobante() as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Validar_Descuento( txVal as Variant ) as Boolean
		local llRetorno as Boolean
		llRetorno = .f.
		if this.CargaManual() and ( !empty(txVal) ) and ( this.cDescuentoAnterior != txVal )
			llRetorno = dodefault( txVal )
		else
			llRetorno = dodefault( txVal )
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Validar_PorcentajeDescuento( txVal as Variant ) as Boolean
		local llRetorno as Boolean
		llRetorno = .f.

		if this.nPorcentajeDeDescuentoAnterior == txVal
			&&No se ejecuta el Setear ya que el valor es igual al Anterior.	
		else
			if this.CargaManual()
				if txVal > 100
					goServicios.Errores.LevantarExcepcion( "No se puede asignar un porcentaje de descuento mayor a 100." ) 
				else
					if ( !empty(txVal) ) and  ( txVal >= 0 ) and ( this.nPorcentajeDeDescuentoAnterior < txVal )
						if txVal < 0
						else
							if this.PedirSeguridadParaAplicarDescuentos()
								llRetorno = dodefault( txVal )
							endif
						endif
					else
						if txVal >= 0
							llRetorno = dodefault( txVal )
						endif
					endif
				endif
			endif
		endif
		
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Validar_PorcentajeDescuento1( txVal as Variant ) as Boolean
		local llRetorno as Boolean
		llRetorno = .f.
		if this.nPorcentajeDeDescuento1Anterior == txVal
			&&No se ejecuta el Setear ya que el valor es igual al Anterior.
		else
			if this.CargaManual() and ( !empty(txVal) ) and ( this.nPorcentajeDeDescuento1Anterior < txVal ) and  ( txVal >= 0 )
				if txVal < 0
				else
					if this.PedirSeguridadParaAplicarDescuentos()
						llRetorno = dodefault( txVal )
					endif
				endif
			else
				if txVal >= 0
					llRetorno = dodefault( txVal )
				endif
			endif
		endif

		return llRetorno	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Validar_PorcentajeDescuento2( txVal as Variant ) as Boolean
		local llRetorno as Boolean
		llRetorno = .f.
		
		if this.nPorcentajeDeDescuento2Anterior == txVal
			&&No se ejecuta el Setear ya que el valor es igual al Anterior.
		else
			if this.CargaManual() and ( !empty(txVal) ) and ( this.nPorcentajeDeDescuento2Anterior < txVal ) and  ( txVal >= 0 )			
				if this.PedirSeguridadParaAplicarDescuentos()
					llRetorno = dodefault( txVal )
				endif
			else
				if txVal >= 0
					llRetorno = dodefault( txVal )
				endif
			endif
		endif
		return llRetorno	
	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	function Setear_PorcentajeDescuento1( txPorcentajeDescuento as variant ) as Void
		local lcSumMonto as String, loError as Object
		
		with this
			dodefault( txPorcentajeDescuento )
			if .CargaManual()
				.PorcentajeDescuento1 = txPorcentajeDescuento
				.nPorcentajeDeDescuento1Anterior = txPorcentajeDescuento
				if type( "this.FacturaDetalle" ) = "O"
					if !.lAsignandoDescuento
						.lAsignandoDescuento = .T.
						lcSumMonto = "this.FacturaDetalle.Sum_Monto" 
						try
							.MontoDescuentoConImpuestos1 = ( .PorcentajeDescuento1 * &lcSumMonto ) / 100
						catch to loError
							goServicios.Errores.LevantarExcepcion( loError )
						finally
							.lAsignandoDescuento = .F.
						endtry
					endif
				endif
			endif
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Setear_Descuento( txVal as variant ) as void 
		dodefault( txVal )

		if this.CargaManual()
			this.cDescuentoAnterior = txVal
			with this
				.ActualizarDescuentosYRecargosEnComponenteFiscal()
				.CalcularTotal()
			endwith
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function Setear_MontoDescuentoConImpuestos1( txVal as variant ) as void
		dodefault( txVal )
		with this
			if .CargaManual()
				.ActualizarDescuentosYRecargosEnComponenteFiscal()
				.CalcularTotal()
			endif
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function Setear_PorcentajeDescuento2( txPorcentajeDescuento as variant ) as Void
		local lcSumMonto as String, loError as Object
		
		with this
			dodefault( txPorcentajeDescuento )
			if .CargaManual()
				.PorcentajeDescuento2 = txPorcentajeDescuento
				.nPorcentajeDeDescuento2Anterior = txPorcentajeDescuento
				if type( "this.FacturaDetalle" ) = "O"
					if !.lAsignandoDescuento
						.lAsignandoDescuento = .T.
						lcSumMonto = "this.FacturaDetalle.Sum_Monto" 
						try
							.MontoDescuentoConImpuestos2 = ( .PorcentajeDescuento2 * &lcSumMonto ) / 100
						catch to loError
							goServicios.Errores.LevantarExcepcion( loError )
						finally
							.lAsignandoDescuento = .F.
						endtry
					endif
				endif
			endif
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Setear_MontoDescuentoConImpuestos2( txVal as variant ) as void &&&&& Esto hace andar los descuentos y recargos
		dodefault( txVal )
		with this
			if .CargaManual()
				.ActualizarDescuentosYRecargosEnComponenteFiscal()
				.CalcularTotal()
			endif
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function PedirSeguridadParaAplicarDescuentos() as Boolean
		local llRetorno as Boolean
		llRetorno = .f.
		
		llRetorno = goServicios.Seguridad.PedirAccesoEntidad( this.ObtenerNombre(), "DESCUENTOCOMPROBANTE" )
		if !llRetorno
			goServicios.Errores.LevantarExcepcion( "No posee permisos para ingresar un descuento." )	
		endif
				
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Validar_MontoDescuentoConImpuestos3( txVal as variant ) as Boolean
		local llRetorno as Boolean
		llRetorno = .f.
		
		if this.nMontoDescuentoConImpuestos3Anterior == txVal
			&&No se ejecuta el Setear ya que el valor es igual al Anterior.
		else
			if this.CargaManual() and ( !empty(txVal) ) and ( this.nMontoDescuentoConImpuestos3Anterior < txVal ) and  ( txVal >= 0 )			
				if this.PedirSeguridadParaAplicarDescuentos()
					llRetorno = dodefault( txVal )
				endif
			else
				if txVal >= 0
					llRetorno = dodefault( txVal )
				endif
			endif
		endif

		return llRetorno	
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Setear_MontoDescuentoConImpuestos3( txVal as variant ) as void &&&&& Esto hace andar los descuentos y recargos
		dodefault( txVal )

		with this
			if .CargaManual()
				.nMontoDescuentoConImpuestos3Anterior = txVal
				.ActualizarDescuentosYRecargosEnComponenteFiscal()
				.CalcularTotal()
			endif
		endwith
	endfunc	

	*-----------------------------------------------------------------------------------------
	function Setear_RecargoPorcentaje( txPorcentajeRecargo as variant ) as Void
		dodefault( txPorcentajeRecargo )
		if this.CargaManual()
			this.nPorcentajeDeRecargoAnterior = txPorcentajeRecargo
			this.ActualizarRecargoEnDetalle()
			this.CalcularTotal()
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function PedirSeguridadParaAplicarRecargos() as Boolean
		local llRetorno as Boolean
		llRetorno = .t.
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Validar_RecargoPorcentaje( txVal, lxValOld ) as Boolean
		local llRetorno as Boolean
		llRetorno = .f.
		
		if this.nPorcentajeDeRecargoAnterior == txVal
			&&No se ejecuta el Setear ya que el valor es igual al Anterior.	
		else
			if this.CargaManual() and ( !empty(txVal) ) and ( this.nPorcentajeDeRecargoAnterior < txVal ) and  ( txVal >= 0 )
				if txVal < 0
				else
					if this.PedirSeguridadParaAplicarRecargos()
						llRetorno = dodefault( txVal )
					endif
				endif
			else
				if txVal >= 0
					llRetorno = dodefault( txVal )
				endif
			endif
		endif	
		return llRetorno	
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Setear_RecargoMonto2( txValor as variant ) as Void
		dodefault( txValor )
		if this.CargaManual()
			this.nRecargoMonto2Anterior = txValor 
			this.ActualizarRecargoEnDetalle()
			this.CalcularTotal()
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Validar_RecargoMonto2( txVal, lxValOld ) as Boolean
		local llRetorno as Boolean
		llRetorno = .f.
		
		if this.nRecargoMonto2Anterior == txVal
			&&No se ejecuta el Setear ya que el valor es igual al Anterior.	
		else
			if this.CargaManual() and ( !empty(txVal) ) and ( this.nRecargoMonto2Anterior < txVal ) and  ( txVal >= 0 )
				if txVal < 0
				else
					if this.PedirSeguridadParaAplicarRecargos()
						llRetorno = dodefault( txVal )
					endif
				endif
			else
				if txVal >= 0
					llRetorno = dodefault( txVal )
				endif
			endif
		endif
		if llRetorno 
			llRetorno = llRetorno and This.ValidacionRecargoMonto2( txVal )	
		endif
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Recalcular() as VOID
		local llMuestraImpuestos as Boolean
		llMuestraImpuestos = .t.
		
		with this
			if .CargaManual()
				.RecalcularDescuentos()
				.RecalcularRecargos()
				if type( "this.oComponenteFiscal" ) = "O"
					llMuestraImpuestos = This.oComponenteFiscal.MostrarImpuestos()
				Endif			
				.CalcularSubTotal( llMuestraImpuestos )
			endif
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CalcularSubTotal( tlMuestraImpuestos as Boolean ) as Void
		dodefault()
	endfunc	
	
	*-----------------------------------------------------------------------------------------
	function RecalcularDescuentos() as Void
		local loError as Object, lnSubTotal as Integer, lnSubTotalSinImpuestos as Integer, llMuestraImpuesto as Boolean 

		lnSubTotalSinImpuestos = 0
		lnSubTotal = 0
		llMuestraImpuesto = .f.

		with this
			if type( "this.FacturaDetalle" ) = "O"
				try	
					
					if type( "this.oComponenteFiscal" ) = "O"
						llMuestraImpuesto = .oComponenteFiscal.MostrarImpuestos()  
					endif
					
					************ CON IMPUESTOS **************
					***Descuento 1*** 
					lnSubTotal = iif( llMuestraImpuesto ,this.SubtotalBruto,this.SubtotalNeto )&&
					.Descuento = ( .PorcentajeDescuento * lnSubTotal ) / 100
					
					***Descuento 2*** 
					lnSubTotal = lnSubTotal - .Descuento
					.MontoDescuentoConImpuestos1 = ( .PorcentajeDescuento1 * lnSubTotal ) / 100
			
					***Descuento 3*** 
					lnSubTotal = ( lnSubTotal - .MontoDescuentoConImpuestos1 )
					.MontoDescuentoConImpuestos2 = ( .PorcentajeDescuento2 * lnSubTotal ) / 100
					
					***Descuento 4*** 
					lnSubTotal = ( lnSubTotal - .MontoDescuentoConImpuestos2 )
					.PorcentajeDescuento3 = iif( lnSubTotal == 0, 0, .MontoDescuentoConImpuestos3 * 100 / lnSubTotal )					
					
					***Redondeamos Montos de descuento
					.Descuento = goLibrerias.RedondearSegunMascara( .Descuento )
					.MontoDescuentoConImpuestos1 = goLibrerias.RedondearSegunMascara( .MontoDescuentoConImpuestos1 )
					.MontoDescuentoConImpuestos2 = goLibrerias.RedondearSegunMascara( .MontoDescuentoConImpuestos2 )
					.MontoDescuentoConImpuestos3 = goLibrerias.RedondearSegunMascara( .MontoDescuentoConImpuestos3 )
										
					************ SIN IMPUESTOS **************
					***Descuento 1*** 
					lnSubTotalSinImpuestos = ( this.SubTotalNeto )
					.MontoDescuentoSinImpuestos = ( .PorcentajeDescuento * lnSubTotalSinImpuestos ) / 100
					
					***Descuento 2*** 
					lnSubTotalSinImpuestos = ( lnSubTotalSinImpuestos - this.MontoDescuentoSinImpuestos )
					.MontoDescuentoSinImpuestos1 = ( .PorcentajeDescuento1 * lnSubTotalSinImpuestos ) / 100
					
					***Descuento 3*** 
					lnSubTotalSinImpuestos = ( lnSubTotalSinImpuestos - this.MontoDescuentoSinImpuestos1 )
					.MontoDescuentoSinImpuestos2 = ( .PorcentajeDescuento2 * lnSubTotalSinImpuestos ) / 100
					
					***Descuento 4*** 
					lnSubTotalSinImpuestos = ( lnSubTotalSinImpuestos - this.MontoDescuentoSinImpuestos2 )					
					.MontoDescuentoSinImpuestos3 = ( .PorcentajeDescuento3 * lnSubTotalSinImpuestos ) / 100
										

					***Redondeamos Montos de descuento
					.MontoDescuentoSinImpuestos = goLibrerias.RedondearSegunMascara( .MontoDescuentoSinImpuestos )
					.MontoDescuentoSinImpuestos1 = goLibrerias.RedondearSegunMascara( .MontoDescuentoSinImpuestos1 )
					.MontoDescuentoSinImpuestos2 = goLibrerias.RedondearSegunMascara( .MontoDescuentoSinImpuestos2 )
					.MontoDescuentoSinImpuestos3 = goLibrerias.RedondearSegunMascara( .MontoDescuentoSinImpuestos3 )	
			
					
					******** Totalizadores
					.TotalDescuentos = goLibrerias.RedondearSegunMascara( .Descuento + .MontoDescuentoConImpuestos1 + .MontoDescuentoConImpuestos2 + .MontoDescuentoConImpuestos3 )
					.TotalDescuentosSinImpuestos = goLibrerias.RedondearSegunMascara( .MontoDescuentoSinImpuestos + .MontoDescuentoSinImpuestos1 + .MontoDescuentoSinImpuestos2 + .MontoDescuentoSinImpuestos3 )

					this.RecalcularImpuestosPorCambioDeNeto()

				catch to loError
					goServicios.Errores.LevantarExcepcion( loError )
				endtry
			endif
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function RecalcularRecargos()
	Local lnSubTotal As Integer, loError As Object, lnSubTotalSinImpuestos As Integer

	lnSubTotal = 0
	lnSubTotalSinImpuestos = 0
	With This
		If Type( "this.FacturaDetalle" ) = "O"
			Try

				************ Visual **************
				lnSubTotalVisual = Iif( .oComponenteFiscal.MostrarImpuestos(), .SubTotalBruto - .TotalDescuentos , .SubTotalNeto - .TotalDescuentosSinImpuestos )
				.RecargoMonto = ( .RecargoPorcentaje * lnSubTotalVisual ) / 100

				lnSubTotalVisual = ( lnSubTotalVisual + .RecargoMonto )
				.nPorcentajeRecargo1 = Iif( lnSubTotalVisual = 0, 0, .RecargoMonto1 * 100 / lnSubTotalVisual )

				lnSubTotalVisual = ( lnSubTotalVisual + .RecargoMonto1 )
				.nPorcentajeRecargo2 = Iif( lnSubTotalVisual = 0, 0, .RecargoMonto2 * 100 / lnSubTotalVisual )


				************ CON IMPUESTOS **************
				***Recargo 1***
				lnSubTotal = .FacturaDetalle.Sum_Monto - .TotalDescuentos
				.RecargoMontoConImpuestos = ( .RecargoPorcentaje * lnSubTotal ) / 100

				***Recargo 2***
				lnSubTotal = lnSubTotal + .RecargoMontoConImpuestos
				.nPorcentajeRecargo1 = Iif( lnSubTotal = 0, 0, ( .RecargoMontoConImpuestos1 * 100 ) / lnSubTotal )

				***Redondeamos Montos de Recargo
				.RecargoMontoConImpuestos = goLibrerias.RedondearSegunMascara( .RecargoMontoConImpuestos )

				***Recargo 3***  && AGREGADO
				lnSubTotal = ( lnSubTotal + .RecargoMontoConImpuestos1 )
				.RecargoMontoConImpuestos2 = ( .nPorcentajeRecargo2 * lnSubTotal ) / 100


				************ SIN IMPUESTOS **************
				***Recargo 1***
				lnSubTotalSinImpuestos = This.SubTotalNeto - .TotalDescuentosSinImpuestos
				.RecargoMontoSinImpuestos = ( .RecargoPorcentaje * lnSubTotalSinImpuestos ) / 100

				***Recargo 2***
				lnSubTotalSinImpuestos = lnSubTotalSinImpuestos + .RecargoMontoSinImpuestos
				.RecargoMontoSinImpuestos1 = ( .nPorcentajeRecargo1 * lnSubTotalSinImpuestos ) / 100

				***Recargo 3***
				lnSubTotalSinImpuestos = ( lnSubTotalSinImpuestos + .RecargoMontoSinImpuestos1  )
				.RecargoMontoSinImpuestos2 = ( .nPorcentajeRecargo2 * lnSubTotalSinImpuestos ) / 100


				If ( .RecargoMontoSinImpuestos1 == 0 ) And ( .RecargoMontoConImpuestos1 == 0.01 )
					.RecargoMontoSinImpuestos1 = 0.01
				Endif

				***Redondeamos Montos de Recargo
				.RecargoMontoSinImpuestos = goLibrerias.RedondearSegunMascara( .RecargoMontoSinImpuestos )
				.RecargoMontoSinImpuestos1 = goLibrerias.RedondearSegunMascara( .RecargoMontoSinImpuestos1 )
				.RecargoMontoSinImpuestos2 = goLibrerias.RedondearSegunMascara( .RecargoMontoSinImpuestos2 )

				******** Totalizadores
				.TotalRecargos = goLibrerias.RedondearSegunMascara( .RecargoMontoConImpuestos + .RecargoMontoConImpuestos1 + .RecargoMontoConImpuestos2  )
				.TotalRecargosSinImpuestos = goLibrerias.RedondearSegunMascara( .RecargoMontoSinImpuestos + .RecargoMontoSinImpuestos1 + .RecargoMontoSinImpuestos2 )

				This.RecalcularImpuestosPorCambioDeNeto()

			Catch To loError
				goServicios.Errores.LevantarExcepcion( loError )
			Endtry
		Endif
	Endwith

	Endfunc

	*-----------------------------------------------------------------------------------------
	function RecalcularImpuestosPorCambioDeNeto()
		if type( "this.FacturaDetalle" ) = "O"
			this.oComponenteFiscal.RecalcularImpuestosPorCambioDeNeto( this.SubTotalNeto, this.FacturaDetalle )
		endif 
	endfunc	

	*-----------------------------------------------------------------------------------------
	function ActualizarRecargoEnDetalle() as Void		
		local lnMonto as Integer
		with this
			if ( .FacturaDetalle.Sum_Monto # 0 ) or ( .EstaAplicandoRecargosODescuentos() )
				.oComponenteFiscal.AplicarRecargoGlobal( .RecargoPorcentaje, .ImpuestosDetalle )
				.oComponenteFiscal.AplicarRecargoGlobal3( .nPorcentajeRecargo2, .ImpuestosDetalle )
			endif

		endwith
	endfunc		
	
	*-----------------------------------------------------------------------------------------
	function EstaAplicandoRecargosODescuentos() as Boolean
		local llRetorno as Boolean
			llRetorno = this.SeAplicoRecargos() or this.SeAplicoDescuentos()
		return llRetorno		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SeAplicoRecargos() as Boolean
		local lnRetorno as Boolean
		lnRetorno = .f.
		with this
			lnRetorno = .RecargoMontoConImpuestos > 0 or .RecargoMontoConImpuestos1 > 0 or .RecargoMontoConImpuestos2 > 0 
		endwith
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SeAplicoDescuentos() as Boolean
		local lnRetorno as Boolean
		lnRetorno = .f.		
		with this
			lnRetorno = .Descuento > 0 or .MontoDescuentoConImpuestos1 > 0 or .MontoDescuentoConImpuestos2 > 0 ;
						or .MontoDescuentoConImpuestos3 > 0 
		endwith
		return lnRetorno					
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ActualizarDescuento() as Void
		local lcSumMonto as String, loError as Object

		dodefault()
		with this
			if type( "this.FacturaDetalle" ) = "O"
				.lAsignandoDescuento = .T.
				try
					if .PorcentajeDescuento # 0
						.DescuentoSinImpuestos = ( .PorcentajeDescuento * .FacturaDetalle.Sum_Neto ) / 100
					else
						if .Descuento # 0
							if .FacturaDetalle.Sum_Neto # 0
								lnPorcentaje = .PorcentajeDescuento
								.DescuentoSinImpuestos = ( lnPorcentaje * .FacturaDetalle.Sum_Neto ) / 100
							else
								.DescuentoSinImpuestos = 0
							endif
						endif 
					endif
				catch to loError
					goServicios.Errores.LevantarExcepcion( loError )
				finally
					.lAsignandoDescuento = .F.
				endtry
			EndIf
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ActualizarDescuentosYRecargosEnComponenteFiscal() as Void		
		with this
			if .TieneImpuestosManuales()
			else
				if type( "this.oComponenteFiscal" ) = "O"
					.oComponenteFiscal.AplicarDescuentoGlobal( .PorcentajeDescuento, .ImpuestosDetalle )
					.oComponenteFiscal.AplicarDescuentoGlobal2( .PorcentajeDescuento1, .ImpuestosDetalle )
					.oComponenteFiscal.AplicarDescuentoGlobal4( .PorcentajeDescuento3, .ImpuestosDetalle )
					.oComponenteFiscal.AplicarRecargoGlobal( .RecargoPorcentaje, .ImpuestosDetalle )
					.oComponenteFiscal.AplicarRecargoGlobal3( .nPorcentajeRecargo2, .ImpuestosDetalle )
				endif
			endif
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Setear_Impuestos( txVal as variant ) as void
		dodefault( txVal )
		if this.CargaManual()
			this.CalcularTotal()
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Setear_PorcentajeDescuento( txPorcentajeDescuento as variant ) as Void
		local loError as Object

		with this
			dodefault( txPorcentajeDescuento )
			if .CargaManual()
				.PorcentajeDescuento = txPorcentajeDescuento
				.nPorcentajeDeDescuentoAnterior = txPorcentajeDescuento
				if type( "this.FacturaDetalle" ) = "O"
					if !.lAsignandoDescuento
						.lAsignandoDescuento = .T.
						try
							.Descuento = goLibrerias.RedondearSegunMascara( ( .PorcentajeDescuento * this.SubTotalNeto ) / 100 )
							.MontoDescuentoSinImpuestos = goLibrerias.RedondearSegunMascara( ( .PorcentajeDescuento * this.SubTotalNeto ) / 100 )
						catch to loError
							goServicios.Errores.LevantarExcepcion( loError )
						finally
							.lAsignandoDescuento = .F.
						endtry
					endif
				EndIf
				.SetearFlagDescuentoAutomatico()
			endif
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function LlenarColeccionDeImpuestos() as Void
		local lnMonto as Integer
		lnMonto = 0
		with This
			if type( "this.FacturaDetalle" ) = "O"
				.ImpuestosDetalle.nPorcentajeDescuentoGlobal = .PorcentajeDescuento
				.ImpuestosDetalle.nPorcentajeDescuentoGlobal2 = .PorcentajeDescuento1
				.ImpuestosDetalle.nPorcentajeRecargoGlobal = .RecargoPorcentaje
				.ImpuestosDetalle.nPorcentajeRecargoGlobal3 = .nPorcentajeRecargo2
				if type( "this.oComponenteFiscal" ) = "O" 
					.oComponenteFiscal.LlenarColeccionDeImpuestos( .FacturaDetalle )
				Endif			
			endif
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AnularoEliminarComprobanteSinMensajes( tlEliminar as Boolean ) as Void
		local loEntidad as entidad OF entidad.prg, loError as Exception
		
		loEntidad = _Screen.zoo.instanciarEntidad( This.cNombre )

		with loEntidad
			try
				.Codigo = ""
				.Letra = This.Letra
				.PuntoDeVenta = This.PuntoDeVenta
				.Numero = This.Numero
				.TipoComprobante = This.TipoComprobante
				.Buscar()
				.Cargar()
				if .EstaAnulado()
				else
					.lAnular = .T.
					.Anular()
				endif
				if tlEliminar
					.lEliminar = .T.
					.Eliminar()
				endif 
			catch to loError
				goServicios.Errores.LevantarExcepcion( loError )
			finally
				.Release()
			endtry
		EndWith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoCancelar() as Void
		&& Para que se cuelgue el Kontroler
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Setear_ListaDePrecios( txVal as variant ) as void
		dodefault( txVal )
		if this.CargaManual()
			This.RecalcularPorCambioDeListaDePrecios( txVal )
			this.EventoCambioListaDePrecios()
			this.lCambioListaPrecios = .f.
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function ExisteComprobante( tcProveedor as String, tcLetra as String, tnPuntoDeVenta as Integer, tnNumero as Integer ) as Boolean  
		local llRetorno as Boolean ,lcXML as String, lcSql as String, lcGUID as String, lcCursor as String, llValidarLetra as Boolean
		llRetorno = .f.
		lcGUID = this.Codigo
		lcCursor = sys( 2015 )
		llValidarLetra = iif( pemstatus( this, "TipoComprobanteRG1361", 5 ) and this.TipoComprobanteRG1361 = 3 , .t., !empty( tcLetra ) )
		this.lDuplicadoConCuentaCorriente = .f.
		if !empty( tcProveedor ) and !empty( tnPuntoDeVenta ) and !empty( tnNumero ) and llValidarLetra
			lcSql = "proveedor = '" + rtrim( upper( tcProveedor ) ) + "' and Letra = '" + ;
				alltrim( upper( tcLetra ) ) + "' and numero = " + alltrim( transform( tnNumero ) ) + ;
				 " and puntodeventa = " + alltrim( transform( tnPuntoDeVenta ) )
			lcXML = this.oAd.Obtenerdatosentidad( "proveedor, letra, puntodeventa, numero, codigo, numint", lcSql ,"" )
			this.XmlACursor( lcXML , lcCursor )
			if reccount( lcCursor ) = 0			
			else
				if reccount( lcCursor ) > 1
					this.cDetalleComprobanteDuplicado = "los números internos: "
				else
					this.cDetalleComprobanteDuplicado = "el número interno "
				endif 	
				select ( lcCursor )
				scan 
					if &lcCursor..codigo != lcGUID 
						this.cDetalleComprobanteDuplicado = this.cDetalleComprobanteDuplicado + transform( &lcCursor..numint, "@LZ 9999999999" ) + ", "
						if this.DuplicadoFuePagadoEnCuentaCorriente( &lcCursor..codigo )
							this.lDuplicadoConCuentaCorriente = .t.
						endif 					 	
						llRetorno = .t.
					endif 
				endscan 
				this.cDetalleComprobanteDuplicado = left( this.cDetalleComprobanteDuplicado, len( this.cDetalleComprobanteDuplicado ) - 2 )				
			endif
			use in select( lcCursor )
		endif

		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ExisteComprobanteUruguay( tcProveedor as String, tcLetra as String, tnNumero as Integer ) as Boolean  
		local llRetorno as Boolean ,lcXML as String, lcSql as String, lcGUID as String, lcCursor as String, llValidarLetra as Boolean
		llRetorno = .f.
		lcGUID = this.Codigo
		lcCursor = sys( 2015 )
		llValidarLetra = iif( pemstatus( this, "TipoComprobanteRG1361", 5 ) and this.TipoComprobanteRG1361 = 3 , .t., !empty( tcLetra ) )
		this.lDuplicadoConCuentaCorriente = .f.
		if !empty( tcProveedor ) and !empty( tnNumero ) and llValidarLetra
			lcSql = "proveedor = '" + rtrim( upper( tcProveedor ) ) + "' and Letra = '" + ;
				alltrim( upper( tcLetra ) ) + "' and numero = " + alltrim( transform( tnNumero ) ) 
				
			lcXML = this.oAd.Obtenerdatosentidad( "proveedor, letra, numero, codigo, numint", lcSql ,"" )
			this.XmlACursor( lcXML , lcCursor )
			if reccount( lcCursor ) = 0			
			else
				if reccount( lcCursor ) > 1
					this.cDetalleComprobanteDuplicado = "los números internos: "
				else
					this.cDetalleComprobanteDuplicado = "el número interno "
				endif 	
				select ( lcCursor )
				scan 
					if &lcCursor..codigo != lcGUID 
						this.cDetalleComprobanteDuplicado = this.cDetalleComprobanteDuplicado + transform( &lcCursor..numint, "@LZ 9999999999" ) + ", "
						if this.DuplicadoFuePagadoEnCuentaCorriente( &lcCursor..codigo )
							this.lDuplicadoConCuentaCorriente = .t.
						endif 					 	
						llRetorno = .t.
					endif 
				endscan 
				this.cDetalleComprobanteDuplicado = left( this.cDetalleComprobanteDuplicado, len( this.cDetalleComprobanteDuplicado ) - 2 )				
			endif
			use in select( lcCursor )
		endif

		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function DuplicadoFuePagadoEnCuentaCorriente( tcCodigoComprobante as String ) as Boolean 
		return .f.
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarExistenciaDeComprobanteAntesDeGrabar( tcProveedor as String, tcLetra as String, tnPuntoDeVenta as Integer, tnNumero as Integer ) as Void
		return .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function PagadoConCuentaCorriente() as Boolean	
		return .f.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarExistenciaDeComprobante( tcProveedor as String, tcLetra as String, tnPuntoDeVenta as Integer, tnNumero as Integer ) as Void
		local lcMensajeAdvertencia as String, llNoPermitirFacturasRepetidas as Boolean, llNoPermitirRemitosRepetidos as Boolean, lnPais as Integer , llExistecomprobante as Boolean
        
		llNoPermitirFacturasRepetidas = goParametros.Felino.GestionDeCompras.NoPermitirElIngresoDeFacturasDeCompraRepetidas	
		llNoPermitirRemitosRepetidos = goParametros.Felino.GestionDeCompras.NoPermitirElIngresoDeRemitosDeCompraRepetidos	
        lnPais = goParametros.Nucleo.DatosGenerales.Pais 
        if lnPais = 3
              llExistecomprobante = this.ExisteComprobanteUruguay( tcProveedor, tcLetra, tnNumero )  
        else
              llExistecomprobante = this.ExisteComprobante( tcProveedor, tcLetra, tnPuntoDeVenta, tnNumero )
        
        endif
		if  llExistecomprobante
		
			if ( llNoPermitirFacturasRepetidas and this.tipocomprobante = 8 ) or ( llNoPermitirRemitosRepetidos and this.tipocomprobante = 40 )
				goServicios.Errores.LevantarExcepcion( "El comprobante ya fue registrado anteriormente y por lo tanto no puede ser ingresado." )
				llRetorno = .f.
			else
				lcMensajeAdvertencia = "El Comprobante " + tcLetra + " " + transform( tnPuntoDeVenta, "@LZ 9999" ) + "-" + transform( tnNumero, "@LZ 99999999" ) + " del Proveedor " + alltrim( tcProveedor ) 
				if this.lDuplicadoConCuentaCorriente
					this.cDetalleComprobanteDuplicado = this.cDetalleComprobanteDuplicado + ". Atención: No podrá ser grabado si se incluyen valores del tipo cuenta corriente con fecha de vencimiento igual a los ya grabados en el comprobante anterior."
				else 
					this.cDetalleComprobanteDuplicado = this.cDetalleComprobanteDuplicado + "."					
				endif 
			endif
			
			lcMensajeAdvertencia = lcMensajeAdvertencia + " ya fué registrado anteriormente bajo " + this.cDetalleComprobanteDuplicado
			this.oMensaje.Advertir( lcMensajeAdvertencia, 0 )
		endif
		return .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Validar_Letra( txVal ) as Boolean
		local llRetorno as Boolean
		llRetorno =	dodefault( txVal ) and ;
				this.ValidarLetraDelComprobante( txVal ) and ;
				This.ValidarExistenciaDeComprobante( This.Proveedor_Pk, txVal, This.PuntoDeVenta, This.Numero )

		if llRetorno
			This.oComponenteFiscal.cLetraComprobante = txVal
		endif
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function Validar_Numero( txVal ) as Boolean
		Return dodefault( txVal ) and This.ValidarExistenciaDeComprobante( This.Proveedor_Pk, This.Letra, This.PuntoDeVenta, txVal )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Validar_PuntoDeVenta( txVal ) as Boolean
		Return dodefault( txVal ) and This.ValidarExistenciaDeComprobante( This.Proveedor_Pk, This.Letra, txVal, This.Numero )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarLetraDelComprobante( txVal as Variant ) as Boolean
		local lcLetrasValidas as String
		lcLetrasValidas = This.oComponenteFiscal.ObtenerLetrasValidas( upper( alltrim( This.ObtenerNombre() ) ) )
		if ( !empty( txVal ) or ( empty( txVal ) and inlist( upper( alltrim( This.ObtenerNombre() ) ), "FACTURADECOMPRA", "NOTADECREDITOCOMPRA" ) ) ) And ; 
			!( upper( alltrim( txVal ) ) $ lcLetrasValidas )
			goServicios.Errores.LevantarExcepcion( "La letra ingresada no es válida." )
		endif
		return .T.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Validar_ListaDePrecios( txVal, txValOld ) as Boolean
		local llRetorno as Boolean
		llRetorno = dodefault( txVal, txValOld )
		
 		if llRetorno
			if this.lProcesando
			else
				if empty( this.ListaDePrecios.Moneda_PK ) or upper( alltrim ( this.ListaDePrecios.Moneda_PK ) ) = upper( alltrim ( this.MonedaComprobante_PK ) )
					try
						this.ValidarLetraDelComprobante( this.Letra )
					catch to loError
						this.ListaDePrecios_PK = ""  
						this.ListaDePrecios.Codigo = ""  
						goServicios.Errores.LevantarExcepcion( loError )
					Endtry
				else
					llRetorno = .f.
					goServicios.errores.LevantarExcepcion( "La moneda de la Lista de Precios no puede ser diferente a la moneda del comprobante." )
				endif
			endif
		endif

		this.lCambioListaPrecios = !( txVal == txValOld )
		this.lRecalcularPorCambioDeListaDePrecios = this.lCambioListaPrecios

		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function RecalcularPorCambioDeListaDePrecios( txVal as Variant ) as Void
		if This.lRecalcularPorCambioDeListaDePrecios
			if this.ImpuestosManuales
				this.MostrarAdvertenciaRecalculoPrecios()
				this.RestaurarCalculoAutomaticoDeImpuestos()
			endif
			dodefault( txVal )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------	
	protected function DeboImprimir() as Boolean
		local llDeboImprimir as Boolean
		llDeboImprimir = dodefault()
		if type( "this.oComponenteFiscal" ) = "O"
			llDeboImprimir = this.oComponenteFiscal.deboImprimir()
		endif
		return llDeboImprimir	
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoCambioListaDePrecios() as Void
		*** Evento para poder informar cambio de lista de precios para que se refresque la parte visual.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function eventoMensajeControlador( tcTexto as String ) as Void
		***este evento esta enlazado al componentefiscal, y de esta el kontroler para terminar haciendo un goMensajes.enviarSinEspera()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoErrorAlObtenerNumeracionDeServicio( tcServicio as String ) as Void
		*** Evento para poder informar que hubo un problema al obtener numeraciones de un servicio.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoHayComprobantesAsociados() as Void
		*** Evento para saber si tiene que cancelar cuando el comprobante tiene otros comprobantes asociados.
	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	function EventoFallaDeValidacionEnComponenteEnBaseA( toInformacion as ZooInformacion of ZooInformacion.prg ) as Void
		*** Evento para advertir la falla de la validacion de nuevo en base a.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function eventoPersonalizarComprobante( toInformacion as ZooInformacion of zooInformacion.Prg ) as Void
		* Avisa que hay que personalizar el comprobante. 
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function LimpiarFlag() as Void
		This.lAvisoPersonalizaciondelComprobante = .f.
		this.lCambioProveedor = .f.
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarVueltoEnCaja() as boolean
		return .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarVueltoSegunTipoValor() as boolean
		return .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AplicarDescuentosPorComponente() as Void
		if this.EsNuevo() and !this.lLimpiando
			this.oCompDescuentos.AplicarDescuentos( this.Fecha, this.FacturaDetalle.Sum_Monto, this.cHoraDescuentos )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoPreguntarSiAplicaDescuento(  ) as Void
		** Se dispara cuando el componente de descuentos pregunta si debe aplicar o no
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function Setear_Fecha( txVal as variant ) as void 
		dodefault( txVal )
		
		if this.CargaManual()
			this.AplicarDescuentos()
			if pemstatus( this, "cotizacion", 5 ) and !empty( this.MonedaComprobante_pk ) && and !this.lCargando
				this.SetearCotizacion()
			endif
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AplicarDescuentos() as Void
		if type( "this.oCompDescuentos" ) = "O" 
			this.AplicarDescuentosPorComponente()
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearFlagDescuentoAutomatico() as Void
		if vartype( this.oCompDescuentos ) = "O"

			with this.oCompDescuentos
				if  vartype( .oDescuentoAplicado ) = "O" and ;
					(( .oDescuentoAplicado.Porcentaje != 0 and this.PorcentajeDescuento = .oDescuentoAplicado.Porcentaje ) or ;
					( .oDescuentoAplicado.Porcentaje = 0 and this.Descuento = .oDescuentoAplicado.Monto ))
				
					this.DescuentoAutomatico = .t.
				else
					this.DescuentoAutomatico = .f.
				endif
			endwith
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function EventoDespuesDeCargarEnBaseA() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ErrorAlGrabar() as Void
		if type( "this.oComponenteFiscal" ) = "O"
			This.oComponenteFiscal.ErrorAlGrabar()
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AplicaPercepciones() as boolean
		return .f.
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function AjustarProrrateo()
		local i as Integer, lnMayor as String, lnTotal as Integer, lnDiferencias as Integer,;
			lcAtributoItem as String, lcAtributoEntidad as String, x as Integer, lnDiferencia as Integer 
		local array aAtributos( 7,2 )
			
		if type( "this.FacturaDetalle" ) = "O"
			********* VER COMO HACERLO MAS LINDO	
			aAtributos( 1,1 ) = "MontoProrrateoDescuentoConImpuestos"
			aAtributos( 1,2 ) = "TotalDescuentos"
			
			aAtributos( 2,1 ) = "MontoProrrateoDescuentoSinImpuestos"
			aAtributos( 2,2 ) = "TotalDescuentosSinImpuestos"
			
			aAtributos( 3,1 ) = "MontoprorrateoRecargoConImpuestos"
			aAtributos( 3,2 ) = "TotalRecargos"

			aAtributos( 4,1 ) = "MontoprorrateoRecargoSinImpuestos"
			aAtributos( 4,2 ) = "TotalRecargosSinImpuestos"

			aAtributos( 5,1 ) = "MontoProrrateoIva"
			aAtributos( 5,2 ) = "Impuestos"

			aAtributos( 6,1 ) = "MontoprorrateoPercepciones"
			aAtributos( 6,2 ) = "TotalImpuestos"

			aAtributos( 7,1 ) = "MontoProrrateoTotal"
			aAtributos( 7,2 ) = "Total"
			********* VER COMO HACERLO MAS LINDO

			lnMayor = this.ItemMayorNeto()
			if lnMayor > 0						
				for x = 1 to alen( aAtributos, 1 )	
					lnTotal = 0
					lcAtributoEntidad = "this." + aAtributos( x,2 )
					lcAtributoItem = "this.FacturaDetalle.Item(i)." + aAtributos( x,1 )
					for i = 1 to this.FacturaDetalle.Count
						lnTotal = lnTotal + &lcAtributoItem
					endfor
					lnDiferencia = &lcAtributoEntidad  - lnTotal
					if &lcAtributoEntidad > 0 and lnDiferencia # 0
						this.AjustarItem( lnMayor, aAtributos( x,1 ), lnDiferencia )
					endif
				endfor
			endif
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AjustarItem( tnItem as Integer, tcPropiedad as String, tnDiferencia as Integer )
		if tnDiferencia # 0
			this.FacturaDetalle.Item(tnItem).&tcPropiedad = this.FacturaDetalle.Item(tnItem).&tcPropiedad + tnDiferencia
		endif 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ItemMayorNeto() as Integer
		local lnRetorno as Integer, i as Integer, lnValor as Integer
		
		lnRetorno = 0
		lnValor = 0

		for i = 1 to this.FacturaDetalle.Count
			if this.FacturaDetalle.Item(i).PrecioSinImpuestos > lnValor
				lnValor = this.FacturaDetalle.Item(i).PrecioSinImpuestos
				lnRetorno = i
			endif
		endfor	
		
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarRecargo( tnValor as Long ) as Void
	*	this.RecargoMontoConImpuestos1 = this.RecargoMontoConImpuestos1 + tnValor
		this.RecargoMonto2 = this.RecargoMonto2 + tnValor
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function DebeSetearListaDePrecio( txCodigoProveedor ) as Boolean
		local llRetorno as Boolean
		llRetorno = .f.
		if !empty( txCodigoProveedor )
			if pemstatus( this, "oCompEnBaseA", 5 ) 
				if ( This.oCompEnBaseA.cCodigoProveedorAfectado # txCodigoProveedor ) and ( !empty( This.Proveedor.ListaDePrecio_PK ) and vartype(This.Proveedor.ListaDePrecio_PK) = "C" )
					llRetorno = .t.
				endif
			else
				if !empty( This.Proveedor.ListaDePrecio_PK )
					llRetorno = .t.
				endif 
			endif
		endif

		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoErrorValidaciondeListaDePrecio()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function DespuesDeInicializarElComponenteFiscal() as Void
		if type( "this.FacturaDetalle" ) = "O" and !isnull( this.FacturaDetalle )
			if type( "this.FacturaDetalle.oItem" ) = "O" and !isnull( this.FacturaDetalle.oItem )
				**Es necesario el ISNULL porque el null es tipo "O" y lo puse en dos if, porque sino se evalua igual a pesar de que la primer patte del and de .f.
				This.FacturaDetalle.oItem.InyectarComponenteFiscal( this.oComponenteFiscal )
			endif
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AsignarTotalImpuestoComprobante() as Void
		local lnImpuestos as Integer 

		lnImpuestos = this.ObtenerTotalImpuestos()
		this.total = this.SubtotalNeto + this.impuestos + lnImpuestos - this.TotalDescuentosSinImpuestos + this.TotalRecargosSinImpuestos
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerTotalImpuestos() as integer
		local lnRetorno as Integer, lnI as Integer 
		lnRetorno = 0

		for lnI = 1 to this.ImpuestosComprobante.count
			if this.ImpuestosComprobante.oItem.NroItem != lnI
				lnRetorno = lnRetorno + this.ImpuestosComprobante.Item[ lnI ].Monto	
			endif
		endfor 
		lnRetorno = lnRetorno + this.ImpuestosComprobante.oItem.Monto
		return lnRetorno		
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ElAtributoEsObligatorio( tcAtributo as String ) as Boolean
		local llRetorno as Boolean, lcAtributo as String 
		llRetorno = .f.
		if isnull( this.oAtributosObligatorios ) or vartype( this.oAtributosObligatorios ) != "O"
			this.oAtributosObligatorios = this.obtenerAtributosObligatorios()
		endif
		
		for each lcAtributo in this.oAtributosObligatorios foxobject
			if upper( lcAtributo ) == upper( tcAtributo )
				llRetorno = .t.
			endif
		endfor
		
		return llRetorno
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function Validar_Situacionfiscal( txval as variant, txValOld as variant ) as Boolean
		local llRetorno as Boolean, lcMensaje as String
		this.lCambioSituacionFiscal = .f.
		llRetorno = dodefault( txVal, txValOld  )

		if llRetorno and !empty( txVal ) and type( "this.oComponenteFiscal" ) = "O" 
			if llRetorno and !empty( txVal ) and type( "this.oComponenteFiscal" ) = "O" and This.VerificarContexto( "B" )
				this.oComponenteFiscal.SetearSituacionFiscalProveedor( txVal )
			endif
			if this.oComponenteFiscal.ValidarSituacionfiscalParaUnProveedor( txVal )
				try
					this.ValidarLetraDelComprobante( this.Letra )
					this.oComponenteFiscal.SetearSituacionFiscalProveedor( txVal )
					this.lCambioSituacionFiscal = .t.
					if this.lCambioSituacionFiscal
						this.MostrarAdvertenciaRecalculoPrecios()
						this.lCambioSituacionFiscal = .f.
						this.ActualizarDetalleArticulos()
						this.RecalcularImpuestosDetalleArticulos()
					endif
				catch to loError
					this.Proveedor_pk = ""
					this.Proveedor.Codigo = ""
					goServicios.Errores.LevantarExcepcion( loError )
				Endtry
			else
				this.Proveedor_pk = ""
				this.Proveedor.Codigo = ""
				lcMensaje = 'La situación fiscal del proveedor es inválida para el ingreso de '
				lcMensaje = lcMensaje + this.ArmarMensajeSegunTipoComprobanteRG1361()
				goServicios.errores.LevantarExcepcion( lcMensaje )
			endif
		endif

		return llRetorno 
	endfunc
		
	*-----------------------------------------------------------------------------------------
	function ArmarMensajeSegunTipoComprobanteRG1361() as String
		local lcRetorno as String		
		
		lcRetorno = ''
		if inlist(this.tipocomprobante, 8, 9, 10) &&FC,ND,NC
			do case
				case this.tipocomprobanterg1361 = 1
					lcRetorno = 'una ' + lower(alltrim( this.cdescripcion )) + ' manual.'
				case this.tipocomprobanterg1361 = 2
					lcRetorno = 'una ' + lower(alltrim( this.cdescripcion )) + ' electrónica.'
				case this.tipocomprobanterg1361 = 3
					lcRetorno = 'una ' + lower(alltrim( this.cdescripcion )) + ' fiscal.'
				case this.tipocomprobanterg1361 = 4
					lcRetorno = 'un comprobante de despacho de importación.'
				case this.tipocomprobanterg1361 = 5
					lcRetorno = 'un comprobante de liquidaciones A.'
				case this.tipocomprobanterg1361 = 6
					lcRetorno = 'un comprobante de liquidaciones B.'
				case this.tipocomprobanterg1361 = 7
					lcRetorno = 'un comprobante de liquidaciones de servicios públicos A.'
				case this.tipocomprobanterg1361 = 8
					lcRetorno = 'un comprobante de liquidaciones de servicios públicos B.'
				otherwise
					lcRetorno = 'un comprobante de compra.'
			endcase
		else
			lcRetorno = 'un comprobante de ' + lower(alltrim( this.cdescripcion )) + '.'
		endif 
		
		return lcRetorno
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function Validar_Proveedor( txVal as variant, txValOld as variant ) as Boolean
		local llRetorno as Boolean, loError as Exception
		Try
			llRetorno = dodefault( txVal, txValOld )
			if llRetorno
				this.lCambioProveedor = ( alltrim( txValOld ) # alltrim( txVal ) )
				this.lRecalcularPorCambioDeProveedor = ( alltrim( txValOld ) # alltrim( txVal ) )
			endif
			if llRetorno and this.lCambioProveedor
				llRetorno = This.ValidarExistenciaDeComprobante( txVal, This.Letra, This.PuntoDeVenta, This.Numero )
			endif			
			if llRetorno and pemstatus( this.proveedor, "odesactivador", 5 )	
				This.Proveedor.oDesactivador.ValidarEstadoActivacion( txVal, txValOld, this.lnuevo, this.ledicion) 
			endif
			llValorOldEsValido = iif( vartype( this.proveedor )== "O" and alltrim( txValOld ) == alltrim( this.proveedor.codigo ), .t., .f. )
			if llValorOldEsValido
				llRetorno = llRetorno and alltrim( txValOld ) != alltrim( txVal ) 	
			endif

		catch to loError
			this.Proveedor_pk = ""
			this.Proveedor.Codigo = ""
			goServicios.Errores.LevantarExcepcion( loError )
		endtry
		return llRetorno
	endfunc	
	
	*-----------------------------------------------------------------------------------------
	function Cargar() as Boolean
		local llRetorno as Boolean
		llRetorno =	dodefault()
		this.SetearMonedaEnDetalleValores()
		return llRetorno
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function Setear_Proveedor( txVal as variant ) as void
		local llProcesando as Boolean
		
		if This.CargaManual()
			dodefault( txVal )
			try
				llProcesando = this.lProcesando		
				this.lProcesando = .t.
				this.SetearDatosPreferentesDelProveedorSeleccionado( txVal )
			catch to loError
				throw loError
			finally
				this.lProcesando = llProcesando 
			endtry 
			this.EventoSetear_Proveedor( txVal )

			this.lCambioProveedor = .f.
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function SetearListaDePrecioPorCambioDeProveedor( tcListaDePrecios as String ) as Void
		local loError as Object, llcarga as Boolean  
		if upper(alltrim( this.ListaDePrecios_PK )) != upper(alltrim( tcListaDePrecios )) 

			try
				this.ListaDePrecios_PK = tcListaDePrecios
				this.eventoActualizaColorListaDePrecio( .t. )
			catch to loError
				llcarga = this.lCargando
				this.lCargando = .t.
				this.ListaDePrecios_PK = tcListaDePrecios
				this.lCargando = llCarga
				this.eventoActualizaColorListaDePrecio( .f. )
			finally
			endtry
		endif 
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function eventoActualizaColorListaDePrecio( tlExiste ) as Void
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerListaDePreciosValidoDelProveedor( txVal as Variant ) as String
		local lcListaDePrecios as String
 
 		if this.VerificarContexto( "B" )
 			lcListaDePrecios = ""
 		else
			lcListaDePrecios = this.ListaDePreciosPreferente &&this.listadeprecios_pk
		endif

		if this.DebeSetearListaDePrecio( txVal ) 
			if this.ExisteEnEntidadForanea( this.Proveedor, "ListaDePrecio" )
				lcListaDePrecios = this.Proveedor.ListaDePrecio_PK
			else
				if goParametros.Felino.Precios.ListasDePrecios.AlertarPorCambioALaListaDefaultCuandoLaListaPreferenteDelProveedorEsInexistente
					this.agregarInformacion( "El código de Lista de precios del alta del proveedor no existe." )
				endif
			endif			
		endif
		
		return lcListaDePrecios
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearDatosPreferentesDelProveedorSeleccionado( tcProveedor as String ) as Void
		local lcListaDePrecios as String
		
		if this.lCambioProveedor and pemstatus( this, "CondicionPagoPreferente_PK", 5 )
			if empty( this.Proveedor.CondicionDePago_PK )
				this.CondicionPagoPreferente_PK = ""
			else
				if this.ExisteEnEntidadForanea( this.Proveedor, "CondicionDePago" )
					this.CondicionPagoPreferente_PK = this.Proveedor.CondicionDePago_PK
				else
					this.AgregarInformacion( "El código de condición de pago preferente del alta del proveedor no existe." )
				endif
			endif 	
		endif
		
		if this.lCambioProveedor and !this.HayBasadoEn()
			lcListaDePrecios = this.ObtenerListaDePreciosValidoDelProveedor( tcProveedor )
			this.SetearListaDePrecioPorCambioDeProveedor( lcListaDePrecios )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoSetear_Proveedor( txVal as Variant ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ExisteEnEntidadForanea( toEntidad as entidad OF entidad.prg, tcAtributo as String ) as Boolean
		local llRetorno as Boolean, lcAtributoPkEntidadForanea as String, loSubEntidad as entidad OF entidad.prg, ;
			lcEvaluate as String, lcAtributoPk as String
		llRetorno = .f.
		try
			lcEvaluate = "toEntidad." + tcAtributo + "_pk"
			if !empty( evaluate( lcEvaluate ) )
				lcEvaluate = "toEntidad." + tcAtributo
				loSubEntidad = &lcEvaluate
				if vartype( loSubEntidad ) == "O" and !isnull( loSubEntidad )
					lcAtributoPk = loSubEntidad.ObtenerAtributoClavePrimaria()
					lcAtributoPk = evaluate( "loSubEntidad." + lcAtributoPk )
					if !empty( lcAtributoPk ) 
						llRetorno = .t.
					endif
				endif
			endif
		catch
		endtry	
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function EsComprobanteM() as Boolean
		return ( this.Letra = "M" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function RecalcularPorPrePantalla( toItemsCargados as ZooColeccion OF ZooColeccion.prg ) as Void
		local lnNroItem as Integer, lnI as Integer 
		
		for lnI = 1 to toItemsCargados.Count
			lnNroItem = toItemsCargados.Item[lnI]
			this.FacturaDetalle.oItem.oCompPrecios.ObtenerPrecio( this.FacturaDetalle.Item[ lnNroItem ], this.ListaDePrecios_PK )
		endfor

		this.RecalcularPreciosDeDetallesAdicionales( this.ListaDePrecios_PK )
		if type( "This.oComponenteFiscal" ) = "O"
			This.oComponenteFiscal.RecalcularImpuestos( this.FacturaDetalle, this.ImpuestosDetalle )
			This.CalcularTotal()
		EndIf	

	endfunc

	*-----------------------------------------------------------------------------------------
	protected function MostrarAdvertenciaRecalculoPrecios() as VOID
		 if this.DebeMostrarAdvertenciaRecalculoPrecios()
			this.oMensaje.Advertir( this.ObtenerMensajeAdvertenciaRecalculoPrecios(), 0 )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerMensajeAdvertenciaRecalculoPrecios() as String
		local lcMensaje as String, lcSituacionFiscal as String, lcListaP as String, lcReactivarCalculoAutomatico as String, loProveedor as String

		if this.lRecalcularPorCambioDeProveedor
			loProveedor = '- Proveedor.' + chr(13) + chr(10)
			this.lRecalcularPorCambioDeProveedor = .f.
		else
			loProveedor = ''
		endif
		
		if this.lCambioSituacionFiscal
			lcSituacionFiscal = "- Situación fiscal del proveedor." + chr(13) + chr(10)
		else
			lcSituacionFiscal = ""
		endif
		
		if this.lCambioListaPrecios
			lcListaP = "- Lista de precios." + chr(13) + chr(10)
		else
			lcListaP = ""
		endif

		if this.TieneImpuestosManuales()
			lcReactivarCalculoAutomatico = ' El cálculo de IVA que estaba manualmente volverá al estado automático. '
		else
			lcReactivarCalculoAutomatico = ''
		endif

		text to lcMensaje textmerge noshow pretext 1+2
			Atención se detectaron los siguientes cambios: 
			<<chr( 9 )>><< loProveedor >><<chr( 9 )>><< lcSituacionFiscal >><<chr( 9 )>><< lcListaP >>
			Los precios ingresados manualmente se establecerán en cero y los que provienen de lista de precios se recalcularán.<<lcReactivarCalculoAutomatico>> 
			Verifique que los importes sean los esperados.
		endtext

		return lcMensaje
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function RecalcularImpuestosDetalleArticulos() as Void
		if this.ImpuestosManuales
			this.ImpuestosManuales = .f.
			This.oComponenteFiscal.RecalcularImpuestos( this.FacturaDetalle, this.ImpuestosDetalle )
		endif
		dodefault()
	endfunc

	*-----------------------------------------------------------------------------------------
	function TieneImpuestosManuales() as Boolean
		local llRetorno as Boolean
		llRetorno = this.ImpuestosManuales
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarArticulosNoPermitenDevolucion() as Boolean
		return .T.
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function RestaurarCalculoAutomaticoDeImpuestos() as Void
		this.ImpuestosManuales = .f.
		This.oComponenteFiscal.RecalcularImpuestos( this.FacturaDetalle, this.ImpuestosDetalle )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EjecutarRecalculosEnElComprobante( txVal as Variant ) as Void
		do case
		case ( this.lCambioSituacionFiscal or this.lCambioListaPrecios )
			this.RecalcularPorCambioDeListaDePrecios( txVal )
		case ( this.lCambioProveedor and this.ImpuestosManuales )
			this.RestaurarCalculoAutomaticoDeImpuestos()
		endcase
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EstaModificandoUnRegistroDeLince() as Boolean
		return this.EsRegistroDeLince() and this.lValidarAlModificar
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function EsRegistroDeLince() as Boolean
		return upper( alltrim( this.SerieAltaFW )) = "LINCE"
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function DebeMostrarAdvertenciaRecalculoPrecios() as Boolean
		return dodefault() or ;
				( this.lCambioProveedor and this.ImpuestosManuales)
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function MostrarAdvertenciaRecalculoImpuestos( tcMensaje as String) as Void
		local lcMensaje as String
		if this.ImpuestosManuales
			lcMensaje = 'El cálculo de IVA que estaba manualmente volverá al estado automático por '
			lcMensaje = lcMensaje + tcMensaje + '.'
			this.oMensaje.Informar( lcMensaje )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Setear_Situacionfiscal( txVal as variant ) as void
		dodefault( txVal )
		this.lCambioSituacionFiscal = .f.
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerPorcentajeAplicadoDeIVA( toItem as object ) as Double
		local lnRetorno as Double
		lnRetorno = toItem.PorcentajeIva
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function TieneDetalleDeImpuestos() as Boolean
		return .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ExisteTotalIvaNegativo() as Boolean
		local llRetorno as Boolean
		llRetorno = .F.
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerFechaDeEmision() as Date
		return this.Fecha
	endfunc

	*-----------------------------------------------------------------------------------------
	function SetearLetraEnItem() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	Protected Function EstaEnContexto() as Boolean
		Local llRetorno as Boolean
		llRetorno = .t.
		Do case
		Case !Empty(this.cContexto)
		Case ( pemstatus(_screen,"lUsaServicioRest", 5) and _Screen.lUsaServicioRest )
		Otherwise
			llRetorno = .f.
		Endcase
		Return llRetorno
	EndFunc 
	
	*--------------------------------------------------------------------------------------------------------
	function Setear_PuntoDeVentaExtendido( txVal as variant ) as Void
		
		if this.lEsEntidadConPuntoDeVentaExtendido and !empty( this.PuntoDeVentaExtendido )
			this.PuntoDeVenta = int( val( right( str( this.PuntoDeVentaExtendido, 5 ), 4 ) ) )
		endif
		dodefault( txVal )

	endfunc	

	*--------------------------------------------------------------------------------------------------------
	function ActualizarPuntoDeVentaExtendidoConPuntoDeVenta() as Void
		
		if this.lEsEntidadConPuntoDeVentaExtendido and empty( this.PuntoDeVentaExtendido )
			this.PuntoDeVentaExtendido = this.PuntoDeVenta
		endif

	endfunc	
	
	*-----------------------------------------------------------------------------------------
	Protected Function ObtenerPercepciones() as Object
		Local loRetorno as Object

		loRetorno = newobject( "PercepcionesAuxiliares" )
		for each oImpuesto in this.ImpuestosComprobante
			if this.EsIva( oImpuesto.codimp_pk )
				loRetorno.nPercepcionesIva = loRetorno.nPercepcionesIva + oImpuesto.Monto
			else
				loRetorno.nPercepcionesResto = loRetorno.nPercepcionesResto + oImpuesto.Monto
			endif
		endfor

		Return loRetorno
	EndFunc 
	
	*-----------------------------------------------------------------------------------------
	Protected Function ObtenerNoGravado() as number
		Local lnRetorno as Number

		lnRetorno = 0
		for each oImpuesto in this.impuestosdetalle
			if oImpuesto.porcentajedeiva = 0
				lnRetorno = lnRetorno + oImpuesto.montonogravadosindescuento
			endif
		endfor

		Return lnRetorno
	EndFunc 

	*-----------------------------------------------------------------------------------------
	Protected Function EsIva( tcCodigoImpuesto ) as Boolean
		Local llRetorno as Boolean

		llRetorno = .f.
		if this.oPercepciones.Buscar( alltrim( tcCodigoImpuesto ) )
			llRetorno = .t.
		endif

		Return llRetorno
	EndFunc 
	
	*-----------------------------------------------------------------------------------------
	function TieneRetencionIVA() as Boolean
		Local llRetorno as Boolean

		llRetorno = .f.	
		if type( "This.ImpuestosComprobante" ) = "O" and !isnull( This.ImpuestosComprobante )
			for lnI = 1 to This.ImpuestosComprobante.Count
				with This.ImpuestosComprobante.Item[lnI]
						if .TipoImpuestoCDR = "IVA" 
							llRetorno = .t.
							exit
						endif
				endwith
			endfor
		endif
		return llRetorno	

	endfunc 
 	
 	*-----------------------------------------------------------------------------------------
 	Function AplicarRecalculosGenerales( txVal1, txVal2, txVal3, txVal4 ) as Void
		if ( this.CargaManual() )
			this.lCargando = .T.
			this.SubTotalBruto = round( this.FacturaDetalle.Sum_Bruto, 4 )
			this.SubTotalNeto  = round( this.FacturaDetalle.Sum_Neto, 4 )
			this.lCargando = .F.
			this.CalcularTotal()
		endif
	Endfunc
	
enddefine


*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
define class PercepcionesAuxiliares as Custom

	nPercepcionesIva = 0
	nPercepcionesResto = 0

enddefine
