*-----------------------------------------------------------------------------------------
Define Class AplicacionNucleo As AplicacionBase of AplicacionBase.prg

	#IF .f.
		Local this as AplicacionNucleo of AplicacionNucleo.prg
	#ENDIF

	Nombre = "Nucleo"
	NombreProducto = "NUCLEO"
	cProyecto = "NUCLEO"
	cListaDeEjecutables = ""

	*-----------------------------------------------------------------------------------------
	function ObtenerSucursalDefault() as Void
		return "Paises"
	endfunc 

enddefine

