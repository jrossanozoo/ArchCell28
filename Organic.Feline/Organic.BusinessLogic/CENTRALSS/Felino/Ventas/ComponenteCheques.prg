define class ComponenteCheques as Din_ComponenteCHEQUES of Din_ComponenteCHEQUES.prg

	#if .f.
		local this as ComponenteCheques of ComponenteCheques.prg
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

	protected oColaboradorCheques as Object
	protected cEntidadDelComponente as String, lUtilizarCarteraDeCheque as Boolean
	
	cNombre = "CHEQUES"
	cEntidadDelComponente = "CHEQUE"
	oCheques= null
	oColaboradorCheques = Null
	oTipoDeValores = null
	lUtilizarCarteraDeCheque = .f.
	oChequesADarDeBajaDeLaCartera = null
	oChequesDadosDebajaDeLaCarteraAntesDeModificar = null
	
	oClonadorDeCheques = null
	nPais = 0
	oValor = NULL
	cMonedaComprobante = ""
	cMonedaSistema = ""
	nTipoComprobante = 0

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
		this.oCheques = _Screen.zoo.crearobjeto( "zooColeccion" )
		this.oEntidad.lEntidadInstanciadaPorComponenteCheques = .t.
		this.oChequesADarDeBajaDeLaCartera = _Screen.zoo.crearobjeto( "zooColeccion" )
		this.oChequesDadosDebajaDeLaCarteraAntesDeModificar = _Screen.zoo.crearobjeto( "zooColeccion" )		
		this.nPais = goServicios.Parametros.Nucleo.DatosGenerales.Pais
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function oColaboradorCheques_access as Object
		if !this.lDestroy and !( vartype( this.oColaboradorCheques ) == "O" )
			this.oColaboradorCheques = _screen.zoo.CrearObjeto( "colaboradorCheques", "colaboradorCheques.PRG" )
		endif
		return this.oColaboradorCheques
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarChequeSelecionadoDeLaCartera( tcIdChequeSeleccionado as String, toItem as ItemActivo of ItemActivo.Prg ) as void
	endfunc		
	
	*-----------------------------------------------------------------------------------------
	protected function ValidarMonedaDeCheque( toItem as Object ) as Void
		local lcMonedaCheque as String	
		lcMonedaCheque = this.ObtenerMonedaCheque()
		if ( lcMonedaCheque = toItem.Valor.SimboloMonetario_PK )
		else
			goServicios.Errores.LevantarExcepcion( "La moneda del cheque debe ser igual a la moneda del valor." )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarTipoDeCheque( toItem as Object ) as Void
		local lnTipoDeChequeDelItem as Integer
		lnTipoDeChequeDelItem = this.ObtenerTipoDeChequeDelItem( toItem )
		if this.oEntidad.Tipo <> lnTipoDeChequeDelItem
			goServicios.Errores.LevantarExcepcion( "El tipo de valor del cheque seleccionado " ;
												+ "[" + this.oTipoDeValores.ObtenerDescripcion( this.oEntidad.Tipo ) +"]" ;
												+ " debe ser igual al del valor ingresado en el comprobante " ;
												+ "[" + this.oTipoDeValores.ObtenerDescripcion( lnTipoDeChequeDelItem ) +"]" )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerMonedaCheque() as Boolean
		local lcRetorno as string
		
		lcRetorno = This.oEntidad.Moneda_pk

		if empty( lcRetorno )
			if empty( This.oEntidad.Valor )
				lcRetorno = this.cMonedaComprobante
			else
				lcRetorno = this.ObtenerMonedaEnValor( This.oEntidad.Valor )
			endif
		endif

		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerTipoDeChequeDelItem( toItem as Object ) as Integer
		local lnTipoDeCheque as Integer
		lnTipoDeCheque = 0
		if empty( alltrim( toItem.Valor_pk ) )
			lnTipoDeCheque = toItem.Tipo
		else
			lnTipoDeCheque = toItem.Valor.Tipo
		endif
		return lnTipoDeCheque
	endfunc 

	*-----------------------------------------------------------------------------------------
	function cMonedaComprobante_Access() as string
		if !this.ldestroy and empty( this.cMonedaComprobante )
			this.cMonedaComprobante = this.oEntidadPadre.MonedaComprobante_PK
		endif

		return this.cMonedaComprobante
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function cMonedaSistema_Access() as string
		if !this.ldestroy and empty( this.cMonedaSistema )
			this.cMonedaSistema = GoParametros.Felino.Generales.MonedaSistema
		endif
		return this.cMonedaSistema
	endfunc 

	*-----------------------------------------------------------------------------------------
	function InyectarEntidad( toEntidad as Object ) as Void
		dodefault( toEntidad )
		if this.ValidarEntidad() and this.LaEntidadDebeUtilizarLaCarteraDeChequesYDarlosDebaja( toEntidad )			
			this.lUtilizarCarteraDecheque = .t.
			this.oChequesADarDeBajaDeLaCartera = _Screen.zoo.CrearObjeto( "ZooColeccion" )
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerEntidad() as entidad OF entidad.prg
		return this.oEntidad
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ValidarEntidad() as boolean
		local llOk as Boolean
		llOk = dodefault()
		if !llOk
			if pemstatus( this.oEntidadPadre, "TipoComprobante", 5 ) and type( "this.oEntidadPadre.TipoComprobante" ) = "N"
				this.nTipoComprobante = this.oEntidadPadre.TipoComprobante
			endif
		endif
		return llOk
	endfunc
		
	*-----------------------------------------------------------------------------------------
	function ValidarCargaEntidad( toCheque as entidad OF entidad.prg ) as boolean
		local llRetorno as boolean
		llRetorno = .t.
		return llRetorno 
	endfunc 
	    
	*-----------------------------------------------------------------------------------------
	function Imprimir( toItem as object ) as void
		if vartype( goControladorFiscal ) = 'O' and !isnull( goControladorFiscal )
			goControladorFiscal.FranqueoCheque( this.ArmarObjetoCheque( toItem.NumeroCheque_pk ) )
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function ArmarObjetoCheque( tcNumeroCheque as String ) as Object
		local loRetorno as Object
		loRetorno = _Screen.Zoo.InstanciarEntidad( "Cheque" )
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoPedirCheque( toCheque as Componente_ItemDatosCheque of ComponenteCheques.prg)
		*** 23/12/2009 - mrusso: aca no se escribe codigo!
	endfunc 

	*-----------------------------------------------------------------------------------------
	*Este métoso se ejecuta cuando se carga el valor en el item
	function VerificarSiSeteaDatos( toItem as Object ) as boolean
		return .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	*Este métoso se ejecuta cuando se carga el valor en el item
	function SetearYVerificarDatos( toItem as Object )
		if This.VerificarContextoEntidadPadre( "BC" )
		else
			if this.DebeUtilizarCarteraDecheque()
				this.SetearYVerificarDatosUsandoLaCarteraDeCheques( toItem )
			else
				this.IngresarUnNuevoCheque( toItem )
			endif
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function IngresarUnNuevoCheque( toItem ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearYVerificarDatosUsandoLaCarteraDeCheques( toItem as ItemActivo of ItemActivo.Prg ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ReinicializarComponenteEspecifico() as Void
		if type( "this.oCheques" ) = "O" and !isnull( this.oCheques )
			this.oCheques.Release()
		endif
		this.oCheques = _Screen.zoo.crearobjeto( "zooColeccion" )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function RestaurarFechaComprobante( toItem as Object ) as Void
		toItem.Fecha = iif( empty( toItem.FechaComp ), date(), toItem.FechaComp )
	endfunc 

	*-----------------------------------------------------------------------------------------
	*Este método se ejecuta cuando se carga el valor en el item
	function RemoverDatosSiCambioTipo( toItem as Object ) as Void
	endfunc 	

	*-----------------------------------------------------------------------------------------
	protected function ObtenerObjetoCheque( toItem as object ) as Componente_ItemDatosCheque of ComponenteCheques.prg
		local loRetorno as Componente_ItemDatosCheque of ComponenteCheques.prg
		loRetorno  = newobject( "Componente_ItemDatosCheque", "ComponenteCheques.prg" )
		loRetorno.lEnabled = .f.
		return loRetorno
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function EsUnItemModificable( toItem ) as Boolean
		return .T.
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearCodigoTributario( toCheque as object ) as void
		with toCheque 
			if this.nPais = 2
				.CodigoTributarioLibradorRUT = this.oEntidadPadre.oLibradorDeCheque.rut
			else
				.CodigoTributarioLibrador = this.oEntidadPadre.oLibradorDeCheque.Cuit
			endif
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarCheque( toDatos as Componente_ItemDatosCheque of ComponenteCheques.prg, tnNroItem as integer )
	endfunc

	*-----------------------------------------------------------------------------------------
	function AsignarNumeroDeItemAlItemCero( toItem as object ) as Void
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	*Este método se ejecuta al hacer nuevo en la entidad
	function Reinicializar( tlLimpiar as Boolean ) as Void
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function CargarCheque( toCheque as Componente_ItemDatosCheque of ComponenteCheques.prg, toItem as object ) as void
	endfunc 

	*-----------------------------------------------------------------------------------------
    function Grabar() as object
    	local loRetorno as zoocoleccion OF zoocoleccion.prg, loColeccion as zoocoleccion OF zoocoleccion.prg
		loColeccion = _Screen.zoo.Crearobjeto( "ZooColeccion" )
		loRetorno = _Screen.zoo.Crearobjeto( "ZooColeccion" )
		this.lUtilizarCarteraDecheque = this.DebeUtilizarCarteraDecheque()
		if This.ValidarEntidad() 
			do case
				case this.lUtilizarCarteraDecheque
					this.AgregarSentencias( this.CargarDatosDeCancelacionEnLosCheques(), loColeccion )
				case  this.oEntidadPadre.lanular
					this.AgregarSentencias( this.AnularOEliminarCheques(), loColeccion )
				case this.oEntidadPadre.EsNuevo()
					this.AgregarSentencias( This.GenerarCheques(), loColeccion )
				case this.oEntidadPadre.EsEdicion()
					this.AgregarSentencias( This.ModificarCheques(), loColeccion )
				case this.oEntidadPadre.EsComprobanteDeCaja() and this.oEntidadPadre.lEliminar
					this.AgregarSentencias( This.EliminarCheques(), loColeccion )
			endcase		
		EndIf

*!*		if type( "this.oEntidadPadre.cComprobante" ) = "C" and this.oEntidadPadre.cComprobante <> "CONCILIACION"   && Refactorizar
		if type( "this.oEntidadPadre.cNombre" ) = "C" and !inlist( this.oEntidadPadre.cNombre, "CONCILIACIONES", "COMPROBANTEDECAJA" ) 
	    	loRetorno = dodefault()
		endif
    	loColeccion.AgregarRango( loRetorno )
    	loRetorno = loColeccion
    	return loRetorno
    endfunc
    
  	*-----------------------------------------------------------------------------------------
	protected function CargarDatosDeCancelacionEnLosCheques() as zoocoleccion OF zoocoleccion.prg
		local loRetorno as zoocoleccion OF zoocoleccion.prg
		loRetorno = _screen.zoo.CrearObjeto( "Zoocoleccion" )
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CargarLosDatosDeCancelacionEnLosChequesUtilizadosEnElComprobante() as zoocoleccion OF zoocoleccion.prg
		local loRetorno as zoocoleccion OF zoocoleccion.prg
		loRetorno = _screen.zoo.CrearObjeto( "Zoocoleccion" )	
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearDatosAlItemActivoDelHistorialSegunEntidadPadre() as Void
		local lcSiglasDeIdentificadorDeComprobante as String

		&& Refactorizar
		lcSiglasDeIdentificadorDeComprobante = goServicios.Entidades.ObtenerIdentificadorDeEntidad( this.oEntidadPadre.cNombre )

		with this.oEntidad.HistorialDetalle.oItem
			do case
				case this.oEntidadPadre.TipoComprobante == 0 and type( "this.oEntidadPadre.cComprobante" ) = "C" and this.oEntidadPadre.cComprobante = "CONCILIACION" && Conciliaci{on bancaria
					.Comprobante = lcSiglasDeIdentificadorDeComprobante + " " + padl( this.oEntidadPadre.Numero, 10, "0" )
				case this.oEntidadPadre.TipoComprobante == 31 && Orden de pago
					.Comprobante = lcSiglasDeIdentificadorDeComprobante + " " + padl( this.oEntidadPadre.Numero, 10, "0" )
					.Proveedor = this.oEntidadPadre.Proveedor_pk
					.ProveedorDescripcion = this.oEntidadPadre.Proveedor.Nombre
				case this.oEntidadPadre.TipoComprobante == 37 && Pago
					.Comprobante = lcSiglasDeIdentificadorDeComprobante + " " + padl( this.oEntidadPadre.Numero, 10, "0" )
					.Proveedor = this.oEntidadPadre.OrdenDePago_Proveedor_pk
					.ProveedorDescripcion = this.oEntidadPadre.OrdenDePago_Proveedor.Nombre
				case this.oEntidadPadre.TipoComprobante == 8  && Factura de compra
					.Comprobante = lcSiglasDeIdentificadorDeComprobante + " " + padl( this.oEntidadPadre.NumInt, 10, "0" )
					.Proveedor = this.oEntidadPadre.Proveedor_pk
					.ProveedorDescripcion = this.oEntidadPadre.Proveedor.Nombre
				case this.oEntidadPadre.TipoComprobante == 9  && Nota de débito de compra
					.Comprobante = lcSiglasDeIdentificadorDeComprobante + " " + padl( this.oEntidadPadre.NumInt, 10, "0" )
					.Proveedor = this.oEntidadPadre.Proveedor_pk
					.ProveedorDescripcion = this.oEntidadPadre.Proveedor.Nombre
				case this.oEntidadPadre.TipoComprobante == 10  && Nota de crédito de compra
					.Comprobante = lcSiglasDeIdentificadorDeComprobante + " " + padl( this.oEntidadPadre.NumInt, 10, "0" )
					.Proveedor = this.oEntidadPadre.Proveedor_pk
					.ProveedorDescripcion = this.oEntidadPadre.Proveedor.Nombre
				case this.oEntidadPadre.TipoComprobante == 98  && Comprobante de caja
					.Comprobante = lcSiglasDeIdentificadorDeComprobante + " " + padl( this.oEntidadPadre.Numero, 10, "0" )
				otherwise
					.Comprobante = this.GenerarDescripcionComprobante( This.oEntidadPadre, ;
						This.oEntidadPadre.TipoComprobante, ;
						This.oEntidadPadre.Letra, ;
						This.oEntidadPadre.PuntoDeVenta, ;
						This.oEntidadPadre.Numero )
					if !this.oEntidadPadre.EsComprobanteDeCaja()
						if this.oEntidadPadre.oLibradorDeCheque.cNombre = "PROVEEDOR"
							.Proveedor = this.oEntidadPadre.Proveedor_pk
							.ProveedorDescripcion = this.oEntidadPadre.Proveedor.Nombre
						else	
							if pemstatus( this.oEntidadPadre, "Cliente_Pk", 5 )
								.Cliente = this.oEntidadPadre.Cliente_Pk
								.ClienteDescripcion = this.oEntidadPadre.Cliente.Nombre
							endif
						endif
					endif
			endcase
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function LimpiarDatosDeCancelacionEnLosChequesQueFueronRemovidosDelComprobante() as zoocoleccion OF zoocoleccion.prg
		local loRetorno as zoocoleccion OF zoocoleccion.prg
		loRetorno = _screen.zoo.CrearObjeto( "Zoocoleccion" )
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ExistenInteraccionesPosterioresALasDelComprobante( toHistorialDetalle as Object, tcCodigoComprobante as String ) as Boolean
		local lnNroItemDeInteraccion as Integer, llHayInteraccionesPosteriores as Boolean
		llHayInteraccionesPosteriores = .f.
		lnNroItemDeInteraccion = this.ObtenerNroItemDeInteraccionDeUnComprobante( toHistorialDetalle, tcCodigoComprobante )
		if lnNroItemDeInteraccion > 0 and lnNroItemDeInteraccion <> this.oEntidad.nUltimaInteraccion
			llHayInteraccionesPosteriores = .t.
		endif
		return llHayInteraccionesPosteriores
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function YaExisteUnaInteraccionParaElComprobante( toHistorialDetalle as Object, tcCodigoComprobante as String ) as Boolean
		return ( this.ObtenerNroItemDeInteraccionDeUnComprobante( toHistorialDetalle, tcCodigoComprobante ) > 0 )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerNroItemDeInteraccionDeUnComprobante( toHistorialDetalle as Object, tcCodigoComprobante as String ) as Boolean
		local loItem as Object, lnNroItemDeInteraccion as Integer
		lnNroItemDeInteraccion = 0
		for each loItem in toHistorialDetalle foxobject
			if loItem.CodigoComprobante = tcCodigoComprobante
				lnNroItemDeInteraccion = loItem.NroItem
				exit
			endif
		endfor
		return lnNroItemDeInteraccion
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EliminarInteraccionEnElHistorialDelCheque( toHistorialDetalle as Object, tcCodigoComprobante as String ) as Void
		local lnNroItemDeInteraccion as Integer
		lnNroItemDeInteraccion = this.ObtenerNroItemDeInteraccionDeUnComprobante( toHistorialDetalle, tcCodigoComprobante )
		if lnNroItemDeInteraccion > 0
			toHistorialDetalle.Quitar( lnNroItemDeInteraccion )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerEstadoDeUltimaInteraccion( toHistorialDetalle as Object ) as String
		local lcRetorno as String
		lcRetorno  = ""
		if toHistorialDetalle.Count > 0
			lcRetorno = toHistorialDetalle.item[ this.oEntidad.nUltimaInteraccion ].Estado
		endif
		return lcRetorno
	endfunc 
	
   	*-----------------------------------------------------------------------------------------
	protected function GenerarCheques( toRetorno as zoocoleccion OF zoocoleccion.prg ) as zoocoleccion OF zoocoleccion.prg
		local loRetorno as zoocoleccion OF zoocoleccion.prg
	 	loRetorno = _screen.zoo.crearobjeto( "zoocoleccion" )
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ModificarCheques() as zoocoleccion OF zoocoleccion.prg
		local loRetorno as zoocoleccion OF zoocoleccion.prg
		loRetorno = _screen.zoo.crearobjeto( "zoocoleccion" )
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function BuscarEnoColCheque( tnNroItem as Integer ) as Object
		local loRetorno as Object
		loRetorno = Null
		if this.oCheques.Buscar( transform( tnNroItem ) )
			loRetorno =	this.oCheques.Item[ transform( tnNroItem ) ]
		endif
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EstaEnDetalle( toItem as Object, toDetalle as Object ) as boolean
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AnularOEliminarCheques() as zoocoleccion OF zoocoleccion.prg
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function EliminarCheques() as zoocoleccion OF zoocoleccion.prg
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function AnularChequesPropios() as zoocoleccion OF zoocoleccion.prg
	endfunc

   	*-----------------------------------------------------------------------------------------
	function AgregarSententiciasEliminarCheque( tcNumeroCheque as String, toRetorno as object ) as void
	endfunc
	
   	*-----------------------------------------------------------------------------------------
	protected function GenerarCheque( toCheque as Componente_ItemDatosCheque of ComponenteCheques.prg, toRetorno as object, tnIncremento as Integer ) as zoocoleccion OF zoocoleccion.prg 
		return toRetorno
	endfunc

   	*-----------------------------------------------------------------------------------------
	protected function ModificarUnCheque( toCheque as Componente_ItemDatosCheque of ComponenteCheques.prg, toRetorno as object ) as zoocoleccion OF zoocoleccion.prg 
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function oValor_Access() as variant
		if !this.ldestroy and ( !vartype( this.oValor ) = 'O' or isnull( this.oValor ) )
			this.oValor = _Screen.Zoo.InstanciarEntidad( "VALOR" )
		endif
		return this.oValor
	endfunc
		
	*-----------------------------------------------------------------------------------------
	protected function ObtenerMonedaEnValor( tcValor as String ) as String
		local lcRetorno as String
		this.oValor.Codigo = tcValor
		lcRetorno = this.oValor.SimboloMonetario_PK
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ActualizarCodigoTributarioLibrador( toCheque as Componente_ItemDatosCheque of ComponenteCheques.prg ) as Void
		if this.nPAIS = 1
			this.oEntidad.CodigoTributarioLibrador = toCheque.CodigoTributarioLibrador
		else
			this.oEntidad.CodigoTributarioLibradorRUT = toCheque.CodigoTributarioLibradorRUT
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function votarCambioEstadoANULAR( tcEstado as String ) as boolean
		local llRetorno as Boolean
		llRetorno = .T.
		if This.ValidarEntidad()
			if !this.DebeUtilizarCarteraDecheque()
				llRetorno = this.ObtenerVotoAnular()
			endif
		endif
		return llRetorno	
	endfunc
	
	*-----------------------------------------------------------------------------------------
	protected function ObtenerVotoAnular() as Boolean
		return .t.
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarAfectacionDelItem( toItem as Object, tcCodigoComprobanteAfectante as String ) as Boolean 
		return .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ValidarComprobanteDeAfectacionDelItem( toItem as Object ) as Boolean 
		local llRetorno as Boolean, loError as Object 
		try
			llRetorno = !empty(toItem.NumeroCheque.CodigoComprobanteAfectante)
		catch to loError
			llRetorno = .f.
		endtry 
		
		return llRetorno
	endfunc 	

	*-----------------------------------------------------------------------------------------
	function ValidarChequeActivo( tcGuid as String ) as Boolean
		Return This.oEntidad.EstaAfectado( tcGuid, this.ObtenerCodigoDeComprobante() )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function votarCambioEstadoGRABAR( tcEstado as String ) as boolean
		local llRetorno as Boolean
		if this.DebeUtilizarCarteraDecheque()
			llRetorno = this.VerificarQueNoSeEsteCancelandoUnChequeCancelado()
		else
			llRetorno = this.votarCambioEstadoGrabarAltaDeCheques()
		endif
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function VerificarChequeAsociado( toItem as Object ) as Boolean 
		return .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CargarChequeElectronicoAColeccion( oColChequeElectronico as Object, toItem as Object ) as Void 
		local loItemElectronico as Object, lcIndice as String 
		if pemstatus(toItem, "ChequeElectronico", 5) and toItem.ChequeElectronico
			loItemElectronico =  newobject( "Custom" ) 
			loItemElectronico.AddProperty("NroItem", 0)
			loItemElectronico.NroItem = toItem.NroItem
			lcIndice = transform(toItem.NroItem)
			oColChequeElectronico.Add(oItemElectronico, lcIndice)
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function votarCambioEstadoGrabarAltaDeCheques() as boolean
		local loItem as Object, loCheque as Object, llRetorno as Boolean, loDetalle as zoocoleccion OF zoocoleccion.prg, lnIntCH as integer, ;
			lnTotal as integer, lni as Integer, lnj as Integer, loColChequeElectronico as zoocoleccion OF zoocoleccion.prg, llEsChequeElectronico  as Boolean
		llRetorno = .t.
	
		if !This.oEntidadPadre.VerificarContexto( "BC" ) and this.ValidarEntidad()
			********************************************************************************************************
			* Verificamos que todo valor de tipo cheque tenga asociado un cheque en la coleccion de cheques
			********************************************************************************************************
			loColChequeElectronico = _screen.zoo.crearobjeto("zoocoleccion")
			for each loItem in This.oDetallePadre foxobject
				this.CargarChequeElectronicoAColeccion(loColChequeElectronico, loItem)
				if !this.verificarchequeasociado( loItem )
					llRetorno = .f.
				endif
			endfor
			********************************************************************************************************
			* Verificamos que todo cheque, en la coleccion de cheques, tenga asociado un valor de tipo cheque en el detalle de valores
			********************************************************************************************************	
			if llRetorno 
				loDetalle = this.oDetallePadre
				lnTotal = this.oCheques.count
				for lnIntCH = lnTotal to 1 step -1
					loCheque = this.oCheques.Item[ lnIntCH ]
					
					if loDetalle.Buscar( loCheque.NroItem )
						loItem = this.ObtenerItemAsociadoACheque( this.oDetallePadre, loCheque.NroItem )
						if this.EsValorTipoChequeDeTerceros( loItem.Tipo ) or this.EsValorTipoChequePropio( loItem.Tipo )
						else
							this.oCheques.Quitar( transform( loCheque.NroItem ) )
							llRetorno = .f.
						endif
					else
						this.oCheques.Quitar( transform( loCheque.NroItem ) )					
						llRetorno = .f.
					endif
				endfor
			endif
			if llRetorno
			else
				This.AgregarInformacion( "Error en los datos de los cheques. Verifique los valores"  )
			endif
			********************************************************************************************************
			* Verificamos que todo cheque, en la coleccion de cheques, Sea unico en numero y entidad financiera
			********************************************************************************************************				
			if llRetorno and goServicios.Parametros.Felino.GestionDeVentas.ChequeDeTerceros.RestringirIngresoDeChequesDuplicados
				for lni = 1 to This.oCheques.Count
					loItem = This.oCheques.Item[ lnI ]
					for lnj = lnI + 1 to This.oCheques.Count
						loItem2 = This.oCheques.Item[ lnJ ]
						llEsChequeElectronico = loColChequeElectronico.buscar(transform( loItem.NroItem ))
						
						if loItem2.NumeroCheque = loItem.NumeroCheque and loItem2.EntidadFinanciera = loItem.EntidadFinanciera and !(llEsChequeElectronico and loItem.NumeroCheque = 0)
							This.AgregarInformacion( "El número de cheque " + transform( loItem.NumeroCheque ) + " para la entidad financiera " + rtrim( loItem.EntidadFinanciera ) + ;
									" - " + alltrim( loItem.DescripcionEntidadFinanciera ) + " se encuentra duplicado en la filas " + transform( loItem.NroItem ) + " y " + transform( loItem2.NroItem ) )
							llRetorno = .F.
						Endif
					EndFor
				endfor
			EndIf
		endif
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SetearCombinacionEnEntidadOrigen( tnTipoComprobante as Integer, tcLetra as String, tnPuntoDeVenta as Integer, ;
		tnNumero as Integer, tnSignoDeMovimiento as Integer, tcCodigoComprobante as String ) as Void

		with This.oEntidad
			.TipoDeComprobanteOrigen = tnTipoComprobante
			.LetraOrigen = tcLetra
			.PuntoDeVentaOrigen = tnPuntoDeVenta
			.NumeroOrigen = tnNumero				
			.ComprobanteOrigen =  this.GenerarDescripcionComprobante( This.oEntidadPadre, tnTipoComprobante, tcLetra, tnPuntoDeVenta, tnNumero )
			.CodigoComprobanteOrigen = tcCodigoComprobante
			.SignoDeMovimientoOrigen = tnSignoDeMovimiento
		endwith

	*-----------------------------------------------------------------------------------------
	protected function GenerarDescripcionComprobante( toEntidad As Object, tnTipo as Integer, tcLetra as String, tnPtoVta as Integer, tnNumero as Integer ) as String
		return upper( toEntidad.obtenerIdentificadorDeComprobante( tnTipo ) ) + " " + upper( alltrim( tcLetra ) ) + " " + padl( int( tnPtoVta  ), 4, "0" ) + ;
    		"-" + padl( round( tnNumero, 0 ), 8, "0" )
    endfunc

    *-----------------------------------------------------------------------------------------
	protected function LlenarColeccionSentencias( toColOrigen as zoocoleccion OF zoocoleccion.prg, toColDestino as zoocoleccion OF zoocoleccion.prg ) as Void
		local lcItem as String
		for each lcItem in toColOrigen
			toColDestino.Agregar( lcItem )
		EndFor	
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ResolverNumeracionEntidad( toCheque as din_entidadCheque of din_entidadCheque.prg ) as void
		toCheque.oAd.GrabarNumeraciones()	
	endfunc	
		
	*-----------------------------------------------------------------------------------------
	*** Refactorizar: Debe estar resuelto por framework
	protected function ResolverNumeracion( tnIncremento as Integer, toRetorno as Object ) as Void
		local loTalonario as entidad OF entidad.prg
		
		with this
			.CancelarCheque()
			.oEntidad.nuevo()
			
			loTalonario = _screen.zoo.instanciarentidad( "Talonario" )
			loTalonario.codigo = .oEntidad.oNumeraciones.obtenerTalonario( "NUMEROC" )
			loTalonario.modificar()
			loTalonario.Numero = loTalonario.Numero + tnIncremento 
			.AgregarSentencias( loTalonario.ObtenerSentenciasUpdate(), toRetorno )

			loTalonario.cancelar()
			loTalonario.release()

			.oEntidad.Cancelar()
		endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CancelarCheque() as Void
		with this
			if .oEntidad.EsNuevo() or .oEntidad.EsEdicion()
				.oEntidad.Cancelar()
			endif
		endwith
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function AntesDeSetearAtributo( toItemValor as Object, tcAtributo as String, txValOld as Variant, txVal as Variant ) as Void
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerXmlDeChequesEnCartera( tnTipoValor as Integer ) as String
		return ""
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AgregarSentencias( toOrigen as zoocoleccion OF zoocoleccion.prg, toDestino as zoocoleccion OF zoocoleccion.prg )  as Void
		local lcSentencia as string
		for each lcSentencia in toOrigen foxobject
			toDestino.Agregar( lcSentencia )
		endfor
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerChequeDeCarteraAUtilizar( tcXmlCarteraDeCheques as String, toItem as ItemActivo of ItemActivo.Prg ) as String
		local loArgumentosEvento as Object, lcNumInt as String, lcAux as String
		loArgumentosEvento = _screen.zoo.CrearObjeto( "ArgumentoEventoSeleccionChequeDeCartera" )
		loArgumentosEvento.cXMLChequesEnCarteraPendientes = tcXmlCarteraDeCheques 
		loArgumentosEvento.cEntidadCheque = this.cEntidadDelComponente
		loArgumentosEvento.oDetalleActual = This.oDetallePadre
		this.ObtenerChequeSeleccionadoDefault( loArgumentosEvento, tcXmlCarteraDeCheques, toItem )
		this.ObtenerChequeSeleccionadoActualmente( loArgumentosEvento, toItem )
		this.oEntidadPadre.ObtenerChequeDeCarteraAUtilizar( loArgumentosEvento ) &&Este metodo llega hasta el kontroler / Método de ent_descargadecheques
		lcNumInt = loArgumentosEvento.idChequeSeleccionado
		lcAux =  this.ObtenerGUIDSegunNroInterno(left(lcNumInt,4)+"-"+right(lcNumInt,len(lcNumInt)-4))
		loArgumentosEvento.idChequeSeleccionado = lcAux
		return loArgumentosEvento.idChequeSeleccionado
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerChequeSeleccionadoDefault( toArgumentosEvento as ArgumentoEventoSeleccionChequeDeCartera of ArgumentoEventoSeleccionChequeDeCartera.prg, ;
		tcXmlCarteraDeCheques as String, toItem as ItemActivo of ItemActivo.Prg ) as Void
		local lcWhere as String
		lcWhere = "1=1"
		
		if empty( toItem.NumeroCheque_pk )
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
			toArgumentosEvento.idChequeSeleccionado = toItem.NumeroCheque_pk
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function VerificarQueNoSeEsteCancelandoUnChequeCancelado() as Boolean
		return .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function obtenerConjuntoDeChequesADarDeBaja() as zoocoleccion OF zoocoleccion.prg
		return this.oChequesADarDeBajaDeLaCartera
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerChequeSeleccionadoActualmente( toArgumentosEvento as ArgumentoEventoSeleccionChequeDeCartera of ArgumentoEventoSeleccionChequeDeCartera.prg, ;
		toItem as ItemActivo of ItemActivo.Prg ) as Void
		if !empty( toItem.NumeroCheque_pk )
			toArgumentosEvento.cidChequeSeleccionadoActualmente = toItem.NumeroCheque_pk
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function LaEntidadDebeUtilizarLaCarteraDeChequesYDarlosDebaja( toEntidad as entidad OF entidad.prg ) as Boolean
 		return .f.
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsDetalleAEntregarCanjeDeCupones( tcNombre as String ) as Boolean
		local llRetorno as Boolean
		llRetorno = .F.
		
		if upper( tcNombre ) == 'CANJEDECUPONES' and upper( This.oDetallePadre.cEtiqueta ) == 'VALORES A ENTREGAR'
			llRetorno = .T.
		endif
		
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsCanjeDeCuponesUsandoCarteraDeCheques( toEntidad as entidad OF entidad.prg ) as Boolean
		local llRetorno as Boolean
		llRetorno = .f.
		if toEntidad.EsCanjeDeCupones()
			if this.EsDetalleAEntregarCanjeDeCupones( toEntidad.cNombre )
				llRetorno = .t.
			else
				llRetorno = !this.EsDetalleARecibirCanjeDeCuponesConChequesIngresadosNuevos( toEntidad, This.oDetallePadre )
			endif
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsComprobanteDeCajaUsandoCarteraDeCheques( toEntidad as entidad OF entidad.prg ) as Boolean
		local llRetorno as Boolean, loDetalle as Collection
		llRetorno = .f.
		if toEntidad.EsComprobanteDeCaja()
			loDetalle = toEntidad.ObtenerDetalleDeValores()
			llRetorno = loDetalle.ObtenerTipoDeUsoDeChequesDeTerceros() = ESTADOSELECCIONADO
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsDetalleARecibirCanjeDeCuponesConChequesIngresadosNuevos( toEntidad as Object, toDetalleARecibir as Object ) as Boolean
		local llRetorno as Boolean, loItem as Object
		llRetorno = .f.
		if toEntidad.EsCanjeDeCupones()
			for each loItem in toDetalleARecibir foxobject
				if  ( toEntidad.lanular and this.oEntidad.ObtenerCantidadDeInteraccionesDeUnCheque( loItem.NumeroCheque_PK ) = 1 ) ;
				 or ( toEntidad.lnuevo and !empty( loItem.NumeroCheque_PK ) )
					llRetorno = .t.
					exit
				endif
			endfor
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CargarChequeDesdeNroInterno(tcguid, toItem  ) as Void
		if This.oEntidadPadre.VerificarContexto( "BC" )
		Else
			this.AgregarChequeSelecionadoDeLaCartera(tcguid, toItem )
		Endif	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerGUIDSegunNroInterno( tcNroInterno as string ) as String  
		local lcRetorno as string, llok as Boolean ,lnPtoVta as Integer, lnNumero as Integer, loCheque as Object 
		lcRetorno = ""
		lnPtoVta = val( getwordnum( tcNroInterno,1,"-"))
		lnNumero = val( getwordnum( tcNroInterno,2,"-"))
		loCheque = this.ObtenerColeccionDeCheques() 	
		
		if !empty( lnPtoVta ) and !empty( lnNumero )
			with loCheque
				.puntodeventa = lnPtoVta
				.numeroC = lnNumero
				llOk = .buscar()
				if llOk
					.cargar()
					lcRetorno = .codigo
				endif
				.puntodeventa = 0
				.numeroC = 0
				.codigo = ''
			endwith 
		endif
			
		return lcRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerColeccionDeCheques() as Object 
		return this.oCheque
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerMontoDeChequesVencidosDelCliente( lcCliente as String ) as Float
		local lnRetorno as Float, lcXml as String, lcWhere as String
		
		lcWhere = "Cliente='" + lcCliente + "'" + " and fecha > ctod('" + dtoc( golibrerias.obtenerfecha() ) + "')"
		lcXml = this.oEntidad.ObtenerDatosEntidad( "Cliente, Fecha, Monto", lcWhere, "" )

		this.XmlACursor( lcXml, "c_ChequesDisponibles" )
		lnRetorno = 0
 	
		select c_ChequesDisponibles
		scan
			lnRetorno = lnRetorno + c_ChequesDisponibles.Monto
		endscan

		use in select( "c_ChequesDisponibles" )
		
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function PreCargarCheque( toCheque as Object ) as Void
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	protected function ObtenerClonadorDeCheques() as Object
		return null
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerMontoDeChequesPendientesDelCliente( lcCliente as String ) as Float
		local lnRetorno as Float, lcXml as String, lcWhere as String

		lcWhere = "Cliente='" + lcCliente + "'" + " and ((estado in ( 'CARTE', 'RECHA', 'ENVIA', 'TRANS', 'ENVRE' ) and cfecha + 2 >= ctod('" + dtoc( golibrerias.obtenerfecha()) + "'))"
		lcWhere = lcWhere + " or (estado IN ( 'ENTRE', 'DEPOS', 'PREPA', 'CUSTO' ) and cfecha + 3 >= ctod('" + dtoc( golibrerias.obtenerfecha()) + "')))"

		lcXml = this.oEntidad.ObtenerDatosEntidad( "Cliente, Fecha, Monto, Moneda ", lcWhere, "" )

		this.XmlACursor( lcXml, "c_ChequesDisponibles" )
		lnRetorno = 0

		select c_ChequesDisponibles
		scan			
			lnRetorno = lnRetorno + this.oEntidad.Moneda.ConvertirImporte( c_ChequesDisponibles.Monto, c_ChequesDisponibles.Moneda, this.cMonedaSistema, date() )
		endscan
		use in select( "c_ChequesDisponibles" )
		
		return lnRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ActualizarLibradorEnCheque( tnNroItem as Integer, tcCuitCliente as String ) as Void
		local lnItem as Integer
		for lnItem = 1 to this.oCheques.Count
			if this.oCheques[lnItem].NroItem = tnNroItem and empty(this.oCheques[lnItem].CodigoTributarioLibrador)
				this.oCheques[lnItem].CodigoTributarioLibrador = tcCuitCliente
				exit
			endif
		next
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCuitCliente( toItem as object ) as String
		local lcRetorno as String
		lcRetorno = ""
		if type("toItem") = "O" and !isnull(toItem) and type("toItem.oEntidad") = "O" and !isnull(toItem.oEntidad);
					 and type("toItem.oEntidad.Cliente") = "O" and !isnull(toItem.oEntidad.Cliente) and type("toItem.oEntidad.Cliente.CUIT") = "C"
			lcRetorno = toItem.oEntidad.Cliente.CUIT
		endif
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerAccionDeCheque( tnNroItem as Integer ) as Integer
		local lnRetorno as Integer, loItem as Object
		lnRetorno = 0
		for each loItem in this.oCheques
			if loItem.Nroitem = tnNroItem
				lnRetorno = loItem.Accion
				exit
			endif
		next
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsValorTipoChequeDeTerceros( tnTipoValor as Integer ) as Boolean
		return inlist( tnTipoValor, TIPOVALORCHEQUETERCERO, TIPOVALORCIRCUITOCHEQUETERCERO )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsValorTipoChequePropio( tnTipoValor as Integer ) as Boolean
		return inlist( tnTipoValor, TIPOVALORCHEQUEPROPIO, TIPOVALORCIRCUITOCHEQUEPROPIO  )
	endfunc 

	*-----------------------------------------------------------------------------------------
	Protected Function ExisteChequeAsociadoAlValor( toItem as Object) as Boolean
		Local llRetorno as Boolean
		llRetorno = !empty(toItem.NumeroCheque_PK) or !empty(toItem.NumeroInterno)
		llRetorno = llRetorno or this.EsChequeConAccion(toItem.NroItem)
		Return llRetorno
	EndFunc 

	*-----------------------------------------------------------------------------------------
	protected function LaEntidadPadreTieneUnConceptoConEstadoCargado() as Boolean
		local llRetorno as Boolean
		llRetorno = .f.
		if pemstatus( this.oEntidadPadre, "Concepto_pk", 5 ) ;
		 and !empty( this.oEntidadPadre.Concepto_pk ) ;
		 and !empty( this.oEntidadPadre.Concepto.EstadoCheque )
			llRetorno = .t.
		endif
		return llRetorno
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function oTipoDeValores_Access() as variant
		if !this.ldestroy and !vartype( this.oTipoDeValores ) = 'O'
			this.oTipoDeValores = _Screen.zoo.CrearObjeto( 'Din_TipoDeValores' )
		endif
		return this.oTipoDeValores
	endfunc

*!*		*-----------------------------------------------------------------------------------------
*!*		function AntesDeGrabarEntidadPadre() as Boolean
*!*			local llRetorno as Boolean
*!*			llRetorno = dodefault()
*!*			return llRetorno
*!*		endfunc

	*-----------------------------------------------------------------------------------------
	protected function CargarDesdeElPagoLosValoresCircuitoChequeTercero() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CargarDesdeElPagoLosValoresCircuitoChequePropio() as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCodigoDeComprobante() as String
		local lcCodigo as String
		with this.oEntidadPadre
			if .EsComprobanteDeCaja()
				lcCodigo = .Identificador
			else
				lcCodigo = .Codigo
			endif
		endwith
		return lcCodigo
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsChequeIngresado( tnNroItem as Integer) as Boolean
		local llRetorno as Boolean
		llRetorno = !this.lUtilizarCarteraDeCheque
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AsignarCodigoTributarioLibrador( toItem as ItemActivo of ItemActivo.Prg, toCheque as Componente_ItemDatosCheque of ComponenteCheques.prg ) as Void
		if this.nPAIS = 1
			toItem.CodigoTributarioLibrador = toCheque.CodigoTributarioLibrador
		else
			toItem.CodigoTributarioLibradorRUT = toCheque.CodigoTributarioLibradorRUT
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function SeEstaGenerandoUnContraComprobanteDeCaja() as Boolean
		return this.oEntidadPadre.EsComprobanteDeCaja() and this.oEntidadPadre.lEstaGenerandoContraComprobante
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ModificarSentenciasPorSerContraComprobanteDeCaja( toSentenciasUpdate as Object ) as Object
		local loColSentenciasModif as zoocoleccion OF zoocoleccion.prg, lnNroSentencia as Integer, lcSentencia as String
		loColSentenciasModif = _screen.zoo.CrearObjeto( "Zoocoleccion" )	

		for lnNroSentencia = 1 to toSentenciasUpdate.count
			lcSentencia = toSentenciasUpdate.Item( lnNroSentencia )
			if this.EsSentenciaDeUpdateDeCabecera( lcSentencia )
				loColSentenciasModif.Agregar( lcSentencia )
			else
				if lnNroSentencia = toSentenciasUpdate.Count and this.EsSentenciaParaElHistorialDelContraComprobante( lcSentencia, this.oEntidadPadre.Identificador )
					loColSentenciasModif.Agregar( lcSentencia )
				endif
			endif
		endfor
		return loColSentenciasModif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsSentenciaDeUpdateDeCabecera( tcSentencia as String ) as Boolean
		return .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EsSentenciaParaElHistorialDelContraComprobante( tcSentencia as String, tcIdentificadorDelComprobanteDeCaja as String ) as Boolean
		return .t.
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerNombreDetallePadre() as String
		local lcRetorno as String
		lcRetorno = ""
		if pemstatus( this.oDetallePadre, "cNombre", 5 ) and type( "this.oDetallePadre.cNombre" ) = "C"
			lcRetorno = this.oDetallePadre.cNombre
		endif
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	Protected Function DebeUtilizarCarteraDecheque() as Boolean
		Local llRetorno as Boolean, lnSigno as Integer
		llRetorno = this.lUtilizarCarteraDeCheque
		Return llRetorno
	EndFunc 

	*-----------------------------------------------------------------------------------------
	Function EsChequeConAccion( tnNroItem as Integer) as Boolean
		local llRetorno as Boolean
		llRetorno = .f.
		for each loItem in this.oCheques
			if loItem.Nroitem = tnNroItem
				llRetorno = inlist(loItem.Accion, ESTADOINGRESADO, ESTADOSELECCIONADO)
				exit
			endif
		next
		return llRetorno
	EndFunc 

	*-----------------------------------------------------------------------------------------
	function Destroy() as Void
		dodefault()
		if this.lDestroy 
			if vartype( this.oTipoDeValores ) == 'O' and !isnull( this.oTipoDeValores )
				this.oTipoDeValores.Release()
			endif
			if vartype( this.oValor ) == 'O' and !isnull( this.oValor )
				this.oValor.Release()
			endif
			if vartype( this.oColaboradorCheques ) == 'O' and !isnull( this.oColaboradorCheques )
				this.oColaboradorCheques.Release()
			endif
			this.oCheques = null
			this.oChequesADarDeBajaDeLaCartera = null
			this.oChequesDadosDebajaDeLaCarteraAntesDeModificar = null
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCajaDelCheque( tcIdCheque as String ) as Integer
		local lnCaja as Integer
		with this.oEntidad
			if .Codigo = tcIdCheque
				lnCaja = .HistorialDetalle.Item[ 1 ].CajaEstado
			else
				lnCaja = goCaja.ObtenerNumeroDeCajaActiva()
			endif
		endwith
		return lnCaja
	endfunc 

	*-----------------------------------------------------------------------------------------
	Protected Function ObtenerItemAsociadoACheque( toDetalle as Collection, tnNroItem as Integer ) as Object
		Local loRetorno as Object, loDetalle as Collection
*!*			loDetalle = toDetalle && this.oDetallePadre
*!*			loRetorno = loDetalle.Item( tnNroItem )
		loRetorno = toDetalle.Item( tnNroItem )
		Return loRetorno
	EndFunc 

	*-----------------------------------------------------------------------------------------
	protected function MostrarNumeroCheque() as Boolean
		return pemstatus(this.oEntidadPadre,"lMostrarNumeroDeCheque",5) and this.oEntidadPadre.lMostrarNumeroDeCheque
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ObtenerStringNumeroCheque( tnNumero ) as string
		return transform( tnNumero )+" (Nro chq)"
	endfunc

enddefine


*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
Define Class Componente_ItemDatosCheque as Custom

	Codigo = ""
	NumeroCheque = 0
	Monto = 0
	Tipo = 0
	Valor = ""
	Moneda = ""
	NroItem = 0
	Fecha = {}
	FechaEmision = {}
	CuitCliente = ""
	EntidadFinanciera = ""
	CodigoTributarioLibrador = ""
	CodigoTributarioLibradorRUT = ""
	TelefonoLibrador = ""
	NombreLibrador = ""
	AutorizacionAlfa = ""
	DescripcionEntidadFinanciera = ""
	EntidadFinancieraEndoso = ""
	CuentaEndoso = ""
	LeyendaEndoso = ""
	FechaEndoso = {}
	Vendedor = ""
	PagueseA = ""
	Estado = ""
	Accion = 0
	HistorialDetalle = null
	Observacion = ""

	lEnabled = .T.
	oInformacion = null

	*-----------------------------------------------------------------------------------------
	function oInformacion_Access() as Object
		if ( vartype( this.oInformacion ) != "O" or isnull( this.oInformacion ) )
			this.oInformacion = _Screen.zoo.crearobjeto( "zooInformacion", "zooInformacion.prg" )
		endif
		Return this.oInformacion
	endfunc 

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

EndDefine

