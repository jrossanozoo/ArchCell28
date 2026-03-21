define class ent_insumo as din_EntidadInsumo of din_EntidadInsumo.prg

	#If .F.
		Local This as ent_insumo of ent_insumo.prg
	#Endif

	*-----------------------------------------------------------------------------------------
	function SetearFiltroBuscadorProduccion( toBusqueda as Object ) as Void
		toBusqueda.Filtro = toBusqueda.Filtro + " and (" + toBusqueda.Tabla + ".astock == 2)"
	endfunc

	*-----------------------------------------------------------------------------------------
	function SetearFiltroBuscadorDescarte( toBusqueda as Object ) as Void
		toBusqueda.Filtro = toBusqueda.Filtro + " and (" + toBusqueda.Tabla + ".astock == 2)"
	endfunc

enddefine
