define class ItemCurvadeProduccionDetalle as Din_ItemCurvadeproduccionDetalle of Din_ItemCurvadeproduccionDetalle.prg

	#if .f.
		local this as ItemCurvadeProduccionDetalle of ItemCurvadeProduccionDetalle.prg
	#endif

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
		this.enlazar( ".color.AjustarObjetoBusqueda","EventoBusquedaDeColor" )
		this.enlazar( ".talle.AjustarObjetoBusqueda","EventoBusquedaDeTalle" )
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function Validar_Color( txVal as variant, txValOld as variant ) as Boolean
		local llRetorno as Boolean
		llRetorno = dodefault( txVal, txValOld )
		if This.CargaManual() and llRetorno and !empty(txVal) and !empty(this.oEntidad.PaletaDeColores_PK)
			if !this.oEntidad.oColaborador.ColorValido( this.oEntidad.PaletaDeColores_PK, txVal)
				llRetorno = .f.
				goServicios.Errores.LevantarExcepcion( "Color invalido para la paleta seleccionada" )
			endif
		endif
		Return llRetorno
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Validar_Talle( txVal as variant, txValOld as variant ) as Boolean
		local llRetorno as Boolean
		llRetorno = dodefault( txVal, txValOld )
		if This.CargaManual() and llRetorno and !empty(txVal) and !empty(this.oEntidad.CurvaDeTalles_PK)
			if !this.oEntidad.oColaborador.TalleValido( this.oEntidad.CurvaDeTalles_PK, txVal)
				llRetorno = .f.
				goServicios.Errores.LevantarExcepcion( "Talle invalido para la curva seleccionada" )
			endif
		endif
		Return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoBusquedaDeColor( toBusqueda as Object ) as Void
		local lcFiltro as String, lcCodigos as String, lcCampoClave as String  
		lcFiltro = ""	
		lcCodigos = ""
		this.lBuscandoCodigo = .t.
		lcCampoClave = this.color.oad.obtenercampoentidad( this.color.obteneratributoclaveprimaria())
		if vartype( toBusqueda ) = "O"
			lcCodigos = this.oEntidad.oColaboradorProduccion.ObtenerColores( this.oEntidad ) && ( this.oEntidad.CurvaDeProduccion )
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
			lcCodigos = this.oEntidad.oColaboradorProduccion.ObtenerTalles( this.oEntidad ) && ( this.oEntidad.CurvaDeProduccion )
			if !empty( lcCodigos )
				lcCodigos = " and codigo in (" + lcCodigos + ")"
			endif 
			toBusqueda.filtro = toBusqueda.filtro + lcCodigos
		endif
		this.lBuscandoCodigo = .f.
	endfunc 

enddefine
