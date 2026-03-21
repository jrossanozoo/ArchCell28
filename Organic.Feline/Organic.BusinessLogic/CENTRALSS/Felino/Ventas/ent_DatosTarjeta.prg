define class Ent_DatosTarjeta as Din_EntidadDatosTarjeta of Din_EntidadDatosTarjeta.prg

	#IF .f.
		Local this as Ent_DatosTarjeta of Ent_DatosTarjeta.prg
	#ENDIF
	
	protected lInicializando as Boolean

    oCupon = null
	oComprobante = null
	oDetalleValores = null
	lInicializando = .t.
	oColaboradorPOS = null
	
	oHelperPlanDeCuotas = null

	*--------------------------------------------------------------------------------------------------------
	Function oHelperPlanDeCuotas_Access() as variant
		If !this.ldestroy and ( !Vartype( this.oHelperPlanDeCuotas ) = 'O' or Isnull( this.oHelperPlanDeCuotas ) )
			this.oHelperPlanDeCuotas = _screen.zoo.CrearObjeto( "HelperPlanDeCuotas" )
		Endif
		Return this.oHelperPlanDeCuotas
	Endfunc
	
	*-----------------------------------------------------------------------------------------
	function ProcesarDespuesDeSetearTarjeta() as Void
  		local loError as zooexception OF zooexception.prg, llHabilitarCuotas as Boolean, llDeshabilitarTipoPagoPosnet as Boolean

		if !this.lLimpiando
			if !this.lInicializando and !empty( this.Tarjeta_PK )
				try
					this.Tarjeta.VerificarSiElValorEstaDisponibleParaMonto( this.Monto )
				catch to loError
					this.Tarjeta_PK = ""
					goServicios.Errores.LevantarExcepcion( loError )
				endtry
			endif
			this.PorcentajeDescuento = this.tarjeta.Descuento	
			this.ActualizarGrilla()
			llHabilitarCuotas = this.lhabilitarCuotas 
			this.lhabilitarCuotas = .t.			
			this.Cuotas = iif( this.ExisteCuotaEnPlan( this.Cuotas ), this.Cuotas, this.ObtenerCuotaGrilla( 1 ) )
			this.lhabilitarCuotas = llHabilitarCuotas
			this.ActualizarCombo()
			this.ActualizarComboClaseDeTarjeta()
			this.EventoActualizarComboPlanes()
			this.EventoSetearObligatoriedadDeAtributosParaDispositivosElectronicos( this.EsValorTipoPagoElectronico(), this.lPermiteCompraNoIntegradaConDispositivoElectronico )
			this.EventoHabilitarMenuHabilitarCargaManualDeNumeroDeCuponPoint()
			this.EventoHabilitarMenuDeshabilitarCargaManualDeNumeroDeCuponPoint()

			if this.POS.EsDispositivoPosnet()
				llDeshabilitarTipoPagoPosnet = this.DeboDeshabilitarTipoPagoPosnet()
				this.DeshabilitarTipoPagoPosnet( llDeshabilitarTipoPagoPosnet )
				this.llNoCambiarTipoPagoPosnet = llDeshabilitarTipoPagoPosnet 
			else
				this.llNoCambiarTipoPagoPosnet = .F.
			endif
		endif
	endfunc

Enddefine

*-----------------------------------------------------------------------------------------
Define Class AccesoDatosCustom as Custom

	cTablaPrincipal = ''

	*-----------------------------------------------------------------------------------------
	Function Limpiar() as Void
	Endfunc
	
	*-----------------------------------------------------------------------------------------
	Function HayDatos() as bool 
		Return .f.
	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ConsultarPorClavePrimaria( tlLlenarAtributos as Boolean ) as Boolean
		Return .f.
	Endfunc

Enddefine
