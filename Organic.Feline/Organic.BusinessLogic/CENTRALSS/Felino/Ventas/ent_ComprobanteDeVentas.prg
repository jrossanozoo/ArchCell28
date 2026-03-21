Define Class Ent_ComprobanteDeVentas as Ent_Comprobante of Ent_Comprobante.prg

	#if .f.
		Local this as ent_ComprobanteDeVentas of ent_ComprobanteDeVentas.prg
	#endif

	#DEFINE PRECISIONENMONTOS 4
	
	Codigo = 0
	Total = 0
	Letra = ""
	Numero = 0
	PuntoDeVenta = 0
	Fecha = {//}
	lImprimir = .F.
	lClienteObligatorio = .F.
	lEliminar = .T.

	oComponenteFiscal = null
	ImpuestosDetalle = null
	FacturaDetalle = null
	ImpuestosComprobante = null

	Cliente = null
	Cliente_Pk = ""
	Vendedor_PK = ""
	SituacionFiscal_Pk = 0
	MonedaComprobante_PK = ""
	ListaDePrecios = null
	ListaDePrecios_Pk = ""

	Impuestos = 0
	anulado = .F.	
	lAsignandoDescuento = .F.
	SimboloMonetarioComprobante = ""
	Cotizacion = 0
	TipoComprobante = 0	
	Vuelto = 0	
	SignoDeMovimiento = 0
	ClienteDescripcion = ""
	FechaModificacion = {//}
	Hora = ""
	lPermiteAccionesDeAbm = .F.
	lPasoPorKontroler = .F.
	lEliminarComprobantePorFalloDeImpresion = .F.
	lAvisoPersonalizaciondelComprobante = .F.
*!*		Percepcion = null
	cDetalleComprobante = "FacturaDetalle"
	lCancelacionExterna = .F.
	cHoraDescuentos = ""
	cDescuentoAnterior = 0
	LimiteMontoComprobanteDeVentas = 0
	lCambioCliente = .f.

	lAgregueRecargoDe1Centavo = .f.
	lEsComprobanteConRecargoSubtotalEnCero = .f.
	ListaDePreciosPreferente = ""
	lHuboCambioSituacionFiscal = .f.
	lHuboCambioListaPrecios = .f.	
	lSoportaKits = .f.
	RecargoMonto = 0
	RecargoMonto1 = 0
	RecargoMonto2 = 0		
	RecargoPorcentaje = 0
	nPorcentajeRecargo1 = 0
	nPorcentajeRecargo2 = 0	
	RecargoMontoConImpuestos = 0
	RecargoMontoConImpuestos1 = 0
	RecargoMontoConImpuestos2 = 0
	RecargoMontoSinImpuestos = 0
	RecargoMontoSinImpuestos1 = 0
	RecargoMontoSinImpuestos2 = 0
	TotalRecargosConImpuestos = 0
	TotalRecargosSinImpuestos = 0
	PorcentajeDescuento  = 0
	PorcentajeDescuento1 = 0
	PorcentajeDescuento2 = 0
	nPorcentajeDescuento3 = 0	
	Descuento = 0
	MontoDescuento1 = 0
	MontoDescuento2 = 0
	MontoDescuento3 = 0
	MontoDescuentoConImpuestos = 0
	MontoDescuentoConImpuestos1 = 0
	MontoDescuentoConImpuestos2 = 0
	MontoDescuentoConImpuestos3 = 0
	MontoDescuentoSinImpuestos = 0
	MontoDescuentoSinImpuestos1 = 0
	MontoDescuentoSinImpuestos2 = 0
	MontoDescuentoSinImpuestos3 = 0
	TotalDescuentosConImpuestos = 0
	TotalDescuentosSinImpuestos = 0

	AjustesPorRedondeos = 0
	TotalImpuestos = 0
	Percepciones = 0
	Gravamenes = 0
	SumPercepciones = 0
	SumGravamenes = 0
	SubTotalBruto = 0
	SubTotalNeto = 0
	lComprobanteConDescuentosAutomaticos = .F.
	DescuentoAutomatico = .F.
	nMontoMaximoDeDescuento = 0
	nPorcentajeMaximoDeDescuento = 0
	nMontoMaximodeRecargo = 0
	nPorcentajeMaximoDeRecargo = 0	
	nModoSeguridadDescuento = 0
	nModoSeguridadRecargo = 0 
	nCantidadDeErrorres = 0
	llFalloAlImprimir = .f.

	oValidacionDominios = null
	oClienteBusquedasAdicionales = null
	oValidadorDetalleArticulos = null
	oAtributosAnulacion = null
	oValidacionesDeSeteosPreferentes = null
	oSeleccionDespachos = null
	oColaboradorEquivalenciaCodigoGTIN = null
	oColaboradorCodigosDJCP = null
	oColaboradorAjusteDeComprobante = null
	oTopes = null
	oColDescuentoAltas = null
	oColaboradorGestionVendedor = null
	oColaboradorDisplayVFD = null

	lComprobanteDebeValidarDevolucionDeArticulo = .F.
	lComprobanteAfectadoDebeValidarDevolucionDeArticulo = .F.
	lImprimeNumeroDeDespachoDeArticulos = .F.
	cDespachos = ""
	lAplicarDescuentoDeValores = .t.
	lMontoTotalDevolucionesNeto = 0
	lMontoTotalDevolucionesBruto = 0
	lObtenerCodigoGTIN = .f.
	lAnularConUsuarioRestringido = .f.

	lDejarCuponHuerfanoPorFalloDeImpresion = .F.
	lYaInformoOrfandadCuponesIntegrados = .F.

	protected nCoeficienteImpuestos
	nCoeficienteImpuestos = 0
	
	cCodArtConRestr = ""
	
	lObteniendoLetra = .f.
	*Estos atributos estan para tener los montos de recargos y descuentos financieros (del detalle de valores)
	nTotalRecargosFinancierosConImpuestos = 0
	nTotalRecargosFinancierosSinImpuestos = 0
	nTotalDescuentosFinancierosConImpuestos = 0
	nTotalDescuentosFinancierosSinImpuestos = 0
		
	lCambioVendedor = .f.
	lDisplayVFD = .f.
	lHaciendoNuevaAccionCancelatoria = .f.
	lAnuladoAntesDeModificar = .F.
	lSeguridadDeDescuentosDesdeValores = .F.
	lSeguridadDeRecargosDesdeValores = .F.
	nMontoDescuentoTotalDesdeSeguridadEnValores = 0
	nMontoRecargoTotalDesdeSeguridadEnValores = 0
	nPorcentajeDescuentoTotalDesdeSeguridadEnValores = 0
	nPorcentajeRecargoTotalDesdeSeguridadEnValores = 0
	lVieneDeValores = .F.
	
	nMontoDescuentoEnLinea = 0
	nMontoTotalSinDescuentoYSinRecargos = 0
	lVieneDeEcommerce = .f.
	
	oColaboradorComprobantesOnline = null
	oColaboradorOmnicanalidad = null
	lTieneContratadaEntregaOnline = .f.
	lEsComprobanteConEntregaPosterior = .F.
	nFilaActivaFacturaDetalle = 0
	lForzarAccionCancelatoria = .F.
	oColaboradorEcommerce = null
	oColaboradorJsonConvert = null

	lIngresarMontoDeDescuentoRecargoConIvaIncluidoEnComprobantesA = .F.

	lCambioMontoDescuentoGeneral = .F.
	nMontoDeDescuento3IngresadoManualmente = 0.00
	
	lCambioMontoRecargoGeneral = .F.
	nMontoDeRecargo2IngresadoManualmente = 0.00	
	
	lEstoyGrabando = .f.
	lEstoyCargandoDescuentosAutomaticos = .F.
	
	oEntidadSeleccionDespachos = null

	lContinuaAlSiguienteControl = .t.
	lBindeoConMensajesDeCtaCteVencida = .f.
	
	lEsListaDePreciosImportacion = .f.
	
	lAjustePorResiduoCentavo = .f.	
	nResiduo = 0
	
	lAdvertirSiSuperaLimiteDeCredito = .F.
	nTotalAnterior = 0
	nTopeDelCliente = 0		
	lMostrarSaldoDeLaCuentaCorrienteEnFacturaNDebyNCred = .F.

	lAdvertirPorMonedaDiferenteALaDelComprobante = .F.
	
	lIncluirRemitosDeVentasEnControlDeLimiteDeCredito = .F.

	oColaboradorRemitos = null
	lControldelimitedecredito = 0
	lYaCalculoRemitosPendientes = .F.
	lSuperoSaldoCC = .F.
	nRecargoPorcentajeAnterior = 0
	nRecargoMonto2Anterior = 0
	lEstoySeteandoRecargos = .F.
	lEstoyEnMontoRecargoEnPago = .f.
 	
 	cValorCtaCte = ""
 	lPercepcionesACtaCte = .F.
 	lCambioTotalPorImpuestos = .F.
 	
	&& Propiedades para descuento por nivel de cliente
	NivelDeClienteAsignado = 0
	nTotalCompradoMensual = 0
	nPorcentajeDescuentoNivel = 0
 	
	*-----------------------------------------------------------------------------------------
	Function Init( t1, t2, t3, t4 ) As Boolean
		Local llRetorno As Boolean
		llRetorno = DoDefault(t1, t2, t3, t4 )

		if llRetorno 
			if type( "this.oComponenteFiscal" ) = "O"
				this.enlazar( "oComponenteFiscal.EventoPreguntarImprimir", "EventoPreguntarImprimir" )	
				this.enlazar( "oComponenteFiscal.EventoMensajeControlador", "EventoMensajeControlador" )
				this.enlazar( "oComponenteFiscal.EventoRecalcularImpuestos", "EventoRecalcularImpuestos" )
				this.enlazar( "oComponenteFiscal.EventoObtenerInformacion", "inyectarInformacion" )
				this.enlazar( "oComponenteFiscal.EventoCambioTotalImpuesto", "AsignarTotalImpuesto" )
			endif
		endif

		if this.EsComprobanteFiscal() and type( "This.FacturaDetalle" ) = "O" and type( "This.FacturaDetalle.oItem" ) = "O"
			bindevent( this.FacturaDetalle, "Actualizar", this, "ValidarMontodeLineaPositivoSinDevoluciones" )
		endif

		if type( "this.oComponenteFiscal.oComponenteImpuestos" ) = "O"
			if pemstatus( this.oComponenteFiscal.oComponenteImpuestos, "EventoSetearDatosAdicionalesParaCalculoDeImpuestos", 5 )
				this.BindearEvento( this.oComponenteFiscal.oComponenteImpuestos, "EventoSetearDatosAdicionalesParaCalculoDeImpuestos", this, "SetearDatosAdicionalesParaCalculoDeImpuestos" )
			endif
			if pemstatus( this.oComponenteFiscal.oComponenteImpuestos, "EventoCargarDetalleImpuestosDesdeFactura", 5 )
				this.BindearEvento( this.oComponenteFiscal.oComponenteImpuestos, "EventoCargarDetalleImpuestosDesdeFactura", this, "CargarDetalleImpuestosDesdeFactura" )			
			endif
			if pemstatus( this.oComponenteFiscal.oComponenteImpuestos, "EventoCargarPorcentajeDescuentoRecargo", 5 )
				bindevent( this.oComponenteFiscal.oComponenteImpuestos, "EventoCargarPorcentajeDescuentoRecargo", this, "ObtenerPorcentajeDescuentoyRecargo", 1 )			
			endif
		endif
	
		if pemstatus( this, "ValorSugeridoListaDePrecios", 5 )
			bindevent( this, "ValorSugeridoListaDePrecios", this, "EventoValorSugeridoListaDePrecios", 1 )
		endif
		
		this.cParametroPreciosNuevoEnBaseA = "goParametros.Felino.GestionDeVentas.Minorista.NuevoEnBaseA.ActualizarPreciosEnComprobantesNuevosEnBaseAVenta"

		Return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function Inicializar() as Void
	 	Dodefault()
		if type( "this." + This.cDetalleComprobante ) = "O"
		
			if type( "this.FacturaDetalle.oItem" ) = "O"
				This.FacturaDetalle.oItem.InyectarListaDePrecios( This.ListaDePrecios )
				This.FacturaDetalle.oItem.cNombreComprobante = this.obtenerNombre()
				bindevent( this.FacturaDetalle.oItem, "EventoAplicarRecalculosGenerales", this, "AplicarRecalculosGenerales", 1 )
				bindevent( this.FacturaDetalle, "EventoDespuesDeInsertarDetalle", this, "AplicarRecalculosGenerales", 1 )
				bindevent( this.FacturaDetalle.oItem, "EventoSetearFlagEnBaseAComprobanteOnline", this, "SetearFlagEnBaseAComprobanteOnline", 1 )
				bindevent( this.FacturaDetalle, "ValidarItem", this, "ValidarIngresoEnBaseAPendienteDeEntregaOnline" )
				bindevent( this.FacturaDetalle, "Actualizar", this, "DescontarEnBaseAPendienteDeEntregaOnline" )
				bindevent( this.FacturaDetalle.oItem, "EventoExisteEnDetalleYCantidadEsDistintaDeCero", this, "ExisteEnDetalleYCantidadEsDistintaDeCero")
				bindevent( this.FacturaDetalle.oItem.Articulo, "AjustarObjetoBusqueda", this, "AjustarObjetoBusquedaArticulo", 1 )								
				this.BindearEvento( This.FacturaDetalle.oItem, "EventoObtenerParticipantes", this, "SetearColeccionParticipantesEnItem" )				
			endif
			
			if type( "this.FacturaDetalle" ) = "O" and !isnull( this.FacturaDetalle )
				this.oValidadorDetalleArticulos = _screen.zoo.CrearObjetoPorProducto("ColaboradorValidacionDetalleArticulos")
				this.BindearEvento( this.FacturaDetalle, "Limpiar", this, "LimpiarImpuestosDetalleAlLimpiarFacturaDetalle" )
				bindevent( this.FacturaDetalle, "Actualizar", this, "SetearStockActualEnItem" )
				bindevent( this.FacturaDetalle, "EventoConsultarInvertirSigno", this, "SetearInvertirSignoEnDetalle" )
				bindevent( this.FacturaDetalle, "EventoConsultarComprobanteDebeValidarDevolucionDeArticulo", this, "SetearComprobanteDebeValidarDevolucionDeArticulo" )
				bindevent( this.FacturaDetalle, "EventoConsultarComprobanteAfectadoDebeValidarDevolucionDeArticulo", this, "SetearComprobanteAfectadoDebeValidarDevolucionDeArticulo" )
				bindevent( this.FacturaDetalle.oItem, "EventoValidarSiElComprobanteTieneDescuento", this, "SetearValidarSiElComprobanteTieneDescuento" )
				bindevent( this.FacturaDetalle, "EventoObtenerLetraDelComprobante", this, "ObtenerLetraDelComprobante" )
				this.enlazar( "FacturaDetalle.Sumarizar", "ActualizarTotalCantidades" )
				this.SetearComprobanteEsCancelacionEnDetalle()
				this.lControlaSecuencialEnCodBarAlt = .T.
				Bindevent( this.FacturaDetalle, "Actualizar", this, "ActualizoDetalles", 1 )
			endif 

			if pemstatus( this, "oCompEnBaseA", 5 ) 
				if pemstatus( this.oCompEnBaseA, "InyectarConsulta", 5 )
					bindevent( this.oCompEnBaseA, "InyectarConsulta", this, "AplicarRecalculosGenerales", 1 )				
				endif
			endif

			if pemstatus( this, "oCompEcommerce", 5 ) 
				this.oCompEcommerce.instanciarEntidadAfectada( this )
			endif
			if this.TieneDescuentoAutomatico()
				This.lComprobanteConDescuentosAutomaticos = .T.
				this.oCompDescuentos.InyectarEntidad( this )
				this.oCompDescuentos.LlenarColeccionDescuentos()
				this.enlazar( "oCompDescuentos.EventoPreguntarSiAplicaDescuento", "EventoPreguntarSiAplicaDescuento" )
				this.BindearEvento( this, "Limpiar", this, "LimpiarDescuentoPreferenteDelCliente" )
				this.oTopes = this.oCompDescuentos.ObtenerTopesGlobales()
				this.nMontoMaximoDeDescuento = this.oTopes.MontoMaximoDescuento 
				this.nPorcentajeMaximoDeDescuento = this.oTopes.PorcentajeMaximoDescuento 
				this.nMontoMaximodeRecargo = this.oTopes.MontoMaximoRecargo
				this.nPorcentajeMaximoDeRecargo = this.oTopes.PorcentajeMaximoRecargo
				loTopesPerfil = this.oCompDescuentos.ObtenerTopesDeDescuentoPorUsuario( goServicios.Seguridad.cUsuarioLogueado ) 
				if loTopesPerfil.MontoMaximoDescuento != 0 or loTopesPerfil.PorcentajeMaximoDescuento != 0
					this.nMontoMaximoDeDescuento = loTopesPerfil.MontoMaximoDescuento 
					this.nPorcentajeMaximoDeDescuento = loTopesPerfil.PorcentajeMaximoDescuento 
					this.oTopes.MontoMaximoDescuento = loTopesPerfil.MontoMaximoDescuento 
					this.oTopes.PorcentajeMaximoDescuento = loTopesPerfil.PorcentajeMaximoDescuento 
				endif
				this.oColDescuentoAltas = _screen.zoo.crearobjeto( "ZooColeccion" )
			endif
		endif

		if type( "this.ImpuestosDetalle" ) = "O"
			this.enlazar( "ImpuestosDetalle.Actualizar", "AsignarTotalImpuesto" )
			This.BindearEvento( This.ImpuestosDetalle, "SumarRecargosDescuentosFinancieros", this,"LlamarARecalcularImpuestos" )
		endif
		if type( "this.oCompLimitesdeconsumo" ) = "O"
			this.oCompLimitesDeConsumo.InyectarEntidadComprobante( this )
		endif
		if pemstatus( this, "oCompServiciosAlCliente", 5 )
			this.oCompServiciosAlCliente.InyectarEntidadPadre( this )
		endif

		if type( "this.FacturaDetalle" ) = "O" and !isnull( this.FacturaDetalle )
			this.InicializarColaboradorEquivalenciaCodigoGTIN()
			this.InicializarColaboradorCodigosDJCP()
			this.InicializarColaboradorAjusteDeComprobante()
			this.InicializarColaboradorDisplayVFD()
			this.SetearEntregaOnline()
		endif
		if this.lSoportaKits 
			this.BindeosSoportaKit() 
		endif 
		this.lIngresarMontoDeDescuentoRecargoConIvaIncluidoEnComprobantesA = goServicios.Parametros.Felino.GestionDeVentas.IngresarMontoDeDescuentoConIvaIncluidoEnComprobantesA
	
		if ( type( "This.ValoresDetalle" ) = "O" or upper(This.cNombre) = "REMITO" )
			this.lControlDeLimiteDeCredito = goParametros.Felino.GestionDeVentas.CuentaCorriente.ControlDeLimiteDeCredito && 1=Controlar /// (Default) 2=Advertir		
		endif

		this.lIncluirRemitosDeVentasEnControlDeLimiteDeCredito = this.DebeIncluirRemitosDeVentasEnControlDeLimiteDeCredito()
	Endfunc
	*-----------------------------------------------------------------------------------------
	function BindeosSoportaKit() as Void
		This.KitsDetalle.oItem.cNombreComprobante = this.obtenerNombre()
		This.KitsDetalle.oItem.InyectarListaDePrecios( This.ListaDePrecios )
		this.BindearEvento( This.KitsDetalle.oItem, "EventoHaCambiadoMonto", this, "ActualizarParticipantesPorMonto" )
		this.BindearEvento( This.KitsDetalle.oItem, "EventoActualizarParticipantes", this, "ActualizarParticipantesPorCambioDeCombinacion" )							
		this.BindearEvento( This.KitsDetalle.oItem, "EventoHaCambiadoCantidad", this, "ActualizarParticipantesPorCantidad" )
		this.BindearEvento( This.KitsDetalle.oItem, "EventoDespuesDeSetear", this, "DespuesDeProcesarItemKit" )
		this.BindearEvento( This.KitsDetalle, "EventoEliminarParticipantes", this, "EliminarParticipantes" )	
		
		this.BindearEvento( This.KitsDetalle.oItem, "EventoObtenerParticipantes", this, "SetearColeccionParticipantesEnItem" )							

		with this.KitsDetalle.oitem
			.lInvertirSigno = This.lInvertirSigno
			
			if .lControlaStock
				.oCompStock.nSigno = iif( This.lInvertirSigno, -1, 1 )
				.oCompStock.lInvertirSigno = This.lInvertirSigno
				.oCompStock.InyectarEntidad( this )
				.oCompStock.SetearoColStockDetalleParticipantes( this.FacturaDetalle )
			endif
		endwith
		this.BindearEvento( This.KitsDetalle.oItem, "EventoNoHayStock", this, "EventoNoHayStock" )
		this.BindearEvento( This.KitsDetalle.oItem, "EventoAlcanzoMinimoDeReposicion", this, "EventoAlcanzoMinimoDeReposicion" )
		this.oCompKitDeArticulos.InyectarEntidad( this )
		this.oCompKitDeArticulos.InyectarDetalles( this.FacturaDetalle, this.KitsDetalle )
		This.KitsDetalle.oItem.lSoportaKits = .t.

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ActualizarTotalCantidades() as Void
		this.TotalCantidad = this.FacturaDetalle.Sum_Cantidad
	endfunc

	*-----------------------------------------------------------------------------------------
	function SetearStockActualEnItem() as Void	
		if this.EsNuevo() or this.EsEdicion()
			this.FacturaDetalle.SetearStockActualEnItem()
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarMontodeLineaPositivoSinDevoluciones() as Void

		if this.CargaManual() and this.facturadetalle.oitem.monto < 0 and this.facturadetalle.oitem.cantidad > 0
			goServicios.Errores.LevantarExcepcion( "No está permitido aplicar un descuento mayor al monto." )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	Function AplicarRecalculosGenerales( txVal1, txVal2, txVal3, txVal4 ) as Void
		if ( this.CargaManual() )
			this.lCargando = .T.
			this.SubTotalBruto = round( this.FacturaDetalle.Sum_Bruto, 4 )
			this.SubTotalNeto  = round( this.FacturaDetalle.Sum_Neto, 4 )
			this.AplicarDescuentosPorComponente()
			this.lCargando = .F.
			this.CalcularTotal()
		endif
	Endfunc
	
	*-----------------------------------------------------------------------------------------
	Protected Function oClienteBusquedasAdicionales_access() as object
		if !this.lDestroy and (type("this.oClienteBusquedasAdicionales") <> "O" or isnull(this.oClienteBusquedasAdicionales))
			this.oClienteBusquedasAdicionales = _screen.zoo.InstanciarEntidad(this.Cliente.ObtenerNombre())
		endif
		Return this.oClienteBusquedasAdicionales
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Protected Function oEntidadSeleccionDespachos_access() as object
		if !this.lDestroy and (type("this.oEntidadSeleccionDespachos") <> "O" or isnull(this.oEntidadSeleccionDespachos))
			this.oEntidadSeleccionDespachos = _screen.zoo.InstanciarEntidad("SELECCIONDESPACHO")
		endif
		Return this.oEntidadSeleccionDespachos
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function InicializarColaboradorEquivalenciaCodigoGTIN() as void
		this.lObtenerCodigoGTIN = this.lObtenerCodigoGTIN and type( "this.FacturaDetalle" ) = "O"
		if this.lObtenerCodigoGTIN
			this.oColaboradorEquivalenciaCodigoGTIN = _screen.Zoo.CrearObjeto( "ColaboradorEquivalenciaCodigoGTIN", ;
				"ColaboradorEquivalenciaCodigoGTIN.prg", this.oMensaje )
			bindevent( this.FacturaDetalle, "Actualizar", this, "SetearCodigoGTIN" )
			bindevent( this.FacturaDetalle, "SetearCodigoGTINEnItem", this, "SetearCodigoGTINEnItem" )
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function InicializarColaboradorCodigosDJCP() as void
		if type( "this.FacturaDetalle" ) = "O" and goParametros.Felino.DatosGenerales.SituacionFiscal = 1
			this.oColaboradorCodigosDJCP = _screen.Zoo.CrearObjeto( "ColaboradorCodigosAutorizacionDJCP " )
			bindevent( this.FacturaDetalle, "Actualizar", this, "SetearCodigoDJCP" )
			bindevent( this.FacturaDetalle, "SetearCodigoGTINEnItem", this, "SetearCodigoDJCPEnItem" )
			bindevent( this, "SetearDatosAComponenteFiscal", this, "ActualizarCodigosDJCPEnDetalle" )
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function InicializarColaboradorAjusteDeComprobante() as void
		if type( "this.FacturaDetalle" ) = "O"
			this.oColaboradorAjusteDeComprobante = _screen.Zoo.CrearObjeto( "ColaboradorAjusteDeComprobante","ColaboradorAjusteDeComprobante.prg", this )
			if !this.oColaboradorAjusteDeComprobante.NoHayConfiguradosAjustesMaximos()
				bindevent( this.FacturaDetalle, "EventoCambioSum_Neto", this.oColaboradorAjusteDeComprobante , "QuitarAjuste" )
			else
				this.oColaboradorAjusteDeComprobante = null
			endif
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function InicializarColaboradorDisplayVFD() as Void
		local lcLineaPresentacion1 as String, lcLineaPresentacion2 as String, i as Integer
		
		this.lDisplayVFD = goParametros.Felino.Interfases.DisplayVFD460.ActivaInterfazConDisplay
		if type( "This.FacturaDetalle" ) = "O" and this.lDisplayVFD
			this.FacturaDetalle.lDisplayVFD = .t.
			lcLineaPresentacion1 = goParametros.Felino.Interfases.DisplayVFD460.MensajeDePresentacionPrimeraLinea
			lcLineaPresentacion2 = goParametros.Felino.Interfases.DisplayVFD460.MensajeDePresentacionSegundaLinea
			for i = 1 to 3
				this.oColaboradorDisplayVFD.SetearPresentacion( lcLineaPresentacion1, lcLineaPresentacion2, i )
			endfor
			
			this.oColaboradorDisplayVFD.MostrarPresentacion( .t., .f., .f., 1 )
			bindevent( this.FacturaDetalle, "EventoEscribirArticuloDisplay", this.oColaboradorDisplayVFD, "EscribirLineaDeArticulo" )
			bindevent( this.FacturaDetalle, "EventoEscribirLinea", this.oColaboradorDisplayVFD, "EscribirLinea" )
			bindevent( this.FacturaDetalle, "EventoActualizarTotal", this, "DisplayVFDMostrarTotalEnDetalle" )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	Protected Function oColaboradorAsiento_Access() as Object
		if !this.lDestroy and vartype( this.oColaboradorAsiento ) # "O"
			this.oColaboradorAsiento = _Screen.zoo.crearobjeto( "ColaboradorAsiento" )
		endif
		Return this.oColaboradorAsiento 
	Endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function oColaboradorDisplayVFD_Access() as Object
		if !this.lDestroy and isnull( this.oColaboradorDisplayVFD ) or vartype( this.oColaboradorDisplayVFD ) != "O"
			this.oColaboradorDisplayVFD = _Screen.zoo.crearobjeto( "colaboradordisplayvfd" )
		endif
		return this.oColaboradorDisplayVFD 
	endfunc

	*-----------------------------------------------------------------------------------------	
	Function oComponenteFiscal_Assign( toVal ) as Void
		if this.lDestroy 
		else
			this.oComponenteFiscal = toVal
			if type( "this.oComponenteFiscal" ) = "O" and !isnull( this.oComponenteFiscal )
				this.lPermiteAccionesDeAbm = this.oComponenteFiscal.PermiteAccionesDeAbm()
				this.oComponenteFiscal.InyectarImpuestosDetalle( this.ImpuestosDetalle )
				this.oComponenteFiscal.InyectarImpuestosComprobante( this.ImpuestosComprobante )
				This.BindearEvento( This, "EventoSetearFechaDeComprobante" , this.oComponenteFiscal, "SetearFechaDeComprobante" )
				this.DespuesDeInicializarElComponenteFiscal()
			endif
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function oColaboradorECommerce_Access() as Object
		if !this.lDestroy and ( isnull( this.oColaboradorECommerce ) or vartype( this.oColaboradorECommerce ) != "O" )
			this.oColaboradorECommerce = _Screen.zoo.crearobjeto( "colaboradorECommerce" )
		endif
		return this.oColaboradorECommerce
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function oColaboradorJsonConvert_Access() as Object
		if !this.lDestroy and ( isnull( this.oColaboradorJsonConvert ) or vartype( this.oColaboradorJsonConvert ) != "O" )
			this.oColaboradorJsonConvert = _Screen.zoo.crearobjeto( "ColaboradorJsonConvert" )
		endif
		return this.oColaboradorJsonConvert
	endfunc

	*-----------------------------------------------------------------------------------------
	function PermiteAccionesDeAbm() as boolean
		return this.lPermiteAccionesDeAbm
	endfunc 

	*-----------------------------------------------------------------------------------------	
	function AsignarTotalImpuesto() as Void
		if type( "this.ImpuestosDetalle" ) = "O"
			this.Impuestos = goLibrerias.RedondearSegunMascara( This.ImpuestosDetalle.Sum_Montodeiva )
		endif
	endfunc 
		
	*-----------------------------------------------------------------------------------------	
	Function Nuevo() as Void
		With this
			.lAvisoPersonalizaciondelComprobante = .f.
			.lCambioCliente = .f.
			.cHoraDescuentos = goLibrerias.ObtenerHora()
			.DescuentoAutomatico = .F.
			.nMontoDeDescuento3IngresadoManualmente = 0.00
			.nMontoDerecargo2IngresadoManualmente = 0.00
			
			if type( "this.oNumeraciones" ) = 'O'
            	this.oNumeraciones.lForzarObtencionNumeroDesdeBuffer = .f.
			endif
			if pemstatus( this, "lHabilitarMonedaComprobante_PK", 5 )
				.lHabilitarMonedaComprobante_PK = .t.
			endif
			dodefault()
			.SetearMonedaComprobante()
			if type( "this.oComponenteFiscal" ) = "O" and !isnull( .oComponenteFiscal )
				if !isnull( .cliente )
					.oComponenteFiscal.SetearSituacionFiscalCliente( this.cliente.situacionfiscal_pk )
				else
					.oComponenteFiscal.SetearSituacionFiscalCliente( goRegistry.felino.SituacionFiscalClienteConsumidorFinal )
				endif
			endif

			.SetearDatosFiscalesComprobante()
			.ResetearAtributoAgipEnComponenteImpuestos()
			.ResetearAtributoIIBBGBAEnComponenteImpuestos()
			
			.nPorcentajeRecargo1 = 0
			.nPorcentajeRecargo2 = 0
			.nPorcentajeDescuento3 = 0
			this.SetearListaDePreciosPreferenteOValorSugerido()
			this.DebeSetearImpuestosInternos()
			
			if this.TieneDescuentoAutomatico()
				this.nMontoMaximoDeDescuento = this.oTopes.MontoMaximoDescuento 
				this.nPorcentajeMaximoDeDescuento = this.oTopes.PorcentajeMaximoDescuento
				this.oCompDescuentos.ReiniciarColeccionDescuentos()
			endif

			if this.EsComprobanteFiscal()

				if !goControladorfiscal.VeriricarSiControladorFiscalTuvoProblemas( This.TipoComprobante )
					this.ProcesarErroresConNumeracionEnCF( This.TipoComprobante )
				endif
			
				if inlist( This.TipoComprobante, 2, 6 )
					lnIdOtro = iif( This.TipoComprobante = 2, 6, 2 )
					if goControladorfiscal.ConsultarEstadoControladorFiscal( goParametros.Felino.ControladoresFiscales.PuntoDeVenta, lnIdOtro )
						lcTipoComprobanteAfectado = this.ObtenerTipoComprobante( lnIdOtro )
						lcTipoComprobanteActual = this.ObtenerTipoComprobante( this.TipoComprobante )
						goServicios.Errores.LevantarExcepcion( "Atención: Hubo problemas en la impresion del ultimo comprobante "+lcTipoComprobanteAfectado+". Intente hacer un nuevo "+lcTipoComprobanteAfectado+" para resolverlo antes de intentar hacer un comprobante "+lcTipoComprobanteActual )
					endif
				endif
				
				this.Secuencia = iif( inlist( This.TipoComprobante, 2, 5, 6 ), This.lcSecuencia, "" )
			endif
			if this.lDisplayVFD
				.oColaboradorDisplayVFD.LimpiarPantalla( .t., .t. )
				.oColaboradorDisplayVFD.MostrarPresentacion( .t., .f., .f., 1 )
			endif
			this.lSeguridadDeDescuentosDesdeValores = .F.
			this.lSeguridadDeRecargosDesdeValores = .F.
			this.lEsListaDePreciosImportacion = .F.
			this.lYaCalculoRemitosPendientes = .F.
			this.lSuperoSaldoCC = .F.
			this.nRecargoPorcentajeAnterior = 0
			this.nRecargoMonto2Anterior = 0
			
		endwith
	Endfunc

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
			this.ListaDePreciosPreferente = goParametros.Felino.Precios.ListasDePrecios.ListaDePreciosPreferente
		endif
		
		return
	endfunc 

	*-----------------------------------------------------------------------------------------
	function DebeSetearImpuestosInternos() as Void
		local lnI as Integer
		if this.EsComprobanteConImpuestosInternos()
			if pemstatus( this, "FacturaDetalle", 5 ) 
				this.FacturaDetalle.oItem.lDebeSetearImpuestosInternos = .t.
			endif		
			if pemstatus( this, "ArticulosSeniadosDetalle", 5 ) 
				this.ArticulosSeniadosDetalle.oItem.lDebeSetearImpuestosInternos = .t.
			endif              
			if pemstatus( this, "KitsDetalle", 5 ) 
				this.KitsDetalle.oItem.lDebeSetearImpuestosInternos = .t.
			endif              
		endif
	endfunc
			
	*-----------------------------------------------------------------------------------------
	function EsComprobanteConImpuestosInternos() as Boolean
		return vartype( this.oComponenteFiscal ) = "O" and !this.EsComprobanteDeExportacion() and this.oComponenteFiscal.oComponenteImpuestos.oEntidadDatosFiscales.TieneImpuestosInternos()
	endfunc
			
	*-----------------------------------------------------------------------------------------
	function EsComprobanteDeExportacion() as Void
		return inlist( This.TipoComprobante, 33, 35, 36, 47, 48, 49 )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ActualizarCotizacion() as Void
		this.Cotizacion = this.MonedaComprobante.ObtenerCotizacionVigente( this.Fecha )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function EsComprobanteFiscal() as boolean
		return vartype( goControladorFiscal ) = "O" and "<CF>" $ This.ObtenerFuncionalidades()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Modificar() as Void
		local loError as Object
		
		this.lAnuladoAntesDeModificar = this.EstaAnulado()

		* Este chequeo del cliente se hace para que en caso de que el cliente no exista, 
		* no pinche cuando se quiere modificar un comprobante.
		* Si se da este caso, se muestra mensaje por pantalla para que el usuario dé de 
		* alta ese usuario y asi pueda editar el comprobante seleccionado.
		if pemstatus( this, "Cliente", 5 ) 
			try
				if vartype( This.Cliente ) = "O" 
					this.Cliente.Codigo = this.Cliente_pk
				endif
			catch to loError
				goServicios.Errores.LevantarExcepcion( "El cliente no existe. Para poder modificar el comprobante debe crearlo nuevamente." )
			endtry
		endif
		* ---------
		* ---------
		* ---------
		* ---------
		
		dodefault()
		
		this.lAvisoPersonalizaciondelComprobante = .f.
		this.lCambioCliente = .f.

		if empty( this.MonedaComprobante_Pk )
			this.SetearMonedaComprobante()
		else
			This.SetearMonedaEnDetalleValores()
		endif
		
		try
			this.SetearDatosAComponenteFiscal()
		catch
		endtry
		this.ResetearAtributoAgipEnComponenteImpuestos()
		this.ResetearAtributoIIBBGBAEnComponenteImpuestos()
		
		if pemstatus( this, "oCompEnBaseA", 5 ) and this.EsNotaDeCredito()
			this.oCompEnBaseA.SetearDatosOriginalesComprobanteAfectadoUnicoAlModificar( this.FacturaDetalle )
		endif	

		this.InicializarPreciosDeListaEnArticulos()

		if This.TipoComprobante # 98	&& 98-Comprobante de caja
			This.anulado = .F.
			This.FechaModificacion = {//}
		endif 
		this.SetearListaDePreciosPreferenteOValorSugerido()
		
		if this.TieneDescuentoAutomatico()
			this.nMontoMaximoDeDescuento = this.oTopes.MontoMaximoDescuento 
			this.nPorcentajeMaximoDeDescuento = this.oTopes.PorcentajeMaximoDescuento
		endif
		if this.lAnuladoAntesDeModificar
			this.SetearValoresSugeridosAlModificarAnulado()				
		endif
		if this.SoportaKits()
			this.SetearDatosKitsDetalle()		
		endif
		
		this.lEsListaDePreciosImportacion = .F.

		if this.DebeQuitarImpuestosAlDescuento()
			this.nMontoDeDescuento3IngresadoManualmente = this.MontoDescuentoConImpuestos3
			this.nMontoDeRecargo2IngresadoManualmente = this.RecargoMontoConImpuestos2
		endif		

		this.lYaCalculoRemitosPendientes = .F.
		this.lSuperoSaldoCC = .F.
		this.nRecargoPorcentajeAnterior = 0
		this.nRecargoMonto2Anterior = 0		
		
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function SetearValoresSugeridosAlModificarAnulado() as Void
		if pemstatus ( this, "ValorSugeridoCajadestino", 5 )  &&Estos son casos para;
		&& comprobantes de caja, que no pueden ser anulados por sistema, pero en los test a veces queda la propiedad en .T.
		else
			with this
				.lEstaSeteandoValorSugerido = .T.
				.ValorSugeridoVendedor()
				if empty( this.Fecha )
					.ValorSugeridoFecha() 
				endif
				.ValorSugeridoCliente()
				.ValorSugeridoPorcentajedescuento()
				.SetearValoresSugeridosAlModificarAnuladoExclusivosDeCadaEntidad()			
				.lEstaSeteandoValorSugerido = .F.
			endwith
		endif

	endfunc
	
	*-----------------------------------------------------------------------------------------
	function SetearValoresSugeridosAlModificarAnuladoExclusivosDeCadaEntidad() as Void
		.ValorSugeridoObs()	
		if pemstatus ( this, "ValorSugeridoRecargoporcentaje", 5 )
			.ValorSugeridoRecargoporcentaje()
		endif			
		if pemstatus ( this, "ValorSugeridoListaDePrecios", 5 )
			.ValorSugeridoListaDePrecios()				
			.ValorSugeridoMontodescuento3()		
			if pemstatus( this, "ValorSugeridoRecargomonto2", 5 )	
				.ValorSugeridoRecargomonto2()						
			endif
			if pemstatus ( this, "ValorSugeridoTransportista", 5 )
				.ValorSugeridoForpago()
				.ValorSugeridoMotivo()
				.ValorSugeridoTransportista()
				do case
					case pemstatus ( this, "ValoSugeridoDireccionEntrega", 5 )
						.ValorsugeridoDireccionEntrega()
					case pemstatus ( this, "ValorSugeridoFechadeentrega", 5 )
						.ValorSugeridoFechadeentrega()
					case pemstatus ( this, "ValorSugeridoFechaVencimiento", 5 )
						.ValorSugeridoFechavencimiento()
				endcase
			endif
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function SetearMonedaEnDetalleValores() as Void
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerTurno() as Integer 
		Local lnTurno As Integer , lcParametroDelTurno As String, lcTime as string

		lcParametroDelTurno = goParametros.Felino.Sugerencias.CambioDeTurno
		lcTime = goLibrerias.ObtenerHora()

		If ( Val( Substr( lcTime ,1,2 ) ) * 100 )+ Val( Substr( lcTime , 4 , 2 ) ) < lcParametroDelTurno
			If !Between( ( Val( Substr( lcTime,1,2 ) ) * 100 ) + Val( Substr( lcTime ,4, 2 ) ) ,0,600 )
				lnTurno = 1
			Else
				lnTurno = 2
			Endif
		Else
			lnTurno = 2
		Endif

		Return lnTurno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function SugiereCotizacionDeMonedaParaDespacho() as Boolean 
		return goServicios.Parametros.Felino.GestionDeVentas.FacturacionElectronica.Exportacion.SugerirCotizacionDeMoneda
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function PermiteEmitirMonedaExtranjera() as Boolean
		local llRetorno as Boolean
	
		do case
			case this.cNombre = "PEDIDO"
				llRetorno = goParametros.Felino.GestionDeVentas.PermitePedidosEnMonedaExtranjera
			case this.cNombre = "REMITO"
				llRetorno = goParametros.Felino.GestionDeVentas.PermiteRemitirEnMonedaExtranjera
			case this.cNombre = "PRESUPUESTO"
				llRetorno = goParametros.Felino.GestionDeVentas.PermitePresupuestosEnMonedaExtranjera
			otherwise 
				llRetorno = goParametros.Felino.GestionDeVentas.PermiteFacturarEnMonedaExtranjera
		endcase
		
		return llRetorno 
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
	protected function DebeRecalcularEnElAntesDeGrabar() as Boolean
		return .T.
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function AntesDeGrabar() As Boolean
		Local llAntesDeGrabar as Boolean, lnTotal as float, loError as exception, llHuboCambioDeTotalPorRestriccionDeCalculoEnIIBB as Boolean
		
		this.lEstoyGrabando = .t.
		llAntesDeGrabar = .t.
		llHuboCambioDeTotalPorRestriccionDeCalculoEnIIBB = .f.
		
		lnTotal = this.Total
		
		if !This.VerificarContexto( "B" ) and This.DebeRecalcularEnElAntesDeGrabar()
			if type( "this.oComponenteFiscal" ) = "O" and type( "this.ImpuestosDetalle" ) = "O" and type( "this.FacturaDetalle" ) = "O"
				llYaHuboAvisoCambioDeTotalPorRestriccionDeCalculoEnIIBB = this.ConsultarSiHuboAvisoDeCambioDeTotalPorRestriccionDeCalculoEnIIBB()
				this.oComponenteFiscal.lEstaRecalculandoImpuestosAntesDeGrabar = .T.
				This.oComponenteFiscal.RecalcularImpuestos( this.FacturaDetalle, this.ImpuestosDetalle )
				this.oComponenteFiscal.lEstaRecalculandoImpuestosAntesDeGrabar = .F.
				This.CalcularTotal()
				if !llYaHuboAvisoCambioDeTotalPorRestriccionDeCalculoEnIIBB and This.ConsultarSiHuboAvisoDeCambioDeTotalPorRestriccionDeCalculoEnIIBB()
					llAntesDeGrabar = .f.
					llHuboCambioDeTotalPorRestriccionDeCalculoEnIIBB = .f.
					This.AgregarInformacion( "No se pudo grabar el comprobante porque se han recalculado impuestos." )
				endif
			endif
		endif
		
		this.SetearFlagRecargoPorCambio( .f. )
		llAntesDeGrabar = llAntesDeGrabar and dodefault()
		
		if llAntesDeGrabar and this.ValidarSiImprimeDespacho()
			This.Despachos = ""
			llAntesDeGrabar = This.VerificarArticulosYDespachos()
		endif
		
		if llAntesDeGrabar 
			this.AjusteDeRecargoPorSubtotalEnCero()

			this.AplicarProrrateo()

			if empty( this.SituacionFiscal_pk )
				this.SituacionFiscal_pk = goRegistry.felino.SituacionFiscalClienteConsumidorFinal
			endif
			if pemstatus( this, "oCompEnBaseA", 5 )
				this.oCompEnBaseA.ActualizarCompAfeAlModificar( this )
				if !this.lVieneDeECommerce
					this.oCompEnBaseA.ObtenerInformacionECommerce( this.lEdicion )
				endif
			endif
		endif

		if This.Total != lnTotal
			if ( This.Total = 0.01 and lnTotal = 0 and This.lAgregueRecargoDe1Centavo) or this.lAjustePorResiduoCentavo or llHuboCambioDeTotalPorRestriccionDeCalculoEnIIBB
			else
				this.lCambioTotalPorImpuestos = ( This.Total - this.TOTALIMPUESTOS ) == lnTotal

				if ( "CONVALORES" $ upper ( this.ObtenerFuncionalidades() ) and this.cContexto == "R" and this.lPercepcionesACtaCte and this.lCambioTotalPorImpuestos )
					if ( pemstatus( this, "ValoresDetalle", 5 ) and this.ValoresDetalle.Count != 0 )
						try
							this.ValoresDetalle.CargarItem( this.ValoresDetalle.Count + 1 )
						catch to loError
							this.ValoresDetalle.LimpiarItem()
						endtry
						this.ValoresDetalle.oItem.Valor_PK = this.cValorCtaCte 
						this.ValoresDetalle.oItem.Recibido = this.TOTALIMPUESTOS  
						this.ValoresDetalle.Actualizar()
					endif
				else
					&& Llamar al equipo naranja si alguna vez algun test tira esta excepcion
					goServicios.errores.LevantarExcepcion( "El recalculo de impuestos modifico el total del comprobante." )
				endif
			EndIf	
		EndIf	
		This.ActualizarCotizacion()

		if llAntesDeGrabar
			if this.lObtenerCodigoGTIN
				llAntesDeGrabar = this.ValidarCodigosGTINEnDetalle()
			endif
		endif

		Return llAntesDeGrabar
	Endfunc	
	
	*-----------------------------------------------------------------------------------------
	protected function ValidarSiPuedoGrabarArticulosSinPrecio() as Boolean
		local llRetorno as Boolean,	lnModoSeguridadArticulosConPrecioCero as Integer, llPasoSeguridad as Boolean
	
		llRetorno = .t.
		lnModoSeguridadArticulosConPrecioCero = this.ObtenerModoSeguridadArticulosConPrecioCero()
		if lnModoSeguridadArticulosConPrecioCero > 1 and this.VerificarArticulosConPrecioCero()
			llPasoSeguridad = .f.
			if inlist( lnModoSeguridadArticulosConPrecioCero, 3, 4 )  && Voy a pedir seguridad
				* Muestro el mensaje y pido seguridad
				this.EventoInformaSeguridadParaArticulosConPrecioCero()
				llPasoSeguridad = goServicios.Seguridad.PedirAccesoEntidad( this.ObtenerNombreOriginal(), "VALIDARARTICULOSINPRECIO" )
			endif
			if llPasoSeguridad
			else
				llRetorno = .f.
			endif
		endif
		return llRetorno  
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerModoSeguridadArticulosConPrecioCero() as Integer
		local lnModoSeguridad as Integer

		lnModoSeguridad = goServicios.Seguridad.ObtenerModo(alltrim(this.ObtenerNombre()) + "_VALIDARARTICULOSINPRECIO")
		return lnModoSeguridad 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function VerificarArticulosConPrecioCero() as Boolean
		local llRetorno, lnI as Integer
		
		llRetorno = .f.
		if pemstatus( This, "FacturaDetalle", 5 ) and vartype( This.FacturaDetalle ) = "O" and this.FacturaDetalle.Count > 0
			for lnI = 1 to this.FacturaDetalle.Count
				if !empty( this.FacturaDetalle.Item(lnI).Articulo_pk ) and this.FacturaDetalle.Item(lnI).Precio = 0
					llRetorno = .t.
					exit
				endif	
			endfor
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoInformaSeguridadParaArticulosConPrecioCero() as Void
		*-- Para que se bindee el kontroler
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AjusteDeRecargoPorSubtotalEnCero() as Void
		if pemstatus( this, "ComprobanteFiscal", 5 ) and this.ComprobanteFiscal and this.Total == 0 and !this.VerificarArticulosConMontoCero()	
			if vartype( goControladorFiscal ) = "O" and goControladorFiscal.VerificarAplicarRecargoPorCambio()
				this.AgregarRecargo( 0.01 )
				this.VerificarRecalculoVuelto()
			endif
			this.SetearFlagRecargoPorCambio( .t. )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function VerificarRecalculoVuelto() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function DespuesDeGrabar() As Boolean
		local llRetorno as Boolean, loError as exception ,loEx as zooexception OF zooexception.prg

		this.EventoDeshabilitarCliente()
		if this.EsComprobanteFiscal() and This.EsEdicion() = .f.
			goControladorFiscal.CambiarEstadoControladorFiscal( This.PuntoDeVenta, This.TipoComprobante, This.Numero, This.Codigo, .T. )
		endif
		
		llRetorno = .T.
		this.llFalloAlImprimir = .f.

		try
			llRetorno = dodefault()
		catch to loError
			loEx = Newobject( "ZooException", "ZooException.prg" )
			With loEx
				.Grabar( loError )
				loTemp = .Obtenerinformacion()
				if loTemp.count > 0
					this.CargarInformacion( .Obtenerinformacion() )
				endif
			endwith
			llRetorno = .F.
		endtry
		
		this.llFalloAlImprimir = !llRetorno
		if llRetorno
			if this.EsComprobanteFiscal() and This.EsEdicion()= .f.
				goControladorFiscal.CambiarEstadoControladorFiscal( This.PuntoDeVenta, This.TipoComprobante, This.Numero, This.Codigo, .F. )
			endif
		else
			if vartype( goControladorFiscal ) = "O" and this.EsComprobanteFiscal() 
				if goControladorFiscal.lEnviarMensajesDeErrorGenericos 
					This.EventoAvisarQueElControladorFiscalEstaFueraDeLinea()
				else
					if this.oInformacion.count > 0
						this.EventoMostrarMensajeDeErrorEspecifico()
					endif
					goControladorFiscal.lEnviarMensajesDeErrorGenericos = .t.
				endif
				Try
					goControladorFiscal.CancelarCF()
				Catch
					this.EventoCancelar()
				Endtry
			else
				if "<CF>" $ This.ObtenerFuncionalidades()
				This.lEliminarComprobantePorFalloDeImpresion = .F.
				This.EventoPreguntarEliminarComprobantePorFalloDeImpresion( This.ObtenerInformacion() )

				if This.lEliminarComprobantePorFalloDeImpresion
					this.AnularoEliminarComprobanteSinMensajes()
					this.limpiar( .T. )
				endif
				else				
					This.EventoAdvertirFalloDeImpresion( This.ObtenerInformacion() )
				endif				
			endif
		endif
		this.EventoHabilitarCliente()
		if this.lDisplayVFD
			this.oColaboradorDisplayVFD.MostrarMensajeDeFinalizacion()
		endif
		this.EventoSetearTituloFormulario()
		lAnuladoAntesDeModificar = .F.
		this.lEstoyGrabando = .f.

		this.LimpiarNombreEntidadAfectada()
		
		Return .T.
		
	Endfunc
	
	*-----------------------------------------------------------------------------------------
	function EventoHabilitarCliente() as Void
		*-- Para que se bindee el kontroler
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoDeshabilitarCliente() as Void
		*-- Para que se bindee el kontroler
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoAvisarQueElControladorFiscalEstaFueraDeLinea() as Void
		*-- Para que se bindee el kontroler
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EventoMostrarMensajeDeErrorEspecifico() as Void
		*-- Para que se bindee el kontroler
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoSetearTituloFormulario() as Void	
		*-- Para que se bindee el kontroler
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
	function EventoAdvertirFalloDeImpresion( toInformacion as ZooInformacion of ZooInformacion.Prg ) as Void
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoPreguntarImprimir( tnRespuestaSugerida as Integer ) as Void
		&&Evento para suscribirse desde el kontroler
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Validar() as boolean
		Local llRetorno as boolean, llFechaValida, llCantidadDeItemsValida as Boolean, llSoloTarjeta as Boolean
		
		this.nCantidadDeErrorres = 0
		 
		llRetorno = dodefault()
		llCantidadDeItemsValida = this.ValidarCantidadItems()
		
		if !isnull(this.FacturaDetalle) and type("this.FacturaDetalle") = "O" and llCantidadDeItemsValida 
			llRetorno = llRetorno and this.oValidadorDetalleArticulos.Validar(this.FacturaDetalle, this)
		else
			llRetorno = llRetorno and llCantidadDeItemsValida 
		endif		

		if This.ValidarTotales()
		else
			this.AgregarInformacion( "Problemas con el total del comprobante", 1 )
			this.nCantidadDeErrorres = this.nCantidadDeErrorres + 1
			llRetorno = .F.
		endif

		if this.EsComprobanteFiscal() and This.EsEdicion() = .f. and !This.ValidarSubTotales()
			this.AgregarInformacion( "Problemas con el subtotal del comprobante", 1 )
			this.nCantidadDeErrorres = this.nCantidadDeErrorres + 1
			llRetorno = .F.
		endif

		if This.ValidarPuntoDeVenta()
		else
			this.AgregarInformacion( "Problemas con el punto de venta", 1 )
			this.nCantidadDeErrorres = this.nCantidadDeErrorres + 1
			llRetorno = .F.
		endif

		if this.ValidarDescuentosYRecargos()
		else
			llRetorno = .F.
		endif
		if this.ValidarDominioVendedor()
		else
			llRetorno = .F.
		endif
	
		if llRetorno and !This.ValidarRestriccionDeDescuentos()
			llRetorno = .F.
			This.AgregarInformacion( This.ObtenerMensajeErrorPorRestriccionDeDescuentos() )
		endif
		
		if this.lContinuaAlSiguienteControl
		else
			llRetorno = .F.

			This.AgregarInformacion( "El cliente " + alltrim( this.cliente.codigo ) + " posee, al menos, un registro de cuenta corriente vencido." )
		endif


		llRetorno = llRetorno and this.ValidarVueltoEnCaja()
		llRetorno = llRetorno and this.ValidarVueltoSegunTipoValor()
		llRetorno = llRetorno and this.ValidarArticulosNoPermitenDevolucion()
		
				
		if this.EsComprobanteFiscal() and (this.ocomponentefiscal.oimpuestosdetalle.count = 3 and gocontroladorfiscal.class = "Hp441f") 
				this.AgregarInformacion( "El controlador fiscal HASAR P-441F no permite más de dos alícuotas de IVA distintas por comprobante.", 1 )
				this.nCantidadDeErrorres = this.nCantidadDeErrorres + 1
				llRetorno = .F.
		endif

		if type( "this.oComponenteFiscal" ) = "O" and !isnull( this.oComponenteFiscal )
			if This.VerificarContexto( "CB" )
			else 
				lcFuncionalidades = This.ObtenerFuncionalidades()
				if ( "<VENTAS>" $ lcFuncionalidades and !"<CF>" $ lcFuncionalidades and "<CONVALORES>" $ lcFuncionalidades ) or;
					this.cNombre = "RECIBO"
					this.SetearDatosFiscalesComprobanteSinPuntoDeVenta()
				else
					this.SetearDatosFiscalesComprobante()
				endif
			endif 

			if this.ValidarTicketExistente()
			else
				if this.lImprimirTicketFaltantes
					this.AgregarInformacion( "Se detectaron problemas en la comunicación con el controlador fiscal. " + ;
						"Por favor revíselo e intente nuevamente.", 1 )
				else
					this.AgregarInformacion( "Comprobante " + this.Letra + " " + transform( this.PuntoDeVenta, "@LZ 9999" ) + "-" + transform( this.Numero, "@LZ 99999999" ) + " ya existente.", 1 )
				endif
				this.nCantidadDeErrorres = this.nCantidadDeErrorres + 1
				llRetorno = .F.
			endif

			if this.esEdicion() 
				llFechaValida = .t.
			else
				llFechaValida = this.oComponenteFiscal.ValidarFechaComprobanteFiscal( this.Fecha )				
			endif 

			if This.VerificarContexto( "CB" ) or llFechaValida
			else
				this.AgregarInformacion( "La fecha del comprobante no coincide con la fecha del controlador fiscal", 1 )
				this.nCantidadDeErrorres = this.nCantidadDeErrorres + 1
				llRetorno = .F.
			endif 

			if this.oComponenteFiscal.ValidarItemsDetalleArticulos( this.FacturaDetalle )
			else
				this.AgregarInformacion( "Problema con los artículos", 1 )
				this.nCantidadDeErrorres = this.nCantidadDeErrorres + 1
				llRetorno = .F.
			endif

			if !empty( this.Cliente_PK )
				if this.oComponenteFiscal.ValidarClienteParaComprobanteFiscal( this.Cliente, this.Total )
				else
					this.AgregarInformacion( "Debe completar datos del cliente", 1 )
					this.nCantidadDeErrorres = this.nCantidadDeErrorres + 1
					llRetorno = .F.
				endif 

				if this.oComponenteFiscal.ValidarTotalComprobantePersonalizado( this.Total, this.SimboloMonetarioComprobante )
				else
					This.AgregarInformacion( "Se ha superado el límite permitido", 1 )
					this.nCantidadDeErrorres = this.nCantidadDeErrorres + 1
					llRetorno = .F.
				endif 
			else
				llSoloTarjeta = iif( pemstatus( this, "ValoresDetalle", 5 ) and pemstatus( this.ValoresDetalle, "lSoloHayValoresTarjetaOPagoElectronico", 5 ),;
										this.ValoresDetalle.lSoloHayValoresTarjetaOPagoElectronico, .f. )
				if this.oComponenteFiscal.ValidarTotalComprobanteSinPersonalizar( this.Total, this.SimboloMonetarioComprobante, llSoloTarjeta )
				else
					this.AgregarInformacion( "Se ha superado el límite permitido", 1 )
					this.nCantidadDeErrorres = this.nCantidadDeErrorres + 1
					llRetorno = .F.
				endif
			endif
			
			if this.ValidarNumeroDeTicketMayorACero()
			else
				this.AgregarInformacion( "El número del comprobante debe ser mayor a 0", 1 )
				this.nCantidadDeErrorres = this.nCantidadDeErrorres + 1
				llRetorno = .F.
			endif


			if this.ValidarNumeroDeTicketDistintoDeCero()
			else
				this.AgregarInformacion( "Hubo problemas con el controlador fiscal: No se pudo obtener numeración. Verifique el controlador fiscal y reintente la operación.", 1 )
				this.nCantidadDeErrorres = this.nCantidadDeErrorres + 1
				llRetorno = .F.
			endif	
			if this.Total == 0 and this.VerificarArticulosConMontoCero()	
				this.AgregarInformacion( "No se puede realizar un " + this.cdescripcion + " donde todos sus ítems tienen el Monto en 0", 1 )
				this.nCantidadDeErrorres = this.nCantidadDeErrorres + 1
				llRetorno = .F.		
			endif
			
			if pemstatus( this, "ImpuestosComprobante",5 ) and vartype( This.ImpuestosComprobante ) == "O" and !isnull( This.ImpuestosComprobante )
				if  this.oComponenteFiscal.ValidarCantidadDePercepciones( This.ImpuestosComprobante.count ) 
				else
					this.AgregarInformacion( "No se podrá grabar el comprobante debido a que contiene " + transform( This.ImpuestosComprobante.count ) + " percepciones y el controlador fiscal soporta un máximo de " + transform( this.ObtenerCantidadMaximaDePercepciones() ) , 1 )
					this.nCantidadDeErrorres = this.nCantidadDeErrorres + 1
					llRetorno = .F.
				endif
			endif
			
		endif
		
		if this.ValidarSiPuedoGrabarArticulosSinPrecio()
		else
			This.AgregarInformacion( "No posee permisos para grabar un comprobante que tiene ítems con precio en 0.", 1 )
			this.nCantidadDeErrorres = this.nCantidadDeErrorres + 1
			llRetorno = .F.
		endif
		
		if this.nCantidadDeErrorres > 1
			this.AgregarInformacion( "Problemas con la grabación del comprobante", 1 )
		endif

		Return llRetorno
	Endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerCantidadMaximaDePercepciones() as Void
	local lnRetorno as Integer
		if vartype( goControladorFiscal ) = 'O'
			lnRetorno = goControladorFiscal.ObtenerCantidadMaximaDePercepciones()
		Endif	
		return lnRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarCliente() as boolean
		local lcTexto As String, llRetorno as boolean

		llRetorno = dodefault()

		if empty( This.Cliente_Pk )
			lcTexto = "No esta permitido dejar el Cliente vacio "
			if This.lClienteObligatorio
				this.AgregarInformacion( lcTexto + "cuando se realiza un comprobante de este tipo" )
				llRetorno = .F.
			endif
			if goParametros.Felino.GestionDeVentas.Minorista.ForzarCargaDeMailingDeClientes
				this.AgregarInformacion( lcTexto + "porque tiene configurado 'Forzar Carga de Mailing de Cliente'" )
				llRetorno = .F.
			EndIf
		endif
		
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------		
	function ValidarPuntoDeVenta() as boolean

		local llRetorno as boolean
		llRetorno = dodefault()
		
		if this.PuntoDeVenta>0
		else
			this.agregarInformacion( "Deberá ingresar el punto de venta para grabar el comprobante" )
			llRetorno = .F.
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
	Function ValidarSubTotales() As boolean
		Local llRetorno As boolean, lnTotalFactura As Float

		llRetorno = dodefault()
		
		If this.SubtotalBruto < 0 or this.SubtotalNeto < 0
			this.agregarInformacion( "El subtotal del comprobante no puede ser negativo." )
			llRetorno = .F.
		Endif

		Return llRetorno
	
	endfunc	

	*-----------------------------------------------------------------------------------------
	function EventoPreguntarEliminar( ) as Void
		&&Evento para suscribirse desde el kontroler
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoMensajesDeClienteConCuentaCorrienteVencida( tnCtaCteImpagaVencida as Integer ) as Void

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
				this.AgregarInformacion( "Debe agregar por lo menos un artículo al comprobante" )
				llRetorno = .F.
			EndIf
		EndIf
		Return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function VerificarArticulosConMontoCero() As Boolean
		Local llRetorno As boolean, lConMontoEnCero as Boolean, loItem as Object

		llRetorno = .f.
		if this.esComprobantefiscal() and type( "This.FacturaDetalle" ) == "O"
			lConMontoEnCero =.t.	
			for each loItem in this.FacturaDetalle FOXOBJECT
				if ( loItem.Monto) != 0  
					lConMontoEnCero =.F.
					exit
				endif
			endfor
			llRetorno = lConMontoEnCero
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
			case inlist( lnPais, 1, 3 )
				.EventoPreguntarAnular( .Letra + " " + transform( .PuntoDeVenta, "@LZ 9999" ) + "-" + transform( .Numero, "@LZ 99999999" ) )

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
	protected function SetearDatosPreferentesDelClienteSeleccionado( tcClienteSeleccionado as String ) as Void
		local lcListaDePrecios as String, loEx as zooexception OF zooexception.prg, loError as Exception

		if empty( tcClienteSeleccionado ) or empty( This.Cliente.Vendedor_PK )
		else
			if this.lCambioCliente 
				if pemstatus(this, "DireccionEntrega", 5)
					this.DireccionEntrega = ""
				endif
				if !empty( This.Cliente.Vendedor_PK ) and this.ValidarVendedorActivo( This.Cliente.Vendedor_PK )
					try
						This.Vendedor_PK = This.Cliente.Vendedor_PK
					catch to loError
						This.Vendedor_PK = ""
						loEx = Newobject( "ZooException", "ZooException.prg" )
						loEx.Grabar( loError )
						if loEx.nZooErrorNo == 9001
							this.agregarInformacion( "El código de vendedor preferente del alta del cliente no existe." )
						else
							loEx.Throw()
						endif
					endtry
				endif
			Endif	
		endif
		
		this.lMostrarAdvertenciaRecalculoPrecios = .f.
		if this.lCambioCliente and !This.VerificarContexto( "B" ) and this.CambiarListadepreciosSegunTipoEnBaseA()
			
			lcListaDePrecios = this.ObtenerListaDePreciosValidoDelCliente( tcClienteSeleccionado )
			this.SetearListaDePrecioPorCambioDeCliente( lcListaDePrecios )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarVendedorActivo( tcVendedor as string ) as Boolean
		local llRetorno as Boolean
		llRetorno = .T.
		if pemstatus( This.Cliente.Vendedor, "InactivoFW", 5 )
			llRetorno = !This.Cliente.Vendedor.InactivoFW
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Setear_Cliente( txVal ) as void
		local lnSitFiscalCliCompFiscal as Integer 
		
		if this.lCambioCliente
			if this.lMostrarSaldoDeLaCuentaCorrienteEnFacturaNDebyNCred or this.lAdvertirSiSuperaLimiteDeCredito
				this.CalcularDeudaCCyCheque() 
			endif

			this.lYaCalculoRemitosPendientes = .F.

			if this.lAdvertirSiSuperaLimiteDeCredito
				this.ObtenerTopeDelCliente()  
				if this.nTopeDelCliente > 0 and !empty( txVal )
					this.nTotalAnterior = 0
					this.AdvertirSobrepasoDeCreditoPorCambioDeTotal( 0 )
				endif
			endif
			
		endif
		
		if This.CargaManual()
			
			if this.cContexto != "I"
				this.ValidarClienteConCuentaCorrienteVencida()
			endif
								
			if this.lContinuaAlSiguienteControl
				dodefault( txVal )
				try
	 				this.SetearDatosPreferentesDelClienteSeleccionado( txVal  )
				catch to loError
					throw loError
				finally
					this.lMostrarAdvertenciaRecalculoPrecios = .t.
				endtry 
				
				if type( "this.oComponenteFiscal" ) = "O"
					with this.oComponenteFiscal
						lnSitFiscalCliCompFiscal = .ObtenerSituacionFiscalCliente()
						if ( this.lHuboCambioSituacionFiscal )
							this.SetearDatosAComponenteFiscal()
							if this.lHuboCambioSituacionFiscal
								this.LimpiarOItemDetalleComprobante()
								this.RecalcularPreciosDeDetallesAdicionales( this.ListaDePrecios_PK )
								this.ActualizarDetalleArticulos()
							endif
							this.RecalcularImpuestosDetalleArticulos()
						else
							if this.lCambioCliente and vartype( this.oComponenteFiscal.oComponenteImpuestos ) = "O"
								this.oComponenteFiscal.oComponenteImpuestos.CodigoCliente = this.Cliente_PK
								this.oComponenteFiscal.oComponenteImpuestos.RestaurarColeccionImpuestosComprobante()
							endif
							if this.lCambioCliente and this.AplicaPercepciones() 
								this.SetearDatosAComponenteFiscal()
								this.RecalcularImpuestosDetalleArticulos()
							endif
						endif
					endwith
				endif

				this.SetearDatosFiscalesComprobante()
							
				if this.lCambioCliente and this.TieneDescuentoAutomatico()
					This.SetearDescuentoPreferente()
				endif
				This.CalcularTotal()
				
				&& Actualizar nivel y descuento del cliente cuando se asigna un nuevo cliente
				if this.lCambioCliente and !empty( txVal )
					this.ActualizarNivelYDescuentoDeCliente()
				endif
				
				this.EventoSetear_Cliente( txVal )
			endif
		endif			
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarClienteConCuentaCorrienteVencida() as void
		local lnCtaCteFacturaImpagaVencida as Integer, llClienteValido as Boolean, lnCtaCteRemitoImpagaVencida as Integer,;
			 llEsRemitoConParamCCVencido as Boolean, llEsFacturaConParamCCVencido as Boolean

		lnCtaCteFacturaImpagaVencida = goparametros.felino.gestiondeventas.cuentacorriente.permitefacturarconcuentacorrientevencidaimpaga
		lnCtaCteRemitoImpagaVencida = goparametros.felino.gestiondeventas.cuentacorriente.permiteremitirconcuentacorrientevencidaimpaga
		llClienteValido = .t.
		llEsRemitoConParamCCVencido = inlist( lnCtaCteRemitoImpagaVencida, 2, 3, 4 ) and  this.TipoComprobante = 11
		llEsFacturaConParamCCVencido = inlist( lnCtaCteFacturaImpagaVencida, 2, 3, 4 ) and  inlist( this.TipoComprobante,1,2,27,33,47,54 )

		if !empty( this.Cliente_pk ) and (llEsRemitoConParamCCVencido or llEsFacturaConParamCCVencido )
				llClienteValido = !this.ContieneCtaCteDeClienteVencidaNoPaga( alltrim( this.Cliente_pk ) )

			if !llClienteValido
				if ( this.TipoComprobante = 11 and lnCtaCteRemitoImpagaVencida = 2 ) or ( llEsFacturaConParamCCVencido and lnCtaCteFacturaImpagaVencida = 2 ) 
					this.lContinuaAlSiguienteControl = .f.
				endif
				
				if this.lCambioCliente or !this.lContinuaAlSiguienteControl
					this.EventoMensajesDeClienteConCuentaCorrienteVencida( iif( this.TipoComprobante = 11, lnCtaCteRemitoImpagaVencida, lnCtaCteFacturaImpagaVencida ))
				endif
				
				if !this.lBindeoConMensajesDeCtaCteVencida
					if this.TipoComprobante = 11
						this.lContinuaAlSiguienteControl = iif( inlist( lnCtaCteRemitoImpagaVencida, 1, 4 ), .t., .f. )
					else
						this.lContinuaAlSiguienteControl = iif( inlist( lnCtaCteFacturaImpagaVencida, 1, 4 ), .t., .f. )
					endif
				endif
			endif
		endif
		
		if llClienteValido
			this.lContinuaAlSiguienteControl = .t.
		endif
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ContieneCtaCteDeClienteVencidaNoPaga( tcCliente as String ) as Boolean
	local lcSentencia as String, llRetorno as Boolean, lcBaseDeDatos as String, lcProducto as String
	llRetorno = .F.
	lcSentencia = ""
	lcBaseDeDatos = alltrim( _screen.zoo.app.cSucursalActiva )
	lcProducto = alltrim(_screen.zoo.app.NombreProducto )
	lcCursorComprobantesVencidos = sys(2015)
	
	lcSentencia = lcSentencia +  "select top 1 CLi.CLCOD from [" + lcProducto + "_" + lcBaseDeDatos + "].Funciones.ObtenerCtaCteExtendida(1) as CTA "
	lcSentencia = lcSentencia +  "inner join [" + lcProducto + "_" + lcBaseDeDatos + "].[ZOOLOGIC].[CLI] as CLI on CLI.CLCOD = CTA.CLIENTE " 
	lcSentencia = lcSentencia +  "where (CLIENTE between '" + tcCliente + " 'and '" + tcCliente + "') and ( CTA.saldocc <> 0 or ( 1 = 1 "
	lcSentencia = lcSentencia +  "and  CTA.Origen = 'Cheque' and ( CTA.EnDebe - CTA.EnHaber <> 0 ) ) ) "
	lcSentencia = lcSentencia +  "and cta.FECHAVEN > '' and cta.FECHAVEN < funciones.datetime() and signo > 0"
	
	goServicios.Datos.EjecutarSentencias( lcSentencia, "CTACTE", "", lcCursorComprobantesVencidos, this.DataSessionId )
	
	lnCantidadComprobantes = reccount( lcCursorComprobantesVencidos )
		
	llRetorno = iif( lnCantidadComprobantes > 0, .t., .f. )
	
	use in select( "lcCursorComprobantesVencidos" )
	return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearListaDePrecioPorCambioDeCliente( tcListaDePrecios as String ) as Void
		local loError as Object, llcarga as Boolean  
		if upper(alltrim( this.ListaDePrecios_PK )) != upper(alltrim( tcListaDePrecios ))
			try
				this.ListaDePrecios_PK = tcListaDePrecios
				this.eventoActualizaColorListaDePrecio( .t. )
			catch to loError
				if this.cContexto == "R" and !this.lVieneDeEcommerce
					goServicios.Errores.LevantarExcepcion( loError.UserValue.oInformacion.Item(1).cMensaje )
				else
					goServicios.Mensajes.Advertir( loError.UserValue.oInformacion.Item(1).cMensaje )
				endif
			finally
			endtry
		endif 
	endfunc

	*-----------------------------------------------------------------------------------------
	function eventoActualizaColorListaDePrecio( tlExiste ) as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function SetearDescuentoPreferente() as void
		local llSeteaEnBlanco as Boolean, lcMensajeDeError as String
		if this.EsNuevo() and !this.lLimpiando &&this.lComprobanteConDescuentosAutomaticos and
			this.oColDescuentoAltas = _screen.zoo.crearobjeto( "ZooColeccion" )
			if !empty( this.Cliente.DescuentoPreferente_PK )
				if this.ExisteEnEntidadForanea( this.Cliente, "DescuentoPreferente" )
					if pemstatus( this.Cliente.DescuentoPreferente, "nEvitar", 5 ) 
						this.Cliente.DescuentoPreferente.nEvitar = 1
					else
						this.Cliente.DescuentoPreferente.addProperty( "nEvitar", 1)
					endif
					this.oColDescuentoAltas.Add( this.Cliente.DescuentoPreferente ) 
				else
					this.AgregarInformacionSiNoExiste("El codigo de descuento '" + alltrim( this.Cliente.DescuentoPreferente_pk ) + "' no se pudo aplicar")
				endif
			endif
			
			if !empty( this.Vendedor.DescuentoPreferente_PK )
				if this.ExisteEnEntidadForanea( this.Vendedor, "DescuentoPreferente" )
					if pemstatus( this.Vendedor.DescuentoPreferente, "nEvitar", 5 ) 
						this.Vendedor.DescuentoPreferente.nEvitar = 1
					else
						this.Vendedor.DescuentoPreferente.addProperty( "nEvitar", 1)
					endif
					this.oColDescuentoAltas.Add( this.Vendedor.DescuentoPreferente ) 
				else
					this.AgregarInformacionSiNoExiste("El codigo de descuento '" + alltrim( this.Vendedor.DescuentoPreferente_pk ) + "' no se pudo aplicar")
				endif
			endif
			
			if !empty( this.ListaDePrecios.DescuentoPreferente_PK )
				if this.ExisteEnEntidadForanea( this.ListaDePrecios, "DescuentoPreferente" )
					if pemstatus( this.ListaDePrecios.DescuentoPreferente, "nEvitar", 5 ) 
						this.ListaDePrecios.DescuentoPreferente.nEvitar = 1
					else
						this.ListaDePrecios.DescuentoPreferente.addProperty( "nEvitar", 1)
					endif
					this.oColDescuentoAltas.Add( this.ListaDePrecios.DescuentoPreferente ) 
				else
					this.AgregarInformacionSiNoExiste("El codigo de descuento '" + alltrim( this.ListaDePrecios.DescuentoPreferente_pk ) + "' no se pudo aplicar")
				endif
			endif
			this.ResolverAplicar()
			this.lCargando = .F.			
		EndIf
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ResolverAplicar() as Void
		if this.oColDescuentoAltas.Count > 0
			this.OrdenarDescuentos( this.oColDescuentoAltas )
			this.oCompDescuentos.SetearDescuentoPreferente( this.oColDescuentoAltas )
		else
			this.oCompDescuentos.SetearDescuentoPreferente( null )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerSituacionFiscalCliente() as Void
		return this.Cliente.ObtenerSituacionFiscalValidoCliente()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function OrdenarDescuentos( toDescuentos as ZooColeccion OF ZooColeccion.prg ) as Void
		local lnCambios as Number
		if toDescuentos.Count > 1
			lnCambios = this.Recorrer( toDescuentos )
			for i = 1 to lnCambios
				this.Recorrer( toDescuentos )
			endfor
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function Recorrer( toDescuentos as ZooColeccion OF ZooColeccion.prg ) as number
		local loPivot as Object, lnCambios as Number
		lnCambios = 0
		for i = 1 to toDescuentos.Count
			for j = i+1 to toDescuentos.Count
				if toDescuentos.Item[i].Orden < toDescuentos.Item[j].orden
					loPivot = toDescuentos.Item[i]
					toDescuentos.Remove(i)
					toDescuentos.add( loPivot )
					lnCambios = lnCambios + 1
				endif
			endfor
		endfor
		return lnCambios
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerListaDePreciosValidoDelCliente( txVal as Variant ) as String
		local lcListaDePrecios as String

		do case
			case this.VerificarContexto( "B" )
				lcListaDePrecios = ""
			case this.VerificarContexto( "I" )
				if empty( this.ListaDePrecios_PK )
					lcListaDePrecios = this.ListaDePreciosPreferente
				else
					lcListaDePrecios = This.ListaDePrecios_PK
				endif				
			otherwise
				lcListaDePrecios = this.ListaDePreciosPreferente
		endcase
		
		if this.DebeSetearListaDePrecio( txVal ) 
			if this.ExisteEnEntidadForanea( this.Cliente, "ListaDePrecio" )
				lcListaDePrecios = This.Cliente.ListaDePrecio_PK
			else
				if goParametros.Felino.Precios.ListasDePrecios.AlertarPorCambioALaListaDefaultCuandoLaListaPreferenteDelClienteEsInexistente
					this.agregarInformacion( "El código de Lista de precios del alta del cliente no existe." )
				endif
			endif			
		endif
		
		return lcListaDePrecios
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearDatosAComponenteFiscal() as Void
		if type( "this.oComponenteFiscal" ) = "O"
			with this.oComponenteFiscal	
				.SetearCodigoCliente( this.Cliente_PK )
				.SetearTipoConvenioCliente( this.Cliente.TipoConvenio )
				if this.EsEdicion()
					.SetearSituacionFiscalCliente( this.SituacionFiscal_pk )
				else
					.SetearSituacionFiscalCliente( this.ObtenerSituacionFiscalCliente() )
				endif
				.CargarImpuestos()
			endwith
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function MostrarAdvertenciaRecalculoPrecios() as Boolean
		local lcMensaje as string, llRetorno as Boolean

		llRetorno = .t.
		if this.DebeMostrarAdvertenciaRecalculoPrecios()
			lcMensaje = this.ObtenerMensajeAdvertenciaRecalculoPrecios()
			llRetorno = this.oMensaje.Advertir( lcMensaje, 4 ) = 6
			If llRetorno
				this.lHuboCambioSituacionFiscal = this.lCambioSituacionFiscal
				this.lHuboCambioListaPrecios = this.lCambioListaPrecios
			Else
				this.lCambioSituacionFiscal = .f.
				this.lCambioListaPrecios = .f.	
			Endif
		endif
				
		if this.DebeMostrarAdvertenciaRecalculoPrecios() or this.ObtenerCantidadDeArticulosCargados() = 0
		endif
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerMensajeAdvertenciaRecalculoPrecios() as String
		local lcMensaje as String, lcSituacionFiscal as String, lcListaP as String, lcBorrarPromociones as String, lcRecalculaItemSenia as String
		
		llOpcionParametro = goParametros.Felino.GestionDeVentas.Minorista.RecalcularPrecioDeArticulosConSenaPorCambioDeListaDePrecios
		
		if this.lCambioSituacionFiscal
			lcSituacionFiscal = "- Situación fiscal del cliente." + chr(13) + chr(10)
		else
			lcSituacionFiscal = ""
		endif
		
		if this.lCambioListaPrecios
			lcListaP = "- Lista de precios." + chr(13) + chr(10)
		else
			lcListaP = ""
		endif
		if This.SoportaPromociones() and this.PromocionesDetalle.CantidadDeItemsCargados() > 0
			lcBorrarPromociones = "Se eliminarán todas las promociones y sus beneficios, y en caso de existir promociones automáticas serán evaluadas de nuevo." + chr(13) + chr(10)
		Else
			lcBorrarPromociones = ""
		endif
		if llOpcionParametro and this.ExistenItemsAsociadosASenia()
			lcRecalculaItemSenia = " (incluídos los artículos señados)"
		else
			lcRecalculaItemSenia = ""
		endif
		
		text to lcMensaje textmerge noshow pretext 1+2
			Atención se detectaron los siguientes cambios: 
			<<chr( 9 )>><< lcSituacionFiscal >><<chr( 9 )>><< lcListaP >>
			Los precios ingresados manualmente se establecerán en cero y los que provienen de lista de precios se recalcularán<<lcRecalculaItemSenia>>. 
			<<lcBorrarPromociones>>Verifique que los importes sean los esperados.
			
			¿Desea continuar?
		endtext
		
		return lcMensaje
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ExistenItemsAsociadosASenia() as Boolean
		local llRetorno as Boolean
		
		if pemstatus( this, "FacturaDetalle", 5 )
			for lnI = 1 to This.FacturaDetalle.Count
				if !empty( This.FacturaDetalle.Item[lnI].IDSeniaCancelada )
					llRetorno = .T.
					exit for
				endif
			endfor
		endif
	
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function SoportaPromociones() as Boolean
		local lcFuncionalidades as String
		lcFuncionalidades = this.ObtenerFuncionalidades()
		return "<PROMO>" $ lcFuncionalidades or "<PROMO_PRINCIPAL>" $ lcFuncionalidades
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoRefrescarGrillaArticulos() as Void
		&& Para que se enganche el kontroler y me refresque la grilla de articulos
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoRecalcularImpuestos() as Void
		&& Para que se enganche alguien
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

		local loError as Object, lnDescuentos as Integer, lnRecargos as Integer, lnAjustes as Float, lnTotal as Float
		if type( "this.FacturaDetalle" ) = "O" and this.CargaManual()
			with this
				try
					.lCargando = .T.
					.Recalcular()
					lnDescuentos = goLibrerias.RedondearSegunPrecision(.MontoDescuentoSinImpuestos + .MontoDescuentoSinImpuestos1 + .MontoDescuentoSinImpuestos2 + .MontoDescuentoSinImpuestos3, PRECISIONENMONTOS)
					lnRecargos = goLibrerias.RedondearSegunPrecision(.RecargoMontoSinImpuestos + .RecargoMontoSinImpuestos1 + .RecargoMontoSinImpuestos2, PRECISIONENMONTOS)

					.ActualizarDescuentosYRecargosEnComponenteFiscal()
					.SumarPercepciones()
					.SumarGravamenes()

					.Percepciones = goLibrerias.RedondearSegunMascara( .SumPercepciones )
					.Gravamenes = goLibrerias.RedondearSegunMascara( .SumGravamenes )


					lnTotal = .FacturaDetalle.Sum_Neto - lnDescuentos + lnRecargos + ;
								goLibrerias.RedondearSegunMascara( .Percepciones ) + ;
								goLibrerias.RedondearSegunMascara( .Gravamenes ) + ;
								.ImpuestosDetalle.Sum_Montodeiva					
					
					lnAjustes = iif( .oComponenteFiscal.MostrarImpuestos(), .FacturaDetalle.Sum_AjustePorRedondeoConImpuestos, .FacturaDetalle.Sum_AjustePorRedondeoSinImpuestos )
					.AjustesPorRedondeos = goLibrerias.RedondearSegunMascara( lnAjustes )
					
					if !this.lAjustePorResiduoCentavo
						.nResiduo = this.ObtenerAjustePorCentavoResidual( lnTotal )
					endif
					
					.TotalImpuestos =  goLibrerias.RedondearSegunMascara( .Percepciones + .Gravamenes + .nResiduo )
					lnTotal = lnTotal + .nResiduo

					.AsignarTotalComprobante( lnTotal )
					.CalcularCoeficienteDeImpuestos()
				catch to loError
					goServicios.Errores.LevantarExcepcion( loError )
				finally 
					.lCargando = .F.
				endtry
			endwith
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerAjustePorCentavoResidual( tctotal as float ) as float
		&& metodo para sobreescribir en comprobantes con valores
		return 0 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function DisplayVFDMostrarTotalEnDetalle() as Void
		this.CalcularTotal()
		this.oColaboradorDisplayVFD.ActualizarTotal( this.total, this.totalCantidad )
	endfunc

	*-----------------------------------------------------------------------------------------
	function SumarPercepciones()
		local lnIndice as Integer

		this.SumPercepciones = 0
		for lnIndice =  1 to this.ImpuestosComprobante.count
			this.SumPercepciones = this.SumPercepciones + this.ImpuestosComprobante.Item[lnIndice].Monto
		endfor
		this.SumPercepciones = goLibrerias.RedondearSegunPrecision( this.SumPercepciones, PRECISIONENMONTOS )
	endfunc

	*-----------------------------------------------------------------------------------------
	function SumarGravamenes()
		local lnIndice as Integer
		this.SumGravamenes = 0
		for lnIndice =  1 to this.ImpuestosDetalle.Count && this.FacturaDetalle.count
			this.SumGravamenes = this.SumGravamenes + this.ImpuestosDetalle.Item[lnIndice].montodeimpuestointerno
		endfor
		this.SumGravamenes = goLibrerias.RedondearSegunPrecision( this.SumGravamenes, PRECISIONENMONTOS )
	endfunc

	*-----------------------------------------------------------------------------------------
	function SetearDatosFiscalesComprobante() as Void
		if type( "this.oComponenteFiscal" ) = "O"
			with this
				if empty( .Letra ) or ( !This.VerificarContexto( "I" ) and !( This.VerificarContexto( "R" ) and !this.TieneTalonarioManual() ) ) or ( This.VerificarContexto( "R" ) and this.lVieneDeEcommerce )
					this.lObteniendoLetra = .t.
					if .esEdicion() or .esNuevo()
						.oComponenteFiscal.SetearSituacionFiscalCliente( .Cliente.SituacionFiscal_PK )
					endif
					if .esNuevo() or ( .esEdicion() and this.lCambioCliente ) 
						.Letra = this.ObtenerLetra()
						this.ObtenerLetraCpteRelacionado()					
					endif
					this.lObteniendoLetra = .f.
				endif
				 
				if empty( .PuntoDeVenta ) or ( !This.VerificarContexto( "I" ) and !( This.VerificarContexto( "R" ) and !this.TieneTalonarioManual() ) ) or ( This.VerificarContexto( "R" ) and this.lVieneDeEcommerce )
					.PuntoDeVenta = this.ObtenerPuntoDeVenta()
				endif
				
			endwith
		EndIf
	endfunc  

	*-----------------------------------------------------------------------------------------
	function ObtenerLetra() as String
		local lcLetra as String
		
		lcLetra = this.oComponenteFiscal.ObtenerLetra()
		return lcLetra
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerLetraCpteRelacionado()
		if !this.lEstoyGrabando and pemstatus( this, "LetraCpteRelacionado", 5 ) and type( "this.oComponenteFiscal" ) = "O"
			if This.RequiereComprobanteAsociadoObligatorio()
				this.LetraCpteRelacionado = this.Letra
			endif
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerPuntoDeVenta() as Integer
		local lnPuntoDeVenta as Integer, lcFuncionalidades as String
		lcFuncionalidades = this.ObtenerFuncionalidades()
		lnPuntoDeVenta = this.oComponenteFiscal.ObtenerPuntoDeVenta( this.letra, this.cComprobante, lcFuncionalidades  )
		if empty( lnPuntoDeVenta )
			lnPuntoDeVenta = this.ObtenerPuntoDeVentaUnicoPorEntidadDesdeTalonarioYSetearParametroFaltante()
		endif
		return lnPuntoDeVenta
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerPuntoDeVentaUnicoPorEntidadDesdeTalonarioYSetearParametroFaltante() as Integer
		local lnPuntoDeVenta as Integer
		lnPuntoDeVenta = this.oNumeraciones.ObtenerPuntoDeVentaUnicoPorEntidadDesdeTalonario()
		if !empty( lnPuntoDeVenta )
			this.oComponenteFiscal.SetearParametroPuntoDeVenta( lnPuntoDeVenta )
		endif
		return lnPuntoDeVenta
	endfunc 

	*-----------------------------------------------------------------------------------------
	function PedirSeguridadParaAplicarDescuentos() as Boolean
		local llRetorno as Boolean
		llRetorno = .f.
		llRetorno = goServicios.Seguridad.PedirAccesoEntidad( this.ObtenerNombreOriginal(), "DESCUENTOCOMPROBANTE" )
		if !llRetorno
			goServicios.Errores.LevantarExcepcion( "No posee permisos para ingresar un descuento." )
		endif
		
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function Validar_PorcentajeDescuento( txVal as Variant ) as Boolean
		local llRetorno as Boolean
		llRetorno = .f.
		if txVal > 100
			goServicios.Errores.LevantarExcepcion( "No se puede asignar un porcentaje de descuento mayor a 100." )
		else
			llRetorno = This.Validar_DescuentoGenerico( "PorcentajeDescuento", txVal )
		endif
		if llretorno and txVal = 0 and this.DescuentoAutomatico
			this.lComprobanteConDescuentosAutomaticos = .f.
			this.DescuentoAutomatico = .f.
		endif
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Validar_PorcentajeDescuento1( txVal as Variant ) as Boolean
		return This.Validar_DescuentoGenerico( "PorcentajeDescuento1", txVal )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Validar_PorcentajeDescuento2( txVal as Variant ) as Boolean
		return This.Validar_DescuentoGenerico( "PorcentajeDescuento2", txVal )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Validar_MontoDescuento3( txVal as variant ) as Boolean
		local llRetorno

		llRetorno = This.Validar_DescuentoGenerico( "MontoDescuento3", txVal )	

 		if this.lEstoyCargandoDescuentosAutomaticos or this.lEstaSeteandoValorSugerido 
		else	
			llRetorno = llRetorno and This.ValidacionMontoDescuento3( txVal )
		endif
					
		if llretorno and txVal = 0 and this.DescuentoAutomatico
			this.lComprobanteConDescuentosAutomaticos = .f.
			this.DescuentoAutomatico = .f.
		endif
	
		this.lCambioMontoDescuentoGeneral = iif( abs ( This.MontoDescuento3 - txVal ) < 0.01 or  txVal < 0 , .f., llRetorno )
			
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Validar_DescuentoGenerico( tcAtributo as String, txVal as Variant ) as Boolean
		local llRetorno as Boolean, lcAtributo As String
		llRetorno = .f.
		lcAtributo = "This." + tcAtributo
		
		if &lcAtributo = txVal or txVal < 0
			&&No se ejecuta el Setear ya que el valor es igual al Anterior.	
		else
			if &lcAtributo < txVal
				if this.PedirSeguridadParaAplicarDescuentos()
					llRetorno = dodefault( txVal )
				endif
			else
				llRetorno = dodefault( txVal )
			endif
			if ( llRetorno and txVal <> 0 and this.SignoDeMovimiento = 1 )
				llRetorno = !this.ValidarSiExistenItemsConRestriccionDeDescuentos()
				if !llRetorno
					goServicios.Errores.LevantarExcepcion( This.ObtenerMensajeErrorPorRestriccionDeDescuentos() )
				endif
			endif
		endif

		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function Setear_PorcentajeDescuento( txPorcentajeDescuento as variant ) as Void
		with this
			dodefault( txPorcentajeDescuento )
			if .CargaManual()
				.DespuesDeSetearDescuento()
			endif
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Setear_PorcentajeDescuento1( txPorcentajeDescuento as variant ) as Void
		with this
			dodefault( txPorcentajeDescuento )
			if .CargaManual()
				.DespuesDeSetearDescuento()
			endif
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Setear_PorcentajeDescuento2( txPorcentajeDescuento as variant ) as Void
		with this
			dodefault( txPorcentajeDescuento )
			if .CargaManual()
				.DespuesDeSetearDescuento()			
			endif
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Setear_MontoDescuento3( txVal as variant ) as void
		with this
			if this.lCambioMontoDescuentoGeneral and this.DebeQuitarImpuestosAlDescuento()
				this.nMontoDeDescuento3IngresadoManualmente = txVal
			endif
			dodefault( txVal )
			if .CargaManual()
				.DespuesDeSetearDescuento()
			endif
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function DespuesDeSetearDescuento() as Void
		with This
			if type( "this.FacturaDetalle" ) = "O"
				.CalcularTotal()
				if this.lDisplayVFD
					.oColaboradorDisplayVFD.ActualizarTotal( this.total, this.totalCantidad )
				endif
			endif
		EndWith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Validar_RecargoPorcentaje( txVal as Variant ) as Boolean
		local llRetorno as Boolean

		if this.nRecargoPorcentajeAnterior = txVal and this.lSuperoSaldoCC
			this.EventoMensajeBlanquearErrorPrecio()
		endif

		llRetorno = This.Validar_RecargoGenerico( "RecargoPorcentaje", txVal )

		if this.lSuperoSaldoCC
			this.lSuperoSaldoCC = .f.
		endif

		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Validar_RecargoMonto1( txVal, lxValOld ) as Boolean
		local llRetorno as Boolean, lnTotalAnt as Integer

		lnTotalAnt = this.nTotalAnterior

		llRetorno = This.Validar_RecargoGenerico( "RecargoMonto1", txVal )

		if this.lSuperoSaldoCC
			This.CalcularTotal()
			if txVal > 0
				if lnTotalAnt = this.total
					this.EventoMensajeBlanquearErrorPrecio()
				else
					this.lSuperoSaldoCC = .f.
				endif
			else
				if this.RecargoMonto1 = 0
					this.lSuperoSaldoCC = .f.
				endif
			endif
		endif
		
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Validar_RecargoMonto2( txVal, lxValOld ) as Boolean
		local llRetorno as Boolean
		
		if this.nRecargoMonto2Anterior = txVal and this.lSuperoSaldoCC
			this.EventoMensajeBlanquearErrorPrecio()
		endif

		llRetorno = This.Validar_RecargoGenerico( "RecargoMonto2", txVal )

		if llRetorno
			llRetorno = llRetorno and This.ValidacionRecargoMonto2( txVal )
		endif

		this.lCambioMontoRecargoGeneral = iif( abs ( This.RecargoMonto2 - txVal ) < 0.01 or  txVal < 0 , .f., llRetorno )

		if this.lSuperoSaldoCC
			this.lSuperoSaldoCC = .f.
		endif
		
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function Validar_RecargoGenerico( tcAtributo as String, txVal as Variant ) as Boolean
		local llRetorno as Boolean, lcAtributo As String
		llRetorno = .f.
		lcAtributo = "This." + tcAtributo
		
		if &lcAtributo = txVal or txVal < 0
			&&No se ejecuta el Setear ya que el valor es igual al Anterior.	
		else
			if &lcAtributo < txVal
				if this.PedirSeguridadParaAplicarRecargos()
					llRetorno = dodefault( txVal )
				endif
			else
				llRetorno = dodefault( txVal )
			endif
			if ( llRetorno and txVal <> 0 and this.SignoDeMovimiento = -1 )
				llRetorno = !this.ValidarSiExistenItemsConRestriccionDeDescuentos()
				if !llRetorno
					goServicios.Errores.LevantarExcepcion( This.ObtenerMensajeErrorPorRestriccionDeDescuentos() )
				endif
			endif
		endif		
		return llRetorno	
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Setear_RecargoPorcentaje( txVal as variant ) as void

		this.lEstoySeteandoRecargos = .T.
		this.nRecargoPorcentajeAnterior = txVal
		
		with this
			dodefault( txVal )
			if .CargaManual()
				.DespuesDeSetearRecargo()
			endif
		endwith
		
		this.lEstoySeteandoRecargos = .F.
	endfunc
	
	*--------------------------------------------------------------------------------------------------------
	function Validar_Vendedor( txVal as variant, txValOld as variant ) as Boolean
		local llRetorno as Boolean
		
		llRetorno = dodefault( txVal, txValOld )
		if llRetorno
			this.lCambioVendedor = ( txVal != txValOld )
		endif
		
		return llRetorno

	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Setear_RecargoMonto1( txVal as variant ) as Void 
		this.lEstoySeteandoRecargos = .T.

		with this
			dodefault( txVal )
			if .CargaManual()
				.DespuesDeSetearRecargo()
			endif
		endwith

		this.lEstoySeteandoRecargos = .F.
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Setear_RecargoMonto2( txVal as variant ) as Void 
		this.lEstoySeteandoRecargos = .T.
		this.nRecargoMonto2Anterior = txVal
		
		with this
			if this.lCambioMontoRecargoGeneral and this.DebeQuitarImpuestosAlDescuento()
				this.nMontoDeRecargo2IngresadoManualmente = txVal
			endif
			dodefault( txVal )
			if .CargaManual()
				.DespuesDeSetearRecargo()
			endif
		endwith
		this.lEstoySeteandoRecargos = .F.
	endfunc

	*-----------------------------------------------------------------------------------------
	function DespuesDeSetearRecargo() as Void
		with This
			if type( "this.FacturaDetalle" ) = "O"
				.CalcularTotal()
				if this.lDisplayVFD
					.oColaboradorDisplayVFD.ActualizarTotal( this.total, this.totalCantidad )
				endif
			endif
		EndWith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function PedirSeguridadParaAplicarRecargos() as Boolean
		local llRetorno as Boolean
		llRetorno = .t.
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ActualizarSubTotal(  ) as Void	
		this.SubTotalBruto = round( this.FacturaDetalle.Sum_Bruto, 4 )
		this.SubTotalNeto  = round( this.FacturaDetalle.Sum_Neto, 4 )
	endfunc
		
	*-----------------------------------------------------------------------------------------
	protected function Recalcular() as void
		local llMuestraImpuestos as Boolean
		llMuestraImpuestos = .t.
		with this
			.RecalcularDescuentos()
			.RecalcularRecargos()
			lnDescuentosConImp = .MontoDescuentoConImpuestos + .MontoDescuentoConImpuestos1 + .MontoDescuentoConImpuestos3
			lnRecargosConImp = .RecargoMontoConImpuestos + .RecargoMontoConImpuestos2		
			
			lnDescuentosSinImp = .MontoDescuentoSinImpuestos + .MontoDescuentoSinImpuestos1 + .MontoDescuentoSinImpuestos3
			lnRecargosSinImp = .RecargoMontoSinImpuestos + .RecargoMontoSinImpuestos2	

			.subtotalSinImp = round(.FacturaDetalle.Sum_Neto - lnDescuentosSinImp + lnRecargosSinImp ,8)
			.subtotalConImp = round(.FacturaDetalle.Sum_Bruto - lnDescuentosConimp + lnRecargosConImp, 8)
			
			.RecalcularDescuentosValores()
			.RecalcularRecargosValores()
			.RecalcularImpuestosPorCambioDeNeto()
			if type( "this.oComponenteFiscal" ) = "O"
				llMuestraImpuestos = This.oComponenteFiscal.MostrarImpuestos()
			Endif			
			.CalcularSubTotal( llMuestraImpuestos )
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function RecalcularDescuentosValores() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function RecalcularRecargosValores() as Void
	endfunc

	*-----------------------------------------------------------------------------------------
	function CalcularSubTotal( tlMuestraImpuestos as Boolean ) as Void
		dodefault()
	endfunc	

	*-----------------------------------------------------------------------------------------
	protected function RecalcularDescuentos() as Void
		local lnSubTotalConImpuestos as Float, lnSubTotalSinImpuestos as Float, lnSubTotalVisual as Float

		lnSubTotalSinImpuestos = 0
		lnSubTotalConImpuestos = 0

		with this
			if type( "this.FacturaDetalle" ) = "O"
				if this.SubTotalBruto <> 0 and this.DebeQuitarImpuestosAlDescuento() and pemstatus( this, "ObtenerMontoDescuento3_DesdeMontoConImpuestos", 5 ) and this.nMontoDeDescuento3IngresadoManualmente # 0 
					this.MontoDescuento3 =  this.ObtenerMontoDescuento3_DesdeMontoConImpuestos( this.nMontoDeDescuento3IngresadoManualmente )
					this.lCambioMontoDescuentoGeneral = .F.
				endif

				************ Visual **************
				lnSubTotalVisual = iif( .oComponenteFiscal.MostrarImpuestos(), .SubTotalBruto, .SubTotalNeto )
				.Descuento = ( .PorcentajeDescuento * lnSubTotalVisual ) / 100
				***Descuento 2*** 
				lnSubTotalVisual = lnSubTotalVisual - .Descuento
				.MontoDescuento1 = ( .PorcentajeDescuento1 * lnSubTotalVisual ) / 100				

				***Descuento 4*** 
				lnSubTotalVisual = ( lnSubTotalVisual - .MontoDescuento1 )
				.nPorcentajeDescuento3 = iif( lnSubTotalVisual = 0, 0, .MontoDescuento3 * 100 / lnSubTotalVisual )
				
				************ CON IMPUESTOS **************
				***Descuento 1*** 
				lnSubTotalConImpuestos = this.SubtotalBruto
				.MontoDescuentoConImpuestos = ( .PorcentajeDescuento * lnSubTotalConImpuestos ) / 100
				***Descuento 2*** 
				lnSubTotalConImpuestos = lnSubTotalConImpuestos - .MontoDescuentoConImpuestos
				.MontoDescuentoConImpuestos1 = ( .PorcentajeDescuento1 * lnSubTotalConImpuestos ) / 100				

				***Descuento 4*** 
				lnSubTotalConImpuestos = ( lnSubTotalConImpuestos - .MontoDescuentoConImpuestos1 )
				.MontoDescuentoConImpuestos3 = goLibrerias.RedondearSegunPrecision( ( .nPorcentajeDescuento3 * lnSubTotalConImpuestos ) / 100 , PRECISIONENMONTOS )

				if lnSubTotalConImpuestos = 0 and .nPorcentajeDescuento3 = 0 and .MontoDescuento3 != 0 
					.MontoDescuentoConImpuestos3 = .MontoDescuento3  			
				else										
					.MontoDescuentoConImpuestos3 = ( .nPorcentajeDescuento3 * lnSubTotalConImpuestos ) / 100
				endif

				************ SIN IMPUESTOS **************
				***Descuento 1*** 
				lnSubTotalSinImpuestos = ( this.SubTotalNeto )
				.MontoDescuentoSinImpuestos = ( .PorcentajeDescuento * lnSubTotalSinImpuestos ) / 100
				***Descuento 2*** 
				lnSubTotalSinImpuestos = ( lnSubTotalSinImpuestos - this.MontoDescuentoSinImpuestos )
				.MontoDescuentoSinImpuestos1 = ( .PorcentajeDescuento1 * lnSubTotalSinImpuestos ) / 100			
				
				***Descuento 4*** 
				lnSubTotalSinImpuestos = ( lnSubTotalSinImpuestos - this.MontoDescuentoSinImpuestos1 )	

				if lnSubTotalSinImpuestos = 0 and .nPorcentajeDescuento3 = 0 and .MontoDescuento3 != 0 
					.MontoDescuentoSinImpuestos3 = .MontoDescuento3  			
				else										
					.MontoDescuentoSinImpuestos3 = ( .nPorcentajeDescuento3 * lnSubTotalSinImpuestos ) / 100
				endif
				
				******** Totalizadores
				.TotalDescuentosConImpuestos = .MontoDescuentoConImpuestos + .MontoDescuentoConImpuestos1 + .MontoDescuentoConImpuestos3
				.TotalDescuentosSinImpuestos = .MontoDescuentoSinImpuestos + .MontoDescuentoSinImpuestos1 + .MontoDescuentoSinImpuestos3
				.Descuento = goLibrerias.RedondearSegunMascara( .Descuento )
				.MontoDescuento1 = goLibrerias.RedondearSegunMascara( .MontoDescuento1 )				
			endif
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerMontoDescuento3_DesdeMontoConImpuestos( tnMontoConImpuesto as Float ) as Float
		local lnMonto as Float
		lnMonto = This.ObtenerMontoDescuento3_DesdePorcentaje( This.ObtenerPorcentajeDescuento3_DesdeMontoConImpuestos( tnMontoConImpuesto ) )
		return 	lnMonto
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerPorcentajeDescuento3_DesdeMontoConImpuestos( tnMontoConImpuesto as Float ) as float
		local lnSubTotalConImpuestos as Float, lnPorcentaje as Float

		with this
			lnSubTotalConImpuestos = .SubTotalBruto - ( .MontoDescuentoConImpuestos + .MontoDescuentoConImpuestos1 + .MontoDescuentoConImpuestos2 )
			lnPorcentaje  = iif( lnSubTotalConImpuestos = 0, 0, tnMontoConImpuesto * 100 / lnSubTotalConImpuestos )
		EndWith
		return lnPorcentaje
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerMontoDescuento3_DesdePorcentaje( tnPorcentaje as Float ) as Float
		local lnSubTotalVisual as Float, lnMontoDescuento3 as Float	
		with this
			lnSubTotalVisual = iif( .oComponenteFiscal.MostrarImpuestos(),	.SubTotalBruto - ( .MontoDescuentoConImpuestos + .MontoDescuentoConImpuestos1 + .MontoDescuentoConImpuestos2 ), ;
																			.SubTotalNeto - ( .MontoDescuentoSinImpuestos + .MontoDescuentoSinImpuestos1 + .MontoDescuentoSinImpuestos2 ) )
			lnMontoDescuento3 = ( tnPorcentaje * lnSubTotalVisual ) / 100
		EndWith
		return lnMontoDescuento3
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerPorcentajeRecargo1( tnMontoConImpuesto as Float ) as float

		local lnSubTotalConImpuestos as Float, lnPorcentaje as Float
		with this
			lnSubTotalConImpuestos = .SubTotalBruto - .TotalDescuentosConImpuestos - .RecargoMontoConImpuestos
			lnPorcentaje  = iif( lnSubTotalConImpuestos = 0, 0, tnMontoConImpuesto * 100 / lnSubTotalConImpuestos )
		EndWith
		return lnPorcentaje
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerRecargoMonto1( tnPorcentaje as Float ) as Float
		local lnSubTotalVisual as Float, lnMontoRecargo1 as Float	

		with this
			lnSubTotalVisual = iif( .oComponenteFiscal.MostrarImpuestos(), .SubTotalBruto - .TotalDescuentosConImpuestos , .SubTotalNeto - .TotalDescuentosSinImpuestos )
			lnSubTotalVisual = lnSubTotalVisual + .RecargoMonto
			lnMontoRecargo1 = ( tnPorcentaje * lnSubTotalVisual ) / 100
		EndWith
		return lnMontoRecargo1
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerRecargoMonto2_DesdeMontoConImpuestos( tnMontoConImpuesto as Float ) as Float
		local lnMonto as Float
		lnMonto = This.ObtenerRecargoMonto2( This.ObtenerPorcentajeRecargo2( tnMontoConImpuesto ) )
		return 	lnMonto
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerPorcentajeRecargo2( tnMontoConImpuesto as Float ) as float
		local lnSubTotalConImpuestos as Float, lnPorcentaje as Float

		with this
			lnSubTotalConImpuestos = .SubTotalBruto - ( .RecargoMontoConImpuestos + .RecargoMontoConImpuestos1 ) &&.TotalDescuentosConImpuestos - .RecargoMontoConImpuestos
			lnPorcentaje  = iif( lnSubTotalConImpuestos = 0, 0, tnMontoConImpuesto * 100 / lnSubTotalConImpuestos )
		EndWith
		return lnPorcentaje
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerRecargoMonto2( tnPorcentaje as Float ) as Float
		local lnSubTotalVisual as Float, lnMontoRecargo1 as Float	

		with this
			lnSubTotalVisual = iif( .oComponenteFiscal.MostrarImpuestos(), .SubTotalBruto - ( .RecargoMontoConImpuestos  + .RecargoMontoConImpuestos1 ) ,;
															               .SubTotalNeto - ( .RecargoMontoSinImpuestos + .RecargoMontoSinImpuestos1 ) )

			lnMontoRecargo1 = ( tnPorcentaje * lnSubTotalVisual ) / 100
		EndWith
		return lnMontoRecargo1
	endfunc 

	*--------------------------------------------------------------------------------------
	protected function RecalcularRecargos()
		local lnSubTotalConImpuestos as Float, lnSubTotalSinImpuestos as Float, lnSubTotalVisual as Float

		lnSubTotalSinImpuestos = 0
		lnSubTotalConImpuestos = 0

		with this
			if type( "this.FacturaDetalle" ) = "O"

				if this.SubTotalBruto <> 0 and this.DebeQuitarImpuestosAlDescuento() and pemstatus( this, "ObtenerRecargoMonto2_DesdeMontoConImpuestos", 5 ) and this.nMontoDeRecargo2IngresadoManualmente # 0
					this.RecargoMonto2 = this.ObtenerRecargoMonto2_DesdeMontoConImpuestos( this.nMontoDeRecargo2IngresadoManualmente )
					this.lCambioMontoRecargoGeneral = .F.
				endif
			
				************ Visual **************
				lnSubTotalVisual = iif( .oComponenteFiscal.MostrarImpuestos(), .SubTotalBruto - .TotalDescuentosConImpuestos , .SubTotalNeto - .TotalDescuentosSinImpuestos )
				.RecargoMonto = ( .RecargoPorcentaje * lnSubTotalVisual ) / 100

				lnSubTotalVisual = ( lnSubTotalVisual + .RecargoMonto )
				.nPorcentajeRecargo2 = iif( lnSubTotalVisual = 0, 0, .RecargoMonto2 * 100 / lnSubTotalVisual )
								
				************ CON IMPUESTOS **************
				lnSubTotalConImpuestos = .SubTotalBruto - .TotalDescuentosConImpuestos
				.RecargoMontoConImpuestos = ( .RecargoPorcentaje * lnSubTotalConImpuestos ) / 100				

				lnSubTotalConImpuestos = ( lnSubTotalConImpuestos + .RecargoMontoConImpuestos )

				if lnSubTotalConImpuestos = 0 and .nPorcentajeRecargo2 = 0
					.RecargoMontoConImpuestos2 = .RecargoMonto2 			
				else										
					.RecargoMontoConImpuestos2 = ( .nPorcentajeRecargo2 * lnSubTotalConImpuestos ) / 100
				endif

				************ SIN IMPUESTOS **************
				lnSubTotalSinImpuestos =  .SubTotalNeto - .TotalDescuentosSinImpuestos
				.RecargoMontoSinImpuestos = ( .RecargoPorcentaje * lnSubTotalSinImpuestos ) / 100				

				lnSubTotalSinImpuestos = ( lnSubTotalSinImpuestos + .RecargoMontoSinImpuestos  )

				if !this.lCargandoRecargo and ( this.lAgregueRecargoDe1Centavo or this.lEsComprobanteConRecargoSubtotalEnCero ) and ;
					( lnSubTotalSinImpuestos = 0 and .nPorcentajeRecargo2 = 0 )
					.RecargoMontoSinImpuestos2 = .RecargoMonto2
				else
					.RecargoMontoSinImpuestos2 = ( .nPorcentajeRecargo2 * lnSubTotalSinImpuestos ) / 100
				endif
				******** Totalizadores
				.TotalRecargosConImpuestos	= .RecargoMontoConImpuestos + .RecargoMontoConImpuestos2
				.TotalRecargosSinImpuestos	= .RecargoMontoSinImpuestos + .RecargoMontoSinImpuestos2				
				.RecargoMonto = goLibrerias.RedondearSegunMascara( .RecargoMonto )
			endif
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function RecalcularImpuestosPorCambioDeNeto()
        local lnMontoGravadoComprobante as Number
        lnMontoGravadoComprobante = This.ObtenerMontoGravadoImpuestosComprobante()
        this.oComponenteFiscal.RecalcularImpuestosPorCambioDeNeto( lnMontoGravadoComprobante, this.FacturaDetalle )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerMontoGravadoImpuestosComprobante() as Float
		return this.SubTotalNeto - This.TotalDescuentosSinImpuestos + this.TotalRecargosSinImpuestos
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
			lnRetorno = .Descuento > 0 or .MontoDescuento1 > 0 or .MontoDescuento2 > 0 or .MontoDescuento3 > 0
		endwith
		return lnRetorno					
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ActualizarDescuentosYRecargosEnComponenteFiscal() as Void		
		with this
			if type( "this.oComponenteFiscal" ) = "O"
				.oComponenteFiscal.AplicarDescuentoGlobal( .PorcentajeDescuento, .ImpuestosDetalle )
				.oComponenteFiscal.AplicarDescuentoGlobal2( .PorcentajeDescuento1, .ImpuestosDetalle )
				.AplicarDescuentoFinanciero()
				.oComponenteFiscal.AplicarDescuentoGlobal4( .nPorcentajeDescuento3, .ImpuestosDetalle )
				.oComponenteFiscal.AplicarRecargoGlobal( .RecargoPorcentaje, .ImpuestosDetalle )
				.AplicarRecargoFinanciero()
				.oComponenteFiscal.AplicarRecargoGlobal3( .nPorcentajeRecargo2, .ImpuestosDetalle )
				.oComponenteFiscal.RecalcularMontosConDescuentosYRecargos(.ImpuestosDetalle)

			EndIf	
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
				.ImpuestosDetalle.nPorcentajeDescuentoGlobal4 = .nPorcentajeDescuento3
				
				.ImpuestosDetalle.nPorcentajeRecargoGlobal = .RecargoPorcentaje
				.ImpuestosDetalle.nPorcentajeRecargoGlobal3 = .nPorcentajeRecargo2
			EndIf
			if type( "this.oComponenteFiscal" ) = "O"
				.oComponenteFiscal.LlenarColeccionDeImpuestos( .FacturaDetalle )
				
				*Le mando la entidad para ver de agregar a la coleccion de impuestos el 21% de IVA en caso
				*de tener recargos/descuentos financieros y no tener ningun registro de IVA 21.
				.oComponenteFiscal.AgregarAColeccionDeImpuestos( This )
				.LlamarARecalcularImpuestos()
			Endif			
		endwith
	endfunc  

	*-----------------------------------------------------------------------------------------
	function ValidarTicketExistente() as Boolean
		local llRetorno as Boolean, lcCodigo as String, loError as Exception, llEncontro as Boolean, llPreguntoEliminar as Boolean
		lcCodigo = This.Codigo
		llRetorno = .T.
		llEncontro = .t.
		llPreguntoEliminar = .T.
	
		if this.EsNuevo() and Vartype( this.oComponenteFiscal ) = "O" And this.oComponenteFiscal.ExisteControlador()
			try
				This.Codigo = ""
				This.ObtenerNumeroProximoComprobante()
				this.Buscar()
			catch to loError
				llEncontro = .f.
			finally
				This.Codigo = lcCodigo
			endtry
				
			if llEncontro
				try
					if this.EsComprobanteFiscal()
						this.lImprimirTicketFaltantes = .f.
						this.EventoPreguntarImprimirTicketFaltantes()
						if this.lImprimirTicketFaltantes
							llRetorno = this.oComponenteFiscal.ReimprimirComprobantes()
							if llRetorno
								this.ObtenerNumeroProximoComprobante()
							endif
							llPreguntoEliminar = .F.
						endif
					endif
					if llPreguntoEliminar
						this.EventoPreguntarEliminarTicketExistente( this.Letra + " " + transform( this.PuntoDeVenta, "@LZ 9999" ) + "-" + transform( this.Numero, "@LZ 99999999" ) )
						if this.lEliminarTicketExistente
							this.AnularoEliminarComprobanteSinMensajes( .t. ) && El parametro es para que elimine el comprobante.
						else
							llRetorno = .F.
						endif
					endif
				catch to loError
					This.Codigo = lcCodigo
					if goControladorFiscal.SemaforoBloqueado() and goControladorFiscal.IntentarBloquearControladorCanceladoPorUsuario()
					else
					 	throw loError
					endif 	
				endtry
			endif
	
		endif
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerNumeroProximoComprobante() as Void
		if type( "this.oNumeraciones" ) = 'O'
			this.oNumeraciones.lForzarObtencionNumeroDesdeBuffer = .f.
			this.oComponenteFiscal.BloquearCF()
			this.NUMERO = this.oNumeraciones.ObtenerNumero( 'NUMERO' , .F., .T. )
			this.oNumeraciones.lForzarObtencionNumeroDesdeBuffer = .t.
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function AnularoEliminarComprobanteSinMensajes( tlEliminar as Boolean ) as Void
		local loEntidad as entidad OF entidad.prg, loError as Exception
		loEntidad = _Screen.zoo.instanciarEntidad( This.cNombre )

		with loEntidad
			try
				.lDejarCuponHuerfanoPorFalloDeImpresion = .T.
				.Codigo = ""
				.Letra = This.Letra
				.PuntoDeVenta = This.PuntoDeVenta
				.Numero = This.Numero
				.TipoComprobante = This.TipoComprobante
				.Buscar()
				.Cargar()
				if .EstaAnulado()
				else
					if !.EstaEnProceso() 
						.lAnular = .T.
						.Anular()
					else
						this.EventoAdvertirNoTienePermisoParaAnular()
					endif
				endif
				if tlEliminar
					.lEliminar = .T.
					.Eliminar()
				endif 
			catch to loError
				goServicios.Errores.LevantarExcepcion( loError )
			finally
				.Release()
 
				this.lCuponesHuerfanosEnColeccion = .F.
				this.cargarcuponeshuerfanos( this.caja_PK )
				.lDejarCuponHuerfanoPorFalloDeImpresion = .F.
			endtry
		EndWith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoAdvertirNoTienePermisoParaAnular() as Void
		&& Para que se bindee el kontroler
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoCancelar() as Void
		&& Para que se cuelgue el Kontroler
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Setear_ListaDePrecios( txVal as variant ) as void
		
		dodefault( txVal )
		if this.CargaManual() and !this.lEstaSeteandoValorSugerido 
			this.eventoActualizaColorListaDePrecio( .t. )
			This.RecalcularPorCambioDeListaDePrecios( txVal )
			this.EventoCambioListaDePrecios()
		endif
		if this.TieneDescuentoAutomatico()
			This.SetearDescuentoPreferente()
		endif
		
	endfunc
	
	*--------------------------------------------------------------------------------------------------------
	function Setear_Vendedor( txVal as variant ) as void

		dodefault( txVal )

		if this.lCambioVendedor and this.TieneDescuentoAutomatico()
			This.SetearDescuentoPreferente()
			this.lCambioVendedor = .F.   
		endif

	endfunc

	*-----------------------------------------------------------------------------------------
	function Validar_Listadeprecios( txVal, txValOld ) as Boolean
		local llRetorno as Boolean, llCargoMensajePorMonedaDiferente as Boolean

		llRetorno = dodefault( txVal, txValOld )
 
 		if llRetorno 
			if this.lProcesando
			else
				if !( alltrim( txVal ) == alltrim( txValOld ) )
					llRetorno = goServicios.Seguridad.PedirAccesoEntidad( this.ObtenerNombreOriginal() , "CAMBIOLISTADEPRECIO" )

					if !llRetorno
						this.ListaDePrecios_PK = txValOld
						goServicios.Seguridad.AgregarInformacion( 'No posee permisos para cambiar la lista de precios.' )
						this.EventoErrorValidaciondeListaDePrecio()
					endif 
					if this.oValidadores.ValidadorComprobanteDeVentas.Validar()
						llRetorno = this.ValidarMostrarAdvertenciaRecalculoPreciosParaListaDePrecios()
						if llRetorno
							This.EliminarTodasLasPromociones()
						Else
							this.ListaDePrecios_PK = txValOld
						endif
					else
						this.ListaDePrecios_PK = txValOld

						llCargoMensajePorMonedaDiferente = this.lAdvertirPorMonedaDiferenteALaDelComprobante
						this.lAdvertirPorMonedaDiferenteALaDelComprobante = .F.
		
						if This.VerificarContexto( "IR" ) and inlist(upper( alltrim( this.cNombre ) ),"REMITO", "PEDIDO")
							if llCargoMensajePorMonedaDiferente and !this.lEsListaDePreciosImportacion
							else
								goServicios.Errores.LevantarExcepcion( this.oValidadores.ValidadorComprobanteDeVentas.obtenerInformacion() )
							endif
						else
							goServicios.Errores.LevantarExcepcion( this.oValidadores.ValidadorComprobanteDeVentas.obtenerInformacion() )
						endif
					endif
				else
					llRetorno  = .f.
				endif	
			endif
		else
			this.ListaDePrecios_PK = txValOld
		endif

		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerNombresValidadores() as zoocoleccion 
		local loNombreDeValidadores as zoocoleccion OF zoocoleccion.prg
		
		loNombreDeValidadores = dodefault()
		loNombreDeValidadores.Add( "ValidadorComprobanteDeVentas" )

		return loNombreDeValidadores
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarMostrarAdvertenciaRecalculoPreciosParaListaDePrecios() as boolean
		local llRetorno as Boolean
		
		this.lCambioSituacionFiscal = .f.
		this.lCambioListaPrecios = .t.
		
		llRetorno = this.MostrarAdvertenciaRecalculoPrecios()				
		this.lMostrarAdvertenciaRecalculoPrecios = .t.
		
		return llRetorno
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
	function Validar_Cliente( txVal as variant, txValOld as variant ) as Boolean
		local llRetorno as Boolean, lcMensaje as string		
		
		if Not ( alltrim( txVal ) = alltrim( txValOld ) ) And empty(this.Letra) and this.EsEdicion()
			this.Cliente_pk = txValOld
			lcMensaje = "No puede agregar un cliente a un comprobante que fue hecho sin personalizar."
			goServicios.Errores.LevantarExcepcion( lcMensaje )
		endif
		if this.TieneAccionCancelatoria() and vartype( This.oFacturaACancelar ) = "O" and this.oFacturaACancelar.Cliente_pk != this.Cliente_pk 
			this.ValidarSituacionFiscalClienteAccionCancelatoria()
		endif
		do case
		case ( alltrim( txVal ) = alltrim( txValOld ) )
			llRetorno = .t.
			this.lCambioSituacionFiscal = .f.
			this.lCambioCliente = .f.
			this.lMostrarAdvertenciaRecalculoPrecios = .t.
			if this.CambioLaSituacionFiscalDelCliente( txVal )
				this.lHuboCambioSituacionFiscal = .t.
				llRetorno = this.ValidarMostrarAdvertenciaRecalculoPreciosParaCliente( txValOld, txVal )
			else
				this.lHuboCambioSituacionFiscal = .f.
			endif
		otherwise
			llRetorno = this.ValidarMostrarAdvertenciaRecalculoPreciosParaCliente( txValOld, txVal )
			if llRetorno
				this.lCambioCliente = ( alltrim( txVal ) # alltrim( txValOld ) )	
				if This.lCambioCliente and ( This.lHuboCambioSituacionFiscal or this.lHuboCambioListaPrecios )
					This.EliminarTodasLasPromociones()
				Endif
			else
				this.cliente_pk = txValOld
			endif
		endcase
		return llRetorno and dodefault( txVal, txValOld )
	endfunc 	

	*-----------------------------------------------------------------------------------------
	protected function EliminarTodasLasPromociones() as Void
		if This.SoportaPromociones()
			local lnI As Integer
			for lni = 1 to This.PromocionesDetalle.Count
				This.PromocionesDetalle.CargarItem( lnI )
				This.PromocionesDetalle.oItem.Promocion_Pk = ""
				This.PromocionesDetalle.Actualizar()
			Endfor
		Endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarMostrarAdvertenciaRecalculoPreciosParaCliente( txCliOld as String, txCliNew as String ) as Boolean
		local lnSituacionFiscal as Integer, lcListaDePrecios as String, llRetorno as Boolean,;
			lcSituacionComprobante as String, lcSituacionCliente as String, lcMensaje as String, loError as zooexception OF zooexception.prg, ;
			lnSitFiscalCliCompFiscal as Integer 
		try
			this.oClienteBusquedasAdicionales.Codigo = txCliNew
			llRetorno = this.PermiteModificarSituacionFiscalDelCliente()
		catch to loError
			this.cliente_pk = txCliOld
			goServicios.Errores.LevantarExcepcion( loError )
		endtry
		if llRetorno
			try
				this.oClienteBusquedasAdicionales.Codigo = txCliOld
				if this.EsEdicion() or this.EsNuevo()
					lnSituacionFiscal = this.SituacionFiscal_Pk
				else
					lnSituacionFiscal = this.oClienteBusquedasAdicionales.ObtenerSituacionfiscalvalidocliente()
				endif
				this.oClienteBusquedasAdicionales.Codigo = txCliNew
				lcListaDePrecios = this.oClienteBusquedasAdicionales.ObtenerListadepreciosvalidocliente()
				this.lCambioSituacionFiscal = ( lnSituacionFiscal != this.oClienteBusquedasAdicionales.ObtenerSituacionfiscalvalidocliente() )		
				if alltrim( upper( txCliNew ) ) != alltrim( upper( txCliOld ) )
					this.lCambioListaPrecios = ( alltrim( upper( this.listadeprecios_pk ) ) != alltrim( upper( lcListaDePrecios ) ) )
				endif
				
				* Esto se agregó para que no haga la pregunta de que se modificarán los precios, ya que si es un comprobante
				* hecho en base a otro, por mas que aceptes, no actualiza precios (por cambio de cliente que tiene otra lista de precios)
				if alltrim( upper( txCliNew ) ) != alltrim( upper( txCliOld ) ) and !this.HayBasadoEn() and !This.VerificarContexto( "B" )
					llRetorno = this.MostrarAdvertenciaRecalculoPrecios()
				endif
					
			catch
			endtry

		else
			lnSitFiscalCliCompFiscal = this.oComponenteFiscal.ObtenerSituacionFiscalCliente()
			lcSituacionComprobante = alltrim( goServicios.Librerias.ObtenerDescripcionSituacionFiscalParaImpresion( lnSitFiscalCliCompFiscal ) )

			this.oClienteBusquedasAdicionales.Codigo = txCliNew
			lcSituacionCliente = alltrim( goServicios.Librerias.ObtenerDescripcionSituacionFiscalParaImpresion( this.oClienteBusquedasAdicionales.ObtenerSituacionfiscalvalidocliente()) ) 
			
			if this.lAnuladoAntesDeModificar	
				lcMensaje = "No puede utilizar un cliente cuya situación fiscal no se corresponda con la letra del comprobante."
			else				
				if ( txCliOld = txCliNew )
					lcMensaje = "No se puede realizar la modificación porque el cliente ha cambiado la situacion fiscal. " + ;
						"Anterior: " + lcSituacionComprobante + " - Actual: " + lcSituacionCliente
				else
					lcMensaje = "No se puede cambiar el cliente debido a que la situación fiscal es diferente. " + ;
						"Anterior: " + lcSituacionComprobante + " - Actual: " + lcSituacionCliente
				endif
			endif
			
			this.Cliente_PK = txCliOld
			if !this.lEstaSeteandoValorSugerido
				goServicios.Errores.LevantarExcepcion( lcMensaje )
			endif

			llRetorno = .f.
		endif

		this.lMostrarAdvertenciaRecalculoPrecios = .t.

		return llRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function PermiteModificarSituacionFiscalDelCliente() as Boolean
		local llRetorno as Boolean, lnSituacionFiscalCliente as Integer
		llRetorno = .t.

		lnSituacionFiscalCliente = This.oClienteBusquedasAdicionales.ObtenerSituacionFiscalValidoCliente()
		
		if this.EsEdicion() and this.cComprobante != "RECIBO" and type( "this.oComponenteFiscal" ) = "O" 
			if	this.lAnuladoAntesDeModificar
				llRetorno = this.oComponenteFiscal.VerificarSituacionFiscalDeClienteCoherenteConLetra( lnSituacionFiscalCliente, this.Letra )
			else			
				llRetorno = this.oComponenteFiscal.PermiteModificarSituacionFiscalDelCliente( this.Situacionfiscal_Pk, lnSituacionFiscalCliente )
			endif	
		endif	

		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function AsignarTotalComprobante( tnTotal as Float) as Void
		local lnTotal as Double
		lnTotal = goLibrerias.RedondearSegunMascara( tnTotal )
		This.Total = lnTotal
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarTotalComprobanteSinPersonalizar() as Void
		local llSoloTarjeta  as Boolean
		
		if !this.lAvisoPersonalizaciondelComprobante and empty( this.Cliente_pk ) and type( "this.oComponenteFiscal" ) = "O"
			llSoloTarjeta = iif( pemstatus( this, "ValoresDetalle", 5 ) and pemstatus( this.ValoresDetalle, "lSoloHayValoresTarjetaOPagoElectronico", 5 ), ;
								this.ValoresDetalle.lSoloHayValoresTarjetaOPagoElectronico, .f. )
			if !this.oComponenteFiscal.ValidarTotalComprobanteSinPersonalizar( this.Total, this.SimboloMonetarioComprobante, llSoloTarjeta )
				this.lAvisoPersonalizaciondelComprobante = .T.
				this.eventoPersonalizarComprobante( This.ObtenerInformacion() )
			endif
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function eventoPersonalizarComprobante( toInformacion as ZooInformacion of zooInformacion.Prg ) as Void
		* Avisa que hay que personalizar el comprobante. 
	endfunc

	*-----------------------------------------------------------------------------------------
	function LimpiarFlag() as Void
		This.lAvisoPersonalizaciondelComprobante = .f.
		this.lCambioCliente = .f.
		This.lComprobanteConDescuentosAutomaticos = iif( type( "this.oCompDescuentos" ) = "O",.T.,.f.)
	endfunc
	
	*--------------------------------------------------------------------------------------------------------
	function Limpiar( tlForzar as boolean ) as void
		dodefault( tlForzar )
		this.lAjustePorResiduoCentavo = .f.
		this.nResiduo = 0
		this.nTotalAnterior = 0
		this.nTopeDelCliente = 0
		this.LimpiarDetalleArticulosDespachos()
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
		if this.lComprobanteConDescuentosAutomaticos and this.EsNuevo() and !this.lLimpiando  &&
			if empty( this.Cliente.DescuentoPreferente_Pk ) and empty( this.Vendedor.DescuentoPreferente_Pk ) and empty( this.ListaDePrecios.DescuentoPreferente_Pk )
				this.oCompDescuentos.AplicarDescuentos()
			else
				if this.ExisteEnEntidadForanea( this.Cliente, "DescuentoPreferente" ) or this.ExisteEnEntidadForanea( this.Vendedor, "DescuentoPreferente" ) or this.ExisteEnEntidadForanea( this.Listadeprecios, "DescuentoPreferente" )
					this.ResolverAplicar()
				endif
			Endif	
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoPreguntarSiAplicaDescuento( tnModoFuncionamiento as Integer, tnMonto as float, tnPorcentaje as float, tcDescuento as String ) as Void
		** Se dispara cuando el componente de descuentos pregunta si debe aplicar o no
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function Setear_Fecha( txVal as variant ) as void
		
		if ( this.lEstaSeteandoValorSugerido or This.CargaManual() ) and !This.VerificarContexto( "CB" ) 
			this.EventoSetearFechaDeComprobante( txVal )
		endif
		dodefault( txVal )
		if this.lComprobanteConDescuentosAutomaticos and This.CargaManual() and !This.VerificarContexto( "B" )
			this.oCompDescuentos.FiltrarColeccionPorFecha()
			This.AplicarRecalculosGenerales()
		Endif	
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerLimiteMontoComprobante() as Integer
		local lnLimite as Integer
			
		lnLimite = 0
		if type( "this.oComponenteFiscal" ) = "O"
			lnLimite = This.oComponenteFiscal.ObtenerMontoLimiteComprobante()	
		endif
		return lnLimite
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function EventoDespuesDeCargarEnBaseA() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ErrorAlGrabar() as Void
		dodefault()
		this.SoltarControladorFiscal()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ErrorAlValidar() as Void
		dodefault()
		this.SoltarControladorFiscal()
	endfunc

	*-----------------------------------------------------------------------------------------
	function AplicaPercepciones() as boolean
		local llRetorno as Boolean, loError as Object
		llRetorno = .f.
		try
			if vartype( this.Cliente ) = "O" and !empty( this.Cliente.Codigo )
				llRetorno = ( this.Cliente.SituacionFiscal_pk != 3 and this.Cliente.SituacionFiscal_pk != 0 ) ;
							and this.TieneComponenteImpuestos() and this.oComponenteFiscal.oComponenteImpuestos.EsAgenteDePercepcion()
			endif
		catch to loError
			* Si pincha, debería ser el caso de que el codigo de cliente no existe
		endtry
		
		return llRetorno		
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarRecargo( tnValor as Long ) as Void
		This.lCargando = .T.
		this.lCargandoRecargo = .t.
			this.RecargoMonto2 = tnValor
			this.RecargoMontoConImpuestos2 = tnValor
			this.RecargoMontoSinImpuestos2 = tnValor
			this.Total = 0.01
		this.lCargandoRecargo = .f.
		This.lCargando = .F.
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function DebeSetearListaDePrecio( txCodigoCliente ) as Boolean
		local llRetorno as Boolean
		llRetorno = .f.
		if !empty( txCodigoCliente ) and !this.VerificarContexto("B")
			if pemstatus( this, "oCompEnBaseA", 5 ) 
				if ( This.oCompEnBaseA.cCodigoClienteAfectado # txCodigoCliente ) and ( !empty( This.Cliente.ListaDePrecio_PK ) and;
						vartype(This.Cliente.ListaDePrecio_PK) = "C" )
					
					llRetorno = .t.
					if this.VerificarContexto("I") and !empty( this.ListaDePrecios_PK ) and this.lEsListaDePreciosImportacion
						llRetorno = .F.
					endif
				endif
			else
				if !empty( This.Cliente.ListaDePrecio_PK )
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
	function EventoSetear_Cliente( tcCliente as String ) as Void
	** Evento para poder informar cambio de Cliente.	
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function DespuesDeInicializarElComponenteFiscal() as Void
		if type( "this.FacturaDetalle" ) = "O" and !isnull( this.FacturaDetalle )
			if type( "this.FacturaDetalle.oItem" ) = "O" and !isnull( this.FacturaDetalle.oItem )
				**Es necesario el ISNULL porque el null es tipo "O" y lo puse en dos if, porque sino se evalua igual a pesar de que la primer patte del and de .f.
				This.FacturaDetalle.oItem.InyectarComponenteFiscal( this.oComponenteFiscal )
			endif
		endif
		if this.SoportaKits()
			if type( "this.KitsDetalle" ) = "O" and !isnull( this.KitsDetalle)
				if type( "this.KitsDetalle.oItem" ) = "O" and !isnull( this.KitsDetalle.oItem )
					This.KitsDetalle.oItem.InyectarComponenteFiscal( this.oComponenteFiscal )
				endif
			endif
		endif
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function Validar_Puntodeventa( txVal as variant ) as Boolean
		if this.lEdicion
			return .f.
		else
			return dodefault( txVal )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function SoltarControladorFiscal() as Void
		if Vartype( this.oComponenteFiscal ) = "O" and !isnull( this.oComponenteFiscal )
			this.oComponenteFiscal.SoltarControladorFiscal()
			this.oNumeraciones.lForzarObtencionNumeroDesdeBuffer = .f.
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function LimpiarImpuestosDetalleAlLimpiarFacturaDetalle() as Void
		if type( "this.oComponenteFiscal" ) = "O" and !isnull( this.oComponenteFiscal ) and this.CargaManual()
			this.oComponenteFiscal.RecalcularImpuestos( this.FacturaDetalle, this.ImpuestosDetalle )
			this.AsignarTotalImpuesto()
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function Validar_Situacionfiscal( tnVal as variant, tnValOld as variant ) as Boolean
		local llRetorno as Boolean
		llRetorno = dodefault( tnVal, tnValOld )

 		if llRetorno 
			if type( "this.oComponenteFiscal" ) = "O" and !isnull( this.oComponenteFiscal )
				llRetorno = this.oComponenteFiscal.ValidarSituacionFiscalCliente( tnVal )

				if !llRetorno
					goServicios.Errores.LevantarExcepcion( 'La situación fiscal asignada al cliente no es válida. Edite el cliente y asigne una nueva.' )
				else
					if tnVal # tnValOld && or this.CondicionIVA # this.SituacionFiscal.Codigo
						this.SetearDatosAComponenteFiscal()
					endif
				endif
			endif
		endif

		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function LimpiarDescuentoPreferenteDelCliente( tlforzar as Boolean ) as Void
		if this.TieneDescuentoAutomatico()
			this.oCompDescuentos.oDescuentosPreferentes = null
		endif 	
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ProcesarErroresConNumeracionEnCF( tnTipoComprobante ) as Void
		local lnNumeroSiguiente as Integer, lnNumeroConError as Integer, lcGuid as String
		if This.TipoComprobante = tnTipoComprobante 
				lcGuidError = goControladorFiscal.ObtenerGuidDeComprobanteConErrorCF( This.PuntoDeVenta, tnTipoComprobante ) 
				if this.EsEdicion() or this.EsNuevo()
					this.Cancelar()
				endif
				this.Codigo = lcGuidError
				lnNumeroSiguiente = this.oNumeraciones.ObtenerNumero( 'NUMERO' , .F., .T. )
				lnNumeroConError =  goControladorFiscal.ObtenerNumeroDeComprobanteConErrorCF( This.PuntoDeVenta, tnTipoComprobante )
				This.EventoPedirSolucionPorProblemaControladorFiscal( lnNumeroSiguiente, lnNumeroConError )

				if !this.EsNuevo()
					goServicios.Errores.LevantarExcepcion( "No se solucionó el problema, quedará pospuesto hasta la próxima vez que intente hacer un nuevo comprobante o un cierre X/Z" )
				endif 
		endif 		
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoPedirSolucionPorProblemaControladorFiscal( tnNumeroSiguiente as Integer, tnNumeroConError as Integer ) as Integer	
		*-- Evento para se bindee el kontroler
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ReimprimirTicketConErrorEnControladorFiscal() as Void

		goControladorFiscal.CambiarEstadoControladorFiscal( This.PuntoDeVenta, This.TipoComprobante, This.Numero, This.Codigo, .T. )

		This.EmitirImpresionFiscal()

		goControladorFiscal.CambiarEstadoControladorFiscal( This.PuntoDeVenta, This.TipoComprobante, This.Numero, This.Codigo, .F. )

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EliminarTicketConErrorEnControladorFiscal() as Void
		
		goControladorFiscal.CambiarEstadoControladorFiscal( This.PuntoDeVenta, This.TipoComprobante, This.Numero, This.Codigo, .F. )

		This.AnularoEliminarComprobanteSinMensajes(.T.)
	endfunc 

	*-----------------------------------------------------------------------------------------
	function QuitarMarcaPorImpresionAnteriorExitosa() as Void
		if vartype( goControladorFiscal ) = "O"	
			goControladorFiscal.CambiarEstadoControladorFiscal( goParametros.Felino.ControladoresFiscales.PuntoDeVenta, This.TipoComprobante, This.Numero, this.Codigo, .F. )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ReimprimirTicketConErrorEnControladorFiscalEnNuevoComprobante() as Void
		local lnNumeroMarcado as Integer

		lnNumeroMarcado = This.ActualizarAUltimoNumeroYDevolverActual( this.oNumeraciones.ObtenerNumero( 'NUMERO' , .F., .T. ) )

		goControladorFiscal.CambiarEstadoControladorFiscal( This.PuntoDeVenta, This.TipoComprobante, This.Numero, This.Codigo, .F. )
		This.GenerarRangoDeAnulados( lnNumeroMarcado, lnNumeroMarcado )

		goControladorFiscal.CambiarEstadoControladorFiscal( This.PuntoDeVenta, This.TipoComprobante, This.Numero, This.Codigo, .T. )
		
		if This.EmitirImpresionFiscal()
			goControladorFiscal.CambiarEstadoControladorFiscal( This.PuntoDeVenta, This.TipoComprobante, This.Numero, This.Codigo, .F. )
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function AnularTicketConErrorEnControladorFiscal() as Void

		This.AnularoEliminarComprobanteSinMensajes( .F. )
		goControladorFiscal.CambiarEstadoControladorFiscal( This.PuntoDeVenta, This.TipoComprobante, This.Numero, This.Codigo, .F. )
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function AnularTicketConErrorYCrearloEnUltimoNumeroImpreso() as Void
		local lnNumeroMarcado as Integer

		lnNumeroMarcado = This.ActualizarAUltimoNumeroYDevolverActual( this.oNumeraciones.ObtenerNumero( 'NUMERO' , .F., .T. ) - 1 )

		goControladorFiscal.CambiarEstadoControladorFiscal( This.PuntoDeVenta, This.TipoComprobante, This.Numero, This.Codigo, .F. )
		
		This.GenerarRangoDeAnulados( lnNumeroMarcado, This.Numero - 1 )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ReemitirComprobanteConErrorYGenerarAnulados() as Void
		local lnNumeroMarcado as Integer

		lnNumeroMarcado = This.ActualizarAUltimoNumeroYDevolverActual( this.oNumeraciones.ObtenerNumero( 'NUMERO' , .F., .T. ) )

		goControladorFiscal.CambiarEstadoControladorFiscal( This.PuntoDeVenta, This.TipoComprobante, This.Numero, This.Codigo, .T. )

		if This.EmitirImpresionFiscal()
			goControladorFiscal.CambiarEstadoControladorFiscal( This.PuntoDeVenta, This.TipoComprobante, This.Numero, This.Codigo, .F. )
			This.GenerarRangoDeAnulados( lnNumeroMarcado, This.Numero - 1 )
		endif
	endfunc 	

	*-----------------------------------------------------------------------------------------
	function GeneraAnuladosHastaElUltimoEmitido() as Void
		local lnNumeroMarcado as Integer

		lnNumeroMarcado = This.Numero
		
		This.AnularoEliminarComprobanteSinMensajes(.F.)
		goControladorFiscal.CambiarEstadoControladorFiscal( This.PuntoDeVenta, This.TipoComprobante, This.Numero, This.Codigo, .F. )

		This.GenerarRangoDeAnulados( lnNumeroMarcado + 1, this.oNumeraciones.ObtenerNumero( 'NUMERO' , .F., .T. ) - 1 )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ActualizarAUltimoNumeroYDevolverActual( pnNumero as Integer ) as Integer
		local lnNumeroMarcado as Integer
		
		This.Modificar()
		lnNumeroMarcado = This.Numero
		This.Numero = pnNumero
		
		This.Grabar()
		return lnNumeroMarcado
		
	endfunc 	

	*-----------------------------------------------------------------------------------------
	protected function ObtenerGuidComprobanteConErrorEnCF() as String
		return goControladorFiscal.ObtenerGuidDeComprobanteConErrorCF( This.PuntoDeVenta, This.TipoComprobante )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function GenerarRangoDeAnulados( tnDesde as Integer, tnHasta as Integer ) as Void
		local loTratamientoComprobantes as ent_TratamientoComprobantes of ent_TratamientoComprobantes.prg

		loTratamientoComprobantes = _screen.zoo.instanciarentidad("tratamientocomprobantes")
		with loTratamientoComprobantes 
			.Nuevo()
			.NumeroDesde = tnDesde
			.NumeroHasta = tnHasta
			.PuntoDeVenta = this.PuntoDeVenta
			.TipoComprobante = This.TipoComprobante
			.Letra = this.Letra
			.FechaComprobante = This.Fecha
			.Hora = this.HoraAltaFW
			.Accion = 1
			.Grabar()
			.Release()
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerNumeroComprobanteCompleto( tnNumero as Integer ) as String
		local lcNombreComprobante as String

		lcNombreComprobante = this.ObtenerTipoComprobanteFormateado()
		
		return lcNombreComprobante + " " + this.ObtenerNumeroComprobanteFormateado( tnNumero )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerNumeroComprobanteReducido( tnNumero as Integer ) as String
		return transform( This.Letra )+" " + this.ObtenerNumeroComprobanteFormateado( tnNumero )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerTipoComprobanteFormateado() as String
		local lcRetorno as String

		lcRetorno = this.ObtenerTipoComprobante( this.TipoComprobante ) + " " + this.Letra
		
		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerTipoComprobante( tnTipo as Integer ) as String
		local loComprobantes as din_comprobante of din_comprobante.prg, lcRetorno as String
		
		if empty( tnTipo )
			tnTipo = this.TipoComprobante
		endif

		loComprobantesyGrupos = _screen.Zoo.CrearObjeto("din_comprobantesygruposcaja")
		lcIdCompyGrupos = loComprobantesyGrupos.Buscaidcomprobante( tnTipo , "B")
		lcRetorno = loComprobantesyGrupos.Item[lcIdCompyGrupos].Comprobante
		lcRetorno = alltrim( strtran( lcRetorno , " B"," ") )
		loComprobantesyGrupos.Release()
		
		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerNumeroComprobanteFormateado( tcNumero as Integer ) as String
		return transform( This.PuntoDeVenta,"@LZ 9999" ) + "-" + transform( tcNumero, "@LZ 99999999" )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ReimprimirTicketsFaltantesEnControladorFiscal() as Void
		local lnNumeroMarcado as Integer

		lnNumeroMarcado = This.Numero
		lnProximoNumeroEnControladorFiscal = this.oNumeraciones.ObtenerNumero( 'NUMERO' , .F., .T. )
		
		lcFiltro = "PuntoDeVenta=" + alltrim( transform( this.PuntoDeVenta ) + " and TipoComprobante=" + alltrim(transform(This.TipoComprobante)) + " and Letra='"+ this.Letra + "' and Numero>=" + alltrim(transform(lnProximoNumeroEnControladorFiscal)) + " and Numero <=" + alltrim(transform(lnNumeroMarcado))  )
		
		lcXml = this.ObtenerDatosEntidad( "", lcFiltro , "Numero" )
		
		lcCursor = sys(2015)
		Xmltocursor( lcXml, lcCursor, 4 )
 	
	 	select( lcCursor )
		scan
			this.Codigo = &lcCursor..Codigo
		 	if this.Anulado
			 	this.EmitirAnulado()
		 	else
			 	This.EmitirImpresionFiscal()
		 	endif
		endscan

	endfunc 

	*-----------------------------------------------------------------------------------------
	function EjecutarSolucion( tnSolucion as Integer ) as Void

		lnNumeroSiguiente = this.oNumeraciones.ObtenerNumero( 'NUMERO' , .F., .T. )
		lnNumeroConError =  goControladorFiscal.ObtenerNumeroDeComprobanteConErrorCF( This.PuntoDeVenta, This.TipoComprobante )

		do case

			case tnSolucion = 1 and lnNumeroConError +1 = lnNumeroSiguiente 
				this.QuitarMarcaPorImpresionAnteriorExitosa()

			case tnSolucion = 1 and lnNumeroConError +1 < lnNumeroSiguiente 
				this.AnularTicketConErrorYCrearloEnUltimoNumeroImpreso()
				
			case tnSolucion = 2 and lnNumeroConError > lnNumeroSiguiente 
				this.ReimprimirTicketsFaltantesEnControladorFiscal()

			case tnSolucion = 2 and lnNumeroConError = lnNumeroSiguiente 
				this.ReimprimirTicketConErrorEnControladorFiscal()

			case tnSolucion = 2 and lnNumeroConError +1 = lnNumeroSiguiente 
				this.ReimprimirTicketConErrorEnControladorFiscalEnNuevoComprobante()

			case tnSolucion = 2 and lnNumeroConError +1 < lnNumeroSiguiente 
				this.ReemitirComprobanteConErrorYGenerarAnulados()

			case tnSolucion = 3 and lnNumeroConError = lnNumeroSiguiente 
				this.EliminarTicketConErrorEnControladorFiscal()
				
			case tnSolucion = 3 and lnNumeroConError +1 = lnNumeroSiguiente 
				this.AnularTicketConErrorEnControladorFiscal()

			case tnSolucion = 3 and lnNumeroConError +1 < lnNumeroSiguiente 
				this.GeneraAnuladosHastaElUltimoEmitido()			
		endcase
		this.ActualizarProgressBar(0)
		
		this.Nuevo()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarDescuentosYRecargos() as Void
		local llretorno as Boolean, lnMontoTotalDelComprobanteSinDesuentosYSinRecargos as float, lnMontoTotalDeSeniasDelComprobante as float
		llretorno = .t.
		store 0 to lnMontoTotalDelComprobanteSinDesuentosYSinRecargos, lnMontoTotalDeSeniasDelComprobante
		this.nModoSeguridadDescuento = goServicios.Seguridad.ObtenerModo(alltrim(this.ObtenerNombre()) + "_VALIDARDESCUENTOS")
		this.nModoSeguridadRecargo = goServicios.Seguridad.ObtenerModo(alltrim(this.ObtenerNombre()) + "_VALIDARRECARGOS")

		if this.nMontoMaximoDeDescuento > 0 or this.nPorcentajeMaximoDeDescuento > 0 or This.nPorcentajeMaximoDeRecargo > 0 or this.nMontoMaximoDeRecargo > 0
			lnMontoTotalDelComprobanteSinDesuentosYSinRecargos =  this.ObtenerMontoTotalDelComprobanteSinDesuentosYSinRecargos()
			lnMontoTotalDeSeniasDelComprobante = this.ObtenerMontoTotalDeSeniasDelComprobante()

			* Descuentos
			if this.TengoQuePedirSeguridadPorDescuentoMaximo() and (this.nMontoMaximoDeDescuento > 0 or this.nPorcentajeMaximoDeDescuento > 0)
				llRetorno = this.ValidarDescuentoMaximo( lnMontoTotalDelComprobanteSinDesuentosYSinRecargos, lnMontoTotalDeSeniasDelComprobante )
			endif

			* Recargos
			if this.TengoQuePedirSeguridadPorRecargoMaximo() and (This.nPorcentajeMaximoDeRecargo > 0 or this.nMontoMaximoDeRecargo > 0)
				llRetorno = this.ValidarRecargoMaximo( lnMontoTotalDelComprobanteSinDesuentosYSinRecargos ) AND llRetorno
			endif
		endif
		
		return llRetorno

	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarDescuentoMaximo( tnMontoTotalDelComprobanteSinDesuentosYSinRecargos as float, tnMontoTotalDeSeniasDelComprobante as float ) as Boolean
		local llretorno as Boolean, lnMontoTotalDeDescuentoDelComprobante as Integer, lnPorcentajeTotalDeDescuentoDelComprobante as Double,;
		      llPasoSeguridad as Boolean, llYaPreguntoPorSeguridad as Boolean, lcMensajeMonto as String, lcMensajePorcentaje as String, ;
		      lnPorcentajeTotalDeDescuentoDelComprobanteSinSeniasIncluidas as float ;
		      lnPorcentajeTotalDeDescuentoDelComprobanteEnItems as float , lnPorcentajeTotalDeDescuentoDelComprobanteGeneral as float, lnMontoDeDescuentoEnLinea as float	
		      

		store 0 to lnMontoTotalDeDescuentoDelComprobante, lnPorcentajeTotalDeDescuentoDelComprobante, lnPorcentajeTotalDeDescuentoDelComprobanteSinSeniasIncluidas
		store 0 to lnPorcentajeTotalDeDescuentoDelComprobanteEnItems, lnPorcentajeTotalDeDescuentoDelComprobanteGeneral, lnMontoDeDescuentoEnLinea
		
		store .F. to llPasoSeguridad, llYaPreguntoPorSeguridad
		store "" to lcMensajeMonto, lcMensajePorcentaje
		llretorno = .T.
		lnMontoDeDescuentoEnLinea = this.ObtenerMontosDeDescuentosEnLinea()
		lnMontoTotalDeDescuentoDelComprobante = this.TotalDescuentosConImpuestos + lnMontoDeDescuentoEnLinea
		
		
		if this.lVieneDeValores
			this.nMontoDescuentoTotalDesdeSeguridadEnValores = lnMontoTotalDeDescuentoDelComprobante
		endif
		* Descuentos por monto
		if this.nMontoMaximoDeDescuento > 0 and lnMontoTotalDeDescuentoDelComprobante > this.nMontoMaximoDeDescuento 
			lcMensajeMonto = "No tiene permisos para aplicar un monto de descuento mayor a " + alltrim(this.monedacomprobante.simbolo) + alltrim(str(this.nMontoMaximoDeDescuento,15,2)) + " y se está realizando un descuento por " + alltrim(this.monedaCOMPROBANTE.simbolo) + alltrim(str(lnMontoTotalDeDescuentoDelComprobante,15,2)) + "."
		endif

		* Descuentos por porcentaje
		if this.nPorcentajeMaximoDeDescuento > 0 and tnMontoTotalDelComprobanteSinDesuentosYSinRecargos <> 0 
		
			lnPorcentajeTotalDeDescuentoDelComprobante = 100 * lnMontoTotalDeDescuentoDelComprobante / tnMontoTotalDelComprobanteSinDesuentosYSinRecargos  
			lnPorcentajeTotalDeDescuentoDelComprobanteSinSeniasIncluidas = 100 * lnMontoTotalDeDescuentoDelComprobante / ( tnMontoTotalDelComprobanteSinDesuentosYSinRecargos + tnMontoTotalDeSeniasDelComprobante )

			if lnMontoDeDescuentoEnLinea >0 && Porcentaje de descuento en linea x ítem (no tiene en cuenta seña)
				lnPorcentajeTotalDeDescuentoDelComprobanteEnItems = 100 * lnMontoDeDescuentoEnLinea / tnMontoTotalDelComprobanteSinDesuentosYSinRecargos   
			endif 
			if pemstatus( this, "porcentajedescuento", 5 ) and this.porcentajedescuento > 0  && Porcentaje de descuento general( si  tiene en cuenta seña)
				lnPorcentajeTotalDeDescuentoDelComprobanteGeneral = this.porcentajedescuento 
			endif
			if pemstatus( this, "porcentajedescuento2", 5 ) and this.porcentajedescuento2 > 0  && Porcentaje de descuento de valores( si  tiene en cuenta seña)
				lnPorcentajeTotalDeDescuentoDelComprobanteGeneral = lnPorcentajeTotalDeDescuentoDelComprobanteGeneral + this.porcentajedescuento2 
			endif
			
			if this.lVieneDeValores
				this.nPorcentajeDescuentoTotalDesdeSeguridadEnValores = round( lnPorcentajeTotalDeDescuentoDelComprobante, 2 )
			endif
			if  round( lnPorcentajeTotalDeDescuentoDelComprobante, 2 ) > round( this.nPorcentajeMaximoDeDescuento, 2 )
				*lcMensajePorcentaje = "No tiene permisos para aplicar un porcentaje de descuento mayor a " + alltrim(str(this.nPorcentajeMaximoDeDescuento)) + "% y se está realizando un descuento por " + alltrim(str(lnPorcentajeTotalDeDescuentoDelComprobanteSinSeniasIncluidas,15,2)) + "%" + "."
				lcMensajePorcentaje = "No tiene permisos para aplicar un porcentaje de descuento al total del comprobante mayor a " + alltrim(str(this.nPorcentajeMaximoDeDescuento)) + "% y se está realizando un descuento promedio de " + alltrim(str(lnPorcentajeTotalDeDescuentoDelComprobanteEnItems + lnPorcentajeTotalDeDescuentoDelComprobanteGeneral ,15,2)) + "%" + "."
			endif	
		endif

		if !empty( lcMensajeMonto ) or !empty( lcMensajePorcentaje )
			 if inlist(this.nModoSeguridadDescuento,3,4)  && Voy a pedir seguridad
				* Muestro el mensaje y pido seguridad
				this.EventoInformaSeguridadParaDescuentosYRecargos( lcMensajeMonto, lcMensajePorcentaje )
				llPasoSeguridad = goServicios.Seguridad.PedirAccesoEntidad( this.ObtenerNombreOriginal(), "VALIDARDESCUENTOS" )
			endif

			if llPasoSeguridad
			else
				if inli(this.nModoSeguridadDescuento,3,4)
					this.AgregarInformacion( "No se pudieron aplicar los descuentos indicados", 1 )
					this.nCantidadDeErrorres = this.nCantidadDeErrorres + 1
				else
					* Si entra aca es porque no tenia acceso a esta funcionalidad y debe mostrar este error al final
					if !empty(lcMensajeMonto)
						this.agregarInformacion( lcMensajeMonto )
						this.nCantidadDeErrorres = this.nCantidadDeErrorres + 1
					endif

					if !empty(lcMensajePorcentaje)
						this.agregarInformacion( lcMensajePorcentaje )
						this.nCantidadDeErrorres = this.nCantidadDeErrorres + 1
					endif
				endif
				llretorno = .f.
			endif
		endif
		if llRetorno and this.lVieneDeValores
			this.lSeguridadDeDescuentosDesdeValores = .T.
		endif
		return llretorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarRecargoMaximo( tnMontoTotalDelComprobanteSinDesuentosYSinRecargos as Integer ) as Boolean
		local lnMontoTotalDeRecargoDelComprobante as Integer, lnPorcentajeTotalDeRecargoDelComprobante as Integer,;
			  llPasoSeguridad as Boolean, llYaPreguntoPorSeguridad as Boolean, lcMensajeMonto as String, lcMensajePorcentaje as String
		store 0 to lnMontoTotalDeRecargoDelComprobante, lnPorcentajeTotalDeRecargoDelComprobante
		store .F. to llPasoSeguridad, llYaPreguntoPorSeguridad
		store "" to lcMensajeMonto, lcMensajePorcentaje
		llretorno = .T.

		lnMontoTotalDeRecargoDelComprobante = this.TotalRecargosConImpuestos
		if this.lVieneDeValores
			this.nMontoRecargoTotalDesdeSeguridadEnValores = lnMontoTotalDeRecargoDelComprobante
		endif
		* Recargos por monto										   
		if this.nMontoMaximoDeRecargo > 0 and lnMontoTotalDeRecargoDelComprobante > this.nMontoMaximoDeRecargo
			lcMensajeMonto = lcMensajeMonto + "No tiene permisos para aplicar un monto de recargo mayor a " + alltrim(this.monedacomprobante.simbolo) + alltrim(str(this.nMontoMaximoDeRecargo,15,2)) + " y se está realizando un recargo por " + alltrim(this.monedaCOMPROBANTE.simbolo) + alltrim(str(lnMontoTotalDeRecargoDelComprobante,15,2)) + "."
		endif

		* Recargos por porcentaje
		if this.nPorcentajeMaximoDeRecargo > 0 and tnMontoTotalDelComprobanteSinDesuentosYSinRecargos <> 0
			lnPorcentajeTotalDeRecargoDelComprobante = 100 * lnMontoTotalDeRecargoDelComprobante / tnMontoTotalDelComprobanteSinDesuentosYSinRecargos
			if this.lVieneDeValores
				this.nPorcentajeRecargoTotalDesdeSeguridadEnValores = round( lnPorcentajeTotalDeRecargoDelComprobante, 2 )
			endif			
			if  lnPorcentajeTotalDeRecargoDelComprobante > this.nPorcentajeMaximoDeRecargo
				lcMensajePorcentaje = "No tiene permisos para aplicar un porcentaje de recargo mayor a " + alltrim(str(this.nPorcentajeMaximoDeRecargo)) + "% y se está realizando un recargo por " + alltrim(str(lnPorcentajeTotalDeRecargoDelComprobante,15,2)) + "%" + "."
			endif
		endif
		
		if !empty( lcMensajeMonto ) or !empty( lcMensajePorcentaje )
			 if inlist(this.nModoSeguridadRecargo,3,4)
				this.EventoInformaSeguridadParaDescuentosYRecargos( lcMensajeMonto, lcMensajePorcentaje )
				llPasoSeguridad = goServicios.Seguridad.PedirAccesoEntidad( this.ObtenerNombreOriginal(), "VALIDARRECARGOS" )
			endif
			
			if llPasoSeguridad
			else
				if inlist(this.nModoSeguridadRecargo,3,4)
					this.AgregarInformacion( "No se pudieron aplicar los recargos indicados", 1 )
					this.nCantidadDeErrorres = this.nCantidadDeErrorres + 1
				else
					if !empty( lcMensajeMonto )
						this.agregarInformacion( lcMensajeMonto )
						this.nCantidadDeErrorres = this.nCantidadDeErrorres + 1
					endif

					if !empty( lcMensajePorcentaje )
						this.agregarInformacion( lcMensajePorcentaje )
						this.nCantidadDeErrorres = this.nCantidadDeErrorres + 1
					endif
				endif
				llretorno = .f.
			endif
		endif
		if llRetorno and this.lVieneDeValores
			this.lSeguridadDeRecargosDesdeValores = .T.
		endif

		return llretorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function TengoQuePedirSeguridadPorDescuentoMaximo() as Void
		local llRetorno as boolean

		if this.lSeguridadDeDescuentosDesdeValores && si ya paso la seguridad desde los valores
			if ( this.nMontoDescuentoTotalDesdeSeguridadEnValores = ( this.TotalDescuentosConImpuestos + this.ObtenerMontosDeDescuentosEnLinea() ) ) and;			&& si ademas, el monto de descuento de ahora es igual al monto de cuando se pidio seguridad por valores
				this.ObtenerPorcentajeDeDescuentosDelTotal() = this.nPorcentajeDescuentoTotalDesdeSeguridadEnValores
				llRetorno = .F.
			else
				llRetorno = .T.
			endif
		else && si no pidio seguridad desde valores, como siempre
			llRetorno = !goServicios.Seguridad.PedirAccesoEntidad( this.ObtenerNombreOriginal(), "VALIDARDESCUENTOS" ,.T. )
		endif
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function TengoQuePedirSeguridadPorRecargoMaximo() as Void
		local llRetorno as boolean

		if this.lSeguridadDeRecargosDesdeValores && si ya paso la seguridad desde los valores
			if ( this.nMontoRecargoTotalDesdeSeguridadEnValores = this.TotalRecargosConImpuestos ) and;			&& si ademas, el monto de descuento de ahora es igual al monto de cuando se pidio seguridad por valores
				this.ObtenerPorcentajeDeRecargoDelTotal() = this.nPorcentajeRecargoTotalDesdeSeguridadEnValores
				llRetorno = .F.
			else
				llRetorno = .T.
			endif
		else && si no pidio seguridad desde valores, como siempre
			llRetorno = !goServicios.Seguridad.PedirAccesoEntidad( this.ObtenerNombreOriginal(), "VALIDARRECARGOS" ,.T. )
		endif
		
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerMontosDeDescuentosEnLinea() as Void
		local lnMontoDescuentoEnLinea as Integer
		lnMontoDescuentoEnLinea = 0
		if type( "This.FacturaDetalle" ) == "O" 
			for each loItem in this.FacturaDetalle
				if !this.EstaAfectadoPorPromocion( loItem.IdItemArticulos ) and !this.EstaAfectadoPorKit( loItem )
					lnMontoDescuentoEnLinea = lnMontoDescuentoEnLinea + loItem.MontoDescuentoConImpuestos + loItem.montoporcentajedescuentoconimpuesto
				endif
			endfor
		endif
		return lnMontoDescuentoEnLinea
	endfunc 

	*-----------------------------------------------------------------------------------------

	protected function ObtenerPorcentajeDeDescuentosDelTotal() as number
		return round( 100 * ( this.TotalDescuentosConImpuestos + this.ObtenerMontosDeDescuentosEnLinea() ) / this.ObtenerMontoTotalDelComprobanteSinDesuentosYSinRecargos(), 2)
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerPorcentajeDeRecargoDelTotal() as number
		return round( 100 * ( this.TotalRecargosConImpuestos / this.ObtenerMontoTotalDelComprobanteSinDesuentosYSinRecargos() ), 2 )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EstaAfectadoPorPromocion( idItemArticulo as String ) as Boolean
		local llRetorno as Boolean
		if type( "This.PromoArticulosDetalle" ) == "O" 
			for each loPItem in this.PromoArticulosDetalle
				if loPItem.idItemArticulo = idItemArticulo
					llRetorno = .t.
					exit
				endif
			endfor
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerMontoTotalDelComprobanteSinDesuentosYSinRecargos() as Void
		local lnMontoTotalSinDescuentoYSinRecargos as Integer
		
		lnMontoTotalSinDescuentoYSinRecargos = 0
		if type( "This.FacturaDetalle" ) == "O" 
			for each loItem in this.FacturaDetalle
				if upper( loItem.Articulo_PK ) = "SEÑA"
					loop
				endif
				lnMontoTotalSinDescuentoYSinRecargos = lnMontoTotalSinDescuentoYSinRecargos + ( loItem.Cantidad * loItem.PrecioConImpuestos )
			endfor
		endif

		return lnMontoTotalSinDescuentoYSinRecargos
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerMontoTotalDeSeniasDelComprobante() as Void
		local lnMontoTotalDeSenias as Integer
		
		lnMontoTotalDeSenias = 0
		if type( "This.FacturaDetalle" ) == "O" 
			for each loItem in this.FacturaDetalle
				if upper( loItem.Articulo_PK ) = "SEÑA"
					lnMontoTotalDeSenias = lnMontoTotalDeSenias + ( loItem.Cantidad * loItem.PrecioConImpuestos )
				else
					loop
				endif
			endfor
		endif

		return lnMontoTotalDeSenias
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoInformaSeguridadParaDescuentosYRecargos( tcMensajeMonto as String, tcMensajePorcentaje as String ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarNumeroDeTicketMayorACero() as Boolean
		local llRetorno as Boolean
		llRetorno = .T.
		
		if Vartype( this.oComponenteFiscal ) = "O" And this.oComponenteFiscal.ExisteControlador() and type("this.numero") = "N"
			llRetorno = this.numero > 0
		endif
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarNumeroDeTicketDistintoDeCero() as Boolean
		local llRetorno as Boolean
		llRetorno = .T.
		if inlist(upper(alltrim( this.cComprobante )), 'TICKETFACTURA', 'TICKETNOTADEDEBITO', 'TICKETNOTADECREDITO' ) ;
		   and goparametros.FELINO.CONTROLADORESFISCALES.CODIGO # 35 && si es Caja Registradora no verifica

			llRetorno = !(this.numero = 1)
			*Si el controlador fiscal no devuelve numeración o devuelve el número de comprobante 0
			* aqui llega numero de comprobante 1 xq Dragonfish al recibir la numeración del 
			* controlador le suma 1 para tener el próximo número de comprobante.
		endif		
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function Cargar() as Boolean
		local llRetorno as Boolean
		llRetorno = dodefault()
		this.lYaInformoOrfandadCuponesIntegrados = .F.
		this.SetearMonedaEnDetalleValores()
		this.EventoSetearTituloFormulario()
		return llRetorno
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
	function RecalcularPorPrePantalla( toItemsCargados as ZooColeccion OF ZooColeccion.prg ) as Void
		local lnNroItem as Integer, lnI as Integer 
		for lnI = 1 to toItemsCargados.Count
			lnNroItem = toItemsCargados.Item[lnI]
			this.FacturaDetalle.oItem.oCompPrecios.ObtenerPrecio( this.FacturaDetalle.Item[ lnNroItem ], this.ListaDePrecios_PK )
		endfor

		this.RecalcularPreciosDeDetallesAdicionales( this.ListaDePrecios_PK )
		if type( "This.oComponenteFiscal" ) = "O"
			This.oComponenteFiscal.RecalcularImpuestos( this.FacturaDetalle, this.ImpuestosDetalle )
			this.AplicarRecalculosGenerales()
			if this.lDisplayVFD
				this.oColaboradorDisplayVFD.ActualizarTotal( this.total, this.totalCantidad )
			endif
		EndIf	

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CambioLaSituacionFiscalDelCliente( tcCli as String ) as Boolean
		local llRetorno as boolean, lnSitFiscalCliCompFiscal as integer, lnSituacionCliente as Integer
		llRetorno = .f.

		lnSitFiscalCliCompFiscal = this.oComponenteFiscal.ObtenerSituacionFiscalCliente()
		lnSituacionCliente = this.Cliente.ObtenerSituacionFiscalValidoCliente()

		if lnSitFiscalCliCompFiscal # lnSituacionCliente
			llRetorno = .t.
		endif
		
		return ( llRetorno )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function MostrarImpuestos() as Boolean
		return this.oComponenteFiscal.MostrarImpuestos()
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function GrabarErrorEnLog( tcDescripcion ) as Void
		local loZooException as Object, loLogueador as Object
		loZooException = _screen.Zoo.CrearObjeto( "ZooException" )
		loLogueador = goServicios.Logueos.ObtenerObjetoLogueo( loZooException )
		loLogueador.Escribir( tcDescripcion )
		goServicios.Logueos.Guardar( loLogueador )
		loLogueador = null
		loZooException = null
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function HayCambiosEnDetalleDePercepciones() as Boolean
		local llRetorno as Boolean, lnIndice as Integer, loImpuestosCliente as Object, loImpuestosComponente as Object, loCliente as Object
		llRetorno = .f.

		if this.Cliente.Codigo = this.oComponenteFiscal.ocomponenteimpuestos.codigocliente
		else
			loImpuestosCliente = this.Cliente.Percepciones
			loCliente = _Screen.Zoo.InstanciarEntidad( "Cliente" )
			loCliente.Codigo = this.oComponenteFiscal.ocomponenteimpuestos.codigocliente
			loImpuestosComponente = loCliente.Percepciones && this.oComponenteFiscal.ocomponenteimpuestos.oimpuestos
			if vartype( loImpuestosCliente ) = "O" and vartype( loImpuestosComponente ) = "O"
				if loImpuestosCliente.Count = loImpuestosComponente.Count
					for lnIndice = 1 to loImpuestosCliente .Count
						do case
						case loImpuestosCliente[ lnIndice ].porcentaje # loImpuestosComponente[ lnIndice ].porcentaje
							llRetorno = .t.
						case loImpuestosCliente[ lnIndice ].Jurisdiccion_PK # loImpuestosComponente[ lnIndice ].Jurisdiccion_PK
							llRetorno = .t.
						case loImpuestosCliente[ lnIndice ].Resolucion # loImpuestosComponente[ lnIndice ].Resolucion
							llRetorno = .t.
						otherwise 
						endcase
					endfor
				else
					llRetorno = .t.
				endif
				loCliente.Release()
			endif
		endif
		return llRetorno
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
	protected function SetearInvertirSignoEnDetalle() as Void
		if type( "this.FacturaDetalle" ) = "O" and !isnull( this.FacturaDetalle )
			this.FacturaDetalle.lInvertirSigno = This.lInvertirSigno
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearComprobanteDebeValidarDevolucionDeArticulo() as Void
		if type( "this.FacturaDetalle" ) = "O" and !isnull( this.FacturaDetalle )
			this.FacturaDetalle.lComprobanteDebeValidarDevolucionDeArticulo = this.lComprobanteDebeValidarDevolucionDeArticulo
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearComprobanteAfectadoDebeValidarDevolucionDeArticulo() as Void
		if type( "this.FacturaDetalle" ) = "O" and !isnull( this.FacturaDetalle )
			this.FacturaDetalle.lComprobanteAfectadoDebeValidarDevolucionDeArticulo = this.lComprobanteAfectadoDebeValidarDevolucionDeArticulo
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarArticulosNoPermitenDevolucion() as Boolean
		local llRetorno as Boolean
		llRetorno = this.FacturaDetalle.ValidarArticulosNoPermitenDevolucion( this )
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearComprobanteEsCancelacionEnDetalle() as Void
		if type( "this.FacturaDetalle" ) = "O" and !isnull( this.FacturaDetalle )
			if upper( alltrim( this.cNombre ) ) = "DEVOLUCION"
				this.FacturaDetalle.lComprobanteEsCancelacion = .T.
			else
				this.FacturaDetalle.lComprobanteEsCancelacion = .F.
			endif
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function VerificarArticulosYDespachos() as Boolean
		local llRetorno as Boolean, loRetorno as Object, llResp as Boolean
		loRetorno = null
		loRetorno = createobject( "custom" )
		addproperty( loRetorno, "cDespachos", "" )
		addproperty( loRetorno, "lCancelo", .f. )
		addproperty( loRetorno, "lHayArticulosQueImprimenDespacho", .f. )

		if this.lEstaElKontroler
			This.EventoMostrarFormSeleccionDespachos( loRetorno, this.DataSessionID )
		else
			this.ObtenerDespachosSinEntornoGrafico( loRetorno, this.DataSessionID )
		endif
		
		if _screen.zoo.app.lSalidaForzada 
			llResp = .f.
		else
			llResp = This.AnalizarRetorno( loRetorno )
			if llResp and !empty( loRetorno.cDespachos )
				This.Despachos = loRetorno.cDespachos
				This.cDespachos = This.Despachos
			endif
		endif	

		loRetorno = null
		
		return llResp

	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoMostrarFormSeleccionDespachos( toRetorno as Object, txIdDeSession as variant ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AnalizarRetorno( toRetorno as Object ) as Boolean
		local llRetorno as Boolean, llPermiteContinuarGrabacion as Boolean
		llPermiteContinuarGrabacion = goParametros.Felino.GestionDeVentas.ComercioExterior.PermiteContinuarSinoPoseeDespachoDeImportacion
		do case
			case toRetorno.lCancelo and llPermiteContinuarGrabacion 
				llRetorno = .T.
			case toRetorno.lCancelo and !llPermiteContinuarGrabacion
				llRetorno = .F.
				This.AgregarInformacion( "No se puede grabar el comprobante. Debe asociar los despachos a los artículos" )
			case !toRetorno.lHayArticulosQueImprimenDespacho 
				llRetorno = .T.
			case empty( toRetorno.cDespachos ) and !llPermiteContinuarGrabacion 
				llRetorno = .F.
				This.AgregarInformacion( "No se puede grabar el comprobante. Debe asociar los despachos a los artículos" )
			otherwise
				llRetorno = .T.
		endcase
		return llRetorno
	endfunc	 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerDespachosSinEntornoGrafico( toRetorno as Object, txIdDeSession as variant ) as Void
		this.oEntidadSeleccionDespachos.InyectarDetalle( this.FacturaDetalle )
		this.oEntidadSeleccionDespachos.ObtenerDespachosSinEntornoGrafico( toRetorno, txIdDeSession )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Setear_MontoDescuento2( txMontoDescuento as variant ) as Void
		with this
			dodefault( txMontoDescuento )
			if .CargaManual() and this.lAplicarDescuentoDeValores 
				if pemstatus( this, "lDebeCalcularVuelto", 5 )
					this.lDebeCalcularVuelto = .t.
				endif
				.DespuesDeSetearDescuento()			
			endif
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function TieneComponenteImpuestos() as Boolean
		local llRetorno as Boolean
		llRetorno = this.TieneComponenteFiscal()
		llRetorno = llRetorno and ( vartype( this.oComponenteFiscal.oComponenteImpuestos ) = "O" and !isnull( this.oComponenteFiscal.oComponenteImpuestos ) )
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function TieneComponenteFiscal() as Boolean
		return vartype( this.oComponenteFiscal ) = "O" and !isnull( this.oComponenteFiscal )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoValorSugeridoListaDePrecios() as Void
		with this
			try
				if 	vartype( .Cliente ) = "O" and !isnull( .Cliente ) and !empty( .Cliente.ListaDePrecio_pk ) and !( 'ELECTRONICAEXPORTACION' $ .cComprobante )
					.Listadeprecios_PK = .Cliente.ListaDePrecio_pk
					.Listadeprecios.Codigo = .Listadeprecios_PK
				endif
			catch
				.Listadeprecios_PK=[]
			endtry 
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerDevoluciones() as Void
		local DevNeto as Number, DevBruto as Number
		DevNeto = 0
		DevBruto = 0
		for i = 1 to this.FacturaDetalle.count
			loItem = this.FacturaDetalle.Item[ i ]
			DevNeto  = DevNeto  + iif( loItem.Neto < 0, loItem.Neto * - 1 , 0 )
			DevBruto  = DevBruto  +  iif( loItem.Bruto < 0, loItem.Bruto * - 1 , 0 )
		endfor
		this.lMontoTotalDevolucionesNeto = DevNeto
		this.lMontoTotalDevolucionesBruto = DevBruto
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function SetearValidarSiElComprobanteTieneDescuento() as void
		if ( this.TotalDescuentosSinImpuestos <> 0 or this.PorcentajeDescuento <> 0 or this.PorcentajeDescuento1 <> 0 ;
			or this.PorcentajeDescuento2 <> 0 or this.ValidarSiHayPorcentajesDeDescuentosEnValores() )
			this.FacturaDetalle.oItem.lElComprobanteTieneDescuento = .t.
		else
			this.FacturaDetalle.oItem.lElComprobanteTieneDescuento = .f.
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarSiHayPorcentajesDeDescuentosEnValores() as Boolean
		return .f.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarSiExistenItemsConRestriccionDeDescuentos() as Boolean
		local llRestringir as Boolean
		if  pemstatus( This, "FacturaDetalle", 5 ) and vartype( This.FacturaDetalle ) = "O" and pemstatus( this.FacturaDetalle, "Sum_tieneRestriccion", 5 )
			llRestringir = This.FacturaDetalle.Sum_TieneRestriccion > 0
		else
			llRestringir = .F.
		endif
		return llRestringir
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function SetearCodigoGTINEnItem( toItem as Object ) as void
		toItem.CodigoGTIN = this.oColaboradorEquivalenciaCodigoGTIN.ObtenerEquivalencia( toItem )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function SetearCodigoGTIN() as void
		this.SetearCodigoGTINEnItem( this.FacturaDetalle.oItem ) 
		this.oColaboradorEquivalenciaCodigoGTIN.ValidarItem( this.FacturaDetalle.oItem )
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarCodigosGTINEnDetalle() as boolean
		local loFactoriaComportamientoValidacionGTIN as object, loTratamientoMultiple as object
		
		try
			loFactoriaComportamientoValidacionGTIN = _screen.zoo.CrearObjeto( "FactoriaComportamientoValidacionGTIN" )
			loTratamientoMultiple = loFactoriaComportamientoValidacionGTIN.ObtenerTratamientoDeValidacionGTIN( .t., this.oMensaje )
			this.oColaboradorEquivalenciaCodigoGTIN.ValidarDetalle( this.FacturaDetalle, loTratamientoMultiple )
		
		catch to loError
			llAntesDeGrabar = .f.
			this.AgregarInformacion( loError )
		finally
			loTratamientoMultiple.Ejecutar()
		endtry
		
		return
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearCodigoDJCPEnItem( toItem as object ) as void
		if this.EsNuevo() and type( "this.Cliente" ) = "O" and !inlist( this.Cliente.SituacionFiscal_PK, 3, 0 )
			toItem.CodigoAutorizacionDJCP = this.oColaboradorCodigosDJCP.ObtenerCodigoAutorizacion( toItem.Articulo_PK, this.Fecha )
		else
			toItem.CodigoAutorizacionDJCP = ""
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function SetearCodigoDJCP() as void
		this.SetearCodigoDJCPEnItem( this.FacturaDetalle.oItem )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ActualizarCodigosDJCPEnDetalle() as void
		local loItem as object
		if this.EsNuevo() and this.lHuboCambioSituacionFiscal
			for each loItem in this.FacturaDetalle
				this.SetearCodigoDJCPEnItem( loItem )
			endfor
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function CalcularCoeficienteDeImpuestos() as Void
		return
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsComprobanteDeVentasConImpuestos() as Boolean
		local llRetorno as Boolean
		llRetorno = .f.
		if "<VENTAS>" $ this.ObtenerFuncionalidades() and vartype(this.ImpuestosDetalle) = "O" and !isnull(this.ImpuestosDetalle)
			llRetorno = .t.
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerCoeficienteDeImpuestos() as Decinal
		local lnRetorno as Integer
		lnRetorno = this.nCoeficienteImpuestos
		return lnRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoSetearFechaDeComprobante( tdFecha as Date ) as Void
	endfunc
	
    *---------------------------------------------------------------------------------------
    function ValidarRestriccionDeDescuentos( tlAplicandoCondicionDePago as Boolean ) as Boolean
		local llRetorno as Boolean, llExisteItemConRestriccion as Boolean, llAplicoDesc as Boolean, llAplicoRec as Boolean
		llRetorno = .T.
		if pemstatus( This, "FacturaDetalle", 5 ) and vartype( This.FacturaDetalle ) = "O" and pemstatus( This.FacturaDetalle, "sum_TieneRestriccion", 5 )
			llExisteItemConRestriccion = this.FacturaDetalle.Sum_TieneRestriccion > 0
		else
			llExisteItemConRestriccion = .F.
		endif
		llAplicoDesc = this.SeAplicoDescuentos()
		llAplicoRec = this.SeAplicoRecargos()
		
        if llExisteItemConRestriccion
            if tlAplicandoCondicionDePago
				llRetorno = .F.
            else
                llRetorno = ( this.SignoDeMovimiento = 1 and llAplicoDesc )
                llRetorno = llRetorno or ( this.SignoDeMovimiento = -1 and llAplicoRec )
                llRetorno = llRetorno or ( vartype(this.oValidadorDetalleArticulos) = "O" and !empty( this.oValidadorDetalleArticulos.cArticuloConRestriccion ) )
				llRetorno = !llRetorno
            endif    
		endif

        if llExisteItemConRestriccion
	        lcCodArtConRestr = this.oValidadorDetalleArticulos.cArticuloConRestriccion
	        if !tlAplicandoCondicionDePago and !empty( lcCodArtConRestr )
				this.cCodArtConRestr = lcCodArtConRestr
			endif
		endif

		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerMensajeErrorPorRestriccionDeDescuentos() as String
		local lcCad as String
		
		if this.SignoDeMovimiento = -1
			lcCad = "No se pueden aplicar recargos en un comprobante del tipo nota de crédito si se ha ingresado algún artículo con restricción de descuentos."
		else
			if !empty( This.cCodArtConRestr )
				lcCad = "No se puede aplicar un descuento en línea al artículo " + rtrim( This.cCodArtConRestr ) + " porque tiene restricción de descuentos."
				This.cCodArtConRestr = ""
			else
				lcCad = "No se puede aplicar un descuento al comprobante porque se ha ingresado algún artículo con restricción de descuentos."
			endif
		endif		
		
		return lcCad
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ExisteArticuloConRestriccionYDescuentoEnLinea() as String
		local lcRetorno as String, lnI as Integer, lnCont as Integer
		lcRetorno = ""
		lnCont = 0
		if pemstatus( This, "FacturaDetalle", 5 ) and vartype( This.FacturaDetalle ) = "O" and pemstatus( This.FacturaDetalle, "Sum_tieneRestriccion", 5 )
			if This.FacturaDetalle.Sum_TieneRestriccion > 0 and ( This.FacturaDetalle.Sum_MontoDescuento > 0 or This.FacturaDetalle.Sum_MontoPorcentajeDescuentoConImpuesto > 0 )
				for lnI = 1 to this.FacturaDetalle.Count
					if this.FacturaDetalle.Item(lnI).TieneRestriccion == 1
						if ( this.FacturaDetalle.Item(lnI).Descuento > 0 or this.FacturaDetalle.Item(lnI).MontoDescuento > 0 )
							lcRetorno = This.FacturaDetalle.Item(lnI).Articulo_pk
							exit
						else
							lnCont = lnCont + 1
						endif 
					endif
					if lnCont == This.FacturaDetalle.Sum_TieneRestriccion
						exit
					endif
				endfor
			endif
		endif
		return lcRetorno

	endfunc
		
	*-----------------------------------------------------------------------------------------
	function ObtenerCantidadImpuestosActivos() as Void
		local lnRetorno as Integer, loitem as Object
		lnRetorno = 0
		if vartype( this.ImpuestosComprobante ) == "O"
			for each loItem in this.ImpuestosComprobante
				if loItem.monto > 0
					lnRetorno = lnRetorno + 1
				endif
			endfor
		endif
		return lnRetorno		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearDatosAdicionalesParaCalculoDeImpuestos( tcJurisdiccion as String ) as Void
		if type( "this.oComponenteFiscal.oComponenteImpuestos" ) = "O" and vartype( this.oCompEnBaseA ) = "O"
			if this.lHaciendoNuevaAccionCancelatoria or this.lLimpiando
				this.oComponenteFiscal.oComponenteImpuestos.lSeEstaCancelandoUnComprobanteEnBaseA = .t.
				this.oComponenteFiscal.oComponenteImpuestos.lSeEstaCancelandoUnComprobanteCompletoEnBaseA = .t.
                this.oComponenteFiscal.oComponenteImpuestos.lSeEstaCancelandoUnComprobanteEnFechaPermitida = .t.
            else
            	this.oComponenteFiscal.oComponenteImpuestos.lSeEstaCancelandoUnComprobanteEnBaseA = .f.
				this.oComponenteFiscal.oComponenteImpuestos.lSeEstaCancelandoUnComprobanteCompletoEnBaseA = .f.
                this.oComponenteFiscal.oComponenteImpuestos.lSeEstaCancelandoUnComprobanteEnFechaPermitida = .f.
                with this.oCompEnBaseA
                	if this.EsNotaDeCredito() and .HayBasadoEn()
                		this.oComponenteFiscal.oComponenteImpuestos.lSeEstaCancelandoUnComprobanteEnBaseA = .t.
                		do case
                			case tcJurisdiccion = "901"
		                		if .ObtenerCantidadDeComprobantesAfectados() = 1  and .ElComprobanteAfectadoEsPosteriorALaResolucion486Agip()
			                        if .VerificarFechaComprobanteAfectadoPermitidaParaResolucion296Agip()
			                            this.oComponenteFiscal.oComponenteImpuestos.lSeEstaCancelandoUnComprobanteEnFechaPermitida = .t.
			                            if .ElComprobanteAfectadoMantieneElMismoSubTotalNetoQueElAfectante() and !.SeModificoElDetalleDelComprobante( this.FacturaDetalle )
			    						    this.oComponenteFiscal.oComponenteImpuestos.lSeEstaCancelandoUnComprobanteCompletoEnBaseA = .t.
			                            endif
			                        endif
								endif
							case tcJurisdiccion = "924"
								if .ObtenerCantidadDeComprobantesAfectados() = 1  and .VerificarFechaComprobanteAfectadoPermitidaParaTucuman()
									this.oComponenteFiscal.oComponenteImpuestos.lSeEstaCancelandoUnComprobanteEnFechaPermitida = .t.
									this.oComponenteFiscal.oComponenteImpuestos.lSeEstaCancelandoUnComprobanteCompletoEnBaseA = .t.	
								endif
							case tcJurisdiccion = "902"
								if .ObtenerCantidadDeComprobantesAfectados() = 1 
		                            if .ElComprobanteAfectadoMantieneElMismoSubTotalNetoQueElAfectante() and !.SeModificoElDetalleDelComprobante( this.FacturaDetalle )
		    						    this.oComponenteFiscal.oComponenteImpuestos.lSeEstaCancelandoUnComprobanteCompletoEnBaseA = .t.
		                            endif
								endif							
						endcase
					endif
				endwith
			endif
		    this.oComponenteFiscal.oComponenteImpuestos.lForzarAccionCancelatoria = this.lForzarAccionCancelatoria
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function EsNotaDeCredito() as Boolean
		return ( "NOTADECREDITO" $ upper( alltrim( this.cNombre ) ) )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearAtributoGrabandoEntidadDelComponenteEnBaseA( tlValor as Boolean ) as Void
		if pemstatus( this, "oCompEnBaseA", 5 ) 
			this.oCompEnBaseA.lGrabandoEntidad = tlValor
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ResetearAtributoAgipEnComponenteImpuestos() as Void
		if type( "this.oComponenteFiscal.oComponenteImpuestos" ) = "O"
			this.oComponenteFiscal.oComponenteImpuestos.lYaSeInformoQueSeAplicaRG_486_2016_AGIP = .f.
            this.oComponenteFiscal.oComponenteImpuestos.lYaSeInformoQueSeAplicaRG_296_2019_AGIP = .f.
            this.oComponenteFiscal.oComponenteImpuestos.lHayBasadoEn = .f.
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ConsultarSiHuboAvisoDeCambioDeTotalPorRestriccionDeCalculoEnIIBB() as Boolean
		local llRetorno as Boolean
		llRetorno = .f.
		if type( "this.oComponenteFiscal.oComponenteImpuestos" ) = "O"
			llRetorno = This.oComponenteFiscal.oComponenteImpuestos.lYaSeInformoQueSeAplicaRG_486_2016_AGIP
		endif
		return llRetorno
	endfunc 	

	*-----------------------------------------------------------------------------------------
	protected function ResetearAtributoIIBBGBAEnComponenteImpuestos() as Void
		if type( "this.oComponenteFiscal.oComponenteImpuestos" ) = "O"
			this.oComponenteFiscal.oComponenteImpuestos.lYaSeInformoQueSeAplicaIIBBGBA = .f.
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function tieneTalonarioManual() as Void
		local llRetorno as Boolean
			llRetorno = this.oNumeraciones.oTalonario.Asignacion = 2
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function LlamarARecalcularImpuestos() as Void
		if vartype( This.oComponenteFiscal ) = 'O' and !isnull( This.oComponenteFiscal )
			local lnMontoGravadoComprobante as Number
	        lnMontoGravadoComprobante = This.ObtenerMontoGravadoImpuestosComprobante()
			This.oComponenteFiscal.RecalcularImpuestosPorCambioDeNeto(lnMontoGravadoComprobante, This.FacturaDetalle)
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerPorcentajeDescuentoyRecargo() as void
		this.oComponenteFiscal.oComponenteImpuestos.nPorcentajeRecargo = this.recargoporcentaje
		this.oComponenteFiscal.oComponenteImpuestos.nPorcentajeDescuento = this.porcentajedescuento
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerCodigoEntidadDescuento() as string
		return this.cCodigoEntidadDescuento
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function TieneDescuentoAutomatico() as string
		return type( "this.oCompDescuentos" ) = "O"
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function AsignarSituacionFiscal() as Void
		if This.cliente.SituacionFiscal_PK = 0
			this.ValorSugeridoSituacionfiscal()
		else
			this.Situacionfiscal_Pk = This.cliente.SituacionFiscal_PK
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AplicarProrrateo() as Void
		if vartype( this.FacturaDetalle ) = "O" and this.FacturaDetalle.Count > 0
			loColaboradorProrrateo = _Screen.Zoo.CrearObjetoPorProducto( "ColaboradorProrrateo", "ColaboradorProrrateo.prg" )
			loColaboradorProrrateo.ProrratearItems( this, this.FacturaDetalle )
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function HayAjusteRecargo() as Boolean
		return vartype( this.oColaboradorAjusteDeComprobante ) = "O" and this.oColaboradorAjusteDeComprobante.HayRecargoAjuste()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function HayAjusteDescuento() as Boolean
		return vartype( this.oColaboradorAjusteDeComprobante ) = "O" and this.oColaboradorAjusteDeComprobante.HayDescuentoAjuste()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarInformacionSiNoExiste( tcMensaje as String ) as Void
		local llExiste as Boolean
		llExiste = .F.
		for each oItemInfo in this.oInformacion
			if alltrim( oItemInfo.cMensaje ) = alltrim( tcMensaje )
				llExiste = .T.
			endif
		endfor
		if llExiste
		else
			this.oInformacion.AgregarInformacion( tcMensaje )
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function oColaboradorGestionVendedor_Access() as variant
		if !this.ldestroy and ( !vartype( this.oColaboradorGestionVendedor ) = 'O' or isnull( this.oColaboradorGestionVendedor ) )
			this.oColaboradorGestionVendedor = _screen.zoo.crearobjeto( "ColaboradorGestionVendedor" )
		endif
		return this.oColaboradorGestionVendedor 
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ValidarDominioVendedor() as boolean
		local llEsCodigoVendedorValido as Boolean,lcMensajeError as String,lcCodigoVendedor  as String
		llEsCodigoVendedorValido = .t. 
		lcCodigoVendedor = this.Vendedor_PK
		
		if !Empty( lcCodigoVendedor )
			llEsCodigoVendedorValido = this.oColaboradorGestionVendedor.validarVendedor(lcCodigoVendedor ,this)
		endif
		
		if !llEsCodigoVendedorValido 
			lcMensajeError = "El vendedor "+ alltrim(lcCodigoVendedor) +" no está habilitado para operar en la sucursal o base de datos."
			This.AgregarInformacion(lcMensajeError)
		endif
			
		return llEsCodigoVendedorValido 
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Cancelar() as Void
		if this.lDisplayVFD
			this.oColaboradorDisplayVFD.LimpiarPantalla( .t., .t. )
			this.oColaboradorDisplayVFD.MostrarPresentacion( .t., .f., .f., 1 )
		endif
		lAnuladoAntesDeModificar = .F.
		doDefault()

		this.LimpiarNombreEntidadAfectada()		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarSituacionFiscalClienteAccionCancelatoria() as Void
		local lcError as String
		lcError = ""
		if !inlist( this.Cliente.SituacionFiscal_pk, 0, 3 )
			lcError = "En una acción cancelatoria solo es posible seleccionar clientes con situación fiscal 'Consumidor final'."
			goServicios.Errores.LevantarExcepcion( lcError )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CargarDetalleImpuestosDesdeFactura() as Void
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function TieneAccionCancelatoria() as Boolean
		local llRetorno as Object 
		llRetorno = .f.
		if pemstatus( this, "AccionCancelatoria", 5 ) 
			llRetorno = this.AccionCancelatoria
		endif
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function LimpiarOItemDetalleComprobante() as Void
		if type( "this.FacturaDetalle" ) = "O" and !isnull(this.FacturaDetalle)
			this.FacturaDetalle.oItem.limpiar()
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function LimpiarDetalleArticulosDespachos() as Void
		if type( "this.oEntidadSeleccionDespachos" ) = "O" and !isnull(this.oEntidadSeleccionDespachos)
			this.oEntidadSeleccionDespachos.DetalleArticulosDespachos.limpiar()
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function VerificarSiHayArticulosQueImprimenDespacho() as boolean
		local loListaArticulo as Object, lcCodArt as String, lcTSQL_IN as string,;
		lcCursorArt as String, lcQueryArtConDesp as String
		
	 	lcTSQL_IN = ""
	 	
	&&Se arma una lista de artículos unicos, unicidad de códigos de artículos.
		loListaArticulo = newobject( "collection" )
		for i = 1 to this.FacturaDetalle.Count 
			lcCodArt = rtrim( upper( this.FacturaDetalle.Item[i].Articulo_pk ) )
			if empty( lcCodArt )
				loop
			endif
			if !this.ExisteEnLista( loListaArticulo, lcCodArt )
				loListaArticulo.add( lcCodArt, lcCodArt )
			endif			
		endfor

		if loListaArticulo.Count == 0
			llRetorno = .F.
			return llRetorno
		endif

		for i = 1 to loListaArticulo.Count
			lcTSQL_IN = lcTSQL_IN + "'" + loListaArticulo.Item[i] + "', "
		endfor
		lcTSQL_IN = left( lcTSQL_IN, len( lcTSQL_IN ) - 2 )
		
		
	* Aca me traigo los articulos que imprimen despacho de los que ingresaron en el detalle
		lcCursorArt = "c_ArtImpDesp"
		lcQueryArtConDesp = "Select ArtCod from Zoologic.Art where Art.esImpDes = 1 and rtrim( Art.ArtCod ) in ( " + lcTSQL_IN + " ) "
		goServicios.Datos.EjecutarSentencias( lcQueryArtConDesp, "", "", lcCursorArt, this.DataSessionID )
		
		select ( lcCursorArt )
		if _tally > 0
			llRetorno = .T.
		else
			llRetorno = .F.
		endif
		
		return llRetorno		
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ExisteEnLista( toLista as Collection, tcCodigo as stirng ) as Boolean
		Local leItem As Variant, llRetorno As boolean

		llRetorno = .T.
		Try
			leItem = toLista.Item( tcCodigo )
		Catch
			&& Si no encuentra el item
			llRetorno = .F.
		Endtry

		Return llRetorno
	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	function ValidarSiImprimeDespacho() as boolean
		local llRetorno as boolean
		
		llRetorno = .F.
		
		if type( "This.FacturaDetalle" ) = "O" and This.lImprimeNumeroDeDespachoDeArticulos and !empty( This.Cliente_pk ) and This.Cliente.SituacionFiscal_pk != 3
			llRetorno = this.VerificarSiHayArticulosQueImprimenDespacho()
		endif
		
		Return llRetorno
	Endfunc
	
	*-----------------------------------------------------------------------------------------
	Function VerificarSiEsComprobanteFiscal() as boolean
		
		Return this.EsComprobanteFiscal()

	Endfunc

	*-----------------------------------------------------------------------------------------
	Protected Function AplicarDescuentoFinanciero() as Void
	EndFunc 

	*-----------------------------------------------------------------------------------------
	Protected Function AplicarRecargoFinanciero() as Void
	EndFunc 

	*-----------------------------------------------------------------------------------------
	Function EventoPreguntarEliminarTicketExistente( tcComprobante as String ) as Void
	Endfunc
	
	*-----------------------------------------------------------------------------------------
	Function EventoPreguntarImprimirTicketFaltantes() as Void
	Endfunc

	*-----------------------------------------------------------------------------------------
	function SetearDatosFiscalesComprobanteSinPuntoDeVenta() as Void
		if type( "this.oComponenteFiscal" ) = "O"
			with this
				if empty( .Letra ) or ( !This.VerificarContexto( "I" ) and !( This.VerificarContexto( "R" ) and !this.TieneTalonarioManual() ) )
					this.lObteniendoLetra = .t.
					if .esEdicion() or .esNuevo()
						.oComponenteFiscal.SetearSituacionFiscalCliente( .Cliente.SituacionFiscal_PK )
					endif
					if .esNuevo() or ( .esEdicion() and this.lCambioCliente ) 
						.Letra = this.ObtenerLetra()
					endif
					this.lObteniendoLetra = .f.
				endif
				
 
				if empty( .PuntoDeVenta )
					.PuntoDeVenta = this.ObtenerPuntoDeVenta()
				endif
				
			endwith
		EndIf	

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EsComprobanteEnBaseAComprobanteOnline() as Boolean
		local llRetorno as Boolean
		
		 llRetorno = (this.TipoComprobante = 11 or this.EsNotaDeCredito() ) and pemstatus(this, "BASADOENCOMPROBANTEONLINE", 5) and this.BasadoEnComprobanteOnline
		
		return llRetorno		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EsComprobanteConEntregaOnline() as Boolean
		local llRetorno as Boolean
		
		llRetorno = inlist( this.TipoComprobante, 1, 2, 27, 54 ) and this.EntregaPosterior = 3
		
		return llRetorno
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	Function oColaboradorComprobantesOnline_access() as Void
		If !this.lDestroy and !( vartype( this.oColaboradorComprobantesOnline) == "O" )
			this.oColaboradorComprobantesOnline = _screen.Zoo.CrearObjeto( "ColaboradorComprobantesOnline" )
		Endif
		Return this.oColaboradorComprobantesOnline
	endfunc

	*-----------------------------------------------------------------------------------------
	function ManejarRespuesta( tnStatus as Integer ) as Void
	
		 if tnStatus = 200
		 	this.FueInformadoALaNube = .T.
		 else
		 	this.FueInformadoALaNube = .F.
		 endif

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerPendientesDeEntregaOnline( tcIdDeCentralizacion as String ) as Void
	
		this.oColaboradorComprobantesOnline.ObtenerPendientes( tcIdDeCentralizacion )
		this.oColaboradorComprobantesOnline.PasarDetalleACursor( this.DataSessionId )		
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerCantidadPendientesDeEntregaOnline() as Integer
		return this.oColaboradorComprobantesOnline.ObtenerTotalPendientes()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function LlenarDetalleConPendientesOnline() as Void
		local loItemAuxiliar as Object, loItem as Object, i as integer
		
		i = 0
		this.ObtenerCursorConDescripcionesDeArticulos()
		this.ObtenerCursorConDescripcionesDeColores()
		
		select( "C_detallePendientes" )
		scan
			select( "C_ArtDes" )
			locate for artcod = C_detallePendientes.Articulo
			select( "C_ColorDes" )
			locate for colcod = C_detallePendientes.Color
			select( "C_detallePendientes" )
			i = i + 1
			loItemAuxiliar = this.FacturaDetalle.CrearItemAuxiliar()
			loItemAuxiliar.NroItem = i
			loItemAuxiliar.IdItemArticulos = goservicios.librerias.obtenerguidpk()
			loItemAuxiliar.Articulo_PK = Articulo
			loItemAuxiliar.ArticuloDetalle = c_ArtDes.ArtDes
			loItemAuxiliar.Color_PK = Color
			loItemAuxiliar.ColorDetalle = c_ColorDes.ColDes
			loItemAuxiliar.Talle_PK = Talle
			loItemAuxiliar.Cantidad = Pendiente
			loItemAuxiliar.Afe_Cantidad = Pendiente
			loItemAuxiliar.Afe_Saldo = Pendiente
			replace Afectado with Pendiente
			loItemAuxiliar.Usarpreciodelista = .T.
			this.FacturaDetalle.oItem.oCompPrecios.ObtenerPrecio( loItemAuxiliar, this.ListaDePrecios_PK )
			this.FacturaDetalle.AgregarItemPlano( loItemAuxiliar )
		endscan
		
		if pemstatus( this, "oComponenteFiscal", 5 ) and pemstatus( this.oComponenteFiscal, "RecalcularImpuestos", 5 )                
			this.oComponenteFiscal.RecalcularImpuestos(this.FacturaDetalle,this.impuestosDetalle)
		endif                       
		if pemstatus(this,"AplicarRecalculosGenerales",5)
			this.AplicarRecalculosGenerales()
		else
			loControlDetalle = this.ObtenerControl( this.FacturaDetalle.cNombre )
			loControlDetalle.RefrescarGrilla()
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarIngresoEnBaseAPendienteDeEntregaOnline() as Void

		if this.EsComprobanteEnBaseAComprobanteOnline() and this.DebeValidarIngresoDeItem()
			this.FacturaDetalle.oItem.cDataSessionEntidad = this.DataSessionId
			this.FacturaDetalle.oItem.VerificarCantidadDisponibleOnlineEnItemNuevo( this.FacturaDetalle.oItem.Cantidad )
		endif

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function DescontarEnBaseAPendienteDeEntregaOnline() as Void
		if this.EsComprobanteEnBaseAComprobanteOnline() and this.DebeDescontarCantidadDeItemEnPendientes()
			this.FacturaDetalle.oItem.cDataSessionEntidad = this.DataSessionId
			this.FacturaDetalle.oItem.DescontarCantidadAfectadaDePendientes( this.FacturaDetalle, this.FacturaDetalle.oItem.NroItem )
		endif

	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearFlagEnBaseAComprobanteOnline() as Void

		if this.EsComprobanteEnBaseAComprobanteOnline()
			this.FacturaDetalle.oItem.lHechoEnBaseAComprobanteOnline = .T.
			this.FacturaDetalle.oItem.cDataSessionEntidad = this.DataSessionId
		else
			this.FacturaDetalle.oItem.lHechoEnBaseAComprobanteOnline = .F.			
		endif
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ExisteEnDetalleYCantidadEsDistintaDeCero() as Void
		local loItem as Object, llExiste as Boolean
		llExiste = .f.
		loItem = this.FacturaDetalle.Item[ this.FacturaDetalle.oItem.NroItem ]
		llExiste = !empty(loItem.Articulo_PK) and loItem.Cantidad != 0
		this.FacturaDetalle.oItem.lExisteEnDetalleYCantidadEsDistintaDeCero = llExiste
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function DebeValidarIngresoDeItem() as Boolean
		local llRetorno as Boolean 
		llRetorno = !empty( this.FacturaDetalle.oItem.Articulo_PK ) 
		llRetorno = llRetorno and (this.FacturaDetalle.oItem.NroItem = 0 or empty( this.FacturaDetalle.Item[ this.FacturaDetalle.oItem.NroItem ].Articulo_PK ) )
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function DebeDescontarCantidadDeItemEnPendientes() as Boolean
		local llRetorno as Boolean 
		llRetorno = (this.FacturaDetalle.oItem.NroItem > 0 and empty(this.FacturaDetalle.oItem.Articulo_PK) and !empty( this.FacturaDetalle.Item[this.FacturaDetalle.oItem.NroItem].Articulo_PK) )
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearEntregaOnline() as void
		this.lTieneContratadaEntregaOnline = (this.lEsComprobanteConEntregaPosterior or this.EsNotaDeCredito() ) and this.TieneContratadoElServicio( 2 )
	endfunc

	*-----------------------------------------------------------------------------------------
	function CambiarListadepreciosSegunTipoEnBaseA() as boolean
		local lRetorno as Boolean
		if this.HayBasadoen() and !this.EsNotaDeCredito()
			this.lMostrarAdvertenciaRecalculoPrecios = .t.
			lRetorno =  .T.
		else
			lRetorno = !this.HayBasadoen()
		endif
		return lRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EsComprobanteConEntregaOnlineQueDebeInformarse() as Void
		local llRetorno as boolean

		llRetorno = inlist( this.TipoComprobante, 3, 5, 11, 12, 28 ) and this.BasadoEnComprobanteOnline
		
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerCursorConDescripcionesDeArticulos() as Void
		local lcSentencia as String, lcArticulos as String, lcWhere as String
		lcArticulos = this.ObtenerStringDeArticulos()
		if empty( lcArticulos )
			lcWhere = ""
		else
			lcWhere = " where ART.ARTCOD in (" + lcArticulos + ")"
		endif
		lcSentencia = "select artcod, artdes from ART" + lcWhere
		goServicios.Datos.EjecutarSentencias( lcSentencia, "ART", "", "c_ArtDes", this.DataSessionId )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerCursorConDescripcionesDeColores() as Void
		local lcSentencia as String, lcColores as String, lcWhere as String
		lcColores = this.ObtenerStringDeColores()
		if empty( lcColores )
			lcWhere = ""
		else
			lcWhere = " where COL.COLCOD in (" + lcColores + ")"
		endif
		lcSentencia = "select colcod, coldes from COL" + lcWhere
		goServicios.Datos.EjecutarSentencias( lcSentencia, "COL", "", "c_ColorDes", this.DataSessionId )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function AjustarObjetoBusquedaArticulo( toBusqueda as Object ) as Void
		local lcArticulos as String 
		if this.EsComprobanteEnBaseAComprobanteOnline()
			lcArticulos = this.ObtenerStringDeArticulos()
			if !empty( lcArticulos )
				toBusqueda.Filtro = toBusqueda.Filtro + iif( !empty( toBusqueda.Filtro ), " AND ", "") + "ART.ARTCOD in (" + lcArticulos + ")"
			endif
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerStringDeArticulos() as String
		local lcRetorno as String 
		lcRetorno = ""
		select distinct Articulo from C_detallePendientes into cursor c_ArtCod
		select c_ArtCod
		scan
			lcRetorno = lcRetorno + iif( !empty( lcRetorno ), ", ", "") + "'" + rtrim( Articulo ) + "'"
		endscan
		use
		return lcRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerStringDeColores() as String
		local lcRetorno as String 
		lcRetorno = ""
		select distinct Color from C_detallePendientes into cursor c_ColorCod
		select c_ColorCod
		scan
			lcRetorno = lcRetorno + iif( !empty( lcRetorno ), ", ", "") + "'" + rtrim( Color ) + "'"
		endscan
		use
		return lcRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerEstadoEvaluacionDePromocionesAutomaticas() as Void
		&&Se sobreescribe en ent_comprobantedeventasconvalores
		return .F.
	endfunc 
	*-----------------------------------------------------------------------------------------
	function EventoOcultarMostrarGrillaKits( tlSeAgrego as Boolean ) as Void
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function SetearContexto() as Void
		dodefault()
		if type( "This.KitsDetalle" ) = "O"
			this.KitsDetalle.oItem.cContexto = this.cContexto 
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function SoportaKits() as Boolean
		return type( "This.oCompKitDeArticulos" ) = "O"
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function TieneKits() as Boolean
		local llRetorno
		llRetorno = .f.
		if type( "This.KitsDetalle" ) = "O"
			llRetorno = this.KitsDetalle.nCantidadDeItemsCargados > 0
		endif
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ActualizarParticipantesPorCambioDeCombinacion( toItem as Object, tnCantidadAnterior as Number, tnMontoAnterior as Number ) as Void
		this.ActualizarParticipantesPorMonto( toItem, tnCantidadAnterior, tnMontoAnterior )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ActualizarParticipantesPorMonto( toItem as Object, tnCantidadAnterior as Number, tnMontoAnterior as Number ) as Void
		local llSeteandoCantidad as Boolean
		llSeteandoCantidad = iif( pemstatus( toItem, "lSeteandoCantidad", 5 ), !toItem.lSeteandoCantidad, .T. )		
		if toItem.CargoParticipantes and !empty( toItem.Articulo_PK ) and llSeteandoCantidad 
			this.ActualizarParticipantes( toItem, tnCantidadAnterior, tnMontoAnterior )
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ActualizarParticipantesPorCantidad( toItem as Object, tnCantidadAnterior as Number, tnMontoAnterior as Number ) as Void
		if toItem.CargoParticipantes and !empty( toItem.Articulo_PK )
			this.ActualizarParticipantes( toItem, tnCantidadAnterior, tnMontoAnterior )
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ActualizarParticipantes( toItem as Object, tnCantidadAnterior as Number, tnMontoAnterior as Number ) as Void
		this.oCompKitDeArticulos.ActualizarPrecioParticipantes( toItem, tnMontoAnterior, tnCantidadAnterior )
		this.EventoRefrescarDetalle( this.cDetalleParticipantes )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function DespuesDeProcesarItemKit( toItem as Object, tcAtributo as String, txValOld as Variant, txValActual as variant ) as Void
		local lcAtributo as String
		lcAtributo = upper( alltrim( tcAtributo ) )
		if lcAtributo == "ARTICULO_PK" and txValOld != txValActual && and empty( txValActual )
			this.oCompKitDeArticulos.EliminarParticipantes( toItem.IdKit )
			this.KitsDetalle.oItem.CargoParticipantes = .F.
			if !empty( txValOld )
				this.EventoRefrescarDetalle( this.cDetalleParticipantes )			
			endif
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EventoObtenerFilaActivaFacturaDetalle() as Void
	endfunc	
	
	*-----------------------------------------------------------------------------------------
	function EliminarParticipantes( tcIdKit ) as Void
		this.oCompKitDeArticulos.EliminarParticipantes( tcIdKit )
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	protected function AgregarKits( toItem as Object ) as Void
		if pemstatus( toItem, "oCompEnBaseA", 5 ) and type( "toItem.oCompEnBaseA" ) = "O" and toItem.oCompEnBaseA.nOperatoria > 0
		else
			if this.oCompKitDeArticulos.EsArticuloTipoKit( toItem.Articulo_pk )
				this.oCompKitDeArticulos.AgregarKitYParticipantes( toItem )
			endif
		endif
	endfunc

	*--------------------------------------------------------------------------------------------------------
	protected function AgregarParticipantes( toItem as Object ) as Void
		this.oCompKitDeArticulos.AgregarParticipantes( toItem )
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function EventoDespuesDeCargarParticipantes( tlCodigoDeBarra, toRespuesta as Object ) as Void
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function ErrorParticipante( tcKit as Object ) as Void
		this.oCompKitDeArticulos.ErrorParticipante( tcKit.articulo_pk, tcKit.Cantidad, tcKit.Precio, tcKit.Descuento, tcKit.MontoDescuento, tcKit.IdKit )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function SolicitarPDFParaEnvio() as Void
		local loDatosPlataforma as Object, loError as Object, lcNombreArchivo as String, lnI as Integer ,;
			llFaltaEnvio as Boolean, llFaltaVinculacion as Boolean, lnPlataformas as Integer 

		try
			loDatosPlataforma = this.oColaboradorJsonConvert.DesSerializar( this.DataECom )
			lnPlataformas = loDatosPlataforma.Plataforma.nSize 
			for lnI = 1 to lnPlataformas
				llFaltaEnvio = .f.
				llFaltaVinculacion = .f.
				if empty( loDatosPlataforma.Plataforma.array[lnI].EnvioId )
					this.AgregarInformacion( replicate(" ", 5) + "Falta el identificador del envío." )
					llFaltaEnvio = .t.
				endif
				if empty( loDatosPlataforma.Plataforma.array[lnI].IdVinculacion )				
					this.AgregarInformacion( replicate(" ", 5) +"Falta el identificador de vinculación de la plataforma " + rtrim(loDatosPlataforma.Plataforma.array[lnI].CodigoPlataforma) )
					llFaltaVinculacion = .t.
				endif
				if llFaltaEnvio or llFaltaVinculacion
					this.AgregarInformacion("Orden " + loDatosPlataforma.Plataforma.array[lnI].OrdenId) 
					loop
			endif
				lcNombreArchivo = this.ObtenerNombreArchivo( this.TipoComprobante, loDatosPlataforma.Plataforma.array[lnI] )
				loDatosPlataforma.Plataforma.array[lnI].IdVinculacion = alltrim( str( int( loDatosPlataforma.Plataforma.array[lnI].IdVinculacion ), 15, 0 ) )
				this.oColaboradorECommerce.GenerarEtiquetaDeEnvio(  alltrim( loDatosPlataforma.Plataforma.array[lnI].EnvioId ) , loDatosPlataforma.Plataforma.array[lnI].IdVinculacion, lcNombreArchivo )
			endfor
			
			if this.HayInformacion()
				if lnPlataformas > 1
					this.AgregarInformacion("No se pudieron generar todos los PDF de envío.")
				else
					this.AgregarInformacion("No se pudo generar el PDF de envío.")
			endif
				goServicios.Errores.LevantarExcepcion( this.oInformacion )
			endif
		catch to loError
			goServicios.Errores.LevantarExcepcion( loError )
		endtry
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerNombreArchivo( tnTipoComprobante as Integer, toDatosPlataforma as Object ) as String
		local lcRetorno as String, lcTipoCpte as String 
		lcTipoCpte = this.oComponente.ObtenerIdentificadorDeComprobante( tnTipoComprobante )
		lcRetorno  = upper(lcTipoCpte) + " " + this.Letra + " " + padl(alltrim(str(this.PuntoDeVenta )), 4, '0') + "-" + padl(alltrim(str(this.Numero)), 8, '0') + " (" + alltrim( toDatosPlataforma.EnvioID )+ ")"
		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function SetearDatosKitsDetalle() as Void
		if type( "this.KitsDetalle.oItem" ) = "O"
			this.KitsDetalle.SetearDatosAlModificar()
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function NuevoOnline( toCliente as Object, tlAutoCompletarDetalle as Boolean ) as Void
		local lnCantidadPendientes as Integer 
		this.ObtenerPendientesDeEntregaOnline( alltrim(toCliente.iDGlobal) )
		lnCantidadPendientes = this.ObtenerCantidadPendientesDeEntregaOnline()
		if lnCantidadPendientes > 0
			this.Nuevo()
			this.Cliente_PK = toCliente.Codigo
			this.BasadoEnComprobanteOnline = .T.
			if tlAutocompletarDetalle
				this.LlenarDetalleConPendientesOnline()
			endif
		else
			goServicios.Errores.LevantarExcepcionTexto( "No hay pendientes de entrega para el cliente (" + toCliente.Codigo + ") " + alltrim(toCliente.Nombre) )
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function DebeQuitarImpuestosAlDescuento() as Boolean
		return this.lIngresarMontoDeDescuentoRecargoConIvaIncluidoEnComprobantesA and ( inlist( this.Letra, "A", "M" ) or this.EsComprobanteA() )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function EsComprobanteA() as Boolean
		local llRetorno
		llRetorno = .F.
		if this.ocomponentefiscal.nsituacionfiscalempresa == 1 and ( this.ocomponentefiscal.nsituacionfiscalcliente == 1 or this.PermiteFacturaAaMonotributistas( this.ocomponentefiscal ) )
			llRetorno = .T.
		endif
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function PermiteFacturaAaMonotributistas( toComponenteFiscal as Object ) as Boolean
		local llRetorno as Boolean
		llRetorno = ( toComponenteFiscal.nSituacionFiscalCliente = toComponenteFiscal.oSFiscal.Monotributo and toComponenteFiscal.lComprobantesAMonotributistas )
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidacionMontoDescuento3( txVal as Variant ) as Boolean
		local llRetorno as Boolean
		llRetorno = .T.

		if txVal != 0 and pemstatus( This, "SubTotalBruto", 5 ) and This.SubtotalBruto = 0
			llRetorno = .F.
			goServicios.errores.LevantarExcepcion("No se puede agregar montos de descuento si el subtotal de artículos es 0." )
		endif
		return llRetorno

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerLetraDelComprobante() as Void
		this.FacturaDetalle.cLetraComprobante = this.Letra
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoPasarAlSiguienteItem() as Void
		&&Hola soy un evento
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function SetearColeccionParticipantesEnItem( toItem as Object ) as Void
		toItem.oColParticipantes = this.oCompKitDeArticulos.ObtenerParticipantesConPrecios( toItem )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function RecalcularPreciosDeDetallesAdicionales( tcListaDePrecios as String ) as Void
		dodefault( tcListaDePrecios )

		if this.SoportaKits()
			this.KitsDetalle.RecalcularPorCambioDeListaDePrecios( tcListaDePrecios )
		endif
		
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ActualizarDetallesAdicionales() as Void
		local loComponenteFiscal as Object
		dodefault()
		if this.SoportaKits()
			loComponenteFiscal = This.KitsDetalle.oItem.oComponenteFiscal
			loComponenteFiscal.ActualizarDetalleArticulos( this.KitsDetalle )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function RecalcularImpuestosDetalleAdicionales() as Void
		local loComponenteFiscal as Object
		dodefault()
		if this.SoportaKits()
			loComponenteFiscal = This.KitsDetalle.oItem.oComponenteFiscal
			loComponenteFiscal.RecalcularImpuestos( this.KitsDetalle, loComponenteFiscal.oImpuestosDetalle )
			this.EventoRefrescarDetalle( "KitsDetalle" )
		endif
	endfunc
		
	*-----------------------------------------------------------------------------------------
	function EstaAfectadoPorKit( loItem as Object ) as Boolean
		return !empty( loItem.idKit )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoLlenarComboPuntosDeVenta( txval as Variant ) as Void
		&&Evento en kontroler
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function SetearMonedaEnDetalleValoresParaActualizarCotizacion() as Void		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function PedirCotizacionParaLaFechaDelComprobante() as Boolean
		return goParametros.Felino.GestionDeVentas.PedirCotizacionParaLaFechaDelComprobante
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerFechaDeUltimaCotizacion() as Date
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function DebeCambiarListaDePrecios() as Boolean
		return this.Cliente.ListaDePrecio.Moneda_Pk = this.MonedaComprobante_Pk and this.lCambioMonedaComprobante
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Validar_MonedaComprobante( txVal as variant, txOldVal as variant ) as Boolean
		local llRetorno as Boolean, llValidar as Boolean

		llRetorno = dodefault( txVal, txOldVal )
		
		llValidar = !empty( txOldVal )
		
		if llRetorno and llValidar and this.cComprobante != "RECIBO"
			llRetorno = this.oValidadores.ValidadorComprobanteDeVentas.ValidarMonedaComprobante( this, txVal, txOldVal )
		endif

		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ActualizoDetalles( ) as Void
		local lnCantidadArticulos as Integer, lnCantidadValores as Integer
		
		if pemstatus( this, "lHabilitarMonedaComprobante_PK", 5 )
			if type( "This.FacturaDetalle" ) = "O"
				lnCantidadArticulos = this.FacturaDetalle.CantidadDeItemsCargados()
				if pemstatus( this, "ArticulosSeniadosDetalle", 5 )
					lnCantidadArticulos = lnCantidadArticulos + this.ArticulosSeniadosDetalle.CantidadDeItemsCargados()       
				endif
			else
				lnCantidadArticulos = 0
			endif
			if pemstatus( this, "ValoresDetalle", 5 )
				lnCantidadValores = this.ValoresDetalle.CantidadDeItemsCargados()
			else
				lnCantidadValores = 0
			endif
			this.lHabilitarMonedaComprobante_PK = ( lnCantidadArticulos = 0 ) and ( lnCantidadValores = 0 )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function LimpiarNombreEntidadAfectada() as Void
		if vartype(this.oCompEnBaseA) = 'O'
			this.oCompEnBaseA.cNombreEntidadAfectada = ""
			if vartype(this.oCompEnBaseA.onumerocomprobanteafectado) = 'O'
				this.oCompenbasea.onumerocomprobanteafectado.Remove(-1)
			endif		
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function CalcularDeudaCCyCheque( tlNoControlarCheques as Boolean ) as Void
		local lcSentencia as String, lcCursorDeuda as String, llParametro as Boolean	

		if pemstatus( this, "deuda", 5 )
			
			if !tlNoControlarCheques
				llParametro = goservicios.parametros.felino.gestiondeventas.cuentacorriente.incluirchequesdetercerosnovencidosalsaldodeudor
			endif
			
			lcSentencia = ""
			lcCursorDeuda = sys(2015)
			
			lcSentencia = "select Funciones.ObtenerDeudaExtendida('" 
			lcSentencia = lcSentencia + iif( llParametro, "1", "0" ) + "','" + this.cliente_PK + "','" + this.Cliente.idGlobal + "') as Deuda"
		
			goServicios.Datos.EjecutarSentencias( lcSentencia, "CTACTE", "", lcCursorDeuda, this.DataSessionId )
			
			select &lcCursorDeuda			
			if reccount() > 0
				this.Deuda = &lcCursorDeuda..deuda
			endif
			
			use in select( "lcCursorDeuda" )
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerTopeDelCliente() as Void
		*para que se bindee el kontroler
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	function AdvertirSobrepasoDeCreditoPorCambioDeTotal( txVal as Variant ) as Void
		*para que se bindee el kontroler
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CalcularDeudaRemitos() as Integer
		local loColaboradorRemitos as Object

		 return this.oColaboradorRemitos.ObtenerMontoRemitosPendientesDelCliente( this )
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsRemitoEnBaseAFacturaEntPosterior() as Boolean
		local llRetorno as Boolean

		if upper(This.cNombre) = "REMITO"
			llRetorno = this.oColaboradorRemitos.EsComprobanteEnBaseAFacturaEntPosterior( this )
		else
			this.oColaboradorRemitos.SetearEsRemitoEnBaseAFacturaEntPosterior()
		endif
		
		return llRetorno

	endfunc		

	*-----------------------------------------------------------------------------------------
	function oColaboradorRemitos_access() as Void
		if !this.lDestroy and vartype( this.oColaboradorRemitos ) != 'O' and isnull( this.oColaboradorRemitos )
			this.oColaboradorRemitos = _screen.zoo.crearobjeto("ColaboradorRemitos")
		endif
		return this.oColaboradorRemitos
	endfunc 

	*-----------------------------------------------------------------------------------------
	function DebeIncluirRemitosDeVentasEnControlDeLimiteDeCredito() as Void
		local llRetorno as Boolean
		
		if inlist( upper( alltrim( this.cNombre ) ), "FACTURA", "REMITO", "FACTURAAGRUPADA", "FACTURADEEXPORTACION", "FACTURAELECTRONICAEXPORTACION", "FACTURAELECTRONICA", "TICKETFACTURA", "FACTURAELECTRONICADECREDITO" )
			llRetorno =	goServicios.Parametros.Felino.GestionDeVentas.CuentaCorriente.IncluirRemitosDeVentasEnControlDeLimiteDeCredito
		endif
			
		return llRetorno
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoMensajeBlanquearErrorPrecio() as Void

	endfunc 

	*-----------------------------------------------------------------------------------------
	function EstaProcesando() as Boolean
		local llRetorno as Boolean
		llRetorno = dodefault()
		llRetorno = llRetorno or this.lAsignandoDescuento
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function TotalCompradoMensual() as Double
		&& Función que obtiene el total comprado por el cliente en el mes actual
		&& La implementación de la consulta SQL se agregará después
		local lnRetorno as Double
		lnRetorno = 0
		
		&& TODO: Implementar consulta SQL para obtener el total comprado en el mes
		&& por el cliente actual
		
		return lnRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function CalcularNivelDeCliente( tnTotalMensual as Double ) as Integer
		local lnNivel as Integer
		
		do case
			case tnTotalMensual <= 250000
				lnNivel = 1
			case tnTotalMensual <= 500000
				lnNivel = 2
			case tnTotalMensual <= 750000
				lnNivel = 3
			otherwise
				lnNivel = 4
		endcase
		
		return lnNivel
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerPorcentajeDescuentoPorNivel( tnNivel as Integer ) as Double
		local lnPorcentaje as Double
		
		do case
			case tnNivel = 1
				lnPorcentaje = 5
			case tnNivel = 2
				lnPorcentaje = 10
			case tnNivel = 3
				lnPorcentaje = 15
			case tnNivel = 4
				lnPorcentaje = 20
			otherwise
				lnPorcentaje = 0
		endcase
		
		return lnPorcentaje
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ActualizarNivelYDescuentoDeCliente() as Void
		local lnTotalMensual as Double
		local lnNivelAnterior as Integer
		local lnNivelNuevo as Integer
		local lnPorcentajeAnterior as Double
		local lnPorcentajeNuevo as Double
		
		if vartype( this.Cliente ) = "O" and !isnull( this.Cliente ) and !empty( this.Cliente.Codigo )
			&& Obtener total comprado mensual
			lnTotalMensual = this.TotalCompradoMensual()
			
			&& Agregar el total actual del comprobante para proyectar el nivel
			lnTotalMensual = lnTotalMensual + this.Total
			
			&& Guardar valores anteriores para comparar cambios
			lnNivelAnterior = this.NivelDeClienteAsignado
			lnPorcentajeAnterior = this.nPorcentajeDescuentoNivel
			
			&& Calcular nuevo nivel y porcentaje
			lnNivelNuevo = this.CalcularNivelDeCliente( lnTotalMensual )
			lnPorcentajeNuevo = this.ObtenerPorcentajeDescuentoPorNivel( lnNivelNuevo )
			
			&& Actualizar propiedades del comprobante
			this.nTotalCompradoMensual = lnTotalMensual
			this.NivelDeClienteAsignado = lnNivelNuevo
			this.nPorcentajeDescuentoNivel = lnPorcentajeNuevo
			
			&& Aplicar descuento solo si cambió el nivel o el porcentaje
			if lnNivelAnterior != lnNivelNuevo or lnPorcentajeAnterior != lnPorcentajeNuevo
				this.AplicarDescuentoPorNivel( lnPorcentajeNuevo )
			endif
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AplicarDescuentoPorNivel( tnPorcentaje as Double ) as Void
		&& Aplicar el descuento por nivel al comprobante
		if tnPorcentaje > 0
			&& Usar el sistema existente de descuentos
			this.PorcentajeDescuento = tnPorcentaje
			this.RecalcularDescuentos()
		else
			&& Si no hay descuento, limpiar el descuento existente
			this.PorcentajeDescuento = 0
			this.RecalcularDescuentos()
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function Setear_Total( txVal as Variant ) as Void
		&& Interceptar cuando se setea el total para recalcular nivel de cliente
		dodefault( txVal )
		
		&& Solo recalcular si:
		&& 1. No estamos en proceso de cálculo de descuentos (evitar bucles)
		&& 2. Hay un cliente asignado con código
		&& 3. El comprobante no está siendo limpiado
		if !this.lAsignandoDescuento and !this.lEstoySeteandoRecargos and !this.lLimpiando
			if vartype( this.Cliente ) = "O" and !isnull( this.Cliente ) and !empty( this.Cliente.Codigo )
				this.ActualizarNivelYDescuentoDeCliente()
			endif
		endif
	endfunc

EndDefine

