define class ent_ProcesoProduccion as din_EntidadProcesoProduccion of din_EntidadProcesoProduccion.prg

	#If .F.
		Local This as ent_ProcesoProduccion of ent_ProcesoProduccion.prg
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

