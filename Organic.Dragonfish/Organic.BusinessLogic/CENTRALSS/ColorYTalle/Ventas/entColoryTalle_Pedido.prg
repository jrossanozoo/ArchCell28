define class entColoryTalle_Pedido as ent_pedido of ent_pedido.prg
	
	#if .f.
		local this as entColoryTalle_Pedido of entColoryTalle_Pedido.prg
	#endif

	lItemControlaDisponibilidad = .T.
	
	*-----------------------------------------------------------------------------------------
	function ControlaStockDisponible() as Boolean
		local llRetorno as Boolean
		llRetorno = goParametros.Felino.Generales.HabilitaControlStock and ( goParametros.ColorYTalle.GestionDeVentas.ControlStockDisponiblePedidos == 2 )
		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function AdvierteStockDisponible() as Boolean
		local llRetorno as Boolean
		llRetorno = goParametros.Felino.Generales.HabilitaControlStock and ( goParametros.ColorYTalle.GestionDeVentas.ControlStockDisponiblePedidos == 3 )
		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function TieneQueVerificarMinimoDeReposicion() as Boolean
		return goParametros.Felino.Generales.HabilitaControlStock and ;
				goParametros.ColorYTalle.GestionDeVentas.ControlDeStockDisponibleMedianteMinimosDeStockEnPedidosDeVenta > 1
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function NoPermitePasarAlSuperarMinimoDeReposicion() as Boolean
		return goParametros.ColorYTalle.GestionDeVentas.ControlDeStockDisponibleMedianteMinimosDeStockEnPedidosDeVenta == 2
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ValidaMinimoDeReposicionAlGrabar() as Void
		return goParametros.Felino.Generales.HabilitaControlStock and ;
				goParametros.ColorYTalle.GestionDeVentas.ControlDeStockDisponibleMedianteMinimosDeStockEnPedidosDeVenta == 2
	endfunc 

enddefine

