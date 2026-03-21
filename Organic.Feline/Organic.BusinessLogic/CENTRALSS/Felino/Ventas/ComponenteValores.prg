define class ComponenteValores as Din_ComponenteValores of Din_ComponenteValores.prg

	#if .f.
		Local this as ComponenteValores as ComponenteValores.prg
	#endif

	cNombre = "VALORES"

	*-----------------------------------------------------------------------------------------
	function Grabar() as ZooColeccion of ZooColeccion.prg
		local loError as Exception, loEx as Exception, loRetorno as zoocoleccion OF zoocoleccion.prg

		Try
			This.SetearAtributosDeLaCaja()
			loRetorno = goCaja.Grabar()
		Catch To loError
			loEx = Newobject( "ZooException", "ZooException.prg" )
			With loEx
				.Grabar( loError )
				.Throw()
			EndWith
		Finally
			with goCaja
				.oDetalleAnterior = Null
				.oDetallePadre = Null
				.oEntidadPadre = Null
			Endwith
		endtry 
		return loRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function SetearAtributosDeLaCaja() as Void
		local lcSecuencia as String, lcLetra as String
		with goCaja
			.oDetalleAnterior = This.oDetalleAnterior
			.oDetallePadre = This.oDetallePadre
			.oEntidadPadre = This.oEntidadPadre
			.nSignoDeMovimiento = This.oEntidadPadre.SignoDeMovimiento
			.nSignoDeMovimientoAnterior = This.oEntidadPadre.nSignoDeMovimientoAnterior
			.nVueltoAnterior = This.oEntidadPadre.nVueltoAnteriorCotizado
			.cCodigoVueltoAnterior = This.oEntidadPadre.cCodigoVueltoAnterior
			.nVueltoCotizado = This.oEntidadPadre.nVueltoCotizado
			lcSecuencia = iif( pemstatus( this.oEntidadPadre, "Secuencia", 5 ), This.oEntidadPadre.Secuencia, "" )
			lcLetra = this.ObtenerLetraDelComprobante()
			.SetearDatosComprobante( This.oEntidadPadre.TipoComprobante, This.oEntidadPadre.Fecha, lcLetra, This.oEntidadPadre.Numero, This.oEntidadPadre.PuntoDeVenta, lcSecuencia)
			.cComponenteAsociado = this.cNombre 
			
		EndWith
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerLetraDelComprobante() as String
		local lcRetorno as String
		
		lcRetorno = ""
		if inlist( this.oEntidadPadre.TipoComprobante, 8, 9, 10 ) and this.oEntidadPadre.nPais = 3
			lcRetorno = iif( this.oEntidadPadre.Proveedor.SituacionFiscal_pk = 1, "A", "B" )
		else
			lcRetorno = this.oEntidadPadre.Letra
		endif
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Recibir( toEntidad as Object, tcAtributoDetalle as String, tcCursorDetalle as String, tcCursorCabecera as String ) as Void	
		goCaja.cComponenteAsociado = this.cNombre 
		goCaja.Recibir( toEntidad, tcAtributoDetalle, tcCursorDetalle, tcCursorCabecera )
	endfunc

	*-----------------------------------------------------------------------------------------
	function RecalcularTotales( toItem as ItemValoresVenta.prg of ItemValoresVenta.prg ) as Void
		
		if pemstatus( toItem, "DescuentoPorcentaje", 5) 
			if toItem.DescuentoPorcentaje = 0 
				if toItem.lUsaDescuentosYRecargos
					toItem.llPuedeEntrar = .T.
					toItem.CalcularDescuentoItemActivo()
				endif
				toItem.CalcularRecargoItemActivo()
			else
				toItem.CalcularRecargoItemActivo()
				if toItem.lUsaDescuentosYRecargos
					toItem.llPuedeEntrar = .T.
					toItem.CalcularDescuentoItemActivo()
				endif
			endif
		else
			if toItem.lUsaDescuentosYRecargos
				toItem.llPuedeEntrar = .T.
				toItem.CalcularDescuentoItemActivo()
			endif
			toItem.CalcularRecargoItemActivo()
		endif
			
	endfunc	
	
	*-----------------------------------------------------------------------------------------
	function AplicarRecargoDirecto( toItem as ItemValoresVenta.prg of ItemValoresVenta.prg ) as Void
		if pemstatus( toItem, "condiciondepago_pk", 5 )
			if pemstatus( toItem, "PorcentajeDiferenciaRedondeoRecibido", 5 ) and alltrim( upper( toItem.oEntidad.cNombre ) ) != "RECIBO"
				if empty( toitem.condiciondepago_pk ) and empty( toItem.PorcentajeDiferenciaRedondeoRecibido )
					toItem.RecargoPorcentaje = 0
				endif
			else
				if empty( toitem.condiciondepago_pk )
					toItem.RecargoPorcentaje = 0
				endif
			endif
		else
			toItem.RecargoPorcentaje = 0
		endif
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function DebeCalcularRecargo( toItem as ItemValoresVenta.prg of ItemValoresVenta.prg, toValor as Ent_Valor of Ent_Valor.prg ) as Void
	endfunc 	

	*-----------------------------------------------------------------------------------------
	protected function ValidarEntidad() as boolean
		local llOk as Boolean
		if pemstatus( this.oEntidadPadre, "cComprobante", 5 ) and type( "this.oEntidadPadre.cComprobante" ) = "C"
			llOk = inlist( this.oEntidadPadre.cComprobante, "FACTURA", "NOTADECREDITO", "NOTADEDEBITO", ;
				"TICKETFACTURA", "TICKETNOTADECREDITO", "TICKETNOTADEDEBITO", ;
				"FACTURAELECTRONICA", "NOTADECREDITOELECTRONICA", "NOTADEDEBITOELECTRONICA", ;
				"FACTURADEEXPORTACION", "NOTADECREDITODEEXPORTACION", "NOTADEDEBITODEEXPORTACION", ;
				"FACTURAELECTRONICAEXPORTACION", "NOTADECREDITOELECTRONICAEXPORTACION", "NOTADEDEBITOELECTRONICAEXPORTACION", ;
				"CANJEDECUPONES", "RECIBO", "FACTURAELECTRONICADECREDITO" )
		else
			llOk = .f.
		endif
		return llOk
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AsignarMontoORecibido( toItem as ItemValores of ItemValores.prg, tnMonto as Double) as Void
		if toItem.lTieneImporteEnRecibido && pemstatus( toItem, "Recibido", 5) and type( "toItem.Recibido" ) = "N"
			toItem.Recibido = tnMonto
		else
			toItem.Monto = tnMonto
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerMontoORecibido( toItem as ItemValores of ItemValores.prg ) as Money
		local lnRetorno
		if toItem.lTieneImporteEnRecibido && pemstatus( toItem, "Recibido", 5 ) and type( "toItem.Recibido" ) = "N"
			lnRetorno = toItem.Recibido
		else
			lnRetorno = toItem.Monto
		endif
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AsignarTotalORecibido( toItem as ItemValores of ItemValores.prg, tnTotal as Double) as Void
		if toItem.lTieneImporteEnRecibido && pemstatus( toItem, "Recibido", 5) and type( "toItem.Recibido" ) = "N"
			toItem.Recibido = tnTotal
		else
			toItem.Total = tnTotal
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerTotalORecibido( toItem as ItemValores of ItemValores.prg ) as Money
		local lnRetorno
		if toItem.lTieneImporteEnRecibido && pemstatus( toItem, "Recibido", 5 ) and type( "toItem.Recibido" ) = "N"
			lnRetorno = toItem.Recibido
		else
			lnRetorno = toItem.Total
		endif
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function VerificarContextoEntidadPadre( tcContexto as String ) as boolean
		local llRetorno as boolean
		llRetorno = .f.
		if type( "this.oEntidadPadre" ) = "O" and !isnull( this.oEntidadPadre)
			llRetorno = This.oEntidadPadre.VerificarContexto( tcContexto )
		endif
		return llRetorno
	endfunc 

enddefine
