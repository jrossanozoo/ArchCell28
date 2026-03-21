#DEFINE CRLF		CHR(13) + CHR(10)
#DEFINE TAB			CHR(9)

Define Class ColaboradorSAP of ColaboradorSAP.prg as zooSession

	#IF .f.
		Local this as ColaboradorSAP of ColaboradorSAP.prg
	#ENDIF

	Protected oServicioSAP, oServicioJson, oTikcetAcceso, oInformacion
	oServicioSAP = Null
	oServicioJson = null
	oTikcetAcceso = null
	cBaseDeDatos = null
	
	*-----------------------------------------------------------------------------------------
	Function oServicioSAP_Access() As Object
		If !This.ldestroy And Vartype( This.oServicioSAP ) # 'O'
			_Screen.Zoo.App.AgregarReferencia( "ZooLogicSA.Interfaz.QuikSilverSAP.dll" )
			This.oServicioSAP = _Screen.Zoo.CrearObjeto( "ZooLogicSA.Interfaz.QuikSilverSAP.InterfaceSAP", "ZooLogicSA.Interfaz.QuikSilverSAP", "c:\dragonfish\bin\sap.ini" )
		Endif
		Return This.oServicioSAP
	Endfunc

	*-----------------------------------------------------------------------------------------
	function oServicioJson_Access() as Object
		if !this.ldestroy and vartype( this.oServicioJson ) # 'O'
			This.oServicioJson = _Screen.Zoo.CrearObjeto( "servicioJson", "ColaboradorSAP.prg" )
		endif
		return This.oServicioJson
	endfunc

	*-----------------------------------------------------------------------------------------
	procedure SetearBaseDeDatos( tcNombreBaseDeDatos as String ) as Void
		if vartype( tcNombreBaseDeDatos ) = "C"
			this.cBaseDeDatos = tcNombreBaseDeDatos
		else
			this.cBaseDeDatos = null
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerInvoice() as Object
		local loRetorno as Object
		loRetorno = createobject( "Invoice" )
		return loRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerPayments() as Object
		local loRetorno as Object
		loRetorno = createobject( "Payments" )
		return loRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerPayOuts() as Object
		local loRetorno as Object
		loRetorno = createobject( "PayOuts" )
		return loRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerItemInvoice() as Void
		local loRetorno as Object
		loRetorno = createobject( "InvoiceItem" )
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerItemAdditional() as Void
		local loRetorno as Object
		loRetorno = createobject( "AdditionalItem" )
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerItemPayments() as Void
		local loRetorno as Object
		loRetorno = createobject( "PaymentsItem" )
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerItemPaymentsInvoice() as Void
		local loRetorno as Object
		loRetorno = createobject( "PaymentItemInvoice" )
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerItemPaymentCard() as Void
		local loRetorno as Object
		loRetorno = createobject( "PaymentsItemCard" )
		return loRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerItemPayOutsCard() as Void
		local loRetorno as Object
		loRetorno = createobject( "PayOutsItemCard" )
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerBussinesPartners() as Void
		local loRetorno as Object
		loRetorno = createobject( "BussinesPartners" )
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerCodigoSituacionFiscal( tnSituacionFiscal as Integer ) as string
		local lcRetorno as String
		do case
		case tnSituacionFiscal = 1
			lcRetorno = "RI"
		case tnSituacionFiscal = 3
			lcRetorno = "CF"
		case tnSituacionFiscal = 4
			lcRetorno = "EX"
		case tnSituacionFiscal = 5
			lcRetorno = "RNI"
		case tnSituacionFiscal = 7
			lcRetorno = "MT"
		otherwise
			lcRetorno = ""
		endcase
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerXMLComprobantes( tcComprobante as String, tcFechaDesde as String, tcFechaHasta as String, tnTipoComprobante as Integer ) as String
		local lcRetorno as String, lcFuncion as String, lcSentencia as String, lcFechaDesde as String, lcFechaHasta as String, loError as Object

		lcRetorno = ""
		this.oInformacion.Limpiar()
		
		try
			lcSentencia = this.ArmarSentencia( "SAP_ObtenerComprobantes", tcComprobante, tcFechaDesde, tcFechaHasta, tnTipoComprobante  )
			lcSentencia = lcSentencia + " order by fletra, fptoven, fnumcomp, nroitem"

			goServicios.Datos.EjecutarSQL( lcSentencia, "c_DatosSAP", this.DataSessionId )
					
			select c_DatosSAP
			lcRetorno = this.CursorAXML( "c_DatosSAP" )
			use in ( "c_DatosSAP" )
		catch to loError
			for each ItemError in loError.UserValue.oInformacion FOXOBJECT 
				this.agregarInformacion( ItemError.cmensaje )
			next
		endtry
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function ObtenerXMLPagos( tcComprobante As String, tcFechaDesde As String, tcFechaHasta As String, tnTipoComprobante As Integer ) As String
		local lcRetorno as String, lcFuncion as String, lcSentencia as String, lcFechaDesde as String, lcFechaHasta as String, loError as Object

		lcRetorno = ""
		this.oInformacion.Limpiar()

		try
			lcSentencia = this.ArmarSentencia( "SAP_ObtenerValoresDePago", tcComprobante, tcFechaDesde, tcFechaHasta, tnTipoComprobante  )
			lcSentencia = lcSentencia + " order by fletra, fptoven, fnumcomp, nroitem"

			goServicios.Datos.EjecutarSQL( lcSentencia, "c_DatosSAP", this.DataSessionId )
					
			select c_DatosSAP
			lcRetorno = this.CursorAXML( "c_DatosSAP" )
			use in ( "c_DatosSAP" )
		catch to loError
			for each ItemError in loError.UserValue.oInformacion FOXOBJECT 
				this.agregarInformacion( ItemError.cmensaje )
			next
		endtry
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerXMLCobros( tcComprobante as String, tcFechaDesde as String, tcFechaHasta as String, tnTipoComprobante as Integer ) as String
		local lcRetorno as String, lcFuncion as String, lcSentencia as String, lcFechaDesde as String, lcFechaHasta as String, loError as Object

		lcRetorno = ""
		this.oInformacion.Limpiar()

		try
			lcSentencia = this.ArmarSentencia( "SAP_ObtenerValoresDeCobro", tcComprobante, tcFechaDesde, tcFechaHasta, tnTipoComprobante  )
			lcSentencia = lcSentencia + " order by fletra, fptoven, fnumcomp, nroitem"

			goServicios.Datos.EjecutarSQL( lcSentencia, "c_DatosSAP", this.DataSessionId )
					
			select c_DatosSAP
			lcRetorno = this.CursorAXML( "c_DatosSAP" )
			use in ( "c_DatosSAP" )
		catch to loError
			for each ItemError in loError.UserValue.oInformacion FOXOBJECT 
				this.agregarInformacion( ItemError.cmensaje )
			next
		endtry
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerXMLClientes( tcComprobante as String, tcFechaDesde as String, tcFechaHasta as String, tnTipoComprobante as Integer ) as String
		local lcRetorno as String, lcFuncion as String, lcSentencia as String, lcFechaDesde as String, lcFechaHasta as String

		lcSentencia = this.ArmarSentencia( "SAP_ObtenerClientes", tcComprobante, tcFechaDesde, tcFechaHasta, tnTipoComprobante  )

		goServicios.Datos.EjecutarSQL( lcSentencia, "c_DatosSAP", this.DataSessionId )
				
		select c_DatosSAP
		lcRetorno = this.CursorAXML( "c_DatosSAP" )
		use in ( "c_DatosSAP" )
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ArmarSentencia( tcFuncionSQL as String,  tcComprobante as String, tcFechaDesde as String, tcFechaHasta as String, tnTipoComprobante as Integer  ) as String
		local lcRetorno as String, lcOrigen as String
		lcOrigen = iif(vartype( this.cBaseDeDatos ) = "C" and !empty(this.cBaseDeDatos), "[DRAGONFISH_" + alltrim(this.cBaseDeDatos)+ "].[Interfaces].[" + tcFuncionSQL + "]", "[Interfaces].[" + tcFuncionSQL + "]")
		if vartype(tcComprobante) = "C" and !empty(tcComprobante)
			lcRetorno = "Select * From "
			lcRetorno = lcRetorno + lcOrigen + "("
			lcRetorno = lcRetorno + "'" + tcComprobante + "',null,null,null)"
		else
			lcRetorno = "Select * From "
			lcRetorno = lcRetorno + lcOrigen + "("
			lcRetorno = lcRetorno + "null,"
			lcRetorno = lcRetorno + "'" + tcFechaDesde +"',"
			lcRetorno = lcRetorno + "'" + tcFechaHasta +"',"
			lcRetorno = lcRetorno + "" + alltrim(str(tnTipoComprobante)) +")"
		endif
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerXMLVentas( tcFechaDesde as String, tcFechaHasta as String, tnComprobanteTipo as Integer ) as Void
		local lcRetorno as String, lcFuncion as String, lcSentencia as String, lcFechaDesde as String, lcFechaHasta as String, lcOrigen as String
		
		lcOrigen = iif(vartype( this.cBaseDeDatos ) = "C", "[DRAGONFISH_" + alltrim(_screen.zoo.app.cSucursalActiva )+ "].[Interfaces].[" + tcFuncionSQL + "]", "[Interfaces]." )

		lcFechaDesde = iif(vartype(tcFechaDesde)="C",tcFechaDesde, dtoc( goServicios.Librerias.ObtenerFecha()-7 ))
		lcFechaHasta = iif(vartype(tcFechaHasta)="C",tcFechaHasta, dtoc( goServicios.Librerias.ObtenerFecha()+1 ))
		
		lcFuncion = lcOrigen + "[SAP_ObtenerComprobantes]( null, " + lcFechaDesde + ", " + lcFechaHasta + ", " + alltrim(str( tnComprobanteTipo )) +  ") " 
		lcSentencia = "Select * From " + lcFuncion + " order by fletra, fptoven, fnumcomp, nroitem"
		
		goServicios.Datos.EjecutarSQL( lcSentencia, "c_DatosSAP", this.DataSessionId )
				
		select c_DatosSAP
		lcRetorno = this.CursorAXML( "c_DatosSAP" )
		use in ( "c_DatosSAP" )
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerXMLValores( tcComprobante as String, tcFechaDesde as String, tcFechaHasta as String, tnTipoComprobante as Integer ) as Void
		local lcRetorno as String, lcFuncion as String, lcSentencia as String, lcFechaDesde as String, lcFechaHasta as String, lcOrigen as String
		lcOrigen = iif(vartype( this.cBaseDeDatos ) = "C", "[DRAGONFISH_" + alltrim(_screen.zoo.app.cSucursalActiva )+ "].[Interfaces].[" + tcFuncionSQL + "]", "[Interfaces]." )
		
		if vartype(tcComprobante) = "C" and !empty(tcComprobante)
			lcSentencia = "Select * From "
			lcSentencia = lcSentencia + lcOrigen + "[SAP_ObtenerValores]("
			lcSentencia = lcSentencia + "'" + tcComprobante + "',null,null,null)"
		else
			lcSentencia = "Select * From "
			lcSentencia = lcSentencia + lcOrigen + "[SAP_ObtenerValores]("
			lcSentencia = lcSentencia + "null,"
			lcSentencia = lcSentencia + "'" + lcFechaDesde +"',"
			lcSentencia = lcSentencia + "'" + tcFechaHasta +"',"
			lcSentencia = lcSentencia + "" + tnTipoComprobante +")"
		endif

		goServicios.Datos.EjecutarSQL( lcSentencia, "c_DatosSAP", this.DataSessionId )
				
		select c_DatosSAP
		lcRetorno = this.CursorAXML( "c_DatosSAP" )
		use in ( "c_DatosSAP" )
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerInformeSAP() as Void
		local loRetorno as Object
		loRetorno = createobject( "InformeSap" )
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ProcesaInterfazMensajeSap() as Boolean
		local llRetorno as Boolean
		llRetorno = .f.
		do case
		case _Screen.Zoo.APP.NOMBREPRODUCTO # "DRAGONFISH"
		case vartype(goParametros)#"O"
		case vartype(goParametros.ColorYTalle)#"O"
		case vartype(goParametros.ColorYTalle.Interfases)#"O"
		case vartype(goParametros.ColorYTalle.Interfases.SAP)#"O"
		case vartype(goParametros.ColorYTalle.Interfases.SAP.HabilitarEquivalenciasErroresInterfazSap)#"L"
		otherwise
			llRetorno = goParametros.ColorYTalle.Interfases.SAP.HabilitarEquivalenciasErroresInterfazSap
		endcase
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerItemInforme() as Object
		local loRetorno as Object
		loRetorno = _screen.zoo.crearobjeto("InformeSAP", "ColaboradorSAP.prg")
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerServicioSAP() as Object
		return this.oServicioSAP
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerServicioJson() as Object
		return this.oServicioJson
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerTicketAcceso( toServicio as Object ) as Void
		return this.oServicioSAP.ObtenerTicketAcceso()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerCabeceraComprobante() as Object
		local loCabecera as Object
		loCabecera = newobject( "ItemComprobante", "ColaboradorSAP.prg" )
		return loCabecera
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerExternalCode( tcEstructuraMensaje as String ) as String
		local lcRetorno as String, lnItem as Integer, lcElemento as String
		lcRetorno = ""
		for lnItem = 1 to  memlines( tcEstructuraMensaje )
			lcElemento = mline(tcEstructuraMensaje,lnItem)
			lcElemento = alltrim(strtran(lcElemento,chr(9),""))
			if left(lcElemento,14) = '"ExternalCode:'
				lcElemento = alltrim(strtran(lcElemento,'"',''))
				lcRetorno = substr(lcElemento,14)
			endif
		next
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function Obtenerinformation( tcEstructuraMensaje as String ) as String
		local lcRetorno as String, lnItem as Integer, lcElemento as String
		lcRetorno = ""
		for lnItem = 1 to  memlines( tcEstructuraMensaje )
			lcElemento = mline( tcEstructuraMensaje,lnItem)
			lcElemento = alltrim(strtran(strtran(lcElemento,chr(9),""),'"',''))
			if left(lcElemento,9) = "DocEntry:" or left(lcElemento,13) = "ExternalCode:"
				loop
			endif
			if !empty(lcElemento)
				lcRetorno = lcElemento
				exit
			endif
		next
		return lcRetorno
	endfunc 

    *-----------------------------------------------------------------------------------------
	protected function LlenarColeccionSentencias( toColOrigen as zoocoleccion OF zoocoleccion.prg, toColDestino as zoocoleccion OF zoocoleccion.prg ) as Void
		local lcItem as String
		for each lcItem in toColOrigen FOXOBJECT
			toColDestino.Agregar( lcItem )
			_Cliptext = _Cliptext + lcItem + chr(13) + chr(10)
		EndFor	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GrabarInconsistencias( toColSentencias as Collection ) as Void
		local lcSentencia as String
		for each lcSentencia in toColSentencias FOXOBJECT
			goServicios.Datos.EjecutarSQL( lcSentencia, .f., this.dataSessionID )
		endfor
	endfunc 


enddefine

*-----------------------------------------------------------------------------------------
* ---------------------------------------- Clases ----------------------------------------
*-----------------------------------------------------------------------------------------

*-----------------------------------------------------------------------------------------
define class Invoice as Custom

	C00U_externalcode = ""
	C01DocDate = {}
	C02DocDateSpecified = .t.
	C03DocDueDate = {}
	C04DocDueDateSpecified = .t.
	C05TaxDate = {}
	C06TaxDateSpecified = .t.

	C07CardCode = ""
	C08PointOfIssueCode = "0025"

	C09Letter = 0
	C10LetterSpecified = .t.

	C11FolioNumberFrom = 140
	C12FolioNumberFromSpecified = .t.
	C13FolioNumberTo = 140
	C14FolioNumberToSpecified = .t.

	C15Comments = ""

	C16DocTotal = 0
	C17DocTotalSpecified = .t.

	C18DiscountPercent = 0.00
	C19DiscountPercentSpecified = .t.
	C20SalesPersonCode = 2
	C21SalesPersonCodeSpecified = .t.	
	
	C22DocumentLines = null
	C23DocumentAdditionalExpenses = null

	*-----------------------------------------------------------------------------------------
	function Init() as Void
		this.C22DocumentLines = _Screen.Zoo.CrearObjeto( "zooColeccion" )
		this.C23DocumentAdditionalExpenses = _Screen.Zoo.CrearObjeto( "zooColeccion" )
	endfunc 

enddefine

*-----------------------------------------------------------------------------------------
define class InvoiceItem as Custom

	C01ItemCode = ""
	C02Quantity = 0
	C03QuantitySpecified =  .t.
	C04WarehouseCode = "01"
	C06PriceAfterVAT = 0
	C07PriceAfterVATSpecified = .t.
	C08TaxCode = "IVA_21"
	C10DiscountPercent = 0.00
	C11DiscountPercentSpecified = .t.
	C12CostingCode = "DC"
	C13CostingCode2 = "ABA1"

enddefine

*-----------------------------------------------------------------------------------------
define class AdditionalItem as Custom

	C01ExpenseCode = ""
	C03DistributionRule2 = ""
	C04LineTotal = 0.00

enddefine

*-----------------------------------------------------------------------------------------
define class Payments as Custom

	C02DocDate = {}
	C03DocDateSpecified = .t.

	C04CardCode = 0
	C05CashAccount = "1.1.010.10.001"

	C06CashSum = 0
	C07CashSumSpecified = .t.
	
	C08PaymentInvoices = null
	
	C09PaymentCreditCards = null
	C10U_ExternalCode = ""
	
	*-----------------------------------------------------------------------------------------
	function Init() as Void
		this.C08PaymentInvoices = _Screen.Zoo.CrearObjeto( "zooColeccion" )
		this.C09PaymentCreditCards = _Screen.Zoo.CrearObjeto( "zooColeccion" )
	endfunc 

enddefine

define class PaymentItemInvoice as Custom


	C01InvoiceType = 0
	C02InvoiceTypeSpecified = .f.
	C03U_ExternalCode = ""

enddefine

*-----------------------------------------------------------------------------------------
define class PaymentsItem as Custom

	C01DocEntry = 0
	C02DocEntrySpecified = .t.
	C03SumApplied = 0
	C04SumAppliedSpecified = .t.

enddefine

*-----------------------------------------------------------------------------------------
define class PaymentsItemChash as Custom

enddefine

*-----------------------------------------------------------------------------------------
define class PaymentsItemCard as Custom

	C01CreditCard = 1
	C02CreditCardSpecified = .t.
	C04CreditCardNumber = ""
	C05CardValidUntil = "12/99"
	C06CardValidUntilSpecified = .t.
	C07VoucherNum =  "1"
	C08PaymentMethodCode = 1
	C09PaymentMethodCodeSpecified = .t.
	C10NumOfPayments = 1
	C11NumOfPaymentsSpecified = .t.
	C12FirstPaymentDue = "2016-10-20"
	C13FirstPaymentDueSpecified = .t.
	C14AdditionalPaymentSum = 0
	C15AdditionalPaymentSumSpecified = .t.
	C16CreditSum = 0
	C17CreditSumSpecified = .t.
	C18CreditCur = "ARS"
	C19NumOfCreditPayments = 1
	C20NumOfCreditPaymentsSpecified = .t.
	C21CreditType = 0
	C22CreditTypeSpecified = .t.
	C23SplitPayments = 0
	C24SplitPaymentsSpecified = .t.

	*-----------------------------------------------------------------------------------------
	function Init() as Void
		dodefault()
		this.C05CardValidUntil = "07/20"
		this.C06CardValidUntilSpecified = .t.
		this.C12FirstPaymentDue = padl(year(date()),4,"0")+"-"+padl(month(date()),2,"0")+"-"+padl(day(date()),2,"0")
	endfunc 

enddefine

*-----------------------------------------------------------------------------------------
define class PayOutsItemCard as Custom

	C01CreditCard = 1
	C02CreditCardSpecified = .t.
	C03CreditAcct = ""
	C04CreditCardNumber = ""
	C05CardValidUntil = "12/99"
	C06CardValidUntilSpecified = .t.
	C07VoucherNum =  "1"
	C08PaymentMethodCode = 1
	C09PaymentMethodCodeSpecified = .t.
	C10NumOfPayments = 1
	C11NumOfPaymentsSpecified = .t.
	C12FirstPaymentDue = "2016-10-20"
	C13FirstPaymentDueSpecified = .t.
	C14AdditionalPaymentSum = 0
	C15AdditionalPaymentSumSpecified = .t.
	C16CreditSum = 0
	C17CreditSumSpecified = .t.
	C18CreditCur = "ARS"
	C19NumOfCreditPayments = 1
	C20NumOfCreditPaymentsSpecified = .t.
	C21CreditType = 0
	C22CreditTypeSpecified = .t.
	C23SplitPayments = 0
	C24SplitPaymentsSpecified = .t.

	*-----------------------------------------------------------------------------------------
	function Init() as Void
		dodefault()
		this.C05CardValidUntil = "07/20"
		this.C06CardValidUntilSpecified = .t.
		this.C12FirstPaymentDue = padl(year(date()),4,"0")+"-"+padl(month(date()),2,"0")+"-"+padl(day(date()),2,"0")
	endfunc 

enddefine

*-----------------------------------------------------------------------------------------
define class PaymentsItemCheck as Custom

enddefine

*-----------------------------------------------------------------------------------------
define class PaymentsItemAccount as Custom

enddefine

*-----------------------------------------------------------------------------------------
define class PayOuts as Custom

	C00DocType = 0
	C01DocTypeSpecified = .t.

	C02DocDate = {}
	C03DocDateSpecified = .t.

	C04CardCode = 0
	C05CashAccount = "1.1.010.10.001"

	C06CashSum = 0
	C07CashSumSpecified = .t.
	
	C08PaymentInvoices = null
	
	C09PaymentCreditCards = null
	C10U_ExternalCode = ""
	
	*-----------------------------------------------------------------------------------------
	function Init() as Void
		this.C08PaymentInvoices = _Screen.Zoo.CrearObjeto( "zooColeccion" )
		this.C09PaymentCreditCards = _Screen.Zoo.CrearObjeto( "zooColeccion" )
	endfunc 

enddefine

*-----------------------------------------------------------------------------------------
define class BussinesPartners as Custom

	C01CardCode = ""
	C02CardName = ""
	C05GroupCode = 106
	C06GroupCodeSpecified = .t.
	C07Currency = "ARS"
	C08U_B1SYS_VATCtg = ""
	C09U_B1SYS_FiscIdType = 0
	C10FederalTaxID = 0

*!*	- Situacion frente al IVA , CF o RI

*!*	"U_B1SYS_VATCtg": "CF",

*!*	Valores posibles:

*!*	RI           Responsable Inscripto
*!*	RNI          Responsable No Inscripto
*!*	MT           Monotributo
*!*	EX           Exento
*!*	NG           No Gravado
*!*	NC           No Categorizado
*!*	CF           Consumidor Final
*!*	 
*!*	- CUIT si es RI o DNI si se carga en Dragon y debe identificarse al cliente en  la factura o NC

*!*	"U_B1SYS_FiscIdType":80,
*!*	"LicTradNum": 27265871297

*!*	Valores posibles:

*!*	80           CUIT
*!*	86           CUIL
*!*	94           Pasaporte
*!*	96           DNI
*!*	87           CDI
*!*	99           Sin Identificacion
*!*	999          CUIT PAIS

enddefine

*-----------------------------------------------------------------------------------------
define class servicioJson as  Session

	function init
	endfunc

	*-----------------------------------------------------------------------------------------
	function Serializar( toObjeto as Collection ) as String
		local lcRetorno as String, loObjeto as Collection
		lcRetorno = ""
		loObjeto = toObjeto
		if vartype( loObjeto ) = "O" and !isnull( loObjeto)
			if lower( loObjeto.baseclass ) = "collection"
				lcRetorno = "["
*!*					for lnItem = 1 to loObjeto.Count
*!*						lcRetorno = lcRetorno + iif(lnItem=1,"","," + CRLF) + this.EstructuraItem( loObjeto[ lnItem ] )
*!*					next
				for each loItem in loObjeto FOXOBJECT
					lcRetorno = lcRetorno + iif(len(lcRetorno)=1,"","," + CRLF) + this.EstructuraItem( loItem )
				next
				lcRetorno = lcRetorno + "]"
			else
				lcRetorno = "[" + this.EstructuraItem( loObjeto ) + "]"
			endif
		endif
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Deserializar( tcTextoJson as String ) as Object

	endfunc

	*-----------------------------------------------------------------------------------------
	protected function EstructuraItem( toObjeto as Object ) as String
		local lcRetorno as String, laPropiedades as Array, lnCantProp as Integer, lnIndProp as Integer
		dimension laPropiedades[1]

		lnCantProp = amembers(laPropiedades,toObjeto,3,"U")
		if lnCantprop > 0 and type( "laPropiedades", 1 ) = "A"
			lcRetorno = "{" + CRLF
			for lnIndProp = 1 to lnCantProp
				lcPropiedad = "toObjeto."+laPropiedades[lnIndProp,1]
				if type( lcPropiedad ) = "O"
					lcRetorno = lcRetorno + TAB + '"' + proper(Alltrim(substr(laPropiedades[lnIndProp,1],4))) + '" :'
					lcRetorno = lcRetorno + this.Coleccion( &lcPropiedad ) + iif(lnIndProp=lnCantProp,'',',') + CRLF
				else
					lcRetorno = lcRetorno + '"' + proper(Alltrim(substr(laPropiedades[lnIndProp,1],4))) + '" :'
					do case
					case type( lcPropiedad ) = "C"
						lcRetorno = lcRetorno + TAB + '"' + Alltrim(Padr(Evaluate(lcPropiedad),100)) + '"'
					case type( lcPropiedad ) = "N"
						lcRetorno = lcRetorno + TAB + Alltrim(Padr(Evaluate(lcPropiedad),100))
					case type( lcPropiedad ) = "T"
						lcRetorno = lcRetorno + TAB + '"' + left(ttoc(Evaluate(lcPropiedad),3),10) + '"'
					case type( lcPropiedad ) = "D"
						lcRetorno = lcRetorno + TAB + '"' + dtoc(Evaluate(lcPropiedad)) + '"'
					case type( lcPropiedad ) = "L"
						lcRetorno = lcRetorno + TAB + iif(Evaluate(lcPropiedad),"true","false")
					endcase
					lcRetorno = lcRetorno +  iif(lnIndProp=lnCantProp,'',',') + CRLF
				endif
			endfor
			lcRetorno = lcRetorno + "}"
		else
			lcRetorno = ""
		endif
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function Coleccion( toObjeto as Collection ) as String
		local lcRetorno as String, loItem as Object, laPropiedades as Array, lnCantProp as Integer, lnIndProp as Integer, loObjeto as Collection
		lcRetorno = ""
		loObjeto = toObjeto
		if vartype( loObjeto ) = "O" and !isnull( loObjeto ) and loObjeto.Count > 0
			for each loItem in loObjeto FOXOBJECT
				if empty(lcRetorno)
					lcRetorno = "[" + CRLF
				else
					lcRetorno = lcRetorno + "," + CRLF
				endif
				lcElemento = this.EstructuraItem( loItem )
				for lnLinea = 1 to memlines( lcElemento )
					lcRetorno = lcRetorno + TAB + TAB + mline( lcElemento, lnLinea ) + CRLF
				next
			endfor
			lcRetorno = lcRetorno + TAB + "]" && + CRLF
		else
			lcRetorno = "[]"
		endif
		return lcRetorno
	endfunc 

enddefine

*-----------------------------------------------------------------------------------------
define class InformeSap as Session

	*-----------------------------------------------------------------------------------------
	function ConvertirContenido( tcContenido as String ) as Object
		local loRetorno as Collection, llNivelDocumento as Integer, lcItem as String, loItem as Object, true as Boolean, false as Boolean, lnTope as Integer, loError as Object
		true = .t.
		false = .f.
		llNivelDocumento = 0
		loRetorno = createobject( "collection" )
		try
			do while !empty( tcContenido )
				do case
				case left( tcContenido, 1) = "["
					llNivelDocumento = llNivelDocumento + 1
					tcContenido = substr( tcContenido, 2)
				case left( tcContenido, 1) = "]"
					llNivelDocumento = llNivelDocumento - 1
					tcContenido = substr( tcContenido, 2)
				case at( "{", tcContenido, 1) > 0 and at( "}", tcContenido, 1) > 0 and at( "{", tcContenido, 1) < at( "}", tcContenido, 1)
					lcItem = substr( tcContenido, at( "{", tcContenido, 1), at( "}", tcContenido, 1) - at( "{", tcContenido, 1) + 1 )
					tcContenido = substr( tcContenido, at( "}", tcContenido, 1) + 1)
					if left( tcContenido, 1) = ","
						tcContenido = substr( tcContenido, 2)
					endif
					loItem = newobject( "ItemSap", "ColaboradorSap.prg" )
					do while !empty( lcItem )
						do case
						case left( lcItem , 8) = '{"Code":'
							lcItem = substr( lcItem,9)
							loItem.Code = evaluate( left( lcItem, at( ",", lcItem) - 1))
							lcItem = substr( lcItem, at( ",", lcItem) + 1)
						case lcItem== '},' or lcItem== '}'
							lcItem= ""
						case left( lcItem, 14) = '"Description":'
							lcItem = substr( lcItem,15)
							do while !empty(lcItem) or left( lcItem, 2) # '],'
								do case
								case left(lcItem,1) = '['
									lcItem= substr( lcItem, 2)
								case left(lcItem,2) = '],'
									lcItem= substr( lcItem, 3)
									exit
								case at( ',', lcItem, 1 ) > 0 or at( '],', lcItem, 1 ) > 0
									lnTope = iif(at( ',', lcItem, 1 )>0 and at( ',', lcItem, 1 )<at( '],', lcItem, 1 ),at( ',', lcItem, 1 ),at( '],', lcItem, 1 ))
									loItem.Description.Add( left(lcItem, lnTope -1 ))
									lcItem = substr( lcItem, at( ',', lcItem, 1 ) + iif(substr(lcitem,lnTope,1)=",",1,-1))
								case at( ']', lcItem, 1 ) > 0
									loItem.Description.Add( left( lcItem, at( ']', lcItem, 1 ) -1 ))
									lcItem = substr( lcItem, at( ']', lcItem, 1 ) +1)
								endcase
							enddo
						case left( lcItem , 10) = '"IsError":'
							loItem.IsError = evaluate( substr(lcItem,11,at("}",lcItem)-11))
							lcItem = substr( lcItem, at( "}", lcItem) + 1)
						endcase
					enddo
					loRetorno.Add( loItem )
				endcase
			enddo
		catch to loError
			loEntorno = null
			goServicios.Errores.LevantarExcepcion( "Error al obtener informacion del servidor SAP" )
		endtry
		return loRetorno
	endfunc

enddefine

*-----------------------------------------------------------------------------------------
define class ItemSap as Session

	Code = 0
	Description = null
	IsError = .f.
	
	*-----------------------------------------------------------------------------------------
	function Init
		dodefault()
		this.Description = createobject( "collection" )
	endfunc 

enddefine

*-----------------------------------------------------------------------------------------
define class InformeSAP as Session

	ExternalCode = ""
	Codigo = 0
	Descripcion = ""
	Informacion = ""
	Detalle = ""

enddefine

*-----------------------------------------------------------------------------------------
define class ItemComprobante as Custom

	Codigo = ""
	Letra = ""
	PuntoDeVenta = 0
	NumeroDeComprobante = 0
	Fecha = {}

enddefine
