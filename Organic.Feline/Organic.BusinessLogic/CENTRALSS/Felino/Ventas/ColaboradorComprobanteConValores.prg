define class ColaboradorComprobanteConValores as ZooSession of ZooSession.prg

	#IF .f.
		Local this as ColaboradorComprobanteConValores of ColaboradorComprobanteConValores.prg
	#ENDIF

	#DEFINE PRECISIONENMONTOS 4
	#DEFINE PRECISIONENCALCULOS 8

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
	function GenerarComprobantePorDescuento( tcCliente as string, tnMonto as Integer, tcComprobante as String, tdFecha as Date ) as VOID 
		local loComprobante as Object, loError as Object, lnMonto as Double
		loComprobante = this.oComprobante.oEntidad 
		this.oComprobante.oEntidad.lIgnorarCamposObligatoriosDefinidosPorUsuario = .T.
		if loComprobante.EsNuevo()
			loComprobante.Cancelar()
		endif
		with loComprobante
			.nuevo()
			.cliente_pk = tcCliente
			.Fecha = tdFecha
			
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
				lnMonto = iif( loComprobante.oComponenteFiscal.MostrarImpuestos(), tnMonto, goLibrerias.RedondearSegunPrecision( tnMonto * 100 / ( loComprobante.oComponenteFiscal.nPorcentajeIVA + 100 ), PRECISIONENMONTOS ) )
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

	*-----------------------------------------------------------------------------------------
	protected function CoeficienteDeImpuestos( toComprobante as Object ) as Decimal
		local lnRetorno as Decimal
		lnRetorno = round((this.Impuestos + this.TotalImpuestos) / this.Total, PRECISIONENCALCULOS)
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function CoeficienteBaseDeCalculo(toComprobante as Object) as Decimal
		local lnRetorno as Decimal
		if !toComprobante.oComponenteFiscal.MostrarImpuestos()
			lnRetorno = goLibrerias.RedondearSegunPrecision( (toComprobante.Total - toComprobante.Impuestos - toComprobante.TotalImpuestos) / toComprobante.Total, PRECISIONENCALCULOS)
		else
			lnRetorno = goLibrerias.RedondearSegunPrecision( (toComprobante.Total - toComprobante.Percepciones) / toComprobante.Total, PRECISIONENCALCULOS)
		endif
		return lnRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerBaseDeCalculo( toComprobante as Object, tnMonto as Decimal ) as Decimal
		local lnRetorno as Decimal
		lnRetorno = goLibrerias.RedondearSegunPrecision( tnMonto * this.CoeficienteBaseDeCalculo(toComprobante), PRECISIONENMONTOS)
		return lnRetorno
	endfunc 

enddefine
