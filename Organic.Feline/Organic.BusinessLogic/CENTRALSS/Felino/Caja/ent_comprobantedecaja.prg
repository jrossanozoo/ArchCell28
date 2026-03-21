define class ent_ComprobantedeCaja as Din_EntidadComprobantedeCaja of Din_EntidadComprobantedeCaja.prg

	#if .f.
		local this as ent_ComprobantedeCaja of ent_ComprobantedeCaja.prg
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
	#define PRECISIONMONTOS        			4

	Tipo = 0
	*** Estos atributos estan duros para poder grabar la caja!
	TipoComprobante = 98
	Numero = 0
	Letra = ""
	PuntoDeVenta = 0
	lEsComprobanteConStock = .F.
	lPermiteAccionesDeAbm = .T.
	cValoresDetalle = "Valores"
	cDetalleComprobante = "NoTieneDetalleComprobante"
	Anulado = .T.
	lActualizaRecepcion = .T.
	oCajaEstado = null
	lComprobanteConVuelto = .F.
	lCambioConcepto = .f.
	oBaseDeDatos = null
	cNombreTransferencia = "CCXVALTRANS"

	lDebeRenumerarAlEnviarABaseDeDatos = .T.
	lValidacionInteractiva = .f.
	lControlCajaOrigen = .f.
	lEstaGenerandoContraComprobante = .f.
	lPermiteIgualOrigenDestino = .f.

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
		This.Valores.oItem.lUsaDescuentosYRecargos = .F.
		this.oCompArqueoDeCaja.InyectarComprobante( this )
		this.oCompCuentaBancariaComprobanteCaja.InyectarEntidadPadre( this )
		this.oCompCuentaBancariaComprobanteCaja.InyectarDetallePadre( this.Valores )
		this.oCompCuentaBancariaComprobanteCaja.Reinicializar()
		this.lPermiteIgualOrigenDestino = goparametros.felino.transferencias.comprobantedecaja.permitirempaquetarcomprobantesdecajaconelmismoorigendestinoqueeldelabasededatosactiva
	endfunc 

	*-----------------------------------------------------------------------------------------
	function lActualizaRecepcion_Access() as Boolean
		return .F.
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function oCajaEstado_Access() as variant
		if !this.ldestroy and !vartype( this.oCajaEstado ) = 'O'
			this.oCajaEstado = _Screen.zoo.Instanciarentidad( "CajaEstado" )
		endif
		return this.oCajaEstado
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function oBaseDeDatos_Access() as variant
		if !this.ldestroy and !vartype( this.oBaseDeDatos ) = 'O'
			this.oBaseDeDatos = _Screen.zoo.Instanciarentidad( "BaseDeDatos" )
		endif
		return this.oBaseDeDatos
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerSiguienteNumerico() as Integer
		local lcXml as String
		lcXml = this.oAD.ObtenerDatosEntidad( "NUMERO", , , "Max" )
		this.xmlACursor( lcXml, "c_Valores" )
		lnMaximo = nvl( c_Valores.max_Numero , 0 ) + 1	
		use in select( "c_Valores" )
		return lnMaximo
	endfunc 
	
	*-----------------------------------------------------------------------------------------	
	function Setear_Tipo( txVal as variant ) as void
		dodefault( txVal )
		This.Signodemovimiento = iif( txVal = 1, 1, -1 )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Setear_Concepto( txVal as variant ) as Void
		dodefault( txVal )
		if this.lCambioConcepto and this.CargaManual() and inlist( This.Concepto.tipo,TIPOMOVIMIENTOENTRADA,TIPOMOVIMIENTOSALIDA) && and empty( This.Tipo )
			This.Tipo = This.Concepto.tipo
			this.lHabilitarTipo = this.HabilitarTipoDeMovimiento()
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearSugeridoCajaDestino() as Void 
	 	if this.lHabilitarCajaDestino_PK and This.Signodemovimiento = -1 and this.lCambioConcepto		
			this.CajaDestino_pk = this.Concepto.CajaDestino_pk 
		endif 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarTotales() as Boolean
		return .T.
	endfunc 
	
	*-----------------------------------------------------------------------------------------		
	function ValidarPuntoDeVenta() as Boolean
		return .T.
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarSaldo() as Boolean
		return .f.
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Validar_Concepto( txVal as variant, txValOld as variant ) as Boolean
		local llRetorno as Boolean
		llRetorno = dodefault( txVal, txValOld )
		llRetorno = llRetorno and this.ValidarConceptoConChequesCargados( txVal, txValOld )
		if llRetorno
			this.lCambioConcepto = !( txval == txValOld )
		endif
        return llRetorno

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearAtributosDeDescuentosYRecargosAnteriores( tlBlanquear as Boolean ) as Void	
	endfunc

	*-----------------------------------------------------------------------------------------
	function AntesDeGrabar() As Boolean		
		local llRetorno as Boolean
		llRetorno = dodefault()
		
		if llRetorno
			this.SetearCajaEnItems()
			this.SetearFechaEnItems(this.Fecha)
			this.AbrirCajas()
			goCaja.InicializaLYaGeneroContracomprobante()
			if alltrim( upper( this.cContexto ) ) = "B"
				this.ZadsFw = "Comprobante origen nº" + transform( this.Numero ) 
			endif
		endif
		llRetorno = llRetorno and this.ValidacionesAdicionales() 
		if llRetorno and this.Valores.lExisteItemCuentaBancaria and (empty( this.Concepto_pk ) or empty( this.Concepto.CuentaBancaria_pk ))
			this.LimpiarIdItemComponente( this.Valores )
		endif
		return llRetorno
	endfunc
	
	*-------------------------------------------------------------------------------------------------
	Function DespuesDeGrabar() As Boolean
		local llRetorno as Boolean
		llRetorno = dodefault()
		if llRetorno 
			llRetorno = this.RealizarAjustesPorChequeDeTercerosRechazado()
		endif
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Eliminar() as Void
		local llValidaOk as Boolean
		llValidaOk = .F.
		if vartype( this.oColaboradorAjusteChequeRechazado ) = "O"
			llValidaOk = this.oColaboradorAjusteChequeRechazado.ValidarSiGeneroComprobantes( this )
		endif
		
		dodefault()
		
		if llValidaOk and this.lEliminar
			this.oColaboradorAjusteChequeRechazado.LoguearAdvertenciaAlAnularEliminar( this, "Eliminar" )
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function RealizarAjustesPorChequeDeTercerosRechazado() as Boolean
		local llRetorno as Boolean
		llRetorno = .T.
		if this.ValidaSiCorrespondeAjustarChequeRechazado() and vartype( this.oColaboradorAjusteChequeRechazado ) = "O"
			llRetorno = this.oColaboradorAjusteChequeRechazado.ValidarYProcesarAjusteChequesRechazados( this )
		endif
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoMensajeAdvertenciaPorAnulacionDeComprobante() as Void
		*** EVENTO BINDEADO AL KONTROLER	
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoPreguntarSiRealizaAjusteDeCtaCteDeCliente( tnOpcion as Integer ) as Void
		*** EVENTO BINDEADO AL KONTROLER	
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoPreguntarSiRealizaRecargoPorEstadoChequeRechazado( tnOpcion as Integer ) as Void
		*** EVENTO BINDEADO AL KONTROLER	
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoMensajeProcesando( tcMensaje as String ) as Void
		*** EVENTO BINDEADO AL KONTROLER
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoFinMensajeProcesando() as Void
		*** EVENTO BINDEADO AL KONTROLER
	endfunc 	
	
	*-----------------------------------------------------------------------------------------
	function ValidaSiCorrespondeAjustarChequeRechazado() as Boolean
		local llRetorno as Boolean
		llRetorno = iif( this.EsNuevo() and type( "this.Concepto" ) == "O" and upper( this.Concepto.EstadoCheque ) = "RECHA", .T., .F. )
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function DebeAbrirCajas() as Boolean
		return alltrim( upper( this.cContexto ) ) = "B"
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function AbrirCajas() as VOID
		local loItem as Object
		for each loItem in this.Valores foxobject
			if !empty( loItem.Valor_PK )
				this.AbrirCajaEspecifica( loItem.Caja_PK )
			endif
		endfor
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function AbrirCajaEspecifica( tnNumeroDeCaja as Integer ) as VOID
		local lnNumeroDeCaja as Integer
		if empty( tnNumeroDeCaja )
			lnNumeroDeCaja = goCaja.ObtenerNumeroDeCajaActiva()
		else
			lnNumeroDeCaja = tnNumeroDeCaja
		EndIf

		if !this.oCajaEstado.EstaAbierta( lnNumeroDeCaja )
			goCaja.Abrir( lnNumeroDeCaja )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function SetearEstadoDeCajaDestino() as Void
		local lcOrigenSucursalActiva as String
		 
		lcOrigenSucursalActiva = this.ObtenerOrigenSucursalActiva()
		if  upper( alltrim( this.origendestino_pk ) ) == upper( alltrim( lcOrigenSucursalActiva ) ) and This.tipo = 2 &&
			this.lHabilitarCajaDestino_PK = .T.
		else 		
				this.CajaDestino_PK = 0
				this.lHabilitarCajaDestino_PK = .F.
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------	
	function Validar_Cajadestino( txVal as variant, txValOld as variant ) as Boolean
		local llRetorno as Boolean
		llRetorno = dodefault( txVal, txValOld )
		if llRetorno  and txVal = goCaja.ObtenerNumeroDeCajaActiva()
			llRetorno = .f.
			goServicios.Errores.Levantarexcepcion( "La caja destino no puede ser la misma que la caja activa" )
		endif
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerOrigenSucursalActiva() as String 
		local lcRetorno as String 
		lcRetorno = ""
		try
			this.oBaseDeDatos.codigo = _screen.zoo.app.cSucursalActiva
			lcRetorno = this.oBaseDeDatos.OrigenDestino_pk	
		catch
		endtry
		return lcRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function AccionesAutomatizadas( tcMetodo as String ) as Void
		local loEmpaquetador as EmpaquetarComprobanteDespuesDeGrabar of EmpaquetarComprobanteDespuesDeGrabar.prg, ;
			llDebeEmpaquetar as Boolean
		
		dodefault( tcMetodo )
		

		if upper( tcMetodo ) == "DESPUESDEGRABAR" 
			loEmpaquetador = _screen.zoo.crearObjeto( "EmpaquetarComprobanteDespuesDeGrabar" )

			llDebeEmpaquetar = loEmpaquetador.DebeEmpaquetarElComprobante( goServicios.Parametros.Felino.Transferencias.ComprobanteDeCaja.EmpaquetarComprobanteDespuesDeGrabar )
			llDebeEmpaquetar = llDebeEmpaquetar and this.Tipo = 2
			llDebeEmpaquetar = llDebeEmpaquetar and this.ValidarOrigenDestinoEmpaquetarAlGrabar()
			if llDebeEmpaquetar
				loEmpaquetador.EmpaquetarComprobante( this )
			endif
			loEmpaquetador.release()
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CrearItemTransferencia() as Object
		local loItem as Custom

		loItem = _screen.zoo.crearObjeto( "ItemFiltroTransferencia" )
		loItem.cValorArchivo = transform( this.Numero , "@LZ 99999999" ) 
		loItem.oColFiltros.Agregar( transform( this.Numero , "@LZ 99999999" ) )
		loItem.oColFiltros.Agregar( dtoc( This.Fecha ) )
		loItem.oColFiltros.Agregar( dtoc( This.FechaModificacionFW ) )
		loItem.oColFiltros.Agregar( this.CajaDestino_pk)
		loItem.oColFiltros.Agregar( this.CajaOrigen_pk)
		loItem.oColFiltros.Agregar( this.Concepto_pk)
		loItem.oColFiltros.Agregar( this.MonedaComprobante_pk)
		loItem.oColFiltros.Agregar( this.MonedaSistema_pk)
		loItem.oColFiltros.Agregar( this.OrigenDestino_pk )

		if !empty( this.OrigenDestino_Pk )
			this.oBuzon.CompletarItemTransferencia( "OrigenDeDatos", this.OrigenDestino_Pk, .t., loItem )			
			if empty( loItem.cBuzon ) and empty( loItem.cBaseDeDatos )
				this.IntentarSeteoDeBaseDeDatosComoDestino( loItem )
			endif
		endif

		loItem.oColFiltros.Agregar( this.Vendedor_Pk )				
		loItem.oColFiltros.Agregar( this.Tipo )
		
		return loItem
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function IntentarSeteoDeBuzonComoDestino ( toItem as Object ) as Void
		local loEntidad as Object
		loEntidad = _Screen.zoo.instanciarEntidad( "Buzon" )
		This.XmlACursor( loEntidad.oAd.ObtenerDatosEntidad( "CODIGO, OrigenDeDatos,hunid,hpath,EsBuzonLince", "OrigenDeDatos = '" + this.OrigenDestino_Pk + "'" ), "c_Ver" )
		if reccount( "c_Ver" ) > 0
			go top in c_Ver
			toitem.cBuzonDestino = loEntidad.ObtenerDirectorioEnvia( c_ver.hunid, c_ver.hpath, c_ver.Codigo )
			toItem.cBuzon = alltrim(  c_ver.Codigo )
			toItem.lEsBuzonLince =  c_ver.EsBuzonLince
		endif
		use in select( "c_Ver" )
		loEntidad.release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function IntentarSeteoDeBaseDeDatosComoDestino ( toItem as Object ) as Void
		local loEntidad as Object, lcHaving as String
		loEntidad = _Screen.zoo.instanciarEntidad( "BaseDeDatos" )
		lcHaving = "Codigo <> '" + _screen.zoo.app.cSucursalActiva + "' and OrigenDestino = '" + this.OrigenDestino_Pk + "'"
		This.XmlACursor( loEntidad.oAd.ObtenerDatosEntidad( "CODIGO, OrigenDestino", lcHaving ), "c_Ver" )
		if reccount( "c_Ver" ) > 0
			go top in c_Ver
			toItem.cBaseDeDatos = alltrim(  c_ver.Codigo )
		endif
		use in select( "c_Ver" )
		loEntidad.release()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function MensajeAdvertenciaOrigenRepetido() as String
		return "El origen está presente en más de una base de datos con lo cual podría tener inconsistencias en el stock."+chr(13);
				+"¿Desea continuar de todos modos?"
	endfunc 

	*-----------------------------------------------------------------------------------------
	function VerificarOrigenRepetido() as boolean
		local loEntidad as Object, lcHaving as String, llRetorno
		llRetorno = .f.
		loEntidad = _Screen.zoo.instanciarEntidad( "BaseDeDatos" )
		lcHaving = "OrigenDestino = '" + this.OrigenDestino_Pk + "'"
		This.XmlACursor( loEntidad.oAd.ObtenerDatosEntidad( "CODIGO, OrigenDestino", lcHaving ), "c_Ver" )
		if reccount( "c_Ver" ) > 1
			llRetorno = .t.
		endif
		use in select( "c_Ver" )
		loEntidad.release()
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function EsComprobanteDeCaja() as Boolean
		return .T.
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function ExistenCuponesHuerfanosNoNeteados() As Boolean
		return .f.
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidacionesAdicionales() as Boolean
		return this.ValidarLongitudNumeracion() and this.ValidarMonedaCuentaBancaria() and this.ValidarSeteosComprobanteParaRecargo()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarArticulosNoPermitenDevolucion() as Boolean
		return .T.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarLongitudNumeracion() as Boolean
		local llEsMenorA8Digitos as Boolean , lcMensaje as String
		
		llEsMenorA8Digitos = len(transform(this.Numero)) <= 8
		
		if !llEsMenorA8Digitos 
			lcMensaje = "La longitud máxima permitida es de 8 dígitos en la numeración de los comprobantes de caja." + chr(10) + chr(13)  
			lcMensaje = lcMensaje + "Por favor diríjase a Configuración -> Talonarios y numeraciones -> Numeraciones, " 
			lcMensaje = lcMensaje + "para realizar el cambio correspondiente. "
			this.agregarInformacion(lcMensaje)
		endif			
		
		return llEsMenorA8Digitos 
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidarSeteosComprobanteParaRecargo() as Boolean 
		local llRetorno as Boolean, lcMensaje as String, lnTipoComprobante as Integer

		llRetorno = .t.
		lcMensaje = ""
		lnTipoComprobante = 0
	
		if this.ValidaSiCorrespondeAjustarChequeRechazado() 
			
			this.oColaboradorAjusteChequeRechazado.ObtenerSeteosDeAjusteChequesRechazados()
			
			lnTipoComprobante = this.oColaboradorAjusteChequeRechazado.oSeteosAjusteRecargo.nTipoComprobante
			
			if lnTipoComprobante > 1 and this.oColaboradorAjusteChequeRechazado.oSeteosAjusteRecargo.nRealizaRecargo > 1
			
				llRetorno =	(lnTipoComprobante = 3 and GOSERVICIOS.PARAMETROS.NUCLEO.DATOSGENERALES.PAIS = 1 and; 
					(GOSERVICIOS.PARAMETROS.FELINO.GESTIONDEVENTAS.FACTURACIONELECTRONICA.NACIONAL.HABILITARFACTURACIONELECTRONICAPARAELMERCADOINTERNO;
					or GOSERVICIOS.PARAMETROS.FELINO.GESTIONDEVENTAS.FACTURACIONELECTRONICA.NACIONAL.HABILITARFACTURACIONELECTRONICAMIPYME)) ;
					or ( lnTipoComprobante = 2 and GOSERVICIOS.PARAMETROS.FELINO.CONTROLADORESFISCALES.CODIGO != 0 )

				if !llRetorno
					do case
					case lnTipoComprobante = 3
						lcMensaje = "No es posible generar la factura electrónica indicada en 'Ajuste de cheques de terceros rechazados'. Verifique la configuración la misma en Parámetros del Sistema -> Gestión de Ventas -> Facturación electrónica."
					case lnTipoComprobante = 2
						lcMensaje = "No es posible generar la factura fiscal indicada en 'Ajuste de cheques de terceros rechazados'. Verifique la configuración del controlador fiscal en Parámetros del Sistema -> Controladores fiscales."
					endcase
					this.AgregarInformacion( lcMensaje )
				endif
			endif
			
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AgregarCuponesIntegradosAColeccionDeHuerfanos() as Void 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function HayCuponesHuerfanosAplicados() as Boolean 
		return .f.
	endfunc 	

	*-----------------------------------------------------------------------------------------
	function EliminarLosCuponesAplicadosEnOtroComprobante() as Void  
	endfunc 	

	*-----------------------------------------------------------------------------------------
	protected function ValidarStockDispoibleAlGrabar() as Boolean
		return .T.
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function SetearCajaEnItems() as Void
		local loItemValor as Object, lnCaja as Integer, llGeneraContracomprobante as Boolean
		
		lnCaja = this.CajaOrigen_pk
		llGeneraContracomprobante = This.CorrespondeGenerarContracomprobante()
		
		for each loItemValor in this.Valores
			if !this.VerificarContexto( "B" )
				if llGeneraContracomprobante or empty( loItemValor.CajaValor )
					loItemValor.Caja_pk = lnCaja
				else
					loItemValor.Caja_pk = loItemValor.CajaValor
				endif
			else
				loItemValor.Caja_pk = this.ObtenerValorCaja( loItemValor )
			endif
		endfor
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Modificar() as Void
		if this.esComprobanteValidoParaModificar()
			dodefault()
			if empty( this.CajaOrigen_pk )
				this.CajaOrigen_pk = goCaja.ObtenerNumeroDeCajaActiva()
			endif
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerCajaOrigen() as Integer
		return goCaja.ObtenerNumeroDeCajaAUsarEnValores()
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function Setear_CajaOrigen( txVal as variant ) as void
		if this.VerificarContexto( "B" )
			this.CajaOrigen_Pk = goCaja.ObtenerNumeroDeCajaActiva()
		else
			dodefault( txVal )
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerValorCaja( toItemValor as Object ) as Integer
		local lnRetorno as Integer, lcXmlValores as String
		
		lcXmlValores = this.Valores.oItem.Valor.Oad.ObtenerDatosEntidad( "Caja", "Codigo = '" + ToItemValor.Valor_Pk + "'" )
		this.XmlACursor( lcXmlValores, "CurValor" )
		
		if reccount( "CurValor" ) > 0
			lnRetorno = CurValor.Caja
		endif
		
		use in select( "CurValor" )
		
		if empty( lnRetorno )
			lnRetorno = goCaja.ObtenerNumeroDeCajaActiva()
		endif
		
		return lnRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function SetearControlDeStock( tlValor as Boolean ) as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function LimpiarNombreEntidadAfectada() as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function SetearentregaPosteriorParaFacturasAnteriores() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Setear_SignoDeMovimiento( txVal as Variant ) as Void
		
		if this.Tipo = 1 and txVal = 1
			dodefault( txVal )
		endif
		
		if this.Tipo != 1 and txVal = -1
			dodefault( txVal )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function RestaurarGenHabilitar() as Void
		dodefault()
		this.lHabilitarCajaOrigen_PK = this.lControlCajaOrigen
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EstablecerEstadoCajaOrigen() as Void
		this.lHabilitarCajaOrigen_PK = goservicios.seguridad.pediraccesoentidad( upper( alltrim( this.cNombre ) ), "HABILITARCAMBIOCAJAORIGEN" )
		this.lControlCajaOrigen = this.lHabilitarCajaOrigen_PK
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoActualizarCircuitoCheque() as Void

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarConsistenciaCheques() as Boolean
		local llRetorno as Boolean, loItem as Object
		llRetorno = .t.
		for each loItem in this.Valores FOXOBJECT
			if inlist(loItem.tipo,TIPOVALORCIRCUITOCHEQUETERCERO,TIPOVALORCUENTABANCARIA,TIPOVALORCIRCUITOCHEQUEPROPIO)
				if loItem.Tipo # this.oColaboradorCheques.ObtenerTipoMovimiento( this.Concepto.EstadoCheque )
					llRetorno = .f.
					this.AgregarInformacion( 'El tipo sugerido para comprobantes de caja es incorrecto para el estado del cheque seleccionado', 0 )
				endif
			endif
		next
		return llRetorno
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function Validar_Tipo( txVal as variant ) as Boolean
		local llRetorno as boolean
		llRetorno = dodefault( txVal )
		if llRetorno and this.lValidacionInteractiva and this.Tipo # txVal
			if !this.ValidarTipoDeMovimientoEnCheques()
				llRetorno = .F.
			endif
		endif

		return llRetorno
	endfunc

	*--------------------------------------------------------------------------------------------------------
	protected function ValidarTipoDeMovimientoEnCheques() as Boolean
		local llRetorno as Boolean, loItem as Object
		llRetorno = .t.
		for each loItem in this.Valores FOXOBJECT
			if inlist(loItem.tipo, TIPOVALORCIRCUITOCHEQUETERCERO)
				llRetorno = .f.
				this.oMensaje.Advertir('No puede cambiar el tipo de movimiento teniendo cheque(s) de terceros cargados (' + alltrim(loItem.Valor_PK) + ")")
				exit
			endif
			if inlist(loItem.tipo, TIPOVALORCHEQUETERCERO)
				if this.Valores.oItem.ObtenerAccionDeCheque( loItem ) = 1
					llRetorno = .f.
					this.oMensaje.Advertir('No puede cambiar el tipo de movimiento teniendo cheque(s) de terceros ingresados (' + alltrim(loItem.Valor_PK) + ")")
					exit
				endif
			endif
			if inlist(loItem.tipo, TIPOVALORCIRCUITOCHEQUEPROPIO)
				llRetorno = .f.
				this.oMensaje.Advertir('No puede cambiar el tipo de movimiento teniendo cheque(s) propio(s) cargados (' + alltrim(loItem.Valor_PK) + ")")
				exit
			endif
			if inlist(loItem.tipo, TIPOVALORCHEQUEPROPIO)
				if this.Valores.oItem.ObtenerAccionDeCheque( loItem ) = 1
					llRetorno = .f.
					this.oMensaje.Advertir('No puede cambiar el tipo de movimiento teniendo cheque(s) propio(s) ingresados (' + alltrim(loItem.Valor_PK) + ")")
					exit
				endif
			endif
		next
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerDetalleDeValores() as Object
		local loRetorno as Object
		loRetorno = null
		if type( "this.Valores" ) = "O"
			if pemstatus( this, "Valores", 5 )
				loRetorno = this.Valores
			endif
		endif
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerNombreTransferencia() as String
		return this.cNombreTransferencia 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarMonedaCuentaBancaria() as Boolean
		local llRetorno as Boolean, lcWhere as string, lcValor as String, lcCursor as String, lcXml as String, lcValores as String
		llRetorno = .t.
		lcCursor = sys(2015)
		lcWhere = ""
		lcValores = ""
		if !empty( this.Concepto_pk ) and !empty( this.Concepto.CuentaBancaria_pk ) and !empty( this.Concepto.CuentaBancaria.MonedaCuenta_pk )
			for each loItem in this.Valores
				if !empty( loItem.Valor_pk )
					lcValor = "'" + upper( rtrim( loItem.Valor_pk ) ) + "', "
					if not( lcValor $ lcWhere )
						lcWhere = lcWhere + lcValor
					endif					
				endif
			endfor
			lcWhere = left( lcWhere, len( lcWhere ) - 2 )
			lcWhere = "CODIGO in (" + lcWhere + ") and SIMBOLOMONETARIO != '" + alltrim( this.Concepto.CuentaBancaria.MonedaCuenta_pk )+ "'"
			lcXml = this.Valores.oItem.Valor.oAd.obtenerdatosentidad( "CODIGO", lcWhere )		
			this.XmlACursor( lcXml, lcCursor )
			select ( lcCursor )
			scan
				llRetorno = .f.
				lcValores = lcValores + "'" + rtrim( codigo ) + "', "
			endscan
			if !empty( lcValores ) and reccount( lcCursor ) > 0
				lcValores = substr( lcValores, 1, len( lcValores ) - 2 )
				this.AgregarInformacion( "Los siguientes valores no se puede utilizar: " + lcValores + ". La moneda debe coincidir con la de la cuenta bancaria."  )
			endif
			use in select( lcCursor )
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function DebeGenerarRegistrosConciliables() as Boolean
		local llRetorno as Boolean
		llRetorno = !empty( this.Concepto_pk ) and !empty( this.Concepto.CuentaBancaria_pk )
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerSignoDeMovimientoRegistroConciliable( toDetalle as Object, tnNroItem as Integer ) as Integer
		local lnRetorno as Integer, lnModificaSigno as Integer
		lnModificaSigno = 1
		if type( "toDetalle" ) = "O" and type( "tnNroItem" ) = "N" and tnNroItem > 0 and toDetalle.Item[ tnNroItem ].Tipo = TIPOVALORCIRCUITOCHEQUEPROPIO
			lnModificaSigno = -1
		endif
		lnRetorno = iif( this.Tipo = 1, -1, 1 ) * lnModificaSigno
		return lnRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerDescripcionComprobante() as Void
		return "Comprobante de caja" + " " + padl( int( this.Numero ), 8, "0" )
	endfunc

	*-----------------------------------------------------------------------------------------
	Protected Function HabilitarTipoDeMovimiento() as Boolean
		Local llRetorno as Boolean, loDetalle as zooColeccion
		loDetalle = this.ObtenerDetalleDeValores()
		llRetorno = this.lEstaGenerandoContraComprobante or ( empty(this.Concepto.EstadoCheque) and !loDetalle.ObtenerTipoDeUsoDeChequesDeTerceros() > 0 )
		Return llRetorno
	EndFunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarConceptoConChequesCargados( txVal as variant, txValOld as variant ) as Boolean
		local llRetorno as Boolean, loDetalle as Object, llTieneCheques as Boolean, lcMensaje as String
		llRetorno = .t.
		llTieneCheques = .f.
        if this.CargaManual() and this.lValidacionInteractiva
	        loDetalle = this.ObtenerDetalleDeValores()
	        if loDetalle.Count > 0 
		        llTieneCheques = loDetalle.ObtenerTipoDeUsoDeChequesDeTerceros() > 0 or loDetalle.ObtenerTipoDeUsoDeChequesPropios() > 0
		        if llTieneCheques
		    		if !this.PermiteCambioEstadoDeCheque(txVal, txValOld, this.Tipo)
		        		llRetorno = .f.
						lcMensaje = "No es posible utilizar el concepto " + alltrim(txVal) + " porque no se puede modificar el estado de cheque teniendo cheques de terceros ingresados." 
							this.oMensaje.Advertir(lcMensaje)
		    		endif
		    		if llRetorno and !this.PermiteCambioTipoDeMovimiento(txVal)
		        		llRetorno = .f.
						lcMensaje = "No es posible utilizar el concepto " + alltrim(txVal) + " porque no se puede modificar el tipo de movimiento teniendo cheques de terceros ingresados."
							this.oMensaje.Advertir(lcMensaje)
		    		endif
		        endif
	        endif
        endif
        if llRetorno
        	this.lCambioConcepto = !( alltrim( txVal ) == alltrim( txValOld ) )
        else
        	this.Concepto_PK = txValOld 
        endif
        if llRetorno
        	this.lHabilitarTipo = !llTieneCheques
        endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	Protected Function PermiteCambioEstadoDeCheque(tcConcepto as String, tcConceptoOld as String, tnTipoMovimiento as Integer) as Boolean
		Local llRetorno as Boolean, loEntidad as Object, loDetalle as Object, lcEstadoDeConcepto as String, lcEstadoDeConceptoOld as String
		llRetorno = .f.
		loEntidad = _screen.zoo.instanciarentidad( "ConceptoCaja" )
		loEntidad.Codigo = tcConcepto
		lcEstadoDeConcepto = loEntidad.EstadoCheque
		loEntidad.Codigo = tcConceptoOld
		lcEstadoDeConceptoOld = loEntidad.EstadoCheque
 		loEntidad.Release()

		if empty( alltrim( lcEstadoDeConceptoOld ) ) and this.HaySeteadoUnNumeroDeCajaEnProcesoDeCierre()
			lcEstadoDeConceptoOld = this.ObtenerEstadoDestinoPorDefaultParaLosCheques()
		endif

		if ( lcEstadoDeConceptoOld == lcEstadoDeConcepto ) ;
			or ( tnTipoMovimiento = TIPOMOVIMIENTOSALIDA  and ( ( lcEstadoDeConceptoOld == "ENTRE" and empty( lcEstadoDeConcepto ) ) ;
															 or ( empty(lcEstadoDeConceptoOld ) and lcEstadoDeConcepto == "ENTRE" ) ) ;
				);
			or ( tnTipoMovimiento = TIPOMOVIMIENTOENTRADA and ( ( lcEstadoDeConceptoOld == "CARTE" and empty( lcEstadoDeConcepto ) ) ;
															 or ( empty(lcEstadoDeConceptoOld ) and lcEstadoDeConcepto == "CARTE" ) ) ;
				)

			llRetorno = .t.
		endif

		Return llRetorno
	EndFunc 

	*-----------------------------------------------------------------------------------------
	Protected Function PermiteCambioTipoDeMovimiento(tcConcepto as variant) as Boolean
		Local llRetorno as Boolean, loEntidad as Object, loDetalle as Object, lnTipoDeMovimiento as Integer
		llRetorno = .t.
		if !this.HaySeteadoUnNumeroDeCajaEnProcesoDeCierre()
			loEntidad = _screen.zoo.instanciarentidad( "ConceptoCaja" )
			loEntidad.Codigo = tcConcepto
			lnTipoDeMovimiento = loEntidad.Tipo
	 		loEntidad.Release()
			if !this.lHabilitarTipo and lnTipoDeMovimiento  # this.Tipo
				llRetorno = .f.
	    	endif
		endif
		Return llRetorno
	EndFunc

	*-----------------------------------------------------------------------------------------
	function LimpiarIdItemComponente( toDetalle as Object ) as Void
		local loItem as Object
		for each loItem in toDetalle
			loItem.IdItemComponente = ""
		endfor
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarOrigenDestinoSegunBaseActiva() as Boolean
		local lcOrigenSucursalActiva as String, llRetorno as Boolean
		
		llRetorno = .T.
		lcOrigenSucursalActiva = this.ObtenerOrigenSucursalActiva()
		if !this.lPermiteIgualOrigenDestino and upper( alltrim( this.origendestino_pk ) ) == upper( alltrim( lcOrigenSucursalActiva ) )
			llRetorno = .F.
		endif
		
		return llRetorno 
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarOrigenDestinoEmpaquetarAlGrabar() as Boolean
		
		llRetorno = this.ValidarOrigenDestinoSegunBaseActiva()

		if !llRetorno
			loZooException = _screen.zoo.crearobjeto( "ZooException" )
			loLogueador = goServicios.logueos.ObtenerObjetoLogueo( loZooException )
			lcTexto = 'No es posible empaquetar el comprobante de caja número ' + transform( this.numero ) + ', para hacerlo deberá habilitar el parámetro ' +;
			'Comunicaciones-> Paquetes de datos-> Comprobantes de caja-> Permitir empaquetar comprobantes ' +;
			'de caja con el mismo Origen/Destino que el de la base de datos activa.'
			loLogueador.Escribir( lcTexto )
			goServicios.Logueos.Guardar( loLogueador )
			loLogueador = null
			loZooException = null
		endif
		
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerEstadoDestinoPorDefaultParaLosCheques() as String
		local lcEstado as String
		lcEstado = this.oColaboradorCheques.ObtenerEstadoDestinoPorDefaultSegunEntidad( this, TIPOVALORCIRCUITOCHEQUETERCERO )
		return lcEstado
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Nuevo() as Void
		dodefault() 
		this.ValidarPedirCotizacionObligatoria( this.Fecha )
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarPedirCotizacionObligatoria( tdFecha ) as Boolean
		local ldFecha as Date, llRetorno as Boolean
		llRetorno = .T.
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
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function SetearFechaEnItems( txVal as Variant ) as Void
		local loItem as Object, lnIndice as Integer
		if This.CargaManual()
		   for lnIndice = 1 to This.valores.Count
				loItem = This.valores.Item[lnIndice]
				loitem.FechaComp = txVal
			endfor
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function esComprobanteValidoParaModificar() as Boolean
		local llRetorno as Boolean, loItemValor as Object, lcMensaje as String
		llRetorno = .t.
		if !empty(this.EstadoTransferencia) or !empty(this.FechaTransferencia)
			if this.Concepto.EstadoCheque = 'ENVIA'
				for each loItemValor in this.Valores FOXOBJECT
					if inlist(loItemValor.Tipo,TIPOVALORCIRCUITOCHEQUETERCERO,TIPOVALORCIRCUITOCHEQUEPROPIO)
						lcMensaje = "No puede modificar un comprobante con estado enviado que incluya cheques."
						goServicios.Errores.LevantarExcepcion( lcMensaje )
						llRetorno = .f.
						exit
					endif
				endfor
			endif
		endif
		return llRetorno
	endfunc 

enddefine
