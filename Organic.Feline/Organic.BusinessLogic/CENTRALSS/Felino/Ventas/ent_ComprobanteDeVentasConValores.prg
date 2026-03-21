Define Class Ent_ComprobanteDeVentasConValores as Her_EntidadComprobanteDeVentas of Her_EntidadComprobanteDeVentas.prg

	#DEFINE NUEVALINEA chr(13) + chr(10)

	#if .f.
		Local this as Ent_ComprobanteDeVentasConValores of Ent_ComprobanteDeVentasConValores.prg
	#endif

*!* -->		#include valores.h
	#define TIPOVALORMONEDALOCAL			1
	#define TIPOVALORMONEDAEXTRANJERA		2
	#define TIPOVALORTARJETA       			3
	#define TIPOVALORCHEQUETERCERO 			4
	#define TIPOVALORCHEQUEPROPIO  			9
	#define TIPOVALORCIRCUITOCHEQUETERCERO	12
	#define TIPOVALORCIRCUITOCHEQUEPROPIO  	14
	#define TIPOVALORCUENTABANCARIA			13
	#define TIPOVALORPAGOELECTRONICO		11
	#define TIPOVALORCUENTACORRIENTE   		6
	#define TIPOVALORVALEDECAMBIO			8
	#define TIPOVALORPAGARE					5
	#define TIPOVALORTICKET					7
	#define TIPOVALORAJUSTEDECUPON  10

	#define TIPOMOVIMIENTONODEFINIDO 0
	#define TIPOMOVIMIENTOENTRADA			1
	#define TIPOMOVIMIENTOSALIDA			2
	#define ESTADOINGRESADO					1
	#define ESTADOSELECCIONADO				2
*!*		#include valores.h   <--

	#define PRECISIONMONTOS					4
	#define PRECISIONCOEFICIENTES			8
	
	Protected oManagerPromociones as Object
	Protected oColaboradorPromocion
	Protected oColaboradorPromocionPorMedioDePago
	Protected lExistenPosIntegrados as Boolean

	oEntidadValor = null
	oManagerPromociones = null
	oColaboradorPromocion = null
	oColaboradorPromocionPorMedioDePago = null
	lExistenPosIntegrados = null

	Fecha = {}
	total = 0	
	lRecalcularVuelto = .t.
	lEliminarTicketExistente = .T.
	lImprimirTicketFaltantes = .T.
	nVueltoAnterior = 0
	nVueltoAnteriorCotizado = 0
	cCodigoVueltoAnterior = ""
	IdVuelto_Pk = ""
	Caja_Pk = 0
	Vuelto = 0
	VueltoVirtual = 0
	nVueltoCotizado = 0
	cValoresDetalle = "ValoresDetalle"
	nSignoDeMovimientoAnterior = 1
	cClienteAnterior = ""
	oColeccionOriginalValores = null
	lImprimeTicketParaCambio = .f.
	lImprimeTicketTestigo = .f.
	lImprimirChequesDespuesDeGrabar = .f.
	lImprimeOrdenDeCompra = .f.
	lImprimeCheque = .f.
	TotalImpuestos = 0
	DescuentoSinImpuestos = 0
	SumItemsDetalleConImpuestos = 0
	SumItemsDetalleSinImpuestos = 0
	oDetallesMontosGravados = null
	lNoSePersonalizoComprobante	= .t.
	lAjusteDiferenciaValoresTotal = .f.
	lAsignarCodigoDeValorSugeridoParaVuelto = .t.
	cCodigoDeValorSugeridoParaVuelto = ""
	cDescripcionDeValorSugeridoParaVuelto = ""
	oConjuntoDeSeniasPendientes = null
	ComprobanteFiscal = .f.
	lMostrarMensajePosDefault = .t.
	oLibradorDeCheque = null	
	Senia_Pk = ""
	lPreguntoValorFinalizoComprobante = .f.
	lComprobanteConVuelto = .t.
	oColaboradorAjusteDeCupon = null
	oColAjustesDeCupon = null
	oValeDeCambio = null
	NoCalculaPercepcion = .f.
	oColeccionCuponesHuerfanos = null 
	oEntidadCuponesHuerfanos = null
	oCuponesIncluidos = null
	lCuponesHuerfanosEnColeccion = .f.
	lYaSeLanzoAvisoDeCuponesHuerfanos = .f.
	oEntidadPos = null 
	oCuponesHuerfanosAplicados = null 
	oColaboradorCondicionDePago = null
	lSeteandoCondicionDePagoPreferente = .f.
	lTieneVuelto = .f.
	oColaboradorCierreComprobantes = null
	lCursoresVacios = .F.
	lEstaCargandoDatosTarjeta = .f.
	lDebeCalcularVuelto = .t.
	nItemCondicionDePago = 0
	nRecargoPorcentajeDatosTarjeta = 0
	lSeteandoCondicionDePago = .f.
	lIncluirAnulacionesCuponesHuerfanos = .f.
	oValidadorTarjeta = null
	lAplicandoTaxFree = .f.
	lPidiendoCotizacion = .f.
	oItemAuxCotiza = null
	lCambioMonedaComprobante = .f.
	oColEstadoDeCajas = null
	oFacturaACancelar = null
	lPermiteAgregarArticulos = .t.
	oColeccion = null
	lQueHacerConCambio = .T.
	lGrabandoRecibo = .f.
	lAplicarDescuentoDeValores = .t.
	lAplicaPromocionesAutomaticas = .F.
	oItemArticuloOriginal = null
	lCargoPromocion = .F.
	lTieneEntregaPosterior = .f.
	lTieneEntregaOnLine = .f.
	lEsComprobanteConEntregaPosterior = .f.
	lEstaCargandoValoresAplicablesParaVuelto = .F.
	lPermiteComprobanteAsociado = .t.
	nNumeroDeCajaEnProcesoDeCierre = 0
	lTieneSeniaCargada = .F.
	cAtributosAOmitir = ""
	oColaboradorImpuestos = null

	oColaboradorSireWS = null
	lCanceloCargaSIRE = .f.
	lDebeObtenerCertificadoSIRE = .f.	
	oSireAModificar = null
	lPedirCertificadoSire = .t.
	lAplicarPromosAutomaticasAlSalirDelDetalle = .f.
	lAplicandoPromoDeAsistente = .f.
	lEstaCargandoPromocionAutomatica = .f.
	lSeEliminoUnaPromoAutomatica = .f.
	lSeEliminoUnaPromoBancaria = .f.
	
	oColaboradorTiquetDeCambio = null
	lTieneTiquetDeCambioPdf = .f.
	lSeConfirmoElEnvioDeMailAlGrabar = .f.
	lSeLeyeronLosParemetosParaTiquetDeCambio = .f.
	lEstoyEnUruguay = .f.
	lEsNuevoBasadoEnOAfectante = .f.
	lParametroEntregaPosteriorHabilitada = 1
	lParametroSugiereTipoDeEntrega = 1
	lIncorporarControlDeStockEnFacturasConEntregaPosterior = .f.
	lActualizaMailEnCliente = .f.
	lActualizarFecha = .f.
	lDebePedirSeguridadComprobantesA = .f.
	lTienePermisoComprobantesA = .f.
	oColaboradorDatosUruguay = null
	lHabilitaAgruparPacks = .f.
	oHerrAgrupadora = null
	lYaPreguntoAgrupamientoDePacks = .f.
	oColaboradorECommerce = null
	lYaSeteoStockInicial = .f.
	lRetiraEfectivo = .f.
	oColaboradorRetiroDeEfectivo = null
	oColaboradorAjusteChequeRechazado = null
	lExcluirComprobanteActualEnControlDeLimiteDeCredito = .F.
	lConfirmaAnulacion = .F.
	oColaboradorComprobantesDeVenta = null
	lGeneroNCPorCorreccionDeAlicuotaGiftCard = .f.
	lPlataformaEcommecerLoPermite = .t.
	
	*-----------------------------------------------------------------------------------------
	Function Destroy() as Void
		this.oFacturaACancelar = null
		Dodefault()
		this.oManagerPromociones = null
		this.oColaboradorPromocion = null
	endfunc
	
	*-----------------------------------------------------------------------------------------	
	function TieneValoresTipoChequeElectronico()  as Boolean	
		local llRetorno as Boolean, lcDetalle as String, lnI as Integer
		llRetorno = .f.
		lcDetalle = this.cValoresDetalle

		for lnI = 1 to this.&lcDetalle..Count
			if this.&lcDetalle..Item[lnI].ChequeElectronico 
				llRetorno = .t.
				exit
			endif
		endfor
		return llRetorno
	endfunc	
	
	*-----------------------------------------------------------------------------------------
	function oEntidadValor_Access() as Void
		if !this.lDestroy and !( vartype( this.oEntidadValor ) == "O" )
			this.oEntidadValor = _screen.zoo.instanciarentidad( "valor" )
			this.enlazar( 'oEntidadValor.eventoObtenerLogueo', 'inyectarLogueo' )
		endif
		return this.oEntidadValor
	endfunc 
	
	*-----------------------------------------------------------------------------------------	
	Function oColaboradorCierreComprobantes_access() as Void
		If !this.lDestroy and !( vartype( this.oColaboradorCierreComprobantes) == "O" )
			this.oColaboradorCierreComprobantes= _screen.Zoo.CrearObjeto( "ColaboradorCierreComprobantes" )
		Endif
		Return this.oColaboradorCierreComprobantes
	endfunc

	*-----------------------------------------------------------------------------------------
	Function oColaboradorDatosUruguay_Access() as void
		if !this.lDestroy and !( vartype( this.oColaboradorDatosUruguay ) == "O" )
			this.oColaboradorDatosUruguay = _screen.Zoo.CrearObjeto( "ColaboradorDatosUruguay" )
		endif
		
		Return this.oColaboradorDatosUruguay
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function oColaboradorRetiroDeEfectivo_Access() as Void
		if !this.lDestroy and !( vartype( this.oColaboradorRetiroDeEfectivo ) == "O" )
			this.oColaboradorRetiroDeEfectivo = _screen.Zoo.CrearObjeto( "ColaboradorRetiroDeEfectivo", "", this )
		endif
		
		Return this.oColaboradorRetiroDeEfectivo
	endfunc 
	
	*--------------------------------------------------------------------------------------------------------
	function oColaboradorComprobantesDeVenta_Access() as variant
		if !this.ldestroy and !( vartype( this.oColaboradorComprobantesDeVenta ) = 'O' )
			this.oColaboradorComprobantesDeVenta = _Screen.zoo.CrearObjeto( "ColaboradorComprobantesDeVenta", "ColaboradorComprobantesDeVenta.prg" )
		endif
		return this.oColaboradorComprobantesDeVenta
	endfunc
	
	*--------------------------------------------------------------------------------------------------------
	function oColaboradorAjusteChequeRechazado_Access() as variant
		if !this.ldestroy and !vartype( this.oColaboradorAjusteChequeRechazado ) = 'O' and inlist( upper( _screen.zoo.app.cProyecto ), "COLORYTALLE" )
			this.oColaboradorAjusteChequeRechazado = _Screen.zoo.CrearObjeto( "ColaboradorAjusteChequeRechazado", "ColaboradorAjusteChequeRechazado.prg", this )
		endif
		return this.oColaboradorAjusteChequeRechazado
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerPosDefault( toEntidadPos as ent_pos of ent_pos.prg ) as String
		local llExiste as Boolean, lcCodigo as String

		do case
			case inlist(alltrim( this.ValoresDetalle.oItem.Valor.Prestador ), "POINT", "POINT2")
				lcCodigo = upper(goParametros.Felino.GestionDeVentas.Tarjetas.DispositivoElectronicoDefault)
			case inlist(alltrim( this.ValoresDetalle.oItem.Valor.Prestador ), "MPQR", "MPQR2")
				lcCodigo = upper(left( goParametros.Felino.GestionDeVentas.Tarjetas.DispositivoMercadoPagoQRDefault, 10 ))
			case inlist(alltrim( this.ValoresDetalle.oItem.Valor.Prestador ), "GOCUOT", "STAFE", "CRYPTO")
				lcCodigo = ""
			otherwise
				lcCodigo = goParametros.Felino.GestionDeVentas.Tarjetas.DispositivoPosDefault
		endcase
		if empty( lcCodigo ) and !empty( this.ValoresDetalle.oItem.Valor.Prestador )
			lcCodigo = this.ObtenerPrimerDispositivoPagoElectronico()
		endif

		llExiste = toEntidadPos.ExistePos( lcCodigo )
	
		if !llExiste
			if this.lMostrarMensajePosDefault
				this.oMensaje.Advertir( "El dispositivo default '" + alltrim( lcCodigo ) + "' configurado no existe. Debe ingresarlo manualmente." )
				this.lMostrarMensajePosDefault = .f.
			endif
			lcCodigo = ""
		endif
		
		return lcCodigo
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerPrimerDispositivoPagoElectronico() as String
		local lcRetorno as String, lcSentencia as String

		lcSentencia = "Select top 1 codigo from Pos where pagoelec = 1 and prestador = '" + this.ValoresDetalle.oItem.Valor.Prestador + "' order by codigo asc"
		goServicios.Datos.EjecutarSentencias( lcSentencia, "Pos", "", "c_DipositivoPoint", this.DataSessionId )
		lcRetorno = alltrim( c_DipositivoPoint.Codigo )
		use in ( "c_DipositivoPoint" )

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function EsComprobanteConVuelto() as Boolean
		return This.lComprobanteConVuelto
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function Inicializar() as Void
		Dodefault()
		this.oDetallesMontosGravados = _Screen.Zoo.CrearObjeto( "ZooColeccion" ) 
		this.oColeccionOriginalValores = _Screen.Zoo.CrearObjeto( "ZooColeccion" )		
		this.oColeccionCuponesHuerfanos = _Screen.Zoo.CrearObjeto( "ZooColeccion" )	
		this.oCuponesIncluidos = _Screen.Zoo.CrearObjeto( "ZooColeccion" )
		
		If Type( "this." + This.cValoresDetalle ) = "O"
			loDetalle = This.cValoresDetalle
			this.&loDetalle..InyectarEntidad( This )
			If !Empty( this.cComprobante )
				if !this.lEsComprobanteDeMovimientoDeFondos
					this.enlazar( This.cValoresDetalle + ".EventoAntesDeAplicarRecargo", "CalculosPreRecargos" )
					this.enlazar( This.cValoresDetalle + ".EventoCambioSum_RecargoMontoSinImpuestos", "MontoRecargoEnPago" )
					this.enlazar( This.cValoresDetalle + ".EventoCambioSum_RecargoMonto", "MontoRecargoEnPago" )
					this.enlazar( This.cValoresDetalle + ".EventoCambioSum_Total", "AjusteDiferenciaValoresTotal" )
					this.enlazar( This.cValoresDetalle + ".EventoSeSeleccionoUnValorQueUtilizaRecargosPorMontos", "EventoSeSeleccionoUnValorQueUtilizaRecargosPorMontos" )
					this.enlazar( This.cValoresDetalle + ".EventoSeSeleccionoUnValorQueNoUtilizaRecargosPorMontos", "EventoSeSeleccionoUnValorQueNoUtilizaRecargosPorMontos" )
					this.enlazar( This.cValoresDetalle + ".EventoAntesDeActualizar", "ValidarUtilizacionDeValor" )
					this.BindearEvento( this.&loDetalle..oItem, "HaCambiado", this, "EventoAplicarCondicionDePago" )
				endif
				bindevent( this.&loDetalle, "Actualizar", this, "ActualizoDetalles", 1 )
				
				if "<VENTAS>" $ this.ObtenerFuncionalidades() and this.CondicionDeBindeo()
					this.BindearEvento( this, "Setear_Letra", this, "EvaluarSeteoPuntoDeVentaEnComboAPartirDeLetra" )
					this.BindearEvento( this, "Setear_PuntoDeVenta", this, "EvaluarSeteoPuntoDeVentaEnComboAPartirDePuntoDeVenta" )
				endif
			endif
		Endif
		if this.SoportaSenias()
			This.BindearEvento( This.ArticulosSeniadosDetalle, "EventoVerificarValidezArticulo" , This, "EventoVerificarValidezArticulo" ) 					
			if type( "this.ArticulosSeniadosDetalle.oItem" ) = "O"
				This.ArticulosSeniadosDetalle.oItem.InyectarListaDePrecios( This.ListaDePrecios )
				This.ArticulosSeniadosDetalle.oItem.cNombreComprobante = this.obtenerNombre()
			Endif
			This.oCompsenias.InyectarEntidad( This )		
			this.BindearEvento( this.oCompSenias, "EventoDespuesDeCargarSeniasPendientes", this, "RecalcularMontosPorCargaDeSenia" )
			this.BindearEvento( this.oCompSenias, "EventoDespuesLimpiarSeniasCargadas", this, "EventoDespuesLimpiarSeniasCargadas" )
			this.BindearEvento( this.oCompSenias, "EventoDespuesDeLimpiarDetalleDeArticulosSeniados", this, "EventoDespuesDeLimpiarDetalleDeArticulosSeniados" )
			this.BindearEvento( this.oCompSenias, "EventoSeAgregoQuitoSenia", this, "EventoSeAgregoQuitoSenia" )
			this.BindearEvento( this.oCompSenias, "EventoDespuesDeSeniarTodosLosArticulos", this, "RecalcularMontosPorCargaDeSenia" )
			this.BindearEvento( this.oCompSenias, "EventoDespuesDeVenderTodosLosArticulosSeniados", this, "RecalcularMontosPorCargaDeSenia" )
			this.BindearEvento( this.oCompSenias, "EventoDespuesDeFacturarSeniarItem", this, "RecalcularMontosPorCargaDeSenia" )			
		Endif

		If Type( "This.FacturaDetalle" ) = "O"
			This.BindearEvento( This.FacturaDetalle, "EventoVerificarValidezArticulo" , This, "EventoVerificarValidezArticulo" ) 					
			If Type( "This.FacturaDetalle.oItem" ) = "O"
				This.BindearEvento( This.FacturaDetalle.oItem.Articulo, "AjustarObjetoBusqueda" , This, "EventoSetearFiltroBuscadorArticulo" )
				if inlist( this.cNombre, "FACTURA", "TICKETFACTURA", "FACTURAELECTRONICA", "FACTURAELECTRONICADECREDITO", "FACTURAAGRUPADA" ) and goParametros.Felino.GestionDeVentas.HabilitarCircuitoDeConsignaciones
					This.BindearEvento( this.FacturaDetalle.oItem, "EventoEsComprobanteLiquidacion", this, "EsComprobanteLiquidacion" )
				endif
				if this.ValidarCircuitoGiftCard()
					This.FacturaDetalle.oItem.oCompGiftCard.InyectarEntidad( this )
				endif
			Endif
			
			this.BindearEvento(this.FacturaDetalle.oItem, "eventoNoSePuedeCalcularVuelto", this, "NoSePuedeCalcularVuelto")
			this.BindearEvento(this.FacturaDetalle.oItem, "eventoSePuedeCalcularVuelto", this, "SePuedeCalcularVuelto")
		Endif

		If this.SoportaPromociones()		
			this.SetearlAplicarPromosAutomaticasAlSalirDelDetalle()
			this.BindearEventosPromociones()
		Endif

		If this.SoportaDatosAdicionalesA()
			this.oCompDatosAdicionalesComprobantesA.InyectarEntidad( this )
		endif

		If this.SoportaDatosAdicionalesSIRE()
			this.oCompDatosAdicionalesSIRE.InyectarEntidad( this )
		endif
		
		if this.SoportaConsignacion() and goParametros.Felino.GestionDeVentas.HabilitarCircuitoDeConsignaciones
			this.oCompRegistroLiquidacionConsignaciones.InyectarEntidad( this )
		endif
		
		if this.TieneEmailParaActualizar()
			this.BindearEvento( This, "EventoActualizarEmail", this, "ActulizarEmail" )
		endif
		
		If Pemstatus( this, "ChequeReintegro", 5 )
			this.BindearEvento( this.FacturaDetalle.oItem, "EventoValidarSiElComprobanteTieneTaxFree", this, "ValidarSiElComprobanteTieneTaxFree" )		
		endif
		
		if this.lEsComprobanteConEntregaPosterior
			if This.VerificarContexto( "R" )
					this.Bindearevento(this,"EntregaPosterior_Assign",this,"ActualizarControlDeStock")
			else
				this.Bindearevento(this,"EventoSetearValorSugeridoComboEntregaPosterior",this,"ActualizarControlDeStock")
				this.Bindearevento(this,"SetearEntregaPosterior",this,"ActualizarControlDeStock")
				if this.SoportaSenias()
					this.Bindearevento(this,"setear_entregaposterior",this,"EventoHabilitarDeshabilitarAccionesSenia")
				endif
			endif			
		endif
		this.SetearAtributosAOmitir()
		
		this.lEstoyEnUruguay = ( GoParametros.Nucleo.DatosGenerales.Pais == 3 ) 

		this.lDebePedirSeguridadComprobantesA = this.DebePedirSeguridadComprobantesA()
		
		this.lMostrarSaldoDeLaCuentaCorrienteEnFacturaNDebyNCred = goservicios.Parametros.felino.gestiondeventas.cuentacorriente.MostrarSaldoDeLaCuentaCorrienteEnFacturaNDebyNCred
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarCircuitoGiftCard() as Void
		local llRetorno as Boolean
		llRetorno = inlist( this.cNombre, "FACTURA", "TICKETFACTURA", "FACTURAELECTRONICA", "FACTURAAGRUPADA", "NOTADECREDITO", "TICKETNOTADECREDITO", "NOTADECREDITOELECTRONICA", "NOTADECREDITOAGRUPADA" )
		llRetorno = llRetorno and ( goServicios.Parametros.Felino.GestionDeVentas.HabilitaCircuitoImplementativoGiftCard )
		llRetorno = llRetorno and !empty( goServicios.Parametros.Felino.GestionDeVentas.ArticuloDelComprobante )
		llRetorno = llRetorno and Type( "This.FacturaDetalle.oItem.oCompGiftCard" ) = "O"
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsComprobanteLiquidacion() as Void
		if pemstatus( this, "MercaderiaConsignacion", 5 )
			this.FacturaDetalle.oItem.lEsComprobanteDeLiquidacion = this.MercaderiaConsignacion
		endif
	endfunc
	*-----------------------------------------------------------------------------------------
	function CondicionDeBindeo() as boolean
		return !"<CF>" $ this.ObtenerFuncionalidades()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function oLibradorDeCheque_access() as object
		if !this.lDestroy and (type("this.oLibradorDeCheque") <> "O" or isnull(this.oLibradorDeCheque))
			this.oLibradorDeCheque = this.Cliente
		endif
		return this.oLibradorDeCheque
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function SePuedeCalcularVuelto() as Void
		this.lDebeCalcularVuelto = .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function NoSePuedeCalcularVuelto() as Void
		this.lDebeCalcularVuelto = .f.
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function oManagerPromociones_Access() as Void
		Local ldFechaModificacion as String
	
		If !this.lDestroy and !( Vartype( this.oManagerPromociones ) == "O" )
			this.oManagerPromociones = _screen.Zoo.CrearObjeto( "ManagerPromociones" )

			ldFechaModificacion = this.oManagerPromociones.ObtenerUltimaModificacionEnPromociones()
			
			If this.oManagerPromociones.dFechaModificacion != ldFechaModificacion 
				this.oManagerPromociones.CargarPromociones()
				this.oManagerPromociones.dFechaModificacion = ldFechaModificacion 
				this.oManagerPromociones.CargarRedondeos()
			Endif
		
			this.BindearEvento( This.oManagerPromociones, "EventoAplicarPromocionSeleccionadaEnAsistente", this, "AplicarPromoDeAsistente" )
			this.BindearEvento( This.oManagerPromociones, "EventoAplicarPromocionAutomatica", this, "AplicarPromoAutomatica" )
		Endif
		
		Return this.oManagerPromociones
	endfunc

	*-----------------------------------------------------------------------------------------
	Function MostrarPantallaAsistente( toInformacionParaAsistente as custom ) as Void
		this.oManagerPromociones.HabilitarSerializacionPorHilos()
		this.oManagerPromociones.MostrarAsistente( toInformacionParaAsistente )
		this.oManagerPromociones.CargarPromociones()
		this.EnviarASerializarRefrescandoPromocionesValidas()
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function HacerFocoEnAsistente() as Void
		this.oManagerPromociones.TraerAlFrenteAsistente()
	Endfunc

	*-----------------------------------------------------------------------------------------
	Protected Function oColaboradorAjusteDeCupon_Access() as Object
		If not this.lDestroy and vartype( this.oColaboradorAjusteDeCupon ) # "O"
			this.oColaboradorAjusteDeCupon = _Screen.zoo.crearobjeto( "ColaboradorAjusteDeCupon" )
		Endif
		Return this.oColaboradorAjusteDeCupon
	Endfunc

	*-----------------------------------------------------------------------------------------
	function oColAjustesDeCupon_Access() as Collection
		if !( vartype( this.oColAjustesDeCupon ) == "O"  ) or isnull( this.oColAjustesDeCupon )
			this.oColAjustesDeCupon = _Screen.Zoo.CrearObjeto( "ZooColeccion" )
		endif
		return this.oColAjustesDeCupon
	endfunc

	*-----------------------------------------------------------------------------------------
	function ExisteIdArticuloEnItemPromociones( tcIdItem as String ) as Boolean
		local lnI as Integer, llRetorno as Boolean
		llRetorno = .F.
		if type( "This.PromoArticulosDetalle" ) == "O" 
			for lnI = 1 to This.PromoArticulosDetalle.Count
				if This.PromoArticulosDetalle.Item[lnI].idItemArticulo == tcIdItem
					llRetorno = .T.
					exit for
				Endif
			endfor
		endif
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ExisteIdValoresEnItemPromociones( tcIdItem as String ) as Boolean
		local lnI as Integer, llRetorno as Boolean
		llRetorno = .F.
		for lnI = 1 to This.PromoArticulosDetalle.Count
			if This.PromoArticulosDetalle.Item[lnI].idItemValor == tcIdItem
				llRetorno = .T.
				exit for
			Endif
		Endfor
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ExisteIdPromocionEnItemPromociones( tcIdItemPromo as String ) as Boolean
		local lnI as Integer, llRetorno as Boolean
		llRetorno = .F.
		for lnI = 1 to This.PromoArticulosDetalle.Count
			if This.PromoArticulosDetalle.Item[lnI].idItemPromo == tcIdItemPromo
				llRetorno = .T.
				exit for
			Endif
		Endfor
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerDescripcionPromocionParaTooltip( tcIdItem as String ) as string
		local lnI as Integer, llRetorno as String, lcItemPromo as string
		lcRetorno = ""

		for lnI = 1 to This.PromoArticulosDetalle.Count
			if This.PromoArticulosDetalle.Item[lnI].idItemArticulo == tcIdItem
				lcItemPromo = This.PromoArticulosDetalle.Item[lnI].IdItemPromo
				lcRetorno = this.ObtenerAtributosDePromocionAfectante( lcItemPromo )
				exit for
			Endif
		endfor
		
		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerDescripcionArticulosParaTooltip( tcIdItem as String ) as String
		local lnI as Integer, llRetorno as String, lcItemArticulo as string
		lcRetorno = ""

		for lnI = 1 to This.PromoArticulosDetalle.Count
			if This.PromoArticulosDetalle.Item[lnI].idItemPromo == tcIdItem and !empty( This.PromoArticulosDetalle.Item[lnI].IdItemArticulo )
				lcItemArticulo = This.PromoArticulosDetalle.Item[lnI].IdItemArticulo
				lcRetorno = lcRetorno + chr( 13 ) + this.ObtenerAtributosDeArticuloAfectado( lcItemArticulo )
			Endif
		endfor
		
		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerAtributosDePromocionAfectante( tcIdItemPromo as String ) as string
		local lnI as Integer, lcRetorno as String
		lcRetorno = ""
		
		for lnI = 1 to This.PromocionesDetalle.Count
			if This.PromocionesDetalle.Item[lnI].IdItemPromocion == tcIdItemPromo
				lcRetorno = alltrim( This.PromocionesDetalle.Item[lnI].Promocion_PK ) + iif( !empty( This.PromocionesDetalle.Item[lnI].PromocionDetalle ), " - " + alltrim( This.PromocionesDetalle.Item[lnI].PromocionDetalle), "" )
				exit for
			Endif
		endfor
		
		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerAtributosDeArticuloAfectado( tcIdItemArt as String ) as string
		local lnI as Integer, lcRetorno as String, loAtributosCombinacion as Object
		
		lcRetorno = ""
		loAtributosCombinacion = AtributosCombinacionFactory()

		for lnI = 1 to This.FacturaDetalle.Count
			if This.FacturaDetalle.Item[lnI].IdItemArticulos == tcIdItemArt
				lcRetorno = "Item: " + alltrim( str( This.FacturaDetalle.Item[lnI].NroItem ) ) + ;
							this.ObtenerDescripcionAtributosCombinacion( loAtributosCombinacion, lnI )
				exit for
			Endif
		endfor
		
		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerDescripcionAtributosCombinacion( toAtributosCombinacion as Object, tnIndice as integer ) as string
		local lnJ as Integer, lcRetorno as string, lcAtributo as String, lcDetalle as String, ;
				lcAtri as String, lcDet as string

		lcRetorno = ""
		for lnJ = 1 to toAtributosCombinacion.Count
			lcAtributo = toAtributosCombinacion.Item[lnJ]
			lcDetalle = strtran( toAtributosCombinacion.Item[lnJ], "_pk", "" ) + "Detalle"
			lcAtri = "This.FacturaDetalle.Item[" + alltrim( str( tnIndice ) ) + "]." + lcAtributo
			lcDet = "This.FacturaDetalle.Item[" + alltrim( str( tnIndice ) ) + "]." + lcDetalle
			if !empty( alltrim( &lcAtri ) )
				lcRetorno = lcRetorno + " - " + alltrim( &lcAtri ) + ;
					iif( pemstatus( This.FacturaDetalle.Item[tnIndice], lcDetalle, 5 ), iif( !empty( &lcDet ), ":" + alltrim( &lcDet ), "" ), "" )
			Endif
		next
			
		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EnviarASerializarRefrescandoPromocionesValidas() as Void
		if !this.EstaEnProceso()
			this.oManagerPromociones.RefrescarPromocionesValidas()
			this.EnviarASerializar()
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EnviarASerializar() as Void
		if ( this.EsNuevo() or this.EsEdicion() ) and !this.EstaEnProceso()
			this.oManagerPromociones.SerializarComprobante( this )
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function AplicarPromocionesForzado() as Void
		if this.lAplicarPromosAutomaticasAlSalirDelDetalle 
			this.AplicarPromocionesAutomaticasForzado()
		else
			this.EnviarASerializar()
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function AplicarPromocionesAutomaticasForzado() as Void	
		if this.lAplicarPromosAutomaticasAlSalirDelDetalle and !this.lAplicandoPromoDeAsistente and this.FacturaDetalle.CantidadDeItemsCargados() > 0 and ;		
			this.oColaboradorPromocion.HayPromocionesAutomaticasVigentes( this.Fecha ) and ( this.EsNuevo() or this.EsEdicion() )
			
				this.EventoMostrarMensajeSinEspera("Aplicando promociones automáticas...")
				if this.TienePromos()
					this.BorrarPromocionesYDesafectarItems()
				endif
				this.oManagerPromociones.AplicarPromocionesAutomaticasForzado( this )
				this.EventoMostrarMensajeSinEspera()
			
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function BindearEventosPromociones() as Void
		this.BindearEvento( This.PromocionesDetalle.oItem, "HaCambiado", this, "ProcesarItemPromociones" )
		this.BindearEvento( This.PromocionesDetalle.oItem, "EventoAntesDeSetear", this, "AntesDeProcesarItemPromociones" )
		this.BindearEvento( This.FacturaDetalle.oItem.oCodigoDeBarras, "EventoValidarArticuloAfectadoPorPromocion", this, "ValidarArticuloAfectadoPorPromocion" )
		this.BindearEvento( This.FacturaDetalle.oItem, "EventoValidar_Articulo", this, "Validar_Articulo" )
		
		this.BindearEvento( This, "EventoCambioParticipantePromocion", this, "EnviarASerializarRefrescandoPromocionesValidas" )

		if this.SoportaPromociones()
			this.BindearEvento( This, "Setear_Fecha", this, "EvaluarSiAplicaPromocionesAutomaticas" )		
		endif
		this.BindearEvento( This.FacturaDetalle.oItem, "EventoCambioParticipantePromocion", this, "EnviarASerializar" )
		this.BindearEvento( This.ValoresDetalle.oItem, "EventoCambioParticipantePromocion", this, "EnviarASerializar" )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function AplicarPromoDeAsistente( idPromocion as String ) as Void
		local loError as Object
		if this.lEstaCargandoDatosTarjeta = .f.
			try 	
				this.lAplicandoPromoDeAsistente = .t.
				this.EventoGuardarControl()
				this.FacturaDetalle.LimpiarItem()
				this.FacturaDetalle.oItem.Articulo_PK = "$"+rtrim( idPromocion )
				this.FacturaDetalle.LimpiarItem()
				this.FacturaDetalle.Actualizar()
				*this.PromocionesDetalle.LimpiarItem()
				this.DespuesDeAplicarPromoDesdeAsistente()
			catch to loError
				goServicios.Errores.LevantarExcepcion( loError )
			finally
				this.lAplicandoPromoDeAsistente = .f.
			endtry
		endif
	endfunc
	 
	*-----------------------------------------------------------------------------------------
	function AplicarPromoAutomatica( tcIdPromocion as String ) as Void

		if this.lPlataformaEcommecerLoPermite 
			if this.lEstaCargandoDatosTarjeta = .f.
				this.lEstaCargandoPromocionAutomatica = .t.
				this.EventoGuardarControl()
				if !empty( this.FacturaDetalle.oItem.Articulo_PK )
					this.FacturaDetalle.LimpiarItem()
					this.EventoPasarAlSiguienteItem()
					this.oManagerPromociones.SerializarComprobante( this )
				else
					this.FacturaDetalle.oItem.Articulo_PK = "$"+rtrim( tcIdPromocion )
					this.FacturaDetalle.LimpiarItem()
					if !this.lEstaCargandoPromocionAutomatica
						this.FacturaDetalle.Actualizar()
					else
						this.lEstaCargandoPromocionAutomatica = .f.					
					endif
					this.EventoPasarAlSiguienteItem()
				endif
			endif
			this.oManagerPromociones.SerializarComprobante( this )
		endif
	
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function DespuesDeAplicarPromoDesdeAsistente() as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoGuardarControl() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarArticuloAfectadoPorPromocion( toItem as Object ) as Void
		if ( pemstatus( toItem, "lAfectadoPorUnaPromocion", 5 ) )
			toItem.lAfectadoPorUnaPromocion = this.ExisteIdArticuloEnItemPromociones( toItem.IdItemArticulos )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ProcesarItemPromociones( tcAtributo as string, toItem as object ) as Void
		local lcAtributo as String, loError as Object, lcDetalle as String
		lcAtributo = upper( alltrim( tcAtributo ) )

		if lcAtributo == "PROMOCION_PK" and !empty( toItem.Promocion_PK )
			This.EventoBloqueoVisual( .T. )
			this.ldebecalcularvuelto = .t.
			try
				this.oManagerPromociones.ValidarYAplicarPromocion( toItem, toItem.IdItemPromocion, this )
				this.EventoRefrescarGrillaArticulos()
				this.EventoBloqueoVisual( .F. )
				lcDetalle = this.cValoresDetalle
				if  this.&lcDetalle..count > 0
					this.&lcDetalle..actualizar()	 
				endif
			catch to loError
				toItem.Promocion_PK = ""
				this.EventoRefrescarGrillaArticulos()
				this.EventoBloqueoVisual( .F. )
				goServicios.Errores.LevantarExcepcion( loError )
			endtry
		endif

		if lcAtributo == "PROMOCION_PK" 
			loPromos = _screen.zoo.crearobjeto( "ZooColeccion" ) 
			for each loItemPromo in this.PromocionesDetalle
				if loItemPromo.PromocionTipo = 5
					loItem = createobject("empty")
					addproperty(loItem, "Promocion_PK", loItemPromo.Promocion_PK)
					addproperty(loItem, "IdItemPromocion", loItemPromo.IdItemPromocion)
					addproperty(loItem, "Tipo", loItemPromo.PromocionTipo)
					loPromos.add( loItem )
				endif
			endfor
			for each loItemPromo in loPromos
				if !empty( toItem.IdItemPromocion ) and loItemPromo.IdItemPromocion != toItem.IdItemPromocion
					this.oManagerPromociones.DesafectarItems( loItemPromo.IdItemPromocion , this )
					this.oManagerPromociones.ValidarYAplicarPromocion( loItemPromo, loItemPromo.IdItemPromocion, this )
				endif
			endfor
			loPromos = null
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoBloqueoVisual( tlBloquear as Boolean ) as Void

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarAtributoParticipanteDePromo( tcAtributo as String, txValor as Variant, txValorViejo as Variant ) as Void
		if txValor != txValorViejo and This.EsUnAtributoParticipanteDePromocion( tcAtributo )
			this.&tcAtributo. = txValor
			This.BorrarPromosEnLasQueParticipaElAtributo( tcAtributo )
			This.EventoValidarAtributoParticipanteDePromo( tcAtributo, txValor, txValorViejo )
		Endif	
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarAtributoSecundarioParticipanteDePromo( tcAtributo as String, txValor as Variant, txValorViejo as Variant ) as Void
		if txValor != txValorViejo and This.EsUnAtributoParticipanteDePromocion( tcAtributo )
			if inlist( upper( tcAtributo ), "PORCENTAJEDESCUENTO", "MONTODESCUENTO3" )
				this.&tcAtributo. = txValorViejo
				this.DespuesDeSetearDescuento()
				this.lComprobanteConDescuentosAutomaticos = .f.
				This.DescuentoAutomatico = .f.
				This.EventoMensajeBloqueoAtributoParticipanteDePromo( tcAtributo )
			endif
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EventoMensajeBloqueoAtributoParticipanteDePromo( tcAtributo as String ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoValidarAtributoParticipanteDePromo( tcAtributo as String, txValor as Variant, txValorViejo as Variant ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsUnAtributoParticipanteDePromocion( tcAtributo as String ) as boolean
		local llRetorno as Boolean, lcAtributo as String, lnI As Integer, lcAtributoCabecera as String
		lcAtributo = upper( alltrim( tcAtributo ) )
		llRetorno = .F.
		if lcAtributo == "LISTADEPRECIOS_PK"
		else
			for lni = 1 to This.PromoArticulosDetalle.Count
				lcAtributoCabecera = getwordnum( upper( alltrim( This.PromoArticulosDetalle.Item[ lnI ].AtributoCabecera ) ), 1, "." )
				if getwordcount( This.PromoArticulosDetalle.Item[ lnI ].AtributoCabecera, "." ) > 1
					lcAtributoCabecera = lcAtributoCabecera + "_PK"
				Endif	
				if lcAtributo == lcAtributoCabecera
					llRetorno = .T.
					exit For
				Endif
			Endfor
		Endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function BorrarPromosEnLasQueParticipaElAtributo( tcAtributo as String ) as Void
		local lcAtributo as String, lnI As Integer, lcAtributoCabecera as String
		lcAtributo = upper( alltrim( tcAtributo ) )
		for lni = 1 to This.PromoArticulosDetalle.Count
			lcAtributoCabecera = getwordnum( upper( alltrim( This.PromoArticulosDetalle.Item[ lnI ].AtributoCabecera ) ), 1, "." )
			if getwordcount( This.PromoArticulosDetalle.Item[ lnI ].AtributoCabecera, "." ) > 1
				lcAtributoCabecera = lcAtributoCabecera + "_PK"
			Endif	
			if lcAtributo == lcAtributoCabecera
				This.EliminarPromo( This.PromoArticulosDetalle.Item[ lnI ].IdItemPromo )
			Endif
		Endfor
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ValidarQueTipoDePromoSeElimina( tcIdPromo as String, txValAtributo as variant ) as Void
		local lnI As Integer, loPromocion as Object, loError as Object
		if empty( txValAtributo )
			for lni = 1 to This.PromocionesDetalle.Count
				if This.PromocionesDetalle.Item[ lnI].IdItemPromocion = tcIdPromo and !empty( This.PromocionesDetalle.Item[ lnI].Promocion_Pk )
					try
						loPromocion = this.oManagerPromociones.oPromocion.ObtenerUnaSolaPromocion( This.PromocionesDetalle.Item[ lnI].Promocion_Pk )
						if loPromocion.Count > 0 
							if loPromocion.item(0).AplicaAutomaticamente
								this.lSeEliminoUnaPromoAutomatica = .T.
							endif
							if loPromocion.item(0).Tipo = "4"
								this.lSeEliminoUnaPromoBancaria = .T.
							endif
						endif
					catch to loError
					finally
						exit
					endtry
				Endif
			endfor
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function EliminarPromo( tcIdPromo as String ) as Void
		local lnI As Integer
		for lni = 1 to This.PromocionesDetalle.Count
			if This.PromocionesDetalle.Item[ lnI].IdItemPromocion = tcIdPromo and !empty( This.PromocionesDetalle.Item[ lnI].Promocion_Pk )
				This.PromocionesDetalle.CargarItem( lnI )
				This.PromocionesDetalle.oItem.Promocion_Pk = ""
				This.PromocionesDetalle.Actualizar()
			Endif
		Endfor
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AntesDeProcesarItemPromociones( toItem as Object, tcAtributo as String, txValOld as Variant, txValActual as variant ) as Void
		local lcAtributo as String
		lcAtributo = upper( alltrim( tcAtributo ) )
		if lcAtributo == "PROMOCION_PK" and txValOld != txValActual and !empty( txValOld )
			this.ValidarQueTipoDePromoSeElimina( toItem.IdItemPromocion, txValActual )
			this.oManagerPromociones.DesafectarItemsPorPromoBancaria( toItem.IdItemPromocion, this.lSeEliminoUnaPromoBancaria )
			this.oManagerPromociones.DesafectarItems( toItem.IdItemPromocion, this )
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Setear_Fecha( txFecha ) as void
		local loDetalle as Detalle of Detalle.prg
		dodefault( txFecha )
		if !this.lLimpiando and !this.lCargando
			loDetalle = this.ObtenerDetalleDeValores()
			if type( "loDetalle" ) = "O" and !isnull( loDetalle )
				loDetalle.dFechaComprobante = txFecha
				loDetalle.oItem.FechaComp = txFecha
				if !empty( this.MonedaComprobante_pk ) && and !this.lCargando
					this.SetearCotizacion()
				endif
			endif
		endif
		
		if this.SoportaPromociones() and inlist ( goParametros.Felino.GestionDeVentas.ActualizarFechaDelComprobanteALaFechaDelDiaAlGrabar, 2,3,4);
	 		and date() != txFecha and !this.lAplicarPromosAutomaticasAlSalirDelDetalle 
				this.lAplicarPromosAutomaticasAlSalirDelDetalle = .t.	
		endif
	endfunc 
	
	*--------------------------------------------------------------------------------------------------------
	function Setear_MonedaComprobante( txVal as variant ) as void
		dodefault( txVal )		
		if type( "this." + This.cValoresDetalle ) = "O"
			loDetalle = This.cValoresDetalle
			This.&loDetalle..cMonedaComprobante = txVal
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function Setear_MonedaSistema( txValor as Variant ) as void
	
		dodefault( txValor )
		if type( "this." + This.cValoresDetalle ) = "O"
			loDetalle = This.cValoresDetalle
			This.&loDetalle..cMonedaSistema = txValor
		endif
		this.EventoSetearMonedaSistema()

	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoSetearMonedaSistema() as Void
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function SetearMonedaEnDetalleValores() as Void
		if type( "this." + This.cValoresDetalle ) = "O"
			loDetalle = This.cValoresDetalle
			This.&loDetalle..cMonedaComprobante = This.MonedaComprobante_Pk
			if pemstatus(This,"MonedaSistema_Pk",5)
				This.&loDetalle..cMonedaSistema = This.MonedaSistema_Pk
			endif
		Endif	
	endfunc

	*-----------------------------------------------------------------------------------------
	function VerificarEstadoDeCaja() as Void
		local llHabilitarCajaOld as Boolean, llDebeRestaurarHabilitarCaja as Boolean , lnCajaActiva as Integer
		lnCajaActiva = 0
		if empty(this.caja_pk)
			llDebeRestaurarHabilitarCaja = .F.
			lnCajaActiva = goCaja.ObtenerNumeroDeCajaActiva()
			if lnCajaActiva != 0
				if pemstatus( this, "lHabilitarCaja_pk", 5 )
					llHabilitarCajaOld = this.lHabilitarCaja_PK
					this.lHabilitarCaja_PK = .T.
					llDebeRestaurarHabilitarCaja = .T.
				endif
				this.Caja_pk = lnCajaActiva
				if llDebeRestaurarHabilitarCaja
					this.lHabilitarCaja_PK = llHabilitarCajaOld 
				endif
			endif
		endif
		
		if !gocaja.estaabierta(this.caja_pk)
			if goCaja.DebeRealizarAperturaAutomaticaDeCaja()
				if gocaja.oCajaEstado.Pedirseguridadabrircaja()
					gocaja.abrir( This.Caja_Pk )
					this.loguear( "Se realizó la apertura automática de la caja " + transform( This.Caja_Pk ))
				else
					loex = newobject(  "zooexception", "zooexception.prg" )
					with loex
						.message = "El usuario no tiene permitido el acceso para realizar la apertura automática de la caja " + transform( This.Caja_Pk ) + "."
						.details = .message
						.grabar()
						.throw()
					endwith
				endif	
			endif
		endif

	endfunc 

	*-----------------------------------------------------------------------------------------	
	Function Nuevo() as Void
		if this.PuedeHacerNuevo()
			this.SetearTotalComprobanteEnDetalleDeValores( 0 )
			This.LimpiarColeccionDeValoresOriginal()
			This.VerificarCodigoDeValorSugeridoParaVuelto()
			this.lTienePermisoComprobantesA = .f.
			this.lAgruparPacksAutomaticamente = .f.
			dodefault()
			this.Verificarestadodecaja()
			this.SumPercepciones = 0
			this.VueltoVirtual = 0
			this.SetearCotizacion()
			this.lYaSeLanzoAvisoDeCuponesHuerfanos = .f.
			this.oCuponesHuerfanosAplicados = null
			this.lAplicandoTaxFree = .f.
			this.SetearValidadorCombinacionesRepetidas()
			if this.lEsComprobanteConEntregaPosterior
				this.EventoActualizarComboEntregaPosterior( .t. )
				this.SetearValorSugeridoEntregaPosterior()
				this.EventoHabilitarDeshabilitarComboEntregaPosterior()
			endif
			this.SetearFechaCpteRelacionadoPorDefecto()
			this.lSeEliminoUnaPromoAutomatica = .f.
			this.lSeEliminoUnaPromoBancaria = .f.
			if pemstatus( this, "ValoresDetalle", 5 ) and pemstatus( this.ValoresDetalle, "lSoloHayValoresTarjetaOPagoElectronico", 5 )
				this.ValoresDetalle.lSoloHayValoresTarjetaOPagoElectronico = .f.
			endif
			if type("this.oColaboradorRetiroDeEfectivo") = 'O' and this.oColaboradorRetiroDeEfectivo.lHayValoresDeRetiroDeEfectivo
				this.oColaboradorRetiroDeEfectivo.lHayValoresDeRetiroDeEfectivo = .f.
			endif
			if type( "this.FacturaDetalle.oItem.oCompGiftCard" ) = "O"
				this.FacturaDetalle.oItem.oCompGiftCard.LimpiarColeccionesGiftCard()
			endif
			this.lYaSeteoStockInicial = .f.
		else
			goServicios.Errores.LevantarExcepcion( "La fecha de apertura de la caja activa es distinta a la fecha actual.  Para poder hacer un comprobante debe realizar el cierre de la caja, para ello diríjase al menú 'Fondos -> Cerrar Caja Activa'" )
		endif
	Endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ActualizarCotizacion() as Void
		this.SetearCotizacion()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function ValidarTotales() As Void
		Local llRetorno As boolean, lnTotalFactura As Float, lnTotalValores As Float, lnI as Integer
		llRetorno = dodefault()
		lnTotalValores = 0

		if type( "this." + This.cValoresDetalle ) = "O"
			loDetalle = This.cValoresDetalle
			for lnI = 1 to this.&loDetalle..count 
				if !this.&loDetalle..item(lni).esvuelto
					lnTotalValores = lnTotalValores +  this.&loDetalle..item(lni).RecibidoAlCambio 
				endif	
			endfor	

			With This
				lnTotalFactura = goLibrerias.RedondearSegunMascara( .Total )
				lnTotalValores = goLibrerias.RedondearSegunMascara( lnTotalValores )
				If lnTotalFactura > lnTotalValores and !this.lAgregueRecargoDe1Centavo
					this.agregarInformacion( "La suma de los valores no cubre el total del Comprobante." )
					llRetorno = .F.
				Endif
			Endwith
		EndIf

		this.SetearFlagRecargoPorCambio( .f. )

		Return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function AsignarTotalComprobante( tnTotal as Float) as Void
		
		dodefault( tnTotal )
		this.SetearTotalComprobanteEnDetalleDeValores( tnTotal )
		this.CalcularVuelto( this.cdetallecomprobante )&&()
	endfunc	

	*-----------------------------------------------------------------------------------------
	protected function SetearTotalComprobanteEnDetalleDeValores( tnTotal as Float ) as Void
		if type( "this." + This.cValoresDetalle ) = "O"
			loDetalle = This.cValoresDetalle
			this.&loDetalle..nTotalComprobante = goLibrerias.RedondearSegunMascara( tnTotal )
		Endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Setear_Cliente( txValor as Variant ) as void
		local loDetalle as Object

		if pemstatus( This, "oComponenteFiscal", 5 ) and inlist( alltrim( upper( this.cNombre ) ), "TICKETFACTURA", "TICKETNOTADECREDITO" )
			This.oComponenteFiscal.lTieneCliente = !empty( This.Cliente_pk )
		endif
*!*			this.lDebeCalcularVuelto = !this.EstaProcesando() && .t.
				
		if this.lCambioCliente
			this.lDebeCalcularVuelto = .t.
*			this.lTienePermisoComprobantesA = .f.
			if pemstatus( This,"email", 5 )
				this.email = ""
			endif		
		endif
		
		dodefault( txValor )
		this.lDebeCalcularVuelto = .f. 
		if type( "this." + This.cValoresDetalle ) = "O"
			loDetalle = This.cValoresDetalle
			this.&loDetalle..cCliente = txValor
			if this.lHuboCambioSituacionFiscal and this.cComprobante != "RECIBO"
				this.MontoRecargoEnPago()
			endif
		endif
		
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function CalcularVuelto( tcdetalle ) as Void
		local loDetalle as Object, lnVuelto as Integer, llaumentarmontos as Boolean, lldescontarmontos as boolean, lndiferenciaVuelto as number, lnImpuestos as integer, lnpasadas as Integer 
		llAumentarMontos = .f.
		llDescontarMontos = .f.
		lndiferenciaVuelto = 0
		if type( "this." + This.cValoresDetalle ) = "O" and type( "this." + This.cValoresDetalle + ".sum_RecibidoAlCambio") != "U" and this.lDebeCalcularVuelto and this.lRecalcularVuelto and !this.lseteandoCondicionDePago
			this.eventoLockear(.t.)	
			loDetalle = This.cValoresDetalle

			with this
				lnVuelto = this.ObtenerVueltoVirtual( .ValoresDetalle )
				if lnVuelto < .VueltoVirtual and .VueltoVirtual > 0	
					llAumentarMontos = .t.
					lnDiferenciaVuelto  = .VueltoVirtual - lnVuelto 
				endif
				
				if lnvuelto > .VueltoVirtual 
					llDescontarMontos = .t.
					lnDiferenciaVuelto  = lnvuelto - iif( .VueltoVirtual < 0, 0, .VueltoVirtual )
				endif
				
				.VueltoVirtual = goLibrerias.RedondearSegunPrecision( lnVuelto, 2 )
				
				this.AjustarMontos( lndiferenciaVuelto, tcdetalle, llAumentarMontos, llDescontarMontos )
				
			endwith
			this.eventoLockear(.f.)
		endif
		this.EventoDespuesDeCargarVuelto()
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerVueltoVirtual( todetalle as Object ) as Float		
		return goLibrerias.RedondearSegunPrecision( toDetalle.sum_RecibidoAlCambio - this.Total, 4 )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function AjustarMontos( tndiferenciaVuelto, tcdetalle, tlaumentarmontos, tldescontarmontos ) as Void
		local lndif as float, lnpasadas as integer
		if tlaumentarmontos and tndiferenciaVuelto > 0
			this.AumentarMontos( tndiferenciaVuelto, tcdetalle )
		endif
		if tldescontarmontos and tndiferenciaVuelto > 0
			this.RestarMontos( tndiferenciaVuelto, tcdetalle )
		endif
		if ( tlaumentarmontos or tldescontarmontos ) and this.AplicaPercepciones() and tndiferenciaVuelto > 0 	
			lndif = -1
			lnpasadas = 0
			do while lndif != 0 and lnpasadas < 5

				this.lDebeCalcularVuelto = .f.
 				lndif = this.total - this.valoresdetalle.sum_pesosalcambio
				do case
					case lndif > 0
						this.AumentarMontos( lndif, tcdetalle )
					case lndif < 0
						this.RestarMontos( lndif * -1 , tcdetalle )
				endcase							
				this.lDebeCalcularVuelto = .t.
				lnpasadas = lnpasadas + 1
			enddo
		endif			
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoLockear( tnLock as Boolean ) as VOID 
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function Imprimir() As Boolean
		local loObjetoImpresion as Object, llRetorno as Boolean
		llRetorno = .t.
		if this.ComprobanteFiscal
			if This.EsNuevo()
				llRetorno = This.EmitirImpresionFiscal()			
			Endif
		else 
			if type( "this.impresionsituacionfiscal" ) = "C"
				this.impresionsituacionfiscal = goLibrerias.ObtenerDescripcionSituacionFiscalParaImpresion( This.SituacionFiscal_pk )
			endif
			if type( "this.impresionporcentajeDeIVA" ) = "C"
				this.impresionporcentajeDeIVA = this.ObtenerPorcentajeDeIvaParaImpresion()
			endif
		endif
		if this.DebeImprimirDisenosAutomaticamente() or ( !this.EsEdicion() and !this.EsNuevo() )
			llRetorno = llRetorno and dodefault()
		endif
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function EmitirAnulado() as Void
		local loObjetoImpresion as Object

		loObjetoImpresion = this.CrearEntornoRepo()
		this.oComponenteFiscal.EmitirAnulado( loObjetoImpresion ) 
	endfunc 	

	*-----------------------------------------------------------------------------------------
	protected function EmitirImpresionFiscal() as Boolean
		local loObjetoImpresion as Object, llRetorno as Boolean

		loObjetoImpresion = this.CrearEntornoRepo()
		if isnull( loObjetoImpresion )
			llRetorno = .F.
			this.AgregarInformacion( "No se pudo crear el objeto de impresión" )
		else
			this.oComponenteFiscal.cItemsAImprimirEnComprobante = ;
				["Artículo" as Campo1_e ,] +;
				[Articulo + " " + ArticuloDetalle as Campo1_d ,] +;
				this.ObtenerCamposAdicionalesDetalleFacturaParaImprimirComprobante()

			llRetorno = this.oComponenteFiscal.Imprimir( loObjetoImpresion ) 
		endif
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function CrearEntornoRepo() as Object 
		local lcNumero as String, lcTipo as String, lcXmlValores as String, lcXmlDetalle as String, ;
			lcXmlComprobante as String, loObjetoImpresion as Object , loCliente as Object, lcDireccionCliente  as String, ;
			loAdicionales as Object, loVendedor as Object, loDatosTaxFree as object, lcMotivoDatosAdicionales as String, ;
			lcComprobanteOrigen as String, lcTipoComprobanteOrigen as string, lnTipoCpteAsociado as Integer, lcFechaComprobanteOrigen as string

		lcDireccionCliente = 	alltrim( this.cliente.Calle )  + ' ' + ;
				transform( evl( this.cliente.Numero, "" ) ) + ' ' + ;
				alltrim( this.cliente.Piso ) + ;
				alltrim( this.cliente.Departamento )

		if empty( lcDireccionCliente )
			lcDireccionCliente = "."
		endif

		lcMotivoDatosAdicionales = this.ObtenerMotivoDatosAdicionales()
		lcComprobanteOrigen = ""
		lcTipoComprobanteOrigen = ""
		lcFechaComprobanteOrigen = ""
		
		if goParametros.Felino.GestionDeVentas.HabilitaComprobanteAsociado and;
			pemstatus( this, "TipoCpteRelacionado", 5 ) and !empty( this.TipoCpteRelacionado ) and;
			!empty( this.NumeroCpteRelacionado ) and !empty( this.PuntoDeVentaCpteRelacionado ) and !empty ( this.FechaCpteRelacionado )
			
			lcComprobanteOrigen = alltrim(transform(padl(this.PuntoDeVentaCpteRelacionado, 5, "0"))) + alltrim(transform(padl(int(this.NumeroCpteRelacionado), 8, "0")))
			do case
				case this.TipoCpteRelacionado = 1
					lnTipoCpteAsociado = 2
				case this.TipoCpteRelacionado = 3  
					lnTipoCpteAsociado = 5
				case this.TipoCpteRelacionado = 4  
					lnTipoCpteAsociado = 6
			endcase
			lcTipoComprobanteOrigen = upper(this.oComponente.ObtenerEntidadDeComprobanteDeVentas( lnTipoCpteAsociado )) 
			if vartype( this.FechaCpteRelacionado ) = 'D'
				lcFechaComprobanteOrigen = this.FechaCpteRelacionado
			else
				lcFechaComprobanteOrigen = dtoc( this.FechaCpteRelacionado )
			endif
		endif

		loVendedor = createobject( 'empty' )
		addproperty( loVendedor,'Nombre', this.Vendedor.Nombre )
		addproperty( loVendedor,'Codigo', this.Vendedor.codigo )

		loCliente = createobject( 'empty' )
		addproperty( loCliente, 'Nombre', this.cliente.Nombre )
		addproperty( loCliente, 'Codigo',this.cliente.codigo )
		addproperty( loCliente, 'TipoDocumento', evl( this.cliente.TipoDocumento, "05" ) )
		addproperty( loCliente, 'Cuit',this.cliente.cuit )
		addproperty( loCliente, 'NroDocumento', This.FormatearNumeroDocumento( this.cliente.nrodocumento, this.cliente.TipoDocumento ) )
		addproperty( loCliente, 'ResponsabilidadCliente',this.cliente.SituacionFiscal_pk )
		addproperty( loCliente, 'SituacionFiscalMonotributo',this.oComponenteFiscal.oSfiscal.Monotributo )	
		addproperty( loCliente, 'SituacionFiscalInscripto',this.oComponenteFiscal.oSfiscal.Inscripto )	
			
		addproperty( loCliente, 'iva1', this.IvaDelSistema )
		addproperty( loCliente, 'iva2',0 )
		addproperty( loCliente, 'Direccion', lcDireccionCliente  )
		addproperty( loCliente, 'Localidad',this.cliente.localidad )
		addproperty( loCliente, 'Telefono',this.cliente.telefono )
		addproperty( loCliente, 'ResponsabilidadEmisor','' )
		addproperty( loCliente, 'ComprobanteOrigen', lcComprobanteOrigen )
		addproperty( loCliente, 'TipoComprobanteOrigen', lcTipoComprobanteOrigen )
		addproperty( loCliente, 'FechaComprobanteOrigen', lcFechaComprobanteOrigen )
		addproperty( loCliente, 'oPercepciones',null )
		addproperty( loCliente, 'RUT', this.cliente.rut )
		addproperty( loCliente, 'MotivoDA', lcMotivoDatosAdicionales )

		loObjetoImpresion = createobject( "empty" )
		addproperty( loObjetoImpresion, "cComprobante", this.cComprobante )
		addproperty( loObjetoImpresion, "oCliente", loCliente )
		addproperty( loObjetoImpresion, "oVendedor", loVendedor )
		addproperty( loObjetoImpresion, 'oDescuentos', This.ObtenerColeccionDescuentos() )
		addproperty( loObjetoImpresion, 'oDescuentosFin', This.ObtenerColeccionDescuentosFinancieros() ) && Nuevitoo
		addproperty( loObjetoImpresion, 'oRecargos', This.ObtenerColeccionRecargos() )
		addproperty( loObjetoImpresion, 'oRecargosFin', This.ObtenerColeccionRecargosFinancieros() ) && Nuevitoo
		addproperty( loObjetoImpresion, 'oColImpuestos', This.ObtenerColeccionDetalleDeImpuestos() ) && Nuevo v2
		addproperty( loObjetoImpresion, 'cLetra', This.Letra )
		addproperty( loObjetoImpresion, 'nSubTotalBruto', This.SubtotalBruto )
		addproperty( loObjetoImpresion, 'nSubTotalNeto', This.SubtotalNeto )
		addproperty( loObjetoImpresion, 'nImpuestos', This.Impuestos )
		addproperty( loObjetoImpresion, 'nTotalImpuestos', This.TotalImpuestos )
		addproperty( loObjetoImpresion, 'nTotal', This.Total )
		addproperty( loObjetoImpresion, 'nPuntoDeVenta', This.PuntoDeVenta )
		addproperty( loObjetoImpresion, 'nNumero', This.Numero )
		addproperty( loObjetoImpresion, 'cFechaComprobante', dtoc(This.Fecha) )
		addproperty( loObjetoImpresion, 'cHoraComprobante', This.horaaltafw )
		addproperty( loObjetoImpresion, 'nCaja', This.Caja_pk )
		addproperty( loObjetoImpresion, 'IvaInscriptosParametro', this.IvaDelSistema )

		addproperty( loObjetoImpresion, 'oPromociones', iif( this.SoportaPromociones(), this.ObtenerPromocionesDetalle(), null ) )
		addproperty( loObjetoImpresion, 'oPromocionesArticulosDetalle', iif( this.SoportaPromociones(), this.ObtenerPromoArticulosDetalle(), null ) )
		addproperty( loObjetoImpresion, 'oItemAuxiliarVacio', iif( this.SoportaPromociones(), this.facturadetalle.crearitemauxiliar(), null ) )

		addproperty( loObjetoImpresion, 'cObservaciones', this.Obs )
		if pemstatus( this, "Despachos", 5 )
			addproperty( loObjetoImpresion, 'cDespachosImportacion', this.Despachos )
		endif
		addproperty( loObjetoImpresion, "oArticulosAAgregarSinPrecio", null )
		if this.SoportaSenias()		
			loObjetoImpresion.oArticulosAAgregarSinPrecio = this.ArticulosSeniadosDetalle
		endif

		if type( "this.FacturaDetalle" ) = "O" 
			addproperty( loObjetoImpresion, "oDetalleArticulos", this.FacturaDetalle )
		Endif	
		if type( "this." + This.cValoresDetalle ) = "O"
			loDetalle = This.cValoresDetalle
			addproperty( loObjetoImpresion, "oDetalleValores", this.&loDetalle )
			this.AgregarNumeroDeLote()
			this.CompletarLoteCuponYTarjetaParaImprimir()
		Endif	
		
		loAdicionales = This.CrearObjetoAdicionalItems( )
		addproperty( loObjetoImpresion, "oAdicionalItems", loAdicionales )

		addproperty( loObjetoImpresion, 'SignoDelComprobante', this.SignoDeMovimiento )

		if pemstatus( this, "ChequeReintegro", 5 ) and !empty( this.chequeReintegro )
			loDatosTaxFree = _screen.zoo.CrearObjeto( "ZooColeccion" )
			loDatosTaxFree.Agregar( "Monto total IVA: $" + alltrim( str( this.Impuestos, 15, 2 ) ) )
			loDatosTaxFree.Agregar( "Monto impuestos internos: $" + alltrim( str( this.gravamenes, 15, 2 ) ) )
			loDatosTaxFree.Agregar( "Cheque reembolso: " + alltrim( this.chequeReintegro ) )
			addproperty( loObjetoImpresion, 'oDatosTaxFree', loDatosTaxFree )
		endif
		return loObjetoImpresion
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function FormatearNumeroDocumento( tcNumeroDocumento as String, tcTipoDocumento as String ) as String
		local lcNumeroDocumento

		lcNumeroDocumento = evl( tcNumeroDocumento, "0" )
		*!* Si tiene pasaporte y tengo configurada una impresora fiscal Hasar 1000/250 completo con ceros a la izquierda
		if tcTipoDocumento = "06" and lcNumeroDocumento != "0" and goparametros.felino.controladoresfiscales.codigo = 34
			lcNumeroDocumento = padl( alltrim( lcNumeroDocumento ), 10, "0" )
		endif
		return lcNumeroDocumento
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerMotivoDatosAdicionales() as String
		local lcRetorno as String, loDatosAdicionalesA  as Object, lnMotivo as Integer

		lcRetorno = ''
		lnMotivo = 0
		if this.SoportaDatosAdicionalesA()
			lnMotivo = this.ObtenerCodigoMotivoDatosAdicionales()
			if lnMotivo > 0
				lcRetorno = this.ObtenerDescripcionMotivoDatosAdicionales( lnMotivo )
			endif			
		endif
		
		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerCodigoMotivoDatosAdicionales() as Integer
		local lnRetorno as Integer, lcSentencia as String

		lcSentencia = "Select Motivo from AFIP3668 where codcomp = '" + this.codigo + "'"
		goServicios.Datos.EjecutarSentencias( lcSentencia, "AFIP3668", "", "c_CodMotivo", this.DataSessionId )
		lnRetorno = c_CodMotivo.Motivo
		use in ( "c_CodMotivo" )

		return lnRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerDescripcionMotivoDatosAdicionales( tnMotivo as Integer ) as String
		local lcRetorno as String, loEntidadMotivoDA as object

			lcRetorno = ''
			loEntidadMotivoDA =  _screen.zoo.instanciarentidad( "MotivoDatosAdicionalesComprobantesA" )
			try
				with loEntidadMotivoDA
					.Codigo = tnMotivo 
					.Buscar()
					lcRetorno = alltrim( iif( empty( .DescripcionCorta ), .Descripcion, .DescripcionCorta ) )
				endwith
			catch
			endtry
			loEntidadMotivoDA.release()

		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AgregarNumeroDeLote() as Void
		local lcDetalle as String, loItem as Object
		
		if pemstatus( this, "ValoresDetalle", 5 ) 
			for each loItem in this.ValoresDetalle foxobject
				addproperty( loItem, "NumeroLoteCupon", 0 )
			endfor
		endif
		
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function CompletarLoteCuponYTarjetaParaImprimir() as Void
		local loItem as object

		if pemstatus( this, "ValoresDetalle", 5 ) 
			for each loItem in this.ValoresDetalle foxobject
				if inlist( loItem.tipo, TIPOVALORTARJETA, TIPOVALORPAGOELECTRONICO ) and !empty( loItem.cupon_pk )
					loCupon = _Screen.Zoo.InstanciarEntidad( "Cupon" )
					try 
						loCupon.codigo = loitem.cupon_pk
						loItem.NumeroCupon = iif ( empty ( loItem.NumeroCupon ), loCupon.numerocupon, loItem.NumeroCupon )
						loItem.NumeroLoteCupon = iif ( empty ( loItem.NumeroLoteCupon ), loCupon.lote, loItem.NumeroLoteCupon )
						loItem.NumeroTarjeta = iif ( empty ( loItem.NumeroTarjeta ), loCupon.UltimosDigitos, loItem.NumeroTarjeta )						
					catch to loError
						throw loError
					endtry	
					loCupon.Release()
				endif
			endfor
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerPromocionesDetalle() as zoocoleccion OF zoocoleccion.prg
		local loPromoDetalle as zoocoleccion OF zoocoleccion.prg
		loPromoDetalle = _screen.zoo.crearobjeto( "ZooColeccion" )

		for each PromoDeta in this.PromocionesDetalle
			if !empty( PromoDeta.iditempromocion )
				loPromoDetalle.Agregar( PromoDeta )
			endif
		endfor

		return loPromoDetalle
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerPromoArticulosDetalle() as zoocoleccion OF zoocoleccion.prg
		local loPromoArticuloDetalle as zoocoleccion OF zoocoleccion.prg, loPromoArticuloDetalleOrd as zoocoleccion OF zoocoleccion.prg
		loPromoArticuloDetalle = _screen.zoo.crearobjeto( "ZooColeccion" )
		loPromoArticuloDetalleOrd = _screen.zoo.crearobjeto( "ZooColeccion" )

		for each PromoArtDeta in this.PromoArticulosDetalle
			if !empty( PromoArtDeta.iditemarticulo )
				loPromoArticuloDetalle.Agregar( PromoArtDeta )
			endif
		endfor

		if loPromoArticuloDetalle.Count > 0
			loPromoArticuloDetalleOrd = this.OrdenaColeccionPromoArticulo( loPromoArticuloDetalle )
		endif

		return loPromoArticuloDetalleOrd
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function OrdenaColeccionPromoArticulo( toPromoArticuloDetalle as object ) as zoocoleccion OF zoocoleccion.prg
		* Las promociones deben visualizarse primero los items normales (los que no se afectan x la promo) y despues los afectados (de menor importe o sin importe).
		* Por último se debe imprimir la descripción de la promo (a modo de separador)

		local loPromoDetalle as zoocoleccion OF zoocoleccion.prg, loColNegativo as zoocoleccion OF zoocoleccion.prg, loColPositivo as zoocoleccion OF zoocoleccion.prg
		local lcIdPromo as String, lcIdArticulo as String

		loPromoDetalle = _screen.zoo.crearobjeto( "ZooColeccion" )
		loColNegativo  = _screen.zoo.crearobjeto( "ZooColeccion" )
		loColPositivo  = _screen.zoo.crearobjeto( "ZooColeccion" )

		for each PromoDeta in this.PromocionesDetalle
			lcIdPromo = alltrim( PromoDeta.iditempromocion )

			if !empty( lcIdPromo )
				for each PromoArticuloDetalle in toPromoArticuloDetalle
					if PromoArticuloDetalle.iditempromo == lcIdPromo
						lcIdArticulo = alltrim( PromoArticuloDetalle.iditemarticulo )
						
						if !empty( lcIdArticulo )
							for each itemFactura in this.FacturaDetalle
								if itemFactura.iditemarticulos == lcIdArticulo
									if itemFactura.descuento > 0
										loColNegativo.Agregar( PromoArticuloDetalle )
									else
										loColPositivo.Agregar( PromoArticuloDetalle  )
									endif
								endif
							endfor
						endif
					endif
				endfor
			else
				loop
			endif
		endfor

		*----- Primero los positivos y despues se agregan lo negativos.
		for each itemPromoOrdenado in loColPositivo
			loPromoDetalle.Agregar( itemPromoOrdenado )
		endfor

		for each itemPromoOrdenado in loColNegativo
			loPromoDetalle.Agregar( itemPromoOrdenado )
		endfor

		return loPromoDetalle
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerColeccionDescuentos() as zoocoleccion OF zoocoleccion.prg
		local loDescuentos as zoocoleccion OF zoocoleccion.prg, lnTotalDescuentosConImp as float, lnTotalDescuentosSinnImp as float
		loDescuentos = _screen.zoo.crearobjeto( "ZooColeccion" )
		with loDescuentos
			if pemstatus( This, "TotalDescuentosConImpuestos", 5 ) and pemstatus( This, "nTotalDescuentosFinancierosConImpuestos", 5 )
				lnTotalDescuentosConImp = This.TotalDescuentosConImpuestos - This.nTotalDescuentosFinancierosConImpuestos
				.Agregar( lnTotalDescuentosConImp )
			endif
			if pemstatus( This, "TotalDescuentosSinImpuestos", 5 ) and pemstatus( This, "nTotalDescuentosFinancierosSinImpuestos", 5 )
				lnTotalDescuentosSinImp = This.TotalDescuentosSinImpuestos - This.nTotalDescuentosFinancierosSinImpuestos
				.Agregar( lnTotalDescuentosSinImp )
			endif
		endwith						
		return loDescuentos
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerColeccionDescuentosFinancieros() as zoocoleccion OF zoocoleccion.prg
		local loDescuentos as zoocoleccion OF zoocoleccion.prg
		loDescuentos = _screen.zoo.crearobjeto( "ZooColeccion" )
		with loDescuentos
			if pemstatus( This, "nTotalDescuentosFinancierosConImpuestos", 5 )
				.Agregar( This.nTotalDescuentosFinancierosConImpuestos )
			endif
			if pemstatus( This, "nTotalDescuentosFinancierosSinImpuestos", 5 )
				.Agregar( This.nTotalDescuentosFinancierosSinImpuestos )
			endif
		endwith						
		return loDescuentos
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerColeccionRecargos() as Number
		local loRecargos as zoocoleccion OF zoocoleccion.prg, lnTotalRecargosConImp as float, lnTotalRecargosSinImp as float

		loRecargos = _screen.zoo.crearobjeto( "ZooColeccion" )
		with loRecargos
			if pemstatus( This, "TotalRecargosConImpuestos", 5 ) and pemstatus( This, "nTotalRecargosFinancierosConImpuestos", 5 )
				lnTotalRecargosConImp = This.TotalRecargosConImpuestos - This.nTotalRecargosFinancierosConImpuestos
				.Agregar( lnTotalRecargosConImp )
			Endif
			
			if pemstatus( This, "TotalRecargosSinImpuestos", 5 ) and pemstatus( This, "nTotalRecargosFinancierosSinImpuestos", 5 )
				lnTotalRecargosSinImp = This.TotalRecargosSinImpuestos - This.nTotalRecargosFinancierosSinImpuestos
				.Agregar( lnTotalRecargosSinImp )
			endif
		endwith
		return loRecargos
	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerColeccionRecargosFinancieros() as Number
		local loRecargos as zoocoleccion OF zoocoleccion.prg
		loRecargos = _screen.zoo.crearobjeto( "ZooColeccion" )
		with loRecargos
			if pemstatus( This, "nTotalRecargosFinancierosConImpuestos", 5 )
				.Agregar( This.nTotalRecargosFinancierosConImpuestos )
			Endif
			
			if pemstatus( This, "nTotalRecargosFinancierosSinImpuestos", 5 )
				.Agregar( This.nTotalRecargosFinancierosSinImpuestos )
			endif

		endwith
		return loRecargos
	endfunc 	

	*-----------------------------------------------------------------------------------------
	function ObtenerCamposDetalleFactura() as String
		local lcCamposDetalle as String 
			
		if this.letra="B"
			lcCamposDetalle = "codigo, Articulo, ArticuloDetalle ,Color, ColorDetalle, Talle, Descuento, Cantidad, PrecioConImpuestos, Monto"
		else
			lcCamposDetalle = "codigo, Articulo, ArticuloDetalle ,Color, ColorDetalle, Talle, Descuento, Cantidad, PrecioSinImpuestos, Monto"
		endif
		
		return lcCamposDetalle 
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerCamposAdicionalesDetalleFacturaParaImprimirComprobante() as String
		local lcCamposDetalle as String 
		 lcCamposDetalle = ["Color" as Campo2_e ,] +;
							[Color + " " + ColorDetalle as Campo2_d ,] +;
							["Talle" as Campo3_e ,] +;
							[Talle as Campo3_d,]  
		
		return lcCamposDetalle 
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function CambiosDetalleValoresdetalle() as void
		dodefault()
		if this.lGrabandoRecibo
		else
			this.CalcularVuelto( this.cvaloresdetalle )&&()
		endif
	endfunc	

	*-----------------------------------------------------------------------------------------
	function CrearObjetoAdicionalItems() as zoocoleccion OF zoocoleccion.prg
		local loAdicional as Collection, lcLinea as String, i as Integer
		loAdicional = _Screen.zoo.Crearobjeto( "zoocoleccion" )
		if pemstatus( this, "ChequeReintegro", 5 ) and !empty( this.chequeReintegro )
			loAdicional.Add( "'Bienes gravados'")		
			loAdicional.Add( "'Producidos en el país'")
		else
			if goParametros.Felino.ControladoresFiscales.ImprimirArticuloColorYTalleEnUnaUnicaLineaHasarP320f
			else
				if	empty( goParametros.Felino.ControladoresFiscales.DatosArticulo.Leyenda1 ) .or. ;
					empty( goParametros.Felino.ControladoresFiscales.DatosArticulo.Atributo1 )
				Else	
					lcLinea =	"'" + alltrim( goParametros.Felino.ControladoresFiscales.DatosArticulo.Leyenda1 ) + ' ' + "' + alltrim( ." + ;
								alltrim( goParametros.Felino.ControladoresFiscales.DatosArticulo.Atributo1 ) + " )"
					loAdicional.Add( lcLinea )
				endif
				if	empty( goParametros.Felino.ControladoresFiscales.DatosArticulo.Leyenda2 ) .or. ;
					empty( goParametros.Felino.ControladoresFiscales.DatosArticulo.Atributo2 )
				Else	
					lcLinea =	"'" + alltrim( goParametros.Felino.ControladoresFiscales.DatosArticulo.Leyenda2 ) + ' ' + "' + alltrim( ." + ;
								alltrim( goParametros.Felino.ControladoresFiscales.DatosArticulo.Atributo2 ) + " )"
					loAdicional.Add( lcLinea )
				endif
				if	empty( goParametros.Felino.ControladoresFiscales.DatosArticulo.Leyenda3 ) .or. ;
					empty( goParametros.Felino.ControladoresFiscales.DatosArticulo.Atributo3 )
				Else	
					lcLinea =	"'" + alltrim( goParametros.Felino.ControladoresFiscales.DatosArticulo.Leyenda3 ) + ' ' + "' + alltrim( ." + ;
								alltrim( goParametros.Felino.ControladoresFiscales.DatosArticulo.Atributo3 ) + " )"
					loAdicional.Add( lcLinea )
				endif
			endif
		endif
		return loAdicional
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function InicializarComponentes( tlLimpiar as Boolean ) as Void
		dodefault( tlLimpiar )
		if tlLimpiar 
			This.nVueltoAnterior = 0
			This.cCodigoVueltoAnterior = ""
			this.nVueltoAnteriorCotizado  = 0
			This.nSignoDeMovimientoAnterior = 0
			This.cClienteAnterior = ""
			this.nVueltoCotizado = 0
		else
			This.nVueltoAnterior = This.VueltoVirtual 
			This.cCodigoVueltoAnterior = This.ObtenerVueltoAnterior()
			this.CotizarVuelto()
			this.nVueltoAnteriorCotizado = This.nVueltoCotizado
			This.nSignoDeMovimientoAnterior = This.SignoDeMovimiento
			This.cClienteAnterior = This.Cliente_Pk			
		Endif
		loDetalle = this.ObtenerDetalleDeValores()
		if type( "loDetalle" ) = "O" and !isnull( loDetalle )
			loDetalle.oItem.oCompCajero.InicializarComponentes( tlLimpiar )
		endif

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoPreguntarEliminarTicketExistente( tcComprobante as String ) as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoPreguntarQueHacerConCambio( tnSugerido as number, lcTexto as String ) as Void
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EventoPreguntarImprimirTicketFaltantes() as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoMostrarMensajeAdvertirBasico( tcMensaje as String ) as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoDespuesDeCargarVuelto() as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Modificar() as Void
	local lcCertificadoSire as String
	
		This.LimpiarColeccionDeValoresOriginal()

		this.nTotalAnterior = this.Total
	
		if this.TieneSeteadaEntregaOnline()
			goServicios.Errores.LevantarExcepcion("No se puede modificar un comprobante con Venta continua.")
		endif

		if this.DebeObtenerCertificadoSIRE()
			lcCertificadoSire = this.oColaboradorSireWS.ObtenerCertificadoSireParaModificacion( this.codigo )
			if !empty( lcCertificadoSire ) and pemstatus( this, "oSireAModificar", 5  ) 
				this.oSireAModificar = this.oColaboradorSireWS.ObtenerDatosParaAnularSire( this, lcCertificadoSire  )
			endif	
		endif
		
		if type( "this.FacturaDetalle" ) = "O" and pemstatus( this.FacturaDetalle.oItem, "oCompGiftCard", 5 ) and type( "this.FacturaDetalle.oItem.oCompGiftCard" ) = "O"
			this.FacturaDetalle.oItem.oCompGiftCard.LimpiarColeccionesGiftCard()
			if this.FacturaDetalle.oItem.oCompGiftCard.VerificarSiElComprobanteTieneGiftCardAsociado( "Modificar" )
				goServicios.Errores.LevantarExcepcion("No se puede modificar un comprobante con un GiftCard asociado.")
			endif
		endif
		
		dodefault()
		
		this.GuardarColeccionDeValoresOriginal()
		if pemstatus( this, "ValoresDetalle", 5 ) 
			this.ValoresDetalle.InicializarAtributosAuxiliares()
			this.CargarValoresAplicablesParaVuelto()
		endif
		if pemstatus( this, "ChequeReintegro", 5 )
			this.lAplicandoTaxFree = !empty( this.chequeReintegro )
		endif
		if pemstatus( this, "IvaDelSistema", 5 )
			this.IvaDelSistema = goParametros.Felino.DatosImpositivos.IvaInscriptos
		endif
		this.SetearValidadorCombinacionesRepetidas()
		
		if this.SoportaPromociones()
	 		this.EvaluarSiAplicaPromocionesAutomaticas( this.Fecha )
	 		if this.lAplicaPromocionesAutomaticas
	 			this.oManagerPromociones.oManagerAutomatico.lAplicaPromocionesAutomaticas = .F.
	 			this.ActivarVerificacionDeCambiosEnItems()
	 	endif
	 		this.lSeEliminoUnaPromoAutomatica = .f.
	 		this.lSeEliminoUnaPromoBancaria = .f.
	 	endif
 		
		this.EventoHabilitarDeshabilitarComboEntregaPosterior()
		if this.lEsComprobanteConEntregaPosterior
			this.SetearentregaPosteriorParaFacturasAnteriores()
			if this.lAnuladoAntesDeModificar
				this.SetearValorSugeridoEntregaPosterior()
			endif
		endif
		
		this.SetearFechaEnDetalleDeValores()
		this.lAjustePorResiduoCentavo = .t.
		if pemstatus( this, "ValoresDetalle", 5 ) and pemstatus( this.ValoresDetalle, "EvaluarTiposDeValoresEnDetalle", 5 )
			this.ValoresDetalle.EvaluarTiposDeValoresEnDetalle()
		endif
		
		if pemstatus( this, "ValoresDetalle", 5 ) and type("this.oColaboradorRetiroDeEfectivo") = 'O'
			this.oColaboradorRetiroDeEfectivo.ValidarSiExistenValoresDeRetiroDeEfectivo()
		endif

		this.lYaSeteoStockInicial = .f.
	endfunc
	 
	*-----------------------------------------------------------------------------------------
	function Anular() as Void
		local llValidaOk as Boolean
		llValidaOk = .F.
		
		This.LimpiarColeccionDeValoresOriginal()
		this.lTieneEntregaPosterior = this.TieneSeteadaEntregaPosterior()
		if this.lTieneEntregaPosterior
			this.SetearSignoPorEntregaPosterior()
		else
			this.SetearSignoPorEntregaPosteriorDefault()
		endif

		this.lDebeObtenerCertificadoSIRE = this.DebeObtenerCertificadoSIRE()
		if this.lDebeObtenerCertificadoSIRE 
			local loSire as Object
			loSire = this.oColaboradorSireWS.ObtenerDatosParaAnularSire( this )	
		endif
		
		if vartype( this.oColaboradorAjusteChequeRechazado ) = "O"
			llValidaOk = this.oColaboradorAjusteChequeRechazado.ValidarSiFueGeneradoPorComprobanteDeCaja( this )
		endif
		
		this.lConfirmaAnulacion = .F.
		
		dodefault()
		
		if llValidaOk and this.lConfirmaAnulacion 
			this.oColaboradorAjusteChequeRechazado.LoguearAdvertenciaAlAnularEliminar( this, "Anular" )
		endif

		if this.lDebeObtenerCertificadoSIRE and ( vartype( loSire ) == "O" and !isnull( loSire) )
			this.oColaboradorSireWS.AnularCertificadoSIREWS( loSire ) 
			loSire = null
		endif

		if this.SoportaDatosDGIUruguay()
			this.oColaboradorDatosUruguay.EliminarDatosDGI( this.codigo )
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function DespuesDeAnular() as Void
		dodefault()
		this.lConfirmaAnulacion = this.lAnular
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoMensajeAdvertenciaPorAnulacionDeComprobante( lcNroComprobante as String ) as Void
		*** EVENTO BINDEADO AL KONTROLER	
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function LimpiarColeccionDeValoresOriginal() as VOID

 		this.oColeccionOriginalValores = null
		this.oColeccionOriginalValores = _Screen.Zoo.CrearObjeto( "ZooColeccion" )
		this.oColAjustesDeCupon = null

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarVueltoEnCaja() as boolean 
		local llRetorno as Boolean, lcValorVuelto as String	
		
		llRetorno = .T.
		
		if this.VueltoVirtual != 0
			lcValorVuelto = this.ObtenerCodigoValorVuelto()
			if alltrim( lcValorVuelto ) == ""
				if empty( goparametros.felino.sugerencias.codigodevalorsugeridoparavuelto )
					this.AgregarInformacion( "No está configurado en parámetros el código de valor sugerido para vuelto.", 1 )
				else
					this.AgregarInformacion( "El parámetro 'Código de valor sugerido para vuelto' configurado en 'Gestión de ventas' es incorrecto.", 1 )
				endif
				llRetorno = .F.
			else
				if this.ValidarSaldo() and goParametros.Felino.GestionDeVentas.ControlDeSaldosNegativosDeCaja = 2
					llRetorno = goCaja.ValidarVuelto( lcValorVuelto, This, this.nVueltoCotizado, this.SignoDeMovimiento, .f. )
					if !llRetorno 
		 				this.CargarInformacion( goCaja.oCajaSaldos.ObtenerInformacion() )
		 				this.agregarInformacion( goCaja.oCajaSaldos.cMensajeSaldoNegativo )
					endif
				endif
			endif
		endif
		
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ValidarSaldo() as Boolean
		return .t.
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarAntesDeAnular() as boolean
		local llRetorno as Boolean
		llRetorno = dodefault() and goCaja.ValidarAnulacion( this )
		if this.TieneSeteadaEntregaOnline()
			this.agregarinformacion("No se puede anular un comprobante con Venta continua.")
			llRetorno = .f.
		endif

		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GuardarColeccionDeValoresOriginal() as Void
		local loDetalle as Object, loSaldoValores as Object, loItem as Object, loItemNuevo as Object, loDetalle as Collection
		loDetalle = this.ObtenerDetalleDeValores()
		this.oColeccionOriginalValores = null
		this.oColeccionOriginalValores = _Screen.Zoo.CrearObjeto( "ZooColeccion" )
		for each loItem in loDetalle
			if this.oColeccionOriginalValores.getKey( loItem.Valor_PK ) <= 0 
				loItemNuevo = newObject( "Custom" )
				with loItemNuevo
					.AddProperty( "Valor", loItem.valor_PK )
					.AddProperty( "Valor_PK", loItem.valor_PK )
					.AddProperty( "Caja_Pk", loItem.Caja_Pk )
					.AddProperty( "Monto", loItem.Monto )
				endwith 
				this.oColeccionOriginalValores.Add( loItemNuevo, loItemNuevo.valor )
			else 
				this.oColeccionOriginalValores.Item( loItem.Valor_PK ).Monto = this.oColeccionOriginalValores.Item( loItem.Valor_PK ).Monto + ( loItem.Monto * this.SignoDeMovimiento * (-1) )
			endif 
		endfor
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Limpiar( tlForzar as Boolean ) as Void
		dodefault( tlForzar )
		This.nVueltoCotizado = 0

		if isnull( this.oColeccionOriginalValores )
			this.oColeccionOriginalValores = _Screen.Zoo.CrearObjeto( "ZooColeccion" )
		else
			this.oColeccionOriginalValores.Quitar(-1)
		endif
	 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function LimpiarFlag() as Void
		dodefault()

		This.nTotalRecargosFinancierosSinImpuestos = 0
		This.nTotalDescuentosFinancierosSinImpuestos = 0
		This.nTotalRecargosFinancierosConImpuestos = 0
		This.nTotalDescuentosFinancierosConImpuestos = 0

		This.lNoSePersonalizoComprobante = .t.
		This.lPermiteAgregarArticulos = .t.
		this.lRecalcularVuelto = .t.
		if type( "This.FacturaDetalle" ) = "O"
			this.FacturaDetalle.oItem.lPermiteAgregarArticulos = .t.
		endif
		if pemstatus( this, "AccionCancelatoria", 5 )
			if !this.lHaciendoNuevaAccionCancelatoria	
				this.ACcionCancelatoria = .f.
			endif		
			if pemstatus( this, "IvaDelSistema", 5 ) and !this.ACcionCancelatoria
				this.IvaDelSistema = goParametros.Felino.DatosImpositivos.IvaInscriptos
				this.SetearAccionCancelatoria( .f. )
				this.SetearIvaDelSistema( this.IvaDelSistema )
			endif
		else
			if pemstatus( this, "IvaDelSistema", 5 )
				this.IvaDelSistema = goParametros.Felino.DatosImpositivos.IvaInscriptos
			endif
		endif
		
		this.lEstaCargandoValoresAplicablesParaVuelto = .F.
		this.lYaPreguntoAgrupamientoDePacks = .f.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerPorcentajeDeIvaParaImpresion() as String 
		return transform( this.IvaDelSistema, "@N 99.99" )	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CotizarVuelto() as Void
		local lcMonedaVuelto as String 	
		this.nVueltoCotizado = 0
		
		if this.VueltoVirtual > 0
			with this.oEntidadValor
				try
					.Codigo = This.ObtenerCodigoValorVuelto()
				catch
					goServicios.Errores.LevantarExcepcion( "El código de valor sugerido para vuelto no esta asignado o no existe." )
				finally
					lcMonedaVuelto = iif( empty( .SimboloMonetario_PK ), goParametros.Felino.Generales.MonedaSistema, .SimboloMonetario_PK )
				endtry
			endwith 
			if type ('this.ValoresDetalle.oMoneda' ) = 'O'	
				this.nVueltoCotizado = this.ValoresDetalle.oMoneda.ConvertirImporte( this.VueltoVirtual, this.MonedaComprobante_pk, lcMonedaVuelto,  this.Fecha )
			endif 	
		endif 
				
		return
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AntesDeGrabar() As Boolean
		local llAntesDeGrabar as Boolean, lcDetalle as Object, loCuponesHuerfanosAplicados as Object, loError as Object, loDetalle as Detalle of Detalle.prg
		this.ActualizarFechaComprobanteAFechaDelDia()	
 		if this.lTieneFuncionalidadesEnBaseA
			This.SetearAtributoGrabandoEntidadDelComponenteEnBaseA( .T. )
		endif
		try
			llAntesDeGrabar = dodefault()
			if llAntesDeGrabar
				if this.lDisplayVFD
					this.oColaboradorDisplayVFD.MostrarVuelto( this.VueltoVirtual )
				endif
				if llAntesDeGrabar and this.SoportaPromociones() and !this.lSeEliminoUnaPromoAutomatica
					llAntesDeGrabar = this.ProcesarPromocionesAutomaticas()
				endif

				loDetalle = this.ObtenerDetalleDeValores()
				if type( "loDetalle" ) = "O" and !isnull( loDetalle )
					llAntesDeGrabar = llAntesDeGrabar and loDetalle.oItem.oCompCajero.AntesDeGrabarEntidadPadre() && this.&lcDetalle.
					if This.Total > 0  				
						llAntesDeGrabar = llAntesDeGrabar and this.AutocompletarDetalleDeValores()
					endif
					if this.lComprobanteConVuelto
						this.CotizarVuelto()
					endif

					this.AgregarCuponesIntegradosAColeccionDeHuerfanos()
					if this.HayCuponesHuerfanosAplicados()
						this.oEntidadCuponesHuerfanos.InyectarEntidad( this )
						if this.oEntidadCuponesHuerfanos.ValidarQueNoSeHayanAplicadoLosCuponesHuerfanos( this.oCuponesHuerfanosAplicados )					
						else 
							this.EliminarLosCuponesAplicadosEnOtroComprobante()
							llAntesDeGrabar = .f.
						endif 
					endif 					
					if this.lComprobanteConVuelto
						this.lDebeCalcularVuelto = .f.
						llAntesDeGrabar = llAntesDeGrabar and this.GenerarItemDeVueltoEnDetalleDeValores()
						this.lDebeCalcularVuelto = .t.
					endif

					if this.lAplicandoTaxFree 
						llAntesDeGrabar = llAntesDeGrabar and this.PuedeAplicarTaxfree()
					endif
				endif
				
				if this.SoportaSenias()
				    llAntesdeGrabar = llAntesDeGrabar and this.ValidarPorcentajeDeSeniaMinima()
					llAntesDeGrabar = llAntesDeGrabar and this.oCompSenias.AntesDeGrabarEntidadPadre()
				endif
				if this.SoportaPromociones() and this.EsNuevo() and this.TieneValoresParaPromocionesBancarias() and !this.lSeEliminoUnaPromoBancaria
					llAntesDeGrabar = llAntesDeGrabar and this.ProcesarPromocionesBancarias()
				endif
				
				if goParametros.Felino.GestionDeVentas.NoPermitirFacturarConFechaDistintaALaDeLaCajaAbierta
					llAntesDeGrabar = llAntesDeGrabar and this.VerificarFechaDeCajas( .t. )
				endif
				
				if this.SoportaPromociones() or this.SoportaKits()
					llAntesDeGrabar = llAntesDeGrabar and this.ValidarArticulosComercializablesSoloEnPromosYKits()
				endif
				
				if pemstatus( this, "LetraCpteRelacionado", 5 ) and goParametros.Felino.GestionDeVentas.HabilitaComprobanteAsociado
					llAntesDeGrabar = llAntesDeGrabar and this.ValidarAtributosCpteAsociado()
						this.LetraCpteRelacionado = this.Letra
				endif
				
				llAntesDeGrabar = llAntesDeGrabar and !this.ValidarSiHayDevlucionesEnFacturaConEntregaPosterior()
				llAntesdeGrabar = llAntesdeGrabar and this.ValidarAlivioDeCaja()
				
			endif
			
			this.lAjusteDiferenciaValoresTotal  = .f.
			this.lTieneEntregaPosterior = this.TieneSeteadaEntregaPosterior()

			this.lTieneEntregaOnLine = this.TieneSeteadaEntregaOnLine()
			if this.lTieneEntregaOnLine .or. (this.lTieneEntregaPosterior and !this.lIncorporarControlDeStockEnFacturasConEntregaPosterior)
				this.SetearControlDeStock(.f.)
			endif

		catch to loError
			goServicios.Errores.LevantarExcepcion( loError )
			llAntesDeGrabar = .f.
			this.lTieneEntregaPosterior = .f.
			this.lTieneEntregaOnLine = .f.
			this.SetearSignoPorEntregaPosteriorDefault()
		finally
			This.SetearAtributoGrabandoEntidadDelComponenteEnBaseA( .F. )
			if !llAntesDeGrabar
				this.QuitarItemVuelto()
			endif
		endtry
		
		return llAntesDeGrabar
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ActualizarFechaComprobanteAFechaDelDia() as Void
		local llActualizar as Boolean
		
		llActualizar = goParametros.Felino.GestionDeVentas.ActualizarFechaDelComprobanteALaFechaDelDiaAlGrabar
		if this.CorrespondeActualizarFecha( llActualizar )
			this.ActualizarFechaALaDelDia( llActualizar )	
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CorrespondeActualizarFecha( tlActualizar as Boolean ) as Boolean
		local llRetorno as Boolean

		llRetorno = .f.
		if tlActualizar > 1 and this.fecha != date() and inlist( this.TipoComprobante, 1, 27, 54 ) and ;
				this.CargaManual() and this.EsNuevo()
			llRetorno = .t.
		endif
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ActualizarFechaALaDelDia( tlActualizar as Boolean ) as Void
	
		this.lActualizarFecha = .f.
		if tlActualizar = 2
			this.lActualizarFecha = .t.
		else
			this.EventoPreguntarActualizarFecha( tlActualizar )
		endif
		if this.lActualizarFecha 
			this.fecha = date()
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoPreguntarActualizarFecha( tlActualizar as Boolean ) as Void
		**  para que se bindee el kontroler
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function ContieneItemsNegativos() as Boolean
		Local llRetorno as Boolean, loItem as Object 
		llRetorno = .f.
		For Each loItem in this.FacturaDetalle
			if loItem.cantidad < 0
				llRetorno = .t.
				exit
			endif 
		Endfor
		
		Return llRetorno
	Endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarSiHayDevlucionesEnFacturaConEntregaPosterior() as Boolean
		local llRetorno as Boolean 
		llRetorno = this.TieneSeteadaEntregaPosterior() and this.ContieneItemsNegativos()
		if llRetorno
			This.AgregarInformacion( "No puede realizar devoluciones con Entrega posterior." )
		endif
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ProcesarPromocionesBancarias() as Boolean
		local lcAtributo as String, loError as Object
		try
			this.oManagerPromociones.ValidarYAplicarPromocionesBancarias( this )
		catch to loError
			goServicios.Errores.LevantarExcepcion( loError )
		endtry

		return .t.
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AutocompletarDetalleDeValores() as Void	
		local llGuardandoFlag as Boolean
		llGuardandoFlag = this.lgrabandorecibo
		this.lgrabandorecibo = .f.
		this.oColaboradorCierreComprobantes.AutocompletarDetalleDeValores( this )
		this.lgrabandorecibo = llGuardandoFlag 	
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function CalcularSubTotal( tlMuestraImpuestos as Boolean ) as Void
		dodefault( tlMuestraImpuestos )
		this.SumItemsDetalleSinImpuestos = this.FacturaDetalle.Sum_Neto
		this.SumItemsDetalleConImpuestos = this.FacturaDetalle.Sum_Monto

		this.SumItemsDetalleSinImpuestos = this.FacturaDetalle.Sum_Neto - this.Descuento
		this.SumItemsDetalleConImpuestos = this.FacturaDetalle.Sum_Monto - this.Descuento

		this.SumItemsDetalleSinImpuestos = this.SumItemsDetalleSinImpuestos - this.MontoDescuentoSinImpuestos1
		this.SumItemsDetalleConImpuestos = this.SumItemsDetalleConImpuestos - this.MontoDescuentoConImpuestos1
		
		this.SumItemsDetalleSinImpuestos = this.SumItemsDetalleSinImpuestos - this.MontoDescuentoSinImpuestos2
		this.SumItemsDetalleConImpuestos = this.SumItemsDetalleConImpuestos - this.MontoDescuentoConImpuestos2

		this.SumItemsDetalleSinImpuestos = this.SumItemsDetalleSinImpuestos - this.MontoDescuentoSinImpuestos3
		this.SumItemsDetalleConImpuestos = this.SumItemsDetalleConImpuestos - this.MontoDescuentoConImpuestos3
		
		this.SumItemsDetalleSinImpuestos = this.SumItemsDetalleSinImpuestos + this.RecargoMontoSinImpuestos
		this.SumItemsDetalleConImpuestos = this.SumItemsDetalleConImpuestos + this.RecargoMontoConImpuestos
		this.SumItemsDetalleSinImpuestos = this.SumItemsDetalleSinImpuestos + this.RecargoMontoSinImpuestos1
		this.SumItemsDetalleConImpuestos = this.SumItemsDetalleConImpuestos + this.RecargoMontoConImpuestos1
		this.SumItemsDetalleSinImpuestos = this.SumItemsDetalleSinImpuestos + this.RecargoMontoSinImpuestos2
		this.SumItemsDetalleConImpuestos = this.SumItemsDetalleConImpuestos + this.RecargoMontoConImpuestos2
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarVueltoSegunTipoValor() as boolean
	local loItem as Object, lnMontoAcumulado as Long, llRetorno as boolean
	
		lnMontoAcumulado = 0 
		lnMontoTotal = 0 
		llRetorno = .f.
		if pemstatus( this, "ValoresDetalle", 5 ) 
			for each loItem in this.ValoresDetalle foxobject
				if !empty( loItem.valor_pk) and !loItem.PermiteVuelto
					lnMontoAcumulado = goLibrerias.RedondearSegunPrecision( lnMontoAcumulado + loItem.RecibidoAlCambio )
				endif
				lnMontoTotal = goLibrerias.RedondearSegunPrecision( lnMontoTotal + loItem.RecibidoAlCambio )
			endfor
		endif 
		
		if ( golibrerias.redondearSegunMascara( lnMontoAcumulado ) > golibrerias.redondearSegunMascara( this.Total ) ) ; 
				and ( golibrerias.redondearSegunMascara( lnMontoTotal ) > golibrerias.redondearSegunMascara( this.Total ) )
			this.agregarInformacion( "Solo es posible dar vuelto si se utilizan valores que lo permiten")
		else
			llRetorno = .t.	
		endif
					
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function MontoRecargoEnPago()
		local loDetalle as String

		this.lEstoyEnMontoRecargoEnPago = .t.

		if type( "this." + This.cValoresDetalle ) = "O"	and type( "This.oComponenteFiscal" ) = "O"
			loDetalle = This.cValoresDetalle
			if This.oComponenteFiscal.MostrarImpuestos()
				this.RecargoMonto1 = This.&loDetalle..Sum_RecargoMonto
			else
				this.RecargoMonto1 = This.&loDetalle..Sum_RecargoMontoSinImpuestos
			endif
		endif

		this.lEstoyEnMontoRecargoEnPago = .F.

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function CalculosPreRecargos()
		local loColeccion as zoocoleccion OF zoocoleccion.prg, lni as Integer, ;
			lcKey as String, loArticulo as Object, lnPorcentajeSumarizadoIIBB AS Long,;
			loItem as Object, loItemDetalleMontoGrabado  as Object,;
			lnPorcentajeDeIva as integer, lnMontoGravadoAlPorcentajeXConIVA as integer,;
			lnMontoGravadoAlPorcentajeXSinNingunImpuesto as integer

		if this.AplicaPercepciones()
			if type( "this.oDetallesMontosGravados" ) == "O"
				this.oDetallesMontosGravados.Remove( -1 )
			endif

			loColeccion = _Screen.Zoo.CrearObjeto( 'ZooColeccion' )
			for lni = 1 to this.FacturaDetalle.Count
				loArticulo = this.FacturaDetalle.Item[ lni ]
				
				if loArticulo.NroItem = this.FacturaDetalle.oItem.NroItem
					loArticulo = this.FacturaDetalle.oItem
				endif
				
				lcKey = transform( loArticulo.PorcentajeIVA ) 
				if !empty( loArticulo.Articulo_PK )
					if !loColeccion.Buscar( lcKey )
						loItem = newobject( "ItemDetalleMontoGravado" )
						loItem.PorcentajeIva = loArticulo.PorcentajeIVA
						loColeccion.Agregar( loItem, lcKey )
					endif		

					loColeccion.Item[lcKey].totalMonto = loColeccion.Item[lcKey].totalMonto + loArticulo.Monto
					loColeccion.Item[lcKey].RecargoComprobante = loColeccion.Item[lcKey].RecargoComprobante + loArticulo.MontoProrrateoRecargoSinImpuestos
					loColeccion.Item[lcKey].DescuentoComprobante  = loColeccion.Item[lcKey].DescuentoComprobante + loArticulo.MontoProrrateoDescuentoSinImpuestos

				endif
			endfor

			if type( "this.oComponenteFiscal" ) == "O"
				lnPorcentajeSumarizadoIIBB = this.oComponenteFiscal.obtenerPorcentajeSumarizadoIIBB()
			else
				lnPorcentajeSumarizadoIIBB = 0
			endif
			
			for each loItemDetalleMontoGrabado in loColeccion
				with loItemDetalleMontoGrabado
					lnPorcentajeDeIva = ( .PorcentajeIVA * 0.01 )
					if This.oComponenteFiscal.MostrarImpuestos()
						lnMontoGravadoAlPorcentajeXConIVA = .TotalMonto + .RecargoComprobante - .DescuentoComprobante
						lnMontoGravadoAlPorcentajeXSinNingunImpuesto = lnMontoGravadoAlPorcentajeXConIVA / ( 1 + lnPorcentajeDeIva )						
					else
						lnMontoGravadoAlPorcentajeXSinNingunImpuesto = ( .TotalMonto + .RecargoComprobante - .DescuentoComprobante )
						lnMontoGravadoAlPorcentajeXConIVA = lnMontoGravadoAlPorcentajeXSinNingunImpuesto * ( 1 + lnPorcentajeDeIva )
					endif
					.TotalPercepciones = lnMontoGravadoAlPorcentajeXSinNingunImpuesto * ( lnPorcentajeSumarizadoIIBB * 0.01 )
					.TotalConImpuestos = lnMontoGravadoAlPorcentajeXConIVA + .TotalPercepciones
					if this.Total > 0
						.PorcentajeRepresentativoSobreElTotal = ( .TotalConImpuestos * 100 ) / this.Total
					else
						.PorcentajeRepresentativoSobreElTotal = 0
					endif 
				endwith
			endfor

			this.oDetallesMontosGravados = loColeccion
		endif	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarCliente() as boolean
		local llRetorno as boolean, lni as Integer, llEstoyEnChile as Boolean

		llRetorno = dodefault()

		llEstoyEnChile = ( GoParametros.Nucleo.DatosGenerales.Pais == 2 ) && Si estoy en Chile Pais = 2
		
		if llRetorno and empty( This.Cliente_Pk )
			if this.ValoresDetalle.ClienteObligatorio()
				for lni = 1 to this.ValoresDetalle.oColValoresClienteObligatorios.Count
					This.AgregarInformacion( "Valor: " + this.ValoresDetalle.oColValoresClienteObligatorios.item[lnI] ) 
				Endfor	
				this.AgregarInformacion( "No está permitido dejar el Cliente vacio. Hay valores que requieren la personalización del comprobante." )
				llRetorno = .F.				
			endif
		endif
		if llRetorno and !empty( This.Cliente_Pk ) and !this.ValidarCuitCliente() and !llEstoyEnChile and !this.lEstoyEnUruguay
			this.AgregarInformacion( "No está permitido grabar el comprobante si el cliente no tiene CUIT." )
			llRetorno = .F.				
		endif
		
		if llRetorno and !empty( This.Cliente_Pk ) and !this.ValidarDniClienteParaComprobantesPersonalizados() and !llEstoyEnChile and !this.lEstoyEnUruguay
			this.AgregarInformacion( "Se superó el límite para comprobantes sin personalizar. No está permitido grabar el comprobante si el cliente no tiene tipo y número de documento." )
			llRetorno = .F.				
		endif

		if 	llRetorno and ;
			( this.TieneComponenteImpuestos() and this.oComponenteFiscal.oComponenteImpuestos.EsAgenteDePercepcionSegunTipoDeImpuesto( "IIBB" ) ) and ;
			this.oComponenteFiscal.oComponenteImpuestos.oColaboradorPercepciones.DebeTenerSeteadoNroDeIibbParaConvenioLocalOMultilateral() and ;
			inlist( this.Cliente.TipoConvenio, 1, 2) and empty( this.Cliente.NroIIBB )
			
			this.AgregarInformacion( 'No está permitido grabar el comprobante si el cliente tiene Convenio Local o Multilateral y no posee Nro. de IIBB.' )
			llRetorno = .F.
			
		endif
			
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function ImprimirTicketParaCambio() as Void
		local loObjetoImpresion as Object, loError as Exception
		if this.ComprobanteFiscal
			loObjetoImpresion = this.CrearEntornoRepo()
			if isnull( loObjetoImpresion )
				This.AgregarInformacion( "No se pudo crear el objeto de impresión" )
			else
				this.oComponenteFiscal.cItemsAImprimirEnComprobante = ;
					["Artículo" as Campo1_e ,] +;
					[Articulo + " " + ArticuloDetalle as Campo1_d ,] +;
					this.ObtenerCamposAdicionalesDetalleFacturaParaImprimirComprobante() 
				try
					this.oComponenteFiscal.ImprimirTicketParaCambio( loObjetoImpresion ) 
				catch to loError
					loEx = Newobject( "ZooException", "ZooException.prg" )
					With loEx
						.Grabar( loError )
						loTemp = .Obtenerinformacion()
						if loTemp.count > 0
							this.CargarInformacion( .Obtenerinformacion() )
						endif
					endwith
					This.EventoAvisarQueElControladorFiscalEstaFueraDeLinea()				
				endtry
			endif
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function HabilitarImpresiondeValedeCambio() as Boolean 
		local llRetorno as Boolean, lcMensaje as String, llHayValesDeCambio as Boolean
		llRetorno = .f.
        If goparametros.felino.controladoresfiscales.OrdenDeCompra.HabilitaLaImpresionDeOrdenesDeCompra
			if goservicios.parametros.felino.controladoresfiscales.ordendecompra.opciondesalida = 2
				llRetorno = .t.
			else
				if goParametros.Felino.ControladoresFiscales.Codigo <> 0 and goParametros.Felino.ControladoresFiscales.Codigo <> 35 && no puede ser caja registradora tampoco
					llRetorno = .t.
				else
					if this.GeneraValeDeCambio()
						if upper( _screen.zoo.app.cproyecto ) = "COLORYTALLE"
							lcMensaje = "Se ha generado el vale de cambio pero no se pudo imprimir ya que no está configurado un controlador fiscal válido."
						else
							lcMensaje = "Se ha generado la orden de compra pero no se pudo imprimir ya que no está configurado el controlador fiscal."
						endif
						this.oMensaje.Informar( lcMensaje )
					endif
				endif
			endif
		endif
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function oValeDeCambio_Access() as Void
		if !this.lDestroy and !( vartype( this.oValeDeCambio ) == "O" )
			this.oValeDeCambio = _screen.Zoo.InstanciarEntidad( "ValeDeCambio" )
		endif
		return this.oValeDeCambio
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function oColaboradorTiquetDeCambio_Access() as Void
		if !this.lDestroy and !( vartype( this.oColaboradorTiquetDeCambio ) == "O" )
			this.oColaboradorTiquetDeCambio = _Screen.zoo.crearobjeto( "ColaboradorTiquetDeCambio" )
		endif
		return this.oColaboradorTiquetDeCambio
	endfunc

	*-----------------------------------------------------------------------------------------
	function ImprimirTiquetDeCambioNoFiscal() as Void
		local loError as Exception
		try
			this.oColaboradorTiquetDeCambio.ImprimirTiquetDeCambio( this )
		catch to loError
			loEx = Newobject( "ZooException", "ZooException.prg" )
			With loEx
				.Grabar( loError )
				loTemp = .Obtenerinformacion()
				if loTemp.count > 0
					this.CargarInformacion( .Obtenerinformacion() )
				endif
			endwith
		endtry
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function GenerarPDFsTiquetDeCambioNoFiscal() as Void
		this.oColaboradorTiquetDeCambio.GenerarPDFsTiquetDeCambio( this )
	endfunc 
	
	*-----------------------------------------------------------------------------------------			
	function ImprimirDespuesDeGrabar() as Boolean
		local llRetorno as Boolean
		llRetorno = doDefault()
		if llRetorno and this.EsNuevo() and ( this.DeboImprimir() or this.DebeImprimirDisenosAutomaticamente() ) and !this.VerificarContexto( 'CBI' )
			this.ImprimirTiquetDeCambioNoFiscal()	
		endif 				
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------			
	protected function GenerarPDFsDespuesDeGrabar() as ZooColeccion of ZooColeccion.Prg
		doDefault()
		if this.EsNuevo() and ( this.DebeGenerarPDFsDeDisenosAutomaticamente() ) and !this.VerificarContexto( 'CBI' )
			this.GenerarPDFsTiquetDeCambioNoFiscal()
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EnviarMailAlGrabar() as Void
		dodefault()
		if !this.lTieneTiquetDeCambioPdf .and. this.lSeConfirmoElEnvioDeMailAlGrabar 
			this.oColaboradorTiquetDeCambio.EnviarTiquetDeCambioPorMail( this )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoPreguntarSiGeneraTiquetDeCambio( toEntidad as Object, tnHabilitaGenerarTiquetDeCambio as Integer ) as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoPreguntarSiGeneraUnTiquetDeCambioPorArticulo( toEntidad as Object, tnHabilitaGenerarUnTiquetDeCambioPorArticulo as Integer ) as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoPreguntarSiGeneraUnTiquetDeCambioPorUnidad( toEntidad as Object, tnHabilitaGenerarUnTiquetDeCambioPorUnidad as Integer ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ImprimirOrdenDeCompra() as Void
		local loObjetoImpresion as Object, loItem as Object, loVale as Object, loError as zooexception OF zooexception.prg,;
			lnCantDisenosImpresora as Integer, lnCantDisenosPDF as Integer, lcMensaje as String

 		lnCantDisenosImpresora = 0
 		lnCantDisenosPDF = 0
 		lcMensaje = ""
 		with this
			If .HabilitarImpresiondeValedeCambio()
				for each loItem in .ValoresDetalle
					if loItem.Tipo = TIPOVALORVALEDECAMBIO &&Vale de cambio
						if empty( loItem.Numerovaledecambio_PK )
							.AgregarInformacion( "No se generó un vale de cambio para este valor (" ;
								+ alltrim( loItem.Valor_pk	) + "). Item " + transform( loItem.NroItem ) )
						else
							try
								.oValeDeCambio.Codigo = loItem.NumeroValeDeCambio_PK
								lnCantDisenosImpresora = .oValeDeCambio.TieneDisenoParaImpresora()
								lnCantDisenosPDF = .oValeDeCambio.TieneDisenoParaPDF() 

								if lnCantDisenosImpresora = 0 and lnCantDisenosPDF = 0
									lcMensaje  = "No se pudo imprimir el comprobante " + .oValeDeCambio.ObtenerDescripcion() + ". " + ;
										"La entidad Vale de cambio no tiene asociado o habilitado ningún diseño de salida. " + ;
										"Puede modificar o cargar un nuevo diseño desde la opción de menú Configuración --> Entrada y salida a dispositivos --> Diseños de salida." 
									.Loguear( lcMensaje )
								else
									if lnCantDisenosImpresora > 0
										.oValeDeCambio.Imprimir()
									endif
									if lnCantDisenosPDF > 0
										.oValeDeCambio.GenerarPDFValeDeCambio()
									endif
								endif
								
							catch to loError
									.Loguear( "No se pudo imprimir el comprobante " + .oValeDeCambio.ObtenerDescripcion() + "." )
							endtry
						endif
					endif
				endfor
			endif
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function GeneraValeDeCambio()as Void
		local loItem as Object, llRetorno as Boolean

		llRetorno = .f.
			for each loItem in This.ValoresDetalle
				if loItem.Tipo = TIPOVALORVALEDECAMBIO and ( this.signodemovimiento * loItem.Recibido < 0 )
					llRetorno = .t.
					exit	 	
				endif
			endfor
		return llRetorno	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AjusteDiferenciaValoresTotal()
*Ajuste por redondeo
		local loDetalle as Object

		if type( "this." + This.cValoresDetalle ) = "O" and !this.lAjusteDiferenciaValoresTotal
			loDetalle = This.cValoresDetalle

			if ( abs( this.&loDetalle..Sum_Total - This.Total ) = 0.01 ) and this.TieneDescuentoRecargo( this.ValoresDetalle.oItem ) and this.&loDetalle..Sum_PesosAlCambio = this.total && and this.TieneDescuentoRecargo()
					
					if This.Total > this.&loDetalle..Sum_Total 
						this.RecargoMonto2 = this.RecargoMonto2 - 0.01
					else 
						this.RecargoMonto2 = this.RecargoMonto2 + 0.01
					endif
					
				this.lAjusteDiferenciaValoresTotal = .t.
				this.CalcularTotal()
				this.lAjusteDiferenciaValoresTotal = .f.				
			endif
		Endif	

	endfunc 
		
	*-----------------------------------------------------------------------------------------
	Function VerificarCodigoDeValorSugeridoParaVuelto() as Void
		local lcCodigoValor as String   

		if empty( goParametros.Felino.Sugerencias.CodigoDeValorSugeridoParaVuelto ) 
			if this.lAsignarCodigoDeValorSugeridoParaVuelto 
				this.BuscarCodigoDeValorSugeridoParaVuelto()
			endif
			this.EventoAsignarCodigoDeValorSugeridoParaVuelto()
		endif

		this.lAsignarCodigoDeValorSugeridoParaVuelto = .f.
			
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function EventoAsignarCodigoDeValorSugeridoParaVuelto() as Void 
				
		if this.lAsignarCodigoDeValorSugeridoParaVuelto and !empty( this.cCodigoDeValorSugeridoParaVuelto )
			goParametros.Felino.Sugerencias.CodigoDeValorSugeridoParaVuelto = this.cCodigoDeValorSugeridoParaVuelto
		endif 	
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function BuscarCodigoDeValorSugeridoParaVuelto() as Void
		with this.oEntidadValor
	
			if .Primero()
		
				do while !.PermiteVuelto and .Siguiente()	
			enddo 
			
				if .PermiteVuelto
					this.cCodigoDeValorSugeridoParaVuelto = .Codigo
					this.cDescripcionDeValorSugeridoParaVuelto = .Descripcion
			else
				this.agregarInformacion( 'Debe habilitar un valor para que permita dar vuelto y luego ' + chr(13) + 'configurar el parámetro "Valor sugerido para dar vuelto".' )
			endif 
		else
			this.agregarInformacion( 'Debe ingresar por lo menos un valor que permita dar vuelto y luego ' + chr(13) + 'configurar el parámetro "Valor sugerido para dar vuelto".' )
		endif 	
		
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function RecalcularMontosPorCargaDeSenia() as Void
		this.oComponenteFiscal.RecalcularImpuestos( This.FacturaDetalle, This.ImpuestosDetalle )
		this.Calculartotal()
		This.FacturaDetalle.Actualizar()
		this.EventoDespuesDeCargarSeniasPendientes()
		This.AplicarRecalculosGenerales()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoDespuesDeCargarSeniasPendientes() as Void
		&&Bindeo al kontroler
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoDespuesLimpiarSeniasCargadas() as Void
		&&Bindeo al Kontroler
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearCargaDeSeniasPendientes( tlCargaSeniasPendientes as Boolean ) as Void
		this.oCompSenias.SetearCargaDeSeniasPendientes( tlCargaSeniasPendientes )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoDespuesDeLimpiarDetalleDeArticulosSeniados() as Void
		&& Bindeo al kontroler
	endfunc	

	*-----------------------------------------------------------------------------------------
	function SoportaSenias() as Boolean
		return type( "This.oCompSenias" ) = "O"
	endfunc

	*-----------------------------------------------------------------------------------------
	function SoportaConsignacion() as Boolean
		return type( "This.oCompRegistroLiquidacionConsignaciones" ) = "O"
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function SoportaDatosAdicionalesA() as Void
		return type( "This.oCompDatosAdicionalesComprobantesA" ) = "O"
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function DespuesDeInicializarElComponenteFiscal() as Void
		dodefault()
		if this.SoportaSenias()
			if type( "this.ArticulosSeniadosDetalle" ) = "O" and !isnull( this.ArticulosSeniadosDetalle )
				if type( "this.ArticulosSeniadosDetalle.oItem" ) = "O" and !isnull( this.ArticulosSeniadosDetalle.oItem )
					this.ArticulosSeniadosDetalle.SetearComportamientodeSenias(.t.)
					This.ArticulosSeniadosDetalle.oItem.InyectarComponenteFiscal( this.oComponenteFiscal )
				endif
			endif
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function RecalcularPreciosDeDetallesAdicionales( tcListaDePrecios as String ) as Void
		dodefault( tcListaDePrecios )
		if this.SoportaSenias()
			this.ArticulosSeniadosDetalle.RecalcularPorCambioDeListaDePrecios( tcListaDePrecios )
		endif		
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ActualizarDetallesAdicionales() as Void
		local loComponenteFiscal as Object
		dodefault()
		if this.SoportaSenias()
			loComponenteFiscal = This.ArticulosSeniadosDetalle.oItem.oComponenteFiscal
			loComponenteFiscal.ActualizarDetalleArticulos( this.ArticulosSeniadosDetalle )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function RecalcularImpuestosDetalleAdicionales() as Void
		local loComponenteFiscal as Object
		dodefault()
		if this.SoportaSenias()
			loComponenteFiscal = This.ArticulosSeniadosDetalle.oItem.oComponenteFiscal
			loComponenteFiscal.RecalcularImpuestos( this.ArticulosSeniadosDetalle, loComponenteFiscal.oImpuestosDetalle )
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function InicializarPreciosDeListaEnArticulos() as Void
		dodefault()
		if this.SoportaSenias()
			this.LlenarPrecioDeListaEnArticulos( this.ArticulosSeniadosDetalle )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerSeniasAUtilizar( tcXMLSeniasPendientes as String ) as Void
		local loArgumentosEvento as Object
		loArgumentosEvento = _screen.zoo.CrearObjeto( "ArgumentoEventoSeleccionDeSeniasPendientes", "Ent_ComprobanteDeVentasConValores.prg" )
		loArgumentosEvento.cXMLSeniasPendientes = tcXMLSeniasPendientes
		loArgumentosEvento.cXMLSeniasSeleccionadas = tcXMLSeniasPendientes
		this.EventoSeleccionDeSeniasPendientes( this, loArgumentosEvento )
		return loArgumentosEvento.cXMLSeniasSeleccionadas
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoSeleccionDeSeniasPendientes( toPublicador as Object, toArgumentos as Object ) as Void
	endfunc

	*-----------------------------------------------------------------------------------------
	function ImprimirCheques() as Boolean
		local llRetorno as Boolean, loDetalle as ZooColeccion of ZooColeccion.prg, loItem as Object, ;
			loError as Exception, i as Integer, loObjetoImpresionCheques as Object
		llRetorno = .T.

		try
			if ( this.EsNuevo() or this.EsEdicion() ) and this.lProcesando = .f. 
				llRetorno = .F.
				this.AgregarInformacion( "Debe grabar el comprobante para imprimir el cheque" )
			else
				if type( "this." + this.cValoresDetalle ) = "O"
					loDetalle = evaluate( "this." + this.cValoresDetalle )
					for i=1 to loDetalle.count
						loDetalle.CargarItem(i)
						loItem = loDetalle.oItem
						if !empty( loItem.valor_pk )
							if loItem.Valor.esImprimible()
								this.lImprimeCheque = .T.
								this.EventoPreguntarImprimirCheque( loItem )
								if this.lImprimeCheque
									loDetalle.oItem.oCompCajero.Imprimir( loItem )
								endif
							endif
						endif
					endfor
				endif
			endif
		catch to loError
		endtry
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoPreguntarImprimirCheque( toItem as object ) as Void
		&&Bindeo al kontroler
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoSeAgregoQuitoSenia( tlSeAgrego as Boolean ) as Void
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EjecutarAccionSenia( tcAccion as String, toArgumentos as ArgumentosAccionesSenias of ArgumentosAccionesSenias.prg ) as Void
		this.EventoEjecutarAccionSenia( tcAccion, toArgumentos )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoEjecutarAccionSenia( tcAccion as String, toArgumentos as ArgumentosAccionesSenias of ArgumentosAccionesSenias.prg ) as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerDatosDelCupon( toCupon as din_EntidadCupon of din_EntidadCupon.prg, tcValorAnterior as String ) as void
		return this.EventoObtenerDatosDelCupon( this, toCupon, tcValorAnterior )
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoObtenerDatosDelCupon( toPublicador as Object, toArgumentos as Object, tcValorAnterior as String ) as Void
		&&Bindeo al kontroler
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoSetearFilaActivaDeLaGrillaDeValores( tnFila as Integer, tlEsCondicionDePago as Boolean ) as Void
		&&Bindeo al kontroler
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function DebeMostrarAdvertenciaRecalculoPrecios() as Boolean
		local llRetorno as Boolean
		llRetorno = dodefault()

		if llRetorno and this.lCambioSituacionFiscal and this.SoportaSenias()
			llRetorno = !This.oCompsenias.ExisteItemsSeniasACancelarAplanados()
		endif

		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerChequeDeCarteraAUtilizar( toArgumentosEvento as Object, cXMLChequesEnCarteraPendientes as String, tcSqlFiltroBuscador as String ) as Void
		this.EventoSeleccionDeChequeDeCarteraAUtilizar( this, toArgumentosEvento )
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoSeleccionDeChequeDeCarteraAUtilizar( toPublicador as Object, toArgumentos as Object ) as Void
	endfunc	

	*-----------------------------------------------------------------------------------------
	function Senia_Pk_Access() as String
		if !this.ldestroy	
			if pemstatus(this,"IdSenia",5)
				return This.IdSenia
			else
				return ""
			endif 
		Endif	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoSeSeleccionoUnValorQueUtilizaRecargosPorMontos() as Void
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoSeSeleccionoUnValorQueNoUtilizaRecargosPorMontos() as Void
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ValidarCuitCliente() as Boolean
		local llRetorno as Boolean

		llRetorno = Iif( this.Cliente.SituacionFiscal_pk = 3 or this.Cliente.SituacionFiscal_pk = 0, .t., len( alltrim( this.Cliente.Cuit ) ) > 0 )

		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ValidarDniClienteParaComprobantesPersonalizados() as Boolean
		local llRetorno as Boolean, lnLimiteComprobanteSinPersonalizar as Integer

		if type( "this.oComponenteFiscal" ) == "O" and pemstatus ( this.oComponenteFiscal, "nLimiteComprobanteSinPersonalizar", 5 )
			lnLimiteComprobanteSinPersonalizar = this.oComponenteFiscal.nLimiteComprobanteSinPersonalizar
		else
			lnLimiteComprobanteSinPersonalizar = goparametros.fELINO.gESTIONDEVENTAS.limiteTOTALDEUNCOMPROBANTESINPERSONALIZAR
		endif
			
		llRetorno = Iif( this.Cliente.SituacionFiscal_pk = 3 and This.Total >= lnLimiteComprobanteSinPersonalizar , len( alltrim( this.Cliente.TipoDocumento ) ) > 0 and len( alltrim( this.Cliente.NroDocumento ) ) > 0, .t. )

		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ExisteTotalIvaNegativo() as Boolean
		local llRetorno as Boolean
		llRetorno = .F.

		for each loItem in this.impuestosdetalle foxobject
			if round( loItem.MontoDeIva, 2 ) < 0 or round( loitem.montonogravado, 2 ) < 0
				llRetorno = .T.
				exit for
			endif
		endfor
		
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function TieneDetalleDeImpuestos() as Boolean
		local llRetorno as Boolean
		
		llRetorno = pemstatus( this, "ImpuestosDetalle", 5 ) and type( "This.ImpuestosDetalle" ) = "O"
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Validar() as boolean
		local llRetorno as boolean

		llRetorno = dodefault()
		
		if this.SuperaLimiteDescuentoEnControladorFiscalIBM( this.PorcentajeDescuento )
			this.AgregarInformacion( "El porcentaje de descuento supera lo permitido por el controlador fiscal.", 1 )
			llRetorno = .F.
		endif	
		
		if this.DebeValidarLimiteEnControladorFiscalIBM()
			llRetorno = llRetorno and this.ValidarAtributosDetalle( "FacturaDetalle" )
		endif

		if llRetorno and this.TieneDetalleDeImpuestos() and this.CorrespondeValidarAlicuotaNegativaEnComprobante()
			if this.ExisteTotalIvaNegativo() and !this.VerificarYGenerarNCPorCorreccionDeAlicuotaGiftCard()
				this.AgregarInformacion( "Al menos una de las alícuotas de I.V.A. en el comprobante es negativa." + chr( 10 ) + "Verifique las alícuotas de los artículos ingresados.", 1 )
				llRetorno = .F.
			endif
		endif

		if !this.ValidarTotalDeImpuestosInternos()
			this.AgregarInformacion( "La suma de impuestos internos en el comprobante es negativa." + chr( 10 ) + "Verifique las tasas de los artículos.", 1 )
			llRetorno = .F.
		endif
		
		if this.lTieneEntregaOnline 
			if empty( this.Cliente_PK )
				this.AgregarInformacion( "Debe personalizar el comprobante si la entrega es de tipo 'Venta continua'" )
				llRetorno = .F.
			endif
			if this.lTieneSeniaCargada
				this.AgregarInformacion( "No puede señar artículos si la entrega es de tipo 'Venta continua'" )
				llRetorno = .F.
			endif
		endif

		this.ValidarYRenumerarNroItemDetalleImpuestos()

		llRetorno = llRetorno and this.ValidarTotalRecargosValoresEnPositivo()
		llRetorno = llRetorno and this.ValidarLimiteTicketFactura()
		llRetorno = llRetorno and this.ValidarDatosAdicionalesComprobanteA()

		llRetorno = llRetorno and this.ValidarDatosAdicionalesSIRE()
			
		llRetorno = llRetorno and this.oValidadores.Validar()
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarYRenumerarNroItemDetalleImpuestos() as Boolean
		if type( "this.oComponenteFiscal" ) = "O" and type( "this.ImpuestosDetalle" ) = "O"
			this.oComponenteFiscal.RenumerarNroItemDetalleImpuestos( this.ImpuestosDetalle )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CorrespondeValidarAlicuotaNegativaEnComprobante() as Boolean
		return .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function VerificarYGenerarNCPorCorreccionDeAlicuotaGiftCard() as Boolean
		local llRetorno as Boolean, loError as Object
		llRetorno = .F.
		this.lGeneroNCPorCorreccionDeAlicuotaGiftCard = .f.
		if type( "this.FacturaDetalle.oItem.oCompGiftCard" ) = "O"
			if this.FacturaDetalle.oItem.oCompGiftCard.CorrespondeHacerNCPorCorreccionDeAlicuota( this )
				try
					llRetorno = this.RealizarNCPorCorreccionDeAlicuotaGiftCard()
					llRetorno = llRetorno and this.ModificarComprobantePorCorreccionDeAlicuotaGiftCard()
					llRetorno = llRetorno and this.CompletarAccionesDeSistemasPorCorreccionDeAlicuotaGiftCard()
				Catch To loError
					llRetorno = .f.
					goServicios.Errores.LevantarExcepcion( loError )
				endtry
			endif
		endif
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerColaboradorComprobanteDeVentas() as Object
		*!* Si es un comprobante electronico, piso este método para usar el colaborador correcto
		return this.oColaboradorComprobantesDeVenta
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function RealizarNCPorCorreccionDeAlicuotaGiftCard() as Boolean
		local llRetorno as Boolean, loError as Object, loColaborador as Object
		this.EventoComienzoNCPorCorreccionDeAlicuotaGiftCard( "Generando nota de crédito ..." )
		try
			loColaborador = this.ObtenerColaboradorComprobanteDeVentas()
			llRetorno = loColaborador.GenerarNCPorCorreccionDeAlicuotaGiftCard( this )
			this.lGeneroNCPorCorreccionDeAlicuotaGiftCard = .t.
		Catch To loError
			llRetorno = .f.
			Throw loError
		finally
			this.EventoFinGeneracionNCPorCorreccionDeAlicuotaGiftCard()
		Endtry
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ModificarComprobantePorCorreccionDeAlicuotaGiftCard() as Boolean
		Local llRetorno as Boolean 
		llRetorno = this.FacturaDetalle.oItem.oCompGiftCard.QuitarLasGiftCardConsumidasDelComprobante( this )
		if llRetorno
			this.AplicarProrrateo()
			loColaborador = this.ObtenerColaboradorComprobanteDeVentas()
			llRetorno = loColaborador.AjustarValoresDelComprobante( this )
		endif 
		Return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function CompletarAccionesDeSistemasPorCorreccionDeAlicuotaGiftCard() as Boolean
		local llRetorno as Boolean, lcMotivo as String
		lcMotivo = " - Motivo: Alícuota negativa por diferencia de I.V.A. en giftcard."
		loColaborador = this.ObtenerColaboradorComprobanteDeVentas()
		llRetorno = loColaborador.CompletarAccionesDeSistemas( this, lcMotivo )
		return llRetorno 
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoComienzoNCPorCorreccionDeAlicuotaGiftCard( tcMensaje as String ) as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoFinGeneracionNCPorCorreccionDeAlicuotaGiftCard() as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarCambiosDeMismaCombinacion() as Boolean
		local loCambiosMismaCombinacion  as Object, lnCantidad as Number, loColCambios as Object, llRetorno as boolean
		
		llRetorno = .t.
		lnPreguntar = goParametros.Felino.GestionDeVentas.Minorista.RealizarCambiosDeArticulosConLaMismaCombinacion
		
		if lnPreguntar > 1 and this.NoEsUnaModificacionConOrdenDeServicio()
			loCambiosMismaCombinacion = this.Iterar()
			if loCambiosMismaCombinacion.Count > 0
				lcCombinacion = this.ObtenerDetalleCombinacionesConCambio( loCambiosMismaCombinacion )
				lcPregunta = "Existe alguna combinación (" + lcCombinacion + ") que se repite en un cambio. ¿Desea continuar?"
				do case 
					case lnPreguntar = 2
						this.lQueHacerConCambio = .f.
					case lnPreguntar = 3
						this.lQueHacerConCambio = .t.
						this.EventoPreguntarQueHacerConCambio( lnPreguntar, lcPregunta )
					case lnPreguntar = 4
						this.lQueHacerConCambio = .t.
					this.EventoPreguntarQueHacerConCambio( lnPreguntar, lcPregunta )
				endcase
				if !this.lQueHacerConCambio
					llRetorno = .F.
					if lnPreguntar = 2	
						goMensajes.Advertir("Debe resolver las combinaciones (" + lcCombinacion + ") con cambios no permitidos",0)
					endif
				endif
			endif
		endif

		return llRetorno
	endfunc
		
	*-----------------------------------------------------------------------------------------
	function NoEsUnaModificacionConOrdenDeServicio() as boolean
		local llRetorno as bolean
		
		llRetorno = .t.
		if at( "ORDEN DE SERVICIO", upper( this.zadsfw ) ) > 0
			llRetorno = .F.
		endif
		return llretorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerDetalleCombinacionesConCambio( toCambios ) as string
		local lcCombinaciones as string
		
		lcCombinaciones = ""
		for i = 0 to (toCambios.Count -1)
			lcCombinaciones = lcCombinaciones + toCambios.Item(i) + "; "
		endfor

		return left( lcCombinaciones, len(lcCombinaciones)-2 )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Iterar() as object

		loColCambios = _screen.zoo.crearobjeto( "zoocoleccion" )
		for lnCantidad = 1 to this.FacturaDetalle.oItem.oCompStock.oCombinacion.count
			loColCambios.add( alltrim( this.FacturaDetalle.oItem.oCompStock.oCombinacion[ lnCantidad ] ) )
		endfor
		this.oColeccion.ObtenerCombinacionRepetida(this.FacturaDetalle, loColCambios )
		return this.oColeccion.ObtenerCambios()
	endfunc
		
	*-----------------------------------------------------------------------------------------
	function ValidarLimiteTicketFactura() as Boolean
		local loItem as Object, lnTotalAcumuladoDeItems as number, lnDescuentos as Number, llRetorno as Boolean, lcMensajeError as String, lnLimiteTF as float
		llRetorno = .t.
		lnTotalAcumuladoDeItems = 0
		if this.VerificarCaracteristicasControladorFiscal() and !empty( alltrim( this.cliente.codigo ) )
			if this.Total >= goControladorFiscal.oCaracteristicas.nLimiteTicketFactura
				llRetorno = .f.
				lcMensajeError = "Se ha superado el monto máximo permitido por el controlador fiscal ( $ " + alltrim( transform( goControladorFiscal.oCaracteristicas.nLimiteTicketFactura ) ) + " )."
				this.AgregarInformacion( lcMensajeError )
			endif
		endif
	
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function VerificarSuperaLimiteCF( toItemFactura as Object ) as boolean
		local llRetorno as Boolean
		
		llRetorno = this.SuperaLimiteCF( toItemFactura )
		
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function superaLimiteCF( toItemFactura as object ) as Boolean
		local llretorno as Boolean
		llretorno = .f.
		
		if goControladorFiscal.oCaracteristicas.cmarca = "HASAR" and goControladorFiscal.oCaracteristicas.cmodelo != "PT-1000F / PT-250F"
			Do Case
				Case this.letra = "A" 
					llretorno = IIF (this.subtotalBruto => goControladorFiscal.oCaracteristicas.nLimiteTicketFactura, .t., .f.)
				case ((toItemFactura.PrecioConImpuestos) * toItemFactura.cantidad) => goControladorFiscal.oCaracteristicas.nLimiteTicketFactura
					llretorno = .t.
				Case this.subtotalNeto => goControladorFiscal.oCaracteristicas.nLimiteTicketFactura
					llretorno = .t.
				Otherwise
					llretorno = .f.
			endcase
		endif	
	
	return llretorno

	*-----------------------------------------------------------------------------------------
	function ValidarLimiteSubtotalAcumuladoTicketSinPersonalizar() as boolean
		local llRetorno as boolean, loItemDetalle as object, lnSubtotalPositivos as Double

		llRetorno = .t.
		if this.VerificarSubtotalAcumuladoPorItem() 

			lnSubtotalPositivos = 0
			
			for each loItemDetalle in this.FacturaDetalle
				if loItemDetalle.Cantidad > 0
					lnSubtotalPositivos = lnSubtotalPositivos + loItemDetalle.Monto
				endif
			endfor
			
			if lnSubtotalPositivos > goControladorFiscal.oCaracteristicas.nLimiteTicketSinPersonalizar 
				llRetorno = .f.
			endif		
			
			if !llRetorno 
				this.AgregarInformacion( "El controlador fiscal requiere la personalización del comprobante.", 1 )
			endif	
		endif

		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarDatosAdicionalesComprobanteA() as Boolean
		local llRetorno as Boolean
		llRetorno = .T.
		if this.SoportaDatosAdicionalesA()
			llRetorno = this.oCompDatosAdicionalesComprobantesA.ValidarDatos()
		endif
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarDatosAdicionalesSIRE() as Boolean
		local llRetorno as Boolean
		llRetorno = .T.

		if !this.lCanceloCargaSIRE and this.SoportaDatosAdicionalesSIRE()
			llRetorno = this.oCompDatosAdicionalesSIRE.ValidarDatos()
		endif
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function DebeObtenerCertificadoSIRE() as Boolean
		local llRetorno as Boolean
		llRetorno = GoParametros.Felino.Interfases.AFIP.RG452319Sire.HabilitarPercepciones and !this.lCanceloCargaSIRE and this.lPedirCertificadoSire and ;
			( this.TieneComponenteImpuestos() and this.oComponenteFiscal.oComponenteImpuestos.EsAgenteDePercepcionSegunTipoDeImpuesto( "IVA" ) )
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function SoportaDatosAdicionalesSIRE() as Boolean 
		return this.lPedirCertificadoSire and GoParametros.Felino.Interfases.AFIP.RG452319Sire.HabilitarPercepciones and type( "This.oCompDatosAdicionalesSIRE" ) = "O" 
	endfunc
			
	*-----------------------------------------------------------------------------------------
	protected function VerificarCaracteristicasControladorFiscal() as Boolean
		local llRetorno 
		llRetorno = ( pemstatus( this, "ComprobanteFiscal", 5 ) and vartype( this.ComprobanteFiscal ) == "L" and this.ComprobanteFiscal ) 
		llRetorno = llRetorno and vartype( goControladorFiscal ) == "O"  and ( vartype( goControladorFiscal.oCaracteristicas ) == "O" )
		llRetorno = llRetorno and goControladorFiscal.oCaracteristicas.nLimiteTicketFactura > 0 
		llRetorno = llRetorno and !goControladorFiscal.oCaracteristicas.lPaginaCompleta 
				
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function VerificarSubtotalAcumuladoPorItem() as Boolean 
		local llRetorno 
		llRetorno = ( pemstatus( this, "ComprobanteFiscal", 5 ) and vartype( this.ComprobanteFiscal ) == "L" and this.ComprobanteFiscal ) 
		llRetorno = llRetorno and vartype( goControladorFiscal ) == "O"  and ( vartype( goControladorFiscal.oCaracteristicas ) == "O" )
		llRetorno = llRetorno and goControladorFiscal.oCaracteristicas.nLimiteTicketFactura > 0
		llRetorno = llRetorno and goControladorFiscal.oCaracteristicas.lValidaLimiteSubtotalAcumuladoPorItem
		llRetorno = llRetorno and empty( alltrim( this.cliente.codigo ) )
								
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarTotalRecargosValoresEnPositivo() as Boolean
		local lnTotalRecargos as Number, loItem as Object, llRetorno as Boolean
		llRetorno = .T.
		lnTotalRecargos = 0
		if type( "This.ValoresDetalle" ) = "O"
			for each loItem in This.ValoresDetalle foxobject
				lnTotalRecargos = lnTotalRecargos + loItem.RecargoMontoSinImpuestos
			endfor
			if lnTotalRecargos  < 0
				llRetorno = .F.
				This.AgregarInformacion( "El total de recargos en los valores ingresados debe ser mayor o igual a 0" )
			endif
		endif
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function DebeValidarLimiteEnControladorFiscalIBM() as boolean
		return pemstatus( this, "FacturaDetalle", 5 ) and vartype( this.FacturaDetalle ) == "O" and this.escomprobantefiscal() and goParametros.Felino.ControladoresFiscales.Codigo == 30
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarAtributosDetalle( tcDetalle as String ) as Boolean
	local llRetorno as boolean, loDetalle as Object
			
		llRetorno = .t.
		loDetalle = this.&tcDetalle	
		for each loItem in loDetalle
			llRetorno = llRetorno and this.ValidarDescuentoEnLinea( loItem )
		next
		
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ValidarDescuentoEnLinea( toItem as object ) as Void
		local llRetorno as Boolean 
		
		llRetorno = .t. 
		if this.SuperaLimiteDescuentoEnControladorFiscalIBM( toItem.Descuento )
			this.AgregarInformacion( "El porcentaje de descuento supera lo permitido por el controlador fiscal para el item " + alltrim( toItem.articulodetalle ) + " (" + alltrim( toItem.articulo_pk )+ ").", 1 )
			llRetorno = .F.
		endif
		return llRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SuperaLimiteDescuentoEnControladorFiscalIBM( tnAtributoPorcentajeDescuento as Integer ) as boolean
		local llSuperaLimite as boolean, lnPorcentajeDescuento as Integer
	
		llSuperaLimite = .T.
		if between( tnAtributoPorcentajeDescuento, 0, goParametros.Felino.ControladoresFiscales.DescuentoMaximoPermitido )
			llSuperaLimite = .F.
		endif 
		llRetorno = this.escomprobantefiscal() and goParametros.Felino.ControladoresFiscales.Codigo == 30 and llSuperaLimite
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Cargar() as Boolean
		local llRetorno as Boolean, lnImporteVuelto as Double

		if This.EsComprobanteConVuelto()
			lnImporteVuelto = 0
			llRetorno = dodefault()
			if llRetorno
				lnImporteVuelto = this.SetearVueltoDesdeElDetalle()
			else
				this.lCursoresVacios = .t.
			endif
			this.lDebeCalcularVuelto = .t.
			This.SetearVueltoDespuesDeCargar( lnImporteVuelto )
			this.lDebeCalcularVuelto = .f.
			if pemstatus( this, "ValoresDetalle", 5 )
				this.ValoresDetalle.Sumarizar()
			endif
			this.lCargando = .t.
			this.SetearAtributosVirtuales()
			this.lCargando = .f.
		else
			llRetorno = dodefault()
		endif		
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function SetearVueltoDespuesDeCargar( tnImporte as Double ) as Void
		if This.lCursoresVacios and !this.lGrabandoRecibo
			this.CalcularVuelto( this.cdetallecomprobante )
		else
			this.VueltoVirtual = tnImporte
			this.EventoOcultarOMostrarVuelto()
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoOcultarOMostrarVuelto() as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function eventoRefrescarGrillaDeValores() as Void	
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearVueltoDesdeElDetalle() as double
		local lnVuelto as Double, loError as Object, lcMonedaValorVuelto as String,;
			 lcMonedaComprobante as String, cCurCabecera as String, cCurVuelto as String
		lnVuelto = 0
		cCurCabecera =  this.oad.cnombrecursor&&"c_" + upper( alltrim( this.cNombre ) )
		cCurVuelto = sys( 2015 )
		if used( "c_ValoresDetalle" )
			select Valor, Recibido from c_ValoresDetalle where EsVuelto into cursor &cCurVuelto
		endif
		if used( cCurVuelto ) and reccount( cCurVuelto ) > 0 and &cCurVuelto..Recibido != 0
			this.lCursoresVacios = .F.
			try
				with this.oEntidadValor
					.Codigo = &cCurVuelto..Valor
					lcMonedaValorVuelto = upper( rtrim( .SimboloMonetario_Pk ) )
				endwith
				lcMonedaComprobante = upper( rtrim( &cCurCabecera..MonedaComprobante ) )
				if lcMonedaValorVuelto != lcMonedaComprobante
					lnVuelto = this.ValoresDetalle.oMoneda.ConvertirImporte( &cCurVuelto..Recibido * -1, lcMonedaValorVuelto, lcMonedaComprobante , &cCurCabecera..Fecha )
				else
					lnVuelto = &cCurVuelto..Recibido * - 1
				endif
			catch to loError
			endtry
		else
			*No tienen nada los cursores, presionó siguiente estando en el último
			this.lCursoresVacios = .T.
		endif
		use in select( cCurVuelto )
		return lnVuelto
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearAtributosVirtuales() as Void
		if this.SoportaPromociones()
			this.Sucursal_PK = goParametros.Nucleo.Sucursal
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerCuponAsociadoAItemValor( toItemValor as Object ) as Object
		local loCupon as Object, loComponente as Object
		loCupon = null
		loComponente = this.ValoresDetalle.oItem.oCompCajero.ObtenerComponente( 3 )
		loCupon = loComponente.ObtenerCuponExistente( toItemValor )
		return loCupon
	endfunc

	*-----------------------------------------------------------------------------------------
	function VerificarRecalculoVuelto() as Void
		this.CalcularVuelto( this.cDetalleComprobante )
		this.lEsComprobanteConRecargoSubtotalEnCero = .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EnviareImprimirSiTieneGiftcardAsociado() as Void  
		local  loItem as Object, lnIndice as Integer, lcNumeroGiftcard
	
		if type( "this.FacturaDetalle" ) = "O" and type( "this.FacturaDetalle.oItem.oCompGiftCard.oentidad" ) = "O" and !empty(this.FacturaDetalle.oItem.oCompGiftCard.oentidad.codigo)
			for lnI = 1 to this.FacturaDetalle.Count
				lcNumeroGiftcard = this.FacturaDetalle.Item[lnI].numerogiftcard_pk
				if !empty( lcNumeroGiftcard )
					this.FacturaDetalle.oItem.oCompGiftCard.EnviarporMaileImprimirlaGiftcard( lcNumeroGiftcard )
				endif
			endfor
		endif	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function DespuesDeGrabar() As Boolean
		local llRetorno as Boolean, loError as Exception, loInformacion as Object, llGenerarNC as Boolean, lcMensaje as String
		
		llRetorno = dodefault()

			if this.SoportaDatosDGIUruguay()
				this.oColaboradorDatosUruguay.PedirDatosDGI( this.codigo, this.Obs )
				this.Obs = this.oColaboradorDatosUruguay.cObsComprobante
			endif

		if this.lPedirCertificadoSire
			this.ObtenerCertificadoSIRE()
		endif

		if this.SoportaPromociones() and this.TienePromocionBancaria() and this.DebeGenerarNotaDeCreditoAlGrabarElComprobante() and !this.llFalloAlImprimir
			loInformacion  = this.oColaboradorAjusteDeCupon.ValidarParametrosAUtilizarEnNotaDeCredito()
			if loInformacion.Count > 0
				goServicios.Mensajes.Advertir( loInformacion )
			else
				llGenerarNC = .T.
				do while ( llGenerarNC )
					try
						this.oColaboradorAjusteDeCupon.GenerarNCParaAjustesDeCuponDeUnComprobante( this.Codigo )
						llGenerarNC = .f.
					catch to loError
					
						lcMensaje = "Se produjo un error al generar notas de crédito por promoción bancaria."
						do case
							case pemstatus(loError.UserValue, "UserValue", 5 ) and vartype( loError.UserValue.UserValue.oInformacion.count ) = "N" and loError.UserValue.UserValue.oInformacion.count > 0
								lcMensaje = lcMensaje + NUEVALINEA + loError.UserValue.UserValue.oInformacion.item(1).cmensaje							
							case pemstatus(loError.UserValue, "oInformacion", 5 ) and vartype( loError.UserValue.oInformacion.count ) = "N" and loError.UserValue.oInformacion.count > 0
								lcMensaje = lcMensaje + NUEVALINEA + loError.UserValue.oInformacion.item(1).cmensaje
							case pemstatus(loError.UserValue, "message", 5 ) and vartype( loError.UserValue.message ) = "C" and !empty( loError.UserValue.message )
								lcMensaje = lcMensaje + NUEVALINEA + loError.UserValue.message
							otherwise
								lcMessage = lcMessage + " " + this.MensajeEspecificoDePromocionBancaria()
						endcase
						lcMensaje = lcMensaje + NUEVALINEA + " ¿Desea reintentar?" 
						if goServicios.Mensajes.Advertir( lcMensaje, 1 ) = 2
							llGenerarNC = .f.
							lcMensaje = "Se ha cancelado la generación de notas de crédito por promoción bancaria." + NUEVALINEA + this.ReferenciaAlArchivoDeLog()
							goServicios.Mensajes.Informar( lcMensaje )
						endif
					finally
					endtry
				Enddo
			endif
		endif

		this.oCuponesHuerfanosAplicados = null 
		this.EventoDespuesDeGrabarActualizarBarraDeAcciones()
		if this.lComprobanteConVuelto and this.TieneVuelto()
			this.QuitarItemVuelto()
		endif
		
		this.lEsComprobanteConRecargoSubtotalEnCero = .f.
		if this.SoportaSenias()
			this.oCompSenias.RestaurarImpuestos()
		endif
		
		if this.TieneEmailParaActualizar() and this.TieneQueActualizarEmailDeCliente( this.Email )
			lcSentencia = this.ObtenerSentenciaDeUpdateDeCliente( this.Email )
			goServicios.Datos.EjecutarSentencias( lcSentencia , "cli", "", "", this.DataSessionId )
		endif
	
		if this.lAgruparPacksAutomaticamente
			this.AgruparPacksAutomaticamente()
		endif
		
		if this.lEsComprobanteConStock
			this.lTieneEntregaPosterior = .f.
			this.lTieneEntregaOnLine = .f.
			this.SetearSignoPorEntregaPosteriorDefault()
			this.SetearControlDeStock(.t.)
		endif
		
		if this.SoportaPromociones() and this.lAplicarPromosAutomaticasAlSalirDelDetalle &&mbrodriguez
			this.SetearlAplicarPromosAutomaticasAlSalirDelDetalle()
		endif
		
		if this.lEsComprobanteConEntregaPosterior
			this.EventoActualizarComboEntregaPosterior( .f. )
		endif
		
		if this.DebeAdjuntarComprobanteAPlataformaEcommerce()
			this.AdjuntarComprobanteAPlataformaEcommece()
		endif

		this.EnviareImprimirSiTieneGiftcardAsociado()	
		
		this.lTieneTiquetDeCambioPdf = .f.
		this.lSeConfirmoElEnvioDeMailAlGrabar = .f.
		this.lSeLeyeronLosParemetosParaTiquetDeCambio = .f.
		
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerCertificadoSire() as Void
	local loSire as object, lcCertificadoSire as String

		loSire = null
		
		if this.EsEdicion() and ( this.DebeObtenerCertificadoSIRE() or ( pemstatus( this, "oSireAModificar", 5  ) and vartype ( this.oSireAModificar ) == "O" and !empty( this.oSireAModificar.NumeroCertificado ) ) )
			&& anular el certificado existente y pedir uno nuevo
			this.oColaboradorSireWS.AnularCertificadoSIREWS( this.oSireAModificar ) 
			this.oSireAModificar = null
		endif	
		if this.DebeObtenerCertificadoSIRE() 
			loSire = this.oColaboradorSireWS.ObtenerDatosParaSire( this  )
			lcCertificado = this.oColaboradorSireWS.ObtenerCertificadoSIREWS( loSire ) 			
			this.oColaboradorSireWS.ActualizarTablaImpVentasParaSIRE( lcCertificado, this.codigo )
			loSire = null
		endif

		return	

	endfunc 

	*-----------------------------------------------------------------------------------------
	function TieneVuelto() as Boolean
		return this.lTieneVuelto
	endfunc 

	*-----------------------------------------------------------------------------------------
	function QuitarItemVuelto() as Void 
		local loDetalle as Object, i as Integer, lcMonedaValorVuelto as String, loError as Object
		if this.TieneVuelto()
			loDetalle = This.cValoresDetalle
			
			with this.&loDetalle
				for i= .count to 1 step -1
					if .item[i].esVuelto
						try
							this.oEntidadValor.Codigo = .item[i].Valor_pk
							lcMonedaValorVuelto = this.oEntidadValor.SimboloMonetario_Pk
						catch to loError
						endtry

						this.VueltoVirtual = this.ValoresDetalle.oMoneda.ConvertirImporte(.item[i].Recibido * -1, lcMonedaValorVuelto, this.MonedaComprobante_pk, this.fecha )
						this.nVueltoCotizado = this.ValoresDetalle.oMoneda.ConvertirImporte(.item[i].Recibido * -1, lcMonedaValorVuelto , this.MonedaComprobante_pk, this.fecha )
						*.remove(i)
						.oItem.nroItem = i
						.oItem.Valor_pk = ""	
						.actualizar()
						.limpiarItem()
						*.sum_RecibidoAlCambio = .sum_RecibidoAlCambio + this.nVueltoCotizado 

						exit
					endif
				endfor
			endwith
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function TienePromocionBancaria() as Boolean
		local llRetorno as Boolean, loItem as Object
		llRetorno = .f.
		if this.SoportaPromociones()
			for each loItem in this.PromocionesDetalle foxObject
				if loItem.PromocionTipo = 5
					llRetorno = .t.
					exit
				endif
			endfor
		endif
		return ( llRetorno )
	endfunc

	*-----------------------------------------------------------------------------------------
	function FueGeneradoPorPromocionBancaria() as Boolean
		local llRetorno as Boolean, loItem as Object
		llRetorno = .f.
		if type( "this.ValoresDetalle" ) = "O"
			for each loItem in this.ValoresDetalle foxObject
				if loItem.Tipo = TIPOVALORAJUSTEDECUPON
					llRetorno = .t.
					exit
				endif
			endfor
		endif
		return ( llRetorno )
	endfunc

	*-----------------------------------------------------------------------------------------
	function DebeGenerarNotaDeCreditoAlGrabarElComprobante() as Void
		return alltrim( goParametros.Felino.GestionDeVentas.AjusteDeCupon.MomentoDeGeneracionDeLosComprobantes ) == "Al grabar un comprobante"
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function SetearNoCalculaPercepciones( tlHabilita as Boolean ) as Void
		this.NoCalculaPercepcion = tlHabilita 
		this.CalcularTotal()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerNoCalculaPercepciones() as Boolean 
		return this.NoCalculaPercepcion
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SumarPercepciones()
		if !this.ObtenerNoCalculaPercepciones()
			dodefault()
		else
			this.SumPercepciones = 0
		endif 
	endfunc	

	*-----------------------------------------------------------------------------------------
	protected function MensajeEspecificoDePromocionBancaria() as String
		local loComprobantes as Object, lnComprobante as Integer, lcRetorno as String
			loComprobantes = newobject( "din_Comprobante", "din_Comprobante.prg" )
			lnComprobante = loComprobantes.ObtenerNumeroComprobante( goParametros.Felino.GestionDeVentas.AjusteDeCupon.TipoDeComprobanteAGenerar )
			lcRetorno = ""
			do case
				case lnComprobante = 3
					lcRetorno = "Verifique los parámetros."
				case lnComprobante = 5
					lcRetorno  = "Verifique la configuración del controlador fiscal y la conexión del mismo."
				case lnComprobante = 28
					lcRetorno  = "Verifique la configuración de la factura electrónica, la vigencia del certificado y la conexión a internet."
			endcase
		loComprobantes.Release()
		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ReferenciaAlArchivoDeLog() as String
		local lcRetorno as String, lnComprobante as Integer, loComprobantes as din_Comprobante of din_Comprobante.prg
			lcRetorno = "Para mas información revise el archivo "
			lcRetorno = lcRetorno + alltrim( _screen.zoo.cRutaInicial ) + "Log" + "\Log.err"
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function TieneQueVerificarMinimoDeReposicion() as Boolean
		return goparametros.felino.gestiondeventas.daravisoporstockinferioralminimodestockestablecidofacturanotadebynotacred
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ApagarPrenderAsistente( tlValor as Boolean ) as Void
		if This.EsEdicion() or this.EsNuevo()
			This.oManagerPromociones.HabilitarSerializacionPorHilos()
		else
			This.oManagerPromociones.DeshabilitarSerializacionPorHilos()			
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function ExistenCuponesHuerfanosNoNeteados() As Boolean
		Local llRetorno As boolean, lnTotalFactura As Float, lnTotalCupones As Float, loItemValor as Object, loCupon as ent_cupon of ent_cupon.prg
		llRetorno = .f.
		if type( "this." + This.cValoresDetalle ) = "O"
			loCupon = _Screen.Zoo.InstanciarEntidad( "Cupon" )
			lcDetalle = this.cValoresDetalle
			loDetalle = this.&lcDetalle
			lnTotalCupones = 0
			for lnItem = 1 to loDetalle.Count
				if loDetalle.oItem.NroItem = lnItem
					loItem = loDetalle.oItem
				else
					loItem = loDetalle.Item[ lnItem ]
				endif
				if loDetalle.TieneCuponHuerfano( loItem ) and !loItem.escuponhuerfano && loItem.TieneCuponHuerfano()
					lnTotalCupones = lnTotalCupones + loItem.Monto
				endif
			endfor
			If lnTotalCupones != 0
				llRetorno = .t.
			endif
			loCupon.Release()
		EndIf

		Return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function Cancelar() as Void
		if this.ExistenCuponesHuerfanosNoNeteados()
			this.EventoCancelarYAdvertir( "No puede cancelar el comprobante si existen cupones integrados pendientes. Cancelelos." )
		else
			dodefault()
			if this.SoportaSenias()
				this.oCompSenias.RestaurarImpuestos()
			endif
		endif
		this.SetearControlDeStock(.t.)

		if type("this.oColaboradorRetiroDeEfectivo") = 'O' and this.oColaboradorRetiroDeEfectivo.lHayValoresDeRetiroDeEfectivo
			this.oColaboradorRetiroDeEfectivo.lHayValoresDeRetiroDeEfectivo = .f.
		endif

		if this.SoportaPromociones() and this.lAplicaPromocionesAutomaticas
			this.DesactivarAplicacionDePromocionesAutomaticas()
		endif
		this.EventoLimpiarTooltipCliente()
		if this.lEsComprobanteConEntregaPosterior
			this.EventoActualizarComboEntregaPosterior( .f. )
		endif
		this.EventoOcultarOMostrarVuelto()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoCancelarYAdvertir( tcMensaje as String ) as Void
		* Evento Bindeado en Kontroler
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function CargarCuponesHuerfanos( tnCaja as Integer ) as Void
		local loCupones as Object
		if this.lCuponesHuerfanosEnColeccion
		else 
			if this.oEntidadPos.ExistenPosIntegrados()
				this.oEntidadCuponesHuerfanos.InyectarEntidad( this )
				if type("tnCaja") = "N" and tnCaja > 0
					loCupones  = this.oEntidadCuponesHuerfanos.ObtenerCuponesHuerfanosPorCaja( tnCaja )
				else
					loCupones  = this.oEntidadCuponesHuerfanos.ObtenerCuponesHuerfanos()
				endif
				for each loItem in loCupones
					this.oColeccionCuponesHuerfanos.Agregar( loItem, loItem.Codigo )
				endfor 	
			endif 										
		endif	
		this.lCuponesHuerfanosEnColeccion = .t.
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ExistenCuponesHuerfanos() as Boolean 
		local llRetorno as Boolean 
		&& Este metodo se llama desde el refresco del formulario, muchas muchas veces, mantener eficiente.
		llRetorno = .f. 
		if this.lCuponesHuerfanosEnColeccion 
			lnCantidad = this.oColeccionCuponesHuerfanos.Count
			llRetorno = ( lnCantidad > 0 )
		else 
			if isnull( this.lExistenPosIntegrados ) 
				this.lExistenPosIntegrados = this.oEntidadPos.ExistenPosIntegrados()
			endif
			llRetorno = this.lExistenPosIntegrados
		endif 	

		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function oEntidadCuponesHuerfanos_Access() as Void
		if !this.lDestroy and !( vartype( this.oEntidadCuponesHuerfanos ) == "O" )
			this.oEntidadCuponesHuerfanos = _screen.Zoo.InstanciarEntidad( "CuponesHuerfanos" )
			this.BindearEvento( this, "Cancelar", this.oEntidadCuponesHuerfanos, "RestaurarCuponesIncluidos" )
			this.BindearEvento( this, "DespuesDeGrabar", this.oEntidadCuponesHuerfanos, "RemoverCuponesIncluidos" )
		endif
		return this.oEntidadCuponesHuerfanos
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerColeccionDeCuponesHuerfanos() as zoocoleccion OF zoocoleccion.prg
		return this.oColeccionCuponesHuerfanos
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AplicarCuponHuerfano( toItem as Object ) as Void
		local llValorOriginal as Boolean	
		with this.ValoresDetalle
			.AgregarCuponHuerfanoAColeccion( toItem )
			.LimpiarItem()
			with .oItem
				.EsCuponHuerfano = .t.
				llValorOriginal = .lEstaSeteandoValorSugerido
				.lEstaSeteandoValorSugerido = .t.
				.EsCuponHuerfano = .t.
				.Valor_PK = toItem.Valor
				.ValorDetalle = .AgregarTextoAdicionalADescripcionDelValorPorCuponIntegrado( .Valor.Descripcion )
				.Cupon_PK = toItem.Codigo
				.CodigoDeCupon = toItem.Codigo			
				.Fecha = ttod( toItem.fecha )
				.NumeroInterno = toItem.NumeroInterno
				.AutorizacionPOS = toItem.AutorizacionPOS
				.lEstaSeteandoValorSugerido = llValorOriginal
				.RecargoPorcentaje = toItem.Porcentaje
				.RecargoMonto = toItem.Recargo * this.SignoDeMovimiento
				.Recibido = ( toItem.Monto + .RecargoMonto )* this.SignoDeMovimiento
			endwith
			.Actualizar()			
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AvisarExistenciaDeCuponesHuerfanos() as Void
		local lcMensaje as String  
		if this.lYaSeLanzoAvisoDeCuponesHuerfanos
		else
			this.CargarCuponesHuerfanos()
			if this.HayCuponesHuerfanos()
				lcMensaje = this.ObtenerMensajeDeAvisoParaCuponesHuerfanos()			
				this.EventoMensajeDeCuponesHuerfanos( lcMensaje )
				this.lYaSeLanzoAvisoDeCuponesHuerfanos = .t.
			endif	
		endif 	
	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	function ObtenerMensajeDeAvisoParaCuponesHuerfanos( ) as String
		local lcRetorno as String
		lcRetorno = this.ObtenerTextoDetalladoDeCuponesHuerfanos()
		if empty( lcRetorno )	
		else 
			lcRetorno = alltrim( lcRetorno ) + " Puede realizar la aplicación desde el menú Acciones -> Aplicar cupones huérfanos."
		endif 	
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerTextoDetalladoDeCuponesHuerfanos() as String
		local lcRetorno as String, loCupon as zoocoleccion OF zoocoleccion.prg, loColHuerfanos as Object, lcSimbolo as String
		loColHuerfanos = this.ObtenerColeccionDeCuponesHuerfanos() 
		do case
			case loColHuerfanos.Count > 1
				lcRetorno = "Existen " + alltrim( transform( loColHuerfanos.Count ) ) + " cupones sin comprobante asociado."
			case loColHuerfanos.Count = 1	
				loCupon = loColHuerfanos.Item[ 1 ]
				with loCupon 
					lcSimbolo = alltrim( this.SimboloMonetarioComprobante )
					lcRetorno  = "Existe un cupón de [" + alltrim( transform( .Valor ) )  + "] " + This.ObtenerNombreDeValor( .Valor ) + " por un monto de " + lcSimbolo + alltrim( transform( .Monto ) )
					lcRetorno  = lcRetorno + " autorizado el " + alltrim( dtoc( .FechaCupon ) )
					lcRetorno  = lcRetorno + " a las " +  left( alltrim( .HoraCupon ), 2 ) + ":" +  right( alltrim( .HoraCupon), 2 )
					lcRetorno  = lcRetorno + " que no tiene un comprobante asociado."	
				endwith 
				loCupon = null 							
			otherwise
				lcRetorno = ""
		endcase
		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerNombreDeValor( tcCodigo as String ) as String
		local lcRetorno as String, loDetalle as Detalle of Detalle.prg  
		loDetalle = this.ObtenerDetalleDeValores()
		lcRetorno = loDetalle.ObtenerNombreDeValor( tcCodigo ) && this.&lcDetalle..ObtenerNombreDeValor( tcCodigo )
		return lcRetorno
	endfunc 
	
 	*-----------------------------------------------------------------------------------------
	function RetiraEfectivo() as Boolean
		local llRetorno as Boolean
		
		llRetorno = this.lRetiraEfectivo
		return llRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AceptaRetiroDeEfectivoEnCaja() as Boolean
		local llRetorno as Boolean, lcListaDeEntidades as String, lcCondicion as String
	
		lcListaDeEntidades = this.ListaDeEntidadesParaRetiroEnCaja()
		lcCondicion = "inlist( '" + this.cNombre + "', " + lcListaDeEntidades + " )"
		llRetorno = &lcCondicion
			
		return llRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ListaDeEntidadesParaRetiroEnCaja() as String
		return '"FACTURA", "TICKETFACTURA", "FACTURAELECTRONICA", "FACTURAAGRUPADA"'
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function HayCuponesHuerfanos() as Boolean 
		return this.oColeccionCuponesHuerfanos.Count > 0 
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function HayCuponesHuerfanosAplicados() as Boolean 
		return this.oCuponesHuerfanosAplicados.Count > 0 
	endfunc 	

	*-----------------------------------------------------------------------------------------
	function oColeccionCuponesHuerfanos_Access() as Void
		if !this.lDestroy and !( vartype( this.oColeccionCuponesHuerfanos ) == "O" )
			this.oColeccionCuponesHuerfanos = _screen.Zoo.CrearObjeto( "ZooColeccion" )
		endif
		return this.oColeccionCuponesHuerfanos
	endfunc	
	
	*-----------------------------------------------------------------------------------------
	function oColeccion_Access() as Void
		if !this.lDestroy and !( vartype( this.oColeccion ) == "O" )
			this.oColeccion = _Screen.Zoo.CrearObjeto( "ZooLogicSA.ValidarCombinacionesRepetidas.ColeccionesItems" )
		endif
		return this.oColeccion
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function oEntidadPos_Access() as Void
		if !this.lDestroy and !( vartype( this.oEntidadPos ) == "O" )
			this.oEntidadPos = _screen.Zoo.InstanciarEntidad( "POS" )
		endif
		return this.oEntidadPos
	endfunc	

	*-----------------------------------------------------------------------------------------
	function EliminarLosCuponesAplicadosEnOtroComprobante() as Void  
		local loInfoAplicados as zoocoleccion OF zoocoleccion.prg, lcMensaje as String 
		loInfoAplicados = this.oEntidadCuponesHuerfanos.ObtenerInformacionDeCuponesAplicados()

		if loInfoAplicados.Count > 1
			lcMensaje = "Se encuentran vinculados a otros comprobantes los siguientes cupones:" + NUEVALINEA 
			for each lcCupon in loInfoAplicados
				lcMensaje = lcMensaje + lcCupon + NUEVALINEA 
			endfor 	

			lcMensaje = lcMensaje + "No es posible vincularlos nuevamente. ¿Desea quitarlos del comprobante actual?"
		else 
			lcMensaje = "El cupón " + alltrim( loInfoAplicados.Item[ 1 ] )
			lcMensaje = lcMensaje + " ya fue vinculado a otro comprobante." + NUEVALINEA + "No es posible vincularlo nuevamente. ¿Desea quitarlo del comprobante actual?"
		endif 

		if this.oMensaje.Preguntar( lcMensaje, 4, 1, ""  ) = 6
			this.QuitarCuponesAfectados( )
			this.oInformacion.AgregarInformacion( "Se produjeron cambios en los valores del comprobante, verifique los mismos y reintente la operación." )
		else 
			this.oInformacion.AgregarInformacion( "No podrá continuar la operación hasta que quite del comprobante los cupones que ya fueron vinculados." )			
		endif 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function QuitarCuponesAfectados( toCupones as Object ) as Void
		local loCuponesARemover as Object, loItem as Object, lcDetalle as String, llValorOriginal as Boolean    

		loCuponesARemover = this.oEntidadCuponesHuerfanos.ObtenerColeccionDeAfectados()
		lcDetalle = This.cValoresDetalle
		loDet = this.&lcDetalle

		for each loItem in loDet 
			if loCuponesARemover.Buscar( loItem.Cupon_PK )
				with this.&lcDetalle.
					.CargarItem( loItem.NroItem )
					with .oItem
						this.QuitarCuponHuerfanoAplicado( .Cupon_PK ) 
						llValorOriginal = .lEstaSeteandoValorSugerido
						.lEstaSeteandoValorSugerido = .t.	
						.Valor_PK = ""
						.Cupon_PK = ""					
						.CodigoDeCupon = ""			
						.NumeroInterno = ""
						.oCompCajero.QuitarCuponHuerfanoAplicado( loItem.Cupon_PK )								
						.lEstaSeteandoValorSugerido = llValorOriginal 			
					endwith 
					.Actualizar()
				endwith
			endif 
		endfor  
	endfunc 	

	*-----------------------------------------------------------------------------------------
	function ObtenerCuponesHuerfanosAplicados() as zoocoleccion OF zoocoleccion.prg 
		return this.oCuponesHuerfanosAplicados 		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function QuitarCuponHuerfanoAplicado( tcItem as String ) as Void
		if this.oCuponesHuerfanosAplicados.Buscar( tcItem )
			this.oCuponesHuerfanosAplicados.Quitar( tcItem ) 
		endif 			
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function oCuponesHuerfanosAplicados_Access() as variant
		if !this.ldestroy and ( !vartype( this.oCuponesHuerfanosAplicados ) = 'O' or isnull( this.oCuponesHuerfanosAplicados ) )
			this.oCuponesHuerfanosAplicados = this.CrearObjeto( 'ZooColeccion' )
		endif
		return this.oCuponesHuerfanosAplicados
	endfunc		
	
	*-----------------------------------------------------------------------------------------
	function ApagarAvisoDeCuponesHuerfanos() as Void
		this.lYaSeLanzoAvisoDeCuponesHuerfanos = .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerUltimoItemDeGrillaDeValores() as Integer 
		local lnRetorno as Integer, loDetalle as Detalle of Detalle.prg
		lnRetorno = 0
		loDetalle = this.ObtenerDetalleDeValores()
		if type("loDetalle") = "O" and !isnull(loDetalle)
			lnRetorno = loDetalle.Count
		endif
		return lnRetorno
	endfunc 	

	*-----------------------------------------------------------------------------------------
	function DebePedirMotivoDevolucion( txVal as variant ) as Boolean
		local llRetorno as Boolean
		llRetorno = !empty( this.facturaDetalle.oItem.Articulo_pk )
		llRetorno = llRetorno and ( txVal * this.SignoDeMovimiento ) < 0 and empty( this.facturaDetalle.oItem.CodigoMotivoDevolucion_pk )
		llRetorno = llRetorno and !this.facturaDetalle.oItem.lCargandoPromo
		llRetorno = llRetorno and this.facturaDetalle.oItem.CargaManual()
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function DebeBlanquearMotivoDevolucion( txVal as variant ) as Boolean
		local llRetorno as Boolean
		llRetorno = ( txVal * this.SignoDeMovimiento )>= 0 and !empty( this.facturaDetalle.oItem.CodigoMotivoDevolucion_pk )
		llRetorno = llRetorno and this.facturaDetalle.oItem.CargaManual()
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function AgregarMotivoDevolucion( tcMotivoDevolucion as String, txVal as variant ) as Void
		this.facturaDetalle.oItem.CodigoMotivoDevolucion_pk = tcMotivoDevolucion
		if empty( tcMotivoDevolucion ) and ( txVal * this.SignoDeMovimiento ) < 0
			goServicios.Errores.LevantarExcepcionTexto( "No puede quedar en blanco el motivo de devolución." )
		endif
	endfunc
		
	*-----------------------------------------------------------------------------------------
	function DebePedirMotivoDescuentoEnLinea( txVal as variant ) as Boolean
		local llRetorno as Boolean
		llRetorno = !empty( this.facturaDetalle.oItem.Articulo_pk )
		llRetorno = llRetorno and txVal > 0 and empty( this.facturaDetalle.oItem.CodigoMotivoDescuento_pk )
		llRetorno = llRetorno and !this.facturaDetalle.oItem.lCargandoPromo
		llRetorno = llRetorno and this.facturaDetalle.oItem.CargaManual()
		return llRetorno
	endfunc	
		
	*-----------------------------------------------------------------------------------------
	function DebeBlanquearMotivoDescuentoEnLinea( txVal as variant, tcAtributo as string ) as Boolean
		local llRetorno as Boolean, lcAtributo as String
		lcAtributo = "this.facturaDetalle.oItem." + tcAtributo
		llRetorno = txVal <= 0 and &lcAtributo <= 0
		llRetorno = llRetorno and !empty( this.facturaDetalle.oItem.CodigoMotivoDescuento_pk )
		llRetorno = llRetorno and this.facturaDetalle.oItem.CargaManual()
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function AgregarMotivoDescuentoEnLinea( tcMotivoDescuentoLinea as String, txVal as variant ) as Void
		this.facturaDetalle.oItem.CodigoMotivoDescuento_pk = tcMotivoDescuentoLinea 
		if empty( tcMotivoDescuentoLinea ) and txVal > 0
			goServicios.Errores.LevantarExcepcion( "No puede quedar en blanco el motivo de descuento." )
		endif
	endfunc
				
	*-----------------------------------------------------------------------------------------
	function DebePedirMotivoDescuentoEnSubtotal( txVal as variant ) as Boolean
		local llRetorno as Boolean
		llRetorno = this.FacturaDetalle.CantidadDeItemsCargados() > 0
		llRetorno = llRetorno and txVal > 0 and empty( this.CodigoMotivoDescuentoEnSubtotal_pk )
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function DebeBlanquearMotivoDescuentoEnSubtotal( txVal as Variant, tcAtributo as string ) as Boolean
		local llRetorno as Boolean, lcAtributo as String
		lcAtributo = "this." + tcAtributo
		llRetorno = txVal <= 0 and !empty( this.CodigoMotivoDescuentoEnSubtotal_pk )
		llRetorno = llRetorno and &lcAtributo <= 0
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function AgregarMotivoDescuentoEnSubtotal( tcMotivoDescuentoSubtotal, txVal as variant ) as Void
		this.CodigoMotivoDescuentoEnSubtotal_pk  = tcMotivoDescuentoSubtotal		 
		if empty( tcMotivoDescuentoSubtotal ) and txVal > 0
			goServicios.Errores.LevantarExcepcionTexto( "No puede quedar en blanco el motivo de descuento." )
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerTooltipMotivoSegunAtributo( tcIdItemArt as String, tcAtributo as String ) as string
		local lnI as Integer, lcRetorno as String, lcMotivo as String, lcMensaje as String, llExisteMotivo as boolean
			
		lcRetorno = ""
			
		for lnI = 1 to this.FacturaDetalle.Count
			if this.FacturaDetalle.Item[lnI].IdItemArticulos == tcIdItemArt and !empty( this.FacturaDetalle.Item[lnI].&tcAtributo )
				lcRetorno = ""
				llExisteMotivo = .f.
				lcMensaje = "Motivo de " + iif( tcAtributo = "CodigoMotivoDescuento_pk", "descuento: ", "devolución: " )
				lcMotivo = this.FacturaDetalle.Item[lnI].&tcAtributo
				lcDescripcion = this.ObtenerDescripcionMotivo( lcMotivo, @llExisteMotivo )
				
				if llExisteMotivo
					lcRetorno = lcMensaje + this.ObtenerDescripcionMotivo( lcMotivo ) + " (" + alltrim( lcMotivo ) + ")."
				else
					lcRetorno = ""
				endif
				
				exit for
			Endif
		endfor		
		return lcRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerTooltipMotivoSubtotal() as string
		local lcRetorno as String, lcMotivo as String, lcDescripcion as string, llExisteMotivo as boolean
		
		llExisteMotivo = .f.
		lcMotivo = this.CodigoMotivoDescuentoEnSubtotal_pk
		lcDescripcion = this.ObtenerDescripcionMotivo( lcMotivo, @llExisteMotivo )
		
		if llExisteMotivo
			lcRetorno = "Motivo de descuento: " + lcDescripcion + " (" + alltrim( lcMotivo ) + ")."
		else
			lcRetorno = ""
		endif
		
		return lcRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerDescripcionMotivo( lcMotivo as String, tlExisteMotivo as boolean) as string
		local loEntidadMotivo as entidad of entidad.prg, lcDescripcion as string
		
		lcDescripcion = ""
 
		try
			loEntidadMotivo =_screen.Zoo.InstanciarEntidad( "MOTIVODESCUENTOYDEVOLUCION" )
			loEntidadMotivo.Codigo = lcMotivo
			lcDescripcion = alltrim( loEntidadMotivo.Descripcion )
			loEntidadMotivo.release()
			tlExisteMotivo = .t.
		catch
			tlExisteMotivo = .f.
		endtry

		return lcDescripcion
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerNombresValidadores() as zoocoleccion 
		local loNombreDeValidadores as zoocoleccion OF zoocoleccion.prg
		
		loNombreDeValidadores = dodefault()
		if this.ComprobanteFiscal
			loNombreDeValidadores.Add( "ValidadorComprobanteFiscal" )
		endif
		loNombreDeValidadores.Add( "ValidadorAceptacionDeValores" )

		return loNombreDeValidadores
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerCantidadDeValoresIngresados() as Integer
		local lnRetorno as Integer, loDetalle as Detalle of Detalle.prg
		lnRetorno = 0
		loDetalle = this.ObtenerDetalleDeValores()
		if type( "loDetalle" ) = "O" and !isnull( loDetalle )
			lnRetorno = loDetalle.CantidadDeTipoDeValoresCargados()
		endif
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarCuponesIntegradosAColeccionDeHuerfanos() as Void 
		local lnIndice as Integer, loDetalle as Object, loItem as Object 
		if this.EsNuevo() and this.oEntidadPos.ExistenPosIntegrados()
			loDetalle = This.cValoresDetalle
			for lnIndice = 1 to this.&loDetalle..count
				loItem = this.&loDetalle..Item(lnIndice)
				if inlist( loItem.Tipo, TIPOVALORTARJETA, TIPOVALORPAGOELECTRONICO ) and loItem.AutorizacionPOS and !this.oCuponesHuerfanosAplicados.Buscar( loItem.CodigoDeCupon )
					this.oCuponesHuerfanosAplicados.Agregar( loItem , loItem.CodigoDeCupon ) 
				endif 
			endfor
		endif 		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function oValidadorTarjeta_access() as Void
		if !this.lDestroy and !( vartype( this.oValidadorTarjeta ) == "O" )
			this.oValidadorTarjeta = _screen.zoo.crearobjeto( "ValidadorAceptacionDeValoresDetalle" )
		endif
		return this.oValidadorTarjeta
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarUtilizacionDeValor( toItem as object ) as Void

		if !empty( toItem.Valor_pk )
			this.oValidadorTarjeta.Inyectarentidad( This )
			this.oValidadorTarjeta.oItem = toItem

			
			if this.oValidadorTarjeta.Validar()
			else
				goServicios.Errores.LevantarExcepcion( This.oValidadorTarjeta.ObtenerInformacion() )
			endif
		endif
		
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerMontoRestante() as Float
		local loDetalle as Object, lnRetorno as Float 
		
		lnRetorno = 0
		if type( "this." + This.cValoresDetalle ) = "O"
			loDetalle = This.cValoresDetalle
			lnRetorno = this.&loDetalle..ObtenerMontoRestante()
		Endif		
		
		return lnRetorno 
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EventoAplicarCondicionDePago( tcAtributo as String, toItem as Object ) as Void
		if upper( tcAtributo ) == "VALOR_PK" and toItem.lAplicandoCondicionDePago and left( toItem.valor_pk, 1 ) = "$"
			this.AplicarCondicionDePago( toItem.cCodigoCondicionDePago )
			toItem.lAplicandoCondicionDePago = .f.
			toItem.cCodigoCondicionDePago = ""
		endif 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AplicarCondicionDePago( tcCondicion as String ) as Boolean
		local lcCodigoCondicionDePago as String, loColPagos as zoocoleccion OF zoocoleccion.prg, llRetorno as Boolean    
		llRetorno = .f.
  
        this.lseteandoCondicionDePago = .t.
    		if empty( tcCondicion )
    			lcCodigoCondicionDePago = this.ObtenerCondicionDePagoPreferente()
    		else
    			lcCodigoCondicionDePago = tcCondicion
    		endif 	
    		
    		if empty( lcCodigoCondicionDePago )
    		else
	    		try
	    			this.EventoComienzaAplicacionDeCondicionesDePago()
	    			loColPagos = this.oColaboradorCondicionDePago.ObtenerPlanDePagos( this.ObtenerMontoRestante(), this.Fecha, lcCodigoCondicionDePago )
	    			this.eventoLockear(.t.)
	    			this.AplicarColeccionDeCondicionesDePago( loColPagos )
	    			this.lDebeCalcularVuelto = .t.
	    			if this.lGrabandoRecibo
	    			else
	    				this.CalcularVuelto( "ValoresDetalle" )
	    			endif
	    			this.eventoLockear(.f.)		
	    			this.EventoFinalizaAplicacionDeCondicionesDePago()
	    			llRetorno = .t.
	    		catch to loError
	    			goServicios.Errores.LevantarExcepcion( loError )	    			
	    		finally
	    			this.eventoLockear(.f.)
	    		endtry	
    		endif
    		this.lseteandoCondicionDePago = .f.
		  return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EventoPreguntarSiRealizaRetiroEnEfectivo() as Void
		&&evento para el kontroler
	endfunc 

	
	*-----------------------------------------------------------------------------------------
	function EventoComienzaAplicacionDeCondicionesDePago() as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoFinalizaAplicacionDeCondicionesDePago() as Void
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	protected function TieneValoresCargados as Boolean
		local llRetorno as Boolean, loDetalle as Detalle of Detalle.prg
		llRetorno = .f.
		loDetalle = this.ObtenerDetalleDeValores()
		if type("loDetalle") = "O" and !isnull(loDetalle)
			llRetorno = loDetalle.Count > 0
		endif
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function SugerirCondicionDePagoPreferente() as Void
		local llValorOriginal as Boolean, lcCodigoCondicionDePago as String 

		lcCodigoCondicionDePago = this.ObtenerCondicionDePagoPreferente()
		
		if this.ValoresDetalle.CantidadDeItemsCargados() = 0 and !empty( lcCodigoCondicionDePago )
			lcCodigoCondicionDePago = this.ObtenerCondicionDePagoPreferente()
			this.lSeteandoCondicionDePagoPreferente = .t.
			with this.ValoresDetalle
				.LimpiarItem()
				with .oItem
					.lEstaSeteandoValorSugerido = .t.
					.lAplicandoCondicionDePago = .f.
					.Valor_PK = "$" + lcCodigoCondicionDePago 
					.lEstaSeteandoValorSugerido = .f.
				endwith 
			endwith 
			this.lSeteandoCondicionDePagoPreferente = .f.
		endif 	
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function AplicarColeccionDeCondicionesDePago( toColeccion as zoocoleccion OF zoocoleccion.prg ) as Boolean
		local llValorOriginal as Boolean, loItem as Object, ldFechaComp as Date, lnCant as Integer, lcValorOld as String, ;
			  llErrorPorRestriccionDescuentos as Boolean, lnMontoConvertido as float
		local lnRecibidoOriginal as float, lnRecibido as float, llTieneDescuento as Boolean, llTieneRecargo as Boolean, ;
				lnDifRecibido as float, lnDifRecibidoEnPesos as float, lnAux as float, lnMontoCotizado as float
		lnCant = 0
		lnUltimoMonto = 0
		lnClonado = 0
		lnUltimo = 0
		llTieneRecargo = .F.
		llTieneDescuento = .F.
		lnDifRecibido = 0
		lnDifRecibidoEnPesos = 0
		
		this.nItemCondicionDePago = 0
			with this.ValoresDetalle

				if .ValidarInsertarCondicionDePagoEnDetalle( toColeccion )
					ldFechaComp = .dFechaComprobante
					for each loItem in toColeccion as FoxObject			
						lnCant = lnCant + 1 
						this.nItemCondicionDePago = this.nItemCondicionDePago + 1
						llErrorPorRestriccionDescuentos = .f.
						if lnCant = toColeccion.Count
							.oItem.llUltimoItemDeLaCondicionDePago = .T.
						endif
                        if loItem.Descuento <> 0 or loItem.Recargo <> 0
                            if !this.ValidarRestriccionDeDescuentos( this.lseteandoCondiciondePago )
                                llErrorPorRestriccionDescuentos  = .t.
                                this.oMensaje.Advertir( This.ObtenerMensajeErrorPorRestriccionDeDescuentos() )
                                if this.oColaboradorCondicionDePago.oenTIDAD.tipoDEPAGOS = 1
                                    exit
                                endif    
                            endif
                        endif
						if !llErrorPorRestriccionDescuentos
							if loItem.lVaPorItemActivo or loItem.Monto != lnUltimoMonto or .oItem.llUltimoItemDeLaCondicionDePago
								this.EventoKeyCodeCondicionDePago()
								.LimpiarItem()
								llValorOriginal = .oItem.lEstaSeteandoValorSugerido
								.oItem.lEstaSeteandoValorSugerido = .t.
								.dFechaComprobante = ttod( loItem.Fecha )
								with .oItem
									.Valor_PK = loItem.CodigoValor 
									.Valor.Codigo = loItem.CodigoValor 
									.ValorDetalle = .Valor.Descripcion 
									.Tipo = .Valor.Tipo
									.Fecha = ttod( loItem.Fecha )
									.CondicionDePago_PK = loItem.CodigoCondicion
									.PermiteVuelto = .Valor.PermiteVuelto
									.VisualizarEnEstadoDeCaja = .Valor.VisualizarEnCaja

									lnMontoCotizado = .Valor.SimboloMonetario.ConvertirImporte( loItem.Monto, this.MonedaComprobante_pk, .Valor.SimboloMonetario_pk, loItem.Fecha ) 
									if loItem.Descuento > 0
										lnRecibidoOriginal = lnMontoCotizado - .ObtenerImporteRedondeado( lnMontoCotizado * (loItem.Descuento/100), "DESCUENTO" )
									 	.nDiferenciaRedondeo = lnRecibidoOriginal - lnMontoCotizado * (1-(loItem.Descuento/100))
									else
										lnRecibidoOriginal = lnMontoCotizado + .ObtenerImporteRedondeado( lnMontoCotizado * (loItem.Recargo/100), "RECARGO" )
									 	.nDiferenciaRedondeo = lnRecibidoOriginal - lnMontoCotizado * (1+(loItem.Recargo/100))
									endif
									lnRecibido = .ObtenerImporteRedondeado( lnRecibidoOriginal , "RECIBIDO" )
									if lnRecibido = 0 and lnRecibidoOriginal != 0 && Si al redondear queda en cero, no redondeo 
										lnRecibido = lnRecibidoOriginal
									endif
									* Funcionalidad 6962: Redondeo del recibido
									if alltrim( upper( this.cNombre ) ) != "RECIBO" and lnRecibido != lnRecibidoOriginal && Aplicó un redondeo
										* Pure Magic
										lnDifRecibido = round( lnRecibido - lnRecibidoOriginal, 4 )
										.DiferenciaPorRedondeoDelRecibido = lnDifRecibido
										.PorcentajeDiferenciaRedondeoRecibido = round( lnDifRecibido * 100 / lnMontoCotizado, 4 )
										if abs( .PorcentajeDiferenciaRedondeoRecibido ) < 0.01
											*.PorcentajeDiferenciaRedondeoRecibido = 0.01 * iif( .PorcentajeDiferenciaRedondeoRecibido < 0 , -1, 1 )
										endif
										if abs( .PorcentajeDiferenciaRedondeoRecibido ) > 99.99
											.PorcentajeDiferenciaRedondeoRecibido = 99.99 * iif( .PorcentajeDiferenciaRedondeoRecibido < 0 , -1, 1 )
										endif
										lnDifRecibidoEnPesos = .Valor.SimboloMonetario.ConvertirImporte( .DiferenciaPorRedondeoDelRecibido, .Valor.SimboloMonetario_pk, .oEntidad.MonedaComprobante_pk, .Fecha )
										llTengoRecargo = loItem.Recargo != 0
										llTengoDescuento = loItem.Descuento != 0
										if !llTengoDescuento and !llTengoRecargo
											if lnDifRecibido > 0
												llTengoRecargo = .T.
											else
												llTengoDescuento = .T.
											endif
										endif
										this.ValoresDetalle.SetearAtributosDeDescuentoYRecargo( llTengoRecargo, llTengoDescuento, lnDifRecibidoEnPesos )
									endif
									.DescuentoPorcentaje = loItem.Descuento
									.RecargoPorcentaje = loItem.Recargo
									if alltrim( upper( this.cNombre ) ) != "RECIBO" and lnRecibido != lnRecibidoOriginal && Aplicó un redondeo
										if llTengoDescuento
											lnAux = .DescuentoPorcentaje - .PorcentajeDiferenciaRedondeoRecibido
											.DescuentoPorcentaje = iif( abs( lnAux ) > 99.99, 99.99 * iif( .PorcentajeDiferenciaRedondeoRecibido < 0, -1, 1 ), lnAux )
										else
											lnAux = .RecargoPorcentaje + .PorcentajeDiferenciaRedondeoRecibido
											.RecargoPorcentaje = iif( abs( lnAux ) > 99.99, 99.99 * iif( .PorcentajeDiferenciaRedondeoRecibido < 0, -1, 1 ), lnAux )
										endif
									endif
									.Recibido = lnRecibido
									.MonedaAnterior = this.ValoresDetalle.cMonedaComprobante
									.nDescuentoPorcentajeDeLaCondicionDePago = loItem.Descuento
									.nRecargoPorcentajeDeLaCondicionDePago = loItem.Recargo
									
									.ProcesarDespuesDeSetearValor()
									*.DescuentoPorcentaje = .nDescuentoPorcentajeDeLaCondicionDePago + iif( .PorcentajeDiferenciaRedondeoRecibido < 0, .PorcentajeDiferenciaRedondeoRecibido, 0 )
									*.RecargoPorcentaje = .nRecargoPorcentajeDeLaCondicionDePago + iif( .PorcentajeDiferenciaRedondeoRecibido > 0, .PorcentajeDiferenciaRedondeoRecibido, 0 )
									.lEstaSeteandoValorSugerido = llValorOriginal
								endwith 
								.oItem.llPuedeEntrar = .T.	
								if empty( .oItem.RecargoPorcentaje )
									.oItem.CalcularRecargoItemActivo()
									.oItem.CalcularDescuentoItemActivo()
								else 
									.oItem.CalcularDescuentoItemActivo()	
									.oItem.CalcularRecargoItemActivo()					
								endif
								.Actualizar()
								lnUltimoMonto = loItem.Monto
								lnUltimo = .oItem.NroItem
							else
								lnClonado = lnClonado + 1
								loItemNuevo = this.ValoresDetalle.ClonarItemAuxiliar( lnUltimo )
								loItemNuevo.nroItem = this.ObtenerNroItemPrimerLugarDisponible( this.ValoresDetalle, lnUltimo + lnClonado )	
								loItemNuevo.idItemValores = goServicios.Librerias.ObtenerGuidPk()
								loItemNuevo.Fecha = ttod( loItem.Fecha )
								.AgregarItemPlano( loItemNuevo )
							endif
						endif
					endfor 	
				if lnClonado != 0 && Agregado para que actualice los sumarizados si "clonó" items
					.Sumarizar()
				endif
					.oItem.RefrescarTotalRecargoValores()
					this.Calculartotal()
					.oItem.llUltimoItemDeLaCondicionDePago = .F.
					.dFechaComprobante = ldFechaComp 
				endif
			endwith
	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	function oColaboradorCondicionDePago_Access() as Void
		if !this.lDestroy and !( vartype( this.oColaboradorCondicionDePago) == "O" )
			this.oColaboradorCondicionDePago= _screen.Zoo.CrearObjeto( "ColaboradorCondicionDePago" )
		endif
		return this.oColaboradorCondicionDePago
	endfunc	
	
	*-----------------------------------------------------------------------------------------
	function ObtenerCondicionDePagoPreferente() as String 
		local lcRetorno as String, loError as Object
		lcRetorno = ""
		try
			if type( "this.Cliente.CondicionDePago" ) = "O" and !empty( this.Cliente.CondicionDePago.Codigo )
				lcRetorno =  this.Cliente.CondicionDePago.Codigo
			endif 
		catch to loError
		endtry
		return lcRetorno 
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function DebePedirDatosAdicionalesComprobantesA() as Boolean
		local llHabilitar as Boolean
		llHabilitar = .F.
		if this.SoportaDatosAdicionalesA()
			llHabilitar = this.oCompDatosAdicionalesComprobantesA.DatosAdicionalesActivados()
		endif
		return llHabilitar
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerEntidadDatosAdicionalesComprobantesA() as Object
		local loDatosAdicionales as Object
		loDatosAdicionales = null
		if this.SoportaDatosAdicionalesA()
			loDatosAdicionales = this.oCompDatosAdicionalesComprobantesA.ObtenerEntidadDatosAdicionales()
		endif
		return loDatosAdicionales
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function oColaboradorSireWS_Access()as Object	
		if !this.lDestroy and vartype( this.oColaboradorSireWS ) # "O" Or Isnull(this.oColaboradorSireWS )
			this.oColaboradorSireWS = _Screen.zoo.crearobjeto( "ColaboradorSireWS", "ColaboradorSireWS.prg" )
		endif
		Return this.oColaboradorSireWS

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function DebePedirDatosAdicionalesSIRE() as Boolean
		local llHabilitar as Boolean
		llHabilitar = .F.

		if this.SoportaDatosAdicionalesSIRE()
			llHabilitar = this.oCompDatosAdicionalesSIRE.DatosAdicionalesSIREActivados()
		endif
		return llHabilitar
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function GenerarItemDeVueltoEnDetalleDeValores() as Boolean
		local loDetalle as Object, llValorOriginal  as Boolean, llRetorno as Boolean, loError as Object
		llRetorno = .t.
		
		if !empty( this.nVueltoCotizado ) and type( "this." + This.cValoresDetalle ) = "O" and this.ValidarVueltoSegunTipoValor()
			llRetorno = .f.
			try
				loDetalle = This.cValoresDetalle
				this.lTieneVuelto = .t.
				with this.&loDetalle
					.LimpiarItem()
					with .oItem
						this.lRecalcularVuelto = .f.
						.EsVuelto = .t.
						llValorOriginal = .lEstaSeteandoValorSugerido
						.Valor_PK = this.ObtenerCodigoValorVuelto() 
						.ValorDetalle = this.AgregarPrefijoDeVuelto( .Valor.Descripcion )
						.Tipo = .Valor.Tipo
						.Fecha = this.Fecha
						.Recibido = this.nVueltoCotizado * -1
						.Total = .Monto
						.MonedaAnterior = iif( empty( .Valor.SimboloMonetario_PK ), goParametros.Felino.Generales.MonedaSistema, .Valor.SimboloMonetario_PK )
						.lEstaSeteandoValorSugerido = llValorOriginal
					endwith 
					.Actualizar()
					this.nVueltoCotizado = 0
				endwith
				llRetorno = .t.	
			catch to loError
				for each loItem in loError.UserValue.oInformacion FOXOBJECT
					this.agregarInformacion( loItem.cMensaje )
				next
				this.agregarInformacion( "Error al generar vuelto." )
			finally 
				this.lRecalcularVuelto = .t.
			endtry
		endif
		*this.VueltoVirtual = 0
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarPrefijoDeVuelto( tcNombreValor as String ) as String
		local lcNombre as String 
		lcNombre = alltrim( left( tcNombreValor, len( tcNombreValor ) - 12 ) )
		return "VUELTO (" + lcNombre + ")"
	endfunc 

	*-----------------------------------------------------------------------------------------
	function RecalcularVuelto() as Void
		if this.lGrabandoRecibo
		else
			this.CalcularVuelto()
			this.CotizarVuelto()
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarTotalDeImpuestosInternos() as Boolean
		return this.Gravamenes >= 0
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarSiHayPorcentajesDeDescuentosEnValores() as Boolean
		local llRetorno as Boolean, lnI as Integer
		llRetorno = .f.
		for lnI = 1 to this.ValoresDetalle.Count
			llRetorno = llRetorno or iif( this.ValoresDetalle.Item(lnI).PorcentajeDesRec < 0, .t., .f. )
		endfor
		return llRetorno
	endfunc  

	*-----------------------------------------------------------------------------------------
	protected function TieneDescuentoRecargo( toItem as Object ) as Boolean
		local llRetorno as Boolean
		llRetorno = .f.
		if pemstatus( toItem, "DescuentoPorcentaje", 5 ) and pemstatus( toItem, "RecargoPorcentaje", 5 ) and ( toItem.DescuentoPorcentaje#0 or toItem.RecargoPorcentaje#0 )
			llRetorno = .t.
		endif
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerCodigoValorVuelto() as String
		local lcRetorno as String, llDebeValidarVueltoAnterior as Boolean
		
		llDebeValidarVueltoAnterior = this.lEdicion and this.cCodigoVueltoAnterior != goParametros.Felino.Sugerencias.CodigoDeValorSugeridoParaVuelto
		
		if goParametros.Felino.GestionDeVentas.UtilizarValorDelComprobanteParaDarVuelto or llDebeValidarVueltoAnterior 
			lcRetorno = this.VerificarValoresParaVuelto( llDebeValidarVueltoAnterior )
		else
			lcRetorno = goParametros.Felino.Sugerencias.CodigoDeValorSugeridoParaVuelto
		endif
		if empty( lcRetorno )
			goServicios.Errores.LevantarExcepcion( "Error con el código de valor asignado para el vuelto" )
		endif
		return lcRetorno 
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ReimprimirUnComprobanteFiscal() as Boolean
		local llRetorno as Boolean

		llRetorno = .t.
		if pemstatus( This, "oComponenteFiscal", 5 )
			llRetorno = This.oComponenteFiscal.ReimprimirUnComprobanteFiscal( this.ccomprobante, this.Letra, this.Numero )
		endif

		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ErrorAlGrabar() as Void
		dodefault() 
		this.QuitarItemVuelto()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ErrorAlValidar() as Void 
		dodefault() 
		this.QuitarItemVuelto()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function AumentarMontos( tnCantidad , tcdetalle ) as Void
	local loitem as Object, lnMontoOld as Number, lndescuento as number, lnrecargo as number, llCargando as Boolean, llAjusto as Boolean, lnItem as integer 
		llrecalcular = .t.
		llrecalcularMontoItemActivo = .t.
		llAjusto = .f.
		llrecalcular = this.total > this.valoresDetalle.sum_PesosAlCambio and !this.valoresDetalle.oitem.esVuelto

		if upper(tcdetalle) = "VALORESDETALLE"
			llrecalcularMontoItemActivo = .f.
			if empty( this.ValoresDetalle.oItem.Valor_pk ) and this.ValoresDetalle.oItem.nroItem > 0
				lnItem = this.ValoresDetalle.oItem.nroItem
				tncantidad = iif( this.ValoresDetalle.item[ lnItem ].Monto > 0, this.ValoresDetalle.item[ lnItem ].Monto , tnCantidad )
			endif
		endif	
		
		if llrecalcular
			for each loitem in this.valoresDetalle
				if tnCantidad > 0
					if loitem.nroitem = this.valoresDetalle.oitem.nroitem
						with this.valoresDetalle.oitem
							if .recibido > round( .total, 2 ) and llrecalcularMontoItemActivo and !empty( .Valor_pk )
								tncantidad = this.modificarValores( this.valoresDetalle.oItem, tnCantidad )
								llAjusto = .t. 	
							endif
						endwith
					else
						with loitem
							if .recibido > round( .total, 2 )
								tncantidad = this.modificarValores( loItem, tnCantidad ) 	
								llAjusto = .t.
							endif
						endwith
					endif
				endif
			endfor
									
			if !this.lProcesando and llAjusto
				llCargando = this.lcargando
				this.lcargando = .f.
				this.valoresdetalle.actualizar()
				this.LimpiarDescuentosYRecargosEnValores()
				this.CalcularTotal()
				this.VueltoVirtual = this.ObtenerVueltoVirtual( this.valoresDetalle ) && this.valoresDetalle.sum_recibidoAlCambio - this.total
				this.lcargando = llCargando 
			endif
			if this.ValoresDetalle.count > 0 
				this.eventoRefrescarGrillaDeValores()			
			endif
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function modificarValores( toitem, tncantidad ) as Void
	local lnrecargo as number, lndescuento  as number, lncotizacion as number, lnRecibido as float
		with toitem			
			ldFechaItem = toitem.fecha && - toitem.fechaultcotizacion???????
			lcMonedaComprobante = this.valoresdetalle.cmonedacomprobante 	 
			lcMonedaValor = this.ObtenerMonedaValor( .valor_pk )
			if lcMonedaComprobante != lcMonedaValor
				tncantidad = this.ValoresDetalle.oMoneda.ConvertirImporte( tncantidad, lcMonedaComprobante, lcMonedaValor, ldFechaItem )
			endif
			lnRecargo = 1 + ( .recargoporcentaje / 100 )
			lnDescuento = 1 - ( .descuentoporcentaje / 100 )
			if this.ValoresDetalle.sum_montoAlCambio - .montoAlCambio < 0
				lnMontoACancelar = (-1) * ( this.ValoresDetalle.sum_montoAlCambio - .montoAlCambio )
				lnRecibido = this.ValoresDetalle.oMoneda.ConvertirImporte( .recibido, lcMonedaValor, lcMonedaComprobante, ldFechaItem )
				if pemstatus( this, "subtotalConImp", 5 )
					lnMontoRestante = min( ( lnRecibido / ( lnRecargo ) - lnMontoACancelar ) / lndescuento, this.subtotalConImp )		
				else
					lnMontoRestante = ( lnRecibido / ( lnRecargo ) - lnMontoACancelar ) / lndescuento
				endif
				lnAuxi = goLibrerias.RedondearSegunMascara( lnMontoACancelar + lnMontoRestante )
				lnAuxi = this.ValoresDetalle.oMoneda.ConvertirImporte( lnAuxi, lcMonedaComprobante, lcMonedaValor, ldFechaItem )
			else				
				lnAuxi = this.ObtenerMontoDeItem( toitem, lnDescuento, lnRecargo, lcMonedaComprobante, lcMonedaValor, ldFechaItem )
			endif
			.monto = goLibrerias.RedondearSegunMascara( lnAuxi )
			this.CompletarDatosRecargosYDescuentos( toitem )			
			.montoAlCambio = this.ValoresDetalle.oMoneda.ConvertirImporte( .monto, lcMonedaValor, lcMonedaComprobante, ldFechaItem )
			lnTotalOld =  .total 
			.total = .monto + .montodesrec
			.pesosalcambio = this.ValoresDetalle.oMoneda.ConvertirImporte( .total, lcMonedaValor, lcMonedaComprobante, ldFechaItem )
			tncantidad = tncantidad + (lnTotalOld - .total) / lnrecargo / lndescuento			
			tncantidad = this.ValoresDetalle.oMoneda.ConvertirImporte( tncantidad, lcMonedaValor, lcMonedaComprobante, ldFechaItem )
			this.valoresdetalle.sumarizar()
			return tncantidad			
		endwith
	endfunc  
	
	*-----------------------------------------------------------------------------------------
	function RestarMontos( tncantidad, tcdetalle ) as Void
		local lndescuento as number, lnrecargo as number, lcItem as string, lncotizacion  as number, lnOld as number, llrecalcularMontoItemActivo as boolean, ;
		      llRecalcular as Boolean, llCargando as Boolean, llAjusto as Boolean, lnRecibido as float, lnMontoACancelar as float, lnMontoRestante as float
		      
		llrecalcularMontoItemActivo = .t.		
		llAjusto = .f.
		llRecalcular = .t.

		if upper(tcdetalle) = "VALORESDETALLE"
			llrecalcularMontoItemActivo = .f.
			llRecalcular = !this.valoresdetalle.oitem.lProcesandoDespuesDeSetearValor
		endif

		if this.DebeActualizarValores()
			for lnI = this.valoresdetalle.count to 1 step -1
				if this.valoresdetalle.item[ lni ].EsRetiroEfectivo and this.valoresdetalle.item[ lni ].monto = this.valoresdetalle.item[ lni ].Recibido
					loop
				endif
				
				if this.valoresdetalle.item[ lni ].nroitem = this.valoresdetalle.oitem.nroitem
					lcItem = "oitem"
				else
					lcItem = "item[ lni ]"				
				endif
				with this.valoresDetalle.&lcItem 
					if !empty(.valor_pk) and !empty(.monto) and llRecalcular
						ldFechaItem = .fecha
						lcMonedaComprobante = this.valoresDetalle.cMonedaComprobante	
						lcMonedaValor = this.ObtenerMonedaValor( .valor_pk )
						if lcMonedaValor != lcMonedaComprobante
							lnCotizacion = this.ValoresDetalle.oMoneda.obtenerCotizacion( ldFechaItem , lcMonedaValor, lcMonedaComprobante )
							if tnCantidad < 0.01 * lnCotizacion 
								tnCantidad = 0
							else
								tnCantidad = this.ValoresDetalle.oMoneda.ConvertirImporte( tnCantidad , lcMonedaComprobante, lcMonedaValor, ldFechaItem )
							endif
						endif
						if tncantidad > 0 and ( .nroitem != this.valoresdetalle.oitem.nroitem or llrecalcularMontoItemActivo ) and .monto > 0
							llAjusto = .t.
							if alltrim( upper( this.cNombre ) ) != "RECIBO" and .PorcentajeDiferenciaRedondeoRecibido != 0
								if .RecargoPorcentaje > 0
									.RecargoPorcentaje = .RecargoPorcentaje - .PorcentajeDiferenciaRedondeoRecibido
									.RecargoSinPercepciones = .RecargoSinPercepciones - this.ValoresDetalle.oItem.ObtenerMontoBaseRecargoFinanciero( .DiferenciaPorRedondeoDelRecibido )
									.RecargoMontoSinImpuestos = this.ValoresDetalle.oMoneda.ConvertirImporte( .RecargoSinPercepciones, lcMonedaValor, lcMonedaComprobante, ldFechaItem )
								else
									if .DescuentoPorcentaje > 0
										.DescuentoPorcentaje = .DescuentoPorcentaje - .PorcentajeDiferenciaRedondeoRecibido
									endif 
								endif
								.PorcentajeDesRec = .PorcentajeDesRec - .PorcentajeDiferenciaRedondeoRecibido
								.PorcentajeDiferenciaRedondeoRecibido = 0
								.DiferenciaPorRedondeoDelRecibido = 0
							endif
							lnrecargo = 1 + ( .recargoporcentaje / 100 )
							lndescuento = 1 - ( .descuentoporcentaje / 100 )
							lnOld = iif(.recargoporcentaje > 0, .monto, .total )
							if this.total = 0
								lnAuxi = 0
							else
								if this.ValoresDetalle.sum_montoAlCambio - .montoAlCambio < 0							
									lnMontoACancelar = (-1) * ( this.ValoresDetalle.sum_montoAlCambio - .montoAlCambio )
									lnRecibido = this.ValoresDetalle.oMoneda.ConvertirImporte( .recibido, lcMonedaValor, lcMonedaComprobante, ldFechaItem )
									lnMontoRestante = min( ( lnRecibido / ( 1 + lnRecargo ) - lnMontoACancelar ) / ( 1 - lndescuento ), this.subtotalConImp )		
									lnAuxi = goLibrerias.RedondearSegunMascara( lnMontoACancelar + lnMontoRestante )
									lnAuxi = this.ValoresDetalle.oMoneda.ConvertirImporte( lnAuxi, lcMonedaComprobante, lcMonedaValor, ldFechaItem )
								else	
									lnAuxi = this.ObtenerMontoDeItem( this.valoresDetalle.&lcItem, lnDescuento, lnRecargo, lcMonedaComprobante, lcMonedaValor, ldFechaItem )
									if .MontoAlCambio != this.ValoresDetalle.Sum_MontoAlCambio
										lnAuxi = max( 0, lnAuxi )
									endif
								endif
							endif
							.monto = lnAuxi
							.montoOri = .monto	
							this.CompletarDatosRecargosYDescuentos( this.valoresDetalle.&lcItem )
							.montoAlCambio = this.ValoresDetalle.oMoneda.ConvertirImporte( .monto, lcMonedaValor, lcMonedaComprobante, ldFechaItem )
							.total = golibrerias.redondearsegunmascara( .monto * lnrecargo * lndescuento )
							.pesosalcambio = this.ValoresDetalle.oMoneda.ConvertirImporte( .total, lcMonedaValor, lcMonedaComprobante, ldFechaItem )
							tncantidad = tncantidad - ( lnOld + iif(.recargoporcentaje > 0, .monto, .total ) ) / lndescuento
							tncantidad = this.ValoresDetalle.oMoneda.ConvertirImporte( tncantidad, lcMonedaValor, lcMonedaComprobante, ldFechaItem )																															
							this.valoresdetalle.sumarizar()
						endif
					endif
				endwith	
			endfor
			if !this.lProcesando and llAjusto 
				llCargando = this.lcargando
				this.lcargando = .f.
				this.valoresdetalle.actualizar()
				this.LimpiarDescuentosYRecargosEnValores()
				this.VueltoVirtual = this.ObtenerVueltoVirtual( this.valoresDetalle ) && this.valoresDetalle.sum_recibidoAlCambio - this.total
				this.lcargando = llCargando 
			endif
			if this.ValoresDetalle.count > 0 
				this.eventoRefrescarGrillaDeValores()			
			endif
		endif
	endfunc	
	
	*-----------------------------------------------------------------------------------------
	protected function DebeActualizarValores() as Boolean
		return this.total != this.valoresdetalle.sum_pesosalcambio
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function oColaboradorImpuestos_Access() as Void
		if !this.ldestroy and vartype( this.oColaboradorImpuestos ) != 'O'
			this.oColaboradorImpuestos = _Screen.Zoo.CrearObjeto( "ColaboradorImpuestos", "ColaboradorImpuestos.prg" )
		endif
		return this.oColaboradorImpuestos
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerMontoDeItem( toItem, tnDescuento, tnRecargo, tcMonedaComprobante, tcMonedaValor, tdFechaItem ) as Void
		local lnMontoDeItem as float, lnMontoRestante as float, lnAuxiliar as float, lnRecibido as float, lnPorcentajes as float
		local lnMontoPercepcionDescuentoFinanciero as float, lnMontoPercepcionRecargoFinanciero as float, llEsRetiroEnEfectivo as Boolean
		
		llEsRetiroEnEfectivo = iif( pemstatus( toItem, "EsRetiroEfectivo", 5 ) and toItem.EsRetiroEfectivo, .t., .f. )
		
		with toItem
			if type("toItem.nMontoPreEstimado") = 'N' and !llEsRetiroEnEfectivo 
				lnAuxiliar = .CalculoDeMonto( tnDescuento, tnRecargo )
			else
				lnRecibido = .Recibido 
				lnAuxiliar = goLibrerias.RedondearSegunMascara( lnRecibido / tnDescuento / tnRecargo )
			endif
						
			if this.Percepciones = 0
				lnMontoRestante = this.SubtotalConImp &&+ this.SumGravamenes &&* (1 + this.ValoresDetalle.oItem.CalcularCoeficienteDeImpuestos() ) + this.SumGravamenes
			else
				lnPorcentajes = this.oColaboradorImpuestos.ObtenerSumaDePorcentajesDeImpuestos( this )
				lnMontoPercepcionDescuentoFinanciero = this.MontoDescuentoSinImpuestos2 * lnPorcentajes 
				lnMontoPercepcionRecargoFinanciero = this.RecargoMontoSinImpuestos1 * lnPorcentajes 
				lnMontoRestante = this.SubtotalConImp + this.percepciones + lnMontoPercepcionDescuentoFinanciero - lnMontoPercepcionRecargoFinanciero && + this.gravamenes
			endif
			lnMontoRestante = goLibrerias.RedondearSegunMascara( lnMontoRestante ) - this.Valoresdetalle.sum_MontoAlCambio + .MontoAlCambio
			if tcMonedaComprobante != tcMonedaValor
				lnMontoRestante = this.MonedaComprobante.ConvertirImporte( lnMontoRestante, tcMonedaComprobante, tcMonedaValor, tdFechaItem )
			endif
			lnMontoDeItem = iif( llEsRetiroEnEfectivo, lnAuxiliar, min( lnAuxiliar, lnMontoRestante ))

		endwith
		return lnMontoDeItem
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerMonedaValor( lcValor ) as Void
		local lcRetorno as string 
		
		with this.oEntidadValor
			.codigo = lcValor 
			lcRetorno = .simboloMonetario_PK
		endwith
		return lcRetorno 
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function CompletarDatosRecargosYDescuentos( toItem ) As Void
		With toItem
			.MontoOri = .Monto
			If .RecargoPorcentaje > 0
				This.CalculosPreRecargos()
			Endif
			
			if alltrim( upper( this.cNombre ) ) != "RECIBO" and .PorcentajeDiferenciaRedondeoRecibido != 0 && ( .RecargoPorcentaje = 0.01 or .RecargoPorcentaje = 99.99 ) and
			* Aca ya esta calculado el recargomonto
			else
				.RecargoMonto = this.ObtenerImporteRedondeadoSegunValor( toItem.Valor_PK, ( .Monto * .RecargoPorcentaje ) / 100, "RECARGO" )
			endif
			.RecargoMontoEnPesos = This.ValoresDetalle.oMoneda.ConvertirImporte( .RecargoMonto, lcMonedaValor, lcMonedaComprobante, ldFechaItem )
			This.ValoresDetalle.EventoAntesDeAplicarRecargo()
			If .RecargoPorcentaje > 0
				.RecargoMontoSinImpuestos = This.ValoresDetalle.oItem.ObtenerMontoBaseRecargoFinanciero( .RecargoMontoEnPesos )
				.RecargoSinPercepciones = .RecargoMontoSinImpuestos
			Endif
			If This.ValoresDetalle.Sum_MontoAlCambio - Round( toItem.montoAlCambio, 2 ) < 0
				.DescuentoMonto = This.Redondear( This.ObtenerMontoParaDescuento( toItem ) * .DescuentoPorcentaje / 100, toItem.valor_pk )
			else
				.DescuentoMonto = this.ObtenerImporteRedondeadoSegunValor( toItem.Valor_PK, ( .Monto * .DescuentoPorcentaje ) / 100, "DESCUENTO" )
			Endif
			.DescuentoMontoEnPesos = This.ValoresDetalle.oMoneda.ConvertirImporte( .DescuentoMonto, lcMonedaValor, lcMonedaComprobante, ldFechaItem )
			.DescuentoMontoSinImpuestos = This.ValoresDetalle.oitem.ObtenerMontoBaseRecargoFinanciero( .DescuentoMontoEnPesos )
			.MontoDesRec = goLibrerias.RedondearSegunMascara( .RecargoMonto - .DescuentoMonto )
			.MontoDesRecPesos = This.ValoresDetalle.oMoneda.ConvertirImporte( .MontoDesRec, lcMonedaValor, lcMonedaComprobante, ldFechaItem )
		Endwith
	Endfunc
	
	*-----------------------------------------------------------------------------------------
	function Redondear( lnNum, tcValor ) as Void
		local lnRetorno as string 
		
		with this.oEntidadValor
			.codigo = tcValor 
			lnRetorno = .Redondeo.redondear( lnNum )
		endwith
		return lnRetorno	
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerImporteRedondeadoSegunValor( tcValor as String, tnImporte as float, tcAtributo as String ) as float
		local lnRetorno as float, lnModoRedondeo as Integer
		* tcAtributo : Es el atributo que está pidiendo que aplique redondeo. Se utiliza para evaluar, junto al modo de redondeo, si debe redondear.
		* ModoRedondeo = 0 ó 1 : Funciona como antes, aplica redondeo sobre recargo y descuento (Default)
		* ModoRedondeo = 2 : Aplica redondeo sobre el total (para nosotros es el "recibido" )
		lnRetorno = tnImporte
		with this.oEntidadValor
			.codigo = tcValor
			if !empty( .Redondeo_pk )
				lnModoRedondeo = iif( .ModoRedondeo = 0, 1, .ModoRedondeo )
				if lnModoRedondeo = 2
					if inlist( alltrim( upper( tcAtributo ) ), "RECIBIDO" ) and alltrim( upper( this.cNombre ) ) != "RECIBO"
						lnRetorno = .Redondeo.Redondear( tnImporte )
					else
						lnRetorno = round( tnImporte, PRECISIONMONTOS )
					endif
				else && default
					if inlist( alltrim( upper( tcAtributo ) ), "RECARGO", "DESCUENTO" )
						lnRetorno = .Redondeo.Redondear( tnImporte )
					else
						lnRetorno = round( tnImporte, PRECISIONMONTOS )
					endif
				endif
			endif
		endwith 
		return lnRetorno	
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerMontoParaDescuento( toItem ) as Void	
		local lnRetorno as float, lnDescuento as float, lnRecibido as float, ldFechaItem as date, lcMonedaComprobante as string, lcMonedaValor as String, ;
			  lnMontoACancelarParaPoderAplicarDescuentos as float, lnRecibido as float, lnRecibidoRestante as float, lnMontoMaximoParaDescuento as float
		lnDescuento = toitem.descuentoPorcentaje / 100
		if pemstatus( this, "SubTotalConImp", 5)
			lnMontoMaximoParaDescuento = this.SubTotalConImp
		else
			lnMontoMaximoParaDescuento = this.Total
		endif
		lnMontoACancelarParaPoderAplicarDescuentos = toItem.MontoAlCambio - this.ValoresDetalle.Sum_MontoAlCambio
		ldFechaItem = toItem.fecha
		lcMonedaComprobante = this.ValoresDetalle.cMonedaComprobante 	 
		lcMonedaValor = this.ObtenerMonedaValor( toItem.valor_pk )
		lnRecibido = this.ValoresDetalle.oMoneda.ConvertirImporte( toItem.Recibido, lcMonedaValor, lcMonedaComprobante, ldFechaItem )
		do case
			case lnRecibido <= lnMontoACancelarParaPoderAplicarDescuentos
				lnRetorno = 0
			case lnRecibido >= lnMontoACancelarParaPoderAplicarDescuentos + lnMontoMaximoParaDescuento * ( 1 - lnDescuento )
				lnRetorno = lnMontoMaximoParaDescuento 
			otherwise
				lnRetorno = ( lnRecibido - lnMontoACancelarParaPoderAplicarDescuentos ) / ( 1 - lnDescuento )
		endcase
		lnRetorno = this.ValoresDetalle.oMoneda.ConvertirImporte( lnRetorno ,lcMonedaComprobante, lcMonedaValor, ldFechaItem )
		return lnRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Setear_RecargoPorcentaje( txVal as variant ) as void
		this.lDebeCalcularVuelto = .t.
		with this
			if .CargaManual()
				if pemstatus( this, "lDebeCalcularVuelto", 5 )
					this.lDebeCalcularVuelto = .t.
				endif
			endif
			dodefault( txVal )
			if .CargaManual()
				if pemstatus( this, "lDebeCalcularVuelto", 5 )
					this.lDebeCalcularVuelto = .t.
					this.valoresdetalle.actualizar()
				endif
			endif
		endwith
		this.lDebeCalcularVuelto = .f.
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function RecalcularPorCambioDeListaDePrecios( txVal as Variant )
		dodefault( txVal )
		this.lDebeCalcularVuelto = .t.
		this.AplicarRecalculosGenerales()
		this.lDebeCalcularVuelto = .f.
	endfunc	 

	*-----------------------------------------------------------------------------------------	
	function Setear_RecargoMonto1( txVal as variant ) as Void 
		dodefault( txVal )
		this.RecargoMonto1Visual = golibrerias.redondearSegunMascara( txVal )
	endfunc
	
	*-----------------------------------------------------------------------------------------	
	function Setear_MontoDescuento2( txVal as variant ) as Void 
		dodefault( txVal )
		this.MontoDescuento2Visual = golibrerias.redondearSegunMascara( txVal )
	endfunc
		
	*-----------------------------------------------------------------------------------------
	function RemoverCuponesIncluidos() as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function SetearRecargoDeTarjeta() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function PuedeAplicarTaxFree() as Void
		local llRetorno as Boolean
		llRetorno = .t.
		with this
			if .total < .oComponenteFiscal.oComponenteImpuestos.oEntidadDatosFiscales.MontoMinimo
				.AgregarInformacion(" El total del comprobante debe ser superior a $" + ;
									alltrim( str( .oComponenteFiscal.oComponenteImpuestos.oEntidadDatosFiscales.MontoMinimo ) ) + ;
									" (monto mínimo configurado para facturas con reintegro de IVA - Tax Free)")
				llRetorno = .f.
			endif	
			with .Cliente
				if empty( .Calle ) or empty( .nroDocumento ) or .tipoDocumento != "06" or .situacionFiscal_pk != 3
					this.AgregarInformacion( "El cliente en una Factura Tax Free debe ser consumidor final, con pasaporte y domicilio" )
					llRetorno = .f.
				endif
			endwith
		endwith
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function TieneArticulosImportados() as Void
		local llRetorno as Boolean, lnI as Integer, loArticulo as Object   
		llRetorno = .f.
		lcTSQL_IN = this.FacturaDetalle.cStringFiltroArticulos
		if !empty( lcTSQL_IN )	
			&& Obtener el atributo ARTNODEVO de la tabla ART utilizando la sentencia IN como filtro.
			local lcCursor as string
			lcCursor = "c_ArticulosImportados" + sys( 2015 )
			goServicios.Datos.EjecutarSentencias( "select artcod from art where artcod in ("+lcTSQL_IN+") and importado = 1", "art", "", lcCursor, set("Datasession") )		
			select ( lcCursor )
			if reccount( lcCursor ) > 0
				llRetorno = .t.
			endif
			use in select ( lcCursor )
		endif
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EliminarArticulosNoImportados() as Void
		local lnI as Integer
		with this.FacturaDetalle
			.actualizar()
			for lnI = 1 to .count
				.cargarItem( lnI )
				if .oItem.articulo.importado
					.oItem.articulo_pk = ""
					.actualizar()
				endif
			endfor
		endwith
		this.EventoRefrescarGrillaArticulos()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarSiElComprobanteTieneTaxFree() as Void
		this.FacturaDetalle.oItem.lElComprobanteTieneTaxFree = !empty( this.ChequeReintegro )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EventoOcultarMonedaComprobante() as Void
	endfunc

	*-----------------------------------------------------------------------------------------
	function TieneDescuentoRecargoGeneral() as Boolean
		local llRetorno as Boolean
		llRetorno = .F.
		
		if This.Descuento != 0 or This.MontoDescuento3 != 0 or This.RecargoMonto != 0 or This.RecargoMonto2 != 0
			llRetorno = .T.
		endif
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	Protected Function ObtenerColeccionDetalleDeImpuestos() As Object
		Local loDetalle As zoocoleccion Of zoocoleccion.prg, lnTotDesRecFinancieros as float
		loDetalle = _Screen.zoo.crearobjeto( "ZooColeccion" )
		With loDetalle
			For Each loItem In This.ImpuestosDetalle
		 		if loItem.PorcentajeDeIVA == this.IvaDelSistema and loItem.MontoNoGravado == (This.nTotalRecargosFinancierosSinImpuestos - This.nTotalDescuentosFinancierosSinImpuestos) and (This.nTotalRecargosFinancierosSinImpuestos - This.nTotalDescuentosFinancierosSinImpuestos) != 0
		 			loop
		 		endif
	 			ItemDetalleImpuestos = _Screen.zoo.crearobjeto( "ItemDetalleImpuestos", "ent_comprobantedeventasconvalores.prg" )
	 			ItemDetalleImpuestos.Alicuota = loItem.PorcentajeDeIVA
	 			ItemDetalleImpuestos.Monto = loItem.MontoNoGravadoSinDescuento
	 			ItemDetalleImpuestos.BaseImponible = loItem.MontoNoGravado
	 			If ItemDetalleImpuestos.Alicuota == ( this.IvaDelSistema )
	 				if inlist( This.SituacionFiscal_pk, 4, 7, 12 ) && Exentos: Debo calcular el monto de recargo/descuento financiero multiplicando el monto sin impuestos x la tasa del iva del parametro (21%)
	 					lnTotDesRecFinancieros = ( - This.nTotalRecargosFinancierosSinImpuestos + This.nTotalDescuentosFinancierosSinImpuestos ) * ( 1 + ( this.IvaDelSistema / 100 ) )
	 				else
		 				lnTotDesRecFinancieros = - This.nTotalRecargosFinancierosConImpuestos + This.nTotalDescuentosFinancierosConImpuestos
	 				endif
					ItemDetalleImpuestos.AjusteSinImpuesto = loItem.MontoNoGravado - loItem.MontoNoGravadoSinDescuento - This.nTotalRecargosFinancierosSinImpuestos + This.nTotalDescuentosFinancierosSinImpuestos
	 				ItemDetalleImpuestos.AjusteConImpuesto = (loItem.MontoNoGravado + loItem.MontoDeIVA + loItem.MontoDeImpuestoInterno) - (loItem.MontoNoGravadoSinDescuento + loItem.MontoDeIVASinDescuento + loItem.MontoDeImpuestoInternoSinDescuento) + lnTotDesRecFinancieros
	 				Do Case
		 				Case (loItem.MontoNoGravado + ItemDetalleImpuestos.Descuento + This.nTotalDescuentosFinancierosSinImpuestos - This.nTotalRecargosFinancierosSinImpuestos) < loItem.MontoNoGravadoSinDescuento
		 					ItemDetalleImpuestos.Descuento = loItem.MontoNoGravadoSinDescuento - (loItem.MontoNoGravado + ItemDetalleImpuestos.Descuento + This.nTotalDescuentosFinancierosSinImpuestos - This.nTotalRecargosFinancierosSinImpuestos)
		 				Case (loItem.MontoNoGravado + ItemDetalleImpuestos.Descuento  + This.nTotalRecargosFinancierosSinImpuestos - This.nTotalDescuentosFinancierosSinImpuestos) < loItem.MontoNoGravadoSinDescuento
		 					ItemDetalleImpuestos.Recargo = loItem.MontoNoGravadoSinDescuento - (loItem.MontoNoGravado + ItemDetalleImpuestos.Recargo + This.nTotalRecargosFinancierosSinImpuestos) - This.nTotalDescuentosFinancierosSinImpuestos
	 				Endcase
	 			Else
	 				ItemDetalleImpuestos.AjusteSinImpuesto = loItem.MontoNoGravado - loItem.MontoNoGravadoSinDescuento
	 				ItemDetalleImpuestos.AjusteConImpuesto = (loItem.MontoNoGravado + loItem.MontoDeIVA + loItem.MontoDeImpuestoInterno) - (loItem.MontoNoGravadoSinDescuento + loItem.MontoDeIVASinDescuento + loItem.MontoDeImpuestoInternoSinDescuento)

	 				Do Case
		 				Case loItem.MontoNoGravado < loItem.MontoNoGravadoSinDescuento
		 					ItemDetalleImpuestos.Descuento = loItem.MontoNoGravadoSinDescuento - loItem.MontoNoGravado
		 				Case  loItem.MontoNoGravado > loItem.MontoNoGravadoSinDescuento
		 					ItemDetalleImpuestos.Recargo = loItem.MontoNoGravado - loItem.MontoNoGravadoSinDescuento
					Endcase
				Endif
				.Agregar( ItemDetalleImpuestos )

				ItemDetalleImpuestos = Null
			Endfor

		Endwith
		Return loDetalle
	Endfunc

	*-----------------------------------------------------------------------------------------
	function RecalcularDescuentosValores() as Void
		local lnSubTotalVisual as Float
		with this				
			************ Visual **************
			lnSubTotalVisual = iif( .oComponenteFiscal.MostrarImpuestos(), .subtotalConImp, .subtotalSinImp)
			.PorcentajeDescuento2 = iif( lnSubTotalVisual = 0, 0, .MontoDescuento2 * 100 / lnSubTotalVisual )
			************ CON IMPUESTOS **************
			if pemstatus( this, "ValoresDetalle", 5 )
				.MontoDescuentoConImpuestos2 = This.ValoresDetalle.Sum_DescuentoMontoEnPesos
			endif
			.nTotalDescuentosFinancierosConImpuestos = .MontoDescuentoConImpuestos2
			************ SIN IMPUESTOS **************
			if pemstatus( this, "ValoresDetalle", 5 )
				.MontoDescuentoSinImpuestos2 = This.ValoresDetalle.Sum_DescuentoMontoSinImpuestos
			endif
			.nTotalDescuentosFinancierosSinImpuestos = .MontoDescuentoSinImpuestos2
			************ TOTALIZADORES **************
			.TotalDescuentosConImpuestos = .MontoDescuentoConImpuestos + .MontoDescuentoConImpuestos1 + .MontoDescuentoConImpuestos2 + .MontoDescuentoConImpuestos3
			.TotalDescuentosSinImpuestos = .MontoDescuentoSinImpuestos + .MontoDescuentoSinImpuestos1 + .MontoDescuentoSinImpuestos2 + .MontoDescuentoSinImpuestos3
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function RecalcularRecargosValores() as Void
		local lnSubTotalVisual as Float
		with this 
			******* Visual **************
			lnSubTotalVisual = iif( .oComponenteFiscal.MostrarImpuestos(), .subtotalConImp - .MontoDescuentoConImpuestos2 , .subtotalSinImp - .MontoDescuentoSinImpuestos2 )
			.nPorcentajeRecargo1 = iif( lnSubTotalVisual = 0, 0, .RecargoMonto1 * 100 / lnSubTotalVisual )
			************ CON IMPUESTOS **************
			if pemstatus( this, "ValoresDetalle", 5 )
				.RecargoMontoConImpuestos1 = This.ValoresDetalle.Sum_RecargoMontoEnPesos
			endif
			.nTotalRecargosFinancierosConImpuestos = .RecargoMontoConImpuestos1
			************ SIN IMPUESTOS **************
			if pemstatus( this, "ValoresDetalle", 5 )
				.RecargoMontoSinImpuestos1 = This.ValoresDetalle.Sum_RecargoMontoSinImpuestos
			endif
			.nTotalRecargosFinancierosSinImpuestos = .RecargoMontoSinImpuestos1
			************ TOTALIZADORES **************
			.TotalRecargosConImpuestos	= .TotalRecargosConImpuestos + .RecargoMontoConImpuestos1 
			.TotalRecargosSinImpuestos	= .TotalRecargosSinImpuestos + .RecargoMontoSinImpuestos1
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function VerificarFechaDeCajas( tlAntesDeGrabar ) as Boolean
		local lnNumeroDeCaja as Integer, ldFechaApertura as date, llRetorno as Boolean, lcHoraActual as string, ldFechaActual as date, llNoValida as Boolean, llHaciendoNuevo as Boolean
		if upper( alltrim( this.cNombre ) ) = "COMPROBANTEDECAJA"
			llRetorno = .t.
		else
			llHaciendoNuevo = !tlAntesDeGrabar && uso el flag para saber si esta haciendo un nuevo
			loColeccionCajas = this.ObtenerColeccionCajas( llHaciendoNuevo ) 
			llRetorno = .t.
			ldFechaActual = golibrerias.Obtenerfecha()
			lnHorasTolerancia = goParametros.Felino.GestionDeVentas.HorasDeToleranciaParaFacturacionSegunFechaDeAperturaDeCaja
			for each loItem in loColeccionCajas		
				if this.oColEstadoDeCajas.Buscar( loItem.Caja ) and ldFechaActual = this.oColEstadoDeCajas.Item[loITem.Caja].fecha
				else
					llNoValida = this.ValidarFechaCaja( loItem.Caja, ldFechaActual, lnHorasTolerancia )
					if !llNoValida
						llRetorno = .f.
						if tlAntesDeGrabar
							this.AgregarInformacion( "Se debe cerrar la caja " + loItem.Caja + ". Hay valores ( " + loItem.Valores + " ) que hacen movimientos en esa caja " )
						endif
					endif		
				endif
			endfor
		endif
		if !llRetorno and tlAntesDeGrabar
			this.AgregarInformacion( "La fecha de apertura de la caja activa es distinta a la fecha actual.  Para poder hacer un comprobante debe realizar el cierre de la caja, para ello diríjase al menú 'Fondos -> Cerrar Caja Activa'" ) 
		endif
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarFechaCaja( tcCaja, tdFechaActual, tnHorasTolerancia ) as Void
		local lcXml as String, lcCursor as String, llRetorno as Boolean, ldFechaApertura as Date, lcFechaActual as Date, lnHorasTolerancia as Integer 
		llRetorno = .t.
		if goCaja.EstaAbierta( val( tcCaja ) )
			lcXml = goCaja.oCajaAuditoria.OAD.ObtenerDatosEntidad( "FECHA", "tarea = 'APERTURA' AND NUMCAJA = " + tcCaja, "fecha desc, hora desc","",1)
			lcCursor = "c_" + sys( 2015)
			this.XmlACursor( lcXml, lcCursor )
			select ( lcCursor )
			go top
			ldFechaApertura = ttod( fecha )
			use in select ( lcCursor )
			llRetorno = this.CompararFechaDeCaja( tdFechaActual, ldFechaApertura, tnHorasTolerancia )
			ldFechaItemCaja = ldFechaApertura 	
		else
			ldFechaItemCaja = tdFechaActual		
		endif
		this.AgregarItemEstadoCaja( tcCaja, llRetorno, ldFechaItemCaja )		
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function CompararFechaDeCaja( tdFechaActual, tdFechaApertura, tnHorasTolerancia ) as Void
		local llRetorno 
		do case 
			case tdFechaActual <= tdFechaApertura
				llRetorno = .t.
			case tdFechaActual - tdFechaApertura = 1
				if tnHorasTolerancia > val( left( goLibrerias.ObtenerHora(), 2 ) )
					llRetorno = .t.
				else
					llRetorno = .f.
				endif
			case tdFechaActual - tdFechaApertura > 1
				llRetorno = .f.
		endcase
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function AgregarItemEstadoCaja( tcCaja, tlEstado, tdFechaApertura ) as Void
		local loItemEstadoCaja as Object
		if this.oColEstadoDeCajas.Buscar( tcCaja )
			this.oColEstadoDeCajas.Item[tcCaja].Estado = tlEstado
			this.oColEstadoDeCajas.Item[tcCaja].Fecha = tdFechaApertura
		else
			loItemEstadoCaja = CreateObject( "Custom" )
			loItemEstadoCaja.AddProperty( "Caja", "" )
			loItemEstadoCaja.AddProperty( "Estado", .f. )
			loItemEstadoCaja.AddProperty( "Fecha", date() )
			loItemEstadoCaja.Caja = tcCaja
			loItemEstadoCaja.Estado = tlEstado
			loItemEstadoCaja.Fecha = tdFechaApertura
			this.oColEstadoDeCajas.Agregar( loItemEstadoCaja, tcCaja )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oColEstadoDeCajas_access() as Void
		if !this.lDestroy and !( vartype( this.oColEstadoDeCajas ) == "O" )
			this.oColEstadoDeCajas = _screen.zoo.CrearObjeto( "ZooColeccion" )
		endif
		return this.oColEstadoDeCajas
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerColeccionCajas( tlHaciendoNuevo ) as Void
		local loColeccion as Object
		loColeccion = _screen.zoo.CrearObjeto( "ZooColeccion" )
		if tlHaciendoNuevo 
			this.AgregarCajaACtiva( @loColeccion )
		else
			this.ObtenerCajasUtilizadas( "Recibido", this.cValoresDetalle, @loColeccion )
		endif
		return loColeccion
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function AgregarCajaACtiva( toColeccion ) as Void
		local lcCajaActiva as String
		lcCajaActiva = alltrim( str( goParametros.Felino.GestionDeVentas.NumeroDeCaja ) )
		loItemCaja = CreateObject( "Custom" )
		loItemCaja.AddProperty( "Caja", "" )
		loItemCaja.AddProperty( "Valores", "" )
		loItemCaja.Caja = lcCajaActiva
		loItemCaja.Valores = ""
		toColeccion.Agregar( loItemCaja, lcCajaActiva )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerCajasUtilizadas( lcAtributo, lcDetalle, toColeccion ) as Void
		local loDetalle as Object, loItemValor as Object
		loDetalle = this.&lcDetalle
		for each loItemValor in loDetalle 
			if !empty( loItemValor.Valor_pk ) and loItemValor.&lcAtributo != 0
				lcCaja = alltrim( str( loItemValor.Caja_pk ) )
				lcValor = alltrim( loItemValor.Valor_pk )
				if !toColeccion.Buscar( lcCaja )
					loItemCaja = CreateObject( "Custom" )
					loItemCaja.AddProperty( "Caja", "" )
					loItemCaja.AddProperty( "Valores", "" )
					loItemCaja.Caja = lcCaja
					loItemCaja.Valores = '"' + lcValor + '"'
					toColeccion.Agregar( loItemCaja, lcCaja )
				else
					if '"' + lcValor + '"' $ toColeccion( lcCaja ).Valores
					else
						toColeccion( lcCaja ).Valores = toColeccion( lcCaja ).Valores + ", " + '"' + lcValor + '"'
					endif
				endif
			endif			
		endfor
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function PuedeHacerNuevo() as Void
		local llRetorno as Boolean, lnHorasTolerancia as integer, lcCaja as String, ldFechaActual as Date
		llRetorno = .t.
		if upper( alltrim( this.cNombre ) ) != "COMPROBANTEDECAJA"
			if goParametros.Felino.GestionDeVentas.NoPermitirFacturarConFechaDistintaALaDeLaCajaAbierta
				llRetorno = this.VerificarFechaDeCajas( .f. )
			endif
		endif
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerNroItemPrimerLugarDisponible( toDetalle as Object, tnInicioBusqueda as Integer ) as Integer
		local lnRetorno as Integer, lnI as Integer
		
		lnRetorno = toDetalle.Count + 1
		if tnInicioBusqueda < toDetalle.Count
			with toDetalle
				for lnI = tnInicioBusqueda to .Count
					if !.ValidarExistenciaCamposFijosItemPlano( lnI )
						lnRetorno = lnI
						exit
					endif
				endfor
			endwith
		endif
		
		return lnRetorno 
	endfunc

	*-----------------------------------------------------------------------------------------
	function NuevoEnBaseAFactura( toFactura ) as Void
		local loEntidadAfectada as Object, loResultado as Object, loSeleccionado as Object, loItem as Object
		With this
		    .oCompEnBaseA.lAccionCancelatoria = .t.
			.oCompEnBaseA.nSigno = 1
		    .oCompEnBaseA.InyectarConsulta()
		endwith
	endfunc 	
		
	*-----------------------------------------------------------------------------------------
	function HacerNCCanceltatoria() as Void
		with this
			.oCompEnBaseA.SetearCodigoDeComprobanteNCCancelatoria()
			.oFacturaACancelar = .oCompEnBaseA.oEntidadAfectada
			.PrepararEntornoAccionCancelatoria( .oCompEnBaseA.oEntidadAfectada )
			.oCompEnBaseA.lAccionCancelatoria = .t.
			.AccionCancelatoria = .t.
			.lHaciendoNuevaAccionCancelatoria = .t.
			.Nuevo()
			.AccionCancelatoria = .t.
			this.IvaDelSistema = .oFacturaACancelar.IvaDelSistema
			.lHaciendoNuevaAccionCancelatoria = .f.
			.NuevoEnBaseAFactura( .oCompEnBaseA.oEntidadAfectada )	
			if this.IvaDelSistema != goParametros.Felino.DatosImpositivos.IvaInscriptos and this.TienePercepcionDeIva()
				this.lPermiteAgregarArticulos = .f.
				this.FacturaDetalle.oItem.lPermiteAgregarArticulos = .f.
			endif	
			.DeshabilitarCamposAccionCancelatoria()
		endwith	
	endfunc 
	
	*-----------------------------------------------------------------------------------------	
	function TienePercepcionDeIva() as Boolean
		local loItemImpuesto as Object, llRetorno as Boolean
		for each loItemImpuesto in this.ImpuestosComprobante
			if loItemImpuesto.TipoImpuesto = "IVA"
				llRetorno = .t.
				exit
			endif
		endfor
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function CargarDetalleImpuestosDesdeFactura() as Void
		this.oComponenteFiscal.oComponenteImpuestos.CargarDetalleImpuestosDesdeFactura( this.oFacturaACancelar )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function DeshabilitarCamposAccionCancelatoria() as Void
		with this
			if !empty( .Cliente_pk )
				.lHabilitarCliente_pk = .f.
			endif
		endwith			
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function PrepararEntornoAccionCancelatoria( toEntidadACancelar ) as Void
		with this
			if empty( toEntidadACancelar.IvaDelSistema )
				.IvaDelSistema = goParametros.Felino.DatosImpositivos.IvaInscriptos && 21 && se asume que todas las factura que se hicieron antes de este cambio tenian IVA 21% - Funcionalidad: 5486
				toEntidadACancelar.IvaDelSistema = .IvaDelSistema && 21
			else
				.IvaDelSistema = toEntidadACancelar.IvaDelSistema 
			endif
			
			this.SetearAccionCancelatoria( .t. )
			this.SetearIvaDelSistema( toEntidadACancelar.IvaDelSistema )
			
			.oComponenteFiscal.nMontoImpuestosInternos = toEntidadACancelar.Gravamenes && se usa para determinar si calcula impuestos internos - componente fiscal - CalculaImpuestosInternos()
			*.oComponenteFiscal.oComponenteImpuestos.lTienePercepcionGanancias = toEntidadFactura.TienePercepcionGanancias() 
			.FacturaDetalle.oItem.lAccionCancelatoria = .t.
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function SetearAccionCancelatoria( tlValor ) as Void
		with this
			.oComponenteFiscal.lAccionCancelatoria = tlValor
			if type( "this.oComponenteFiscal.oComponenteImpuestos" ) = "O"
				.oComponenteFiscal.oComponenteImpuestos.lAccionCancelatoria = tlValor
			endif
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearIvaDelSistema( tnIva ) as Void
		with this
			.ImpuestosDetalle.nIvaDelSistema = tnIva
			.oComponenteFiscal.nIvainscriptos = tnIva
			if type( "this.oComponenteFiscal.oComponenteImpuestos" ) = "O"
				.oComponenteFiscal.oComponenteImpuestos.nIvainscriptos = tnIva
				.oComponenteFiscal.oComponenteImpuestos.oColaboradorPercepciones.nIvainscriptos = tnIva
			endif
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function DebeHacerNCCancelatoria() as Boolean
		local llRetorno as Boolean
		llRetorno = this.EsNotaDeCredito() and this.oCompEnBaseA.nCantidadComprobantesDelEnBaseA == 1
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function LimpiarDescuentosYRecargosEnValores() as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function VerificarValoresParaVuelto( tlValidarVueltoAnterior as Boolean ) as String
		local lcRetorno as String, loItem as Object
		lcRetorno = goParametros.Felino.Sugerencias.CodigoDeValorSugeridoParaVuelto
		
		if pemstatus( this, "ValoresDetalle", 5 ) 
			if  this.ValoresDetalle.Sum_AplicableParaVuelto = 1
				for each loItem in this.ValoresDetalle
					if loItem.AplicableParaVuelto = 1 and loItem.Descuento = 0
						lcRetorno = oItem.Valor_PK
						exit
					endif
				endfor
			endif
		endif
		
		if !goParametros.Felino.GestionDeVentas.UtilizarValorDelComprobanteParaDarVuelto and tlValidarVueltoAnterior 
			if alltrim( lcRetorno ) = alltrim( this.cCodigoVueltoAnterior )
				lcRetorno = this.cCodigoVueltoAnterior
			else
				lcRetorno = goParametros.Felino.Sugerencias.CodigoDeValorSugeridoParaVuelto
			endif
		endif

		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerVueltoAnterior() as String
		local lcRetorno as String, lcCursorVuelto as String
		
		lcRetorno = ""
		lcCursorVuelto = sys(2015)
	
		if used( "c_ValoresDetalle" )
			select Valor from c_ValoresDetalle where EsVuelto into cursor &lcCursorVuelto
		endif
		if used( lcCursorVuelto ) and reccount( lcCursorVuelto ) > 0
			lcRetorno = &lcCursorVuelto..Valor
		endif
		use in select( lcCursorVuelto )
		
		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function CargarValoresAplicablesParaVuelto() as Void

		this.lEstaCargandoValoresAplicablesParaVuelto = .T.
 	
 		for ind = 1 to this.ValoresDetalle.Count
			this.ValoresDetalle.CargarItem( ind )
			this.ValoresDetalle.oItem.VerificarValorAplicableParaVuelto()
			this.ValoresDetalle.Actualizar()
		endfor
		
		this.lEstaCargandoValoresAplicablesParaVuelto = .F.
	endfunc 

 	*-----------------------------------------------------------------------------------------
	function ObtenerCaracteristicasControladorFiscal() as boolean
		local llRetorno as Boolean
		
		llRetorno = this.VerificarCaracteristicasControladorFiscal()
		
		return llRetorno		
	endfunc 

	*-----------------------------------------------------------------------------------------
	Protected Function oColaboradorPromocion_Access() as Void
		If !this.lDestroy And (!( vartype( this.oColaboradorPromocion ) == "O" ) Or Isnull(this.oColaboradorPromocion))
			this.oColaboradorPromocion = _screen.Zoo.CrearObjetoPorProducto( "ColaboradorPromociones", "ColaboradorPromociones.prg" )
			If this.oColaboradorPromocion.ImplementaPromociones()
				this.oColaboradorPromocion.InicializarColaborador()
			Endif
		Endif
		Return this.oColaboradorPromocion
	Endfunc
	
	*-----------------------------------------------------------------------------------------
	Protected Function oColaboradorPromocionPorMedioDePago_Access() as Void
		If !this.lDestroy And (!( vartype( this.oColaboradorPromocionPorMedioDePago ) == "O" ) Or Isnull(this.oColaboradorPromocionPorMedioDePago))
			this.oColaboradorPromocionPorMedioDePago= _screen.Zoo.CrearObjetoPorProducto( "ColaboradorpromocionesPorMedioDePago", "ColaboradorpromocionesPorMedioDePago.prg" )
			If this.oColaboradorPromocionPorMedioDePago.ImplementaPromociones()
				this.oColaboradorPromocionPorMedioDePago.InicializarColaborador()
			Endif
		Endif
		Return this.oColaboradorPromocionPorMedioDePago
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ObtenerColaboradorPromociones() as Object
		Local loColaborador as Object
		loColaborador = null
		loColaborador = this.oColaboradorPromocion
		Return loColaborador
	Endfunc
	
	*-----------------------------------------------------------------------------------------
	Function ObtenerColaboradorPromocionesPorMedioDePago() as Object
		Local loColaborador as Object
		loColaborador = null
		loColaborador = this.oColaboradorPromocionPorMedioDePago
		Return loColaborador
	Endfunc
	
	*-----------------------------------------------------------------------------------------
	Function ExcluyeIdValoresEnItemPromociones( tcIdItem as String ) as Boolean
		Local lnI as Integer, llRetorno as Boolean
		llRetorno = .F.
		For lnI = 1 to This.ValoresDetalle.Count

			If (this.ValoresDetalle.Item[lnI].IdItemValores = tcIdItem And This.ValoresDetalle.Item[lnI].Tipo =TIPOVALORTARJETA And vartype(This.ValoresDetalle.Item[lnI].Cupon ) = "O" and This.ValoresDetalle.Item[lnI].Cupon.EstaAnulado())
				llRetorno = .T.
				Exit For
			Endif
		Endfor
		Return llRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	function Setear_PorcentajeDescuento( txPorcentajeDescuento as variant ) as Void
		with this
			if .CargaManual()
				if pemstatus( this, "lDebeCalcularVuelto", 5 )
					this.lDebeCalcularVuelto = .t.
				endif
				dodefault( txPorcentajeDescuento )
				if pemstatus( this, "lDebeCalcularVuelto", 5 )
					this.lDebeCalcularVuelto = .t.
					this.valoresdetalle.actualizar()
				endif
				This.DescuentoAutomatico = .F.
			endif
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Setear_MontoDescuento3( txVal as variant ) as void

		if this.lCambioMontoDescuentoGeneral
			this.QuitarImpuestosMontoDescuento3()
		endif

		with this
			if .CargaManual()
				if pemstatus( this, "lDebeCalcularVuelto", 5 )
					this.lDebeCalcularVuelto = .t.
				endif
				dodefault( txVal )
				if pemstatus( this, "lDebeCalcularVuelto", 5 )
					this.lDebeCalcularVuelto = .t.
					this.valoresdetalle.actualizar()
				endif

				if this.HayAjusteDescuento()
					this.oColaboradorAjusteDeComprobante.QuitarCodigoAjuste()
				endif
				This.DescuentoAutomatico = .F.
			endif
		endwith
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function QuitarImpuestosMontoDescuento3() as Void

		if this.DebeQuitarImpuestosAlDescuento() and this.SubTotalBruto <> 0
			this.GuardarMontoDescuento3Original( this.MontoDescuento3 )
			this.MontoDescuento3 =  this.ObtenerMontoDescuento3_DesdeMontoConImpuestos( this.MontoDescuento3 )
			this.lCambioMontoDescuentoGeneral = .F.
		endif
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Setear_RecargoMonto2( txVal as variant ) as Void 
		if this.lCambioMontoRecargoGeneral
			this.QuitarImpuestosMontoRecargo2()
		endif

		with this
			if .CargaManual()
				if pemstatus( this, "lDebeCalcularVuelto", 5 )
					this.lDebeCalcularVuelto = .t.
				endif
				dodefault( txVal )
				if pemstatus( this, "lDebeCalcularVuelto", 5 )
					this.lDebeCalcularVuelto = .t.
					this.valoresdetalle.actualizar()
				endif
				if this.HayAjusteRecargo()
					this.oColaboradorAjusteDeComprobante.QuitarCodigoAjuste()
				endif
			endif
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function QuitarImpuestosMontoRecargo2() as Void

		if this.DebeQuitarImpuestosAlDescuento() and this.SubTotalBruto <> 0
			this.GuardarMontoRecargo2Original( this.RecargoMonto2)
			this.RecargoMonto2 =  this.ObtenerRecargoMonto2_DesdeMontoConImpuestos( this.RecargoMonto2 )
			this.lCambioMontoRecargoGeneral = .F.
		endif
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GuardarMontoRecargo2Original( txValor as variant ) as void
		this.nMontoDeRecargo2IngresadoManualmente = txValor
	endfunc 

	*-----------------------------------------------------------------------------------------
	Protected Function AplicarDescuentoFinanciero() as Void
		if pemstatus( this, "ValoresDetalle", 5 )
			.oComponenteFiscal.AplicarDescuentoFinanciero( .ValoresDetalle.Sum_DescuentoMontoSinImpuestos, .ImpuestosDetalle )
		endif
	EndFunc 

	*-----------------------------------------------------------------------------------------
	Protected Function AplicarRecargoFinanciero() as Void
		if pemstatus( this, "ValoresDetalle", 5 )
			.oComponenteFiscal.AplicarRecargoFinanciero( .ValoresDetalle.Sum_RecargoMontoSinImpuestos, .ImpuestosDetalle )
		endif
	EndFunc 

	*-----------------------------------------------------------------------------------------
	protected function LlenarColeccionDeImpuestos() as Void
		with This
			if type( "this.ValoresDetalle" ) = "O"
				if pemstatus( this, "ValoresDetalle", 5 )
					.ImpuestosDetalle.nMontoBaseDescuentoFinanciero = .ValoresDetalle.Sum_DescuentoMontoSinImpuestos
				endif
				if pemstatus( this, "ValoresDetalle", 5 )
					.ImpuestosDetalle.nMontoBaseRecargoFinanciero = .ValoresDetalle.Sum_RecargoMontoSinImpuestos
				endif
			Endif
		endwith
		Dodefault()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarRecargo( tnValor as Long ) as Void

		this.ValoresDetalle.nTotalComprobante = 0.01
		Dodefault( tnValor )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EvaluarSiAplicaPromocionesAutomaticas( tdFecha as Date ) as Void 
		if !this.lAplicarPromosAutomaticasAlSalirDelDetalle and this.oColaboradorPromocion.HayPromocionesAutomaticasVigentes( tdFecha ) and ( this.EsNuevo() or this.EsEdicion() )
			this.HabilitarAplicacionAutomaticaDePromociones()
		else
			if vartype( this.oManagerPromociones.oManagerAutomatico ) = "O"
				this.DesactivarAplicacionDePromocionesAutomaticas()
			endif
		endif

	endfunc	

	*-----------------------------------------------------------------------------------------
	function HabilitarAplicacionAutomaticaDePromociones() as void
		
		this.lAplicaPromocionesAutomaticas = .T.
		
		if !vartype( this.oManagerPromociones.oManagerAutomatico ) = "O"
			this.oManagerPromociones.InstanciarEInyectarManagerAutomatico()
		else
			this.oManagerPromociones.oManagerAutomatico.lAplicaPromocionesAutomaticas = .T.
		endif
		
		this.oManagerPromociones.HabilitarSerializacionPorHilos()
		this.oManagerPromociones.CargarPromociones( this.Fecha )
		bindevent( this, "Grabar", this, "EnviarASerializarSiEstaEnoItem" )
	
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EnviarASerializarSiEstaEnoItem() as Void
		if !empty( this.FacturaDetalle.oItem.Articulo_PK )
			this.EnviarASerializar()
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EvaluarSiSeAgregoUnItem() as Void
		if !empty( this.FacturaDetalle.oItem.Articulo_PK )
			this.ReactivarAplicacionAutomaticaDePromosSiEstaApagada()
		endif		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ReactivarAplicacionAutomaticaDePromosSiEstaApagada( txVal as Variant ) as Void 
		this.oManagerPromociones.oManagerAutomatico.lAplicaPromocionesAutomaticas = .T.
		this.DesactivarVerificacionDeCambiosEnItems()			
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function GuardarItemOriginal() as Void
		local lnItem as integer

		if this.FacturaDetalle.ValidarItem()
			this.oItemArticuloOriginal = this.FacturaDetalle.CrearItemAuxiliar()
			lnItem = this.FacturaDetalle.oItem.NroItem			
			this.FacturaDetalle.CopiarItemAItem( this.FacturaDetalle.Item[ lnItem ], this.oItemArticuloOriginal )
		endif		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EvaluarSiHuboCambiosEnItem() as Void
		local lnItem as Integer, loItemPosterior as Object, llSeModifico as boolean

		lnItem = this.FacturaDetalle.oItem.NroItem
		loItemPosterior = this.FacturaDetalle.Item[ lnItem ]
		llSeModifico = .F.
		
		if vartype( this.oItemArticuloOriginal ) = "O" and !empty( loItemPosterior.Articulo_PK );
			and this.HuboCambiosEnItem( this.oItemArticuloOriginal, loItemPosterior )
			
		 llSeModifico = .T.
		endif
		
		if llSeModifico and this.lAplicaPromocionesAutomaticas
			this.ReactivarAplicacionAutomaticaDePromosSiEstaApagada()
		endif		
	endfunc 	 

	*-----------------------------------------------------------------------------------------
	function DesactivarAplicacionDePromocionesAutomaticas() as Void
	
 		this.lAplicaPromocionesAutomaticas = .F.
 		this.oManagerPromociones.LimpiarManagerAutomatico()
	
		unbindevents( This.FacturaDetalle, "EventoSeAgregoUnItem", this, "EvaluarSiSeAgregoUnItem" )
		unbindevents( This.FacturaDetalle, "EventoAntesDeModificarItem", this, "GuardarItemOriginal" )
		unbindevents( This.FacturaDetalle, "EventoDespuesDeModificarItem", this, "EvaluarSiHuboCambiosEnItem" )		
		unbindevents( this, "Setear_ListaDePrecios", this, "ReactivarAplicacionAutomaticaDePromosSiEstaApagada" )
		unbindevents( this, "Grabar", this, "EnviarASerializarSiEstaEnoItem" )		
		
		if !this.oManagerPromociones.lAsistenteEncendido
			this.oManagerPromociones.DeshabilitarSerializacionPorHilos()
		endif
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ActivarVerificacionDeCambiosEnItems() as Void
	
		this.BindearEvento( This.FacturaDetalle, "EventoSeAgregoUnItem", this, "EvaluarSiSeAgregoUnItem" )
		this.BindearEvento( This.FacturaDetalle, "EventoAntesDeModificarItem", this, "GuardarItemOriginal" )		
		this.BindearEvento( This.FacturaDetalle, "EventoDespuesDeModificarItem", this, "EvaluarSiHuboCambiosEnItem" )
		this.BindearEvento( This, "Setear_ListaDePrecios", this, "EnviarASerializarPorCambioListaDePrecios" )
		bindevent( this, "Setear_ListaDePrecios", this, "ReactivarAplicacionAutomaticaDePromosSiEstaApagada" )
			
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EnviarASerializarPorCambioListaDePrecios( txval as Variant ) as Void
		this.EnviarASerializar()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function DesactivarVerificacionDeCambiosEnItems() as Void
	
		unbindevents( This.FacturaDetalle, "EventoSeAgregoUnItem", this, "ReactivarAplicacionAutomaticaDePromosSiEstaApagada" )
		unbindevents( This.FacturaDetalle, "EventoAntesDeModificarItem", this, "GuardarItemOriginal" )
		unbindevents( This.FacturaDetalle, "EventoDespuesDeModificarItem", this, "EvaluarSiHuboCambiosEnItem" )		
			
	endfunc
	 	
	*-----------------------------------------------------------------------------------------
	function ProcesarPromocionesAutomaticas() as Void
		local llEstaSerializandoYEvaluando as Boolean
 
		if this.lAplicaPromocionesAutomaticas and this.lPlataformaEcommecerLoPermite
			if !empty( this.FacturaDetalle.oItem.Articulo_PK  )
				this.ReactivarAplicacionAutomaticaDePromosSiEstaApagada()
				this.oManagerPromociones.SerializarComprobante( this )
			endif
			llEstaSerializandoYEvaluando = this.oManagerPromociones.PedirEstadoSerializacionYEvaluacion()
			if llEstaSerializandoYEvaluando 				
				this.EsperarAEvaluacionDePromocionesAutomaticas( llEstaSerializandoYEvaluando ) 
				this.SePuedeCalcularVuelto()  
				this.CalcularVuelto( upper( this.cValoresDetalle ) )
				this.NoSePuedeCalcularVuelto()
			endif
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsperarAEvaluacionDePromocionesAutomaticas( tlEstaEvaluando as Boolean ) as Void
		local llEvaluando as Boolean
		
		llEvaluando = tlEstaEvaluando	

		this.EventoMostrarMensajeSinEspera("Evaluando promociones automáticas...")
		
		do while llEvaluando
			llEvaluando = .F.
			llEvaluando = this.oManagerPromociones.PedirEstadoSerializacionYEvaluacion()
			wait windows "" timeout 0.5 &&Se tiene que dejar un pequeñísimo tiempo de espera porque el ciclo es muy rapido		
		enddo
		
		this.EventoMostrarMensajeSinEspera() 				
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoMostrarMensajeSinEspera( tcMensaje as String, tcTitulo as string, tcTextoBoton as String ) as Void
		&&Hola soy un evento para bindearme al kontroler
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function Validar_Articulo( tcValor as String ) as Void
		This.lCargoPromocion = .F.
		if This.CargaManual() and "$" == substr( alltrim( tcValor ), 1, 1 )
			This.lCargoPromocion = .T.
			This.FacturaDetalle.oItem.lValidarArticulo = .F.
			This.FacturaDetalle.oItem.Articulo_PK = ""
			This.SetearPromoEnPrimerLugarGrillaPromociones( substr( alltrim( tcValor ), 2 ) )			
			this.EventoSetearGrillaPromociones( tcValor )
		Endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function SetearPromoEnPrimerLugarGrillaPromociones( tcValor as String ) as Void
		local lnI as Integer, loDetalle as Object
		loDetalle = This.PromocionesDetalle
		for lnI = 1 to loDetalle.Count
			if loDetalle.ValidarExistenciaCamposFijosItemPlano( lnI )
			Else
				exit for
			endif
		EndFor
		if lnI > loDetalle.Count
			loDetalle.LimpiarItem()
		else
			loDetalle.CargarItem( lnI )
		Endif
		loDetalle.oItem.Promocion_Pk = tcValor
		loDetalle.Actualizar()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoSetearGrillaPromociones( tcValor as string ) as Void
		&&Hola soy un evento para bindearme al kontroler
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoMostrarGrillaPromociones() as Void
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EventoRestaurarCuotasSinRecargo( toItem as Object, tlCargaPromo as Boolean ) as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoSetearnKeyCodeEnValoresDetalle( tnKeyCode as Integer ) as Void
	endfunc 

	
	*-----------------------------------------------------------------------------------------
	function HuboCambiosEnItem( toItemOriginal as object, toItemActual as Object ) as boolean
		local llRetorno as Boolean
		
		llRetorno = .F.

		if toItemOriginal.idItemArticulos	!= toItemActual.idItemArticulos or;
			toItemOriginal.Articulo_PK		!= toItemActual.Articulo_PK or;
			toItemOriginal.ArticuloDetalle	!= toItemActual.ArticuloDetalle or;
			toItemOriginal.Color_PK			!= toItemActual.Color_PK or;
			toItemOriginal.ColorDetalle		!= toItemActual.ColorDetalle or;
			toItemOriginal.Talle_PK			!= toItemActual.Talle_PK or; 
			toItemOriginal.Cantidad			!= toItemActual.Cantidad or;
			toItemOriginal.Precio			!= toItemActual.Precio or;
			toItemOriginal.MontoDescuento	!= toItemActual.MontoDescuento or;
			toItemOriginal.Descuento		!= toItemActual.Descuento
	
			llRetorno = .T.
		endif		
		
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerSentenciaDeUpdateDeCliente( tcEmail ) as string
		lcCampoEmail = this.Cliente.oAd.ObtenerCampoEntidad( "Email" )
		lcTablaCliente = this.Cliente.oAd.cTablaPrincipal
		lcCampoClave = this.Cliente.oAd.ObtenerCampoEntidad( "Codigo" )
		lcSentencia = "Update " + alltrim( lcTablaCliente ) + " set " + alltrim( lcCampoEmail ) + " = '" + alltrim( tcEmail ) + ;
			"', FMODIFW = '" + dtoc( goLibrerias.ObtenerFecha()) + "', HMODIFW = '" + goLibrerias.ObtenerHora() + ;
			"', BDMODIFW = '" + _screen.zoo.app.cSucursalActiva + "', SMODIFW = '" + _Screen.Zoo.App.cSerie + ;
			"', UMODIFW = '" + goServicios.Seguridad.cUsuarioLogueado + "', VMODIFW = '" + _screen.zoo.app.cVersionSegunIni + ;
			"' where " + lcCampoClave + " = '" + alltrim( this.Cliente.Codigo ) + "'"
		return lcSentencia
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function TieneQueActualizarEmailDeCliente( tcEmail ) as Boolean
		local llRetorno as Boolean, lnParametro as Integer
	
		llRetorno = .F.
		if !empty( alltrim( tcEmail ))
			llRetorno = alltrim( upper( tcEmail ) ) != alltrim( upper( this.Cliente.Email ) ) and alltrim( this.cliente_PK ) != "" and !this.lVieneDeEcommerce
			
			if llRetorno
				lnParametro = goParametros.Felino.GestionDeVentas.Minorista.ActualizarElMailEnElAltaDeClientes
				if lnParametro <= 2
					this.lActualizaMailEnCliente  = ( lnParametro = 1 )
				else
					this.EventoPreguntarSiActualizaElMailEnElAltaDeClientes( lnParametro )			
				endif
				llRetorno = this.lActualizaMailEnCliente
			endif
			
		endif
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoPreguntarSiActualizaElMailEnElAltaDeClientes( tnParametro as Integer ) as Void
	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	protected function TieneEmailParaActualizar() as Boolean
		return pemstatus( this, "Email",5)
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ActulizarEmail() as void
		if alltrim( this.Cliente.Email ) != ""
			this.Email = this.Cliente.Email
		else
			this.Email = ""	
		endif
	endfunc 			
	
	*-----------------------------------------------------------------------------------------
	Function NuevoBasadoEn() as Void
		local llAsistenteActivo as Boolean, lnPuntoDeVentaCpteRelacionado as Integer, lnNumeroCpteRelacionado as Integer,;
			lnTipoCpteRelacionado as Integer, lcLetraCpteRelacionado as String, ldFechaCpteRelacionado as Date, llHabilitaComprobanteAsociado as Boolean
		
		this.lEsNuevoBasadoEnOAfectante  = .t.
		llAsistenteActivo = this.oManagerPromociones.lAsistenteEncendido
		if llAsistenteActivo
			this.oManagerPromociones.DeshabilitarSerializacionPorHilos()
		endif
		this.lSeEliminoUnaPromoAutomatica = .f.
		this.lSeEliminoUnaPromoBancaria = .f.
		
		lnPuntoDeVentaCpteRelacionado = this.oCompEnBaseA.oEntidadAfectada.PuntoDeVenta
		lnNumeroCpteRelacionado = this.oCompEnBaseA.oEntidadAfectada.Numero
		lnTipoCpteRelacionado = this.oCompEnBaseA.oEntidadAfectada.TipoComprobante
		lcLetraCpteRelacionado = this.oCompEnBaseA.oEntidadAfectada.Letra
		ldFechaCpteRelacionado = this.oCompEnBaseA.oEntidadAfectada.Fecha
		dodefault()
		
		this.QuitarReferenciaAComprobanteDGIUruguay()

		this.SetearComprobanteRelacionado( lnPuntoDeVentaCpteRelacionado, lnNumeroCpteRelacionado, lnTipoCpteRelacionado, lcLetraCpteRelacionado, ;
			ldFechaCpteRelacionado )
				
		if llAsistenteActivo
			this.oManagerPromociones.HabilitarSerializacionPorHilos()
		endif
		this.lEsNuevoBasadoEnOAfectante  = .f.
	EndFunc 
	
	*-----------------------------------------------------------------------------------------
	function QuitarReferenciaAComprobanteDGIUruguay() as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function CargarDatosDGICpteRelacionado() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerEstadoDeStockDeComprobante( tcEntidad as String, tlVieneDeEnBaseA as Boolean ) as String
		local lcRetorno as String 
		
		do case
			case ( tcEntidad == this.cComprobante and this.lTieneEntregaPosterior ) or tlVieneDeEnBaseA or this.EsNCEnBaseAComprobanteConEntregaPosterior( tcEntidad )
				lcRetorno = "ENTREGAPEN"
			case this.lTieneEntregaOnLine or this.EsNCEnBaseAComprobanteOnline()
				lcRetorno = ""
			otherwise
				lcRetorno = dodefault( tcEntidad ) 
		endcase
		
		return lcRetorno 
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function TieneSeteadaEntregaPosterior() as Boolean
		local llRetorno as Boolean
		
		llRetorno = this.lEsComprobanteConEntregaPosterior and this.EntregaPosterior = 1
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function TieneSeteadaEntregaOnLine() as Boolean
		local llRetorno as Boolean
		
		llRetorno = this.lEsComprobanteConEntregaPosterior and this.EntregaPosterior = 3
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoSetearValorSugeridoComboEntregaposterior() as Void		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function SetearControlDeStock( tlValor as Boolean ) as Void
		if this.lEsComprobanteConEntregaPosterior
			this.FacturaDetalle.oItem.lControlaStock = tlValor
			if tlValor
				this.SetearSignoPorEntregaPosteriorDefault()
			else
				this.SetearSignoPorEntregaPosterior()
			endif
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function SetearSignoPorEntregaPosterior() as Void
		if this.lEsComprobanteConEntregaPosterior
			this.FacturaDetalle.oItem.oCompStock.lInvertirSigno = .t.
			this.FacturaDetalle.oItem.oCompStock.nSigno = -1
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function SetearSignoPorEntregaPosteriorDefault() as Void
		if this.lEsComprobanteConEntregaPosterior
			this.FacturaDetalle.oItem.oCompStock.lInvertirSigno = .f.
			this.FacturaDetalle.oItem.oCompStock.nSigno = 1
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EventoCargarComboEntregaPosterior() as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoActualizarComboEntregaPosterior( tlNuevo as Boolean  ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoHabilitarDeshabilitarComboEntregaPosterior() as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ActualizarControlDeStock( txValor ) as Void
		local llValor as Boolean
		llValor = ( this.EntregaPosterior != 1 and this.EntregaPosterior != 3 ) or ( this.EntregaPosterior = 1 and this.lIncorporarControlDeStockEnFacturasConEntregaPosterior )
		this.SetearControlDeStock( llValor )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EsNCEnBaseAComprobanteConEntregaPosterior( tcEntidad as String ) as Boolean
		local llRetorno as Boolean
		llRetorno = ( this.EsNotaDeCredito() and vartype( this.oCompEnBaseA.oEntidadAfectada ) = 'O' and pemstatus( this.oCompEnBaseA.oEntidadAfectada, "EntregaPosterior", 5 ) and this.oCompEnBaseA.oEntidadAfectada.EntregaPosterior = 1 )
		
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function SetearValorSugeridoEntregaPosterior() as Void
		this.lParametroEntregaPosteriorHabilitada = goParametros.Felino.GestionDeVentas.EntregaPosteriorEnFacturas
		
		this.lParametroSugiereTipoDeEntrega = This.SetearValorParametroTipoDeEntrega()
		
		with this 
		do case
				case .lParametroSugiereTipoDeEntrega = 4 && Último utilizado
					do case
						case .UltimoUtilizado_EntregaPosterior ( .TIPOCOMPROBANTE ) = 1 and .lParametroEntregaPosteriorHabilitada = 1
							.SetearEntregaPosterior( 3 ) 
							case .UltimoUtilizado_EntregaPosterior ( .TIPOCOMPROBANTE ) = 2 and .lParametroEntregaPosteriorHabilitada = 1
								.SetearEntregaPosterior( 2 ) && Inmediata
						case .UltimoUtilizado_EntregaPosterior ( .TIPOCOMPROBANTE ) = 3 and .lParametroEntregaPosteriorHabilitada = 1 
							if goParametros.Felino.GestionDeVentas.SugiereTipoDeEntregaOnline 
								goParametros.Felino.GestionDeVentas.SugiereTipoDeEntregaOnline = .f.
							endif
							.SetearEntregaPosterior( 3 ) && Venta Continua							
						case .UltimoUtilizado_EntregaPosterior ( .TIPOCOMPROBANTE ) = 1 and .lParametroEntregaPosteriorHabilitada = 2
							.SetearEntregaPosterior( 1 ) && Posterior
						case .UltimoUtilizado_EntregaPosterior ( .TIPOCOMPROBANTE ) = 2 and .lParametroEntregaPosteriorHabilitada = 2
							.SetearEntregaPosterior( 2 )
						case .UltimoUtilizado_EntregaPosterior ( .TIPOCOMPROBANTE ) = 3 and .lParametroEntregaPosteriorHabilitada = 2
							if goParametros.Felino.GestionDeVentas.SugiereTipoDeEntregaOnline 
								goParametros.Felino.GestionDeVentas.SugiereTipoDeEntregaOnline = .f.
							endif
							.SetearEntregaPosterior( 3 )	
					endcase			
				case .lParametroSugiereTipoDeEntrega = 1 &&Inmediata
					.SetearEntregaPosterior( 2 )
				case .lParametroSugiereTipoDeEntrega = 2 &&Posterior
					do case
						case .lParametroEntregaPosteriorHabilitada = 2 and ( !pemstatus( this, "oCompEnBaseA", 5 ) or alltrim(upper(.oCompEnBaseA.cNombreEntidadAfectada)) != "REMITO" )
							.SetearEntregaPosterior( 1 )
						case .lParametroEntregaPosteriorHabilitada = 1 and ( goParametros.Felino.GestionDeVentas.SugiereTipoDeEntregaOnline or .lTieneContratadaEntregaOnline )
							.SetearEntregaPosterior( 3 )
						case .lParametroEntregaPosteriorHabilitada = 1 and !.lTieneContratadaEntregaOnline
							.SetearEntregaPosterior( 2 )
			otherwise
							.SetearEntregaPosterior( 1 )
					endcase
				case .lParametroSugiereTipoDeEntrega = 3 &&Venta Continua	
						.SetearEntregaPosterior( 3 )
		endcase			

		this.EventoSetearValorSugeridoComboEntregaPosterior()
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function SetearValorParametroTipoDeEntrega( ) as Integer
		local lnRetorno as Integer
		if goregistry.felino.ACTUALIZOTIPODEENTREGAPORPUESTO 
		else
			goregistry.felino.ACTUALIZOTIPODEENTREGAPORPUESTO = .t.
			if  goServicios.Parametros.Felino.GestionDeVentas.SugiereTipoEntregaPorPuesto = 1
				goServicios.Parametros.Felino.GestionDeVentas.SugiereTipoEntregaPorPuesto =  goServicios.Parametros.Felino.GestionDeVentas.SugiereTipoDeEntrega
			endif
		endif

		lnRetorno = goServicios.Parametros.Felino.GestionDeVentas.SugiereTipoEntregaPorPuesto
		return lnRetorno
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function SetearEntregaPosterior( tnValor as Integer ) as Void
		this.EntregaPosterior = tnValor
	endfunc 

	*-----------------------------------------------------------------------------------------
	function setear_entregaposterior( txval as variant ) as void 
		 
		with this
		if txval = 3
				if type( "this.FacturaDetalle" ) = "O" and !isnull( .FacturaDetalle )
					.InicializarColaboradorEquivalenciaCodigoGTIN()
					.InicializarColaboradorCodigosDJCP()
					.InicializarColaboradorAjusteDeComprobante()
					.InicializarColaboradorDisplayVFD()
					.SetearEntregaOnline()
					if !.lTieneContratadaEntregaOnline
						do case
							case ( .lParametroSugiereTipoDeEntrega = 4 or .lParametroSugiereTipoDeEntrega = 3 ) and .UltimoUtilizado_EntregaPosterior ( .TIPOCOMPROBANTE ) = 3
								goServicios.Mensajes.Advertir( "El servicio de venta continua no se encuentra contratado para la base de datos actual." )
								if .lnuevo or .ledicion
									if .lParametroEntregaPosteriorHabilitada = 2
										.SetearEntregaPosterior( 1 )
									else
										.SetearEntregaPosterior( 2 )
									endif
								endif
							case .lParametroSugiereTipoDeEntrega = 3 and !.UltimoUtilizado_EntregaPosterior ( .TIPOCOMPROBANTE ) = 3
								goServicios.Mensajes.Advertir( "El servicio de venta continua no se encuentra contratado para la base de datos actual." )
								if .lnuevo or .ledicion
									if .lParametroEntregaPosteriorHabilitada = 2 
										.SetearEntregaPosterior( 1 )
									else
										.SetearEntregaPosterior( 2 )
									endif	
								endif
							case .lParametroEntregaPosteriorHabilitada = 2 and ( .lnuevo or .ledicion )
								.SetearEntregaPosterior( 1 )
							case .lParametroEntregaPosteriorHabilitada = 1 and ( .lnuevo or .ledicion )
								.SetearEntregaPosterior( 2 )
							otherwise  
								goServicios.Errores.LevantarExcepcion( "El servicio de venta continua no se encuentra contratado para la base de datos actual." )
						endcase	
					endif	
				endif
			endif
		endwith		
		dodefault( txval )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function SetearentregaPosteriorParaFacturasAnteriores() as Void
		if this.EntregaPosterior = 0
			this.SetearEntregaPosterior( 2 )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EvaluarSeteoPuntoDeVentaEnComboAPartirDePuntoDeVenta( txVal as Variant ) as Void

		if !empty( txVal ) and !this.EsNuevo() and !this.EsEdicion()
			this.EventoLlenarComboPuntosDeVenta( txval )		
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EvaluarSeteoPuntoDeVentaEnComboAPartirDeLetra( txVal as Variant ) as Void
		if !empty( txVal ) and this.EsNuevo()
			this.EventoCambiarOpcionesComboPuntoDeVenta( txVal )
		endif
	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	function EventoCambiarOpcionesComboPuntoDeVenta( txval as Variant ) as Void
		&&Hola soy un evento
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoLlenarComboPuntosDeVenta( txval as Variant ) as Void
		&&Hola soy un evento
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarAtributosCpteAsociado() as Boolean
		local llRetorno as Boolean
		
		llRetorno = .t.
		if !empty(this.TipoCpteRelacionado) or !empty(this.NumeroCpteRelacionado) or !empty(this.PuntoDeVentaCpteRelacionado) or !empty(this.FechaCpteRelacionado)
			llRetorno = !empty(this.TipoCpteRelacionado) and !empty(this.NumeroCpteRelacionado) and !empty(this.PuntoDeVentaCpteRelacionado) ;
						 and !empty(this.FechaCpteRelacionado)
		endif
		
		if !llRetorno
			this.agregarInformacion( "Si carga comprobante asociado, todos los datos deben estar completos." )
		endif
		
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function TieneValoresParaPromocionesBancarias() as Boolean
		local lcDetalle as String, loDetalleValores as Object, llRetorno as Boolean
		llRetorno = .f.
		lcDetalle = This.cValoresDetalle
		loDetalleValores = this.&lcDetalle
		for each oValor in loDetalleValores
			if oValor.Tipo = TIPOVALORTARJETA
				llRetorno = .t.
			endif
		endfor
		
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoLimpiarTooltipCliente() as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerIdItemArticulosAfectadosPorPromo( tcIdPromocion as String ) as Void
		local lcRetorno as string
		
		lcRetorno = ""

		for each loItem in this.PromoArticulosDetalle
			if loItem.idItemPromo == tcIdPromocion and !empty( loItem.IdItemArticulo )
				lcRetorno = lcRetorno +  this.ObtenerCombinacionYDescuentos( loItem.IdItemArticulo ) + ","
			endif
		endfor
		
		if !empty( lcRetorno )
			lcRetorno = substr( lcRetorno, 1, len( lcRetorno ) - 1 )
		endif
		
		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerCombinacionYDescuentos( tcIdArticulo as String ) as Void
		local lcRetorno as String
		
		lcRetorno = ""
		
		for each loItem in this.FacturaDetalle
			if loItem.IdItemArticulos == tcIdArticulo
				lcRetorno = rtrim( loItem.Articulo_PK ) + "-" + rtrim( loItem.Color_PK ) +;
				 "-" + rtrim( loItem.Talle_PK ) + "-" + transform( loItem.Descuento ) + "-" +;
				 transform( round( loItem.MontoDescuentoSinImpuestos, 4 ) )							
			endif
		endfor
		
		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EsTipoComprobanteAsociadoValido( tnTipoComprobanteAsociado as integer ) as Boolean
		local llRetorno as Boolean 
		llRetorno = .f.
		do case
			case this.TipoComprobante = 35 or this.TipoComprobante = 36
				llRetorno = inlist( tnTipoComprobanteAsociado,33,35,36)
			case this.TipoComprobante = 28 or this.TipoComprobante = 29
				llRetorno = inlist( tnTipoComprobanteAsociado,1,3,4,2,5,6,27,28,29,54,55,56) or;
					( GoParametros.Nucleo.DatosGenerales.Pais == 3 and inlist( tnTipoComprobanteAsociado,97,98,99))
			otherwise
				llRetorno = inlist( tnTipoComprobanteAsociado,1,3,4,2,5,6,27,28,29)
		endcase		
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function SetearCajaEnProcesoDeCierre( tnCaja as Integer ) as Void
		if vartype( tnCaja ) = 'N'
			this.nNumeroDeCajaEnProcesoDeCierre = tnCaja
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function HaySeteadoUnNumeroDeCajaEnProcesoDeCierre as Boolean
		return ( this.nNumeroDeCajaEnProcesoDeCierre <> 0 )
	endfunc	

	*-----------------------------------------------------------------------------------------
	function SetearComprobanteRelacionado( tnPuntoDeVentaCpteRelacionado as number, tnNumeroCpteRelacionado as Number, tnTipoCpteRelacionado as Number, tcLetraCpteRelacionado as String,;
	                                       tdFechaCpteRelacionado as Date ) as Boolean
	local lhabilitaComprobanteAsociado as Boolean, lnTipoCpteRelacionado as Integer, lcLetraCpteRelacionado as String, ldFechaCpteRelacionado as Date
	
		llHabilitaComprobanteAsociado = goParametros.Felino.GestionDeVentas.HabilitaComprobanteAsociado and this.lPermiteComprobanteAsociado and this.EsTipoComprobanteAsociadoValido( tnTipoCpteRelacionado )

		if llHabilitaComprobanteAsociado
			lnTipoCpteRelacionado = this.ObtenerTipoCpteRelacionado( tnTipoCpteRelacionado )
			lcLetraCpteRelacionado = iif( type( "tcLetraCpteRelacionado" ) = "L", "", tcLetraCpteRelacionado )
			this.PuntoDeVentaCpteRelacionado = tnPuntoDeVentaCpteRelacionado
			this.NumeroCpteRelacionado = tnNumeroCpteRelacionado
			this.TipoCpteRelacionado = lnTipoCpteRelacionado
			if lcLetraCpteRelacionado != ' '
		   		this.LetraCpteRelacionado = lcLetraCpteRelacionado
		    endif
			if this.LetraCpteRelacionado = " "
				this.LetraCpteRelacionado = This.letra
			endif
			if !empty( tdFechaCpteRelacionado )
			    if vartype( tdFechaCpteRelacionado ) = 'T'
			      this.FechaCpteRelacionado = ttod( tdFechaCpteRelacionado )
			    else
			      this.FechaCpteRelacionado = tdFechaCpteRelacionado
			    endif
			endif
			this.CargarDatosDGICpteRelacionado()
		else
			this.PuntoDeVentaCpteRelacionado = 0
			this.NumeroCpteRelacionado = 0
			this.TipoCpteRelacionado = 0
			this.LetraCpteRelacionado = ""
			this.FechaCpteRelacionado = ctod( "  /  /  " )
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function AsignarComprobanteRelacionado() as Void
		local lnPuntoDeVentaCpteRelacionado as number, lnNumeroCpteRelacionado as number, lnTipoCpteRelacionado as Number, lcLetraCpteRelacionado as String,;
		      ldFechaCpteRelacionado as Date
		
		if pemstatus(this.oAfectanteAuxiliar, "SetearComprobanteRelacionado", 5)
			with this.oAfectanteAuxiliar
				.lEsNuevoBasadoEnOAfectante  = .t.
				lnPuntoDeVentaCpteRelacionado = this.PuntoDeVenta
				lnNumeroCpteRelacionado = this.Numero
				lnTipoCpteRelacionado = this.TipoComprobante
				lcLetraCpteRelacionado = this.Letra   
				ldFechaCpteRelacionado = this.Fecha
				
				.QuitarReferenciaAComprobanteDGIUruguay()
				.SetearComprobanteRelacionado( lnPuntoDeVentaCpteRelacionado, lnNumeroCpteRelacionado, lnTipoCpteRelacionado, ;
					lcLetraCpteRelacionado, ldFechaCpteRelacionado )
				.lEsNuevoBasadoEnOAfectante  = .f.
			endwith
		endif
		
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerTipoCpteRelacionado( tnTipoCpteRelacionado ) as Integer
		local lnRetorno as Integer
		
		do case
			case inlist(tnTipoCpteRelacionado,1,2,27)
				lnRetorno = 1
			case inlist(tnTipoCpteRelacionado,3,5,28)
				lnRetorno = 3   
			case inlist(tnTipoCpteRelacionado,4,6,29)
				lnRetorno = 4	
			otherwise
				lnRetorno = tnTipoCpteRelacionado
		endcase
			
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsNCEnBaseAComprobanteOnline() as Boolean
		local llRetonro as Boolean 
		llRetorno = this.EsNotaDeCredito() and pemstatus(this, "BasadoEnComprobanteOnline", 5) and this.BasadoEnComprobanteOnline
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerEstadoEvaluacionDePromocionesAutomaticas() as boolean
		local llRetorno as Boolean
		
		llRetorno = this.lAplicaPromocionesAutomaticas and this.oManagerPromociones.PedirEstadoSerializacionYEvaluacion()
		
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ReEvaluarPromociones() as Void

		if this.lAplicaPromocionesAutomaticas
		
			this.BorrarPromocionesYDesafectarItems()
					
			this.FacturaDetalle.Actualizar()			
			this.ReactivarAplicacionAutomaticaDePromosSiEstaApagada()
			this.EnviarASerializar()
		endif		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function BorrarPromocionesYDesafectarItems() as Void
		local loColIdArticulosADesafectar as Object, loItem as Object, lnIndice as Integer
	
			loColIdArticulosADesafectar = newobject("Collection")
			

			this.PromocionesDetalle.Limpiar()

			this.PromocionesDetalle.Actualizar()
			for each loItem in this.PromoArticulosDetalle foxobject
				if !empty( loItem.idItemArticulo )
					loColIdArticulosADesafectar.Add( loItem.idItemArticulo, loItem.idItemArticulo )
				endif
			endfor	
			for each loItem in this.FacturaDetalle foxobject
				lnIndice = loColIdArticulosADesafectar.Getkey( loItem.idItemArticulos )
				if lnIndice != 0
					loItem.MontoDescuento = 0
					loItem.Descuento = 0
				endif
			endfor
			this.PromoArticulosDetalle.Limpiar()
			this.PromoArticulosDetalle.Actualizar()	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function TieneKits() as Boolean
		local llRetorno as Boolean
		llRetorno = .f.
		if pemstatus( this, "KitsDetalle",5 ) and vartype( This.KitsDetalle ) == "O" and !isnull( This.KitsDetalle )
			llRetorno = this.KitsDetalle.CantidadDeItemsCargados() > 0	
		endif
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function TienePromos() as Void
		local llRetorno as Boolean
		llRetorno = .f.
		if pemstatus( this, "PromocionesDetalle",5 ) and vartype( This.PromocionesDetalle ) == "O" and !isnull( This.PromocionesDetalle )
			llRetorno = this.PromocionesDetalle.CantidadDeItemsCargados() > 0	
		endif
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarArticulosComercializablesSoloEnPromosYKits() as Boolean
		local llRetorno as Boolean, lnI as Integer, loArticulo as Object, lcTSQL_IN as String, lcArticulos as string   
		llRetorno = .t.
		lcTSQL_IN = this.FacturaDetalle.cStringFiltroArticulosPromoYKits
		lcArticulos = ""
		if !empty( lcTSQL_IN )	
			local lcCursor as string
			lcCursor = "c_" + sys( 2015 )
			goServicios.Datos.EjecutarSentencias( "select artcod from art where artcod in (" + lcTSQL_IN + ") and PromoYKit = 1", "art", "", lcCursor, set("Datasession") )		
			select ( lcCursor )
			scan
				llRetorno = .f.
				lcArticulos = lcArticulos + "'" + rtrim( artcod ) + "', "
			endscan
			if !empty( lcArticulos ) and reccount( lcCursor ) > 0
				lcArticulos = substr( lcArticulos , 1, len( lcArticulos ) - 2 )
				this.AgregarInformacion( "Los siguientes artículos solo se pueden usar en promos o kits: " + lcArticulos )
			endif
			use in select ( lcCursor )
		endif		
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function RequiereComprobanteAsociadoObligatorio() as Boolean 
		local llRetorno as Boolean
		llRetorno = this.lPermiteComprobanteAsociado and pemstatus(this, "TipoCpteRelacionado", 5) and goParametros.Felino.GestionDeVentas.HabilitaComprobanteAsociado
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarAtributosCpteAsociadoObligatorio() as Boolean
		local llRetorno as Boolean
		
		llRetorno = .t.
		if this.RequiereComprobanteAsociadoObligatorio()
			llRetorno = !empty(this.TipoCpteRelacionado)  and !empty(this.NumeroCpteRelacionado) ;
						and !empty(this.PuntoDeVentaCpteRelacionado) and !empty(this.FechaCpteRelacionado)
		endif
		
		if !llRetorno
			this.agregarInformacion( "Debe completar los datos de comprobante asociado." )
		endif
		
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarSiLetraCpteRelacionadoEstaVacia() as Boolean
		local llRetorno as Boolean
		llRetorno = .f.
		if !this.EsTicketNotaDeCreditoConNumeracionIndependiente()
			llRetorno = empty( this.LetraCpteRelacionado )
		endif
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EsTicketNotaDeCreditoConNumeracionIndependiente() as Boolean
		return ( inlist( this.TipoComprobante, 5 ) and vartype( goControladorFiscal ) = 'O' and goControladorFiscal.oCaracteristicas.lTicketBNumeracionIndependiente )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidacionBasica() as boolean
		local llRetorno as Boolean
		llRetorno = dodefault()
		llRetorno = llRetorno and this.ValidarAtributosCpteAsociadoObligatorio()
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ExisteAtributo( tcAtributo as String ) as Boolean
		local llRetorno as Boolean, lcAtributo as String
		lcAtributo = substr(tcAtributo, at('.',tcAtributo)+1)
		if at(lcAtributo,this.cAtributosAOmitir)>0
			llRetorno = .f.
		else
			llRetorno = dodefault(tcAtributo)
		endif
		return llRetorno
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function SetearAtributosAOmitir() as Void
		if goParametros.Felino.GestionDeVentas.HabilitaComprobanteAsociado
			cAtributosAOmitir = ""
		else
			this.cAtributosAOmitir = "PUNTODEVENTACPTERELACIONADO,NUMEROCPTERELACIONADO,TIPOCPTERELACIONADO"
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerDetalleDeValores() as Object
		local loRetorno as Object
		loRetorno = null
		if pemstatus( this, "ValoresDetalle", 5 )
			if type( "this.ValoresDetalle" ) = "O"
				loRetorno = this.ValoresDetalle
			endif
		endif
		return loRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerDefaultParaOperatoriaEnNuevoEnBaseA() as Integer
		local lnRetorno as Integer
		if this.EsNotaDeCredito()
			lnRetorno = goParametros.Felino.GestionDeVentas.Minorista.NuevoEnBaseA.NotaDeCreditoTicketNotaDeCreditoDefaultComboSeleccionOperatoria
		else
			lnRetorno = goParametros.Felino.GestionDeVentas.Minorista.NuevoEnBaseA.FacturaTicketFacturaDefaultComboSeleccionOperatoria
		endif
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearValidadorCombinacionesRepetidas as Void
		this.oColeccion = _Screen.Zoo.CrearObjeto( "ZooLogicSA.ValidarCombinacionesRepetidas.ColeccionesItems" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GuardarMontoDescuento3Original( txValor as variant ) as void
		this.nMontoDeDescuento3IngresadoManualmente = txValor
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function SetearFechaEnDetalleDeValores() as Void
		local loDetalle as Object
		if type( "this." + This.cValoresDetalle ) = "O"
			loDetalle = This.cValoresDetalle
			This.&loDetalle..dFechaComprobante = This.Fecha
		Endif	
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function SetearlAplicarPromosAutomaticasAlSalirDelDetalle() as Void
		this.lAplicarPromosAutomaticasAlSalirDelDetalle = goParametros.Felino.GestionDeVentas.Minorista.Promociones.AplicarPromosAutomaticasAlSalirDelDetalle
	endfunc

	*-----------------------------------------------------------------------------------------
	function Setear_FechaCpteRelacionado( txval ) as Void
		dodefault( txVal )

		if txVal > this.fecha and ( This.EsEdicion() or this.EsNuevo() )
			this.EventoMostrarMensajeFechaMayorAlComprobante()	
		endif

	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoMostrarMensajeFechaMayorAlComprobante() as Void
		* Para bindeo
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function SetearFechaCpteRelacionadoPorDefecto() as Void
		
		if this.RequiereComprobanteAsociadoObligatorio()
			this.FechaCpteRelacionado = this.fecha
		endif

	endfunc 

	*-----------------------------------------------------------------------------------------
	function UltimoUtilizado_EntregaPosterior( tnTipoComp as Integer ) as Integer
		local lnRetorno as Integer, lcSentencia as String , lcEnter as String, lcFrom as String, lcCursor as String
	
		lcCursor = sys(2015)
		lcEnter = chr( 13 ) + chr( 10 )
		lcSentencia = ""
		lcFrom = "[" + alltrim( _screen.zoo.app.Obtenerprefijodb() + _screen.zoo.app.cSucursalActiva ) + "]."
        lcFrom = lcFrom + "[" + alltrim( _screen.zoo.app.cSchemaDefault ) + "]." + "[" + "COMPROBANTEV" + "] "
       
		lcSentencia = "select top 1 ENTREGAPOS from " + lcFrom + " WHERE ANULADO = 0 AND FACTTIPO = " + transform(tnTipoComp) + lcEnter
		lcSentencia = lcSentencia + " order by FALTAFW DESC, HALTAFW DESC "
		goServicios.Datos.EjecutarSentencias( lcSentencia , "UltimoUtilizado", "", lcCursor, set( "Datasession" ) )
			
		select &lcCursor
		if reccount() > 0 
			lnRetorno = &lcCursor..entregapos
		else
			lnRetorno = 2
		endif
		
  		return lnRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearPromosConCuponesIntegrados( tlValor as Boolean, tcIdItemValor as String ) as Void
		this.oManagerPromociones.SetearPromosConCuponesIntegrados( tlValor, tcIdItemValor )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EventoHabilitarDeshabilitarAccionesSenia( txval as variant ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearMonedaEnDetalleValoresParaActualizarCotizacion() as Void
		local lcDetalle as String 
		lcDetalle = This.cValoresDetalle
		this.&lcDetalle..oMoneda.Codigo = This.MonedaComprobante_Pk		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function IngreseCotizacion() as String
		local lcDetalle as string
		lcDetalle = This.cValoresDetalle
		return this.&lcDetalle..IngreseCotizacion()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerFechaDeUltimaCotizacion() as Date
		local ldFechaUltCotizacion as Date, lcDetalle as String 
		lcDetalle = This.cValoresDetalle
		ldFechaUltCotizacion = this.&lcDetalle..oMoneda.ObtenerFechaUltimaCotizacion( this.Fecha )
		return ldFechaUltCotizacion
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerAjustePorCentavoResidual( tnTotal as float ) as float
		local lnResiduo as float
		lnResiduo = 0
		if this.HayValorQueAdmiteVuelto()
		else
			if !this.lAjustePorResiduoCentavo and pemstatus(this,"ValoresDetalle",5) and pemstatus(this.ValoresDetalle,"Sum_Recargomonto",5) and abs(this.ValoresDetalle.Sum_Recargomonto) > 0 && si tiene recargo en valores 
				* and pemstatus(this.ValoresDetalle,"Sum_Recargomontosinimpuestos",5) and this.ValoresDetalle.Sum_Recargomontosinimpuestos > 0 ;
				*lnIvaFinanciero = this.oComponenteFiscal.oComponenteImpuestos.ObtenerCoeficienteFinanciero() 
				*lnIvaFinancieroPorDiferencia = this.ValoresDetalle.Sum_Recargomonto - this.RecargoMonto1
				*lnIvaFinancieroCalculado	 =  goLibrerias.RedondearSegunMascara( this.RecargoMonto1 * lnIvaFinanciero )
				lnResiduo = this.ValoresDetalle.Sum_Recibidoalcambio - tnTotal 
				if abs(lnResiduo) > 0 and abs(lnResiduo) < 1 and this.Percepciones # 0
					this.lAjustePorResiduoCentavo = .t.
				else
					lnResiduo = 0
				endif
			endif
		endif
		return lnResiduo
	endfunc 

	*-----------------------------------------------------------------------------------------
	function HayValorQueAdmiteVuelto() as Boolean
		local llRetorno as Boolean
		llRetorno = this.ValoresDetalle.oItem.PermiteVuelto
		for each loItem in this.ValoresDetalle foxobject
			if loItem.PermiteVuelto
				llRetorno = .t.
				exit
			endif
		endfor
		return llRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AnalizarRecalculoDeCentavoResidual() as void
		if this.lAjustePorResiduoCentavo and pemstatus(this.ValoresDetalle,"Sum_Recibido",5) and abs(this.ValoresDetalle.Sum_Recibido - this.total) > 1 
			this.lAjustePorResiduoCentavo = .f. && debe el flag estar en falso para forzar el recalculo en metodos llamados con posterioridad a este en la linea de calculos de total del comprobante
			this.CalcularTotal()
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearDatosPreferentesDelClienteSeleccionado( tcClienteSeleccionado as String ) as Void
	
		dodefault( tcClienteSeleccionado )
		
		if empty( tcClienteSeleccionado ) or empty( this.Cliente.CondicionDePago_pk )
		else
			if ( this.lNuevo or this.lEdicion ) and this.lCambioCliente and inlist( this.TipoComprobante, 1, 2, 27 ) 
				try
					this.ForPago_pk = this.Cliente.CondicionDePago_pk
				catch to loError
					this.ForPago_pk = ""
					loEx = newobject( "ZooException", "ZooException.prg" )
					loEx.Grabar( loError )
					if loEx.nZooErrorNo == 9001
						this.agregarInformacion( "El código de condición de pago del alta del cliente no existe." )
					else
						loEx.throw()
					endif			
				endtry	
			endif		
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function DebePedirSeguridadComprobantesA() as Boolean
		local llRetorno as Boolean, lnModo as Integer

		llRetorno = .f.
		lnModo = this.ObtenerModoSeguridadRedactarComprobantesA()
		llRetorno = this.TipoDeComprobanteAdmiteLetraA() and inlist( lnModo, 3, 4 )

		return llRetorno 
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerModoSeguridadRedactarComprobantesA() as Integer
		local lnRetorno
		
		lnRetorno = goServicios.Seguridad.ObtenerModo(alltrim(this.ObtenerNombre()) + "_REDACTARCOMPROBANTETIPOA")

		return lnRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function TipoDeComprobanteAdmiteLetraA() as Boolean
		**  se sobreescribe en comprobantes con letra A
		local llRetorno as Boolean
		llRetorno = .f.
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerLetra() as String
		local lcLetra as String, lcLetraAnterior as String, llTienePermiso as Boolean

		lcLetraAnterior = this.letra
		lcLetra = dodefault()
		if inlist( lcLetra, "A", "M" ) and lcLetra != lcLetraAnterior 

			if this.lDebePedirSeguridadComprobantesA 
				if !this.lTienePermisoComprobantesA
					this.EventoPedirSeguridadComprobantesA()
				endif
				if this.lTienePermisoComprobantesA
				else
					this.LanzarExcepcionRedactarComprobantesANoPermitido( lcLetra )
				endif
			else
				if this.ObtenerModoSeguridadRedactarComprobantesA() = 2    
					this.LanzarExcepcionRedactarComprobantesANoPermitido( lcLetra )
				endif
			endif	
			
		endif
		return lcLetra
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function LanzarExcepcionRedactarComprobantesANoPermitido( tcLetra as String ) as Void

		goServicios.Errores.LevantarExcepcion( "No posee permisos para redactar un comprobante tipo " + alltrim( tcLetra ) + "." )

	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoPedirSeguridadComprobantesA() as Void
		* para que se bindee el kontorler
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SoportaDatosDGIUruguay() as Void
		return this.lEstoyEnUruguay and inlist( this.tipocomprobante,1,3,4 )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function DebeAgruparPackAutomaticamente() as Boolean
		local llRetorno as Boolean

		llRetorno = .f.
		if this.lPermiteAgruparPacksAutomaticamente and this.EsNuevo()
			this.HabilitaAgruparPacksPorParametro()
			if this.lHabilitaAgruparPacks
				this.lAgruparPacksAutomaticamente = .t.
				llRetorno = .t.
			endif
		endif
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function HabilitaAgruparPacksPorParametro() as Void 

		this.lHabilitaAgruparPacks = .f.
		
		if this.nParamAgrupamientoDePacks > 1
			if this.nParamAgrupamientoDePacks = 2 or this.lAgruparPacksAutomaticamente 
				this.lHabilitaAgruparPacks = .t.
			else
				if !this.lYaPreguntoAgrupamientoDePacks 
					this.EventoPreguntarAgruparPacksAutomaticamente()	
					this.lYaPreguntoAgrupamientoDePacks = .t.
				endif		
			endif
		endif

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoPreguntarAgruparPacksAutomaticamente() as Void
		***  para que se bindee el kontroler
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function AgruparPacksAutomaticamente() as Void
		local llHabilitaControlStock as Boolean
		
		llHabilitaControlStock = goParametros.Felino.Generales.HabilitaControlStock
		try
			goParametros.Felino.Generales.HabilitaControlStock = .f.
			lcLeyenda = "Generado automáticamente por el comprobante " + this.DescripcionFW
			with this.oHerrAgrupadora
				.Nuevo()
				.motivo_pk = goParametros.Felino.GestionDeVentas.MotivoSugeridoAlAgruparAutomaticamenteLosArticulosDeTipoPack
				.vendedor_pk = this.vendedor_pk
				.accion = 1
				.observacion = lcLeyenda
				.zadsfw = lcLeyenda
				this.AgruparDetalle()
				.Grabar()				
			endwith
		catch to loError
		finally
			goParametros.Felino.Generales.HabilitaControlStock = llHabilitaControlStock 
		endtry
	
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function AgruparDetalle() as Void
		local loItem as Object
		
		for each loItem in this.FacturaDetalle 
			if !empty( loItem.articulo_pk ) and loItem.comportamiento = 5 
				with .DetallePacks
					.LimpiarItem()
					with .oItem
						.articulo_PK = loItem.articulo_pk
						.color_pk = loItem.color_pk
						.talle_pk = loItem.talle_pk
						.cantidad = loItem.cantidad
					endwith
					.Actualizar()
				endwith 
			endif 
		endfor
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oHerrAgrupadora_access () as Object
		
		if !this.lDestroy and !( vartype( this.oHerrAgrupadora ) == "O" )
			this.oHerrAgrupadora = _screen.Zoo.InstanciarEntidad( "HerramientaAgrupadoraDePacks" )
		endif
		return this.oHerrAgrupadora

	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarPorcentajeDeSeniaMinima() as boolean
	local llretorno as Boolean, lnPorcentajeMinimoDeSenia as Integer,lnMontoPorcentajeSeniado as float 
	llretorno = .T.
	
    lnPorcentajeMinimoDeSenia = goservicios.parametros.felino.gestiondeventas.porcentajedesenaminimo
    if  lnPorcentajeMinimoDeSenia > 0
        lnMontoPorcentajeSeniado = lnPorcentajeMinimoDeSenia * this.articulosseniadosdetalle.sum_monto /100
        if this.ocompsenias.nmontodeseniaingresadomanualmente < lnMontoPorcentajeSeniado
           llretorno = .F.
           This.AgregarInformacion( "La seña no alcanza el monto mínimo establecido por parámetro." )
		endif
    endif
    return llretorno 
	endfunc 
 
 	*-----------------------------------------------------------------------------------------
	function DebeAdjuntarComprobanteAPlataformaEcommerce() as Boolean
		local llRetorno as Boolean

		if !this.lVieneDeEcommerce and pemstatus( this, "NroOPEcommerce", 5 ) and !empty( this.NroOPEcommerce ) and this.EsNuevo() and this.EsFacturaEnBaseARemitoOPedido()
			llRetorno = .T.
		endif
		
		return llRetorno

	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsFacturaEnBaseARemitoOPedido() as Boolean
		local llRetorno as Boolean, loItem as Object

		if inlist( this.TipoComprobante, 1, 2, 27 ) and pemstatus( this, "COMPAFEC", 5 ) and this.compafec.Count > 0
			for each loItem in this.compafec
				if inli( loItem.TipoComprobante, 11, 23 )
					llRetorno = .T.
					exit
				endif			
			endfor
		endif
		
		return llRetorno

	endfunc 

	*-----------------------------------------------------------------------------------------
	function AdjuntarComprobanteAPlataformaEcommece() as Void
		local loOperaciones as Object
		
		*Se cambia a una colección ya que un comprobante se puede hace en base a varios y pueden ser provenientes de Operaciones distintas
		loOperaciones = this.oColaboradorEcommerce.ObtenerDatosOperacionEcommerce( this.NroOPEcommerce )
		for each loDatosOperacion in loOperaciones
			this.oColaboradorEcommerce.ActualizarOperacionConComprobanteGeneradoManualmente( this, loDatosOperacion.cCodigo, loDatosOperacion.cZADSFW )
			
			if ( ( pemstatus( this, "cae",5 ) and !empty( this.CAE ) or !pemstatus( this, "cae",5 ) ) ) 
				if type("loDatosOperacion ") = "O"
					with loDatosOperacion
						this.oColaboradorEcommerce.EnviarMensajeria( alltrim(upper(this.cNombre)), this, 0, .cEcommerce, .cCodigo, .cLogisticType, .nTipoEcommerce )
						this.oColaboradorEcommerce.oAccionEnvioDeMensajeriaEcommerce.ProcesarBuffer()
					endwith
				endif							
			endif
		endfor

	endfunc 

	*-----------------------------------------------------------------------------------------
	function oColaboradorECommerce_Access() as variant
		if !this.ldestroy and !vartype( this.oColaboradorECommerce ) = 'O'
			this.oColaboradorECommerce = _screen.zoo.crearObjeto( "ColaboradorEcommerce" )
		endif
		return this.oColaboradorECommerce
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function SetearStockInicial() as Void
		if !this.lYaSeteoStockInicial 
			dodefault()
			this.lYaSeteoStockInicial = .t.
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
	function ValidarAlivioDeCaja() as Boolean
		local llRetorno as Boolean, loValores as Object, loColConfiguracioAlivio as Object  
 
		llRetorno = .t.
		if !this.VerificarContexto( 'CBI' )
			loValores = this.ObtenerValoresTipoMoneda()
			if loValores.count > 0
				loColConfiguracioAlivio = gocaja.ObtenerConfiguracionDeAlivioDeCaja(_screen.zoo.app.csucursalactiva, gocaja.nNumeroDeCajaActiva )
				if loColConfiguracioAlivio.count > 0	
					llRetorno = this.ValidarMontosDisponibles( loValores, loColConfiguracioAlivio )
				endif
			endif
		endif
		return llRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------	
	function ValidarMontosDisponibles( toValores, toConfiguracionAlivio ) as Boolean
		local loItem as Object, lnSaldo as Object, loAlivio as Object, lnI, lcValor ,llRetorno as Boolean , lcMensaje as String   
		llRetorno = .t.

		for lni = 1 to toValores.count
			lcValor = toValores(lni).Valor
			lnMontoItem = toValores(lnI).Monto * this.signodemovimiento
			try	
				loAlivio = toConfiguracionAlivio.item( lcvalor )
				lnSaldo = goCaja.oCajasaldos.obtenersaldovalor( gocaja.nNumeroDeCajaActiva ,lcvalor )
				lnAdvertencia = loAlivio.MontoDeAdvertencia 
				lnMaximo = loAlivio.MontoMaximo
				do case
					case loAlivio.TipoControl = 1 
					if lnSaldo > lnAdvertencia 
					*	goservicios.mensajes.advertir("Se ha alcanzado el límite máximo permitido a ingresar para el valor "+loAlivio.ValorDescripcion)
						lcMensaje = "Se ha alcanzado el límite máximo permitido a ingresar para el valor "+loAlivio.ValorDescripcion
						this.EventoMostrarMensajeAdvertirBasico( lcMensaje )		
					else 
						if lnSaldo + lnMontoItem > lnAdvertencia
							*goservicios.mensajes.advertir("Va a superar el monto máximo permitido a ingresar en caja, deberá realizar un alivio de la caja")
							lcMensaje = "Va a superar el monto máximo permitido a ingresar en caja, deberá realizar un alivio de la caja"
							this.EventoMostrarMensajeAdvertirBasico( lcMensaje )
						endif 
					endif 	
					case  loAlivio.TipoControl = 2 
						if lnSaldo > lnMaximo
							this.agregarinformacion("Se ha alcanzado el límite máximo permitido a ingresar para el valor "+loAlivio.ValorDescripcion;
							+" en la caja "+alltrim(transform(gocaja.nNumeroDeCajaActiva))+", debe proceder a realizar un alivio de caja para continuar.")
							llRetorno = .f.
						else
							if lnSaldo + lnMontoItem > lnMaximo
								*goservicios.mensajes.advertir("Va a superar el monto de dinero en caja, va a tener que aliviar la caja")
								lcMensaje = "Va a superar el monto de dinero en caja, va a tener que aliviar la caja"
								this.EventoMostrarMensajeAdvertirBasico( lcMensaje )								
							endif 
						endif	
				endcase 
			catch 
			endtry
		endfor
		return llRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerValoresTipoMoneda() as zoocoleccion OF zoocoleccion.prg
		local lcDetalle as String, loDetalleValores as Object, llRetorno as Boolean, loValor as Object, loItemValor as Object  
		loRetorno = _screen.zoo.crearobjeto("zoocoleccion")
		lcDetalle = This.cValoresDetalle
		loDetalleValores = this.&lcDetalle
		for each loValor in loDetalleValores
			if (loValor.Tipo = TIPOVALORMONEDALOCAL) or (loValor.Tipo = TIPOVALORMONEDAEXTRANJERA)
				loItemValor = newObject( "Custom" )
				with loItemValor
					.AddProperty( "Valor", rtrim(loValor.valor_PK) )
					.AddProperty( "Monto", loValor.monto )
				endwith 	
				loRetorno.Agregar( loItemValor)
			endif
		endfor
		
		return loRetorno
	endfunc 	

	*-----------------------------------------------------------------------------------------
	function EstaProcesando() as Boolean
		local llRetorno as Boolean
		llRetorno = dodefault()
		llRetorno = llRetorno or this.lSeteandoCondicionDePagoPreferente or this.lEstaCargandoDatosTarjeta or this.lSeteandoCondicionDePago or this.lEstaCargandoValoresAplicablesParaVuelto
		return llRetorno
	endfunc 
	
enddefine

*----------------------------------------------------------------------------------------
*----------------------------------------------------------------------------------------
*----------------------------------------------------------------------------------------
Define Class ItemDetalleMontoGravado as Custom
	TotalConImpuestos = 0 
	TotalMonto = 0
	PorcentajeIva = 0
	RecargoComprobante = 0
	DescuentoComprobante = 0
	TotalPercepciones = 0
	PorcentajeRepresentativoSobreElTotal = 0
	nMontoDeRecargoQueRepresentaElMontoGravado = 0
Enddefine

*----------------------------------------------------------------------------------------
*----------------------------------------------------------------------------------------
*----------------------------------------------------------------------------------------
Define Class ArgumentoEventoSeleccionDeSeniasPendientes as Custom
	cXMLSeniasPendientes = ""
	cXMLSeniasSeleccionadas = ""
Enddefine

*----------------------------------------------------------------------------------------
*----------------------------------------------------------------------------------------
*----------------------------------------------------------------------------------------
Define Class ItemDetalleImpuestos as Custom
	Alicuota = 0
	Monto = 0
	BaseImponible = 0
	Descuento = 0
	Recargo = 0
	AjusteConImpuesto = 0
	AjusteSinImpuesto = 0
Enddefine
