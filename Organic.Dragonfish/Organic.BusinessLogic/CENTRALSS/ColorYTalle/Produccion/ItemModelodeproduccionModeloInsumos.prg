define class ItemModelodeProduccionModeloinsumos as Din_ItemModelodeproduccionModeloinsumos of Din_ItemModelodeproduccionModeloinsumos.prg

	#if .f.
		local this as ItemModelodeProduccionModeloinsumos of ItemModelodeProduccionModeloinsumos.prg
	#endif

	oEntidad = null
	cProcesoActivo = ''
	
	*--------------------------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
		this.AjustarFiltroSegunCurvaEnModelo()
		this.enlazar( ".colorM.AjustarObjetoBusqueda","EventoBusquedaDeColor" )
		this.enlazar( ".talleM.AjustarObjetoBusqueda","EventoBusquedaDeTalle" )
	endfunc

	*-----------------------------------------------------------------------------------------
	function InyectarEntidad( toEntidad As Object ) as Void
		This.oEntidad = toEntidad
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function HabilitarItem( tcProcesoActivo as String ) as void
		local lHabilitar as Boolean
		this.cProcesoActivo = tcProcesoActivo
		if this.oEntidad.EsModoEdicion() and !empty(this.cProcesoActivo)

			lHabilitar = alltrim(upper(this.Proceso_PK)) == alltrim(upper(tcProcesoActivo))
			this.lHabilitarCodigo = lHabilitar
			this.lHabilitarProceso_PK = lHabilitar
			this.lHabilitarColorM_PK = lHabilitar
			this.lHabilitarColorMDetalle = lHabilitar
			this.lHabilitarTalleM_PK = lHabilitar
			this.lHabilitarInsumo_PK = lHabilitar
			this.lHabilitarInsumoDetalle = lHabilitar
			this.lHabilitarComportamientoInsumo = lHabilitar
			this.lHabilitarColor_PK = lHabilitar
			this.lHabilitarColorDetalle = lHabilitar
			this.lHabilitarTalle_PK = lHabilitar
			this.lHabilitarUnidadDeMedida_PK = lHabilitar
			this.lHabilitarCantidad = lHabilitar
		endif
	endfunc

	*--------------------------------------------------------------------------------------------------------
	function Validar_Proceso( txVal as variant, txValOld as variant ) as Boolean
		local llRetorno as Boolean
		llRetorno = This.EsModoEdicion() and dodefault( txVal, txValOld )
		if llRetorno and !empty(txval)
			llRetorno = this.oEntidad.ValidarProcesoEnModelo(txVal)
			if !llRetorno
				goServicios.Errores.LevantarExcepcion('El proceso debe formar parte del modelo')
			endif
		endif
		Return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function EventoDespuesDeSetear( toObject as Object, tcAtributo as String, txValOld as Variant, txVal as Variant ) as Void
		dodefault( toObject, tcAtributo, txValOld, txVal )
		if this.CargaManual()
			if "INSUMO_PK" = upper( tcAtributo ) and !( alltrim( txValOld ) == alltrim( txVal ) )
				this.UnidadDeMedida_PK = this.Insumo.RindeUnidad_PK
			endif
		endif
	endfunc 

enddefine
