define class DetalleColorYtalle_MovimientoStockAInvent as DetalleMovStock of DetalleMovStock.prg

	oColaboradorValidacionControlDeStockDisponible = NULL

	*--------------------------------------------------------------------------------------------------------
	function oColaboradorValidacionControlDeStockDisponible_Access() as variant
		if !this.ldestroy and ( !vartype( this.oColaboradorValidacionControlDeStockDisponible ) = 'O' or isnull( this.oColaboradorValidacionControlDeStockDisponible ) )
			this.oColaboradorValidacionControlDeStockDisponible = _Screen.Zoo.CrearObjeto( "ColaboradorValidacionControlDeStockProduccionDisponible" )
		endif
		return this.oColaboradorValidacionControlDeStockDisponible
	endfunc

	*-----------------------------------------------------------------------------------------
	function Actualizar( tcClave as string ) as Void
		local lcMensajeSinDisponibleas as String
*		if this.TieneHabilitadoElControlDeStock() and !this.oItem.NoProcesarStock and this.ItemAdvierteStockDisponible() and this.AdvierteNoTieneDisponible()
		if this.oColaboradorValidacionControlDeStockDisponible.DebeValidarStockDisponible( this.oItem, this.lItemControlaDisponibilidad )
        lcMensajeSinDisponible = this.oItem.oCompStockProduccion.FormarMensajeCombSegunDisponible(this.oitem)
			goServicios.Mensajes.Informar( lcMensajeSinDisponible)
		endif

		dodefault( tcClave )
	endfunc

*!*		*-----------------------------------------------------------------------------------------
*!*		function CargarItem( tnItem as Integer ) as Void
*!*			dodefault( tnItem )
*!*			This.oItem.InventarioDestino_PK = this.oEntidad.InventarioOrigen_PK
*!*		endfunc 

enddefine
