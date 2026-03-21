define class kontrolercotizacion as din_kontrolercotizacion of din_kontrolercotizacion.prg

	#IF .f.
		Local this as kontrolercotizacion of kontrolercotizacion.prg
	#ENDIF
	
	PudoGrabar = .f.
	MonedaUnica = ""
	
	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()

		this.BindearEventoLostFocusMoneda()
		this.BindearAjustarObjetoBusquedaDeEntidadMoneda()
		
		this.BloquearControlesUltimaCotizacion()
		this.Ejecutar( "NUEVO" )
		this.VerificarEInicializarSiTieneUnaSolaMoneda()
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function BindearEventoLostFocusMoneda() as Void
		local loControl as TextBox
		
		loControl = this.ObtenerControl( "Moneda" )
		this.BindearEvento( loControl, "LostFocus", this, "SaltarANuevaCotizacion" )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	Function Ejecutar( tcAccion As String ) As boolean 
		dodefault( tcAccion )
		
		if tcAccion = "GRABAR" 
			if this.PudoGrabar
				dodefault( "SALIR" )
			endif
		else
			if tcAccion = "CANCELAR"
				dodefault( "SALIR" )
			endif
		endif
	Endfunc
	
	*-----------------------------------------------------------------------------------------
	function VerificarEInicializarSiTieneUnaSolaMoneda() as Void
		local lcFiltroMonedasExtranjeras as String, lnCantidadDeMonedasExtranjeras as Integer
			  
		lcFiltroMonedasExtranjeras = "upper( alltrim( CODIGO ) ) != '" + upper( alltrim( goparametros.felino.generales.monedasistema ) ) + "'"
		lnCantidadDeMonedasExtranjeras = this.oEntidad.Moneda.obtenercantidadderegistrosconfiltro( lcFiltroMonedasExtranjeras )
		
		if lnCantidadDeMonedasExtranjeras = 1
			xmltocursor( this.oEntidad.Moneda.obtenerdatosentidad( "CODIGO", lcFiltroMonedasExtranjeras ), "Prueba" )
			this.MonedaUnica = upper( alltrim( Prueba.CODIGO ) )
			this.InicializarFormularioConLaMoneda( this.MonedaUnica )
		endif

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function BloquearControlesUltimaCotizacion() as Void
		local loControl as TextBox
		
		loControl = this.ObtenerControl( "UltimaFecha" )
		loControl.ReadOnly = .t.
		loControl.TabStop = .f.
		
		loControl = this.ObtenerControl( "UltimaHora" )
		loControl.ReadOnly = .t.
		loControl.TabStop = .f.
		
		loControl = this.ObtenerControl( "UltimaCotizacion" )
		loControl.ReadOnly = .t.
		loControl.TabStop = .f.
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	protected function SaltarANuevaCotizacion() as Void
		local loControl as TextBox
		
		loControl = this.ObtenerControl( "NuevaCotizacion" )
		loControl.SetFocus()
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function InicializarFormularioConLaMoneda( tcMoneda as String ) as Void
		local loControl as TextBox
		
		loControl = this.ObtenerControl( "Moneda" )
		
		loControl.Value = tcMoneda
		
		loControl.SetFocus()
		loControl.LostFocus()

	endfunc
	
	*-----------------------------------------------------------------------------------------
	function BloquearControlMoneda() as Void
		local loControl as TextBox
		
		loControl = this.ObtenerControl( "Moneda" )
			
		if loControl.Enabled
		
			loControl.Enabled = .f.
			
			loControl = Thisform.SUBGRUPO0.COTIZACIONMONEDA.CMDBOTON
			loControl.Enabled = .f.
		
		endif
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function BindearAjustarObjetoBusquedaDeEntidadMoneda() as Void
		local loControl as TextBox

		loControl = this.ObtenerControl( "Moneda" )
		bindevent( loControl.oEntidad, "AjustarObjetoBusqueda", this.oEntidad, "AjustarObjetoBusqueda" )
	endfunc

	*-----------------------------------------------------------------------------------------
	Function Procesar() As boolean
		this.PudoGrabar = dodefault()
		
		return this.PudoGrabar
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ActualizarFormulario() as Void
		dodefault()
		if !empty( this.MonedaUnica )
			this.bloquearcontrolmoneda()
		endif
	endfunc 

enddefine
