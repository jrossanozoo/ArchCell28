define class CopiadorDeItemsStockProduccionAColeccion as custom
	oCombinacion = null

	*-----------------------------------------------------------------------------------------
	function InyectarCombinacion( toCombinacion as Object ) as Void
		this.oCombinacion = toCombinacion
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CopiarItemAColeccion( toColeccion as Object, toItem as Object, tcKey as String ) as Void
		local loItem as Object, i as Integer, lcAtributo as String, i as Integer
		loItem = _Screen.zoo.CrearObjeto( "zooColeccion" )
		for i = 1 to this.oCombinacion.count
			lcAtributo = this.oCombinacion[ i ]
			loItem.AddProperty( lcAtributo , toItem.&lcAtributo )
		endfor

		if vartype( toItem.CantidadInsumo ) = "U"
			lcAtributo = "Cantidad"
			loItem.AddProperty( lcAtributo , toItem.&lcAtributo )			
		else
			lcAtributo = "Cantidad"
			lcAtributoInsumo = "CantidadInsumo"
			loItem.AddProperty( lcAtributo , toItem.&lcAtributoInsumo )	
		endif

		lcAtributo = "NoProcesarStock"
		loItem.AddProperty( lcAtributo , toItem.&lcAtributo )
		if empty( tcKey )
			toColeccion.Add( loItem )
		else
			toColeccion.Add( loItem , tcKey )
		endif
	endfunc

enddefine
