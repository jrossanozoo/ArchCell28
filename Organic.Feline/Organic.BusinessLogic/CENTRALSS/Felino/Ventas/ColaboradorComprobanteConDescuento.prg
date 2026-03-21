define class ColaboradorComprobanteConDescuento as ColaboradorComprobanteConValores of ColaboradorComprobanteConValores.prg

	#IF .f.
		Local this as ColaboradorComprobanteConDescuento of ColaboradorComprobanteConDescuento.prg
	#ENDIF

	oComprobante = null
	
	*-----------------------------------------------------------------------------------------
	function oComprobante_Access() as Object
		if this.lDestroy
		else
			if ( !vartype( this.oComprobante ) = 'O' or isnull( this.oComprobante ) )
				this.oComprobante = goServicios.Formularios.Procesar( alltrim( goParametros.Felino.GestionDeVentas.Recibo.Descuento.TipoDeComprobante ) )	
			endif
		endif
		return this.oComprobante 
	endfunc

	*-----------------------------------------------------------------------------------------	
	function GenerarComprobantePorDescuento( tcCliente as string, tnMonto as Integer, tcComprobante as String, toComprobanteAsociado as object ) as VOID 
		local loComprobante as Object, loError as Object, lnMonto as Double, llParametroDesgloceEnPrecio as Boolean
		llParametroDesgloceEnPrecio = goParametros.Felino.GestionDeVentas.Minorista.PermitirIngresarMontoDeSenaEnFacturasAIVAIncluido
		goParametros.Felino.GestionDeVentas.Minorista.PermitirIngresarMontoDeSenaEnFacturasAIVAIncluido = .f.
		loComprobante = this.oComprobante.oEntidad
		this.oComprobante.oEntidad.lIgnorarCamposObligatoriosDefinidosPorUsuario = .T.
		if loComprobante.EsNuevo()
			loComprobante.Cancelar()
		endif
		with loComprobante
			.nuevo()
			if pemstatus( loComprobante, "SetearCargaDeSeniasPendientes", 5 )
				.SetearCargaDeSeniasPendientes( .f. )
			endif
			.cliente_pk = tcCliente
			if goParametros.Felino.GestionDeVentas.HabilitaComprobanteAsociado
				.PuntoDeVentaCpteRelacionado = toComprobanteAsociado.PuntoDeVenta
				.NumeroCpteRelacionado = toComprobanteAsociado.Numero
				.TipoCpteRelacionado = toComprobanteAsociado.TipoComprobante
				.FechaCpteRelacionado = toComprobanteAsociado.Fecha
			endif
			
			if empty(.ListaDePrecios_pk)
				.ListaDePrecios_pk = goParametros.Felino.Precios.ListasDePrecios.ListaDePreciosPreferente
			endif
			
			if "FISCAL" $ goParametros.Felino.GestionDeVentas.Recibo.Descuento.TipoDeComprobante
				.Fecha = date()
			endif
			with .FacturaDetalle
				.Limpiar()
				.oItem.Articulo_pk = goParametros.Felino.GestionDeVentas.Recibo.Descuento.ArticuloDelComprobante
				.oItem.Cantidad = 1
				lnMonto = iif( loComprobante.oComponenteFiscal.MostrarImpuestos(), tnMonto, ( tnMonto * 100 / ( loComprobante.oComponenteFiscal.nPorcentajeIVA + 100 ) ) )
				.oItem.AsignarPrecio( lnMonto )
				.Actualizar()
			endwith 
			.PorcentajeDescuento = 0

			if tnMonto # .Total

				lnNuevoMonto = this.ObtenerBaseDeCalculo( loComprobante, tnMonto )

				with .FacturaDetalle
					.CargarItem(1)
					lnMonto = lnNuevoMonto
					.oItem.AsignarPrecio( lnMonto )
					.Actualizar()
				endwith 

				lnSubTotalBruto = .SubTotalBruto
				lnSubtotalNeto = .SubtotalNeto
				lnTotal = .Total

			endif

			with .ValoresDetalle
				.Limpiar()
				.oItem.Valor_pk = goParametros.Felino.GestionDeVentas.Recibo.Descuento.ValorDelComprobante
				.oItem.Monto = loComprobante.total
				.actualizar()
			endwith 	

		 	.zadsfw = .zadsfw + "Comprobante generado por el " + tcComprobante + " - Motivo: Recibo con descuento"
		 	.grabar()

		endwith
		goParametros.Felino.GestionDeVentas.Minorista.PermitirIngresarMontoDeSenaEnFacturasAIVAIncluido = llParametroDesgloceEnPrecio

	endfunc

	*-----------------------------------------------------------------------------------------
	function ObtenerDescripcionDelComprobante( ) as String 
		local lcDescripcion as String 
		with this.oComprobante.oEntidad
			lcDescripcion = .ObtenerNombreDeComprobanteDeVentas( .TipoComprobante ) +;
							 " " + upper( alltrim( .Letra ) ) +;
							 " " + padl( int( .PuntoDeVenta ), 4, "0" ) +;
							 "-" + padl( int( .Numero ), 8, "0" )
		endwith				 
		return lcDescripcion
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AnularComprobanteDescuento() as Void

		this.DesbindearEvento( this.oComprobante.oEntidad,"EventoPreguntarAnular", this.oComprobante.oKontroler, "PreguntarAnular" )
		this.oComprobante.oEntidad.anular()
	endfunc 

enddefine
