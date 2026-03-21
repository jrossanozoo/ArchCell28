Define Class entColorYTalle_DatosTarjeta as ent_DatosTarjeta of ent_DatosTarjeta.prg

	#IF .f.
		Local this as entColorYTalle_DatosTarjeta of entColorYTalle_DatosTarjeta.prg
	#ENDIF

	lAplicaPromocion = .f.
	nMontoBeneficioPromoMedioDePago = 0
	oColaboradorPromocionBancaria = null
	oColaboradorPromocionMedioDePago = null
	lLanzarEventoCambioDeValor = .f.

	*-----------------------------------------------------------------------------------------
	Protected Function PreparaCupon() as Void
		Local lcTipoTarjeta as String, lnTotalConDescuento as Decimal
		lnTotalConDescuento = this.monto - this.totaldescuento
		
		With this.oCupon
			.Valor_PK = this.Tarjeta_PK
			.NumeroCupon = this.NumeroCupon
			.Monto = this.ObtenerMontoParaCupon( iif( lnTotalConDescuento = this.monto, this.TotalConRecargo, lnTotalConDescuento ) )
			.Cuotas = this.Cuotas
			.RecargoPorcentaje = this.PorcentajeRecargo
			.RecargoMonto = this.totalrecargo
			.TipoCupon = this.TipoCupon			
			.EntidadFinanciera_PK = this.entidadFINANCIERA_PK
			.ClaseDeTarjeta_PK = this.ClaseDeTarjeta
			.NumeroComprobante = this.NumeroComprobante
			.Cliente = this.Cliente_pk
			.DescuentoPorcentaje = this.PorcentajeDescuento
			.DescuentoMonto = this.totaldescuento
			.CodigoPlan = this.CodigoPlan
			.Serial = this.Serial
			.DispositivoMovil = this.DispositivoMovil
			.ReferenciaExterna = this.ReferenciaExterna
		Endwith
		this.HabilitarControlesSegunCupon()
	Endfunc 

	*-----------------------------------------------------------------------------------------
	Function AplicaPromocionAutomatica() as Boolean
		Local llRetorno as Boolean, loColaborador as Object
		loColaborador = this.oColaboradorPromocionBancaria
		llRetorno = Type( "loColaborador" ) = "O" and !Isnull( loColaborador ) and loColaborador.debeEvaluarPromocionesBancarias( this.oCupon.FechaCupon )
		Return llRetorno
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ObtenerColaboradorPromociones() as Object
		Local loColaborador as Object
		If type( "this.oComprobante" ) = "O" and !isnull(this.oComprobante)
			loColaborador = this.oComprobante.ObtenerColaboradorPromociones()
		Else
			loColaborador = null
		Endif
		Return loColaborador
	endfunc
	
	*-----------------------------------------------------------------------------------------
	Function InyectarEntidades( toEntidad as ent_comprobantedeventasconvalores of ent_comprobantedeventasconvalores.prg, ;
								toDetalle as detalle OF detalle.prg, toCupon as ent_cupon of ent_cupon.prg ) as Void
		Dodefault( toEntidad, toDetalle, toCupon )
		this.oColaboradorPromocionBancaria = this.ObtenerColaboradorPromociones()
		this.oColaboradorPromocionMedioDePago = this.ObtenerColaboradorPromocionesPorMedioDePago()
		this.EventoDespuesDeInyectarEntidades()
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function EventoDespuesDeInyectarEntidades() as Void
*!*		Para que se bindee el kontroler y ocurra solo en el formulario
	Endfunc

	*-----------------------------------------------------------------------------------------
	Protected Function RecuperarDatosParaAnular() as Boolean
		local llRetorno as Boolean
		this.EventoAnularCupon()
		llRetorno = DoDefault()
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function EventoAnularCupon() as Void
*!*		Para que se bindee el kontroler y ocurra solo en el formulario
	EndFunc 
	
	*-----------------------------------------------------------------------------------------
	function Grabar() as Void
		this.EventoEvaluarActualizarAplicacionDePromocion()
		this.EventoEvaluarPromocionPorMedioDePago()
		dodefault()
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EventoEvaluarActualizarAplicacionDePromocion() as Void
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EventoEvaluarPromocionPorMedioDePago() as Void
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function EvaluaPromocionesPorMedioDePago() as Void
		return !this.AutorizacionPOS and !this.EsCuponConAnulacion() and !this.TipoCupon = "AC" and this.monto > 0
	endfunc 

	*-----------------------------------------------------------------------------------------
	function esCargaManual() as Boolean
		return !this.lInicializando and !this.lEstaSeteandoValorSugerido and !this.lLimpiando and !this.lCargando and !this.lDestroy and (this.lNuevo or this.lEdicion)
	endfunc

	*-------------------------------------------------------------------------------------------------
	protected Function ValidarExistencia() As Boolean
		return .f.
	endfunc

Enddefine
