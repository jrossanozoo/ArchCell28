Define Class ComponenteChequesPropios As din_ComponenteChequesPropios Of din_ComponenteChequesPropios.prg

	#If .F.
		Local This As ComponenteChequesPropios Of ComponenteChequesPropios.prg
	#Endif

*!* -->		#include valores.h
	#define TIPOVALORMONEDALOCAL			1
	#define TIPOVALORMONEDAEXTRANJERA		2
	#define TIPOVALORTARJETA       			3
	#define TIPOVALORCHEQUETERCERO 			4
	#define TIPOVALORCHEQUEPROPIO  			9
	#define TIPOVALORCIRCUITOCHEQUETERCERO	12
	#define TIPOVALORCIRCUITOCHEQUEPROPIO	14
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

	protected oColaboradorCheques as Object
	Protected cEntidadDelComponente As String, lUtilizarCarteraDeChequeDeTerceros As Boolean

	cNombre = "CHEQUESPROPIOS"
	cEntidadDelComponente = "CHEQUEPROPIO"
	oChequesPropios = Null
	oColaboradorCheques = Null
	oChequesADarDeBajaDeLaCartera = Null
	oChequesDadosDebajaDeLaCarteraAntesDeModificar = Null

	oClonadorDeCheques = null
	nNroItemCheque = 0
	oCompCuentaBancariaChequesPropios = null

	*-----------------------------------------------------------------------------------------
	Function Inicializar() As Void
		DoDefault()
		This.oChequesPropios = _Screen.zoo.crearobjeto( "zooColeccion" )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function oColaboradorCheques_access as Object
		if !this.lDestroy and !( vartype( this.oColaboradorCheques ) == "O" )
			this.oColaboradorCheques = _screen.zoo.CrearObjeto( "colaboradorCheques", "colaboradorCheques.PRG" )
		endif
		return this.oColaboradorCheques
	endfunc 

	*---------------------------------------------------------------------------------
	function oClonadorDeCheques_Access() as variant
		if this.ldestroy
		else
			if !vartype( this.oClonadorDeCheques ) = 'O' or isnull( this.oClonadorDeCheques )
				this.oClonadorDeCheques = this.ObtenerClonadorDeCheques()
			endif
		endif
		return this.oClonadorDeCheques
	endfunc

	*-----------------------------------------------------------------------------------------
	function VerificarChequeAsociado( toItem as Object ) as Boolean 
		local llRetorno as Boolean 
		llRetorno = .t.
		if (toItem.Tipo = TIPOVALORCIRCUITOCHEQUEPROPIO) or (toItem.Tipo = TIPOVALORCHEQUEPROPIO and !this.oEntidadPadre.EsComprobanteDeCaja())
			if this.oChequesPropios.Buscar( transform( toItem.NroItem ) )
			else
				llRetorno = .f.
			endif
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function LaEntidadDebeUtilizarLaCarteraDeChequesYDarlosDebaja( toEntidad as entidad OF entidad.prg ) as Boolean
		local lcNombre as String, llRetorno as Boolean
		llRetorno = .t.
		if pemstatus( this.oEntidadPadre, "cComprobante", 5 ) and type( "this.oEntidadPadre.cComprobante" ) = "C"
			lcNombre = alltrim(upper( toEntidad.cComprobante ))
			do case
			case inlist( lcNombre, "FACTURADECOMPRA", "NOTADECREDITO", "NOTADECREDITOELECTRONICA", "TICKETNOTADECREDITO" ,"NOTADEDEBITOCOMPRA", "COMPROBANTEPAGO", "CONCILIACIONES" )
				llRetorno = .f.
			case This.EsDetalleAEntregarCanjeDeCupones( lcNombre )
				llRetorno = .f.
			case lcNombre == "ORDENDEPAGO"
				llRetorno = this.EsOrdenDePagoUsandoCarteraDeCheques()
			endcase
		endif
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	Function Destroy() As Void
		If this.ldestroy and Vartype( This.oChequesPropios ) = "O" And !Isnull( This.oChequesPropios )
			This.oChequesPropios.Release()
		Endif
		If this.ldestroy and Vartype( This.oClonadorDeCheques ) = "O" And !Isnull( This.oClonadorDeCheques )
			This.oClonadorDeCheques = null
		Endif
		If this.ldestroy and Vartype( This.oColaboradorCheques) = "O" And !Isnull( This.oColaboradorCheques )
			This.oColaboradorCheques.Release()
		Endif
		If this.ldestroy and Vartype( This.oCompCuentaBancariaChequesPropios ) = "O" And !Isnull( This.oCompCuentaBancariaChequesPropios )
			This.oCompCuentaBancariaChequesPropios.Release()
		Endif
		DoDefault()
	Endfunc

	*-----------------------------------------------------------------------------------------
	Protected Function ValidarEntidad() As Boolean
		Local llOk As Boolean
		llOk = dodefault()
		llOk = llOk or this.oEntidadPadre.EsComprobanteDeCaja()
		if !llOk
			If Pemstatus( This.oEntidadPadre, "cComprobante", 5 ) And Type( "this.oEntidadPadre.cComprobante" ) = "C"
				llOk = .T.
				Do Case
				Case This.oEntidadPadre.cComprobante == "NOTADEDEBITOCOMPRA"
				Case This.oEntidadPadre.cComprobante == "NOTADECREDITOCOMPRA"
				Case This.oEntidadPadre.cComprobante == "FACTURADECOMPRA"
				Case This.oEntidadPadre.cComprobante == "ORDENDEPAGO"
				Case This.oEntidadPadre.cComprobante == "RECIBO"
				Case This.oEntidadPadre.cComprobante == "PAGO"
				Case This.oEntidadPadre.cComprobante == "FACTURA"
				Case This.oEntidadPadre.cComprobante == "NOTADEDEBITO"
				Case This.oEntidadPadre.cComprobante == "NOTADECREDITO"
				Case This.oEntidadPadre.cComprobante == "NOTADEDEBITOELECTRONICA"
				Case This.oEntidadPadre.cComprobante == "NOTADECREDITOELECTRONICA"
				Case This.oEntidadPadre.cComprobante == "TICKETFACTURA"
				Case This.oEntidadPadre.cComprobante == "TICKETNOTADEDEBITO"
				Case This.oEntidadPadre.cComprobante == "CANJEDECUPONES"
				Case This.oEntidadPadre.cComprobante == "FACTURADEEXPORTACION"
				Case This.oEntidadPadre.cComprobante == "COMPROBANTEPAGO"
				Otherwise
					llOk = .F.
				Endcase
			Endif
		Endif
		Return llOk
	Endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerChequera( tcChequera_PK as String ) as entidad OF entidad.prg 
		local loRetorno as Object
		loRetorno = _Screen.Zoo.InstanciarEntidad( "Chequera" )
		loRetorno.Codigo = tcChequera_PK
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function ValidarCargaEntidad( toCheque As entidad Of entidad.prg ) As Boolean
		local llRetorno as Boolean, loTipoValorElectronico as Boolean
		llRetorno = .t.
		loTipoValorElectronico = .f.

		if type("this.oEntidadpadre.Valoresdetalle.oiTEM.valor")="O"
			if pemstatus( this.oEntidadpadre.Valoresdetalle.oiTEM.valor, "chequeelectronico", 5 ) 
				loTipoValorElectronico = this.oEntidadpadre.Valoresdetalle.oiTEM.valor.chequeelectronico 
			endif
		else
			if type("this.Oentidad")="O"
				if pemstatus( this.Oentidad,"chequeelectronico", 5 ) 
					loTipoValorElectronico = this.Oentidad.chequeelectronico   
				endif
			endif
		endif

		llRetorno = this.oEntidad.ValidarDatos( toCheque.Numero, toCheque.FechaEmision, toCheque.Fecha, this.ObtenerChequera( toCheque.Chequera_PK ), toCheque.codigo ,loTipoValorElectronico )
		llRetorno = llRetorno and This.ValidarUnicidadNumeroYChequeraEnColeccion( toCheque.Chequera_PK, toCheque.Numero , toCheque.Chequera.ChequeraElectronica)
		return llRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function Imprimir( toItem As Object ) As Void
		If Vartype( goControladorFiscal ) = 'O' and !isnull( goControladorFiscal )
			goControladorFiscal.FranqueoCheque( This.ArmarObjetoCheque( toItem.NumeroChequePropio_pk ) )
		Endif
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ArmarObjetoCheque( tcNumeroCheque As String ) As Object
		Local loCheque As Object, loEntidad As Object, lcCodigoComprobanteOrigen as String
		loEntidad = _Screen.Zoo.InstanciarEntidad( "ChequePropio" )
		lcCodigoComprobanteOrigen = this.ObtenerCodigoDeComprobante()
		with loEntidad
			.Codigo = alltrim( tcNumeroCheque )
			loCheque = createobject( "empty" )
			addproperty( loCheque, "Codigo", loEntidad.Codigo )
			addproperty( loCheque, "ComprobanteOrigen", lcCodigoComprobanteOrigen )
			addproperty( loCheque, "FechaEndoso", loEntidad.FechaEndoso )
			addproperty( loCheque, "Monto", loEntidad.Monto )
			addproperty( loCheque, "PagueseA", loEntidad.PagueseA )
			addproperty( loCheque, "Leyenda", loEntidad.LeyendaEndoso )
			addproperty( loCheque, "CodigoVendedor", loEntidad.Vendedor_PK )
			addproperty( loCheque, "NombreVendedor", loEntidad.Vendedor.Nombre )
			addproperty( loCheque, "SerieOrigen", loEntidad.SerieOrigen )
			addproperty( loCheque, "LetraOrigen", loEntidad.LetraOrigen )
			addproperty( loCheque, "PuntoDeVentaOrigen", loEntidad.PuntoDeVentaOrigen )
			addproperty( loCheque, "NumeroOrigen", loEntidad.NumeroOrigen )
			addproperty( loCheque, "TipoDeComprobanteOrigen", loEntidad.TipoDeComprobanteOrigen )
			addproperty( loCheque, "SignoDeMovimientoOrigen", loEntidad.SignoDeMovimientoOrigen )
			addproperty( loCheque, "CodigoComprobanteOrigen", lcCodigoComprobanteOrigen  )
			addproperty( loCheque, "Valor", loEntidad.Valor )
			addproperty( loCheque, "Numero", loEntidad.Numero )
			addproperty( loCheque, "BDOrigen", loEntidad.BDOrigen )
			addproperty( loCheque, "AutorizacionAlfa", loEntidad.AutorizacionAlfa )
			addproperty( loCheque, "ComprobanteAfectante", alltrim( loEntidad.DescripcionTipoComprobanteAfectante + " " + loEntidad.ComprobanteAfectante  ) )
			AddProperty( loCheque, "CodigoChequera", loEntidad.Chequera_PK )

			addproperty( loCheque, "Tipo", loEntidad.Tipo )
			addproperty( loCheque, "Estado", loEntidad.Estado )

			loDetalleCheque = _Screen.zoo.crearobjeto( "zooColeccion" )
			loUltimaInteraccion = createobject( "empty" )
			addproperty( loUltimaInteraccion, "NroItem", iif( loEntidad.HistorialDetalle.Count = 0, 0, loEntidad.HistorialDetalle.item[ this.oEntidad.nUltimaInteraccion ].NroItem ) )
			addproperty( loUltimaInteraccion, "Comprobante", iif( loEntidad.HistorialDetalle.Count = 0, "", loEntidad.HistorialDetalle.item[ this.oEntidad.nUltimaInteraccion ].Comprobante ) )
			addproperty( loUltimaInteraccion, "TipoDeComprobante", iif( loEntidad.HistorialDetalle.Count = 0, 0, loEntidad.HistorialDetalle.item[ this.oEntidad.nUltimaInteraccion ].TipoDeComprobante ) )
			addproperty( loUltimaInteraccion, "Estado", iif( loEntidad.HistorialDetalle.Count = 0, "", loEntidad.HistorialDetalle.item[ this.oEntidad.nUltimaInteraccion ].Estado ) )
			addproperty( loUltimaInteraccion, "Tipo", iif( loEntidad.HistorialDetalle.Count = 0, 0, loEntidad.HistorialDetalle.item[ this.oEntidad.nUltimaInteraccion ].Tipo ) )
			loDetalleCheque.Agregar( loUltimaInteraccion )
			addproperty( loCheque, "HistorialDetalle", loDetalleCheque )

			.Release()
		endwith

		Return loCheque
	Endfunc

	*-----------------------------------------------------------------------------------------
	protected function MarcarItemSiEsChequeElectronico( toItem as object )
		if pemstatus(toItem.Valor, "ChequeElectronico", 5)
			toItem.ChequeElectronico =  toItem.Valor.ChequeElectronico
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected Function IngresarUnNuevoCheque( toItem ) As Void
		Local loCheque As Object, loInformacion  as Object, loChequera as object
		With This

			.MarcarItemSiEsChequeElectronico(toItem) 
			loCheque = .ObtenerObjetoCheque( toItem )
			
			.nNroItemCheque = loCheque.NroItem
			loCheque.Monto = this.ObtenerMontoORecibido( toItem )

			.EventoPedirCheque( loCheque )
			.nNroItemCheque = 0	
			loChequera = this.ObtenerChequera( loCheque.Chequera ) 
			If Empty( loCheque.NumeroCheque ) and !loChequera.chequeraelectronica 
				goServicios.Errores.LevantarExcepcion( "Debe completar el número de cheque." )
			Else
				if alltrim(toItem.NumeroInterno) == "+"
					toItem.NumeroInterno = space(len(toItem.NumeroInterno))
				endif

				if this.MostrarNumeroCheque()
					toItem.cEtiquetaNumeroCheque = this.ObtenerStringNumeroCheque( loCheque.NumeroCheque )
				endif 				

				If !Empty( loCheque.ChequeraDescripcion )
					toItem.ValorDetalle = loCheque.ChequeraDescripcion
					toItem.Valor.descripcion = loCheque.ChequeraDescripcion
					if pemstatus(toItem.Valor, "ChequeElectronico", 5)
						toItem.Valor.ChequeElectronico = loChequera.chequeraelectronica   
						toItem.ChequeElectronico =  toItem.Valor.ChequeElectronico
					endif
				endif

				 if !this.oEntidad.ValidarDatos( loCheque.NumeroCheque, loCheque.FechaEmision, loCheque.Fecha, loChequera, toItem.Numerochequepropio_pk, loChequera.chequeraelectronica )  && envio el dato de la chequera
					loChequera.Release()
					loInformacion = this.oEntidad.ObtenerInformacion()
					goServicios.Errores.LevantarExcepcion( loInformacion )
				else
					loChequera.Release()
					loCheque.Accion = ESTADOINGRESADO
					.AgregarCheque( loCheque, toItem.NroItem )
					toItem.Fecha = loCheque.Fecha
					this.AsignarMontoORecibido( toItem, loCheque.Monto )
				endif
			Endif
		Endwith
	Endfunc

	*-----------------------------------------------------------------------------------------
	*Este método se ejecuta cuando se carga el valor en el item
	function RemoverDatosSiCambioTipo( toItem as Object ) as Void
		local llHabilitarNumInt as Boolean 
		if this.DebeUtilizarCarteraDecheque()
			if this.oChequesADarDeBajaDeLaCartera.Buscar( toItem.NumeroChequePropio_pk )
				this.oChequesADarDeBajaDeLaCartera.Quitar( toItem.NumeroChequePropio_pk )
				toItem.NumeroChequePropio_pk = ""
				if pemstatus( toItem, "lHabilitarNumeroInterno", 5 )
					llHabilitarNumInt = toItem.lHabilitarNumeroInterno
					toItem.lHabilitarNumeroInterno = .t.
					toItem.NumeroInterno = ""
					toItem.lHabilitarNumeroInterno = llHabilitarNumInt
				endif
				toItem.Fecha = iif( empty( toItem.FechaComp ), date(), toItem.FechaComp )
			endif
		else
			if this.oChequesPropios.Buscar( transform( toItem.NroItem ) )
				this.oChequesPropios.Quitar( transform( toItem.NroItem ) )
				toItem.NumeroChequePropio_PK = ""
			endif
		endif
	endfunc 	

	*-----------------------------------------------------------------------------------------
	protected function GenerarInteraccionFakeSoloParaAumentarElNroItem( tnCaja as Integer ) as Void
		this.GenerarInteraccionEnElHistorialDelCheque( tnCaja )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function InvocarObtenerObjetoCheque(toItem As Object) As Object
		local loItem as Object
		loItem = this.ObtenerObjetocheque(toItem)
		return loItem 
	endfunc

	*-----------------------------------------------------------------------------------------
	protected Function ObtenerObjetoCheque( toItem As Object ) As Componente_ItemDatosCheque Of ComponenteChequesPropios.prg
		Local loRetorno As Componente_ItemDatosCheque Of ComponenteChequesPropios.prg
		If Type( "toItem" ) = "O" And !Isnull( toItem ) And This.oChequesPropios.Buscar( Transform( toItem.NroItem ) )
			loRetorno = This.oChequesPropios.Item[ transform( toItem.NroItem ) ]
		Else
			loRetorno  = Newobject( "Componente_ItemDatosCheque", "ComponenteChequesPropios.prg" )
			If Type( "toItem" ) = "O" And !Isnull( toItem )
				With loRetorno
					.NroItem = toItem.NroItem
					if !toItem.ChequeElectronico
						.FechaEmision = This.oEntidadPadre.Fecha
						.Fecha = toItem.FechaComp + iif( !pemstatus( toItem, "CondicionDePago_Pk", 5), 1, iif( empty( toItem.CondicionDePago_Pk ), 1, 0 ) )
					endif
					.Valor = toItem.Valor_PK
					.Tipo = toItem.Valor.Tipo
					.Moneda = toItem.Valor.SimboloMonetario_Pk
				endwith
				if !toItem.ChequeElectronico
					this.PreCargarCheque( loRetorno )
				endif
			Endif
		Endif
		loRetorno.lEnabled = This.EsUnItemModificable( toItem )
		Return loRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	Protected Function EsUnItemModificable( toItem ) As Boolean
		Local llRetorno As Boolean
		llRetorno = .T.
		If Type( "toItem" ) = "O" And !Isnull( toItem )
			llRetorno = empty( toItem.NumeroChequePropio_pk ) or !this.ExistenInteraccionesPosterioresALasDelComprobante( toItem.NumeroChequePropio.HistorialDetalle, this.ObtenerCodigoDeComprobante() )
		Endif
		Return llRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	*Este método se ejecuta cuando se carga el valor en el item
	Protected Function AgregarCheque( toDatos As Componente_ItemDatosCheque Of ComponenteChequesPropios.prg, tnNroItem As Integer )
		If This.oChequesPropios.Buscar( Transform( tnNroItem ) )
		else
			This.oChequesPropios.Agregar( toDatos, Transform( tnNroItem ) )
		Endif
	endfunc

	*-----------------------------------------------------------------------------------------
	*Este métoso se ejecuta cuando se carga el valor en el item
	Function AsignarNumeroDeItemAlItemCero( toItem As Object ) As Void
		Local loItem As Object
		If This.oChequesPropios.Buscar( "0" )
			loItem = This.oChequesPropios.Item[ "0" ]
			This.oChequesPropios.Quitar( "0" )
			loItem.NroItem = toItem.NroItem
			This.AgregarCheque( loItem, Transform( toItem.NroItem ) )
		Endif
	Endfunc

	*-----------------------------------------------------------------------------------------
	*Este método se ejecuta al hacer nuevo en la entidad
	Function Reinicializar( tlLimpiar As Boolean ) As Void
		Local loItem As Object, loCheque As Componente_ItemDatosCheque Of ComponenteChequesPropios.prg
		If Type( "this.oChequesPropios" ) = "O" And !Isnull( This.oChequesPropios )
			This.oChequesPropios.Release()
		Endif
		This.oChequesPropios = _Screen.zoo.crearobjeto( "zooColeccion" )

		if type( "this.oChequesADarDeBajaDeLaCartera" ) = "O" and !isnull( this.oChequesADarDeBajaDeLaCartera )
			this.oChequesADarDeBajaDeLaCartera.Release()
		endif
		if type( "this.oChequesDadosDebajaDeLaCarteraAntesDeModificar " ) = "O" and !isnull( this.oChequesDadosDebajaDeLaCarteraAntesDeModificar )
			this.oChequesDadosDebajaDeLaCarteraAntesDeModificar.Release()
		endif			
		this.oChequesADarDeBajaDeLaCartera = _Screen.zoo.crearobjeto( "zooColeccion" )
		this.oChequesDadosDebajaDeLaCarteraAntesDeModificar = _Screen.zoo.crearobjeto( "zooColeccion" )

		if this.DebeUtilizarCarteraDecheque()		
			if !tlLimpiar
				for each loItem in This.oDetalleAnterior foxobject
					if inlist(loItem.Tipo,TIPOVALORCHEQUEPROPIO,TIPOVALORCIRCUITOCHEQUEPROPIO) and !empty( loItem.Valor_PK ) and !empty( loItem.NumeroChequePropio_pk )
						this.oChequesADarDeBajaDeLaCartera.Agregar( loItem.NumeroChequePropio_pk , loItem.NumeroChequePropio_pk )
						this.oChequesDadosDebajaDeLaCarteraAntesDeModificar.Agregar( loItem.NumeroChequePropio_pk , loItem.NumeroChequePropio_pk )				
					endif
				endfor
			endif
		else
			If !tlLimpiar
				For Each loItem In This.oDetalleAnterior FoxObject
					If inlist(loItem.Tipo,TIPOVALORCHEQUEPROPIO,TIPOVALORCIRCUITOCHEQUEPROPIO) And !Empty( loItem.Valor_PK ) And !Empty( loItem.NumeroChequePropio_pk )
						loCheque = This.ObtenerObjetoCheque()
						This.CargarCheque( loCheque, loItem )
						This.AgregarCheque( loCheque, loItem.NroItem )
					Endif
				endfor
			endif 	
		Endif

		if type( "this.oEntidadPadre.cComprobante" ) = "C" and this.oEntidadPadre.cComprobante <> "CONCILIACION"
			this.oCompCuentaBancariaChequesPropios.InyectarEntidadPadre( this.oEntidadPadre )
			this.oCompCuentaBancariaChequesPropios.InyectarDetallePadre( this.oDetallePadre )
			this.oCompCuentaBancariaChequesPropios.InyectarDetalleChequesPropios( this.oChequesPropios )
			this.oCompCuentaBancariaChequesPropios.Reinicializar()
		endif
	Endfunc

	*-----------------------------------------------------------------------------------------
	Protected Function CargarCheque( toCheque As Componente_ItemDatosCheque Of ComponenteChequesPropios.prg, toItem As Object ) As Void
		With This.oEntidad
			.Codigo = toItem.NumeroChequePropio_pk
			toCheque.Codigo = .Codigo
			toCheque.Chequera = .chequera_pk
			toCheque.NumeroCheque = .Numero
			toCheque.AutorizacionAlfa = .AutorizacionAlfa
			toCheque.Fecha = .Fecha
			toCheque.FechaEmision = .FechaEmision
			toCheque.Valor = .Valor
			toCheque.Monto = .Monto
			toCheque.Vendedor = .Vendedor_PK
			toCheque.NroItem = toItem.NroItem
			toCheque.Moneda = .Moneda_PK
			toCheque.Tipo = toItem.Tipo
			toCheque.Accion = iif(.HistorialDetalle.Count = 1, ESTADOINGRESADO, ESTADOSELECCIONADO )
		Endwith
	Endfunc

	*-----------------------------------------------------------------------------------------
	Protected Function CargarDatosDeCancelacionEnLosCheques() As zoocoleccion Of zoocoleccion.prg
		Local loRetorno As zoocoleccion Of zoocoleccion.prg
		loRetorno = _Screen.zoo.crearobjeto( "Zoocoleccion" )

		if this.oEntidadPadre.lAnular ;
		 or ( this.oEntidadPadre.cNombre = "COMPROBANTEDECAJA" and !this.oEntidadPadre.lNuevo and !this.oEntidadPadre.lEdicion ) ;
		 or ( this.oEntidadPadre.cNombre = "CONCILIACIONES" and !this.oEntidadPadre.lNuevo and !this.oEntidadPadre.lEdicion )
			This.oChequesADarDeBajaDeLaCartera.Remove(-1)
		endif
		
		if this.oEntidadPadre.cNombre = "COMPROBANTEDECAJA"
		 For lnIndCH = 1 To this.oDetalleAnterior.Count
				loItem = this.oDetalleAnterior.Item(lnIndCH)
				If this.EsValorTipoChequePropio( loItem.Tipo ) And !This.EstaEnDetalle( loItem, this.oDetallePadre )
					this.AgregarSententiciasEliminarCheque(loItem.NumeroChequePropio_pk, loRetorno )
				Endif
			Endfor
		endif
		
		This.AgregarSentencias( This.CargarLosDatosDeCancelacionEnLosChequesUtilizadosEnElComprobante(), loRetorno )
		This.AgregarSentencias( This.LimpiarDatosDeCancelacionEnLosChequesQueFueronRemovidosDelComprobante(), loRetorno )

		Return loRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	Protected Function CargarLosDatosDeCancelacionEnLosChequesUtilizadosEnElComprobante() As zoocoleccion Of zoocoleccion.prg
		Local loRetorno As zoocoleccion Of zoocoleccion.prg, lcIdCheque As String, lnCaja as Integer

		loRetorno = _Screen.zoo.crearobjeto( "Zoocoleccion" )

		For Each lcIdCheque In This.oChequesADarDeBajaDeLaCartera
			With This.oEntidad As din_EntidadCheque Of din_EntidadCheque.prg
				.Codigo = lcIdCheque
				.Modificar()
				.TipoDeComprobanteAfectante = This.oEntidadPadre.TipoComprobante
				If This.oChequesDadosDebajaDeLaCarteraAntesDeModificar.Buscar( lcIdCheque  )
					This.oChequesDadosDebajaDeLaCarteraAntesDeModificar.Quitar( lcIdCheque )
				Endif

				lnCaja = 0

				***
				if this.oEntidadPadre.cComprobante <> "CONCILIACION"
					loDetalle = this.oDetallePadre
					for each loItem in loDetalle
						if loItem.NumeroChequePropio_pk = lcIdCheque
							lcMoneda = this.ObtenerMonedaEnValor( loItem.Valor_PK )
							if pemstatus( loItem, "Caja_PK", 5 )
								lnCaja = loItem.Caja_PK
							endif
							exit
						endif
					endfor

					if empty( .Moneda_PK )
						.Moneda_PK = lcMoneda
					endif
				endif
				
				if !this.YaExisteUnaInteraccionParaElComprobante( .HistorialDetalle, this.ObtenerCodigoDeComprobante() )
					if this.SeEstaGenerandoUnContraComprobanteDeCaja()
						this.GenerarInteraccionFakeSoloParaAumentarElNroItem( lnCaja )
					endif

					this.GenerarInteraccionEnElHistorialDelCheque( lnCaja )
				endif

				loSentenciasUpdate = .ObtenerSentenciasUpdate()
				if this.SeEstaGenerandoUnContraComprobanteDeCaja()
					loSentenciasUpdate = this.ModificarSentenciasPorSerContraComprobanteDeCaja( loSentenciasUpdate )
				endif
				this.AgregarSentencias( loSentenciasUpdate, loRetorno )
				.Cancelar()
			Endwith
		Endfor
		Return loRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	Protected Function SetearEnElChequeACancelarDatosDeCancelacionSegunEntidadPadre() As Void
		With This.oEntidad As din_EntidadCheque Of din_EntidadCheque.prg
			Do Case
			Case This.oEntidadPadre.TipoComprobante == 31 && Orden de pago
				.ComprobanteAfectante = Padl( This.oEntidadPadre.Numero, 10, "0" )
				.ProveedorAfectante_Pk = This.oEntidadPadre.Proveedor_pk
			Case This.oEntidadPadre.TipoComprobante == 37 && Pago
				.ProveedorAfectante_Pk = This.oEntidadPadre.ordendepago.Proveedor_pk
			Case This.oEntidadPadre.TipoComprobante == 8  && Factura de compra
				.ComprobanteAfectante = Padl( This.oEntidadPadre.NumInt, 10, "0" )
				.ProveedorAfectante_Pk = This.oEntidadPadre.Proveedor_pk
			Case This.oEntidadPadre.TipoComprobante == 9  && Nota de débito de compra
				.ComprobanteAfectante = Padl( This.oEntidadPadre.NumInt, 10, "0" )
				.ProveedorAfectante_Pk = This.oEntidadPadre.Proveedor_pk
			Case This.oEntidadPadre.TipoComprobante == 10  && Nota de crédito de compra
				.ComprobanteAfectante = Padl( This.oEntidadPadre.NumInt, 10, "0" )
				.ProveedorAfectante_Pk = This.oEntidadPadre.Proveedor_pk
			Otherwise
				.ComprobanteAfectante = This.GenerarDescripcionComprobante( This.oEntidadPadre, ;
					This.oEntidadPadre.TipoComprobante, ;
					This.oEntidadPadre.Letra, ;
					This.oEntidadPadre.PuntoDeVenta, ;
					This.oEntidadPadre.Numero )
			Endcase
		Endwith
	endfunc

	*-----------------------------------------------------------------------------------------
    function Grabar() as object
    	local loRetorno as zoocoleccion OF zoocoleccion.prg, loColSentencias as zoocoleccion OF zoocoleccion.prg
		loColeccion = _Screen.zoo.Crearobjeto( "ZooColeccion" )
    	loRetorno = dodefault()
		with this.oCompCuentaBancariaChequesPropios
*!*			if type( "this.oEntidadPadre.cComprobante" ) = "C" and this.oEntidadPadre.cComprobante <> "CONCILIACION"
			if type( "this.oEntidadPadre.cNombre" ) = "C" and !inlist( this.oEntidadPadre.cNombre, "CONCILIACIONES") && , "COMPROBANTEDECAJA" ) 
				.lNuevo = this.oEntidadPadre.EsNuevo()
				.lEdicion = this.oEntidadPadre.EsEdicion()
				.lEliminar = this.oEntidadPadre.lEliminar
				.lAnular = this.oEntidadPadre.lAnular
				loColSentencias =.grabar()
				for each lcItem in loColSentencias
					loRetorno.Agregar( lcItem )
				endfor
			endif
		endwith
    	return loRetorno
    endfunc

	*-----------------------------------------------------------------------------------------
	Protected Function GenerarCheques( toRetorno As zoocoleccion Of zoocoleccion.prg ) As zoocoleccion Of zoocoleccion.prg
		Local  loCheque  As Object, loRetorno As zoocoleccion Of zoocoleccion.prg

		loRetorno = _Screen.zoo.crearobjeto( "zoocoleccion" )
		For Each loCheque In This.oChequesPropios FoxObject
			If Empty( loCheque.Codigo )
				toRetorno = This.GenerarCheque( loCheque, loRetorno, 0 )
			Endif
		Endfor

		Return loRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	Protected Function ModificarCheques() As zoocoleccion Of zoocoleccion.prg
		Local loRetorno As zoocoleccion Of zoocoleccion.prg, lnIndCH As Integer, ;
			lcDetalle As String, loItem As Object
		loRetorno = _Screen.zoo.crearobjeto( "zoocoleccion" )
		With This
			For lnIndCH = 1 To .oDetalleAnterior.Count
				loItem = .oDetalleAnterior.Item(lnIndCH)
				If this.EsValorTipoChequePropio( loItem.Tipo ) And !This.EstaEnDetalle( loItem, .oDetallePadre )
					.AgregarSententiciasEliminarCheque(loItem.NumeroChequePropio_pk, loRetorno )
				Endif
			Endfor

			For lnIndCH = 1 To .oDetallePadre.Count
				loItem = this.ObtenerItemAsociadoACheque(.oDetallePadre,lnIndCH)
				If inlist(loItem.Tipo,TIPOVALORCHEQUEPROPIO,TIPOVALORCIRCUITOCHEQUEPROPIO) and (!this.oEntidadPadre.EsComprobanteDeCaja() or this.ExisteChequeAsociadoAlValor( loItem ))
					loCheque = This.BuscarEnoColCheque( loItem.NroItem )
					if!This.EstaEnDetalle( loItem, .oDetalleAnterior )
						loRetorno = .GenerarCheque( loCheque, loRetorno, 0 )
					else
						loRetorno = .ModificarUnCheque( loCheque, loRetorno )
					endif	
				Endif
			Endfor

		Endwith

		Return loRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	Function EsChequeConAccion( tnNroItem as Integer) as Boolean
		local llRetorno as Boolean
		llRetorno = .f.
		for each loItem in this.oChequesPropios
			if loItem.Nroitem = tnNroItem
				llRetorno = inlist(loItem.Accion, ESTADOINGRESADO, ESTADOSELECCIONADO)
				exit
			endif
		next
		return llRetorno
	EndFunc 

	*-----------------------------------------------------------------------------------------
	Protected Function BuscarEnoColCheque( tnNroItem As Integer ) As Object
		Local loRetorno As Object
		loRetorno = Null
		If This.oChequesPropios.Buscar( Transform( tnNroItem ) )
			loRetorno =	This.oChequesPropios.Item[ transform( tnNroItem ) ]
		Endif
		Return loRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	Protected Function EstaEnDetalle( toItem As Object, toDetalle As Object ) As Boolean
		Local lnIndCH As Integer, llRetorno As Boolean
		llRetorno = .F.
		For lnIndCH = 1 To toDetalle.Count
			If inlist(toDetalle.Item[lnIndCH].Tipo,TIPOVALORCHEQUEPROPIO,TIPOVALORCIRCUITOCHEQUEPROPIO) And toDetalle.Item[lnIndCH].NumeroChequePropio_pk = toItem.NumeroChequePropio_pk
				llRetorno = .T.
				Exit
			Endif
		Endfor

		Return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	Protected Function AnularOEliminarCheques() As zoocoleccion Of zoocoleccion.prg
		Local loRetorno As zoocoleccion Of zoocoleccion.prg
		if goParametros.Felino.GestionDeCompras.AnularChequesPropiosEnComprobantes
			loRetorno = this.AnularChequesPropios()
		else
			loRetorno = This.EliminarCheques()
		endif
		Return loRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function AnularChequesPropios() as zoocoleccion OF zoocoleccion.prg
		local loRetorno as zoocoleccion OF zoocoleccion.prg, lnIndCH as Integer, ;
			lcDetalle as String, loItem as object, lnTipo as Integer, lcEstado as String

		loRetorno = _screen.zoo.crearobjeto( "zoocoleccion" )
		with this
			for lnIndCH = 1 to .oDetallePadre.count 
				loItem = this.ObtenerItemAsociadoACheque(.oDetallePadre,lnIndCH)
				if inlist(loItem.Tipo, TIPOVALORCHEQUEPROPIO,TIPOVALORCIRCUITOCHEQUEPROPIO)
					.oEntidad.Codigo = loItem.NumeroChequePropio_PK
					.oEntidad.Modificar()		
					.oEntidad.ZADSFW = "El cheque se ha anulado desde el comprobante" + " " + transform(.oEntidad.DescripcionTipoComprobanteOrigen )  + " " +;
						 transform(upper ( .oEntidad.LetraOrigen ) )	+ " " + transform( padl( .oEntidad.PuntoDeVentaOrigen, 4, "0" ) )+ "-" +;
						 transform( padl( .oEntidad.NumeroOrigen, 10, "0" ) ) + "."

					lnTipo = .oEntidad.Tipo
					lcEstado = .oEntidad.Estado
					.oEntidad.lAnular = .T.
					.oEntidad.Estado = 'ANULA'
					.AgregarSentencias( .oEntidad.ObtenerSentenciasUpdate(), loRetorno )
					.oEntidad.Cancelar()
				Endif
			endfor
		endwith
		return loRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	Protected Function EliminarCheques() As zoocoleccion Of zoocoleccion.prg
		Local loRetorno As zoocoleccion Of zoocoleccion.prg, lnIndCH As Integer, ;
			lcDetalle As String , loItem As Object
		loRetorno = _Screen.zoo.crearobjeto( "zoocoleccion" )
		With This
			For lnIndCH = 1 To .oDetallePadre.Count
				loItem = this.ObtenerItemAsociadoACheque(.oDetallePadre,lnIndCH)
				If inlist(loItem.Tipo,TIPOVALORCHEQUEPROPIO,TIPOVALORCIRCUITOCHEQUEPROPIO)
					.AgregarSententiciasEliminarCheque( .oDetallePadre.Item( lnIndCH ).NumeroChequePropio_pk, loRetorno )
				Endif
			Endfor
		Endwith
		Return loRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	Function AgregarSententiciasEliminarCheque( tcNumeroCheque As String, toRetorno As Object ) As Void
		local lcDetalle  as string, lnNroItem as Integer
		With This
			.oEntidad.Codigo = tcNumeroCheque
			lnNroItem = 1
			for each loItem in This.oEntidad.HistorialDetalle foxobject
				if loItem.CodigoComprobante = this.ObtenerCodigoDeComprobante()
					lnNroItem = loItem.NroItem
					exit
				endif
			endfor
			if lnNroItem <> 1
				goServicios.Errores.LevantarExcepcion( "No puede modificar el cheque porque tiene movimientos posteriores." )
			endif

			if .oEntidad.Tipo = TIPOVALORCIRCUITOCHEQUEPROPIO
				if .oEntidad.HistorialDetalle.Count < 2
					.LlenarColeccionSentencias( .oEntidad.ObtenerSentenciasDelete( ), toRetorno )
				endif
			else
				.LlenarColeccionSentencias( .oEntidad.ObtenerSentenciasDelete( ), toRetorno )
			endif
		Endwith
	Endfunc
	
	*-----------------------------------------------------------------------------------------
	Protected Function GenerarCheque( toCheque As Componente_ItemDatosCheque Of ComponenteChequesPropios.prg, toRetorno As Object, tnIncremento As Integer ) As zoocoleccion Of zoocoleccion.prg
		Local loDetalle  As String, loItemValor As Object, loError As Exception, loItem As Object, lcCodigoComprobanteOrigen as String, lnCaja as Integer
		With This
			loItem = this.ObtenerItemAsociadoACheque( .oDetallePadre,toCheque.NroItem )
			If !inlist(loItem.Tipo,TIPOVALORCHEQUEPROPIO,TIPOVALORCIRCUITOCHEQUEPROPIO)
				goServicios.Errores.LevantarExcepcion( "Error en los datos de los cheques. Verifique los valores" )
			Endif

			With .oEntidad
				.Nuevo()
				Try
					*.NumeroC = .NumeroC + tnIncremento
					 this.ResolverNumeracionEntidad( this.oEntidad )	
					.Fecha = toCheque.Fecha
					.FechaEmision = toCheque.FechaEmision
					.Numero = toCheque.NumeroCheque
					.Chequera_PK = toCheque.Chequera
					.Monto = this.ObtenerMontoORecibido( loItem )
					.Valor = toCheque.Valor
					.Tipo = toCheque.Tipo
					.Moneda_PK = this.ObtenerMonedaEnValor( loItem.Valor_PK )
					
					if pemstatus( this.oEntidadPadre, "Proveedor_pk", 5 )
						.Proveedor_pk = this.oEntidadPadre.Proveedor_Pk
					endif
					
					lcCodigoComprobanteOrigen = this.ObtenerCodigoDeComprobante()
					With This.oEntidadPadre
						This.SetearCombinacionEnEntidadOrigen( .TipoComprobante, .Letra, .PuntoDeVenta, .Numero, .signodemovimiento, lcCodigoComprobanteOrigen ) && .Codigo )
					Endwith

					if loItem.Caja_PK = 0
						lnCaja = goCaja.ObtenerNumeroDeCajaActiva()
					else
						lnCaja = loItem.Caja_PK
					endif
					this.GenerarInteraccionEnElHistorialDelCheque( lnCaja )

					If .Validar()
						loItem.NumeroInterno = Padl( Transform( .PuntoDeVenta ), 4, "0" ) + "-" + Padl( Transform( .NumeroC ), 8, "0" )

						if this.MostrarNumeroCheque()
							loItem.cEtiquetaNumeroCheque = this.ObtenerStringNumeroCheque( toCheque.NumeroCheque )
						endif 
						
						loItem.NumeroChequePropio_pk = .Codigo
						This.LlenarColeccionSentencias( .ObtenerSentenciasInsert( ), toRetorno )
					Else
						goServicios.Errores.LevantarExcepcion( .ObtenerInformacion() )
					Endif
				Catch To loError
					goServicios.Errores.LevantarExcepcion( loError )
				Finally
					.Cancelar()
				Endtry
			Endwith
		Endwith

		Return toRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	Protected Function ObtenerVotoAnular() As Boolean
		Local llRetorno As Boolean, lnIndCH As Integer, loCheque As din_EntidadCheque Of din_EntidadCheque.prg

		With This
			llRetorno = .T.
			For lnIndCH = 1 To .oDetallePadre.Count
				if this.EsValorTipoChequePropio( .oDetallePadre.Item[lnIndCH].Tipo )
					If .ValidarChequeActivo( .oDetallePadre.Item(lnIndCH).NumeroChequePropio_pk )
						loCheque = .ArmarObjetoCheque( .oDetallePadre.Item(lnIndCH).NumeroChequePropio_pk )
						.Agregarinformacion( "Cheque número: " + Alltrim( .oDetallePadre.Item(lnIndCH).NumeroInterno ) +;
							" - Monto: " + Transform( loCheque.Monto ) + " - Chequera: " + Alltrim( loCheque.CodigoChequera ) + ;
							" - Comprobante: " + loCheque.ComprobanteAfectante )
						loCheque = Null
						llRetorno = .F.
					Endif
				Endif
			Endfor

		Endwith

		If !llRetorno
			This.Agregarinformacion( "No se puede anular el comprobante ya que incluye al menos un valor del tipo Cheque Propio afectado por otra operación." )
		else
			llRetorno = this.oCompCuentaBancariaChequesPropios.VotarCambioEstadoEliminar()
		Endif

		Return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	Function ValidarChequeActivo( tcGuid As String ) As Boolean
		Return This.oEntidad.EstaAfectado( tcGuid, this.ObtenerCodigoDeComprobante() )
	Endfunc

	*-----------------------------------------------------------------------------------------
	Protected Function SetearCombinacionEnEntidadOrigen( tnTipoComprobante As Integer, tcLetra As String, tnPuntoDeVenta As Integer, ;
			tnNumero As Integer, tnSignoDeMovimiento As Integer, tcCodigoComprobante As String ) As Void

		With This.oEntidad
			.TipoDeComprobanteOrigen = tnTipoComprobante
			.LetraOrigen = tcLetra
			.PuntoDeVentaOrigen = tnPuntoDeVenta
			.NumeroOrigen = tnNumero
			.ComprobanteOrigen =  This.GenerarDescripcionComprobante( This.oEntidadPadre, tnTipoComprobante, tcLetra, tnPuntoDeVenta, tnNumero )
			.CodigoComprobanteOrigen = tcCodigoComprobante
			.SignoDeMovimientoOrigen = tnSignoDeMovimiento
		Endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	Protected Function GenerarDescripcionComprobante( toEntidad As Object, tnTipo As Integer, tcLetra As String, tnPtoVta As Integer, tnNumero As Integer ) As String
		Return toEntidad.obtenerIdentificadorDeComprobante( tnTipo ) + " " + Upper( Alltrim( tcLetra ) ) + " " + Padl( Int( tnPtoVta  ), 4, "0" ) + ;
			"-" + Padl( Round( tnNumero, 0 ), 8, "0" )
	endfunc

	*-----------------------------------------------------------------------------------------
	Protected Function CancelarCheque() As Void
		With This
			If .oEntidad.EsNuevo() Or .oEntidad.EsEdicion()
				.oEntidad.Cancelar()
			Endif
		Endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	Function AntesDeSetearAtributo( toItemValor As Object, tcAtributo As String, txValOld As Variant, txVal As Variant ) As Void
		local lcMensaje as String
		If Empty( toItemValor.NumeroChequePropio_pk ) or This.oEntidadPadre.VerificarContexto( "BC" )	
			if upper( tcAtributo ) == "VALOR_PK" and !Empty( txValOld  )
				this.Removerdatossicambiotipo( toItemValor )
			endif 		
		Else
			Do Case
				case this.DebeUtilizarCarteraDecheque()
					if Upper( tcAtributo ) == "MONTO"
						if this.ValidarAfectacionDelItem( toItemValor, this.ObtenerCodigoDeComprobante() )
							goServicios.Errores.LevantarExcepcionTexto( "No se puede modificar el monto del cheque desde este comprobante." )
						endif
					endif 
					if upper( tcAtributo ) == "VALOR_PK" and txValOld != txVal 
						this.Removerdatossicambiotipo( toItemValor )	
					endif 	

					if upper( tcAtributo ) == "NUMEROINTERNO" and !empty( txValOld ) and empty( txVal )
						this.RemoverDatosSiCambioTipo( toItemValor )	
					endif

				Case Upper( tcAtributo ) == "NUMEROCHEQUEPROPIO_PK" And Empty( txValOld )
				&& CONTROLADO
				Case Upper( tcAtributo ) == "VALOR_PK"
					if this.ValidarAfectacionDelItem( toItemValor, this.ObtenerCodigoDeComprobante() )
						toItemValor.Valor_PK = txValOld
						lcMensaje = "Cheque afectado por " + toItemValor.numerochequepropio.descripciontipocomprobanteafectante+ ": "+ toItemValor.numerochequepropio.comprobanteafectante
						goServicios.Errores.LevantarExcepcionTexto( "No se puede modificar/eliminar un valor afectado a otro comprobante."+ chr(13)+ lcmensaje )
					else 
						if txValOld != txVal 
							this.Removerdatossicambiotipo( toItemValor )	
						endif 	
					endif

				Case Empty( toItemValor.Valor_PK )
					&& Esta Limpiando el Item
				otherwise
					if this.ValidarAfectacionDelItem( toItemValor, this.ObtenerCodigoDeComprobante() )
						toItemValor.&tcAtributo. = txValOld
						lcMensaje = "Cheque afectado por " + toItemValor.numerochequepropio.descripciontipocomprobanteafectante+ ": "+ toItemValor.numerochequepropio.comprobanteafectante
						goServicios.Errores.LevantarExcepcionTexto( "No se pueden modificar los valores del cheque." + chr(13)+ lcmensaje)
					endif	
			Endcase
		Endif
	Endfunc

	*-----------------------------------------------------------------------------------------
	Protected function ValidarSiEstaAfectado( tcCheque as String ) as boolean
		local loEntidad as entidad OF entidad.prg, loError as Exception, llRetorno as Boolean
		
		llRetorno = .f.
		loEntidad = _Screen.Zoo.InstanciarEntidad( "ChequePropio" )

		try
			loEntidad.Codigo = tcCheque
			llRetorno = !empty( loEntidad.ComprobanteAfectante )
			loEntidad.Release()
			loEntidad = null
		catch to loError
		endtry
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ReinicializarComponenteEspecifico() as Void
		if type( "this.oChequesPropios" ) = "O" and !isnull( this.oChequesPropios )
			this.oChequesPropios.Release()
		endif
		this.oChequesPropios = _Screen.zoo.crearobjeto( "zooColeccion" )

	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerColeccionDeCheques() as Object 
		return this.oChequePropio
	endfunc 

	*-----------------------------------------------------------------------------------------	
	protected function AgregarChequeSelecionadoDeLaCartera( tcIdChequeSeleccionado as String, toItem as ItemActivo of ItemActivo.Prg ) as void
		if empty( tcIdChequeSeleccionado )
			toItem.NumeroInterno = ""
		else
			if this.oChequesADarDeBajaDeLaCartera.Buscar( tcIdChequeSeleccionado ) and toItem.NumeroChequePropio_pk != tcIdChequeSeleccionado
				goServicios.Errores.LevantarExcepcion( "No puede utilizar el mismo cheque dos veces." )
			else
				if this.oChequesADarDeBajaDeLaCartera.Buscar( toItem.NumeroChequePropio_pk ) and toItem.NumeroChequePropio_pk != tcIdChequeSeleccionado
					this.oChequesADarDeBajaDeLaCartera.Quitar( toItem.NumeroChequePropio_pk )
					toItem.NumeroChequePropio_pk = ""
				endif
				if this.oChequesADarDeBajaDeLaCartera.Buscar( toItem.NumeroChequePropio_pk ) and toItem.NumeroChequePropio_pk == tcIdChequeSeleccionado
					this.oChequesADarDeBajaDeLaCartera.Quitar( toItem.NumeroChequePropio_pk )
					toItem.NumeroChequePropio_pk = ""
				endif				
			endif
			this.oEntidad.Codigo = tcIdChequeSeleccionado
			
			this.ValidarMonedaDeCheque( toItem )
			this.ValidarTipoDeCheque( toItem )

			if !this.ExistenInteraccionesPosterioresALasDelComprobante( toItem.NumeroChequePropio.HistorialDetalle, this.ObtenerCodigoDeComprobante() ) ;
 			 or this.oChequesDadosDebajaDeLaCarteraAntesDeModificar.buscar( tcIdChequeSeleccionado )

				if this.oColaboradorCheques.ValidarEstadoDeChequeSeleccionadoSegunEstadoDestino( this.oEntidadPadre, this.oEntidad.Estado, toItem.Tipo, this.ObtenerNombreDetallePadre() )
	 				this.oChequesADarDeBajaDeLaCartera.Agregar( tcIdChequeSeleccionado, tcIdChequeSeleccionado )
					this.CargarDatosDeChequeEnItem( toItem, tcIdChequeSeleccionado )
				else
					lcDescripcionDeEstadosDeSeleccion = this.oColaboradorCheques.ObtenerDescripcionDeEstadosDeSeleccionSegunEntidad( this.oEntidadPadre, toItem.Tipo, this.ObtenerNombreDetallePadre() )
					lcMensajeAdicional = ""
					do case
						case empty( lcDescripcionDeEstadosDeSeleccion )
							lcMensajeAdicional = "no hay ningún estado de cheque disponible para selección."
						case occurs( ',', lcDescripcionDeEstadosDeSeleccion ) = 0
							lcMensajeAdicional = "sólo se pueden seleccionar cheques que tengan estado " + lcDescripcionDeEstadosDeSeleccion + "."
						otherwise
							lcMensajeAdicional = "sólo se pueden seleccionar cheques que tengan alguno de los siguientes estados: " + lcDescripcionDeEstadosDeSeleccion + "."
					endcase
					this.AgregarInformacion( "El estado actual del cheque seleccionado es '" ;
											+ alltrim( this.oColaboradorCheques.ObtenerDescripcion( this.oEntidad.Estado ) ) + "',";
											+ " por lo cual no puede utilizarse en éste tipo de comprobante" ;
											+ iif( this.LaEntidadPadreTieneUnConceptoConEstadoCargado(), " mediante el concepto " + alltrim( this.oEntidadPadre.Concepto_pk ), "" ) ;
											+ "." ;
											+ chr(10) + chr(13) ;
											+ "Para la información ingresada hasta el momento en ésta operación " + lcMensajeAdicional )
					loEx = Newobject( 'ZooException', 'ZooException.prg' )
					loEx.oInformacion = this.ObtenerInformacion()
					loEx.Throw()
				endif

			else
				this.AgregarInformacion( " El cheque seleccionado ya fue utilizado en " + this.oEntidad.ObtenerDescripcionDeUltimoAfectante() )
				loEx = Newobject( 'ZooException', 'ZooException.prg' )
				loEx.oInformacion = this.ObtenerInformacion()
				loEx.Throw()
			endif
		endif
	endfunc			

	*-----------------------------------------------------------------------------
	Protected Function ModificarUnCheque( toCheque As Componente_ItemDatosCheque Of ComponenteChequesPropios.prg, toRetorno As Object ) As zoocoleccion Of zoocoleccion.prg
		Local loItem As Object, loError As Exception, loDetalle  As String && , loItemValor As Object, 
		With This
			loDetalle = This.oDetallePadre

			loItem = this.ObtenerItemAsociadoACheque(.oDetallePadre,toCheque.NroItem)
			If !inlist(loItem.Tipo,TIPOVALORCHEQUEPROPIO,TIPOVALORCIRCUITOCHEQUEPROPIO)
				goServicios.Errores.LevantarExcepcion( "Error en los datos de los cheques. Verifique los valores" )
			endif
			With .oEntidad
				Try
					.codigo = tocheque.Codigo 
					.modificar()
					.Fecha = toCheque.Fecha
					.FechaEmision = toCheque.FechaEmision
					.Numero = toCheque.NumeroCheque
					.Chequera_PK = toCheque.Chequera
					.Monto = Abs( loItem.Monto )
					if empty( .Moneda_PK )
						.Moneda_PK = this.ObtenerMonedaEnValor( loItem.Valor_PK )
					endif

					If .Validar()
						This.LlenarColeccionSentencias( .ObtenerSentenciasUpdate( ), toRetorno )
					Else
						goServicios.Errores.LevantarExcepcion( .ObtenerInformacion() )
					Endif
				Catch To loError
					goServicios.Errores.LevantarExcepcion( loError )
				Finally
					.Cancelar()
				Endtry

			Endwith
		Endwith

		Return toRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected Function ValidarUnicidadNumeroYChequeraEnColeccion( tcChequera as String, tnNumero as Integer , tlChequeraElectronica as Boolean) as Boolean
		local lcCursor, lcXml as String, lcEdicion as String, llRetorno as Boolean
		llRetorno = .t.
		for lnIndice = 1 to this.oChequesPropios.Count
			loCheque = this.oChequesPropios[lnIndice]
			if tlChequeraElectronica  
				if !empty(tnNumero)&& si es chequera electronica solo valido unicidad para cheques con numero cargado
					if loCheque.NroItem != this.nNroItemCheque and loCheque.Chequera = tcChequera and loCheque.numerocheque = tnNumero 
						llRetorno = .f.
						This.AgregarInformacion( "El número de cheque ya se encuentra usado para esta chequera en este mismo comprobante." )
						exit
					endif
				endif
			else
				if loCheque.NroItem != this.nNroItemCheque and loCheque.Chequera = tcChequera and loCheque.numerocheque = tnNumero 
					llRetorno = .f.
					This.AgregarInformacion( "El número de cheque ya se encuentra usado para esta chequera en este mismo comprobante." )
					exit
				endif
			endif
		endfor
		return llRetorno

	endfunc 

	*-----------------------------------------------------------------------------------------
	function PreCargarCheque( toCheque as Object ) as Void
		local lcPropiedad as String, lcPropiedadMemo as String, lnI as Integer, loColAtributos as zoocoleccion OF zoocoleccion.prg, loItem as Object
		llPrimerCheque = vartype( this.oChequesPropios ) # "O" or isnull( this.oChequesPropios) or this.oChequesPropios.Count = 0
		this.oClonadorDeCheques.PreCargarCheque( toCheque, llPrimerCheque )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ActualizarMemoriaChequePropio( toCheque as Componente_ItemDatosCheque ) as Void
		this.oClonadorDeCheques.ActualizarClonDelCheque( toCheque )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerClonadorDeCheques() as Object
		local loRetorno as Object
		loRetorno = _Screen.Zoo.CrearObjeto( "ClonadorChequesPropios" )
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsChequeIngresado( tnNroItem as Integer) as Boolean
		local llRetorno as Boolean
		llRetorno = .f.
		for each loItem in this.oChequesPropios
			if loItem.Nroitem = tnNroItem
				llRetorno = (loItem.Accion = ESTADOINGRESADO)
				exit
			endif
		next
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function VerificarQueNoSeEsteCancelandoUnChequeCancelado() as Boolean
		local llRetorno as Boolean, lcIdCheque as String
		llRetorno = .t.
		for each lcIdCheque in this.oChequesADarDeBajaDeLaCartera foxobject

			this.oEntidad.Codigo = lcIdCheque

			if !this.YaExisteUnaInteraccionParaElComprobante( this.oEntidad.HistorialDetalle, this.ObtenerCodigoDeComprobante() )
				if !this.oColaboradorCheques.ValidarEstadoDeChequeSeleccionadoSegunEstadoDestino( this.oEntidadPadre, this.oEntidad.Estado, this.oEntidad.Tipo, this.ObtenerNombreDetallePadre() )
					llRetorno = .f.
					this.AgregarInformacion( "El estado del cheque " + this.oEntidad.ObtenerStringDeNumeroInterno() + " [" ;
											+ alltrim( this.oColaboradorCheques.ObtenerDescripcion( this.oEntidad.Estado ) ) + "]";
											+ " hace que no pueda ser utilizado en éste tipo de comprobante" ;
											+ iif( this.LaEntidadPadreTieneUnConceptoConEstadoCargado(), " mediante el concepto " + alltrim( this.oEntidadPadre.Concepto_pk ), "" ) ;
											+ "." )
				endif
			endif
		endfor
		return llRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerXmlDeChequesEnCartera( tnTipoValorCheque as Integer ) as String
		local lcRetorno as String, lcXml as String, lcFiltroEstados as String
		lcRetorno = "" 
		lcFiltroEstados = this.oColaboradorCheques.ObtenerCadenaEstadosDeSeleccionSegunEntidad( this.oEntidadPadre, tnTipoValorCheque )
		if empty( lcFiltroEstados )
			lcFiltroEstados = "''"
		endif
		
		lcXml = this.oEntidad.ObtenerDatosEntidad( "", " tipo = " + str( tnTipoValorCheque ) + " and estado in (" + lcFiltroEstados + ") " , "FECHAALTAFW, HORAALTAFW" )

		this.XmlACursor( lcXml, "c_ChequesDisponibles" )
		
		create cursor c_ChequesEnCartera ( idCheque C(38), NumeroInterno C(14), Numero N(8),;
			FechaOrigen D, FechaVto D, Importe N( 16,2 ), Banco C(5), FECHAALTAFW D, HORAALTAFW C(8) )
		select( "c_ChequesDisponibles" )
		scan
			insert into c_ChequesEnCartera ( idCheque, NumeroInterno, Numero, FechaOrigen, FechaVto, Importe, Banco, FECHAALTAFW, HORAALTAFW  ) ;
				values ( ;
				c_ChequesDisponibles.Codigo, ;
				padl( transform( c_ChequesDisponibles.PuntoDeVenta ),4 ,"0" ) + "-" + padl( transform( c_ChequesDisponibles.NumeroC ), 8, "0" ), ;
				c_ChequesDisponibles.Numero, ;
				c_ChequesDisponibles.FechaOrigen, ;
				c_ChequesDisponibles.FechaVencimiento, ;
				c_ChequesDisponibles.Monto, ;
				c_ChequesDisponibles.EntidadFinanciera, ;
				c_ChequesDisponibles.FECHAALTAFW, ;
				c_ChequesDisponibles.HORAALTAFW )
		endscan

		lcRetorno = this.CursorAXml( "c_ChequesEnCartera" )
		use in select( "c_ChequesEnCartera" )
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	Protected Function DebeUtilizarCarteraDecheque() as Boolean
		Local llRetorno as Boolean, lcFuncionalidad as String, lnSigno as Integer
		do case
		case this.oEntidadPadre.EsComprobanteDeCaja()
			llRetorno = this.EsComprobanteDeCajaUsandoCarteraDeCheques( this.oEntidadPadre )
		case alltrim(upper(this.oEntidadPadre.cComprobante)) == 'ORDENDEPAGO' && EsComprobanteDePago()

			llRetorno = this.EsOrdenDePagoUsandoCarteraDeCheques()

		otherwise
			llRetorno = this.lUtilizarCarteraDeCheque
		endcase
		Return llRetorno
	EndFunc 

	*-----------------------------------------------------------------------------------------
	protected function LimpiarDatosDeCancelacionEnLosChequesQueFueronRemovidosDelComprobante() as zoocoleccion OF zoocoleccion.prg
		local loRetorno as zoocoleccion OF zoocoleccion.prg, lcIdCheque as String
		loRetorno = dodefault()

		if vartype( this.oChequesDadosDebajaDeLaCarteraAntesDeModificar ) = "O"
			for each lcIdCheque in this.oChequesDadosDebajaDeLaCarteraAntesDeModificar
				with this.oEntidad as din_EntidadChequePropio of din_EntidadChequePropio.prg
					.Codigo = lcIdCheque 

					if this.ExistenInteraccionesPosterioresALasDelComprobante( .HistorialDetalle, this.ObtenerCodigoDeComprobante() )
						goServicios.Errores.LevantarExcepcion( "No puede modificar el cheque porque tiene movimientos posteriores." )
					endif

					.Modificar()
					this.EliminarInteraccionEnElHistorialDelCheque( .HistorialDetalle, this.ObtenerCodigoDeComprobante() )
					.Estado = this.ObtenerEstadoDeUltimaInteraccion( .HistorialDetalle )

					this.AgregarSentencias( .ObtenerSentenciasUpdate(), loRetorno )
					.Cancelar()
				endwith
			endfor
		endif
		return loRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function SetearDatosChequeParaAPI( toCheque as Object, toDatos as Object, toItem as Object ) as Void
		toCheque.Fecha = toDatos.Fecha
		toCheque.NumeroCheque = toDatos.Numero
		toCheque.Chequera = toDatos.Chequera_PK
		toCheque.FechaEmision = toDatos.FechaEmision		
		if empty( toDatos.Monto )
			toCheque.Monto = this.ObtenerMontoORecibido( toItem )
		else
			toCheque.Monto = toDatos.Monto
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AntesDeGrabarEntidadPadre() as Boolean
		local llRetorno as Boolean
		llRetorno = dodefault()
		if llRetorno and this.oEntidadPadre.cNombre == "PAGO"
			this.CargarDesdeElPagoLosValoresCircuitoChequePropio()
		endif
		if llRetorno and this.oEntidadPadre.cNombre == "CONCILIACIONES"
			this.CargarDesdeLaConciliacionLosValoresCircuitoChequePropio()
		endif
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function GenerarInteraccionEnElHistorialDelCheque( tnCaja as Integer ) as Void
		local lcEstado as String
		lcEstado = ""

		with this.oEntidad.HistorialDetalle
			.LimpiarItem()
			.oItem.Fecha = this.oEntidadPadre.FechaAltaFW
			.oItem.Hora = this.oEntidadPadre.HoraAltaFW
			.oItem.IdentificadorEntidadComprobante = upper( This.oEntidadPadre.obtenerIdentificadorDeComprobante( This.oEntidadPadre.TipoComprobante ) )
			.oItem.CodigoComprobante = this.ObtenerCodigoDeComprobante()
			.oItem.TipoDeComprobante = This.oEntidadPadre.TipoComprobante
			this.SetearDatosAlItemActivoDelHistorialSegunEntidadPadre()
			if pemstatus( this.oEntidadPadre, "Concepto_PK", 5 )
				.oItem.Concepto_PK = this.oEntidadPadre.Concepto_PK
				.oItem.ConceptoDetalle = this.oEntidadPadre.Concepto.Descripcion
			endif
			.oItem.Serie = _screen.zoo.app.cSerie
			.oItem.Version = _screen.zoo.app.ObtenerVersion()
			.oItem.BaseDeOrigen = _screen.zoo.app.cSucursalActiva

			lcEstado = this.oColaboradorCheques.ObtenerEstadoDestinoParaElCheque( This.oEntidadPadre, this.oEntidad.Tipo, this.ObtenerNombreDetallePadre(), this.oEntidad.HistorialDetalle )
			.oItem.Estado = lcEstado
			.oItem.Tipo = this.oColaboradorCheques.ObtenerTipoMovimiento( .oItem.Estado )

			if .oItem.Tipo <> 0 and this.oEntidad.Tipo = TIPOVALORCIRCUITOCHEQUEPROPIO
				.oItem.CajaEstado = tnCaja
				.oItem.CajaEstadoDetalle = goCaja.ObtenerDescripcionDeCaja( .oItem.CajaEstado )
			endif

			.Actualizar()

			this.oEntidad.Estado = lcEstado
		endwith

	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CargarDesdeElPagoLosValoresCircuitoChequePropio() as Void
		local loItem as Object
		
		this.oChequesADarDeBajaDeLaCartera.Remove( -1 )
		this.oChequesDadosDebajaDeLaCarteraAntesDeModificar.Remove( -1 )
		for each loItem in this.oDetallePadre foxobject
			if ( loItem.Tipo = TIPOVALORCIRCUITOCHEQUEPROPIO or loItem.Tipo = TIPOVALORCHEQUEPROPIO ) and !empty( loItem.Valor_PK ) and !empty( loItem.NumeroChequePropio_PK )
				this.oChequesADarDeBajaDeLaCartera.Agregar( loItem.NumeroChequePropio_PK, loItem.NumeroChequePropio_PK )
				this.oChequesDadosDebajaDeLaCarteraAntesDeModificar.Agregar( loItem.NumeroChequePropio_PK, loItem.NumeroChequePropio_PK )
			endif
		endfor
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CargarDesdeLaConciliacionLosValoresCircuitoChequePropio() as Void
		local loItem as Object, lcNumeroChequePropio_PK as String

		this.oChequesADarDeBajaDeLaCartera.Remove( -1 )
		this.oChequesDadosDebajaDeLaCarteraAntesDeModificar.Remove( -1 )
		for each loItem in this.oDetallePadre foxobject
			if loItem.TipoValor = TIPOVALORCIRCUITOCHEQUEPROPIO &&& and !empty( loItem.Valor_PK )
				lcNumeroChequePropio_PK = this.ObtenerNumeroChequePropioDeUnRegistroConciliable( loItem.Registro_PK )
				if !empty( lcNumeroChequePropio_PK )
					this.oChequesADarDeBajaDeLaCartera.Agregar( lcNumeroChequePropio_PK, lcNumeroChequePropio_PK )
					this.oChequesDadosDebajaDeLaCarteraAntesDeModificar.Agregar( lcNumeroChequePropio_PK, lcNumeroChequePropio_PK )
				endif
			endif
		endfor
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerNumeroChequePropioDeUnRegistroConciliable( tcCodigoRegistroConciliable ) as String
		local lcCursor as String, loError as zooexception OF zooexception.prg, lcSql as String, lcRetorno as String, loEntidadRegistro as Object, ;
			loEntidad as Object, lcNombreFuncion as String
		
		lcCursor = sys( 2015 )
		lcRetorno = ""

		loEntidadRegistro = _Screen.Zoo.InstanciarEntidad( "RegistroDeCuenta" )
		loEntidadRegistro.Codigo = tcCodigoRegistroConciliable
		** refactorizar
		loEntidad = _Screen.Zoo.InstanciarEntidad( loEntidadRegistro.EntidadComprobante )
		try	
			if alltrim( loEntidadRegistro.EntidadComprobante ) == "CANJEDECUPONES"
				lcNombreFuncion = "ObtenerDatosDetalle" + "ValoresAEnt"
			else
				lcNombreFuncion = "ObtenerDatosDetalle" + loEntidad.cValoresDetalle
			endif
			lcXml = loEntidad.oAd.&lcNombreFuncion( "NumeroChequePropio", "GuidComp = '" + tcCodigoRegistroConciliable + "'" )
			this.XmlACursor( lcXml, lcCursor )
			
			lcRetorno = &lcCursor..NumeroChequePropio
		catch to loError
			throw loError
		finally
			loDetalle = null
			loEntidad.Release()
			loEntidadRegistro.Release()
			use in select( lcCursor )
		endtry
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsComprobanteDeCajaUsandoCarteraDeCheques( toEntidad as entidad OF entidad.prg ) as Boolean
		local llRetorno as Boolean, loDetalle as Collection, lnEstado as Integer, loCheque as ent_ChequePropio of ent_ChequePropio.prg
		llRetorno = this.lUtilizarCarteraDeCheque
		if toEntidad.EsComprobanteDeCaja()
			loDetalle = toEntidad.ObtenerDetalleDeValores()
			if loDetalle.Count > 0
				loCheque = _Screen.Zoo.InstanciarEntidad( "ChequePropio" )
				if this.oChequesPropios.Count = 0 and this.oChequesADarDeBajaDeLaCartera.Count = 0
					for each loItem in loDetalle FOXOBJECT
						if this.EsValorTipoChequePropio( loItem.Tipo )
							loCheque.Codigo = loItem.NumeroChequePropio_PK
							if loCheque.HistorialDetalle.Count > 1
								llRetorno = .t.
							else
								llRetorno = .f.
							endif
							exit
						endif
					endfor
				else

					lnEstado = loDetalle.ObtenerTipoDeUsoDeChequesPropios()
					if lnEstado > 0
						llRetorno = lnEstado = ESTADOSELECCIONADO
					else
						if this.oChequesADarDeBajaDeLaCartera.Count > 0
							llRetorno = .t.
						endif
					endif

				endif
				loCheque.Release()
			endif
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsOrdenDePagoUsandoCarteraDeCheques( toEntidad as entidad OF entidad.prg ) as Boolean
		local llRetorno as Boolean, lcNombre as String, loItem as Object, loCheque as ent_ChequePropio of ent_ChequePropio.prg
		llRetorno = .f. && this.lUtilizarCarteraDeCheque
		lcNombre = alltrim(upper( this.oEntidadPadre.cComprobante ))
		if lcNombre == "ORDENDEPAGO"
			if this.oEntidadPadre.ValoresDetalle.oItem.NroItem = 0 and this.oEntidadPadre.ValoresDetalle.oItem.lEstaEntregandoChequeDeCartera
				llRetorno = .t.
			else
				loCheque = _Screen.Zoo.InstanciarEntidad( "ChequePropio" )
				if this.oChequesPropios.Count = 0 and this.oChequesADarDeBajaDeLaCartera.Count = 0
					for each loItem in this.oEntidadPadre.ValoresDetalle FOXOBJECT
						if this.EsValorTipoChequePropio( loItem.Tipo )
							loCheque.Codigo = loItem.NumeroChequePropio_PK
							if loCheque.HistorialDetalle.Count > 1
								llRetorno = .t.
							else
								llRetorno = .f.
							endif
							exit
						endif
					endfor
				else
					if this.oChequesADarDeBajaDeLaCartera.Count > 0
						llRetorno = .t.
					endif
				endif
				loCheque.Release()
			endif
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarAfectacionDelItem( toItem as Object, tcCodigoComprobanteAfectante as String ) as Boolean 
		local llRetorno as Boolean, loError as Object 
		try
			llRetorno = toItem.NumeroChequePropio.EstaAfectado( toItem.NumeroChequePropio_PK, tcCodigoComprobanteAfectante )
		catch to loError
			llRetorno = .f.
		endtry 
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CargarDatosDeChequeEnItem( toItem as object, tcIdCheque as String ) as Void
		this.AsignarMontoORecibido( toItem, this.oEntidad.Monto )
		with toItem
			.lCargando = .t.
			.NumeroInterno = padl( transform( this.oEntidad.PuntoDeVenta ), 4, "0" ) + "-" + padl( transform( this.oEntidad.NumeroC ), 8, "0" )
			if this.MostrarNumeroCheque()
				toItem.cEtiquetaNumeroCheque = this.ObtenerStringNumeroCheque( this.oEntidad.Numero )
			endif 
			.lCargando = .f.
			.NumeroChequePropio_pk = tcIdCheque 
			.Fecha = this.oEntidad.Fecha
			if pemstatus( toItem, "ChequeElectronico", 5 ) and pemstatus( this.oEntidad, "ChequeElectronico", 5 )
				.ChequeElectronico = this.oEntidad.ChequeElectronico 
			endif
			if .Tipo = TIPOVALORCIRCUITOCHEQUEPROPIO and !this.oColaboradorCheques.EsComprobanteDeCajaGeneradoPorAceptacionDeValoresEnTransito( this.oEntidadPadre )
				.lHabilitarCaja_PK = .T.
				.Caja_PK = this.ObtenerCajaDelCheque( tcIdCheque )
			endif
		endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerChequeSeleccionadoDefault( toArgumentosEvento as ArgumentoEventoSeleccionChequeDeCartera of ArgumentoEventoSeleccionChequeDeCartera.prg, ;
		tcXmlCarteraDeCheques as String, toItem as ItemActivo of ItemActivo.Prg ) as Void
		local lcWhere as String
		lcWhere = "1=1"
		
		if empty( toItem.NumeroChequePropio_pk )
			this.XmlACursor( tcXmlCarteraDeCheques, "c_SeleccionDefaultCheque" )

			for each lcGuidCheque in this.oChequesADarDeBajaDeLaCartera foxobject
				lcWhere = lcWhere + " and idCheque <> '" + lcGuidCheque + "'"
			endfor

			select * from c_SeleccionDefaultCheque order by FECHAALTAFW, HORAALTAFW where &lcWhere into cursor c_SeleccionDefaultCheque
			if reccount( "c_SeleccionDefaultCheque" ) > 0
				toArgumentosEvento.idChequeSeleccionado = c_SeleccionDefaultCheque.idCheque	
			endif
			use in select( "c_SeleccionDefaultCheque" )
		else
			toArgumentosEvento.idChequeSeleccionado = toItem.NumeroChequePropio_pk
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerChequeSeleccionadoActualmente( toArgumentosEvento as ArgumentoEventoSeleccionChequeDeCartera of ArgumentoEventoSeleccionChequeDeCartera.prg, ;
		toItem as ItemActivo of ItemActivo.Prg ) as Void
		if !empty( toItem.NumeroChequePropio_pk )
			toArgumentosEvento.cidChequeSeleccionadoActualmente = toItem.NumeroChequePropio_pk
		endif
	endfunc 

	*---------------------------------------------------------------------------------
	function oCompCuentaBancariaChequesPropios_Access() as variant
		if this.ldestroy
		else
			if !vartype( this.oCompCuentaBancariaChequesPropios ) = 'O' or isnull( this.oCompCuentaBancariaChequesPropios )
				this.oCompCuentaBancariaChequesPropios = _screen.zoo.instanciarcomponente( "ComponenteCuentaBancariaChequesPropios" )
			endif
		endif
		return this.oCompCuentaBancariaChequesPropios
	endfunc	

	*-----------------------------------------------------------------------------------------
	protected function SetearYVerificarDatosUsandoLaCarteraDeCheques( toItem as ItemActivo of ItemActivo.Prg ) as Void
		local lcIdChequeSeleccionado as String, lcXmlCarteraDeCheques as String, lnCantidadDeChequesEnCartera as Integer, lcEstadosDeSeleccion as String, lcMensaje as String
		lcXmlCarteraDeCheques = this.ObtenerXmlDeChequesEnCartera( toItem.Tipo )
		this.XmlACursor( lcXmlCarteraDeCheques, "c_CarteraDeCheques" )
		lnCantidadDeChequesEnCartera = reccount( "c_CarteraDeCheques" )
		use in select( "c_CarteraDeCheques" )
		if lnCantidadDeChequesEnCartera == 0
			if this.EsValorTipoChequePropio( toItem.Tipo )
				lcEstadosDeSeleccion = this.oColaboradorCheques.ObtenerDescripcionDeEstadosDeSeleccionSegunEntidad( this.oEntidadPadre, toItem.Tipo, this.ObtenerNombreDetallePadre() )
				if empty( lcEstadosDeSeleccion )
					lcMensaje = "Para la información ingresada hasta el momento en ésta operación no hay ningún estado de cheque disponible de selección."
				else
					lcMensaje = "No existen cheques disponibles en la cartera con los siguientes estados: " + lcEstadosDeSeleccion
				endif
			else
				lcMensaje = "No existen cheques disponibles en la cartera."
			endif
			goServicios.Errores.LevantarExcepcion( lcMensaje )
		else
			lcIdChequeSeleccionado = this.ObtenerChequeDeCarteraAUtilizar( lcXmlCarteraDeCheques, toItem )
			this.AgregarChequeSelecionadoDeLaCartera( lcIdChequeSeleccionado, toItem )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsSentenciaDeUpdateDeCabecera( tcSentencia as String ) as Boolean
		return ( upper( substr( tcSentencia, 1, 6 ) ) = "UPDATE" and "ZOOLOGIC.CHQPROP " $ upper( tcSentencia ) )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsSentenciaParaElHistorialDelContraComprobante( tcSentencia as String, tcIdentificadorDelComprobanteDeCaja as String ) as Boolean
		return ( "ZOOLOGIC.CHPROPHIST" $ upper( tcSentencia ) and tcIdentificadorDelComprobanteDeCaja $ upper( tcSentencia ) )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ActualizarDatosChequeElectronico( toCheque as object ) as Void
		local loColSentencias as Object, loError as Object, llEjecutoBegin as Boolean, lcMensaje as String 
		if this.ValidarIngresoNumeroChequeUnico(toCheque, toCheque.NumeroCheque)
			try
				this.EventoMensajeProcesando("Procesando")
				loColSentencias = this.ObtenerSentenciasUpdateChequeElectronico(toCheque)
				goservicios.datos.ejecutarsql( "BEGIN TRANSACTION", .f., this.dataSessionID )
				llEjecutoBegin = .T.
				for each lcSentencia in loColSentencias
					lcResultado = goServicios.Datos.EjecutarSQL( lcSentencia, .f., this.dataSessionID )
				endfor
				goServicios.Datos.EjecutarSQL( "COMMIT TRANSACTION", .f., this.dataSessionID )	
				
			catch to loError	
				if llEjecutoBegin
					goServicios.Datos.EjecutarSQL( "ROLLBACK TRANSACTION", .f., this.dataSessionID )
				endif
				goServicios.Errores.LevantarExcepcion( loError )
			finally
				this.EventoFinMensajeProcesando()
			endtry	
		else
						
			lcMensaje = "El número de cheque " + transform( toCheque.NumeroCheque ) + " para la chequera " + rtrim( toCheque.Chequera ) + ;
						" - " + alltrim( toCheque.ChequeraDescripcion ) + " se encuentra duplicado."
			this.EventoMostrarMensajeChequeDuplicado(lcMensaje)	
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerSentenciasUpdateChequeElectronico( toCheque as object ) as object
		local loSentencias as Object, loRegistro as Object, lcSentencia as String, lcTabla as String, lcCampoNumeroChque as String, ;
		lcCampoCodigo as String,lcCampoFechaEmision as string, lcCampoFechaDePago as String, lcCodigo as string,;
		lcFechaEmision as date, lcFechaEmision as date, ldFecha as date, lcFecha as String lcHora as String, lcFechaEnBlanco as String
	
		loSentencias = _screen.zoo.CrearObjeto( "ZooColeccion" )
		with this.oEntidad
			lcTabla = .oAd.cEsquema + "." + .oAd.cTablaPrincipal

			lcCampoNumeroCheque = .oAd.ObtenerCampoEntidad( "Numero" )
			lcCampoFechaEmision = .oAd.ObtenerCampoEntidad( "FechaEmision" )
			lcCampoFechaDePago = .oAd.ObtenerCampoEntidad( "Fecha" )
			lcCampoCodigo = .oAd.ObtenerCampoEntidad( "Codigo" )
			
			ldFecha = goServicios.Librerias.ObtenerFecha()
			lcFecha = dtoc( ldFecha, 1 )
			lcHora = goServicios.Librerias.ObtenerHora()
			lcFechaEnBlanco = dtos( evaluate( goRegistry.Nucleo.FechaEnBlancoParaSQLServer ) )
			
			if !empty(toCheque.Codigo)
				lcNumeroCheque = toCheque.NumeroCheque
				lcFechaEmision = iif(empty(toCheque.FechaEmision), lcFechaEnBlanco ,toCheque.FechaEmision)
				lcFechaDePago = iif(empty(toCheque.Fecha), lcFechaEnBlanco ,toCheque.Fecha)
				lcCodigo = toCheque.Codigo
									
				text to lcSentencia noshow textmerge
					update <<lcTabla>> set <<lcCampoNumeroCheque >> = '<<lcNumeroCheque >>' , 
										   <<lcCampoFechaEmision >> = '<<lcFechaEmision >>',
											<<lcCampoFechaDePago >> = '<<lcFechaDePago >>',
											FModiFW = '<<lcFecha>>' , 
								   			HModiFW = '<<lcHora>>' , 
								   			UmodiFW = '<<goServicios.Seguridad.cUsuarioLogueado>>' , 
								   			SmodiFW = '<<_Screen.Zoo.App.cSerie>>' , 
								   			VmodiFW = '<<_screen.zoo.app.cVersionSegunIni>>' , 
								   			BDmodiFW = '<<_screen.zoo.app.cSucursalActiva>>'
					where <<lcCampoCodigo>> = '<<lcCodigo>>'
				endtext
				
				loSentencias.Agregar( lcSentencia )
			endif
		
		endwith
		return loSentencias
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EventoMensajeProcesando(tcMensaje as String) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoFinMensajeProcesando() as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoMostrarMensajeChequeDuplicado(tcMensaje as String) as Void
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ValidarIngresoNumeroChequeUnico(toCheque as object, tnNumero as Integer ) as boolean
		local lnNumeroCheque as Integer, llExistente as Boolean, lcCursor as String, lcXml as String 
		llExistente = .f. 
		********************************************************************************************************
		* Verificamos que todo cheque, en la coleccion de cheques, Sea unico en numero y entidad financiera
		********************************************************************************************************
		lnNumeroCheque = tnNumero 
		if !empty(lnNumeroCheque ) 
			lcCursor = sys(2015)
			try
				lcXml = this.oEntidad.ObtenerDatosEntidad( "Codigo",  " Codigo != '" +  toCheque.Codigo  + "' and Chequera = '" +  toCheque.Chequera  + "' and Numero = " + transform(lnNumeroCheque)  , "" )
				this.XmlACursor( lcXml, lcCursor )
				select (lcCursor)
				llExistente = (_Tally > 0)
				use in select (lcCursor)
			catch to loErr
			endtry
		endif
		return !llExistente
	endfunc

Enddefine


*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
Define Class Componente_ItemDatosCheque As Custom

	Codigo = ""
	NumeroCheque = 0
	Chequera = ""
	ChequeraDescripcion = ""
	Monto = 0
	AutorizacionAlfa = ""
	NroItem = 0
	Valor = ""
	Tipo = 0
	Moneda = ""
	Fecha = {}
	FechaEmision = {}
	CuentaEndoso = ""
	LeyendaEndoso = ""
	FechaEndoso = {}
	Vendedor = ""
	PagueseA = ""
	lEnabled = .T.
	Accion = 0
	Estado = ""
	HistorialDetalle = null
	oInformacion = null

	*-----------------------------------------------------------------------------------------
	function oInformacion_Access() as Object
		if ( vartype( this.oInformacion ) != "O" or isnull( this.oInformacion ) )
			this.oInformacion = _Screen.zoo.crearobjeto( "zooInformacion", "zooInformacion.prg" )
		endif
		Return this.oInformacion
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Init() as VOID
		local loDetalleCheque as Object, loInteraccion as Object
		loDetalleCheque = _Screen.zoo.crearobjeto( "zooColeccion" )
		loInteraccion = createobject( "empty" )
		addproperty( loInteraccion, "NroItem", 0 )
		addproperty( loInteraccion, "Comprobante", "" )
		addproperty( loInteraccion, "TipoDeComprobante", 0 )
		addproperty( loInteraccion, "Estado", "" )
		addproperty( loInteraccion, "Tipo", 0 )
		loDetalleCheque.Agregar( loInteraccion )
		this.HistorialDetalle = loDetalleCheque		
	endfunc

Enddefine
