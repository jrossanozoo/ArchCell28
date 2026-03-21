define class Ent_ChequePropio as Din_EntidadChequePropio of Din_EntidadChequePropio.prg

	#if .f.
		Local this as Ent_ChequePropio of Ent_ChequePropio.prg
	#endif

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
		llRetorno = .f.  
		if  this.Chequera.chequeraelectronica
			if !empty(This.Numero)
				if This.ValidarUnicidadNumeroYChequera( this.Chequera_PK, this.Numero ,this.coDIGO )
					llRetorno = .t. 
				endif
			else
				llRetorno = .t. 
			endif
		else
			if dodefault() and; 
				this.ValidarFechaDeEmisionYFechaDePago( this.FechaEmision, this.Fecha ) and;
				This.ValidarNumeroRangoSegunChequera( This.Numero, this.Chequera ) and;
					This.ValidarUnicidadNumeroYChequera( this.Chequera_PK, this.Numero ,this.coDIGO )
				llRetorno = .t.
			endif			
		endif			

		
		return llRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ValidarTipoChequera( toChequera as entidad OF entidad.prg, tbTipoValorElectronico as Boolean ) as Boolean
		local llRetorno as Boolean, lcInformacion as String , lcValor_TipoChequeElectronico as Boolean
		llRetorno = .t.   && valido solo si la chequera no es electronica
		lcInformacion =""
		
		if tbTipoValorElectronico  and !toChequera.ChequeraElectronica  && validar que solo seleccione chequera electronica cuando el tipo de valor es electronico.
			llRetorno = .f.
			This.agregarinformacion( "Debe seleccionar una chequera del tipo eléctronica." + lcInformacion )
		else
			if !tbTipoValorElectronico   and toChequera.ChequeraElectronica
				llRetorno = .f.
				This.agregarinformacion(  "Debe seleccionar una chequera del tipo no eléctronica." + lcInformacion )
			endif
		endif	
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ProcesarDespuesDeSetear_ChequeraElectronica() as Void
		this.Numero.txtDato.BackColor = this.txtDato.nBackColorObligSinFoco

	endfunc

	*-----------------------------------------------------------------------------------------
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
	function ControlarSiPuedeEliminarElCheque() as Boolean
		local llRetorno as Boolean
		llRetorno = .F.
		
		if this.EstaAnulado()
			llRetorno = .T.
		endif
		
		return llRetorno
	endfunc 

    *-----------------------------------------------------------------------------------------
	function Anular() as Void
		do case
			case this.ZADSFW =  "El cheque se ha anulado desde el comprobante" + " " + transform( this.DescripcionTipoComprobanteOrigen ) +;
				 " " + transform(upper ( this.LetraOrigen ) )	+ " " + transform( padl( this.PuntoDeVentaOrigen, 4, "0" ) )+ "-" + transform( padl( this.NumeroOrigen, 10, "0" ) ) + "."
				dodefault()
			case this.TipoDeComprobanteAfectante != 32 and this.TipoDeComprobanteAfectante != 0		
				this.AgregarInformacion( "No se puede anular el cheque propio debido a que tiene comprobante de cancelación distinto a canje de valores." )
			case this.comprobanteorigen != "" and this.TipoDeComprobanteAfectante != 32
				this.AgregarInformacion( "No se puede anular el cheque propio debido a que tiene un comprobante de origen." )
			otherwise
				dodefault()
		endcase
			
		if this.HayInformacion()
			this.EventoLanzarExcepcionEnKontroler()		
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoLanzarExcepcionEnKontroler() as Void			
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarNumeroRangoSegunChequera( tnNumero as Number, toChequera as entidad OF entidad.prg ) as Boolean
		local llRetorno as Boolean, lcInformacion as String, lnCantidadCheques as Number
		
		IF toChequera.CantidadCheques = 1 
			lnCantidadCheques = toChequera.CantidadPersonalizada
		ELSE
			lnCantidadCheques = toChequera.CantidadCheques
		ENDIF
			
		llRetorno = .t.
		if ! toChequera.chequeraelectronica   && validar solo si la chequera no es electronica
			lcInformacion = "( Rango: " + transform( toChequera.NumeroInicial ) + " al " + transform( toChequera.NumeroInicial + lnCantidadCheques - 1 ) + ")"

			if tnNumero < toChequera.NumeroInicial
				llRetorno = .f.
				This.agregarinformacion( "El número de cheque ingresado es inferior al primer número de la chequera." + lcInformacion)
			else
				if tnNumero > ( toChequera.NumeroInicial + lnCantidadCheques - 1 )
					llRetorno = .f.
					This.agregarinformacion( "El número de cheque ingresado es superior al rango de la chequera." + lcInformacion )
				endif
			endif		
		endif
		
		return llRetorno

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected Function ValidarUnicidadNumeroYChequera( tcChequera_PK as String, tnNumero as Integer, tcCodigo) as Boolean
		local lcCursor, lcXml as String, lcEdicion as String, llRetorno as Boolean
		llRetorno = .t.

		lcCursor = sys( 2015 )
		with this
			lcXml = .oAD.ObtenerDatosEntidad( '', "Chequera = '" + tcChequera_PK + "' and Numero = " + transform( tnNumero ) )
			.XmlACursor( lcXml, lcCursor )
			llRetorno = ( reccount( lcCursor ) = 0 )
			if !llRetorno
				if &lcCursor..Codigo = tcCodigo
					llRetorno = .t.
				else
					This.AgregarInformacion( "El número de cheque ya se encuentra usado para esta chequera." )
				endif
			endif
			use in select( lcCursor )
			
		endwith 
		return llRetorno

	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarDatos( tnNumero as Integer, tdFechaEmision as Date, tdFecha as Date, toChequera as entidad OF entidad.prg, tcCodigo as String , tbTipoValorElectronico as Boolean ) as Boolean
		local llRetorno as boolean
		llRetorno = .f.
		if  toChequera.chequeraelectronica   
				if !empty(tnNumero) 
					if This.ValidarUnicidadNumeroYChequera( toChequera.Codigo, tnNumero, tcCodigo )
						llRetorno = .t.
					endif
				else
					llRetorno = .t.
				endif	
		else
			if	this.ValidarFechaDeEmisionYFechaDePago( tdFechaEmision , tdFecha ) and;
				This.ValidarNumeroRangoSegunChequera( tnNumero, toChequera ) and;
				This.ValidarUnicidadNumeroYChequera( toChequera.Codigo, tnNumero, tcCodigo );
				
				llRetorno = .t.			
			endif
		endif
			
		return llRetorno		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerAtributoAdChequeElectronico() as Void
		return "CHQPROP.CElectro"
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerChequesDisponibles( toEntidadComprobante as Object, tnTipoValor as Integer ) as Void
		local lcRetorno as String, lcFiltroEstados as String
		lcFiltroEstados = this.oColaboradorCheques.ObtenerCadenaEstadosDeSeleccionSegunEntidad( toEntidadComprobante, tnTipoValor )
		if empty( lcFiltroEstados )
			lcFiltroEstados = "''"
		endif
		lcRetorno = " CHQPROP.TIPOCH = " + alltrim( str( tnTipoValor ) ) + " and CHQPROP.Estado in (" + lcFiltroEstados + ")"
		** refactorizar en ent_carteradecheques
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Setear_Chequera( txVal ) as Void
		dodefault( txVal )
		this.Moneda_PK = this.Chequera.CuentaBancaria.MonedaCuenta_PK
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Nuevo() as Void
		local lcMensaje as String
		if !This.VerificarContexto( "BC" ) and !this.lEntidadInstanciadaPorComponenteCheques
			lcMensaje = 'Para dar de alta un cheque propio debe hacerlo desde Fondos --> Caja --> Comprobantes de caja.' + chr(13) + chr(10)
			lcMensaje = lcMensaje + 'Realice un nuevo comprobante de tipo "Entrada" y con un concepto cuyo estado asociado sea "En cartera" o este vacío, '
			lcMensaje = lcMensaje + 'ingresando el código de valor del cheque y el signo "+" en el número interno.'
			goServicios.Errores.LevantarExcepcion( lcMensaje )
		else
			dodefault()	
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function Modificar() as Void
		dodefault()
		this.EventoSetearControlesNoObligatorios()	
		if !This.VerificarContexto( "BC" ) and !this.lEntidadInstanciadaPorComponenteCheques
			THIS.lHabilitarCHEQUEELECTRONICO = .F.
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoSetearControlesNoObligatorios() as Void

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
			case tnTipoDeComprobante = 0			&& refactorizar
				lcRetorno = 'Conciliación bancaria'
			case tnTipoDeComprobante = 98
				lcRetorno = 'Comprobante de caja'
			case tnTipoDeComprobante = 95
				lcRetorno = 'Valores en tránsito'
			otherwise
				lcRetorno = this.ObtenerNombreDeComprobanteDeVentas( tnTipoDeComprobante )
		endcase
		return lcRetorno
	endfunc 

enddefine
