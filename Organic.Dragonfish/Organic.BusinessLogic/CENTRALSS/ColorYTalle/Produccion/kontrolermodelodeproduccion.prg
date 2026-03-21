define class KontrolerModelodeproduccion as din_KontrolerModelodeproduccion of din_KontrolerModelodeproduccion.prg

	#If .F.
		Local This as KontrolerModelodeproduccion of KontrolerModelodeproduccion.prg
	#Endif

	*-----------------------------------------------------------------------------------------
	function Inicializar() as Void
		dodefault()
		this.EnlazarControlesDeGrilla()
		bindevent( this.oEntidad, 'Cancelar', this, 'LimpiarYRefrescarGrillas' )
		bindevent( this.oEntidad, 'Grabar', this, 'LimpiarYRefrescarGrillas' )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EnlazarControlesDeGrilla() as Void
		local j as integer, loCampo as object, i as integer, llOriginalVacio as Boolean, loObjeto
		loControl = this.obtenerControl( "ModeloProcesos" )
		With loControl
			for i = 1 to .nCantidadItemsVisibles
				for j = 1 to .nCantidadColumnas
					loCampo = .ObtenerCelda( i, j )
					loObjeto = _Screen.Zoo.CrearObjeto('ItemGrilla','KontrolerModelodeproduccion.prg')
					loCampo.AddProperty('ItemGrilla',loObjeto)
					loCampo.ItemGrilla.NroFila = loCampo.nFila
					
					bindevent( loCampo, 'GotFocus', loCampo.ItemGrilla, 'GotFocus' )
					bindevent( loCampo.ItemGrilla, 'SetearFilaEnProcesos', this, 'FocoEnGrilla' )
					loObjeto = null
				endfor
			endfor
		Endwith
	endfunc 

	*-----------------------------------------------------------------------------------------
	function FocoEnGrilla( tnItem as Integer) as Void
		local loDetalle as Object, loControl as Object
		loProceso = this.obtenerControl( "ModeloProcesos" )
		loControl = loProceso.ObtenerCelda( tnItem, 1 )
		this.oEntidad.ProcesoActivo = alltrim(loControl.Value)
		if this.oEntidad.ModeloProcesos.Count > 1
			loProceso.RefrescarGrilla()
		endif
		loDetalle = this.obtenerControl( "ModeloMaquinas" )
		loDetalle.RefrescarGrilla()
		loDetalle = this.obtenerControl( "ModeloInsumos" )
		loDetalle.RefrescarGrilla()
		loDetalle = this.obtenerControl( "ModeloSalidas" )
		loDetalle.RefrescarGrilla()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function VerificarFormateosDeLaFilaActiva( tcDetalle as string, toControl as Object ) as Void
		local lcIdItem as String
		if This.oEntidad.EsModoEdicion()
			toControl.FontItalic = .F.
			toControl.FontBold = .F.

			if inlist( upper(alltrim(tcDetalle)), "MODELOPROCESOS", "MODELOMAQUINAS", "MODELOINSUMOS", "MODELOSALIDAS")
				this.AsignarFormatoItemActivoSegunProcesoSeleccionado(tcDetalle, toControl)
			endif
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function VerificarFormateosDeLaFilaPlana( tcDetalle as string, toControl as Object, tnRegistroIncioPantalla as integer ) as void
		local lcIdItem as String
		if This.oEntidad.EsModoEdicion()
			toControl.FontItalic = .F.
			toControl.FontBold = .F.
			if inlist( upper(alltrim(tcDetalle)), "MODELOPROCESOS", "MODELOMAQUINAS", "MODELOINSUMOS", "MODELOSALIDAS")
				this.AsignarFormatoItemPlanoSegunProcesoSeleccionado(tcDetalle, toControl, tnRegistroIncioPantalla)
			endif
		endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AsignarFormatoItemActivoSegunProcesoSeleccionado(tcDetalle as string, toControl as Object) as Void
		local lcIdItem as String
		if This.oEntidad.EsModoEdicion()
			lcIdItem = This.ObtenerValorAtributoItemActivoSegunAtributo( tcDetalle, "Proceso_PK" )
			if !empty(lcIdItem) and (lcIdItem = this.oEntidad.ProcesoActivo)
				toControl.FontItalic = .t.
				toControl.FontBold = .T.
			Endif
		Endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function AsignarFormatoItemPlanoSegunProcesoSeleccionado(tcDetalle as string, toControl as Object, tnRegistroIncioPantalla as integer) as Void
		local lcIdItem as String
		if This.oEntidad.EsModoEdicion()
			lcIdItem = This.ObtenerValorAtributoPlanoSegunAtributoFila( tcDetalle, toControl.nFila, "Proceso_PK", tnRegistroIncioPantalla )
			if !empty(lcIdItem) and (lcIdItem = this.oEntidad.ProcesoActivo)
				toControl.FontItalic = .t.
				toControl.FontBold = .T.
			Endif
		Endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function LimpiarYRefrescarGrillas() as Void
		local loDetalle as Object, loControl as Object
		loProceso = this.obtenerControl( "ModeloProcesos" )
		this.oEntidad.ProcesoActivo = ""
		loProceso.RefrescarGrilla()
		loDetalle = this.obtenerControl( "ModeloMaquinas" )
		loDetalle.RefrescarGrilla()
		loDetalle = this.obtenerControl( "ModeloInsumos" )
		loDetalle.RefrescarGrilla()
		loDetalle = this.obtenerControl( "ModeloSalidas" )
		loDetalle.RefrescarGrilla()
	endfunc 


enddefine

*-----------------------------------------------------------------------------------------
define class ItemGrilla as Custom

	NroFila = 0
	Detalle = ''

	*-----------------------------------------------------------------------------------------
	function GotFocus() as Void
		this.SetearFilaEnProcesos( this.NroFila  )
		dodefault()
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SetearFilaEnProcesos( tnFila as Integer) as Void
	endfunc 

enddefine
