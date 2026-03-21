define class Ent_Cheque as Din_EntidadCheque of Din_EntidadCheque.prg

	#if .f.
		local this as Ent_Cheque of Ent_Cheque.prg
	#endif 

	lEstoyEnChile = .F.
	lTengoCFIBM = .F.
	lHabilitarCodigoTributarioLibradorRut = .F.
	lHabilitarCODIGOTRIBUTARIOLIBRADORRUT = .F.
	lHabilitarNOMBRELIBRADOR = .F.
	lHabilitarTELEFONOLIBRADOR = .F.
	lHabilitarENTIDADFINANCIERAENDOSO = .F.
	lHabilitarCUENTAENDOSO = .F.
	lHabilitarFECHAENDOSO = .F.
	lHabilitarLEYENDAENDOSO = .F.
	lHabilitarPAGUESEA = .F.
	lHabilitarAUTORIZACIONALFA = .F.

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
		this.lEstoyEnChile = ( GoParametros.Nucleo.DatosGenerales.Pais == 2 )
		this.lTengoCFIBM = ( goparametros.felino.controladoresfiscales.codigo = 30 )
		this.HabilitarControles()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerValorSugeridoPuntodeventa() as Integer
		local lnRetorno as Integer, lnPuntoDeVenta as Integer, lnPtoVentaTalonacio as Integer
		lnPuntoDeVenta = int( goParametros.felino.Numeraciones.BocaDeExpendio )
		lnPtoVentaTalonacio = this.ObtenerPuntoDeVentaTalonarioEntidad( this.cNombre )
		lnRetorno = iif( empty( lnPtoVentaTalonacio ), lnPuntoDeVenta, lnPtoVentaTalonacio )
		return lnRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Validar() as boolean
		local llRetorno as boolean
		llRetorno = dodefault() and this.ValidarFechaDeEmisionYFechaDePago( this.FechaEmision, this.Fecha ) and This.ValidarRepeticionNumeracionCheque()
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarNumero() as boolean
		local llRetorno as boolean
		llRetorno = .t.
		if !this.ChequeElectronico
			llRetorno = dodefault() 
		endif
		return llRetorno
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function ValidarFechaEmision() as boolean
		local llRetorno as boolean
		llRetorno = .t.
		if !this.ChequeElectronico
			llRetorno = dodefault() 
		endif
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarFechaDeEmisionYFechaDePago( tdFechaEmision as Date , tdFecha as Date ) as Void
		local llRetorno as Boolean
		llRetorno = .t.
		if !this.ChequeElectronico
			llRetorno = dodefault(tdFechaEmision, tdFecha) 
		else
			if !Empty( tdfecha ) and ( tdFecha < tdFechaEmision )
				llRetorno = .f.
				this.AgregarInformacion( "La fecha de pago debe ser igual o posterior a la fecha de emisión." )
			endif		
		endif
		return llRetorno
	endfunc		

	*-----------------------------------------------------------------------------------------------------------
	protected function AsignarFechaDeOrdenamiento() as Void
		local ldFecha as Date
		ldFecha = {}
		do case
			case !empty( this.Fecha )
				ldFecha = this.Fecha
			case !empty( this.FechaEmision )
				ldFecha = this.FechaEmision
		endcase
		if !empty( ldFecha )
			this.FechaOrdenamiento = ldFecha
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ValidarRepeticionNumeracionCheque() as Boolean
		local lcCursor as String, llRetorno As Boolean, lcMensaje As String, lcHaving as String
		llRetorno = .T.
		lcCursor = sys( 2015 )
		if goServicios.Parametros.Felino.GestionDeVentas.ChequeDeTerceros.RestringirIngresoDeChequesDuplicados and !(this.CheQUEELECTRONICO and this.Numero=0)
			lcMensaje = "El número de cheque " + Transform( this.Numero ) + " para la entidad financiera " + rtrim( This.EntidadFinanciera_Pk ) + " - " + alltrim( This.EntidadFinanciera.Descripcion ) + " ya fue ingresado con anterioridad."
			lcHaving = 'Numero = ' + transform( this.Numero ) + " and EntidadFinanciera = '" + This.EntidadFinanciera_Pk + "'"
			if This.EsEdicion()
				lcHaving = lcHaving + " and Codigo <> '" + This.Codigo + "'"
			endif
			This.XmlACursor( This.oAd.ObtenerDatosEntidad( '', lcHaving ), lcCursor )
			if reccount( lcCursor ) > 0
				This.AgregarInformacion( lcMensaje )
				llRetorno = .F.	
			Endif
			use in select( lcCursor )
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Nuevo() as Void
		local lcMensaje as String
		if !This.VerificarContexto( "BC" ) and !this.lEntidadInstanciadaPorComponenteCheques
			lcMensaje = 'Para dar de alta un cheque debe hacerlo desde Fondos --> Caja --> Comprobantes de caja.' + chr(13) + chr(10)
			lcMensaje = lcMensaje + 'Realice un nuevo comprobante de tipo "Entrada" y con un concepto cuyo estado asociado sea "En cartera" o este vacío, '
			lcMensaje = lcMensaje + 'ingresando el código de valor del cheque y el signo "+" en el número interno.'
			goServicios.Errores.LevantarExcepcion( lcMensaje )
		else
			dodefault()	
			this.HabilitarControles()
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Modificar() as Void
		dodefault()
		this.HabilitarControles()
		this.EventoSetearControlesNoObligatorios()	
		if this.TieneComprobanteDeOrigen() or this.TieneComprobanteAfectante()
			this.lHabilitarMonto = .f.
		else 
			this.lHabilitarMonto = .t.			
		endif 
		if !This.VerificarContexto( "BC" ) and !this.lEntidadInstanciadaPorComponenteCheques
		 	THIS.lHabilitarCHEQUEELECTRONICO = .f.
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoSetearControlesNoObligatorios() as Void

	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidacionBasica() as Boolean
		local llRetorno as Boolean

		llRetorno = dodefault()

		if this.lHabilitarCodigoTributarioLibradorRut and empty( this.CodigoTributarioLibradorRut )
			this.AgregarInformacion( "Debe cargar el campo RUT" )
			llRetorno = .F.
		endif

		if this.lHabilitarNOMBRELIBRADOR  and empty( this.NOMBRELIBRADOR  )
			this.AgregarInformacion( "Debe cargar el campo Nombre del Librador" )
			llRetorno = .F.
		endif

		if this.lHabilitarTELEFONOLIBRADOR and empty( this.TELEFONOLIBRADOR )
			this.AgregarInformacion( "Debe cargar el campo Telefono del Librador" )
			llRetorno = .F.
		endif

		if this.lHabilitarENTIDADFINANCIERAENDOSO and empty( this.ENTIDADFINANCIERAENDOSO_PK )
			this.AgregarInformacion( "Debe cargar el campo Entidad Financiera", 9005, 'Entidadfinancieraendoso' )
			llRetorno = .F.
		endif

		if this.lHabilitarCUENTAENDOSO and empty( this.CUENTAENDOSO )
			this.AgregarInformacion( "Debe cargar el campo Cuenta", 9005, 'Cuentaendoso' )
			llRetorno = .F.
		endif

		if this.lHabilitarFECHAENDOSO and empty( this.FECHAENDOSO )
			this.AgregarInformacion( "Debe cargar el campo Fecha del Endoso", 9005, 'FechaEndoso' )
			llRetorno = .F.
		endif

		if this.lHabilitarLEYENDAENDOSO and empty( this.LEYENDAENDOSO )
			this.AgregarInformacion( "Debe cargar el campo Leyenda", 9005, 'LeyendaEndoso' )
			llRetorno = .F.
		endif

		if this.lHabilitarPAGUESEA and empty( this.PAGUESEA )
			this.AgregarInformacion( "Debe cargar el campo Paguese a", 9005, 'Paguesea' )
			llRetorno = .F.
		endif

		if this.lHabilitarAUTORIZACIONALFA and empty( this.AUTORIZACIONALFA )
			this.AgregarInformacion( "Debe cargar el campo Autorización" )
			llRetorno = .F.
		endif

		if this.CorrespondeValidarRG1547() and empty( this.CodigoTributarioLibrador )
			this.AgregarInformacion( "Debe cargar el campo C.U.I.T. del Librador" )
			llRetorno = .F.
		endif

		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function HabilitarControles() as Void

		this.lHabilitarCodigoTributarioLibradorRut = this.lEstoyEnChile
		this.lHabilitarNOMBRELIBRADOR = this.lEstoyEnChile
		this.lHabilitarTELEFONOLIBRADOR = this.lEstoyEnChile
		this.lHabilitarENTIDADFINANCIERAENDOSO = this.lEstoyEnChile
		this.lHabilitarCUENTAENDOSO = this.lEstoyEnChile
		this.lHabilitarFECHAENDOSO = this.lEstoyEnChile
		this.lHabilitarLEYENDAENDOSO = this.lEstoyEnChile
		this.lHabilitarPAGUESEA = this.lEstoyEnChile
		this.lHabilitarAUTORIZACIONALFA = this.lEstoyEnChile

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CorrespondeValidarRG1547() as Boolean
		return ( GoParametros.Nucleo.DatosGenerales.Pais == 1 ) and goParametros.Felino.GestionDeVentas.PedirDatosParaRG1547EnVentasYCompras
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerDescripcionDeUltimoAfectante( toCheque as Object ) as String
		local lcRetorno as String
		if type( "toCheque" ) = "O"
			lcRetorno = this.ObtenerDescripcionDeTipoDeComprobante( toCheque.HistorialDetalle.item[ this.nUltimaInteraccion ].TipoDeComprobante ) ;
						+ ": "+ alltrim( toCheque.HistorialDetalle.item[ this.nUltimaInteraccion ].Comprobante )
		else
			lcRetorno = this.ObtenerDescripcionDeTipoDeComprobante( this.HistorialDetalle.item[ this.nUltimaInteraccion ].TipoDeComprobante ) ;
						+ ": "+ alltrim( this.HistorialDetalle.item[ this.nUltimaInteraccion ].Comprobante )
		endif
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerDescripcionDeTipoDeComprobante( tnTipoDeComprobante as Integer ) as String
		local lcRetorno as String
		lcRetorno = ""
		do case
			case tnTipoDeComprobante = 98
				lcRetorno = 'Comprobante de caja'
			case tnTipoDeComprobante = 95
				lcRetorno = 'Valores en tránsito'
			otherwise
				lcRetorno = this.ObtenerNombreDeComprobanteDeVentas( tnTipoDeComprobante )
		endcase
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerCantidadDeInteraccionesDeUnCheque( tcCodigo as String ) as Integer
		local lcCursor as String, lcXml as String, lnCantidadDeInteracciones as Integer
		lcXml = this.oAD.ObtenerDatosDetalleHistorialDetalle( "codigo", "codigo = '" + tcCodigo + "'" )
		lcCursor = sys( 2015 )
		This.XmlACursor( lcXml, lcCursor )
		lnCantidadDeInteracciones = reccount( lcCursor )
		use in select( lcCursor )
		return lnCantidadDeInteracciones
	endfunc 

enddefine

