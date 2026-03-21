define class Ent_Comprobante as Din_Comprobante of Din_Comprobante.prg

	#if .f.
		local this as ent_Comprobante of ent_Comprobante.prg
	#endif

	#define TIPOVALORAJUSTEDECUPON  10
	#define TIPOVALORCIRCUITOCHEQUETERCERO	12
	#define TIPOVALORCIRCUITOCHEQUEPROPIO  	14

	cDetalleComprobante = "MovimientoDetalle"
	Numero = 0
	lEsComprobanteConStock = .T.
	Guid = ""
	lInvertirSigno = .f.
	Fecha = {}
	cComprobante = ""
	lActualizandoSaldos = .f.
	lValidarAlModificar = .T.
	lAfectaCaja = .T.
	lSoloAfectaCaja = .f.
	Situacionfiscal_Pk = 0
	lRecalcularPorCambioDeListaDePrecios = .T.
	lCambioSituacionFiscal = .f.
	lCambioListaPrecios = .f.
	lCambioFecha = .f.
	lMostrarAdvertenciaRecalculoPrecios = .T.
	llPermiteTipoAjusteDeCupon  = .f.
	lItemControlaDisponibilidad = .f.
	lCancelaDiferenciasDePicking = .f.
	oValidadores = null
	oColaboradorValidacionControlDeStockDiponible = null
	oColaboradorValidacionMinimoDeReposicion = null
	cParametroPreciosNuevoEnBaseA = ""
	lUtilizaSecuenciaFiscal = .f.
	lUsoBuscador = .f.
	lCargandoRecargo = .f.
	oLogueadorOperacionesAvanzadas = null
	oDetalleCompOmnicanalidad = null
	cEvento = ""
	lEstaElKontroler = .f.
	oAfectanteAuxiliar = null	
	oFormularioAfectanteAuxiliar = null
	lTieneFuncionalidadesEnBaseA = .f.
	lAfectada = .f.
	lEsComprobanteDeMovimientoDeFondos = .f.
	lPidiendoCotizacion = .f.
	oBuzon = null
	oMoneda = null
	oItemAuxCotiza = null
	oCacheAfectantes = null
	cDisenoComprobanteAdjunto = ""
	cMonedaSistemaDefault = ""
	oColCombinacionesYaProcesadas = null
	lAgruparPacksAutomaticamente = .f.
	nParamAgrupamientoDePacks = 0
	lPermiteAgruparPacksAutomaticamente = .f.
	lDebeAdvertirFaltantedestock = .t.
	oColaboradorCheques = null
	oEntidadCotizacion = null
	
	*-----------------------------------------------------------------------------------------
	function EventoPorInsertar() as Void

	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function oColaboradorValidacionControlDeStockDiponible_Access() as variant
		if !this.ldestroy and ( !vartype( this.oColaboradorValidacionControlDeStockDiponible ) = 'O' or isnull( this.oColaboradorValidacionControlDeStockDiponible ) )
			this.oColaboradorValidacionControlDeStockDiponible = _Screen.Zoo.CrearObjeto( "ColaboradorValidacionControlDeStockDiponible" )
		endif
		return this.oColaboradorValidacionControlDeStockDiponible
	endfunc
	
	*--------------------------------------------------------------------------------------------------------
	function oColaboradorValidacionMinimoDeReposicion_Access() as variant
		if !this.ldestroy and ( !vartype( this.oColaboradorValidacionMinimoDeReposicion ) = 'O' or isnull( this.oColaboradorValidacionMinimoDeReposicion ) )
			this.oColaboradorValidacionMinimoDeReposicion = _Screen.Zoo.CrearObjeto( "ColaboradorValidacionMinimoDeReposicion" )
		endif
		return this.oColaboradorValidacionMinimoDeReposicion
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function oLogueadorOperacionesAvanzadas_access() as variant
		if !this.ldestroy and (type("this.oLogueadorOperacionesAvanzadas") <> 'O' or isnull(this.oLogueadorOperacionesAvanzadas))
			this.oLogueadorOperacionesAvanzadas = _screen.Zoo.CrearObjeto( "LogueoOperacionesAvanzadas" )
		endif
		return this.oLogueadorOperacionesAvanzadas
	endfunc

	*-----------------------------------------------------------------------------------------
	Function Init( t1, t2, t3, t4 ) As Boolean
		Local llRetorno As Boolean
		llRetorno = DoDefault(t1, t2, t3, t4 )
		if llRetorno and pemstatus( this, "IvaDelSistema", 5 )
			this.IvaDelSistema = goParametros.Felino.DatosImpositivos.IvaInscriptos
			if type( "this.ImpuestosDetalle" ) = "O"
				this.ImpuestosDetalle.nIvaDelSistema = this.IvaDelSistema		
			endif
			if type( "this.oComponenteFiscal" ) = "O"
				this.oComponenteFiscal.nIvaInscriptos = this.IvaDelSistema
			endif
			if type( "this.oComponenteFiscal.oComponenteImpuestos" ) = "O"
				this.oComponenteFiscal.oComponenteImpuestos.nIvaInscriptos = this.IvaDelSistema
			endif
			if type( "this.ArticulosSeniadosDetalle.oItem.oComponenteFiscal" ) = "O"
				this.ArticulosSeniadosDetalle.oItem.oComponenteFiscal.nIvaInscriptos = this.IvaDelSistema
			endif
			if type( "this.KitsDetalle.oItem.oComponenteFiscal" ) = "O"
				this.KitsDetalle.oItem.oComponenteFiscal.nIvaInscriptos = this.IvaDelSistema
			endif
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		local lcDetalle as String
		dodefault()
		if type( "this." + This.cDetalleComprobante ) = "O"
			lcDetalle = This.cDetalleComprobante
			if This.lEsComprobanteConStock
				if this.lDebeAdvertirFaltantedestock
					This.Enlazar( This.cDetalleComprobante + ".EventoSetearsidebeAdvertirFaltantedeStock", "SetearsidebeAdvertirFaltantedeStock" )
				endif
				This.Enlazar( This.cDetalleComprobante + ".EventoNoHayStock", "EventoNoHayStock" )
				if pemstatus( this.&lcDetalle, "EventoAlcanzoMinimoDeReposicion", 5 )
					This.Enlazar( This.cDetalleComprobante + ".EventoAlcanzoMinimoDeReposicion", "EventoAlcanzoMinimoDeReposicion" )
				endif 	
				this.&lcDetalle..lItemControlaDisponibilidad = this.lItemControlaDisponibilidad
				with this.&lcDetalle..oitem
					.lInvertirSigno = This.lInvertirSigno
					if .lControlaStock
						.oCompStock.nSigno = iif( This.lInvertirSigno, -1, 1 )
						.oCompStock.lInvertirSigno = This.lInvertirSigno
						.oCompStock.InyectarEntidad( this )
					endif
				endwith
				if pemstatus( this.&lcDetalle..oitem, "EventoInformarArticuloConColorOTalleFueraDePaletaOCurva", 5 )
					this.BindearEvento( this.&lcDetalle..oitem, "EventoInformarArticuloConColorOTalleFueraDePaletaOCurva", this, "EventoInformarArticuloConColorOTalleFueraDePaletaOCurva")		
				endif
				if pemstatus( this.&lcDetalle..oitem, "EventoSetearItemDespuesDeExcepcionFueraDePaletaOCurva", 5 )
					this.BindearEvento( this.&lcDetalle..oitem, "EventoSetearItemDespuesDeExcepcionFueraDePaletaOCurva", this, "EventoSetearItemDespuesDeExcepcionFueraDePaletaOCurva")		
				endif
			endif
			this.enlazar( "cContexto", "SetearContexto" )
		endif
		if This.TieneFuncionalidadBasadoEn()
			this.lTieneFuncionalidadesEnBaseA = .t.
			This.oCompEnBaseA.lGestionDeVentas = ( "<VENTAS>" $ this.ObtenerFuncionalidades() )
			this.enlazar( "oCompEnBaseA.EventoFallaDeValidacion", "EventoFallaDeValidacionEnComponenteEnBaseA" )
			this.BindearEvento( This.FacturaDetalle.oItem, "EventoAntesDeSetear", this, "AntesDeProcesarItemArticulosPorBasadoEn" )
			this.FacturaDetalle.oItem.esComprobanteEnBaseARestringido()
			bindevent( this.FacturaDetalle, "Actualizar", this, "RestablecerSaldosAfectados" )
			bindevent( this.FacturaDetalle, "Actualizar", this, "ValidarIngresoManualEnBaseA", 1 )
			bindevent( this.FacturaDetalle, "Actualizar", this, "LimpiarVariablesPorOperatoria" )
		endif
		if "<VENTAS>" $ this.ObtenerFuncionalidades()
			bindevent( This.oAd, "ConsultarPorClaveCandidata", This, "CompletarCampoSecuencia" )
		endif
		this.ObtenerMonedaSistemaDefault()
		this.nParamAgrupamientoDePacks = goParametros.Felino.GestionDeVentas.AgruparAutomaticamenteLosArticulosDeTipoPackAlRealizarUnaFacturaDeVenta
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function CompletarCampoSecuencia() as Boolean
		* Se sobreescribe en las entidades de comprobantes fiscales (ticketfactura, ticketnotadecredito, ticketnotadedebito)
		return .T.
	endfunc 

	*-------------------------------------------------------------------------------------
	protected function ValidarSiFueGeneradoPorUnaMercaderiaEnTransito() as Boolean
		local llRetorno as Boolean, lnPosicion as Integer
		
		llRetorno = .f.
		lnPosicion = 1

		do while !llRetorno and lnPosicion <= this.compafec.count
			if alltrim( this.compafec.item[lnPosicion].nombreEntidad ) == "MERCADERIAENTRANSITO"
				This.AgregarInformacion( "Este comprobante ha sido generado por la ";
				+ alltrim( this.compafec.item[1].tipocompcaracter ) + ". No puede anularse" )
				llRetorno = .t.
			else
				lnPosicion = lnPosicion + 1
			endif
		enddo 

		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Nuevo() as Void
		dodefault() 
		this.ValidarPedirCotizacionObligatoria( this.Fecha )
		this.SetearMonedaSistemaDefault()
		if This.lEsComprobanteConStock
			This.SetearStockInicial()
		EndIf	
		This.LimpiarBasadoEn()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Cancelar() as Void
		dodefault()
		if This.TieneFuncionalidadBasadoEn()
			This.oCompEnBaseA.lCancelaDiferenciasDeInterviniente = .f.
			if vartype( this.oCompEnBaseA.oEntidadAfectante ) = "O" 
				this.oCompEnBaseA.oEntidadAfectante.lCancelaDiferenciasDePicking = .f.
			endif
			This.oCompEnBaseA.oRelacionPickingComprobante.Remove( -1 )
			this.oCompEnBaseA.LimpiarOperatoria()
			this.FacturaDetalle.oItem.lPrecioAMano = .f.
		Endif
		this.oLogueadorOperacionesAvanzadas.Limpiar()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerMonedaSistemaDefault() as Void
		if pemstatus(this,"MonedaSistema_pk",5)
			this.cMonedaSistemaDefault = rtrim( goServicios.Parametros.Felino.Generales.MonedaSistema )
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function SetearMonedaSistemaDefault() as Void
		if pemstatus(this,"MonedaSistema_pk",5)
			this.MonedaSistema_pk = this.cMonedaSistemaDefault
			if pemstatus(this,"ValorSugeridoMonedaSistema",5)
				this.ValorSugeridoMonedasistema()
			endif
		endif
	endfunc 
	
	*--------------------------------------------------------------------------------------------------------
	function Setear_MonedaComprobante( txVal as variant ) as void
		dodefault( txVal )
		
		if !empty( txVal )
			this.EventoSetearMonedaComprobante()
			this.SetearMonedaComprobante()
			this.SimboloMonetarioComprobante = this.MonedaComprobante.Simbolo
			this.SetearCotizacion()
		endif
		if vartype( this.ListaDePrecios ) = "O" and this.ListaDePrecios.Moneda_Pk != txVal and !empty( this.ListaDePrecios_Pk )
			this.ListaDePrecios_Pk = ""
			if this.DebeCambiarListaDePrecios()
				this.ListaDePrecios_Pk = this.Cliente.ListaDePrecio_Pk
				&&this.lCambioMonedaComprobante = .f.
			endif
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EventoSetearMonedaComprobante() as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function DebeCambiarListaDePrecios() as Boolean
		return .f.
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearMonedaComprobante() as Void
		local lcMoneda as String, llPermiteEmitirEnMonedaExtranjera as Boolean

		llPermiteEmitirEnMonedaExtranjera = this.PermiteEmitirMonedaExtranjera()

		if llPermiteEmitirEnMonedaExtranjera and !empty( this.MonedaComprobante_Pk )
		else
			with this
				if pemstatus(this,"MonedaSistema_pk",5) and !empty( this.MonedaSistema_pk )
					lcMoneda = this.MonedaSistema_pk
				else
					try
						lcMoneda	= goParametros.Felino.Generales.MonedaSistema
						lcMoneda	= iif(empty(alltrim(lcMoneda)), .ListaDePrecios.Moneda_Pk, lcMoneda )
					catch to loError
						goServicios.Errores.LevantarExcepcion( "No se puede realizar el comprobante ya que no tiene moneda del comprobante.  Debe configurar el parámetro Moneda de sistema desde Parámetros del sistema -> Generales." )
					endtry
				Endif
				.MonedaComprobante_Pk = lcMoneda
				.SimboloMonetarioComprobante = .MonedaComprobante.Simbolo
			endwith
		endif
		
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function PermiteEmitirMonedaExtranjera() as Boolean
		return .f.
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function PedirCotizacionParaLaFechaDelComprobante() as Void
		return .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearCotizacion() as Void
		local loex as exception, ldFechaUltCotizacion as Date
		
		if empty( this.MonedaComprobante_Pk )
			loex = newobject(  "zooexception", "zooexception.prg" )
			with loex
				.message = "Error en la moneda del comprobante"
				.details = .message
				.grabar()
				.throw()
			endwith
		else
			this.SetearMonedaEnDetalleValoresParaActualizarCotizacion()
			if alltrim( goParametros.Felino.Generales.MonedaSistema ) = alltrim( this.MonedaComprobante_PK )
				this.cotizacion = 1
			else
				if this.PedirCotizacionParaLaFechaDelComprobante()
					this.Cotizacion = this.MonedaComprobante.ObtenerCotizacion( this.Fecha )	
					if this.Cotizacion = 0 and !empty( this.fecha )
						this.PedirCotizacionNueva()
					endif
				else
					*ldFechaUltCotizacion  = this.&loDetalle..oMoneda.ObtenerFechaUltimaCotizacion( this.Fecha )
					ldFechaUltCotizacion = this.ObtenerFechaDeUltimaCotizacion()
					this.Cotizacion = this.MonedaComprobante.ObtenerCotizacion( ldFechaUltCotizacion , this.MonedaComprobante_PK, goParametros.Felino.Generales.MonedaSistema )
				endif
			endif
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerItemAuxiliarCotizacion() as Void
		local loRetorno as object
		loRetorno = _screen.zoo.crearObjeto( "ItemAuxCotiza" )
		with loRetorno 
			.Moneda = alltrim( this.MonedaComprobante_pk )
			.FechaUltimaCotizacion = this.MonedaComprobante.ObtenerFechaUltimaCotizacion()
			.FechaNuevaCotizacion = this.Fecha
			.MontoUltimaCotizacion = this.MonedaComprobante.ObtenerCotizacion( .FechaUltimaCotizacion )
			.MontoNuevaCotizacion = .MontoUltimaCotizacion
		endwith
		return loRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ValidarSiEsComprobanteEnMonedaExtranjera() as Boolean
		local llRetorno as Boolean
		llRetorno = .F.
		with this
			if rtrim( .MonedaSistema_Pk ) != iif( pemstatus( this, "MonedaComprobante_Pk", 5 ), rtrim( .MonedaComprobante_Pk ), rtrim( .MonedaComprobante ) )
				llRetorno = .T.
			endif
		endwith
		return llRetorno 
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ActualizarCotizacionMoneda( txVal as variant ) as Void
		local lcCotizacionAFecha as Number
		with this.oEntidadCotizacion
			.Moneda_Pk = rtrim( this.MonedaComprobante_Pk )
			lcCotizacionAFecha = .Moneda.ObtenerCotizacion( this.Fecha )
		endwith
		if !empty( lcCotizacionAFecha ) and lcCotizacionAFecha != txVal
			this.AgregarCotizacionMoneda( txVal )
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function AgregarCotizacionMoneda( txVal as variant ) as Void
		local loError as Object
		with this.oEntidadCotizacion
			try
				.Nuevo()
				.Moneda_Pk = this.MonedaComprobante_Pk
				.NuevaFecha = this.Fecha
				.NuevaCotizacion = txVal 
				.Grabar()
			catch to loError
			endtry
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerFechaDeUltimaCotizacion() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function PedirCotizacionNueva() as Void
		local lcMonedaSugerida as String, lcMonedaComprobante as String, lcMonedaCotizacion as String

		if goServicios.Seguridad.PedirAccesoEntidad( this.MonedaComprobante.ObtenerNombre(), "MODIFICAR", .F., this.MonedaComprobante.ObtenerDescripcion() )
			this.lPidiendoCotizacion = .t.
			this.oItemAuxCotiza = this.ObtenerItemAuxiliarCotizacion() 
			this.IngreseCotizacion()
			lcMonedaSugerida = alltrim( goParametros.Felino.Generales.MonedaSistema )
			lcMonedaComprobante = alltrim( this.MonedaComprobante_PK )
			if this.Cotizacion = 0 
				lcMonedaDeMensaje = this.MonedaComprobante.Descripcion
				goServicios.Errores.LevantarExcepcion( "No se cargó la cotización de la moneda " + alltrim( lcMonedaDeMensaje ) + "." )
			else					
				this.GrabarCotizacion( this.oItemAuxCotiza, lcMonedaComprobante )
			endif
			this.lPidiendoCotizacion = .f.
		else
			goServicios.Errores.LevantarExcepcion( "Se requieren permisos para modificar la cotización de una moneda." )
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function IngreseCotizacion() as String
	endfunc 
	
	*-----------------------------------------------------------------------------------------	
	function MayusculaEnCodigosDelDetalleContextoRest() as Void
		if ( vartype( this.facturadetalle ) = "O" and pemstatus( this,"cContexto", 5 ) and upper(alltrim( this.cContexto )) = "R" )
			for each loItem in this.facturadetalle
				loItem.articulo_pk = upper(loItem.articulo_pk)
				loItem.color_pk = upper(loItem.color_pk)
				loItem.talle_pk = upper(loItem.talle_pk)		
			endfor
		endif
	endfunc	
	
	*-----------------------------------------------------------------------------------------	
	function AntesDeGrabar() as Boolean
		local llAntesDeGrabar as Boolean
		this.RecorrerYAcumular()
		this.cEvento = "AntesDeGrabar"
		this.MayusculaEnCodigosDelDetalleContextoRest()
		llAntesDeGrabar = dodefault()
		if llAntesDeGrabar
			if this.verificarContexto( "B" ) and this.EsNuevo()
				this.fecha = date()	
			endif
		endif
		this.oColCombinacionesYaProcesadas.Remove(-1)
		return llAntesDeGrabar
	endfunc	

	*-----------------------------------------------------------------------------------------
	function Modificar() as Void
		dodefault()
		
		if This.lEsComprobanteConStock
			this.GuardarDetalleOriginalAAnularOModificar()
			This.SetearStockInicial()
		EndIf	
		if !this.lActualizandoSaldos and This.TieneFuncionalidadBasadoEn()
			if this.lValidarAlModificar
				this.ValidarComprobantesAfectantes( "Modificar" )
			endif
			this.oCompEnBaseA.ActualizarDetalleEntidadAfectanteParaModificar( this )
			this.oCompEnBaseA.nSigno = 1
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function ModificarSinValidarAfectados() as Void
		this.lValidarAlModificar = .f.
		this.Modificar()
		this.lValidarAlModificar = .t.
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function AntesdeAnular() as Void
		this.GuardarDetalleOriginalAAnularOModificar()
		this.cEvento = "AntesDeAnular"
		dodefault()
		if This.TieneFuncionalidadBasadoEn()
			.oCompEnBaseA.nSigno = -1
			.oCompEnBaseA.ResguardarDetalleAfectanteAntesDeAnularEntidadAfectante( this )
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function SetearStockInicial() as Void
		local loDetalle as Object
		if This.lEsComprobanteConStock
			loDetalle = This.cDetalleComprobante
			This.&loDetalle..SetearStockInicial()
		Endif	
	endfunc

	*-----------------------------------------------------------------------------------------
	function Eliminar() as Void
		This.InicializarComponentes()
		This.LimpiarBasadoEn()
		this.RestaurarStock()
		dodefault()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EliminarStockInicial() as Void
		local loDetalle as Object
		if This.lEsComprobanteConStock
			loDetalle = This.cDetalleComprobante
			This.&loDetalle..EliminarStockInicial()
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function RestaurarStock() as Void
		local loDetalle as Object
		if This.lEsComprobanteConStock
			loDetalle = This.cDetalleComprobante
			If this.&loDetalle..oItem.lControlaStock
				This.&loDetalle..SetearStockInicial()
			endif
		Endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function Setear_Situacionfiscal( txVal as variant ) as void
		if ( This.EsNuevo() or This.EsEdicion() ) and txVal = 0
			txVal = goServicios.Registry.Felino.SituacionFiscalClienteConsumidorFinal
		Endif
		this.Situacionfiscal.Codigo = txVal
	endfunc

	*-----------------------------------------------------------------------------------------
	function Setear_tipo( txVal as Variant ) as Void
		dodefault( txVal )
		local loDetalle as Object
		if This.lEsComprobanteConStock
			loDetalle = This.cDetalleComprobante
			this.&loDetalle..tipo = txVal
			do case
				case txVal = 1
					this.&loDetalle..oitem.lInvertirSigno = .T.
					this.&loDetalle..oitem.oCompStock.lInvertirSigno = .T.
					this.&loDetalle..oitem.oCompStock.nSigno = -1
					this.&loDetalle..oitem.lPermiteCantidadesNegativas = .F.				
				Case txVal = 2
					this.&loDetalle..oitem.lInvertirSigno = .F.
					this.&loDetalle..oitem.oCompStock.lInvertirSigno = .F.				
					this.&loDetalle..oitem.oCompStock.nSigno = 1
					this.&loDetalle..oitem.lPermiteCantidadesNegativas = .F.
				case txVal = 3
					this.&loDetalle..oitem.lInvertirSigno = .T.
					this.&loDetalle..oitem.oCompStock.lInvertirSigno = .T.				
					this.&loDetalle..oitem.oCompStock.nSigno = -1
					this.&loDetalle..oitem.lPermiteCantidadesNegativas = .T.
			EndCase
		Endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function SetearsidebeAdvertirFaltantedeStock( tlValor as boolean ) as Void
		this.lDebeAdvertirFaltantedestock = !tlValor 
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EventoNoHayStock( toInformacion ) as Void
		local loEx As zooException of zooException.prg, ;
			loComportamientoNoHayStock as ComportamientoNoHayStock of ComportamientoNoHayStock.prg
		
		if This.lEsComprobanteConStock and this.lDebeAdvertirFaltantedestock 
			loComportamientoNoHayStock = _screen.zoo.crearobjeto( "ComportamientoNoHayStock", "ComportamientoNoHayStock.prg", this.oMensaje )
			if parameters() > 0
				loComportamientoNoHayStock.oInformacion = toInformacion 
			endif
			loComportamientoNoHayStock.Ejecutar()
			*this.lDebeAdvertirFaltantedestock = .t.
		Endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoAlcanzoMinimoDeReposicion( toInformacion ) as Void
		local loComportamientoMinimoDeReposicion as ComportamientoMinimoDeReposicion of ComportamientoMinimoDeReposicion.prg, llPermitePasar as Boolean
			
		if This.lEsComprobanteConStock
			loComportamientoMinimoDeReposicion = _screen.zoo.crearobjeto( "ComportamientoMinimoDeReposicion", "ComportamientoMinimoDeReposicion.prg", this.oMensaje )
			if parameters() > 0
				loComportamientoMinimoDeReposicion.oInformacion = toInformacion 
			endif
			llPermitePasar = this.NoPermitePasarAlSuperarMinimoDeReposicion()
			loComportamientoMinimoDeReposicion.Ejecutar( llPermitePasar )
		Endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function VotacionCambioEstadoANULAR( tcEstado as String ) as void
		return .T.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Validar() as boolean
		local llRetorno as boolean, lcDetalle as String
		llRetorno = dodefault()

		if this.ControlaStockDisponible()
			llRetorno = llRetorno and this.ValidarStockDispoibleAlGrabar()
		endif
		
		if this.ValidaMinimoDeReposicionAlGrabar()
			llRetorno = llRetorno and this.ValidarMinimoDeReposicionAlGrabar()
		endif

		if !This.ValidarEquivalencias()
			lcDetalle = This.cDetalleComprobante
			this.AgregarInformacion( "No se permite realizar un comprobante sin " + ;
				alltrim( this.&lcDetalle..oItem.Equivalencia.ObtenerDescripcion() ), 1 )
			llRetorno = .F.
		endif
		
		&& Si esta haciendo un cambio y agrega un recargo cuando la grilla de articulos tiene subtotal en 0	
		if llRetorno and This.ExisteMontoDeRecargoEnUnCambio()
			this.AgregarInformacion( "No se puede agregar montos de recargo si el subtotal de artículos es 0." )
			llRetorno = .F.
		endif
		
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function oValidadores_Access() as Void
        if this.ldestroy
        else
              if !vartype( this.oValidadores ) = 'O' or isnull( this.oValidadores )
					loFactoryValidadoresComprobantes = _screen.zoo.crearobjeto( "FactoryValidadoresDeComprobantes", "FactoryValidadoresDeComprobantes.prg" )
					this.oValidadores = loFactoryValidadoresComprobantes.ObtenerColeccionValidadores( this )
					this.enlazar( 'oValidadores.EventoObtenerInformacion', 'inyectarInformacion' )
					this.oValidadores.PasarInformacion()
                    release loFactoryValidadoresComprobantes
              endif
        endif
        return this.oValidadores
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function oEntidadCotizacion_Access() as Void
		if !this.lDestroy and !( vartype( this.oEntidadCotizacion ) == "O" )
			this.oEntidadCotizacion = _screen.zoo.instanciarentidad( "Cotizacion" )
		endif
		return this.oEntidadCotizacion
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ValidarEquivalencias as Boolean
		local lcDetalle as Object, i as Integer, llRetorno as Boolean, loItem as Object

		llRetorno = .t.
		if this.DebeValidarItemsSinEquivalencias()
			lcDetalle = This.cDetalleComprobante
			if pemstatus( this, lcDetalle, 5 )
			
				for i = 1 to this.&lcDetalle..count
					loItem = evaluate( "this." + lcDetalle + ".Item[" + transform( i ) + "]" )
					if !empty( loItem.Articulo_pk ) and pemstatus( loItem, "Equivalencia_pk", 5 ) and empty( loItem.Equivalencia_pk )
						llRetorno = .f.
						exit
					endif
				endfor

			endif
		endif
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function DebeValidarItemsSinEquivalencias() as Void
		return goParametros.Felino.CodigosDeBarras.HabilitarLectura ;
			and goParametros.Felino.CodigosDeBarras.VerificarExistenciaDeEquivalenciaEnLectura ;
			and !goParametros.Felino.CodigosDeBarras.PermitirRealizarComprobantesSinEquivalencias
	endfunc

	*-----------------------------------------------------------------------------------------
	function SetearContexto() as Void
		local lcDetalle as String
		
		if type( "this." + This.cDetalleComprobante ) = "O"
			lcDetalle = This.cDetalleComprobante
			this.&lcDetalle..oItem.cContexto = this.cContexto 
		endif
	endfunc
	
	*--------------------------------------------------------------------------------------------------------
	function VotacionCambioEstadoELIMINAR() as Boolean
		local llVotacion as boolean, ll as boolean
		llVotacion = dodefault()

		if goServicios.Seguridad.PedirAccesoEntidad( this.cComprobante , "ELIMINARTRANSFERIDO" )
		else
			llVotacion = .f.
			this.AgregarInformacion( 'No posee permisos para eliminar el comprobante ' + this.ObtenerDescripcion() + " transferido." )
		endif
		
		return llVotacion
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValorPermitidoParaComprobante( tnTipoValor as Integer ) as Boolean
		local llRetorno as Boolean

		llRetorno = .t.
		if !this.llPermiteTipoAjusteDeCupon 
			if inlist(  tnTipoValor, TIPOVALORAJUSTEDECUPON )
				llRetorno = .f.
			endif
		endif

		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerNombresValidadores() as zoocoleccion 
		local loNombreDeValidadores as zoocoleccion OF zoocoleccion.prg
		
		loNombreDeValidadores = _screen.zoo.crearobjeto( "zoocoleccion" )
		loNombreDeValidadores.Add( "ValidadorComprobanteConValores" )

		return loNombreDeValidadores
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoVerificarValidezArticulo( toArticulo as entidad OF entidad.prg ) as Boolean
		return This.oValidadores.VALIDADORCOMPROBANTECONVALORES.EventoVerificarValidezArticulo( toArticulo )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoSetearFiltroBuscadorArticulo( toEntidad as entidad OF entidad.prg ) as Boolean
		return This.oValidadores.VALIDADORCOMPROBANTECONVALORES.EventoSetearFiltroBuscadorArticulo( toEntidad )
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerEstadoDeStockDeComprobante( tcEntidad ) as String  
		local lcRetorno as String 
		lcRetorno = dodefault( tcEntidad ) 
		if empty( lcRetorno )
			lcRetorno = "CANTIDAD"
		Endif	
		return lcRetorno 
	endfunc 		

	*-----------------------------------------------------------------------------------------
	function ModificaStockBasadoEn() as Boolean
		return This.HayBasadoEn() and this.oCompEnBaseA.ModificaAfeStock( This.ObtenerNombre() )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsUnItemAfectado( toItem as Object ) as Boolean
		return This.TieneFuncionalidadBasadoEn() and this.oCompEnBaseA.EsUnItemAfectado( toItem )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function TieneFuncionalidadBasadoEn() as Boolean
		return pemstatus( this, "oCompEnBaseA", 5 )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function HayBasadoEn() as Boolean
		return this.TieneFuncionalidadBasadoEn() and this.oCompEnBaseA.HayBasadoEn()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function NuevoBasadoEn() as Void
		with this
			try
				.EsEntidadQuePermiteNuevoBasadoEn()
			catch to loError
				goServicios.Errores.LevantarExcepcion( loError )
			endtry
			if this.DebeHacerNCCancelatoria()
				this.HacerNCCanceltatoria()
			else
				.Nuevo()
				if pemstatus( this, "oCompEnBaseA", 5 ) and ( !isnull( this.oCompEnBaseA ) )
					.oCompEnBaseA.nSigno = 1
					.oCompEnBaseA.InyectarEntidadAfectante( this )
					.oCompEnBaseA.InyectarConsulta()
					.EventoDespuesDeCargarEnBaseA()
				endif
			endif
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function EsEntidadQuePermiteNuevoBasadoEn() as Void
		local lcMotivo as String
		
		lcMotivo = ""
		if !_Screen.Zoo.App.PermiteABM( this.oAd.cTablaPrincipal )
			lcMotivo = " porque la sucursal " + _screen.zoo.app.ObtenerSucursalActiva() + " pertenece a una base réplica."
		endif
		if !empty( lcMotivo )
			goServicios.Errores.LevantarExcepcion( "La entidad " + ;
				alltrim( this.cDescripcion ) + " no permite hacer nuevo basado en" + lcMotivo )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AntesDeProcesarItemArticulosPorBasadoEn( toItem as Object, tcAtributo as String, txValOld as Variant, txValActual as Variant ) as Void
		local lcAtributo as String
		lcAtributo = upper( alltrim( tcAtributo ) )
		&& Chequeo que no se pueda modificar un atributo del stock si es un item afectado
		&& el atributo que se modifica es uno de la combinacion del stock menos articulo - ( ya no 12/2017, dejaba cambiar el código de artículo y no perdía la relación )
		&& y que los atributosStock sean los mismos en el afectado y en el afectante
		if txValOld != txValActual and This.EsUnItemAfectado( toItem )
			if lcAtributo = "ARTICULO_PK" and txValActual = ""
			else
				if This.FacturaDetalle.oItem.lControlaStock and This.VerificarAtributoEnCombinacion( lcAtributo )
					if This.VerificarDiferenciasDeAtributosStock( This.ObtenerEntidadAfectada( toItem ) ) and this.VerificarOperatoriaEnBaseA()
						toItem.&lcAtributo = txValOld
						goServicios.Errores.LevantarExcepcion( "El artículo y su combinación está afectado en el comprobante origen." + chr( 13 ) + chr( 10 ) + "No está permitido cambiar el valor del atributo." )
					Endif	
				endif
			endif
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function VerificarAtributoEnCombinacion( tcAtributo as String ) as Boolean
		local llRetorno as Boolean
		llRetorno = pemstatus( This.FacturaDetalle.oItem, "oCompStock", 5 ) and vartype( This.FacturaDetalle.oItem.oCompStock ) == 'O' and This.FacturaDetalle.oItem.oCompStock.EstaEnOCombinacion( tcAtributo )
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function VerificarOperatoriaEnBaseA() as Boolean
		local llRetorno as Boolean
		llRetorno = pemstatus( This, "oCompEnBaseA", 5 ) and vartype( this.oCompEnBaseA ) == 'O' and !this.oCompEnBaseA.UtilizaNuevaOperatoria()
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function VerificarDiferenciasDeAtributosStock( tcEntidad as String ) as boolean
		local lcAtributoStockAfectante as String, lcAtributoStockAfectado as String	
		lcAtributoStockAfectante = This.ObtenerEstadoDeStockDeComprobante( This.ObtenerNombre() )
		lcAtributoStockAfectado = This.ObtenerEstadoDeStockDeComprobante( tcEntidad )
		return lcAtributoStockAfectado = lcAtributoStockAfectante
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsUnItemTablaAfectado( toItem as Object ) as Boolean
		return This.TieneFuncionalidadBasadoEn() and this.oCompEnBaseA.EsUnItemTablaAfectado( toItem, this )
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerSignoEntidadAfectada( tcEntidad as String ) as Boolean
		this.oCompEnBaseA.ObtenerSignoEntidadAfectada( tcEntidad )
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerEntidadAfectadaItemTabla( toItem as Object ) as String
		local lcRetorno as String
		if This.TieneFuncionalidadBasadoEn()
			lcRetorno = this.oCompEnBaseA.ObtenerEntidadAfectadaItemTabla( toItem, this )
		else
			lcRetorno = ""
		Endif		
		return lcRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerEntidadAfectada( toItem as Object ) as String
		local lcRetorno as String
		if This.TieneFuncionalidadBasadoEn()
			lcRetorno = this.oCompEnBaseA.ObtenerEntidadAfectada( toItem, this )
		else
			lcRetorno = ""
		Endif		
		return lcRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	function AgregarAtributosBasadoEn( toItemStock as Object, toItem as Object ) as Void
		This.oCompEnBaseA.AgregarAtributosBasadoEn( toItemStock, toItem )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearCombinacionAfectada( toItem as Object, toColeccion as Object ) as Void
		This.oCompEnBaseA.SetearCombinacionAfectada( toItem, toColeccion, This )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerEstadoDeStockDeComprobanteAfectado() as String
		return This.ObtenerEstadoDeStockDeComprobante( This.oCompEnBaseA.cNombreEntidadAfectada )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerInvertiSignoDeComprobanteAfectado() as Boolean
		Return This.oCompEnBaseA.ObtenerInvertiSignoDeComprobanteAfectado()
	endfunc

	*-----------------------------------------------------------------------------------------
	function LimpiarBasadoEn() as Void
		if This.TieneFuncionalidadBasadoEn()
			This.oCompEnBaseA.Limpiar()	
		Endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerColStockAfectado( toDetalle as ZooColeccion of ZooColeccion.Prg, toCombinacion as zoocoleccion OF zoocoleccion.prg ) as void
		This.oCompEnBaseA.ObtenerColStockAfectado( toDetalle, toCombinacion )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarComprobantesAfectantes( tcAccion as String ) as Void
		if this.oCompEnBaseA.EsComprobanteAfectado( this.cNombre ) and !this.oCompEnBaseA.ValidarComprobantesAfectantes( this, tcAccion )
			this.EventoHayComprobantesAsociados()
			if this.EsNuevo() or this.EsEdicion()
				this.Cancelar()
			endif
			goServicios.Errores.LevantarExcepcion( this.oCompEnBaseA.ObtenerInformacion() )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function RecalcularPorPrePantalla(toItemsCargados as ZooColeccion OF ZooColeccion.prg ) as Void
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function InicializarPreciosDeListaEnArticulos() as Void
		if type( "this.FacturaDetalle" ) = "O" and !isnull( this.FacturaDetalle )
			this.LlenarPrecioDeListaEnArticulos( this.FacturaDetalle )
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function LlenarPrecioDeListaEnArticulos( toDetalle as Object ) as Void
		local lnIndArt as Integer, loItem as Object
		with toDetalle
			for lnIndArt = 1 to .Count
				if .ValidarExistenciaCamposFijosItemPlano( lnIndArt )
					loItem = .item[ lnIndArt ]
					if loItem.UsarPrecioDeLista
						if this.ListaDePrecios.CondicionIva = 2
							loItem.PrecioDeLista = loItem.PrecioSinImpuestos
						else
							loItem.PrecioDeLista = loItem.PrecioConImpuestos
						endif
					endif
				endif
			endfor
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function RecalcularPorCambioDeListaDePrecios( txVal as Variant ) as Void
		if This.lRecalcularPorCambioDeListaDePrecios
			if type( "this.FacturaDetalle" ) = "O"
				this.FacturaDetalle.RecalcularPorCambioDeListaDePrecios( txVal )
			endif
			this.RecalcularPreciosDeDetallesAdicionales( txVal )
			if type( "This.oComponenteFiscal" ) = "O"
				this.ActualizarDetalleArticulos()
				this.RecalcularImpuestosDetalleArticulos()
				This.CalcularTotal()
			EndIf	
			if type( "this.FacturaDetalle" ) = "O"
				this.SubTotalBruto = this.FacturaDetalle.Sum_Bruto
				this.SubTotalNeto = this.FacturaDetalle.Sum_Neto
			endif
		Endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ActualizarDetalleArticulos() as Void
		if type( "this.FacturaDetalle" ) = "O" and !isnull( this.FacturaDetalle )
			this.EventoSetearItemAntesDeActualizaDetalleArticulos()
			This.oComponenteFiscal.ActualizarDetalleArticulos( this.FacturaDetalle )
			this.ActualizarDetallesAdicionales()
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function RecalcularImpuestosDetalleArticulos() as Void
		if type( "this.FacturaDetalle" ) = "O" and !isnull( this.FacturaDetalle ) and !this.lEstaSeteandoValorSugerido
			this.oComponenteFiscal.RecalcularImpuestos( this.FacturaDetalle, this.ImpuestosDetalle )
			this.RecalcularImpuestosDetalleAdicionales()
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function RecalcularPreciosDeDetallesAdicionales( tcListaDePrecios as String ) as Void
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ActualizarDetallesAdicionales() as Void
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function RecalcularImpuestosDetalleAdicionales() as Void
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function DebeMostrarAdvertenciaRecalculoPrecios() as Boolean
		local llTieneCampoFijo as Boolean, llTieneArtCargados as Boolean, llRetorno as Boolean

		llRetorno = .F.
		if type( "this.FacturaDetalle" ) = "O"
			llTieneCampoFijo = this.FacturaDetalle.oItem.ValidarExistenciaCamposFijos()
			if llTieneCampoFijo
				llTieneArtCargados = this.FacturaDetalle.count > 0
			else
				llTieneArtCargados = this.ObtenerCantidadDeArticulosCargados() > 0
			endif
			
			llRetorno = this.lMostrarAdvertenciaRecalculoPrecios and ;
						( this.lCambioSituacionFiscal or this.lCambioListaPrecios or this.lCambioFecha ) and ;
		 				llTieneArtCargados 
	 	endif
	 				
	 	return llRetorno

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCantidadDeArticulosCargados() as Void
		local lnRetorno as Integer
		
		lnRetorno = 0
		if vartype( this.FacturaDetalle ) == "O" and pemstatus( this.FacturaDetalle, "CantidadDeItemsCargados", 5 )
			lnRetorno = this.FacturaDetalle.CantidadDeItemsCargados()
		endif
		
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SoportaPromociones() as Boolean
		return .F.
	endfunc

	*-----------------------------------------------------------------------------------------
	function EsComprobanteDeCaja() as Boolean
		local llRetorno as Boolean
		llRetorno = this.oComponente.ObtenerNumeroComprobante( this.cComprobante ) == 98
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------	
	function CorrespondeGenerarContracomprobante() as Boolean
		local llRetorno as Boolean
		llRetorno = .f.
		if this.EsComprobanteDeCaja() and this.CajaDestino_pk <> 0
			llRetorno = .t.
		endif
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function TienePromocionBancaria() as Boolean
		local llRetorno as Boolean
		llRetorno = .f.
		return ( llRetorno )
	endfunc

	*-----------------------------------------------------------------------------------------
	function FueGeneradoPorPromocionBancaria() as Boolean
		local llRetorno as Boolean
		llRetorno = .f.
		return ( llRetorno )
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoDespuesDeGrabarActualizarBarraDeAcciones() as Void
		&& Bindeo al kontroler
	endfunc		
	
	*-----------------------------------------------------------------------------------------
	function ObtenerNoCalculaPercepciones() as Boolean 
		&& Se reescribe en las entidades que tienen la posibilidad de no calcular percepciones desde el menú Acciones
		return .f.
	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	function TieneQueVerificarMinimoDeReposicion() as Boolean
		return .f.
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function NoPermitePasarAlSuperarMinimoDeReposicion() as Boolean
		return .f.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarAutomaticamenteNuevoEnBaseAInterviniente( tcNombreEntidadInterviniente as String, tcCodigoRegistroInterviniente as String, tlGeneraCancelacion as Boolean ) as Void
		local loSeleccionado as Object 
		with this
			.oCompEnBaseA.lGenerarAutomaticamenteNuevoEnBaseAInterviniente = .t.
			.oCompEnBaseA.lCancelaDiferenciasDeInterviniente = tlGeneraCancelacion 
			.oCompEnBaseA.cNombreEntidadAfectada = tcNombreEntidadInterviniente
			.oCompEnBaseA.nNumeroComprobanteAfectado = tcCodigoRegistroInterviniente
			.oCompEnBaseA.oNumeroComprobanteAfectado = _screen.zoo.crearobjeto( "zoocoleccion" )
			loSeleccionado = _screen.zoo.crearobjeto( "ItemSeleccionEnBaseA" )
			loSeleccionado.cValor = tcCodigoRegistroInterviniente
			loSeleccionado.cFiltro = "CODIGO"
			.oCompEnBaseA.oNumeroComprobanteAfectado.Add( loSeleccionado )	
			
			.oCompEnBaseA.cComprobantesValidos = this.ObtenerComprobantesValidosDeEnBasea()
			.oCompEnBaseA.InyectarEntidadesPrincipales( this, .oCompEnBaseA.InstanciarEntidad( tcNombreEntidadInterviniente ) )
			.oCompEnBaseA.QueTengoQueHacerConLosPreciosV2()
			.oCompEnBaseA.ObtenerCabeceraDeComprobante()
			.oCompEnBaseA.ObtenerDetalleDeComprobantes()

			.NuevoBasadoEn()
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerComprobantesValidosDeEnBasea() as String
		local loColeccion as zoocoleccion OF zoocoleccion.prg, lcComprobantesValidos as String
		lcComprobantesValidos = ""
		loColeccion	= this.oCompEnBaseA.ObtenerColeccionParaCombo( this.cNombre )
		for lnId = 1 to loColeccion.Count
			if !("PICKING" $ upper( loColeccion.Item( lnId ).cNombre ))
				lcComprobantesValidos = lcComprobantesValidos + iif(lnId>1,",","") + upper( loColeccion.Item( lnId ).cNombre )
			endif
		endfor
		return lcComprobantesValidos
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoInformarArticuloConColorOTalleFueraDePaletaOCurva( toInformacion as Object ) as Void
		&& este metodo levanta el evento disparado por el colaborador para que lo pueda capturar el kontroler
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EventoSetearItemDespuesDeExcepcionFueraDePaletaOCurva() as Void
		&& este metodo levanta el evento disparado por el colaborador para que lo pueda capturar el kontroler
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EventoSetearItemAntesDeActualizaDetalleArticulos() as Void
	endfunc

	*-----------------------------------------------------------------------------------------
	function CompararAntesYDespuesDeModificar() as Object
		local lnContador as Integer, llSeEncontro as Boolean
		
		llSeEncontro = .F.

		if pemstatus( this, [ccomprobante] , 5 ) and alltrim(upper(this.ccomprobante)) == 'MOVIMIENTODESTOCK'
			for each loItem1 in this.movimientodetalle
				for each loItem2 in this.oDetalleCompOmnicanalidad
					if alltrim(loItem1.articulo_pk) == alltrim(loItem2.articulo_pk) and alltrim(loItem1.color_pk) == alltrim(loItem2.color_pk) and alltrim(loItem1.talle_pk) == alltrim(loItem2.talle_pk)
						llSeEncontro = .T.
					endif
				endfor
				if !llSeEncontro 
						
					this.oDetalleCompOmnicanalidad.Add( this.CargarObjetoAuxiliarOmnicanalidad(loItem1) )
					
				endif
				llSeEncontro = .F.
			endfor
		else
			for each loItem1 in this.facturadetalle
				for each loItem2 in this.oDetalleCompOmnicanalidad
					if alltrim(loItem1.articulo_pk) == alltrim(loItem2.articulo_pk) and alltrim(loItem1.color_pk) == alltrim(loItem2.color_pk) and alltrim(loItem1.talle_pk) == alltrim(loItem2.talle_pk)
						llSeEncontro = .T.
					endif
				endfor
				if !llSeEncontro 
				
					this.oDetalleCompOmnicanalidad.Add( this.CargarObjetoAuxiliarOmnicanalidad(loItem1) )

				endif
				llSeEncontro = .F.
			endfor
		endif
		
		return this.oDetalleCompOmnicanalidad
	endfunc 

	*-------------------------------------------------------------------------------------------------
	Function DespuesDeGrabar() As Boolean
		local llRetorno as Boolean
		this.cEvento = "DespuesDeGrabar"

		if goServicios.RealTime.ExisteCanalOmnicanalidad()
			this.EnviarActualizacionDeStockOmnicanalidad()
		endif
		if pemstatus(this, "oCompEnBaseA", 5)
			this.oCompEnBaseA.LimpiarOperatoria()
			this.FacturaDetalle.oItem.lPrecioAMano = .f.
		endif

		llRetorno = dodefault()
		this.lCancelaDiferenciasDePicking = .f.
		this.oLogueadorOperacionesAvanzadas.Loguear(this)
		
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EnviarActualizacionDeStockOmnicanalidad() as Void
		local loDetalleComp as Object, lnTipoComp as Integer, loex as exception
		
		do case
			case pemstatus( this, [tipocomprobante] , 5 ) and inlist(this.tipocomprobante,1,2,3,4,5,6,8,9,10,11,12,23,27,28,29,33,35,36,40,41,47,48,49)
				do case 
					case this.lEdicion
						loDetalleComp = this.CompararAntesYDespuesDeModificar()
					case this.lAnular
						loDetalleComp = this.oDetalleCompOmnicanalidad
					otherwise
						loDetalleComp = this.facturadetalle
				endcase
				lnTipoComp = this.tipocomprobante
			case pemstatus( this, [ccomprobante] , 5 ) and alltrim(upper(this.ccomprobante)) == 'MOVIMIENTODESTOCK'
				do case 
					case this.lEdicion
						loDetalleComp = this.CompararAntesYDespuesDeModificar()
					case this.lAnular
						loDetalleComp = this.oDetalleCompOmnicanalidad
					otherwise
						loDetalleComp = this.movimientodetalle
				endcase
				lnTipoComp = 0
			otherwise
				loDetalleComp = null
				lnTipoComp = -1
		endcase

		if !isnull(loDetalleComp) and lnTipoComp >= 0
			try
				goServicios.RealTime.AgregarStockOmnicanalidad( loDetalleComp, lnTipoComp )
			catch to loError
				loEx = newobject( "ZooException", "ZooException.prg" )
				with loEx
					.Grabar( loError )
				endwith
			endtry
		endif

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function DespuesDeAnular() as Void
		this.cEvento = "DespuesDeAnular"
		if goServicios.RealTime.ExisteCanalOmnicanalidad()
			this.EnviarActualizacionDeStockOmnicanalidad()
		endif
		dodefault()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function GuardarDetalleOriginalAAnularOModificar() as Void
		this.oDetalleCompOmnicanalidad = newobject("Collection")
		do case
			case pemstatus( this, [tipocomprobante] , 5 ) and inlist(this.tipocomprobante,1,2,3,4,5,6,8,9,10,11,12,23,27,28,29,33,35,36,40,41,47,48,49)
				for each loItem in this.facturadetalle
				
					this.oDetalleCompOmnicanalidad.Add( this.CargarObjetoAuxiliarOmnicanalidad(loItem) )
					
				endfor
			case pemstatus( this, [ccomprobante] , 5 ) and alltrim(upper(this.ccomprobante)) == 'MOVIMIENTODESTOCK'
				for each loItem in this.movimientodetalle

					this.oDetalleCompOmnicanalidad.Add( this.CargarObjetoAuxiliarOmnicanalidad(loItem) )
					
				endfor
			otherwise
				this.oDetalleCompOmnicanalidad = null
		endcase
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function CargarObjetoAuxiliarOmnicanalidad( toItem as Object ) as Object
		local loDetalle as Object
		
		loDetalle = newobject("Custom")
		loDetalle.Addproperty("articulo_pk","")
		loDetalle.Addproperty("color_pk","")
		loDetalle.Addproperty("talle_pk","")
					
		loDetalle.articulo_pk = rtrim(toItem.articulo_pk)
		loDetalle.color_pk = rtrim(toItem.color_pk)
		
		loDetalle.talle_pk = iif( pemstatus( toItem, [talle_pk], 5 ), rtrim(toItem.talle_pk), rtrim(toItem.talle) )
		
		return loDetalle
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CargarCuponesHuerfanos() as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ExistenCuponesHuerfanos() as Boolean 
		return .f.
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function AgregarCuponHuerfanoAColeccion( tcGuidCupon as String ) as Void
	endfunc 	

	*-----------------------------------------------------------------------------------------
	function EventoMensajeDeCuponesHuerfanos( tcMensaje as String ) as Void
	endfunc

	*-----------------------------------------------------------------------------------------
	function AvisarExistenciaDeCuponesHuerfanos() as Void
	endfunc 		
	
	*-----------------------------------------------------------------------------------------
	function ObtenerMensajeDeAvisoParaCuponesHuerfanos( ) as String
		return ""
	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	function ObtenerNombreDeValor( tcCodigo as String ) as String
		return ""
	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	protected function HayCuponesHuerfanos() as Boolean 
		return .f. 
	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	protected function HayCuponesHuerfanosAplicados() as Boolean 
		return .f.
	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	function EliminarLosCuponesAplicadosEnOtroComprobante() as Void  
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function QuitarCuponesAfectados( toCupones as Object ) as Void
	endfunc 	

	*-----------------------------------------------------------------------------------------
	function ObtenerCuponesHuerfanosAplicados() as zoocoleccion OF zoocoleccion.prg 
		local loRetorno as zoocoleccion OF zoocoleccion.prg 
		loRetorno = _screen.zoo.crearobjeto( "ZooColeccion" )
		return loRetorno 		
	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	function QuitarCuponHuerfanoAplicado( tcItem as String ) as Void	
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ApagarAvisoDeCuponesHuerfanos() as Void
	endfunc 		

	*-----------------------------------------------------------------------------------------
	function TieneDetalleComprobanteCargado() as Boolean
		local llRetorno as Boolean, lcDetalleComprobante as String
		llRetorno = .f.
		if vartype( This.cDetalleComprobante ) = "C" and !empty( This.cDetalleComprobante )
			lcDetalleComprobante = This.cDetalleComprobante
			if vartype( This.&lcDetalleComprobante ) = "O" and This.&lcDetalleComprobante..TieneAlMenosUnItemValido()
				llRetorno = .t.
			endif
		endif
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerUltimoItemDeGrillaDeValores() as Integer 
		return 0
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearDescripcionDeCuponesIntegrados() as Void			
	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	function NoTienePrefijoDeIntegrado( toItem as Object ) as Boolean 
		return .f.
	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	function ControlaStockDisponible() as boolean
		return .F.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AdvierteStockDisponible() as Boolean
		return .F.
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidaMinimoDeReposicionAlGrabar() as Void
		return .f.
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarStockDispoibleAlGrabar() as Boolean
		local loDetalle as Object, llRetorno as Boolean
		loDetalle = this.ObtenerDetalleAValidarStock()
		llRetorno = this.oColaboradorValidacionControlDeStockDiponible.ValidarStockDispoibleAlGrabar( this, loDetalle )
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ValidarMinimoDeReposicionAlGrabar() as Boolean
		local loDetalle as Object, llRetorno as Boolean
		loDetalle = this.ObtenerDetalleAValidarStock()
		llRetorno = this.oColaboradorValidacionMinimoDeReposicion.ValidarMinimoDeReposicionAlGrabar( this, loDetalle )
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerDetalleAValidarStock() as Object
		local loRetorno as Object
		loRetorno = this.FacturaDetalle
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerFiltroDeBusquedaAdicional() as String 
		return ""
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerRelacionesDeBusquedaAdicional() as String 
		return ""
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerFechaBaseParaVigencia() as Date
		return this.Fecha
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function Setear_Fecha( txVal as variant ) as void
		dodefault( txVal )
		
		if This.CargaManual()
			if  !This.VerificarContexto( "B" ) and !this.TieneAccionCancelatoria()
				This.RecalcularPorCambioFecha()
				this.EventoCambioFecha()
			endif	
		Endif	
	endfunc	
	
	*-----------------------------------------------------------------------------------------
	function RecalcularPorCambioFecha() as Void
		if type( "this.FacturaDetalle" ) = "O" and pemstatus( this, "ListaDePrecios_PK", 5)
			this.FacturaDetalle.SetearNuevaFechaParaVigencia( this.ObtenerFechaBaseParaVigencia() )
			this.FacturaDetalle.RecalcularPorCambioDeListaDePrecios( this.ListaDePrecios_PK )
			this.RecalcularPreciosDeDetallesAdicionales( this.ListaDePrecios_PK )
			if type( "This.oComponenteFiscal" ) = "O"
				this.ActualizarDetalleArticulos()
				this.RecalcularImpuestosDetalleArticulos()
				This.CalcularTotal()
			endif
		endif	
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoCambioFecha() as Void
		*** Evento para poder informar cambio la fecha para que se refresque la parte visual y recalcule precios segun vigencia.
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Validar_Fecha( txVal ) as Boolean
		local llRetorno as Boolean

		llRetorno = dodefault( txVal ) and this.ValidarPedirCotizacionObligatoria( txVal )
		if this.lProcesando
		else
	 		if llRetorno and (txVal != this.Fecha ) and !this.VerificarContexto( 'BC' ) and !this.TieneAccionCancelatoria()
				llRetorno = this.ValidarMostrarAdvertenciaRecalculoPreciosPorCambioDeFecha()
			endif
		endif 	

		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ValidarMostrarAdvertenciaRecalculoPreciosPorCambioDeFecha() as Boolean
		local llRetorno as Boolean, lcMensaje as String 
		llRetorno = .t.
			this.lCambioFecha = .t.
			if this.DebeMostrarAdvertenciaRecalculoPrecios()
				lcMensaje = this.ObtenerMensajeAdvertenciaRecalculoPreciosPorFecha()
				llRetorno = goMensajes.Advertir( lcMensaje, 4 ) = 6 
			endif 	
			this.lCambioFecha = .f.
		
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerMensajeAdvertenciaRecalculoPreciosPorFecha() as String
		local lcMensaje as String, lcCambio as String

		lcCambio = "- Fecha de comprobante."
		
		text to lcMensaje textmerge noshow pretext 1+2
			Atención se detectaron los siguientes cambios: 
			<<chr( 9 )>><< lcCambio >><<chr( 9 )>>
			Los precios ingresados manualmente se establecerán en cero y los que provienen de lista de precios se recalcularán. 
			Verifique que los importes sean los esperados.
			
			¿Desea continuar?
		endtext
		
		return lcMensaje
	endfunc	
	
	*-----------------------------------------------------------------------------------------
	function AplicarCondicionDePago() as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoKeyCodeCondicionDePago() as Void
		** PARA BINDEAR DESDE EL KONTROLER
	endfunc 	

	*-----------------------------------------------------------------------------------------
	protected function EsComprobanteConValores() as Boolean
		return .f.
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsComprobanteDePago() as Boolean
		return .f.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GrabarCotizacion( toItemCotiza, lcMoneda ) as Void
		local loMoneda as Object 
		loMoneda = _screen.Zoo.InstanciarEntidad( "Moneda" )
		with loMoneda
			.Codigo = toItemCotiza.Moneda
			.Modificar()
			.Cotizaciones.LimpiarItem()
			.Cotizaciones.oItem.Fecha = toItemCotiza.FechaNuevaCotizacion
			.Cotizaciones.oItem.Hora = this.ObtenerHoraCotizacion( toItemCotiza ) 
			.Cotizaciones.oItem.Cotizacion = toItemCotiza.MontoNuevaCotizacion
			.Cotizaciones.Actualizar()
			.grabar()
		endwith
		loMoneda.release()
	endfunc	
	
	*-----------------------------------------------------------------------------------------
	function ExisteMontoDeRecargoEnUnCambio() as Boolean
		local llRetorno as Boolean
		llRetorno = .F.

		if pemstatus( This, "RecargoMonto2", 5 ) and This.RecargoMonto2 != 0 and pemstatus( This, "lAgregueRecargoDe1Centavo", 5 ) and !this.lAgregueRecargoDe1Centavo and !inlist( alltrim( upper( This.cNombre ) ), "NOTADECREDITOELECTRONICACHILE", "NOTADECREDITOCHILE" ) and pemstatus( This, "SubTotalBruto", 5 ) and This.SubtotalBruto = 0
			llRetorno = .T.
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidacionRecargoMonto2( txVal as Variant ) as Boolean
		local llRetorno as Boolean
		llRetorno = .T.
		* Si el subtotal es 0 no debería poder poner un recargo, salvo..
		* Excepcion: cuando el comprobante fiscal agrega el centavo de recargo x un cambio para que no pinche el CF
		if txVal != 0 and pemstatus( This, "SubTotalBruto", 5 ) and This.SubtotalBruto = 0 and !this.lCargandoRecargo
			llRetorno = .F.
			goServicios.errores.LevantarExcepcion("No se puede agregar montos de recargo si el subtotal de artículos es 0.")
		endif
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function TieneAccionCancelatoria() as Boolean
		return .f.
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function DebeHacerNCCancelatoria() as Boolean
		return .f.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function PrepararLogueoFiltrosNuevoEnBaseA(toFiltros as object) as void
		this.oLogueadorOperacionesAvanzadas.PrepararLogueoNuevoEnBaseA(toFiltros)
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function CargarFiltrosInsertarDesde(toFiltros as object) as void
		this.oLogueadorOperacionesAvanzadas.CargarFiltrosInsertarDesde(toFiltros)
	endfunc

	*-----------------------------------------------------------------------------------------
	function PrepararLogueoFiltrosCompletarDesdeVentas(toFiltros as object) as void
		this.oLogueadorOperacionesAvanzadas.PrepararLogueoCompletarDesdeVentas(toFiltros)
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function RecorrerYAcumular() as Void
		&& Armar sentencia IN tsql.
		local lcTSQL_IN as String, llTieneKitOPromos as Boolean, lcTSQL_INParaPromosYKits as string, llAgregar as Boolean

		lcTSQL_IN = ""	
		lcTSQL_INParaPromosYKits = ""
		if pemstatus( this, "Facturadetalle",5 ) and vartype( This.Facturadetalle) == "O" and !isnull( This.Facturadetalle)
			
			llTienePromos = this.TienePromos()
			llTieneKits = this.TieneKits()
		
			for each loItem in this.FacturaDetalle
				if !empty( loItem.Articulo_pk  )
					lcArt = "'" + upper( rtrim( loItem.Articulo_pk ) ) + "', "
					if not( lcArt $ lcTSQL_IN )
						lcTSQL_IN = lcTSQL_IN + lcArt
					endif					
					if ( llTieneKits or llTienePromos ) and not( lcArt $ lcTSQL_INParaPromosYKits )
						llAgregar = .f.
						if empty( loItem.IdKit ) and !This.ExisteIdArticuloEnItemPromociones( loItem.IdItemArticulos )
						&& no es participante de kit  y no es participante de promos
							lcTSQL_INParaPromosYKits = lcTSQL_INParaPromosYKits + lcArt
						endif						
					endif
				endif
			endfor
			
			this.FacturaDetalle.cStringFiltroArticulos = left( lcTSQL_IN, len(lcTSQL_IN)-2 )
			if llTieneKits or llTienePromos
				this.FacturaDetalle.cStringFiltroArticulosPromoYKits = 	left( lcTSQL_INParaPromosYKits, len(lcTSQL_INParaPromosYKits)-2 )
			else
				this.FacturaDetalle.cStringFiltroArticulosPromoYKits = this.FacturaDetalle.cStringFiltroArticulos
			endif
		endif
	endfunc	
	
	*-----------------------------------------------------------------------------------------
	function ExisteIdArticuloEnItemPromociones( tcIdItem as String ) as Boolean
		return .f.
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerHoraCotizacion( toItemCotiza as Object ) as string
		local lcHora as String, lcRetorno as String
		
		lcHora = this.MonedaComprobante.ObtenerHoraDeCotizacion( toItemCotiza.FechaNuevaCotizacion )		
		lcRetorno = left( lcHora, 2 ) + ":" + right( lcHora, 2 )
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AsignarComprobanteRelacionado( toItemCotiza as Object ) as void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EsCanjeDeCupones() as Boolean
		local llRetorno as Boolean
		llRetorno = this.oComponente.ObtenerNumeroComprobante( this.cComprobante ) == 32
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function EsOtrosPagos() as Boolean
		local llRetorno as Boolean
		llRetorno = this.oComponente.ObtenerNumeroComprobante( this.cComprobante ) == 50
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function TieneKits() as Boolean
		return .f.
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function TienePromos() as Boolean
		return .f.
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerDatosMovimientoBancario( toDatos as Object, tcDetalle as Object ) as void
		return this.EventoObtenerDatosMovimientoBancario( this, toDatos, tcDetalle )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EventoObtenerDatosMovimientoBancario( toComprobante as Object, toDatos as Object, toDetalle as Object ) as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerSignoDeMovimientoRegistroConciliable( toDetalle as Object ) as Integer
		return this.SignoDeMovimiento
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerDescripcionComprobante() as Void
		return this.obtenernombredecomprobantedeventas( this.Tipocomprobante ) + " " + this.FormatearNumeroComprobante()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerDescripcionComplementariaValorComprobante( toValor as Object, toCheques as Object ) as String
		local lcRetorno as String
		lcRetorno = ""
		if inlist( toValor.tipo, TIPOVALORCIRCUITOCHEQUETERCERO, TIPOVALORCIRCUITOCHEQUEPROPIO )
			lcRetorno = this.oColaboradorCheques.ObtenerInformacionDelCheque( toValor, toCheques )
		else
			if pemstatus( toValor, "ValorDetalle", 5 ) and type( "toValor.ValorDetalle" ) == "C"
				lcRetorno = "/Valor " + iif( pemstatus( toValor, "Valor_Pk", 5 ), "(" + rtrim( toValor.Valor_Pk )+ ") ", "" ) + rtrim( toValor.ValorDetalle )
			endif
		endif
		return lcRetorno
	endfunc  
	
	*-----------------------------------------------------------------------------------------
	protected function FormatearNumeroComprobante() as String
		local lcValorRetorno as String
		lcValorRetorno = this.Letra + " " + padl( int( this.PuntoDeVenta ), 4, "0" ) + "-" + padl( int( this.Numero ), 8, "0" )
		return lcValorRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function GenerarComprobante( tcEntidad as String, tcCodigo as String, tcCodigoValor as String, toRequest as Object ) as Void
		local loForm as Object, loError as Object, llPuedeSeguir as Boolean, llEsVentas as Boolean, lcMensajeError as String
		* Aca estoy en la entidad desde la que saco la información
		* tcEntidad es el comprobante que quiero generar. 
		if !empty( tcCodigo )
			lcCodigoAfectado = tcCodigo
		else
			lcCodigoAfectado = this.Codigo
		endif	
		llEsVentas = .F.
		llPuedeSeguir = .F.
		lcMensajeError = ""
		tcEntidad = upper( alltrim( tcEntidad ) )
			
		try
			this.oCompEnBaseA.ValidarTipoDeEntregaDelComprobanteAfectado( this, tcEntidad, this.cNombre  )
			llPuedeSeguir = goServicios.Seguridad.PedirAccesoEntidad( tcEntidad, "NUEVOENBASEA" )
			if this.ccomprobante = "PRESUPUESTO"
				this.ValidarFechaVencimientoPresupuestos( llPuedeSeguir, this.oAfectanteAuxiliar )
			endif
			if llPuedeSeguir
				this.EventoEnviarMensajeCargandoComprobante()
				this.EventoObtenerAfectante( tcEntidad )
				llEsVentas = "<VENTAS>" $ this.ObtenerFuncionalidades()
				with this.oAfectanteAuxiliar
					if .lNuevo
						.Cancelar()
					endif
					.oCompEnBaseA.nCantidadComprobantesDelEnBaseA = 1
					.oCompEnBaseA.cNombreEntidadAfectada = this.cNombre
				endwith				
				if llEsVentas and this.oAfectanteAuxiliar.DebeHacerNCCancelatoria() && Esto es una "Accion Cancelatoria"
					this.CompletarDatosEnComprobanteAGenerar( lcCodigoAfectado )
					this.oAfectanteAuxiliar.HacerNCCanceltatoria()
										
					llVacio = .t.
				  	for each oItem in this.oAfectanteAuxiliar.Facturadetalle
					  	if !empty(oItem.Codigo)
							llVacio = .f.
							exit  	
					  	endif	  	
					endfor
					if llVacio
						goServicios.Errores.LevantarExcepcion( "El comprobante no posee artículos pendientes" ) 
					endif					
					
					this.AsignarComprobanteRelacionadoAfecta()

					this.oAfectanteAuxiliar.EventoActualizarBarra() 
					this.oAfectanteAuxiliar.EventoActualizarFormulario()
					this.EventoMostrarComprobante( this.oFormularioAfectanteAuxiliar ) 
				else
					This.EventoNuevoComprobante( this.oFormularioAfectanteAuxiliar )
					if this.oAfectanteAuxiliar.lNuevo
						this.CompletarDatosEnComprobanteAGenerar( lcCodigoAfectado )
						this.AsignarComprobanteRelacionadoAfecta()
						this.EventoActualizarBarra() 
						this.EventoActualizarFormulario() 
						this.lAfectada = .t.
						this.EventoMostrarComprobante( this.oFormularioAfectanteAuxiliar ) 
					else
						llPuedeSeguir = .F.
					endif
				endif
			endif
 		
			if  "CONVALORES" $ upper ( this.oAfectanteAuxiliar.ObtenerFuncionalidades() )
				if ( vartype( tcCodigoValor ) = "C" and !empty( tcCodigoValor ) )
					this.AgregarValorEnComprobante( this.oAfectanteAuxiliar, tcCodigoValor )
				endif
				if ( pemstatus( this,"cContexto", 5 ) and this.cContexto = "R" and vartype( toRequest ) = "O" )
					this.CargarValoresCpteRelacionado( this.oAfectanteAuxiliar, toRequest ) 
				endif
			endif
									
			if llPuedeSeguir
				this.GrabarSinEntornoVisual() 
			else 
				goMensajes.Advertir( goServicios.Seguridad.ObtenerInformacion() )
			endif
		catch to loError 
			goServicios.Errores.LevantarExcepcion( loError )
		endtry
	  	return this.oAfectanteAuxiliar
	endfunc 
	
	*-----------------------------------------------------------------------------------------	
	protected function CargarValoresCpteRelacionado( toEntidad as Object, toRequest as Object ) as Void
	
		lnTipoCpteRelacionado = _screen.dotnetbridge.ObtenerValorpropiedad( toRequest, "TipoCpteRelacionado" )
		lcLetraCpteRelacionado = _screen.dotnetbridge.ObtenerValorpropiedad( toRequest, "LetraCpteRelacionado" )
		lnPuntoDeVentaCpteRelacionado = _screen.dotnetbridge.ObtenerValorpropiedad( toRequest, "PuntoDeVentaCpteRelacionado" )
		lnNumeroCpteRelacionado = _screen.dotnetbridge.ObtenerValorpropiedad( toRequest, "NumeroCpteRelacionado" )
		ldFechaCpteRelacionado = _screen.dotnetbridge.ObtenerValorpropiedad( toRequest, "FechaCpteRelacionado" )
			
		if vartype( lnTipoCpteRelacionado ) != "" and lnTipoCpteRelacionado != 0
			toEntidad.TipoCpteRelacionado = lnTipoCpteRelacionado 
		endif		
		if vartype( lcLetraCpteRelacionado ) != ""
			toEntidad.LetraCpteRelacionado = lcLetraCpteRelacionado 
		endif
		if vartype( lnPuntoDeVentaCpteRelacionado ) != "" and lnPuntoDeVentaCpteRelacionado != 0
			toEntidad.PuntoDeVentaCpteRelacionado = lnPuntoDeVentaCpteRelacionado 
		endif
		if vartype( lnNumeroCpteRelacionado ) != "" and lnNumeroCpteRelacionado != 0
			toEntidad.NumeroCpteRelacionado = lnNumeroCpteRelacionado 
		endif		
			
		if vartype( ldFechaCpteRelacionado ) != "" and year( ldFechaCpteRelacionado ) > 1900 	 
			toEntidad.FechaCpteRelacionado = ttod( ldFechaCpteRelacionado )
		endif
		
	endfunc
		
	*-----------------------------------------------------------------------------------------
	function EventoEnviarMensajeCargandoComprobante() as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function oCacheAfectantes_Access() as Object
		if !this.ldestroy and (type("this.oCacheAfectantes") <> 'O' or isnull(this.oCacheAfectantes))
			this.oCacheAfectantes = _screen.Zoo.CrearObjeto( "ZooColeccion" )
		endif
		return this.oCacheAfectantes
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function oColCombinacionesYaProcesadas_Access() as Object
		if !this.ldestroy and (type("this.oColCombinacionesYaProcesadas") <> 'O' or isnull(this.oColCombinacionesYaProcesadas))
			this.oColCombinacionesYaProcesadas = _screen.Zoo.CrearObjeto( "ZooColeccion" )
		endif
		return this.oColCombinacionesYaProcesadas
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerAfectanteDeCache( tcAfectante as String ) as Object
		local loRetorno as Object, lnI as Integer
		
		loRetorno = null

		for lnI = 1 to this.oCacheAfectantes.Count
			if this.oCacheAfectantes.Item[ lnI ].cNombre = tcAfectante
				loRetorno = this.oCacheAfectantes.Item[ lnI ]
				exit
			endif
		endfor

		if isnull(loRetorno)
			loRetorno = _screen.zoo.instanciarentidad( tcAfectante )
			this.oCacheAfectantes.Agregar( loRetorno )
		endif

		return loRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoObtenerAfectante( tcAfectante ) as Void
		if !this.lEstaElKontroler 
				this.oAfectanteAuxiliar = this.ObtenerAfectanteDeCache( tcAfectante )
		else
			this.oAfectanteAuxiliar = this.oFormularioAfectanteAuxiliar.oEntidad
		endif
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	function EventoActualizarBarra() as Void
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EventoActualizarFormulario() as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoMostrarComprobante( toFormulario ) as Void
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EventoNuevoComprobante( toForm as Object ) as Void
		if !this.lEstaElKontroler 
			if this.oAfectanteAuxiliar.lNuevo
				this.oAfectanteAuxiliar.Cancelar()
			endif
			this.oAfectanteAuxiliar.nuevo()
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function GrabarSinEntornoVisual() as Void
		if !this.lEstaElKontroler 
			this.oAfectanteAuxiliar.CalcularTotal()
			this.oAfectanteAuxiliar.Grabar()
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function CompletarDatosEnComprobanteAGenerar ( tcCodigo as String ) as void
		local loEntidadAfectada as Object, loResultado as Object, loSeleccionado as Object
		local lcAtributoPk as String, lxValorPk as Variant, llEsVentas as Boolean, loKontrolerNuevoEnBaseA as Object 
		llEsVentas = "<VENTAS>" $ this.ObtenerFuncionalidades()
		loEntidadAfectada = null
		With this
			lcAtributoPk = .ObtenerAtributoClavePrimaria()
			lxValorPk = .&lcAtributoPk
			*loEntidadAfectada = _Screen.zoo.InstanciarEntidad( .cNombre )
			*loEntidadAfectada.&lcAtributoPk = lxValorPk &&this.oEntidad.&cAtributoPk
		endwith

	    With this.oAfectanteAuxiliar.oCompEnBaseA
	    	if llEsVentas and this.oAfectanteAuxiliar.EsNotaDeCredito()
				if !isnull( this.oFormularioAfectanteAuxiliar )
			    	this.oFormularioAfectanteAuxiliar.oKontroler.cEstado = "NUEVO"
			    endif
	    	endif
	    	.nCantidadComprobantesDelEnBaseA = 1
	        .cNombreEntidadAfectada = This.cNombre
	        loResultado = _screen.zoo.crearobjeto("Zoocoleccion")
	        loSeleccionado = createobject("custom")
	        addproperty( loSeleccionado, "cFiltro", lcAtributoPk )
	        addproperty( loSeleccionado, "cValor", tcCodigo )
	        loResultado.Add( loSeleccionado )
	        .oNumeroComprobanteAfectado = loResultado
	        .InyectarEntidadesPrincipales( this.oAfectanteAuxiliar , this )
	        if !llEsVentas or ( llEsVentas and !this.oAfectanteAuxiliar.EsNotaDeCredito() ) && Si es 'Accion cancelatoria' trae todo tal como está en la factura
	        	if vartype( this.oFormularioAfectanteAuxiliar ) == 'O'
		        	loKontrolerNuevoEnBaseA = _screen.Zoo.App.Crearobjeto("KontrolerNuevoEnBaseA", "KontrolerNuevoEnBaseA.prg")
		        	loKontrolerNuevoEnBaseA.InyectarKontrolerEntidad( this.oFormularioAfectanteAuxiliar.oKontroler )
		        	bindevent(this.oAfectanteAuxiliar.oCompEnBaseA, "EventoPreguntar", loKontrolerNuevoEnBaseA, "Preguntar")
		        endif
	        	.QueTengoQueHacerConLosPreciosV2()
		    endif
	        .ObtenerCabeceraDeComprobante()
	        .ObtenerDetalleDeComprobantes()
	   	    .nSigno = 1
	   	    if !llEsVentas or ( llEsVentas and !this.oAfectanteAuxiliar.EsNotaDeCredito() ) && Lo hago desde otro metodo
		   	    .InyectarConsulta()
		   	    
		   	    llVacio = .t.
			  	for each oItem in this.oAfectanteAuxiliar.Facturadetalle
				  	if !empty(oItem.Codigo)
						llVacio = .f.
						exit  	
				  	endif	  	
				endfor
				if llVacio
					goServicios.Errores.LevantarExcepcion( "El comprobante no posee artículos pendientes" )
				endif				 
		 
		 	endif
	  	endwith
	  	
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function AsignarComprobanteRelacionadoAfecta()
		this.EventoSalvarEntidad()
		this.AsignarComprobanteRelacionado()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EventoSalvarEntidad()
		&&bindeo para que al cerrar el formulario de la entidad generada, no mate la entidad actual
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarIngresoManualEnBaseA() as Void
		local llCodigoDeBarras as Boolean, lcTalle as String, llForzarCalculos as Boolean  

		try
			llCodigoDeBarras = pemstatus( this.FacturaDetalle.oItem, "CodigoDeBarras", 5 ) and !empty( this.FacturaDetalle.oItem.CodigoDeBarras )
			if this.oCompEnBaseA.nOperatoria > 1
				*if (!this.oCompEnBaseA.lYaValidado and llCodigoDeBarras) or !llCodigoDeBarras
				if (!this.oCompEnBaseA.lYaValidado )
					this.oCompEnBaseA.nCantidadDeItemsDistribuidos = 0
					this.oCompEnBaseA.lQuedaronSinAgregar = .f.
					this.oCompEnBaseA.lSeAgregoUnItemNuevo = .f.
					this.oCompEnBaseA.lSeModificoUnItem = .f.
					this.LimparSeDistribuyeronCantidades()
					with this.FacturaDetalle.oItem
						this.oCompEnBaseA.lYaValidado = .f.
						if !empty( .Articulo_PK )
							this.oCompEnBaseA.ValidarSiEnIngresoManualEnBaseASeModificoCombinacionEnItemCargado( this.FacturaDetalle )
							if !empty( .Afe_codigo )
								if this.oCompEnBaseA.nOperatoria = 4
									this.oCompEnBaseA.ValidarIngresoManualEnBaseAConVariantesItemCargado( this.FacturaDetalle )
								else
									this.oCompEnBaseA.ValidarIngresoManualEnBaseAItemCargado( this.FacturaDetalle )
								endif
							else
								if .EsLibre
									this.oCompEnBaseA.ValidarSiEnIngresoManualEnBaseASeModificoCombinacionPreFiltrada( this.FacturaDetalle, llCodigoDeBarras )
								else
									if this.oCompEnBaseA.nOperatoria = 4
										this.oCompEnBaseA.ValidarIngresoManualEnBaseAConVariantes( this.FacturaDetalle, llCodigoDeBarras )
									else
										lcTalle = iif( pemstatus( this.FacturaDetalle.oItem, [talle_pk], 5 ), rtrim(.talle_pk), rtrim(.talle) )
										this.oCompEnBaseA.ValidarIngresoManualEnBaseA( .Articulo_PK, .Color_PK, lcTalle, .Cantidad, .IdItemArticulos, llCodigoDeBarras )
									endif
								endif
							endif
						else
							llForzarCalculos = this.oCompEnBaseA.lItemNoCoincide
							this.oCompEnBaseA.lItemNoCoincide = .f.
						endif
						if this.oCompEnBaseA.lSeDistribuyeronCantidades or this.oCompEnBaseA.lSeEliminoUnItem or this.oCompEnBaseA.lSeActualizoUnItem or llForzarCalculos
							this.ActualizarCalculos()
						endif
					endwith
					this.EventoEstablecerFocoDetalleDespuesDeCargaAutomaticaPorOperatoria( this.oCompEnBaseA.nCantidadDeItemsDistribuidos, llCodigoDeBarras, this.oCompEnBaseA.lQuedaronSinAgregar )
					this.oCompEnBaseA.lSeEliminoUnItem = .f.
					this.oCompEnBaseA.lSeActualizoUnItem = .f.
				else
					this.oCompEnBaseA.lYaValidado = .f.
				endif
			endif
		catch to loError
			goServicios.Errores.LevantarExcepcion( loError )
		endtry
				
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoEstablecerFocoDetalleDespuesDeCargaAutomaticaPorOperatoria( tnCantidadDeItemsDistribuidos as Integer, tlCodigoDeBarras as Boolean, tlQuedaronSinAgregar as Boolean ) as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function RestablecerSaldosAfectados() as Void
		if this.SeEliminoUnItem()
			this.oCompEnBaseA.RestablecerSaldosAfectados( this.FacturaDetalle, this.FacturaDetalle.oItem.NroItem )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SeEliminoUnItem() as Boolean
		local llRetorno as Boolean 
		llRetorno = (this.FacturaDetalle.oItem.NroItem > 0 and empty(this.FacturaDetalle.oItem.Articulo_PK) and !empty( this.FacturaDetalle.Item[this.FacturaDetalle.oItem.NroItem].Articulo_PK) )
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function DistribuirCantidadesEnSaldosPendientes() as Boolean
		local llRetorno as Boolean 
		llRetorno = this.lTieneFuncionalidadesEnBaseA and this.oCompEnBaseA.DebeDistribuirEnSaldosPendientes()
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ItemAfectado( tnNroItem as Integer ) as Boolean
		local llRetorno as Boolean, loItem as Object 
		loItem = this.FacturaDetalle.Item[ tnNroItem ]
		llRetorno = this.EsUnItemAfectado( loItem )
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerTooltipComprobanteAfectado( tnNroItem as Integer ) as String
		local lcRetorno as String, loItem as Object, lcComprobante as String 
		loItem = this.FacturaDetalle.Item[ tnNroItem ]
		lcComprobante = this.oComponente.obtenernombredecomprobantedeventas( loItem.Afe_TipoComprobante )
		lcRetorno = this.oCompEnBaseA.ObtenerComprobanteAfectadoParaTooltip( loItem, lcComprobante )
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function NoValidarDetallePorOperatoriaEnBaseA() as Boolean
		local llRetorno as Boolean 
		llRetorno = pemstatus(this, "oCompEnBaseA", 5) and this.oCompEnBaseA.lSeDistribuyeronCantidades
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function LimparSeDistribuyeronCantidades() as Void
		this.oCompEnBaseA.LimpiarSeDistribuyeronCantidades()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ActualizarCalculos() as Void
		if pemstatus( this, "oComponenteFiscal", 5 ) and pemstatus( this.oComponenteFiscal, "RecalcularImpuestos", 5 )
			this.oComponenteFiscal.RecalcularImpuestos(this.FacturaDetalle,this.impuestosDetalle)
		endif                       
		if pemstatus(this,"AplicarRecalculosGenerales",5)
			this.AplicarRecalculosGenerales()
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function LimpiarVariablesPorOperatoria() as Void
		this.oCompEnBaseA.lYaValidado = .f.
	endfunc 
						
	*-----------------------------------------------------------------------------------------
	function SoyAfectada() as Boolean
		return this.lAfectada
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerResultadoDeVotacion( pepe as zoocoleccion OF zoocoleccion.prg) as zoocoleccion
		local loRetorno as zoocoleccion OF zoocoleccion.prg
		llVotacion = .T.
		loRetorno = _screen.zoo.crearobjeto( "zoocoleccion" ) &&_screen.zoo.crearobjeto( "zoocoleccion" )
		if pemstatus( this, "VotacionCambioEstadoModificar", 5 )
			this.InicializarComponentes()
			llVotacion = this.VotacionCambioEstadoModificar( this.ObtenerEstado() )
			if !llVotacion			
				for i=1 to this.oInformacion.Count
					loRetorno.Agregar( this.oInformacion.Item[i].cMensaje )
				endfor
				this.oInformacion.Limpiar()
			endif
		endif
		if !this.lActualizandoSaldos and This.TieneFuncionalidadBasadoEn()
			if this.lValidarAlModificar
				if this.oCompEnBaseA.EsComprobanteAfectado( this.cNombre ) and !this.oCompEnBaseA.ValidarComprobantesAfectantes( this, "Modificar" )
					loRetorno.Agregarrango( this.oCompEnBaseA.ObtenerInformacion() )
				endif
			endif
		endif
		if pemstatus( this, "TieneSeteadaEntregaOnline", 5)
			if this.TieneSeteadaEntregaOnline()
				loRetorno.Agregar("No se puede modificar un comprobante con Venta continua.")
			endif
		endif
		return loRetorno
	endfunc
										
	*-----------------------------------------------------------------------------------------
	function Destroy() as Void
		if type( "this.oColaboradorCheques" ) == 'O'
			this.oColaboradorCheques.Release()
		endif
		this.oFormularioAfectanteAuxiliar = null
		this.oAfectanteAuxiliar = NULL
		dodefault()
	endfunc
	
	*--------------------------------------------------------------------------------------------------------
	function oBuzon_Access() as variant
		if !this.ldestroy and ( !vartype( this.oBuzon ) = 'O' or isnull( this.oBuzon ) )
			this.oBuzon = _Screen.zoo.instanciarEntidad( "Buzon" )
		endif
		return this.oBuzon
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function oMoneda_Access() as variant
		if !this.ldestroy
			if !vartype( this.oMoneda ) = 'O'
				this.oMoneda = _screen.zoo.instanciarentidad( "Moneda" )
				this.oMoneda.inicializar()
			endif
		endif
		return this.oMoneda
	endfunc 
	
	*--------------------------------------------------------------------------------------------------------
	function oColaboradorCheques_Access() as variant
		if !this.ldestroy and ( type( "this.oColaboradorCheques" ) != 'O' or isnull( this.oColaboradorCheques ) )
			this.oColaboradorCheques = _screen.zoo.CrearObjeto( "colaboradorCheques", "colaboradorCheques.PRG" )
		endif
		return this.oColaboradorCheques
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarPedirCotizacionObligatoria( tdFecha ) as Boolean
		local ldFecha as Date, llRetorno as Boolean
		llRetorno = .T.
		if vartype( this.FacturaDetalle ) = "O" and vartype( this.ValoresDetalle ) = "O"
			local loMonedas as object
			ldFecha = iif( empty( tdFecha ), date(), tdFecha )
			loMonedas = this.ObtenerMonedasConCotizacionObligatoria( ldFecha )
			if vartype( loMonedas ) = "O" 
				if loMonedas.count != 0				
					for each lcItem in loMonedas
						llRetorno = this.PedirCotizacionObligatoriaDeMoneda( lcItem, ldFecha )
					endfor
				endif
			endif
		endif
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function PedirCotizacionObligatoriaDeMoneda( tcMoneda as String, tdFecha ) as Boolean
		local lcMonedaSugerida as String, lcMonedaComprobante as String, lcMonedaCotizacion as String, lnCotiAnterior, llRetorno as Boolean
		llRetorno = .T.
		if goServicios.Seguridad.PedirAccesoEntidad( this.MonedaComprobante.ObtenerNombre(), "MODIFICAR", .F., this.MonedaComprobante.ObtenerDescripcion() )
			this.lPidiendoCotizacion = .t.
			this.oItemAuxCotiza = this.ObtenerItemAuxCotiz( tcMoneda, tdFecha )
			lnCotiAnterior = this.Cotizacion 
			this.Cotizacion = 0
			this.IngresarCotizacion()
			if this.Cotizacion = 0 
				goServicios.Errores.LevantarExcepcion( "No se cargó la cotización de la moneda " + alltrim( tcMoneda ) + "." )
				*goServicios.Mensajes.Advertir( "No se cargó la cotización de la moneda " + alltrim( tcMoneda ) + "." )
				llRetorno = .F.
			else					
				this.GrabarCotizacion( this.oItemAuxCotiza, tcMoneda )
			endif
			this.Cotizacion = lnCotiAnterior
			this.lPidiendoCotizacion = .f.
		else
			goServicios.Errores.LevantarExcepcion( "Se requieren permisos para modificar la cotización de una moneda." )
			llRetorno = .F.
		endif
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerItemAuxCotiz( tcMoneda as String, tdFecha ) as object
		local loRetorno as object
		loRetorno = _screen.zoo.crearObjeto( "ItemAuxCotiza" )
		with loRetorno 
			.Moneda = alltrim( tcMoneda )
			.FechaUltimaCotizacion = this.oMoneda.ObtenerFechaUltimaCotizacion( date(), tcMoneda )
			.FechaNuevaCotizacion = tdFecha
			.MontoUltimaCotizacion = this.oMoneda.ObtenerCotizacion( .FechaUltimaCotizacion, tcMoneda, '')
			.MontoNuevaCotizacion = .MontoUltimaCotizacion
		endwith
		return loRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function IngresarCotizacion()
		*Bindeo en kontroler
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerMonedasConCotizacionObligatoria( tdFecha ) as object
		local lcSentencia as String, loRetorno as object
		
		lcSentencia = "Select Moneda from ( Select Codigo as Moneda, "
		lcSentencia = lcSentencia + "case when (select top 1 fecha from " + alltrim(_screen.zoo.app.cSchemaDefault)+ ".cotiza as c where c.CODIGO = m.CODIGO and c.FECHA <= '" + alltrim(str(year(tdFecha))+padl(month(tdFecha),2,'0')+padl(day(tdFecha),2,'0')) + "' "
		lcSentencia = lcSentencia + "order by fecha desc) = '" + alltrim(str(year(tdFecha))+padl(month(tdFecha),2,'0')+padl(day(tdFecha),2,'0')) + "' then 0 else 1 end as DebePedirCotiz "
		lcSentencia = lcSentencia + "from zoologic.moneda as m "
		lcSentencia = lcSentencia + "where coblig = 1 ) as Datos where DebePedirCotiz = 1"

		goServicios.Datos.Ejecutarsentencias( lcSentencia, 'moneda', '', 'cMoneda', this.oAd.DataSessionId )
		
		loRetorno = _screen.zoo.crearobjeto( 'zooColeccion' )
		If Reccount('cMoneda') > 0
			scan
				loRetorno.Add( alltrim( cMoneda.Moneda ) )
			endscan
		endif
		Use In cMoneda
		
		return loRetorno
	endfunc  
	
	*-----------------------------------------------------------------------------------------
	function ObtenerUltimoCargado( toDetalle as Object ) as Integer
		local lnRetorno as Integer, lnItem as Integer 
		lnRetorno = toDetalle.count
		for lnItem = toDetalle.count to 1 step -1
			if !empty(toDetalle.Item[lnItem].Articulo_pk)
				lnRetorno = toDetalle.Item[lnItem].NroItem
				exit
			endif
		endfor
		return lnRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function AgregarValorEnComprobante( toEntidad as Object, tcCodigoValor as String ) as Void		
		if toEntidad.ValoresDetalle.Count = 0
			toEntidad.valoresdetalle.oItem.valor_pk = tcCodigoValor
			toEntidad.valoresdetalle.actualizar()
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function RetiraEfectivo() as Boolean
		return .f. 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoObtenerMascaraCantidad( tcNombreDetalle as String, tcMascaraCantidades as String ) as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarFechaVencimientoPresupuestos( tlContinuar, toAfectanteAuxiliar) as Void
		this.ValidacionFechaVencimiento( tlContinuar, this.oAfectanteAuxiliar )
	endfunc 
	
	*--------------------------------------------------------------------------------------------------------
	function ValidarSiCambioElValorDelAtributo( tcAtributo as String, txValOld as variant, txVal as variant ) as Boolean
		return .t.
	endfunc

	*-----------------------------------------------------------------------------------------
	function DebeAgruparPackAutomaticamente() as Boolean
		return .f.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function eventoEmitirMensaje( tcMensaje as String, tcTitulo as String, tnIcono as Integer, tnEspeta as Integer ) as Void

	endfunc 

	*-----------------------------------------------------------------------------------------
	function EstaEnProceso() as Boolean
		local llRetorno as Boolean
		llRetorno = dodefault()
		llRetorno = llRetorno or this.lActualizandoSaldos or this.lCargandoRecargo or this.lPidiendoCotizacion
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EstaProcesando() as Boolean
		local llRetorno as Boolean
		llRetorno = This.lCargando or This.lLimpiando or This.lDestroy
		llRetorno = llRetorno or this.lActualizandoSaldos or this.lCargandoRecargo or this.lPidiendoCotizacion
		return llRetorno
	endfunc 

enddefine
