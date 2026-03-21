define class DetalleArticulosProduccion as detalle of detalle.prg

	#if .f.
		local this as DetalleArticulosProduccion of DetalleArticulosProduccion.prg
	#endif

	tipo = 0
	lItemControlaDisponibilidad = .F.
	dFechaBaseParaVigencia = {//}
	cStringFiltroArticulos = ['']
	cStringFiltroArticulosPromoYKits = ['']
	nCargadosPorPrePantalla = 0
	nTotalDetallePrePantalla = 0
	
	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
		This.Enlazar( ".oItem.EventoNoHayStock", "EventoNoHayStock" )
		This.Enlazar( ".oItem.VerificarValidezArticulo", "EventoVerificarValidezArticulo" )
		
		if pemstatus( this.oItem, "EventoInformarArticuloConColorOTalleFueraDePaletaOCurva", 5 )
			this.enlazar(".oItem.EventoInformarArticuloConColorOTalleFueraDePaletaOCurva","EventoInformarArticuloConColorOTalleFueraDePaletaOCurva")		
		endif
		This.InyectarDetalleAlItem()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoNoHayStock( toInformacion ) as Void
		&& Para que se cuelguen
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function eventoAlcanzoMinimoDeReposicion( toInformacion ) as Void
		&& para que se enganche alguien
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	function SetearStockInicial() as Void
		dodefault()
		This.oItem.SetearStockInicial()
	endfunc 
	*-----------------------------------------------------------------------------------------
	function EliminarStockInicial() as Void
		dodefault()
		This.oItem.EliminarStockInicial()
	endfunc 
	*-----------------------------------------------------------------------------------------
	protected function InyectarDetalleAlItem() as Void
		dodefault()
		This.oItem.InyectarDetalle( This )
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function EventoVerificarValidezArticulo( toEntidad as entidad OF entidad.prg ) as Void

	endfunc 
	*-----------------------------------------------------------------------------------------
	function CompletarDatosComplementariosDePrePantalla( toItemAux as ItemAuxiliar of din_detallefacturafacturadetalle.prg ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ProcesarPorPrepantalla( tcNombreDetalle as String, tcValor as String ) as Void
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ReposicionarAlVolverDePrePantalla( tcNombreDetalle as String ) as Void
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoInformarArticuloConColorOTalleFueraDePaletaOCurva( toInformacion as Object ) as Void
		&& este metodo levanta el evento disparado por el colaborador para que lo pueda capturar el kontroler
	endfunc

	*-----------------------------------------------------------------------------------------
	function SetearNuevaFechaParaVigencia( tdFecha as Date ) as Void
		this.dFechaBaseParaVigencia = tdFecha 
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerFechaBaseParaVigencia() as Date
		return this.dFechaBaseParaVigencia 
	endfunc 

	function Limpiar() as Void
		dodefault()
		this.dFechaBaseParaVigencia = {//}
	endfunc
	
	*-----------------------------------------------------------------------------------------
	function DebeCargarItemPorActualizarDetalleArticulos() as Void
		return .f.
	endfunc 
	*-----------------------------------------------------------------------------------------
	function EventoSetearsidebeAdvertirFaltantedeStock( tlValor as boolean ) as Void

	endfunc 


		
enddefine

