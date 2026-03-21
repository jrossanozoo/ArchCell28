Define Class ColaboradorComprobantesDeVenta as zooColaborador Of zooColaborador.prg 

	#IF .f.
		Local this as ColaboradorComprobantesDeVenta of ColaboradorComprobantesDeVenta.prg
	#ENDIF

	Protected oComprobante
	oComprobante = null
	
	Protected Estado
	Estado = 0
	
	#define SINESTADO	0
	#define GENERADA	1
	#define NOGENERADA	2
	
	oEntidad = null
	lResultadoEventoKontrolerDescuento = .f.
	cCodigoDeValorSugeridoParaVuelto = ""
	cCodigoValorUtilizadoAlFinalizarElComprobante = ""
	lEsNCPorCorreccionDeAlicuotaGiftCard = .f.

	*-----------------------------------------------------------------------------------------
	function InyectarEntidad( toEntidad as Object ) as Void
		this.oEntidad = toEntidad
	endfunc 

	*-----------------------------------------------------------------------------------------
	function oComprobante_Access()
		if !this.ldestroy and ( !vartype( this.oComprobante ) = 'O' or isnull( this.oComprobante ) or this.oComprobante.cNombre != this.ObtenerNombreEntidadNC() )
			this.oComprobante = _Screen.Zoo.InstanciarEntidad( this.ObtenerNombreEntidadNC() )
			bindevent( this.oComprobante, "EventoPreguntarSiAplicaDescuento", this, "EventoPreguntarSiAplicaDescuento" )
		endif
		return this.oComprobante 
	endfunc

	*-----------------------------------------------------------------------------------------
	function cCodigoDeValorSugeridoParaVuelto_Access()
		if !this.ldestroy and empty( this.cCodigoDeValorSugeridoParaVuelto )
			this.cCodigoDeValorSugeridoParaVuelto = alltrim( goParametros.Felino.Sugerencias.CodigoDeValorSugeridoParaVuelto )
		endif
		return this.cCodigoDeValorSugeridoParaVuelto
	endfunc

	*-----------------------------------------------------------------------------------------
	function cCodigoValorUtilizadoAlFinalizarElComprobante_Access()
		if !this.ldestroy and empty( this.cCodigoValorUtilizadoAlFinalizarElComprobante )
			this.cCodigoValorUtilizadoAlFinalizarElComprobante = alltrim( goParametros.Felino.Sugerencias.CodigoValorUtilizadoAlFinalizarElComprobante )
		endif
		return this.cCodigoValorUtilizadoAlFinalizarElComprobante
	endfunc

	*-----------------------------------------------------------------------------------------
	function Destroy()
		Dodefault()
		If Type("this.oComprobante") = "O"
			If Pemstatus( this.oComprobante, "release", 5)
				this.oComprobante.Release()
			Endif
			this.oComprobante = null
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerCodigoComprobante() as string
		Return this.oComprobante.Codigo
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function ObtenerDescripcionComprobante() as String
		Return this.oComprobante.cDescripcion
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerNumeracionComprobanteRelacionado() as Integer
		Return this.oComprobante.NumeroCpteRelacionado
	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerTotalComprobanteGenerado() as Double
		return this.oComprobante.Total
	endfunc

	*-----------------------------------------------------------------------------------------
	Function ObtenerComprobanteGenerado() as String
		Local lcRetorno as String
		with this.oComprobante
			lcRetorno = .Letra + " " + padl( transform( .PuntoDeVenta ), 4, "0" ) + "-" + padl( transform( .Numero ), 8, "0" )
		endwith
		Return lcRetorno
	EndFunc 

	*-----------------------------------------------------------------------------------------
	function EventoPreguntarSiAplicaDescuento( tnInteraccion as Integer, tnMonto as float, tnPorcentaje as float, tcDescuento as String ) as Void
		this.oComprobante.oCompDescuentos.lAplicarDescuento	= this.lResultadoEventoKontrolerDescuento
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarNCPorCorreccionDeAlicuotaGiftCard( toComprobante as Object ) as Boolean
		Local llRetorno as Boolean, loComprobante as Object, loItem as Object, lcComprobante as String, ;
			loError as Object, llNoValidarsaldo as Boolean

		this.InyectarEntidad( toComprobante )
		this.lResultadoEventoKontrolerDescuento = toComprobante.oCompDescuentos.lAplicarDescuento	
		this.lEsNCPorCorreccionDeAlicuotaGiftCard = .t.
		llRetorno = .f.
		this.Estado = SINESTADO

		try
			if this.oComprobante.EsNuevo()
				this.oComprobante.Cancelar()
			endif

			this.oInformacion.Limpiar()
			loComprobante = this.oComprobante
			with loComprobante
				.Nuevo()

				.lForzarAccionCancelatoria = ( toComprobante.Total = 0 )
				&& Se debería comportar como una accion cancelatoria y se deben calcular IIBB
				&& ver DebeCalcularIIBBCabaSegunCorrespondePorNormativaAGIP en ComponenteImpuestosVentas
				
				this.CargarCabecera( loComprobante, toComprobante )
				
				this.CargarDetalle( loComprobante, toComprobante )

				this.CargarPie( loComprobante, toComprobante )

				this.CargarValores( loComprobante, toComprobante )
				
				lcComprobante = toComprobante.letra + " " + Padl( Transform( toComprobante.PuntoDeVenta ), 4, "0") + "-" + Padl( Transform( toComprobante.Numero ), 8, "0" )
			 	.zadsfw = .zadsfw + "Comprobante generado por la " + toComprobante.cDescripcion + " Nº " + lcComprobante + " - Motivo: Alícuota negativa por diferencia de I.V.A. en giftcard."
			 	
				if pemstatus( loComprobante, "lPedirCAE", 5 )
					.lPedirCAE = .f.
				endif
			 	
				lNoValidarsaldo = goCaja.oCajasaldos.lNoVerificarCaja
				goCaja.oCajasaldos.lNoVerificarCaja = .t.
				
			 	.Grabar()
			 	
				goCaja.oCajasaldos.lNoVerificarCaja = lNoValidarsaldo
				
				if pemstatus( loComprobante, "lPedirCAE", 5 )
					.lPedirCAE = iif( loComprobante.lModoCaeaActivado, .f., .t. )
				endif
				
				this.Estado = GENERADA
				llRetorno = .t.
			endwith
			
		catch To loError
			this.Estado = NOGENERADA
			llRetorno = .f.

			if type( "loerror" ) = "O" and type( "loerror.uservalue" ) = "O" and type( "loerror.uservalue.oinformacion" ) = "O" and lower( loError.uservalue.oInformacion.class ) = "zooinformacion" and type( "loerror.uservalue.oinformacion.count" ) = "N"
				for each loItem in loError.uservalue.oInformacion
					this.oInformacion.AgregarInformacion( loItem.cMensaje )
				next
				if loError.userValue.oInformacion.Count > 1
					lcMensaje = "Han ocurrido errores al intentar generar una nota de crédito."
				else
					lcMensaje = "Ha ocurrido un error al intentar generar una nota de crédito."
				endif
				this.oInformacion.AgregarInformacion( lcMensaje )
			Endif

			goServicios.Errores.LevantarExcepcion( this.oInformacion )
		finally
			this.lEsNCPorCorreccionDeAlicuotaGiftCard = .f.
		endtry
		
		Return llRetorno 
	endfunc 

	*-----------------------------------------------------------------------------------------
	Protected Function CargarCabecera( toComprobanteDestino as ent_ComprobanteDeVentasConValores of ent_ComprobanteDeVentasConValores.prg, toComprobanteOrigen as ent_ComprobanteDeVentasConValores of ent_ComprobanteDeVentasConValores.prg ) as Void
		
		With toComprobanteDestino
				.Cliente_pk = toComprobanteOrigen.Cliente_pk
				If !Empty( toComprobanteOrigen.Vendedor_pk )
					.Vendedor_pk = toComprobanteOrigen.Vendedor_pk
				Endif
				.ListaDePrecios_pk = toComprobanteOrigen.ListaDePrecios_pk
				if toComprobanteDestino.DebePedirDatosAdicionalesComprobantesA()
					toComprobanteDestino.oCompDatosAdicionalesComprobantesA.oFormularioDatosAdicionales.oEntidad = toComprobanteOrigen.oCompDatosAdicionalesComprobantesA.oFormularioDatosAdicionales.oEntidad
				endif				
				
				if goParametros.Felino.GestionDeVentas.HabilitaComprobanteAsociado
					.LetraCpteRelacionado = toComprobanteOrigen.Letra
					.PuntoDeVentaCpteRelacionado  = toComprobanteOrigen.PuntoDeVenta
					.NumeroCpteRelacionado = toComprobanteOrigen.Numero
					.TipoCpteRelacionado = toComprobanteDestino.ObtenerTipoCpteRelacionado( toComprobanteOrigen.TipoComprobante )
					.FechaCpteRelacionado = toComprobanteOrigen.Fecha
				endif		             
		Endwith
	EndFunc 

	*-----------------------------------------------------------------------------------------
	Protected Function CargarDetalle( toComprobanteDestino as ent_ComprobanteDeVentasConValores of ent_ComprobanteDeVentasConValores.prg, toComprobanteOrigen as ent_ComprobanteDeVentasConValores of ent_ComprobanteDeVentasConValores.prg, tcCondicion as String ) as Void
		Local loItem as Object, llAsignacionDePrecio as Boolean
		
		With toComprobanteDestino
			For Each loItem In toComprobanteOrigen.FacturaDetalle
				If this.CondicionDelItemParaCargarDetalle( loItem )
					With .FacturaDetalle
						.oItem.Limpiar()
						.oItem.Articulo_pk = loItem.Articulo_pk
						.oItem.Color_PK = loItem.Color_PK
						.oItem.Talle_PK = loItem.Talle_PK
						.oItem.Cantidad = loItem.Cantidad * (-1)
						llAsignacionDePrecio = .oItem.lEstaAsignadoPrecio
						.oItem.lEstaAsignadoPrecio = .t.
						.oItem.Precio = loItem.Precio
						.oItem.Descuento = loItem.Descuento
						.oItem.MontoDescuento = loItem.MontoDescuento
						.oItem.lEstaAsignadoPrecio = llAsignacionDePrecio 
						.oItem.IDSeniaCancelada = loItem.IDSeniaCancelada
						.oItem.NumeroGiftCard_PK = loItem.NumeroGiftCard_PK
						.oItem.ArticuloDetalle = loItem.ArticuloDetalle
						.Actualizar()
					Endwith
				Endif
			Endfor
		Endwith
	EndFunc 

	*-----------------------------------------------------------------------------------------
	protected function CondicionDelItemParaCargarDetalle( toItem as Object ) as Boolean
		local llRetorno as Boolean
		llRetorno = ( toItem.Cantidad < 0 )
		if this.lEsNCPorCorreccionDeAlicuotaGiftCard
			llRetorno = llRetorno and !empty( toItem.NumeroGiftCard_PK )
		endif
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	Protected Function CargarPie( toComprobanteDestino as ent_ComprobanteDeVentasConValores of ent_ComprobanteDeVentasConValores.prg, toComprobanteOrigen as ent_ComprobanteDeVentasConValores of ent_ComprobanteDeVentasConValores.prg ) as Void
	EndFunc 

	*-----------------------------------------------------------------------------------------
	Protected Function CargarValores( toComprobanteDestino as ent_ComprobanteDeVentasConValores of ent_ComprobanteDeVentasConValores.prg, toComprobanteOrigen as ent_ComprobanteDeVentasConValores of ent_ComprobanteDeVentasConValores.prg ) as Void
		
		With toComprobanteDestino
				With .ValoresDetalle
					.Limpiar()
					.oItem.Valor_pk = this.cCodigoValorUtilizadoAlFinalizarElComprobante
					.oItem.Valordetalle = .oItem.Valor.descripcion 
					.oItem.Monto = toComprobanteDestino.total
					.Actualizar()
				Endwith
		Endwith
	endfunc

	*-----------------------------------------------------------------------------------------
	Function AjustarValoresDelComprobante( toComprobante as Object ) as Boolean
		Local llRetorno as Boolean, loItem as Object, loError as Object  
		llRetorno = .t.
		Try
			With toComprobante.ValoresDetalle
				.limpiarItem()
				.oItem.Valor_pk = this.cCodigoDeValorSugeridoParaVuelto
				.oItem.ValorDetalle = .oItem.Valor.Descripcion 
				.actualizar()
			Endwith
		Catch To loError
			llRetorno = .f.
		Endtry
		Return llRetorno			
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function CompletarAccionesDeSistemas(  toComprobante as Object, tcMotivo as String ) as Void
		Local lcString as String, lcMotivo as String
		lcMotivo = iif( type( "tcMotivo" ) = "C", tcMotivo, "" )
		lcString = "Se generó la " + this.ObtenerDescripcionComprobante() + " Nº " + this.ObtenerComprobanteGenerado()
		toComprobante.ZADSFW = lcString + lcMotivo
	endfunc

	*-----------------------------------------------------------------------------------------
	function ActualizarNumeracionComprobanteRelacionado( tcCodigo as String , toComprobante as object ) as Void
		local lcCursor as String, lcFrom as String, lcConsulta as String, lcMotivo as String

		lcCursor = sys(2015)
	    
	    lcMotivo = iif( toComprobante.lGeneroNCPorCorreccionDeAlicuotaGiftCard, " - Motivo: Alícuota negativa por diferencia de I.V.A. en giftcard ", " - Motivo: Devolución " )
	    lcComprobante = toComprobante.letra + " " + Padl( Transform( toComprobante.PuntoDeVenta ), 4, "0" ) + "-" + Padl( Transform( toComprobante.numero ), 8, "0" )
		lcInfoAdicional = "Comprobante generado por la " + alltrim( toComprobante.cdescripcion ) + " Nº " + lcComprobante + lcMotivo
	    
		lcFrom = "[" + alltrim( _screen.zoo.app.ObtenerPrefijoDB() + _screen.zoo.app.cSucursalActiva ) + "]."
		lcFrom = lcFrom + "[" + alltrim( _screen.zoo.app.cSchemaDefault ) + "]." + "[" + "comprobantev" + "] "
		lcConsulta = "UPDATE " + lcFrom + " set numerorela = " + alltrim(str( toComprobante.numero )) + ",zadsfw ='" + alltrim(lcInfoAdicional) + "' where CODIGO = '" + alltrim( tccodigo ) + "'"
		goServicios.Datos.EjecutarSentencias( lcConsulta, "", "", lcCursor, set( "Datasession" ) )
		
		use in select(lcCursor)
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerNombreEntidadNC() as String
		local lcRetorno as String
		do case
			case this.oEntidad.cNombre == "FACTURA"
				lcRetorno = "NOTADECREDITO"
			case this.oEntidad.cNombre == "FACTURAAGRUPADA"
				lcRetorno = "NOTADECREDITOAGRUPADA"
			case this.oEntidad.cNombre == "TICKETFACTURA"
				lcRetorno = "TICKETNOTADECREDITO"
			case this.oEntidad.cNombre == "FACTURAELECTRONICA"
				lcRetorno = "NOTADECREDITOELECTRONICA"
			case this.oEntidad.cNombre == "FACTURAELECTRONICADECREDITO"
				lcRetorno = "NOTADECREDITOELECTRONICADECREDITO"
			case this.oEntidad.cNombre == "FACTURADEEXPORTACION"
				lcRetorno = "NOTADECREDITODEEXPORTACION"
			case this.oEntidad.cNombre == "FACTURAELECTRONICAEXPORTACION"
				lcRetorno = "NOTADECREDITOELECTRONICAEXPORTACION"
			otherwise
				lcRetorno = "NOTADECREDITO"
		endcase
		return lcRetorno
	endfunc 

Enddefine
