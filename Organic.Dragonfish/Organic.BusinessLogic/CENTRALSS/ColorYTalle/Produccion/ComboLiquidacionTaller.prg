define class ComboLiquidacionTaller as ZOOCOMBOBOX of ZOOCOMBOBOX.prg

	#if .f.
		local this as ComboLiquidacionTaller of ComboLiquidacionTaller.prg
	#endif

	*-----------------------------------------------------------------------------------------
	function CompletarCombo() as Void
		local loValores as zoocoleccion OF zoocoleccion.prg, loItem as ItemValorEtiqueta of ZooComboBox.prg
			
		this.ColumnCount = 2
		this.BoundTo = .t.
		this.BoundColumn = 2
		this.RowsourceType = 1
		this.ColumnLines = .f.
		this.ColumnWidths = "260,0"
				
		loValores = this.ObtenerValoresCombo()
		
		for each loItem in loValores
			this.RowSource = this.RowSource + loItem.cEtiqueta + ","+ transform( loItem.xValor ) + ","
		endfor
		
		this.value = null
		
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ObtenerValoresCombo( toParametros as zoocoleccion OF zoocoleccion.prg ) as zoocoleccion OF zoocoleccion.prg
		local loColeccion as zoocoleccion OF zoocoleccion.prg, loItem as ItemValorEtiqueta of ZooComboBox.prg
		
		loColeccion = _Screen.zoo.CrearObjeto( "zoocoleccion" )

		loItem = newobject( "ItemValorEtiqueta", "ZooComboBox.prg" )
		loItem.cEtiqueta = space(30)
		loItem.xValor = 0
		loColeccion.Agregar( loItem )

		loItem = newobject( "ItemValorEtiqueta", "ZooComboBox.prg" )
		loItem.cEtiqueta = "Incluir en la liquidación"
		loItem.xValor = 1
		loColeccion.Agregar( loItem )

		loItem = newobject( "ItemValorEtiqueta", "ZooComboBox.prg" )
		loItem.cEtiqueta = "No incluir en la liquidación"
		loItem.xValor = 2
		loColeccion.Agregar( loItem )
		
		return loColeccion
	endfunc 	

	*------------------------------------------------------------------------
	function ObtenerMontoVenta( tnPrecio as Number, tnCantidad as Number ) as Number
	    local lnRetorno as Number
	    lnRetorno = tnPrecio * tnCantidad
	    return lnRetorno
	endfunc

enddefine
