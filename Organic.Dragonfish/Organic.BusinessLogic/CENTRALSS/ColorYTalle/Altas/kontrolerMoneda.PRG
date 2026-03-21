define class KontrolerMONEDA as Din_KontrolerMONEDA of Din_KontrolerMONEDA.prg
	
	#IF .f.
		Local this as KontrolerMoneda of KontrolerMoneda.prg
	#ENDIF

	protected GrillaCotizaciones as zooGrillaExtensible of ZooGrillaExtensible.Prg
	
	GrillaCotizaciones = null
	BuscandoPrimeraFila = .F.
	FilaParaNuevoIngreso = 0
	ControlFecha = null
	ControlHora = null
	ControlCotizacion = null

	*-----------------------------------------------------------------------------------------
	function ObtenerGrillaDeCotizaciones() as zooGrillaExtensible of ZooGrillaExtensible.Prg
		local lcDetalle as String
		
		if isnull( this.GrillaCotizaciones )
			lcDetalle = "COTIZACIONES"
			
			if This.Existecontrol( lcDetalle )
				this.GrillaCotizaciones = This.ObtenerControl( lcDetalle )
			endif
		endif
		
		return this.GrillaCotizaciones
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
		
		if vartype( this.oEntidad ) = "O"
			this.BindearEvento( this.oEntidad, "EventoHabilitarDeshabilitarMonedaCotizacionAFIP" , this, "HabilitarDeshabilitarMonedaCotizacionAFIP" )
		endif
	
		this.BindearAEventoGotFocusCotizaciones()
		this.CambiarAtributosPorPais()
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function BindearAEventoGotFocusCotizaciones() as Void
		local loGrilla as zooGrillaExtensible of ZooGrillaExtensible.Prg
		loGrilla = this.ObtenerGrillaDeCotizaciones()
		this.BindearEvento( loGrilla, "GotFocus", this, "SetearFocoEnPrimerFilaConItemVacio" )
		this.BindearEvento( loGrilla, "LostFocus", this, "ReiniciarSeteoFocoEnPrimerFilaConItemVacio" )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function IngresarNuevaCotizacion() as Void
		local loFormularioCotizacion as Object
		
		loFormularioCotizacion = _screen.zoo.crearobjeto( "FrmAbm_CotizacionAvanzadoEstilo2" )
		loFormularioCotizacion.oKontroler.InicializarFormularioConLaMoneda( this.oEntidad.Codigo )
		loFormularioCotizacion.oKontroler.BloquearControlMoneda()
		this.SetearEstadoMenuYToolbar( .f. )
		loFormularioCotizacion.show()
		this.SetearEstadoMenuYToolbar( .t. )

		this.oEntidad.Buscar()
		this.oEntidad.Cargar()
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearFocoEnPrimerFilaConItemVacio() as Void
		local loGrilla as zooGrillaExtensible of ZooGrillaExtensible.Prg,;
			  loControlFecha as TextBox, lnIndV as Integer

		if !this.BuscandoPrimeraFila
			this.BuscandoPrimeraFila = .T.
			
			loGrilla = this.ObtenerGrillaDeCotizaciones()
			loControlFecha = null
			
			for lnIndV = 1 to loGrilla.nCantidadItemsVisibles
				loControlFecha = loGrilla.ObtenerCampoPorAtributo( lnIndV, "Fecha" )
				if empty( loControlFecha.Value )
					this.FilaParaNuevoIngreso = lnIndV
					exit
				endif
			endfor
			
			if !empty( this.FilaParaNuevoIngreso )
				this.EstablecerReferenciasParaNuevoIngreso()
				this.ControlFecha.SetFocus()
			endif
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ReiniciarSeteoFocoEnPrimerFilaConItemVacio() as Void
		this.BuscandoPrimeraFila = .F.
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function EstablecerReferenciasParaNuevoIngreso() as Void
		local loGrilla as zooGrillaExtensible of ZooGrillaExtensible.Prg
		
		if !empty( this.FilaParaNuevoIngreso )
			loGrilla = this.ObtenerGrillaDeCotizaciones()
			
			this.ControlFecha = this.ObtenerControl( "COTIZACIONES_FECHA_CAMPO_1_" + transform( this.FilaParaNuevoIngreso ) )
			this.ControlHora = this.ObtenerControl( "COTIZACIONES_HORA_CAMPO_2_" + transform( this.FilaParaNuevoIngreso ) )
			this.ControlCotizacion = this.ObtenerControl( "COTIZACIONES_COTIZACION_CAMPO_3_" + transform( this.FilaParaNuevoIngreso ) )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function MoverAlUltimoCampoEnDetalleCotizaciones() as Void
		local loGrilla as zooGrillaExtensible of ZooGrillaExtensible.Prg

		loGrilla = This.ObtenerGrillaDeCotizaciones()
	
		if vartype( loGrilla ) = "O"
			loGrilla.MoverAUltimoCampo()
			loGrilla.RefrescarGrilla()
		endif
		
		loGrilla = Null
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function Ejecutar( tcAccion as String ) as Boolean
		dodefault( tcAccion )
		
		if !inlist( upper( alltrim( tcAccion ) ), "MODIFICAR", "NUEVO")
			if upper( alltrim( tcAccion ) ) = "GRABAR"
				this.PosicionarEnPrimerCampoDeLaGrilla()
			else
				this.MoverAlUltimoCampoEnDetalleCotizaciones()
			endif
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function PosicionarEnPrimerCampoDeLaGrilla() as Boolean
		local loGrilla as zooGrillaExtensible of ZooGrillaExtensible.Prg, loControlFecha as TextBox
		
		loGrilla = This.ObtenerGrillaDeCotizaciones()
		loControlFecha = loGrilla.ObtenerCampoPorAtributo( 1, "Fecha" )
		if empty( loControlFecha.Value )
			loControlFecha.setfocus()
		endif
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	Function ActualizarBarra( tcEstado as String ) As Void
		local loHabilitaNuevaCotizacion as Boolean
		
			loHabilitaNuevaCotizacion = thisform.omenu.menu_ACCIONES.menu_nuevacotizacion.Enabled
			
			if ( Empty( this.oEntidad.Codigo ) or upper( alltrim( this.cAccion ) ) = "MODIFICAR" ) and loHabilitaNuevaCotizacion
				this.SetearEnabledMenu( "acciones", "NuevaCotizacion", .F. )
			endif
			
			if !Empty( this.oEntidad.Codigo ) and !loHabilitaNuevaCotizacion
				this.SetearEnabledMenu( "acciones", "NuevaCotizacion", .T. )
			endif
			
		dodefault( tcEstado )
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function CambiarAtributosPorPais() as Void
		local llEsUruguay as Boolean, loControlAfip as Object, loControlDGI as Object, loControlCarga as Object, ;
			loControlMonedaCotiz as Object, lnDif as Integer

		llEsUruguay = ( goParametros.Nucleo.DatosGenerales.Pais = 3 )
		if this.ExisteControl( "EquivalenciaAfip" )	and this.ExisteControl( "EquivalenciaDGI" )	;
			and this.ExisteControl( "CargaObligatoria" )	
					
			loControlAfip = this.ObtenerControl( "EquivalenciaAfip" ) 
			loControlAfip.parent.visible = !llEsUruguay
			
			loControlDGI = this.ObtenerControl( "EquivalenciaDGI" ) 
			loControlDGI.parent.visible = llEsUruguay 
			loControlDGI.parent.top = loControlDGI.parent.top - 16
			
			loControlMonedaCotiz = this.ObtenerControl( "MonedaCotizacionAFIP" )
			loControlMonedaCotiz.parent.visible = !llEsUruguay
			loControlMonedaCotiz.parent.top = loControlMonedaCotiz.parent.top - 16
	
			loControlCarga = this.ObtenerControl( "CargaObligatoria" )
			lnDif = iif( llEsUruguay, 32, 16 )
			loControlCarga.parent.top = loControlCarga.parent.top - lnDif
					
		endif
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function HabilitarDeshabilitarMonedaCotizacionAFIP() as Void
		local loControlMonedaCotiz as Object
		
		loControlMonedaCotiz = this.ObtenerControl( "MonedaCotizacionAFIP" )
		loControlMonedaCotiz.enabled = this.oEntidad.lHabilitarMonedaCotizacionAFIP_PK 
	endfunc 

enddefine
