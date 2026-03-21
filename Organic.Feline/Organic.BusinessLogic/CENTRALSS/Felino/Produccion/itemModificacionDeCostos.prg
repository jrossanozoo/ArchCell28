define class itemModificacionDeCostos as ItemActivo of ItemActivo.prg

	#If .F.
		Local This As itemModificacionDeCostos As itemModificacionDeCostos.prg
	#Endif

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AjustarFiltroSegunCurvaEnModelo() as Void
		this.enlazar( ".colorM.AjustarObjetoBusqueda","EventoBusquedaDeColor" )
		this.enlazar( ".talleM.AjustarObjetoBusqueda","EventoBusquedaDeTalle" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AjustarFiltroSegunCurvaEnInsumo() as Void
		this.enlazar( ".color.AjustarObjetoBusqueda","EventoBusquedaDeColor" )
		this.enlazar( ".talle.AjustarObjetoBusqueda","EventoBusquedaDeTalle" )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoBusquedaDeColor( toBusqueda as Object ) as Void
		local lcFiltro as String, lcCodigos as String, lcCampoClave as String  
		lcFiltro = ""	
		lcCodigos = ""
		this.lBuscandoCodigo = .t.
		lcCampoClave = this.color.oad.obtenercampoentidad( this.color.obteneratributoclaveprimaria())
		if vartype( toBusqueda ) = "O"
			lcCodigos = this.oEntidad.oColaboradorProduccion.ObtenerColores( this.oEntidad.CurvaDeProduccion )
			if !empty( lcCodigos )
				lcCodigos = " and " + lcCampoClave + " in ("+lcCodigos+")"
			endif 
			toBusqueda.filtro = toBusqueda.filtro + lcCodigos
		endif
		this.lBuscandoCodigo = .f.
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EventoBusquedaDeTalle( toBusqueda as Object ) as Void
		local lcFiltro as String, lcCodigos as String, lcCampoClave as String  
		lcFiltro = ""	
		lcCodigos = ""
		this.lBuscandoCodigo = .t.
		lcCampoClave = this.talle.oad.obtenercampoentidad( this.talle.obteneratributoclaveprimaria() )
		if vartype( toBusqueda ) = "O"
			lcCodigos = this.oEntidad.oColaboradorProduccion.ObtenerTalles( this.oEntidad.CurvaDeProduccion )
			if !empty( lcCodigos )
				lcCodigos = " and codigo in (" + lcCodigos + ")"
			endif 
			toBusqueda.filtro = toBusqueda.filtro + lcCodigos
		endif
		this.lBuscandoCodigo = .f.
	endfunc 

enddefine
