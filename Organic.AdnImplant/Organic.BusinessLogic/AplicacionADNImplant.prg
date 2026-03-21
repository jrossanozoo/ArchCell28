*-----------------------------------------------------------------------------------------
Define Class AplicacionAdnImplant As AplicacionBase of AplicacionBase.prg

	Nombre = "AdnImplant"
	NombreProducto = "ADNIMPLANT"
	cProyecto = "ADNIMPLANT"

	*-----------------------------------------------------------------------------------------
	function ObtenerSucursalDefault() as Void
		return "ANDIMPLANT"
	endfunc 

Enddefine
