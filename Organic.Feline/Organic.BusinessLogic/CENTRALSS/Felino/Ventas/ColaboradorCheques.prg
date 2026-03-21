Define Class ColaboradorCheques As ZooSession Of ZooSession.prg

	#If .F.
		Local This As ColaboradorCheques As ColaboradorCheques.prg
	#Endif

	#define ENCARTERA		"CARTE"
	#define ENCUSTODIA		"CUSTO" 
	#define ENTREGADO		"ENTRE"
	#define COBRADO			"COBRA"
	#define DEPOSITADO		"DEPOS"
	#define RECHAZADO		"RECHA"
	#define BAJA			"BAJA"
	#define ANULADO			"ANULA"
	#define DEVUELTO		"DEVOL"
	#define ENVIADO			"ENVIA"
	#define ENVIORECHAZADO	"ENVRE"
	#define PREPARADO		"PREPA"
	#define ACREDITADO		"ACRED"
	#define DEBITADO		"DEBIT"
	#define ENTRANSITO		"TRANS"
	#define CANCELADO		"CANCE"

	#define TIPONODEFINIDO 0
	#define TIPOENTRADA 1
	#define TIPOSALIDA 2

	#define TIPOVALORCHEQUETERCERO 			4
	#define TIPOVALORCHEQUEPROPIO 			9
	#define TIPOVALORCIRCUITOCHEQUETERCERO	12
	#define TIPOVALORCIRCUITOCHEQUEPROPIO	14

	protected oColEstados
	oColEstados = null
	protected oTabFlujo
	oTabFlujo = null
	protected lImplementaEstadosDeCheques
	lImplementaEstadosDeCheques = .f.
	oColFlujosEstados = null
	oEntidadCheque = null
	oEntidadChequePropio = null

	*-------------------------------------------------------------------
	Function Init() as Boolean
		DoDefault()
		this.InicializarColaborador()
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function oEntidadCheque_Access() as variant
		if !this.ldestroy and ( type( "this.oEntidadCheque" ) != 'O' or isnull( this.oEntidadCheque ) )
			this.oEntidadCheque = _Screen.Zoo.InstanciarEntidad( 'Cheque' )
		endif
		return this.oEntidadCheque
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function oEntidadChequePropio_Access() as variant
		if !this.ldestroy and ( type( "this.oEntidadChequePropio" ) != 'O' or isnull( this.oEntidadChequePropio ) )
			this.oEntidadChequePropio = _Screen.Zoo.InstanciarEntidad( 'ChequePropio' )
		endif
		return this.oEntidadChequePropio 
	endfunc

	*-----------------------------------------------------------------------------------------
	function Destroy() as Void
		if this.ldestroy and type( "this.oEntidadCheque" ) == 'O'
			this.oEntidadCheque.Release()
		endif
		if this.ldestroy and type( "this.oEntidadChequePropio" ) == 'O'
			this.oEntidadChequePropio.Release()
		endif
		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerDescripcion( tcEstado as String ) as String
		local lcRetorno as String, loEstado as Object
		lcRetorno = ""
		for each loItem in this.oColEstados FOXOBJECT
			if upper(alltrim(loItem.Codigo)) = upper(alltrim(tcEstado))
				lcRetorno = alltrim( loItem.Descripcion )
			endif
		next
		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ImplementaEstadosDeCheques() as Boolean
		return this.lImplementaEstadosDeCheques
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerEstadoDestinoPorDefaultSegunEntidad( toEntidad as Object, tnTipoValor as Integer, tcNombreDetallePadre as String ) as String
		local lcEstado as String, lcEntidadParaFlujosEstados as String, loItem as Object, lnTipoMovimiento as Integer

		lcEstado = ""
		lcEntidadParaFlujosEstados = this.ObtenerNombreEntidadParaFlujosEstados( toEntidad )
		lnTipoMovimiento = this.ObtenerTipoMovimientoDeComprobante( toEntidad, tcNombreDetallePadre )

		for each loItem in This.oColFlujosEstados foxobject
			if loItem.TipoValor = tnTipoValor ;
					and loItem.Entidad = lcEntidadParaFlujosEstados ;
					and loItem.TipoMovimiento = lnTipoMovimiento ;
					and loItem.EsEstadoDestinoDefault
				lcEstado = loItem.EstadoDestino
				exit
			endif
		endfor

		return lcEstado
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerTipoMovimientoDeComprobante( toEntidad as Object, tcNombreDetallePadre as String ) as Integer
		local lnTipoMovimiento as Integer
		lnTipoMovimiento = 0
		with toEntidad 
			do case
				case .cNombre == "ORDENDEPAGO"
					lnTipoMovimiento = TIPONODEFINIDO
				case .cNombre == "CONCILIACIONES"
					lnTipoMovimiento = TIPONODEFINIDO
				case .cNombre == "DESCARGADECHEQUES"
					lnTipoMovimiento = TIPOSALIDA
				case .cNombre == "CANJEDECUPONES"
					if this.EsCanjeDeCuponesValoresARecibir( toEntidad, tcNombreDetallePadre )
						lnTipoMovimiento = TIPOENTRADA
					else
						lnTipoMovimiento = TIPOSALIDA
					endif
				otherwise
					if pemstatus( toEntidad, "SignoDeMovimiento", 5 ) and .SignoDeMovimiento > 0
						lnTipoMovimiento = TIPOENTRADA
					else
						lnTipoMovimiento = TIPOSALIDA
					endif
			endcase
		endwith
		return lnTipoMovimiento
	endfunc

	*-----------------------------------------------------------------------------------------
	Function ObtenerEstadoEnCartera() as String
		return ENCARTERA
	endfunc 


	*-----------------------------------------------------------------------------------------
	Function ObtenerEstadoEnCustodia() as String
		return ENCUSTODIA 
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function ObtenerEstadoEntregado() as String
		return ENTREGADO
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function ObtenerEstadoPreparado() as String
		return PREPARADO
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function ObtenerEstadoAcreditado() as String
		return ACREDITADO
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function ObtenerEstadoDebitado() as String
		return DEBITADO
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function ObtenerEstadoEnviado() as String
		return ENVIADO
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function ObtenerEstadoEnvioRechazado() as String
		return ENVIORECHAZADO
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function ObtenerEstadoEnTransito() as String
		return ENTRANSITO
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected Function InicializarColaborador() as Void
		this.CargarEstados()
		this.CargarFlujosEstados()
	Endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerEstadosValidos( toComprobante as Object, toCheque as Object, toEstado as String ) as Collection
		local loRetorno as Collection
		loRetorno = _Screen.Zoo.CrearObjeto( "zooColeccion", "zooColeccion.prg")
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsCambioDeEstadoValido( toComprobante as Object, toCheque as Object, toEstado as String ) as Boolean
		local llRetorno as Boolean
		llRetorno = .f.
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function ObtenerColeccionEstados() as Collection
		local loRetorno as Collection
		loRetorno = this.oColEstados
		return loRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerTipoMovimiento( tcEstado as String ) as Integer
		local lnRetorno as Integer, loEstado as Object
		lnRetorno = 0
		for each loItem in this.oColEstados FOXOBJECT
			if upper(alltrim(loItem.Codigo)) = upper(alltrim(tcEstado))
				lnRetorno = loItem.TipoMovimiento
				exit
			endif
		next
		return lnRetorno

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected Function CargarEstados() as Void
		local loItem as Object
		this.oColEstados = _Screen.Zoo.CrearObjeto( "zooColeccion", "zooColeccion.prg")
	
*!*			Parametros de la funcion ObtenerItemEstado( 
*!*			tcCodigo <codigo>, 
*!*			tcDescripcion <descripcion del estado>, 
*!*			tnTipoMovimiento <tipo de movimiento : entrada, salida o sin definir>, 
*!*			tlEsSeleccionable <se puede seleccionar en un concepto para ser aplicado manualmente>, 
*!*			tlPropio <aplica para cheques propios>, 
*!*			tlTercero <aplica para cheques de terceros>, 
*!*			tlEnCaja <para ser usado en caja>) as Object
*!*			tlGestinoCHCustodia <para ser usado en Gestion de cheques en custodia>) as Object


		loItem = this.ObtenerItemEstado(ENCARTERA,"En cartera",TIPOENTRADA,.t.,.t.,.t.,.t.,.f.)
		this.oColEstados.Agregar( loItem, loItem.Codigo )
		loItem = this.ObtenerItemEstado(ENCUSTODIA,"En custodia",TIPOSALIDA,.t.,.f.,.t.,.t.,.t.)  && mnavas
		this.oColEstados.Agregar( loItem, loItem.Codigo )
		loItem = this.ObtenerItemEstado(ENTREGADO,"Entregado",TIPOSALIDA,.t.,.t.,.t.,.t.,.f.)
		this.oColEstados.Agregar( loItem, loItem.Codigo )
		loItem = this.ObtenerItemEstado(COBRADO,"Cobrado",TIPOSALIDA,.t.,.f.,.t.,.t.,.f.)
		this.oColEstados.Agregar( loItem, loItem.Codigo )
		loItem = this.ObtenerItemEstado(DEPOSITADO,"Depositado",TIPOSALIDA,.t.,.f.,.t.,.t.,.t.)
		this.oColEstados.Agregar( loItem, loItem.Codigo )
		loItem = this.ObtenerItemEstado(RECHAZADO,"Rechazado",TIPOENTRADA,.t.,.t.,.t.,.t.,.f.)
		this.oColEstados.Agregar( loItem, loItem.Codigo )
		loItem = this.ObtenerItemEstado(BAJA,"Baja",TIPOSALIDA,.t.,.t.,.t.,.t.,.f.)
		this.oColEstados.Agregar( loItem, loItem.Codigo )
		loItem = this.ObtenerItemEstado(ANULADO,"Anulado",TIPOSALIDA,.f.,.t.,.f.,.f.,.f.)
		this.oColEstados.Agregar( loItem, loItem.Codigo )
		loItem = this.ObtenerItemEstado(CANCELADO,"Cancelado",TIPOENTRADA,.f.,.t.,.f.,.f.,.f.)
		this.oColEstados.Agregar( loItem, loItem.Codigo )
		loItem = this.ObtenerItemEstado(DEVUELTO,"Devuelto",TIPOSALIDA,.t.,.f.,.t.,.t.,.f.)
		this.oColEstados.Agregar( loItem, loItem.Codigo )
		loItem = this.ObtenerItemEstado(PREPARADO,"Comprometido",TIPONODEFINIDO,.f.,.t.,.t.,.f.,.f.)
		this.oColEstados.Agregar( loItem, loItem.Codigo )
		loItem = this.ObtenerItemEstado(DEBITADO,"Debitado",TIPONODEFINIDO,.f.,.t.,.f.,.f.,.f.)
		this.oColEstados.Agregar( loItem, loItem.Codigo )
		loItem = this.ObtenerItemEstado(ACREDITADO,"Acreditado",TIPONODEFINIDO,.f.,.f.,.t.,.f.,.f.)
		this.oColEstados.Agregar( loItem, loItem.Codigo )

		loItem = this.ObtenerItemEstado(ENVIADO,"Enviado",TIPOSALIDA,.t.,.t.,.t.,.t.,.f.)
		this.oColEstados.Agregar( loItem, loItem.Codigo )
		loItem = this.ObtenerItemEstado(ENVIORECHAZADO,"Envío rechazado",TIPONODEFINIDO,.f.,.t.,.t.,.t.,.f.)
		this.oColEstados.Agregar( loItem, loItem.Codigo )
		loItem = this.ObtenerItemEstado(ENTRANSITO,"En tránsito",TIPONODEFINIDO,.f.,.t.,.t.,.t.,.f.)
		this.oColEstados.Agregar( loItem, loItem.Codigo )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected Function ObtenerItemEstado( tcCodigo as String, tcDescripcion as String, tnTipoMovimiento as Integer, tlEsSeleccionable as Boolean, tlPropio as Boolean, tlTercero as Boolean, tlEnCaja as Boolean, tlCHCUSTODIA as Boolean ) as Object
		local loRetorno as Object
		loRetorno = this.ObtenerItemAuxEstado()
		loRetorno.Codigo = tcCodigo
		loRetorno.Descripcion = tcDescripcion
		loRetorno.TipoMovimiento = iif(type("tnTipoMovimiento")="N",tnTipoMovimiento,0)
		loRetorno.EsSeleccionable = iif(type("tlEsSeleccionable")="L",tlEsSeleccionable,.f.)
		loRetorno.Propio = iif(type("tlPropio")="L",tlPropio,.f.)
		loRetorno.Tercero = iif(type("tlTercero")="L",tlTercero,.f.)
		loRetorno.EnCaja = iif(type("tlEnCaja")="L",tlEnCaja,.f.)
		loRetorno.CHCUSTODIA = iif(type("tlCHCUSTODIA")="L",tlCHCUSTODIA ,.f.)
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerItemAuxEstado() as Object
		local loItem as Object
		loItem = newobject( "Custom" )
		loItem.AddProperty( "Codigo", "" )
		loItem.AddProperty( "Descripcion", "" )
		loItem.AddProperty( "TipoMovimiento", 0 )
		loItem.AddProperty( "EsSeleccionable", .f. )
		loItem.AddProperty( "Propio", .f. )
		loItem.AddProperty( "Tercero", .f. )
		loItem.AddProperty( "EnCaja", .f. )
		loItem.AddProperty( "CHCUSTODIA", .f. )
		return loItem
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CargarFlujosEstados() as Void
		this.oColFlujosEstados = _Screen.Zoo.CrearObjeto( "zooColeccion", "zooColeccion.prg")

		with this.oColFlujosEstados
*!*	 Flujos de estados nuevo tipo cheque de terceros Circuito
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUETERCERO, "COMPRAS_FAC",			TIPOSALIDA,     ENCARTERA,      ENTREGADO,  .T., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUETERCERO, "COMPRAS_NC",			TIPOENTRADA,    "ninguno",      ENCARTERA,  .T., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUETERCERO, "VENTAS_FAC",			TIPOENTRADA,    "ninguno",      ENCARTERA,  .T., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUETERCERO, "VENTAS_NC",			TIPOSALIDA,     ENCARTERA,      ENTREGADO,  .T., .F. ) )

			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUETERCERO, "CANJEDECUPONES",		TIPOSALIDA,     ENCARTERA,      ENTREGADO,  .T., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUETERCERO, "CANJEDECUPONES",		TIPOSALIDA,     ENCARTERA,      COBRADO,    .F., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUETERCERO, "CANJEDECUPONES",		TIPOSALIDA,     RECHAZADO,      DEVUELTO,   .F., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUETERCERO, "CANJEDECUPONES",		TIPOENTRADA,    ENTREGADO,      ENCARTERA,  .T., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUETERCERO, "CANJEDECUPONES",		TIPOENTRADA,    ENTREGADO,      RECHAZADO,  .F., .F. ) )

			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUETERCERO, "COMPROBANTEDECAJA",	TIPOSALIDA,     ENCARTERA,      ENTREGADO,  .T., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUETERCERO, "COMPROBANTEDECAJA",	TIPOSALIDA,     ENCARTERA,      DEPOSITADO, .F., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUETERCERO, "COMPROBANTEDECAJA",	TIPOSALIDA,     ENCARTERA,      ENCUSTODIA, .F., .F. ) )	&& mnavas
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUETERCERO, "COMPROBANTEDECAJA",	TIPOSALIDA,     ENCARTERA,      BAJA,       .F., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUETERCERO, "COMPROBANTEDECAJA",	TIPOSALIDA,     ENCARTERA,      ENVIADO,    .F., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUETERCERO, "COMPROBANTEDECAJA",	TIPOSALIDA,     RECHAZADO,      DEVUELTO,   .F., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUETERCERO, "COMPROBANTEDECAJA",	TIPOSALIDA,     RECHAZADO,      BAJA,       .F., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUETERCERO, "COMPROBANTEDECAJA",	TIPOSALIDA,     RECHAZADO,      ENVIADO,    .F., .F. ) )
			*.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUETERCERO, "COMPROBANTEDECAJA",	TIPOENTRADA,    ENCUSTODIA,     RECHAZADO,  .F., .F. ) ) 	&& mnavas esta bien??
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUETERCERO, "COMPROBANTEDECAJA",	TIPOENTRADA,    ENTREGADO,      ENCARTERA,  .T., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUETERCERO, "COMPROBANTEDECAJA",	TIPOENTRADA,    ENTREGADO,      RECHAZADO,  .F., .F. ) )

			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUETERCERO, "COMPROBANTEDECAJA",	TIPOENTRADA,    DEPOSITADO,     RECHAZADO,  .F., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUETERCERO, "COMPROBANTEDECAJA",	TIPOENTRADA,    ENVIADO,        ENCARTERA,  .F., .T. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUETERCERO, "COMPROBANTEDECAJA",	TIPOENTRADA,    ENTRANSITO,     ENCARTERA,  .F., .T. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUETERCERO, "COMPROBANTEDECAJA",	TIPOENTRADA,    ENTRANSITO,     RECHAZADO,  .F., .T. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUETERCERO, "COMPROBANTEDECAJA",	TIPOENTRADA,    ENVIORECHAZADO, ENCARTERA,  .F., .T. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUETERCERO, "COMPROBANTEDECAJA",	TIPOENTRADA,    ENVIORECHAZADO, RECHAZADO,  .F., .T. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUETERCERO, "COMPROBANTEDECAJA",	TIPOENTRADA,    ENCARTERA,      ENCARTERA,  .F., .T. ) )  && flujo de estados interno para contracomprobantes automáticos de caja

			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUETERCERO, "DESCARGADECHEQUES",	TIPOSALIDA,     ENCARTERA,      ENTREGADO,  .T., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUETERCERO, "COMPROBANTEPAGO",		TIPOSALIDA,     ENCARTERA,      ENTREGADO,  .T., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUETERCERO, "ORDENDEPAGO",			TIPONODEFINIDO, ENCARTERA,      PREPARADO,  .T., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUETERCERO, "PAGO",				TIPOSALIDA,     PREPARADO,      ENTREGADO,  .T., .F. ) )

			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUETERCERO, "VALORESENTRANSITO",	TIPONODEFINIDO,  ENVIORECHAZADO, ENCARTERA,  .T., .T. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUETERCERO, "VALORESENTRANSITO",	TIPONODEFINIDO,  ENVIORECHAZADO, RECHAZADO,  .F., .T. ) )

*!*	 Flujos de estados tipo cheque de terceros Discontinuado
*!*				.Agregar( this.ObtenerItemFlujo( TIPOVALORCHEQUETERCERO, "COMPRAS_FAC",			TIPOSALIDA,     "ninguno",      ENTREGADO,  .T., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCHEQUETERCERO, "COMPRAS_FAC",			TIPOSALIDA,     ENCARTERA,      ENTREGADO,  .T., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCHEQUETERCERO, "COMPRAS_NC",			TIPOENTRADA,    ENTREGADO,      ENCARTERA,  .T., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCHEQUETERCERO, "VENTAS_FAC",			TIPOENTRADA,    ENTREGADO,      ENCARTERA,  .T., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCHEQUETERCERO, "VENTAS_NC",			TIPOSALIDA,     ENCARTERA,      ENTREGADO,  .T., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCHEQUETERCERO, "CANJEDECUPONES",		TIPOSALIDA,     ENCARTERA,      ENTREGADO,  .T., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCHEQUETERCERO, "CANJEDECUPONES",		TIPOENTRADA,    ENTREGADO,      ENCARTERA,  .T., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCHEQUETERCERO, "COMPROBANTEDECAJA",	TIPOENTRADA,    "ninguno",      ENCARTERA,  .T., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCHEQUETERCERO, "DESCARGADECHEQUES",	TIPOSALIDA,     ENCARTERA,      ENTREGADO,  .T., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCHEQUETERCERO, "COMPROBANTEPAGO",		TIPOSALIDA,     ENCARTERA,      ENTREGADO,  .T., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCHEQUETERCERO, "ORDENDEPAGO",			TIPONODEFINIDO, ENCARTERA,      ENTREGADO,  .T., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCHEQUETERCERO, "PAGO",				TIPOSALIDA,     PREPARADO,      ENTREGADO,  .T., .F. ) )

*!*	 Flujos de estados nuevo tipo cheque propio Circuito
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUEPROPIO, "COMPRAS_FAC",			TIPOSALIDA,     "ninguno",      ENTREGADO,  .T., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUEPROPIO, "COMPRAS_NC",			TIPOENTRADA,    ENTREGADO,      ENCARTERA,  .T., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUEPROPIO, "VENTAS_FAC",			TIPOENTRADA,    ENTREGADO,      ENCARTERA,  .T., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUEPROPIO, "VENTAS_NC",			TIPOSALIDA,     "ninguno",      ENTREGADO,  .T., .F. ) )

			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUEPROPIO, "COMPROBANTEDECAJA",	TIPOSALIDA,     ENCARTERA,      ENTREGADO,  .T., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUEPROPIO, "COMPROBANTEDECAJA",	TIPOENTRADA,    ENCARTERA,      ENCARTERA,  .F., .T. ) )  && flujo de estados interno para contracomprobantes automáticos de caja
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUEPROPIO, "COMPROBANTEDECAJA",	TIPOSALIDA,     ENCARTERA,      BAJA     ,  .F., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUEPROPIO, "COMPROBANTEDECAJA",	TIPOSALIDA,     ENCARTERA,      ENVIADO,    .F., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUEPROPIO, "COMPROBANTEDECAJA",	TIPOSALIDA,     RECHAZADO,      ENVIADO,    .F., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUEPROPIO, "COMPROBANTEDECAJA",	TIPOENTRADA,    "ninguno",      ENCARTERA,  .T., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUEPROPIO, "COMPROBANTEDECAJA",	TIPOENTRADA,    ENTREGADO,      RECHAZADO,  .F., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUEPROPIO, "COMPROBANTEDECAJA",	TIPOENTRADA,    ENTRANSITO,     ENCARTERA,  .F., .T. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUEPROPIO, "COMPROBANTEDECAJA",	TIPOENTRADA,    ENTRANSITO,     RECHAZADO,  .F., .T. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUEPROPIO, "COMPROBANTEDECAJA",	TIPOENTRADA,    ENVIORECHAZADO, ENCARTERA,  .F., .T. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUEPROPIO, "COMPROBANTEDECAJA",	TIPOENTRADA,    ENVIORECHAZADO, RECHAZADO,  .F., .T. ) )

			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUEPROPIO, "CANJEDECUPONES",		TIPOSALIDA,     "ninguno",      ENTREGADO,  .T., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUEPROPIO, "CANJEDECUPONES",		TIPOENTRADA,    ENTREGADO,      ENCARTERA,  .T., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUEPROPIO, "CANJEDECUPONES",		TIPOENTRADA,    ENTREGADO,      RECHAZADO,  .F., .F. ) )

			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUEPROPIO, "COMPROBANTEPAGO",		TIPOSALIDA,     "ninguno",      ENTREGADO,  .T., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUEPROPIO, "ORDENDEPAGO",			TIPONODEFINIDO, "ninguno",      PREPARADO,  .T., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUEPROPIO, "ORDENDEPAGO",			TIPONODEFINIDO, ENCARTERA,      PREPARADO,  .F., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUEPROPIO, "PAGO",					TIPOSALIDA, 	PREPARADO,      ENTREGADO,  .T., .F. ) )

			.Agregar( this.ObtenerItemFlujo( TIPOVALORCIRCUITOCHEQUEPROPIO, "CONCILIACIONES",		TIPONODEFINIDO, ENTREGADO,      DEBITADO,  .T., .F. ) )

*!*	 Flujos de estados tipo cheque propio Discontinuado
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCHEQUEPROPIO, "COMPRAS_FAC",			TIPOSALIDA,     "ninguno",      ENTREGADO,  .T., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCHEQUEPROPIO, "COMPRAS_NC",			TIPOENTRADA,    ENTREGADO,      CANCELADO,  .T., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCHEQUEPROPIO, "VENTAS_FAC",			TIPOENTRADA,    ENTREGADO,      CANCELADO,  .T., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCHEQUEPROPIO, "VENTAS_NC",			TIPOSALIDA,     "ninguno",      ENTREGADO,  .T., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCHEQUEPROPIO, "CANJEDECUPONES",		TIPOSALIDA,     "ninguno",      ENTREGADO,  .T., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCHEQUEPROPIO, "CANJEDECUPONES",		TIPOSALIDA,     ENCARTERA,      ENTREGADO,  .T., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCHEQUEPROPIO, "CANJEDECUPONES",		TIPOENTRADA,    ENTREGADO,      CANCELADO,  .T., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCHEQUEPROPIO, "COMPROBANTEDECAJA",	TIPOENTRADA,    ENTREGADO,      CANCELADO,  .T., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCHEQUEPROPIO, "COMPROBANTEDECAJA",	TIPOSALIDA,    "ninguno",      ENTREGADO,  .T., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCHEQUEPROPIO, "COMPROBANTEPAGO",		TIPOSALIDA,     "ninguno",      ENTREGADO,  .T., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCHEQUEPROPIO, "ORDENDEPAGO",			TIPONODEFINIDO, "ninguno",      PREPARADO,  .T., .F. ) )
			.Agregar( this.ObtenerItemFlujo( TIPOVALORCHEQUEPROPIO, "PAGO",					TIPOSALIDA,     PREPARADO,      ENTREGADO,  .T., .F. ) )
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerItemFlujo( tnTipoValor as Integer, tcEntidad as String, tnTipoMovimiento as Integer, tcEstadoOrigen as String, tcEstadoDestino as String, ;
										 tlEsEstadoDestinoDefault as Boolean, tlEsSoloDeUsoInterno as Boolean ) as Object
		local loRetorno as Object
		loRetorno = this.ObtenerItemAuxParaFlujosDeEstados()
		loRetorno.TipoValor = tnTipoValor
		loRetorno.Entidad = tcEntidad
		loRetorno.TipoMovimiento = tnTipoMovimiento
		loRetorno.EstadoOrigen = tcEstadoOrigen
		loRetorno.EstadoDestino = tcEstadoDestino
		loRetorno.EsEstadoDestinoDefault = tlEsEstadoDestinoDefault
		loRetorno.EsSoloDeUsoInterno = tlEsSoloDeUsoInterno
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerItemAuxParaFlujosDeEstados() as Object
		local loItem as Object
		loItem = newobject( "Custom" )
		loItem.AddProperty( "TipoValor", 0 )
		loItem.AddProperty( "Entidad", "" )
		loItem.AddProperty( "TipoMovimiento", 0 )
		loItem.AddProperty( "EstadoOrigen", "" )
		loItem.AddProperty( "EstadoDestino", "" )
		loItem.AddProperty( "EsEstadoDestinoDefault", .f. )
		loItem.AddProperty( "EsSoloDeUsoInterno", .f. )
		return loItem
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerEstadosDeSeleccionSegunEntidad( toEntidad as Object, tnTipoValor as Integer, tcNombreDetallePadre as String ) as Object
		local loItem as Object, loColEstados as Object, lcEntidadParaFlujosEstados as String, lcEstadoDestinoAEvaluar as String, lnTipoMovimiento as Integer, ;
			llIncluirEstadosSoloDeUsoInterno as Boolean, lcNombreDetalle as String

		loColEstados = _Screen.Zoo.CrearObjeto( "zooColeccion", "zooColeccion.prg")
		if type( "tcNombreDetallePadre" ) = "C"
			lcNombreDetalle = tcNombreDetallePadre
		else
			if toEntidad.EsCanjeDeCupones()
				lcNombreDetalle = toEntidad.cFlagDeUltimoDetalleActivo
			else
				lcNombreDetalle = ""
			endif
		endif

		lcEstadoDestinoAEvaluar = this.ObtenerEstadoDestinoParaElCheque( toEntidad, tnTipoValor, lcNombreDetalle )
		lcEntidadParaFlujosEstados = this.ObtenerNombreEntidadParaFlujosEstados( toEntidad )

		do case
			case toEntidad.cNombre = "ORDENDEPAGO"
				lnTipoMovimiento = TIPONODEFINIDO
			case toEntidad.cNombre = "CONCILIACIONES"
				lnTipoMovimiento = TIPONODEFINIDO
			case toEntidad.cNombre = "CANJEDECUPONES"
				if this.EsCanjeDeCuponesValoresARecibir( toEntidad, tcNombreDetallePadre )
					lnTipoMovimiento = TIPOENTRADA
				else
					lnTipoMovimiento = TIPOSALIDA
				endif
			case pemstatus( toEntidad, "SignoDeMovimiento", 5 ) and toEntidad.SignoDeMovimiento > 0
				lnTipoMovimiento = TIPOENTRADA
			otherwise
				lnTipoMovimiento = TIPOSALIDA
		endcase

		llIncluirEstadosSoloDeUsoInterno = this.CorrespondeIncluirEstadosSoloDeUsoInterno( toEntidad )

		for each loItem in This.oColFlujosEstados foxobject
			if loItem.TipoValor = tnTipoValor ;
			 and loItem.Entidad = lcEntidadParaFlujosEstados ;
			 and loItem.TipoMovimiento = lnTipoMovimiento ;
			 and loItem.EstadoDestino = lcEstadoDestinoAEvaluar ;
			 and ( !loItem.EsSoloDeUsoInterno or llIncluirEstadosSoloDeUsoInterno )
				loColEstados.Agregar( loItem.EstadoOrigen )
			endif
		endfor

		return loColEstados
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerCadenaEstadosDeSeleccionSegunEntidad( toEntidad as Object, tnTipoValor as Integer, tcNombreDetallePadre as String ) as String
		local lcRetorno as String, loEstados as Object, lcEstado as String, lcNombreDetalle as String
		lcRetorno = ""
		if type( "tcNombreDetallePadre" ) = "C"
			lcNombreDetalle = tcNombreDetallePadre
		else
			if toEntidad.EsCanjeDeCupones()
				lcNombreDetalle = toEntidad.cFlagDeUltimoDetalleActivo
			else
				lcNombreDetalle = ""
			endif
		endif

		loEstados = this.ObtenerEstadosDeSeleccionSegunEntidad( toEntidad, tnTipoValor, lcNombreDetalle )
		for each lcEstado in loEstados foxobject
			lcRetorno = lcRetorno + iif( empty( lcRetorno ), "", "," ) + "'" + alltrim( lcEstado ) + "'"
		endfor
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerDescripcionDeEstadosDeSeleccionSegunEntidad( toEntidad as Object, tnTipoValor as Integer, tcNombreDetallePadre as String ) as String
		local lcRetorno as String, loEstados as Object, lcEstado as String
		lcRetorno = ""
		loEstados = this.ObtenerEstadosDeSeleccionSegunEntidad( toEntidad, tnTipoValor, tcNombreDetallePadre )
		for each lcEstado in loEstados foxobject 
			lcRetorno = lcRetorno + iif( empty( lcRetorno ), "", ", " ) + "'" + alltrim( this.ObtenerDescripcion( lcEstado ) ) + "'"
		endfor
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerEstadoDestinoParaElCheque( toEntidad as Object, tnTipoValor as Integer, tcNombreDetallePadre as String, toHistorialDetalle as Object ) as String
		local lcEstadoDestino as String, lcEstadoSegunConcepto as String
		lcEstadoSegunConcepto = ""
		if ( tnTipoValor = TIPOVALORCIRCUITOCHEQUETERCERO or tnTipoValor = TIPOVALORCIRCUITOCHEQUEPROPIO ) and pemstatus( toEntidad, "Concepto_PK", 5 ) and !empty( toEntidad.Concepto.EstadoCheque )

			if !toEntidad.EsCanjeDeCupones() ;
				or ( type( "tcNombreDetallePadre" ) = "C" and this.EsCanjeDeCuponesValoresAEntregar( toEntidad, tcNombreDetallePadre ) and toEntidad.Concepto.Tipo = TIPOSALIDA ) ;
				or ( type( "tcNombreDetallePadre" ) = "C" and this.EsCanjeDeCuponesValoresARecibir( toEntidad, tcNombreDetallePadre ) and toEntidad.Concepto.Tipo = TIPOENTRADA )

				lcEstadoSegunConcepto = toEntidad.Concepto.EstadoCheque

				if lcEstadoSegunConcepto = ENVIADO and this.EsComprobanteDeCajaGeneradoPorAceptacionDeValoresEnTransito( toEntidad )		
					if type( "toHistorialDetalle" ) = "O"
						lcEstadoSegunConcepto = this.ObtenerEstadoDeChequeAnteriorAAceptacionDeValoresEnTransito( toHistorialDetalle )
					else
						lcEstadoSegunConcepto = ENCARTERA
					endif
				endif
			endif
		endif

		if empty( lcEstadoSegunConcepto )
			lcEstadoDestino = this.ObtenerEstadoDestinoPorDefaultSegunEntidad( toEntidad, tnTipoValor, tcNombreDetallePadre )
		else
			lcEstadoDestino = lcEstadoSegunConcepto
		endif
		return lcEstadoDestino
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CorrespondeIncluirEstadosSoloDeUsoInterno( toEntidad as Object ) as Boolean
		return this.EsComprobanteDeCajaGeneradoPorAceptacionDeValoresEnTransito( toEntidad ) or this.EsComprobanteDeCajaGeneradoPorPasajeDeUnaCajaAOtra( toEntidad )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsComprobanteDeCajaGeneradoPorAceptacionDeValoresEnTransito( toEntidad as Object ) as Boolean
		return ( toEntidad.cNombre = "COMPROBANTEDECAJA" and toEntidad.Compafec.Count = 1 and toEntidad.Compafec.item[ 1 ].tipoComprobante = 95 )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsComprobanteDeCajaGeneradoPorPasajeDeUnaCajaAOtra( toEntidad as Object ) as Boolean
		return ( toEntidad.cNombre = "COMPROBANTEDECAJA" and toEntidad.lEstaGenerandoContraComprobante )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerEstadoDeChequeAnteriorAAceptacionDeValoresEnTransito( toHistorialDetalle as Object ) as String
		local lcEstadoAnterior as String, lnNroItem as Integer
		lcEstadoAnterior = ENCARTERA
		for lnNroItem = 1 to toHistorialDetalle.Count
			if inlist( toHistorialDetalle.item[ lnNroItem ].Estado, ENCARTERA, RECHAZADO )
				lcEstadoAnterior = toHistorialDetalle.item[ lnNroItem ].Estado
				exit
			endif
		endfor
		return lcEstadoAnterior
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarEstadoDeChequeSeleccionadoSegunEstadoDestino( toEntidad as Object, tcEstadoChequeSeleccionado as String, tnTipoValor as Integer, tcNombreDetallePadre as String ) as Boolean
		local llEsValido as Boolean, loColEstadosDestinoPosibles as Object
		llEsValido = .F.
		loColEstadosDestinoPosibles = this.ObtenerEstadosDeSeleccionSegunEntidad( toEntidad, tnTipoValor, tcNombreDetallePadre )
		for each lcEstadoItem in loColEstadosDestinoPosibles foxobject
			if lcEstadoItem == tcEstadoChequeSeleccionado
				llEsValido = .t.
				exit
			endif
		endfor
		return llEsValido
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerNombreEntidadParaFlujosEstados( toEntidad as Object ) as String
		local lcRetorno as String, llEsComprobanteDeVentas as Boolean, llEsComprobanteDeCompras as Boolean
		lcRetorno = ""
		llEsComprobanteDeVentas = ( "<VENTAS>" $ toEntidad.ObtenerFuncionalidades() )
		llEsComprobanteDeCompras = ( "<COMPRAS>" $ toEntidad.ObtenerFuncionalidades() )

		do case
			case llEsComprobanteDeVentas and !inlist( upper( alltrim( toEntidad.cNombre ) ), "DESCARGADECHEQUES" )
				if toEntidad.SignoDeMovimiento = -1
					lcRetorno = "VENTAS_NC"
				else
					lcRetorno = "VENTAS_FAC"
				endif

			case llEsComprobanteDeCompras and !inlist( upper( alltrim( toEntidad.cNombre ) ), "PAGO", "ORDENDEPAGO", "COMPROBANTEPAGO" )
				if toEntidad.SignoDeMovimiento = 1
					lcRetorno = "COMPRAS_NC"
				else
					lcRetorno = "COMPRAS_FAC"
				endif

			otherwise
				lcRetorno = alltrim( toEntidad.cNombre )
		endcase

		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerEstadosDeSeleccionSegunEntidadValorMovimientoYEstado( tcEntidad as Object, tnTipoDeValor as Integer, tnTipoDeMovimiento as Integer, tcEstado as String ) as Object
		local loItem as Object, loColEstados as Object, lcEntidadParaFlujosEstados as String, lcEstadoDestinoAEvaluar as String, lnTipoMovimiento as Integer, ;
			llIncluirEstadosSoloDeUsoInterno as Boolean

		loColEstados = _Screen.Zoo.CrearObjeto( "zooColeccion", "zooColeccion.prg")
		lcEstadoDestinoAEvaluar = iif(type("tcEstado")="C" and !empty(tcEstado),tcEstado,iif(tnTipoDeMovimiento=1,ENCARTERA,ENTREGADO))
		lcEntidadParaFlujosEstados = tcEntidad && this.ObtenerNombreEntidadParaFlujosEstados( toEntidad )

		do case
			case tcEntidad = "ORDENDEPAGO"
				lnTipoMovimiento = TIPONODEFINIDO
			case tcEntidad = "CANJEDECUPONES"
				lnTipoMovimiento = TIPOSALIDA
			otherwise
				lnTipoMovimiento = tnTipoDeMovimiento
		endcase
		for each loItem in This.oColFlujosEstados foxobject
			if loItem.TipoValor = tnTipoDeValor ;
			 and loItem.Entidad = lcEntidadParaFlujosEstados ;
			 and loItem.TipoMovimiento = lnTipoMovimiento ;
			 and loItem.EstadoDestino = lcEstadoDestinoAEvaluar ;
			 and !loItem.EsSoloDeUsoInterno && ( !loItem.EsSoloDeUsoInterno or llIncluirEstadosSoloDeUsoInterno )
				loColEstados.Agregar( loItem.EstadoOrigen )
			endif
		endfor

		return loColEstados
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerCadenaEstadosDeSeleccionSegunEntidadValorMovimientoYEstado( tcEntidad as Object, tnTipoDeValor as Integer, tnTipoDeMovimiento as Integer, tcEstado as String ) as String
		local lcRetorno as String, loEstados as Object, lcEstado as String
		lcRetorno = ""
		loEstados = this.ObtenerEstadosDeSeleccionSegunEntidadValorMovimientoYEstado( tcEntidad, tnTipoDeValor, tnTipoDeMovimiento, tcEstado )
		for each lcEstado in loEstados foxobject
			lcRetorno = lcRetorno + iif( empty( lcRetorno ), "", "," ) + "'" + alltrim( lcEstado ) + "'"
		endfor
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsCanjeDeCuponesValoresAEntregar( toEntidad as Object, tcNombreDetalle as String ) as Boolean
		return ( toEntidad.EsCanjeDeCupones() and upper( tcNombreDetalle ) = "VALORESAENT" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsCanjeDeCuponesValoresARecibir( toEntidad as Object, tcNombreDetalle as String ) as Boolean
		return ( toEntidad.EsCanjeDeCupones() and upper( tcNombreDetalle ) = "VALORESDETALLE" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function ObtenerColeccionEstadosParaEntidad( tcEntidad as String ) as Collection
		local loRetorno as Collection
		loRetorno = _Screen.Zoo.CrearObjeto( "zooColeccion", "zooColeccion.prg")
		for each loItem in this.oColEstados FOXOBJECT
			do case
			case tcEntidad = 'CHEQUE'
				if loItem.Tercero
					loRetorno.Agregar( loItem )
				endif
			case tcEntidad = 'ITEMCHEQUEHISTORIAL'
				if loItem.Tercero
					loRetorno.Agregar( loItem )
				endif
			case tcEntidad = 'CHEQUEPROPIO'
				if loItem.Propio
					loRetorno.Agregar( loItem )
				endif
			case tcEntidad = 'ITEMCHEQUEPROPIOHIST'
				if loItem.Propio
					loRetorno.Agregar( loItem )
				endif
			case tcEntidad = 'CONCEPTOCAJA'
				if loItem.EsSeleccionable
					loRetorno.Agregar( loItem )
				endif
			case tcEntidad = 'VALORESENTRANSITO'
				if loItem.EnCaja
					loRetorno.Agregar( loItem )
				endif
			case tcEntidad = 'CHEQUESDISPONIBLES'
				if loItem.TipoMovimiento = TIPOENTRADA
					loRetorno.Agregar( loItem )
				endif
			case tcEntidad = 'ITEMCHCUSTODIA'
				if loItem.CHCUSTODIA
					loRetorno.Agregar( loItem )
				endif
			otherwise
				if loItem.EsSeleccionable
					loRetorno.Agregar( loItem )
				endif

			endcase
		endfor
		return loRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerInformacionDelCheque( toValor as Object, toCheques as Object ) as Void
		local lcRetorno as String
		lcRetorno = ""
		do case
			case toValor.tipo = TIPOVALORCIRCUITOCHEQUETERCERO	
				lcRetorno = this.ObtenerInformacionDelChequeDeTerceros(  toValor )
			case toValor.tipo = TIPOVALORCIRCUITOCHEQUEPROPIO 
				lcRetorno = this.ObtenerInformacionDelChequePropio( toValor, toCheques )
		endcase
		return lcRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerInformacionDelChequeDeTerceros( toValor as Object ) as String
		local lcRetorno as String, lcCursor as String, lcBase as String, lcTabla as String

		lcRetorno = ""
		lcBase = _screen.zoo.app.nombreProducto + "_" + _screen.zoo.app.cSucursalActiva
		lcTabla = this.oEntidadCheque.oAd.cTablaPrincipal
		lcCursor = this.ObtenerCursorCheques( lcBase, lcTabla, toValor.Tipo, toValor.NumeroInterno )
		if used( lcCursor ) and reccount( lcCursor ) > 0
			select ( lcCursor )
			
			lcRetorno = "/Nro. Cheque " + alltrim( str( cnumero, 10, 0 ) ) + " /E.Financiera (" + rtrim( entFinanciera ) + ") " + rtrim( entFinancDesc )
			
		endif
		use in select ( lcCursor )
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerInformacionDelChequePropio( toValor as Object, toCheques as Object ) as String
		local lcRetorno as String, lcCursor as String, lcBase as String, lcTabla as String, loItemCheque as Object

		lcRetorno = ""
		if type( "toCheques" ) = "O"
			for each loItemCheque in toCheques foxobject
				if toValor.NroItem = loItemCheque.NroItem
					
					lcRetorno = "/Nro. Cheque " + alltrim( str( loItemCheque.NumeroCheque, 10, 0 ) ) + " /Chequera (" + rtrim( loItemCheque.Chequera ) + ") " + rtrim( toValor.ValorDetalle )
					
					exit
				endif
			endfor
		else
			lcBase = _screen.zoo.app.nombreProducto + "_" + _screen.zoo.app.cSucursalActiva
			lcTabla = this.oEntidadChequePropio.oAd.cTablaPrincipal
			lcCursor = this.ObtenerCursorCheques( lcBase, lcTabla, toValor.Tipo, toValor.NumeroInterno )
			if used( lcCursor ) and reccount( lcCursor ) > 0
				select ( lcCursor )
				
				lcRetorno = "/Nro. Cheque " + alltrim( str( cnumero, 10, 0 ) ) + " /Chequera (" + rtrim( Chequera ) + ") " + rtrim( ChequeraDesc )
				
			endif
			use in select ( lcCursor )
		endif
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCursorCheques( tcBase as String, tcTabla as String, tnValorTipo as Integer, tcNumeroInterno as String ) as String
		local lcCursor as String, lcSentencia as String, loError as Object

		lcSentencia = ""
		lcCursor = sys( 2015 )
		
		lcSentencia = lcSentencia + "select cnumero, estado, entFinanciera, entFinancDesc, ident, tipo, chequera, ChequeraDesc "
		lcSentencia = lcSentencia + "from ( "
		lcSentencia = lcSentencia + 	"select ch.cnumero as cnumero, ch.estado as estado, ch.tipoch as tipo, ch.centfin as entFinanciera"
		lcSentencia = lcSentencia + 	", ef.efdes as entFinancDesc"
		
		if tnValorTipo = TIPOVALORCIRCUITOCHEQUEPROPIO
			lcSentencia = lcSentencia + ", ch.Chequera as chequera"
			lcSentencia = lcSentencia + ", cq.cqdes as ChequeraDesc"
		else
			lcSentencia = lcSentencia + ", '' as chequera"
			lcSentencia = lcSentencia + ", '' as ChequeraDesc"
		endif
		
		lcSentencia = lcSentencia + 	", right( '0000' + rtrim( ltrim( convert( varchar, ch.ptoventa) ) ), 4 ) + '-' + right( '00000000' + rtrim( ltrim( convert( varchar,ch.numeroc) ) ), 8 ) as ident "
		lcSentencia = lcSentencia + 	"from " + tcBase + ".Zoologic." + tcTabla + " as ch "
		lcSentencia = lcSentencia + 	"left join ( select efdes, efcod from " + tcBase + ".Zoologic.ENTFIN ) as ef on ch.centfin = ef.efcod "
		lcSentencia = lcSentencia + iif( tnValorTipo = TIPOVALORCIRCUITOCHEQUEPROPIO, "left join ( select cqdes, cqcod from " + tcBase + ".Zoologic.CHEQUERA ) as cq on ch.chequera = cq.cqcod ", "" )
		lcSentencia = lcSentencia + ") as cheque "
		lcSentencia = lcSentencia + "where cheque.tipo = " + transform( tnValorTipo ) + " and cheque.ident = '" + rtrim( tcNumeroInterno ) + "'"
		
		try
			goServicios.Datos.EjecutarSentencias( lcSentencia, tcTabla, "", lcCursor, this.DataSessionId )
		catch to loError
		endtry

		return lcCursor
	endfunc 

EndDefine
