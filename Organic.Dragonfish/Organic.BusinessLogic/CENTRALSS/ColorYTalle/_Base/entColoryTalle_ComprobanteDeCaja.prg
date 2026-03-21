define class EntColorYTalle_ComprobanteDeCaja as ent_comprobantedecaja of ent_comprobantedecaja.prg

	#if .f.
		local this as EntColorYTalle_ComprobanteDeCaja of EntColorYTalle_ComprobanteDeCaja.prg
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
	#define TIPOVALORAJUSTEDECUPON  		10

	#define TIPOMOVIMIENTONODEFINIDO 		0
	#define TIPOMOVIMIENTOENTRADA			1
	#define TIPOMOVIMIENTOSALIDA			2
	#define ESTADOINGRESADO					1
	#define ESTADOSELECCIONADO				2
*!*		#include valores.h   <--
	#define PRECISIONMONTOS        			4
	#define ENVIADO "ENVIA"

	*-----------------------------------------------------------------------------------------
	protected function ObtenerSelectParaPreparacionDeCursores()	 as String
		local lcSql as String
		lcSql = "select 'Fecha' as Fecha_E,	Fecha as Fecha_D, " + ;
					" 'Origen/Destino' as OrigDest_E, "  + ;
					"alltrim( OrigenDestino ) + ' - ' + '" + alltrim( this.OrigenDestino.Descripcion ) + "' as OrigDest_D, " + ;
					"'Tipo'	as Tipo_E, " + ;
					"iif( Tipo = " + +alltrim(str(TIPOMOVIMIENTOENTRADA)) + ", 'ENTRADA', 'SALIDA' ) as Tipo_D, " + ;
					"'Número' as numero_E," + ;
					" Numero as numero_D, " + ;
					"'Concepto' as concepto_E, " + ;
					"alltrim( Concepto ) + ' - ' + '" + alltrim( this.Concepto.Descripcion ) + "' as Concepto_D, " + ;
					"'Vendedor' as Vendedor_E, " + ;
					"alltrim( Vendedor ) + ' - ' + '" + alltrim( this.Vendedor.Nombre ) + "' as Vendedor_D " + ;
			 	"from C_RepoTemp into cursor C_Repo"
		return lcSql
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function PuedeGenerarValorEnTransito() as Boolean
		Local llRetorno as Boolean, lcMensaje as String
		llRetorno = .t.

		if !this.EsComprobanteDeSalida()
			llRetorno = .f.
		endif
		if this.ExistenChequesDeTercerosConCircuitoDeEstados()
			if !this.EsConceptoEnviado()
				llRetorno = .f.
			endif
		endif
		if !llRetorno
			if this.oInformacion.Count > 1
				lcMensaje = 'Existen errores que no permiten enviar el comprobante como valores en tránsito'
				this.oInformacion.AgregarInformacion( lcMensaje )
			endif
			this.oMensaje.Alertar( this.oInformacion )
			this.oInformacion.Limpiar()
		endif
		Return llRetorno
	EndFunc 

	*-----------------------------------------------------------------------------------------
	Protected function ObtenerEstadoDeConcepto() as String
		local lcRetorno as String
		lcRetorno = iif( !empty(this.Concepto_pk),this.Concepto.EstadoCheque,"")
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	Protected Function EsComprobanteDeSalida() as Boolean
		Local llRetorno as Boolean, lcMensaje as String
		llRetorno = this.Tipo == TIPOMOVIMIENTOSALIDA
		if !llRetorno
			lcMensaje = 'Para poder enviar un comprobante de caja como valores en tránsito el "Tipo" debe ser de "Salida"'
			this.oInformacion.AgregarInformacion( lcMensaje )
		endif
		Return llRetorno
	EndFunc 

	*-----------------------------------------------------------------------------------------
	Protected Function EsConceptoEnviado() as Boolean && SiTieneCheques() as Boolean
		Local llRetorno as Boolean, lcEstado as String, llTieneChequesDeCircuito as Boolean, lcMensaje as String
		lcEstado = this.ObtenerEstadoDeConcepto()
		llRetorno = !empty(lcEstado) and lcEstado == ENVIADO
		if !llRetorno
			lcMensaje = 'Para poder enviar un comprobante de caja con cheques de terceros como valores en tránsito, debe seleccionar un "Concepto" cuyo estado sea "Enviado"'
			this.oInformacion.AgregarInformacion( lcMensaje )
		endif
		Return llRetorno
	EndFunc 

	*--------------------------------------------------------------------------------------------------------
	function VotacionCambioEstadoELIMINAR( tcEstado as string ) as Boolean
		local llRetorno as boolean
		llRetorno = dodefault() and !this.EsComprobanteGeneradoPorAceptacionDeValoresEnTransito()
		return llRetorno
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function VotacionCambioEstadoMODIFICAR( tcEstado as string ) as Boolean
		local llRetorno as boolean
		llRetorno = dodefault() and !this.EsComprobanteGeneradoPorAceptacionDeValoresEnTransito()
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function EsComprobanteGeneradoPorAceptacionDeValoresEnTransito() as Boolean
		local llRetorno as Boolean, loColaborador as Object
		loColaborador = _Screen.Zoo.App.CrearObjeto( "ColaboradorCheques" )
		llRetorno = loColaborador.EsComprobanteDeCajaGeneradoPorAceptacionDeValoresEnTransito( this )
		if llRetorno
			this.AgregarInformacion( "No se puede realizar la operación ya que el comprobante fué generado por la aceptación de valores en tránsito." )
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ExistenChequesDeTercerosConCircuitoDeEstados() as Boolean
		local llRetorno as boolean, loDetalle as Object, loItem as Object
		llRetorno = .f.
		loDetalle = this.ObtenerDetalleDeValores()
		for each loItem in loDetalle FOXOBJECT
			if loItem.Tipo = TIPOVALORCIRCUITOCHEQUETERCERO
				llRetorno = .t.
				exit
			endif
		next
		return llRetorno
	endfunc 

enddefine
