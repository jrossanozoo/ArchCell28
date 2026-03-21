define class kontrolerProcesoProduccion as din_kontrolerProcesoProduccion of din_kontrolerProcesoProduccion.prg

	#If .F.
		Local This as kontrolerProcesoProduccion of kontrolerProcesoProduccion.prg
	#Endif

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
		This.BindearEvento( This.oEntidad.ArticuloLiquidacionProduccion, "AjustarObjetoBusqueda" , This.oEntidad, "SetearFiltroBuscadorProduccion" )
		This.BindearEvento( This.oEntidad.ArticuloLiquidacionDescarte, "AjustarObjetoBusqueda" , This.oEntidad, "SetearFiltroBuscadorDescarte" )
	endfunc 

enddefine
