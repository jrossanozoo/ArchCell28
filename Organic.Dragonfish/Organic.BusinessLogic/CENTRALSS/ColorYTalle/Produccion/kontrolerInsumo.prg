define class kontrolerInsumo as din_kontrolerInsumo of din_kontrolerInsumo.prg

	#If .F.
		Local This as kontrolerInsumo of kontrolerInsumo.prg
	#Endif

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
		This.BindearEvento( This.oEntidad.ArticuloLiquidacionProduccion, "AjustarObjetoBusqueda" , This.oEntidad, "SetearFiltroBuscadorProduccion" )
		This.BindearEvento( This.oEntidad.ArticuloLiquidacionDescarte, "AjustarObjetoBusqueda" , This.oEntidad, "SetearFiltroBuscadorDescarte" )
	endfunc 

enddefine
