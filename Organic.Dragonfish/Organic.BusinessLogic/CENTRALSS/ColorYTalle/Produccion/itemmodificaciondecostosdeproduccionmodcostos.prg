define class ItemModificacionDeCostosDeProduccionModcostos as Din_ItemModificaciondecostosdeproduccionModCostos of Din_ItemModificaciondecostosdeproduccionModCostos.prg

	#if .f.
		local this as ItemModificacionDeCostosDeProduccionModcostos of ItemModificacionDeCostosDeProduccionModcostos.prg
	#endif

	oListaDeCostos = null
	oDetalle = null
	lHayComponenteCostos = .f.

	*-----------------------------------------------------------------------------------------
	function inicializar() as Void
		dodefault()
		This.lHayComponenteCostos = This.HayComponenteCostos()		
		this.enlazar("haCambiado","eventoComponenteCosto")		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function InyectarDetalle( toDetalle As detalle OF detalle.prg ) as Void
		This.oDetalle = toDetalle
		This.oCompCostosProduccion.InyectarDetalle( This.oDetalle )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function eventoComponenteCosto( tcAtributo As String, toItem as object ) as Void
		local lcListaDeCostos as String, llLimpiando as boolean, loError as Object
		if This.lHayComponenteCostos and inlist(lower(tcAtributo),'semielaborado_pk','listadecosto_pk','color_pk','talle_pk','taller_pk','proceso_pk','desdecantidad')
			if !empty( this.SemiElaborado_pk ) and empty( this.ListaDeCosto_PK )
				lcListaDeCostos = this.ObtenerListaDeCostosPreferente()
				if !empty(lcListaDeCostos)
					try
						this.ListaDeCosto_PK = lcListaDeCostos						
					catch to loError
						llLimpiando = this.llimpiando
						this.llimpiando = .t.
						this.ListaDeCosto_PK = ""
						this.llimpiando = llLimpiando
					endtry				
				endif 
			endif
			if !empty( this.ListaDeCosto_PK )
				this.oCompCostosProduccion.SetearCostoActual( toItem, This.oListaDeCostos.Codigo, tcAtributo )				
			endif			
		Endif
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function oListaDeCostos_access() as variant
		if !this.ldestroy and !vartype( this.oListaDeCostos ) = 'O'
			this.oListaDeCostos = _Screen.zoo.instanciarentidad( 'LISTADECOSTOSDEPRODUCCION' )
		endif
		return this.oListaDeCostos
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerListaDeCostosPreferente() as Void
		local lcLista as String
		lcLista = goparametros.Felino.Generales.ListaDeCostosPreferenteParaCotizacionesYLiquidacionesDeProduccion
		return lcLista
	endfunc 

	*-----------------------------------------------------------------------------------------
	function Validar_ListadeCosto( txVal as variant, lxValOld  as Variant ) as Boolean
		local llRetorno as Boolean
		llRetorno = dodefault( txVal, lxValOld )

		if llRetorno and empty( txVal )
			goServicios.Errores.LevantarExcepcion( "Debe cargar el atributo Lista de costo." )
			llRetorno = .f.
		endif

		return llRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function HayComponenteCostos() as Boolean
		return  vartype( This.oCompCostosProduccion ) = "O" .and. lower("componenteCostosProduccion") $ lower( This.ocompcostosproduccion.Class )
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function Setear_Listadecosto( txVal as variant ) as void
		dodefault( txVal )
		This.oListaDeCostos.Codigo = txVal
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Setear_Semielaboradodetalle( txVal as variant ) as void
		dodefault( txVal )
		if empty(this.Proceso_PK) and !empty(this.oEntidad.Proceso_PK)
			this.Proceso_PK = this.oDetalle.oEntidad.Proceso_PK
		endif
		if empty(this.Taller_PK) and !empty(this.oEntidad.Taller_PK)
			this.Taller_PK = this.oDetalle.oEntidad.Taller_PK
		endif
	endfunc

enddefine
