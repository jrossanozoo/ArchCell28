define class ComboServicioProduccion as ComboServicio of ComboServicio.prg

	#if .f.
		local this as ComboServicioProduccion of ComboServicioProduccion.prg
	#endif

	protected cTipoRetorno 
	cTipoRetorno = ''

	xValorDefault = ''
	cValores = ''
	cAtributoRealEntidad = ''
	lAgregarValorTODOS = .t.
	cValorTodos = "-1"
	
	*-----------------------------------------------------------------------------------------
	function ObtenerDatos() as Void
		local loLista as Collection, loOrigen as Object, loError as Exception, lcLista as String
		try
			loOrigen = _Screen.zoo.CrearObjeto( "ColaboradorProduccion", "ColaboradorProduccion.prg" )
			loLista = loOrigen.ObtenerComboParaAtributo( this.ObtenerNombreDeAtributo() )
			
			lcLista = ""
			
			for each loItem in loLista FOXOBJECT
				lcLista = lcLista + loItem.Descripcion + "," + loItem.Codigo + ","
			next
			lcLista = substr( lcLista, 1, len( lcLista ) - 1 )
			
			this.cValores = lcLista
			this.xValorDefault = ""
			this.RowSource = lcLista
			release loOrigen

		catch to loError
			goServicios.Errores.LevantarExcepcion( loError )
		endtry
	endfunc 
	
enddefine
