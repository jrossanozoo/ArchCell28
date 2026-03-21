define class KontrolerMovimientoStockAInvent as din_KontrolerMovimientoStockAInvent of din_KontrolerMovimientoStockAInvent.prg

	#if .f.
		local this as KontrolerMovimientoStockAInvent of KontrolerMovimientoStockAInvent.prg
	#endif

	*-----------------------------------------------------------------------------------------
	Function Inicializar() As Void
		dodefault()
		if pemstatus( this.oEntidad, "MovimientoDetalle", 5 ) and vartype( this.oEntidad.MovimientoDetalle ) == "O"
			This.BindearCondicionDeFoco()
			This.BindearEvento( This.oEntidad, "ActualizarEtiquetas", This, "ActualizarEtiquetas" )
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function BindearCondicionDeFoco() as Void
		local loDetalle as Object, loControl as Object, lnI as Integer
		loDetalle = this.ObtenerControl( "MovimientoDetalle" )
		for lnI = 1 to loDetalle.nCantidadItemsVisibles
			loControl = loDetalle.ObtenerCampoPorAtributo( lnI, "InventarioDestino" )
			this.BindearEvento( loControl, "SePuedeHabilitar", this, "SePuedeHabilitarInventarioDestino" )
		endfor
	endfunc 	

	*-----------------------------------------------------------------------------------------
	function SePuedeHabilitarInventarioDestino() as Void
		local loDetalle as Object, loCampo as Object, loControl as Object
		loDetalle = this.ObtenerControl( "MovimientoDetalle" )
		loControl = loDetalle.ObtenerCampoPorAtributo( loDetalle.nfilaActiva, "InventarioDestino" )
		if !isnull( loControl )
			loControl.lSaltoCampo = ( this.oEntidad.Tipo = 1 )
		endif
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function ActualizarEtiquetas() as Void
		local loControl as Object
		if this.ExisteControl( 'InventarioOrigen' )
			loControl = this.ObtenerControl( 'InventarioOrigen' )
			if this.oEntidad.Tipo = 1   
				loControl.parent.cEtiqueta = "Inventario destino"
				loControl.parent.lblEtiqueta.caption = "Inventario destino"
			else
				loControl.parent.cEtiqueta = "Inventario origen"
				loControl.parent.lblEtiqueta.caption = "Inventario origen"			
			endif
		endif
	endfunc 

enddefine
